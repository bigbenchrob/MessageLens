import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../infrastructure/repositories/stray_handles_provider.dart';

/// Sidebar cassette that displays a scrollable list of stray handles,
/// filtered by phone numbers or email addresses.
///
/// Each row shows the handle value, message count, and last message date.
/// Reviewed-but-unlinked handles are visually muted. Tapping a row
/// dispatches [MessagesSpec.handleLens] to the center panel.
class StrayHandlesReviewCassette extends HookConsumerWidget {
  const StrayHandlesReviewCassette({required this.filter, super.key});

  final StrayHandleFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final asyncHandles = ref.watch(strayHandlesProvider);

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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: colors.lines.border),
          itemBuilder: (context, index) {
            final handle = filtered[index];
            return _StrayHandleRow(
              handle: handle,
              onTap: () => _openHandleLens(ref, handle.handleId),
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
      StrayHandleFilter.phones =>
        handles.where((h) => h.serviceType != 'iMessage').toList(),
      StrayHandleFilter.emails =>
        handles.where((h) => h.serviceType == 'iMessage').toList(),
    };
  }

  String get _emptyMessage => switch (filter) {
    StrayHandleFilter.phones =>
      'No stray phone numbers found.\nAll phone handles are linked to contacts.',
    StrayHandleFilter.emails =>
      'No stray email addresses found.\nAll email handles are linked to contacts.',
  };

  void _openHandleLens(WidgetRef ref, int handleId) {
    ref
        .read(panelsViewStateProvider(SidebarMode.messages).notifier)
        .show(
          panel: WindowPanel.center,
          spec: ViewSpec.messages(MessagesSpec.handleLens(handleId: handleId)),
        );
  }
}

class _StrayHandleRow extends ConsumerWidget {
  const _StrayHandleRow({required this.handle, required this.onTap});

  final StrayHandleSummary handle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    final isReviewed = handle.reviewedAt != null;
    final contentAlpha = isReviewed ? 0.5 : 1.0;

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
                  Text(
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
            if (isReviewed) ...[
              const SizedBox(width: 6),
              Icon(
                CupertinoIcons.checkmark_circle,
                size: 14,
                color: colors.content.textTertiary.withValues(alpha: 0.5),
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
