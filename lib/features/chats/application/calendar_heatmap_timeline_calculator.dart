import 'package:drift/drift.dart' as drift;

import '../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../domain/calendar_heatmap_timeline_data.dart';

/// Calculate calendar heatmap timeline data for a chat
///
/// Creates a compact year × month grid where each month is a fixed-size
/// rectangle colored by message intensity (1 message to 50,000+)
Future<CalendarHeatmapTimelineData?> calculateCalendarHeatmapTimeline(
  WorkingDatabase db,
  int chatId,
  DateTime? firstMessageDate,
  DateTime? lastMessageDate,
) async {
  if (firstMessageDate == null || lastMessageDate == null) {
    return null;
  }

  final firstYear = firstMessageDate.year;
  final lastYear = lastMessageDate.year;

  // Query message counts by year-month
  final query = db.customSelect(
    '''
    SELECT 
      strftime('%Y', sent_at_utc) as year,
      strftime('%m', sent_at_utc) as month,
      COUNT(*) as count
    FROM messages
    WHERE chat_id = ?
      AND sent_at_utc IS NOT NULL
      AND sent_at_utc != ''
    GROUP BY year, month
    ORDER BY year, month
    ''',
    variables: [drift.Variable.withInt(chatId)],
    readsFrom: {db.workingMessages},
  );

  final results = await query.get();

  if (results.isEmpty) {
    return null;
  }

  // Build a map of year-month to count
  final counts = <String, int>{};
  for (final row in results) {
    final year = row.read<String>('year');
    final month = row.read<String>('month');
    final count = row.read<int>('count');
    counts['$year-$month'] = count;
  }

  // Build year rows
  final yearRows = <YearRow>[];
  var totalMessages = 0;
  var maxMonthCount = 0;

  for (var year = firstYear; year <= lastYear; year++) {
    final months = <MonthData>[];
    var yearHasMessages = false;

    for (var month = 1; month <= 12; month++) {
      // Check if this month is before the chat started
      final monthDate = DateTime(year, month);
      final chatStartDate = DateTime(
        firstMessageDate.year,
        firstMessageDate.month,
      );
      final isBeforeStart = monthDate.isBefore(chatStartDate);

      final MonthIntensity intensity;
      final int count;

      if (isBeforeStart) {
        // Month before chat started - show nothing
        intensity = MonthIntensity.notYetStarted;
        count = 0;
      } else {
        // Chat was active - check message count
        final key = '$year-${month.toString().padLeft(2, '0')}';
        count = counts[key] ?? 0;

        if (count > 0) {
          yearHasMessages = true;
          totalMessages += count;
          if (count > maxMonthCount) {
            maxMonthCount = count;
          }
        }

        intensity = MonthIntensity.fromMessageCount(count);
      }

      months.add(
        MonthData(
          year: year,
          month: month,
          messageCount: count,
          intensity: intensity,
          chatId: chatId,
        ),
      );
    }

    // Include ALL years in range (even if only some months have messages)
    yearRows.add(
      YearRow(year: year, months: months, hasMessages: yearHasMessages),
    );
  }

  if (yearRows.isEmpty) {
    return null;
  }

  return CalendarHeatmapTimelineData(
    yearRows: yearRows,
    firstMessageDate: firstMessageDate,
    lastMessageDate: lastMessageDate,
    totalMessages: totalMessages,
    maxMonthCount: maxMonthCount,
  );
}
