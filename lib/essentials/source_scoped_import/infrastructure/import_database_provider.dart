import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../../db/app_database_schema_versions.dart';
import '../domain/known_sources.dart';
import '../domain/ports/import_ledger_port.dart';

class ImportDatabase implements ImportLedger {
  ImportDatabase._(this.database);

  static const int _busyTimeoutMilliseconds = 3000;

  final Database database;

  static Future<ImportDatabase> open({
    required String databaseDirectory,
    required String databaseName,
  }) async {
    final directory = Directory(databaseDirectory);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final db = await openDatabase(
      path.join(databaseDirectory, databaseName),
      version: sourceScopedImportSchemaVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createChatSchema(db);
          await _createChatToMessageSchema(db);
        }
        if (oldVersion < 3) {
          await db.execute('DROP TABLE IF EXISTS chats');
          await _createChatSchema(db);
        }
        if (oldVersion < 4) {
          await db.execute('DROP TABLE IF EXISTS chats');
          await _createChatSchema(db);
        }
        if (oldVersion < 5) {
          await _createHandleSchema(db);
          await _createChatToHandleSchema(db);
        }
        if (oldVersion < 6) {
          await _createContactSchema(db);
          await _createContactChannelSchema(db);
        }
        if (oldVersion < 7) {
          await _addMessageSemanticSourceColumns(db);
        }
        if (oldVersion < 8) {
          await _createAttachmentSchema(db);
          await _createMessageToAttachmentSchema(db);
        }
        if (oldVersion < 9) {
          await _createIncrementalProjectionIndexes(db);
        }
        if (oldVersion < 10) {
          await _addHandleSelfIdentityColumn(db);
        }
      },
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        // This tolerates brief SQLite contention. It does not authorize
        // unrelated readers during admitted archive maintenance.
        await db.execute('PRAGMA busy_timeout = $_busyTimeoutMilliseconds');
        await _createIncrementalProjectionIndexes(db);
      },
    );

    await _ensureLiveSource(db);
    return ImportDatabase._(db);
  }

  Future<void> close() async {
    await database.close();
  }

  @override
  Future<T> writeTransaction<T>(
    Future<T> Function(ImportLedgerWriteTransaction txn) action,
  ) {
    return database.transaction((txn) {
      return action(ImportDatabaseWriteTransaction._(txn));
    });
  }

  @override
  Future<int> insertImportBatch({
    required int sourceId,
    required String startedAtUtc,
  }) async {
    return database.insert('import_batches', <String, Object?>{
      'source_id': sourceId,
      'started_at_utc': startedAtUtc,
    });
  }

  @override
  Future<int> getOrCreateSource({
    required String sourceKey,
    required String sourceKind,
    String? sourceLabel,
  }) async {
    final normalizedKey = sourceKey.trim();
    final normalizedKind = sourceKind.trim();
    final trimmedLabel = sourceLabel?.trim();
    final normalizedLabel = trimmedLabel == null || trimmedLabel.isEmpty
        ? null
        : trimmedLabel;

    if (normalizedKey.isEmpty) {
      throw ArgumentError.value(sourceKey, 'sourceKey', 'must not be empty');
    }
    if (normalizedKind.isEmpty) {
      throw ArgumentError.value(sourceKind, 'sourceKind', 'must not be empty');
    }

    return database.transaction((txn) async {
      final existing = await txn.query(
        'source_registry',
        columns: <String>['source_id'],
        where: 'source_key = ?',
        whereArgs: <Object?>[normalizedKey],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        final existingSourceId = existing.single['source_id'];
        if (existingSourceId is! int) {
          throw StateError('source_registry.source_id must be an integer');
        }
        return existingSourceId;
      }

      final nextRows = await txn.rawQuery(
        'SELECT COALESCE(MAX(source_id), ?) + 1 AS next_source_id '
        'FROM source_registry',
        <Object?>[liveAddressBookSourceId],
      );
      final nextSourceIdValue = nextRows.single['next_source_id'];
      if (nextSourceIdValue is! int) {
        throw StateError('next source_id must be an integer');
      }
      final nextSourceId = nextSourceIdValue;

      await txn.insert('source_registry', <String, Object?>{
        'source_id': nextSourceId,
        'source_key': normalizedKey,
        'source_kind': normalizedKind,
        'source_label': normalizedLabel,
        'created_at_utc': DateTime.now().toUtc().toIso8601String(),
      });

      return nextSourceId;
    });
  }

  @override
  Future<int?> sourceIdForKey(String sourceKey) async {
    final normalizedKey = sourceKey.trim();
    if (normalizedKey.isEmpty) {
      throw ArgumentError.value(sourceKey, 'sourceKey', 'must not be empty');
    }

    final rows = await database.query(
      'source_registry',
      columns: <String>['source_id'],
      where: 'source_key = ?',
      whereArgs: <Object?>[normalizedKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final value = rows.single['source_id'];
    if (value is! int) {
      throw StateError('source_registry.source_id must be an integer');
    }
    return value;
  }

  @override
  Future<int?> maxMessageSourceRowIdForSource(int sourceId) async {
    final rows = await database.rawQuery(
      'SELECT MAX(source_rowid) AS max_source_rowid '
      'FROM messages WHERE source_id = ?',
      <Object?>[sourceId],
    );
    return rows.single['max_source_rowid'] as int?;
  }

  @override
  Future<int> messageCountForSource(int sourceId) async {
    final rows = await database.rawQuery(
      'SELECT COUNT(*) AS message_count '
      'FROM messages WHERE source_id = ?',
      <Object?>[sourceId],
    );
    return rows.single['message_count'] as int? ?? 0;
  }

  @override
  Future<ImportLedgerMessageStatusSnapshot> messageStatusForSource(
    int sourceId,
  ) async {
    final rows = await database.rawQuery(
      '''
      SELECT
        COUNT(*) AS message_count,
        COALESCE(MAX(source_rowid), 0) AS max_source_rowid,
        SUM(CASE WHEN text IS NULL AND attributed_body_blob IS NOT NULL
          THEN 1 ELSE 0 END) AS needing_enrichment_count,
        SUM(CASE WHEN text IS NULL OR text = '' THEN 1 ELSE 0 END)
          AS without_text_count
      FROM messages
      WHERE source_id = ?
      ''',
      <Object?>[sourceId],
    );
    final row = rows.single;
    return ImportLedgerMessageStatusSnapshot(
      count: _readInt(row['message_count']),
      maxSourceRowId: _readInt(row['max_source_rowid']),
      needingEnrichmentCount: _readInt(row['needing_enrichment_count']),
      withoutTextCount: _readInt(row['without_text_count']),
    );
  }

  @override
  Future<ImportLedgerProjectionStatusSnapshot>
  projectionStatusSnapshot() async {
    final chatRows = await database.rawQuery(
      'SELECT COUNT(*) AS chat_count FROM chats',
    );
    final handleRows = await database.rawQuery(
      'SELECT COUNT(*) AS handle_count FROM handles',
    );
    final chatToMessageRows = await database.rawQuery(
      'SELECT COUNT(*) AS edge_count FROM chat_to_message',
    );
    final chatToHandleRows = await database.rawQuery(
      'SELECT COUNT(*) AS edge_count FROM chat_to_handle',
    );
    final attachmentRows = await database.rawQuery(
      'SELECT COUNT(*) AS attachment_count FROM attachments',
    );
    final messageToAttachmentRows = await database.rawQuery(
      'SELECT COUNT(*) AS edge_count FROM message_to_attachment',
    );

    return ImportLedgerProjectionStatusSnapshot(
      chatCount: _readInt(chatRows.single['chat_count']),
      handleCount: _readInt(handleRows.single['handle_count']),
      chatToMessageEdgeCount: _readInt(chatToMessageRows.single['edge_count']),
      chatToHandleEdgeCount: _readInt(chatToHandleRows.single['edge_count']),
      attachmentCount: _readInt(attachmentRows.single['attachment_count']),
      messageToAttachmentEdgeCount: _readInt(
        messageToAttachmentRows.single['edge_count'],
      ),
    );
  }

  @override
  Future<ImportLedgerMessageTextWindow> messageTextEnrichmentWindow({
    int? sourceId,
    int? startedAfterSourceRowId,
  }) async {
    final whereParts = <String>[
      'text IS NULL',
      'attributed_body_blob IS NOT NULL',
      if (sourceId != null) 'source_id = ?',
      if (startedAfterSourceRowId != null) 'source_rowid > ?',
    ];
    final whereArgs = <Object?>[
      if (sourceId != null) sourceId,
      if (startedAfterSourceRowId != null) startedAfterSourceRowId,
    ];
    final rows = await database.rawQuery(
      'SELECT COUNT(*) AS candidate_count, MAX(ss_id) AS high_water_ss_id '
      'FROM messages WHERE ${whereParts.join(' AND ')}',
      whereArgs,
    );
    final row = rows.single;
    return ImportLedgerMessageTextWindow(
      candidateCount: _readInt(row['candidate_count']),
      highWaterSsId: row['high_water_ss_id'] as int?,
    );
  }

  @override
  Future<List<ImportLedgerMessageTextCandidate>> readMessageTextEnrichmentPage({
    required int afterSsId,
    required int throughSsId,
    required int limit,
    int? sourceId,
    int? startedAfterSourceRowId,
  }) async {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'must be greater than zero');
    }
    final whereParts = <String>[
      'text IS NULL',
      'attributed_body_blob IS NOT NULL',
      'ss_id > ?',
      'ss_id <= ?',
      if (sourceId != null) 'source_id = ?',
      if (startedAfterSourceRowId != null) 'source_rowid > ?',
    ];
    final whereArgs = <Object?>[
      afterSsId,
      throughSsId,
      if (sourceId != null) sourceId,
      if (startedAfterSourceRowId != null) startedAfterSourceRowId,
    ];
    final rows = await database.rawQuery(
      'SELECT ss_id, source_rowid, '
      'length(attributed_body_blob) AS attributed_body_blob_byte_count '
      'FROM messages WHERE ${whereParts.join(' AND ')} '
      'ORDER BY ss_id ASC LIMIT ?',
      <Object?>[...whereArgs, limit],
    );

    return rows
        .map((row) {
          return ImportLedgerMessageTextCandidate(
            ssId: _readRequiredInt(row, 'ss_id'),
            sourceRowId: _readRequiredInt(row, 'source_rowid'),
            attributedBodyBlobByteCount: _readRequiredInt(
              row,
              'attributed_body_blob_byte_count',
            ),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<Map<int, Uint8List>> readMessageTextEnrichmentBlobs({
    required List<int> ssIds,
    required int maximumBlobBytes,
  }) async {
    if (ssIds.isEmpty) {
      return const <int, Uint8List>{};
    }
    if (maximumBlobBytes <= 0) {
      throw ArgumentError.value(
        maximumBlobBytes,
        'maximumBlobBytes',
        'must be greater than zero',
      );
    }
    final placeholders = List<String>.filled(ssIds.length, '?').join(', ');
    final rows = await database.rawQuery(
      'SELECT ss_id, '
      'CAST(substr(attributed_body_blob, 1, ?) AS BLOB) '
      'AS attributed_body_blob '
      'FROM messages WHERE ss_id IN ($placeholders) '
      'AND attributed_body_blob IS NOT NULL',
      <Object?>[maximumBlobBytes + 1, ...ssIds],
    );

    return <int, Uint8List>{
      for (final row in rows)
        _readRequiredInt(row, 'ss_id'): switch (row['attributed_body_blob']) {
          final Uint8List blob => blob,
          final List<int> blob => Uint8List.fromList(blob),
          _ => throw StateError('messages.attributed_body_blob is required'),
        },
    };
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
    return database.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  @override
  Future<SourceScopedImportSourceDeletionResult> deleteRowsForSource({
    required int sourceId,
  }) async {
    return database.transaction((txn) async {
      final messageAttachmentEdges = await txn.delete(
        'message_to_attachment',
        where: 'message_source_id = ? OR attachment_source_id = ?',
        whereArgs: <Object?>[sourceId, sourceId],
      );
      final chatHandleEdges = await txn.delete(
        'chat_to_handle',
        where: 'source_id = ?',
        whereArgs: <Object?>[sourceId],
      );
      final chatMessageEdges = await txn.delete(
        'chat_to_message',
        where: 'source_id = ?',
        whereArgs: <Object?>[sourceId],
      );
      final contactChannels = await txn.delete(
        'contact_channels',
        where: 'source_id = ?',
        whereArgs: <Object?>[sourceId],
      );
      final contacts = await txn.delete(
        'contacts',
        where: 'source_id = ?',
        whereArgs: <Object?>[sourceId],
      );
      final attachments = await txn.delete(
        'attachments',
        where: 'source_id = ?',
        whereArgs: <Object?>[sourceId],
      );
      final messages = await txn.delete(
        'messages',
        where: 'source_id = ?',
        whereArgs: <Object?>[sourceId],
      );
      final chats = await txn.delete(
        'chats',
        where: 'source_id = ?',
        whereArgs: <Object?>[sourceId],
      );
      final handles = await txn.delete(
        'handles',
        where: 'source_id = ?',
        whereArgs: <Object?>[sourceId],
      );
      final importBatches = await txn.delete(
        'import_batches',
        where: 'source_id = ?',
        whereArgs: <Object?>[sourceId],
      );

      return SourceScopedImportSourceDeletionResult(
        sourceId: sourceId,
        messages: messages,
        chats: chats,
        handles: handles,
        contacts: contacts,
        contactChannels: contactChannels,
        attachments: attachments,
        chatMessageEdges: chatMessageEdges,
        chatHandleEdges: chatHandleEdges,
        messageAttachmentEdges: messageAttachmentEdges,
        importBatches: importBatches,
      );
    });
  }

  @override
  Future<int?> maxHandleSourceRowIdForSource(int sourceId) async {
    final rows = await database.rawQuery(
      'SELECT MAX(source_rowid) AS max_source_rowid '
      'FROM handles WHERE source_id = ?',
      <Object?>[sourceId],
    );
    return rows.single['max_source_rowid'] as int?;
  }

  @override
  Future<int?> maxAttachmentSourceRowIdForSource(int sourceId) async {
    final rows = await database.rawQuery(
      'SELECT MAX(source_rowid) AS max_source_rowid '
      'FROM attachments WHERE source_id = ?',
      <Object?>[sourceId],
    );
    return rows.single['max_source_rowid'] as int?;
  }

  static Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE source_registry (
        source_id INTEGER PRIMARY KEY,
        source_key TEXT NOT NULL UNIQUE,
        source_kind TEXT NOT NULL,
        source_label TEXT,
        created_at_utc TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE import_batches (
        batch_id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_id INTEGER NOT NULL,
        started_at_utc TEXT NOT NULL,
        finished_at_utc TEXT,
        notes TEXT,
        FOREIGN KEY (source_id) REFERENCES source_registry(source_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        ss_id INTEGER PRIMARY KEY,
        source_id INTEGER NOT NULL,
        source_rowid INTEGER NOT NULL,
        guid TEXT NOT NULL,
        sender_handle_ss_id INTEGER,
        is_from_me INTEGER NOT NULL CHECK (is_from_me IN (0, 1)),
        date_utc TEXT,
        date_read_utc TEXT,
        date_delivered_utc TEXT,
        text TEXT,
        attributed_body_blob BLOB,
        associated_message_guid TEXT,
        raw_item_type INTEGER,
        raw_associated_message_type INTEGER,
        thread_originator_guid TEXT,
        error_code INTEGER,
        is_system_message INTEGER NOT NULL DEFAULT 0 CHECK (is_system_message IN (0, 1)),
        has_attributed_body_source INTEGER NOT NULL DEFAULT 0 CHECK (has_attributed_body_source IN (0, 1)),
        has_message_summary_info INTEGER NOT NULL DEFAULT 0 CHECK (has_message_summary_info IN (0, 1)),
        has_payload_data_source INTEGER NOT NULL DEFAULT 0 CHECK (has_payload_data_source IN (0, 1)),
        batch_id INTEGER NOT NULL,
        UNIQUE(source_id, source_rowid),
        FOREIGN KEY (source_id) REFERENCES source_registry(source_id),
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_messages_source_cursor '
      'ON messages(source_id, source_rowid)',
    );
    await db.execute('CREATE INDEX idx_messages_guid ON messages(guid)');
    await _createHandleSchema(db);
    await _createChatSchema(db);
    await _createChatToMessageSchema(db);
    await _createChatToHandleSchema(db);
    await _createContactSchema(db);
    await _createContactChannelSchema(db);
    await _createAttachmentSchema(db);
    await _createMessageToAttachmentSchema(db);
    await _createIncrementalProjectionIndexes(db);
  }

  static Future<void> _addMessageSemanticSourceColumns(Database db) async {
    await _addColumnIfMissing(db, 'messages', 'raw_item_type INTEGER');
    await _addColumnIfMissing(
      db,
      'messages',
      'raw_associated_message_type INTEGER',
    );
    await _addColumnIfMissing(db, 'messages', 'thread_originator_guid TEXT');
    await _addColumnIfMissing(db, 'messages', 'error_code INTEGER');
    await _addColumnIfMissing(
      db,
      'messages',
      'is_system_message INTEGER NOT NULL DEFAULT 0 '
          'CHECK (is_system_message IN (0, 1))',
    );
    await _addColumnIfMissing(
      db,
      'messages',
      'has_attributed_body_source INTEGER NOT NULL DEFAULT 0 '
          'CHECK (has_attributed_body_source IN (0, 1))',
    );
    await _addColumnIfMissing(
      db,
      'messages',
      'has_message_summary_info INTEGER NOT NULL DEFAULT 0 '
          'CHECK (has_message_summary_info IN (0, 1))',
    );
    await _addColumnIfMissing(
      db,
      'messages',
      'has_payload_data_source INTEGER NOT NULL DEFAULT 0 '
          'CHECK (has_payload_data_source IN (0, 1))',
    );
  }

  static Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String columnDefinition,
  ) async {
    final columnName = columnDefinition.split(' ').first;
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final columnNames = columns.map((row) => row['name']).toSet();
    if (columnNames.contains(columnName)) {
      return;
    }
    await db.execute('ALTER TABLE $table ADD COLUMN $columnDefinition');
  }

  static Future<void> _createHandleSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS handles (
        ss_id INTEGER PRIMARY KEY,
        source_id INTEGER NOT NULL,
        source_rowid INTEGER NOT NULL,
        id TEXT NOT NULL,
        service TEXT,
        is_me INTEGER NOT NULL DEFAULT 0 CHECK(is_me IN (0,1)),
        batch_id INTEGER NOT NULL,
        UNIQUE(source_id, source_rowid),
        FOREIGN KEY (source_id) REFERENCES source_registry(source_id),
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_handles_source_cursor '
      'ON handles(source_id, source_rowid)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_handles_id ON handles(id)',
    );
  }

  static Future<void> _addHandleSelfIdentityColumn(Database db) async {
    await _addColumnIfMissing(
      db,
      'handles',
      'is_me INTEGER NOT NULL DEFAULT 0 CHECK(is_me IN (0,1))',
    );
  }

  static Future<void> _createChatSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chats (
        ss_id INTEGER PRIMARY KEY,
        source_id INTEGER NOT NULL,
        source_rowid INTEGER NOT NULL,
        guid TEXT NOT NULL,
        service TEXT,
        group_id TEXT,
        original_group_id TEXT,
        last_read_message_at_utc TEXT,
        batch_id INTEGER NOT NULL,
        UNIQUE(source_id, source_rowid),
        FOREIGN KEY (source_id) REFERENCES source_registry(source_id),
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chats_source_cursor '
      'ON chats(source_id, source_rowid)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chats_guid ON chats(guid)',
    );
  }

  static Future<void> _createChatToMessageSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_to_message (
        ss_id INTEGER PRIMARY KEY,
        source_id INTEGER NOT NULL,
        source_rowid INTEGER NOT NULL,
        source_chat_rowid INTEGER NOT NULL,
        source_message_rowid INTEGER NOT NULL,
        chat_ss_id INTEGER NOT NULL,
        message_ss_id INTEGER NOT NULL,
        UNIQUE(source_id, source_rowid)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chat_to_message_chat '
      'ON chat_to_message(chat_ss_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chat_to_message_message '
      'ON chat_to_message(message_ss_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chat_to_message_source_message_cursor '
      'ON chat_to_message(source_id, source_message_rowid)',
    );
  }

  static Future<void> _createChatToHandleSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_to_handle (
        source_id INTEGER NOT NULL,
        source_chat_rowid INTEGER NOT NULL,
        source_handle_rowid INTEGER NOT NULL,
        chat_ss_id INTEGER NOT NULL,
        handle_ss_id INTEGER NOT NULL,
        batch_id INTEGER NOT NULL,
        UNIQUE(source_id, source_chat_rowid, source_handle_rowid),
        FOREIGN KEY (source_id) REFERENCES source_registry(source_id),
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chat_to_handle_chat '
      'ON chat_to_handle(chat_ss_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chat_to_handle_handle '
      'ON chat_to_handle(handle_ss_id)',
    );
  }

  static Future<void> _createContactSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS contacts (
        ss_id INTEGER PRIMARY KEY,
        source_id INTEGER NOT NULL,
        source_rowid INTEGER NOT NULL,
        display_name TEXT NOT NULL,
        first_name TEXT,
        last_name TEXT,
        organization TEXT,
        created_at_utc TEXT,
        batch_id INTEGER NOT NULL,
        UNIQUE(source_id, source_rowid),
        FOREIGN KEY (source_id) REFERENCES source_registry(source_id),
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_contacts_source_cursor '
      'ON contacts(source_id, source_rowid)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_contacts_display_name '
      'ON contacts(display_name)',
    );
  }

  static Future<void> _createContactChannelSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS contact_channels (
        source_id INTEGER NOT NULL,
        source_contact_rowid INTEGER NOT NULL,
        contact_ss_id INTEGER NOT NULL,
        kind TEXT NOT NULL CHECK(kind IN ('email', 'phone')),
        value TEXT NOT NULL,
        label TEXT,
        batch_id INTEGER NOT NULL,
        UNIQUE(source_id, source_contact_rowid, kind, value),
        FOREIGN KEY (source_id) REFERENCES source_registry(source_id),
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_contact_channels_contact '
      'ON contact_channels(contact_ss_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_contact_channels_value '
      'ON contact_channels(value)',
    );
  }

  static Future<void> _createAttachmentSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS attachments (
        ss_id INTEGER PRIMARY KEY,
        source_id INTEGER NOT NULL,
        source_rowid INTEGER NOT NULL,
        guid TEXT,
        filename TEXT,
        transfer_name TEXT,
        uti TEXT,
        mime_type TEXT,
        total_bytes INTEGER,
        created_at_utc TEXT,
        batch_id INTEGER NOT NULL,
        UNIQUE(source_id, source_rowid),
        FOREIGN KEY (source_id) REFERENCES source_registry(source_id),
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_attachments_source_cursor '
      'ON attachments(source_id, source_rowid)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_attachments_guid ON attachments(guid)',
    );
  }

  static Future<void> _createMessageToAttachmentSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS message_to_attachment (
        message_source_id INTEGER NOT NULL,
        attachment_source_id INTEGER NOT NULL,
        source_message_rowid INTEGER NOT NULL,
        source_attachment_rowid INTEGER NOT NULL,
        message_ss_id INTEGER NOT NULL,
        attachment_ss_id INTEGER NOT NULL,
        batch_id INTEGER NOT NULL,
        UNIQUE(
          message_source_id,
          source_message_rowid,
          attachment_source_id,
          source_attachment_rowid
        ),
        FOREIGN KEY (message_source_id) REFERENCES source_registry(source_id),
        FOREIGN KEY (attachment_source_id) REFERENCES source_registry(source_id),
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_message_to_attachment_message '
      'ON message_to_attachment(message_ss_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_message_to_attachment_attachment '
      'ON message_to_attachment(attachment_ss_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS '
      'idx_message_to_attachment_source_message_cursor '
      'ON message_to_attachment(message_source_id, source_message_rowid)',
    );
  }

  static Future<void> _createIncrementalProjectionIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chat_to_message_source_message_cursor '
      'ON chat_to_message(source_id, source_message_rowid)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS '
      'idx_message_to_attachment_source_message_cursor '
      'ON message_to_attachment(message_source_id, source_message_rowid)',
    );
  }

  static Future<void> _ensureLiveSource(Database db) async {
    await db.insert('source_registry', <String, Object?>{
      'source_id': liveChatDbSourceId,
      'source_key': liveChatDbSourceKey,
      'source_kind': liveChatDbSourceKind,
      'source_label': 'Live chat.db',
      'created_at_utc': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('source_registry', <String, Object?>{
      'source_id': liveAddressBookSourceId,
      'source_key': liveAddressBookSourceKey,
      'source_kind': liveAddressBookSourceKind,
      'source_label': 'Live AddressBook',
      'created_at_utc': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}

final class ImportDatabaseWriteTransaction
    implements ImportLedgerWriteTransaction {
  const ImportDatabaseWriteTransaction._(this._txn);

  final Transaction _txn;

  @override
  Future<int> insertIgnore(String table, Map<String, Object?> values) {
    return _txn.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) {
    return _txn.update(table, values, where: where, whereArgs: whereArgs);
  }
}

int _readRequiredInt(Map<String, Object?> row, String field) {
  final value = row[field];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw StateError('messages.$field is required');
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return 0;
}
