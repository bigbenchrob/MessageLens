import 'dart:io';

import 'package:path/path.dart' as path;

import '../../application/attachment_archive_adoption_root_inspector.dart';

final class FilesystemAttachmentArchiveAdoptionRootInspector
    implements AttachmentArchiveAdoptionRootInspector {
  const FilesystemAttachmentArchiveAdoptionRootInspector();

  @override
  Future<AttachmentArchiveAdoptionRootInspection> inspect({
    required String directoryPath,
    required String label,
  }) async {
    if (!path.isAbsolute(directoryPath)) {
      throw FileSystemException('The $label path must be absolute.');
    }
    final normalized = path.normalize(directoryPath);
    final type = FileSystemEntity.typeSync(normalized, followLinks: false);
    if (type == FileSystemEntityType.notFound) {
      throw FileSystemException('The $label is unavailable.', normalized);
    }
    if (type == FileSystemEntityType.link) {
      throw FileSystemException(
        'The $label root must not be a symbolic link.',
        normalized,
      );
    }
    if (type != FileSystemEntityType.directory) {
      throw FileSystemException(
        'The $label root must be a directory.',
        normalized,
      );
    }
    final canonical = path.normalize(
      await Directory(normalized).resolveSymbolicLinks(),
    );
    await Directory(canonical).list(followLinks: false).take(1).toList();
    return AttachmentArchiveAdoptionRootInspection(canonicalPath: canonical);
  }
}
