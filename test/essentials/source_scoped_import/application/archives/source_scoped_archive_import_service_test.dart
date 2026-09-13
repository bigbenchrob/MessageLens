import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/source_scoped_import/application/archives/historical_messages_archive_source_registrar.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/archives/source_scoped_archive_import_service.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/message_extractor_port.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/filesystem_historical_messages_archive_source_folder_resolver.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late Directory archiveFolder;
  late String chatDbPath;
  late ImportDatabase importDatabase;
  late SourceScopedArchiveImportService service;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'source_scoped_archive_import_service_test_',
    );
    archiveFolder = Directory(path.join(tempDir.path, 'Archive-2017'));
    await archiveFolder.create(recursive: true);
    chatDbPath = path.join(archiveFolder.path, 'chat.db');
    await _createArchiveChatDb(chatDbPath);
    await _insertArchiveRows(chatDbPath);

    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    service = SourceScopedArchiveImportService(
      registrar: HistoricalMessagesArchiveSourceRegistrar(
        importLedger: importDatabase,
        folderResolver:
            const FilesystemHistoricalMessagesArchiveSourceFolderResolver(),
      ),
      richTextExtractor: const _FakeExtractor(<int, String>{
        300: 'enriched archive message',
      }),
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );
  });

  tearDown(() async {
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'imports archive source facts and topology with archive source id',
    () async {
      final result = await service.importSourceFacts(
        folderPath: archiveFolder.path,
        sourceLabel: 'Archive 2017',
      );
      final sourceId = result.registration.sourceId;

      expect(sourceId, greaterThan(liveAddressBookSourceId));
      expect(
        result.registration.sourceKind,
        historicalMessagesArchiveSourceKind,
      );
      expect(result.insertedSourceFactCount, 4);
      expect(result.insertedTopologyEdgeCount, 3);
      expect(result.messages.insertedMessageCount, 1);
      expect(result.chats.insertedChatCount, 1);
      expect(result.handles.insertedHandleCount, 1);
      expect(result.attachments.insertedAttachmentCount, 1);
      expect(result.chatMessageEdges.insertedJoinCount, 1);
      expect(result.chatHandleEdges.insertedJoinCount, 1);
      expect(result.messageAttachmentEdges.insertedJoinCount, 1);
      expect(result.textEnrichment.candidateMessageCount, 1);
      expect(result.textEnrichment.enrichedMessageCount, 1);
      expect(result.textEnrichment.missingExtractionCount, 0);

      final messageRows = await importDatabase.database.query('messages');
      final chatRows = await importDatabase.database.query('chats');
      final handleRows = await importDatabase.database.query('handles');
      final attachmentRows = await importDatabase.database.query('attachments');
      final chatMessageRows = await importDatabase.database.query(
        'chat_to_message',
      );
      final chatHandleRows = await importDatabase.database.query(
        'chat_to_handle',
      );
      final messageAttachmentRows = await importDatabase.database.query(
        'message_to_attachment',
      );

      expect(messageRows.single['source_id'], sourceId);
      expect(messageRows.single['source_rowid'], 300);
      expect(messageRows.single['text'], 'enriched archive message');
      expect(
        messageRows.single['ss_id'],
        SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 300),
      );
      expect(
        messageRows.single['sender_handle_ss_id'],
        SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 200),
      );
      expect(chatRows.single['source_id'], sourceId);
      expect(handleRows.single['source_id'], sourceId);
      expect(attachmentRows.single['source_id'], sourceId);
      expect(chatMessageRows.single['source_id'], sourceId);
      expect(
        chatMessageRows.single['chat_ss_id'],
        SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 100),
      );
      expect(
        chatMessageRows.single['message_ss_id'],
        SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 300),
      );
      expect(chatHandleRows.single['source_id'], sourceId);
      expect(messageAttachmentRows.single['message_source_id'], sourceId);
      expect(messageAttachmentRows.single['attachment_source_id'], sourceId);
    },
  );

  test('is idempotent for the same archive source', () async {
    final firstResult = await service.importSourceFacts(
      folderPath: archiveFolder.path,
      sourceLabel: 'Archive 2017',
    );
    final secondResult = await service.importSourceFacts(
      folderPath: archiveFolder.path,
      sourceLabel: 'Renamed Archive 2017',
    );

    expect(
      secondResult.registration.sourceId,
      firstResult.registration.sourceId,
    );
    expect(secondResult.insertedSourceFactCount, 0);
    expect(secondResult.insertedTopologyEdgeCount, 0);
    expect(secondResult.textEnrichment.candidateMessageCount, 0);
    expect(secondResult.textEnrichment.enrichedMessageCount, 0);

    expect(await _countRows(importDatabase, 'messages'), 1);
    expect(await _countRows(importDatabase, 'chats'), 1);
    expect(await _countRows(importDatabase, 'handles'), 1);
    expect(await _countRows(importDatabase, 'attachments'), 1);
    expect(await _countRows(importDatabase, 'chat_to_message'), 1);
    expect(await _countRows(importDatabase, 'chat_to_handle'), 1);
    expect(await _countRows(importDatabase, 'message_to_attachment'), 1);
  });
}

Future<int> _countRows(ImportDatabase importDatabase, String table) async {
  final rows = await importDatabase.database.rawQuery(
    'SELECT COUNT(*) AS row_count FROM $table',
  );
  final value = rows.single['row_count'];
  if (value is! int) {
    throw StateError('$table row_count must be an integer');
  }
  return value;
}

Future<void> _createArchiveChatDb(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.execute('''
    CREATE TABLE chat (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT NOT NULL,
      service_name TEXT,
      group_id TEXT,
      original_group_id TEXT,
      last_read_message_timestamp INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE handle (
      ROWID INTEGER PRIMARY KEY,
      id TEXT NOT NULL,
      service TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE message (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT NOT NULL,
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
    CREATE TABLE attachment (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT,
      filename TEXT,
      transfer_name TEXT,
      uti TEXT,
      mime_type TEXT,
      total_bytes INTEGER,
      created_date INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE chat_message_join (
      ROWID INTEGER PRIMARY KEY,
      chat_id INTEGER NOT NULL,
      message_id INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE chat_handle_join (
      chat_id INTEGER NOT NULL,
      handle_id INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE message_attachment_join (
      message_id INTEGER NOT NULL,
      attachment_id INTEGER NOT NULL
    )
  ''');
  await db.close();
}

Future<void> _insertArchiveRows(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('chat', <String, Object?>{
    'ROWID': 100,
    'guid': 'archive-chat-guid',
    'service_name': 'iMessage',
    'group_id': 'archive-group',
  });
  await db.insert('handle', <String, Object?>{
    'ROWID': 200,
    'id': '+16045550100',
    'service': 'iMessage',
  });
  await db.insert('message', <String, Object?>{
    'ROWID': 300,
    'guid': 'archive-message-guid',
    'handle_id': 200,
    'is_from_me': 0,
    'text': null,
    'attributedBody': Uint8List.fromList(<int>[1, 2, 3]),
  });
  await db.insert('attachment', <String, Object?>{
    'ROWID': 400,
    'guid': 'archive-attachment-guid',
    'filename': 'Attachments/photo.jpg',
    'transfer_name': 'photo.jpg',
    'uti': 'public.jpeg',
    'mime_type': 'image/jpeg',
    'total_bytes': 1234,
  });
  await db.insert('chat_message_join', <String, Object?>{
    'ROWID': 500,
    'chat_id': 100,
    'message_id': 300,
  });
  await db.insert('chat_handle_join', <String, Object?>{
    'chat_id': 100,
    'handle_id': 200,
  });
  await db.insert('message_attachment_join', <String, Object?>{
    'message_id': 300,
    'attachment_id': 400,
  });
  await db.close();
}

class _FakeExtractor implements MessageExtractorPort {
  const _FakeExtractor(this.extracted);

  final Map<int, String> extracted;

  @override
  Future<Map<int, String>> extractAllMessageTexts({
    int? limit,
    String? dbPath,
  }) async {
    throw StateError('Archive import enrichment must decode import blobs');
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
    return true;
  }

  @override
  Future<bool> isBlobExtractionAvailable() async {
    return true;
  }
}
