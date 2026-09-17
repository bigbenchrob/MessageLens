import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_environment/domain/archive_mutation_operation.dart';
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider, archiveMutationCoordinatorProvider;
import '../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../domain/entities/attachment_archive_relocation.dart';
import '../infrastructure/repositories/filesystem_attachment_archive_relocation_file_system.dart';
import '../infrastructure/repositories/filesystem_attachment_archive_relocation_journal_store.dart';
import '../infrastructure/repositories/overlay_attachment_archive_relocation_metadata_reader.dart';
import 'attachment_archive_location_dependencies_provider.dart';
import 'attachment_archive_location_provider.dart';
import 'attachment_archive_relocation_activation_gate.dart';
import 'attachment_archive_relocation_progress_monitor.dart';
import 'attachment_archive_relocation_service.dart';

part 'attachment_archive_relocation_provider.g.dart';

/// Internal relocation-engine composition.
@riverpod
Future<AttachmentArchiveRelocationService> attachmentArchiveRelocationService(
  Ref ref,
) async {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  final nativeAdapter = ref.watch(
    attachmentArchiveLocationNativeAdapterProvider,
  );
  final journalStore = FilesystemAttachmentArchiveRelocationJournalStore(
    primaryArchiveRootPath: authority.rootPath,
  );
  return AttachmentArchiveRelocationService(
    archiveAccessAuthority: authority,
    journalStore: journalStore,
    metadataReader: OverlayAttachmentArchiveRelocationMetadataReader(
      overlayDatabase: overlayDatabase,
    ),
    fileSystem: FilesystemAttachmentArchiveRelocationFileSystem(
      capacityReader: nativeAdapter,
    ),
    nativeAdapter: nativeAdapter,
    activationGate: AttachmentArchiveRelocationActivationGate(
      journalStore: journalStore,
    ),
    readLocation: () => ref.read(attachmentArchiveLocationProvider.future),
    activateLocation: ({required configuration, required activationPermit}) {
      return ref
          .read(attachmentArchiveLocationProvider.notifier)
          .activateVerifiedRelocation(
            configuration: configuration,
            activationPermit: activationPermit,
          );
    },
    restoreLocation: ({required configuration, required activationPermit}) {
      return ref
          .read(attachmentArchiveLocationProvider.notifier)
          .restoreRelocationConfiguration(
            configuration: configuration,
            activationPermit: activationPermit,
          );
    },
    readWritableAdmission: () =>
        ref.read(attachmentArchiveWritableRootAdmissionProvider.future),
  );
}

@Riverpod(keepAlive: true)
class AttachmentArchiveRelocationWorkflow
    extends _$AttachmentArchiveRelocationWorkflow {
  String? _pauseRequestedOperationId;

  @override
  Future<AttachmentArchiveRelocationProgress?> build() async {
    final authority = ref.watch(archiveAccessAuthorityProvider);
    final journalStore = FilesystemAttachmentArchiveRelocationJournalStore(
      primaryArchiveRootPath: authority.rootPath,
    );
    final journal = await journalStore.readCurrent();
    return journal == null
        ? null
        : AttachmentArchiveRelocationProgress.fromJournal(journal);
  }

  Future<AttachmentArchiveRelocationProgress> selectDestination(
    String destinationParentPath,
  ) async {
    state = const AsyncLoading();
    final service = await ref.read(
      attachmentArchiveRelocationServiceProvider.future,
    );
    final coordinator = ref.read(archiveMutationCoordinatorProvider.notifier);
    try {
      final progress = await coordinator.runWithCapability(
        operation: ArchiveMutationOperation.attachmentRelocation,
        ownerLabel: 'attachment-archive-relocation-selection',
        action: (capability) => service.selectDestination(
          destinationParentPath: destinationParentPath,
          mutationCapability: capability,
        ),
      );
      state = AsyncData(progress);
      return progress;
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<AttachmentArchiveRelocationProgress?>
  chooseDestinationAndPrepare() async {
    final destinationParentPath = await chooseDestinationParent();
    if (destinationParentPath == null) {
      return state.valueOrNull;
    }
    final selected = await selectDestination(destinationParentPath);
    return prepareForReview(selected.operationId);
  }

  Future<String?> chooseDestinationParent() {
    return ref
        .read(attachmentArchiveLocationFolderChooserProvider)
        .chooseArchiveDirectory();
  }

  Future<AttachmentArchiveRelocationProgress> prepareForReview(
    String operationId,
  ) async {
    final service = await ref.read(
      attachmentArchiveRelocationServiceProvider.future,
    );
    final coordinator = ref.read(archiveMutationCoordinatorProvider.notifier);
    return _runWithJournalProgress(
      operationId: operationId,
      action: () => coordinator.runWithCapability(
        operation: ArchiveMutationOperation.attachmentRelocation,
        ownerLabel: 'attachment-archive-relocation-preflight-$operationId',
        action: (capability) => service.prepareForReview(
          operationId: operationId,
          mutationCapability: capability,
        ),
      ),
    );
  }

  Future<AttachmentArchiveRelocationProgress> run(String operationId) async {
    final service = await ref.read(
      attachmentArchiveRelocationServiceProvider.future,
    );
    final coordinator = ref.read(archiveMutationCoordinatorProvider.notifier);
    _pauseRequestedOperationId = null;
    return _runWithJournalProgress(
      operationId: operationId,
      action: () => coordinator.runWithCapability(
        operation: ArchiveMutationOperation.attachmentRelocation,
        ownerLabel: 'attachment-archive-relocation-$operationId',
        action: (capability) => service.run(
          operationId: operationId,
          mutationCapability: capability,
          pauseRequested: () => _pauseRequestedOperationId == operationId,
        ),
      ),
    );
  }

  void requestPause(String operationId) {
    final progress = state.valueOrNull;
    if (progress?.operationId != operationId || progress?.canPause != true) {
      throw StateError(
        'Attachment archive relocation cannot pause in the current stage.',
      );
    }
    _pauseRequestedOperationId = operationId;
  }

  Future<AttachmentArchiveRelocationProgress> cancel(String operationId) async {
    final service = await ref.read(
      attachmentArchiveRelocationServiceProvider.future,
    );
    final coordinator = ref.read(archiveMutationCoordinatorProvider.notifier);
    return _runWithJournalProgress(
      operationId: operationId,
      action: () => coordinator.runWithCapability(
        operation: ArchiveMutationOperation.attachmentRelocation,
        ownerLabel: 'attachment-archive-relocation-cancel-$operationId',
        action: (capability) => service.cancel(
          operationId: operationId,
          mutationCapability: capability,
        ),
      ),
    );
  }

  Future<void> refreshFromJournal() async {
    final authority = ref.read(archiveAccessAuthorityProvider);
    final journalStore = FilesystemAttachmentArchiveRelocationJournalStore(
      primaryArchiveRootPath: authority.rootPath,
    );
    final journal = await journalStore.readCurrent();
    state = AsyncData(
      journal == null
          ? null
          : AttachmentArchiveRelocationProgress.fromJournal(journal),
    );
  }

  Future<AttachmentArchiveRelocationProgress> _runWithJournalProgress({
    required String operationId,
    required Future<AttachmentArchiveRelocationProgress> Function() action,
  }) async {
    final service = await ref.read(
      attachmentArchiveRelocationServiceProvider.future,
    );
    final monitor = AttachmentArchiveRelocationProgressMonitor(service: service)
      ..start(
        operationId: operationId,
        onProgress: (progress) => state = AsyncData(progress),
        onError: (error, stackTrace) => state = AsyncError(error, stackTrace),
      );
    try {
      final progress = await action();
      monitor.stop();
      state = AsyncData(progress);
      return progress;
    } on Object catch (error, stackTrace) {
      monitor.stop();
      try {
        state = AsyncData(await service.readProgress(operationId));
      } on Object {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    } finally {
      monitor.stop();
      _pauseRequestedOperationId = null;
    }
  }
}
