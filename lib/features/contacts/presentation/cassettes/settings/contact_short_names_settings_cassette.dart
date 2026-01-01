import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';

class ContactShortNamesSettingsCassette extends ConsumerWidget {
  const ContactShortNamesSettingsCassette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Short Name Format',
          style: typography.vizInstruction.copyWith(
            color: colors.content.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        _OptionRow(
          label: 'First Name Only',
          isSelected: true,
          colors: colors,
          typography: typography,
        ),
        _OptionRow(
          label: 'First Initial & Last Name',
          isSelected: false,
          colors: colors,
          typography: typography,
        ),
        _OptionRow(
          label: 'Nickname',
          isSelected: false,
          colors: colors,
          typography: typography,
        ),
        const SizedBox(height: 16),
        Text(
          'Prefer nicknames when available.',
          style: typography.caption.copyWith(
            color: colors.content.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            isSelected
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            size: 18,
            color: isSelected ? colors.accents.primary : colors.lines.border,
          ),
          const SizedBox(width: 10),
          Text(label, style: typography.body),
        ],
      ),
    );
  }
}
