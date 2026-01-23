part of '../cassette_spec.dart';

CassetteSpec? resolveCassetteChild(CassetteSpec spec) {
  return spec.when(
    sidebarUtility: resolveSidebarUtilityChild,
    sidebarUtilitySettings: resolveSidebarUtilitySettingsChild,
    presentation: (presentationSpec) => presentationSpec.childSpec(),
    contacts: resolveContactsChild,
    contactsSettings: resolveContactsSettingsChild,
    contactsInfo: resolveContactsInfoChild,
    handles: resolveHandlesChild,
    messages: resolveMessagesChild,
  );
}
