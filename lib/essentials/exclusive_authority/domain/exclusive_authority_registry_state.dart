import 'exclusive_authority_key.dart';

/// Immutable, non-authoritative diagnostic view of one authority key.
final class ExclusiveAuthorityDiagnostic {
  const ExclusiveAuthorityDiagnostic({
    required this.authority,
    this.isHeld = false,
    this.tenureOccurrence,
    this.ownerLabel,
    this.acquiredAtUtc,
    this.holdCount = 0,
    this.lastDeniedOwnerLabel,
    this.lastDeniedAtUtc,
    this.deniedRequests = 0,
    this.lastReleasedAtUtc,
  });

  final ExclusiveAuthorityKey authority;
  final bool isHeld;
  final int? tenureOccurrence;
  final String? ownerLabel;
  final DateTime? acquiredAtUtc;
  final int holdCount;
  final String? lastDeniedOwnerLabel;
  final DateTime? lastDeniedAtUtc;
  final int deniedRequests;
  final DateTime? lastReleasedAtUtc;
}

/// Immutable diagnostics for all authority keys observed by one registry.
///
/// These values describe occupancy. They never grant or prove authority.
final class ExclusiveAuthorityRegistryState {
  ExclusiveAuthorityRegistryState({
    Map<ExclusiveAuthorityKey, ExclusiveAuthorityDiagnostic> diagnostics =
        const {},
  }) : diagnostics = Map.unmodifiable(diagnostics);

  final Map<ExclusiveAuthorityKey, ExclusiveAuthorityDiagnostic> diagnostics;

  ExclusiveAuthorityDiagnostic diagnosticFor(ExclusiveAuthorityKey authority) {
    return diagnostics[authority] ??
        ExclusiveAuthorityDiagnostic(authority: authority);
  }
}
