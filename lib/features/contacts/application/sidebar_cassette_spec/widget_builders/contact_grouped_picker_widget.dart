import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../domain/spec_classes/contacts_cassette_spec.dart';
import '../../../infrastructure/repositories/contacts_list_repository.dart';
import '../../../presentation/widgets/contact_cassette_error.dart';
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
    final contactsAsync = ref.watch(
      contactsListRepositoryProvider(
        spec: const ContactsListSpec.alphabetical(),
      ),
    );

    return contactsAsync.when(
      data: (contacts) {
        return FullContactPicker(
          selectedParticipantId: chosenContactId,
          onContactSelected: (contactId) =>
              _handleContactSelection(ref, contactId),
          maxHeight: 380,
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => ContactCassetteError(
        onRetry: () {
          ref.invalidate(
            contactsListRepositoryProvider(
              spec: const ContactsListSpec.alphabetical(),
            ),
          );
        },
        message: '$error',
      ),
    );
  }

  void _handleContactSelection(WidgetRef ref, int contactId) {
    // Construct spec on user interaction (output, not interpretation)
    final newSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.contactHeroSummary(chosenContactId: contactId),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(cassetteIndex, newSpec);
  }
}
