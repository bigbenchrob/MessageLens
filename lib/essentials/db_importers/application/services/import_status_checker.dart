import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';

/// Checks how many messages/attachments are waiting to be imported from macOS
class ImportStatusChecker {
  const ImportStatusChecker();

  /// Get count of messages in macOS chat.db that haven't been imported yet
  Future<ImportStatus> checkStatus({
    required String macOsChatDbPath,
    required SqfliteImportDatabase importDb,
  }) async {
    try {
      // Get max ROWID from macOS Messages database
      final macOsMaxMessageRowId = _getMacOsMaxRowId(
        macOsChatDbPath,
        'message',
      );
      final macOsMaxAttachmentRowId = _getMacOsMaxRowId(
        macOsChatDbPath,
        'attachment',
      );

      // Get max imported source_rowid from import database
      final importedMaxMessageRowId = await importDb.maxMessageSourceRowId();
      final importedMaxAttachmentRowId =
          await importDb.maxAttachmentSourceRowId();

      // Calculate differences
      final unimportedMessages =
          macOsMaxMessageRowId - (importedMaxMessageRowId ?? 0);
      final unimportedAttachments =
          macOsMaxAttachmentRowId - (importedMaxAttachmentRowId ?? 0);

      return ImportStatus(
        macOsMessageCount: macOsMaxMessageRowId,
        importedMessageCount: importedMaxMessageRowId ?? 0,
        unimportedMessageCount: unimportedMessages > 0 ? unimportedMessages : 0,
        macOsAttachmentCount: macOsMaxAttachmentRowId,
        importedAttachmentCount: importedMaxAttachmentRowId ?? 0,
        unimportedAttachmentCount:
            unimportedAttachments > 0 ? unimportedAttachments : 0,
      );
    } catch (e) {
      throw Exception('Failed to check import status: $e');
    }
  }

  int _getMacOsMaxRowId(String dbPath, String tableName) {
    if (!File(dbPath).existsSync()) {
      throw Exception('macOS database not found: $dbPath');
    }

    try {
      final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
      try {
        db.execute('PRAGMA query_only = ON;');
        db.execute('PRAGMA busy_timeout = 3000;');

        final result = db.select(
          'SELECT COALESCE(MAX(ROWID), 0) as max_rowid FROM $tableName',
        );

        if (result.isEmpty || result.first.values.isEmpty) {
          return 0;
        }

        final value = result.first.values.first;
        if (value is int) {
          return value;
        }
        if (value is num) {
          return value.toInt();
        }
        return int.parse('$value');
      } finally {
        db.dispose();
      }
    } on SqliteException catch (error) {
      throw Exception(
        'SQLite error reading $tableName (${error.extendedResultCode}): $error',
      );
    }
  }
}

/// Status of what's been imported vs what's available in macOS
class ImportStatus {
  const ImportStatus({
    required this.macOsMessageCount,
    required this.importedMessageCount,
    required this.unimportedMessageCount,
    required this.macOsAttachmentCount,
    required this.importedAttachmentCount,
    required this.unimportedAttachmentCount,
  });

  final int macOsMessageCount;
  final int importedMessageCount;
  final int unimportedMessageCount;

  final int macOsAttachmentCount;
  final int importedAttachmentCount;
  final int unimportedAttachmentCount;

  bool get hasUnimportedData =>
      unimportedMessageCount > 0 || unimportedAttachmentCount > 0;

  bool shouldTriggerImport({int messageThreshold = 50}) {
    return unimportedMessageCount >= messageThreshold;
  }

  @override
  String toString() {
    return 'ImportStatus('
        'messages: $importedMessageCount/$macOsMessageCount, '
        'unimported: $unimportedMessageCount, '
        'attachments: $importedAttachmentCount/$macOsAttachmentCount, '
        'unimported: $unimportedAttachmentCount'
        ')';
  }
}
