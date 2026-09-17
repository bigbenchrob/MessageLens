import '../domain/entities/attachment_archive_relocation.dart';
import 'attachment_archive_relocation_metadata_reader.dart';

class AttachmentArchiveRelocationPreflightResult {
  const AttachmentArchiveRelocationPreflightResult({
    required this.availableCapacityBytes,
  });

  final int availableCapacityBytes;
}

class AttachmentArchiveRelocationInventoryResult {
  const AttachmentArchiveRelocationInventoryResult({
    required this.fileCount,
    required this.byteCount,
    required this.metadataRowCount,
    required this.unreferencedFileCount,
    required this.operationalDebrisCount,
  });

  final int fileCount;
  final int byteCount;
  final int metadataRowCount;
  final int unreferencedFileCount;
  final int operationalDebrisCount;
}

abstract interface class AttachmentArchiveDestinationCapacityReader {
  Future<int> availableCapacityForImportantUsage(String directoryPath);
}

abstract interface class AttachmentArchiveExclusiveDirectoryFinalizer {
  Future<void> finalize({
    required String stagingRootPath,
    required String finalRootPath,
  });
}

abstract interface class AttachmentArchiveRelocationFileSystem {
  Future<AttachmentArchiveRelocationPreflightResult> preflight({
    required String sourceRootPath,
    required String destinationParentPath,
    required String stagingDirectoryName,
    required String finalDirectoryName,
    required bool resumeStartedPreflight,
  });

  Future<AttachmentArchiveRelocationInventoryResult> inventory({
    required String sourceRootPath,
    required AttachmentArchiveRelocationMetadataReader metadataReader,
    required Future<void> Function(
      AttachmentArchiveRelocationManifestEntry entry,
    )
    onEntry,
  });

  Future<void> verifyMetadataCoverage({
    required String sourceRootPath,
    required AttachmentArchiveRelocationMetadataReader metadataReader,
  });

  Future<AttachmentArchiveRelocationCopyReceipt> copyAndVerify({
    required int index,
    required AttachmentArchiveRelocationManifestEntry entry,
    required String sourceRootPath,
    required String stagingRootPath,
  });

  Future<void> verifyReceipt({
    required AttachmentArchiveRelocationManifestEntry entry,
    required AttachmentArchiveRelocationCopyReceipt receipt,
    required String sourceRootPath,
    required String destinationRootPath,
  });

  Future<void> verifyDestinationCoverage({
    required String destinationRootPath,
    required int expectedFileCount,
    required int expectedByteCount,
  });

  Future<void> finalizeDestination({
    required String stagingRootPath,
    required String finalRootPath,
  });
}
