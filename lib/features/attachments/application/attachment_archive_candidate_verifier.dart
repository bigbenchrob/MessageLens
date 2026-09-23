import '../domain/entities/attachment_archive_candidate_verification.dart';
import '../domain/entities/attachment_archive_location_state.dart';

typedef AttachmentArchiveVerificationProgressCallback =
    void Function(AttachmentArchiveVerificationProgress progress);

abstract interface class AttachmentArchiveCandidateVerifier {
  Future<AttachmentArchiveCandidateVerificationResult> verify({
    required AttachmentArchiveLocationState sourceLocation,
    required AttachmentArchiveCandidateAccess candidate,
    AttachmentArchiveVerificationProgressCallback? onProgress,
    bool Function()? isCancelled,
  });
}
