import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

// Import the cassette rack state provider and spec definitions so the menu can notify the rack
import '../../../../config/theme.dart';
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
class TopChatMenu extends ConsumerStatefulWidget {
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
  ConsumerState<TopChatMenu> createState() => _TopChatMenuState();
}

class _TopChatMenuState extends ConsumerState<TopChatMenu> {
  bool _isOpen = false;

  void _toggleOpen() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _close() {
    if (!_isOpen) {
      return;
    }
    setState(() {
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const choices = TopChatMenuChoice.values;
    // The selected enum value is stored on the sidebar spec.  We assume the
    // spec is the topChatMenu variant; if other variants are added later, this
    // will need to be updated.
    final spec = widget.spec;
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
      _close();
    }

    final theme = MacosTheme.of(context);
    final bbc = AppTheme.bbc(context);

    final controlFill = bbc.bbcControlSurface;
    final panelFill = bbc.bbcControlPanelSurface;
    final dividerColor = bbc.bbcDivider;
    final borderColor = bbc.bbcBorderSubtle;
    final labelColor = bbc.bbcControlText;

    Widget buildTrigger() {
      return FocusableActionDetector(
        onShowFocusHighlight: (_) {},
        mouseCursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleOpen,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: controlFill,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              child: Row(
                children: [
                  Text(
                    'Show:',
                    style: theme.typography.callout.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedChoice.label,
                      style: theme.typography.callout.copyWith(
                        color: labelColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isOpen
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    size: 14,
                    color: labelColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget buildPanel() {
      return Padding(
        padding: const EdgeInsets.only(top: 6.0, right: 18.0),
        child: SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: panelFill,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final choice in choices) ...[
                  _MenuRow(
                    label: choice.label,
                    isSelected: choice == selectedChoice,
                    onTap: () {
                      handleSelectionChange(choice);
                    },
                  ),
                  if (choice != choices.last)
                    Divider(height: 1, thickness: 1, color: dividerColor),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTrigger(),
            AnimatedSize(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _isOpen ? buildPanel() : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final bbc = AppTheme.bbc(context);
    final labelColor = bbc.bbcControlText;
    final selectedFill = bbc.bbcPrimaryOne;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? selectedFill.withValues(alpha: 0.16) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.typography.callout.copyWith(
                    color: labelColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isSelected)
                Icon(CupertinoIcons.check_mark, size: 14, color: labelColor),
            ],
          ),
        ),
      ),
    );
  }
}
