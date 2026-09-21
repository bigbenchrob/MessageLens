import '../../../essentials/archive_environment/domain/archive_access_authority.dart';
import '../../../essentials/archive_environment/domain/archive_mutation_operation.dart';
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability, ArchiveMutationCoordinator;
import '../domain/entities/attachment_archive_adoption.dart';
import '../domain/entities/attachment_archive_location_configuration.dart';
import '../domain/entities/attachment_archive_location_state.dart';
import 'attachment_archive_adoption_authority.dart';
import 'attachment_archive_adoption_root_inspector.dart';
import 'attachment_archive_adoption_service.dart';
import 'attachment_archive_adoption_transaction_store.dart';
import 'attachment_archive_bookmark_adapter.dart';
import 'attachment_archive_location_controller.dart';

/// Cheap startup recovery for the small adoption configuration-switch record.
///
/// Recovery reads one record and bounded location/bookmark/root evidence. It
/// never inventories an archive, reads grouped metadata, or hashes payloads.
final class AttachmentArchiveAdoptionRecoveryService {
  const AttachmentArchiveAdoptionRecoveryService({
    required ArchiveAccessAuthority archiveAccessAuthority,
    required ArchiveMutationCoordinator mutationCoordinator,
    required AttachmentArchiveAdoptionTransactionStore transactionStore,
    required AttachmentArchiveAdoptionAuthorityIssuer authorityIssuer,
    required AttachmentArchiveBookmarkAdapter bookmarkAdapter,
    required AttachmentArchiveAdoptionRootInspector rootInspector,
    required AttachmentArchiveAdoptionLocationReader readLocation,
    required AttachmentArchiveAdoptionLocationActivator restoreLocation,
  }) : _archiveAccessAuthority = archiveAccessAuthority,
       _mutationCoordinator = mutationCoordinator,
       _transactionStore = transactionStore,
       _authorityIssuer = authorityIssuer,
       _bookmarkAdapter = bookmarkAdapter,
       _rootInspector = rootInspector,
       _readLocation = readLocation,
       _restoreLocation = restoreLocation;

  final ArchiveAccessAuthority _archiveAccessAuthority;
  final ArchiveMutationCoordinator _mutationCoordinator;
  final AttachmentArchiveAdoptionTransactionStore _transactionStore;
  final AttachmentArchiveAdoptionAuthorityIssuer _authorityIssuer;
  final AttachmentArchiveBookmarkAdapter _bookmarkAdapter;
  final AttachmentArchiveAdoptionRootInspector _rootInspector;
  final AttachmentArchiveAdoptionLocationReader _readLocation;
  final AttachmentArchiveAdoptionLocationActivator _restoreLocation;

  Future<AttachmentArchiveAdoptionResult> recoverPending() async {
    final pending = await _transactionStore.readPending();
    if (pending == null) {
      return const AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.noPendingRecovery,
      );
    }
    return _mutationCoordinator.runWithCapability(
      operation: ArchiveMutationOperation.attachmentArchiveAdoption,
      ownerLabel: 'attachment-archive-adoption-recovery',
      action: (capability) =>
          _recoverWithinScope(transaction: pending, capability: capability),
    );
  }

  Future<AttachmentArchiveAdoptionResult> _recoverWithinScope({
    required AttachmentArchiveAdoptionTransaction transaction,
    required ArchiveMutationCapability capability,
  }) async {
    try {
      capability.requireOperation(
        ArchiveMutationOperation.attachmentArchiveAdoption,
      );
      final current = await _readLocation();
      if (current.configuration != transaction.previousConfiguration &&
          current.configuration != transaction.intendedConfiguration) {
        return AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome.configurationConflict,
          transactionId: transaction.transactionId,
          issue: 'Pending archive adoption found an unrelated configuration.',
        );
      }

      if (transaction.hasCrossedActiveAuthorityBoundary) {
        if (current.configuration != transaction.intendedConfiguration ||
            current.generation != transaction.sourceLocationGeneration + 1 ||
            !current.isWritableMutationEligible ||
            current.archiveRootPath == null) {
          return AttachmentArchiveAdoptionResult(
            outcome: AttachmentArchiveAdoptionOutcome.remediationPending,
            transactionId: transaction.transactionId,
            issue:
                'The adopted archive remains authoritative but is currently '
                'unavailable; historical remediation is pending.',
          );
        }
        try {
          final activeRoot = await _rootInspector.inspect(
            directoryPath: current.archiveRootPath!,
            label: 'active adopted archive',
          );
          if (activeRoot.canonicalPath !=
              transaction.candidateCanonicalIdentity) {
            return AttachmentArchiveAdoptionResult(
              outcome: AttachmentArchiveAdoptionOutcome.remediationPending,
              transactionId: transaction.transactionId,
              issue:
                  'The adopted archive identity cannot be proven; historical '
                  'remediation is pending.',
            );
          }
        } on Object catch (error) {
          return AttachmentArchiveAdoptionResult(
            outcome: AttachmentArchiveAdoptionOutcome.remediationPending,
            transactionId: transaction.transactionId,
            issue:
                'The adopted archive remains active; historical remediation '
                'is pending: $error',
          );
        }
        return AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome.remediationPending,
          transactionId: transaction.transactionId,
          issue:
              'The adopted archive is active. Resume adding the finite set of '
              'missing historical attachments in Settings.',
        );
      }

      final previousAvailable = await _previousSourceIsAvailable(transaction);
      if (!previousAvailable) {
        return AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome
              .rollbackPendingPreviousUnavailable,
          transactionId: transaction.transactionId,
          issue:
              'The previous archive is unavailable; configuration recovery '
              'remains pending.',
        );
      }

      if (current.configuration == transaction.previousConfiguration) {
        if (!await _locationMatchesPrevious(current, transaction)) {
          return AttachmentArchiveAdoptionResult(
            outcome: AttachmentArchiveAdoptionOutcome
                .rollbackPendingPreviousUnavailable,
            transactionId: transaction.transactionId,
            issue: 'The previous archive configuration could not be proven.',
          );
        }
        await _transactionStore.clearPending(
          expectedTransactionId: transaction.transactionId,
        );
        return AttachmentArchiveAdoptionResult(
          outcome:
              transaction.state ==
                  AttachmentArchiveAdoptionTransactionState.prepared
              ? AttachmentArchiveAdoptionOutcome.preparedTransactionAbandoned
              : AttachmentArchiveAdoptionOutcome.rollbackRestoredPrevious,
          transactionId: transaction.transactionId,
        );
      }

      final recoveryAuthority = await _authorityIssuer.issueRecoveryAuthority(
        transactionId: transaction.transactionId,
        capability: capability,
      );
      await _restoreLocation(
        configuration: transaction.previousConfiguration,
        adoptionAuthority: recoveryAuthority,
      );
      final restored = await _readLocation();
      if (!await _locationMatchesPrevious(restored, transaction)) {
        return AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome
              .rollbackPendingPreviousUnavailable,
          transactionId: transaction.transactionId,
          issue: 'The previous archive could not be proven after recovery.',
        );
      }
      await _transactionStore.clearPending(
        expectedTransactionId: transaction.transactionId,
      );
      return AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.rollbackRestoredPrevious,
        transactionId: transaction.transactionId,
      );
    } on Object catch (error) {
      return AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.failed,
        transactionId: transaction.transactionId,
        issue: 'Archive adoption recovery remains pending: $error',
      );
    }
  }

  Future<bool> _previousSourceIsAvailable(
    AttachmentArchiveAdoptionTransaction transaction,
  ) async {
    final previous = transaction.previousConfiguration;
    String? resolvedPath;
    if (previous.mode == AttachmentArchiveLocationMode.defaultInternal) {
      resolvedPath = _archiveAccessAuthority.resolvePath(
        AttachmentArchiveLocationController.defaultArchiveDirectoryName,
      );
    } else {
      final bookmark = previous.bookmarkDataBase64;
      if (bookmark == null) {
        return false;
      }
      final resolution = await _bookmarkAdapter.resolveBookmark(
        bookmarkDataBase64: bookmark,
      );
      if (resolution.status !=
              AttachmentArchiveBookmarkResolutionStatus.available &&
          resolution.status !=
              AttachmentArchiveBookmarkResolutionStatus.readOnly) {
        return false;
      }
      resolvedPath = resolution.resolvedPath;
    }
    if (resolvedPath == null) {
      return false;
    }
    try {
      final root = await _rootInspector.inspect(
        directoryPath: resolvedPath,
        label: 'previous attachment archive',
      );
      return root.canonicalPath == transaction.sourceCanonicalIdentity;
    } on Object {
      return false;
    }
  }

  Future<bool> _locationMatchesPrevious(
    AttachmentArchiveLocationState location,
    AttachmentArchiveAdoptionTransaction transaction,
  ) async {
    if (location.configuration != transaction.previousConfiguration ||
        !location.isAvailable ||
        location.archiveRootPath == null) {
      return false;
    }
    try {
      final root = await _rootInspector.inspect(
        directoryPath: location.archiveRootPath!,
        label: 'restored attachment archive',
      );
      return root.canonicalPath == transaction.sourceCanonicalIdentity;
    } on Object {
      return false;
    }
  }
}
