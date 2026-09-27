import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/exclusive_authority_denied_exception.dart';
import '../domain/exclusive_authority_key.dart';
import '../domain/exclusive_authority_proof_denied_exception.dart';
import '../domain/exclusive_authority_registry_state.dart';

part 'exclusive_authority_registry_provider.g.dart';
part 'exclusive_authority_registry_test_support.dart';

/// Opaque, occurrence-unique proof issued only by [ExclusiveAuthorityRegistry].
///
/// Visible fields are diagnostics only. Currentness is always established by
/// asking the originating registry.
final class ExclusiveAuthorityTenure {
  ExclusiveAuthorityTenure._({
    required this.authority,
    required this.diagnosticOccurrence,
    required this.issuedAtUtc,
    required Object registryIdentity,
    required Object tenureIdentity,
  }) : _registryIdentity = registryIdentity,
       _tenureIdentity = tenureIdentity;

  final ExclusiveAuthorityKey authority;
  final int diagnosticOccurrence;
  final DateTime issuedAtUtc;
  final Object _registryIdentity;
  final Object _tenureIdentity;
}

final class _LiveExclusiveAuthority {
  _LiveExclusiveAuthority({
    required this.tenure,
    required this.ownerLabel,
    required this.acquiredAtUtc,
  });

  final ExclusiveAuthorityTenure tenure;
  final String ownerLabel;
  final DateTime acquiredAtUtc;
  final Set<Object> activeScopeIdentities = <Object>{};
}

/// Process-local registry for exact, scoped exclusive-authority tenure.
///
/// It owns only tenure mechanics. Domain policy, scheduling, retries, and
/// presentation remain outside this registry.
///
/// Its supported lifecycle is exactly one [ProviderContainer] lifetime.
/// Production code must not refresh or invalidate this provider. Disposing the
/// container is the sole supported revocation boundary and permanently revokes
/// every tenure issued by that registry lifecycle.
@Riverpod(keepAlive: true)
class ExclusiveAuthorityRegistry extends _$ExclusiveAuthorityRegistry {
  static const _maximumDiagnosticLabelLength = 120;

  final Object _registryIdentity = Object();
  final Map<ExclusiveAuthorityKey, _LiveExclusiveAuthority> _liveAuthorities =
      <ExclusiveAuthorityKey, _LiveExclusiveAuthority>{};
  final Map<ExclusiveAuthorityKey, int> _lastOccurrences =
      <ExclusiveAuthorityKey, int>{};
  var _isDisposed = false;

  @override
  ExclusiveAuthorityRegistryState build() {
    ref.onDispose(_dispose);
    return ExclusiveAuthorityRegistryState();
  }

  Future<T> runExclusive<T>({
    required ExclusiveAuthorityKey authority,
    required String ownerLabel,
    required Future<T> Function(ExclusiveAuthorityTenure tenure) action,
  }) async {
    _requireRegistryAvailable(authority);
    final boundedOwnerLabel = _boundedLabel(ownerLabel);
    final current = _liveAuthorities[authority];
    if (current != null) {
      _recordDeniedAcquisition(
        authority: authority,
        requestedOwnerLabel: boundedOwnerLabel,
        current: current,
      );
      throw ExclusiveAuthorityDeniedException(
        authority: authority,
        requestedOwnerLabel: boundedOwnerLabel,
        currentOwnerLabel: current.ownerLabel,
      );
    }

    final issuedAtUtc = DateTime.now().toUtc();
    final occurrence = (_lastOccurrences[authority] ?? 0) + 1;
    _lastOccurrences[authority] = occurrence;
    final tenure = ExclusiveAuthorityTenure._(
      authority: authority,
      diagnosticOccurrence: occurrence,
      issuedAtUtc: issuedAtUtc,
      registryIdentity: _registryIdentity,
      tenureIdentity: Object(),
    );
    final live = _LiveExclusiveAuthority(
      tenure: tenure,
      ownerLabel: boundedOwnerLabel,
      acquiredAtUtc: issuedAtUtc,
    );
    final scopeIdentity = Object();
    live.activeScopeIdentities.add(scopeIdentity);
    _liveAuthorities[authority] = live;
    _publishLive(live);

    return _runScope(
      live: live,
      scopeIdentity: scopeIdentity,
      action: () => action(tenure),
    );
  }

  Future<T> runReentrant<T>({
    required ExclusiveAuthorityTenure tenure,
    required Future<T> Function() action,
  }) async {
    final live = _requireLiveTenure(
      authority: tenure.authority,
      tenure: tenure,
    );
    final scopeIdentity = Object();
    live.activeScopeIdentities.add(scopeIdentity);
    _publishLive(live);

    return _runScope(live: live, scopeIdentity: scopeIdentity, action: action);
  }

  void requireCurrent({
    required ExclusiveAuthorityKey authority,
    required ExclusiveAuthorityTenure tenure,
  }) {
    _requireLiveTenure(authority: authority, tenure: tenure);
  }

  Future<T> _runScope<T>({
    required _LiveExclusiveAuthority live,
    required Object scopeIdentity,
    required Future<T> Function() action,
  }) async {
    try {
      return await action();
    } finally {
      _releaseScope(live: live, scopeIdentity: scopeIdentity);
    }
  }

  _LiveExclusiveAuthority _requireLiveTenure({
    required ExclusiveAuthorityKey authority,
    required ExclusiveAuthorityTenure tenure,
  }) {
    if (_isDisposed) {
      throw ExclusiveAuthorityProofDeniedException(
        authority: authority,
        tenureAuthority: tenure.authority,
        reason: ExclusiveAuthorityProofDenialReason.registryDisposed,
      );
    }
    if (tenure.authority != authority) {
      throw ExclusiveAuthorityProofDeniedException(
        authority: authority,
        tenureAuthority: tenure.authority,
        reason: ExclusiveAuthorityProofDenialReason.wrongAuthority,
      );
    }
    if (!identical(tenure._registryIdentity, _registryIdentity)) {
      throw ExclusiveAuthorityProofDeniedException(
        authority: authority,
        tenureAuthority: tenure.authority,
        reason: ExclusiveAuthorityProofDenialReason.foreignRegistry,
      );
    }

    final live = _liveAuthorities[authority];
    if (live == null ||
        !identical(live.tenure, tenure) ||
        !identical(live.tenure._tenureIdentity, tenure._tenureIdentity)) {
      throw ExclusiveAuthorityProofDeniedException(
        authority: authority,
        tenureAuthority: tenure.authority,
        reason: ExclusiveAuthorityProofDenialReason.staleOrReleased,
      );
    }
    return live;
  }

  void _releaseScope({
    required _LiveExclusiveAuthority live,
    required Object scopeIdentity,
  }) {
    if (_isDisposed) {
      return;
    }
    final current = _liveAuthorities[live.tenure.authority];
    if (current == null ||
        !identical(current.tenure, live.tenure) ||
        !identical(
          current.tenure._tenureIdentity,
          live.tenure._tenureIdentity,
        ) ||
        !current.activeScopeIdentities.remove(scopeIdentity)) {
      return;
    }

    if (current.activeScopeIdentities.isNotEmpty) {
      _publishLive(current);
      return;
    }

    _liveAuthorities.remove(current.tenure.authority);
    _publishReleased(current);
  }

  void _recordDeniedAcquisition({
    required ExclusiveAuthorityKey authority,
    required String requestedOwnerLabel,
    required _LiveExclusiveAuthority current,
  }) {
    final previous = state.diagnosticFor(authority);
    _replaceDiagnostic(
      ExclusiveAuthorityDiagnostic(
        authority: authority,
        isHeld: true,
        tenureOccurrence: current.tenure.diagnosticOccurrence,
        ownerLabel: current.ownerLabel,
        acquiredAtUtc: current.acquiredAtUtc,
        holdCount: current.activeScopeIdentities.length,
        lastDeniedOwnerLabel: requestedOwnerLabel,
        lastDeniedAtUtc: DateTime.now().toUtc(),
        deniedRequests: previous.deniedRequests + 1,
        lastReleasedAtUtc: previous.lastReleasedAtUtc,
      ),
    );
  }

  void _publishLive(_LiveExclusiveAuthority live) {
    final previous = state.diagnosticFor(live.tenure.authority);
    _replaceDiagnostic(
      ExclusiveAuthorityDiagnostic(
        authority: live.tenure.authority,
        isHeld: true,
        tenureOccurrence: live.tenure.diagnosticOccurrence,
        ownerLabel: live.ownerLabel,
        acquiredAtUtc: live.acquiredAtUtc,
        holdCount: live.activeScopeIdentities.length,
        lastDeniedOwnerLabel: previous.lastDeniedOwnerLabel,
        lastDeniedAtUtc: previous.lastDeniedAtUtc,
        deniedRequests: previous.deniedRequests,
        lastReleasedAtUtc: previous.lastReleasedAtUtc,
      ),
    );
  }

  void _publishReleased(_LiveExclusiveAuthority live) {
    final previous = state.diagnosticFor(live.tenure.authority);
    _replaceDiagnostic(
      ExclusiveAuthorityDiagnostic(
        authority: live.tenure.authority,
        tenureOccurrence: live.tenure.diagnosticOccurrence,
        lastDeniedOwnerLabel: previous.lastDeniedOwnerLabel,
        lastDeniedAtUtc: previous.lastDeniedAtUtc,
        deniedRequests: previous.deniedRequests,
        lastReleasedAtUtc: DateTime.now().toUtc(),
      ),
    );
  }

  void _replaceDiagnostic(ExclusiveAuthorityDiagnostic diagnostic) {
    state = ExclusiveAuthorityRegistryState(
      diagnostics: <ExclusiveAuthorityKey, ExclusiveAuthorityDiagnostic>{
        ...state.diagnostics,
        diagnostic.authority: diagnostic,
      },
    );
  }

  void _requireRegistryAvailable(ExclusiveAuthorityKey authority) {
    if (_isDisposed) {
      throw ExclusiveAuthorityProofDeniedException(
        authority: authority,
        tenureAuthority: authority,
        reason: ExclusiveAuthorityProofDenialReason.registryDisposed,
      );
    }
  }

  String _boundedLabel(String label) {
    final normalized = label.trim().isEmpty ? '(unnamed)' : label.trim();
    if (normalized.length <= _maximumDiagnosticLabelLength) {
      return normalized;
    }
    return normalized.substring(0, _maximumDiagnosticLabelLength);
  }

  void _dispose() {
    _isDisposed = true;
    _liveAuthorities.clear();
  }
}
