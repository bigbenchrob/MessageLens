import 'package:sqflite/sqflite.dart';

import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../domain/ports/import_context.dart';
import '../../domain/ports/message_extractor_port.dart';

export '../../domain/ports/import_context.dart';

/// SQLite implementation of [IImportContext].
///
/// Provides access to raw sqflite [Database] handles for the source macOS
/// databases (chat.db, AddressBook) and the staging ledger.
class ImportContextSqlite implements IImportContext {
  ImportContextSqlite({
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

  @override
  final SqfliteImportDatabase importDb;

  @override
  final Database messagesDb;

  @override
  final String messagesDbPath;

  @override
  final Database addressBookDb;

  @override
  final int batchId;

  @override
  final bool dryRun;

  final void Function(String message)? log;

  @override
  final MessageExtractorPort? extractor;

  @override
  final int rustExtractionLimit;

  @override
  final int? previousMaxHandleRowId;

  @override
  final int? previousMaxChatRowId;

  @override
  final int? previousMaxMessageRowId;

  @override
  final int? previousMaxAttachmentRowId;

  @override
  final int? previousMaxMessageAttachmentRowId;

  @override
  final bool hasExistingLedgerData;

  final Map<String, Object?> scratchpad;

  /// Convenience access for importers needing direct SQL handle on the ledger.
  Future<Database> get ledgerSqlite async => importDb.database;

  @override
  void info(String message) {
    log?.call(message);
  }

  @override
  T? readScratch<T>(String key) {
    final value = scratchpad[key];
    if (value is T) {
      return value;
    }
    return null;
  }

  @override
  void writeScratch(String key, Object? value) {
    scratchpad[key] = value;
  }
}
