import '../domain/onboarding_environment_report.dart';
import '../domain/onboarding_operation_snapshot.dart';
import 'onboarding_operation_snapshot_controller.dart';

OnboardingDurableReconciliationEvidence onboardingReconciliationEvidenceFrom(
  OnboardingEnvironmentReport report,
  OnboardingOperationSnapshot snapshot,
) {
  final hasInterruptedOperation =
      snapshot.status == OnboardingOperationStatus.interrupted;
  final hasExactSafeBoundary =
      hasInterruptedOperation && _hasExactSafeBoundary(snapshot);
  if (hasInterruptedOperation && !hasExactSafeBoundary) {
    return const OnboardingDurableReconciliationEvidence.inconsistent(
      failureSummary:
          'The interrupted setup operation has no verified safe resume boundary.',
    );
  }
  return switch (report.state) {
    OnboardingEnvironmentState.ready =>
      OnboardingDurableReconciliationEvidence.completed(
        proof: OnboardingInstallationReadyProof(
          verifiedAtUtc: DateTime.now().toUtc(),
          sourceScopedImportRows:
              report.sourceScopedImportDatabase.rowCount ?? 0,
          conversationGraphRows: report.conversationGraph.rowCount ?? 0,
        ),
      ),
    OnboardingEnvironmentState.importFailed =>
      OnboardingDurableReconciliationEvidence.inconsistent(
        failureSummary:
            report.importFailureMessage ??
            'The durable source import reports a failure.',
      ),
    OnboardingEnvironmentState.graphProjectionFailed =>
      hasExactSafeBoundary
          ? const OnboardingDurableReconciliationEvidence.resumable()
          : OnboardingDurableReconciliationEvidence.inconsistent(
              failureSummary:
                  report.graphProjectionFailureMessage ??
                  'The durable conversation graph reports a failure.',
            ),
    OnboardingEnvironmentState.maintenanceInProgress =>
      const OnboardingDurableReconciliationEvidence.unavailable(),
    OnboardingEnvironmentState.permissionBlocked ||
    OnboardingEnvironmentState.sourceUnavailable ||
    OnboardingEnvironmentState.sourceSparseOrUnsynced ||
    OnboardingEnvironmentState.readyToImport =>
      hasExactSafeBoundary
          ? const OnboardingDurableReconciliationEvidence.resumable()
          : const OnboardingDurableReconciliationEvidence.unavailable(),
  };
}

bool _hasExactSafeBoundary(OnboardingOperationSnapshot snapshot) {
  final kind = snapshot.kind;
  final stage = snapshot.currentStage;
  final substage = snapshot.currentSubstage;
  if (kind == null || stage == null || substage == null) {
    return false;
  }
  final stageBelongsToKind = switch (kind) {
    OnboardingOperationKind.initialImport =>
      stage == OnboardingOperationStage.messageDataBuild ||
          stage == OnboardingOperationStage.durableReadinessVerification,
    OnboardingOperationKind.reimport =>
      stage == OnboardingOperationStage.environmentPreparation ||
          stage == OnboardingOperationStage.messageDataBuild ||
          stage == OnboardingOperationStage.durableReadinessVerification,
    OnboardingOperationKind.automaticRecovery =>
      stage == OnboardingOperationStage.automaticRecoveryReset,
  };
  if (!stageBelongsToKind) {
    return false;
  }
  return switch (stage) {
    OnboardingOperationStage.environmentPreparation =>
      substage == OnboardingOperationSubstage.preparingEnvironment ||
          substage == OnboardingOperationSubstage.resettingDerivedData,
    OnboardingOperationStage.messageDataBuild =>
      substage != OnboardingOperationSubstage.preparingEnvironment &&
          substage != OnboardingOperationSubstage.resettingDerivedData &&
          substage != OnboardingOperationSubstage.verifyingDurableReadiness,
    OnboardingOperationStage.durableReadinessVerification =>
      substage == OnboardingOperationSubstage.verifyingDurableReadiness,
    OnboardingOperationStage.automaticRecoveryReset =>
      substage == OnboardingOperationSubstage.resettingDerivedData,
  };
}
