part of '../cassette_spec.dart';

CassetteSpec? resolveContactsSettingsChild(ContactsSettingsSpec spec) {
  return spec.when(displayNameInfo: () => null);
}

extension ContactsSettingsSpecX on ContactsSettingsSpec {
  /// Settings specs currently have no children.
  CassetteSpec? childSpec() {
    return resolveContactsSettingsChild(this);
  }
}
