part of '../cassette_spec.dart';

CassetteSpec? resolveContactsInfoChild(ContactsInfoCassetteSpec spec) {
  return spec.when(
    infoCard: (key) {
      // After the info card, show the normal contact chooser.
      return const CassetteSpec.contacts(
        ContactsCassetteSpec.contactChooser(),
      );
    },
  );
}

extension ContactsInfoCassetteSpecX on ContactsInfoCassetteSpec {
  CassetteSpec? childSpec() {
    return resolveContactsInfoChild(this);
  }
}
