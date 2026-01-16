import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
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
  /// spec contains the currently selected menu choice.
  final SidebarUtilityCassetteSpec spec;

  const TopChatMenu({super.key, required this.spec});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const choices = TopChatMenuChoice.values;
    final selectedChoice = spec.when(topChatMenu: (choice) => choice);

    // Get accent color for chevron emphasis
    final colors = ref.watch(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    void handleSelectionChange(TopChatMenuChoice newChoice) {
      final updatedSidebarSpec = SidebarUtilityCassetteSpec.topChatMenu(
        selectedChoice: newChoice,
      );
      final oldCassetteSpec = CassetteSpec.sidebarUtility(spec);
      final newCassetteSpec = CassetteSpec.sidebarUtility(updatedSidebarSpec);
      ref
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .updateSpecAndChild(oldCassetteSpec, newCassetteSpec);
    }

    return AppThemeWidgets.dropdownMenu<TopChatMenuChoice>(
      options: choices,
      selectedOption: selectedChoice,
      onSelected: handleSelectionChange,
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
      // Typography tokens for control header hierarchy:
      // - controlValue for selected option (confident, primary)
      // - Brand-tinted chevron background for intentional feel
      selectedValueStyle: typography.controlValue,
      chevronColor: colors.accents.primary,
      chevronBackgroundColor: colors.accents.primary.withValues(alpha: 0.12),
    );
  }
}
