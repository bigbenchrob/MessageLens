import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../sidebar_utilities/domain/sidebar_utilities_constants.dart';

class SettingsMenuCassette extends ConsumerWidget {
  final SidebarUtilityCassetteSpec spec;

  const SettingsMenuCassette({super.key, required this.spec});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    final selectedChoice = spec.when(
      topChatMenu: (_) => SettingsMenuChoice.general, // Should not happen
      settingsMenu: (choice) => choice,
    );

    void handleSelection(SettingsMenuChoice choice) {
      final updatedSpec = SidebarUtilityCassetteSpec.settingsMenu(
        selectedChoice: choice,
      );
      final oldCassetteSpec = CassetteSpec.sidebarUtility(spec);
      final newCassetteSpec = CassetteSpec.sidebarUtility(updatedSpec);

      ref
          .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
          .updateSpecAndChild(oldCassetteSpec, newCassetteSpec);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingsItem(
          title: 'Contact Short Names',
          icon: CupertinoIcons.person_crop_circle,
          isSelected: selectedChoice == SettingsMenuChoice.contactShortNames,
          onTap: () => handleSelection(SettingsMenuChoice.contactShortNames),
          colors: colors,
          typography: typography,
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.colors,
    required this.typography,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? colors.surfaces.control.withValues(alpha: 0.1)
        : null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              bottom: BorderSide(color: colors.lines.borderSubtle, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: colors.accents.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: typography.body)),
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: colors.accents.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
