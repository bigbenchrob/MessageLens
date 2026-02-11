part of '../../cassette_spec.dart';

CassetteSpec sidebarUtilityToContactsInfoCard() {
  return const CassetteSpec.contactsInfo(
    ContactsInfoCassetteSpec.infoCard(key: ContactsInfoKey.favouritesVsRecents),
  );
}

CassetteSpec sidebarUtilityToHandlesInfoCardForStrayEmails() {
  return const CassetteSpec.handlesInfo(
    HandlesInfoCassetteSpec.infoCard(
      key: HandlesInfoKey.strayEmailsExplanation,
      childVariant: HandlesCassetteChildVariant.strayEmails,
    ),
  );
}

CassetteSpec sidebarUtilityToHandlesStrayPhoneNumbers() {
  return const CassetteSpec.handles(
    HandlesCassetteSpec.strayHandlesReview(filter: StrayHandleFilter.phones),
  );
}

CassetteSpec sidebarUtilityToMessagesHeatMapAll() {
  return const CassetteSpec.messages(
    MessagesCassetteSpec.heatMap(contactId: null),
  );
}

CassetteSpec sidebarUtilityToPresentationThemePlayground() {
  return const CassetteSpec.presentation(
    PresentationCassetteSpec.themePlayground(),
  );
}

CassetteSpec sidebarUtilitySettingsToContactsSettings() {
  return const CassetteSpec.contactsSettings(
    ContactsSettingsSpec.displayNameInfo(),
  );
}
