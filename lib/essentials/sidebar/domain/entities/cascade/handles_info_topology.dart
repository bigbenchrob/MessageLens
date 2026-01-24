part of '../cassette_spec.dart';

CassetteSpec? resolveHandlesInfoChild(HandlesInfoCassetteSpec spec) {
  return spec.when(
    infoCard: (key, childVariant) {
      // After the info card, show the appropriate handles list.
      return switch (childVariant) {
        HandlesCassetteChildVariant.strayPhoneNumbers =>
          const CassetteSpec.handles(HandlesCassetteSpec.strayPhoneNumbers()),
        HandlesCassetteChildVariant.strayEmails => const CassetteSpec.handles(
          HandlesCassetteSpec.strayEmails(),
        ),
      };
    },
  );
}

extension HandlesInfoCassetteSpecX on HandlesInfoCassetteSpec {
  CassetteSpec? childSpec() {
    return resolveHandlesInfoChild(this);
  }
}
