import 'exclusive_authority_key.dart';

enum ExclusiveAuthorityProofDenialReason {
  wrongAuthority,
  foreignRegistry,
  staleOrReleased,
  registryDisposed,
}

/// Denial because an opaque tenure does not prove current authority.
final class ExclusiveAuthorityProofDeniedException implements Exception {
  const ExclusiveAuthorityProofDeniedException({
    required this.authority,
    required this.tenureAuthority,
    required this.reason,
  });

  final ExclusiveAuthorityKey authority;
  final ExclusiveAuthorityKey tenureAuthority;
  final ExclusiveAuthorityProofDenialReason reason;

  @override
  String toString() {
    return 'Exclusive authority proof denied for '
        '${authority.diagnosticName}: ${reason.name}.';
  }
}
