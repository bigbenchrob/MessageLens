import '../domain/entities/attachment_archive_candidate_verification.dart';
import '../domain/entities/attachment_archive_location_state.dart';

/// Structural evidence recomputed immediately before archive adoption approval.
///
/// Implementations must not read payload contents or mutate either archive.
final class AttachmentArchiveApprovalStructuralSnapshot {
  const AttachmentArchiveApprovalStructuralSnapshot({
    required this.sourceCanonicalIdentity,
    required this.candidateCanonicalIdentity,
    required this.sourceStructuralSnapshotFingerprint,
    required this.candidateStructuralSnapshotFingerprint,
    required this.requiredSourcePhysicalFileCount,
    required this.requiredSourceBytes,
    required this.structurallyMatchedCandidateFileCount,
    required this.structurallyMatchedCandidateBytes,
    required this.metadataReferenceCount,
    required this.unreferencedPreservationCount,
    required this.sourceOperationalDebrisCount,
    required this.candidateOperationalDebrisCount,
    required this.allowedCandidateExtraCount,
    required this.allowedCandidateExtraBytes,
    required this.sourceStructuralBaseline,
  });

  final String sourceCanonicalIdentity;
  final String candidateCanonicalIdentity;
  final String sourceStructuralSnapshotFingerprint;
  final String candidateStructuralSnapshotFingerprint;
  final int requiredSourcePhysicalFileCount;
  final int requiredSourceBytes;
  final int structurallyMatchedCandidateFileCount;
  final int structurallyMatchedCandidateBytes;
  final int metadataReferenceCount;
  final int unreferencedPreservationCount;
  final int sourceOperationalDebrisCount;
  final int candidateOperationalDebrisCount;
  final int allowedCandidateExtraCount;
  final int allowedCandidateExtraBytes;
  final AttachmentArchiveVerificationStructuralBaseline
  sourceStructuralBaseline;
}

/// Candidate-only structural evidence recomputed after configuration switch.
final class AttachmentArchiveApprovalCandidateStructuralSnapshot {
  const AttachmentArchiveApprovalCandidateStructuralSnapshot({
    required this.candidateCanonicalIdentity,
    required this.candidateStructuralSnapshotFingerprint,
    required this.structurallyMatchedCandidateFileCount,
    required this.structurallyMatchedCandidateBytes,
    required this.candidateOperationalDebrisCount,
    required this.allowedCandidateExtraCount,
    required this.allowedCandidateExtraBytes,
  });

  final String candidateCanonicalIdentity;
  final String candidateStructuralSnapshotFingerprint;
  final int structurallyMatchedCandidateFileCount;
  final int structurallyMatchedCandidateBytes;
  final int candidateOperationalDebrisCount;
  final int allowedCandidateExtraCount;
  final int allowedCandidateExtraBytes;
}

enum AttachmentArchiveApprovalSnapshotFailureKind {
  sourceChanged,
  candidateChanged,
  sourceUnavailable,
  candidateUnavailable,
  failed,
}

final class AttachmentArchiveApprovalSnapshotException implements Exception {
  const AttachmentArchiveApprovalSnapshotException({
    required this.kind,
    required this.issue,
  });

  final AttachmentArchiveApprovalSnapshotFailureKind kind;
  final String issue;

  @override
  String toString() {
    return 'AttachmentArchiveApprovalSnapshotException(${kind.name}): '
        '$issue';
  }
}

abstract interface class AttachmentArchiveApprovalSnapshotReader {
  Future<AttachmentArchiveApprovalStructuralSnapshot> read({
    required AttachmentArchiveLocationState sourceLocation,
    required AttachmentArchiveCandidateAccess candidate,
    required String expectedSourceCanonicalIdentity,
    required String expectedCandidateCanonicalIdentity,
  });

  Future<AttachmentArchiveApprovalCandidateStructuralSnapshot> readCandidate({
    required String sourceCanonicalIdentity,
    required AttachmentArchiveCandidateAccess candidate,
    required String expectedCandidateCanonicalIdentity,
  });
}
