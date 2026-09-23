import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability;
import 'attachment_archive_location_provider.dart';
import 'cross_snapshot_mapping.dart';

abstract interface class RecoveredAttachmentArchiveWriter {
  /// Archives the mapped file and returns its size when newly archived.
  ///
  /// Returns null when the mapped file was already archived.
  Future<int?> archive({
    required MappedAttachmentRecord record,
    required AttachmentArchiveWritableRootLease writableRootLease,
    required ArchiveMutationCapability mutationCapability,
  });
}
