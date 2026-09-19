import 'package:uuid/uuid.dart';

import '../../../essentials/archive_environment/domain/archive_access_authority.dart';
import '../../../essentials/archive_environment/domain/archive_mutation_operation.dart';
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability, ArchiveMutationCoordinator;
import '../domain/entities/attachment_archive_adoption.dart';
import '../domain/entities/attachment_archive_approval_revalidation.dart';
import '../domain/entities/attachment_archive_candidate_verification.dart';
import '../domain/entities/attachment_archive_location_configuration.dart';
import '../domain/entities/attachment_archive_location_state.dart';
import 'attachment_archive_adoption_authority.dart';
import 'attachment_archive_adoption_root_inspector.dart';
import 'attachment_archive_adoption_transaction_store.dart';
import 'attachment_archive_approval_revalidator.dart';
import 'attachment_archive_approval_snapshot_reader.dart';
import 'attachment_archive_bookmark_adapter.dart';
import 'attachment_archive_location_controller.dart';
import 'attachment_archive_location_provider.dart';

typedef AttachmentArchiveAdoptionLocationActivator =
    Future<void> Function({
      required AttachmentArchiveLocationConfiguration configuration,
      required AttachmentArchiveAdoptionConfigurationAuthority
      adoptionAuthority,
    });

typedef AttachmentArchiveAdoptionLocationReader =
    Future<AttachmentArchiveLocationState> Function();

typedef AttachmentArchiveAdoptionWritableAdmissionReader =
    Future<AttachmentArchiveWritableRootAdmission> Function();

typedef AttachmentArchiveAdoptionFailureInjector =
    Future<void> Function(AttachmentArchiveAdoptionFailurePoint point);

/// Opaque proof that this service admitted the bookmark for one ready result.
///
/// The private constructor keeps transaction authority from being minted from
/// revalidation evidence, raw bookmark bytes, or an arbitrary configuration.
final class AttachmentArchiveAdoptionBookmarkProof {
  const AttachmentArchiveAdoptionBookmarkProof._({
    required AttachmentArchiveApprovalReadyEvidence readyEvidence,
    required AttachmentArchiveApprovalScopeProof approvalScopeProof,
    required AttachmentArchiveLocationConfiguration intendedConfiguration,
  }) : _readyEvidence = readyEvidence,
       _approvalScopeProof = approvalScopeProof,
       _intendedConfiguration = intendedConfiguration;

  final AttachmentArchiveApprovalReadyEvidence _readyEvidence;
  final AttachmentArchiveApprovalScopeProof _approvalScopeProof;
  final AttachmentArchiveLocationConfiguration _intendedConfiguration;

  void requireExactAdmission({
    required AttachmentArchiveApprovalReadyEvidence readyEvidence,
    required AttachmentArchiveApprovalScopeProof approvalScopeProof,
    required AttachmentArchiveLocationConfiguration intendedConfiguration,
    required ArchiveMutationCapability capability,
  }) {
    approvalScopeProof.requireExactReadyEvidence(
      readyEvidence: readyEvidence,
      capability: capability,
    );
    if (!identical(readyEvidence, _readyEvidence) ||
        !identical(approvalScopeProof, _approvalScopeProof) ||
        intendedConfiguration != _intendedConfiguration) {
      throw StateError(
        'Archive bookmark proof belongs to another adoption admission.',
      );
    }
  }
}

/// Runs verified archive adoption inside one uninterrupted coordinator scope.
final class AttachmentArchiveAdoptionService {
  AttachmentArchiveAdoptionService({
    required ArchiveAccessAuthority archiveAccessAuthority,
    required ArchiveMutationCoordinator mutationCoordinator,
    required AttachmentArchiveApprovalCurrentLocationReader
    currentLocationReader,
    required AttachmentArchiveApprovalSnapshotReader snapshotReader,
    required AttachmentArchiveAdoptionTransactionStore transactionStore,
    required AttachmentArchiveAdoptionAuthorityIssuer authorityIssuer,
    required AttachmentArchiveBookmarkAdapter bookmarkAdapter,
    required AttachmentArchiveAdoptionRootInspector rootInspector,
    required AttachmentArchiveAdoptionLocationReader readLocation,
    required AttachmentArchiveAdoptionLocationActivator activateLocation,
    required AttachmentArchiveAdoptionLocationActivator restoreLocation,
    required AttachmentArchiveAdoptionWritableAdmissionReader
    readWritableAdmission,
    String Function()? newTransactionId,
    DateTime Function()? clock,
    AttachmentArchiveAdoptionFailureInjector? failureInjector,
  }) : _archiveAccessAuthority = archiveAccessAuthority,
       _mutationCoordinator = mutationCoordinator,
       _currentLocationReader = currentLocationReader,
       _snapshotReader = snapshotReader,
       _transactionStore = transactionStore,
       _authorityIssuer = authorityIssuer,
       _bookmarkAdapter = bookmarkAdapter,
       _rootInspector = rootInspector,
       _readLocation = readLocation,
       _activateLocation = activateLocation,
       _restoreLocation = restoreLocation,
       _readWritableAdmission = readWritableAdmission,
       _newTransactionId = newTransactionId ?? _newUuid,
       _clock = clock ?? _utcNow,
       _failureInjector = failureInjector ?? _noFailure;

  static const String ownerLabel = 'attachment-archive-adoption';

  final ArchiveAccessAuthority _archiveAccessAuthority;
  final ArchiveMutationCoordinator _mutationCoordinator;
  final AttachmentArchiveApprovalCurrentLocationReader _currentLocationReader;
  final AttachmentArchiveApprovalSnapshotReader _snapshotReader;
  final AttachmentArchiveAdoptionTransactionStore _transactionStore;
  final AttachmentArchiveAdoptionAuthorityIssuer _authorityIssuer;
  final AttachmentArchiveBookmarkAdapter _bookmarkAdapter;
  final AttachmentArchiveAdoptionRootInspector _rootInspector;
  final AttachmentArchiveAdoptionLocationReader _readLocation;
  final AttachmentArchiveAdoptionLocationActivator _activateLocation;
  final AttachmentArchiveAdoptionLocationActivator _restoreLocation;
  final AttachmentArchiveAdoptionWritableAdmissionReader _readWritableAdmission;
  final String Function() _newTransactionId;
  final DateTime Function() _clock;
  final AttachmentArchiveAdoptionFailureInjector _failureInjector;

  Future<AttachmentArchiveAdoptionResult> adopt(
    AttachmentArchiveCandidateComplete verification,
  ) {
    return _mutationCoordinator.runWithCapability(
      operation: ArchiveMutationOperation.attachmentArchiveAdoption,
      ownerLabel: ownerLabel,
      action: (capability) =>
          _adoptWithinScope(verification: verification, capability: capability),
    );
  }

  Future<AttachmentArchiveAdoptionResult> _adoptWithinScope({
    required AttachmentArchiveCandidateComplete verification,
    required ArchiveMutationCapability capability,
  }) async {
    capability.requireOperation(
      ArchiveMutationOperation.attachmentArchiveAdoption,
    );
    final existing = await _transactionStore.readPending();
    if (existing != null) {
      return AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.failed,
        transactionId: existing.transactionId,
        issue: 'A previous archive adoption requires recovery.',
      );
    }

    final revalidator = AttachmentArchiveApprovalRevalidator(
      mutationCoordinator: _mutationCoordinator,
      currentLocationReader: _currentLocationReader,
      candidateAccessReader: _CompleteBoundCandidateAccessReader(verification),
      snapshotReader: _snapshotReader,
      clock: _clock,
    );
    final scopedRevalidation = await revalidator
        .revalidateForAdoptionWithinApprovalScope(
          verification: verification,
          capability: capability,
        );
    final revalidation = scopedRevalidation.result;
    final ready = revalidation.readyEvidence;
    final approvalScopeProof = scopedRevalidation.scopeProof;
    if (ready == null || approvalScopeProof == null) {
      return _fromRevalidation(revalidation);
    }

    final previousConfiguration = ready.sourceLocationConfiguration;
    final transactionId = _newTransactionId();
    AttachmentArchiveAdoptionTransaction? transaction;
    var pendingTransactionIsDurable = false;
    try {
      final intendedConfiguration = await _createIntendedConfiguration(ready);
      final bookmarkProof = AttachmentArchiveAdoptionBookmarkProof._(
        readyEvidence: ready,
        approvalScopeProof: approvalScopeProof,
        intendedConfiguration: intendedConfiguration,
      );
      final now = _clock().toUtc();
      final verified = verification.evidence!;
      transaction = AttachmentArchiveAdoptionTransaction(
        formatVersion:
            AttachmentArchiveAdoptionTransaction.currentFormatVersion,
        transactionId: transactionId,
        state: AttachmentArchiveAdoptionTransactionState.prepared,
        previousConfiguration: previousConfiguration,
        intendedConfiguration: intendedConfiguration,
        sourceCanonicalIdentity: ready.sourceCanonicalIdentity,
        candidateCanonicalIdentity: ready.candidateCanonicalIdentity,
        sourceLocationGeneration: ready.sourceLocationGeneration,
        verificationContentDigest: ready.contentCoverageDigest,
        sourceStructuralSnapshotFingerprint:
            ready.sourceStructuralSnapshotFingerprint,
        candidateStructuralSnapshotFingerprint:
            ready.candidateStructuralSnapshotFingerprint,
        verifiedFileCount: verified.verifiedFileCount,
        verifiedBytes: verified.verifiedBytes,
        createdAtUtc: now,
        updatedAtUtc: now,
      );
      transaction.validate();

      await _inject(
        AttachmentArchiveAdoptionFailurePoint.beforePreparedTransactionWrite,
      );
      await _transactionStore.writePending(transaction);
      pendingTransactionIsDurable = true;
      await _inject(
        AttachmentArchiveAdoptionFailurePoint.afterPreparedTransactionWrite,
      );

      final authority = await _authorityIssuer.issueVerifiedAuthority(
        transactionId: transactionId,
        readyEvidence: ready,
        previousConfiguration: previousConfiguration,
        intendedConfiguration: intendedConfiguration,
        capability: capability,
        approvalScopeProof: approvalScopeProof,
        bookmarkProof: bookmarkProof,
      );
      await _inject(
        AttachmentArchiveAdoptionFailurePoint.beforeConfigurationPersistence,
      );
      await _activateLocation(
        configuration: intendedConfiguration,
        adoptionAuthority: authority,
      );
      await _inject(
        AttachmentArchiveAdoptionFailurePoint.afterConfigurationPersistence,
      );

      transaction = transaction.withState(
        AttachmentArchiveAdoptionTransactionState.configurationPersisted,
        updatedAtUtc: _clock().toUtc(),
      );
      await _transactionStore.writePending(transaction);
      await _inject(
        AttachmentArchiveAdoptionFailurePoint.afterConfigurationPersistedWrite,
      );

      await _validateSwitchedLocation(
        transaction: transaction,
        intendedConfiguration: intendedConfiguration,
      );
      await _transactionStore.clearPending(
        expectedTransactionId: transactionId,
      );
      return AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.adopted,
        transactionId: transactionId,
      );
    } on _AttachmentArchiveAdoptionAbort catch (error) {
      if (transaction == null || !pendingTransactionIsDurable) {
        return AttachmentArchiveAdoptionResult(
          outcome: error.outcome,
          issue: error.issue,
        );
      }
      return _rollback(
        transaction: transaction,
        capability: capability,
        activationError: error,
      );
    } on Object catch (error) {
      if (transaction == null || !pendingTransactionIsDurable) {
        return AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome.failed,
          issue: error.toString(),
        );
      }
      return _rollback(
        transaction: transaction,
        capability: capability,
        activationError: error,
      );
    }
  }

  Future<AttachmentArchiveLocationConfiguration> _createIntendedConfiguration(
    AttachmentArchiveApprovalReadyEvidence ready,
  ) async {
    final creation = await _bookmarkAdapter.createBookmark(
      directoryPath: ready.candidateCanonicalIdentity,
    );
    final createdRoot = await _rootInspector.inspect(
      directoryPath: creation.resolvedPath,
      label: 'created candidate bookmark',
    );
    if (createdRoot.canonicalPath != ready.candidateCanonicalIdentity) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain,
        'The created bookmark resolved to another candidate archive.',
      );
    }
    final resolution = await _bookmarkAdapter.resolveBookmark(
      bookmarkDataBase64: creation.bookmarkDataBase64,
    );
    if (resolution.status ==
        AttachmentArchiveBookmarkResolutionStatus.readOnly) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.candidateNoLongerWritable,
        'The candidate archive is no longer writable.',
      );
    }
    if (resolution.status !=
            AttachmentArchiveBookmarkResolutionStatus.available ||
        resolution.resolvedPath == null) {
      throw _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.candidateUnavailable,
        resolution.issue ?? 'The candidate bookmark is unavailable.',
      );
    }
    final resolvedRoot = await _rootInspector.inspect(
      directoryPath: resolution.resolvedPath!,
      label: 'resolved candidate bookmark',
    );
    if (resolvedRoot.canonicalPath != ready.candidateCanonicalIdentity) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain,
        'The resolved bookmark identifies another candidate archive.',
      );
    }
    return AttachmentArchiveLocationConfiguration.customExternal(
      bookmarkDataBase64:
          resolution.refreshedBookmarkDataBase64 ?? creation.bookmarkDataBase64,
      lastKnownPath: resolution.resolvedPath!,
      volumeName: resolution.volumeName ?? creation.volumeName,
      customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
    );
  }

  Future<void> _validateSwitchedLocation({
    required AttachmentArchiveAdoptionTransaction transaction,
    required AttachmentArchiveLocationConfiguration intendedConfiguration,
  }) async {
    await _inject(
      AttachmentArchiveAdoptionFailurePoint.beforeNewLocationResolution,
    );
    final current = await _readLocation();
    if (current.configuration != intendedConfiguration ||
        current.availability !=
            AttachmentArchiveLocationAvailability.customAvailable ||
        current.archiveRootPath == null ||
        current.generation != transaction.sourceLocationGeneration + 1) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.failed,
        'The adopted archive did not resolve as the expected active location.',
      );
    }
    final currentRoot = await _rootInspector.inspect(
      directoryPath: current.archiveRootPath!,
      label: 'active adopted archive',
    );
    if (currentRoot.canonicalPath != transaction.candidateCanonicalIdentity) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain,
        'The active archive resolved to another canonical root.',
      );
    }

    await _inject(
      AttachmentArchiveAdoptionFailurePoint
          .beforePostSwitchCandidateFingerprint,
    );
    final candidateSnapshot = await _snapshotReader.readCandidate(
      sourceCanonicalIdentity: transaction.sourceCanonicalIdentity,
      candidate: AttachmentArchiveCandidateAccess(
        directoryPath: current.archiveRootPath!,
        isPhysicallyWritable: true,
      ),
      expectedCandidateCanonicalIdentity:
          transaction.candidateCanonicalIdentity,
    );
    if (candidateSnapshot.candidateStructuralSnapshotFingerprint !=
            transaction.candidateStructuralSnapshotFingerprint ||
        candidateSnapshot.structurallyMatchedCandidateFileCount !=
            transaction.verifiedFileCount ||
        candidateSnapshot.structurallyMatchedCandidateBytes !=
            transaction.verifiedBytes) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain,
        'The candidate archive changed during configuration switching.',
      );
    }

    await _inject(
      AttachmentArchiveAdoptionFailurePoint.beforeWritableRootAdmission,
    );
    final admission = await _readWritableAdmission();
    final lease = admission.lease;
    if (lease == null ||
        lease.archiveRootPath != current.archiveRootPath ||
        lease.locationGeneration != current.generation ||
        lease.locationMode != AttachmentArchiveLocationMode.customExternal ||
        lease.permitsDestructiveReset ||
        !lease.matchesConfiguration(intendedConfiguration)) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.failed,
        'The adopted archive did not receive normal writable-root authority.',
      );
    }
    final leaseRoot = await _rootInspector.inspect(
      directoryPath: lease.archiveRootPath,
      label: 'adopted writable-root lease',
    );
    if (leaseRoot.canonicalPath != transaction.candidateCanonicalIdentity) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.failed,
        'Writable-root authority identifies another archive.',
      );
    }
    await _inject(
      AttachmentArchiveAdoptionFailurePoint.beforeWritableRootValidation,
    );
    await lease.requireValid(
      operation: ArchiveMutationOperation.attachmentArchiveAdoption,
      boundary: AttachmentArchiveMutationBoundary.operationStart,
    );
  }

  Future<AttachmentArchiveAdoptionResult> _rollback({
    required AttachmentArchiveAdoptionTransaction transaction,
    required ArchiveMutationCapability capability,
    required Object activationError,
  }) async {
    try {
      final durable = await _transactionStore.readPending();
      if (durable == null ||
          durable.transactionId != transaction.transactionId) {
        return AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome.failed,
          transactionId: transaction.transactionId,
          issue:
              'Adoption failed and its durable recovery record is unavailable: '
              '$activationError',
        );
      }
      final current = await _readLocation();
      if (current.configuration != durable.previousConfiguration &&
          current.configuration != durable.intendedConfiguration) {
        return AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome.configurationConflict,
          transactionId: durable.transactionId,
          issue: 'An unrelated archive configuration appeared during rollback.',
        );
      }

      final previousAvailable = await _previousSourceIsAvailable(durable);
      if (!previousAvailable) {
        return AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome
              .rollbackPendingPreviousUnavailable,
          transactionId: durable.transactionId,
          issue:
              'Adoption failed and the previous archive is unavailable. '
              'Recovery remains pending.',
        );
      }

      if (current.configuration == durable.intendedConfiguration) {
        final recoveryAuthority = await _authorityIssuer.issueRecoveryAuthority(
          transactionId: durable.transactionId,
          capability: capability,
        );
        await _inject(
          AttachmentArchiveAdoptionFailurePoint
              .beforeRollbackConfigurationPersistence,
        );
        await _restoreLocation(
          configuration: durable.previousConfiguration,
          adoptionAuthority: recoveryAuthority,
        );
      }
      final restored = await _readLocation();
      if (!await _locationMatchesPrevious(restored, durable)) {
        return AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome
              .rollbackPendingPreviousUnavailable,
          transactionId: durable.transactionId,
          issue: 'The previous archive could not be proven after rollback.',
        );
      }
      await _transactionStore.clearPending(
        expectedTransactionId: durable.transactionId,
      );
      return AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.rollbackRestoredPrevious,
        transactionId: durable.transactionId,
        issue: activationError.toString(),
      );
    } on Object catch (rollbackError) {
      return AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.failed,
        transactionId: transaction.transactionId,
        issue:
            'Adoption failed: $activationError; rollback remains pending: '
            '$rollbackError',
      );
    }
  }

  Future<bool> _previousSourceIsAvailable(
    AttachmentArchiveAdoptionTransaction transaction,
  ) async {
    await _inject(
      AttachmentArchiveAdoptionFailurePoint.beforePreviousSourceValidation,
    );
    final previous = transaction.previousConfiguration;
    String? resolvedPath;
    if (previous.mode == AttachmentArchiveLocationMode.defaultInternal) {
      resolvedPath = _archiveAccessAuthority.resolvePath(
        AttachmentArchiveLocationController.defaultArchiveDirectoryName,
      );
    } else {
      final bookmark = previous.bookmarkDataBase64;
      if (bookmark == null) {
        return false;
      }
      final resolution = await _bookmarkAdapter.resolveBookmark(
        bookmarkDataBase64: bookmark,
      );
      if (resolution.status !=
              AttachmentArchiveBookmarkResolutionStatus.available &&
          resolution.status !=
              AttachmentArchiveBookmarkResolutionStatus.readOnly) {
        return false;
      }
      resolvedPath = resolution.resolvedPath;
    }
    if (resolvedPath == null) {
      return false;
    }
    try {
      final inspected = await _rootInspector.inspect(
        directoryPath: resolvedPath,
        label: 'previous attachment archive',
      );
      return inspected.canonicalPath == transaction.sourceCanonicalIdentity;
    } on Object {
      return false;
    }
  }

  Future<bool> _locationMatchesPrevious(
    AttachmentArchiveLocationState location,
    AttachmentArchiveAdoptionTransaction transaction,
  ) async {
    if (location.configuration != transaction.previousConfiguration ||
        !location.isAvailable ||
        location.archiveRootPath == null) {
      return false;
    }
    try {
      final inspected = await _rootInspector.inspect(
        directoryPath: location.archiveRootPath!,
        label: 'restored attachment archive',
      );
      return inspected.canonicalPath == transaction.sourceCanonicalIdentity;
    } on Object {
      return false;
    }
  }

  Future<void> _inject(AttachmentArchiveAdoptionFailurePoint point) {
    return _failureInjector(point);
  }

  static AttachmentArchiveAdoptionResult _fromRevalidation(
    AttachmentArchiveApprovalRevalidationResult result,
  ) {
    final outcome = switch (result.outcome) {
      AttachmentArchiveApprovalRevalidationOutcome.sourceChanged =>
        AttachmentArchiveAdoptionOutcome.sourceChangedCheckAgain,
      AttachmentArchiveApprovalRevalidationOutcome.candidateChanged =>
        AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain,
      AttachmentArchiveApprovalRevalidationOutcome.sourceUnavailable =>
        AttachmentArchiveAdoptionOutcome.sourceUnavailable,
      AttachmentArchiveApprovalRevalidationOutcome.candidateUnavailable =>
        AttachmentArchiveAdoptionOutcome.candidateUnavailable,
      AttachmentArchiveApprovalRevalidationOutcome.candidateNoLongerWritable =>
        AttachmentArchiveAdoptionOutcome.candidateNoLongerWritable,
      AttachmentArchiveApprovalRevalidationOutcome.approvalReady ||
      AttachmentArchiveApprovalRevalidationOutcome
          .verificationEvidenceInvalid ||
      AttachmentArchiveApprovalRevalidationOutcome.failed =>
        AttachmentArchiveAdoptionOutcome.failed,
    };
    return AttachmentArchiveAdoptionResult(
      outcome: outcome,
      issue: result.issue,
    );
  }

  static String _newUuid() => const Uuid().v4();
  static DateTime _utcNow() => DateTime.now().toUtc();
  static Future<void> _noFailure(
    AttachmentArchiveAdoptionFailurePoint _,
  ) async {}
}

final class _CompleteBoundCandidateAccessReader
    implements AttachmentArchiveApprovalCandidateAccessReader {
  const _CompleteBoundCandidateAccessReader(this._verification);

  final AttachmentArchiveCandidateComplete _verification;

  @override
  Future<AttachmentArchiveApprovalCandidateAccessResult> readCurrentAccess(
    AttachmentArchiveCandidateComplete verification,
  ) async {
    if (!identical(verification, _verification)) {
      return const AttachmentArchiveApprovalCandidateUnavailable(
        'Approval evidence belongs to another candidate verification.',
      );
    }
    final evidence = verification.evidence!;
    return AttachmentArchiveApprovalCandidateAvailable(
      AttachmentArchiveCandidateAccess(
        directoryPath: evidence.candidateCanonicalIdentity,
        isPhysicallyWritable: evidence.candidateWasPhysicallyWritable,
      ),
    );
  }
}

final class _AttachmentArchiveAdoptionAbort implements Exception {
  const _AttachmentArchiveAdoptionAbort(this.outcome, this.issue);

  final AttachmentArchiveAdoptionOutcome outcome;
  final String issue;

  @override
  String toString() =>
      'AttachmentArchiveAdoptionAbort(${outcome.name}): $issue';
}
