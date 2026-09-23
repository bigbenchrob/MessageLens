import 'package:meta/meta.dart';

enum AttachmentArchiveBookmarkResolutionStatus {
  available,
  readOnly,
  unavailable,
  permissionDenied,
  configuredDirectoryMissing,
  invalidBookmark,
}

enum AttachmentArchiveLocationEvent {
  volumeMounted,
  volumeUnmounted,
  volumeRenamed,
  applicationActivated,
}

@immutable
final class AttachmentArchiveBookmarkCreation {
  const AttachmentArchiveBookmarkCreation({
    required this.bookmarkDataBase64,
    required this.resolvedPath,
    this.volumeName,
  });

  final String bookmarkDataBase64;
  final String resolvedPath;
  final String? volumeName;
}

@immutable
final class AttachmentArchiveBookmarkResolution {
  const AttachmentArchiveBookmarkResolution({
    required this.status,
    this.resolvedPath,
    this.refreshedBookmarkDataBase64,
    this.volumeName,
    this.issue,
  });

  final AttachmentArchiveBookmarkResolutionStatus status;
  final String? resolvedPath;
  final String? refreshedBookmarkDataBase64;
  final String? volumeName;
  final String? issue;
}

final class AttachmentArchiveBookmarkCreationException implements Exception {
  const AttachmentArchiveBookmarkCreationException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  @override
  String toString() =>
      'AttachmentArchiveBookmarkCreationException($code): '
      '$message';
}

/// Bookmark-only native authority shared by location and archive adoption.
///
/// It creates no directories and performs no write probes. Physical
/// availability and writability come only from Foundation bookmark results.
abstract interface class AttachmentArchiveBookmarkAdapter {
  Future<AttachmentArchiveBookmarkCreation> createBookmark({
    required String directoryPath,
  });

  Future<AttachmentArchiveBookmarkResolution> resolveBookmark({
    required String bookmarkDataBase64,
  });

  Stream<AttachmentArchiveLocationEvent> get locationEvents;
}
