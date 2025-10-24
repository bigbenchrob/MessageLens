/// Calendar heatmap timeline data structures
///
/// Represents message activity as a compact calendar grid where each month is a
/// fixed-size rectangle colored by message intensity. This approach:
/// - Handles 1 to 50,000+ messages with equal visual clarity
/// - Uses minimal vertical space (no tall bars)
/// - Wraps long timespans across multiple rows
/// - Shows sparse data with dots, dense data with color intensity

/// Intensity level for a month's message activity
enum MonthIntensity {
  /// Month before chat started (show nothing - empty space)
  notYetStarted,

  /// Chat active but no messages this month (show empty square with grey border)
  empty,

  /// 1-3 messages (show as 1-3 dots)
  fewDots,

  /// 4-10 messages (light gray)
  lightGray,

  /// 11-30 messages (medium gray)
  mediumGray,

  /// 31-50 messages (dark gray)
  darkGray,

  /// 51-100 messages (light yellow)
  lightYellow,

  /// 101-200 messages (dark yellow)
  darkYellow,

  /// 201-500 messages (light green)
  lightGreen,

  /// 501-1000 messages (medium green)
  mediumGreen,

  /// 1001-2000 messages (dark green)
  darkGreen,

  /// 2001-3000 messages (light blue)
  lightBlue,

  /// 3001-5000 messages (medium blue)
  mediumBlue,

  /// 5001-8000 messages (dark blue)
  darkBlue,

  /// 8001-12000 messages (light orange)
  lightOrange,

  /// 12001-20000 messages (dark orange)
  darkOrange,

  /// 20001-30000 messages (light purple)
  lightPurple,

  /// 30001-50000 messages (dark purple)
  darkPurple,

  /// 50001+ messages (red - maximum intensity)
  red;

  /// Get intensity level from message count
  /// Note: This only handles counts >= 0 where chat is active.
  /// Use MonthIntensity.notYetStarted explicitly for months before chat started.
  static MonthIntensity fromMessageCount(int count) {
    if (count == 0) {
      return MonthIntensity.empty;
    } else if (count <= 3) {
      return MonthIntensity.fewDots;
    } else if (count <= 10) {
      return MonthIntensity.lightGray;
    } else if (count <= 30) {
      return MonthIntensity.mediumGray;
    } else if (count <= 50) {
      return MonthIntensity.darkGray;
    } else if (count <= 100) {
      return MonthIntensity.lightYellow;
    } else if (count <= 200) {
      return MonthIntensity.darkYellow;
    } else if (count <= 500) {
      return MonthIntensity.lightGreen;
    } else if (count <= 1000) {
      return MonthIntensity.mediumGreen;
    } else if (count <= 2000) {
      return MonthIntensity.darkGreen;
    } else if (count <= 3000) {
      return MonthIntensity.lightBlue;
    } else if (count <= 5000) {
      return MonthIntensity.mediumBlue;
    } else if (count <= 8000) {
      return MonthIntensity.darkBlue;
    } else if (count <= 12000) {
      return MonthIntensity.lightOrange;
    } else if (count <= 20000) {
      return MonthIntensity.darkOrange;
    } else if (count <= 30000) {
      return MonthIntensity.lightPurple;
    } else if (count <= 50000) {
      return MonthIntensity.darkPurple;
    } else {
      return MonthIntensity.red;
    }
  }

  /// Whether this intensity should render as individual dots (1-3 messages)
  bool get shouldRenderAsDots => this == MonthIntensity.fewDots;

  /// Whether this month is empty (chat active but no messages)
  bool get isEmpty => this == MonthIntensity.empty;

  /// Whether this month is before chat started (show nothing)
  bool get isNotYetStarted => this == MonthIntensity.notYetStarted;
}

/// A single month's data in the calendar heatmap
class MonthData {
  const MonthData({
    required this.year,
    required this.month,
    required this.messageCount,
    required this.intensity,
    required this.chatId,
  });

  /// Calendar year (e.g., 2023)
  final int year;

  /// Month number (1-12)
  final int month;

  /// Total messages in this month
  final int messageCount;

  /// Intensity level for visual encoding
  final MonthIntensity intensity;

  /// Chat ID for navigation when clicked
  final int chatId;

  /// Month abbreviation (Jan, Feb, etc.)
  String get monthAbbr {
    const abbrs = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return abbrs[month - 1];
  }
}

/// A single year row in the calendar heatmap
class YearRow {
  const YearRow({
    required this.year,
    required this.months,
    required this.hasMessages,
  });

  /// Calendar year
  final int year;

  /// Month data for this year (length = 12)
  final List<MonthData> months;

  /// Whether this year has any messages at all
  final bool hasMessages;

  /// Total messages in this year
  int get totalMessages => months.fold(0, (sum, m) => sum + m.messageCount);
}

/// Complete calendar heatmap timeline data
class CalendarHeatmapTimelineData {
  const CalendarHeatmapTimelineData({
    required this.yearRows,
    required this.firstMessageDate,
    required this.lastMessageDate,
    required this.totalMessages,
    required this.maxMonthCount,
  });

  /// Year rows (only years with messages)
  final List<YearRow> yearRows;

  /// Date of first message
  final DateTime firstMessageDate;

  /// Date of last message
  final DateTime lastMessageDate;

  /// Total messages across all time
  final int totalMessages;

  /// Maximum messages in any single month
  final int maxMonthCount;

  /// Total number of years spanned
  int get totalYears => yearRows.length;

  /// Whether timeline should wrap to multiple rows
  /// (if more than 3-4 years, consider wrapping)
  bool get shouldWrap => totalYears > 4;

  /// Calculate how many years to show per row when wrapping
  int get yearsPerRow {
    if (totalYears <= 4) {
      return totalYears;
    } else if (totalYears <= 8) {
      return 4;
    } else if (totalYears <= 12) {
      return 4;
    } else {
      return 3; // For very long timespans
    }
  }

  /// Get year rows organized into display rows for wrapping
  List<List<YearRow>> get wrappedYearRows {
    if (!shouldWrap) {
      return [yearRows];
    }

    final result = <List<YearRow>>[];
    for (var i = 0; i < yearRows.length; i += yearsPerRow) {
      final endIdx = (i + yearsPerRow).clamp(0, yearRows.length);
      result.add(yearRows.sublist(i, endIdx));
    }
    return result;
  }
}
