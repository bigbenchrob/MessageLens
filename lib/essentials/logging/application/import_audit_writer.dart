import 'package:sqflite/sqflite.dart';

import '../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../infrastructure/pipeline_audit_logger.dart';

/// Writes detailed audit entries for the import pipeline.
///
/// Called before and after the import orchestrator runs to capture:
/// - Source macOS database row counts (chat.db + AddressBook)
/// - Destination import.db row counts after import
/// - Per-table deltas and skip reasons
class ImportAuditWriter {
  const ImportAuditWriter();

  static const _logFile = 'import_log';

  /// Write the full import audit report.
  ///
  /// [messagesDb] and [addressBookDb] are the open source database handles.
  /// [importDb] is the staging ledger.
  /// [scratchpad] contains per-importer scratch values written during the run.
  /// [batchId] identifies this import run.
  /// [startedAt] is the ISO 8601 timestamp when the import started.
  /// [success] indicates whether the import completed without errors.
  /// [errorMessage] is set if [success] is false.
  Future<void> writeReport({
    required Database messagesDb,
    required Database addressBookDb,
    required SqfliteImportDatabase importDb,
    required Map<String, Object?> scratchpad,
    required int batchId,
    required String startedAt,
    required bool success,
    String? errorMessage,
    required bool hasExistingLedgerData,
    int? previousMaxMessageRowId,
  }) async {
    final log = await PipelineAuditLogger.open(_logFile);

    try {
      final finishedAt = DateTime.now().toUtc().toIso8601String();

      log.header('IMPORT AUDIT — batch $batchId — $startedAt');
      log.stat('Finished at', finishedAt);
      log.stat('Success', success);
      log.stat('Mode', hasExistingLedgerData ? 'incremental' : 'full');
      if (previousMaxMessageRowId != null) {
        log.stat('Previous max message ROWID', previousMaxMessageRowId);
      }
      if (!success && errorMessage != null) {
        log.error(errorMessage);
      }

      // ---- Source macOS database counts ----
      log.subHeader('SOURCE: macOS Messages (chat.db)');
      await _logSourceMessagesCounts(log, messagesDb);

      log.subHeader('SOURCE: macOS AddressBook');
      await _logSourceAddressBookCounts(log, addressBookDb);

      // ---- Import ledger counts ----
      log.subHeader('DESTINATION: import.db (ledger)');
      await _logImportDbCounts(log, importDb);

      // ---- Per-importer scratch data ----
      log.subHeader('PER-IMPORTER DETAILS');
      _logScratchData(log, scratchpad);

      // ---- Source vs Destination comparison ----
      log.subHeader('SOURCE vs DESTINATION COMPARISON');
      await _logComparison(log, messagesDb, addressBookDb, importDb);

      log.blank();
      log.info('--- end of import audit ---');
      log.blank();
    } finally {
      await log.close();
    }
  }

  Future<void> _logSourceMessagesCounts(
    PipelineAuditLogger log,
    Database db,
  ) async {
    final tables = {
      'handle': 'SELECT COUNT(*) AS c FROM handle',
      'chat': 'SELECT COUNT(*) AS c FROM chat',
      'message': 'SELECT COUNT(*) AS c FROM message',
      'chat_handle_join': 'SELECT COUNT(*) AS c FROM chat_handle_join',
      'chat_message_join': 'SELECT COUNT(*) AS c FROM chat_message_join',
      'attachment': 'SELECT COUNT(*) AS c FROM attachment',
      'message_attachment_join':
          'SELECT COUNT(*) AS c FROM message_attachment_join',
    };

    for (final entry in tables.entries) {
      try {
        final rows = await db.rawQuery(entry.value);
        final count = rows.isNotEmpty ? rows.first['c'] ?? 0 : 0;
        log.stat('${entry.key} rows', count);
      } catch (e) {
        log.warn('Could not count ${entry.key}: $e');
      }
    }

    // Message breakdown by text presence
    try {
      final withText = await db.rawQuery(
        "SELECT COUNT(*) AS c FROM message WHERE text IS NOT NULL AND text != ''",
      );
      final withoutText = await db.rawQuery(
        "SELECT COUNT(*) AS c FROM message WHERE text IS NULL OR text = ''",
      );
      final withBlob = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM message WHERE attributedBody IS NOT NULL',
      );
      log.blank();
      log.stat('messages with text', _extractCount(withText));
      log.stat('messages without text', _extractCount(withoutText));
      log.stat('messages with attributedBody blob', _extractCount(withBlob));
    } catch (e) {
      log.warn('Could not get message text breakdown: $e');
    }

    // Messages not in chat_message_join (orphan messages)
    try {
      final orphans = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM message '
        'WHERE ROWID NOT IN (SELECT message_id FROM chat_message_join)',
      );
      log.stat('messages not in any chat (orphans)', _extractCount(orphans));
    } catch (e) {
      log.warn('Could not count orphan messages: $e');
    }

    // Max ROWID
    try {
      final maxRow = await db.rawQuery('SELECT MAX(ROWID) AS m FROM message');
      log.stat(
        'max message ROWID',
        maxRow.isNotEmpty ? maxRow.first['m'] ?? 'NULL' : 'NULL',
      );
    } catch (e) {
      log.warn('Could not get max message ROWID: $e');
    }
  }

  Future<void> _logSourceAddressBookCounts(
    PipelineAuditLogger log,
    Database db,
  ) async {
    final tables = {
      'ZABCDRECORD (contacts)': 'SELECT COUNT(*) AS c FROM ZABCDRECORD',
      'ZABCDEMAILADDRESS': 'SELECT COUNT(*) AS c FROM ZABCDEMAILADDRESS',
      'ZABCDPHONENUMBER': 'SELECT COUNT(*) AS c FROM ZABCDPHONENUMBER',
    };

    for (final entry in tables.entries) {
      try {
        final rows = await db.rawQuery(entry.value);
        final count = rows.isNotEmpty ? rows.first['c'] ?? 0 : 0;
        log.stat('${entry.key} rows', count);
      } catch (e) {
        log.warn('Could not count ${entry.key}: $e');
      }
    }
  }

  Future<void> _logImportDbCounts(
    PipelineAuditLogger log,
    SqfliteImportDatabase importDb,
  ) async {
    final tables = [
      'handles',
      'chats',
      'chat_to_handle',
      'contacts',
      'contact_phone_email',
      'contact_to_chat_handle',
      'messages',
      'recovered_unlinked_messages',
      'chat_to_message',
      'attachments',
      'message_attachments',
      'recovered_unlinked_message_attachments',
      'message_links',
      'reactions',
    ];

    final db = await importDb.database;

    for (final table in tables) {
      try {
        final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM "$table"');
        final count = rows.isNotEmpty ? rows.first['c'] ?? 0 : 0;
        log.stat('$table rows', count);
      } catch (e) {
        log.warn('Could not count $table: $e');
      }
    }

    // Message text breakdown in import.db
    try {
      final withText = await db.rawQuery(
        "SELECT COUNT(*) AS c FROM messages WHERE text IS NOT NULL AND text != ''",
      );
      final withoutText = await db.rawQuery(
        "SELECT COUNT(*) AS c FROM messages WHERE text IS NULL OR text = ''",
      );
      final withBlob = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM messages WHERE attributed_body_blob IS NOT NULL',
      );
      log.blank();
      log.stat('import messages with text', _extractCount(withText));
      log.stat('import messages without text', _extractCount(withoutText));
      log.stat(
        'import messages with attributed_body_blob',
        _extractCount(withBlob),
      );
    } catch (e) {
      log.warn('Could not get import message text breakdown: $e');
    }

    // Import messages by item_type
    try {
      final byType = await db.rawQuery(
        "SELECT COALESCE(item_type, '<<NULL>>') AS t, COUNT(*) AS c "
        'FROM messages GROUP BY item_type ORDER BY c DESC',
      );
      log.blank();
      log.info('  Import messages by item_type:');
      for (final row in byType) {
        log.stat('    ${row['t']}', row['c'] ?? 0);
      }
    } catch (e) {
      log.warn('Could not get import message type breakdown: $e');
    }
  }

  void _logScratchData(
    PipelineAuditLogger log,
    Map<String, Object?> scratchpad,
  ) {
    final interestingKeys = [
      'handles.inserted',
      'handles.lastSourceRowId',
      'chats.inserted',
      'chats.lastSourceRowId',
      'chatMemberships.inserted',
      'contacts.inserted',
      'contactChannels.inserted',
      'contactHandleLinks.inserted',
      'messages.inserted',
      'messages.lastSourceRowId',
      'messages.richTextApplied',
      'messages.extractionCandidates',
      'chatToMessage.inserted',
      'attachments.inserted',
      'attachments.lastSourceRowId',
      'messageAttachments.inserted',
    ];

    for (final key in interestingKeys) {
      final value = scratchpad[key];
      if (value == null) {
        continue;
      }
      if (value is List) {
        log.stat(key, '${value.length} items');
      } else {
        log.stat(key, value);
      }
    }
  }

  Future<void> _logComparison(
    PipelineAuditLogger log,
    Database messagesDb,
    Database addressBookDb,
    SqfliteImportDatabase importDb,
  ) async {
    final db = await importDb.database;

    // Messages: source chat.db vs import.db
    try {
      final sourceRows = await messagesDb.rawQuery(
        'SELECT COUNT(*) AS c FROM message',
      );
      final destRows = await db.rawQuery('SELECT COUNT(*) AS c FROM messages');
      log.compare(
        'messages',
        _extractCount(sourceRows),
        _extractCount(destRows),
      );

      final sourceOrphans = await messagesDb.rawQuery(
        'SELECT COUNT(*) AS c FROM message '
        'WHERE ROWID NOT IN (SELECT message_id FROM chat_message_join)',
      );
      final recoveredRows = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM recovered_unlinked_messages',
      );
      log.compare(
        'source orphan messages → recovered_unlinked_messages',
        _extractCount(sourceOrphans),
        _extractCount(recoveredRows),
      );

      // Messages with text in source vs destination
      final srcWithText = await messagesDb.rawQuery(
        "SELECT COUNT(*) AS c FROM message WHERE text IS NOT NULL AND text != ''",
      );
      final dstWithText = await db.rawQuery(
        "SELECT COUNT(*) AS c FROM messages WHERE text IS NOT NULL AND text != ''",
      );
      log.compare(
        'messages with text',
        _extractCount(srcWithText),
        _extractCount(dstWithText),
      );

      final recoveredWithText = await db.rawQuery(
        "SELECT COUNT(*) AS c FROM recovered_unlinked_messages WHERE text IS NOT NULL AND text != ''",
      );
      log.stat(
        'recovered_unlinked_messages with text',
        _extractCount(recoveredWithText),
      );
    } catch (e) {
      log.warn('Could not compare messages: $e');
    }

    // Handles
    try {
      final sourceRows = await messagesDb.rawQuery(
        'SELECT COUNT(*) AS c FROM handle',
      );
      final destRows = await db.rawQuery('SELECT COUNT(*) AS c FROM handles');
      log.compare(
        'handles',
        _extractCount(sourceRows),
        _extractCount(destRows),
      );
    } catch (e) {
      log.warn('Could not compare handles: $e');
    }

    // Chats
    try {
      final sourceRows = await messagesDb.rawQuery(
        'SELECT COUNT(*) AS c FROM chat',
      );
      final destRows = await db.rawQuery('SELECT COUNT(*) AS c FROM chats');
      log.compare('chats', _extractCount(sourceRows), _extractCount(destRows));
    } catch (e) {
      log.warn('Could not compare chats: $e');
    }

    // Attachments
    try {
      final sourceRows = await messagesDb.rawQuery(
        'SELECT COUNT(*) AS c FROM attachment',
      );
      final destRows = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM attachments',
      );
      log.compare(
        'attachments',
        _extractCount(sourceRows),
        _extractCount(destRows),
      );
    } catch (e) {
      log.warn('Could not compare attachments: $e');
    }

    // Contacts
    try {
      final sourceRows = await addressBookDb.rawQuery(
        'SELECT COUNT(*) AS c FROM ZABCDRECORD',
      );
      final destRows = await db.rawQuery('SELECT COUNT(*) AS c FROM contacts');
      log.compare(
        'contacts',
        _extractCount(sourceRows),
        _extractCount(destRows),
      );
    } catch (e) {
      log.warn('Could not compare contacts: $e');
    }
  }

  int _extractCount(List<Map<String, Object?>> rows) {
    if (rows.isEmpty) {
      return 0;
    }
    final value = rows.first['c'];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }
}
