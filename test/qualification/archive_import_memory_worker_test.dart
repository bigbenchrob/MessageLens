import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/message_extractor_port.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const int _fixtureInsertBatchSize = 1000;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'runs the synthetic archive import memory workload',
    () async {
      final databasePath = Platform.environment['ML_MEMORY_DB_PATH'];
      final mode = Platform.environment['ML_MEMORY_MODE'];
      final candidateCount = int.tryParse(
        Platform.environment['ML_MEMORY_CANDIDATE_COUNT'] ?? '',
      );
      final blobBytes = int.tryParse(
        Platform.environment['ML_MEMORY_BLOB_BYTES'] ?? '',
      );
      if (databasePath == null ||
          mode == null ||
          candidateCount == null ||
          blobBytes == null) {
        markTestSkipped('Run through tool/archive_import_memory_harness.dart.');
        return;
      }

      final database = await ImportDatabase.open(
        databaseDirectory: File(databasePath).parent.path,
        databaseName: File(databasePath).uri.pathSegments.last,
      );
      try {
        if (mode == 'prepare') {
          await _populateSyntheticCandidates(
            database,
            candidateCount: candidateCount,
            baseBlobBytes: blobBytes,
          );
          return;
        }
        if (mode != 'enrich') {
          throw StateError('Unknown memory harness mode: $mode');
        }

        final stopwatch = Stopwatch()..start();
        final result = await MessageRichTextEnricher(
          chatDbPath: '/synthetic/chat.db',
          importLedger: database,
          extractor: const _SyntheticExtractor(),
        ).enrichMissingText();
        stopwatch.stop();

        expect(result.candidateMessageCount, candidateCount);
        expect(result.enrichedMessageCount, candidateCount);
        expect(result.missingExtractionCount, 0);
        // This content-free line is retained by the parent harness as timing and
        // completion evidence. It contains no database path or message content.
        stdout.writeln(
          'ML_MEMORY_RESULT candidates=$candidateCount '
          'elapsedMilliseconds=${stopwatch.elapsedMilliseconds}',
        );
      } finally {
        await database.close();
      }
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );
}

Future<void> _populateSyntheticCandidates(
  ImportDatabase database, {
  required int candidateCount,
  required int baseBlobBytes,
}) async {
  const archiveSourceId = 3;
  await database.database.insert('source_registry', <String, Object?>{
    'source_id': archiveSourceId,
    'source_key': 'synthetic-archive',
    'source_kind': 'historical_messages_archive',
    'created_at_utc': DateTime.now().toUtc().toIso8601String(),
  });
  final liveBatchId = await database.insertImportBatch(
    sourceId: liveChatDbSourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );
  final archiveBatchId = await database.insertImportBatch(
    sourceId: archiveSourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );

  for (
    var start = 0;
    start < candidateCount;
    start += _fixtureInsertBatchSize
  ) {
    final end = (start + _fixtureInsertBatchSize < candidateCount)
        ? start + _fixtureInsertBatchSize
        : candidateCount;
    final batch = database.database.batch();
    for (var index = start; index < end; index += 1) {
      final useArchiveSource = index > 0 && index % 100 == 0;
      final sourceId = useArchiveSource ? archiveSourceId : liveChatDbSourceId;
      final sourceRowId = useArchiveSource
          ? ((index - 1) * 2) + 1
          : (index * 2) + 1;
      final size = switch (index) {
        _ when index % 5000 == 0 => baseBlobBytes * 32,
        _ when index % 101 == 0 => baseBlobBytes * 8,
        _ when index % 17 == 0 => baseBlobBytes * 2,
        _ => baseBlobBytes,
      };
      final blob = Uint8List(size);
      blob.fillRange(0, blob.length, index % 251);
      batch.insert('messages', <String, Object?>{
        'ss_id': SourceScopedRowKey.pack(
          sourceId: sourceId,
          sourceRowId: sourceRowId,
        ),
        'source_id': sourceId,
        'source_rowid': sourceRowId,
        'guid': 'synthetic-$sourceId-$sourceRowId',
        'is_from_me': index.isEven ? 1 : 0,
        'text': null,
        'attributed_body_blob': blob,
        'batch_id': useArchiveSource ? archiveBatchId : liveBatchId,
      });
    }
    await batch.commit(noResult: true);
  }
}

final class _SyntheticExtractor implements MessageExtractorPort {
  const _SyntheticExtractor();

  @override
  Future<Map<int, String>> extractAllMessageTexts({
    int? limit,
    String? dbPath,
  }) async {
    throw StateError('The memory harness exercises blob extraction only.');
  }

  @override
  Future<Map<int, String>> extractMessageTextsFromBlobs(
    Map<int, Uint8List> attributedBodyBlobsByWorkId, {
    MessageExtractionProgressObserver? onProgress,
  }) async {
    return <int, String>{
      for (final workId in attributedBodyBlobsByWorkId.keys)
        workId: 'synthetic',
    };
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> isBlobExtractionAvailable() async => true;
}
