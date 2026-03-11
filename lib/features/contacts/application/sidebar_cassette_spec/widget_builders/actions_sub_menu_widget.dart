import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../config/theme/widgets/theme_widgets.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../../essentials/sidebar/domain/entities/cassette_spec.dart';
import '../../../../sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../domain/spec_classes/contacts_settings_spec.dart';

/// Dropdown submenu for choosing an action within Settings → Actions.
///
/// Renders a dropdown with [ActionsMenuChoice] options (Send Logs, Reimport Data).
/// On selection, replaces itself in the rack and cascades to the chosen leaf.
class ActionsSubMenuWidget extends ConsumerWidget {
  const ActionsSubMenuWidget({
    super.key,
    required this.currentChoice,
    required this.cassetteIndex,
    required this.sidebarMode,
  });

  final ActionsMenuChoice currentChoice;
  final int cassetteIndex;
  final SidebarMode sidebarMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const choices = ActionsMenuChoice.values;

    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    void handleSelectionChange(ActionsMenuChoice newChoice) {
      final newSpec = CassetteSpec.contactsSettings(
        ContactsSettingsSpec.actionsMenu(selectedChoice: newChoice),
      );

      ref
          .read(cassetteRackStateProvider(sidebarMode).notifier)
          .replaceAtIndexAndCascade(cassetteIndex, newSpec);
    }

    return AppThemeWidgets.dropdownMenu<ActionsMenuChoice>(
      options: choices,
      selectedOption: currentChoice,
      onSelected: handleSelectionChange,
      optionLabelBuilder: (choice) => choice.label,
      leadingLabel: 'Choose an action:',
      outerPadding: EdgeInsets.zero,
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
