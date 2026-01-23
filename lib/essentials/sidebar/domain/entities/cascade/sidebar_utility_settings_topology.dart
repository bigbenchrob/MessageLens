part of '../cassette_spec.dart';

CassetteSpec? resolveSidebarUtilitySettingsChild(
  SidebarUtilitySettingsSpec spec,
) {
  return spec.when(
    settingsMenu: (selectedChoice) {
      switch (selectedChoice) {
        case SettingsMenuChoice.contacts:
          return sidebarUtilitySettingsToContactsSettings();
      }
    },
  );
}

extension SidebarUtilitySettingsSpecX on SidebarUtilitySettingsSpec {
  /// Determine the next cassette to show beneath this settings utility.
  CassetteSpec? childSpec() {
    return resolveSidebarUtilitySettingsChild(this);
  }
}
