part of '../cassette_spec.dart';

CassetteSpec? resolveSidebarUtilityChild(SidebarUtilityCassetteSpec spec) {
  return spec.when(
    topChatMenu: (selectedChoice) {
      switch (selectedChoice) {
        case TopChatMenuChoice.contacts:
          return sidebarUtilityToContactsInfoCard();

        case TopChatMenuChoice.strayHandles:
          return sidebarUtilityToStrayHandlesTypeSwitcher();

        case TopChatMenuChoice.recoveredUnlinkedMessages:
          return sidebarUtilityToRecoveredUnlinkedNavigator();

        case TopChatMenuChoice.recoveredNoHandleFromMeMessages:
          return sidebarUtilityToRecoveredNoHandleFromMeNavigator();

        case TopChatMenuChoice.searchAllMessages:
          return sidebarUtilityToMessagesHeatMapAll();
      }
    },
    settingsMenu: (selectedChoice) {
      switch (selectedChoice) {
        case SettingsMenuChoice.actions:
          return sidebarUtilitySettingsToActionsMenu();
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
