import 'package:drift/drift.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'ordinal_strategy.dart';

/// Ordinal strategy for messages with a specific contact filtered to a single
/// handle.
///
/// Uses raw SQL that JOINs `contact_message_index` → `messages` →
/// `chat_to_handle` so we get ALL messages (both sent and received) in
/// conversations that involve the selected handle. Because the filtering
/// makes the original ordinals sparse, every method maps to dense positions
/// via `LIMIT … OFFSET` or `COUNT(*)`.
class FilteredContactOrdinalStrategy implements OrdinalStrategy {
  FilteredContactOrdinalStrategy(this._db, this.contactId, this.handleId);

  final WorkingDatabase _db;
  final int contactId;
  final int handleId;

  /// Base FROM + WHERE clause shared by every query.
  ///
  /// Joins contact_message_index to messages, then to chat_to_handle to
  /// filter to chats where the selected handle participates.
  static const _baseFromWhere = '''
    FROM contact_message_index cmi
    JOIN messages m ON m.id = cmi.message_id
    JOIN chat_to_handle cth ON cth.chat_id = m.chat_id AND cth.handle_id = ?
    WHERE cmi.contact_id = ?
  ''';

  List<Variable> get _baseVars => [
    Variable.withInt(handleId),
    Variable.withInt(contactId),
  ];

  @override
  Future<int> getTotalCount() async {
    final result = await _db
        .customSelect(
          '''
          SELECT COUNT(*) AS cnt
          $_baseFromWhere
          ''',
          variables: _baseVars,
          readsFrom: {
            _db.contactMessageIndex,
            _db.workingMessages,
            _db.chatToHandle,
          },
        )
        .getSingleOrNull();

    return result?.read<int?>('cnt') ?? 0;
  }

  @override
  Future<int?> getFirstOrdinalOnOrAfter(DateTime date) async {
    // Return the dense ordinal (0-based position) of the first matching
    // message whose sent_at_utc >= the requested date.
    final isoString = date.toUtc().toIso8601String();

    // Count how many matching messages come BEFORE the target date —
    // that count IS the dense ordinal of the first message on-or-after.
    final result = await _db
        .customSelect(
          '''
          SELECT COUNT(*) AS pos
          $_baseFromWhere
            AND cmi.sent_at_utc < ?
          ''',
          variables: [..._baseVars, Variable.withString(isoString)],
          readsFrom: {
            _db.contactMessageIndex,
            _db.workingMessages,
            _db.chatToHandle,
          },
        )
        .getSingleOrNull();

    final pos = result?.read<int?>('pos') ?? 0;

    // Verify that the position actually exists (the date might be past all
    // messages).
    final total = await getTotalCount();
    if (pos >= total) {
      return null;
    }
    return pos;
  }

  @override
  Future<int?> getFirstOrdinalForMonth(String monthKey) async {
    final result = await _db
        .customSelect(
          '''
          SELECT COUNT(*) AS pos
          $_baseFromWhere
            AND cmi.month_key < ?
          ''',
          variables: [..._baseVars, Variable.withString(monthKey)],
          readsFrom: {
            _db.contactMessageIndex,
            _db.workingMessages,
            _db.chatToHandle,
          },
        )
        .getSingleOrNull();

    final pos = result?.read<int?>('pos') ?? 0;
    final total = await getTotalCount();
    if (pos >= total) {
      return null;
    }
    return pos;
  }

  @override
  Future<int?> getMessageIdByOrdinal(int ordinal) async {
    final result = await _db
        .customSelect(
          '''
          SELECT cmi.message_id
          $_baseFromWhere
          ORDER BY cmi.ordinal ASC
          LIMIT 1 OFFSET ?
          ''',
          variables: [..._baseVars, Variable.withInt(ordinal)],
          readsFrom: {
            _db.contactMessageIndex,
            _db.workingMessages,
            _db.chatToHandle,
          },
        )
        .getSingleOrNull();

    return result?.read<int?>('message_id');
  }
}
