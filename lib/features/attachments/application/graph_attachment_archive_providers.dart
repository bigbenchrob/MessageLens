import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import '../../../essentials/paths/feature_level_providers.dart'
    show pathsHelperProvider;
import '../../../essentials/source_scoped_import/feature_level_providers.dart'
    show sourceDatabaseOpenerProvider, sourceScopedImportLedgerProvider;
import '../infrastructure/repositories/import_ledger_message_lens_attachment_evidence_reader.dart';
import '../infrastructure/repositories/overlay_archive_compatibility_lookup.dart';
import '../infrastructure/repositories/source_database_attachment_path_lookup.dart';
import '../infrastructure/repositories/source_scoped_attachment_snapshot_lookup.dart';
import '../infrastructure/repositories/sqlite_graph_attachment_archive_candidate_reader.dart';
import 'attachment_archive_location_provider.dart';
import 'attachment_archive_store_providers.dart';
import 'current_attachment_snapshot_lookup.dart';
import 'current_messages_attachment_path_lookup.dart';
import 'graph_attachment_archive_candidate_reader.dart';
import 'graph_attachment_archive_lookup.dart';
import 'message_lens_attachment_evidence_reader.dart';

part 'graph_attachment_archive_providers.g.dart';

@riverpod
Future<GraphAttachmentArchiveLookup> graphAttachmentArchiveLookup(
  GraphAttachmentArchiveLookupRef ref,
) async {
  final location = await ref.watch(attachmentArchiveLocationProvider.future);
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayArchiveCompatibilityLookup(
    graphDatabase: graphDb,
    overlayDatabase: overlayDb,
    archiveDirectory: location.requireArchiveRootPath(),
  );
}

@riverpod
Future<GraphAttachmentArchiveCandidateReader>
graphAttachmentArchiveCandidateReader(
  GraphAttachmentArchiveCandidateReaderRef ref,
) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return SqliteGraphAttachmentArchiveCandidateReader(
    graphDatabase: graphDb,
    overlayDatabase: overlayDb,
  );
}

@riverpod
Future<CurrentAttachmentSnapshotLookup> currentAttachmentSnapshotLookup(
  CurrentAttachmentSnapshotLookupRef ref,
) async {
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  return SourceScopedAttachmentSnapshotLookup(importLedger: importLedger);
}

@riverpod
Future<CurrentMessageLensAttachmentEvidenceReader>
messageLensAttachmentCurrentEvidenceReader(
  MessageLensAttachmentCurrentEvidenceReaderRef ref,
) async {
  final location = await ref.watch(attachmentArchiveLocationProvider.future);
  return ImportLedgerMessageLensAttachmentEvidenceReader(
    importLedger: await ref.watch(sourceScopedImportLedgerProvider.future),
    archiveReadStore: await ref.watch(
      attachmentArchiveReadStoreProvider.future,
    ),
    archiveDirectoryPath: location.requireArchiveRootPath(),
  );
}

@riverpod
Future<CurrentMessagesAttachmentPathLookup> currentMessagesAttachmentPathLookup(
  CurrentMessagesAttachmentPathLookupRef ref,
) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  return SourceDatabaseAttachmentPathLookup(
    databasePath: pathsHelper.chatDBPath,
    sourceDatabaseOpener: ref.watch(sourceDatabaseOpenerProvider),
  );
}
