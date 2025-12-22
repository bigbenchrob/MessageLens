import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../infrastructure/repositories/contacts_list_repository.dart';
import '../view_model/cassette_view_model.dart';
import '../widgets/contact_cassette_error.dart';
import '../widgets/contact_highlight_row.dart';

class ContactHeroSummaryCassette extends ConsumerWidget {
  const ContactHeroSummaryCassette({required this.spec, super.key});

  final ContactsCassetteSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const listSpec = ContactsListSpec.alphabetical();
    final contactsAsync = ref
        .watch(cassetteViewModelProvider.notifier)
        .watchContacts(spec: listSpec);

    final selectedContactId = spec.maybeWhen(
      contactHeroSummary: (chosenContactId) => chosenContactId,
      orElse: () => null,
    );

    return contactsAsync.when(
      data: (contacts) {
        final selectedContact = ref
            .read(cassetteViewModelProvider.notifier)
            .findContactByParticipantId(
              contacts: contacts,
              participantId: selectedContactId,
            );

        if (selectedContactId == null || selectedContact == null) {
          return const Text('Selected contact not found.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ContactHeroHeaderHighlight(
              displayName: selectedContact.displayName,
              shortName: selectedContact.shortName,
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
}
