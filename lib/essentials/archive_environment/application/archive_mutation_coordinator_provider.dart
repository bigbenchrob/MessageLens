import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../exclusive_authority/feature_level_providers.dart'
    show
        ExclusiveAuthorityDeniedException,
        ExclusiveAuthorityKey,
        ExclusiveAuthorityProofDeniedException,
        ExclusiveAuthorityRegistry,
        ExclusiveAuthorityTenure,
        exclusiveAuthorityRegistryProvider;
import '../domain/archive_checkpoint_required_exception.dart';
import '../domain/archive_environment.dart';
import '../domain/archive_instance_id.dart';
import '../domain/archive_mutation_capability_denied_exception.dart';
import '../domain/archive_mutation_denied_exception.dart';
import '../domain/archive_mutation_operation.dart';
import 'archive_access_authority_provider.dart';
import 'verified_archive_checkpoint_provider.dart';

part 'archive_mutation_coordinator_provider.g.dart';

final Object _archiveMutationOwnerZoneKey = Object();

final class _ArchiveMutationAsyncContext {
  const _ArchiveMutationAsyncContext({
    required this.coordinatorIdentity,
    required this.tenure,
    required this.scopeId,
    required this.operation,
  });

  final Object coordinatorIdentity;
  final ExclusiveAuthorityTenure tenure;
  final int scopeId;
  final ArchiveMutationOperation operation;
}

/// Opaque proof that one exact async scope owns an admitted archive mutation.
///
/// The coordinator is the only authority that can create this capability. It
/// becomes unusable outside its originating Zone, while a nested scope is
/// active, and as soon as its originating scope is released.
final class ArchiveMutationCapability {
  const ArchiveMutationCapability._({
    required this.operation,
    required bool Function() isActive,
  }) : _isActive = isActive;

  final ArchiveMutationOperation operation;
  final bool Function() _isActive;

  void requireOperation(ArchiveMutationOperation requestedOperation) {
    if (operation != requestedOperation || !_isActive()) {
      throw ArchiveMutationCapabilityDeniedException(
        requestedOperation: requestedOperation,
        capabilityOperation: operation,
      );
    }
  }
}

class ArchiveMutationCoordinatorState {
  const ArchiveMutationCoordinatorState({
    this.operation,
    this.ownerId,
    this.ownerLabel,
    this.activeOperations = const <ArchiveMutationOperation>[],
    this.environment,
    this.archiveInstanceId,
    this.holdCount = 0,
    this.acquiredAtUtc,
    this.lastReleasedAtUtc,
    this.lastDeniedOperation,
    this.lastDeniedOwner,
    this.lastDeniedAtUtc,
    this.deniedRequests = 0,
  });

  final ArchiveMutationOperation? operation;
  final String? ownerId;
  final String? ownerLabel;
  final List<ArchiveMutationOperation> activeOperations;
  final ArchiveEnvironment? environment;
  final ArchiveInstanceId? archiveInstanceId;
  final int holdCount;
  final DateTime? acquiredAtUtc;
  final DateTime? lastReleasedAtUtc;
  final ArchiveMutationOperation? lastDeniedOperation;
  final String? lastDeniedOwner;
  final DateTime? lastDeniedAtUtc;
  final int deniedRequests;

  bool get isLocked => ownerId != null;
  bool get blocksDatabaseReopen {
    if (activeOperations.isEmpty) {
      return operation?.blocksDatabaseReopen ?? false;
    }
    return activeOperations.any((operation) => operation.blocksDatabaseReopen);
  }
}

/// Single process-local admission authority for every archive mutation.
///
/// Feature owners retain their business logic. They request a named operation
/// here before mutating an admitted archive. Nested stages inherit the same
/// owner through the async Zone and may re-enter without creating another
/// authority source.
@Riverpod(keepAlive: true)
class ArchiveMutationCoordinator extends _$ArchiveMutationCoordinator {
  final Object _coordinatorIdentity = Object();
  var _nextScopeSequence = 0;
  var _isDisposed = false;
  final Map<int, ArchiveMutationOperation> _activeScopes = {};

  @override
  ArchiveMutationCoordinatorState build() {
    ref.onDispose(() {
      _isDisposed = true;
    });
    return const ArchiveMutationCoordinatorState();
  }

  Future<T> run<T>({
    required ArchiveMutationOperation operation,
    required String ownerLabel,
    required Future<T> Function() action,
  }) {
    return _run<T>(
      operation: operation,
      ownerLabel: ownerLabel,
      action: (_) => action(),
    );
  }

  /// Runs an operation with caller-specific proof of its admitted scope.
  ///
  /// Mutation boundaries that must be mechanically inaccessible without
  /// admission accept this capability instead of trusting caller convention.
  Future<T> runWithCapability<T>({
    required ArchiveMutationOperation operation,
    required String ownerLabel,
    required Future<T> Function(ArchiveMutationCapability capability) action,
  }) {
    return _run<T>(
      operation: operation,
      ownerLabel: ownerLabel,
      action: action,
    );
  }

  Future<T> _run<T>({
    required ArchiveMutationOperation operation,
    required String ownerLabel,
    required Future<T> Function(ArchiveMutationCapability capability) action,
  }) async {
    final inheritedContext =
        Zone.current[_archiveMutationOwnerZoneKey]
            as _ArchiveMutationAsyncContext?;
    try {
      if (inheritedContext != null &&
          identical(
            inheritedContext.coordinatorIdentity,
            _coordinatorIdentity,
          )) {
        return await _exclusiveAuthorityRegistry.runReentrant<T>(
          tenure: inheritedContext.tenure,
          action: () => _runAdmittedArchiveScope<T>(
            tenure: inheritedContext.tenure,
            operation: operation,
            ownerLabel: ownerLabel,
            action: action,
          ),
        );
      }

      return await _exclusiveAuthorityRegistry.runExclusive<T>(
        authority: ExclusiveAuthorityKey.archiveMutation,
        ownerLabel: ownerLabel,
        action: (tenure) => _runAdmittedArchiveScope<T>(
          tenure: tenure,
          operation: operation,
          ownerLabel: ownerLabel,
          action: action,
        ),
      );
    } on ExclusiveAuthorityDeniedException {
      throw _archiveDenial(operation: operation, ownerLabel: ownerLabel);
    } on ExclusiveAuthorityProofDeniedException {
      throw _archiveDenial(operation: operation, ownerLabel: ownerLabel);
    }
  }

  Future<T> _runAdmittedArchiveScope<T>({
    required ExclusiveAuthorityTenure tenure,
    required ArchiveMutationOperation operation,
    required String ownerLabel,
    required Future<T> Function(ArchiveMutationCapability capability) action,
  }) async {
    final scopeId = _activateArchiveScope(
      tenure: tenure,
      operation: operation,
      ownerLabel: ownerLabel,
    );
    try {
      await _requireVerifiedCheckpointWhenApplicable(operation);
      final capability = ArchiveMutationCapability._(
        operation: operation,
        isActive: () => _scopeIsActiveForCurrentCaller(
          tenure: tenure,
          scopeId: scopeId,
          operation: operation,
        ),
      );
      return await runZoned(
        () => action(capability),
        zoneValues: {
          _archiveMutationOwnerZoneKey: _ArchiveMutationAsyncContext(
            coordinatorIdentity: _coordinatorIdentity,
            tenure: tenure,
            scopeId: scopeId,
            operation: operation,
          ),
        },
      );
    } finally {
      _releaseArchiveScope(scopeId);
    }
  }

  bool _scopeIsActiveForCurrentCaller({
    required ExclusiveAuthorityTenure tenure,
    required int scopeId,
    required ArchiveMutationOperation operation,
  }) {
    if (_isDisposed || _activeScopes[scopeId] != operation) {
      return false;
    }
    final context =
        Zone.current[_archiveMutationOwnerZoneKey]
            as _ArchiveMutationAsyncContext?;
    return identical(context?.coordinatorIdentity, _coordinatorIdentity) &&
        identical(context?.tenure, tenure) &&
        context?.scopeId == scopeId &&
        context?.operation == operation &&
        _tenureIsCurrent(tenure);
  }

  ArchiveMutationResourceAdmission resourceAdmissionForCurrentCaller(
    ArchiveMutationResourceAction action,
  ) {
    if (!state.blocksDatabaseReopen) {
      return ArchiveMutationResourceAdmission.unrestricted;
    }

    final context =
        Zone.current[_archiveMutationOwnerZoneKey]
            as _ArchiveMutationAsyncContext?;
    final callerOwnsMutation =
        context != null &&
        identical(context.coordinatorIdentity, _coordinatorIdentity) &&
        _tenureIsCurrent(context.tenure);
    if (!callerOwnsMutation ||
        !context.operation.permitsOwnerResourceAction(action)) {
      return ArchiveMutationResourceAdmission.deniedByActiveMutation;
    }

    final strongerScopeForbidsAction = _activeScopes.values
        .where((operation) => operation.blocksDatabaseReopen)
        .any((operation) => !operation.permitsOwnerResourceAction(action));
    if (strongerScopeForbidsAction) {
      return ArchiveMutationResourceAdmission.deniedByActiveMutation;
    }

    return ArchiveMutationResourceAdmission.admittedOwner;
  }

  Future<void> _requireVerifiedCheckpointWhenApplicable(
    ArchiveMutationOperation operation,
  ) async {
    final authority = ref.read(archiveAccessAuthorityProvider);
    if (authority.identity.environment != ArchiveEnvironment.production ||
        !operation.requiresVerifiedCheckpoint) {
      return;
    }

    final receipt = ref.read(verifiedArchiveCheckpointProvider);
    if (receipt == null) {
      throw ArchiveCheckpointRequiredException(
        operation: operation,
        reason: 'no verified checkpoint receipt is registered.',
      );
    }
    final validator = ref.read(archiveCheckpointReceiptValidatorProvider);
    if (!await validator.validates(receipt: receipt, authority: authority)) {
      throw ArchiveCheckpointRequiredException(
        operation: operation,
        reason:
            'the registered checkpoint no longer matches this archive identity and file inventory.',
      );
    }
  }

  ExclusiveAuthorityRegistry get _exclusiveAuthorityRegistry =>
      ref.read(exclusiveAuthorityRegistryProvider.notifier);

  bool _tenureIsCurrent(ExclusiveAuthorityTenure tenure) {
    try {
      _exclusiveAuthorityRegistry.requireCurrent(
        authority: ExclusiveAuthorityKey.archiveMutation,
        tenure: tenure,
      );
      return true;
    } on ExclusiveAuthorityProofDeniedException {
      return false;
    }
  }

  int _activateArchiveScope({
    required ExclusiveAuthorityTenure tenure,
    required ArchiveMutationOperation operation,
    required String ownerLabel,
  }) {
    final scopeId = ++_nextScopeSequence;
    if (!state.isLocked) {
      final authority = ref.read(archiveAccessAuthorityProvider);
      _activeScopes[scopeId] = operation;
      state = ArchiveMutationCoordinatorState(
        operation: operation,
        ownerId: '$ownerLabel#${tenure.diagnosticOccurrence}',
        ownerLabel: ownerLabel,
        activeOperations: List.unmodifiable(_activeScopes.values),
        environment: authority.identity.environment,
        archiveInstanceId: authority.identity.archiveInstanceId,
        holdCount: 1,
        acquiredAtUtc: tenure.issuedAtUtc,
        lastReleasedAtUtc: state.lastReleasedAtUtc,
        lastDeniedOperation: state.lastDeniedOperation,
        lastDeniedOwner: state.lastDeniedOwner,
        lastDeniedAtUtc: state.lastDeniedAtUtc,
        deniedRequests: state.deniedRequests,
      );
      return scopeId;
    }

    _activeScopes[scopeId] = operation;
    state = ArchiveMutationCoordinatorState(
      operation: state.operation,
      ownerId: state.ownerId,
      ownerLabel: state.ownerLabel,
      activeOperations: List.unmodifiable(_activeScopes.values),
      environment: state.environment,
      archiveInstanceId: state.archiveInstanceId,
      holdCount: _activeScopes.length,
      acquiredAtUtc: state.acquiredAtUtc,
      lastReleasedAtUtc: state.lastReleasedAtUtc,
      lastDeniedOperation: state.lastDeniedOperation,
      lastDeniedOwner: state.lastDeniedOwner,
      lastDeniedAtUtc: state.lastDeniedAtUtc,
      deniedRequests: state.deniedRequests,
    );
    return scopeId;
  }

  void _releaseArchiveScope(int scopeId) {
    if (_isDisposed) {
      return;
    }
    if (!state.isLocked || _activeScopes.remove(scopeId) == null) {
      return;
    }

    final nextHoldCount = _activeScopes.length;
    if (nextHoldCount > 0) {
      state = ArchiveMutationCoordinatorState(
        operation: state.operation,
        ownerId: state.ownerId,
        ownerLabel: state.ownerLabel,
        activeOperations: List.unmodifiable(_activeScopes.values),
        environment: state.environment,
        archiveInstanceId: state.archiveInstanceId,
        holdCount: nextHoldCount,
        acquiredAtUtc: state.acquiredAtUtc,
        lastReleasedAtUtc: state.lastReleasedAtUtc,
        lastDeniedOperation: state.lastDeniedOperation,
        lastDeniedOwner: state.lastDeniedOwner,
        lastDeniedAtUtc: state.lastDeniedAtUtc,
        deniedRequests: state.deniedRequests,
      );
      return;
    }

    _activeScopes.clear();
    state = ArchiveMutationCoordinatorState(
      lastReleasedAtUtc: DateTime.now().toUtc(),
      lastDeniedOperation: state.lastDeniedOperation,
      lastDeniedOwner: state.lastDeniedOwner,
      lastDeniedAtUtc: state.lastDeniedAtUtc,
      deniedRequests: state.deniedRequests,
    );
  }

  ArchiveMutationDeniedException _archiveDenial({
    required ArchiveMutationOperation operation,
    required String ownerLabel,
  }) {
    final denial = ArchiveMutationDeniedException(
      requestedOperation: operation,
      requestedOwner: ownerLabel,
      currentOperation: state.operation,
      currentOwner: state.ownerLabel,
    );
    state = ArchiveMutationCoordinatorState(
      operation: state.operation,
      ownerId: state.ownerId,
      ownerLabel: state.ownerLabel,
      activeOperations: state.activeOperations,
      environment: state.environment,
      archiveInstanceId: state.archiveInstanceId,
      holdCount: state.holdCount,
      acquiredAtUtc: state.acquiredAtUtc,
      lastReleasedAtUtc: state.lastReleasedAtUtc,
      lastDeniedOperation: operation,
      lastDeniedOwner: ownerLabel,
      lastDeniedAtUtc: DateTime.now().toUtc(),
      deniedRequests: state.deniedRequests + 1,
    );
    return denial;
  }
}

@riverpod
bool archiveDatabaseReopenBlocked(Ref ref) {
  return ref.watch(
    archiveMutationCoordinatorProvider.select(
      (state) => state.blocksDatabaseReopen,
    ),
  );
}
