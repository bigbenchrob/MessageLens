import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
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

    // Update sidebar cassette stack
    ref
        .read(cassetteRackStateProvider.notifier)
        .updateSpecAndChild(
          CassetteSpec.contacts(currentSpec),
          CassetteSpec.contacts(updatedSpec),
        );

    // When a contact is selected, show their messages in the center panel
    // scrolled to the most recent (scrollToDate: null means scroll to bottom)
    if (nextContactId != null) {
      ref
          .read(panelsViewStateProvider.notifier)
          .show(
            panel: WindowPanel.center,
            spec: ViewSpec.messages(
              MessagesSpec.forContact(
                contactId: nextContactId,
                scrollToDate: null,
              ),
            ),
          );
    }
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
