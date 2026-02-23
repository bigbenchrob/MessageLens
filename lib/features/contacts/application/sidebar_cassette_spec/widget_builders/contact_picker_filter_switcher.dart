import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../../config/theme/theme_typography.dart';
import '../../state/contact_picker_filter_provider.dart';

/// A segmented control for filtering contacts in the picker:
/// Favourites only or All contacts.
class ContactPickerFilterSwitcher extends ConsumerWidget {
  const ContactPickerFilterSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final currentMode = ref.watch(contactPickerFilterProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CupertinoSegmentedControl<ContactPickerFilterMode>(
        groupValue: currentMode,
        onValueChanged: (mode) {
          ref.read(contactPickerFilterProvider.notifier).setMode(mode);
        },
        padding: const EdgeInsets.all(2),
        unselectedColor: colors.surfaces.surface,
        borderColor: colors.lines.border,
        pressedColor: colors.surfaces.hover,
        children: {
          ContactPickerFilterMode.favorites: _SegmentContent(
            label: 'Favourites',
            isSelected: currentMode == ContactPickerFilterMode.favorites,
            colors: colors,
            typography: typography,
          ),
          ContactPickerFilterMode.all: _SegmentContent(
            label: 'All Contacts',
            isSelected: currentMode == ContactPickerFilterMode.all,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
