import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../sidebar_utilities/domain/sidebar_utilities_constants.dart';

class SettingsTopMenu extends ConsumerWidget {
  final SidebarUtilityCassetteSpec spec;

  SettingsTopMenu({super.key, required this.spec})
    : assert(
        spec.maybeWhen(settingsMenu: (_) => true, orElse: () => false),
        'SettingsTopMenu requires a SidebarUtilityCassetteSpec.settingsMenu variant.',
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    const choices = SettingsMenuChoice.values;
    final selectedChoice = spec.when(
      settingsMenu: (choice) => choice,
      topChatMenu: (_) => SettingsMenuChoice.contacts, // Should not happen
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

    return AppThemeWidgets.dropdownMenu<SettingsMenuChoice>(
      options: choices,
      selectedOption: selectedChoice,
      onSelected: handleSelection,
      optionLabelBuilder: (choice) => choice.label,
      // Naked card wrapper provides 12px horizontal margin
      outerPadding: EdgeInsets.zero,
      // Match card internal padding: 12px left for text alignment
      triggerPadding: const EdgeInsets.only(
        left: 12.0,
        right: 16.0,
        top: 10.0,
        bottom: 10.0,
      ),
      selectedValueStyle: typography.controlValue,
      chevronColor: colors.accents.primary,
      chevronBackgroundColor: colors.accents.primary.withValues(alpha: 0.12),
    );
  }
}
