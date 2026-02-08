part of '../cassette_spec.dart';

CassetteSpec? resolveContactsInfoChild(ContactsInfoCassetteSpec spec) {
  return spec.when(
    infoCard: (key, chosenContactId) {
      switch (key) {
        case ContactsInfoKey.favouritesVsRecents:
          // No contact chosen yet — show the contact picker.
          return const CassetteSpec.contacts(
            ContactsCassetteSpec.contactChooser(),
          );
        case ContactsInfoKey.chosenContact:
          // Contact chosen — selection control is embedded in the info card.
          // Info card cascades directly to hero summary.
          // Chain: infoCard(chosenContact) → heroSummary → heatMap
          return CassetteSpec.contacts(
            ContactsCassetteSpec.contactHeroSummary(
              chosenContactId: chosenContactId!,
            ),
          );
      }
    },
  );
}

extension ContactsInfoCassetteSpecX on ContactsInfoCassetteSpec {
  CassetteSpec? childSpec() {
    return resolveContactsInfoChild(this);
  }
}
