part of 'exclusive_authority_key.dart';

/// Test-only friend seam for proving independent typed authority keys.
///
/// This symbol is deliberately hidden from the feature-level production seam.
/// Architecture tests prohibit every production reference to it.
abstract final class ExclusiveAuthorityKeyTestSupport {
  static const independent = ExclusiveAuthorityKey._('testOnlyIndependent');
}
