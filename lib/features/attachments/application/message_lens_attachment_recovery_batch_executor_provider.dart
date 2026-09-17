import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/repositories/message_lens_attachment_payload_inspector.dart';
import '../infrastructure/repositories/sqlite_message_lens_attachment_donor_evidence_reader.dart';
import 'attachment_archive_location_provider.dart';
import 'attachment_archive_store_providers.dart';
import 'graph_attachment_archive_providers.dart';
import 'message_lens_attachment_recovery_batch_executor.dart';
import 'message_lens_attachment_recovery_installer.dart';

part 'message_lens_attachment_recovery_batch_executor_provider.g.dart';

@riverpod
Future<MessageLensAttachmentRecoveryBatchRunner>
messageLensAttachmentRecoveryBatchExecutor(
  MessageLensAttachmentRecoveryBatchExecutorRef ref, {
  required String donorArchiveRoot,
}) async {
  final admission = await ref.watch(
    attachmentArchiveWritableRootAdmissionProvider.future,
  );
  final writableRootLease = admission.lease;
  if (writableRootLease == null) {
    return DeferredMessageLensAttachmentRecoveryBatchRunner(
      admission.deferredReason!,
    );
  }
  final fileStore = ref.watch(attachmentArchiveFileStoreProvider);
  final readStore = await ref.watch(attachmentArchiveReadStoreProvider.future);
  final writeStore = await ref.watch(
    attachmentArchiveWriteStoreProvider.future,
  );
  final currentReader = await ref.watch(
    messageLensAttachmentCurrentEvidenceReaderProvider.future,
  );
  final donorReader =
      SqliteMessageLensAttachmentDonorEvidenceReader.forArchiveRoot(
        donorArchiveRoot: donorArchiveRoot,
      );
  return MessageLensAttachmentRecoveryBatchExecutor(
    donorEvidenceReader: donorReader,
    currentEvidenceReader: currentReader,
    payloadVerifier: const MessageLensAttachmentPayloadInspector(),
    installer: MessageLensAttachmentRecoveryInstaller(
      fileStore: fileStore,
      readStore: readStore,
      writeStore: writeStore,
      writableRootLease: writableRootLease,
    ),
    fileStore: fileStore,
    writableRootLease: writableRootLease,
  );
}
