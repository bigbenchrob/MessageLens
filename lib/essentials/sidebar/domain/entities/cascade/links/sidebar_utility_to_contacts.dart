part of '../../cassette_spec.dart';

CassetteSpec sidebarUtilityToContactsInfoCard() {
  return const CassetteSpec.contactsInfo(
    ContactsInfoCassetteSpec.infoCard(
      key: ContactsInfoKey.favouritesVsRecents,
    ),
  );
}

CassetteSpec sidebarUtilityToHandlesInfoCardForStrayEmails() {
  return const CassetteSpec.handles(
    HandlesCassetteSpec.infoCard(
      message:
          'These are messages from email addresses that do not '
          'belong to a contact in your address book.',
      childVariant: HandlesCassetteChildVariant.strayEmails,
    ),
  );
}

CassetteSpec sidebarUtilityToHandlesStrayPhoneNumbers() {
  return const CassetteSpec.handles(
    HandlesCassetteSpec.strayPhoneNumbers(),
  );
}

CassetteSpec sidebarUtilityToMessagesHeatMapAll() {
  return const CassetteSpec.messages(
    MessagesCassetteSpec.heatMap(
      contactId: null,
      useV2Timeline: true,
    ),
  );
}

CassetteSpec sidebarUtilityToPresentationThemePlayground() {
  return const CassetteSpec.presentation(
    PresentationCassetteSpec.themePlayground(),
  );
}

CassetteSpec sidebarUtilitySettingsToContactsSettings() {
  return const CassetteSpec.contactsSettings(
    ContactsSettingsSpec.shortNames(),
  );
}
