import '../../../essentials/archive_environment/domain/archive_mutation_operation.dart';
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability;
import '../domain/entities/attachment_archive_adoption.dart';
import '../domain/entities/attachment_archive_approval_revalidation.dart';
import '../domain/entities/attachment_archive_location_configuration.dart';
import 'attachment_archive_adoption_service.dart';
import 'attachment_archive_adoption_transaction_store.dart';
import 'attachment_archive_approval_revalidator.dart';

/// Opaque, scope-bound configuration authority for verified archive adoption.
///
/// Only this library can construct implementations. Every use revalidates the
/// exact coordinator capability, so an authority expires with its originating
/// adoption scope and cannot become durable configuration authority.
sealed class AttachmentArchiveAdoptionConfigurationAuthority {
  const AttachmentArchiveAdoptionConfigurationAuthority._({
    required this.transactionId,
    required ArchiveMutationCapability capability,
    required AttachmentArchiveLocationConfiguration previousConfiguration,
    required AttachmentArchiveLocationConfiguration intendedConfiguration,
    required bool permitsActivation,
  }) : _capability = capability,
       _previousConfiguration = previousConfiguration,
       _intendedConfiguration = intendedConfiguration,
       _permitsActivation = permitsActivation;

  final String transactionId;
  final ArchiveMutationCapability _capability;
  final AttachmentArchiveLocationConfiguration _previousConfiguration;
  final AttachmentArchiveLocationConfiguration _intendedConfiguration;
  final bool _permitsActivation;

  void requireActivationConfiguration(
    AttachmentArchiveLocationConfiguration configuration,
  ) {
    _requireActiveScope();
    if (!_permitsActivation ||
        configuration != _intendedConfiguration ||
        configuration.mode != AttachmentArchiveLocationMode.customExternal ||
        configuration.customWritePolicy !=
            AttachmentArchiveCustomWritePolicy.activeArchive) {
      throw StateError(
        'Archive adoption authority does not permit this activation.',
      );
    }
  }

  void requireRollbackConfiguration(
    AttachmentArchiveLocationConfiguration configuration,
  ) {
    _requireActiveScope();
    if (configuration != _previousConfiguration) {
      throw StateError(
        'Archive adoption authority does not permit this rollback.',
      );
    }
  }

  void _requireActiveScope() {
    _capability.requireOperation(
      ArchiveMutationOperation.attachmentArchiveAdoption,
    );
  }
}

final class _VerifiedAttachmentArchiveAdoptionAuthority
    extends AttachmentArchiveAdoptionConfigurationAuthority {
  const _VerifiedAttachmentArchiveAdoptionAuthority({
    required super.transactionId,
    required super.capability,
    required super.previousConfiguration,
    required super.intendedConfiguration,
  }) : super._(permitsActivation: true);
}

final class _AttachmentArchiveAdoptionRecoveryAuthority
    extends AttachmentArchiveAdoptionConfigurationAuthority {
  const _AttachmentArchiveAdoptionRecoveryAuthority({
    required super.transactionId,
    required super.capability,
    required super.previousConfiguration,
    required super.intendedConfiguration,
  }) : super._(permitsActivation: false);
}

final class AttachmentArchiveAdoptionAuthorityIssuer {
  const AttachmentArchiveAdoptionAuthorityIssuer({
    required AttachmentArchiveAdoptionTransactionStore transactionStore,
  }) : _transactionStore = transactionStore;

  final AttachmentArchiveAdoptionTransactionStore _transactionStore;

  Future<AttachmentArchiveAdoptionConfigurationAuthority>
  issueVerifiedAuthority({
    required String transactionId,
    required AttachmentArchiveApprovalReadyEvidence readyEvidence,
    required AttachmentArchiveLocationConfiguration previousConfiguration,
    required AttachmentArchiveLocationConfiguration intendedConfiguration,
    required ArchiveMutationCapability capability,
    required AttachmentArchiveApprovalScopeProof approvalScopeProof,
    required AttachmentArchiveAdoptionBookmarkProof bookmarkProof,
  }) async {
    capability.requireOperation(
      ArchiveMutationOperation.attachmentArchiveAdoption,
    );
    approvalScopeProof.requireExactReadyEvidence(
      readyEvidence: readyEvidence,
      capability: capability,
    );
    bookmarkProof.requireExactAdmission(
      readyEvidence: readyEvidence,
      approvalScopeProof: approvalScopeProof,
      intendedConfiguration: intendedConfiguration,
      capability: capability,
    );
    final transaction = await _requirePending(transactionId);
    if (transaction.state !=
            AttachmentArchiveAdoptionTransactionState.prepared ||
        transaction.previousConfiguration != previousConfiguration ||
        transaction.intendedConfiguration != intendedConfiguration ||
        transaction.sourceCanonicalIdentity !=
            readyEvidence.sourceCanonicalIdentity ||
        transaction.candidateCanonicalIdentity !=
            readyEvidence.candidateCanonicalIdentity ||
        transaction.sourceLocationGeneration !=
            readyEvidence.sourceLocationGeneration ||
        transaction.verificationContentDigest !=
            readyEvidence.contentCoverageDigest ||
        transaction.sourceStructuralSnapshotFingerprint !=
            readyEvidence.sourceStructuralSnapshotFingerprint ||
        transaction.candidateStructuralSnapshotFingerprint !=
            readyEvidence.candidateStructuralSnapshotFingerprint ||
        transaction.verifiedFileCount !=
            readyEvidence.verification.evidence!.verifiedFileCount ||
        transaction.verifiedBytes !=
            readyEvidence.verification.evidence!.verifiedBytes) {
      throw StateError(
        'Pending adoption transaction does not match freshly approved evidence.',
      );
    }
    return _VerifiedAttachmentArchiveAdoptionAuthority(
      transactionId: transactionId,
      capability: capability,
      previousConfiguration: previousConfiguration,
      intendedConfiguration: intendedConfiguration,
    );
  }

  Future<AttachmentArchiveAdoptionConfigurationAuthority>
  issueRecoveryAuthority({
    required String transactionId,
    required ArchiveMutationCapability capability,
  }) async {
    capability.requireOperation(
      ArchiveMutationOperation.attachmentArchiveAdoption,
    );
    final transaction = await _requirePending(transactionId);
    return _AttachmentArchiveAdoptionRecoveryAuthority(
      transactionId: transactionId,
      capability: capability,
      previousConfiguration: transaction.previousConfiguration,
      intendedConfiguration: transaction.intendedConfiguration,
    );
  }

  Future<AttachmentArchiveAdoptionTransaction> _requirePending(
    String transactionId,
  ) async {
    final transaction = await _transactionStore.readPending();
    if (transaction == null || transaction.transactionId != transactionId) {
      throw StateError(
        'Verified archive adoption requires its exact durable transaction.',
      );
    }
    return transaction;
  }
}
