abstract interface class DerivedMessageDataFileStore {
  /// Checks an app-owned database base filename inside the app data directory.
  ///
  /// Callers must pass a filename such as `working_ss.db`, not a path. This
  /// boundary exists so reset cleanup cannot reach attachment archives or
  /// unrelated directories.
  bool databaseBaseFileExists(String baseName);

  /// Checks app-owned database base filenames inside the app data directory.
  ///
  /// Callers must pass filenames such as `working_ss.db`, not paths.
  Map<String, bool> databaseExistenceByBaseName(List<String> baseNames);

  /// Deletes app-owned database base files and SQLite companion files.
  ///
  /// Each entry must be a filename such as `working_ss.db`, not a path. The
  /// implementation deletes only the base file plus `-wal` and `-shm`.
  Future<List<String>> deleteDatabaseBaseFiles(List<String> baseNames);
}

final class LocalDataRepairPhysicalSnapshot {
  const LocalDataRepairPhysicalSnapshot({required this.preservedEntries});

  final Map<String, String> preservedEntries;
}

/// Narrow physical proof boundary used only by AppCzar Local Data Repair.
abstract interface class LocalDataRepairPhysicalFileStore {
  Future<LocalDataRepairPhysicalSnapshot> captureLocalDataRepairSnapshot(
    List<String> resetBaseNames,
  );

  Future<void> requireLocalDataRepairPostcondition({
    required LocalDataRepairPhysicalSnapshot before,
    required List<String> resetBaseNames,
  });
}
