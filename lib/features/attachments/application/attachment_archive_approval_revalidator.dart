import '../../../essentials/archive_environment/domain/archive_mutation_operation.dart';
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability, ArchiveMutationCoordinator;
import '../domain/entities/attachment_archive_approval_revalidation.dart';
import '../domain/entities/attachment_archive_candidate_verification.dart';
import '../domain/entities/attachment_archive_location_state.dart';
import 'attachment_archive_approval_snapshot_reader.dart';

abstract interface class AttachmentArchiveApprovalCurrentLocationReader {
  Future<AttachmentArchiveLocationState> readCurrentLocation();
}

sealed class AttachmentArchiveApprovalCandidateAccessResult {
  const AttachmentArchiveApprovalCandidateAccessResult();
}

final class AttachmentArchiveApprovalCandidateAvailable
    extends AttachmentArchiveApprovalCandidateAccessResult {
  const AttachmentArchiveApprovalCandidateAvailable(this.access);

  final AttachmentArchiveCandidateAccess access;
}

final class AttachmentArchiveApprovalCandidateUnavailable
    extends AttachmentArchiveApprovalCandidateAccessResult {
  const AttachmentArchiveApprovalCandidateUnavailable(this.issue);

  final String issue;
}

/// Re-resolves bounded native candidate availability for one verified result.
///
/// A future bookmark-backed implementation must resolve from application-owned
/// selection state. The remembered display path is never authority.
abstract interface class AttachmentArchiveApprovalCandidateAccessReader {
  Future<AttachmentArchiveApprovalCandidateAccessResult> readCurrentAccess(
    AttachmentArchiveCandidateComplete verification,
  );
}

/// Opaque proof that one exact ready result was produced in the active scope.
///
/// Only this library can construct implementations. The proof cannot be
/// serialized and expires with the coordinator capability that produced it.
sealed class AttachmentArchiveApprovalScopeProof {
  const AttachmentArchiveApprovalScopeProof._({
    required AttachmentArchiveApprovalReadyEvidence readyEvidence,
    required ArchiveMutationCapability capability,
  }) : _readyEvidence = readyEvidence,
       _capability = capability;

  final AttachmentArchiveApprovalReadyEvidence _readyEvidence;
  final ArchiveMutationCapability _capability;

  void requireExactReadyEvidence({
    required AttachmentArchiveApprovalReadyEvidence readyEvidence,
    required ArchiveMutationCapability capability,
  }) {
    capability.requireOperation(
      ArchiveMutationOperation.attachmentArchiveAdoption,
    );
    _capability.requireOperation(
      ArchiveMutationOperation.attachmentArchiveAdoption,
    );
    if (!identical(capability, _capability) ||
        !identical(readyEvidence, _readyEvidence)) {
      throw StateError(
        'Archive approval scope proof belongs to another revalidation.',
      );
    }
  }
}

final class _AttachmentArchiveApprovalScopeProof
    extends AttachmentArchiveApprovalScopeProof {
  const _AttachmentArchiveApprovalScopeProof({
    required super.readyEvidence,
    required super.capability,
  }) : super._();
}

final class AttachmentArchiveScopedApprovalRevalidation {
  const AttachmentArchiveScopedApprovalRevalidation({
    required this.result,
    this.scopeProof,
  });

  final AttachmentArchiveApprovalRevalidationResult result;
  final AttachmentArchiveApprovalScopeProof? scopeProof;
}

/// Performs the short approval-time comparison while archive mutation is held.
///
/// [revalidate] acquires and releases coordination around this checkpoint-only
/// operation. Checkpoint Four can instead acquire the same operation once,
/// call [revalidateWithinApprovalScope], and continue into adoption without
/// releasing the coordinator between the fresh check and configuration switch.
final class AttachmentArchiveApprovalRevalidator {
  AttachmentArchiveApprovalRevalidator({
    required ArchiveMutationCoordinator mutationCoordinator,
    required AttachmentArchiveApprovalCurrentLocationReader
    currentLocationReader,
    required AttachmentArchiveApprovalCandidateAccessReader
    candidateAccessReader,
    required AttachmentArchiveApprovalSnapshotReader snapshotReader,
    DateTime Function()? clock,
  }) : _mutationCoordinator = mutationCoordinator,
       _currentLocationReader = currentLocationReader,
       _candidateAccessReader = candidateAccessReader,
       _snapshotReader = snapshotReader,
       _clock = clock ?? _utcNow;

  static const String ownerLabel = 'attachment-archive-adoption-approval';

  final ArchiveMutationCoordinator _mutationCoordinator;
  final AttachmentArchiveApprovalCurrentLocationReader _currentLocationReader;
  final AttachmentArchiveApprovalCandidateAccessReader _candidateAccessReader;
  final AttachmentArchiveApprovalSnapshotReader _snapshotReader;
  final DateTime Function() _clock;

  Future<AttachmentArchiveApprovalRevalidationResult> revalidate(
    AttachmentArchiveCandidateComplete verification,
  ) {
    return _mutationCoordinator
        .runWithCapability<AttachmentArchiveApprovalRevalidationResult>(
          operation: ArchiveMutationOperation.attachmentArchiveAdoption,
          ownerLabel: ownerLabel,
          action: (capability) => revalidateWithinApprovalScope(
            verification: verification,
            capability: capability,
          ),
        );
  }

  Future<AttachmentArchiveApprovalRevalidationResult>
  revalidateWithinApprovalScope({
    required AttachmentArchiveCandidateComplete verification,
    required ArchiveMutationCapability capability,
  }) async {
    capability.requireOperation(
      ArchiveMutationOperation.attachmentArchiveAdoption,
    );

    final verified = verification.evidence;
    final invalidEvidenceIssue = _validateCompleteEvidence(
      verification,
      verified,
    );
    if (invalidEvidenceIssue != null || verified == null) {
      return AttachmentArchiveApprovalRevalidationResult.verificationEvidenceInvalid(
        invalidEvidenceIssue ?? 'Candidate verification evidence is absent.',
      );
    }

    final AttachmentArchiveLocationState currentSource;
    try {
      currentSource = await _currentLocationReader.readCurrentLocation();
    } on Object catch (error) {
      return AttachmentArchiveApprovalRevalidationResult.sourceUnavailable(
        'The current attachment archive could not be resolved: $error',
      );
    }
    if (!currentSource.isAvailable || currentSource.archiveRootPath == null) {
      return AttachmentArchiveApprovalRevalidationResult.sourceUnavailable(
        currentSource.issue ?? 'The current attachment archive is unavailable.',
      );
    }
    if (currentSource.configuration != verified.sourceLocationConfiguration) {
      return const AttachmentArchiveApprovalRevalidationResult.sourceChanged(
        'The active archive configuration changed after verification.',
      );
    }
    if (currentSource.generation != verified.sourceLocationGeneration) {
      return const AttachmentArchiveApprovalRevalidationResult.sourceChanged(
        'The active archive generation changed after verification.',
      );
    }

    final AttachmentArchiveApprovalCandidateAccessResult candidateResult;
    try {
      candidateResult = await _candidateAccessReader.readCurrentAccess(
        verification,
      );
    } on Object catch (error) {
      return AttachmentArchiveApprovalRevalidationResult.candidateUnavailable(
        'The candidate archive could not be resolved: $error',
      );
    }
    if (candidateResult is AttachmentArchiveApprovalCandidateUnavailable) {
      return AttachmentArchiveApprovalRevalidationResult.candidateUnavailable(
        candidateResult.issue,
      );
    }
    final candidate =
        (candidateResult as AttachmentArchiveApprovalCandidateAvailable).access;
    if (!verified.candidateWasPhysicallyWritable ||
        !candidate.isPhysicallyWritable) {
      return const AttachmentArchiveApprovalRevalidationResult.candidateNoLongerWritable(
        'The candidate archive is not currently writable for adoption.',
      );
    }

    final AttachmentArchiveApprovalStructuralSnapshot snapshot;
    try {
      snapshot = await _snapshotReader.read(
        sourceLocation: currentSource,
        candidate: candidate,
        expectedSourceCanonicalIdentity: verified.sourceCanonicalIdentity,
        expectedCandidateCanonicalIdentity: verified.candidateCanonicalIdentity,
      );
    } on AttachmentArchiveApprovalSnapshotException catch (error) {
      return _mapSnapshotFailure(error);
    } on Object catch (error) {
      return AttachmentArchiveApprovalRevalidationResult.failed(
        'Approval revalidation failed: $error',
      );
    }

    if (!_sourceSnapshotMatches(snapshot, verified)) {
      return const AttachmentArchiveApprovalRevalidationResult.sourceChanged(
        'The active archive changed after verification.',
      );
    }
    if (!_candidateSnapshotMatches(snapshot, verified)) {
      return const AttachmentArchiveApprovalRevalidationResult.candidateChanged(
        'The candidate archive changed after verification.',
      );
    }

    return AttachmentArchiveApprovalRevalidationResult.approvalReady(
      AttachmentArchiveApprovalReadyEvidence(
        verification: verification,
        sourceLocationConfiguration: verified.sourceLocationConfiguration,
        sourceLocationGeneration: verified.sourceLocationGeneration,
        sourceCanonicalIdentity: snapshot.sourceCanonicalIdentity,
        candidateCanonicalIdentity: snapshot.candidateCanonicalIdentity,
        sourceStructuralSnapshotFingerprint:
            snapshot.sourceStructuralSnapshotFingerprint,
        candidateStructuralSnapshotFingerprint:
            snapshot.candidateStructuralSnapshotFingerprint,
        contentCoverageDigest: verified.contentCoverageDigest,
        revalidatedAtUtc: _clock().toUtc(),
      ),
    );
  }

  /// Revalidates and binds a ready result to this exact active adoption scope.
  Future<AttachmentArchiveScopedApprovalRevalidation>
  revalidateForAdoptionWithinApprovalScope({
    required AttachmentArchiveCandidateComplete verification,
    required ArchiveMutationCapability capability,
  }) async {
    final result = await revalidateWithinApprovalScope(
      verification: verification,
      capability: capability,
    );
    final readyEvidence = result.readyEvidence;
    return AttachmentArchiveScopedApprovalRevalidation(
      result: result,
      scopeProof: readyEvidence == null
          ? null
          : _AttachmentArchiveApprovalScopeProof(
              readyEvidence: readyEvidence,
              capability: capability,
            ),
    );
  }

  static String? _validateCompleteEvidence(
    AttachmentArchiveCandidateComplete verification,
    AttachmentArchiveCandidateVerificationEvidence? evidence,
  ) {
    if (evidence == null) {
      return 'Candidate verification evidence is absent.';
    }
    if (verification.outcome !=
        AttachmentArchiveCandidateVerificationOutcome.candidateComplete) {
      return 'Approval requires candidateComplete verification.';
    }
    if (evidence.missingCount != 0 || evidence.missingBytes != 0) {
      return 'Complete verification contains missing candidate coverage.';
    }
    if (evidence.verifiedFileCount !=
            evidence.requiredSourcePhysicalFileCount ||
        evidence.verifiedBytes != evidence.requiredSourceBytes) {
      return 'Complete verification totals are internally inconsistent.';
    }
    if (!_isSha256(evidence.contentCoverageDigest) ||
        !_isSha256(evidence.sourceStructuralSnapshotFingerprint) ||
        !_isSha256(evidence.candidateStructuralSnapshotFingerprint)) {
      return 'Complete verification digest evidence is malformed.';
    }
    if (verification.context.sourceCanonicalIdentity !=
            evidence.sourceCanonicalIdentity ||
        verification.context.candidateCanonicalIdentity !=
            evidence.candidateCanonicalIdentity ||
        verification.context.sourceLocationConfiguration !=
            evidence.sourceLocationConfiguration ||
        verification.context.sourceLocationGeneration !=
            evidence.sourceLocationGeneration) {
      return 'Complete verification context does not match its evidence.';
    }
    return null;
  }

  static bool _sourceSnapshotMatches(
    AttachmentArchiveApprovalStructuralSnapshot snapshot,
    AttachmentArchiveCandidateVerificationEvidence verified,
  ) {
    return snapshot.sourceCanonicalIdentity ==
            verified.sourceCanonicalIdentity &&
        snapshot.sourceStructuralSnapshotFingerprint ==
            verified.sourceStructuralSnapshotFingerprint &&
        snapshot.requiredSourcePhysicalFileCount ==
            verified.requiredSourcePhysicalFileCount &&
        snapshot.requiredSourceBytes == verified.requiredSourceBytes &&
        snapshot.metadataReferenceCount == verified.metadataReferenceCount &&
        snapshot.unreferencedPreservationCount ==
            verified.unreferencedPreservationCount &&
        snapshot.sourceOperationalDebrisCount ==
            verified.sourceOperationalDebrisCount;
  }

  static bool _candidateSnapshotMatches(
    AttachmentArchiveApprovalStructuralSnapshot snapshot,
    AttachmentArchiveCandidateVerificationEvidence verified,
  ) {
    return snapshot.candidateCanonicalIdentity ==
            verified.candidateCanonicalIdentity &&
        snapshot.candidateStructuralSnapshotFingerprint ==
            verified.candidateStructuralSnapshotFingerprint &&
        snapshot.structurallyMatchedCandidateFileCount ==
            verified.verifiedFileCount &&
        snapshot.structurallyMatchedCandidateBytes == verified.verifiedBytes &&
        snapshot.candidateOperationalDebrisCount ==
            verified.candidateOperationalDebrisCount &&
        snapshot.allowedCandidateExtraCount ==
            verified.allowedCandidateExtraCount &&
        snapshot.allowedCandidateExtraBytes ==
            verified.allowedCandidateExtraBytes;
  }

  static AttachmentArchiveApprovalRevalidationResult _mapSnapshotFailure(
    AttachmentArchiveApprovalSnapshotException error,
  ) {
    return switch (error.kind) {
      AttachmentArchiveApprovalSnapshotFailureKind.sourceChanged =>
        AttachmentArchiveApprovalRevalidationResult.sourceChanged(error.issue),
      AttachmentArchiveApprovalSnapshotFailureKind.candidateChanged =>
        AttachmentArchiveApprovalRevalidationResult.candidateChanged(
          error.issue,
        ),
      AttachmentArchiveApprovalSnapshotFailureKind.sourceUnavailable =>
        AttachmentArchiveApprovalRevalidationResult.sourceUnavailable(
          error.issue,
        ),
      AttachmentArchiveApprovalSnapshotFailureKind.candidateUnavailable =>
        AttachmentArchiveApprovalRevalidationResult.candidateUnavailable(
          error.issue,
        ),
      AttachmentArchiveApprovalSnapshotFailureKind.failed =>
        AttachmentArchiveApprovalRevalidationResult.failed(error.issue),
    };
  }

  static bool _isSha256(String value) {
    return RegExp(r'^[0-9a-f]{64}$').hasMatch(value);
  }

  static DateTime _utcNow() => DateTime.now().toUtc();
}
