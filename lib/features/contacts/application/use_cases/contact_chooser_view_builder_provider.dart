import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      return asyncRecents.when(
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
    final typography = MacosTheme.of(context).typography;

    final selectedContactId = spec.when(
      recentContacts: (id) => id,
      contactChooser: (id) => id,
      contactHeroSummary: (id) => id,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate height for each recent contact row (padding + text)
        const recentRowHeight = 41.0; // 10 vertical padding * 2 + text height
        const dividerHeight = 8.0;
        final recentsHeight = recents.length * recentRowHeight;
        final totalRecentsHeight = recentsHeight + 
            (recents.isNotEmpty ? dividerHeight : 0);
        
        // Calculate remaining height for main picker
        final availableHeight = constraints.maxHeight;
        final mainPickerHeight = availableHeight - totalRecentsHeight;

        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recent contacts section (always visible, no collapsing)
            ...recents.map((recent) {
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
                typography: typography,
                colors: bbc,
              );
            }),

            // Divider between recent and all contacts
            if (recents.isNotEmpty)
              Container(
                height: dividerHeight,
                color: bbc.bbcBorderSubtle.withValues(alpha: 0.3),
              ),

            // Full contact picker below - expands to fill remaining space
            SizedBox(
              height: mainPickerHeight,
              child: mainPicker,
            ),
          ],
        );
      },
    );
  }
}

/// Row widget for a recent contact in the combined picker.
class _RecentContactRow extends StatelessWidget {
  const _RecentContactRow({
    required this.displayName,
    required this.participantId,
    required this.isSelected,
    required this.onTap,
    required this.typography,
    required this.colors,
  });

  final String displayName;
  final int participantId;
  final bool isSelected;
  final VoidCallback onTap;
  final MacosTypography typography;
  final BbcColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.bbcPrimaryOne.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: colors.bbcBorderSubtle, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: typography.body.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.checkmark_alt,
                size: 14,
                color: colors.bbcPrimaryOne,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
