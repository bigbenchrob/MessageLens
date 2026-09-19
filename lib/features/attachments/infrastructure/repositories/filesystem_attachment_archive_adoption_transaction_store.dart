import 'dart:convert';
import 'dart:io';

import '../../../../essentials/archive_environment/domain/archive_access_authority.dart';
import '../../application/attachment_archive_adoption_transaction_store.dart';
import '../../domain/entities/attachment_archive_adoption.dart';

/// Atomic single-record storage beneath the admitted primary MessageLens root.
///
/// The record is deliberately outside `attachment_archive` and never causes
/// either preservation root to be created, traversed, or mutated.
final class FilesystemAttachmentArchiveAdoptionTransactionStore
    implements AttachmentArchiveAdoptionTransactionStore {
  FilesystemAttachmentArchiveAdoptionTransactionStore({
    required ArchiveAccessAuthority archiveAccessAuthority,
  }) : _recordPath = archiveAccessAuthority.resolvePath(recordFileName);

  static const String recordFileName =
      '.messagelens-attachment-adoption-transaction.json';
  static const int _maximumRecordBytes = 256 * 1024;

  final String _recordPath;

  @override
  Future<AttachmentArchiveAdoptionTransaction?> readPending() async {
    final type = FileSystemEntity.typeSync(_recordPath, followLinks: false);
    if (type == FileSystemEntityType.notFound) {
      return null;
    }
    if (type != FileSystemEntityType.file) {
      throw const FileSystemException(
        'Attachment archive adoption transaction is not a regular file.',
      );
    }
    final file = File(_recordPath);
    final length = await file.length();
    if (length <= 0 || length > _maximumRecordBytes) {
      throw const FormatException(
        'Attachment archive adoption transaction size is invalid.',
      );
    }
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map) {
      throw const FormatException(
        'Attachment archive adoption transaction must be an object.',
      );
    }
    return AttachmentArchiveAdoptionTransaction.fromJson(
      Map<String, Object?>.from(decoded),
    );
  }

  @override
  Future<void> writePending(
    AttachmentArchiveAdoptionTransaction transaction,
  ) async {
    transaction.validate();
    final existing = await readPending();
    if (existing != null &&
        existing.transactionId != transaction.transactionId) {
      throw StateError(
        'Another attachment archive adoption transaction is pending.',
      );
    }
    final temporaryPath = '$_recordPath.${transaction.transactionId}.pending';
    final temporaryType = FileSystemEntity.typeSync(
      temporaryPath,
      followLinks: false,
    );
    if (temporaryType != FileSystemEntityType.notFound) {
      throw const FileSystemException(
        'Attachment archive adoption temporary record already exists.',
      );
    }
    final temporary = File(temporaryPath);
    await temporary.create(exclusive: true);
    try {
      await temporary.writeAsString(
        '${jsonEncode(transaction.toJson())}\n',
        flush: true,
      );
      await temporary.rename(_recordPath);
    } finally {
      if (temporary.existsSync()) {
        await temporary.delete();
      }
    }
  }

  @override
  Future<void> clearPending({required String expectedTransactionId}) async {
    final pending = await readPending();
    if (pending == null) {
      return;
    }
    if (pending.transactionId != expectedTransactionId) {
      throw StateError(
        'Attachment archive adoption transaction identity changed.',
      );
    }
    await File(_recordPath).delete();
  }
}
