import 'dart:io';

import 'package:path/path.dart' as path;
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
import 'attachment_archive_adoption_workflow.dart';
import 'attachment_archive_approval_revalidator.dart';
import 'attachment_archive_approval_snapshot_reader.dart';
import 'attachment_archive_bookmark_adapter.dart';
import 'attachment_archive_candidate_verifier.dart';
import 'attachment_archive_file_store.dart';
import 'attachment_archive_location_controller.dart';
import 'attachment_archive_location_provider.dart';
import 'attachment_archive_remediation_authority.dart';

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
    required AttachmentArchiveCandidateVerificationResult verification,
    required AttachmentArchiveLocationConfiguration intendedConfiguration,
  }) : _verification = verification,
       _intendedConfiguration = intendedConfiguration;

  final AttachmentArchiveCandidateVerificationResult _verification;
  final AttachmentArchiveLocationConfiguration _intendedConfiguration;

  void requireExactAdmission({
    required AttachmentArchiveCandidateVerificationResult verification,
    required AttachmentArchiveLocationConfiguration intendedConfiguration,
    required ArchiveMutationCapability capability,
  }) {
    capability.requireOperation(
      ArchiveMutationOperation.attachmentArchiveAdoption,
    );
    if (!identical(verification, _verification) ||
        intendedConfiguration != _intendedConfiguration) {
      throw StateError(
        'Archive bookmark proof belongs to another adoption admission.',
      );
    }
  }
}

/// Runs verified archive adoption inside one uninterrupted coordinator scope.
final class AttachmentArchiveAdoptionService
    implements AttachmentArchiveAdoptionExecutor {
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
    AttachmentArchiveCandidateVerifier? candidateVerifier,
    AttachmentArchiveFileStore? fileStore,
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
       _failureInjector = failureInjector ?? _noFailure,
       _candidateVerifier = candidateVerifier,
       _fileStore = fileStore;

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
  final AttachmentArchiveCandidateVerifier? _candidateVerifier;
  final AttachmentArchiveFileStore? _fileStore;

  @override
  Future<AttachmentArchiveAdoptionResult> adopt(
    AttachmentArchiveCandidateVerificationResult verification, {
    AttachmentArchiveVerificationProgressCallback? onVerificationProgress,
    AttachmentArchiveRemediationProgressCallback? onRemediationProgress,
  }) {
    if (verification is! AttachmentArchiveCandidateComplete &&
        verification is! AttachmentArchiveCandidateBehind) {
      return Future<AttachmentArchiveAdoptionResult>.value(
        const AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome.verificationEvidenceInvalid,
          issue: 'Only a complete or safely verified-behind copy may be used.',
        ),
      );
    }
    return _mutationCoordinator.runWithCapability(
      operation: ArchiveMutationOperation.attachmentArchiveAdoption,
      ownerLabel: ownerLabel,
      action: (capability) {
        if (verification is AttachmentArchiveCandidateComplete) {
          return _adoptCompleteWithinScope(
            verification: verification,
            capability: capability,
          );
        }
        return _adoptBehindWithinScope(
          reviewedVerification:
              verification as AttachmentArchiveCandidateBehind,
          capability: capability,
          onVerificationProgress: onVerificationProgress,
          onRemediationProgress: onRemediationProgress,
        );
      },
    );
  }

  @override
  Future<AttachmentArchiveAdoptionResult> resumePendingRemediation({
    AttachmentArchiveRemediationProgressCallback? onRemediationProgress,
  }) {
    return _mutationCoordinator.runWithCapability(
      operation: ArchiveMutationOperation.attachmentArchiveAdoption,
      ownerLabel: '$ownerLabel-remediation-resume',
      action: (capability) => _resumePendingWithinScope(
        capability: capability,
        onRemediationProgress: onRemediationProgress,
      ),
    );
  }

  Future<AttachmentArchiveAdoptionResult> _adoptCompleteWithinScope({
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
      final intendedConfiguration = await _createIntendedConfiguration(
        ready.candidateCanonicalIdentity,
      );
      final bookmarkProof = AttachmentArchiveAdoptionBookmarkProof._(
        verification: verification,
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

  Future<AttachmentArchiveAdoptionResult> _adoptBehindWithinScope({
    required AttachmentArchiveCandidateBehind reviewedVerification,
    required ArchiveMutationCapability capability,
    AttachmentArchiveVerificationProgressCallback? onVerificationProgress,
    AttachmentArchiveRemediationProgressCallback? onRemediationProgress,
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

    AttachmentArchiveAdoptionTransaction? transaction;
    var pendingTransactionIsDurable = false;
    try {
      final finalVerification = await _refreshBehindVerification(
        reviewedVerification: reviewedVerification,
        onProgress: onVerificationProgress,
      );
      final evidence = finalVerification.evidence!;
      final previousConfiguration = evidence.sourceLocationConfiguration;
      final intendedConfiguration = await _createIntendedConfiguration(
        evidence.candidateCanonicalIdentity,
      );
      final bookmarkProof = AttachmentArchiveAdoptionBookmarkProof._(
        verification: finalVerification,
        intendedConfiguration: intendedConfiguration,
      );
      final now = _clock().toUtc();
      final transactionId = _newTransactionId();
      transaction = AttachmentArchiveAdoptionTransaction(
        formatVersion:
            AttachmentArchiveAdoptionTransaction.currentFormatVersion,
        transactionId: transactionId,
        state: AttachmentArchiveAdoptionTransactionState.prepared,
        kind: AttachmentArchiveAdoptionTransactionKind.verifiedBehind,
        previousConfiguration: previousConfiguration,
        intendedConfiguration: intendedConfiguration,
        sourceCanonicalIdentity: evidence.sourceCanonicalIdentity,
        candidateCanonicalIdentity: evidence.candidateCanonicalIdentity,
        sourceLocationGeneration: evidence.sourceLocationGeneration,
        verificationContentDigest: evidence.contentCoverageDigest,
        sourceStructuralSnapshotFingerprint:
            evidence.sourceStructuralSnapshotFingerprint,
        candidateStructuralSnapshotFingerprint:
            evidence.candidateStructuralSnapshotFingerprint,
        verifiedFileCount: evidence.verifiedFileCount,
        verifiedBytes: evidence.verifiedBytes,
        remediationPayloads: evidence.missingPayloads
            .map(
              (payload) => AttachmentArchiveRemediationPayload(
                relativePath: payload.relativePath,
                expectedSizeBytes: payload.expectedSizeBytes,
                expectedSha256: payload.expectedSha256,
              ),
            )
            .toList(growable: false),
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

      final authority = await _authorityIssuer.issueVerifiedBehindAuthority(
        transactionId: transactionId,
        verification: finalVerification,
        previousConfiguration: previousConfiguration,
        intendedConfiguration: intendedConfiguration,
        capability: capability,
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

      final lease = await _validateSwitchedLocation(
        transaction: transaction,
        intendedConfiguration: intendedConfiguration,
      );

      // Point of no automatic rollback: configuration and writable-root lease
      // are proven while the coordinator still excludes ordinary ingestion,
      // then this durable state is written before remediation begins.
      transaction = transaction.withState(
        AttachmentArchiveAdoptionTransactionState.activeRemediationPending,
        updatedAtUtc: _clock().toUtc(),
      );
      await _transactionStore.writePending(transaction);
      await _inject(
        AttachmentArchiveAdoptionFailurePoint.afterActiveRemediationBoundary,
      );

      await _remediate(
        transaction: transaction,
        capability: capability,
        writableLease: lease,
        onProgress: onRemediationProgress,
      );
      await _proveFinalCoverage(transaction);
      await _transactionStore.clearPending(
        expectedTransactionId: transactionId,
      );
      return AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.adopted,
        transactionId: transactionId,
      );
    } on _AttachmentArchiveAdoptionAbort catch (error) {
      if (transaction?.hasCrossedActiveAuthorityBoundary ?? false) {
        return AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome.remediationPending,
          transactionId: transaction!.transactionId,
          issue: error.issue,
        );
      }
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
      if (transaction?.hasCrossedActiveAuthorityBoundary ?? false) {
        return AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome.remediationPending,
          transactionId: transaction!.transactionId,
          issue:
              'The new archive remains active; historical remediation is '
              'pending: $error',
        );
      }
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

  Future<AttachmentArchiveCandidateBehind> _refreshBehindVerification({
    required AttachmentArchiveCandidateBehind reviewedVerification,
    AttachmentArchiveVerificationProgressCallback? onProgress,
  }) async {
    final verifier = _candidateVerifier;
    final reviewed = reviewedVerification.evidence;
    if (verifier == null ||
        reviewed == null ||
        !reviewed.hasCompleteMissingPayloadEvidence ||
        reviewed.missingCount <= 0 ||
        reviewed.missingCount >
            AttachmentArchiveAdoptionTransaction
                .maximumRemediationPayloadCount ||
        reviewed.missingBytes >
            AttachmentArchiveAdoptionTransaction.maximumRemediationBytes) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.verificationEvidenceInvalid,
        'This copy is too far behind or lacks exact remediation evidence.',
      );
    }
    final currentSource = await _currentLocationReader.readCurrentLocation();
    if (!currentSource.isAvailable || currentSource.archiveRootPath == null) {
      throw _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.sourceUnavailable,
        currentSource.issue ?? 'The current archive is unavailable.',
      );
    }
    if (currentSource.configuration != reviewed.sourceLocationConfiguration ||
        currentSource.generation != reviewed.sourceLocationGeneration) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.sourceChangedCheckAgain,
        'The active archive configuration changed. Check the copy again.',
      );
    }
    final sourceRoot = await _rootInspector.inspect(
      directoryPath: currentSource.archiveRootPath!,
      label: 'refreshed authoritative archive',
    );
    if (sourceRoot.canonicalPath != reviewed.sourceCanonicalIdentity) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.sourceChangedCheckAgain,
        'The active archive identity changed. Check the copy again.',
      );
    }

    final refreshed = await verifier.verify(
      sourceLocation: currentSource,
      candidate: AttachmentArchiveCandidateAccess(
        directoryPath: reviewed.candidateCanonicalIdentity,
        isPhysicallyWritable: reviewed.candidateWasPhysicallyWritable,
      ),
      onProgress: onProgress,
    );
    if (refreshed is AttachmentArchiveCandidateInvalid) {
      throw _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain,
        refreshed.issue ?? 'The copy now contains conflicting content.',
      );
    }
    if (refreshed is AttachmentArchiveVerificationSourceUnavailable) {
      throw _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.sourceUnavailable,
        refreshed.issue ?? 'The current archive is unavailable.',
      );
    }
    if (refreshed is AttachmentArchiveVerificationCandidateUnavailable) {
      throw _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.candidateUnavailable,
        refreshed.issue ?? 'The archive copy is unavailable.',
      );
    }
    if (refreshed is! AttachmentArchiveCandidateBehind) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain,
        'The archive evidence changed. Check the copy again.',
      );
    }
    final finalEvidence = refreshed.evidence!;
    if (!finalEvidence.candidateWasPhysicallyWritable) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.candidateNoLongerWritable,
        'The archive copy is no longer writable.',
      );
    }
    if (!finalEvidence.hasCompleteMissingPayloadEvidence ||
        finalEvidence.missingCount >
            AttachmentArchiveAdoptionTransaction
                .maximumRemediationPayloadCount ||
        finalEvidence.missingBytes >
            AttachmentArchiveAdoptionTransaction.maximumRemediationBytes) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.verificationEvidenceInvalid,
        'This copy is substantially out of date. Refresh it externally.',
      );
    }
    if (finalEvidence.candidateStructuralSnapshotFingerprint !=
            reviewed.candidateStructuralSnapshotFingerprint ||
        finalEvidence.verifiedFileCount != reviewed.verifiedFileCount ||
        finalEvidence.verifiedBytes != reviewed.verifiedBytes ||
        finalEvidence.allowedCandidateExtraCount !=
            reviewed.allowedCandidateExtraCount ||
        finalEvidence.allowedCandidateExtraBytes !=
            reviewed.allowedCandidateExtraBytes ||
        !_reviewedMissingPayloadsRemainExact(reviewed, finalEvidence) ||
        finalEvidence.requiredSourcePhysicalFileCount !=
            reviewed.requiredSourcePhysicalFileCount +
                finalEvidence.missingCount -
                reviewed.missingCount ||
        finalEvidence.requiredSourceBytes !=
            reviewed.requiredSourceBytes +
                finalEvidence.missingBytes -
                reviewed.missingBytes) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.sourceChangedCheckAgain,
        'Changes since review were not solely additive. Check the copy again.',
      );
    }
    return refreshed;
  }

  static bool _reviewedMissingPayloadsRemainExact(
    AttachmentArchiveCandidateVerificationEvidence reviewed,
    AttachmentArchiveCandidateVerificationEvidence refreshed,
  ) {
    final byPath = <String, AttachmentArchiveVerifiedMissingPayload>{
      for (final payload in refreshed.missingPayloads)
        payload.relativePath: payload,
    };
    for (final original in reviewed.missingPayloads) {
      final current = byPath[original.relativePath];
      if (current == null ||
          current.expectedSizeBytes != original.expectedSizeBytes ||
          current.expectedSha256 != original.expectedSha256) {
        return false;
      }
    }
    return true;
  }

  Future<AttachmentArchiveAdoptionResult> _resumePendingWithinScope({
    required ArchiveMutationCapability capability,
    AttachmentArchiveRemediationProgressCallback? onRemediationProgress,
  }) async {
    capability.requireOperation(
      ArchiveMutationOperation.attachmentArchiveAdoption,
    );
    final transaction = await _transactionStore.readPending();
    if (transaction == null) {
      return const AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.noPendingRecovery,
      );
    }
    if (!transaction.hasCrossedActiveAuthorityBoundary ||
        transaction.kind !=
            AttachmentArchiveAdoptionTransactionKind.verifiedBehind) {
      return AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.failed,
        transactionId: transaction.transactionId,
        issue: 'The pending adoption still requires pre-switch recovery.',
      );
    }
    try {
      final current = await _readLocation();
      if (current.configuration != transaction.intendedConfiguration ||
          current.generation != transaction.sourceLocationGeneration + 1 ||
          !current.isWritableMutationEligible ||
          current.archiveRootPath == null) {
        throw const _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.remediationPending,
          'The active archive copy is unavailable; remediation is waiting.',
        );
      }
      final candidateRoot = await _rootInspector.inspect(
        directoryPath: current.archiveRootPath!,
        label: 'active remediation archive',
      );
      if (candidateRoot.canonicalPath !=
          transaction.candidateCanonicalIdentity) {
        throw const _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.remediationPending,
          'The active archive copy identity cannot be proven.',
        );
      }
      final admission = await _readWritableAdmission();
      final lease = admission.lease;
      if (lease == null ||
          lease.archiveRootPath != current.archiveRootPath ||
          lease.locationGeneration != current.generation ||
          !lease.matchesConfiguration(transaction.intendedConfiguration)) {
        throw const _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.remediationPending,
          'The active archive copy is not currently writable.',
        );
      }
      await _remediate(
        transaction: transaction,
        capability: capability,
        writableLease: lease,
        onProgress: onRemediationProgress,
      );
      await _proveFinalCoverage(transaction);
      await _transactionStore.clearPending(
        expectedTransactionId: transaction.transactionId,
      );
      return AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.remediationComplete,
        transactionId: transaction.transactionId,
      );
    } on Object catch (error) {
      return AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.remediationPending,
        transactionId: transaction.transactionId,
        issue:
            'The new archive remains active; historical remediation is '
            'pending: $error',
      );
    }
  }

  Future<void> _remediate({
    required AttachmentArchiveAdoptionTransaction transaction,
    required ArchiveMutationCapability capability,
    required AttachmentArchiveWritableRootLease writableLease,
    AttachmentArchiveRemediationProgressCallback? onProgress,
  }) async {
    final fileStore = _fileStore;
    if (fileStore == null) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.remediationPending,
        'The verified payload installer is unavailable.',
      );
    }
    final retainedSourcePath = await _resolveRetainedSourcePath(transaction);
    if (retainedSourcePath == null) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.remediationPending,
        'The original archive is unavailable; remediation is waiting.',
      );
    }
    final current = await _readLocation();
    final candidateRootPath = current.archiveRootPath;
    if (current.configuration != transaction.intendedConfiguration ||
        current.generation != transaction.sourceLocationGeneration + 1 ||
        candidateRootPath == null) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.remediationPending,
        'The active archive copy is unavailable; remediation is waiting.',
      );
    }
    try {
      final candidateRoot = await _rootInspector.inspect(
        directoryPath: candidateRootPath,
        label: 'active remediation archive',
      );
      if (candidateRoot.canonicalPath !=
          transaction.candidateCanonicalIdentity) {
        throw const _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.remediationPending,
          'The active archive copy identity cannot be proven.',
        );
      }
    } on _AttachmentArchiveAdoptionAbort {
      rethrow;
    } on Object {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.remediationPending,
        'The active archive copy is unavailable; remediation is waiting.',
      );
    }

    var filesCompleted = 0;
    var bytesCompleted = 0;
    final totalFiles = transaction.remediationPayloads.length;
    final totalBytes = transaction.remediationBytes;
    onProgress?.call(
      AttachmentArchiveRemediationProgress(
        filesCompleted: 0,
        totalFiles: totalFiles,
        bytesCompleted: 0,
        totalBytes: totalBytes,
      ),
    );
    for (final payload in transaction.remediationPayloads) {
      await _inject(AttachmentArchiveAdoptionFailurePoint.duringRemediation);
      final sourceFile = await _verifiedRetainedSourceFile(
        rootPath: retainedSourcePath,
        payload: payload,
      );
      final authority = await AttachmentArchiveRemediationAuthority.issue(
        transaction: transaction,
        payload: payload,
        capability: capability,
        transactionStore: _transactionStore,
        readLocation: _readLocation,
        writableLease: writableLease,
      );
      final install = await fileStore.installVerifiedArchiveEntryAtPath(
        archiveDirectoryPath: candidateRootPath,
        sourceBytes: sourceFile.openRead(),
        remediationAuthority: authority,
      );
      if (install.status != AttachmentArchiveFileInstallStatus.installed &&
          install.status != AttachmentArchiveFileInstallStatus.alreadyPresent) {
        throw _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.remediationPending,
          'A missing payload could not be installed without conflict: '
          '${payload.relativePath}',
        );
      }
      filesCompleted++;
      bytesCompleted += payload.expectedSizeBytes;
      onProgress?.call(
        AttachmentArchiveRemediationProgress(
          filesCompleted: filesCompleted,
          totalFiles: totalFiles,
          bytesCompleted: bytesCompleted,
          totalBytes: totalBytes,
        ),
      );
    }
  }

  Future<File> _verifiedRetainedSourceFile({
    required String rootPath,
    required AttachmentArchiveRemediationPayload payload,
  }) async {
    var currentPath = rootPath;
    for (final component in path.split(payload.relativePath)) {
      currentPath = path.join(currentPath, component);
      final type = FileSystemEntity.typeSync(currentPath, followLinks: false);
      if (type == FileSystemEntityType.link ||
          type == FileSystemEntityType.notFound) {
        throw _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.remediationPending,
          'A retained source payload is unavailable: ${payload.relativePath}',
        );
      }
    }
    if (FileSystemEntity.typeSync(currentPath, followLinks: false) !=
        FileSystemEntityType.file) {
      throw _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.remediationPending,
        'A retained source payload is not a regular file: '
        '${payload.relativePath}',
      );
    }
    final file = File(currentPath);
    final resolved = path.normalize(await file.resolveSymbolicLinks());
    if (!path.isWithin(rootPath, resolved) ||
        await file.length() != payload.expectedSizeBytes) {
      throw _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.remediationPending,
        'A retained source payload changed: ${payload.relativePath}',
      );
    }
    return file;
  }

  Future<void> _proveFinalCoverage(
    AttachmentArchiveAdoptionTransaction transaction,
  ) async {
    final verifier = _candidateVerifier;
    if (verifier == null) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.remediationPending,
        'Final archive coverage cannot be verified.',
      );
    }
    final retainedSourcePath = await _resolveRetainedSourcePath(transaction);
    final current = await _readLocation();
    if (retainedSourcePath == null || current.archiveRootPath == null) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.remediationPending,
        'Final archive coverage is waiting for both archives.',
      );
    }
    final sourceState =
        transaction.previousConfiguration.mode ==
            AttachmentArchiveLocationMode.defaultInternal
        ? AttachmentArchiveLocationState.defaultAvailable(
            archiveRootPath: retainedSourcePath,
            configuration: transaction.previousConfiguration,
            generation: transaction.sourceLocationGeneration,
          )
        : AttachmentArchiveLocationState.customAvailable(
            configuration: transaction.previousConfiguration,
            archiveRootPath: retainedSourcePath,
            generation: transaction.sourceLocationGeneration,
          );
    final result = await verifier.verify(
      sourceLocation: sourceState,
      candidate: AttachmentArchiveCandidateAccess(
        directoryPath: current.archiveRootPath!,
        isPhysicallyWritable: true,
      ),
    );
    if (result is! AttachmentArchiveCandidateComplete) {
      throw _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.remediationPending,
        result.issue ?? 'Final archive coverage is incomplete.',
      );
    }
  }

  Future<String?> _resolveRetainedSourcePath(
    AttachmentArchiveAdoptionTransaction transaction,
  ) async {
    final previous = transaction.previousConfiguration;
    String? resolvedPath;
    if (previous.mode == AttachmentArchiveLocationMode.defaultInternal) {
      resolvedPath = _archiveAccessAuthority.resolvePath(
        AttachmentArchiveLocationController.defaultArchiveDirectoryName,
      );
    } else {
      final bookmark = previous.bookmarkDataBase64;
      if (bookmark == null) {
        return null;
      }
      final resolution = await _bookmarkAdapter.resolveBookmark(
        bookmarkDataBase64: bookmark,
      );
      if (resolution.status !=
              AttachmentArchiveBookmarkResolutionStatus.available &&
          resolution.status !=
              AttachmentArchiveBookmarkResolutionStatus.readOnly) {
        return null;
      }
      resolvedPath = resolution.resolvedPath;
    }
    if (resolvedPath == null) {
      return null;
    }
    try {
      final root = await _rootInspector.inspect(
        directoryPath: resolvedPath,
        label: 'retained source archive',
      );
      return root.canonicalPath == transaction.sourceCanonicalIdentity
          ? root.canonicalPath
          : null;
    } on Object {
      return null;
    }
  }

  Future<AttachmentArchiveLocationConfiguration> _createIntendedConfiguration(
    String candidateCanonicalIdentity,
  ) async {
    final creation = await _bookmarkAdapter.createBookmark(
      directoryPath: candidateCanonicalIdentity,
    );
    final createdRoot = await _rootInspector.inspect(
      directoryPath: creation.resolvedPath,
      label: 'created candidate bookmark',
    );
    if (createdRoot.canonicalPath != candidateCanonicalIdentity) {
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
    if (resolvedRoot.canonicalPath != candidateCanonicalIdentity) {
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

  Future<AttachmentArchiveWritableRootLease> _validateSwitchedLocation({
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
    return lease;
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
      AttachmentArchiveApprovalRevalidationOutcome.failed =>
        AttachmentArchiveAdoptionOutcome.failed,
      AttachmentArchiveApprovalRevalidationOutcome
          .verificationEvidenceInvalid =>
        AttachmentArchiveAdoptionOutcome.verificationEvidenceInvalid,
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
