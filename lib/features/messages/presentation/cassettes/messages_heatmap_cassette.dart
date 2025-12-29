import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../../contacts/application_pre_cassette/contact_profile_provider.dart';
import '../../../contacts/application_pre_cassette/contact_timeline_provider.dart';
import '../../application/use_cases/global_messages_heatmap_provider.dart';
import '../../domain/calendar_heatmap_timeline_data.dart';
import '../view_model/view_model_contact/current_visible_month_for_contact_provider.dart';
import '../view_model/view_model_global/current_visible_month_provider.dart';
import '../view_model/view_model_global/global_timeline_controller.dart';
import '../widgets/calendar_heatmap_timeline_widget.dart';

class MessagesHeatmapCassette extends ConsumerWidget {
  const MessagesHeatmapCassette({
    this.contactId,
    this.useV2Timeline = false,
    super.key,
  });

  final int? contactId;
  final bool useV2Timeline;

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
            loading: () => const _HeatmapLoadingCard(),
            error: (error, _) => _HeatmapErrorCard(
              message: 'Unable to load profile. $error',
              onRetry: () {
                ref.invalidate(contactProfileProvider(contactId: contactId!));
              },
            ),
          );
        }
        return _GlobalHeatmapContent(
          data: timeline,
          useV2Timeline: useV2Timeline,
        );
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

class _GlobalHeatmapContent extends HookConsumerWidget {
  const _GlobalHeatmapContent({
    required this.data,
    required this.useV2Timeline,
  });

  final CalendarHeatmapTimelineData? data;
  final bool useV2Timeline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auto-open timeline view on first load
    useEffect(() {
      if (data != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(panelsViewStateProvider.notifier)
              .show(
                panel: WindowPanel.center,
                spec: ViewSpec.messages(
                  useV2Timeline
                      ? const MessagesSpec.globalTimelineV2()
                      : const MessagesSpec.globalTimeline(),
                ),
              );
        });
      }
      return null;
    }, [data != null]);

    if (data == null) {
      return const _EmptyHeatmapCard(
        message: 'Import messages to see how your conversations ebb and flow.',
        icon: CupertinoIcons.chart_bar_alt_fill,
      );
    }

    final timeline = data!;
    final macosTheme = MacosTheme.of(context);
    final colors = ref.watch(themeColorsProvider.notifier);
    final t = ref.watch(themeTypographyProvider);

    // Watch the currently visible month
    final selectedMonthAsync = ref.watch(currentVisibleMonthProvider);
    final selectedMonth = selectedMonthAsync.valueOrNull;

    final stats = _buildStats(
      macosTheme: macosTheme,
      typography: t,
      colors: colors,
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
          selectedMonthKey: selectedMonth,
          onMonthTap: (year, month, count) {
            if (count <= 0) {
              return;
            }

            // If this is the last month, treat it as a "jump to latest" action
            // by passing null as the date.
            final isLastMonth =
                year == timeline.lastMessageDate.year &&
                month == timeline.lastMessageDate.month;
            final startDate = isLastMonth ? null : DateTime(year, month, 1);

            ref
                .read(panelsViewStateProvider.notifier)
                .show(
                  panel: WindowPanel.center,
                  spec: ViewSpec.messages(
                    useV2Timeline
                        ? MessagesSpec.globalTimelineV2(scrollToDate: startDate)
                        : const MessagesSpec.globalTimeline(),
                  ),
                );

            if (startDate != null) {
              unawaited(
                ref
                    .read(globalTimelineControllerProvider().notifier)
                    .jumpToDate(startDate),
              );
            }
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
                  spec: ViewSpec.messages(
                    useV2Timeline
                        ? const MessagesSpec.globalTimelineV2()
                        : const MessagesSpec.globalTimeline(),
                  ),
                );
          },
          child: Text(
            'Open full timeline',
            style: t.body.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _ContactHeatmapContent extends HookConsumerWidget {
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
    // Auto-open contact messages view on first load
    useEffect(() {
      if (data != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(panelsViewStateProvider.notifier)
              .show(
                panel: WindowPanel.center,
                spec: ViewSpec.messages(
                  MessagesSpec.forContact(
                    contactId: contactId,
                    scrollToDate: null,
                  ),
                ),
              );
        });
      }
      return null;
    }, [data != null]);

    if (data == null) {
      return const _EmptyHeatmapCard(
        message: 'Select a contact or choose one with messages to plot.',
        icon: CupertinoIcons.person_crop_circle_badge_exclam,
      );
    }

    final timeline = data!;
    final t = ref.watch(themeTypographyProvider);

    // Watch the currently visible month for this contact
    final selectedMonthAsync = ref.watch(
      currentVisibleMonthForContactProvider(contactId: contactId),
    );
    final selectedMonth = selectedMonthAsync.valueOrNull;

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
          selectedMonthKey: selectedMonth,
          onMonthTap: (year, month, count) {
            if (count <= 0) {
              return;
            }

            // If this is the last month, treat it as a "jump to latest" action
            // by passing null as the date.
            final isLastMonth =
                year == timeline.lastMessageDate.year &&
                month == timeline.lastMessageDate.month;
            final startDate = isLastMonth ? null : DateTime(year, month, 1);

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
        Text(summaryText, style: t.vizMeta),
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
  required ThemeTypography typography,
  required ThemeColors colors,
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
                Icon(stat.icon, size: 14, color: colors.content.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stat.value, style: typography.vizMeta),
                      const SizedBox(height: 2),
                      Text(stat.label, style: typography.caption),
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
