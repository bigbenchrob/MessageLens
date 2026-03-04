part of '../../cassette_spec.dart';

CassetteSpec sidebarUtilityToContactsInfoCard() {
  return const CassetteSpec.contactsInfo(
    ContactsInfoCassetteSpec.infoCard(key: ContactsInfoKey.favouritesVsRecents),
  );
}

/// Cascade from "From unfamiliar sources" menu to stray handles type switcher.
CassetteSpec sidebarUtilityToStrayHandlesTypeSwitcher() {
  return const CassetteSpec.handles(
    HandlesCassetteSpec.strayHandlesTypeSwitcher(),
  );
}

CassetteSpec sidebarUtilityToMessagesHeatMapAll() {
  return const CassetteSpec.messages(
    MessagesCassetteSpec.heatMap(contactId: null),
  );
}

CassetteSpec sidebarUtilitySettingsToContactsSettings() {
  return const CassetteSpec.contactsSettings(
    ContactsSettingsSpec.displayNameInfo(),
  );
}
