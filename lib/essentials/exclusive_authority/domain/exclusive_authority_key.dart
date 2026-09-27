part 'exclusive_authority_key_test_support.dart';

/// Closed typed name for one process-local exclusive authority.
final class ExclusiveAuthorityKey {
  const ExclusiveAuthorityKey._(this.diagnosticName);

  /// Exclusive authority for admitted archive mutation.
  static const archiveMutation = ExclusiveAuthorityKey._('archiveMutation');

  /// Stable human-readable name for bounded diagnostics only.
  final String diagnosticName;
}
