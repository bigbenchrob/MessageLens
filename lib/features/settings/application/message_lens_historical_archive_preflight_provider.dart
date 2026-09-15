import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../../../essentials/source_scoped_import/feature_level_providers.dart'
    show
        messagesLineageAdmissionAuthorityProvider,
        sourceScopedImportLedgerProvider;
import '../../attachments/feature_level_providers.dart'
    show attachmentArchiveLocationProvider, attachmentArchiveReadStoreProvider;
import '../../attachments/infrastructure/repositories/import_ledger_message_lens_attachment_evidence_reader.dart';
import '../../attachments/infrastructure/repositories/sqlite_message_lens_attachment_recovery_donor_qualifier.dart';
import '../infrastructure/repositories/message_lens_historical_archive_preflight_service.dart';
import 'message_lens_historical_archive_preflight.dart';

part 'message_lens_historical_archive_preflight_provider.g.dart';

@riverpod
Future<MessageLensHistoricalArchivePreflight>
messageLensHistoricalArchivePreflight(
  MessageLensHistoricalArchivePreflightRef ref,
) async {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  final location = await ref.watch(attachmentArchiveLocationProvider.future);
  final currentReader = ImportLedgerMessageLensAttachmentEvidenceReader(
    importLedger: await ref.watch(sourceScopedImportLedgerProvider.future),
    archiveReadStore: await ref.watch(
      attachmentArchiveReadStoreProvider.future,
    ),
    archiveDirectoryPath: location.requireArchiveRootPath(),
  );
  return MessageLensHistoricalArchivePreflightService(
    donorQualifier: SqliteMessageLensAttachmentRecoveryDonorQualifier(
      currentArchiveRoot: authority.rootPath,
      currentArchiveInstanceId: authority.identity.archiveInstanceId.value,
      currentArchiveEnvironment: authority.identity.environment,
    ),
    lineageAdmissionAuthority: await ref.watch(
      messagesLineageAdmissionAuthorityProvider.future,
    ),
    currentEvidenceReader: currentReader,
  );
}
