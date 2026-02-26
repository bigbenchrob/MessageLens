import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../value_objects/canonical_handle_info.dart';

/// Abstract context passed to table migrators during working DB population.
///
/// Concrete implementations provide access to the import ledger (source) and
/// working database (target). This abstraction allows the domain layer to
/// define the migrator contract without direct infrastructure coupling.
abstract class IMigrationContext {
  /// The import ledger database (source of truth from macOS imports).
  SqfliteImportDatabase get importDb;

  /// The working database (target for normalized/projected data).
  WorkingDatabase get workingDb;

  /// When true, migrators should skip write operations.
  bool get dryRun;

  /// When true, migrators should preserve existing data and only add new rows.
  bool get incrementalMode;

  /// Map of source handle IDs to canonical handle IDs.
  ///
  /// Built during handle migration for use by downstream migrators.
  Map<int, int> get handleIdCanonicalMap;

  /// Map of canonical handle IDs to display information.
  Map<int, CanonicalHandleInfo> get canonicalHandleInfo;

  /// Log a message during migration.
  void log(String message);

  /// Verify the import database is ready for a migration stage.
  Future<void> ensureImportReady(String stageLabel);

  /// Clean up any lingering attachments after a migration stage.
  Future<void> ensureImportClean(String stageLabel);
}
