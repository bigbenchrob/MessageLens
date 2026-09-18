import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/attachment_archive_relocation_metadata_reader.dart';
import '../../application/attachment_archive_verification_metadata_reader.dart';
import 'overlay_attachment_archive_verification_metadata_reader.dart';

/// Historical relocation adapter over the verification-owned metadata reader.
final class OverlayAttachmentArchiveRelocationMetadataReader
    implements AttachmentArchiveRelocationMetadataReader {
  OverlayAttachmentArchiveRelocationMetadataReader({
    required OverlayDatabase overlayDatabase,
  }) : _delegate = OverlayAttachmentArchiveVerificationMetadataReader(
         overlayDatabase: overlayDatabase,
       );

  final OverlayAttachmentArchiveVerificationMetadataReader _delegate;

  @override
  Future<AttachmentArchiveRelocationMetadata?> readByRelativePath(
    String relativePath,
  ) async {
    final group = await _delegate.readByRelativePath(relativePath);
    return group == null ? null : _toRelocation(group);
  }

  @override
  Future<AttachmentArchiveRelocationMetadataPage> readPage({
    required String? afterRelativePath,
    required int limit,
  }) async {
    final page = await _delegate.readPage(
      afterRelativePath: afterRelativePath,
      limit: limit,
    );
    return AttachmentArchiveRelocationMetadataPage(
      entries: page.groups.map(_toRelocation).toList(growable: false),
      hasMore: page.hasMore,
    );
  }

  static AttachmentArchiveRelocationMetadata _toRelocation(
    AttachmentArchiveVerificationMetadataGroup group,
  ) {
    return AttachmentArchiveRelocationMetadata(
      relativePath: group.relativePath,
      fileSizeBytes: group.fileSizeBytes,
      contentHash: group.contentHash,
      rowCount: group.referenceCount,
    );
  }
}
