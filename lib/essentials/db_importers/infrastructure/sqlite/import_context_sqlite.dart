import 'package:sqflite/sqflite.dart';

import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../domain/ports/message_extractor_port.dart';

/// Shared context passed to each table importer while orchestrating the
/// ledger refresh. Mirrors the migration context but includes the raw macOS
/// source databases so that importers can read directly from `chat.db` and
/// AddressBook while staging data in the ledger.
class ImportContext {
  ImportContext({
    required this.importDb,
    required this.messagesDb,
    required this.messagesDbPath,
    required this.addressBookDb,
    required this.batchId,
    this.dryRun = false,
    this.log,
    this.extractor,
    this.rustExtractionLimit = 200000,
    this.previousMaxHandleRowId,
    this.previousMaxChatRowId,
    this.previousMaxMessageRowId,
    this.previousMaxAttachmentRowId,
    this.previousMaxMessageAttachmentRowId,
    this.hasExistingLedgerData = false,
    Map<String, Object?>? scratchpad,
  }) : scratchpad = scratchpad ?? <String, Object?>{};

  final SqfliteImportDatabase importDb;
  final Database messagesDb;
  final String messagesDbPath;
  final Database addressBookDb;
  final int batchId;
  final bool dryRun;
  final void Function(String message)? log;
  final MessageExtractorPort? extractor;
  final int rustExtractionLimit;
  final int? previousMaxHandleRowId;
  final int? previousMaxChatRowId;
  final int? previousMaxMessageRowId;
  final int? previousMaxAttachmentRowId;
  final int? previousMaxMessageAttachmentRowId;
  final bool hasExistingLedgerData;
  final Map<String, Object?> scratchpad;

  /// Convenience access for importers needing direct SQL handle on the ledger.
  Future<Database> get ledgerSqlite async => importDb.database;

  void info(String message) {
    log?.call(message);
  }

  T? readScratch<T>(String key) {
    final value = scratchpad[key];
    if (value is T) {
      return value;
    }
    return null;
  }

  void writeScratch(String key, Object? value) {
    scratchpad[key] = value;
  }
}
