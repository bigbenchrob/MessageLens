import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../core/util/date_label_formatter.dart';
import '../../../../essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart';
import 'conversation_signature_calendar_heatmap.dart';

class ConversationSignatureCardData {
  const ConversationSignatureCardData({
    required this.conversationId,
    required this.title,
    this.chatHookLabel,
    this.titleContextLabel,
    this.summaryHighlight = ConversationSignatureSummaryHighlight.none,
    this.highlightedMonth,
    required this.participantCount,
    required this.messageCount,
    required this.firstMessageAtUtc,
    required this.lastMessageAtUtc,
    required this.activityMonths,
    this.tagLabels = const <String>[],
  });

  final int conversationId;
  final String title;
  final String? chatHookLabel;
  final String? titleContextLabel;
  final ConversationSignatureSummaryHighlight summaryHighlight;
  final ConversationSignatureMonthMarker? highlightedMonth;
  final int participantCount;
  final int messageCount;
  final String? firstMessageAtUtc;
  final String? lastMessageAtUtc;
  final List<ConversationSignatureMonth> activityMonths;
  final List<String> tagLabels;
}

class ConversationSignatureMonthMarker {
  const ConversationSignatureMonthMarker({
    required this.year,
    required this.month,
  });

  final int year;
  final int month;

  bool matches(ConversationSignatureMonth candidate) {
    return candidate.year == year && candidate.month == month;
  }
}

enum ConversationSignatureSummaryHighlight {
  none,
  messageCount,
  firstDate,
  lastDate,
  dateRange,
}

class ConversationSignatureCardStyle {
  const ConversationSignatureCardStyle({
    required this.backgroundColor,
    required this.hoverBackgroundColor,
    required this.selectedBackgroundColor,
    required this.borderColor,
    required this.hoverBorderColor,
    required this.selectedBorderColor,
    required this.titleStyle,
    required this.selectedTitleStyle,
    this.titleContextStyle,
    required this.chatHookStyle,
    required this.participantSuffixStyle,
    required this.summaryStyle,
    this.summaryHighlightStyle,
    this.monthHighlightColor,
    required this.tagTextStyle,
    required this.tagBackgroundColor,
    required this.tagBorderColor,
    required this.emptyMonthBorderColor,
  });

  final Color backgroundColor;
  final Color hoverBackgroundColor;
  final Color selectedBackgroundColor;
  final Color borderColor;
  final Color hoverBorderColor;
  final Color selectedBorderColor;
  final TextStyle titleStyle;
  final TextStyle selectedTitleStyle;
  final TextStyle? titleContextStyle;
  final TextStyle chatHookStyle;
  final TextStyle participantSuffixStyle;
  final TextStyle summaryStyle;
  final TextStyle? summaryHighlightStyle;
  final Color? monthHighlightColor;
  final TextStyle tagTextStyle;
  final Color tagBackgroundColor;
  final Color tagBorderColor;
  final Color emptyMonthBorderColor;
}

class ConversationSignatureCard extends StatefulWidget {
  const ConversationSignatureCard({
    required this.signature,
    required this.style,
    required this.monthColorForMessageCount,
    this.onPressed,
    this.onMonthTap,
    this.isSelected = false,
    this.trailing,
    this.horizontalPlacement = Alignment.centerLeft,
    super.key,
  });

  final ConversationSignatureCardData signature;
  final ConversationSignatureCardStyle style;
  final Color Function(int messageCount) monthColorForMessageCount;
  final VoidCallback? onPressed;
  final void Function(int year, int month, int messageCount)? onMonthTap;
  final bool isSelected;
  final Widget? trailing;
  final AlignmentGeometry horizontalPlacement;

  @override
  State<ConversationSignatureCard> createState() =>
      _ConversationSignatureCardState();
}

class _ConversationSignatureCardState extends State<ConversationSignatureCard> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final signature = widget.signature;
    final background = widget.isSelected
        ? widget.style.selectedBackgroundColor
        : _isHovered
        ? widget.style.hoverBackgroundColor
        : widget.style.backgroundColor;
    final borderColor = widget.isSelected
        ? widget.style.selectedBorderColor
        : _isHovered
        ? widget.style.hoverBorderColor
        : widget.style.borderColor;

    final onPressed = widget.onPressed;
    final isInteractive = onPressed != null;

    return Align(
      alignment: widget.horizontalPlacement,
      child: SizedBox(
        width: ConversationSignatureCardPresentationMetrics.canonicalWidth,
        child: MouseRegion(
          cursor: isInteractive ? SystemMouseCursors.click : MouseCursor.defer,
          onEnter: (_) {
            if (!isInteractive) {
              return;
            }
            setState(() {
              _isHovered = true;
            });
          },
          onExit: (_) {
            if (!isInteractive) {
              return;
            }
            setState(() {
              _isHovered = false;
            });
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: borderColor,
                  width: widget.isSelected || _isHovered ? 1 : 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ConversationSignatureCardPresentationMetrics
                      .cardHorizontalPadding,
                  vertical: ConversationSignatureCardPresentationMetrics
                      .cardVerticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: signature.title),
                                if (signature.participantCount > 1)
                                  TextSpan(
                                    text: ' +${signature.participantCount}',
                                    style: widget.style.participantSuffixStyle,
                                  ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: widget.isSelected
                                ? widget.style.selectedTitleStyle
                                : widget.style.titleStyle,
                          ),
                        ),
                        if (signature.titleContextLabel != null) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            signature.titleContextLabel!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                widget.style.titleContextStyle ??
                                widget.style.participantSuffixStyle,
                          ),
                        ],
                        if (widget.trailing != null) ...[
                          const SizedBox(width: AppSpacing.xs),
                          widget.trailing!,
                        ],
                      ],
                    ),
                    if (signature.chatHookLabel != null) ...[
                      Text(
                        signature.chatHookLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: widget.style.chatHookStyle,
                      ),
                    ],
                    const SizedBox(
                      height: ConversationSignatureCardPresentationMetrics
                          .identityGlyphGap,
                    ),
                    if (widget.isSelected)
                      ConversationSignatureCalendarHeatmap(
                        conversationId: signature.conversationId,
                        activityMonths: signature.activityMonths,
                        focusBorderColor:
                            widget.style.monthHighlightColor ??
                            widget.style.emptyMonthBorderColor,
                        onMonthTap: widget.onMonthTap,
                      )
                    else
                      _ConversationMonthGlyph(
                        months: signature.activityMonths,
                        highlightedMonth: signature.highlightedMonth,
                        monthColorForMessageCount:
                            widget.monthColorForMessageCount,
                        monthHighlightColor:
                            widget.style.monthHighlightColor ??
                            widget.style.emptyMonthBorderColor,
                        emptyMonthBorderColor:
                            widget.style.emptyMonthBorderColor,
                      ),
                    const SizedBox(
                      height: ConversationSignatureCardPresentationMetrics
                          .glyphSummaryGap,
                    ),
                    Text.rich(
                      _signatureSummarySpan(
                        signature,
                        baseStyle: widget.style.summaryStyle,
                        highlightStyle:
                            widget.style.summaryHighlightStyle ??
                            widget.style.summaryStyle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (signature.tagLabels.isNotEmpty) ...[
                      const SizedBox(
                        height:
                            ConversationSignatureCardPresentationMetrics.tagGap,
                      ),
                      _ConversationTagRow(
                        labels: signature.tagLabels,
                        style: widget.style,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationTagRow extends StatelessWidget {
  const _ConversationTagRow({required this.labels, required this.style});

  final List<String> labels;
  final ConversationSignatureCardStyle style;

  @override
  Widget build(BuildContext context) {
    final visibleLabels = labels.take(3).toList(growable: false);
    final hiddenCount = labels.length - visibleLabels.length;

    return Wrap(
      spacing: ConversationSignatureCardPresentationMetrics.tagSpacing,
      runSpacing: ConversationSignatureCardPresentationMetrics.tagRunSpacing,
      children: [
        for (final label in visibleLabels)
          _ConversationTagChip(label: label, style: style),
        if (hiddenCount > 0)
          _ConversationTagChip(label: '+$hiddenCount', style: style),
      ],
    );
  }
}

class _ConversationTagChip extends StatelessWidget {
  const _ConversationTagChip({required this.label, required this.style});

  final String label;
  final ConversationSignatureCardStyle style;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.tagBackgroundColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: style.tagBorderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ConversationSignatureCardPresentationMetrics.tagPaddingX,
          vertical: ConversationSignatureCardPresentationMetrics.tagPaddingY,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style.tagTextStyle,
        ),
      ),
    );
  }
}

class _ConversationMonthGlyph extends StatelessWidget {
  const _ConversationMonthGlyph({
    required this.months,
    required this.highlightedMonth,
    required this.monthColorForMessageCount,
    required this.monthHighlightColor,
    required this.emptyMonthBorderColor,
  });

  final List<ConversationSignatureMonth> months;
  final ConversationSignatureMonthMarker? highlightedMonth;
  final Color Function(int messageCount) monthColorForMessageCount;
  final Color monthHighlightColor;
  final Color emptyMonthBorderColor;

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      return const SizedBox(
        height: ConversationSignatureCardPresentationMetrics.emptyGlyphHeight,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            ConversationSignatureCardPresentationMetrics.glyphColumnsForWidth(
              constraints.maxWidth,
            );
        final anchoredMonths =
            ConversationSignatureCardPresentationMetrics.anchorMonthsToNow(
              months,
            );
        final rows =
            ConversationSignatureCardPresentationMetrics.chunkMonthsFromNewest(
              anchoredMonths,
              columns: columns,
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final row in rows) ...[
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var index = 0; index < row.length; index++) ...[
                      if (index > 0)
                        const SizedBox(
                          width: ConversationSignatureCardPresentationMetrics
                              .glyphSpacing,
                        ),
                      _MonthGlyphDot(
                        month: row[index],
                        isHighlighted:
                            highlightedMonth?.matches(row[index]) ?? false,
                        emptyColor: emptyMonthBorderColor,
                        highlightColor: monthHighlightColor,
                        monthColorForMessageCount: monthColorForMessageCount,
                      ),
                    ],
                  ],
                ),
              ),
              if (row != rows.last)
                const SizedBox(
                  height:
                      ConversationSignatureCardPresentationMetrics.glyphSpacing,
                ),
            ],
          ],
        );
      },
    );
  }
}

class _MonthGlyphDot extends StatelessWidget {
  const _MonthGlyphDot({
    required this.month,
    required this.isHighlighted,
    required this.emptyColor,
    required this.highlightColor,
    required this.monthColorForMessageCount,
  });

  final ConversationSignatureMonth month;
  final bool isHighlighted;
  final Color emptyColor;
  final Color highlightColor;
  final Color Function(int messageCount) monthColorForMessageCount;

  @override
  Widget build(BuildContext context) {
    final size = month.messageCount <= 0
        ? ConversationSignatureCardPresentationMetrics.emptyGlyphDotSize
        : ConversationSignatureCardPresentationMetrics.glyphDotSize;
    final fillColor = month.messageCount <= 0
        ? null
        : monthColorForMessageCount(month.messageCount);
    final dot = DecoratedBox(
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: month.messageCount <= 0
            ? Border.all(color: emptyColor.withValues(alpha: 0.38))
            : null,
      ),
      child: SizedBox(width: size, height: size),
    );

    if (!isHighlighted) {
      return dot;
    }

    return DecoratedBox(
      key: ValueKey(
        'conversation-signature-highlighted-month-${month.year}-${month.month}',
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: highlightColor, width: 1),
      ),
      child: Padding(padding: const EdgeInsets.all(1.5), child: dot),
    );
  }
}

TextSpan _signatureSummarySpan(
  ConversationSignatureCardData signature, {
  required TextStyle baseStyle,
  required TextStyle highlightStyle,
}) {
  TextSpan span(String text, {required bool isHighlighted}) {
    return TextSpan(
      text: text,
      style: isHighlighted ? highlightStyle : baseStyle,
    );
  }

  final messageCount = _formatCount(signature.messageCount);
  final firstDate = _formatDate(signature.firstMessageAtUtc);
  final lastDate = _formatDate(signature.lastMessageAtUtc);
  final highlight = signature.summaryHighlight;

  final children = <TextSpan>[
    span(
      '$messageCount ${signature.messageCount == 1 ? 'message' : 'messages'}',
      isHighlighted:
          highlight == ConversationSignatureSummaryHighlight.messageCount,
    ),
    span(' • ', isHighlighted: false),
    ..._dateRangeSpans(
      firstDate: firstDate,
      lastDate: lastDate,
      highlight: highlight,
      span: span,
    ),
  ];
  return TextSpan(children: children);
}

List<TextSpan> _dateRangeSpans({
  required String firstDate,
  required String lastDate,
  required ConversationSignatureSummaryHighlight highlight,
  required TextSpan Function(String text, {required bool isHighlighted}) span,
}) {
  final highlightFirst =
      highlight == ConversationSignatureSummaryHighlight.firstDate ||
      highlight == ConversationSignatureSummaryHighlight.dateRange;
  final highlightLast =
      highlight == ConversationSignatureSummaryHighlight.lastDate ||
      highlight == ConversationSignatureSummaryHighlight.dateRange;

  if (firstDate.isEmpty && lastDate.isEmpty) {
    return [span('no dated messages', isHighlighted: false)];
  }
  if (firstDate.isEmpty) {
    return [
      span('through ', isHighlighted: false),
      span(lastDate, isHighlighted: highlightLast),
    ];
  }
  if (lastDate.isEmpty || firstDate == lastDate) {
    return [span(firstDate, isHighlighted: highlightFirst || highlightLast)];
  }
  return [
    span(firstDate, isHighlighted: highlightFirst),
    span(
      ' - ',
      isHighlighted:
          highlight == ConversationSignatureSummaryHighlight.dateRange,
    ),
    span(lastDate, isHighlighted: highlightLast),
  ];
}

String _formatCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return '$value';
}

String _formatDate(String? value) {
  return DateLabelFormatter.sortableDateFromIso(value, fallback: value) ?? '';
}

String _monthKey(int year, int month) {
  return DateLabelFormatter.monthKey(DateTime(year, month));
}

class ConversationSignatureCardPresentationMetrics {
  const ConversationSignatureCardPresentationMetrics._();

  static const int fallbackGlyphColumns = 24;
  static const double canonicalWidth = 296;
  static const double cardBorderWidth = 0.5;
  static const double cardHorizontalPadding = 8;
  static const double cardVerticalPadding = 9;
  static const double identityGlyphGap = 5;
  static const double glyphSummaryGap = 5;
  static const double tagGap = 6;
  static const double tagSpacing = 4;
  static const double tagRunSpacing = 4;
  static const double tagPaddingX = 5;
  static const double tagPaddingY = 2;
  static const double glyphDotSize = 6;
  static const double emptyGlyphDotSize = 5;
  static const double glyphSpacing = 3;
  static const double emptyGlyphHeight = 9;

  static double naturalHeight({
    required ConversationSignatureCardData signature,
    required ConversationSignatureCardStyle style,
    required PresentationConstraints constraints,
    double trailingHeight = 0,
  }) {
    final contentWidth = math.max(
      0.0,
      canonicalWidth - (cardHorizontalPadding * 2),
    );
    final titleHeight = math.max(
      _textHeight(
        text: signature.title,
        style: style.titleStyle,
        constraints: constraints,
        maxWidth: contentWidth,
      ),
      trailingHeight,
    );
    final chatHookHeight = signature.chatHookLabel == null
        ? 0.0
        : _textHeight(
            text: signature.chatHookLabel!,
            style: style.chatHookStyle,
            constraints: constraints,
            maxWidth: contentWidth,
          );
    final summaryHeight = _textHeight(
      text: 'Summary',
      style: style.summaryStyle,
      constraints: constraints,
      maxWidth: contentWidth,
    );
    final tagHeight = _tagRowHeight(
      labels: signature.tagLabels,
      style: style,
      constraints: constraints,
      maxWidth: contentWidth,
    );

    return (cardBorderWidth * 2) +
        (cardVerticalPadding * 2) +
        titleHeight +
        chatHookHeight +
        identityGlyphGap +
        glyphNaturalHeight(
          months: signature.activityMonths,
          availableWidth: contentWidth,
        ) +
        glyphSummaryGap +
        summaryHeight +
        tagHeight;
  }

  /// Natural height of the smallest approved Conversation Card presentation.
  ///
  /// This uses the same typography, spacing, canonical width, glyph metrics,
  /// and trailing-control contract as a rendered card. It represents one title
  /// line, one glyph row, and one summary line without optional hook or tags.
  static double minimumNaturalHeight({
    required ConversationSignatureCardStyle style,
    required PresentationConstraints constraints,
    double trailingHeight = 0,
  }) {
    final contentWidth = math.max(
      0.0,
      canonicalWidth - (cardHorizontalPadding * 2),
    );
    final titleHeight = math.max(
      _textHeight(
        text: 'M',
        style: style.titleStyle,
        constraints: constraints,
        maxWidth: contentWidth,
      ),
      trailingHeight,
    );
    final summaryHeight = _textHeight(
      text: 'M',
      style: style.summaryStyle,
      constraints: constraints,
      maxWidth: contentWidth,
    );

    return (cardBorderWidth * 2) +
        (cardVerticalPadding * 2) +
        titleHeight +
        identityGlyphGap +
        glyphDotSize +
        glyphSummaryGap +
        summaryHeight;
  }

  static double glyphNaturalHeight({
    required List<ConversationSignatureMonth> months,
    required double availableWidth,
  }) {
    if (months.isEmpty) {
      return emptyGlyphHeight;
    }

    final columns = glyphColumnsForWidth(availableWidth);
    final rowCount = math.max(
      1,
      chunkMonthsFromNewest(anchorMonthsToNow(months), columns: columns).length,
    );
    return (rowCount * glyphDotSize) + ((rowCount - 1) * glyphSpacing);
  }

  static int glyphColumnsForWidth(double maxWidth) {
    if (!maxWidth.isFinite || maxWidth <= 0) {
      return fallbackGlyphColumns;
    }
    return math.max(
      1,
      ((maxWidth + glyphSpacing) / (glyphDotSize + glyphSpacing)).floor(),
    );
  }

  static List<ConversationSignatureMonth> anchorMonthsToNow(
    List<ConversationSignatureMonth> months,
  ) {
    final counts = <String, int>{
      for (final month in months)
        _monthKey(month.year, month.month): month.messageCount,
    };
    final firstMonth = months.first;
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final anchoredMonths = <ConversationSignatureMonth>[];

    var cursor = DateTime(firstMonth.year, firstMonth.month);
    while (!cursor.isAfter(currentMonth)) {
      anchoredMonths.add(
        ConversationSignatureMonth(
          year: cursor.year,
          month: cursor.month,
          messageCount: counts[_monthKey(cursor.year, cursor.month)] ?? 0,
        ),
      );
      cursor = DateTime(cursor.year, cursor.month + 1);
    }

    return anchoredMonths;
  }

  static List<List<ConversationSignatureMonth>> chunkMonthsFromNewest(
    List<ConversationSignatureMonth> months, {
    required int columns,
  }) {
    final rowsNewestFirst = <List<ConversationSignatureMonth>>[];
    for (var end = months.length; end > 0; end -= columns) {
      final start = math.max(0, end - columns);
      rowsNewestFirst.add(months.sublist(start, end));
    }
    return rowsNewestFirst.reversed.toList(growable: false);
  }

  static double _tagRowHeight({
    required List<String> labels,
    required ConversationSignatureCardStyle style,
    required PresentationConstraints constraints,
    required double maxWidth,
  }) {
    if (labels.isEmpty) {
      return 0;
    }

    final visibleLabels = labels.take(3).toList(growable: false);
    final hiddenCount = labels.length - visibleLabels.length;
    final renderedLabels = [
      ...visibleLabels,
      if (hiddenCount > 0) '+$hiddenCount',
    ];
    final chipHeight =
        _textHeight(
          text: renderedLabels.first,
          style: style.tagTextStyle,
          constraints: constraints,
          maxWidth: maxWidth,
        ) +
        (tagPaddingY * 2) +
        2;
    var rowCount = 1;
    var currentRowWidth = 0.0;
    for (final label in renderedLabels) {
      final chipWidth =
          _textWidth(
            text: label,
            style: style.tagTextStyle,
            constraints: constraints,
          ) +
          (tagPaddingX * 2) +
          2;
      final nextWidth = currentRowWidth == 0
          ? chipWidth
          : currentRowWidth + tagSpacing + chipWidth;
      if (nextWidth > maxWidth && currentRowWidth > 0) {
        rowCount++;
        currentRowWidth = chipWidth;
      } else {
        currentRowWidth = nextWidth;
      }
    }

    return tagGap + (rowCount * chipHeight) + ((rowCount - 1) * tagRunSpacing);
  }

  static double _textHeight({
    required String text,
    required TextStyle style,
    required PresentationConstraints constraints,
    required double maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      ellipsis: '\u2026',
      textDirection: constraints.textDirection,
      textScaler: constraints.textScaler,
      locale: constraints.locale,
    )..layout(maxWidth: maxWidth);
    return painter.height;
  }

  static double _textWidth({
    required String text,
    required TextStyle style,
    required PresentationConstraints constraints,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: constraints.textDirection,
      textScaler: constraints.textScaler,
      locale: constraints.locale,
    )..layout(maxWidth: double.infinity);
    return painter.width;
  }
}
