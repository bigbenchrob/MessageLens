import '../domain/entities/attachment_archive_adoption.dart';

/// Persistence for the single small pending archive-adoption switch record.
abstract interface class AttachmentArchiveAdoptionTransactionStore {
  Future<AttachmentArchiveAdoptionTransaction?> readPending();

  Future<void> writePending(AttachmentArchiveAdoptionTransaction transaction);

  Future<void> clearPending({required String expectedTransactionId});
}
