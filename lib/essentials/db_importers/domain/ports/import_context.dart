import 'package:sqflite/sqflite.dart';

import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'message_extractor_port.dart';

/// Abstract context passed to table importers during ledger refresh.
///
/// Concrete implementations (e.g., [ImportContextSqlite]) provide actual
/// database handles. This abstraction allows the domain layer to remain
/// independent of infrastructure details.
abstract class IImportContext {
  /// Current import batch identifier.
  int get batchId;

  /// When true, importers should skip write operations.
  bool get dryRun;

  /// Whether the ledger contains data from previous imports.
  bool get hasExistingLedgerData;

  /// Path to the source Messages database file.
  String get messagesDbPath;

  // ---------------------------------------------------------------------------
  // Incremental import tracking - highest ROWIDs from previous imports
  // ---------------------------------------------------------------------------

  int? get previousMaxHandleRowId;
  int? get previousMaxChatRowId;
  int? get previousMaxMessageRowId;
  int? get previousMaxAttachmentRowId;
  int? get previousMaxMessageAttachmentRowId;

  // ---------------------------------------------------------------------------
  // Rich text extraction support
  // ---------------------------------------------------------------------------

  /// Optional extractor for attributed string content.
  MessageExtractorPort? get extractor;

  /// Maximum messages to process in a single Rust extraction batch.
  int get rustExtractionLimit;

  // ---------------------------------------------------------------------------
  // Database access
  // ---------------------------------------------------------------------------

  /// The import ledger database for staging imported data.
  SqfliteImportDatabase get importDb;

  /// Source Messages database (chat.db).
  Database get messagesDb;

  /// Source AddressBook database.
  Database get addressBookDb;

  // ---------------------------------------------------------------------------
  // Logging and inter-importer communication
  // ---------------------------------------------------------------------------

  /// Log an informational message.
  void info(String message);

  /// Read a value from the shared scratchpad.
  T? readScratch<T>(String key);

  /// Write a value to the shared scratchpad for downstream importers.
  void writeScratch(String key, Object? value);
}
