import 'package:drift/drift.dart' as drift;

import '../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../messages/domain/calendar_heatmap_timeline_data.dart';

/// Calculate calendar heatmap timeline data for all messages with a contact
/// across all their chats/handles.
///
/// Creates a compact year × month grid where each month is a fixed-size
/// rectangle colored by message intensity (1 message to 50,000+)
Future<CalendarHeatmapTimelineData?> calculateContactCalendarHeatmapTimeline(
  WorkingDatabase db,
  int contactId,
  DateTime? firstMessageDate,
  DateTime? lastMessageDate,
) async {
  if (firstMessageDate == null || lastMessageDate == null) {
    print('[CONTACT_HEATMAP] Contact $contactId: Missing dates, skipping');
    return null;
  }

  final firstYear = firstMessageDate.year;
  final lastYear = lastMessageDate.year;

  print('[CONTACT_HEATMAP] Contact $contactId: Years $firstYear-$lastYear');

  // Query message counts by year-month from contact_message_index
  // This automatically aggregates across all chats/handles for this contact
  final query = db.customSelect(
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
  );

  final results = await query.get();

  if (results.isEmpty) {
    print('[CONTACT_HEATMAP] Contact $contactId: No messages in results');
    return null;
  }

  print(
    '[CONTACT_HEATMAP] Contact $contactId: Query returned ${results.length} months',
  );

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
      // Check if this month is before contact's first message
      final monthDate = DateTime(year, month);
      final contactStartDate = DateTime(
        firstMessageDate.year,
        firstMessageDate.month,
      );
      final isBeforeStart = monthDate.isBefore(contactStartDate);

      final MonthIntensity intensity;
      final int count;

      if (isBeforeStart) {
        // Month before first message with this contact
        intensity = MonthIntensity.notYetStarted;
        count = 0;
      } else {
        // Check message count
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
          chatId: contactId, // Use contactId for navigation context
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

  print(
    '[CONTACT_HEATMAP] Contact $contactId: Built ${yearRows.length} years, '
    'total=$totalMessages, maxMonth=$maxMonthCount',
  );

  return CalendarHeatmapTimelineData(
    yearRows: yearRows,
    firstMessageDate: firstMessageDate,
    lastMessageDate: lastMessageDate,
    totalMessages: totalMessages,
    maxMonthCount: maxMonthCount,
  );
}
