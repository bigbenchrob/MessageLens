import 'package:flutter/widgets.dart';

import '../../../../core/util/date_label_formatter.dart';
import '../../../../essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart';
import '../../../messages/feature_level_providers.dart'
    show
        CalendarHeatmapTimelineData,
        CalendarHeatmapTimelineWidget,
        MonthData,
        MonthIntensity,
        YearRow;

/// Thin render-edge adapter from Conversation activity facts to the shared
/// Messages calendar heat-map presentation contract.
class ConversationSignatureCalendarHeatmap extends StatelessWidget {
  const ConversationSignatureCalendarHeatmap({
    required this.conversationId,
    required this.activityMonths,
    required this.focusBorderColor,
    this.onMonthTap,
    super.key,
  });

  final int conversationId;
  final List<ConversationSignatureMonth> activityMonths;
  final Color focusBorderColor;
  final void Function(int year, int month, int messageCount)? onMonthTap;

  @override
  Widget build(BuildContext context) {
    final timelineData = conversationSignatureCalendarHeatmapData(
      conversationId: conversationId,
      activityMonths: activityMonths,
    );
    if (timelineData == null) {
      return const SizedBox(height: 9);
    }

    return CalendarHeatmapTimelineWidget(
      key: ValueKey('conversation-signature-calendar-$conversationId'),
      data: timelineData,
      monthSize: 12,
      monthSpacing: 1,
      monthHitTargetSize: 18,
      focusBorderColor: focusBorderColor,
      onMonthTap: onMonthTap,
      monthTooltipBuilder: _monthTooltip,
    );
  }
}

CalendarHeatmapTimelineData? conversationSignatureCalendarHeatmapData({
  required int conversationId,
  required List<ConversationSignatureMonth> activityMonths,
}) {
  final validMonths =
      activityMonths
          .where((month) => month.month >= 1 && month.month <= 12)
          .toList(growable: false)
        ..sort((left, right) {
          final yearComparison = left.year.compareTo(right.year);
          if (yearComparison != 0) {
            return yearComparison;
          }
          return left.month.compareTo(right.month);
        });
  if (validMonths.isEmpty) {
    return null;
  }

  final countsByMonth = <String, int>{
    for (final month in validMonths)
      _monthKey(month.year, month.month): month.messageCount,
  };
  final firstMonth = validMonths.first;
  final lastMonth = validMonths.last;
  final yearRows = <YearRow>[];

  for (var year = firstMonth.year; year <= lastMonth.year; year++) {
    final months = <MonthData>[];
    for (var month = 1; month <= 12; month++) {
      final isBeforeConversation =
          year == firstMonth.year && month < firstMonth.month;
      final messageCount = countsByMonth[_monthKey(year, month)] ?? 0;
      months.add(
        MonthData(
          year: year,
          month: month,
          messageCount: messageCount,
          intensity: isBeforeConversation
              ? MonthIntensity.notYetStarted
              : MonthIntensity.fromMessageCount(messageCount),
          chatId: conversationId,
        ),
      );
    }
    yearRows.add(
      YearRow(
        year: year,
        months: months,
        hasMessages: months.any((month) => month.messageCount > 0),
      ),
    );
  }

  final totalMessages = validMonths.fold<int>(
    0,
    (total, month) => total + month.messageCount,
  );
  final maxMonthCount = validMonths.fold<int>(
    0,
    (maximum, month) =>
        month.messageCount > maximum ? month.messageCount : maximum,
  );

  return CalendarHeatmapTimelineData(
    yearRows: yearRows,
    firstMessageDate: DateTime(firstMonth.year, firstMonth.month, 15),
    lastMessageDate: DateTime(lastMonth.year, lastMonth.month, 15),
    totalMessages: totalMessages,
    maxMonthCount: maxMonthCount,
  );
}

String _monthTooltip(MonthData monthData) {
  final monthLabel = DateLabelFormatter.longMonthYear(
    DateTime(monthData.year, monthData.month, 15),
  );
  final messageLabel = monthData.messageCount == 1 ? 'message' : 'messages';
  return '$monthLabel: ${monthData.messageCount} $messageLabel';
}

String _monthKey(int year, int month) {
  return DateLabelFormatter.monthKey(DateTime(year, month));
}
