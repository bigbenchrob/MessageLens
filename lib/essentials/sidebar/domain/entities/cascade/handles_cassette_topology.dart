part of '../cassette_spec.dart';

CassetteSpec? resolveHandlesChild(HandlesCassetteSpec spec) {
  return spec.when(
    unmatchedHandlesList: (_) => null,
    strayPhoneNumbers: () => null,
    strayEmails: () => null,
    strayHandlesReview: (_, __) => null,
    // Mode switcher cascades to the stray handles review list
    strayHandlesModeSwitcher: (filter) => CassetteSpec.handles(
      HandlesCassetteSpec.strayHandlesReview(filter: filter),
    ),
    // Type switcher cascades to the mode switcher with selected filter
    strayHandlesTypeSwitcher: (selectedFilter) => CassetteSpec.handles(
      HandlesCassetteSpec.strayHandlesModeSwitcher(filter: selectedFilter),
    ),
  );
}

extension HandlesCassetteSpecX on HandlesCassetteSpec {
  /// Resolve child spec for handles cassettes.
  CassetteSpec? childSpec() {
    return resolveHandlesChild(this);
  }
}
