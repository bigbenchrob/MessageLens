import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider;
import '../infrastructure/repositories/graph_cross_snapshot_mapper.dart';
import '../infrastructure/repositories/overlay_recovered_attachment_archive_writer.dart';
import '../infrastructure/repositories/sqlite_historical_snapshot_reader.dart';
import 'attachment_archive_store_providers.dart';
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
  final fileStore = ref.watch(attachmentArchiveFileStoreProvider);
  final writeStore = await ref.watch(
    attachmentArchiveWriteStoreProvider.future,
  );
  return OverlayRecoveredAttachmentArchiveWriter(
    fileStore: fileStore,
    writeStore: writeStore,
  );
}

@riverpod
HistoricalSnapshotReaderFactory historicalSnapshotReaderFactory(
  HistoricalSnapshotReaderFactoryRef ref,
) {
  return const SqliteHistoricalSnapshotReaderFactory();
}
