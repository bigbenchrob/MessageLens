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
import 'attachment_archive_relocation_service.dart';

part 'attachment_archive_relocation_provider.g.dart';

/// Internal Phase Five engine composition.
///
/// This provider is deliberately absent from the attachments public seam and
/// has no production UI action. Phase Six may expose a reviewed workflow.
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

@riverpod
class AttachmentArchiveRelocationWorkflow
    extends _$AttachmentArchiveRelocationWorkflow {
  @override
  AsyncValue<AttachmentArchiveRelocationProgress?> build() {
    return const AsyncData(null);
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

  Future<AttachmentArchiveRelocationProgress> run(String operationId) async {
    state = const AsyncLoading();
    final service = await ref.read(
      attachmentArchiveRelocationServiceProvider.future,
    );
    final coordinator = ref.read(archiveMutationCoordinatorProvider.notifier);
    try {
      final progress = await coordinator.runWithCapability(
        operation: ArchiveMutationOperation.attachmentRelocation,
        ownerLabel: 'attachment-archive-relocation-$operationId',
        action: (capability) => service.run(
          operationId: operationId,
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

  Future<AttachmentArchiveRelocationProgress> cancel(String operationId) async {
    state = const AsyncLoading();
    final service = await ref.read(
      attachmentArchiveRelocationServiceProvider.future,
    );
    final coordinator = ref.read(archiveMutationCoordinatorProvider.notifier);
    try {
      final progress = await coordinator.runWithCapability(
        operation: ArchiveMutationOperation.attachmentRelocation,
        ownerLabel: 'attachment-archive-relocation-cancel-$operationId',
        action: (capability) => service.cancel(
          operationId: operationId,
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
}
