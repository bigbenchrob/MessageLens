import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme.dart';
import '../../../../constants/domain/contact_constants.dart';
import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../application/recent_contacts_provider.dart';
import '../../application_pre_cassette/contact_picker_mode.dart';
import '../../infrastructure/repositories/contacts_list_repository.dart';
import '../../presentation/cassettes/contacts_enhanced_picker_cassette.dart';
import '../../presentation/cassettes/contacts_flat_menu_cassette.dart';
import '../../presentation/view_model/cassette_view_model.dart';

part 'contact_chooser_view_builder_provider.g.dart';

/// Debug flag for temporarily forcing the flat chooser.
///
/// Keep `false` for normal behavior.
const bool _forceFlatContactChooser = false;

/// Resolves which contact picker widget to display based on contact count.
///
/// This provider determines whether to show a flat list or grouped picker
/// by checking the total contact count against [kContactPickerGroupingThreshold].
/// Recent contacts (max 6) are always shown at the top if any exist.
@riverpod
Widget contactChooserViewBuilder(Ref ref, ContactsCassetteSpec spec) {
  final maintenanceLocked = ref.watch(dbMaintenanceLockProvider);
  if (maintenanceLocked) {
    debugPrint('ContactChooser: maintenance lock active (skipping load)');
    return const Center(child: ProgressCircle());
  }

  final asyncContacts = ref.watch(
    contactsListRepositoryProvider(spec: const ContactsListSpec.alphabetical()),
  );
  final asyncRecents = ref.watch(recentContactsProvider);

  return asyncContacts.when(
    data: (contacts) {
      final config = resolveContactPickerConfig(contacts.length);

      // Build the main picker widget
      Widget mainPicker;
      if (_forceFlatContactChooser) {
        mainPicker = ContactsFlatMenuCassette(spec: spec, contacts: contacts);
      } else {
        mainPicker = switch (config.mode) {
          ContactPickerMode.flat => ContactsFlatMenuCassette(
            spec: spec,
            contacts: contacts,
          ),
          ContactPickerMode.grouped => ContactsEnhancedPickerCassette(
            spec: spec,
          ),
        };
      }

      // Wrap with recent contacts section if any exist
      // Use LayoutBuilder to provide proper constraints for responsive height
      return LayoutBuilder(
        builder: (context, constraints) {
          final child = asyncRecents.when(
            data: (recents) {
              if (recents.isEmpty) {
                return mainPicker;
              }
              return _CombinedContactPicker(
                spec: spec,
                recents: recents,
                mainPicker: mainPicker,
              );
            },
            loading: () => mainPicker, // Show main picker while recents load
            error: (_, __) => mainPicker, // Show main picker if recents fail
          );

          if (constraints.hasBoundedHeight) {
            return SizedBox(height: constraints.maxHeight, child: child);
          }

          // If the parent doesn't provide a bounded height (e.g. inside a
          // scrollable), give the picker a reasonable fixed height so internal
          // Expanded widgets receive constraints.
          return SizedBox(height: 400, child: child);
        },
      );
    },
    loading: () {
      return const Center(child: ProgressCircle());
    },
    error: (error, stack) {
      debugPrint('ContactChooser error: $error');
      return Center(
        child: Text(
          'Error loading contacts: $error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    },
  );
}

/// Combined picker showing recent contacts at top (max 6) and full picker below.
/// Uses LayoutBuilder to adapt to available sidebar height and respond to window resizing.
class _CombinedContactPicker extends ConsumerWidget {
  const _CombinedContactPicker({
    required this.spec,
    required this.recents,
    required this.mainPicker,
  });

  final ContactsCassetteSpec spec;
  final List<RecentContactSummary> recents;
  final Widget mainPicker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bbc = AppTheme.bbc(context);

    final selectedContactId = spec.when(
      recentContacts: (id) => id,
      contactChooser: (id) => id,
      contactHeroSummary: (id) => id,
    );

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Recent contacts section (always visible, no collapsing)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: recents.map((recent) {
              final isSelected = recent.participantId == selectedContactId;
              return _RecentContactRow(
                displayName: recent.displayName,
                participantId: recent.participantId,
                isSelected: isSelected,
                onTap: () {
                  ref
                      .read(cassetteViewModelProvider.notifier)
                      .updateContactSelection(
                        currentSpec: spec,
                        nextContactId: recent.participantId,
                      );
                },
              );
            }).toList(),
          ),
        ),

        // Divider between recent and all contacts: subtle theme line
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 14),
          child: Container(
            height: 1,
            color: bbc.bbcBorderSubtle.withValues(alpha: 0.8),
          ),
        ),

        // Full contact picker below - fills remaining height
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: mainPicker,
          ),
        ),
      ],
    );
  }
}

/// Row widget for a recent contact in the combined picker.
class _RecentContactRow extends ConsumerStatefulWidget {
  const _RecentContactRow({
    required this.displayName,
    required this.participantId,
    required this.isSelected,
    required this.onTap,
  });

  final String displayName;
  final int participantId;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  ConsumerState<_RecentContactRow> createState() => _RecentContactRowState();
}

class _RecentContactRowState extends ConsumerState<_RecentContactRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final bbc = AppTheme.bbc(context);

    final hoverColor = colors.accents.primary.withValues(alpha: 0.15);
    final selectedColor = bbc.bbcPrimaryOne.withValues(alpha: 0.12);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? selectedColor
                : _isHovered
                ? hoverColor
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: bbc.bbcBorderSubtle, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.displayName,
                  style: theme.typography.body.copyWith(
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                Icon(
                  CupertinoIcons.checkmark_alt,
                  size: 14,
                  color: bbc.bbcPrimaryOne,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
