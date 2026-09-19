final class AttachmentArchiveAdoptionRootInspection {
  const AttachmentArchiveAdoptionRootInspection({required this.canonicalPath});

  final String canonicalPath;
}

/// Bounded read-only canonical identity and readability check for one root.
abstract interface class AttachmentArchiveAdoptionRootInspector {
  Future<AttachmentArchiveAdoptionRootInspection> inspect({
    required String directoryPath,
    required String label,
  });
}
