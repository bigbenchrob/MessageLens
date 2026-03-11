part of '../cassette_spec.dart';

CassetteSpec? resolveContactsSettingsChild(ContactsSettingsSpec spec) {
  return spec.when(
    displayNameInfo: () => null,
    actionsMenu: (selectedChoice) {
      switch (selectedChoice) {
        case ActionsMenuChoice.sendLogs:
          return const CassetteSpec.contactsSettings(
            ContactsSettingsSpec.sendLogsInfo(),
          );
        case ActionsMenuChoice.reimportData:
          return const CassetteSpec.contactsSettings(
            ContactsSettingsSpec.reimportDataInfo(),
          );
      }
    },
    sendLogsInfo: () => null,
    reimportDataInfo: () => null,
  );
}

extension ContactsSettingsSpecX on ContactsSettingsSpec {
  CassetteSpec? childSpec() {
    return resolveContactsSettingsChild(this);
  }
}
