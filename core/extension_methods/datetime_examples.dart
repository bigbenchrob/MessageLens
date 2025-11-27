// // ignore_for_file: unused_local_variable, avoid_redundant_argument_values, omit_local_variable_types

// import 'package:jiffy/jiffy.dart';
// import '../extension_methods/datetime_extensions.dart';

// /// Examples of how to use the calendar_time alternatives
// class DateTimeExamples {
//   /// Using built-in DateTime with custom extensions
//   void builtInDateTimeExamples() {
//     final now = DateTime.now();

//     // Start and end of periods
//     final startOfDay = now.startOfDay;
//     final endOfDay = now.endOfDay;
//     final startOfWeek = now.startOfWeek;
//     final endOfWeek = now.endOfWeek;
//     final startOfMonth = now.startOfMonth;
//     final endOfMonth = now.endOfMonth;

//     // Boolean checks
//     final isToday = now.isToday;
//     final isYesterday = now.isYesterday;
//     final isTomorrow = now.isTomorrow;

//     // Date arithmetic
//     final nextMonth = now.addMonths(1);
//     final daysDiff = now.daysDifference(DateTime(2024, 1, 1));

//     print('Start of today: $startOfDay');
//     print('End of month: $endOfMonth');
//     print('Is today: $isToday');
//     print('Next month: $nextMonth');
//   }

//   /// Using Jiffy package (moment.js style)
//   void jiffyExamples() {
//     final now = Jiffy.now();

//     // Start and end of periods
//     final startOfDay = now.startOf(Unit.day);
//     final endOfDay = now.endOf(Unit.day);
//     final startOfWeek = now.startOf(Unit.week);
//     final endOfWeek = now.endOf(Unit.week);
//     final startOfMonth = now.startOf(Unit.month);
//     final endOfMonth = now.endOf(Unit.month);

//     // Date arithmetic
//     final nextWeek = now.add(weeks: 1);
//     final lastMonth = now.subtract(months: 1);
//     final in30Days = now.add(days: 30);

//     // Formatting
//     final formatted = now.format(pattern: 'yyyy-MM-dd HH:mm:ss');
//     final relative = now.fromNow(); // "a few seconds ago"

//     // Comparisons
//     final isAfter = now.isAfter(Jiffy.parse('2024-01-01'));
//     final isBefore = now.isBefore(Jiffy.parse('2025-01-01'));
//     final isSame = now.isSame(Jiffy.now(), unit: Unit.day);

//     print('Start of week (Jiffy): ${startOfWeek.dateTime}');
//     print('Next week: ${nextWeek.dateTime}');
//     print('Formatted: $formatted');
//     print('Relative: $relative');
//   }

//   /// Using built-in Duration for time arithmetic
//   void builtInDurationExamples() {
//     final now = DateTime.now();

//     // Using Duration class (built-in)
//     final in2Hours = now.add(const Duration(hours: 2));
//     final in30Minutes = now.add(const Duration(minutes: 30));
//     final in5Days = now.add(const Duration(days: 5));
//     final in2Weeks = now.add(const Duration(days: 14));

//     // Complex duration
//     const duration = Duration(hours: 2, minutes: 30, seconds: 15);
//     final future = now.add(duration);

//     print('In 2 hours: $in2Hours');
//     print('In 5 days: $in5Days');
//     print('Complex duration: $duration');
//     print('Future time: $future');
//   }

//   /// Practical calendar operations
//   void calendarOperations() {
//     final today = DateTime.now();

//     // Get all days in current month
//     List<DateTime> getDaysInMonth(DateTime date) {
//       final start = date.startOfMonth;
//       final end = date.endOfMonth;
//       final days = <DateTime>[];

//       for (int i = 0; i <= end.day - start.day; i++) {
//         days.add(start.add(Duration(days: i)));
//       }
//       return days;
//     }

//     // Get work days (Monday to Friday) in current month
//     List<DateTime> getWorkDaysInMonth(DateTime date) {
//       return getDaysInMonth(
//         date,
//       ).where((day) => day.weekday >= 1 && day.weekday <= 5).toList();
//     }

//     // Check if date is weekend
//     bool isWeekend(DateTime date) {
//       return date.weekday == 6 || date.weekday == 7; // Saturday or Sunday
//     }

//     // Examples
//     final daysThisMonth = getDaysInMonth(today);
//     final workDays = getWorkDaysInMonth(today);
//     final todayIsWeekend = isWeekend(today);

//     print('Days in this month: ${daysThisMonth.length}');
//     print('Work days this month: ${workDays.length}');
//     print('Today is weekend: $todayIsWeekend');
//   }
// }
