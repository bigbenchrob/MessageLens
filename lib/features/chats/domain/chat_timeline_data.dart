/// Recency category for a chat based on last message date
enum ChatRecency {
  /// Last message within 1 hour
  now,

  /// Last message today
  today,

  /// Last message within 7 days
  thisWeek,

  /// Last message within 30 days
  thisMonth,

  /// Last message within 180 days
  recent,

  /// Last message older than 180 days
  archive;

  /// Get recency category from a DateTime
  static ChatRecency fromDateTime(DateTime lastMessageDate) {
    final now = DateTime.now();
    final difference = now.difference(lastMessageDate);

    if (difference.inHours <= 1) {
      return ChatRecency.now;
    } else if (difference.inDays == 0) {
      return ChatRecency.today;
    } else if (difference.inDays <= 7) {
      return ChatRecency.thisWeek;
    } else if (difference.inDays <= 30) {
      return ChatRecency.thisMonth;
    } else if (difference.inDays <= 180) {
      return ChatRecency.recent;
    } else {
      return ChatRecency.archive;
    }
  }

  /// Get display label for the recency category
  String get label {
    switch (this) {
      case ChatRecency.now:
        return 'Now';
      case ChatRecency.today:
        return 'Today';
      case ChatRecency.thisWeek:
        return 'This week';
      case ChatRecency.thisMonth:
        return 'This month';
      case ChatRecency.recent:
        return 'Recent';
      case ChatRecency.archive:
        return 'Archive';
    }
  }

  /// Get icon for the recency category
  String get icon {
    switch (this) {
      case ChatRecency.now:
        return '⏱';
      case ChatRecency.today:
        return '📩';
      case ChatRecency.thisWeek:
        return '📆';
      case ChatRecency.thisMonth:
        return '🗓';
      case ChatRecency.recent:
        return '🗂';
      case ChatRecency.archive:
        return '📚';
    }
  }
}

/// A single bucket in the timeline visualization
class TimelineBucket {
  const TimelineBucket({
    required this.startDate,
    required this.endDate,
    required this.messageCount,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int messageCount;
}

/// Timeline data for a chat including buckets and statistics
class ChatTimelineData {
  const ChatTimelineData({
    required this.buckets,
    required this.maxCount,
    required this.totalSpanDays,
  });

  /// List of timeline buckets with message counts
  final List<TimelineBucket> buckets;

  /// Maximum message count in any bucket (for normalization)
  final int maxCount;

  /// Total span in days from first to last message
  final int totalSpanDays;

  /// Get the percentile rank for a bucket's message count
  double getPercentileRank(int messageCount) {
    if (maxCount == 0) {
      return 0;
    }
    return messageCount / maxCount;
  }
}
