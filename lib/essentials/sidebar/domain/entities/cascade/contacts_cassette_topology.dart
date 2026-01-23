part of '../cassette_spec.dart';

CassetteSpec? resolveContactsChild(ContactsCassetteSpec spec) {
  return spec.when(
    recentContacts: (chosenContactId) {
      if (chosenContactId == null) {
        return null;
      }
      return contactsToMessagesHeatMap(chosenContactId);
    },
    contactChooser: (chosenContactId) {
      if (chosenContactId == null) {
        return null;
      }
      return contactsToMessagesHeatMap(chosenContactId);
    },
    contactHeroSummary: (chosenContactId) {
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
