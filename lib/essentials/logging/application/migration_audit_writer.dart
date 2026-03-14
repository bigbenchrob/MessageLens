import '../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../infrastructure/pipeline_audit_logger.dart';

/// Writes detailed audit entries for the migration pipeline.
///
/// Called before and after the migration orchestrator runs to capture:
/// - Source import.db row counts
/// - Destination working.db row counts after migration
/// - Per-table deltas, JOIN-drop diagnostics, and skip reasons
class MigrationAuditWriter {
  const MigrationAuditWriter();

  static const _logFile = 'migrate_log';

  /// Write the full migration audit report.
  Future<void> writeReport({
    required SqfliteImportDatabase importDb,
    required WorkingDatabase workingDb,
    required bool incrementalMode,
    required bool success,
    String? errorMessage,
  }) async {
    final log = await PipelineAuditLogger.open(_logFile);

    try {
      final timestamp = DateTime.now().toUtc().toIso8601String();

      log.header('MIGRATION AUDIT — $timestamp');
      log.stat('Success', success);
      log.stat('Mode', incrementalMode ? 'incremental' : 'full');
      if (!success && errorMessage != null) {
        log.error(errorMessage);
      }

      // ---- Source import.db counts ----
      log.subHeader('SOURCE: import.db');
      final importCounts = await _logImportDbCounts(log, importDb);

      // ---- Destination working.db counts ----
      log.subHeader('DESTINATION: working.db');
      final workingCounts = await _logWorkingDbCounts(log, workingDb);

      // ---- Source vs Destination comparison ----
      log.subHeader('IMPORT vs WORKING COMPARISON');
      _logComparison(log, importCounts, workingCounts);

      // ---- Working DB message text diagnostics ----
      log.subHeader('WORKING DB MESSAGE TEXT DIAGNOSTICS');
      await _logMessageTextDiagnostics(log, workingDb);

      // ---- Working DB JOIN-drop diagnostics ----
      log.subHeader('JOIN-DROP DIAGNOSTICS');
      await _logJoinDropDiagnostics(log, importDb, workingDb);

      log.blank();
      log.info('--- end of migration audit ---');
      log.blank();
    } finally {
      await log.close();
    }
  }

  Future<Map<String, int>> _logImportDbCounts(
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
      'chat_to_message',
      'attachments',
      'message_attachments',
      'reactions',
    ];
    final counts = <String, int>{};
    final db = await importDb.database;

    for (final table in tables) {
      try {
        final c = _extractCount(
          await db.rawQuery('SELECT COUNT(*) AS c FROM "$table"'),
        );
        counts[table] = c;
        log.stat('$table rows', c);
      } catch (e) {
        log.warn('Could not count import.$table: $e');
      }
    }

    // Message text breakdown
    try {
      final withText = await db.rawQuery(
        "SELECT COUNT(*) AS c FROM messages WHERE text IS NOT NULL AND text != ''",
      );
      final withoutText = await db.rawQuery(
        "SELECT COUNT(*) AS c FROM messages WHERE text IS NULL OR text = ''",
      );
      log.blank();
      log.stat('import messages with text', _extractCount(withText));
      log.stat('import messages without text', _extractCount(withoutText));
    } catch (e) {
      log.warn('Could not get import message text breakdown: $e');
    }

    return counts;
  }

  Future<Map<String, int>> _logWorkingDbCounts(
    PipelineAuditLogger log,
    WorkingDatabase workingDb,
  ) async {
    final tables = [
      'handles_canonical',
      'handles_canonical_to_alias',
      'chats',
      'chat_to_handle',
      'participants',
      'handle_to_participant',
      'messages',
      'recovered_unlinked_messages',
      'attachments',
      'recovered_unlinked_attachments',
      'reactions',
      'reaction_counts',
      'message_read_marks',
      'read_state',
    ];
    final counts = <String, int>{};

    for (final table in tables) {
      try {
        final row = await workingDb
            .customSelect('SELECT COUNT(*) AS c FROM "$table"')
            .getSingle();
        final c = _extractDriftCount(row.data);
        counts[table] = c;
        log.stat('$table rows', c);
      } catch (e) {
        log.warn('Could not count working.$table: $e');
      }
    }

    return counts;
  }

  void _logComparison(
    PipelineAuditLogger log,
    Map<String, int> importCounts,
    Map<String, int> workingCounts,
  ) {
    // Map import table names to their working table counterparts
    final mapping = <String, String>{
      'handles': 'handles_canonical',
      'chats': 'chats',
      'chat_to_handle': 'chat_to_handle',
      'contacts': 'participants',
      'messages': 'messages',
      'recovered_unlinked_messages': 'recovered_unlinked_messages',
      'attachments': 'attachments',
      'recovered_unlinked_attachments': 'recovered_unlinked_attachments',
      'reactions': 'reactions',
    };

    for (final entry in mapping.entries) {
      final src = importCounts[entry.key];
      final dst = workingCounts[entry.value];
      if (src != null && dst != null) {
        log.compare('${entry.key} → ${entry.value}', src, dst);
      }
    }
  }

  Future<void> _logMessageTextDiagnostics(
    PipelineAuditLogger log,
    WorkingDatabase workingDb,
  ) async {
    try {
      final withText = await workingDb
          .customSelect(
            "SELECT COUNT(*) AS c FROM messages WHERE text IS NOT NULL AND text != ''",
          )
          .getSingle();
      final withoutText = await workingDb
          .customSelect(
            "SELECT COUNT(*) AS c FROM messages WHERE text IS NULL OR text = ''",
          )
          .getSingle();
      log.stat('working messages with text', _extractDriftCount(withText.data));
      log.stat(
        'working messages without text',
        _extractDriftCount(withoutText.data),
      );
    } catch (e) {
      log.warn('Could not get working message text breakdown: $e');
    }

    // By item_type
    try {
      final rows = await workingDb
          .customSelect(
            "SELECT COALESCE(item_type, '<<NULL>>') AS t, COUNT(*) AS c "
            'FROM messages GROUP BY item_type ORDER BY c DESC',
          )
          .get();
      log.blank();
      log.info('  Working messages by item_type:');
      for (final row in rows) {
        final type = row.data['t'] ?? '<<unknown>>';
        final count = row.data['c'] ?? 0;
        log.stat('    $type', count as Object);
      }
    } catch (e) {
      log.warn('Could not get working message type breakdown: $e');
    }
  }

  Future<void> _logJoinDropDiagnostics(
    PipelineAuditLogger log,
    SqfliteImportDatabase importDb,
    WorkingDatabase workingDb,
  ) async {
    final db = await importDb.database;

    // Messages with no matching chat (would be dropped by messages_migrator JOIN)
    try {
      final orphans = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM messages m '
        'WHERE m.chat_id NOT IN (SELECT id FROM chats)',
      );
      log.stat('import messages with no matching chat', _extractCount(orphans));
    } catch (e) {
      log.warn('Could not check message-chat join drops: $e');
    }

    // Messages with unresolvable sender_handle_id (LEFT JOIN, so not dropped
    // but worth flagging)
    try {
      final unmapped = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM messages m '
        'WHERE m.sender_handle_id IS NOT NULL '
        'AND m.sender_handle_id != 0 '
        'AND m.sender_handle_id NOT IN (SELECT id FROM handles)',
      );
      log.stat(
        'import messages with unmappable sender_handle_id',
        _extractCount(unmapped),
      );
    } catch (e) {
      log.warn('Could not check handle mapping drops: $e');
    }

    // chat_to_handle with missing chat or handle (3 INNER JOINs)
    try {
      final missingChat = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM chat_to_handle cth '
        'WHERE cth.chat_id NOT IN (SELECT id FROM chats)',
      );
      final missingHandle = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM chat_to_handle cth '
        'WHERE cth.handle_id NOT IN (SELECT id FROM handles)',
      );
      log.stat('chat_to_handle with missing chat', _extractCount(missingChat));
      log.stat(
        'chat_to_handle with missing handle',
        _extractCount(missingHandle),
      );
    } catch (e) {
      log.warn('Could not check chat_to_handle join drops: $e');
    }

    // Attachments with missing message
    try {
      final missingMsg = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM message_attachments ma '
        'WHERE ma.message_id NOT IN (SELECT id FROM messages)',
      );
      log.stat(
        'message_attachments with missing message',
        _extractCount(missingMsg),
      );
    } catch (e) {
      log.warn('Could not check attachment join drops: $e');
    }

    // Working DB: messages with NULL text that had text in import
    try {
      // Count how many working messages have null/empty text
      final workingNullText = await workingDb
          .customSelect(
            'SELECT COUNT(*) AS c FROM messages '
            "WHERE text IS NULL OR text = ''",
          )
          .getSingle();
      log.blank();
      log.stat(
        'working messages with null/empty text',
        _extractDriftCount(workingNullText.data),
      );
    } catch (e) {
      log.warn('Could not check text migration fidelity: $e');
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

  int _extractDriftCount(Map<String, dynamic> data) {
    final value = data['c'];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }
}
