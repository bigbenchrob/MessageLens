import '../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../../essentials/archive_environment/domain.dart'
    show ArchiveMutationOperation;
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability;
import '../../../essentials/source_scoped_import/domain/messages_lineage_admission.dart';
import '../domain/entities/message_lens_attachment_recovery.dart';
import '../domain/entities/message_lens_attachment_recovery_donor.dart';
import 'attachment_archive_file_store.dart';
import 'attachment_archive_location_provider.dart';
import 'message_lens_attachment_evidence_reader.dart';
import 'message_lens_attachment_recovery_installer.dart';
import 'message_lens_attachment_recovery_matcher.dart';
import 'verified_donor_attachment_payload.dart';

enum MessageLensAttachmentRecoveryBatchStage {
  verifyingDonorPayloads,
  installingPayloads,
  finalVerification,
  complete,
}

enum MessageLensAttachmentRecoveryItemStatus {
  installed,
  alreadyPresent,
  conflict,
  donorMissing,
  donorChanged,
  verificationFailed,
  metadataUpdateFailed,
  messageMismatch,
  attachmentMismatch,
  ambiguous,
  unsafeSource,
  deferred,
}

final class MessageLensAttachmentRecoveryBatchProgress {
  const MessageLensAttachmentRecoveryBatchProgress({
    required this.stage,
    required this.totalAttachments,
    required this.verifiedAttachments,
    required this.processedAttachments,
    required this.recoveredAttachments,
    required this.totalBytes,
    required this.verifiedBytes,
    required this.copiedBytes,
    required this.terminallyVerifiedAttachments,
  });

  final MessageLensAttachmentRecoveryBatchStage stage;
  final int totalAttachments;
  final int verifiedAttachments;
  final int processedAttachments;
  final int recoveredAttachments;
  final int totalBytes;
  final int verifiedBytes;
  final int copiedBytes;
  final int terminallyVerifiedAttachments;
}

final class MessageLensAttachmentRecoveryItemOutcome {
  const MessageLensAttachmentRecoveryItemOutcome({
    required this.candidate,
    required this.status,
    required this.installedBytes,
    required this.archiveRelativePath,
    this.deferredReason,
  });

  final MessageLensAttachmentRecoveryCandidate candidate;
  final MessageLensAttachmentRecoveryItemStatus status;
  final int installedBytes;
  final String? archiveRelativePath;
  final AttachmentArchiveMutationDeferredReason? deferredReason;

  bool get recovered =>
      status == MessageLensAttachmentRecoveryItemStatus.installed;

  bool get physicallySatisfied =>
      status == MessageLensAttachmentRecoveryItemStatus.installed ||
      status == MessageLensAttachmentRecoveryItemStatus.alreadyPresent;
}

final class MessageLensAttachmentRecoveryBatchResult {
  const MessageLensAttachmentRecoveryBatchResult({
    required this.outcomes,
    required this.recoveredCount,
    required this.recoveredBytes,
    required this.alreadyPresentCount,
    required this.couldNotRecoverCount,
    required this.terminallyVerifiedCount,
    required this.remainingRecoverableCount,
    this.deferredReason,
  });

  final List<MessageLensAttachmentRecoveryItemOutcome> outcomes;
  final int recoveredCount;
  final int recoveredBytes;
  final int alreadyPresentCount;
  final int couldNotRecoverCount;
  final int terminallyVerifiedCount;
  final int remainingRecoverableCount;
  final AttachmentArchiveMutationDeferredReason? deferredReason;

  bool get isDeferred => deferredReason != null;

  bool get fullyRecovered =>
      !isDeferred &&
      couldNotRecoverCount == 0 &&
      remainingRecoverableCount == 0 &&
      terminallyVerifiedCount == outcomes.length;
}

typedef MessageLensAttachmentRecoveryBatchProgressObserver =
    void Function(MessageLensAttachmentRecoveryBatchProgress progress);

abstract interface class MessageLensAttachmentRecoveryBatchRunner {
  Future<MessageLensAttachmentRecoveryBatchResult> execute({
    required ArchiveMutationCapability mutationCapability,
    required MessageLensAttachmentRecoveryDonor donor,
    required SameMessagesLineageAdmission lineageAdmission,
    required MessageLensAttachmentRecoveryPreflight preflight,
    required List<MessageLensAttachmentRecoveryCandidate>
    preflightApprovedCandidates,
    MessageLensAttachmentRecoveryBatchProgressObserver? onProgress,
  });
}

/// Canonical batch orchestration above the preservation-safe single installer.
///
/// The executor accepts only the exact recoverable set emitted by a completed
/// preflight. It rereads and revalidates that evidence, hashes only candidates
/// that remain missing, and never installs outside the approved set.
final class MessageLensAttachmentRecoveryBatchExecutor
    implements MessageLensAttachmentRecoveryBatchRunner {
  const MessageLensAttachmentRecoveryBatchExecutor({
    required MessageLensDonorAttachmentEvidenceReader donorEvidenceReader,
    required CurrentMessageLensAttachmentEvidenceReader currentEvidenceReader,
    required MessageLensAttachmentRecoveryPayloadVerifier payloadVerifier,
    required MessageLensAttachmentRecoveryInstaller installer,
    required AttachmentArchiveFileStore fileStore,
    required AttachmentArchiveWritableRootLease writableRootLease,
    MessageLensAttachmentRecoveryMatcher matcher =
        const MessageLensAttachmentRecoveryMatcher(),
  }) : _donorEvidenceReader = donorEvidenceReader,
       _currentEvidenceReader = currentEvidenceReader,
       _payloadVerifier = payloadVerifier,
       _installer = installer,
       _fileStore = fileStore,
       _writableRootLease = writableRootLease,
       _matcher = matcher;

  final MessageLensDonorAttachmentEvidenceReader _donorEvidenceReader;
  final CurrentMessageLensAttachmentEvidenceReader _currentEvidenceReader;
  final MessageLensAttachmentRecoveryPayloadVerifier _payloadVerifier;
  final MessageLensAttachmentRecoveryInstaller _installer;
  final AttachmentArchiveFileStore _fileStore;
  final AttachmentArchiveWritableRootLease _writableRootLease;
  final MessageLensAttachmentRecoveryMatcher _matcher;

  @override
  Future<MessageLensAttachmentRecoveryBatchResult> execute({
    required ArchiveMutationCapability mutationCapability,
    required MessageLensAttachmentRecoveryDonor donor,
    required SameMessagesLineageAdmission lineageAdmission,
    required MessageLensAttachmentRecoveryPreflight preflight,
    required List<MessageLensAttachmentRecoveryCandidate>
    preflightApprovedCandidates,
    MessageLensAttachmentRecoveryBatchProgressObserver? onProgress,
  }) async {
    mutationCapability.requireOperation(
      ArchiveMutationOperation.attachmentReconciliation,
    );
    final initialValidation = await _writableRootLease.validate(
      operation: ArchiveMutationOperation.attachmentReconciliation,
      boundary: AttachmentArchiveMutationBoundary.operationStart,
    );
    if (!initialValidation.isValid) {
      return _deferredBatchResult(
        reason: initialValidation.deferredReason!,
        candidates: preflightApprovedCandidates,
      );
    }
    _requireExactApprovedSet(
      preflight: preflight,
      approved: preflightApprovedCandidates,
    );
    if (!preflight.classificationCountsReconcile) {
      throw StateError(
        'Attachment preflight classifications do not reconcile.',
      );
    }

    final totalBytes = preflightApprovedCandidates.fold<int>(
      0,
      (sum, candidate) => sum + candidate.recoverableBytes,
    );
    var verifiedAttachments = 0;
    var processedAttachments = 0;
    var recoveredAttachments = 0;
    var verifiedBytes = 0;
    var copiedBytes = 0;
    var terminallyVerifiedAttachments = 0;
    var stage = MessageLensAttachmentRecoveryBatchStage.verifyingDonorPayloads;
    void publish() {
      onProgress?.call(
        MessageLensAttachmentRecoveryBatchProgress(
          stage: stage,
          totalAttachments: preflightApprovedCandidates.length,
          verifiedAttachments: verifiedAttachments,
          processedAttachments: processedAttachments,
          recoveredAttachments: recoveredAttachments,
          totalBytes: totalBytes,
          verifiedBytes: verifiedBytes,
          copiedBytes: copiedBytes,
          terminallyVerifiedAttachments: terminallyVerifiedAttachments,
        ),
      );
    }

    publish();
    await _donorEvidenceReader.validateExecutionIntegrity();
    mutationCapability.requireOperation(
      ArchiveMutationOperation.attachmentReconciliation,
    );
    final postDonorValidation = await _writableRootLease.validate(
      operation: ArchiveMutationOperation.attachmentReconciliation,
      boundary: AttachmentArchiveMutationBoundary.beforeSourceRead,
    );
    if (!postDonorValidation.isValid) {
      return _deferredBatchResult(
        reason: postDonorValidation.deferredReason!,
        candidates: preflightApprovedCandidates,
      );
    }

    final evidence = await _loadExecutionEvidence(preflightApprovedCandidates);
    final outcomes = <MessageLensAttachmentRecoveryItemOutcome>[];
    final verified = <_VerifiedBatchCandidate>[];
    for (final candidate in preflightApprovedCandidates) {
      mutationCapability.requireOperation(
        ArchiveMutationOperation.attachmentReconciliation,
      );
      final revalidated = await _revalidateCandidate(
        candidate: candidate,
        donorRoot: donor.rootPath,
        lineageAdmission: lineageAdmission,
        evidence: evidence,
      );
      if (revalidated.classification !=
          MessageLensAttachmentRecoveryClassification.recoverable) {
        outcomes.add(
          _outcomeForClassification(candidate, revalidated.classification),
        );
        verifiedAttachments += 1;
        processedAttachments += 1;
        publish();
        continue;
      }

      final verificationBase = verifiedBytes;
      var lastPublishedBytes = verificationBase;
      final verifiedPayload = await _payloadVerifier.inspectVerified(
        donorArchiveRoot: donor.rootPath,
        payload: revalidated.payload,
        onBytesProcessed: (itemBytes) {
          verifiedBytes = verificationBase + itemBytes;
          if (verifiedBytes - lastPublishedBytes >= 1024 * 1024 ||
              itemBytes == candidate.recoverableBytes) {
            lastPublishedBytes = verifiedBytes;
            publish();
          }
        },
      );
      final payload = verifiedPayload.payload;
      final postVerificationValidation = await _writableRootLease.validate(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        boundary: AttachmentArchiveMutationBoundary.afterSourceHash,
      );
      if (!postVerificationValidation.isValid) {
        return _deferredBatchResult(
          reason: postVerificationValidation.deferredReason!,
          candidates: preflightApprovedCandidates,
          outcomes: outcomes,
        );
      }
      if (payload == null) {
        outcomes.add(
          MessageLensAttachmentRecoveryItemOutcome(
            candidate: candidate,
            status: _statusForInspection(verifiedPayload.inspection),
            installedBytes: 0,
            archiveRelativePath: null,
          ),
        );
        verifiedAttachments += 1;
        processedAttachments += 1;
        publish();
        continue;
      }
      final preflightHash = candidate.donorPayloadSha256?.trim().toLowerCase();
      if (!_candidateStillMatches(candidate, revalidated.candidate) ||
          (preflightHash != null &&
              preflightHash.isNotEmpty &&
              preflightHash != payload.expectedSha256.toLowerCase())) {
        outcomes.add(
          MessageLensAttachmentRecoveryItemOutcome(
            candidate: candidate,
            status: MessageLensAttachmentRecoveryItemStatus.donorChanged,
            installedBytes: 0,
            archiveRelativePath: null,
          ),
        );
        verifiedAttachments += 1;
        processedAttachments += 1;
        publish();
        continue;
      }
      verified.add(
        _VerifiedBatchCandidate(candidate: candidate, payload: payload),
      );
      verifiedAttachments += 1;
      publish();
    }

    stage = MessageLensAttachmentRecoveryBatchStage.installingPayloads;
    publish();
    for (final item in verified) {
      mutationCapability.requireOperation(
        ArchiveMutationOperation.attachmentReconciliation,
      );
      final copyBase = copiedBytes;
      var lastPublishedBytes = copyBase;
      final observedPayload = _ObservedVerifiedDonorAttachmentPayload(
        delegate: item.payload,
        onBytesRead: (itemBytes) {
          copiedBytes = copyBase + itemBytes;
          if (copiedBytes - lastPublishedBytes >= 1024 * 1024 ||
              itemBytes == item.payload.expectedSizeBytes) {
            lastPublishedBytes = copiedBytes;
            publish();
          }
        },
      );
      final installation = await _installer.install(
        mutationCapability: mutationCapability,
        candidate: item.candidate,
        donorPayload: observedPayload,
      );
      final outcome = MessageLensAttachmentRecoveryItemOutcome(
        candidate: item.candidate,
        status: _statusForInstallation(installation.status),
        installedBytes: installation.installedBytes,
        archiveRelativePath: installation.archiveRelativePath,
        deferredReason: installation.deferredReason,
      );
      outcomes.add(outcome);
      processedAttachments += 1;
      if (installation.deferredReason != null) {
        return _deferredBatchResult(
          reason: installation.deferredReason!,
          candidates: preflightApprovedCandidates,
          outcomes: outcomes,
        );
      }
      if (outcome.recovered) {
        recoveredAttachments += 1;
      }
      publish();
    }

    stage = MessageLensAttachmentRecoveryBatchStage.finalVerification;
    publish();
    final beforeFinalVerification = await _writableRootLease.validate(
      operation: ArchiveMutationOperation.attachmentReconciliation,
      boundary: AttachmentArchiveMutationBoundary.beforePayloadVerification,
    );
    if (!beforeFinalVerification.isValid) {
      return _deferredBatchResult(
        reason: beforeFinalVerification.deferredReason!,
        candidates: preflightApprovedCandidates,
        outcomes: outcomes,
      );
    }
    final finalStatuses = await _currentEvidenceReader.readPayloadStatuses([
      for (final candidate in preflightApprovedCandidates)
        candidate.archiveCompatibilityKey,
    ]);
    final verifiedByKey = <String, _VerifiedBatchCandidate>{
      for (final item in verified)
        item.candidate.archiveCompatibilityKey.storageKeySegment: item,
    };
    for (final outcome in outcomes) {
      final key = outcome.candidate.archiveCompatibilityKey;
      final verifiedItem = verifiedByKey[key.storageKeySegment];
      if (!outcome.physicallySatisfied ||
          finalStatuses[key] != CurrentAttachmentPayloadStatus.presentValid) {
        continue;
      }
      if (verifiedItem == null) {
        // Execution-time revalidation established that this payload was
        // already present. It deliberately was not hashed or copied.
        terminallyVerifiedAttachments += 1;
        publish();
        continue;
      }
      if (outcome.archiveRelativePath == null) {
        continue;
      }
      final beforeIntegrity = await _writableRootLease.validate(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        boundary: AttachmentArchiveMutationBoundary.beforePayloadVerification,
      );
      if (!beforeIntegrity.isValid) {
        return _deferredBatchResult(
          reason: beforeIntegrity.deferredReason!,
          candidates: preflightApprovedCandidates,
          outcomes: outcomes,
        );
      }
      final integrity = await _fileStore.checkIntegrity(
        archiveDirectoryPath: _writableRootLease.archiveRootPath,
        relativePath: outcome.archiveRelativePath!,
        storedHash: verifiedItem.payload.expectedSha256,
      );
      final afterIntegrity = await _writableRootLease.validate(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        boundary: AttachmentArchiveMutationBoundary.beforeMetadataCommit,
      );
      if (!afterIntegrity.isValid) {
        return _deferredBatchResult(
          reason: afterIntegrity.deferredReason!,
          candidates: preflightApprovedCandidates,
          outcomes: outcomes,
        );
      }
      if (integrity.fileExists &&
          integrity.actualSizeBytes == verifiedItem.payload.expectedSizeBytes &&
          integrity.hashMatches == true) {
        terminallyVerifiedAttachments += 1;
        publish();
      }
    }

    final remainingRecoverable = await _countRemainingRecoverable(
      donorRoot: donor.rootPath,
      lineageAdmission: lineageAdmission,
      candidates: preflightApprovedCandidates,
      evidence: evidence,
      currentStatuses: finalStatuses,
    );
    stage = MessageLensAttachmentRecoveryBatchStage.complete;
    publish();

    final recoveredCount = outcomes
        .where((outcome) => outcome.recovered)
        .length;
    final alreadyPresentCount = outcomes
        .where(
          (outcome) =>
              outcome.status ==
              MessageLensAttachmentRecoveryItemStatus.alreadyPresent,
        )
        .length;
    return MessageLensAttachmentRecoveryBatchResult(
      outcomes: List<MessageLensAttachmentRecoveryItemOutcome>.unmodifiable(
        outcomes,
      ),
      recoveredCount: recoveredCount,
      recoveredBytes: outcomes.fold<int>(
        0,
        (sum, outcome) => sum + outcome.installedBytes,
      ),
      alreadyPresentCount: alreadyPresentCount,
      couldNotRecoverCount:
          outcomes.length - recoveredCount - alreadyPresentCount,
      terminallyVerifiedCount: terminallyVerifiedAttachments,
      remainingRecoverableCount: remainingRecoverable,
    );
  }

  static MessageLensAttachmentRecoveryBatchResult _deferredBatchResult({
    required AttachmentArchiveMutationDeferredReason reason,
    required List<MessageLensAttachmentRecoveryCandidate> candidates,
    List<MessageLensAttachmentRecoveryItemOutcome> outcomes = const [],
  }) {
    final recoveredCount = outcomes
        .where((outcome) => outcome.recovered)
        .length;
    final alreadyPresentCount = outcomes
        .where(
          (outcome) =>
              outcome.status ==
              MessageLensAttachmentRecoveryItemStatus.alreadyPresent,
        )
        .length;
    final deferredCount = outcomes
        .where(
          (outcome) =>
              outcome.status ==
              MessageLensAttachmentRecoveryItemStatus.deferred,
        )
        .length;
    return MessageLensAttachmentRecoveryBatchResult(
      outcomes: List<MessageLensAttachmentRecoveryItemOutcome>.unmodifiable(
        outcomes,
      ),
      recoveredCount: recoveredCount,
      recoveredBytes: outcomes.fold<int>(
        0,
        (sum, outcome) => sum + outcome.installedBytes,
      ),
      alreadyPresentCount: alreadyPresentCount,
      couldNotRecoverCount:
          outcomes.length -
          recoveredCount -
          alreadyPresentCount -
          deferredCount,
      terminallyVerifiedCount: 0,
      remainingRecoverableCount:
          candidates.length - outcomes.length + deferredCount,
      deferredReason: reason,
    );
  }

  Future<_ExecutionEvidence> _loadExecutionEvidence(
    List<MessageLensAttachmentRecoveryCandidate> candidates,
  ) async {
    final donorRelationships = await _donorEvidenceReader
        .readLiveSourceRelationships();
    final currentRelationships = await _currentEvidenceReader
        .readLiveSourceRelationships();
    final donorClaims = await _donorEvidenceReader.readArchivedPayloadClaims();
    final currentStatuses = await _currentEvidenceReader.readPayloadStatuses([
      for (final candidate in candidates) candidate.archiveCompatibilityKey,
    ]);
    return _ExecutionEvidence(
      donorRelationships: donorRelationships,
      currentRelationships: currentRelationships,
      donorClaims: donorClaims,
      currentStatuses: currentStatuses,
    );
  }

  Future<_RevalidatedCandidate> _revalidateCandidate({
    required MessageLensAttachmentRecoveryCandidate candidate,
    required String donorRoot,
    required SameMessagesLineageAdmission lineageAdmission,
    required _ExecutionEvidence evidence,
    Map<ArchiveCompatibilityKey, CurrentAttachmentPayloadStatus>?
    currentStatuses,
  }) async {
    final key = candidate.archiveCompatibilityKey;
    final claims = evidence.donorClaims
        .where((claim) => claim.archiveCompatibilityKey == key)
        .toList(growable: false);
    final donorRelationships = evidence.donorRelationships
        .where((relationship) => relationship.archiveCompatibilityKey == key)
        .toList(growable: false);
    if (claims.length != 1 || donorRelationships.length != 1) {
      return _RevalidatedCandidate(
        candidate: candidate,
        payload: claims.isEmpty
            ? MessageLensArchivedPayloadEvidence(
                archiveRelativePath: candidate.donorArchiveRelativePath,
                recordedSizeBytes: candidate.recoverableBytes,
                recordedSha256: candidate.donorPayloadSha256,
              )
            : claims.first.payload,
        classification: MessageLensAttachmentRecoveryClassification.ambiguous,
      );
    }
    final donorRelationship = donorRelationships.single;
    final payload = claims.single.payload;
    final currentCandidates = evidence.currentRelationships
        .where(
          (relationship) =>
              relationship.originalMessageRowId ==
                  donorRelationship.originalMessageRowId &&
              relationship.originalAttachmentRowId ==
                  donorRelationship.originalAttachmentRowId,
        )
        .toList(growable: false);
    final inspection = await _payloadVerifier.inspect(
      donorArchiveRoot: donorRoot,
      payload: payload,
    );
    final matched = _matcher.inspect(
      lineageAdmission: lineageAdmission,
      inputs: [
        MessageLensAttachmentRecoveryInput(
          donorRelationship: donorRelationship,
          currentRelationshipCandidates: currentCandidates,
          donorPayload: payload,
          donorPayloadInspection: inspection,
          currentPayloadStatus:
              (currentStatuses ?? evidence.currentStatuses)[key] ??
              CurrentAttachmentPayloadStatus.inaccessible,
        ),
      ],
    );
    final freshCandidate = matched.candidates.single;
    return _RevalidatedCandidate(
      candidate: freshCandidate,
      payload: payload,
      classification: freshCandidate.classification,
    );
  }

  Future<int> _countRemainingRecoverable({
    required String donorRoot,
    required SameMessagesLineageAdmission lineageAdmission,
    required List<MessageLensAttachmentRecoveryCandidate> candidates,
    required _ExecutionEvidence evidence,
    required Map<ArchiveCompatibilityKey, CurrentAttachmentPayloadStatus>
    currentStatuses,
  }) async {
    var remaining = 0;
    for (final candidate in candidates) {
      final revalidated = await _revalidateCandidate(
        candidate: candidate,
        donorRoot: donorRoot,
        lineageAdmission: lineageAdmission,
        evidence: evidence,
        currentStatuses: currentStatuses,
      );
      if (revalidated.classification ==
          MessageLensAttachmentRecoveryClassification.recoverable) {
        remaining += 1;
      }
    }
    return remaining;
  }

  static void _requireExactApprovedSet({
    required MessageLensAttachmentRecoveryPreflight preflight,
    required List<MessageLensAttachmentRecoveryCandidate> approved,
  }) {
    final expected = preflight.candidates
        .where(
          (candidate) =>
              candidate.classification ==
              MessageLensAttachmentRecoveryClassification.recoverable,
        )
        .map(_candidateFingerprint)
        .toSet();
    final actual = approved.map(_candidateFingerprint).toSet();
    if (expected.length != approved.length ||
        actual.length != approved.length ||
        expected.length != actual.length ||
        !expected.containsAll(actual)) {
      throw StateError(
        'Recovery candidates must equal the completed preflight recoverable set.',
      );
    }
  }

  static String _candidateFingerprint(
    MessageLensAttachmentRecoveryCandidate candidate,
  ) {
    return '${candidate.archiveCompatibilityKey.storageKeySegment}|'
        '${candidate.classification.name}|${candidate.recoverableBytes}|'
        '${candidate.donorArchiveRelativePath}|'
        '${candidate.donorPayloadSha256?.toLowerCase() ?? ''}';
  }

  static bool _candidateStillMatches(
    MessageLensAttachmentRecoveryCandidate original,
    MessageLensAttachmentRecoveryCandidate fresh,
  ) {
    return original.archiveCompatibilityKey == fresh.archiveCompatibilityKey &&
        original.classification == fresh.classification &&
        original.recoverableBytes == fresh.recoverableBytes &&
        original.donorArchiveRelativePath == fresh.donorArchiveRelativePath;
  }

  static MessageLensAttachmentRecoveryItemOutcome _outcomeForClassification(
    MessageLensAttachmentRecoveryCandidate candidate,
    MessageLensAttachmentRecoveryClassification classification,
  ) {
    final status = switch (classification) {
      MessageLensAttachmentRecoveryClassification.alreadyPresent =>
        MessageLensAttachmentRecoveryItemStatus.alreadyPresent,
      MessageLensAttachmentRecoveryClassification.donorMissing =>
        MessageLensAttachmentRecoveryItemStatus.donorMissing,
      MessageLensAttachmentRecoveryClassification.messageMismatch =>
        MessageLensAttachmentRecoveryItemStatus.messageMismatch,
      MessageLensAttachmentRecoveryClassification.attachmentMismatch =>
        MessageLensAttachmentRecoveryItemStatus.attachmentMismatch,
      MessageLensAttachmentRecoveryClassification.conflict =>
        MessageLensAttachmentRecoveryItemStatus.conflict,
      MessageLensAttachmentRecoveryClassification.ambiguous =>
        MessageLensAttachmentRecoveryItemStatus.ambiguous,
      MessageLensAttachmentRecoveryClassification.unsafeDonorPath =>
        MessageLensAttachmentRecoveryItemStatus.unsafeSource,
      MessageLensAttachmentRecoveryClassification.recoverable =>
        throw StateError(
          'Recoverable candidates require payload verification.',
        ),
    };
    return MessageLensAttachmentRecoveryItemOutcome(
      candidate: candidate,
      status: status,
      installedBytes: 0,
      archiveRelativePath: null,
    );
  }

  static MessageLensAttachmentRecoveryItemStatus _statusForInspection(
    AttachmentPayloadInspection inspection,
  ) {
    return switch (inspection.status) {
      AttachmentPayloadInspectionStatus.missing =>
        MessageLensAttachmentRecoveryItemStatus.donorMissing,
      AttachmentPayloadInspectionStatus.unsafePath =>
        MessageLensAttachmentRecoveryItemStatus.unsafeSource,
      AttachmentPayloadInspectionStatus.invalid ||
      AttachmentPayloadInspectionStatus.valid =>
        MessageLensAttachmentRecoveryItemStatus.donorChanged,
    };
  }

  static MessageLensAttachmentRecoveryItemStatus _statusForInstallation(
    MessageLensAttachmentInstallationStatus status,
  ) {
    return switch (status) {
      MessageLensAttachmentInstallationStatus.installed =>
        MessageLensAttachmentRecoveryItemStatus.installed,
      MessageLensAttachmentInstallationStatus.alreadyPresent =>
        MessageLensAttachmentRecoveryItemStatus.alreadyPresent,
      MessageLensAttachmentInstallationStatus.conflict =>
        MessageLensAttachmentRecoveryItemStatus.conflict,
      MessageLensAttachmentInstallationStatus.donorMissing =>
        MessageLensAttachmentRecoveryItemStatus.donorMissing,
      MessageLensAttachmentInstallationStatus.donorChanged =>
        MessageLensAttachmentRecoveryItemStatus.donorChanged,
      MessageLensAttachmentInstallationStatus.verificationFailed =>
        MessageLensAttachmentRecoveryItemStatus.verificationFailed,
      MessageLensAttachmentInstallationStatus.unsafeSource =>
        MessageLensAttachmentRecoveryItemStatus.unsafeSource,
      MessageLensAttachmentInstallationStatus.metadataUpdateFailed =>
        MessageLensAttachmentRecoveryItemStatus.metadataUpdateFailed,
      MessageLensAttachmentInstallationStatus.deferred =>
        MessageLensAttachmentRecoveryItemStatus.deferred,
    };
  }
}

final class DeferredMessageLensAttachmentRecoveryBatchRunner
    implements MessageLensAttachmentRecoveryBatchRunner {
  const DeferredMessageLensAttachmentRecoveryBatchRunner(this.reason);

  final AttachmentArchiveMutationDeferredReason reason;

  @override
  Future<MessageLensAttachmentRecoveryBatchResult> execute({
    required ArchiveMutationCapability mutationCapability,
    required MessageLensAttachmentRecoveryDonor donor,
    required SameMessagesLineageAdmission lineageAdmission,
    required MessageLensAttachmentRecoveryPreflight preflight,
    required List<MessageLensAttachmentRecoveryCandidate>
    preflightApprovedCandidates,
    MessageLensAttachmentRecoveryBatchProgressObserver? onProgress,
  }) async {
    mutationCapability.requireOperation(
      ArchiveMutationOperation.attachmentReconciliation,
    );
    return MessageLensAttachmentRecoveryBatchExecutor._deferredBatchResult(
      reason: reason,
      candidates: preflightApprovedCandidates,
    );
  }
}

abstract interface class MessageLensAttachmentRecoveryPayloadVerifier {
  Future<AttachmentPayloadInspection> inspect({
    required String donorArchiveRoot,
    required MessageLensArchivedPayloadEvidence payload,
  });

  Future<VerifiedDonorAttachmentPayloadResult> inspectVerified({
    required String donorArchiveRoot,
    required MessageLensArchivedPayloadEvidence payload,
    void Function(int bytesProcessed)? onBytesProcessed,
  });
}

final class VerifiedDonorAttachmentPayloadResult {
  const VerifiedDonorAttachmentPayloadResult({
    required this.inspection,
    required this.payload,
  });

  final AttachmentPayloadInspection inspection;
  final VerifiedDonorAttachmentPayload? payload;
}

final class _ExecutionEvidence {
  const _ExecutionEvidence({
    required this.donorRelationships,
    required this.currentRelationships,
    required this.donorClaims,
    required this.currentStatuses,
  });

  final List<MessageLensAttachmentRelationshipEvidence> donorRelationships;
  final List<MessageLensAttachmentRelationshipEvidence> currentRelationships;
  final List<MessageLensArchivedPayloadClaim> donorClaims;
  final Map<ArchiveCompatibilityKey, CurrentAttachmentPayloadStatus>
  currentStatuses;
}

final class _RevalidatedCandidate {
  const _RevalidatedCandidate({
    required this.candidate,
    required this.payload,
    required this.classification,
  });

  final MessageLensAttachmentRecoveryCandidate candidate;
  final MessageLensArchivedPayloadEvidence payload;
  final MessageLensAttachmentRecoveryClassification classification;
}

final class _VerifiedBatchCandidate {
  const _VerifiedBatchCandidate({
    required this.candidate,
    required this.payload,
  });

  final MessageLensAttachmentRecoveryCandidate candidate;
  final VerifiedDonorAttachmentPayload payload;
}

final class _ObservedVerifiedDonorAttachmentPayload
    implements VerifiedDonorAttachmentPayload {
  const _ObservedVerifiedDonorAttachmentPayload({
    required VerifiedDonorAttachmentPayload delegate,
    required void Function(int bytesRead) onBytesRead,
  }) : _delegate = delegate,
       _onBytesRead = onBytesRead;

  final VerifiedDonorAttachmentPayload _delegate;
  final void Function(int bytesRead) _onBytesRead;

  @override
  String get archiveRelativePath => _delegate.archiveRelativePath;

  @override
  int get expectedSizeBytes => _delegate.expectedSizeBytes;

  @override
  String get expectedSha256 => _delegate.expectedSha256;

  @override
  String get sourceExtension => _delegate.sourceExtension;

  @override
  Stream<List<int>> openRead() async* {
    var bytesRead = 0;
    await for (final chunk in _delegate.openRead()) {
      bytesRead += chunk.length;
      _onBytesRead(bytesRead);
      yield chunk;
    }
  }
}
