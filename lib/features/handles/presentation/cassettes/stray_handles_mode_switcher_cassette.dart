import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../application/state/stray_handle_mode_provider.dart';
import '../../infrastructure/repositories/stray_handles_provider.dart';

/// A compact segmented control for switching between stray handle triage modes.
///
/// This cassette reads and writes to [strayHandleModeSettingProvider], which
/// the list cassette watches to determine which handles to display.
class StrayHandlesModeSwitcherCassette extends ConsumerWidget {
  const StrayHandlesModeSwitcherCassette({required this.filter, super.key});

  final StrayHandleFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final currentMode = ref.watch(strayHandleModeSettingProvider);

    // Get counts for badges
    final allStraysAsync = ref.watch(strayHandlesProvider);
    final spamAsync = ref.watch(spamCandidateHandlesProvider);
    final dismissedAsync = ref.watch(dismissedHandlesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: CupertinoSegmentedControl<StrayHandleMode>(
        groupValue: currentMode,
        onValueChanged: (mode) {
          ref.read(strayHandleModeSettingProvider.notifier).setMode(mode);
        },
        padding: const EdgeInsets.all(2),
        children: {
          StrayHandleMode.allStrays: _SegmentContent(
            label: 'All',
            count: allStraysAsync.valueOrNull?.length,
            isSelected: currentMode == StrayHandleMode.allStrays,
            colors: colors,
            typography: typography,
          ),
          StrayHandleMode.spamCandidates: _SegmentContent(
            label: 'Spam',
            count: spamAsync.valueOrNull?.length,
            isSelected: currentMode == StrayHandleMode.spamCandidates,
            colors: colors,
            typography: typography,
            badgeColor: colors.accents.primary,
          ),
          StrayHandleMode.dismissed: _SegmentContent(
            label: 'Dismissed',
            count: dismissedAsync.valueOrNull?.length,
            isSelected: currentMode == StrayHandleMode.dismissed,
            colors: colors,
            typography: typography,
          ),
        },
      ),
    );
  }
}

class _SegmentContent extends StatelessWidget {
  const _SegmentContent({
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.typography,
    this.count,
    this.badgeColor,
  });

  final String label;
  final int? count;
  final bool isSelected;
  final ThemeColors colors;
  final ThemeTypography typography;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: typography.caption.copyWith(
              color: isSelected
                  ? colors.content.textPrimary
                  : colors.content.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
          if (count != null && count! > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color:
                    badgeColor?.withValues(alpha: 0.15) ??
                    colors.surfaces.hover,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: typography.caption.copyWith(
                  color: badgeColor ?? colors.content.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
