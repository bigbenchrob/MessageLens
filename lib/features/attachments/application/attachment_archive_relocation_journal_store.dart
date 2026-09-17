import '../domain/entities/attachment_archive_relocation.dart';

abstract interface class AttachmentArchiveRelocationJournalStore {
  Future<void> create(AttachmentArchiveRelocationJournal journal);

  Future<void> save(AttachmentArchiveRelocationJournal journal);

  Future<AttachmentArchiveRelocationJournal?> readCurrent();

  Future<AttachmentArchiveRelocationJournal> read(String operationId);

  Future<void> beginManifest(String operationId);

  Future<void> appendManifestEntry({
    required String operationId,
    required AttachmentArchiveRelocationManifestEntry entry,
  });

  Stream<AttachmentArchiveRelocationManifestEntry> readManifest(
    String operationId,
  );

  Future<String> hashManifest(String operationId);

  Future<void> beginCopyReceipts(String operationId);

  Future<void> appendCopyReceipt({
    required String operationId,
    required AttachmentArchiveRelocationCopyReceipt receipt,
  });

  Stream<AttachmentArchiveRelocationCopyReceipt> readCopyReceipts(
    String operationId,
  );
}
