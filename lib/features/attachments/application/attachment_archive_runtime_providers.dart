import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../infrastructure/repositories/attachment_archive_stats_repository.dart';
import '../infrastructure/repositories/filesystem_attachment_archive_file_operations.dart';
import 'attachment_archive_file_operations.dart';
import 'attachment_archive_location_provider.dart';
import 'attachment_archive_stats_reader.dart';

part 'attachment_archive_runtime_providers.g.dart';

@riverpod
AttachmentArchiveFileOperations attachmentArchiveFileOperations(
  AttachmentArchiveFileOperationsRef ref,
) {
  return const FilesystemAttachmentArchiveFileOperations();
}

@riverpod
Future<AttachmentArchiveStatsReader> attachmentArchiveStatsReader(
  AttachmentArchiveStatsReaderRef ref,
) async {
  final location = await ref.watch(attachmentArchiveLocationProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return AttachmentArchiveStatsRepository(
    archiveDirectoryPath: location.requireArchiveRootPath(),
    overlayDatabase: overlayDb,
  );
}
