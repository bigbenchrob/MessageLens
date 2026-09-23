import '../../../essentials/archive_environment/domain/archive_mutation_operation.dart';
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability;
import '../domain/entities/attachment_archive_adoption.dart';
import '../domain/entities/attachment_archive_location_state.dart';
import 'attachment_archive_adoption_transaction_store.dart';
import 'attachment_archive_location_provider.dart';

typedef AttachmentArchiveRemediationLocationReader =
    Future<AttachmentArchiveLocationState> Function();

/// Scope-bound authority to install exactly one durable remediation payload.
///
/// Raw source/destination paths are deliberately insufficient. Every mutation
/// boundary rechecks the exact pending transaction, active candidate
/// configuration/generation, canonical candidate root, item evidence, and
/// coordinator capability.
final class AttachmentArchiveRemediationAuthority {
  const AttachmentArchiveRemediationAuthority._({
    required this.transactionId,
    required this.sourceCanonicalIdentity,
    required this.candidateCanonicalIdentity,
    required this.activeCandidateRootPath,
    required this.candidateLocationGeneration,
    required this.payload,
    required ArchiveMutationCapability capability,
    required AttachmentArchiveAdoptionTransactionStore transactionStore,
    required AttachmentArchiveRemediationLocationReader readLocation,
    required AttachmentArchiveWritableRootLease writableLease,
  }) : _capability = capability,
       _transactionStore = transactionStore,
       _readLocation = readLocation,
       _writableLease = writableLease;

  final String transactionId;
  final String sourceCanonicalIdentity;
  final String candidateCanonicalIdentity;
  final String activeCandidateRootPath;
  final int candidateLocationGeneration;
  final AttachmentArchiveRemediationPayload payload;
  final ArchiveMutationCapability _capability;
  final AttachmentArchiveAdoptionTransactionStore _transactionStore;
  final AttachmentArchiveRemediationLocationReader _readLocation;
  final AttachmentArchiveWritableRootLease _writableLease;

  static Future<AttachmentArchiveRemediationAuthority> issue({
    required AttachmentArchiveAdoptionTransaction transaction,
    required AttachmentArchiveRemediationPayload payload,
    required ArchiveMutationCapability capability,
    required AttachmentArchiveAdoptionTransactionStore transactionStore,
    required AttachmentArchiveRemediationLocationReader readLocation,
    required AttachmentArchiveWritableRootLease writableLease,
  }) async {
    capability.requireOperation(
      ArchiveMutationOperation.attachmentArchiveAdoption,
    );
    if (!transaction.hasCrossedActiveAuthorityBoundary ||
        transaction.kind !=
            AttachmentArchiveAdoptionTransactionKind.verifiedBehind ||
        !transaction.remediationPayloads.contains(payload)) {
      throw StateError(
        'Remediation authority requires an active exact transaction item.',
      );
    }
    final current = await readLocation();
    final activeRootPath = current.archiveRootPath;
    if (current.configuration != transaction.intendedConfiguration ||
        current.generation != transaction.sourceLocationGeneration + 1 ||
        activeRootPath == null) {
      throw StateError(
        'Remediation authority requires the exact active candidate generation.',
      );
    }
    if (writableLease.archiveRootPath != activeRootPath ||
        writableLease.locationGeneration != current.generation ||
        !writableLease.matchesConfiguration(
          transaction.intendedConfiguration,
        )) {
      throw StateError(
        'Remediation authority requires the active writable-root lease.',
      );
    }
    final authority = AttachmentArchiveRemediationAuthority._(
      transactionId: transaction.transactionId,
      sourceCanonicalIdentity: transaction.sourceCanonicalIdentity,
      candidateCanonicalIdentity: transaction.candidateCanonicalIdentity,
      activeCandidateRootPath: activeRootPath,
      candidateLocationGeneration: transaction.sourceLocationGeneration + 1,
      payload: payload,
      capability: capability,
      transactionStore: transactionStore,
      readLocation: readLocation,
      writableLease: writableLease,
    );
    await authority.requireValid(
      candidateRootPath: activeRootPath,
      boundary: AttachmentArchiveMutationBoundary.operationStart,
    );
    return authority;
  }

  Future<void> requireValid({
    required String candidateRootPath,
    required AttachmentArchiveMutationBoundary boundary,
  }) async {
    _capability.requireOperation(
      ArchiveMutationOperation.attachmentArchiveAdoption,
    );
    final pending = await _transactionStore.readPending();
    if (pending == null ||
        pending.transactionId != transactionId ||
        !pending.hasCrossedActiveAuthorityBoundary ||
        pending.sourceCanonicalIdentity != sourceCanonicalIdentity ||
        pending.candidateCanonicalIdentity != candidateCanonicalIdentity ||
        !pending.remediationPayloads.contains(payload)) {
      throw StateError(
        'The active remediation transaction no longer authorizes this item.',
      );
    }
    final current = await _readLocation();
    if (current.configuration != pending.intendedConfiguration ||
        current.generation != candidateLocationGeneration ||
        current.archiveRootPath != candidateRootPath ||
        candidateRootPath != activeCandidateRootPath) {
      throw StateError(
        'Remediation no longer targets the proven active archive generation.',
      );
    }
    if (boundary == AttachmentArchiveMutationBoundary.beforeDestructiveReset) {
      throw StateError('Remediation authority never permits deletion.');
    }
    await _writableLease.requireValid(
      operation: ArchiveMutationOperation.attachmentArchiveAdoption,
      boundary: boundary,
    );
  }
}
