/// Year-based timeline data structures for intuitive message distribution visualization
///
/// This approach provides consistent visual anchoring by showing each year as a separate
/// line segment, making it easy to understand message patterns regardless of timespan.

/// Granularity level for timeline buckets within a year
enum TimelineGranularity {
  /// Daily buckets (for very recent, concentrated activity)
  daily,

  /// Weekly buckets (for spans up to ~6 months)
  weekly,

  /// Monthly buckets (standard - 12 months per year)
  monthly,

  /// Quarterly buckets (for very long spans to keep segments readable)
  quarterly,
}

/// A single time period within a year (could be day/week/month/quarter)
class YearPeriodBucket {
  const YearPeriodBucket({
    required this.periodIndex,
    required this.messageCount,
    required this.isHighDensity,
  });

  /// Period index (0-11 for months, 0-6 for days, etc.)
  final int periodIndex;

  /// Number of messages in this period
  final int messageCount;

  /// True if this period has high message density (should show as stacked dots)
  final bool isHighDensity;
}

/// Timeline data for a single year
class YearTimeline {
  const YearTimeline({
    required this.year,
    required this.buckets,
    required this.granularity,
    required this.maxCount,
    required this.hasMessages,
  });

  /// Calendar year (e.g., 2023)
  final int year;

  /// Buckets for this year (length depends on granularity)
  final List<YearPeriodBucket> buckets;

  /// The granularity used for this year's buckets
  final TimelineGranularity granularity;

  /// Maximum message count in any bucket for this year (for normalization)
  final int maxCount;

  /// Whether this year has any messages at all
  final bool hasMessages;

  /// Get percentile rank for a bucket's message count
  double getPercentileRank(int messageCount) {
    if (maxCount == 0) {
      return 0;
    }
    return messageCount / maxCount;
  }
}

/// Complete timeline data organized by years
class YearBasedTimelineData {
  const YearBasedTimelineData({
    required this.yearTimelines,
    required this.totalSpanYears,
    required this.overallMaxCount,
    required this.firstMessageDate,
    required this.lastMessageDate,
  });

  /// List of year timelines (only years with messages)
  final List<YearTimeline> yearTimelines;

  /// Total number of years spanned (including empty years)
  final int totalSpanYears;

  /// Maximum message count across all years and buckets
  final int overallMaxCount;

  /// Date of first message
  final DateTime firstMessageDate;

  /// Date of last message
  final DateTime lastMessageDate;

  /// Calculate optimal line width for each year based on total span
  /// Returns a value between 0.0 (shortest) and 1.0 (max ~1/4 card width)
  double getYearLineWidthFactor() {
    if (totalSpanYears <= 1) {
      return 1.0; // Single year gets full width
    } else if (totalSpanYears <= 3) {
      return 0.8; // 2-3 years get 80% width each
    } else if (totalSpanYears <= 5) {
      return 0.6; // 4-5 years get 60% width each
    } else if (totalSpanYears <= 10) {
      return 0.4; // 6-10 years get 40% width each
    } else {
      return 0.25; // 10+ years get minimum width each
    }
  }

  /// Check if we should use compact year labels (for many years)
  bool get shouldUseCompactLabels => totalSpanYears > 5;
}

/// Threshold for considering a period "high density" (should show as dots)
const int kHighDensityThreshold = 100;

/// Maximum messages per day to show as individual dots before stacking
const int kMaxDotsPerDay = 10;
