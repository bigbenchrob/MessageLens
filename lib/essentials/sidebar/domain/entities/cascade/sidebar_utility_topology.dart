part of '../cassette_spec.dart';

CassetteSpec? resolveSidebarUtilityChild(SidebarUtilityCassetteSpec spec) {
  return spec.when(
    topChatMenu: (selectedChoice) {
      switch (selectedChoice) {
        case TopChatMenuChoice.contacts:
          return sidebarUtilityToContactsInfoCard();

        case TopChatMenuChoice.strayHandles:
          return sidebarUtilityToStrayHandlesTypeSwitcher();

        case TopChatMenuChoice.searchAllMessages:
          return sidebarUtilityToMessagesHeatMapAll();

        case TopChatMenuChoice.themePlayground:
          return sidebarUtilityToPresentationThemePlayground();
      }
    },
    settingsMenu: (selectedChoice) {
      switch (selectedChoice) {
        case SettingsMenuChoice.contacts:
          return sidebarUtilitySettingsToContactsSettings();
      }
    },
  );
}

extension SidebarUtilityCassetteSpecX on SidebarUtilityCassetteSpec {
  /// Determine the next cassette to show beneath this sidebar utility.
  CassetteSpec? childSpec() {
    return resolveSidebarUtilityChild(this);
  }
}
