import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';

/// Common context shared by all migrators.
class MigrationContext {
  final SqfliteImportDatabase importDb;
  final WorkingDatabase workingDb;
  final bool dryRun;
  final void Function(String msg) log;
  final Map<int, int> handleIdCanonicalMap;
  final Map<int, String> canonicalHandleNormalized;
  final Map<int, String> canonicalHandleDisplay;
  MigrationContext({
    required this.importDb,
    required this.workingDb,
    this.dryRun = false,
    required this.log,
    Map<int, int>? handleIdCanonicalMap,
    Map<int, String>? canonicalHandleNormalized,
    Map<int, String>? canonicalHandleDisplay,
  }) : handleIdCanonicalMap = handleIdCanonicalMap ?? <int, int>{},
       canonicalHandleNormalized = canonicalHandleNormalized ?? <int, String>{},
       canonicalHandleDisplay = canonicalHandleDisplay ?? <int, String>{};
}
