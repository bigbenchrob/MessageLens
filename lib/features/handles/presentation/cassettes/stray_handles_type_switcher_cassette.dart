import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/sidebar/domain/entities/cassette_spec.dart';
import '../../../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../../../essentials/sidebar/feature_level_providers.dart';
import '../../infrastructure/repositories/stray_handles_provider.dart';

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

    // Get counts for badges
    final allStraysAsync = ref.watch(strayHandlesProvider);

    // Filter counts by type
    int? filterCount(StrayHandleFilter filter) {
      final handles = allStraysAsync.valueOrNull;
      if (handles == null) {
        return null;
      }
      final filtered = switch (filter) {
        StrayHandleFilter.businessUrns =>
          handles.where((h) => h.handleValue.startsWith('urn:')),
        StrayHandleFilter.emails =>
          handles.where((h) => h.handleValue.contains('@')),
        StrayHandleFilter.phones => handles.where(
          (h) =>
              !h.handleValue.contains('@') &&
              !h.handleValue.startsWith('urn:'),
        ),
      };
      return filtered.length;
    }

    void handleFilterChange(StrayHandleFilter newFilter) {
      // Build new spec with updated filter and cascade
      final newSpec = CassetteSpec.handles(
        HandlesCassetteSpec.strayHandlesTypeSwitcher(selectedFilter: newFilter),
      );
      ref
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .replaceAtIndexAndCascade(cassetteIndex, newSpec);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: CupertinoSegmentedControl<StrayHandleFilter>(
        groupValue: selectedFilter,
        onValueChanged: handleFilterChange,
        padding: const EdgeInsets.all(2),
        children: {
          StrayHandleFilter.phones: _SegmentContent(
            label: 'Phone #',
            count: filterCount(StrayHandleFilter.phones),
            isSelected: selectedFilter == StrayHandleFilter.phones,
            colors: colors,
            typography: typography,
          ),
          StrayHandleFilter.emails: _SegmentContent(
            label: 'Email',
            count: filterCount(StrayHandleFilter.emails),
            isSelected: selectedFilter == StrayHandleFilter.emails,
            colors: colors,
            typography: typography,
          ),
          StrayHandleFilter.businessUrns: _SegmentContent(
            label: 'Business',
            count: filterCount(StrayHandleFilter.businessUrns),
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
    this.count,
  });

  final String label;
  final int? count;
  final bool isSelected;
  final ThemeColors colors;
  final ThemeTypography typography;

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
                color: colors.surfaces.hover,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: typography.caption.copyWith(
                  color: colors.content.textTertiary,
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
