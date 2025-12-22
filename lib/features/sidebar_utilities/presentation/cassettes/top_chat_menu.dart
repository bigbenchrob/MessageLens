import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme.dart';
import '../../../../essentials/sidebar/feature_level_providers.dart';
import '../../domain/sidebar_utilities_constants.dart';

/// A widget representing the top menu of the sidebar. This menu allows
/// users to switch between the core sidebar utility views: Contacts,
/// Unmatched phone numbers and emails, and All messages.
///
/// This is a root-level control that defines the scope of all content below it
/// in the cassette rack hierarchy. It uses emphasized styling (heavier value
/// weight and accent-colored chevron) to signal its authoritative role.
/// When a user selects a new menu entry, the widget constructs a new
/// sidebar spec and notifies the cassette rack state provider with
/// both the old and updated specs (wrapped back into [CasetteSpec]
/// variants).
class TopChatMenu extends ConsumerWidget {
  /// The sidebar utility specification representing this top menu.  The
  /// spec contains the currently selected menu choice.  It must be a
  /// [SidebarUtilityCassetteSpec.topChatMenu] variant.
  final SidebarUtilityCassetteSpec spec;

  TopChatMenu({super.key, required this.spec})
    : assert(
        spec.maybeWhen(
          topChatMenu: (_) {
            return true;
          },
          orElse: () {
            return false;
          },
        ),
        'TopChatMenu requires a SidebarUtilityCassetteSpec.topChatMenu variant.',
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const choices = TopChatMenuChoice.values;
    final spec = this.spec;
    final selectedChoice = spec.when(topChatMenu: (choice) => choice);

    // Get accent color for chevron emphasis
    final colors = ref.watch(themeColorsProvider.notifier);

    void handleSelectionChange(TopChatMenuChoice newChoice) {
      final updatedSidebarSpec = spec.when(
        topChatMenu: (_) =>
            SidebarUtilityCassetteSpec.topChatMenu(selectedChoice: newChoice),
      );
      final oldCassetteSpec = CassetteSpec.sidebarUtility(spec);
      final newCassetteSpec = CassetteSpec.sidebarUtility(updatedSidebarSpec);
      ref
          .read(cassetteRackStateProvider.notifier)
          .updateSpecAndChild(oldCassetteSpec, newCassetteSpec);
    }

    return AppThemeWidgets.dropdownMenu<TopChatMenuChoice>(
      options: choices,
      selectedOption: selectedChoice,
      onSelected: handleSelectionChange,
      optionLabelBuilder: (choice) => choice.label,
      leadingLabel: 'Show:',
      // Emphasis styling for root-level control:
      // - Tertiary weight for "Show:" label (de-emphasized)
      // - Semibold weight for selected value (emphasized)
      // - Accent color chevron (signals authority)
      leadingLabelWeight: FontWeight.w400,
      selectedValueWeight: FontWeight.w600,
      chevronColor: colors.accents.primary,
    );
  }
}
