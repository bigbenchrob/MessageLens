import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../essentials/db/feature_level_providers.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../application_pre_cassette/unified_picker_sections_provider.dart';
import '../../../infrastructure/repositories/recent_contacts_repository.dart';
import '../../../presentation/widgets/grouped_contact_selector.dart';

/// Widget builder for the grouped contact picker display.
///
/// This widget builder assembles the full grouped/alphabetical contact picker
/// for use when the contact count is at or above the grouping threshold.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Widget builders:
/// - Accept fully-decided inputs (not specs)
/// - May use `ref.watch()` for reactive updates
/// - Construct specs only on user interaction (output, not interpretation)
/// - Never make branching decisions about which UI to show
class ContactGroupedPickerWidget extends ConsumerWidget {
  const ContactGroupedPickerWidget({
    super.key,
    required this.chosenContactId,
    required this.cassetteIndex,
  });

  /// Currently selected contact ID, if any.
  final int? chosenContactId;

  /// Position in the cassette rack (for updates via replaceAtIndexAndCascade).
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullContactPicker(
      selectedParticipantId: chosenContactId,
      onContactSelected: (contactId) => _handleContactSelection(ref, contactId),
      maxHeight: 380,
    );
  }

  Future<void> _handleContactSelection(WidgetRef ref, int contactId) async {
    // Replace the info card (one level up) with the chosen-contact variant.
    // The info card's cascade topology will produce:
    //   infoCard(chosenContact) → selectionControl → heroSummary → heatMap
    final infoCardIndex = cassetteIndex - 1;
    final newSpec = CassetteSpec.contactsInfo(
      ContactsInfoCassetteSpec.infoCard(
        key: ContactsInfoKey.chosenContact,
        chosenContactId: contactId,
      ),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(infoCardIndex, newSpec);

    // Track contact as recently accessed (persists to overlay.db)
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    await overlayDb.trackContactAccess(contactId);
    ref.invalidate(recentContactsProvider);
    ref.invalidate(unifiedPickerSectionsProvider);
  }
}
