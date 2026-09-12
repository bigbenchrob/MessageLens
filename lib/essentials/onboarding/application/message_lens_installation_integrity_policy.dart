import '../domain/message_lens_installation_state.dart';
import '../domain/onboarding_operation_snapshot.dart';
import '../domain/startup_installation_validation.dart';

sealed class StartupIntegrityPolicyDecision {
  const StartupIntegrityPolicyDecision();
}

final class StartupIntegrityNotRequired extends StartupIntegrityPolicyDecision {
  const StartupIntegrityNotRequired();
}

final class StartupIntegrityRequired extends StartupIntegrityPolicyDecision {
  const StartupIntegrityRequired({required this.requirement});

  final InstallationIntegrityRequirement requirement;
}

final class StartupIntegrityRejected extends StartupIntegrityPolicyDecision {
  const StartupIntegrityRejected();
}

final class StartupIntegrityBlocked extends StartupIntegrityPolicyDecision {
  const StartupIntegrityBlocked({required this.message});

  final String message;
}

final class MessageLensInstallationIntegrityPolicy {
  const MessageLensInstallationIntegrityPolicy();

  StartupIntegrityPolicyDecision decide({
    required MessageLensInstallationEvidence evidence,
    required MessageLensInstallationState installationState,
  }) {
    final databases = _databases(evidence);
    for (final entry in databases.entries) {
      if (entry.value.boundedInspectionStatus ==
          InstallationBoundedInspectionStatus.contention) {
        return StartupIntegrityBlocked(
          message:
              'Database inspection could not continue because '
              '${entry.key.name} is busy or locked.',
        );
      }
    }
    if (databases.values.any(
      (database) =>
          database.boundedInspectionStatus ==
          InstallationBoundedInspectionStatus.unsupportedSchema,
    )) {
      return const StartupIntegrityRejected();
    }

    final targets = <InstallationDatabaseKey>{};
    final triggers = <InstallationIntegrityValidationTrigger>{};
    for (final entry in databases.entries) {
      final failure = entry.value.failure;
      if (entry.value.boundedInspectionStatus !=
              InstallationBoundedInspectionStatus.failed ||
          failure == null) {
        continue;
      }
      targets.add(entry.key);
      triggers.add(_triggerFor(failure.kind));
    }

    if (evidence.operationSnapshotFailure != null) {
      targets.add(InstallationDatabaseKey.overlay);
      triggers.add(
        InstallationIntegrityValidationTrigger.malformedOnboardingSnapshot,
      );
    }

    for (final entry in databases.entries) {
      final database = entry.value;
      final userVersion = database.userVersion;
      final currentVersion = database.currentSchemaVersion;
      if (database.passedBoundedInspection &&
          userVersion != null &&
          currentVersion != null &&
          userVersion < currentVersion) {
        targets.add(entry.key);
        triggers.add(
          InstallationIntegrityValidationTrigger.olderSupportedSchema,
        );
      }
    }

    final import = evidence.sourceScopedImport;
    final graph = evidence.conversationGraph;
    if (import.passedBoundedInspection && graph.passedBoundedInspection) {
      if ((import.messageCount ?? 0) != (graph.messageCount ?? 0)) {
        targets
          ..add(InstallationDatabaseKey.sourceScopedImport)
          ..add(InstallationDatabaseKey.conversationGraph);
        triggers.add(
          InstallationIntegrityValidationTrigger.importGraphLogicalMismatch,
        );
      }
      final graphMessages = graph.messageCount ?? 0;
      if (graphMessages > 0 &&
          ((graph.chatCount ?? 0) == 0 ||
              (graph.chatMessageEdgeCount ?? 0) == 0)) {
        targets
          ..add(InstallationDatabaseKey.sourceScopedImport)
          ..add(InstallationDatabaseKey.conversationGraph);
        triggers.add(
          InstallationIntegrityValidationTrigger.graphTopologyMismatch,
        );
      }
    }

    final operationStatus = evidence.operationSnapshot.status;
    if (operationStatus == OnboardingOperationStatus.running ||
        operationStatus == OnboardingOperationStatus.interrupted ||
        operationStatus == OnboardingOperationStatus.failed) {
      targets.addAll(_existingDatabaseKeys(databases));
      triggers.add(
        InstallationIntegrityValidationTrigger
            .onboardingOperationRequiresValidation,
      );
    }

    if (operationStatus == OnboardingOperationStatus.completed &&
        installationState.kind ==
            MessageLensInstallationStateKind.remediationRequired) {
      targets.addAll(<InstallationDatabaseKey>{
        InstallationDatabaseKey.overlay,
        InstallationDatabaseKey.sourceScopedImport,
        InstallationDatabaseKey.conversationGraph,
      });
      triggers.add(
        InstallationIntegrityValidationTrigger.importGraphLogicalMismatch,
      );
    }

    if ((import.nonLiveSourceCount ?? 0) > 0 &&
        installationState.kind != MessageLensInstallationStateKind.completed) {
      targets
        ..add(InstallationDatabaseKey.sourceScopedImport)
        ..add(InstallationDatabaseKey.conversationGraph);
      triggers.add(
        InstallationIntegrityValidationTrigger.importGraphLogicalMismatch,
      );
    }

    if (triggers.isEmpty) {
      return const StartupIntegrityNotRequired();
    }
    final existingTargets = _orderedDatabaseKeys.where((key) {
      return targets.contains(key) && databases[key]?.exists == true;
    });
    if (existingTargets.isEmpty) {
      return const StartupIntegrityRejected();
    }
    return StartupIntegrityRequired(
      requirement: InstallationIntegrityRequirement(
        targets: existingTargets,
        triggers: triggers,
      ),
    );
  }

  InstallationIntegrityValidationTrigger _triggerFor(
    InstallationBoundedInspectionFailureKind kind,
  ) {
    return switch (kind) {
      InstallationBoundedInspectionFailureKind.zeroByteDatabase =>
        InstallationIntegrityValidationTrigger.zeroByteDatabase,
      InstallationBoundedInspectionFailureKind.invalidSqlite =>
        InstallationIntegrityValidationTrigger.invalidSqlite,
      InstallationBoundedInspectionFailureKind.sqliteCorrupt =>
        InstallationIntegrityValidationTrigger.sqliteCorrupt,
      InstallationBoundedInspectionFailureKind.ioFailure =>
        InstallationIntegrityValidationTrigger.ioFailure,
      InstallationBoundedInspectionFailureKind.missingRequiredObject =>
        InstallationIntegrityValidationTrigger.missingRequiredObject,
      InstallationBoundedInspectionFailureKind.targetedReadFailure =>
        InstallationIntegrityValidationTrigger.targetedReadFailure,
      InstallationBoundedInspectionFailureKind.malformedOnboardingSnapshot =>
        InstallationIntegrityValidationTrigger.malformedOnboardingSnapshot,
      InstallationBoundedInspectionFailureKind.unknown =>
        InstallationIntegrityValidationTrigger.unknownFailure,
    };
  }
}

const _orderedDatabaseKeys = <InstallationDatabaseKey>[
  InstallationDatabaseKey.overlay,
  InstallationDatabaseKey.sourceScopedImport,
  InstallationDatabaseKey.conversationGraph,
  InstallationDatabaseKey.presence,
];

Map<InstallationDatabaseKey, InstallationDatabaseEvidence> _databases(
  MessageLensInstallationEvidence evidence,
) {
  return <InstallationDatabaseKey, InstallationDatabaseEvidence>{
    InstallationDatabaseKey.overlay: evidence.overlay,
    InstallationDatabaseKey.sourceScopedImport: evidence.sourceScopedImport,
    InstallationDatabaseKey.conversationGraph: evidence.conversationGraph,
    InstallationDatabaseKey.presence: evidence.presence,
  };
}

Iterable<InstallationDatabaseKey> _existingDatabaseKeys(
  Map<InstallationDatabaseKey, InstallationDatabaseEvidence> databases,
) {
  return _orderedDatabaseKeys.where((key) => databases[key]?.exists == true);
}
