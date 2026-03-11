import 'package:drift/drift.dart' as drift;

import '../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../domain/chat_timeline_data.dart';

/// Calculate timeline buckets for a chat based on message distribution
Future<ChatTimelineData?> calculateChatTimeline(
  WorkingDatabase db,
  int chatId,
  DateTime? firstMessageDate,
  DateTime? lastMessageDate,
) async {
  if (firstMessageDate == null || lastMessageDate == null) {
    return null;
  }

  // Calculate total span
  final spanDays = lastMessageDate.difference(firstMessageDate).inDays;

  // Determine bucketing strategy based on span
  final BucketStrategy strategy;
  if (spanDays <= 30) {
    strategy = BucketStrategy.daily;
  } else if (spanDays <= 180) {
    strategy = BucketStrategy.weekly;
  } else if (spanDays <= 730) {
    // 2 years
    strategy = BucketStrategy.biweekly;
  } else if (spanDays <= 1825) {
    // 5 years
    strategy = BucketStrategy.monthly;
  } else {
    strategy = BucketStrategy.quarterly;
  }

  // Query message counts grouped by the appropriate time period
  final bucketCounts = await _queryBucketedCounts(db, chatId, strategy);

  if (bucketCounts.isEmpty) {
    return null;
  }

  // Create timeline buckets
  final buckets = <TimelineBucket>[];
  var maxCount = 0;

  for (final entry in bucketCounts.entries) {
    final count = entry.value;
    if (count > maxCount) {
      maxCount = count;
    }

    // Parse the bucket start date based on strategy
    final bucketStart = _parseBucketKey(entry.key, strategy);
    final bucketEnd = _getBucketEnd(bucketStart, strategy);

    buckets.add(
      TimelineBucket(
        startDate: bucketStart,
        endDate: bucketEnd,
        messageCount: count,
      ),
    );
  }

  // Sort buckets by date
  buckets.sort((a, b) => a.startDate.compareTo(b.startDate));

  return ChatTimelineData(
    buckets: buckets,
    maxCount: maxCount,
    totalSpanDays: spanDays,
  );
}

/// Bucketing strategies for different time spans
enum BucketStrategy { daily, weekly, biweekly, monthly, quarterly }

/// Query message counts grouped by bucket strategy
Future<Map<String, int>> _queryBucketedCounts(
  WorkingDatabase db,
  int chatId,
  BucketStrategy strategy,
) async {
  // Determine the strftime format based on strategy
  final String dateFormat;
  switch (strategy) {
    case BucketStrategy.daily:
      dateFormat = '%Y-%m-%d';
    case BucketStrategy.weekly:
      // Group by week (year + week number)
      // We'll use the start of the week (Monday)
      dateFormat = '%Y-%W';
    case BucketStrategy.biweekly:
      // For biweekly, we'll query weekly and combine later
      dateFormat = '%Y-%W';
    case BucketStrategy.monthly:
      dateFormat = '%Y-%m';
    case BucketStrategy.quarterly:
      // For quarterly, we'll query monthly and combine later
      dateFormat = '%Y-%m';
  }

  // Build the query
  // Note: sent_at_utc is stored as ISO 8601 text, which SQLite can parse directly
  final query = db.customSelect(
    '''
    SELECT 
      strftime('$dateFormat', sent_at_utc) as bucket,
      COUNT(*) as count
    FROM messages
    WHERE chat_id = ?
      AND sent_at_utc IS NOT NULL
      AND sent_at_utc != ''
    GROUP BY bucket
    ORDER BY bucket
    ''',
    variables: [drift.Variable.withInt(chatId)],
    readsFrom: {db.workingMessages},
  );

  final results = await query.get();
  final counts = <String, int>{};

  for (final row in results) {
    final bucket = row.read<String>('bucket');
    final count = row.read<int>('count');

    if (strategy == BucketStrategy.biweekly) {
      // Combine every 2 weeks
      final weekParts = bucket.split('-');
      final year = int.parse(weekParts[0]);
      final week = int.parse(weekParts[1]);
      final biweekNumber = week ~/ 2;
      final biweekKey = '$year-${biweekNumber.toString().padLeft(2, '0')}';

      final currentCount = counts[biweekKey] ?? 0;
      counts[biweekKey] = currentCount + count;
    } else if (strategy == BucketStrategy.quarterly) {
      // Combine months into quarters
      final monthParts = bucket.split('-');
      final year = int.parse(monthParts[0]);
      final month = int.parse(monthParts[1]);
      final quarter = ((month - 1) ~/ 3) + 1;
      final quarterKey = '$year-Q$quarter';

      final currentCount = counts[quarterKey] ?? 0;
      counts[quarterKey] = currentCount + count;
    } else {
      counts[bucket] = count;
    }
  }

  return counts;
}

/// Parse bucket key based on strategy
DateTime _parseBucketKey(String key, BucketStrategy strategy) {
  switch (strategy) {
    case BucketStrategy.daily:
      // Format: "2024-10-23"
      return DateTime.parse(key);

    case BucketStrategy.weekly:
      // Format: "2024-42" (year-week)
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final week = int.parse(parts[1]);
      // Approximate: first day of the year + weeks * 7
      return DateTime(year, 1, 1).add(Duration(days: week * 7));

    case BucketStrategy.biweekly:
      // Format: "2024-05" (year-biweekNumber)
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final biweekNumber = int.parse(parts[1]);
      // Approximate: first day of the year + biweeks * 14
      return DateTime(year, 1, 1).add(Duration(days: biweekNumber * 14));

    case BucketStrategy.monthly:
      // Format: "2024-10" (year-month)
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      return DateTime(year, month, 1);

    case BucketStrategy.quarterly:
      // Format: "2024-Q3" (year-quarter)
      final parts = key.split('-Q');
      final year = int.parse(parts[0]);
      final quarter = int.parse(parts[1]);
      final month = ((quarter - 1) * 3) + 1;
      return DateTime(year, month, 1);
  }
}

/// Calculate the end date for a bucket based on strategy
DateTime _getBucketEnd(DateTime bucketStart, BucketStrategy strategy) {
  switch (strategy) {
    case BucketStrategy.daily:
      return bucketStart.add(const Duration(days: 1));
    case BucketStrategy.weekly:
      return bucketStart.add(const Duration(days: 7));
    case BucketStrategy.biweekly:
      return bucketStart.add(const Duration(days: 14));
    case BucketStrategy.monthly:
      // Add approximately 1 month
      return DateTime(bucketStart.year, bucketStart.month + 1, bucketStart.day);
    case BucketStrategy.quarterly:
      // Add approximately 3 months
      return DateTime(bucketStart.year, bucketStart.month + 3, bucketStart.day);
  }
}
