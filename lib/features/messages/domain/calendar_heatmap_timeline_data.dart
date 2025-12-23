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

  /// 50000+ messages (red - maximum intensity)
  red;

  /// Convert message count to intensity level
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

  final int year;
  final int month;
  final int messageCount;
  final MonthIntensity intensity;
  final int chatId; // For navigation context
}

/// A single year row: year label + 12 months
class YearRow {
  const YearRow({
    required this.year,
    required this.months,
    required this.hasMessages,
  });

  final int year;
  final List<MonthData> months; // Always 12 months
  final bool hasMessages; // Whether any month has messages
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

  final List<YearRow> yearRows;
  final DateTime firstMessageDate;
  final DateTime lastMessageDate;
  final int totalMessages;
  final int maxMonthCount; // For legend/tooltip

  /// Group years into wrapped display rows
  /// Rules:
  /// - First row: up to 8 years
  /// - Subsequent rows: up to 12 years each
  List<List<YearRow>> get wrappedYearRows {
    if (yearRows.isEmpty) {
      return [];
    }

    final groups = <List<YearRow>>[];
    final firstGroup = yearRows.take(8).toList();
    groups.add(firstGroup);

    if (yearRows.length > 8) {
      final remaining = yearRows.skip(8).toList();
      for (var i = 0; i < remaining.length; i += 12) {
        final end = (i + 12 > remaining.length) ? remaining.length : i + 12;
        groups.add(remaining.sublist(i, end));
      }
    }

    return groups;
  }
}
