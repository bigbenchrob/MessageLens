import '../domain/entities/attachment_archive_candidate_verification.dart';
import '../domain/entities/attachment_archive_location_state.dart';

/// Reads exact content evidence only for structurally new source payloads.
///
/// Implementations must revalidate each supplied entry, require its candidate
/// path to remain absent, and stream-hash only those newly added source files.
abstract interface class AttachmentArchiveApprovalAddedPayloadReader {
  Future<List<AttachmentArchiveVerifiedMissingPayload>>
  readAddedMissingPayloads({
    required AttachmentArchiveLocationState sourceLocation,
    required AttachmentArchiveCandidateAccess candidate,
    required String expectedSourceCanonicalIdentity,
    required String expectedCandidateCanonicalIdentity,
    required List<AttachmentArchiveStructuralEntryEvidence> addedEntries,
  });
}
