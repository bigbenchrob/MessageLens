import 'package:drift/drift.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';

/// Data source for contact message ordinal index operations.
/// Provides O(1) lookups for all messages with a contact across multiple chats/handles.
/// Enables unified chronological view of all communication with a specific person.
class ContactMessageIndexDataSource {
  final WorkingDatabase _db;

  const ContactMessageIndexDataSource(this._db);

  /// Get total message count for a contact (participant).
  /// Returns 0 if no messages exist with this contact.
  Future<int> getTotalCount(int contactId) async {
    final result =
        await (_db.selectOnly(_db.contactMessageIndex)
              ..addColumns([_db.contactMessageIndex.ordinal.max()])
              ..where(_db.contactMessageIndex.contactId.equals(contactId)))
            .getSingleOrNull();

    if (result == null) {
      return 0;
    }

    final maxOrdinal = result.read(_db.contactMessageIndex.ordinal.max());
    // Ordinals are 0-based, so count = max + 1
    return maxOrdinal == null ? 0 : maxOrdinal + 1;
  }

  /// Get message ID for a specific ordinal position within contact's messages.
  /// Returns null if ordinal is out of range.
  Future<int?> getMessageIdByOrdinal(int contactId, int ordinal) async {
    final result =
        await (_db.select(_db.contactMessageIndex)..where(
              (t) => t.contactId.equals(contactId) & t.ordinal.equals(ordinal),
            ))
            .getSingleOrNull();

    return result?.messageId;
  }

  /// Get the first ordinal for a specific month within contact's messages.
  /// Returns null if no messages exist in that month.
  /// Month key format: 'YYYY-MM' (e.g., '2023-06')
  Future<int?> getFirstOrdinalForMonth(int contactId, String monthKey) async {
    final result =
        await (_db.selectOnly(_db.contactMessageIndex)
              ..addColumns([_db.contactMessageIndex.ordinal.min()])
              ..where(
                _db.contactMessageIndex.contactId.equals(contactId) &
                    _db.contactMessageIndex.monthKey.equals(monthKey),
              ))
            .getSingleOrNull();

    return result?.read(_db.contactMessageIndex.ordinal.min());
  }

  /// Get message IDs for an ordinal range (inclusive).
  /// Used for batch loading/hydration.
  Future<List<int>> getMessageIdsInRange(
    int contactId,
    int startOrdinal,
    int endOrdinal,
  ) async {
    final results =
        await (_db.select(_db.contactMessageIndex)
              ..where(
                (t) =>
                    t.contactId.equals(contactId) &
                    t.ordinal.isBiggerOrEqualValue(startOrdinal) &
                    t.ordinal.isSmallerOrEqualValue(endOrdinal),
              )
              ..orderBy([
                (_) => OrderingTerm.asc(_db.contactMessageIndex.ordinal),
              ]))
            .get();

    return results.map((r) => r.messageId).toList();
  }

  /// Get ordinal for a specific message ID within a contact's message sequence.
  /// Returns null if message not found in index for this contact.
  Future<int?> getOrdinalForMessage(int contactId, int messageId) async {
    final result =
        await (_db.select(_db.contactMessageIndex)..where(
              (t) =>
                  t.contactId.equals(contactId) & t.messageId.equals(messageId),
            ))
            .getSingleOrNull();

    return result?.ordinal;
  }

  /// Get month key for a specific ordinal position.
  /// Returns null if ordinal is out of range.
  /// Month key format: 'YYYY-MM' (e.g., '2023-06')
  Future<String?> getMonthKeyForOrdinal(int contactId, int ordinal) async {
    final result =
        await (_db.select(_db.contactMessageIndex)..where(
              (t) => t.contactId.equals(contactId) & t.ordinal.equals(ordinal),
            ))
            .getSingleOrNull();

    return result?.monthKey;
  }
}
