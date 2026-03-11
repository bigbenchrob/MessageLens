import 'package:drift/drift.dart' as drift;

import '../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../domain/year_based_timeline_data.dart';

/// Calculate year-based timeline data for a chat
///
/// This algorithm creates intuitive timeline visualizations by:
/// 1. Segmenting data by calendar year
/// 2. Choosing appropriate granularity per year based on message density
/// 3. Skipping empty years
/// 4. Scaling year line widths based on total timespan
Future<YearBasedTimelineData?> calculateYearBasedTimeline(
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
  final totalSpanYears = (lastYear - firstYear) + 1;

  // Query message counts by year and month
  final yearMonthCounts = await _queryMessageCountsByYearMonth(db, chatId);

  if (yearMonthCounts.isEmpty) {
    return null;
  }

  // Determine granularity based on total span and message density
  final granularity = _determineGranularity(
    totalSpanYears,
    yearMonthCounts,
    firstMessageDate,
    lastMessageDate,
  );

  // Build year timelines
  final yearTimelines = <YearTimeline>[];
  var overallMaxCount = 0;

  for (var year = firstYear; year <= lastYear; year++) {
    final yearData = await _buildYearTimeline(
      db,
      chatId,
      year,
      granularity,
      yearMonthCounts,
    );

    if (yearData != null && yearData.hasMessages) {
      yearTimelines.add(yearData);
      if (yearData.maxCount > overallMaxCount) {
        overallMaxCount = yearData.maxCount;
      }
    }
  }

  if (yearTimelines.isEmpty) {
    return null;
  }

  return YearBasedTimelineData(
    yearTimelines: yearTimelines,
    totalSpanYears: totalSpanYears,
    overallMaxCount: overallMaxCount,
    firstMessageDate: firstMessageDate,
    lastMessageDate: lastMessageDate,
  );
}

/// Query message counts grouped by year and month
Future<Map<String, int>> _queryMessageCountsByYearMonth(
  WorkingDatabase db,
  int chatId,
) async {
  final query = db.customSelect(
    '''
    SELECT 
      strftime('%Y-%m', sent_at_utc) as year_month,
      COUNT(*) as count
    FROM messages
    WHERE chat_id = ?
      AND sent_at_utc IS NOT NULL
      AND sent_at_utc != ''
    GROUP BY year_month
    ORDER BY year_month
    ''',
    variables: [drift.Variable.withInt(chatId)],
    readsFrom: {db.workingMessages},
  );

  final results = await query.get();
  final counts = <String, int>{};

  for (final row in results) {
    final yearMonth = row.read<String>('year_month');
    final count = row.read<int>('count');
    counts[yearMonth] = count;
  }

  return counts;
}

/// Determine appropriate granularity based on timespan and message density
TimelineGranularity _determineGranularity(
  int totalSpanYears,
  Map<String, int> yearMonthCounts,
  DateTime firstMessageDate,
  DateTime lastMessageDate,
) {
  // For very recent, concentrated activity (< 3 months), consider daily
  final spanDays = lastMessageDate.difference(firstMessageDate).inDays;
  if (spanDays <= 90) {
    // Check if messages are spread out or concentrated
    final totalMessages = yearMonthCounts.values.fold(
      0,
      (sum, count) => sum + count,
    );
    final avgMessagesPerDay = totalMessages / spanDays;

    if (avgMessagesPerDay < 5) {
      return TimelineGranularity.weekly; // Sparse - use weekly
    }
  }

  // For long spans (10+ years), use quarterly to keep segments readable
  if (totalSpanYears >= 10) {
    return TimelineGranularity.quarterly;
  }

  // Default: monthly buckets (most intuitive - 12 months per year)
  return TimelineGranularity.monthly;
}

/// Build timeline data for a single year
Future<YearTimeline?> _buildYearTimeline(
  WorkingDatabase db,
  int chatId,
  int year,
  TimelineGranularity granularity,
  Map<String, int> yearMonthCounts,
) async {
  // Get months for this year from the pre-queried data
  final yearMonths = <int, int>{};
  for (var month = 1; month <= 12; month++) {
    final key = '$year-${month.toString().padLeft(2, '0')}';
    yearMonths[month] = yearMonthCounts[key] ?? 0;
  }

  final totalMessages = yearMonths.values.fold(0, (sum, count) => sum + count);
  if (totalMessages == 0) {
    return null; // Skip empty years
  }

  // Build buckets based on granularity
  final buckets = <YearPeriodBucket>[];
  var maxCount = 0;

  switch (granularity) {
    case TimelineGranularity.daily:
      // For daily, we need more detailed data (this is rare)
      buckets.addAll(await _buildDailyBuckets(db, chatId, year));

    case TimelineGranularity.weekly:
      // Aggregate months into ~4 weeks each
      for (var month = 1; month <= 12; month++) {
        final count = yearMonths[month] ?? 0;
        final weekIndex = (month - 1) * 4; // Approximate: 4 weeks per month

        // Distribute the month's messages across ~4 weeks
        final weekCount = (count / 4).round();
        for (var w = 0; w < 4; w++) {
          final periodIndex = weekIndex + w;
          if (periodIndex < 52) {
            // Keep within 52 weeks
            buckets.add(
              YearPeriodBucket(
                periodIndex: periodIndex,
                messageCount: weekCount,
                isHighDensity: weekCount > kHighDensityThreshold,
              ),
            );
            if (weekCount > maxCount) {
              maxCount = weekCount;
            }
          }
        }
      }

    case TimelineGranularity.monthly:
      // Standard: 12 months
      for (var month = 1; month <= 12; month++) {
        final count = yearMonths[month] ?? 0;
        buckets.add(
          YearPeriodBucket(
            periodIndex: month - 1, // 0-11
            messageCount: count,
            isHighDensity: count > kHighDensityThreshold,
          ),
        );
        if (count > maxCount) {
          maxCount = count;
        }
      }

    case TimelineGranularity.quarterly:
      // 4 quarters
      for (var quarter = 1; quarter <= 4; quarter++) {
        var quarterCount = 0;
        for (var m = 0; m < 3; m++) {
          final month = ((quarter - 1) * 3) + m + 1;
          quarterCount += yearMonths[month] ?? 0;
        }

        buckets.add(
          YearPeriodBucket(
            periodIndex: quarter - 1, // 0-3
            messageCount: quarterCount,
            isHighDensity: quarterCount > kHighDensityThreshold,
          ),
        );
        if (quarterCount > maxCount) {
          maxCount = quarterCount;
        }
      }
  }

  return YearTimeline(
    year: year,
    buckets: buckets,
    granularity: granularity,
    maxCount: maxCount,
    hasMessages: totalMessages > 0,
  );
}

/// Build daily buckets for a specific year (used for very recent activity)
Future<List<YearPeriodBucket>> _buildDailyBuckets(
  WorkingDatabase db,
  int chatId,
  int year,
) async {
  final query = db.customSelect(
    '''
    SELECT 
      strftime('%j', sent_at_utc) as day_of_year,
      COUNT(*) as count
    FROM messages
    WHERE chat_id = ?
      AND strftime('%Y', sent_at_utc) = ?
      AND sent_at_utc IS NOT NULL
      AND sent_at_utc != ''
    GROUP BY day_of_year
    ORDER BY day_of_year
    ''',
    variables: [
      drift.Variable.withInt(chatId),
      drift.Variable.withString(year.toString()),
    ],
    readsFrom: {db.workingMessages},
  );

  final results = await query.get();
  final buckets = <YearPeriodBucket>[];

  for (final row in results) {
    final dayOfYear = int.parse(row.read<String>('day_of_year'));
    final count = row.read<int>('count');

    buckets.add(
      YearPeriodBucket(
        periodIndex: dayOfYear - 1, // 0-364
        messageCount: count,
        isHighDensity: count > kMaxDotsPerDay,
      ),
    );
  }

  return buckets;
}
