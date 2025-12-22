import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../application_pre_cassette/contacts_list_provider.dart';
import '../widgets/flat_contacts_list.dart';
import 'contact_cassette_helpers.dart';

class ContactsFlatMenuCassette extends ConsumerWidget {
  const ContactsFlatMenuCassette({
    required this.spec,
    required this.contacts,
    super.key,
  });

  final ContactsCassetteSpec spec;
  final List<ContactSummary> contacts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Extract chosenContactId using pattern matching
    final selectedContactId = spec.when(
      contactChooser: (id) => id,
      contactHeroSummary: (id) => id,
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      child: FlatContactsList(
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
    );
  }
}
