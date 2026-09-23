import 'package:meta/meta.dart';

import 'attachment_archive_candidate_verification.dart';
import 'attachment_archive_location_configuration.dart';

enum AttachmentArchiveApprovalRevalidationOutcome {
  approvalReady,
  sourceChanged,
  candidateChanged,
  sourceUnavailable,
  candidateUnavailable,
  candidateNoLongerWritable,
  verificationEvidenceInvalid,
  failed,
}

/// Process-local comparison evidence only. This is not mutation authority.
///
/// Keeping the original [verification] object binds this result to the exact
/// in-memory candidate-complete result that was freshly revalidated. A later
/// checkpoint must still mint separate verified-adoption authority while the
/// coordinator scope remains active.
@immutable
final class AttachmentArchiveApprovalReadyEvidence {
  const AttachmentArchiveApprovalReadyEvidence({
    required this.verification,
    required this.sourceLocationConfiguration,
    required this.sourceLocationGeneration,
    required this.sourceCanonicalIdentity,
    required this.candidateCanonicalIdentity,
    required this.sourceStructuralSnapshotFingerprint,
    required this.candidateStructuralSnapshotFingerprint,
    required this.contentCoverageDigest,
    required this.revalidatedAtUtc,
  });

  final AttachmentArchiveCandidateComplete verification;
  final AttachmentArchiveLocationConfiguration sourceLocationConfiguration;
  final int sourceLocationGeneration;
  final String sourceCanonicalIdentity;
  final String candidateCanonicalIdentity;
  final String sourceStructuralSnapshotFingerprint;
  final String candidateStructuralSnapshotFingerprint;
  final String contentCoverageDigest;
  final DateTime revalidatedAtUtc;
}

@immutable
final class AttachmentArchiveApprovalRevalidationResult {
  const AttachmentArchiveApprovalRevalidationResult._({
    required this.outcome,
    this.issue,
    this.readyEvidence,
  });

  const AttachmentArchiveApprovalRevalidationResult.approvalReady(
    AttachmentArchiveApprovalReadyEvidence evidence,
  ) : this._(
        outcome: AttachmentArchiveApprovalRevalidationOutcome.approvalReady,
        readyEvidence: evidence,
      );

  const AttachmentArchiveApprovalRevalidationResult.sourceChanged(String issue)
    : this._(
        outcome: AttachmentArchiveApprovalRevalidationOutcome.sourceChanged,
        issue: issue,
      );

  const AttachmentArchiveApprovalRevalidationResult.candidateChanged(
    String issue,
  ) : this._(
        outcome: AttachmentArchiveApprovalRevalidationOutcome.candidateChanged,
        issue: issue,
      );

  const AttachmentArchiveApprovalRevalidationResult.sourceUnavailable(
    String issue,
  ) : this._(
        outcome: AttachmentArchiveApprovalRevalidationOutcome.sourceUnavailable,
        issue: issue,
      );

  const AttachmentArchiveApprovalRevalidationResult.candidateUnavailable(
    String issue,
  ) : this._(
        outcome:
            AttachmentArchiveApprovalRevalidationOutcome.candidateUnavailable,
        issue: issue,
      );

  const AttachmentArchiveApprovalRevalidationResult.candidateNoLongerWritable(
    String issue,
  ) : this._(
        outcome: AttachmentArchiveApprovalRevalidationOutcome
            .candidateNoLongerWritable,
        issue: issue,
      );

  const AttachmentArchiveApprovalRevalidationResult.verificationEvidenceInvalid(
    String issue,
  ) : this._(
        outcome: AttachmentArchiveApprovalRevalidationOutcome
            .verificationEvidenceInvalid,
        issue: issue,
      );

  const AttachmentArchiveApprovalRevalidationResult.failed(String issue)
    : this._(
        outcome: AttachmentArchiveApprovalRevalidationOutcome.failed,
        issue: issue,
      );

  final AttachmentArchiveApprovalRevalidationOutcome outcome;
  final String? issue;
  final AttachmentArchiveApprovalReadyEvidence? readyEvidence;

  bool get isApprovalReady {
    return outcome ==
        AttachmentArchiveApprovalRevalidationOutcome.approvalReady;
  }
}
