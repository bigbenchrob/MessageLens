part of '../cassette_spec.dart';

CassetteSpec? resolveHandlesChild(HandlesCassetteSpec spec) {
  return spec.when(
    unmatchedHandlesList: (_) => null,
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
