import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import '../infrastructure/repositories/graph_cross_snapshot_mapper.dart';
import '../infrastructure/repositories/overlay_recovered_attachment_archive_writer.dart';
import '../infrastructure/repositories/sqlite_historical_snapshot_reader.dart';
import 'attachment_archive_location_provider.dart';
import 'cross_snapshot_mapper.dart';
import 'graph_attachment_archive_providers.dart';
import 'historical_snapshot_reader.dart';
import 'recovered_attachment_archive_writer.dart';

part 'deterministic_recovery_runtime_providers.g.dart';

@riverpod
Future<CrossSnapshotMapper> crossSnapshotMapper(
  CrossSnapshotMapperRef ref,
) async {
  final attachmentLookup = await ref.watch(
    currentAttachmentSnapshotLookupProvider.future,
  );
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return GraphCrossSnapshotMapper(
    attachmentLookup: attachmentLookup,
    graphDb: graphDb,
  );
}

@riverpod
Future<RecoveredAttachmentArchiveWriter> recoveredAttachmentArchiveWriter(
  RecoveredAttachmentArchiveWriterRef ref,
) async {
  final mutationRoot = await ref.watch(
    attachmentArchiveMutationRootProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayRecoveredAttachmentArchiveWriter(
    overlayDb: overlayDb,
    archiveDir: mutationRoot.archiveRootPath,
  );
}

@riverpod
HistoricalSnapshotReaderFactory historicalSnapshotReaderFactory(
  HistoricalSnapshotReaderFactoryRef ref,
) {
  return const SqliteHistoricalSnapshotReaderFactory();
}
