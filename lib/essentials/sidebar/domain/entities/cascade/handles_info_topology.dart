part of '../cassette_spec.dart';

CassetteSpec? resolveHandlesInfoChild(HandlesInfoCassetteSpec spec) {
  return spec.when(
    infoCard: (key, childVariant) {
      // After the info card, show the mode switcher which cascades to the list.
      return switch (childVariant) {
        HandlesCassetteChildVariant.strayPhoneNumbers =>
          const CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesModeSwitcher(
              filter: StrayHandleFilter.phones,
            ),
          ),
        HandlesCassetteChildVariant.strayEmails => const CassetteSpec.handles(
          HandlesCassetteSpec.strayHandlesModeSwitcher(
            filter: StrayHandleFilter.emails,
          ),
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
