import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../domain/calendar_heatmap_timeline_data.dart';

part 'global_messages_heatmap_provider.g.dart';

/// Provides a calendar heatmap timeline spanning the entire message archive.
@riverpod
Future<CalendarHeatmapTimelineData?> globalMessagesHeatmap(
  GlobalMessagesHeatmapRef ref,
) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  final boundsRow = await db
      .customSelect(
        '''
        SELECT MIN(sent_at_utc) as first_date,
               MAX(sent_at_utc) as last_date
        FROM global_message_index
        WHERE sent_at_utc IS NOT NULL
          AND sent_at_utc != ''
        ''',
        readsFrom: {db.globalMessageIndex},
      )
      .getSingleOrNull();

  if (boundsRow == null) {
    return null;
  }

  final firstUtc = boundsRow.read<String?>('first_date');
  final lastUtc = boundsRow.read<String?>('last_date');

  final firstDate = firstUtc == null || firstUtc.isEmpty
      ? null
      : DateTime.tryParse(firstUtc);
  final lastDate = lastUtc == null || lastUtc.isEmpty
      ? null
      : DateTime.tryParse(lastUtc);

  if (firstDate == null || lastDate == null) {
    return null;
  }

  final results = await db
      .customSelect(
        '''
        SELECT 
          strftime('%Y', sent_at_utc) as year,
          strftime('%m', sent_at_utc) as month,
          COUNT(*) as count
        FROM global_message_index
        WHERE sent_at_utc IS NOT NULL
          AND sent_at_utc != ''
        GROUP BY year, month
        ORDER BY year, month
        ''',
        readsFrom: {db.globalMessageIndex},
      )
      .get();

  if (results.isEmpty) {
    return null;
  }

  final firstYear = firstDate.year;
  final lastYear = lastDate.year;

  final counts = <String, int>{};
  for (final row in results) {
    final year = row.read<String>('year');
    final month = row.read<String>('month');
    final count = row.read<int>('count');
    counts['$year-$month'] = count;
  }

  final firstMonth = DateTime(firstDate.year, firstDate.month);
  final yearRows = <YearRow>[];
  var totalMessages = 0;
  var maxMonthCount = 0;

  for (var year = firstYear; year <= lastYear; year++) {
    final months = <MonthData>[];
    var yearHasMessages = false;

    for (var month = 1; month <= 12; month++) {
      final key = '$year-${month.toString().padLeft(2, '0')}';
      final count = counts[key] ?? 0;
      final monthDate = DateTime(year, month);
      final isBeforeStart = monthDate.isBefore(firstMonth);

      if (!isBeforeStart && count > 0) {
        yearHasMessages = true;
        totalMessages += count;
        if (count > maxMonthCount) {
          maxMonthCount = count;
        }
      }

      final intensity = isBeforeStart
          ? MonthIntensity.notYetStarted
          : MonthIntensity.fromMessageCount(count);

      months.add(
        MonthData(
          year: year,
          month: month,
          messageCount: count,
          intensity: intensity,
          chatId: 0,
        ),
      );
    }

    yearRows.add(
      YearRow(year: year, months: months, hasMessages: yearHasMessages),
    );
  }

  return CalendarHeatmapTimelineData(
    yearRows: yearRows,
    firstMessageDate: firstDate,
    lastMessageDate: lastDate,
    totalMessages: totalMessages,
    maxMonthCount: maxMonthCount,
  );
}
