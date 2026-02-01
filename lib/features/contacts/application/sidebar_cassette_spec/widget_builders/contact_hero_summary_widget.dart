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
import '../../../presentation/widgets/contact_highlight_row.dart';

/// Widget builder for the contact hero summary cassette.
///
/// Displays detailed information about a selected contact with an option
/// to clear the selection and return to the contact chooser.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Widget builders:
/// - Accept fully-decided inputs (not specs)
/// - May use `ref.watch()` for reactive updates
/// - Construct specs only on user interaction (output, not interpretation)
class ContactHeroSummaryWidget extends ConsumerWidget {
  const ContactHeroSummaryWidget({
    super.key,
    required this.contactId,
    required this.cassetteIndex,
  });

  /// The ID of the contact to display.
  final int contactId;

  /// Position in the cassette rack (for updates via replaceAtIndexAndCascade).
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const listSpec = ContactsListSpec.alphabetical();
    final contactsAsync = ref.watch(
      contactsListRepositoryProvider(spec: listSpec),
    );

    return contactsAsync.when(
      data: (contacts) {
        final selectedContact = _findContactById(contacts, contactId);

        if (selectedContact == null) {
          return const Text('Selected contact not found.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ContactHeroHeaderHighlight(
              displayName: selectedContact.displayName,
              shortName: selectedContact.shortName,
              summaryLine: _buildSummaryLine(selectedContact),
              onChange: () => _clearSelection(ref),
            ),
          ],
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => ContactCassetteError(
        onRetry: () {
          ref.invalidate(contactsListRepositoryProvider(spec: listSpec));
        },
        message: '$error',
      ),
    );
  }

  ContactSummary? _findContactById(List<ContactSummary> contacts, int id) {
    for (final contact in contacts) {
      if (contact.participantId == id) {
        return contact;
      }
    }
    return null;
  }

  void _clearSelection(WidgetRef ref) {
    // Construct a contact chooser spec with no selection
    const newSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.contactChooser(),
    );

    // Update the cassette rack using the index
    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(cassetteIndex, newSpec);
  }
}

/// Builds a human-readable summary line for the contact.
String _buildSummaryLine(ContactSummary contact) {
  final chatLabel = contact.totalChats == 1 ? 'chat' : 'chats';
  final messageLabel = contact.totalMessages == 1 ? 'message' : 'messages';
  return '${contact.totalChats} $chatLabel · ${contact.totalMessages} $messageLabel';
}
