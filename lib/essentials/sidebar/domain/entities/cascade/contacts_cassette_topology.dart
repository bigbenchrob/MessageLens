part of '../cassette_spec.dart';

CassetteSpec? resolveContactsChild(ContactsCassetteSpec spec) {
  return spec.when(
    contactChooser: (chosenContactId) {
      if (chosenContactId == null) {
        return null;
      }
      // When a contact is chosen, show the selection control
      return CassetteSpec.contacts(
        ContactsCassetteSpec.contactSelectionControl(
          chosenContactId: chosenContactId,
        ),
      );
    },
    contactSelectionControl: (chosenContactId) {
      // Selection control cascades to the hero summary
      return CassetteSpec.contacts(
        ContactsCassetteSpec.contactHeroSummary(
          chosenContactId: chosenContactId,
        ),
      );
    },
    contactHeroSummary: (chosenContactId) {
      // Hero summary cascades to messages heat map
      return contactsToMessagesHeatMap(chosenContactId);
    },
  );
}

extension ContactsCassetteSpecX on ContactsCassetteSpec {
  /// Contacts cascade into a messages heatmap when a contact is selected.
  CassetteSpec? childSpec() {
    return resolveContactsChild(this);
  }
}
