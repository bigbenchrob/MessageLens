import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../essentials/sidebar/domain/entities/cassette_spec.dart';
import '../../domain/spec_classes/contacts_cassette_spec.dart';
import '../../infrastructure/repositories/contacts_list_repository.dart';

part 'cassette_view_model.g.dart';

@riverpod
class CassetteViewModel extends _$CassetteViewModel {
  @override
  void build() {
    // Intent-only notifier: no local state.
  }

  Future<void> updateContactSelection({
    required ContactsCassetteSpec currentSpec,
    required int? nextContactId,
  }) async {
    final updatedSpec = nextContactId == null
        ? const ContactsCassetteSpec.contactChooser()
        : ContactsCassetteSpec.contactHeroSummary(
            chosenContactId: nextContactId,
          );

    // Update sidebar cassette stack
    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .updateSpecAndChild(
          CassetteSpec.contacts(currentSpec),
          CassetteSpec.contacts(updatedSpec),
        );

    // Track this contact as recently accessed (for Recent Contacts feature)
    if (nextContactId != null) {
      final overlayDb = await ref.read(overlayDatabaseProvider.future);
      await overlayDb.trackContactAccess(nextContactId);

      // Show their messages in the center panel
      // scrolled to the most recent (scrollToDate: null means scroll to bottom)
      ref
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
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
