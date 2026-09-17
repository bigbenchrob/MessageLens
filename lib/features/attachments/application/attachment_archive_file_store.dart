import '../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'attachment_archive_location_provider.dart';

class ArchivedAttachmentFileWrite {
  const ArchivedAttachmentFileWrite({
    required this.sourcePath,
    required this.relativePath,
    required this.fileSizeBytes,
    required this.contentHash,
  });

  final String sourcePath;
  final String relativePath;
  final int fileSizeBytes;
  final String? contentHash;
}

class ArchiveIntegrityFileCheck {
  const ArchiveIntegrityFileCheck({
    required this.fileExists,
    required this.actualSizeBytes,
    required this.hashMatches,
    required this.actualHash,
  });

  final bool fileExists;
  final int? actualSizeBytes;
  final bool? hashMatches;
  final String? actualHash;
}

enum AttachmentArchiveFileInstallStatus {
  installed,
  alreadyPresent,
  conflict,
  donorChanged,
  verificationFailed,
}

class AttachmentArchiveFileInstall {
  const AttachmentArchiveFileInstall({
    required this.status,
    required this.relativePath,
    required this.fileSizeBytes,
    required this.contentHash,
  });

  final AttachmentArchiveFileInstallStatus status;
  final String relativePath;
  final int fileSizeBytes;
  final String contentHash;
}

abstract interface class AttachmentArchiveFileStore {
  String expandHomePath(String rawPath);

  bool fileExists(String path);

  Future<void> ensureArchiveDirectory(
    String archiveDirectoryPath, {
    required Future<void> Function(AttachmentArchiveMutationBoundary boundary)
    validateMutation,
  });

  /// Writes an archive file under the current archive compatibility key.
  Future<ArchivedAttachmentFileWrite?> writeArchiveEntry({
    required String archiveDirectoryPath,
    required String sourcePath,
    required ArchiveCompatibilityKey archiveKey,
    required String? sha256Hex,
    required Future<void> Function(AttachmentArchiveMutationBoundary boundary)
    validateMutation,
  });

  /// Installs already-proven payload bytes through the canonical
  /// content-addressed archive path using atomic no-overwrite semantics.
  Future<AttachmentArchiveFileInstall> installVerifiedArchiveEntry({
    required String archiveDirectoryPath,
    required Stream<List<int>> sourceBytes,
    required String sourceExtension,
    required int expectedSizeBytes,
    required String expectedSha256,
    required Future<void> Function(AttachmentArchiveMutationBoundary boundary)
    validateMutation,
  });

  Future<ArchiveIntegrityFileCheck> checkIntegrity({
    required String archiveDirectoryPath,
    required String relativePath,
    required String? storedHash,
  });
}
