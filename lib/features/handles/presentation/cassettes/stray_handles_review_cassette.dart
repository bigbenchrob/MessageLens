import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../domain/utilities/handle_normalizer.dart';
import '../../infrastructure/repositories/stray_handles_provider.dart';

/// Sidebar cassette that displays a scrollable list of stray handles,
/// filtered by phone numbers or email addresses.
///
/// Each row shows the handle value, message count, and last message date.
/// Reviewed-but-unlinked handles are visually muted. Tapping a row
/// dispatches [MessagesSpec.handleLens] to the center panel.
///
/// Mode support:
/// - [StrayHandleMode.allStrays]: Shows all stray handles (default)
/// - [StrayHandleMode.spamCandidates]: Shows only high junk-score handles
/// - [StrayHandleMode.dismissed]: Shows dismissed handles for recovery
class StrayHandlesReviewCassette extends HookConsumerWidget {
  const StrayHandlesReviewCassette({
    required this.filter,
    required this.mode,
    super.key,
  });

  final StrayHandleFilter filter;
  final StrayHandleMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    // Select provider based on mode
    final asyncHandles = switch (mode) {
      StrayHandleMode.allStrays => ref.watch(strayHandlesProvider),
      StrayHandleMode.spamCandidates => ref.watch(spamCandidateHandlesProvider),
      StrayHandleMode.dismissed => ref.watch(dismissedHandlesProvider),
    };

    return asyncHandles.when(
      data: (handles) {
        final filtered = _applyFilter(handles);

        if (filtered.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: Center(
              child: Text(
                _emptyMessage,
                style: typography.caption.copyWith(
                  color: colors.content.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.separated(
            // Let ListView fill the bounded height from shouldExpand: true
            // and handle its own scrolling
            itemCount: filtered.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: colors.lines.border),
            itemBuilder: (context, index) {
              final handle = filtered[index];
              return _StrayHandleRow(
                handle: handle,
                mode: mode,
                onTap: () => _openHandleLens(ref, handle.handleId),
                onDismiss: mode != StrayHandleMode.dismissed
                    ? () => _dismissHandle(ref, handle)
                    : null,
                onRestore: mode == StrayHandleMode.dismissed
                    ? () => _restoreHandle(ref, handle)
                    : null,
              );
            },
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Error loading handles: $error',
          style: typography.caption.copyWith(color: colors.accents.secondary),
        ),
      ),
    );
  }

  List<StrayHandleSummary> _applyFilter(List<StrayHandleSummary> handles) {
    return switch (filter) {
      StrayHandleFilter.phones =>
        handles.where((h) => h.serviceType != 'iMessage').toList(),
      StrayHandleFilter.emails =>
        handles.where((h) => h.serviceType == 'iMessage').toList(),
    };
  }

  String get _emptyMessage => switch (mode) {
    StrayHandleMode.allStrays => switch (filter) {
      StrayHandleFilter.phones =>
        'No stray phone numbers found.\nAll phone handles are linked to contacts.',
      StrayHandleFilter.emails =>
        'No stray email addresses found.\nAll email handles are linked to contacts.',
    },
    StrayHandleMode.spamCandidates => switch (filter) {
      StrayHandleFilter.phones =>
        'No spam candidates found.\nNo short codes or one-off messages detected.',
      StrayHandleFilter.emails =>
        'No spam candidates found.\nNo one-off email addresses detected.',
    },
    StrayHandleMode.dismissed =>
      'No dismissed handles.\nHandles you dismiss will appear here.',
  };

  void _openHandleLens(WidgetRef ref, int handleId) {
    ref
        .read(panelsViewStateProvider(SidebarMode.messages).notifier)
        .show(
          panel: WindowPanel.center,
          spec: ViewSpec.messages(MessagesSpec.handleLens(handleId: handleId)),
        );
  }

  Future<void> _dismissHandle(WidgetRef ref, StrayHandleSummary handle) async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    final normalizedHandle = normalizeHandleIdentifier(handle.handleValue);
    await overlayDb.dismissHandle(normalizedHandle);
    // Force refresh of stray handles
    ref.invalidate(strayHandlesProvider);
    ref.invalidate(spamCandidateHandlesProvider);
    ref.invalidate(dismissedHandlesProvider);
  }

  Future<void> _restoreHandle(WidgetRef ref, StrayHandleSummary handle) async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    final normalizedHandle = normalizeHandleIdentifier(handle.handleValue);
    await overlayDb.restoreHandle(normalizedHandle);
    // Force refresh of stray handles
    ref.invalidate(strayHandlesProvider);
    ref.invalidate(spamCandidateHandlesProvider);
    ref.invalidate(dismissedHandlesProvider);
  }
}

class _StrayHandleRow extends ConsumerWidget {
  const _StrayHandleRow({
    required this.handle,
    required this.mode,
    required this.onTap,
    this.onDismiss,
    this.onRestore,
  });

  final StrayHandleSummary handle;
  final StrayHandleMode mode;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    final isReviewed = handle.reviewedAt != null;
    final contentAlpha = isReviewed ? 0.5 : 1.0;

    // Show spam indicator for high junk scores in all modes
    final showSpamBadge =
        handle.junkScore >= 3 && mode != StrayHandleMode.dismissed;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Handle value + last date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (showSpamBadge) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colors.accents.primary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'SPAM',
                            style: typography.caption.copyWith(
                              color: colors.accents.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          handle.handleValue,
                          style: typography.body.copyWith(
                            color: colors.content.textPrimary.withValues(
                              alpha: contentAlpha,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (handle.lastMessageDate != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(handle.lastMessageDate!),
                      style: typography.caption.copyWith(
                        color: colors.content.textTertiary.withValues(
                          alpha: contentAlpha,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Message count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.surfaces.hover,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${handle.totalMessages}',
                style: typography.caption.copyWith(
                  color: colors.content.textSecondary.withValues(
                    alpha: contentAlpha,
                  ),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),

            // Reviewed indicator
            if (isReviewed && mode != StrayHandleMode.dismissed) ...[
              const SizedBox(width: 6),
              Icon(
                CupertinoIcons.checkmark_circle,
                size: 14,
                color: colors.content.textTertiary.withValues(alpha: 0.5),
              ),
            ],

            // Dismiss button (always visible in spam mode, hover in all strays)
            if (onDismiss != null &&
                (mode == StrayHandleMode.spamCandidates ||
                    handle.junkScore >= 3)) ...[
              const SizedBox(width: 6),
              _ActionButton(
                icon: CupertinoIcons.xmark_circle_fill,
                color: colors.accents.secondary,
                tooltip: 'Dismiss handle',
                onPressed: onDismiss!,
              ),
            ],

            // Restore button (dismissed mode only)
            if (onRestore != null) ...[
              const SizedBox(width: 6),
              _ActionButton(
                icon: CupertinoIcons.arrow_uturn_left_circle_fill,
                color: colors.accents.tertiary,
                tooltip: 'Restore handle',
                onPressed: onRestore!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat.jm().format(date);
    } else if (diff.inDays < 7) {
      return DateFormat.E().format(date);
    } else if (diff.inDays < 365) {
      return DateFormat.MMMd().format(date);
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }
}

/// Small icon button for row actions (dismiss/restore).
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Icon(icon, size: 18, color: color.withValues(alpha: 0.7)),
      ),
    );
  }
}
