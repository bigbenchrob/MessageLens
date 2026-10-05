import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/paths/feature_level_providers.dart'
    show pathsHelperProvider;
import '../../../essentials/source_scoped_import/feature_level_providers.dart'
    show sourceDatabaseOpenerProvider;
import '../infrastructure/repositories/source_database_current_messages_attachment_source_reader.dart';
import 'admitted_attachment_archive_repair_writer.dart';
import 'attachment_archive_store_providers.dart';
import 'current_messages_attachment_source_reader.dart';

part 'attachment_archive_repair_providers.g.dart';

@riverpod
Future<CurrentMessagesAttachmentSourceReader>
currentMessagesAttachmentSourceReader(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  return SourceDatabaseCurrentMessagesAttachmentSourceReader(
    databasePath: pathsHelper.chatDBPath,
    sourceDatabaseOpener: ref.watch(sourceDatabaseOpenerProvider),
  );
}

@riverpod
Future<AdmittedAttachmentArchiveRepairWriter>
admittedAttachmentArchiveRepairWriter(Ref ref) async {
  return AdmittedAttachmentArchiveRepairWriter(
    sourceReader: await ref.watch(
      currentMessagesAttachmentSourceReaderProvider.future,
    ),
    fileStore: ref.watch(attachmentArchiveFileStoreProvider),
    readStore: await ref.watch(attachmentArchiveReadStoreProvider.future),
    writeStore: await ref.watch(attachmentArchiveWriteStoreProvider.future),
  );
}
