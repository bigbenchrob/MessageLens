import '../../../essentials/archive_environment/domain/archive_mutation_capability_denied_exception.dart';
import '../../../essentials/archive_environment/domain/archive_mutation_operation.dart';
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability;
import '../domain/constants/attachment_archive_payload_status.dart';
import 'attachment_archive_file_store.dart';
import 'attachment_archive_location_provider.dart';
import 'attachment_archive_read_store.dart';
import 'attachment_archive_write_store.dart';
import 'current_messages_attachment_source_reader.dart';

enum AdmittedAttachmentArchiveRepairWriteStatus {
  preserved,
  recordAppeared,
  sourceAbsent,
  sourceUnreadable,
  sourceUnavailable,
  sourceInconclusive,
  itemInconclusive,
  sourceChanged,
  installationFailed,
  metadataCommitFailed,
  verificationFailed,
  deferred,
}

final class AdmittedAttachmentArchiveRepairWriteResult {
  const AdmittedAttachmentArchiveRepairWriteResult({
    required this.status,
    this.installedBytes = 0,
    this.archiveRelativePath,
    this.deferredReason,
    this.issue,
  });

  final AdmittedAttachmentArchiveRepairWriteStatus status;
  final int installedBytes;
  final String? archiveRelativePath;
  final AttachmentArchiveMutationDeferredReason? deferredReason;
  final String? issue;

  bool get isPreserved =>
      status == AdmittedAttachmentArchiveRepairWriteStatus.preserved;
}

/// Preserves one no-record attachment inside an already admitted mutation.
///
/// The writer cannot acquire mutation authority. Its capability and writable
/// root lease are callback-local method inputs so neither can become retained
/// ambient state. Record-backed defects are deliberately outside this seam.
final class AdmittedAttachmentArchiveRepairWriter {
  const AdmittedAttachmentArchiveRepairWriter({
    required CurrentMessagesAttachmentSourceReader sourceReader,
    required AttachmentArchiveFileStore fileStore,
    required AttachmentArchiveReadStore readStore,
    required AttachmentArchiveWriteStore writeStore,
  }) : _sourceReader = sourceReader,
       _fileStore = fileStore,
       _readStore = readStore,
       _writeStore = writeStore;

  static const _operation = ArchiveMutationOperation.attachmentReconciliation;

  final CurrentMessagesAttachmentSourceReader _sourceReader;
  final AttachmentArchiveFileStore _fileStore;
  final AttachmentArchiveReadStore _readStore;
  final AttachmentArchiveWriteStore _writeStore;

  Future<AdmittedAttachmentArchiveRepairWriteResult> preserveNoRecord({
    required ArchiveMutationCapability capability,
    required AttachmentArchiveWritableRootLease writableRootLease,
    required CurrentMessagesAttachmentSourceObservation expectedSource,
    DateTime? archivedAtUtc,
  }) async {
    try {
      await _requireAdmission(
        capability: capability,
        writableRootLease: writableRootLease,
        boundary: AttachmentArchiveMutationBoundary.operationStart,
      );

      final expectedFailure = _sourceFailure(expectedSource);
      if (expectedFailure != null) {
        return expectedFailure;
      }

      await _requireAdmission(
        capability: capability,
        writableRootLease: writableRootLease,
        boundary: AttachmentArchiveMutationBoundary.beforeSourceRead,
      );
      final currentSource = await _sourceReader.observeCurrent(
        expectedSource.archiveKey,
      );
      final currentFailure = _sourceFailure(currentSource);
      if (currentFailure != null) {
        return currentFailure;
      }
      if (!expectedSource.hasSameMaterialEvidenceAs(currentSource)) {
        return const AdmittedAttachmentArchiveRepairWriteResult(
          status: AdmittedAttachmentArchiveRepairWriteStatus.sourceChanged,
          issue: 'Current source evidence changed before preservation.',
        );
      }

      await _requireAdmission(
        capability: capability,
        writableRootLease: writableRootLease,
        boundary: AttachmentArchiveMutationBoundary.beforeSourceRead,
      );
      if (await _writeStore.hasArchiveRecord(currentSource.archiveKey)) {
        return const AdmittedAttachmentArchiveRepairWriteResult(
          status: AdmittedAttachmentArchiveRepairWriteStatus.recordAppeared,
          issue: 'A durable archive record appeared before preservation.',
        );
      }

      final archiveWrite = await _installPayload(
        capability: capability,
        writableRootLease: writableRootLease,
        currentSource: currentSource,
      );
      if (archiveWrite == null || archiveWrite.contentHash == null) {
        return const AdmittedAttachmentArchiveRepairWriteResult(
          status: AdmittedAttachmentArchiveRepairWriteStatus.installationFailed,
          issue: 'The payload could not be installed and verified.',
        );
      }

      await _requireAdmission(
        capability: capability,
        writableRootLease: writableRootLease,
        boundary: AttachmentArchiveMutationBoundary.beforeSourceRead,
      );
      final postInstallSource = await _sourceReader.observeCurrent(
        currentSource.archiveKey,
      );
      final postInstallFailure = _sourceFailure(postInstallSource);
      if (postInstallFailure != null) {
        return postInstallFailure;
      }
      if (!currentSource.hasSameMaterialEvidenceAs(postInstallSource)) {
        return AdmittedAttachmentArchiveRepairWriteResult(
          status: AdmittedAttachmentArchiveRepairWriteStatus.sourceChanged,
          archiveRelativePath: archiveWrite.relativePath,
          issue: 'Current source evidence changed during preservation.',
        );
      }

      await _requireAdmission(
        capability: capability,
        writableRootLease: writableRootLease,
        boundary: AttachmentArchiveMutationBoundary.beforeMetadataCommit,
      );
      try {
        await _writeStore.writeArchiveRecord(
          ArchivedAttachmentWrite(
            archiveKey: currentSource.archiveKey,
            archiveRelativePath: archiveWrite.relativePath,
            archivedAtUtc: (archivedAtUtc ?? DateTime.now().toUtc())
                .toUtc()
                .toIso8601String(),
            fileSizeBytes: archiveWrite.fileSizeBytes,
            contentHash: archiveWrite.contentHash,
            originalLocalPath: archiveWrite.sourcePath,
          ),
        );
      } on ArchiveMutationCapabilityDeniedException {
        rethrow;
      } on AttachmentArchiveMutationDeferredException {
        rethrow;
      } on Object catch (error) {
        return AdmittedAttachmentArchiveRepairWriteResult(
          status:
              AdmittedAttachmentArchiveRepairWriteStatus.metadataCommitFailed,
          archiveRelativePath: archiveWrite.relativePath,
          issue: 'Archive metadata could not be committed: $error',
        );
      }

      await _requireAdmission(
        capability: capability,
        writableRootLease: writableRootLease,
        boundary: AttachmentArchiveMutationBoundary.beforePayloadVerification,
      );
      final verified = await _verifyCommittedObject(
        writableRootLease: writableRootLease,
        source: currentSource,
        archiveWrite: archiveWrite,
      );
      if (!verified) {
        return AdmittedAttachmentArchiveRepairWriteResult(
          status: AdmittedAttachmentArchiveRepairWriteStatus.verificationFailed,
          archiveRelativePath: archiveWrite.relativePath,
          issue: 'Committed archive evidence did not verify.',
        );
      }

      return AdmittedAttachmentArchiveRepairWriteResult(
        status: AdmittedAttachmentArchiveRepairWriteStatus.preserved,
        installedBytes: archiveWrite.fileSizeBytes,
        archiveRelativePath: archiveWrite.relativePath,
      );
    } on AttachmentArchiveMutationDeferredException catch (error) {
      return AdmittedAttachmentArchiveRepairWriteResult(
        status: AdmittedAttachmentArchiveRepairWriteStatus.deferred,
        deferredReason: error.reason,
        issue: error.issue,
      );
    }
  }

  Future<ArchivedAttachmentFileWrite?> _installPayload({
    required ArchiveMutationCapability capability,
    required AttachmentArchiveWritableRootLease writableRootLease,
    required CurrentMessagesAttachmentSourceObservation currentSource,
  }) async {
    try {
      return await _fileStore.writeArchiveEntry(
        archiveDirectoryPath: writableRootLease.archiveRootPath,
        sourcePath: currentSource.requireSourcePath(),
        archiveKey: currentSource.archiveKey,
        sha256Hex: null,
        validateMutation: (boundary) => _requireAdmission(
          capability: capability,
          writableRootLease: writableRootLease,
          boundary: boundary,
        ),
      );
    } on ArchiveMutationCapabilityDeniedException {
      rethrow;
    } on AttachmentArchiveMutationDeferredException {
      rethrow;
    } on Object {
      return null;
    }
  }

  Future<bool> _verifyCommittedObject({
    required AttachmentArchiveWritableRootLease writableRootLease,
    required CurrentMessagesAttachmentSourceObservation source,
    required ArchivedAttachmentFileWrite archiveWrite,
  }) async {
    final record = await _readStore.readArchiveRecord(source.archiveKey);
    final archiveAbsolutePath = record?.archiveAbsolutePath;
    if (record == null ||
        record.archiveRelativePath != archiveWrite.relativePath ||
        record.fileSizeBytes != archiveWrite.fileSizeBytes ||
        record.contentHash != archiveWrite.contentHash ||
        record.locationGeneration != writableRootLease.locationGeneration ||
        record.payloadStatus != AttachmentArchivePayloadStatus.available ||
        archiveAbsolutePath == null ||
        !_fileStore.fileExists(archiveAbsolutePath)) {
      return false;
    }

    final integrity = await _fileStore.checkIntegrity(
      archiveDirectoryPath: writableRootLease.archiveRootPath,
      relativePath: archiveWrite.relativePath,
      storedHash: archiveWrite.contentHash,
    );
    return integrity.fileExists &&
        integrity.actualSizeBytes == archiveWrite.fileSizeBytes &&
        integrity.hashMatches == true &&
        integrity.actualHash == archiveWrite.contentHash;
  }

  Future<void> _requireAdmission({
    required ArchiveMutationCapability capability,
    required AttachmentArchiveWritableRootLease writableRootLease,
    required AttachmentArchiveMutationBoundary boundary,
  }) async {
    capability.requireOperation(_operation);
    await writableRootLease.requireValid(
      operation: _operation,
      boundary: boundary,
    );
  }

  static AdmittedAttachmentArchiveRepairWriteResult? _sourceFailure(
    CurrentMessagesAttachmentSourceObservation source,
  ) {
    return switch (source.condition) {
      CurrentMessagesAttachmentSourceCondition.available => null,
      CurrentMessagesAttachmentSourceCondition.absent =>
        AdmittedAttachmentArchiveRepairWriteResult(
          status: AdmittedAttachmentArchiveRepairWriteStatus.sourceAbsent,
          issue: source.issue,
        ),
      CurrentMessagesAttachmentSourceCondition.unreadable =>
        AdmittedAttachmentArchiveRepairWriteResult(
          status: AdmittedAttachmentArchiveRepairWriteStatus.sourceUnreadable,
          issue: source.issue,
        ),
      CurrentMessagesAttachmentSourceCondition.sourceUnavailable =>
        AdmittedAttachmentArchiveRepairWriteResult(
          status: AdmittedAttachmentArchiveRepairWriteStatus.sourceUnavailable,
          issue: source.issue,
        ),
      CurrentMessagesAttachmentSourceCondition.sourceInconclusive =>
        AdmittedAttachmentArchiveRepairWriteResult(
          status: AdmittedAttachmentArchiveRepairWriteStatus.sourceInconclusive,
          issue: source.issue,
        ),
      CurrentMessagesAttachmentSourceCondition.unknown =>
        AdmittedAttachmentArchiveRepairWriteResult(
          status: AdmittedAttachmentArchiveRepairWriteStatus.itemInconclusive,
          issue: source.issue,
        ),
    };
  }
}
