import 'message_lens_installation_state.dart';

enum InstallationDatabaseKey {
  sourceScopedImport,
  conversationGraph,
  overlay,
  presence,
}

enum InstallationIntegrityValidationTrigger {
  zeroByteDatabase,
  invalidSqlite,
  sqliteCorrupt,
  ioFailure,
  missingRequiredObject,
  targetedReadFailure,
  malformedOnboardingSnapshot,
  importGraphLogicalMismatch,
  graphTopologyMismatch,
  onboardingOperationRequiresValidation,
  olderSupportedSchema,
  destructiveJournalCompatibility,
  startFreshMutationBoundary,
  explicitRequest,
  unknownFailure,
}

final class InstallationIntegrityRequirement {
  InstallationIntegrityRequirement({
    required Iterable<InstallationDatabaseKey> targets,
    required Iterable<InstallationIntegrityValidationTrigger> triggers,
  }) : targets = List<InstallationDatabaseKey>.unmodifiable(targets),
       triggers = Set<InstallationIntegrityValidationTrigger>.unmodifiable(
         triggers,
       );

  final List<InstallationDatabaseKey> targets;
  final Set<InstallationIntegrityValidationTrigger> triggers;
}

enum InstallationIntegrityValidationStatus { passed, failed, contention }

final class InstallationDatabaseIntegrityValidation {
  const InstallationDatabaseIntegrityValidation({
    required this.database,
    required this.status,
    this.failure,
  });

  final InstallationDatabaseKey database;
  final InstallationIntegrityValidationStatus status;
  final String? failure;
}

final class InstallationIntegrityValidationReport {
  InstallationIntegrityValidationReport({
    required Iterable<InstallationDatabaseIntegrityValidation> results,
  }) : results = List<InstallationDatabaseIntegrityValidation>.unmodifiable(
         results,
       );

  final List<InstallationDatabaseIntegrityValidation> results;

  bool get passed {
    return results.every(
      (result) => result.status == InstallationIntegrityValidationStatus.passed,
    );
  }

  InstallationDatabaseIntegrityValidation? get contention {
    for (final result in results) {
      if (result.status == InstallationIntegrityValidationStatus.contention) {
        return result;
      }
    }
    return null;
  }
}

enum StartupAdmissionBasis { boundedInspection, integrityValidation }

sealed class StartupInstallationValidationState {
  const StartupInstallationValidationState();

  MessageLensInstallationState? get resolvedInstallationState {
    return switch (this) {
      StartupBoundedInspectionInProgress() ||
      StartupIntegrityValidationRequired() ||
      StartupIntegrityValidationInProgress() ||
      StartupValidationBlocked() => null,
      StartupBoundedInspectionPassed(:final installationState) ||
      StartupIntegrityValidationPassed(:final installationState) ||
      StartupAdmissionGranted(:final installationState) ||
      StartupAdmissionWithheld(:final installationState) ||
      StartupIntegrityValidationFailed(
        :final installationState,
      ) => installationState,
    };
  }
}

final class StartupBoundedInspectionInProgress
    extends StartupInstallationValidationState {
  const StartupBoundedInspectionInProgress();
}

final class StartupBoundedInspectionPassed
    extends StartupInstallationValidationState {
  const StartupBoundedInspectionPassed({required this.installationState});

  final MessageLensInstallationState installationState;
}

final class StartupIntegrityValidationRequired
    extends StartupInstallationValidationState {
  const StartupIntegrityValidationRequired({required this.requirement});

  final InstallationIntegrityRequirement requirement;
}

final class StartupIntegrityValidationInProgress
    extends StartupInstallationValidationState {
  const StartupIntegrityValidationInProgress({
    required this.requirement,
    required this.currentDatabase,
    required this.completedDatabaseCount,
  });

  final InstallationIntegrityRequirement requirement;
  final InstallationDatabaseKey currentDatabase;
  final int completedDatabaseCount;

  int get totalDatabaseCount => requirement.targets.length;
}

final class StartupIntegrityValidationPassed
    extends StartupInstallationValidationState {
  const StartupIntegrityValidationPassed({
    required this.installationState,
    required this.report,
  });

  final MessageLensInstallationState installationState;
  final InstallationIntegrityValidationReport report;
}

final class StartupIntegrityValidationFailed
    extends StartupInstallationValidationState {
  const StartupIntegrityValidationFailed({
    required this.installationState,
    required this.report,
  });

  final MessageLensInstallationState installationState;
  final InstallationIntegrityValidationReport report;
}

final class StartupAdmissionGranted extends StartupInstallationValidationState {
  const StartupAdmissionGranted({
    required this.installationState,
    required this.basis,
  });

  final MessageLensInstallationState installationState;
  final StartupAdmissionBasis basis;
}

final class StartupAdmissionWithheld
    extends StartupInstallationValidationState {
  const StartupAdmissionWithheld({
    required this.installationState,
    required this.basis,
  });

  final MessageLensInstallationState installationState;
  final StartupAdmissionBasis basis;
}

final class StartupValidationBlocked
    extends StartupInstallationValidationState {
  const StartupValidationBlocked({required this.message});

  final String message;
}
