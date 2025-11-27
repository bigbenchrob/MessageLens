/// DateTime extensions for calendar operations
/// This replaces calendar_time functionality
// ignore_for_file: avoid_redundant_argument_values, omit_local_variable_types

extension CalendarDateTime on DateTime {
  /// Get the start of the day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get the end of the day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Get the start of the week (Monday)
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }

  /// Get the end of the week (Sunday)
  DateTime get endOfWeek {
    final daysToSunday = 7 - weekday;
    return add(Duration(days: daysToSunday)).endOfDay;
  }

  /// Get the start of the month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get the end of the month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Get the start of the year
  DateTime get startOfYear => DateTime(year, 1, 1);

  /// Get the end of the year
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  /// Check if this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if this date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if this date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Check if this date is in the same week as another date
  bool isSameWeek(DateTime other) {
    return startOfWeek.isBefore(other.add(const Duration(days: 1))) &&
        endOfWeek.isAfter(other.subtract(const Duration(days: 1)));
  }

  /// Check if this date is in the same month as another date
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  /// Get days difference from another date
  int daysDifference(DateTime other) {
    return difference(other).inDays.abs();
  }

  /// Add months (handles month boundaries correctly)
  DateTime addMonths(int months) {
    int newYear = year;
    int newMonth = month + months;

    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }

    // Handle days that don't exist in the target month (e.g., Jan 31 + 1 month)
    int newDay = day;
    final daysInTargetMonth = DateTime(newYear, newMonth + 1, 0).day;
    if (newDay > daysInTargetMonth) {
      newDay = daysInTargetMonth;
    }

    return DateTime(
      newYear,
      newMonth,
      newDay,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }
}
