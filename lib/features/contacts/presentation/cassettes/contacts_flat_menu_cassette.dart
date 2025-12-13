import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../application_pre_cassette/contacts_list_provider.dart';
import '../widgets/flat_contacts_list.dart';
import 'contact_cassette_helpers.dart';

class ContactsFlatMenuCassette extends ConsumerWidget {
  const ContactsFlatMenuCassette({required this.spec, super.key});

  final ContactsCassetteSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(
      contactsListProvider(spec: const ContactsListSpec.alphabetical()),
    );

    final selectedContactId = spec.chosenContactId;

    return contactsAsync.when(
      data: (contacts) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FlatContactsList(
              contacts: contacts,
              selectedParticipantId: selectedContactId,
              onContactSelected: (contactId) {
                updateContactSelection(
                  ref: ref,
                  currentSpec: spec,
                  nextContactId: contactId,
                );
              },
            ),
            if (selectedContactId != null) ...[
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
                child: const Text('Clear selection'),
              ),
            ],
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
