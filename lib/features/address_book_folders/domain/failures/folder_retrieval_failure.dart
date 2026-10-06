enum FolderRetrievalFailureKind {
  accessDenied,
  sourceUnavailable,
  invalidOrCorrupt,
  unknown,
}

class FolderRetrievalFailure implements Exception {
  const FolderRetrievalFailure({
    required this.message,
    this.kind = FolderRetrievalFailureKind.unknown,
  });

  final String message;
  final FolderRetrievalFailureKind kind;

  String get error => message;

  @override
  String toString() {
    return 'FolderRetrievalFailure(kind: ${kind.name}, message: $message)';
  }
}
