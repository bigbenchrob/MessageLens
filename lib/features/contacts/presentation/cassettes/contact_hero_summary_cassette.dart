import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../application_pre_cassette/contacts_list_provider.dart';
import 'contact_cassette_helpers.dart';

class ContactHeroSummaryCassette extends ConsumerWidget {
  const ContactHeroSummaryCassette({required this.spec, super.key});

  final ContactsCassetteSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(
      contactsListProvider(spec: const ContactsListSpec.alphabetical()),
    );

    final selectedContactId = spec.maybeWhen(
      contactHeroSummary: (chosenContactId) => chosenContactId,
      orElse: () => null,
    );

    return contactsAsync.when(
      data: (contacts) {
        final selectedContact = findContact(
          contacts: contacts,
          participantId: selectedContactId,
        );

        if (selectedContactId == null || selectedContact == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selected contact not found.'),
              const SizedBox(height: 8),
              PushButton(
                controlSize: ControlSize.small,
                onPressed: () {
                  updateContactSelection(
                    ref: ref,
                    currentSpec: spec,
                    nextContactId: null,
                  );
                },
                child: const Text('Choose another contact'),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectedContactSummary(contact: selectedContact),
            const SizedBox(height: 8),
            PushButton(
              controlSize: ControlSize.small,
              onPressed: () {
                updateContactSelection(
                  ref: ref,
                  currentSpec: spec,
                  nextContactId: null,
                );
              },
              child: const Text('Choose another contact'),
            ),
          ],
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => ContactCassetteError(
        onRetry: () {
          ref.invalidate(
            contactsListProvider(spec: const ContactsListSpec.alphabetical()),
          );
        },
        message: '$error',
      ),
    );
  }
}
