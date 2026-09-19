import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider, archiveMutationCoordinatorProvider;
import '../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../domain/entities/attachment_archive_adoption.dart';
import '../domain/entities/attachment_archive_location_state.dart';
import '../infrastructure/repositories/filesystem_attachment_archive_adoption_root_inspector.dart';
import '../infrastructure/repositories/filesystem_attachment_archive_adoption_transaction_store.dart';
import '../infrastructure/repositories/filesystem_attachment_archive_candidate_verifier.dart';
import '../infrastructure/repositories/overlay_attachment_archive_verification_metadata_reader.dart';
import 'attachment_archive_adoption_authority.dart';
import 'attachment_archive_adoption_recovery_service.dart';
import 'attachment_archive_adoption_service.dart';
import 'attachment_archive_approval_revalidator.dart';
import 'attachment_archive_location_dependencies_provider.dart';
import 'attachment_archive_location_provider.dart';

part 'attachment_archive_adoption_provider.g.dart';

/// Internal composition for the approval-to-adoption transaction.
///
/// This provider is deliberately not consumed by Settings in Checkpoint Four.
@riverpod
Future<AttachmentArchiveAdoptionService> attachmentArchiveAdoptionService(
  Ref ref,
) async {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  final transactionStore = FilesystemAttachmentArchiveAdoptionTransactionStore(
    archiveAccessAuthority: authority,
  );
  final nativeAdapter = ref.watch(
    attachmentArchiveLocationNativeAdapterProvider,
  );
  final snapshotReader = FilesystemAttachmentArchiveCandidateVerifier(
    metadataReader: OverlayAttachmentArchiveVerificationMetadataReader(
      overlayDatabase: overlayDatabase,
    ),
  );
  return AttachmentArchiveAdoptionService(
    archiveAccessAuthority: authority,
    mutationCoordinator: ref.read(archiveMutationCoordinatorProvider.notifier),
    currentLocationReader: _CallbackAttachmentArchiveLocationReader(
      () => ref.read(attachmentArchiveLocationProvider.future),
    ),
    snapshotReader: snapshotReader,
    transactionStore: transactionStore,
    authorityIssuer: AttachmentArchiveAdoptionAuthorityIssuer(
      transactionStore: transactionStore,
    ),
    bookmarkAdapter: nativeAdapter,
    rootInspector: const FilesystemAttachmentArchiveAdoptionRootInspector(),
    readLocation: () => ref.read(attachmentArchiveLocationProvider.future),
    activateLocation: ({required configuration, required adoptionAuthority}) {
      return ref
          .read(attachmentArchiveLocationProvider.notifier)
          .activateVerifiedAdoption(
            configuration: configuration,
            adoptionAuthority: adoptionAuthority,
          );
    },
    restoreLocation: ({required configuration, required adoptionAuthority}) {
      return ref
          .read(attachmentArchiveLocationProvider.notifier)
          .restoreAdoptionConfiguration(
            configuration: configuration,
            adoptionAuthority: adoptionAuthority,
          );
    },
    readWritableAdmission: () =>
        ref.read(attachmentArchiveWritableRootAdmissionProvider.future),
  );
}

/// Performs the bounded startup rollback check for an interrupted adoption.
@Riverpod(keepAlive: true)
Future<AttachmentArchiveAdoptionResult> attachmentArchiveAdoptionRecovery(
  Ref ref,
) async {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  final transactionStore = FilesystemAttachmentArchiveAdoptionTransactionStore(
    archiveAccessAuthority: authority,
  );
  final nativeAdapter = ref.watch(
    attachmentArchiveLocationNativeAdapterProvider,
  );
  final service = AttachmentArchiveAdoptionRecoveryService(
    archiveAccessAuthority: authority,
    mutationCoordinator: ref.read(archiveMutationCoordinatorProvider.notifier),
    transactionStore: transactionStore,
    authorityIssuer: AttachmentArchiveAdoptionAuthorityIssuer(
      transactionStore: transactionStore,
    ),
    bookmarkAdapter: nativeAdapter,
    rootInspector: const FilesystemAttachmentArchiveAdoptionRootInspector(),
    readLocation: () => ref.read(attachmentArchiveLocationProvider.future),
    restoreLocation: ({required configuration, required adoptionAuthority}) {
      return ref
          .read(attachmentArchiveLocationProvider.notifier)
          .restoreAdoptionConfiguration(
            configuration: configuration,
            adoptionAuthority: adoptionAuthority,
          );
    },
  );
  try {
    return await service.recoverPending();
  } on Object catch (error) {
    return AttachmentArchiveAdoptionResult(
      outcome: AttachmentArchiveAdoptionOutcome.failed,
      issue:
          'Archive adoption startup recovery could not read its record: '
          '$error',
    );
  }
}

final class _CallbackAttachmentArchiveLocationReader
    implements AttachmentArchiveApprovalCurrentLocationReader {
  const _CallbackAttachmentArchiveLocationReader(this._read);

  final Future<AttachmentArchiveLocationState> Function() _read;

  @override
  Future<AttachmentArchiveLocationState> readCurrentLocation() {
    return _read();
  }
}
