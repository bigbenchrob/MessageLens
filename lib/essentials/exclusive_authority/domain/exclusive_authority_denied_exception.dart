import 'exclusive_authority_key.dart';

/// Immediate denial because another tenure already holds the authority.
final class ExclusiveAuthorityDeniedException implements Exception {
  const ExclusiveAuthorityDeniedException({
    required this.authority,
    required this.requestedOwnerLabel,
    required this.currentOwnerLabel,
  });

  final ExclusiveAuthorityKey authority;
  final String requestedOwnerLabel;
  final String currentOwnerLabel;

  @override
  String toString() {
    return 'Exclusive authority denied: $requestedOwnerLabel requested '
        '${authority.diagnosticName} while $currentOwnerLabel held it.';
  }
}
