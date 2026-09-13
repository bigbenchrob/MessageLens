import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_page_metric.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_work_progress.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/import_ledger_port.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/message_extractor_port.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ss_rich_text_test_');
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
  });

  tearDown(() async {
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'enriches attributed-body rows without changing existing text',
    () async {
      await _insertImportMessage(
        importDatabase,
        sourceRowId: 100,
        text: null,
        attributedBodyBlob: Uint8List.fromList(<int>[1, 2, 3]),
      );
      await _insertImportMessage(
        importDatabase,
        sourceRowId: 101,
        text: 'already text',
        attributedBodyBlob: Uint8List.fromList(<int>[4, 5, 6]),
      );
      await _insertImportMessage(importDatabase, sourceRowId: 102, text: null);

      final result = await MessageRichTextEnricher(
        chatDbPath: '/fake/chat.db',
        importLedger: importDatabase,
        extractor: const _FakeExtractor(<int, String>{100: ' decoded text '}),
      ).enrichMissingText();

      final rows = await importDatabase.database.query(
        'messages',
        columns: <String>['source_rowid', 'text'],
        orderBy: 'source_rowid ASC',
      );

      expect(result.candidateMessageCount, 1);
      expect(result.enrichedMessageCount, 1);
      expect(result.missingExtractionCount, 0);
      expect(rows.map((row) => row['text']), [
        'decoded text',
        'already text',
        null,
      ]);
    },
  );

  test('is idempotent after text has been enriched', () async {
    await _insertImportMessage(
      importDatabase,
      sourceRowId: 100,
      text: null,
      attributedBodyBlob: Uint8List.fromList(<int>[1, 2, 3]),
    );

    final enricher = MessageRichTextEnricher(
      chatDbPath: '/fake/chat.db',
      importLedger: importDatabase,
      extractor: const _FakeExtractor(<int, String>{100: 'decoded text'}),
    );

    final first = await enricher.enrichMissingText();
    final second = await enricher.enrichMissingText();

    expect(first.enrichedMessageCount, 1);
    expect(second.candidateMessageCount, 0);
    expect(second.enrichedMessageCount, 0);
  });

  test(
    'enriches only messages after source rowid for incremental builds',
    () async {
      await _insertImportMessage(
        importDatabase,
        sourceRowId: 100,
        text: null,
        attributedBodyBlob: Uint8List.fromList(<int>[1, 2, 3]),
      );
      await _insertImportMessage(
        importDatabase,
        sourceRowId: 101,
        text: null,
        attributedBodyBlob: Uint8List.fromList(<int>[4, 5, 6]),
      );

      final result =
          await MessageRichTextEnricher(
            chatDbPath: '/fake/chat.db',
            importLedger: importDatabase,
            extractor: const _FakeExtractor(<int, String>{
              100: 'previous decoded text',
              101: 'new decoded text',
            }),
          ).enrichMissingTextAfterSourceRowId(
            sourceId: liveChatDbSourceId,
            startedAfterSourceRowId: 100,
          );
      final rows = await importDatabase.database.query(
        'messages',
        columns: <String>['source_rowid', 'text'],
        orderBy: 'source_rowid ASC',
      );

      expect(result.candidateMessageCount, 1);
      expect(result.enrichedMessageCount, 1);
      expect(rows.map((row) => row['text']), [null, 'new decoded text']);
    },
  );

  test(
    'systemic extractor unavailability fails without mutating rows',
    () async {
      await _insertImportMessage(
        importDatabase,
        sourceRowId: 100,
        text: null,
        attributedBodyBlob: Uint8List.fromList(<int>[1, 2, 3]),
      );

      await expectLater(
        MessageRichTextEnricher(
          chatDbPath: '/fake/chat.db',
          importLedger: importDatabase,
          extractor: const _FakeExtractor(<int, String>{
            100: 'decoded',
          }, available: false),
        ).enrichMissingText(),
        throwsA(
          isA<SourceImportSystemicException>().having(
            (error) => error.failureCode,
            'failure code',
            'typedstream_decoder_unavailable',
          ),
        ),
      );
      final rows = await importDatabase.database.query('messages');

      expect(rows.single['text'], isNull);
    },
  );

  test('one undecodable attributed body is local and accounted', () async {
    await _insertImportMessage(
      importDatabase,
      sourceRowId: 100,
      text: null,
      attributedBodyBlob: Uint8List.fromList(<int>[1, 2, 3]),
    );

    final result = await MessageRichTextEnricher(
      chatDbPath: '/fake/chat.db',
      importLedger: importDatabase,
      extractor: const _FakeExtractor(<int, String>{}),
    ).enrichMissingText();

    expect(result.candidateMessageCount, 1);
    expect(result.enrichedMessageCount, 0);
    expect(result.missingExtractionCount, 1);
    expect(result.anomalyCounts.richTextDecodeUnavailableCount, 1);
    expect(
      (await importDatabase.database.query('messages')).single['text'],
      isNull,
    );
  });

  test(
    'over-budget body is not materialized or decoded and later rows continue',
    () async {
      await _insertImportMessage(
        importDatabase,
        sourceRowId: 100,
        text: null,
        attributedBodyBlob: Uint8List(9),
      );
      await _insertImportMessage(
        importDatabase,
        sourceRowId: 101,
        text: null,
        attributedBodyBlob: Uint8List(4),
      );
      final extractor = _RecordingExtractor();

      final result = await MessageRichTextEnricher(
        chatDbPath: '/fake/chat.db',
        importLedger: importDatabase,
        extractor: extractor,
        candidatePageSize: 2,
        pageBlobByteTarget: 8,
        maximumAttributedBodyBlobBytes: 8,
      ).enrichMissingText();
      final rows = await importDatabase.database.query(
        'messages',
        columns: <String>['source_rowid', 'text', 'attributed_body_blob'],
        orderBy: 'source_rowid ASC',
      );

      expect(result.candidateMessageCount, 2);
      expect(result.enrichedMessageCount, 1);
      expect(result.missingExtractionCount, 1);
      expect(extractor.calls, hasLength(1));
      expect(_totalBlobBytes(extractor.calls.single), 4);
      expect(rows.first['text'], isNull);
      expect(
        rows.first['attributed_body_blob'],
        isA<Uint8List>().having((blob) => blob.length, 'length', 9),
      );
      expect(rows.last['text'], 'decoded');
    },
  );

  test(
    'bounds decoder calls by candidate count and cumulative bytes',
    () async {
      final blobSizes = <int>[4, 4, 4, 12, 4, 4, 4];
      for (var index = 0; index < blobSizes.length; index += 1) {
        await _insertImportMessage(
          importDatabase,
          sourceRowId: index + 1,
          text: null,
          attributedBodyBlob: Uint8List(blobSizes[index]),
        );
      }
      final extractor = _RecordingExtractor();
      final metrics = <SourceImportPageMetric>[];

      final result = await MessageRichTextEnricher(
        chatDbPath: '/fake/chat.db',
        importLedger: importDatabase,
        extractor: extractor,
        candidatePageSize: 3,
        pageBlobByteTarget: 8,
        onPageMetric: metrics.add,
      ).enrichMissingText();

      expect(result.candidateMessageCount, 7);
      expect(result.enrichedMessageCount, 7);
      expect(extractor.calls.map((call) => call.length), <int>[2, 1, 1, 2, 1]);
      expect(extractor.calls.map(_totalBlobBytes), <int>[8, 4, 12, 8, 4]);
      expect(metrics.map((metric) => metric.pageRowCount), <int>[
        2,
        1,
        1,
        2,
        1,
      ]);
      expect(metrics.map((metric) => metric.cumulativeCompletedCount), <int>[
        2,
        3,
        4,
        6,
        7,
      ]);
      expect(metrics.map((metric) => metric.totalWorkCount).toSet(), <int>{7});
      expect(
        extractor.calls.where((call) => _totalBlobBytes(call) > 8),
        everyElement(hasLength(1)),
      );
    },
  );

  test('uses source-scoped identity when source row IDs collide', () async {
    const duplicateSourceRowId = 50;
    const archiveSourceId = 3;
    await _insertImportMessage(
      importDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: duplicateSourceRowId,
      text: null,
      attributedBodyBlob: Uint8List.fromList(<int>[1]),
    );
    await _insertImportMessage(
      importDatabase,
      sourceId: archiveSourceId,
      sourceRowId: duplicateSourceRowId,
      text: null,
      attributedBodyBlob: Uint8List.fromList(<int>[2]),
    );
    final liveSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: duplicateSourceRowId,
    );
    final archiveSsId = SourceScopedRowKey.pack(
      sourceId: archiveSourceId,
      sourceRowId: duplicateSourceRowId,
    );

    final result = await MessageRichTextEnricher(
      chatDbPath: '/fake/chat.db',
      importLedger: importDatabase,
      extractor: _RecordingExtractor(
        decodedTextByWorkId: <int, String>{
          liveSsId: 'live text',
          archiveSsId: 'archive text',
        },
      ),
      candidatePageSize: 1,
    ).enrichMissingText();
    final rows = await importDatabase.database.query(
      'messages',
      columns: <String>['source_id', 'text'],
      orderBy: 'source_id ASC',
    );

    expect(result.enrichedMessageCount, 2);
    expect(rows, <Map<String, Object?>>[
      <String, Object?>{'source_id': liveChatDbSourceId, 'text': 'live text'},
      <String, Object?>{'source_id': archiveSourceId, 'text': 'archive text'},
    ]);
  });

  test('committed decoder pages survive a later decoder failure', () async {
    for (var rowId = 1; rowId <= 5; rowId += 1) {
      await _insertImportMessage(
        importDatabase,
        sourceRowId: rowId,
        text: null,
        attributedBodyBlob: Uint8List.fromList(<int>[rowId]),
      );
    }
    final failingExtractor = _RecordingExtractor(failOnCall: 2);

    await expectLater(
      MessageRichTextEnricher(
        chatDbPath: '/fake/chat.db',
        importLedger: importDatabase,
        extractor: failingExtractor,
        candidatePageSize: 2,
      ).enrichMissingText(),
      throwsStateError,
    );
    final afterFailure = await importDatabase.database.query(
      'messages',
      columns: <String>['source_rowid', 'text'],
      orderBy: 'source_rowid ASC',
    );
    expect(afterFailure.map((row) => row['text']), <Object?>[
      'decoded',
      'decoded',
      null,
      null,
      null,
    ]);

    final retryExtractor = _RecordingExtractor();
    final retry = await MessageRichTextEnricher(
      chatDbPath: '/fake/chat.db',
      importLedger: importDatabase,
      extractor: retryExtractor,
      candidatePageSize: 2,
    ).enrichMissingText();

    expect(retry.candidateMessageCount, 3);
    expect(retry.enrichedMessageCount, 3);
    final replayedSourceRowIds = retryExtractor.calls
        .expand((call) => call.keys)
        .map(SourceScopedRowKey.unpackSourceRowId);
    expect(replayedSourceRowIds, <int>[3, 4, 5]);
  });

  test('decoder output is not durable before its page transaction', () async {
    for (var rowId = 1; rowId <= 3; rowId += 1) {
      await _insertImportMessage(
        importDatabase,
        sourceRowId: rowId,
        text: null,
        attributedBodyBlob: Uint8List.fromList(<int>[rowId]),
      );
    }
    final interruptedLedger = _InterruptingImportLedger(
      importDatabase,
      failBeforeTransaction: 1,
    );

    await expectLater(
      MessageRichTextEnricher(
        chatDbPath: '/fake/chat.db',
        importLedger: interruptedLedger,
        extractor: _RecordingExtractor(),
        candidatePageSize: 2,
      ).enrichMissingText(),
      throwsStateError,
    );

    expect(
      (await importDatabase.database.query(
        'messages',
        columns: <String>['text'],
      )).map((row) => row['text']),
      everyElement(isNull),
    );
  });

  test('retry skips a page committed just before interruption', () async {
    for (var rowId = 1; rowId <= 5; rowId += 1) {
      await _insertImportMessage(
        importDatabase,
        sourceRowId: rowId,
        text: null,
        attributedBodyBlob: Uint8List.fromList(<int>[rowId]),
      );
    }
    final interruptedLedger = _InterruptingImportLedger(
      importDatabase,
      failAfterTransaction: 2,
    );

    await expectLater(
      MessageRichTextEnricher(
        chatDbPath: '/fake/chat.db',
        importLedger: interruptedLedger,
        extractor: _RecordingExtractor(),
        candidatePageSize: 2,
      ).enrichMissingText(),
      throwsStateError,
    );
    expect(
      (await importDatabase.database.query(
        'messages',
        columns: <String>['text'],
        orderBy: 'source_rowid ASC',
      )).map((row) => row['text']),
      <Object?>['decoded', 'decoded', 'decoded', 'decoded', null],
    );

    final retryExtractor = _RecordingExtractor();
    final retry = await MessageRichTextEnricher(
      chatDbPath: '/fake/chat.db',
      importLedger: importDatabase,
      extractor: retryExtractor,
      candidatePageSize: 2,
    ).enrichMissingText();

    expect(retry.candidateMessageCount, 1);
    expect(retry.enrichedMessageCount, 1);
    expect(
      retryExtractor.calls.single.keys
          .map(SourceScopedRowKey.unpackSourceRowId)
          .single,
      5,
    );
  });

  test('defers candidates above the frozen ss_id window', () async {
    for (final rowId in <int>[1, 2]) {
      await _insertImportMessage(
        importDatabase,
        sourceRowId: rowId,
        text: null,
        attributedBodyBlob: Uint8List.fromList(<int>[rowId]),
      );
    }
    final extractor = _RecordingExtractor(
      onAfterCall: (callNumber) async {
        if (callNumber == 1) {
          await _insertImportMessage(
            importDatabase,
            sourceRowId: 3,
            text: null,
            attributedBodyBlob: Uint8List.fromList(<int>[3]),
          );
        }
      },
    );

    final first = await MessageRichTextEnricher(
      chatDbPath: '/fake/chat.db',
      importLedger: importDatabase,
      extractor: extractor,
      candidatePageSize: 1,
    ).enrichMissingText();
    final second = await MessageRichTextEnricher(
      chatDbPath: '/fake/chat.db',
      importLedger: importDatabase,
      extractor: _RecordingExtractor(),
      candidatePageSize: 1,
    ).enrichMissingText();

    expect(first.candidateMessageCount, 2);
    expect(first.enrichedMessageCount, 2);
    expect(second.candidateMessageCount, 1);
    expect(second.enrichedMessageCount, 1);
  });

  test(
    'reports cumulative monotonic progress including missing decodes',
    () async {
      await _insertManyImportMessages(importDatabase, count: 1001);
      final observations = <SourceImportWorkProgress>[];
      final extractor = _RecordingExtractor(
        unavailableSourceRowIds: <int>{
          for (var rowId = 1; rowId <= 1001; rowId += 100) rowId,
        },
      );

      final result = await MessageRichTextEnricher(
        chatDbPath: '/fake/chat.db',
        importLedger: importDatabase,
        extractor: extractor,
        candidatePageSize: 500,
      ).enrichMissingText(onProgress: observations.add);
      final extraction = observations
          .where(
            (value) => value.unit == SourceImportWorkUnit.richTextExtraction,
          )
          .toList(growable: false);
      final persistence = observations
          .where(
            (value) => value.unit == SourceImportWorkUnit.richTextPersistence,
          )
          .toList(growable: false);

      expect(result.candidateMessageCount, 1001);
      expect(result.missingExtractionCount, 11);
      for (final progress in <List<SourceImportWorkProgress>>[
        extraction,
        persistence,
      ]) {
        expect(progress.first.completedWorkCount, 0);
        expect(progress.last.completedWorkCount, 1001);
        expect(progress.map((value) => value.totalWorkCount).toSet(), <int>{
          1001,
        });
        for (var index = 1; index < progress.length; index += 1) {
          expect(
            progress[index].completedWorkCount,
            greaterThanOrEqualTo(progress[index - 1].completedWorkCount),
          );
        }
      }
      expect((await importDatabase.database.query('messages')).length, 1001);
    },
  );
}

class _FakeExtractor implements MessageExtractorPort {
  const _FakeExtractor(this.extracted, {this.available = true});

  final Map<int, String> extracted;
  final bool available;

  @override
  Future<Map<int, String>> extractAllMessageTexts({
    int? limit,
    String? dbPath,
  }) async {
    throw StateError('SS rich text enrichment must decode import blobs');
  }

  @override
  Future<Map<int, String>> extractMessageTextsFromBlobs(
    Map<int, Uint8List> attributedBodyBlobsByWorkId, {
    MessageExtractionProgressObserver? onProgress,
  }) async {
    return <int, String>{
      for (final workId in attributedBodyBlobsByWorkId.keys)
        if (extracted[workId] ??
                extracted[SourceScopedRowKey.unpackSourceRowId(workId)]
            case final String value)
          workId: value,
    };
  }

  @override
  Future<bool> isAvailable() async {
    return available;
  }

  @override
  Future<bool> isBlobExtractionAvailable() async {
    return available;
  }
}

final class _RecordingExtractor implements MessageExtractorPort {
  _RecordingExtractor({
    this.decodedTextByWorkId,
    this.unavailableSourceRowIds = const <int>{},
    this.failOnCall,
    this.onAfterCall,
  });

  final Map<int, String>? decodedTextByWorkId;
  final Set<int> unavailableSourceRowIds;
  final int? failOnCall;
  final Future<void> Function(int callNumber)? onAfterCall;
  final calls = <Map<int, Uint8List>>[];

  @override
  Future<Map<int, String>> extractAllMessageTexts({
    int? limit,
    String? dbPath,
  }) async {
    throw StateError('SS rich text enrichment must decode import blobs');
  }

  @override
  Future<Map<int, String>> extractMessageTextsFromBlobs(
    Map<int, Uint8List> attributedBodyBlobsByWorkId, {
    MessageExtractionProgressObserver? onProgress,
  }) async {
    final call = Map<int, Uint8List>.from(attributedBodyBlobsByWorkId);
    calls.add(call);
    final callNumber = calls.length;
    if (failOnCall == callNumber) {
      throw StateError('injected decoder interruption');
    }
    if (onAfterCall case final callback?) {
      await callback(callNumber);
    }
    final result = <int, String>{
      for (final workId in call.keys)
        if (!unavailableSourceRowIds.contains(
          SourceScopedRowKey.unpackSourceRowId(workId),
        ))
          workId: decodedTextByWorkId?[workId] ?? 'decoded',
    };
    if (call.isNotEmpty) {
      final lastWorkId = call.keys.last;
      onProgress?.call(
        completedWorkCount: call.length,
        totalWorkCount: call.length,
        lastCompletedWorkId: lastWorkId,
      );
    }
    return result;
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> isBlobExtractionAvailable() async => true;
}

Future<void> _insertImportMessage(
  ImportDatabase importDatabase, {
  int sourceId = liveChatDbSourceId,
  required int sourceRowId,
  required String? text,
  Uint8List? attributedBodyBlob,
}) async {
  if (sourceId != liveChatDbSourceId) {
    await importDatabase.database.insert('source_registry', <String, Object?>{
      'source_id': sourceId,
      'source_key': 'test-source-$sourceId',
      'source_kind': 'historical_messages_archive',
      'created_at_utc': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  final batchId = await importDatabase.insertImportBatch(
    sourceId: sourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );
  await importDatabase.database.insert('messages', <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': sourceId,
    'source_rowid': sourceRowId,
    'guid': 'message-$sourceId-$sourceRowId',
    'is_from_me': 0,
    'text': text,
    'attributed_body_blob': attributedBodyBlob,
    'batch_id': batchId,
  });
}

Future<void> _insertManyImportMessages(
  ImportDatabase importDatabase, {
  required int count,
}) async {
  final batchId = await importDatabase.insertImportBatch(
    sourceId: liveChatDbSourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );
  final batch = importDatabase.database.batch();
  for (var sourceRowId = 1; sourceRowId <= count; sourceRowId += 1) {
    batch.insert('messages', <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: sourceRowId,
      ),
      'source_id': liveChatDbSourceId,
      'source_rowid': sourceRowId,
      'guid': 'message-$liveChatDbSourceId-$sourceRowId',
      'is_from_me': 0,
      'text': null,
      'attributed_body_blob': Uint8List.fromList(<int>[sourceRowId % 251]),
      'batch_id': batchId,
    });
  }
  await batch.commit(noResult: true);
}

int _totalBlobBytes(Map<int, Uint8List> blobs) {
  return blobs.values.fold<int>(0, (total, blob) => total + blob.length);
}

final class _InterruptingImportLedger implements ImportLedger {
  _InterruptingImportLedger(
    this.delegate, {
    this.failBeforeTransaction,
    this.failAfterTransaction,
  });

  final ImportLedger delegate;
  final int? failBeforeTransaction;
  final int? failAfterTransaction;
  var _transactionCount = 0;

  @override
  Future<SourceScopedImportSourceDeletionResult> deleteRowsForSource({
    required int sourceId,
  }) {
    return delegate.deleteRowsForSource(sourceId: sourceId);
  }

  @override
  Future<int> getOrCreateSource({
    required String sourceKey,
    required String sourceKind,
    String? sourceLabel,
  }) {
    return delegate.getOrCreateSource(
      sourceKey: sourceKey,
      sourceKind: sourceKind,
      sourceLabel: sourceLabel,
    );
  }

  @override
  Future<int> insertImportBatch({
    required int sourceId,
    required String startedAtUtc,
  }) {
    return delegate.insertImportBatch(
      sourceId: sourceId,
      startedAtUtc: startedAtUtc,
    );
  }

  @override
  Future<int?> maxAttachmentSourceRowIdForSource(int sourceId) {
    return delegate.maxAttachmentSourceRowIdForSource(sourceId);
  }

  @override
  Future<int?> maxHandleSourceRowIdForSource(int sourceId) {
    return delegate.maxHandleSourceRowIdForSource(sourceId);
  }

  @override
  Future<int?> maxMessageSourceRowIdForSource(int sourceId) {
    return delegate.maxMessageSourceRowIdForSource(sourceId);
  }

  @override
  Future<int> messageCountForSource(int sourceId) {
    return delegate.messageCountForSource(sourceId);
  }

  @override
  Future<ImportLedgerMessageStatusSnapshot> messageStatusForSource(
    int sourceId,
  ) {
    return delegate.messageStatusForSource(sourceId);
  }

  @override
  Future<ImportLedgerMessageTextWindow> messageTextEnrichmentWindow({
    int? sourceId,
    int? startedAfterSourceRowId,
  }) {
    return delegate.messageTextEnrichmentWindow(
      sourceId: sourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
    );
  }

  @override
  Future<ImportLedgerProjectionStatusSnapshot> projectionStatusSnapshot() {
    return delegate.projectionStatusSnapshot();
  }

  @override
  Future<List<Map<String, Object?>>> queryTable(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) {
    return delegate.queryTable(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  @override
  Future<List<ImportLedgerMessageTextCandidate>> readMessageTextEnrichmentPage({
    required int afterSsId,
    required int throughSsId,
    required int limit,
    int? sourceId,
    int? startedAfterSourceRowId,
  }) {
    return delegate.readMessageTextEnrichmentPage(
      afterSsId: afterSsId,
      throughSsId: throughSsId,
      limit: limit,
      sourceId: sourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
    );
  }

  @override
  Future<Map<int, Uint8List>> readMessageTextEnrichmentBlobs({
    required List<int> ssIds,
    required int maximumBlobBytes,
  }) {
    return delegate.readMessageTextEnrichmentBlobs(
      ssIds: ssIds,
      maximumBlobBytes: maximumBlobBytes,
    );
  }

  @override
  Future<int?> sourceIdForKey(String sourceKey) {
    return delegate.sourceIdForKey(sourceKey);
  }

  @override
  Future<T> writeTransaction<T>(
    Future<T> Function(ImportLedgerWriteTransaction txn) action,
  ) async {
    _transactionCount += 1;
    if (_transactionCount == failBeforeTransaction) {
      throw StateError('injected before page persistence');
    }
    final result = await delegate.writeTransaction(action);
    if (_transactionCount == failAfterTransaction) {
      throw StateError('injected after page persistence');
    }
    return result;
  }
}
