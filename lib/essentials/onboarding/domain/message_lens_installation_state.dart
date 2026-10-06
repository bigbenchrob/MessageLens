import '../../installation_evidence/domain/message_lens_physical_installation_evidence.dart';
import 'onboarding_operation_snapshot.dart';

export '../../installation_evidence/domain/message_lens_physical_installation_evidence.dart';

enum MessageLensInstallationStateKind {
  virgin,
  resumable,
  completed,
  abandoned,
  remediationRequired,
}

enum MessageLensInstallationReasonCode {
  malformedOnboardingSnapshot,
  preservationStoreUnavailable,
  derivedStoreUnavailable,
  durableStoresReconciled,
  completedEvidenceMismatch,
  historicalSourcesRequireReview,
  virginNoConsequentialImport,
  resumableOperation,
  abandonedArtifacts,
  physicalIntegrityFailure,
  unspecified,
}

final class MessageLensInstallationEvidence {
  const MessageLensInstallationEvidence({
    required this.sourceScopedImport,
    required this.conversationGraph,
    required this.overlay,
    required this.presence,
    required this.hasRetiredDerivedArtifacts,
    required this.operationSnapshot,
    this.operationSnapshotFailure,
  });

  final InstallationDatabaseEvidence sourceScopedImport;
  final InstallationDatabaseEvidence conversationGraph;
  final InstallationDatabaseEvidence overlay;
  final InstallationDatabaseEvidence presence;
  final bool hasRetiredDerivedArtifacts;
  final OnboardingOperationSnapshot operationSnapshot;
  final InstallationBoundedInspectionFailure? operationSnapshotFailure;
}

final class MessageLensInstallationState {
  const MessageLensInstallationState({
    required this.kind,
    required this.reason,
    this.reasonCode = MessageLensInstallationReasonCode.unspecified,
  });

  final MessageLensInstallationStateKind kind;
  final String reason;
  final MessageLensInstallationReasonCode reasonCode;

  bool get mayContinue {
    return kind == MessageLensInstallationStateKind.virgin ||
        kind == MessageLensInstallationStateKind.resumable ||
        kind == MessageLensInstallationStateKind.completed;
  }

  bool get mayStartFresh {
    return kind == MessageLensInstallationStateKind.resumable ||
        kind == MessageLensInstallationStateKind.abandoned;
  }

  bool get requiresStartupAttention {
    return kind == MessageLensInstallationStateKind.abandoned ||
        kind == MessageLensInstallationStateKind.remediationRequired;
  }
}
