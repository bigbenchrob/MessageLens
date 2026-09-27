part of 'exclusive_authority_registry_provider.dart';

/// Opaque test-only handle for replaying one exact production cleanup.
///
/// This type is hidden from the feature-level production seam. Architecture
/// tests prohibit every production reference to it or its friend helper.
final class ExclusiveAuthorityScopeCleanupTestHandle {
  const ExclusiveAuthorityScopeCleanupTestHandle._({
    required ExclusiveAuthorityRegistry registry,
    required _LiveExclusiveAuthority live,
    required Object scopeIdentity,
  }) : _registry = registry,
       _live = live,
       _scopeIdentity = scopeIdentity;

  final ExclusiveAuthorityRegistry _registry;
  final _LiveExclusiveAuthority _live;
  final Object _scopeIdentity;
}

/// Test-only friend seam that reaches the production identity-checked cleanup.
final class ExclusiveAuthorityRegistryTestSupport {
  const ExclusiveAuthorityRegistryTestSupport._();

  static const instance = ExclusiveAuthorityRegistryTestSupport._();

  ExclusiveAuthorityScopeCleanupTestHandle captureOnlyActiveScope({
    required ExclusiveAuthorityRegistry registry,
    required ExclusiveAuthorityKey authority,
  }) {
    registry._requireRegistryAvailable(authority);
    final live = registry._liveAuthorities[authority];
    if (live == null) {
      throw StateError(
        'No live tenure exists for ${authority.diagnosticName}.',
      );
    }
    if (live.activeScopeIdentities.length != 1) {
      throw StateError(
        'Expected exactly one active scope for ${authority.diagnosticName}.',
      );
    }
    return ExclusiveAuthorityScopeCleanupTestHandle._(
      registry: registry,
      live: live,
      scopeIdentity: live.activeScopeIdentities.single,
    );
  }

  void replayCleanup(ExclusiveAuthorityScopeCleanupTestHandle handle) {
    handle._registry._releaseScope(
      live: handle._live,
      scopeIdentity: handle._scopeIdentity,
    );
  }
}
