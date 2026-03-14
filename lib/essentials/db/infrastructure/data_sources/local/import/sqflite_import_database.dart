// ignore_for_file: prefer_single_quotes

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../../../../db_importers/application/debug_settings_provider.dart';
import '../../../../shared/handle_identifier_utils.dart';

class SqfliteImportDatabase {
  SqfliteImportDatabase({
    required String databaseDirectory,
    required String databaseName,
    required ImportDebugSettingsState debugSettings,
  }) : _databaseDirectory = databaseDirectory,
       _databaseName = databaseName,
       _debugSettings = debugSettings;

  static const int _schemaVersion = 2;

  final String _databaseDirectory;
  final String _databaseName;
  final ImportDebugSettingsState _debugSettings;

  Database? _database;

  String get _dbPath => p.join(_databaseDirectory, _databaseName);

  Future<Database> get database async {
    final dbPath = _dbPath;

    if (_database != null) {
      final fileExists = File(dbPath).existsSync();
      if (!fileExists) {
        _debugSettings.logDatabase(
          'SqfliteImportDatabase.database: detected missing database file at $dbPath, reopening',
        );
        await _database!.close();
        _database = null;
      } else {
        _debugSettings.logDatabase(
          'SqfliteImportDatabase.database: returning existing instance for $_databaseName',
        );
        return _database!;
      }
    }

    _debugSettings.logDatabase(
      'SqfliteImportDatabase.database: opening database $_databaseName at $dbPath',
    );
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final directory = Directory(_databaseDirectory);
    if (!directory.existsSync()) {
      _debugSettings.logDatabase(
        'SqfliteImportDatabase._openDatabase: creating directory $_databaseDirectory',
      );
      await directory.create(recursive: true);
    }

    final dbPath = _dbPath;

    return openDatabase(
      dbPath,
      version: _schemaVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    _debugSettings.logDatabase(
      'SqfliteImportDatabase._onCreate: creating schema version $version',
    );

    try {
      final batch = db.batch();

      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: adding ${_schemaStatements.length} schema statements',
      );
      _schemaStatements.forEach(batch.execute);

      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: adding ${_indexStatements.length} index statements',
      );
      _indexStatements.forEach(batch.execute);

      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: adding expanded messages view',
      );
      batch.execute(_expandedMessagesViewStatement);

      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: committing batch',
      );
      await batch.commit(noResult: true);

      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: inserting schema migration record',
      );
      await db.insert('schema_migrations', <String, Object?>{
        'version': version,
        'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: schema creation completed successfully',
      );
    } catch (e, stackTrace) {
      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: ERROR creating schema: $e',
      );
      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: Stack trace: $stackTrace',
      );
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final batch = db.batch();
      _v2SchemaStatements.forEach(batch.execute);
      _v2IndexStatements.forEach(batch.execute);
      await batch.commit(noResult: true);

      await db.insert('schema_migrations', <String, Object?>{
        'version': 2,
        'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> close() async {
    if (_database != null) {
      _debugSettings.logDatabase(
        'SqfliteImportDatabase.close: closing database',
      );
      await _database!.close();
      _database = null;
    }
  }

  Future<void> deleteDatabaseFile() async {
    await close();
    final file = File(p.join(_databaseDirectory, _databaseName));
    if (file.existsSync()) {
      _debugSettings.logDatabase(
        'SqfliteImportDatabase.deleteDatabaseFile: deleting ${file.path}',
      );
      await file.delete();
    }
  }

  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? args,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }

  /// Returns the maximum source_rowid imported from the messages table.
  /// Used by ChatDbChangeMonitor to prime its state from import.db
  /// instead of chat.db, ensuring messages that arrived before app launch
  /// but after the last import are properly detected.
  Future<int?> getMaxImportedMessageRowId() async {
    final db = await database;
    final result = await db.rawQuery('''
SELECT MAX(source_rowid) AS max_rowid FROM (
  SELECT source_rowid FROM messages
  UNION ALL
  SELECT source_rowid FROM recovered_unlinked_messages
)
''');
    if (result.isEmpty || result.first['max_rowid'] == null) {
      return null;
    }
    return result.first['max_rowid'] as int?;
  }

  Future<int?> insertSchemaMigration({
    required int version,
    required String appliedAtUtc,
  }) async {
    final db = await database;
    return db.insert('schema_migrations', <String, Object?>{
      'version': version,
      'applied_at_utc': appliedAtUtc,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertImportBatch({
    int? id,
    required String startedAtUtc,
    String? finishedAtUtc,
    String? sourceChatDb,
    String? sourceAddressbook,
    String? hostInfoJson,
    String? notes,
  }) async {
    final db = await database;

    // Safety check: ensure schema exists (in case database initialization failed)
    await _ensureSchemaExists(db);
    _debugSettings.logDatabase(
      'SqfliteImportDatabase.insertImportBatch: creating batch with startedAtUtc=$startedAtUtc',
    );

    final data = _cleanMap(<String, Object?>{
      'id': id,
      'started_at_utc': startedAtUtc,
      'finished_at_utc': finishedAtUtc,
      'source_chat_db': sourceChatDb,
      'source_addressbook': sourceAddressbook,
      'host_info_json': hostInfoJson,
      'notes': notes,
    });

    final batchId = await db.insert(
      'import_batches',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _debugSettings.logDatabase(
      'SqfliteImportDatabase.insertImportBatch: created batch with ID=$batchId',
    );

    // Verify the batch was actually created
    final verification = await db.query(
      'import_batches',
      where: 'id = ?',
      whereArgs: [batchId],
    );

    if (verification.isEmpty) {
      _debugSettings.logDatabase(
        'SqfliteImportDatabase.insertImportBatch: ERROR - batch $batchId not found after creation!',
      );
      throw Exception(
        'Failed to create import batch: batch $batchId not found after insertion',
      );
    }

    _debugSettings.logDatabase(
      'SqfliteImportDatabase.insertImportBatch: verified batch $batchId exists',
    );

    return batchId;
  }

  Future<void> updateImportBatch({
    required int id,
    String? finishedAtUtc,
    String? notes,
  }) async {
    final db = await database;

    _debugSettings.logDatabase(
      'SqfliteImportDatabase.updateImportBatch: updating batch $id with finishedAtUtc=$finishedAtUtc, notes=$notes',
    );

    final data = _cleanMap(<String, Object?>{
      'finished_at_utc': finishedAtUtc,
      'notes': notes,
    });

    final updateCount = await db.update(
      'import_batches',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (updateCount == 0) {
      throw Exception('Failed to update import batch: batch $id not found');
    }

    _debugSettings.logDatabase(
      'SqfliteImportDatabase.updateImportBatch: successfully updated batch $id',
    );
  }

  Future<int> insertSourceFile({
    int? id,
    required int batchId,
    required String path,
    String? sha256Hex,
    int? sizeBytes,
    String? mtimeUtc,
  }) async {
    final db = await database;
    final data = _cleanMap(<String, Object?>{
      'id': id,
      'batch_id': batchId,
      'path': path,
      'sha256_hex': sha256Hex,
      'size_bytes': sizeBytes,
      'mtime_utc': mtimeUtc,
    });
    return db.insert(
      'source_files',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertImportLog({
    int? id,
    int? batchId,
    required String atUtc,
    required String level,
    required String message,
    String? contextJson,
  }) async {
    final db = await database;
    final data = _cleanMap(<String, Object?>{
      'id': id,
      'batch_id': batchId,
      'at_utc': atUtc,
      'level': level,
      'message': message,
      'context_json': contextJson,
    });
    return db.insert(
      'import_logs',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> maxMessageSourceRowId() async {
    return _selectMaxIntAcrossTables(
      tables: const <String>['messages', 'recovered_unlinked_messages'],
      column: 'source_rowid',
    );
  }

  Future<int?> maxAttachmentSourceRowId() async {
    return _selectMaxInt(table: 'attachments', column: 'source_rowid');
  }

  Future<int?> maxMessageAttachmentSourceRowId() async {
    return _selectMaxIntAcrossTables(
      tables: const <String>[
        'message_attachments',
        'recovered_unlinked_message_attachments',
      ],
      column: 'source_rowid',
    );
  }

  Future<int?> maxHandleSourceRowId() async {
    return _selectMaxInt(table: 'handles', column: 'source_rowid');
  }

  Future<int?> maxChatSourceRowId() async {
    return _selectMaxInt(table: 'chats', column: 'source_rowid');
  }

  Future<void> assignExistingRecordsToBatch({required int batchId}) async {
    final db = await database;
    await db.transaction((txn) async {
      const tablesWithBatchColumn = <String>[
        'contacts',
        'handles',
        'chats',
        'messages',
        'recovered_unlinked_messages',
        'attachments',
      ];

      for (final table in tablesWithBatchColumn) {
        await txn.update(table, <String, Object?>{'batch_id': batchId});
      }
    });
  }

  Future<int> insertContact({
    int? id,
    required int zPk,
    String? firstName,
    String? lastName,
    String? organization,
    required String displayName,
    String? shortName,
    bool isIgnored = false,
    String? createdAtUtc,
    required int batchId,
  }) async {
    final db = await database;
    final data = _cleanMap(<String, Object?>{
      'id': id,
      'Z_PK': zPk,
      'first_name': firstName,
      'last_name': lastName,
      'organization': organization,
      'display_name': displayName,
      'short_name': shortName,
      'created_at_utc': createdAtUtc,
      'is_ignored': _boolToInt(isIgnored),
      'batch_id': batchId,
    });
    return db.insert(
      'contacts',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertContactHandleLink({
    int? id,
    required int contactZpk,
    required int handleId,
    required int batchId,
  }) async {
    final db = await database;
    final data = _cleanMap(<String, Object?>{
      'id': id,
      'contact_Z_PK': contactZpk,
      'chat_handle_id': handleId,
      'batch_id': batchId,
    });
    return db.insert(
      'contact_to_chat_handle',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertContactHandleLinksBatch({
    required List<Map<String, int>> links,
    required int batchId,
  }) async {
    if (links.isEmpty) {
      return;
    }

    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final link in links) {
        final data = _cleanMap(<String, Object?>{
          'contact_Z_PK': link['contact_Z_PK'],
          'chat_handle_id': link['chat_handle_id'],
          'batch_id': batchId,
        });
        batch.insert(
          'contact_to_chat_handle',
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<Map<String, Object?>>> handlesForBatch(int batchId) async {
    final db = await database;
    return db.query(
      'handles',
      where: 'batch_id = ?',
      whereArgs: <Object>[batchId],
    );
  }

  Future<List<Map<String, Object?>>> contactChannelsForBatch(
    int batchId,
  ) async {
    final db = await database;
    return db.rawQuery(
      '''
SELECT c.Z_PK AS contact_Z_PK, cpe.kind, cpe.value
FROM contact_phone_email cpe
JOIN contacts c ON c.Z_PK = cpe.ZOWNER
WHERE c.batch_id = ?
''',
      <Object>[batchId],
    );
  }

  Future<void> clearContactHandleLinksForBatch({required int batchId}) async {
    final db = await database;
    await db.delete(
      'contact_to_chat_handle',
      where: 'contact_Z_PK IN (SELECT Z_PK FROM contacts WHERE batch_id = ?)',
      whereArgs: <Object>[batchId],
    );
  }

  Future<void> updateContactIgnoreFlags({required int batchId}) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'contacts',
        <String, Object?>{'is_ignored': 0},
        where: 'batch_id = ?',
        whereArgs: <Object>[batchId],
      );
      await txn.rawUpdate(
        '''
UPDATE contacts
SET is_ignored = 1
WHERE batch_id = ?
AND Z_PK NOT IN (
  SELECT DISTINCT contact_Z_PK FROM contact_to_chat_handle
  WHERE batch_id = ?
)
''',
        <Object>[batchId, batchId],
      );
    });
  }

  Future<int> insertContactChannel({
    int? id,
    required int zOwner,
    required String kind,
    required String value,
    String? label,
  }) async {
    final db = await database;
    final data = _cleanMap(<String, Object?>{
      'id': id,
      'ZOWNER': zOwner,
      'kind': kind,
      'value': value,
      'label': label,
    });
    return db.insert(
      'contact_phone_email',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertHandle({
    int? id,
    int? sourceRowid,
    required String service,
    required String rawIdentifier,
    String? normalizedIdentifier,
    required String compoundIdentifier,
    String? country,
    String? lastSeenUtc,
    required int batchId,
  }) async {
    final db = await database;

    // FK constraint on batch_id → import_batches(id) enforces existence.

    final safeService = sanitizeHandleService(service);
    final trimmedCompound = compoundIdentifier.trim();
    if (trimmedCompound.isEmpty) {
      throw Exception('Cannot insert handle without compound identifier');
    }

    _debugSettings.logDatabase(
      'SqfliteImportDatabase.insertHandle: inserting handle for batch $batchId, service=$safeService, rawIdentifier=$rawIdentifier',
    );

    final data = _cleanMap(<String, Object?>{
      'id': id,
      'source_rowid': sourceRowid,
      'service': safeService,
      'raw_identifier': rawIdentifier,
      'normalized_identifier': normalizedIdentifier,
      'compound_identifier': trimmedCompound,
      'country': country,
      'last_seen_utc': lastSeenUtc,
      'batch_id': batchId,
    });

    try {
      final handleId = await db.insert(
        'handles',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _debugSettings.logDatabase(
        'SqfliteImportDatabase.insertHandle: successfully created handle $handleId',
      );

      return handleId;
    } catch (e) {
      _debugSettings.logDatabase(
        'SqfliteImportDatabase.insertHandle: ERROR inserting handle: $e',
      );
      _debugSettings.logDatabase(
        'SqfliteImportDatabase.insertHandle: Failed data: $data',
      );
      rethrow;
    }
  }

  Future<int> insertChat({
    int? id,
    int? sourceRowid,
    required String guid,
    String? service,
    String? displayName,
    bool isGroup = false,
    String? createdAtUtc,
    String? updatedAtUtc,
    required int batchId,
  }) async {
    final db = await database;
    final data = _cleanMap(<String, Object?>{
      'id': id,
      'source_rowid': sourceRowid,
      'guid': guid,
      'service': service,
      'display_name': displayName,
      'is_group': _boolToInt(isGroup),
      'created_at_utc': createdAtUtc,
      'updated_at_utc': updatedAtUtc,
      'batch_id': batchId,
    });
    return db.insert(
      'chats',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertChatParticipant({
    required int chatId,
    required int handleId,
    String? role,
    String? addedAtUtc,
  }) async {
    final db = await database;

    // No validation needed - all chats and handles are imported before relationships
    final data = _cleanMap(<String, Object?>{
      'chat_id': chatId,
      'handle_id': handleId,
      'role': role,
      'added_at_utc': addedAtUtc,
    });
    return db.insert(
      'chat_to_handle',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertMessage({
    int? id,
    int? sourceRowid,
    required String guid,
    required int chatId,
    int? senderHandleId,
    String? service,
    required bool isFromMe,
    String? dateUtc,
    String? dateReadUtc,
    String? dateDeliveredUtc,
    String? subject,
    String? text,
    Uint8List? attributedBodyBlob,
    String? itemType,
    int? errorCode,
    required bool isSystemMessage,
    String? threadOriginatorGuid,
    String? associatedMessageGuid,
    String? balloonBundleId,
    String? payloadJson,
    required int batchId,
  }) async {
    final db = await database;

    // FK constraint on chat_id → chats(id) enforces existence.

    // Handle sender_handle_id = 0 (treat as NULL)
    // All handles are now imported, so no need to validate existence
    final actualSenderHandleId = (senderHandleId == 0) ? null : senderHandleId;

    _debugSettings.logDatabase(
      'SqfliteImportDatabase.insertMessage: inserting message for chat $chatId, handle $actualSenderHandleId, guid $guid',
    );

    final data = _cleanMap(<String, Object?>{
      'id': id,
      'source_rowid': sourceRowid,
      'guid': guid,
      'chat_id': chatId,
      'sender_handle_id': actualSenderHandleId,
      'service': service,
      'is_from_me': _boolToInt(isFromMe),
      'date_utc': dateUtc,
      'date_read_utc': dateReadUtc,
      'date_delivered_utc': dateDeliveredUtc,
      'subject': subject,
      'text': text,
      'attributed_body_blob': attributedBodyBlob,
      'item_type': itemType,
      'error_code': errorCode,
      'is_system_message': _boolToInt(isSystemMessage),
      'thread_originator_guid': threadOriginatorGuid,
      'associated_message_guid': associatedMessageGuid,
      'balloon_bundle_id': balloonBundleId,
      'payload_json': payloadJson,
      'batch_id': batchId,
    });

    final insertedId = await db.insert(
      'messages',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _debugSettings.logDatabase(
      'SqfliteImportDatabase.insertMessage: SUCCESS - inserted message $id (returned ID: $insertedId)',
    );

    return insertedId;
  }

  Future<int> insertChatMessageJoinSource({
    required int chatId,
    required int messageId,
    int? sourceRowid,
  }) async {
    final db = await database;
    final data = _cleanMap(<String, Object?>{
      'chat_id': chatId,
      'message_id': messageId,
      'source_rowid': sourceRowid,
    });
    return db.insert(
      'chat_to_message',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertRecoveredUnlinkedMessage({
    int? id,
    int? sourceRowid,
    required String guid,
    int? senderHandleId,
    String? service,
    required bool isFromMe,
    String? dateUtc,
    String? dateReadUtc,
    String? dateDeliveredUtc,
    String? subject,
    String? text,
    Uint8List? attributedBodyBlob,
    String? itemType,
    int? errorCode,
    required bool isSystemMessage,
    String? threadOriginatorGuid,
    String? associatedMessageGuid,
    String? balloonBundleId,
    String? payloadJson,
    required int batchId,
  }) async {
    final db = await database;
    final actualSenderHandleId = (senderHandleId == 0) ? null : senderHandleId;

    final data = _cleanMap(<String, Object?>{
      'id': id,
      'source_rowid': sourceRowid,
      'guid': guid,
      'sender_handle_id': actualSenderHandleId,
      'service': service,
      'is_from_me': _boolToInt(isFromMe),
      'date_utc': dateUtc,
      'date_read_utc': dateReadUtc,
      'date_delivered_utc': dateDeliveredUtc,
      'subject': subject,
      'text': text,
      'attributed_body_blob': attributedBodyBlob,
      'item_type': itemType,
      'error_code': errorCode,
      'is_system_message': _boolToInt(isSystemMessage),
      'thread_originator_guid': threadOriginatorGuid,
      'associated_message_guid': associatedMessageGuid,
      'balloon_bundle_id': balloonBundleId,
      'payload_json': payloadJson,
      'batch_id': batchId,
    });

    return db.insert(
      'recovered_unlinked_messages',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMessageText({
    required int messageId,
    required String text,
  }) async {
    final db = await database;
    _debugSettings.logDatabase(
      'SqfliteImportDatabase.updateMessageText: updating message $messageId with extracted text',
    );
    await db.rawUpdate(
      "UPDATE messages "
      "SET text = ?, "
      "item_type = CASE "
      "  WHEN item_type IS NULL THEN 'text' "
      "  WHEN item_type IN ('attachment-only', 'unknown', 'balloon') THEN 'text' "
      '  ELSE item_type '
      'END '
      'WHERE id = ?',
      <Object>[text, messageId],
    );
  }

  Future<void> updateRecoveredUnlinkedMessageText({
    required int messageId,
    required String text,
  }) async {
    final db = await database;
    await db.rawUpdate(
      "UPDATE recovered_unlinked_messages "
      "SET text = ?, "
      "item_type = CASE "
      "  WHEN item_type IS NULL THEN 'text' "
      "  WHEN item_type IN ('attachment-only', 'unknown', 'balloon') THEN 'text' "
      '  ELSE item_type '
      'END '
      'WHERE id = ?',
      <Object>[text, messageId],
    );
  }

  Future<int> insertAttachment({
    int? id,
    int? sourceRowid,
    String? guid,
    String? transferName,
    String? uti,
    String? mimeType,
    int? totalBytes,
    bool isSticker = false,
    bool? isOutgoing,
    String? createdAtUtc,
    String? localPath,
    String? sha256Hex,
    required int batchId,
  }) async {
    final db = await database;
    final data = _cleanMap(<String, Object?>{
      'id': id,
      'source_rowid': sourceRowid,
      'guid': guid,
      'transfer_name': transferName,
      'uti': uti,
      'mime_type': mimeType,
      'total_bytes': totalBytes,
      'is_sticker': _boolToInt(isSticker),
      'is_outgoing': _boolToNullableInt(isOutgoing),
      'created_at_utc': createdAtUtc,
      'local_path': localPath,
      'sha256_hex': sha256Hex,
      'batch_id': batchId,
    });
    return db.insert(
      'attachments',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertMessageAttachment({
    required int messageId,
    required int attachmentId,
    int? sourceRowid,
  }) async {
    final db = await database;

    // Validate that the message exists
    final messageExists = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );

    if (messageExists.isEmpty) {
      _debugSettings.logDatabase(
        'SqfliteImportDatabase.insertMessageAttachment: SKIPPING - message $messageId does not exist (likely filtered during validation)',
      );
      // Return -1 to indicate skipped insertion
      return -1;
    }

    // Validate that the attachment exists
    final attachmentExists = await db.query(
      'attachments',
      where: 'id = ?',
      whereArgs: [attachmentId],
    );

    if (attachmentExists.isEmpty) {
      _debugSettings.logDatabase(
        'SqfliteImportDatabase.insertMessageAttachment: ERROR - attachment $attachmentId does not exist!',
      );
      throw Exception(
        'Cannot insert message_attachment: attachment $attachmentId does not exist',
      );
    }

    _debugSettings.logDatabase(
      'SqfliteImportDatabase.insertMessageAttachment: linking message $messageId to attachment $attachmentId',
    );

    final data = _cleanMap(<String, Object?>{
      'message_id': messageId,
      'attachment_id': attachmentId,
      'source_rowid': sourceRowid,
    });
    return db.insert(
      'message_attachments',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Batch-insert message↔attachment join rows in a single transaction.
  ///
  /// Each entry must contain `message_id`, `attachment_id`, and optionally
  /// `source_rowid`. No per-row existence validation is performed — callers
  /// are responsible for ensuring referenced rows already exist.
  Future<void> insertMessageAttachmentsBatch(
    List<Map<String, Object?>> rows,
  ) async {
    if (rows.isEmpty) {
      return;
    }
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final row in rows) {
        batch.insert(
          'message_attachments',
          _cleanMap(row),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> insertRecoveredUnlinkedMessageAttachmentsBatch(
    List<Map<String, Object?>> rows,
  ) async {
    if (rows.isEmpty) {
      return;
    }
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final row in rows) {
        batch.insert(
          'recovered_unlinked_message_attachments',
          _cleanMap(row),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<int> insertReaction({
    int? id,
    required int carrierMessageId,
    required String targetMessageGuid,
    required String action,
    required String kind,
    int? reactorHandleId,
    String? reactedAtUtc,
    double parseConfidence = 1.0,
  }) async {
    final db = await database;
    final data = _cleanMap(<String, Object?>{
      'id': id,
      'carrier_message_id': carrierMessageId,
      'target_message_guid': targetMessageGuid,
      'action': action,
      'kind': kind,
      'reactor_handle_id': reactorHandleId,
      'reacted_at_utc': reactedAtUtc,
      'parse_confidence': parseConfidence,
    });
    return db.insert(
      'reactions',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertMessageLink({
    int? id,
    required int messageId,
    required String url,
    int? start,
    int? end,
  }) async {
    final db = await database;
    final data = _cleanMap(<String, Object?>{
      'id': id,
      'message_id': messageId,
      'url': url,
      'start': start,
      'end': end,
    });
    return db.insert(
      'message_links',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, int>> tableRowCounts() async {
    final db = await database;
    final tableNames = <String>[
      'schema_migrations',
      'import_batches',
      'source_files',
      'import_logs',
      'contacts',
      'contact_phone_email',
      'contact_to_chat_handle',
      'handles',
      'chats',
      'chat_to_handle',
      'messages',
      'recovered_unlinked_messages',
      'chat_to_message',
      'attachments',
      'message_attachments',
      'recovered_unlinked_message_attachments',
      'reactions',
      'message_links',
    ];

    final results = <String, int>{};
    for (final table in tableNames) {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'),
      );
      results[table] = count ?? 0;
    }
    return results;
  }

  Future<int> countRows(String table) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS row_count FROM $table',
    );
    if (result.isEmpty) {
      return 0;
    }
    final value = result.first['row_count'];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? 0;
  }

  /// Deletes all *ledger data* rows (handles, chats, messages, contacts, etc.)
  /// but preserves import metadata (import_batches, source_files, import_logs)
  /// so the current batch's FK references remain valid.
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      const tablesInDeleteOrder = <String>[
        'message_links',
        'reactions',
        'recovered_unlinked_message_attachments',
        'message_attachments',
        'attachments',
        'chat_to_message',
        'recovered_unlinked_messages',
        'messages',
        'chat_to_handle',
        'chats',
        'contact_to_chat_handle',
        'handles',
        'contact_phone_email',
        'contacts',
      ];

      for (final table in tablesInDeleteOrder) {
        await txn.delete(table);
      }
    });
  }

  Future<bool> _rowExists({
    required String table,
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;
    final result = await db.query(
      table,
      columns: const <String>['1'],
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<bool> rowExists({
    required String table,
    required String where,
    required List<Object?> whereArgs,
  }) {
    return _rowExists(table: table, where: where, whereArgs: whereArgs);
  }

  /// Get all handles for spam filtering
  Future<List<Map<String, Object?>>> getAllHandles() async {
    final db = await database;
    return db.query('handles');
  }

  /// Flag a handle as ignored/spam
  Future<void> flagHandleAsIgnored(int handleId) async {
    final db = await database;
    await db.update(
      'handles',
      {'is_ignored': 1},
      where: 'id = ?',
      whereArgs: [handleId],
    );
  }

  /// Flag a chat as ignored/spam
  Future<void> flagChatAsIgnored(int chatId) async {
    final db = await database;
    await db.update(
      'chats',
      {'is_ignored': 1},
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }

  /// Get chats that only have spam handles as participants
  Future<List<int>> getChatsWithOnlySpamHandles(List<int> spamHandleIds) async {
    if (spamHandleIds.isEmpty) {
      return <int>[];
    }

    final db = await database;
    final placeholders = List<String>.filled(
      spamHandleIds.length,
      '?',
    ).join(', ');

    // Find chats where ALL participants are spam handles
    final result = await db.rawQuery(
      '''
      SELECT c.id as chat_id
      FROM chats c
      WHERE c.id IN (
        SELECT chat_id FROM chat_to_handle WHERE handle_id IN ($placeholders)
      )
      AND c.id NOT IN (
        SELECT chat_id FROM chat_to_handle WHERE handle_id NOT IN ($placeholders)
      )
    ''',
      [...spamHandleIds, ...spamHandleIds],
    );

    return result
        .map((row) => row['chat_id'] as int?)
        .whereType<int>()
        .toList();
  }

  /// Flag all messages in specified chats as ignored
  Future<void> flagMessagesInChatsAsIgnored(List<int> chatIds) async {
    if (chatIds.isEmpty) {
      return;
    }

    final db = await database;
    final placeholders = List<String>.filled(chatIds.length, '?').join(', ');

    await db.rawUpdate('''
      UPDATE messages 
      SET is_ignored = 1 
      WHERE chat_id IN ($placeholders)
    ''', chatIds);
  }

  Future<bool> contactExists(int zPk) {
    return _rowExists(
      table: 'contacts',
      where: 'Z_PK = ?',
      whereArgs: <Object>[zPk],
    );
  }

  Future<bool> contactChannelExists({
    required String kind,
    required String value,
  }) {
    return _rowExists(
      table: 'contact_phone_email',
      where: 'kind = ? AND value = ?',
      whereArgs: <Object>[kind, value],
    );
  }

  Future<bool> chatParticipantExists({
    required int chatId,
    required int handleId,
  }) {
    return _rowExists(
      table: 'chat_to_handle',
      where: 'chat_id = ? AND handle_id = ?',
      whereArgs: <Object>[chatId, handleId],
    );
  }

  Future<int?> _selectMaxInt({
    required String table,
    required String column,
  }) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT MAX($column) AS max_value FROM $table',
    );
    if (rows.isEmpty) {
      return null;
    }
    final value = rows.first['max_value'];
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value');
  }

  Future<int?> _selectMaxIntAcrossTables({
    required List<String> tables,
    required String column,
  }) async {
    if (tables.isEmpty) {
      return null;
    }

    final db = await database;
    final unionSql = tables
        .map((table) => 'SELECT $column AS max_value FROM $table')
        .join(' UNION ALL ');
    final rows = await db.rawQuery(
      'SELECT MAX(max_value) AS max_value FROM ($unionSql)',
    );
    if (rows.isEmpty) {
      return null;
    }
    final value = rows.first['max_value'];
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value');
  }

  Map<String, Object?> _cleanMap(Map<String, Object?> data) {
    final result = <String, Object?>{};
    data.forEach((key, value) {
      if (value != null) {
        result[key] = value;
      }
    });
    return result;
  }

  int _boolToInt(bool value) => value ? 1 : 0;

  int? _boolToNullableInt(bool? value) =>
      value == null ? null : (value ? 1 : 0);

  static const List<String> _schemaStatements = <String>[
    'CREATE TABLE IF NOT EXISTS schema_migrations (version INTEGER PRIMARY KEY, applied_at_utc TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS import_batches (id INTEGER PRIMARY KEY, started_at_utc TEXT NOT NULL, finished_at_utc TEXT, source_chat_db TEXT, source_addressbook TEXT, host_info_json TEXT, notes TEXT)',
    'CREATE TABLE IF NOT EXISTS source_files (id INTEGER PRIMARY KEY, batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE CASCADE, path TEXT NOT NULL, sha256_hex TEXT, size_bytes INTEGER, mtime_utc TEXT, UNIQUE(path, sha256_hex))',
    "CREATE TABLE IF NOT EXISTS import_logs (id INTEGER PRIMARY KEY, batch_id INTEGER REFERENCES import_batches(id) ON DELETE SET NULL, at_utc TEXT NOT NULL, level TEXT NOT NULL CHECK(level IN ('debug','info','warn','error')), message TEXT NOT NULL, context_json TEXT)",
    'CREATE TABLE IF NOT EXISTS contacts (id INTEGER PRIMARY KEY, Z_PK INTEGER NOT NULL UNIQUE, first_name TEXT, last_name TEXT, organization TEXT, display_name TEXT NOT NULL, short_name TEXT, created_at_utc TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT)',
    "CREATE TABLE IF NOT EXISTS contact_phone_email (id INTEGER PRIMARY KEY, ZOWNER INTEGER NOT NULL REFERENCES contacts(Z_PK) ON DELETE CASCADE, kind TEXT NOT NULL CHECK(kind IN ('email','phone')), value TEXT NOT NULL, label TEXT, UNIQUE(kind, value))",
    "CREATE TABLE IF NOT EXISTS handles (id INTEGER PRIMARY KEY, source_rowid INTEGER, service TEXT NOT NULL, raw_identifier TEXT NOT NULL, normalized_identifier TEXT, compound_identifier TEXT NOT NULL DEFAULT '', country TEXT, last_seen_utc TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(service, raw_identifier))",
    "CREATE TABLE IF NOT EXISTS chats (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, service TEXT, display_name TEXT, is_group INTEGER NOT NULL DEFAULT 0 CHECK(is_group IN (0,1)), created_at_utc TEXT, updated_at_utc TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))",
    "CREATE TABLE IF NOT EXISTS chat_to_handle (chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE, handle_id INTEGER NOT NULL REFERENCES handles(id) ON DELETE CASCADE, role TEXT CHECK(role IN ('member','owner','unknown')) DEFAULT 'member', added_at_utc TEXT, PRIMARY KEY (chat_id, handle_id))",
    "CREATE TABLE IF NOT EXISTS messages (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE, sender_handle_id INTEGER REFERENCES handles(id) ON DELETE SET NULL, service TEXT, is_from_me INTEGER NOT NULL CHECK(is_from_me IN (0,1)), date_utc TEXT, date_read_utc TEXT, date_delivered_utc TEXT, subject TEXT, text TEXT, attributed_body_blob BLOB, item_type TEXT CHECK(item_type IN ('text','attachment-only','sticker','reaction-carrier','system','unknown','balloon')), error_code INTEGER, is_system_message INTEGER NOT NULL DEFAULT 0 CHECK(is_system_message IN (0,1)), thread_originator_guid TEXT, associated_message_guid TEXT, balloon_bundle_id TEXT, payload_json TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))",
    "CREATE TABLE IF NOT EXISTS recovered_unlinked_messages (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, sender_handle_id INTEGER REFERENCES handles(id) ON DELETE SET NULL, service TEXT, is_from_me INTEGER NOT NULL CHECK(is_from_me IN (0,1)), date_utc TEXT, date_read_utc TEXT, date_delivered_utc TEXT, subject TEXT, text TEXT, attributed_body_blob BLOB, item_type TEXT CHECK(item_type IN ('text','attachment-only','sticker','reaction-carrier','system','unknown','balloon')), error_code INTEGER, is_system_message INTEGER NOT NULL DEFAULT 0 CHECK(is_system_message IN (0,1)), thread_originator_guid TEXT, associated_message_guid TEXT, balloon_bundle_id TEXT, payload_json TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))",
    'CREATE TABLE IF NOT EXISTS chat_to_message (chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE, message_id INTEGER NOT NULL REFERENCES messages(id) ON DELETE CASCADE, source_rowid INTEGER, PRIMARY KEY (chat_id, message_id))',
    'CREATE TABLE IF NOT EXISTS attachments (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT, transfer_name TEXT, uti TEXT, mime_type TEXT, total_bytes INTEGER, is_sticker INTEGER NOT NULL DEFAULT 0 CHECK(is_sticker IN (0,1)), is_outgoing INTEGER CHECK(is_outgoing IN (0,1)), created_at_utc TEXT, local_path TEXT, sha256_hex TEXT, batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT)',
    'CREATE TABLE IF NOT EXISTS message_attachments (message_id INTEGER NOT NULL REFERENCES messages(id) ON DELETE CASCADE, attachment_id INTEGER NOT NULL REFERENCES attachments(id) ON DELETE CASCADE, source_rowid INTEGER, PRIMARY KEY (message_id, attachment_id))',
    'CREATE TABLE IF NOT EXISTS recovered_unlinked_message_attachments (message_id INTEGER NOT NULL REFERENCES recovered_unlinked_messages(id) ON DELETE CASCADE, attachment_id INTEGER NOT NULL REFERENCES attachments(id) ON DELETE CASCADE, source_rowid INTEGER, PRIMARY KEY (message_id, attachment_id))',
    "CREATE TABLE IF NOT EXISTS reactions (id INTEGER PRIMARY KEY, carrier_message_id INTEGER NOT NULL REFERENCES messages(id) ON DELETE CASCADE, target_message_guid TEXT NOT NULL, action TEXT NOT NULL CHECK(action IN ('add','remove')), kind TEXT NOT NULL CHECK(kind IN ('love','like','dislike','laugh','emphasize','question','unknown')), reactor_handle_id INTEGER REFERENCES handles(id) ON DELETE SET NULL, reacted_at_utc TEXT, parse_confidence REAL CHECK(parse_confidence >= 0.0 AND parse_confidence <= 1.0) DEFAULT 1.0)",
    'CREATE TABLE IF NOT EXISTS message_links (id INTEGER PRIMARY KEY, message_id INTEGER NOT NULL REFERENCES messages(id) ON DELETE CASCADE, url TEXT NOT NULL, start INTEGER, end INTEGER)',
    'CREATE TABLE IF NOT EXISTS contact_to_chat_handle (id INTEGER PRIMARY KEY, contact_Z_PK INTEGER NOT NULL REFERENCES contacts(Z_PK) ON DELETE CASCADE, chat_handle_id INTEGER NOT NULL REFERENCES handles(id) ON DELETE CASCADE, batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(contact_Z_PK, chat_handle_id))',
  ];

  static const List<String> _indexStatements = <String>[
    'CREATE INDEX IF NOT EXISTS idx_handles_compound ON handles(compound_identifier)',
    'CREATE INDEX IF NOT EXISTS idx_handles_norm ON handles(normalized_identifier)',
    'CREATE INDEX IF NOT EXISTS idx_handles_ignore ON handles(is_ignored)',
    'CREATE INDEX IF NOT EXISTS idx_participants_handle ON chat_to_handle(handle_id)',
    'CREATE INDEX IF NOT EXISTS idx_chats_ignore ON chats(is_ignored)',
    'CREATE INDEX IF NOT EXISTS idx_messages_chat_date ON messages(chat_id, date_utc)',
    'CREATE INDEX IF NOT EXISTS idx_messages_chat_active_date ON messages(chat_id, date_utc) WHERE is_ignored = 0',
    'CREATE INDEX IF NOT EXISTS idx_messages_ignore ON messages(is_ignored)',
    'CREATE INDEX IF NOT EXISTS idx_messages_assoc ON messages(associated_message_guid)',
    'CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_handle_id)',
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_messages_date ON recovered_unlinked_messages(date_utc)',
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_messages_ignore ON recovered_unlinked_messages(is_ignored)',
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_messages_assoc ON recovered_unlinked_messages(associated_message_guid)',
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_messages_sender ON recovered_unlinked_messages(sender_handle_id)',
    'CREATE INDEX IF NOT EXISTS idx_attach_created ON attachments(created_at_utc)',
    'CREATE INDEX IF NOT EXISTS idx_reactions_target ON reactions(target_message_guid)',
    'CREATE INDEX IF NOT EXISTS idx_reactions_reactor ON reactions(reactor_handle_id)',
    'CREATE INDEX IF NOT EXISTS idx_contact_phone_email_owner ON contact_phone_email(ZOWNER)',
    'CREATE INDEX IF NOT EXISTS idx_message_attachments_attachment ON message_attachments(attachment_id)',
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_message_attachments_attachment ON recovered_unlinked_message_attachments(attachment_id)',
    'CREATE INDEX IF NOT EXISTS idx_reactions_carrier ON reactions(carrier_message_id)',
    'CREATE INDEX IF NOT EXISTS idx_chat_to_message_message ON chat_to_message(message_id)',
  ];

  static const List<String> _v2SchemaStatements = <String>[
    "CREATE TABLE IF NOT EXISTS recovered_unlinked_messages (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, sender_handle_id INTEGER REFERENCES handles(id) ON DELETE SET NULL, service TEXT, is_from_me INTEGER NOT NULL CHECK(is_from_me IN (0,1)), date_utc TEXT, date_read_utc TEXT, date_delivered_utc TEXT, subject TEXT, text TEXT, attributed_body_blob BLOB, item_type TEXT CHECK(item_type IN ('text','attachment-only','sticker','reaction-carrier','system','unknown','balloon')), error_code INTEGER, is_system_message INTEGER NOT NULL DEFAULT 0 CHECK(is_system_message IN (0,1)), thread_originator_guid TEXT, associated_message_guid TEXT, balloon_bundle_id TEXT, payload_json TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))",
    'CREATE TABLE IF NOT EXISTS recovered_unlinked_message_attachments (message_id INTEGER NOT NULL REFERENCES recovered_unlinked_messages(id) ON DELETE CASCADE, attachment_id INTEGER NOT NULL REFERENCES attachments(id) ON DELETE CASCADE, source_rowid INTEGER, PRIMARY KEY (message_id, attachment_id))',
  ];

  static const List<String> _v2IndexStatements = <String>[
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_messages_date ON recovered_unlinked_messages(date_utc)',
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_messages_ignore ON recovered_unlinked_messages(is_ignored)',
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_messages_assoc ON recovered_unlinked_messages(associated_message_guid)',
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_messages_sender ON recovered_unlinked_messages(sender_handle_id)',
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_message_attachments_attachment ON recovered_unlinked_message_attachments(attachment_id)',
  ];

  static const String _expandedMessagesViewStatement =
      'CREATE VIEW IF NOT EXISTS v_messages_expanded AS SELECT m.id AS message_id, m.guid AS message_guid, m.chat_id, c.guid AS chat_guid, m.date_utc, m.is_from_me, m.text, m.item_type, m.associated_message_guid, h.id AS sender_handle_id, h.normalized_identifier AS sender_address FROM messages m JOIN chats c ON c.id = m.chat_id LEFT JOIN handles h ON h.id = m.sender_handle_id';

  /// Safety method to ensure schema exists (in case database initialization failed during app startup)
  Future<void> _ensureSchemaExists(Database db) async {
    try {
      // Check if import_batches table exists
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'import_batches'],
      );

      if (tables.isEmpty) {
        _debugSettings.logDatabase(
          'SqfliteImportDatabase._ensureSchemaExists: import_batches table missing, creating schema',
        );

        // Create the schema since it's missing
        final batch = db.batch();
        _schemaStatements.forEach(batch.execute);
        _indexStatements.forEach(batch.execute);
        batch.execute(_expandedMessagesViewStatement);
        await batch.commit(noResult: true);

        // Insert schema migration record
        await db.insert('schema_migrations', <String, Object?>{
          'version': _schemaVersion,
          'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        _debugSettings.logDatabase(
          'SqfliteImportDatabase._ensureSchemaExists: schema created successfully',
        );
      }
    } catch (e, stackTrace) {
      _debugSettings.logDatabase(
        'SqfliteImportDatabase._ensureSchemaExists: ERROR ensuring schema: $e',
      );
      _debugSettings.logDatabase(
        'SqfliteImportDatabase._ensureSchemaExists: Stack trace: $stackTrace',
      );
      rethrow;
    }
  }
}
