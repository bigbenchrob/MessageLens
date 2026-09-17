import 'dart:async';

import '../domain/entities/attachment_archive_location_configuration.dart';
import '../domain/entities/attachment_archive_relocation.dart';
import 'attachment_archive_relocation_journal_store.dart';

final class AttachmentArchiveRelocationActivationPermit {
  const AttachmentArchiveRelocationActivationPermit._({
    required this.operationId,
    required AttachmentArchiveLocationConfiguration intendedConfiguration,
    required AttachmentArchiveLocationConfiguration previousConfiguration,
  }) : _intendedConfiguration = intendedConfiguration,
       _previousConfiguration = previousConfiguration;

  final String operationId;
  final AttachmentArchiveLocationConfiguration _intendedConfiguration;
  final AttachmentArchiveLocationConfiguration _previousConfiguration;

  void requireActivationConfiguration(
    AttachmentArchiveLocationConfiguration configuration,
  ) {
    if (configuration != _intendedConfiguration ||
        configuration.mode != AttachmentArchiveLocationMode.customExternal ||
        configuration.customWritePolicy !=
            AttachmentArchiveCustomWritePolicy.activeArchive) {
      throw StateError(
        'Relocation activation permit does not match the requested '
        'configuration.',
      );
    }
  }

  void requireRollbackConfiguration(
    AttachmentArchiveLocationConfiguration configuration,
  ) {
    if (configuration != _previousConfiguration) {
      throw StateError(
        'Relocation activation permit does not match the rollback '
        'configuration.',
      );
    }
  }
}

final class AttachmentArchiveRelocationActivationGate {
  const AttachmentArchiveRelocationActivationGate({
    required AttachmentArchiveRelocationJournalStore journalStore,
  }) : _journalStore = journalStore;

  final AttachmentArchiveRelocationJournalStore _journalStore;

  Future<AttachmentArchiveRelocationActivationPermit> issuePermit(
    String operationId,
  ) async {
    final journal = await _journalStore.read(operationId);
    final intended = journal.intendedConfiguration;
    if (journal.stage !=
            AttachmentArchiveRelocationStage.configurationSwitching ||
        intended == null ||
        intended.mode != AttachmentArchiveLocationMode.customExternal ||
        intended.customWritePolicy !=
            AttachmentArchiveCustomWritePolicy.activeArchive ||
        journal.manifestSha256 == null ||
        journal.copiedFileCount != journal.expectedFileCount ||
        journal.copiedByteCount != journal.expectedByteCount ||
        journal.verifiedFileCount != journal.expectedFileCount ||
        journal.verifiedByteCount != journal.expectedByteCount ||
        journal.activationOccurred ||
        journal.failure != null ||
        journal.deferredReason != null) {
      throw StateError(
        'Attachment archive relocation has not earned activation authority.',
      );
    }
    if (await _journalStore.hashManifest(operationId) !=
        journal.manifestSha256) {
      throw StateError('Attachment relocation manifest integrity failed.');
    }

    final manifests = StreamIterator(_journalStore.readManifest(operationId));
    var receiptCount = 0;
    var receiptBytes = 0;
    try {
      await for (final receipt in _journalStore.readCopyReceipts(operationId)) {
        if (!await manifests.moveNext() ||
            receipt.index != receiptCount ||
            receipt.relativePath != manifests.current.relativePath ||
            receipt.sizeBytes != manifests.current.sizeBytes ||
            !RegExp(r'^[0-9a-f]{64}$').hasMatch(receipt.sha256)) {
          throw StateError(
            'Attachment relocation receipt sequence is invalid.',
          );
        }
        receiptCount++;
        receiptBytes += receipt.sizeBytes;
      }
      if (await manifests.moveNext()) {
        throw StateError(
          'Attachment relocation receipt coverage is incomplete.',
        );
      }
    } finally {
      await manifests.cancel();
    }
    if (receiptCount != journal.expectedFileCount ||
        receiptBytes != journal.expectedByteCount) {
      throw StateError('Attachment relocation receipt coverage is incomplete.');
    }
    return AttachmentArchiveRelocationActivationPermit._(
      operationId: operationId,
      intendedConfiguration: intended,
      previousConfiguration: journal.previousConfiguration,
    );
  }
}
