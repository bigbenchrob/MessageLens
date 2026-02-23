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
          padding: const EdgeInsets.only(top: 2),
          itemCount: filtered.length,
          // Symmetric divider insets - action button overlays on top
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: colors.lines.border,
            // No indent - card wrapper provides horizontal inset
          ),
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

    // Muted warning/destructive hue for spam rows
    // Using coral-red for instant spam recognition during blitz cleanup
    const spamTint = Color(0xFFD64545);

    // Show dismiss button for spam candidates
    final showDismiss =
        onDismiss != null &&
        (mode == StrayHandleMode.spamCandidates || handle.junkScore >= 3);

    // Show restore button for dismissed mode
    final showRestore = onRestore != null;

    // Whether an action button will be shown (affects data padding)
    final hasAction = showDismiss || showRestore;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Data container: no left padding (card wrapper provides inset)
          // Conditional right inset to keep action button from overlapping
          Padding(
            padding: EdgeInsets.only(
              right: hasAction ? 32 : 0, // action-safe inset only
              top: 8,
              bottom: 8,
            ),
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
                            // Warning tint for spam badge
                            color: spamTint.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            'SPAM',
                            style: typography.caption.copyWith(
                              // Warning color for spam badge text
                              color: spamTint.withValues(alpha: 0.75),
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
                            // Spam rows: tint handle with warning color
                            // Normal rows: standard primary text
                            color: showSpamBadge
                                ? spamTint.withValues(
                                    alpha: contentAlpha * 0.85,
                                  )
                                : colors.content.textPrimary.withValues(
                                    alpha: contentAlpha,
                                  ),
                            // Spam: slightly lighter weight (less substantial)
                            // Normal: medium weight
                            fontWeight: showSpamBadge
                                ? FontWeight.w400
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Metadata (message count + date) - flows naturally, right-aligned
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
              ],
            ),
          ),

          // Action button overlay (outside data flow)
          if (showDismiss || showRestore)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: showDismiss
                    ? _DismissButton(onPressed: onDismiss!)
                    : _RestoreButton(onPressed: onRestore!, colors: colors),
              ),
            ),
        ],
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
  const _DismissButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_DismissButton> createState() => _DismissButtonState();
}

class _DismissButtonState extends State<_DismissButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Red X on neutral surface at rest - action is clear without hover
    // Hover/pressed reinforce, not redefine
    const destructiveRed = Color(0xFFD64545);
    const neutralGray = Color(0xFF8E8E93); // System gray

    // Background: neutral at rest, slight darkening on hover/press
    final bgColor = _isPressed
        ? neutralGray.withValues(alpha: 0.18)
        : _isHovered
        ? neutralGray.withValues(alpha: 0.12)
        : neutralGray.withValues(alpha: 0.08);

    // Border: subtle at rest, slightly stronger on interaction
    final borderColor = _isPressed
        ? neutralGray.withValues(alpha: 0.35)
        : _isHovered
        ? neutralGray.withValues(alpha: 0.28)
        : neutralGray.withValues(alpha: 0.20);

    // Icon: RED at rest, intensifies on hover/press
    final iconColor = _isPressed
        ? destructiveRed
        : _isHovered
        ? destructiveRed.withValues(alpha: 0.95)
        : destructiveRed.withValues(alpha: 0.75);

    return Tooltip(
      message: 'Dismiss handle',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          child: Container(
            // Larger hit area for button-like feel
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Icon(CupertinoIcons.xmark, size: 10, color: iconColor),
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
