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
    this.inspectionDurationMicroseconds = 0,
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
  final int inspectionDurationMicroseconds;

  bool get exists {
    return boundedInspectionStatus !=
        InstallationBoundedInspectionStatus.absent;
  }

  bool get passedBoundedInspection {
    return boundedInspectionStatus ==
        InstallationBoundedInspectionStatus.passed;
  }

  InstallationDatabaseEvidence withInspectionDurationMicroseconds(
    int durationMicroseconds,
  ) {
    return InstallationDatabaseEvidence(
      boundedInspectionStatus: boundedInspectionStatus,
      userVersion: userVersion,
      currentSchemaVersion: currentSchemaVersion,
      messageCount: messageCount,
      chatCount: chatCount,
      chatMessageEdgeCount: chatMessageEdgeCount,
      nonLiveSourceCount: nonLiveSourceCount,
      failure: failure,
      inspectionDurationMicroseconds: durationMicroseconds,
    );
  }
}

/// Snapshot-free physical evidence about stores under one admitted root.
///
/// This value contains no workflow cursor, journey state, or semantic outcome.
/// It can therefore be shared by startup observers without making any of them
/// an onboarding authority.
final class MessageLensPhysicalInstallationEvidence {
  const MessageLensPhysicalInstallationEvidence({
    required this.sourceScopedImport,
    required this.conversationGraph,
    required this.overlay,
    required this.presence,
    required this.hasRetiredDerivedArtifacts,
  });

  final InstallationDatabaseEvidence sourceScopedImport;
  final InstallationDatabaseEvidence conversationGraph;
  final InstallationDatabaseEvidence overlay;
  final InstallationDatabaseEvidence presence;
  final bool hasRetiredDerivedArtifacts;
}
