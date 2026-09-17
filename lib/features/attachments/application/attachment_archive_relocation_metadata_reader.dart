class AttachmentArchiveRelocationMetadata {
  const AttachmentArchiveRelocationMetadata({
    required this.relativePath,
    required this.fileSizeBytes,
    required this.contentHash,
    required this.rowCount,
  });

  final String relativePath;
  final int fileSizeBytes;
  final String? contentHash;
  final int rowCount;
}

class AttachmentArchiveRelocationMetadataPage {
  const AttachmentArchiveRelocationMetadataPage({
    required this.entries,
    required this.hasMore,
  });

  final List<AttachmentArchiveRelocationMetadata> entries;
  final bool hasMore;
}

abstract interface class AttachmentArchiveRelocationMetadataReader {
  Future<AttachmentArchiveRelocationMetadata?> readByRelativePath(
    String relativePath,
  );

  Future<AttachmentArchiveRelocationMetadataPage> readPage({
    required String? afterRelativePath,
    required int limit,
  });
}
