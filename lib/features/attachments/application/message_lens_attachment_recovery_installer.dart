import 'dart:io';

import '../../../essentials/archive_environment/domain.dart'
    show ArchiveMutationOperation;
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability;
import '../domain/entities/message_lens_attachment_recovery.dart';
import 'attachment_archive_file_store.dart';
import 'attachment_archive_location_provider.dart';
import 'attachment_archive_read_store.dart';
import 'attachment_archive_write_store.dart';
import 'verified_donor_attachment_payload.dart';

enum MessageLensAttachmentInstallationStatus {
  installed,
  alreadyPresent,
  conflict,
  donorMissing,
  donorChanged,
  verificationFailed,
  unsafeSource,
  metadataUpdateFailed,
  deferred,
}

class MessageLensAttachmentInstallationResult {
  const MessageLensAttachmentInstallationResult({
    required this.status,
    required this.installedBytes,
    required this.archiveRelativePath,
    this.deferredReason,
  });

  final MessageLensAttachmentInstallationStatus status;
  final int installedBytes;
  final String? archiveRelativePath;
  final AttachmentArchiveMutationDeferredReason? deferredReason;
}

/// Dormant orchestration for one already-proven MessageLens recovery candidate.
///
/// Filesystem truth is established before overlay metadata is reconciled. The
/// required capability makes coordinator admission a mechanical precondition.
class MessageLensAttachmentRecoveryInstaller {
  const MessageLensAttachmentRecoveryInstaller({
    required AttachmentArchiveFileStore fileStore,
    required AttachmentArchiveReadStore readStore,
    required AttachmentArchiveWriteStore writeStore,
    required AttachmentArchiveWritableRootLease writableRootLease,
  }) : _fileStore = fileStore,
       _readStore = readStore,
       _writeStore = writeStore,
       _writableRootLease = writableRootLease;

  final AttachmentArchiveFileStore _fileStore;
  final AttachmentArchiveReadStore _readStore;
  final AttachmentArchiveWriteStore _writeStore;
  final AttachmentArchiveWritableRootLease _writableRootLease;

  Future<MessageLensAttachmentInstallationResult> install({
    required ArchiveMutationCapability mutationCapability,
    required MessageLensAttachmentRecoveryCandidate candidate,
    required VerifiedDonorAttachmentPayload donorPayload,
    DateTime? installedAtUtc,
  }) async {
    mutationCapability.requireOperation(
      ArchiveMutationOperation.attachmentReconciliation,
    );
    final initialValidation = await _writableRootLease.validate(
      operation: ArchiveMutationOperation.attachmentReconciliation,
      boundary: AttachmentArchiveMutationBoundary.operationStart,
    );
    if (!initialValidation.isValid) {
      return _deferredResult(initialValidation);
    }
    if (candidate.classification !=
        MessageLensAttachmentRecoveryClassification.recoverable) {
      return _result(MessageLensAttachmentInstallationStatus.unsafeSource);
    }
    final preflightHash = candidate.donorPayloadSha256?.trim().toLowerCase();
    if (candidate.donorArchiveRelativePath !=
            donorPayload.archiveRelativePath ||
        candidate.recoverableBytes != donorPayload.expectedSizeBytes ||
        (preflightHash != null &&
            preflightHash.isNotEmpty &&
            preflightHash != donorPayload.expectedSha256.toLowerCase())) {
      return _result(MessageLensAttachmentInstallationStatus.donorChanged);
    }

    final existing = await _readStore.readArchiveRecord(
      candidate.archiveCompatibilityKey,
    );
    if (existing != null && existing.archiveFileExists) {
      final beforeIntegrity = await _writableRootLease.validate(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        boundary: AttachmentArchiveMutationBoundary.beforePayloadVerification,
      );
      if (!beforeIntegrity.isValid) {
        return _deferredResult(beforeIntegrity);
      }
      final integrity = await _fileStore.checkIntegrity(
        archiveDirectoryPath: _writableRootLease.archiveRootPath,
        relativePath: existing.archiveRelativePath,
        storedHash: donorPayload.expectedSha256,
      );
      final afterIntegrity = await _writableRootLease.validate(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        boundary: AttachmentArchiveMutationBoundary.beforeMetadataCommit,
      );
      if (!afterIntegrity.isValid) {
        return _deferredResult(afterIntegrity);
      }
      final sizeMatches =
          existing.fileSizeBytes == null ||
          existing.fileSizeBytes == donorPayload.expectedSizeBytes;
      final hashMatches = integrity.hashMatches == true;
      return _result(
        hashMatches && sizeMatches
            ? MessageLensAttachmentInstallationStatus.alreadyPresent
            : MessageLensAttachmentInstallationStatus.conflict,
        path: existing.archiveRelativePath,
      );
    }

    late final AttachmentArchiveFileInstall fileInstall;
    try {
      fileInstall = await _fileStore.installVerifiedArchiveEntry(
        archiveDirectoryPath: _writableRootLease.archiveRootPath,
        sourceBytes: donorPayload.openRead(),
        sourceExtension: donorPayload.sourceExtension,
        expectedSizeBytes: donorPayload.expectedSizeBytes,
        expectedSha256: donorPayload.expectedSha256,
        validateMutation: (boundary) async {
          mutationCapability.requireOperation(
            ArchiveMutationOperation.attachmentReconciliation,
          );
          await _writableRootLease.requireValid(
            operation: ArchiveMutationOperation.attachmentReconciliation,
            boundary: boundary,
          );
        },
      );
    } on AttachmentArchiveMutationDeferredException catch (error) {
      return _result(
        MessageLensAttachmentInstallationStatus.deferred,
        deferredReason: error.reason,
      );
    } on FileSystemException {
      final validation = await _writableRootLease.validate(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        boundary: AttachmentArchiveMutationBoundary.beforePayloadVerification,
      );
      if (!validation.isValid) {
        return _deferredResult(validation);
      }
      return _result(MessageLensAttachmentInstallationStatus.donorMissing);
    }

    final mappedStatus = switch (fileInstall.status) {
      AttachmentArchiveFileInstallStatus.conflict =>
        MessageLensAttachmentInstallationStatus.conflict,
      AttachmentArchiveFileInstallStatus.donorChanged =>
        MessageLensAttachmentInstallationStatus.donorChanged,
      AttachmentArchiveFileInstallStatus.verificationFailed =>
        MessageLensAttachmentInstallationStatus.verificationFailed,
      AttachmentArchiveFileInstallStatus.installed ||
      AttachmentArchiveFileInstallStatus.alreadyPresent => null,
    };
    if (mappedStatus != null) {
      return _result(mappedStatus, path: fileInstall.relativePath);
    }

    final metadataValidation = await _writableRootLease.validate(
      operation: ArchiveMutationOperation.attachmentReconciliation,
      boundary: AttachmentArchiveMutationBoundary.beforeMetadataCommit,
    );
    if (!metadataValidation.isValid) {
      return _deferredResult(
        metadataValidation,
        path: fileInstall.relativePath,
      );
    }

    try {
      await _writeStore.reconcileArchiveRecord(
        ArchivedAttachmentWrite(
          archiveKey: candidate.archiveCompatibilityKey,
          archiveRelativePath: fileInstall.relativePath,
          archivedAtUtc: (installedAtUtc ?? DateTime.now().toUtc())
              .toIso8601String(),
          fileSizeBytes: fileInstall.fileSizeBytes,
          contentHash: fileInstall.contentHash,
          provenance: 'recovered_message_lens_archive',
          originalLocalPath: null,
        ),
      );
    } on Object {
      return _result(
        MessageLensAttachmentInstallationStatus.metadataUpdateFailed,
        path: fileInstall.relativePath,
      );
    }

    return MessageLensAttachmentInstallationResult(
      status: fileInstall.status == AttachmentArchiveFileInstallStatus.installed
          ? MessageLensAttachmentInstallationStatus.installed
          : MessageLensAttachmentInstallationStatus.alreadyPresent,
      installedBytes:
          fileInstall.status == AttachmentArchiveFileInstallStatus.installed
          ? fileInstall.fileSizeBytes
          : 0,
      archiveRelativePath: fileInstall.relativePath,
    );
  }

  static MessageLensAttachmentInstallationResult _result(
    MessageLensAttachmentInstallationStatus status, {
    String? path,
    AttachmentArchiveMutationDeferredReason? deferredReason,
  }) {
    return MessageLensAttachmentInstallationResult(
      status: status,
      installedBytes: 0,
      archiveRelativePath: path,
      deferredReason: deferredReason,
    );
  }

  static MessageLensAttachmentInstallationResult _deferredResult(
    AttachmentArchiveWritableRootValidation validation, {
    String? path,
  }) {
    return _result(
      MessageLensAttachmentInstallationStatus.deferred,
      path: path,
      deferredReason: validation.deferredReason,
    );
  }
}
