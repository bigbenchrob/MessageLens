import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
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
import 'attachment_archive_approval_added_payload_reader.dart';
import 'attachment_archive_approval_revalidator.dart';
import 'attachment_archive_approval_snapshot_reader.dart';
import 'attachment_archive_bookmark_adapter.dart';
import 'attachment_archive_candidate_verifier.dart';
import 'attachment_archive_file_store.dart';
import 'attachment_archive_location_controller.dart';
import 'attachment_archive_location_provider.dart';
import 'attachment_archive_remediation_authority.dart';
import 'attachment_showcase.dart';

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
    required AttachmentArchiveApprovalAddedPayloadReader addedPayloadReader,
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
    AttachmentShowcaseEventCallback? onShowcaseItem,
  }) : _archiveAccessAuthority = archiveAccessAuthority,
       _mutationCoordinator = mutationCoordinator,
       _currentLocationReader = currentLocationReader,
       _snapshotReader = snapshotReader,
       _addedPayloadReader = addedPayloadReader,
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
       _fileStore = fileStore,
       _onShowcaseItem = onShowcaseItem;

  static const String ownerLabel = 'attachment-archive-adoption';

  final ArchiveAccessAuthority _archiveAccessAuthority;
  final ArchiveMutationCoordinator _mutationCoordinator;
  final AttachmentArchiveApprovalCurrentLocationReader _currentLocationReader;
  final AttachmentArchiveApprovalSnapshotReader _snapshotReader;
  final AttachmentArchiveApprovalAddedPayloadReader _addedPayloadReader;
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
  final AttachmentShowcaseEventCallback? _onShowcaseItem;

  @override
  Future<AttachmentArchiveAdoptionResult> adopt(
    AttachmentArchiveCandidateVerificationResult verification, {
    AttachmentArchiveVerificationProgressCallback? onVerificationProgress,
    AttachmentArchiveRemediationProgressCallback? onRemediationProgress,
    AttachmentArchiveVerificationProgressCallback? onFinalCoverageProgress,
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
          onFinalCoverageProgress: onFinalCoverageProgress,
        );
      },
    );
  }

  @override
  Future<AttachmentArchiveAdoptionResult> resumePendingRemediation({
    AttachmentArchiveRemediationProgressCallback? onRemediationProgress,
    AttachmentArchiveVerificationProgressCallback? onFinalCoverageProgress,
  }) {
    return _mutationCoordinator.runWithCapability(
      operation: ArchiveMutationOperation.attachmentArchiveAdoption,
      ownerLabel: '$ownerLabel-remediation-resume',
      action: (capability) => _resumePendingWithinScope(
        capability: capability,
        onRemediationProgress: onRemediationProgress,
        onFinalCoverageProgress: onFinalCoverageProgress,
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
    AttachmentArchiveVerificationProgressCallback? onFinalCoverageProgress,
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
      final refreshedApproval = await _refreshBehindVerification(
        reviewedVerification: reviewedVerification,
        onProgress: onVerificationProgress,
      );
      final finalVerification = refreshedApproval.verification;
      final evidence = finalVerification.evidence!;
      final previousConfiguration = evidence.sourceLocationConfiguration;
      final intendedConfiguration = refreshedApproval.intendedConfiguration;
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
      await _proveFinalCoverage(
        transaction,
        onProgress: onFinalCoverageProgress,
      );
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

  Future<_RefreshedBehindApproval> _refreshBehindVerification({
    required AttachmentArchiveCandidateBehind reviewedVerification,
    AttachmentArchiveVerificationProgressCallback? onProgress,
  }) async {
    final reviewed = reviewedVerification.evidence;
    final reviewedBaseline = reviewed?.structuralBaseline;
    if (reviewed == null ||
        reviewedBaseline == null ||
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
    if (!reviewed.candidateWasPhysicallyWritable) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.candidateNoLongerWritable,
        'The archive copy is no longer writable.',
      );
    }
    final intendedConfiguration = await _createIntendedConfiguration(
      reviewed.candidateCanonicalIdentity,
    );
    final candidate = AttachmentArchiveCandidateAccess(
      directoryPath: reviewed.candidateCanonicalIdentity,
      isPhysicallyWritable: true,
    );
    final AttachmentArchiveApprovalStructuralSnapshot snapshot;
    try {
      snapshot = await _snapshotReader.read(
        sourceLocation: currentSource,
        candidate: candidate,
        expectedSourceCanonicalIdentity: reviewed.sourceCanonicalIdentity,
        expectedCandidateCanonicalIdentity: reviewed.candidateCanonicalIdentity,
      );
    } on AttachmentArchiveApprovalSnapshotException catch (error) {
      throw _abortForApprovalSnapshot(error);
    }
    if (!_candidateSnapshotStillExact(snapshot, reviewed)) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain,
        'The archive copy changed after it was checked. Check it again.',
      );
    }

    final additions = _requirePureSourceAdditions(
      reviewed: reviewedBaseline.sourceEntries,
      current: snapshot.sourceStructuralBaseline.sourceEntries,
    );
    final addedPayloadEntries = additions
        .where(
          (entry) =>
              entry.kind ==
              AttachmentArchiveStructuralEntryKind.preservationPayload,
        )
        .toList(growable: false);
    if (snapshot.requiredSourcePhysicalFileCount !=
            reviewed.requiredSourcePhysicalFileCount +
                addedPayloadEntries.length ||
        snapshot.requiredSourceBytes !=
            reviewed.requiredSourceBytes +
                addedPayloadEntries.fold<int>(
                  0,
                  (total, entry) => total + entry.sizeBytes,
                )) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.sourceChangedCheckAgain,
        'Changes since review were not solely additive. Check the copy again.',
      );
    }
    final List<AttachmentArchiveVerifiedMissingPayload> addedPayloads;
    try {
      addedPayloads = await _addedPayloadReader.readAddedMissingPayloads(
        sourceLocation: currentSource,
        candidate: candidate,
        expectedSourceCanonicalIdentity: reviewed.sourceCanonicalIdentity,
        expectedCandidateCanonicalIdentity: reviewed.candidateCanonicalIdentity,
        addedEntries: addedPayloadEntries,
      );
    } on AttachmentArchiveApprovalSnapshotException catch (error) {
      throw _abortForApprovalSnapshot(error);
    }
    final finalPayloads = <AttachmentArchiveVerifiedMissingPayload>[
      ...reviewed.missingPayloads,
      ...addedPayloads,
    ]..sort((left, right) => left.relativePath.compareTo(right.relativePath));
    final finalMissingBytes = finalPayloads.fold<int>(
      0,
      (total, payload) => total + payload.expectedSizeBytes,
    );
    if (finalPayloads.length >
            AttachmentArchiveAdoptionTransaction
                .maximumRemediationPayloadCount ||
        finalMissingBytes >
            AttachmentArchiveAdoptionTransaction.maximumRemediationBytes) {
      throw const _AttachmentArchiveAdoptionAbort(
        AttachmentArchiveAdoptionOutcome.verificationEvidenceInvalid,
        'This copy is substantially out of date. Refresh it externally.',
      );
    }

    onProgress?.call(
      AttachmentArchiveVerificationProgress(
        phase: AttachmentArchiveVerificationPhase.preparing,
        filesChecked: snapshot.requiredSourcePhysicalFileCount,
        bytesChecked: snapshot.requiredSourceBytes,
        totalFiles: snapshot.requiredSourcePhysicalFileCount,
        totalBytes: snapshot.requiredSourceBytes,
      ),
    );
    final refreshedContext = AttachmentArchiveCandidateVerificationContext(
      sourceLocationConfiguration: reviewed.sourceLocationConfiguration,
      sourceLocationGeneration: reviewed.sourceLocationGeneration,
      requestedSourcePath: currentSource.archiveRootPath,
      requestedCandidatePath: reviewed.candidateCanonicalIdentity,
      verifiedAtUtc: _clock().toUtc(),
      candidateWasPhysicallyWritable: true,
      sourceCanonicalIdentity: reviewed.sourceCanonicalIdentity,
      candidateCanonicalIdentity: reviewed.candidateCanonicalIdentity,
    );
    final refreshedEvidence = AttachmentArchiveCandidateVerificationEvidence(
      sourceCanonicalIdentity: reviewed.sourceCanonicalIdentity,
      candidateCanonicalIdentity: reviewed.candidateCanonicalIdentity,
      sourceLocationConfiguration: reviewed.sourceLocationConfiguration,
      sourceLocationGeneration: reviewed.sourceLocationGeneration,
      verifiedAtUtc: refreshedContext.verifiedAtUtc,
      candidateWasPhysicallyWritable: true,
      requiredSourcePhysicalFileCount: snapshot.requiredSourcePhysicalFileCount,
      requiredSourceBytes: snapshot.requiredSourceBytes,
      verifiedFileCount: reviewed.verifiedFileCount,
      verifiedBytes: reviewed.verifiedBytes,
      metadataReferenceCount: snapshot.metadataReferenceCount,
      unreferencedPreservationCount: snapshot.unreferencedPreservationCount,
      sourceOperationalDebrisCount: snapshot.sourceOperationalDebrisCount,
      candidateOperationalDebrisCount: snapshot.candidateOperationalDebrisCount,
      allowedCandidateExtraCount: snapshot.allowedCandidateExtraCount,
      allowedCandidateExtraBytes: snapshot.allowedCandidateExtraBytes,
      missingCount: finalPayloads.length,
      missingBytes: finalMissingBytes,
      contentCoverageDigest: _extendCoverageDigest(
        reviewed.contentCoverageDigest,
        snapshot.sourceStructuralSnapshotFingerprint,
        finalPayloads,
      ),
      sourceStructuralSnapshotFingerprint:
          snapshot.sourceStructuralSnapshotFingerprint,
      candidateStructuralSnapshotFingerprint:
          snapshot.candidateStructuralSnapshotFingerprint,
      diagnostics: AttachmentArchiveVerificationDiagnostics(
        missingPathExamples: <String>{
          ...reviewed.diagnostics.missingPathExamples,
          ...addedPayloads.map((payload) => payload.relativePath),
        }.take(100).toList(growable: false),
        conflictingPathExamples: reviewed.diagnostics.conflictingPathExamples,
        allowedExtraPathExamples: reviewed.diagnostics.allowedExtraPathExamples,
        operationalDebrisPathExamples:
            reviewed.diagnostics.operationalDebrisPathExamples,
        sourceAnomalyPathExamples:
            reviewed.diagnostics.sourceAnomalyPathExamples,
      ),
      structuralBaseline: snapshot.sourceStructuralBaseline,
      missingPayloads: List.unmodifiable(finalPayloads),
    );
    return _RefreshedBehindApproval(
      verification: AttachmentArchiveCandidateBehind(
        context: refreshedContext,
        evidence: refreshedEvidence,
      ),
      intendedConfiguration: intendedConfiguration,
    );
  }

  static bool _candidateSnapshotStillExact(
    AttachmentArchiveApprovalStructuralSnapshot snapshot,
    AttachmentArchiveCandidateVerificationEvidence reviewed,
  ) {
    return snapshot.candidateCanonicalIdentity ==
            reviewed.candidateCanonicalIdentity &&
        snapshot.candidateStructuralSnapshotFingerprint ==
            reviewed.candidateStructuralSnapshotFingerprint &&
        snapshot.structurallyMatchedCandidateFileCount ==
            reviewed.verifiedFileCount &&
        snapshot.structurallyMatchedCandidateBytes == reviewed.verifiedBytes &&
        snapshot.candidateOperationalDebrisCount ==
            reviewed.candidateOperationalDebrisCount &&
        snapshot.allowedCandidateExtraCount ==
            reviewed.allowedCandidateExtraCount &&
        snapshot.allowedCandidateExtraBytes ==
            reviewed.allowedCandidateExtraBytes;
  }

  static List<AttachmentArchiveStructuralEntryEvidence>
  _requirePureSourceAdditions({
    required List<AttachmentArchiveStructuralEntryEvidence> reviewed,
    required List<AttachmentArchiveStructuralEntryEvidence> current,
  }) {
    final reviewedByPath = <String, AttachmentArchiveStructuralEntryEvidence>{};
    for (final entry in reviewed) {
      if (reviewedByPath.putIfAbsent(entry.relativePath, () => entry) !=
          entry) {
        throw const _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.verificationEvidenceInvalid,
          'The reviewed source structure is ambiguous.',
        );
      }
    }
    final currentByPath = <String, AttachmentArchiveStructuralEntryEvidence>{};
    for (final entry in current) {
      if (currentByPath.putIfAbsent(entry.relativePath, () => entry) != entry) {
        throw const _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.sourceChangedCheckAgain,
          'The current source structure is ambiguous. Check the copy again.',
        );
      }
    }
    for (final reviewedEntry in reviewed) {
      final currentEntry = currentByPath[reviewedEntry.relativePath];
      if (currentEntry == null ||
          !reviewedEntry.hasSameExistingEvidence(currentEntry)) {
        throw const _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.sourceChangedCheckAgain,
          'Changes since review were not solely additive. Check the copy again.',
        );
      }
    }
    return current
        .where((entry) => !reviewedByPath.containsKey(entry.relativePath))
        .toList(growable: false);
  }

  static String _extendCoverageDigest(
    String reviewedDigest,
    String currentSourceStructuralFingerprint,
    List<AttachmentArchiveVerifiedMissingPayload> finalPayloads,
  ) {
    final encoded = jsonEncode(<Object?>[
      'messagelens-behind-approval-delta-v1',
      reviewedDigest,
      currentSourceStructuralFingerprint,
      for (final payload in finalPayloads)
        <Object?>[
          payload.relativePath,
          payload.expectedSizeBytes,
          payload.expectedSha256,
        ],
    ]);
    return sha256.convert(utf8.encode(encoded)).toString();
  }

  static _AttachmentArchiveAdoptionAbort _abortForApprovalSnapshot(
    AttachmentArchiveApprovalSnapshotException error,
  ) {
    return switch (error.kind) {
      AttachmentArchiveApprovalSnapshotFailureKind.sourceChanged =>
        _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.sourceChangedCheckAgain,
          error.issue,
        ),
      AttachmentArchiveApprovalSnapshotFailureKind.candidateChanged =>
        _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain,
          error.issue,
        ),
      AttachmentArchiveApprovalSnapshotFailureKind.sourceUnavailable =>
        _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.sourceUnavailable,
          error.issue,
        ),
      AttachmentArchiveApprovalSnapshotFailureKind.candidateUnavailable =>
        _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.candidateUnavailable,
          error.issue,
        ),
      AttachmentArchiveApprovalSnapshotFailureKind.failed =>
        _AttachmentArchiveAdoptionAbort(
          AttachmentArchiveAdoptionOutcome.failed,
          error.issue,
        ),
    };
  }

  Future<AttachmentArchiveAdoptionResult> _resumePendingWithinScope({
    required ArchiveMutationCapability capability,
    AttachmentArchiveRemediationProgressCallback? onRemediationProgress,
    AttachmentArchiveVerificationProgressCallback? onFinalCoverageProgress,
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
      await _proveFinalCoverage(
        transaction,
        onProgress: onFinalCoverageProgress,
      );
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
      _publishShowcaseItem(
        candidateRootPath: candidateRootPath,
        payload: payload,
      );
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

  void _publishShowcaseItem({
    required String candidateRootPath,
    required AttachmentArchiveRemediationPayload payload,
  }) {
    final callback = _onShowcaseItem;
    if (callback == null) {
      return;
    }
    final extension = path.extension(payload.relativePath).toLowerCase();
    try {
      callback(
        AttachmentShowcaseItem(
          resolvedPath: path.join(candidateRootPath, payload.relativePath),
          mediaKind: _showcaseMediaKind(extension),
          stablePresentationIdentity: payload.expectedSha256,
          displayFilename: path.basename(payload.relativePath),
          displayType: extension.isEmpty ? null : extension.substring(1),
        ),
      );
    } on Object {
      // Showcase presentation is deliberately outside remediation correctness.
    }
  }

  static AttachmentShowcaseMediaKind _showcaseMediaKind(String extension) {
    if (const <String>{
      '.avif',
      '.bmp',
      '.gif',
      '.heic',
      '.heif',
      '.jpeg',
      '.jpg',
      '.png',
      '.tif',
      '.tiff',
      '.webp',
    }.contains(extension)) {
      return AttachmentShowcaseMediaKind.image;
    }
    if (const <String>{
      '.avi',
      '.m4v',
      '.mov',
      '.mp4',
      '.mpeg',
      '.mpg',
      '.webm',
    }.contains(extension)) {
      return AttachmentShowcaseMediaKind.video;
    }
    if (extension == '.pdf') {
      return AttachmentShowcaseMediaKind.pdf;
    }
    return AttachmentShowcaseMediaKind.other;
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
    AttachmentArchiveAdoptionTransaction transaction, {
    AttachmentArchiveVerificationProgressCallback? onProgress,
  }) async {
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
      onProgress: onProgress,
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

final class _RefreshedBehindApproval {
  const _RefreshedBehindApproval({
    required this.verification,
    required this.intendedConfiguration,
  });

  final AttachmentArchiveCandidateBehind verification;
  final AttachmentArchiveLocationConfiguration intendedConfiguration;
}

final class _AttachmentArchiveAdoptionAbort implements Exception {
  const _AttachmentArchiveAdoptionAbort(this.outcome, this.issue);

  final AttachmentArchiveAdoptionOutcome outcome;
  final String issue;

  @override
  String toString() =>
      'AttachmentArchiveAdoptionAbort(${outcome.name}): $issue';
}
