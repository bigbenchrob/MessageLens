part of '../cassette_spec.dart';

CassetteSpec? resolveHandlesChild(HandlesCassetteSpec spec) {
  return spec.when(
    unmatchedHandlesList: (_) => null,
    infoCard: (_, __, ___, childVariant) {
      return switch (childVariant) {
        HandlesCassetteChildVariant.strayPhoneNumbers =>
          const CassetteSpec.handles(HandlesCassetteSpec.strayPhoneNumbers()),
        HandlesCassetteChildVariant.strayEmails => const CassetteSpec.handles(
          HandlesCassetteSpec.strayEmails(),
        ),
      };
    },
    strayPhoneNumbers: () => null,
    strayEmails: () => null,
  );
}

extension HandlesCassetteSpecX on HandlesCassetteSpec {
  /// Resolve child spec for handles cassettes.
  CassetteSpec? childSpec() {
    return resolveHandlesChild(this);
  }
}
