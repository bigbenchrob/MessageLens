import 'onboarding_operation_snapshot.dart';

enum MessageLensInstallationStateKind {
  virgin,
  resumable,
  completed,
  abandoned,
  remediationRequired,
}

enum InstallationBoundedInspectionStatus {
  absent,
  passed,
  failed,
  contention,
  unsupportedSchema,
}

enum InstallationBoundedInspectionFailureKind {
  zeroByteDatabase,
  invalidSqlite,
  sqliteCorrupt,
  ioFailure,
  missingRequiredObject,
  targetedReadFailure,
  malformedOnboardingSnapshot,
  unknown,
}

final class InstallationBoundedInspectionFailure {
  const InstallationBoundedInspectionFailure({
    required this.kind,
    required this.message,
    this.sqliteResultCode,
  });

  final InstallationBoundedInspectionFailureKind kind;
  final String message;
  final int? sqliteResultCode;
}

final class InstallationDatabaseEvidence {
  const InstallationDatabaseEvidence({
    required this.boundedInspectionStatus,
    this.userVersion,
    this.currentSchemaVersion,
    this.messageCount,
    this.chatCount,
    this.chatMessageEdgeCount,
    this.nonLiveSourceCount,
    this.failure,
  });

  const InstallationDatabaseEvidence.absent()
    : this(boundedInspectionStatus: InstallationBoundedInspectionStatus.absent);

  const InstallationDatabaseEvidence.passed({
    required int userVersion,
    int? currentSchemaVersion,
    int? messageCount,
    int? chatCount,
    int? chatMessageEdgeCount,
    int? nonLiveSourceCount,
  }) : this(
         boundedInspectionStatus: InstallationBoundedInspectionStatus.passed,
         userVersion: userVersion,
         currentSchemaVersion: currentSchemaVersion ?? userVersion,
         messageCount: messageCount,
         chatCount: chatCount,
         chatMessageEdgeCount: chatMessageEdgeCount,
         nonLiveSourceCount: nonLiveSourceCount,
       );

  final InstallationBoundedInspectionStatus boundedInspectionStatus;
  final int? userVersion;
  final int? currentSchemaVersion;
  final int? messageCount;
  final int? chatCount;
  final int? chatMessageEdgeCount;
  final int? nonLiveSourceCount;
  final InstallationBoundedInspectionFailure? failure;

  bool get exists {
    return boundedInspectionStatus !=
        InstallationBoundedInspectionStatus.absent;
  }

  bool get passedBoundedInspection {
    return boundedInspectionStatus ==
        InstallationBoundedInspectionStatus.passed;
  }
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
  });

  final MessageLensInstallationStateKind kind;
  final String reason;

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
