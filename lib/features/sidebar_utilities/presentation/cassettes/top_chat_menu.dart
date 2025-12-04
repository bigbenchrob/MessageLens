import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Import the cassette rack state provider and spec definitions so the menu can notify the rack
import '../../../../essentials/sidebar/feature_level_providers.dart';

/// A widget representing the top menu of the sidebar.  This menu allows
/// users to switch between the core sidebar utility views: Contacts,
/// Unmatched phone numbers and emails, and All messages.  Instead of a
/// vertical list, a dropdown menu is used.  The selection state is
/// embedded in the [SidebarUtilityCassetteSpec] provided to this widget.
/// When a user selects a new menu entry, the widget constructs a new
/// sidebar spec and notifies the cassette rack state provider with
/// both the old and updated specs (wrapped back into [CasetteSpec]
/// variants).
class TopChatMenu extends ConsumerWidget {
  /// The sidebar utility specification representing this top menu.  The
  /// spec contains the currently selected menu index.  It must be a
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

  static const _menuItems = [
    'Contacts',
    'Unmatched phone numbers and emails',
    'All messages',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The selected index is stored on the sidebar spec.  We assume the
    // spec is the topChatMenu variant; if other variants are added
    // later, this will need to be updated.
    final selectedIndex = spec.when(
      topChatMenu: (chosenMenuIndex) => chosenMenuIndex,
    );

    return DropdownButton<int>(
      value: selectedIndex,
      onChanged: (int? newIndex) {
        if (newIndex == null) {
          return;
        }
        // Create an updated sidebar spec with the new index.
        final updatedSidebarSpec = spec.when(
          topChatMenu: (chosenMenuIndex) =>
              SidebarUtilityCassetteSpec.topChatMenu(chosenMenuIndex: newIndex),
        );
        // Wrap the old and new sidebar specs into CasetteSpec.sidebar so
        // that the rack update method can identify the cassette in the
        // stack and update it.  The oldSpec uses the current spec, and
        // the newSpec uses the updatedSidebarSpec.
        final oldCasetteSpec = CassetteSpec.sidebarUtility(spec);
        final newCasetteSpec = CassetteSpec.sidebarUtility(updatedSidebarSpec);
        // Notify the rack state provider of the change.
        ref
            .read(cassetteRackStateProvider.notifier)
            .updateSpecAndChild(oldCasetteSpec, newCasetteSpec);
      },
      items: List<DropdownMenuItem<int>>.generate(
        _menuItems.length,
        (index) =>
            DropdownMenuItem<int>(value: index, child: Text(_menuItems[index])),
      ),
    );
  }
}
