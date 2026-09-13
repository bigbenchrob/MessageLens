import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/date_converter.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_page_metric.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_work_progress.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/source_database_port.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late String chatDbPath;
  late ImportDatabase importDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('message_import_ss_test_');
    chatDbPath = '${tempDir.path}/chat.db';
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    await _createSourceMessageTable(chatDbPath);
  });

  tearDown(() async {
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('imports messages into source-scoped ledger schema', () async {
    final appleDate = DateConverter.dateString2Apple('2026-05-19');
    await _insertSourceMessage(
      chatDbPath,
      rowId: 101,
      guid: 'message-101',
      handleId: 42,
      isFromMe: 0,
      date: appleDate,
      text: 'hello',
      associatedMessageGuid: 'associated-1',
      itemType: 1,
      associatedMessageType: 2000,
      threadOriginatorGuid: 'thread-originator-1',
      error: 404,
      isSystemMessage: 1,
      attributedBody: Uint8List.fromList(<int>[1, 2, 3]),
      messageSummaryInfo: Uint8List.fromList(<int>[4, 5, 6]),
      payloadData: Uint8List.fromList(<int>[7, 8, 9]),
    );

    final importer = MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );

    final result = await importer.importNewMessages();

    expect(result.startedAfterSourceRowId, 0);
    expect(result.insertedMessageCount, 1);
    expect(result.lastImportedSourceRowId, 101);

    final rows = await importDatabase.database.query('messages');

    expect(rows, hasLength(1));
    expect(
      rows.single['ss_id'],
      SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 101),
    );
    expect(rows.single['source_id'], liveChatDbSourceId);
    expect(rows.single['source_rowid'], 101);
    expect(rows.single['guid'], 'message-101');
    expect(
      rows.single['sender_handle_ss_id'],
      SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 42),
    );
    expect(rows.single['is_from_me'], 0);
    expect(rows.single['date_utc'], DateConverter.appleToIsoString(appleDate));
    expect(rows.single['text'], 'hello');
    expect(rows.single['associated_message_guid'], 'associated-1');
    expect(rows.single['raw_item_type'], 1);
    expect(rows.single['raw_associated_message_type'], 2000);
    expect(rows.single['thread_originator_guid'], 'thread-originator-1');
    expect(rows.single['error_code'], 404);
    expect(rows.single['is_system_message'], 1);
    expect(rows.single['has_attributed_body_source'], 1);
    expect(rows.single['has_message_summary_info'], 1);
    expect(rows.single['has_payload_data_source'], 1);
  });

  test(
    'imports old Apple-second and modern nanosecond dates compatibly',
    () async {
      final archiveSourceId = await importDatabase.getOrCreateSource(
        sourceKey: 'historical-test-source',
        sourceKind: 'historical_messages_archive',
      );
      expect(archiveSourceId, 3);

      await _insertSourceMessage(
        chatDbPath,
        rowId: 1,
        guid: 'archive-2012',
        handleId: 0,
        isFromMe: 0,
        date: 364929382,
        text: 'old',
      );
      const modernAppleTimestamp = 808531200000000000;
      await _insertSourceMessage(
        chatDbPath,
        rowId: 2,
        guid: 'modern-2026',
        handleId: 0,
        isFromMe: 0,
        date: modernAppleTimestamp,
        text: 'modern',
      );

      final importer = MessageImporter(
        chatDbPath: chatDbPath,
        importLedger: importDatabase,
        sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
        sourceId: archiveSourceId,
      );

      await importer.importNewMessages();
      final rows = await importDatabase.database.query(
        'messages',
        orderBy: 'source_rowid ASC',
      );

      expect(rows, hasLength(2));
      expect(rows[0]['date_utc'], '2012-07-25T17:16:22.000Z');
      expect(rows[1]['date_utc'], '2026-08-16T00:00:00.000Z');
    },
  );

  test('is idempotent on repeated imports', () async {
    await _insertSourceMessage(
      chatDbPath,
      rowId: 1,
      guid: 'message-1',
      handleId: 2,
      isFromMe: 1,
      text: 'one',
    );

    final importer = MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );

    final firstResult = await importer.importNewMessages();
    final secondResult = await importer.importNewMessages();
    final rows = await importDatabase.database.query('messages');

    expect(firstResult.insertedMessageCount, 1);
    expect(secondResult.startedAfterSourceRowId, 1);
    expect(secondResult.insertedMessageCount, 0);
    expect(rows, hasLength(1));
  });

  test('source-scoped continuation ignores rows from another source', () async {
    final batchId = await importDatabase.insertImportBatch(
      sourceId: liveChatDbSourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    await _insertLedgerMessage(
      importDatabase,
      sourceId: 3,
      sourceRowId: 999999,
      guid: 'archive-message-999999',
      batchId: batchId,
    );

    await _insertSourceMessage(
      chatDbPath,
      rowId: 10,
      guid: 'live-message-10',
      handleId: 0,
      isFromMe: 0,
      text: 'live',
    );

    final importer = MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );

    final result = await importer.importNewMessages();

    expect(result.startedAfterSourceRowId, 0);
    expect(result.insertedMessageCount, 1);
    expect(result.lastImportedSourceRowId, 10);
  });

  test('sender_handle_ss_id is null when handle_id is zero', () async {
    await _insertSourceMessage(
      chatDbPath,
      rowId: 12,
      guid: 'message-12',
      handleId: 0,
      isFromMe: 0,
      text: 'no handle',
    );

    final importer = MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );

    await importer.importNewMessages();
    final rows = await importDatabase.database.query('messages');

    expect(rows.single['sender_handle_ss_id'], isNull);
  });

  test('reports truthful message progress after completed rows', () async {
    await _insertSourceMessage(
      chatDbPath,
      rowId: 10,
      guid: 'message-10',
      handleId: 0,
      isFromMe: 0,
    );
    await _insertSourceMessage(
      chatDbPath,
      rowId: 20,
      guid: 'message-20',
      handleId: 0,
      isFromMe: 0,
    );
    final observations = <SourceImportWorkProgress>[];

    await MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importNewMessages(onProgress: observations.add);

    expect(observations, hasLength(2));
    expect(observations.first.completedWorkCount, 0);
    expect(observations.first.totalWorkCount, 2);
    expect(observations.last.completedWorkCount, 2);
    expect(observations.last.lastCompletedSourceRowId, 20);
  });

  test('accounts for recovered, timestamp, and reaction degradation', () async {
    await _insertSourceMessage(
      chatDbPath,
      rowId: 30,
      guid: 'reaction-30',
      handleId: 0,
      isFromMe: 0,
      associatedMessageGuid: 'missing-target',
      associatedMessageType: 2000,
    );

    final result = await MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importNewMessages();

    expect(result.insertedMessageCount, 1);
    expect(result.anomalyCounts.messageTimestampUnavailableCount, 1);
    expect(result.anomalyCounts.recoveredUnlinkedMessageCount, 1);
    expect(result.anomalyCounts.unresolvedReactionTargetCount, 1);
    expect(await importDatabase.database.query('messages'), hasLength(1));
  });

  test('resolves Apple part and balloon reaction references', () async {
    await _insertSourceMessage(
      chatDbPath,
      rowId: 31,
      guid: 'target-31',
      handleId: 0,
      isFromMe: 0,
    );

    await MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importNewMessages();

    await _insertSourceMessage(
      chatDbPath,
      rowId: 32,
      guid: 'reaction-32',
      handleId: 0,
      isFromMe: 0,
      associatedMessageGuid: 'p:0/target-31',
      associatedMessageType: 2000,
    );
    await _insertSourceMessage(
      chatDbPath,
      rowId: 33,
      guid: 'reaction-33',
      handleId: 0,
      isFromMe: 0,
      associatedMessageGuid: 'bp:target-31',
      associatedMessageType: 2001,
    );

    final result = await MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importNewMessages();

    expect(result.insertedMessageCount, 2);
    expect(result.anomalyCounts.unresolvedReactionTargetCount, 0);
  });

  test('malformed message stops with bounded source row context', () async {
    await _insertSourceMessage(
      chatDbPath,
      rowId: 77,
      guid: null,
      handleId: 0,
      isFromMe: 0,
    );
    final observations = <SourceImportWorkProgress>[];

    await expectLater(
      MessageImporter(
        chatDbPath: chatDbPath,
        importLedger: importDatabase,
        sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
      ).importNewMessages(onProgress: observations.add),
      throwsA(
        isA<SourceImportRecordException>()
            .having(
              (error) => error.unit,
              'unit',
              SourceImportWorkUnit.messages,
            )
            .having((error) => error.sourceRowId, 'source ROWID', 77),
      ),
    );

    expect(observations, hasLength(1));
    expect(observations.single.completedWorkCount, 0);
    expect(await importDatabase.database.query('messages'), isEmpty);
  });

  test('imports sparse page-plus-one rows in bounded transactions', () async {
    for (final rowId in <int>[1, 7, 20]) {
      await _insertSourceMessage(
        chatDbPath,
        rowId: rowId,
        guid: 'message-$rowId',
        handleId: 0,
        isFromMe: 0,
        attributedBody: Uint8List(rowId),
      );
    }
    final metrics = <SourceImportPageMetric>[];

    final result = await MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
      pageSize: 2,
      onPageMetric: metrics.add,
    ).importNewMessages();

    expect(result.insertedMessageCount, 3);
    expect(result.lastImportedSourceRowId, 20);
    expect(metrics.map((metric) => metric.pageRowCount), <int>[2, 1]);
    expect(metrics.map((metric) => metric.cumulativeCompletedCount), <int>[
      2,
      3,
    ]);
    expect(metrics.map((metric) => metric.totalWorkCount).toSet(), <int>{3});
    expect(metrics.map((metric) => metric.totalBlobBytes), <int>[8, 20]);
    expect(metrics.map((metric) => metric.outcome).toSet(), <Object>{
      SourceImportPageOutcome.completed,
    });
  });

  test(
    'defers rows above the frozen high-water mark to the next run',
    () async {
      for (final rowId in <int>[1, 2]) {
        await _insertSourceMessage(
          chatDbPath,
          rowId: rowId,
          guid: 'message-$rowId',
          handleId: 0,
          isFromMe: 0,
        );
      }
      final mutatingOpener = _MutatingSourceDatabaseOpener(
        onFirstPageRead: () {
          return _insertSourceMessage(
            chatDbPath,
            rowId: 100,
            guid: 'message-100',
            handleId: 0,
            isFromMe: 0,
          );
        },
      );

      final first = await MessageImporter(
        chatDbPath: chatDbPath,
        importLedger: importDatabase,
        sourceDatabaseOpener: mutatingOpener,
        pageSize: 1,
      ).importNewMessages();
      final second = await MessageImporter(
        chatDbPath: chatDbPath,
        importLedger: importDatabase,
        sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
        pageSize: 1,
      ).importNewMessages();

      expect(first.insertedMessageCount, 2);
      expect(first.lastImportedSourceRowId, 2);
      expect(second.startedAfterSourceRowId, 2);
      expect(second.insertedMessageCount, 1);
      expect(second.lastImportedSourceRowId, 100);
    },
  );

  test('committed pages survive a later page rollback and retry', () async {
    for (final rowId in <int>[1, 2, 3, 4, 5, 7]) {
      await _insertSourceMessage(
        chatDbPath,
        rowId: rowId,
        guid: 'message-$rowId',
        handleId: 0,
        isFromMe: 0,
      );
    }
    await _insertSourceMessage(
      chatDbPath,
      rowId: 6,
      guid: null,
      handleId: 0,
      isFromMe: 0,
    );
    final metrics = <SourceImportPageMetric>[];

    await expectLater(
      MessageImporter(
        chatDbPath: chatDbPath,
        importLedger: importDatabase,
        sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
        pageSize: 2,
        onPageMetric: metrics.add,
      ).importNewMessages(),
      throwsA(isA<SourceImportRecordException>()),
    );
    expect(
      (await importDatabase.database.query(
        'messages',
        columns: <String>['source_rowid'],
        orderBy: 'source_rowid ASC',
      )).map((row) => row['source_rowid']),
      <Object?>[1, 2, 3, 4],
    );
    expect(metrics.map((metric) => metric.outcome), <Object>[
      SourceImportPageOutcome.completed,
      SourceImportPageOutcome.completed,
      SourceImportPageOutcome.failed,
    ]);
    expect(metrics.last.cumulativeCompletedCount, 4);
    expect(metrics.last.pageRowCount, 2);

    await _updateSourceMessageGuid(chatDbPath, rowId: 6, guid: 'message-6');
    final retry = await MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
      pageSize: 2,
    ).importNewMessages();

    expect(retry.startedAfterSourceRowId, 4);
    expect(retry.insertedMessageCount, 3);
    expect(await importDatabase.database.query('messages'), hasLength(7));
  });

  test('resolves association targets beyond the current page', () async {
    await _insertSourceMessage(
      chatDbPath,
      rowId: 1,
      guid: 'reaction-1',
      handleId: 0,
      isFromMe: 0,
      associatedMessageGuid: 'p:0/target-100',
      associatedMessageType: 2000,
    );
    await _insertSourceMessage(
      chatDbPath,
      rowId: 100,
      guid: 'target-100',
      handleId: 0,
      isFromMe: 0,
    );

    final result = await MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
      pageSize: 1,
    ).importNewMessages();

    expect(result.insertedMessageCount, 2);
    expect(result.anomalyCounts.unresolvedReactionTargetCount, 0);
  });
}

Future<void> _createSourceMessageTable(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.execute('''
    CREATE TABLE message (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT,
      handle_id INTEGER,
      is_from_me INTEGER NOT NULL,
      date INTEGER,
      date_read INTEGER,
      date_delivered INTEGER,
      text TEXT,
      attributedBody BLOB,
      associated_message_guid TEXT,
      item_type INTEGER,
      associated_message_type INTEGER,
      thread_originator_guid TEXT,
      error INTEGER,
      is_system_message INTEGER,
      message_summary_info BLOB,
      payload_data BLOB
    )
  ''');
  await db.execute('''
    CREATE TABLE chat_message_join (
      chat_id INTEGER,
      message_id INTEGER
    )
  ''');
  await db.close();
}

Future<void> _insertSourceMessage(
  String chatDbPath, {
  required int rowId,
  required String? guid,
  required int handleId,
  required int isFromMe,
  int? date,
  String? text,
  String? associatedMessageGuid,
  int? itemType,
  int? associatedMessageType,
  String? threadOriginatorGuid,
  int? error,
  int? isSystemMessage,
  Uint8List? attributedBody,
  Uint8List? messageSummaryInfo,
  Uint8List? payloadData,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('message', <String, Object?>{
    'ROWID': rowId,
    'guid': guid,
    'handle_id': handleId,
    'is_from_me': isFromMe,
    'date': date,
    'text': text,
    'attributedBody': attributedBody,
    'associated_message_guid': associatedMessageGuid,
    'item_type': itemType,
    'associated_message_type': associatedMessageType,
    'thread_originator_guid': threadOriginatorGuid,
    'error': error,
    'is_system_message': isSystemMessage,
    'message_summary_info': messageSummaryInfo,
    'payload_data': payloadData,
  });
  await db.close();
}

Future<void> _insertLedgerMessage(
  ImportDatabase importDatabase, {
  required int sourceId,
  required int sourceRowId,
  required String guid,
  required int batchId,
}) async {
  await importDatabase.database.insert('source_registry', <String, Object?>{
    'source_id': sourceId,
    'source_key': 'archive-test',
    'source_kind': 'archive_chat_db',
    'created_at_utc': DateTime.now().toUtc().toIso8601String(),
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
  await importDatabase.database.insert('messages', <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': sourceId,
    'source_rowid': sourceRowId,
    'guid': guid,
    'is_from_me': 0,
    'batch_id': batchId,
  });
}

Future<void> _updateSourceMessageGuid(
  String chatDbPath, {
  required int rowId,
  required String guid,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.update(
    'message',
    <String, Object?>{'guid': guid},
    where: 'ROWID = ?',
    whereArgs: <Object?>[rowId],
  );
  await db.close();
}

final class _MutatingSourceDatabaseOpener implements SourceDatabaseOpener {
  _MutatingSourceDatabaseOpener({required this.onFirstPageRead});

  final Future<void> Function() onFirstPageRead;

  @override
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath) async {
    final delegate = await const SqfliteSourceDatabaseOpener().openReadOnly(
      databasePath,
    );
    return _MutatingReadOnlySourceDatabase(
      delegate: delegate,
      onFirstPageRead: onFirstPageRead,
    );
  }
}

final class _MutatingReadOnlySourceDatabase implements ReadOnlySourceDatabase {
  _MutatingReadOnlySourceDatabase({
    required this.delegate,
    required this.onFirstPageRead,
  });

  final ReadOnlySourceDatabase delegate;
  final Future<void> Function() onFirstPageRead;
  var _pageReadCount = 0;

  @override
  Future<void> close() => delegate.close();

  @override
  Future<Set<String>> findExistingMessageGuids(Set<String> targetGuids) {
    return delegate.findExistingMessageGuids(targetGuids);
  }

  @override
  Future<SourceMessageImportWindow> messageImportWindowAfter(int sourceRowId) {
    return delegate.messageImportWindowAfter(sourceRowId);
  }

  @override
  Future<List<Map<String, Object?>>> query(String table, {String? orderBy}) {
    return delegate.query(table, orderBy: orderBy);
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) {
    return delegate.rawQuery(sql, arguments);
  }

  @override
  Future<List<Map<String, Object?>>> readMessageImportPage({
    required int afterSourceRowId,
    required int throughSourceRowId,
    required int limit,
  }) async {
    final rows = await delegate.readMessageImportPage(
      afterSourceRowId: afterSourceRowId,
      throughSourceRowId: throughSourceRowId,
      limit: limit,
    );
    _pageReadCount += 1;
    if (_pageReadCount == 1) {
      await onFirstPageRead();
    }
    return rows;
  }
}
