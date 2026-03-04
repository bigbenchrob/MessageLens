import 'dart:io';

import 'package:path/path.dart' as path;

/// Pure check: do `macos_import.db` and `working.db` both exist with data?
///
/// Returns `true` when both files are present and non-empty (file size > 0).
/// This is a cheap filesystem check that avoids opening SQLite connections.
///
/// A zero-byte file is treated the same as absent — SQLite creates the file
/// on first connection but it contains no tables until schema runs.
class DatabaseExistenceChecker {
  const DatabaseExistenceChecker();

  /// Returns `true` if both import and working databases exist and are non-empty.
  bool hasPopulatedDatabases(String databaseDirectory) {
    final importFile = File(path.join(databaseDirectory, 'macos_import.db'));
    final workingFile = File(path.join(databaseDirectory, 'working.db'));

    if (!importFile.existsSync() || !workingFile.existsSync()) {
      return false;
    }

    // A freshly-created SQLite DB may have schema but zero user data.
    // For a robust check we'd query row counts, but file size > 4096
    // (one page) is a reasonable heuristic for "has tables with data".
    // The gate provider does the definitive row-count check if the files exist.
    return importFile.lengthSync() > 0 && workingFile.lengthSync() > 0;
  }
}
