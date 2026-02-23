import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../../config/theme/theme_typography.dart';
import '../../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../../essentials/sidebar/domain/entities/cassette_spec.dart';
import '../../../../../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../../../../../essentials/sidebar/feature_level_providers.dart';

/// A segmented control for selecting which type of stray handles to review:
/// Phone numbers, Email addresses, or Business URNs.
///
/// This cassette sits between the menu selection and the mode switcher,
/// allowing the user to choose which handle type to triage.
class StrayHandlesTypeSwitcherCassette extends ConsumerWidget {
  const StrayHandlesTypeSwitcherCassette({
    required this.selectedFilter,
    required this.cassetteIndex,
    super.key,
  });

  final StrayHandleFilter selectedFilter;
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    void handleFilterChange(StrayHandleFilter newFilter) {
      // Build new spec with updated filter and cascade
      final newSpec = CassetteSpec.handles(
        HandlesCassetteSpec.strayHandlesTypeSwitcher(selectedFilter: newFilter),
      );
      ref
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .replaceAtIndexAndCascade(cassetteIndex, newSpec);
    }

    // Spacing constants:
    // - 12pt from top dropdown (8pt here + 4pt from naked wrapper)
    // - 20pt to "Show:" below (12pt here + 4pt wrapper + 4pt mode switcher wrapper)
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: CupertinoSegmentedControl<StrayHandleFilter>(
        groupValue: selectedFilter,
        onValueChanged: handleFilterChange,
        padding: const EdgeInsets.all(2),
        // Use neutral gray for unselected border/separator
        unselectedColor: colors.surfaces.surface,
        borderColor: colors.lines.border,
        pressedColor: colors.surfaces.hover,
        children: {
          StrayHandleFilter.phones: _SegmentContent(
            label: 'Phone #',
            isSelected: selectedFilter == StrayHandleFilter.phones,
            colors: colors,
            typography: typography,
          ),
          StrayHandleFilter.emails: _SegmentContent(
            label: 'Email',
            isSelected: selectedFilter == StrayHandleFilter.emails,
            colors: colors,
            typography: typography,
          ),
          StrayHandleFilter.businessUrns: _SegmentContent(
            label: 'Business',
            isSelected: selectedFilter == StrayHandleFilter.businessUrns,
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
