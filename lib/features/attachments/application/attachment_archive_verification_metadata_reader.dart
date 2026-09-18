/// One physical archive path grouped from every overlay metadata reference.
final class AttachmentArchiveVerificationMetadataGroup {
  const AttachmentArchiveVerificationMetadataGroup({
    required this.relativePath,
    required this.fileSizeBytes,
    required this.contentHash,
    required this.referenceCount,
  });

  final String relativePath;
  final int fileSizeBytes;
  final String? contentHash;
  final int referenceCount;
}

/// A bounded page of grouped archive metadata.
final class AttachmentArchiveVerificationMetadataPage {
  const AttachmentArchiveVerificationMetadataPage({
    required this.groups,
    required this.hasMore,
  });

  final List<AttachmentArchiveVerificationMetadataGroup> groups;
  final bool hasMore;
}

/// Read-only grouped evidence used while verifying an existing archive copy.
abstract interface class AttachmentArchiveVerificationMetadataReader {
  Future<AttachmentArchiveVerificationMetadataGroup?> readByRelativePath(
    String relativePath,
  );

  Future<AttachmentArchiveVerificationMetadataPage> readPage({
    required String? afterRelativePath,
    required int limit,
  });
}
