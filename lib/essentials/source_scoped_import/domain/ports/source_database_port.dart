abstract interface class ReadOnlySourceDatabase {
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);

  Future<List<Map<String, Object?>>> query(String table, {String? orderBy});

  Future<SourceMessageImportWindow> messageImportWindowAfter(int sourceRowId);

  Future<List<Map<String, Object?>>> readMessageImportPage({
    required int afterSourceRowId,
    required int throughSourceRowId,
    required int limit,
  });

  Future<Set<String>> findExistingMessageGuids(Set<String> targetGuids);

  Future<void> close();
}

abstract interface class SourceDatabaseOpener {
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath);
}

final class SourceMessageImportWindow {
  const SourceMessageImportWindow({
    required this.highWaterSourceRowId,
    required this.totalRowCount,
  });

  final int? highWaterSourceRowId;
  final int totalRowCount;
}
