import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../domain/chat_timeline_data.dart';
import '../view_model/recent_chats_provider.dart';
import 'calendar_heatmap_timeline_widget.dart';

/// Enhanced chat card with recency indicator and activity timeline.
///
/// Displays:
/// - Primary label: Contact's familiar name (e.g., "Rusung")
/// - Secondary label: Handle identifier (e.g., "rusung@me.com")
/// - Message count badge
/// - Recency indicator (⏱ Now, 📩 Today, 📆 This week, etc.)
/// - Activity timeline showing message distribution over time
///
/// Visual hierarchy:
/// ```
/// ┌─────────────────────────────┐
/// │ Rusung              [123]   │  ← Primary label + badge
/// │ rusung@me.com       ⏱ Now  │  ← Handle + recency
/// │ ┌─┬──┬─┬───┬─┬──┐          │
/// │ │ ││  │ │   │ ││  │         │  ← Timeline
/// │ └─┴──┴─┴───┴─┴──┘          │
/// │ Jan 2014  →  Dec 2024       │  ← Date range
/// └─────────────────────────────┘
/// ```
class EnhancedChatCard extends StatelessWidget {
  const EnhancedChatCard({required this.chat, required this.onTap, super.key});

  final RecentChatSummary chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final typography = theme.typography;
    final isDark = theme.brightness == Brightness.dark;

    // Debug: Log timeline data availability
    print(
      '[CARD] Chat ${chat.chatId}: heatmap=${chat.calendarHeatmapTimelineData != null}, '
      'firstDate=${chat.firstMessageDate}, lastDate=${chat.lastMessageDate}, '
      'years=${chat.calendarHeatmapTimelineData?.yearRows.length ?? 0}',
    );

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C33) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E2EA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primary row: Name + Chat ID + Message count badge
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            chat.title,
                            style: typography.title2.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${chat.chatId})',
                          style: typography.caption1.copyWith(
                            color: const Color(0xFF999999),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _MessageCountBadge(count: chat.messageCount),
                ],
              ),

              const SizedBox(height: 6),

              // Secondary row: Handle + Recency indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _getHandleDisplayText(),
                      style: typography.caption1.copyWith(
                        color: const Color(0xFF999999),
                        fontFamily: 'SF Mono',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (chat.recency != null) ...[
                    const SizedBox(width: 8),
                    _RecencyBadge(recency: chat.recency!),
                  ],
                ],
              ),

              // Calendar heatmap timeline visualization
              if (chat.calendarHeatmapTimelineData != null) ...[
                const SizedBox(height: 12),
                CalendarHeatmapTimelineWidget(
                  data: chat.calendarHeatmapTimelineData!,
                  monthSize: 14,
                  monthSpacing: 2,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getHandleDisplayText() {
    // Show the actual handle identifier (email/phone)
    if (chat.handles.isNotEmpty) {
      return chat.handles.first;
    }
    return 'Unknown';
  }
}

class _MessageCountBadge extends StatelessWidget {
  const _MessageCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          count.toString(),
          style: typography.caption1.copyWith(
            color: const Color(0xFF007AFF),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _RecencyBadge extends StatelessWidget {
  const _RecencyBadge({required this.recency});

  final ChatRecency recency;

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _getBackgroundColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(recency.icon, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Text(
              recency.label,
              style: typography.caption2.copyWith(
                color: _getTextColor(),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (recency) {
      case ChatRecency.now:
      case ChatRecency.today:
        return const Color(0xFF34C759); // Green
      case ChatRecency.thisWeek:
        return const Color(0xFF007AFF); // Blue
      case ChatRecency.thisMonth:
        return const Color(0xFFFF9500); // Orange
      case ChatRecency.recent:
        return const Color(0xFF8E8E93); // Gray
      case ChatRecency.archive:
        return const Color(0xFFD1D1D6); // Light gray
    }
  }

  Color _getTextColor() {
    switch (recency) {
      case ChatRecency.now:
      case ChatRecency.today:
        return const Color(0xFF34C759);
      case ChatRecency.thisWeek:
        return const Color(0xFF007AFF);
      case ChatRecency.thisMonth:
        return const Color(0xFFFF9500);
      case ChatRecency.recent:
        return const Color(0xFF8E8E93);
      case ChatRecency.archive:
        return const Color(0xFF999999);
    }
  }
}
