import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../config/theme/widgets/heatmap/activity_heatmap_color_scale.dart';
import '../../../../../core/util/count_label_formatter.dart';
import '../../../../../core/util/date_label_formatter.dart';
import '../../../../../essentials/sidebar/application/sidebar_cassette_sectioning.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart'
    show SidebarFlowContactProjection, sidebarFlowProvider;
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../../conversations/feature_level_providers.dart'
    show ContactGraphConversationSection;
import '../../../../sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../application/message_evidence/current_visible_month_provider.dart';
import '../../../application/message_evidence/global_messages_investigation_actions_provider.dart';
import '../../../domain/calendar_heatmap_timeline_data.dart';
import '../../../domain/message_evidence/message_evidence_scope.dart';
import '../../../presentation/widgets/calendar_heatmap_timeline_widget.dart';
import '../resolver_tools/contact_context_identity.dart';
import '../resolver_tools/contact_timeline_provider.dart';
import '../resolver_tools/global_messages_heatmap_provider.dart';
import '../resolver_tools/message_heatmap_navigation_actions_provider.dart';
import '../resolver_tools/message_heatmap_refresh_actions_provider.dart';

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
/// - Dispatch semantic actions on user interaction; do not construct panel specs
/// - Never make branching decisions about which UI to show
class MessagesHeatmapWidget extends ConsumerWidget {
  const MessagesHeatmapWidget({this.contactId, super.key});

  final int? contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (contactId != null) {
      return _ContactEvidenceContent(contactId: contactId!);
    }

    final timelineAsync = ref.watch(globalMessagesHeatmapProvider);

    return timelineAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (timeline) {
        return _GlobalHeatmapContent(data: timeline);
      },
      loading: () => const _HeatmapLoadingCard(),
      error: (error, _) => _HeatmapErrorCard(
        message: 'Unable to load heatmap data. $error',
        onRetry: () {
          ref
              .read(messageHeatmapRefreshActionsProvider.notifier)
              .refreshGlobalHeatmap();
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

    final selectedMonthKey = ref.watch(
      currentVisibleMonthForScopeProvider(
        scope: const GlobalMessagesEvidenceScope(),
      ),
    );
    return MessageHeatmapContent(
      data: timeline,
      selectedMonthKey: selectedMonthKey,
      onMonthTap: (year, month, count) {
        if (count <= 0) {
          return;
        }

        final isLastMonth =
            year == timeline.lastMessageDate.year &&
            month == timeline.lastMessageDate.month;
        ref
            .read(globalMessagesInvestigationActionsProvider.notifier)
            .browseMonth(isLastMonth ? null : DateTime(year, month, 1));
      },
    );
  }
}

enum _ContactEvidenceMode { allMessages, conversations }

class _ContactEvidenceContent extends ConsumerWidget {
  const _ContactEvidenceContent({required this.contactId});

  final int contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(sidebarFlowProvider);
    final mode =
        flowState.topMenuChoice == TopChatMenuChoice.contacts &&
            isSameContactContext(flowState.chosenContactId, contactId) &&
            flowState.contactProjection ==
                SidebarFlowContactProjection.conversations
        ? _ContactEvidenceMode.conversations
        : _ContactEvidenceMode.allMessages;

    final body = switch (mode) {
      _ContactEvidenceMode.allMessages => _ContactAllMessagesEvidence(
        contactId: contactId,
      ),
      _ContactEvidenceMode.conversations => ContactGraphConversationSection(
        contactId: contactId,
        selectedConversationId: flowState.selectedConversationId,
        padding: EdgeInsets.zero,
        maxHeight: 360,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContactEvidenceModeToggle(
          mode: mode,
          onChanged: (mode) {
            final projection = switch (mode) {
              _ContactEvidenceMode.allMessages =>
                SidebarContactProjection.allMessages,
              _ContactEvidenceMode.conversations =>
                SidebarContactProjection.conversations,
            };

            ref
                .read(messageHeatmapNavigationActionsProvider.notifier)
                .selectContactProjection(
                  contactId: contactId,
                  projection: projection,
                );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(width: double.infinity, child: body),
      ],
    );
  }
}

class _ContactAllMessagesEvidence extends ConsumerWidget {
  const _ContactAllMessagesEvidence({required this.contactId});

  final int contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(sidebarFlowProvider);
    final selectedHandleId = flowState.chosenContactId == contactId
        ? flowState.selectedHandleId
        : null;
    final timelineAsync = ref.watch(
      contactTimelineProvider(
        contactId: contactId,
        filterHandleId: selectedHandleId,
      ),
    );

    return timelineAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (timeline) {
        if (timeline == null) {
          return const _EmptyHeatmapCard(
            message: 'Select a contact or choose one with messages to plot.',
            icon: CupertinoIcons.person_crop_circle_badge_exclam,
          );
        }

        return _ContactAllMessagesHeatmap(
          contactId: contactId,
          timeline: timeline,
        );
      },
      loading: () => const _HeatmapLoadingCard(),
      error: (error, _) => _HeatmapErrorCard(
        message: 'Unable to load heatmap data. $error',
        onRetry: () {
          ref
              .read(messageHeatmapRefreshActionsProvider.notifier)
              .refreshContactTimeline(
                contactId: contactId,
                filterHandleId: selectedHandleId,
              );
        },
      ),
    );
  }
}

class _ContactAllMessagesHeatmap extends ConsumerWidget {
  const _ContactAllMessagesHeatmap({
    required this.contactId,
    required this.timeline,
  });

  final int contactId;
  final CalendarHeatmapTimelineData timeline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(sidebarFlowProvider);
    final selectedHandleId = flowState.chosenContactId == contactId
        ? flowState.selectedHandleId
        : null;
    final selectedMonthKey = ref.watch(
      currentVisibleMonthForScopeProvider(
        scope: _contactEvidenceScope(
          contactId: contactId,
          selectedHandleId: selectedHandleId,
        ),
      ),
    );

    return MessageHeatmapContent(
      data: timeline,
      selectedMonthKey: selectedMonthKey,
      onMonthTap: (year, month, count) {
        if (count <= 0) {
          return;
        }

        final isLastMonth =
            year == timeline.lastMessageDate.year &&
            month == timeline.lastMessageDate.month;

        ref
            .read(messageHeatmapNavigationActionsProvider.notifier)
            .focusMonth(
              contactId: contactId,
              monthAnchor: isLastMonth ? null : DateTime(year, month, 1),
            );
      },
    );
  }
}

MessageEvidenceScope _contactEvidenceScope({
  required int contactId,
  required int? selectedHandleId,
}) {
  if (selectedHandleId == null) {
    return ContactAllMessagesEvidenceScope(contactId: contactId);
  }
  return ContactHandleMessagesEvidenceScope(
    contactId: contactId,
    handleId: selectedHandleId,
  );
}

class _ContactEvidenceModeToggle extends ConsumerWidget {
  const _ContactEvidenceModeToggle({
    required this.mode,
    required this.onChanged,
  });

  final _ContactEvidenceMode mode;
  final ValueChanged<_ContactEvidenceMode> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return CupertinoSlidingSegmentedControl<_ContactEvidenceMode>(
      groupValue: mode,
      thumbColor: colors.surfaces.selected,
      backgroundColor: colors.surfaces.control,
      children: {
        _ContactEvidenceMode.allMessages: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text('All messages', style: typography.caption),
        ),
        _ContactEvidenceMode.conversations: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text('By conversation', style: typography.caption),
        ),
      },
      onValueChanged: (value) {
        if (value == null) {
          return;
        }
        onChanged(value);
      },
    );
  }
}

class MessageHeatmapContent extends ConsumerWidget {
  const MessageHeatmapContent({
    required this.data,
    required this.selectedMonthKey,
    required this.onMonthTap,
    this.monthTooltipBuilder,
    this.legend = const MessageHeatmapLegend(),
    this.hintText = 'Tap a square to jump to that month',
    super.key,
  });

  final CalendarHeatmapTimelineData data;
  final String? selectedMonthKey;
  final void Function(int year, int month, int count) onMonthTap;
  final String? Function(MonthData monthData)? monthTooltipBuilder;
  final Widget? legend;
  final String hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    final visualizationGap = sidebarCassetteContentGapForSemanticStyle(
      SidebarCassetteSemanticStyle.visualization,
    );
    final summaryText =
        '${CountLabelFormatter.messages(data.totalMessages)} '
        '• ${_formatDateRange(data.firstMessageDate, data.lastMessageDate)}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final railWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(
                0.0,
                _messageHeatmapVisualizationRailWidth,
              )
            : _messageHeatmapVisualizationRailWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: railWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(summaryText, style: typography.vizMeta),
                SizedBox(height: visualizationGap),
                SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: CalendarHeatmapTimelineWidget(
                      data: data,
                      monthSize: 12,
                      monthSpacing: 2,
                      selectedMonthKey: selectedMonthKey,
                      monthTooltipBuilder: monthTooltipBuilder,
                      onMonthTap: onMonthTap,
                    ),
                  ),
                ),
                if (legend != null) ...[
                  SizedBox(height: visualizationGap),
                  legend!,
                ],
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.cassetteHintGap,
                  ),
                  child: Text(
                    hintText,
                    style: typography.caption,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

const double _messageHeatmapVisualizationRailWidth = 252;

class MessageHeatmapLegend extends ConsumerWidget {
  const MessageHeatmapLegend({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        _LegendItem(
          label: '1-3',
          swatch: _DotLegendSwatch(color: colors.content.textTertiary),
        ),
        const _LegendItem(label: '4-10', representativeCount: 4),
        const _LegendItem(label: '11-30', representativeCount: 11),
        const _LegendItem(label: '31-50', representativeCount: 31),
        const _LegendItem(label: '51-100', representativeCount: 51),
        const _LegendItem(label: '101-300', representativeCount: 101),
        const _LegendItem(label: '301-1K', representativeCount: 301),
        const _LegendItem(label: '1K-3K', representativeCount: 1001),
        const _LegendItem(label: '3K-10K', representativeCount: 3001),
        const _LegendItem(label: '10K+', representativeCount: 10001),
      ],
    );
  }
}

class _LegendItem extends ConsumerWidget {
  const _LegendItem({
    required this.label,
    this.representativeCount,
    this.swatch,
  });

  final String label;
  final int? representativeCount;
  final Widget? swatch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        swatch ?? _ColorLegendSwatch(messageCount: representativeCount!),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: typography.caption),
      ],
    );
  }
}

class _ColorLegendSwatch extends StatelessWidget {
  const _ColorLegendSwatch({required this.messageCount});

  final int messageCount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: activityHeatmapColorForMessageCount(messageCount),
        borderRadius: BorderRadius.circular(2),
      ),
      child: const SizedBox(width: 10, height: 10),
    );
  }
}

class _DotLegendSwatch extends StatelessWidget {
  const _DotLegendSwatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 10,
      child: Center(
        child: Text(
          '...',
          style: TextStyle(fontSize: 8, height: 1, color: color),
        ),
      ),
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
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: colors.status.error,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: t.caption.copyWith(color: colors.status.error),
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
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
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
              style: t.caption.copyWith(color: colors.content.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateRange(DateTime start, DateTime end) {
  final startLabel = DateLabelFormatter.compactMonthYear(start);
  final endLabel = DateLabelFormatter.compactMonthYear(end);
  return startLabel == endLabel ? startLabel : '$startLabel → $endLabel';
}
