import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/chat_timeline_data.dart';

/// Renders a compact timeline visualization showing message activity distribution.
///
/// The timeline displays:
/// - Vertical bars representing time buckets (daily/weekly/monthly/quarterly)
/// - Bar height indicates message volume (normalized by maxCount)
/// - Color intensity shows percentile rank (light → medium → dark → blue)
/// - First and last dates shown below timeline
///
/// Example:
/// ```
/// ┌─┬──┬─┬───┬─┬──┐
/// │ ││  │ │   │ ││  │  Bar height = message density
/// └─┴──┴─┴───┴─┴──┘
/// Jan 2014  →  Dec 2024
/// ```
class ChatTimelineWidget extends StatelessWidget {
  const ChatTimelineWidget({
    required this.data,
    required this.firstMessageDate,
    required this.lastMessageDate,
    this.height = 40.0,
    super.key,
  });

  final ChatTimelineData data;
  final DateTime firstMessageDate;
  final DateTime lastMessageDate;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (data.buckets.isEmpty) {
      return const SizedBox.shrink();
    }

    final dateFormat = DateFormat('MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timeline bars
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final bucket in data.buckets)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: _TimelineBucket(
                      messageCount: bucket.messageCount,
                      percentile: data.getPercentileRank(bucket.messageCount),
                      maxHeight: height,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Date range labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateFormat.format(firstMessageDate),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF999999),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              '→',
              style: TextStyle(fontSize: 11, color: Color(0xFFCCCCCC)),
            ),
            Text(
              dateFormat.format(lastMessageDate),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF999999),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineBucket extends StatelessWidget {
  const _TimelineBucket({
    required this.messageCount,
    required this.percentile,
    required this.maxHeight,
  });

  final int messageCount;
  final double percentile;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    // Calculate bar height (minimum 2px for visibility if count > 0)
    final barHeight = messageCount > 0
        ? (percentile * maxHeight).clamp(2.0, maxHeight)
        : 0.0;

    // Determine color based on percentile
    final Color barColor;
    if (percentile >= 0.75) {
      barColor = const Color(0xFF007AFF); // Blue - top 25%
    } else if (percentile >= 0.50) {
      barColor = const Color(0xFF6B6B70); // Dark gray - 50-75%
    } else if (percentile >= 0.25) {
      barColor = const Color(0xFF999999); // Medium gray - 25-50%
    } else {
      barColor = const Color(0xFFD1D1D6); // Light gray - bottom 25%
    }

    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(1.5)),
      ),
    );
  }
}
