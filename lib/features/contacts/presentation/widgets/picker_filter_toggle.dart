import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../application/sidebar_cassette_spec/resolver_tools/picker_filter_mode_provider.dart';

/// Segmented control that toggles the contact picker between
/// showing all contacts and showing only favourites.
class PickerFilterToggle extends ConsumerWidget {
  const PickerFilterToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(pickerFilterProvider);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoSlidingSegmentedControl<PickerFilterMode>(
          thumbColor: colors.accents.primary,
          groupValue: mode,
          children: {
            PickerFilterMode.all: _SegmentLabel(
              'All',
              isSelected: mode == PickerFilterMode.all,
              selectedColor: colors.buttons.primaryForeground,
            ),
            PickerFilterMode.favouritesOnly: _SegmentLabel(
              'Favourites',
              isSelected: mode == PickerFilterMode.favouritesOnly,
              selectedColor: colors.buttons.primaryForeground,
            ),
          },
          onValueChanged: (value) {
            if (value != null) {
              ref.read(pickerFilterProvider.notifier).setMode(value);
            }
          },
        ),
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(
    this.text, {
    required this.isSelected,
    this.selectedColor,
  });

  final String text;
  final bool isSelected;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        style: isSelected ? TextStyle(color: selectedColor) : null,
      ),
    );
  }
}
