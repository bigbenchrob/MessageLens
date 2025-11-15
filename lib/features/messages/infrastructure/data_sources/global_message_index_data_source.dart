import 'package:drift/drift.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';

class GlobalMessageIndexEntry {
  final int ordinal;
  final int messageId;
  final int chatId;
  final String? sentAtUtc;
  final String monthKey;

  const GlobalMessageIndexEntry({
    required this.ordinal,
    required this.messageId,
    required this.chatId,
    required this.sentAtUtc,
    required this.monthKey,
  });
}

/// Provides keyset pagination over the global ordinal index so large datasets
/// can be streamed without loading full message payloads.
class GlobalMessageIndexDataSource {
  final WorkingDatabase _db;

  const GlobalMessageIndexDataSource(this._db);

  Future<int> getTotalCount() async {
    final result = await (_db.selectOnly(
      _db.globalMessageIndex,
    )..addColumns([_db.globalMessageIndex.ordinal.max()])).getSingleOrNull();

    final maxOrdinal = result?.read(_db.globalMessageIndex.ordinal.max());
    return maxOrdinal == null ? 0 : maxOrdinal + 1;
  }

  Future<GlobalMessageIndexEntry?> getByOrdinal(int ordinal) async {
    final row = await (_db.select(
      _db.globalMessageIndex,
    )..where((t) => t.ordinal.equals(ordinal))).getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _map(row);
  }

  Future<List<GlobalMessageIndexEntry>> fetchFirstPage(int limit) async {
    final rows =
        await (_db.select(_db.globalMessageIndex)
              ..orderBy([(t) => OrderingTerm.asc(t.ordinal)])
              ..limit(limit))
            .get();

    return rows.map(_map).toList(growable: false);
  }

  Future<List<GlobalMessageIndexEntry>> fetchAfterOrdinal({
    required int startExclusiveOrdinal,
    required int limit,
  }) async {
    final rows =
        await (_db.select(_db.globalMessageIndex)
              ..where((t) => t.ordinal.isBiggerThanValue(startExclusiveOrdinal))
              ..orderBy([(t) => OrderingTerm.asc(t.ordinal)])
              ..limit(limit))
            .get();

    return rows.map(_map).toList(growable: false);
  }

  Future<List<GlobalMessageIndexEntry>> fetchBeforeOrdinal({
    required int endExclusiveOrdinal,
    required int limit,
  }) async {
    final rows =
        await (_db.select(_db.globalMessageIndex)
              ..where((t) => t.ordinal.isSmallerThanValue(endExclusiveOrdinal))
              ..orderBy([(t) => OrderingTerm.desc(t.ordinal)])
              ..limit(limit))
            .get();

    return rows
        .map(_map)
        .toList(growable: false)
        .reversed
        .toList(growable: false);
  }

  GlobalMessageIndexEntry _map(GlobalMessageIndexData row) {
    return GlobalMessageIndexEntry(
      ordinal: row.ordinal,
      messageId: row.messageId,
      chatId: row.chatId,
      sentAtUtc: row.sentAtUtc,
      monthKey: row.monthKey,
    );
  }

  Future<int?> firstOrdinalOnOrAfter(DateTime date) async {
    final isoString = date.toUtc().toIso8601String();
    final row =
        await (_db.select(_db.globalMessageIndex)
              ..where(
                (t) =>
                    t.sentAtUtc.isNotNull() &
                    t.sentAtUtc.isBiggerOrEqualValue(isoString),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.sentAtUtc)])
              ..limit(1))
            .getSingleOrNull();

    return row?.ordinal;
  }
}
