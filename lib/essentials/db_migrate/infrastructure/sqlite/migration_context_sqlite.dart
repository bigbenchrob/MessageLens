import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';

class CanonicalHandleInfo {
  const CanonicalHandleInfo({required this.compound, required this.display});

  final String compound;
  final String display;
}

/// Common context shared by all migrators.
class MigrationContext {
  final SqfliteImportDatabase importDb;
  final WorkingDatabase workingDb;
  final bool dryRun;
  final void Function(String msg) log;
  final Map<int, int> handleIdCanonicalMap;
  final Map<int, CanonicalHandleInfo> canonicalHandleInfo;
  MigrationContext({
    required this.importDb,
    required this.workingDb,
    this.dryRun = false,
    required this.log,
    Map<int, int>? handleIdCanonicalMap,
    Map<int, CanonicalHandleInfo>? canonicalHandleInfo,
  }) : handleIdCanonicalMap = handleIdCanonicalMap ?? <int, int>{},
       canonicalHandleInfo =
           canonicalHandleInfo ?? <int, CanonicalHandleInfo>{};
}
