import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../infrastructure/repositories/filesystem_attachment_archive_file_store.dart';
import '../infrastructure/repositories/local_attachment_file_access.dart';
import '../infrastructure/repositories/overlay_attachment_archive_read_store.dart';
import '../infrastructure/repositories/overlay_attachment_archive_write_store.dart';
import 'attachment_archive_file_store.dart';
import 'attachment_archive_location_provider.dart';
import 'attachment_archive_read_store.dart';
import 'attachment_archive_write_store.dart';
import 'attachment_file_access.dart';

part 'attachment_archive_store_providers.g.dart';

@riverpod
AttachmentFileAccess attachmentFileAccess(AttachmentFileAccessRef ref) {
  return const LocalAttachmentFileAccess();
}

@riverpod
AttachmentArchiveFileStore attachmentArchiveFileStore(
  AttachmentArchiveFileStoreRef ref,
) {
  return const FilesystemAttachmentArchiveFileStore();
}

@riverpod
Future<AttachmentArchiveReadStore> attachmentArchiveReadStore(
  AttachmentArchiveReadStoreRef ref,
) async {
  final location = await ref.watch(attachmentArchiveLocationProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayAttachmentArchiveReadStore(
    overlayDb: overlayDb,
    location: location,
  );
}

@riverpod
Future<AttachmentArchiveWriteStore> attachmentArchiveWriteStore(
  AttachmentArchiveWriteStoreRef ref,
) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayAttachmentArchiveWriteStore(overlayDatabase: overlayDb);
}
