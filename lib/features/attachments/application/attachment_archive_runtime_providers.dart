import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../domain/entities/attachment_archive_location_state.dart';
import '../domain/entities/attachment_archive_stats.dart';
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

/// Explicit, potentially recursive archive inventory.
///
/// Ordinary settings, startup, search, and attachment resolution never watch
/// this provider. Callers opt into the scan and receive a root-level
/// unavailable result rather than an exception when a custom volume is gone.
@riverpod
Future<AttachmentArchiveStatisticsSnapshot> attachmentArchiveStatistics(
  AttachmentArchiveStatisticsRef ref,
) async {
  final location = await ref.watch(attachmentArchiveLocationProvider.future);
  if (!location.isAvailable) {
    return AttachmentArchiveStatisticsSnapshot(location: location, stats: null);
  }
  final reader = await ref.watch(attachmentArchiveStatsReaderProvider.future);
  return AttachmentArchiveStatisticsSnapshot(
    location: location,
    stats: await reader.readStats(),
  );
}

class AttachmentArchiveStatisticsSnapshot {
  const AttachmentArchiveStatisticsSnapshot({
    required this.location,
    required this.stats,
  });

  final AttachmentArchiveLocationState location;
  final AttachmentArchiveStats? stats;

  bool get isAvailable => stats != null;
}
