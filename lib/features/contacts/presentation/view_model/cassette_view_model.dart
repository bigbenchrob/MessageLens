import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../essentials/sidebar/domain/entities/cassette_spec.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../infrastructure/repositories/contacts_list_repository.dart';

part 'cassette_view_model.g.dart';

@riverpod
class CassetteViewModel extends _$CassetteViewModel {
  @override
  void build() {
    // Intent-only notifier: no local state.
  }

  void updateContactSelection({
    required ContactsCassetteSpec currentSpec,
    required int? nextContactId,
  }) {
    final updatedSpec = nextContactId == null
        ? const ContactsCassetteSpec.contactChooser()
        : ContactsCassetteSpec.contactHeroSummary(
            chosenContactId: nextContactId,
          );

    ref
        .read(cassetteRackStateProvider.notifier)
        .updateSpecAndChild(
          CassetteSpec.contacts(currentSpec),
          CassetteSpec.contacts(updatedSpec),
        );
  }

  AsyncValue<List<ContactSummary>> watchContacts({
    ContactsListSpec spec = const ContactsListSpec.alphabetical(),
  }) {
    return ref.watch(contactsListRepositoryProvider(spec: spec));
  }

  ContactSummary? findContactByParticipantId({
    required List<ContactSummary> contacts,
    required int? participantId,
  }) {
    if (participantId == null) {
      return null;
    }
    for (final contact in contacts) {
      if (contact.participantId == participantId) {
        return contact;
      }
    }
    return null;
  }
}
