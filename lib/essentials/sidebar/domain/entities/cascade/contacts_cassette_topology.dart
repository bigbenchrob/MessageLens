part of '../cassette_spec.dart';

CassetteSpec? resolveContactsChild(ContactsCassetteSpec spec) {
  return spec.when(
    contactChooser: (_) {
      // Terminal node — the info card above handles the transition
      // to contactSelectionControl when a contact is chosen.
      return null;
    },
    contactSelectionControl: (chosenContactId) {
      // Selection control sits below info card, cascades to hero summary.
      // Chain: infoCard(chosenContact) → selectionControl → heroSummary → heatMap
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
