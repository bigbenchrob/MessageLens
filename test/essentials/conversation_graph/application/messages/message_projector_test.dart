import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/message_projection_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importLedgerDatabase;
  late ConversationGraphDatabase graphDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('message_projector_test_');
    importLedgerDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    graphDatabase = await openConversationGraphTestDatabase();
  });

  tearDown(() async {
    await graphDatabase.close();
    await importLedgerDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('projects messages and preserves ss_id exactly', () async {
    final ssId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 100,
    );
    await _insertImportMessage(
      importLedgerDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: 100,
      guid: 'message-100',
      text: 'hello',
    );

    final result = await MessageProjector(
      repository: SqliteMessageProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    ).projectMessages();

    final rows = await graphDatabase.database.query('messages');

    expect(result.examinedMessageCount, 1);
    expect(result.insertedMessageCount, 1);
    expect(rows, hasLength(1));
    expect(rows.single['ss_id'], ssId);
    expect(rows.single['guid'], 'message-100');
    expect(rows.single['text'], 'hello');
  });

  test('is idempotent', () async {
    await _insertImportMessage(
      importLedgerDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: 101,
      guid: 'message-101',
    );

    final projector = MessageProjector(
      repository: SqliteMessageProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    );
    final firstResult = await projector.projectMessages();
    final secondResult = await projector.projectMessages();
    final rows = await graphDatabase.database.query('messages');

    expect(firstResult.insertedMessageCount, 1);
    expect(secondResult.examinedMessageCount, 1);
    expect(secondResult.insertedMessageCount, 0);
    expect(rows, hasLength(1));
  });

  test(
    'projects only messages after source rowid for incremental builds',
    () async {
      await _insertImportMessage(
        importLedgerDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 100,
        guid: 'already-projected',
        text: 'old',
      );
      await _insertImportMessage(
        importLedgerDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 101,
        guid: 'newly-imported',
        text: 'new',
      );

      final result =
          await MessageProjector(
            repository: SqliteMessageProjectionRepository(
              importLedgerDatabase: importLedgerDatabase,
              graphDatabase: graphDatabase,
            ),
          ).projectMessagesAfterSourceRowId(
            sourceId: liveChatDbSourceId,
            startedAfterSourceRowId: 100,
          );
      final rows = await graphDatabase.database.query('messages');

      expect(result.examinedMessageCount, 1);
      expect(result.insertedMessageCount, 1);
      expect(rows, hasLength(1));
      expect(rows.single['guid'], 'newly-imported');
    },
  );

  test(
    'refreshes existing working text after import ledger enrichment',
    () async {
      final messageSsId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 101,
      );
      await _insertImportMessage(
        importLedgerDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 101,
        guid: 'message-101',
        text: null,
      );

      final projector = MessageProjector(
        repository: SqliteMessageProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      );
      await projector.projectMessages();
      await importLedgerDatabase.database.update(
        'messages',
        <String, Object?>{'text': 'decoded text'},
        where: 'source_id = ? AND source_rowid = ?',
        whereArgs: <Object?>[liveChatDbSourceId, 101],
      );
      final secondResult = await projector.projectMessages();
      final rows = await graphDatabase.database.query('messages');

      expect(secondResult.insertedMessageCount, 0);
      expect(rows.single['text'], 'decoded text');
      expect(await _messageTextMatchIds(graphDatabase, '"decoded"'), <int>[
        messageSsId,
      ]);
    },
  );

  test(
    'graph reset and reprojection restore searchable message text',
    () async {
      final messageSsId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 103,
      );
      await _insertImportMessage(
        importLedgerDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 103,
        guid: 'message-103',
        text: 'reprojection searchable',
      );
      final projector = MessageProjector(
        repository: SqliteMessageProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      );

      await projector.projectMessages();
      expect(await _messageTextMatchIds(graphDatabase, '"reprojection"'), <int>[
        messageSsId,
      ]);

      await graphDatabase.clearProjectionRows();
      expect(
        await _messageTextMatchIds(graphDatabase, '"reprojection"'),
        isEmpty,
      );

      await projector.projectMessages();
      expect(await _messageTextMatchIds(graphDatabase, '"reprojection"'), <int>[
        messageSsId,
      ]);
    },
  );

  test(
    'duplicate guid values do not block projection when ss_id differs',
    () async {
      await _insertSource(importLedgerDatabase, sourceId: 3);
      await _insertImportMessage(
        importLedgerDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 102,
        guid: 'same-guid',
      );
      await _insertImportMessage(
        importLedgerDatabase,
        sourceId: 3,
        sourceRowId: 102,
        guid: 'same-guid',
      );

      final result = await MessageProjector(
        repository: SqliteMessageProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ).projectMessages();
      final rows = await graphDatabase.database.query(
        'messages',
        where: 'guid = ?',
        whereArgs: <Object?>['same-guid'],
      );

      expect(result.insertedMessageCount, 2);
      expect(rows, hasLength(2));
    },
  );

  test(
    'projects associated message guid to associated message ss_id',
    () async {
      final associatedSsId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 200,
      );
      await _insertImportMessage(
        importLedgerDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 200,
        guid: 'target-guid',
      );
      await _insertImportMessage(
        importLedgerDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 201,
        guid: 'reaction-guid',
        associatedMessageGuid: 'target-guid',
      );

      await MessageProjector(
        repository: SqliteMessageProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ).projectMessages();
      final rows = await graphDatabase.database.query(
        'messages',
        where: 'guid = ?',
        whereArgs: <Object?>['reaction-guid'],
      );

      expect(rows.single['associated_message_ss_id'], associatedSsId);
    },
  );

  test('associated message lookup remains source scoped', () async {
    await _insertSource(importLedgerDatabase, sourceId: 3);
    final liveTargetSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 300,
    );
    final archiveTargetSsId = SourceScopedRowKey.pack(
      sourceId: 3,
      sourceRowId: 300,
    );
    await _insertImportMessage(
      importLedgerDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: 300,
      guid: 'shared-target-guid',
    );
    await _insertImportMessage(
      importLedgerDatabase,
      sourceId: 3,
      sourceRowId: 300,
      guid: 'shared-target-guid',
    );
    await _insertImportMessage(
      importLedgerDatabase,
      sourceId: 3,
      sourceRowId: 301,
      guid: 'archive-reaction-guid',
      associatedMessageGuid: 'shared-target-guid',
    );

    await MessageProjector(
      repository: SqliteMessageProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    ).projectMessages();
    final rows = await graphDatabase.database.query(
      'messages',
      where: 'guid = ?',
      whereArgs: <Object?>['archive-reaction-guid'],
    );

    expect(rows.single['associated_message_ss_id'], archiveTargetSsId);
    expect(rows.single['associated_message_ss_id'], isNot(liveTargetSsId));
  });

  test(
    'missing associated guid projects null associated message ss_id',
    () async {
      await _insertImportMessage(
        importLedgerDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 400,
        guid: 'missing-target-reaction',
        associatedMessageGuid: 'missing-target-guid',
      );

      await MessageProjector(
        repository: SqliteMessageProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ).projectMessages();
      final rows = await graphDatabase.database.query(
        'messages',
        where: 'guid = ?',
        whereArgs: <Object?>['missing-target-reaction'],
      );

      expect(rows.single['associated_message_ss_id'], isNull);
    },
  );

  test('projects lightweight message semantic fields', () async {
    await _insertImportMessage(
      importLedgerDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: 500,
      guid: 'rich-text-message',
      text: 'hello',
      hasAttributedBodySource: 1,
      hasMessageSummaryInfo: 1,
      hasPayloadDataSource: 1,
      errorCode: 12,
    );

    await MessageProjector(
      repository: SqliteMessageProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    ).projectMessages();
    final rows = await graphDatabase.database.query(
      'messages',
      where: 'guid = ?',
      whereArgs: <Object?>['rich-text-message'],
    );

    expect(rows.single['semantic_kind'], 'payload');
    expect(rows.single['item_kind'], 'payload');
    expect(rows.single['is_system_message'], 0);
    expect(rows.single['is_sparse_artifact'], 0);
    expect(rows.single['has_attributed_body_source'], 1);
    expect(rows.single['has_message_summary_info'], 1);
    expect(rows.single['has_payload_data_source'], 1);
    expect(rows.single['error_code'], 12);
  });

  test(
    'classifies associated, system, text, and sparse message shapes',
    () async {
      await _insertImportMessage(
        importLedgerDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 600,
        guid: 'associated-message',
        associatedMessageType: 2000,
      );
      await _insertImportMessage(
        importLedgerDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 601,
        guid: 'system-message',
        isSystemMessage: 1,
      );
      await _insertImportMessage(
        importLedgerDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 602,
        guid: 'plain-text-message',
        text: 'plain',
      );
      await _insertImportMessage(
        importLedgerDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 603,
        guid: 'sparse-message',
      );

      await MessageProjector(
        repository: SqliteMessageProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ).projectMessages();
      final rows = await graphDatabase.database.query('messages');
      final byGuid = <Object?, Map<String, Object?>>{
        for (final row in rows) row['guid']: row,
      };

      expect(byGuid['associated-message']?['semantic_kind'], 'associated');
      expect(byGuid['system-message']?['semantic_kind'], 'system');
      expect(byGuid['plain-text-message']?['semantic_kind'], 'text');
      expect(byGuid['sparse-message']?['semantic_kind'], 'sparse_artifact');
      expect(byGuid['sparse-message']?['is_sparse_artifact'], 1);
    },
  );

  test('projects sender canonical handle endpoint when alias exists', () async {
    final senderHandleSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 50,
    );
    final canonicalHandleSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 49,
    );
    await graphDatabase.database.insert('handle_aliases', <String, Object?>{
      'handle_ss_id': senderHandleSsId,
      'canonical_handle_ss_id': canonicalHandleSsId,
      'raw_identifier': '+16049995969',
      'normalized_identifier': '6049995969',
      'alias_kind': 'phone',
    });
    await _insertImportMessage(
      importLedgerDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: 700,
      guid: 'sender-alias-message',
    );

    await MessageProjector(
      repository: SqliteMessageProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    ).projectMessages();
    final rows = await graphDatabase.database.query(
      'messages',
      where: 'guid = ?',
      whereArgs: <Object?>['sender-alias-message'],
    );

    expect(rows.single['sender_handle_ss_id'], senderHandleSsId);
    expect(rows.single['sender_canonical_handle_ss_id'], canonicalHandleSsId);
  });
}

Future<void> _insertSource(
  ImportDatabase importLedgerDatabase, {
  required int sourceId,
}) async {
  await importLedgerDatabase.database
      .insert('source_registry', <String, Object?>{
        'source_id': sourceId,
        'source_key': 'source-$sourceId',
        'source_kind': 'archive_chat_db',
        'created_at_utc': DateTime.now().toUtc().toIso8601String(),
      });
}

Future<void> _insertImportMessage(
  ImportDatabase importLedgerDatabase, {
  required int sourceId,
  required int sourceRowId,
  required String guid,
  String? text,
  String? associatedMessageGuid,
  int? associatedMessageType,
  int? isSystemMessage,
  int? hasAttributedBodySource,
  int? hasMessageSummaryInfo,
  int? hasPayloadDataSource,
  int? errorCode,
}) async {
  final batchId = await importLedgerDatabase.insertImportBatch(
    sourceId: sourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );

  await importLedgerDatabase.database.insert('messages', <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': sourceId,
    'source_rowid': sourceRowId,
    'guid': guid,
    'sender_handle_ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: 50,
    ),
    'is_from_me': 0,
    'date_utc': '2026-05-19T00:00:00.000Z',
    'text': text,
    'associated_message_guid': associatedMessageGuid,
    'raw_associated_message_type': associatedMessageType,
    'is_system_message': isSystemMessage ?? 0,
    'has_attributed_body_source': hasAttributedBodySource ?? 0,
    'has_message_summary_info': hasMessageSummaryInfo ?? 0,
    'has_payload_data_source': hasPayloadDataSource ?? 0,
    'error_code': errorCode,
    'batch_id': batchId,
  });
}

Future<List<int>> _messageTextMatchIds(
  ConversationGraphDatabase database,
  String expression,
) async {
  final rows = await database.selectRows(
    '''
    SELECT rowid
    FROM message_text_fts
    WHERE message_text_fts MATCH ?
    ORDER BY rowid
    ''',
    <Object?>[expression],
  );
  return <int>[for (final row in rows) row['rowid']! as int];
}
