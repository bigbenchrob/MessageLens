import '../../../../essentials/archive_environment/domain.dart'
    show ArchiveMutationOperation;
import '../../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability;
import '../../application/attachment_archive_file_store.dart';
import '../../application/attachment_archive_location_provider.dart';
import '../../application/attachment_archive_write_store.dart';
import '../../application/cross_snapshot_mapping.dart';
import '../../application/recovered_attachment_archive_writer.dart';

/// Historical recovery adapter that reuses the canonical safe installer.
///
/// The former direct copy implementation predated mutation admission. Keeping
/// recovery on the same content-addressed installer gives it identical lease,
/// temporary-file, verification, and no-overwrite semantics as ingestion.
final class OverlayRecoveredAttachmentArchiveWriter
    implements RecoveredAttachmentArchiveWriter {
  const OverlayRecoveredAttachmentArchiveWriter({
    required AttachmentArchiveFileStore fileStore,
    required AttachmentArchiveWriteStore writeStore,
  }) : _fileStore = fileStore,
       _writeStore = writeStore;

  final AttachmentArchiveFileStore _fileStore;
  final AttachmentArchiveWriteStore _writeStore;

  @override
  Future<int?> archive({
    required MappedAttachmentRecord record,
    required AttachmentArchiveWritableRootLease writableRootLease,
    required ArchiveMutationCapability mutationCapability,
  }) async {
    mutationCapability.requireOperation(
      ArchiveMutationOperation.automaticRecovery,
    );
    final archiveKey = record.currentArchiveCompatibilityKey;
    if (await _writeStore.hasArchiveRecord(archiveKey)) {
      return null;
    }

    final archiveWrite = await _fileStore.writeArchiveEntry(
      archiveDirectoryPath: writableRootLease.archiveRootPath,
      sourcePath: record.resolvedFilePath,
      archiveKey: archiveKey,
      sha256Hex: null,
      validateMutation: (boundary) async {
        mutationCapability.requireOperation(
          ArchiveMutationOperation.automaticRecovery,
        );
        await writableRootLease.requireValid(
          operation: ArchiveMutationOperation.automaticRecovery,
          boundary: boundary,
        );
      },
    );
    if (archiveWrite == null) {
      throw StateError('Recovered attachment payload could not be installed.');
    }

    await writableRootLease.requireValid(
      operation: ArchiveMutationOperation.automaticRecovery,
      boundary: AttachmentArchiveMutationBoundary.beforeMetadataCommit,
    );
    await _writeStore.reconcileArchiveRecord(
      ArchivedAttachmentWrite(
        archiveKey: archiveKey,
        archiveRelativePath: archiveWrite.relativePath,
        archivedAtUtc: DateTime.now().toUtc().toIso8601String(),
        fileSizeBytes: archiveWrite.fileSizeBytes,
        contentHash: archiveWrite.contentHash,
        provenance: 'imported_historical_snapshot',
        originalLocalPath: record.histLocalPath,
      ),
    );
    return archiveWrite.fileSizeBytes;
  }
}
