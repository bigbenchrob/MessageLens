import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../domain/year_based_timeline_data.dart';

/// Renders a year-based timeline visualization with intuitive visual hierarchy
///
/// Each year is shown as a separate line segment with:
/// - Year label below (2015, 2016, etc.)
/// - Bars or dots representing activity in that year
/// - Adaptive width based on total timespan
/// - Skip empty years entirely
///
/// Example (3 messages in Aug 2016 only):
/// ```
///       |—————|
///      2016
/// ```
///
/// Example (long span with gaps):
/// ```
/// |———————| |—————| |—————————| |————|
///   2016     2018      2022      2023
/// ```
class YearBasedTimelineWidget extends StatelessWidget {
  const YearBasedTimelineWidget({
    required this.data,
    this.barHeight = 36.0,
    super.key,
  });

  final YearBasedTimelineData data;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    if (data.yearTimelines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Year segments with activity bars
        SizedBox(
          height: barHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < data.yearTimelines.length; i++) ...[
                if (i > 0) const SizedBox(width: 8), // Gap between years
                Flexible(
                  flex: _getYearFlex(data.yearTimelines[i]),
                  child: _YearSegment(
                    yearTimeline: data.yearTimelines[i],
                    maxHeight: barHeight,
                    overallMaxCount: data.overallMaxCount,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Year labels
        SizedBox(
          height: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < data.yearTimelines.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Flexible(
                  flex: _getYearFlex(data.yearTimelines[i]),
                  child: _YearLabel(
                    year: data.yearTimelines[i].year,
                    isCompact: data.shouldUseCompactLabels,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Calculate flex weight for a year (proportional to messages)
  int _getYearFlex(YearTimeline yearTimeline) {
    // Give each year a flex weight based on its message count relative to overall max
    // This makes busier years slightly wider
    final ratio = yearTimeline.maxCount / data.overallMaxCount;
    return math.max(1, (ratio * 10).round());
  }
}

/// A single year's timeline segment
class _YearSegment extends StatelessWidget {
  const _YearSegment({
    required this.yearTimeline,
    required this.maxHeight,
    required this.overallMaxCount,
  });

  final YearTimeline yearTimeline;
  final double maxHeight;
  final int overallMaxCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base line (year axis)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(height: 1, color: const Color(0xFFE2E2EA)),
        ),

        // Activity bars or dots
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final bucket in yearTimeline.buckets)
              Expanded(
                child: _BucketBar(
                  bucket: bucket,
                  maxHeight: maxHeight,
                  maxCount: overallMaxCount,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A single bucket's bar or dots
class _BucketBar extends StatelessWidget {
  const _BucketBar({
    required this.bucket,
    required this.maxHeight,
    required this.maxCount,
  });

  final YearPeriodBucket bucket;
  final double maxHeight;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    if (bucket.messageCount == 0) {
      return const SizedBox.shrink();
    }

    // For high density periods, show as stacked dots
    if (bucket.isHighDensity) {
      return _buildStackedDots();
    }

    // For low/medium density, show as bar
    return _buildBar();
  }

  Widget _buildBar() {
    final percentile = bucket.messageCount / maxCount;
    final barHeight = (percentile * maxHeight).clamp(2.0, maxHeight);

    // Color based on percentile
    final Color barColor;
    if (percentile >= 0.75) {
      barColor = const Color(0xFF007AFF); // Blue - top 25%
    } else if (percentile >= 0.50) {
      barColor = const Color(0xFF6B6B70); // Dark gray
    } else if (percentile >= 0.25) {
      barColor = const Color(0xFF999999); // Medium gray
    } else {
      barColor = const Color(0xFFD1D1D6); // Light gray
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.5),
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(1.5)),
        ),
      ),
    );
  }

  Widget _buildStackedDots() {
    // Show 3-5 stacked dots for high density
    final numDots = math.min(5, (bucket.messageCount / 50).ceil() + 2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (var i = 0; i < numDots; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Year label below the timeline
class _YearLabel extends StatelessWidget {
  const _YearLabel({required this.year, required this.isCompact});

  final int year;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final label = isCompact
        ? "'${year.toString().substring(2)}"
        : year.toString();

    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: isCompact ? 9 : 10,
          color: const Color(0xFF999999),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
