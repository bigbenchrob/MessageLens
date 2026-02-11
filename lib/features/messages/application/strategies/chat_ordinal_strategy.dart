import 'package:drift/drift.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../infrastructure/data_sources/message_index_data_source.dart';
import 'ordinal_strategy.dart';

/// Ordinal strategy for messages within a specific chat.
///
/// Queries the message_index table which contains messages
/// for a single chat/conversation thread in chronological order.
class ChatOrdinalStrategy implements OrdinalStrategy {
  ChatOrdinalStrategy(this._db, this.chatId)
    : _dataSource = MessageIndexDataSource(_db);

  final WorkingDatabase _db;
  final int chatId;
  final MessageIndexDataSource _dataSource;

  @override
  Future<int> getTotalCount() => _dataSource.getTotalCount(chatId);

  @override
  Future<int?> getFirstOrdinalOnOrAfter(DateTime date) async {
    // Find first message on or after the given date for this chat.
    final isoString = date.toUtc().toIso8601String();
    final result =
        await (_db.selectOnly(_db.messageIndex)
              ..addColumns([_db.messageIndex.ordinal.min()])
              ..where(
                _db.messageIndex.chatId.equals(chatId) &
                    _db.messageIndex.sentAtUtc.isNotNull() &
                    _db.messageIndex.sentAtUtc.isBiggerOrEqualValue(isoString),
              ))
            .getSingleOrNull();

    return result?.read(_db.messageIndex.ordinal.min());
  }

  @override
  Future<int?> getFirstOrdinalForMonth(String monthKey) =>
      _dataSource.getFirstOrdinalForMonth(chatId, monthKey);

  @override
  Future<int?> getMessageIdByOrdinal(int ordinal) =>
      _dataSource.getMessageIdByOrdinal(chatId, ordinal);
}
