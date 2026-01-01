import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../domain/calendar_heatmap_timeline_data.dart';

/// Renders a calendar heatmap timeline visualization
///
/// Each month is displayed as a fixed-size rectangle (or dots for sparse data)
/// colored by message intensity. Years wrap to multiple rows if needed.
///
/// Visual encoding:
/// - 1-3 messages: Individual dots (•, ••, •••)
/// - 4-50 messages: Gray intensities (light → dark)
/// - 51-200 messages: Yellow intensities
/// - 201-2000 messages: Green intensities
/// - 2001-8000 messages: Blue intensities
/// - 8001-30000 messages: Orange → Purple
/// - 30000+ messages: Dark purple → Red
class CalendarHeatmapTimelineWidget extends ConsumerWidget {
  const CalendarHeatmapTimelineWidget({
    required this.data,
    this.monthSize = 14.0,
    this.monthSpacing = 2.0,
    this.onMonthTap,
    this.selectedMonthKey,
    super.key,
  });

  final CalendarHeatmapTimelineData data;
  final double monthSize;
  final double monthSpacing;

  /// Optional custom tap handler. If not provided, uses default chat navigation.
  /// Parameters: (year, month, messageCount)
  final void Function(int year, int month, int messageCount)? onMonthTap;

  /// Currently selected/visible month in format "YYYY-MM"
  final String? selectedMonthKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.yearRows.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group years into display rows based on wrapping rules
    final groups = data.wrappedYearRows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final group in groups)
          _YearRowsGroup(
            yearRows: group,
            monthSize: monthSize,
            monthSpacing: monthSpacing,
            onMonthTap: onMonthTap,
            selectedMonthKey: selectedMonthKey,
            ref: ref,
          ),
      ],
    );
  }
}

/// A group of year rows (wraps years into display rows)
class _YearRowsGroup extends StatelessWidget {
  const _YearRowsGroup({
    required this.yearRows,
    required this.monthSize,
    required this.monthSpacing,
    required this.ref,
    this.onMonthTap,
    this.selectedMonthKey,
  });

  final List<YearRow> yearRows;
  final double monthSize;
  final double monthSpacing;
  final WidgetRef ref;
  final void Function(int year, int month, int messageCount)? onMonthTap;
  final String? selectedMonthKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final yearRow in yearRows) ...[
          _SingleYearRow(
            yearRow: yearRow,
            monthSize: monthSize,
            monthSpacing: monthSpacing,
            onMonthTap: onMonthTap,
            selectedMonthKey: selectedMonthKey,
            ref: ref,
          ),
          SizedBox(height: monthSpacing * 2),
        ],
      ],
    );
  }
}

/// A single year row: year label + 12 month cells
class _SingleYearRow extends StatelessWidget {
  const _SingleYearRow({
    required this.yearRow,
    required this.monthSize,
    required this.monthSpacing,
    required this.ref,
    this.onMonthTap,
    this.selectedMonthKey,
  });

  final YearRow yearRow;
  final double monthSize;
  final double monthSpacing;
  final WidgetRef ref;
  final void Function(int year, int month, int messageCount)? onMonthTap;
  final String? selectedMonthKey;

  @override
  Widget build(BuildContext context) {
    final typography = ref.watch(themeTypographyProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Year label
        SizedBox(
          width: 32,
          child: Text(
            yearRow.year.toString(),
            style: typography.vizAxisLabel.copyWith(fontSize: 10),
          ),
        ),
        SizedBox(width: monthSpacing * 2),

        // 12 months
        for (var i = 0; i < 12; i++) ...[
          if (i > 0) SizedBox(width: monthSpacing),
          _MonthCell(
            monthData: yearRow.months[i],
            size: monthSize,
            onMonthTap: onMonthTap,
            isSelected: _isMonthSelected(yearRow.months[i]),
            ref: ref,
          ),
        ],
      ],
    );
  }

  bool _isMonthSelected(MonthData month) {
    if (selectedMonthKey == null) {
      return false;
    }
    final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    return monthKey == selectedMonthKey;
  }
}

/// A single month cell - clickable, shows dots or colored rectangle
class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.monthData,
    required this.size,
    required this.ref,
    this.onMonthTap,
    this.isSelected = false,
  });

  final MonthData monthData;
  final double size;
  final WidgetRef ref;
  final void Function(int year, int month, int messageCount)? onMonthTap;
  final bool isSelected;

  void _handleTap() {
    // Don't navigate for notYetStarted or empty months
    if (monthData.intensity.isNotYetStarted || monthData.messageCount == 0) {
      return;
    }

    // If custom tap handler provided, use it
    if (onMonthTap != null) {
      onMonthTap!(monthData.year, monthData.month, monthData.messageCount);
      return;
    }

    // Default behavior: navigate to chat in date range
    final startDate = DateTime(monthData.year, monthData.month, 1);
    final endDate = DateTime(
      monthData.year,
      monthData.month + 1,
      0,
      23,
      59,
      59,
    );

    print(
      '[TIMELINE_TAP] Clicked ${monthData.year}-${monthData.month.toString().padLeft(2, '0')} '
      '(${monthData.messageCount} messages). '
      'startDate=$startDate, endDate=$endDate',
    );

    // Always navigate with forChatInDateRange
    // The view will detect if it's the same chat and just scroll instead of reloading
    ref
        .read(panelsViewStateProvider(SidebarMode.messages).notifier)
        .show(
          panel: WindowPanel.center,
          spec: ViewSpec.messages(
            MessagesSpec.forChatInDateRange(
              chatId: monthData.chatId,
              startDate: startDate,
              endDate: endDate,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    Widget cellContent;

    if (monthData.intensity.isNotYetStarted) {
      // Month before chat started - show empty space
      cellContent = SizedBox(width: size, height: size);
    } else if (monthData.intensity.isEmpty) {
      // Chat active but no messages - show empty square with light grey border
      cellContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD0D0D0), width: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    } else if (monthData.intensity.shouldRenderAsDots) {
      // 1-3 messages: Show as 6×6 dot matrix
      cellContent = _DotMatrixIndicator(
        count: monthData.messageCount,
        size: size,
      );
    } else {
      // 4+ messages: Show as colored rectangle
      cellContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _getColor(monthData.intensity),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    // Add pink border if selected
    if (isSelected) {
      cellContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFFF1493), // Deep pink
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: cellContent,
      );
    }

    // Wrap in GestureDetector for click handling (except notYetStarted)
    if (monthData.intensity.isNotYetStarted) {
      return cellContent;
    }

    return GestureDetector(
      onTap: _handleTap,
      child: MouseRegion(
        cursor: monthData.messageCount > 0
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: cellContent,
      ),
    );
  }

  Color _getColor(MonthIntensity intensity) {
    switch (intensity) {
      case MonthIntensity.notYetStarted:
      case MonthIntensity.empty:
      case MonthIntensity.fewDots:
        return Colors.transparent;

      // Gray series (4-50 messages)
      case MonthIntensity.lightGray:
        return const Color(0xFFE0E0E0);
      case MonthIntensity.mediumGray:
        return const Color(0xFFB0B0B0);
      case MonthIntensity.darkGray:
        return const Color(0xFF808080);

      // Yellow series (51-200 messages)
      case MonthIntensity.lightYellow:
        return const Color(0xFFFFF9C4);
      case MonthIntensity.darkYellow:
        return const Color(0xFFFDD835);

      // Green series (201-2000 messages)
      case MonthIntensity.lightGreen:
        return const Color(0xFFC8E6C9);
      case MonthIntensity.mediumGreen:
        return const Color(0xFF66BB6A);
      case MonthIntensity.darkGreen:
        return const Color(0xFF2E7D32);

      // Blue series (2001-8000 messages)
      case MonthIntensity.lightBlue:
        return const Color(0xFFB3E5FC);
      case MonthIntensity.mediumBlue:
        return const Color(0xFF42A5F5);
      case MonthIntensity.darkBlue:
        return const Color(0xFF1565C0);

      // Orange series (8001-20000 messages)
      case MonthIntensity.lightOrange:
        return const Color(0xFFFFE0B2);
      case MonthIntensity.darkOrange:
        return const Color(0xFFFB8C00);

      // Purple series (20001-50000 messages)
      case MonthIntensity.lightPurple:
        return const Color(0xFFE1BEE7);
      case MonthIntensity.darkPurple:
        return const Color(0xFF8E24AA);

      // Red (50000+ messages - maximum intensity)
      case MonthIntensity.red:
        return const Color(0xFFD32F2F);
    }
  }
}

/// Renders a 6×6 dot matrix for 1-3 messages
/// Creates a cacheable visual representation where dots fill from top-left
class _DotMatrixIndicator extends StatelessWidget {
  const _DotMatrixIndicator({required this.count, required this.size});

  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dotCount = count.clamp(1, 3);

    // 6×6 grid with 1px dots and minimal spacing
    // Total: 6 dots + 5 gaps = needs ~11-12px
    // For 14px cell, use 1px dots with 1px spacing (compressed at edges)
    const gridSize = 6;
    const dotSize = 1.0;
    const spacing = 1.0;
    const totalGridSize = (gridSize * dotSize) + ((gridSize - 1) * spacing);
    final padding = (size - totalGridSize) / 2;

    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: CustomPaint(
          painter: _DotMatrixPainter(dotCount: dotCount),
          size: const Size(totalGridSize, totalGridSize),
        ),
      ),
    );
  }
}

/// Custom painter for efficient 6×6 dot matrix
class _DotMatrixPainter extends CustomPainter {
  const _DotMatrixPainter({required this.dotCount});

  final int dotCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF999999)
      ..style = PaintingStyle.fill;

    const gridSize = 6;
    const dotSize = 1.0;
    const spacing = 1.0;

    // Fill dots from top-left, row by row
    var dotsDrawn = 0;
    for (var row = 0; row < gridSize && dotsDrawn < dotCount; row++) {
      for (var col = 0; col < gridSize && dotsDrawn < dotCount; col++) {
        final x = col * (dotSize + spacing) + (dotSize / 2);
        final y = row * (dotSize + spacing) + (dotSize / 2);
        canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
        dotsDrawn++;
      }
    }
  }

  @override
  bool shouldRepaint(_DotMatrixPainter oldDelegate) {
    return oldDelegate.dotCount != dotCount;
  }
}
