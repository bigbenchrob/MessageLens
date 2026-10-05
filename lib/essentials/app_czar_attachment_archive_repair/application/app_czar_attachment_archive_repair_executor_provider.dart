import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/app_czar_attachment_archive_repair_models.dart';

part 'app_czar_attachment_archive_repair_executor_provider.g.dart';

/// One-use execution boundary for one generation-bound repair occurrence.
abstract interface class AppCzarAttachmentArchiveRepairExecutor {
  Future<AppCzarAttachmentArchiveRepairObservation> inspectCurrent({
    required AppCzarAttachmentArchiveRepairBinding binding,
  });

  Future<AppCzarAttachmentArchiveRepairObservation> preserveAvailable({
    required AppCzarAttachmentArchiveRepairBinding binding,
    AppCzarAttachmentArchiveRepairProgressObserver? onProgress,
  });

  /// Synchronously rejects new work before awaiting active source/writer work.
  Future<void> stopAndDrain();
}

abstract interface class AppCzarAttachmentArchiveRepairExecutorFactory {
  AppCzarAttachmentArchiveRepairExecutor create();
}

final class UnconfiguredAppCzarAttachmentArchiveRepairExecutorFactory
    implements AppCzarAttachmentArchiveRepairExecutorFactory {
  const UnconfiguredAppCzarAttachmentArchiveRepairExecutorFactory();

  @override
  AppCzarAttachmentArchiveRepairExecutor create() {
    throw StateError(
      'Attachment Archive Repair executor must be supplied by the admitted '
      'development composition.',
    );
  }
}

@Riverpod(keepAlive: true)
AppCzarAttachmentArchiveRepairExecutorFactory
appCzarAttachmentArchiveRepairExecutorFactory(Ref ref) {
  return const UnconfiguredAppCzarAttachmentArchiveRepairExecutorFactory();
}
