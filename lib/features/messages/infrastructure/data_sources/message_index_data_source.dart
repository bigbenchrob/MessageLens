import 'package:drift/drift.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';

/// Data source for message ordinal index operations.
/// Provides O(1) lookups and timeline navigation without loading all messages.
class MessageIndexDataSource {
  final WorkingDatabase _db;

  const MessageIndexDataSource(this._db);

  /// Get total message count for a chat.
  /// Returns 0 if chat has no messages.
  Future<int> getTotalCount(int chatId) async {
    final result =
        await (_db.selectOnly(_db.messageIndex)
              ..addColumns([_db.messageIndex.ordinal.max()])
              ..where(_db.messageIndex.chatId.equals(chatId)))
            .getSingleOrNull();

    if (result == null) {
      return 0;
    }

    final maxOrdinal = result.read(_db.messageIndex.ordinal.max());
    // Ordinals are 0-based, so count = max + 1
    return maxOrdinal == null ? 0 : maxOrdinal + 1;
  }

  /// Get message ID for a specific ordinal position.
  /// Returns null if ordinal is out of range.
  Future<int?> getMessageIdByOrdinal(int chatId, int ordinal) async {
    final result =
        await (_db.select(_db.messageIndex)..where(
              (t) => t.chatId.equals(chatId) & t.ordinal.equals(ordinal),
            ))
            .getSingleOrNull();

    return result?.messageId;
  }

  /// Get the first ordinal for a specific month.
  /// Returns null if no messages exist in that month.
  /// Month key format: 'YYYY-MM' (e.g., '2023-06')
  Future<int?> getFirstOrdinalForMonth(int chatId, String monthKey) async {
    final result =
        await (_db.selectOnly(_db.messageIndex)
              ..addColumns([_db.messageIndex.ordinal.min()])
              ..where(
                _db.messageIndex.chatId.equals(chatId) &
                    _db.messageIndex.monthKey.equals(monthKey),
              ))
            .getSingleOrNull();

    return result?.read(_db.messageIndex.ordinal.min());
  }

  /// Get message IDs for an ordinal range (inclusive).
  /// Used for batch loading/hydration.
  Future<List<int>> getMessageIdsInRange(
    int chatId,
    int startOrdinal,
    int endOrdinal,
  ) async {
    final results =
        await (_db.select(_db.messageIndex)
              ..where(
                (t) =>
                    t.chatId.equals(chatId) &
                    t.ordinal.isBiggerOrEqualValue(startOrdinal) &
                    t.ordinal.isSmallerOrEqualValue(endOrdinal),
              )
              ..orderBy([(_) => OrderingTerm.asc(_db.messageIndex.ordinal)]))
            .get();

    return results.map((r) => r.messageId).toList();
  }

  /// Get ordinal for a specific message ID.
  /// Returns null if message not found in index.
  Future<int?> getOrdinalForMessage(int messageId) async {
    final result = await (_db.select(
      _db.messageIndex,
    )..where((t) => t.messageId.equals(messageId))).getSingleOrNull();

    return result?.ordinal;
  }

  /// Get month key for a specific ordinal position.
  /// Returns null if ordinal is out of range.
  /// Month key format: 'YYYY-MM' (e.g., '2023-06')
  Future<String?> getMonthKeyForOrdinal(int chatId, int ordinal) async {
    final result =
        await (_db.select(_db.messageIndex)..where(
              (t) => t.chatId.equals(chatId) & t.ordinal.equals(ordinal),
            ))
            .getSingleOrNull();

    return result?.monthKey;
  }
}
