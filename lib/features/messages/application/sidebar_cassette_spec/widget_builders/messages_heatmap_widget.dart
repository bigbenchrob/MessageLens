import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/navigation/feature_level_providers.dart';
import '../../../../contacts/infrastructure/repositories/contact_profile_provider.dart';
import '../../../domain/calendar_heatmap_timeline_data.dart';
import '../../../domain/value_objects/message_timeline_scope.dart';
import '../../../presentation/view_model/timeline/ordinal/current_visible_month_provider.dart';
import '../../../presentation/widgets/calendar_heatmap_timeline_widget.dart';
import '../resolver_tools/contact_timeline_provider.dart';
import '../resolver_tools/global_messages_heatmap_provider.dart';

/// Widget builder for the messages heatmap cassette.
///
/// Displays a calendar heatmap of message activity, either globally or scoped
/// to a specific contact.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Widget builders:
/// - Accept fully-decided inputs (not specs)
/// - May use `ref.watch()` for reactive updates
/// - Construct specs only on user interaction (output, not interpretation)
/// - Never make branching decisions about which UI to show
class MessagesHeatmapWidget extends ConsumerWidget {
  const MessagesHeatmapWidget({this.contactId, super.key});

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
            loading: () => const _HeatmapLoadingCard(),
            error: (error, _) => _HeatmapErrorCard(
              message: 'Unable to load profile. $error',
              onRetry: () {
                ref.invalidate(contactProfileProvider(contactId: contactId!));
              },
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

class _GlobalHeatmapContent extends HookConsumerWidget {
  const _GlobalHeatmapContent({required this.data});

  final CalendarHeatmapTimelineData? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      if (data != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(panelsViewStateProvider(SidebarMode.messages).notifier)
              .show(
                panel: WindowPanel.center,
                spec: const ViewSpec.messages(MessagesSpec.globalTimeline()),
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
    final colors = ref.watch(themeColorsProvider.notifier);
    final t = ref.watch(themeTypographyProvider);

    final selectedMonthAsync = ref.watch(
      currentVisibleMonthForScopeProvider(
        scope: const MessageTimelineScope.global(),
      ),
    );
    final selectedMonth = selectedMonthAsync.valueOrNull;

    final stats = _buildStats(
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
        const SizedBox(height: AppSpacing.sm),
        CalendarHeatmapTimelineWidget(
          data: timeline,
          monthSize: 12,
          monthSpacing: 2,
          selectedMonthKey: selectedMonth,
          onMonthTap: (year, month, count) {
            if (count <= 0) {
              return;
            }

            final isLastMonth =
                year == timeline.lastMessageDate.year &&
                month == timeline.lastMessageDate.month;
            final startDate = isLastMonth ? null : DateTime(year, month, 1);

            ref
                .read(panelsViewStateProvider(SidebarMode.messages).notifier)
                .show(
                  panel: WindowPanel.center,
                  spec: ViewSpec.messages(
                    MessagesSpec.globalTimeline(scrollToDate: startDate),
                  ),
                );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        PushButton(
          controlSize: ControlSize.small,
          onPressed: () {
            ref
                .read(panelsViewStateProvider(SidebarMode.messages).notifier)
                .show(
                  panel: WindowPanel.center,
                  spec: const ViewSpec.messages(MessagesSpec.globalTimeline()),
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
    useEffect(() {
      if (data != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(panelsViewStateProvider(SidebarMode.messages).notifier)
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

    final selectedMonthAsync = ref.watch(
      currentVisibleMonthForScopeProvider(
        scope: MessageTimelineScope.contact(contactId: contactId),
      ),
    );
    final selectedMonth = selectedMonthAsync.valueOrNull;

    final summaryText =
        '${NumberFormat.decimalPattern().format(timeline.totalMessages)} '
        'Messages • ${_formatDateRange(timeline.firstMessageDate, timeline.lastMessageDate)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Summary above heatmap acts as visual separator from info card
        Text(summaryText, style: t.vizMeta),
        const SizedBox(height: AppSpacing.md),
        CalendarHeatmapTimelineWidget(
          data: timeline,
          monthSize: 12,
          monthSpacing: 2,
          selectedMonthKey: selectedMonth,
          onMonthTap: (year, month, count) {
            if (count <= 0) {
              return;
            }

            final isLastMonth =
                year == timeline.lastMessageDate.year &&
                month == timeline.lastMessageDate.month;
            final startDate = isLastMonth ? null : DateTime(year, month, 1);

            ref
                .read(panelsViewStateProvider(SidebarMode.messages).notifier)
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
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: ProgressCircle(radius: 10),
      ),
    );
  }
}

class _HeatmapErrorCard extends ConsumerWidget {
  const _HeatmapErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeTypographyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: CupertinoColors.systemRed,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: t.caption.copyWith(color: CupertinoColors.systemRed),
                ),
                const SizedBox(height: AppSpacing.sm),
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

class _EmptyHeatmapCard extends ConsumerWidget {
  const _EmptyHeatmapCard({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeColorsProvider.notifier);
    final t = ref.watch(themeTypographyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colors.content.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: t.caption.copyWith(
                color: colors.content.textSecondary,
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
  required ThemeTypography typography,
  required ThemeColors colors,
  required List<_HeatmapStat> stats,
}) {
  return Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.xs,
    children: stats
        .map(
          (stat) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(stat.icon, size: 14, color: colors.content.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stat.value, style: typography.vizMeta),
                  Text(stat.label, style: typography.caption),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
            ],
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
