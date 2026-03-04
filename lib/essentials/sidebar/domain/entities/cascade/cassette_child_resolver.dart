part of '../cassette_spec.dart';

/// Resolve the child cassette spec for the given cassette spec, if any.
///
/// This function delegates to each inner spec's `childSpec()` extension method.
/// All inner spec families define their own `childSpec()` in their topology file.
///
/// Pattern (Option A):
/// - Each inner spec type has an extension with `childSpec()`.
/// - This outer resolver simply calls `inner.childSpec()` for each variant.
/// - The `resolveXChild(innerSpec)` functions remain as implementation details
///   called only from within the inner extensions.
CassetteSpec? resolveCassetteChild(CassetteSpec spec) {
  return spec.when(
    sidebarUtility: (inner) => inner.childSpec(),
    contacts: (inner) => inner.childSpec(),
    contactsSettings: (inner) => inner.childSpec(),
    contactsInfo: (inner) => inner.childSpec(),
    handles: (inner) => inner.childSpec(),
    handlesInfo: (inner) => inner.childSpec(),
    messages: (inner) => inner.childSpec(),
  );
}
