import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../application/state/stray_handle_mode_provider.dart';

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

    // Use only vertical padding - horizontal space comes from cassette chrome
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoSegmentedControl<StrayHandleMode>(
        groupValue: currentMode,
        onValueChanged: (mode) {
          ref.read(strayHandleModeSettingProvider.notifier).setMode(mode);
        },
        padding: const EdgeInsets.all(2),
        // Use neutral gray for unselected border/separator
        unselectedColor: colors.surfaces.surface,
        borderColor: colors.lines.border,
        pressedColor: colors.surfaces.hover,
        children: {
          StrayHandleMode.allStrays: _SegmentContent(
            label: 'All',
            isSelected: currentMode == StrayHandleMode.allStrays,
            colors: colors,
            typography: typography,
          ),
          StrayHandleMode.spamCandidates: _SegmentContent(
            label: 'Spam',
            isSelected: currentMode == StrayHandleMode.spamCandidates,
            colors: colors,
            typography: typography,
          ),
          StrayHandleMode.dismissed: _SegmentContent(
            label: 'Dismissed',
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
  });

  final String label;
  final bool isSelected;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        label,
        style: typography.caption.copyWith(
          // Selected segment has blue background, so use white text
          // Unselected uses secondary text color
          color: isSelected
              ? CupertinoColors.white
              : colors.content.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}
