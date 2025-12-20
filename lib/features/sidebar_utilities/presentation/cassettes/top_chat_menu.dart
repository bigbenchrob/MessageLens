import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Import the cassette rack state provider and spec definitions so the menu can notify the rack
import '../../../../config/theme/theme.dart';
import '../../../../essentials/sidebar/feature_level_providers.dart';
import '../../domain/sidebar_utilities_constants.dart';

/// A widget representing the top menu of the sidebar.  This menu allows
/// users to switch between the core sidebar utility views: Contacts,
/// Unmatched phone numbers and emails, and All messages.  Instead of a
/// vertical list, an in-cassette expandable menu is used.  The selection state is
/// embedded in the [SidebarUtilityCassetteSpec] provided to this widget.
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
    // The selected enum value is stored on the sidebar spec.  We assume the
    // spec is the topChatMenu variant; if other variants are added later, this
    // will need to be updated.
    final spec = this.spec;
    final selectedChoice = spec.when(topChatMenu: (choice) => choice);

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
    );
  }
}
