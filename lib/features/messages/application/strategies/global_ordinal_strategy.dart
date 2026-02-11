import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../infrastructure/data_sources/global_message_index_data_source.dart';
import 'ordinal_strategy.dart';

/// Ordinal strategy for the global message timeline.
///
/// Queries the global_message_index table which contains all messages
/// across all contacts and chats in chronological order.
class GlobalOrdinalStrategy implements OrdinalStrategy {
  GlobalOrdinalStrategy(WorkingDatabase db)
    : _dataSource = GlobalMessageIndexDataSource(db);

  final GlobalMessageIndexDataSource _dataSource;

  @override
  Future<int> getTotalCount() => _dataSource.getTotalCount();

  @override
  Future<int?> getFirstOrdinalOnOrAfter(DateTime date) =>
      _dataSource.firstOrdinalOnOrAfter(date);

  @override
  Future<int?> getFirstOrdinalForMonth(String monthKey) async {
    // Global index doesn't have a direct getFirstOrdinalForMonth,
    // so we convert month key to a date and use firstOrdinalOnOrAfter.
    final parts = monthKey.split('-');
    if (parts.length != 2) {
      return null;
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null) {
      return null;
    }
    final startOfMonth = DateTime.utc(year, month);
    return _dataSource.firstOrdinalOnOrAfter(startOfMonth);
  }

  @override
  Future<int?> getMessageIdByOrdinal(int ordinal) async {
    final entry = await _dataSource.getByOrdinal(ordinal);
    return entry?.messageId;
  }
}
