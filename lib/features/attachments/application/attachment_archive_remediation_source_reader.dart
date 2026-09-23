import 'attachment_archive_remediation_authority.dart';

enum AttachmentArchiveRemediationSourceFailureKind {
  unavailable,
  unsafeEntry,
  changed,
  unreadable,
}

final class AttachmentArchiveRemediationSourceException implements Exception {
  const AttachmentArchiveRemediationSourceException({
    required this.kind,
    required this.issue,
  });

  final AttachmentArchiveRemediationSourceFailureKind kind;
  final String issue;

  @override
  String toString() => issue;
}

/// Read-only access to one exact payload authorized by an active remediation
/// transaction.
///
/// The authority binds the source identity, transaction, and payload evidence;
/// this is intentionally not a general path-reading interface.
abstract interface class AttachmentArchiveRemediationSourceReader {
  Future<Stream<List<int>>> openVerifiedPayload({
    required String retainedSourceRootPath,
    required AttachmentArchiveRemediationAuthority remediationAuthority,
  });
}
