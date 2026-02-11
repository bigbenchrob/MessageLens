import 'package:drift/drift.dart' as drift;

import '../../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../domain/calendar_heatmap_timeline_data.dart';

/// Pure computation: query contact_message_index and build a calendar heatmap.
///
/// This is a resolver tool: a shared pure helper for resolvers.
/// It contains no Riverpod, no widgets, and no routing.
///
/// Queries `contact_message_index` (which aggregates across all chats/handles
/// for the given contact) and returns a year × month grid of message intensity.
Future<CalendarHeatmapTimelineData?> calculateContactCalendarHeatmapTimeline(
  WorkingDatabase db,
  int contactId,
  DateTime firstMessageDate,
  DateTime lastMessageDate,
) async {
  final firstYear = firstMessageDate.year;
  final lastYear = lastMessageDate.year;

  final results = await db
      .customSelect(
        '''
    SELECT
      strftime('%Y', cmi.sent_at_utc) as year,
      strftime('%m', cmi.sent_at_utc) as month,
      COUNT(*) as count
    FROM contact_message_index cmi
    WHERE cmi.contact_id = ?
      AND cmi.sent_at_utc IS NOT NULL
      AND cmi.sent_at_utc != ''
    GROUP BY year, month
    ORDER BY year, month
    ''',
        variables: [drift.Variable.withInt(contactId)],
        readsFrom: {db.contactMessageIndex},
      )
      .get();

  if (results.isEmpty) {
    return null;
  }

  final counts = <String, int>{};
  for (final row in results) {
    final year = row.read<String>('year');
    final month = row.read<String>('month');
    final count = row.read<int>('count');
    counts['$year-$month'] = count;
  }

  final contactStartMonth = DateTime(
    firstMessageDate.year,
    firstMessageDate.month,
  );
  final yearRows = <YearRow>[];
  var totalMessages = 0;
  var maxMonthCount = 0;

  for (var year = firstYear; year <= lastYear; year++) {
    final months = <MonthData>[];
    var yearHasMessages = false;

    for (var month = 1; month <= 12; month++) {
      final monthDate = DateTime(year, month);
      final isBeforeStart = monthDate.isBefore(contactStartMonth);

      final MonthIntensity intensity;
      final int count;

      if (isBeforeStart) {
        intensity = MonthIntensity.notYetStarted;
        count = 0;
      } else {
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
          chatId: contactId,
        ),
      );
    }

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
