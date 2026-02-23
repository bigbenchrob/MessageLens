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

        return ListView.separated(
          // Let ListView fill the bounded height from shouldExpand: true
          // and handle its own scrolling
          // 4pt top padding completes 12pt gap: 8pt (sectionTitle) + 4pt
          padding: const EdgeInsets.only(top: 4),
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
      // Business URNs start with 'urn:'
      StrayHandleFilter.businessUrns =>
        handles.where((h) => h.handleValue.startsWith('urn:')).toList(),
      // Emails contain '@'
      StrayHandleFilter.emails =>
        handles.where((h) => h.handleValue.contains('@')).toList(),
      // Phones: no '@', no 'urn:' prefix
      StrayHandleFilter.phones =>
        handles
            .where(
              (h) =>
                  !h.handleValue.contains('@') &&
                  !h.handleValue.startsWith('urn:'),
            )
            .toList(),
    };
  }

  String get _emptyMessage => switch (mode) {
    StrayHandleMode.allStrays => switch (filter) {
      StrayHandleFilter.phones =>
        'No unfamiliar phone numbers found.\nAll are linked to contacts.',
      StrayHandleFilter.emails =>
        'No unfamiliar email addresses found.\nAll are linked to contacts.',
      StrayHandleFilter.businessUrns =>
        'No unfamiliar business accounts found.\nAll are linked to contacts.',
    },
    StrayHandleMode.spamCandidates => switch (filter) {
      StrayHandleFilter.phones =>
        'No spam candidates.\nNo short codes or one-off messages detected.',
      StrayHandleFilter.emails =>
        'No spam candidates.\nNo one-off email addresses detected.',
      StrayHandleFilter.businessUrns =>
        'No spam candidates.\nNo one-off business accounts detected.',
    },
    StrayHandleMode.dismissed =>
      'No dismissed items.\nItems you dismiss will appear here.',
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
            // Handle value (with optional spam badge)
            Expanded(
              child: Row(
                children: [
                  if (showSpamBadge) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        // Reduced visual weight: softer background
                        color: colors.content.textTertiary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'SPAM',
                        style: typography.caption.copyWith(
                          // Reduced visual weight: use tertiary color
                          color: colors.content.textTertiary,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
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
            ),

            const SizedBox(width: 8),

            // Metadata cluster: message count + last date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Message count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
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
                // Last message date (reduced visual prominence)
                if (handle.lastMessageDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(handle.lastMessageDate!),
                    style: typography.caption.copyWith(
                      color: colors.content.textTertiary.withValues(
                        alpha: contentAlpha * 0.8,
                      ),
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
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

            // Dismiss button (for spam candidates)
            if (onDismiss != null &&
                (mode == StrayHandleMode.spamCandidates ||
                    handle.junkScore >= 3)) ...[
              const SizedBox(width: 8),
              _DismissButton(onPressed: onDismiss!, colors: colors),
            ],

            // Restore button (dismissed mode only)
            if (onRestore != null) ...[
              const SizedBox(width: 8),
              _RestoreButton(onPressed: onRestore!, colors: colors),
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

/// Dismiss button with destructive styling and hover state.
class _DismissButton extends StatefulWidget {
  const _DismissButton({required this.onPressed, required this.colors});

  final VoidCallback onPressed;
  final ThemeColors colors;

  @override
  State<_DismissButton> createState() => _DismissButtonState();
}

class _DismissButtonState extends State<_DismissButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Destructive accent: subtle red tones
    final baseColor = widget.colors.accents.secondary;
    final bgAlpha = _isPressed ? 0.25 : (_isHovered ? 0.15 : 0.08);
    final iconAlpha = _isPressed ? 1.0 : (_isHovered ? 0.9 : 0.6);

    return Tooltip(
      message: 'Dismiss',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: bgAlpha),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              CupertinoIcons.xmark,
              size: 12,
              color: baseColor.withValues(alpha: iconAlpha),
            ),
          ),
        ),
      ),
    );
  }
}

/// Restore button with hover state.
class _RestoreButton extends StatefulWidget {
  const _RestoreButton({required this.onPressed, required this.colors});

  final VoidCallback onPressed;
  final ThemeColors colors;

  @override
  State<_RestoreButton> createState() => _RestoreButtonState();
}

class _RestoreButtonState extends State<_RestoreButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.colors.accents.tertiary;
    final bgAlpha = _isPressed ? 0.25 : (_isHovered ? 0.15 : 0.08);
    final iconAlpha = _isPressed ? 1.0 : (_isHovered ? 0.9 : 0.6);

    return Tooltip(
      message: 'Restore',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: bgAlpha),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              CupertinoIcons.arrow_uturn_left,
              size: 12,
              color: baseColor.withValues(alpha: iconAlpha),
            ),
          ),
        ),
      ),
    );
  }
}
