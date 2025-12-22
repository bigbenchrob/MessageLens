import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../../chats/domain/calendar_heatmap_timeline_data.dart';
import '../../../chats/presentation/widgets/calendar_heatmap_timeline_widget.dart';
import '../../../contacts/application_pre_cassette/contact_profile_provider.dart';
import '../../../contacts/application_pre_cassette/contact_timeline_provider.dart';
import '../../application/use_cases/global_messages_heatmap_provider.dart';
import '../view_model/global_timeline_controller.dart';
import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';

class MessagesHeatmapCassette extends ConsumerWidget {
  const MessagesHeatmapCassette({this.contactId, super.key});

  final int? contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = contactId == null
        ? ref.watch(globalMessagesHeatmapProvider)
        : ref.watch(contactTimelineProvider(contactId: contactId!));

    final profileAsync = contactId == null
        ? const AsyncValue<ContactProfileSummary?>.data(null)
        : ref.watch(contactProfileProvider(contactId: contactId!));

    return timelineAsync.when(
      data: (timeline) {
        if (contactId != null) {
          return profileAsync.when(
            data: (profile) => _ContactHeatmapContent(
              contactId: contactId!,
              profile: profile,
              data: timeline,
            ),
            loading: () => _ContactHeatmapContent(
              contactId: contactId!,
              profile: null,
              data: timeline,
            ),
            error: (error, _) => _ContactHeatmapContent(
              contactId: contactId!,
              profile: null,
              data: timeline,
            ),
          );
        }
        return _GlobalHeatmapContent(data: timeline);
      },
      loading: () => const _HeatmapLoadingCard(),
      error: (error, _) => _HeatmapErrorCard(
        message: 'Unable to load heatmap data. $error',
        onRetry: () {
          if (contactId == null) {
            ref.invalidate(globalMessagesHeatmapProvider);
          } else {
            ref.invalidate(contactTimelineProvider(contactId: contactId!));
          }
        },
      ),
    );
  }
}

class _GlobalHeatmapContent extends ConsumerWidget {
  const _GlobalHeatmapContent({required this.data});

  final CalendarHeatmapTimelineData? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data == null) {
      return const _EmptyHeatmapCard(
        message: 'Import messages to see how your conversations ebb and flow.',
        icon: CupertinoIcons.chart_bar_alt_fill,
      );
    }

    final timeline = data!;
    final macosTheme = MacosTheme.of(context);
    final stats = _buildStats(
      macosTheme: macosTheme,
      stats: [
        _HeatmapStat(
          icon: CupertinoIcons.bolt_circle,
          label: 'Total messages',
          value: NumberFormat.decimalPattern().format(timeline.totalMessages),
        ),
        _HeatmapStat(
          icon: CupertinoIcons.calendar,
          label: 'Archive span',
          value: _formatDateRange(
            timeline.firstMessageDate,
            timeline.lastMessageDate,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        stats,
        const SizedBox(height: 12),
        CalendarHeatmapTimelineWidget(
          data: timeline,
          monthSize: 12,
          monthSpacing: 2,
          onMonthTap: (year, month, count) {
            if (count <= 0) {
              return;
            }
            final startDate = DateTime(year, month, 1);
            ref
                .read(panelsViewStateProvider.notifier)
                .show(
                  panel: WindowPanel.center,
                  spec: const ViewSpec.messages(MessagesSpec.globalTimeline()),
                );
            unawaited(
              ref
                  .read(globalTimelineControllerProvider().notifier)
                  .jumpToDate(startDate),
            );
          },
        ),
        const SizedBox(height: 12),
        PushButton(
          controlSize: ControlSize.small,
          onPressed: () {
            ref
                .read(panelsViewStateProvider.notifier)
                .show(
                  panel: WindowPanel.center,
                  spec: const ViewSpec.messages(MessagesSpec.globalTimeline()),
                );
          },
          child: const Text('Open full timeline'),
        ),
      ],
    );
  }
}

class _ContactHeatmapContent extends ConsumerWidget {
  const _ContactHeatmapContent({
    required this.contactId,
    required this.profile,
    required this.data,
  });

  final int contactId;
  final ContactProfileSummary? profile;
  final CalendarHeatmapTimelineData? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data == null) {
      return const _EmptyHeatmapCard(
        message: 'Select a contact or choose one with messages to plot.',
        icon: CupertinoIcons.person_crop_circle_badge_exclam,
      );
    }

    final timeline = data!;
    final macosTheme = MacosTheme.of(context);

    final summaryText =
        '${NumberFormat.decimalPattern().format(timeline.totalMessages)} '
        'Messages • ${_formatDateRange(timeline.firstMessageDate, timeline.lastMessageDate)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CalendarHeatmapTimelineWidget(
          data: timeline,
          monthSize: 12,
          monthSpacing: 2,
          onMonthTap: (year, month, count) {
            if (count <= 0) {
              return;
            }
            final startDate = DateTime(year, month, 1);
            ref
                .read(panelsViewStateProvider.notifier)
                .show(
                  panel: WindowPanel.center,
                  spec: ViewSpec.messages(
                    MessagesSpec.forContact(
                      contactId: contactId,
                      scrollToDate: startDate,
                    ),
                  ),
                );
          },
        ),
        const SizedBox(height: 12),
        Text(
          summaryText,
          style: macosTheme.typography.caption1.copyWith(
            color: macosTheme.typography.caption1.color?.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _HeatmapLoadingCard extends StatelessWidget {
  const _HeatmapLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: ProgressCircle(radius: 10),
      ),
    );
  }
}

class _HeatmapErrorCard extends StatelessWidget {
  const _HeatmapErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final macosTheme = MacosTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: macosTheme.canvasColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CupertinoColors.systemRed.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: CupertinoColors.systemRed,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: macosTheme.typography.caption1.copyWith(
                    color: CupertinoColors.systemRed,
                  ),
                ),
                const SizedBox(height: 8),
                PushButton(
                  controlSize: ControlSize.small,
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHeatmapCard extends StatelessWidget {
  const _EmptyHeatmapCard({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final macosTheme = MacosTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: macosTheme.canvasColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: macosTheme.dividerColor.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: CupertinoColors.inactiveGray),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: macosTheme.typography.caption1.copyWith(
                color: macosTheme.typography.caption1.color?.withValues(
                  alpha: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapStat {
  const _HeatmapStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

Widget _buildStats({
  required MacosThemeData macosTheme,
  required List<_HeatmapStat> stats,
}) {
  return Wrap(
    spacing: 10,
    runSpacing: 10,
    children: stats
        .map(
          (stat) => Container(
            constraints: const BoxConstraints(minWidth: 140),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: macosTheme.canvasColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: macosTheme.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  stat.icon,
                  size: 14,
                  color: macosTheme.typography.body.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.value,
                        style: macosTheme.typography.caption1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(stat.label, style: macosTheme.typography.caption2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(growable: false),
  );
}

String _formatDateRange(DateTime start, DateTime end) {
  final formatter = DateFormat('MMM yyyy');
  final startLabel = formatter.format(start);
  final endLabel = formatter.format(end);
  return startLabel == endLabel ? startLabel : '$startLabel → $endLabel';
}
