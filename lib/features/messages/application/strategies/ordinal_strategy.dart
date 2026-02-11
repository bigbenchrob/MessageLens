/// Strategy interface for obtaining ordinal-based message counts and positions.
///
/// Each scope (global, contact, chat) provides its own implementation that
/// delegates to the appropriate data source and index table.
abstract class OrdinalStrategy {
  /// Total message count in this scope.
  ///
  /// Returns 0 if no messages exist.
  Future<int> getTotalCount();

  /// Find first ordinal on or after the given date.
  ///
  /// Returns null if no messages exist on or after the date.
  Future<int?> getFirstOrdinalOnOrAfter(DateTime date);

  /// Find first ordinal for a given month.
  ///
  /// Month key format: 'YYYY-MM' (e.g., '2023-06').
  /// Returns null if no messages exist in that month.
  Future<int?> getFirstOrdinalForMonth(String monthKey);

  /// Get the message ID at the given ordinal position.
  ///
  /// Returns null if ordinal is out of range.
  Future<int?> getMessageIdByOrdinal(int ordinal);
}
