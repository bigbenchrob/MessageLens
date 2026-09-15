import '../domain/onboarding_environment_report.dart';
import 'onboarding_operation_snapshot_controller.dart';

OnboardingDurableReconciliationEvidence onboardingReconciliationEvidenceFrom(
  OnboardingEnvironmentReport report,
) {
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
      report.hasIncompleteOperationStage
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
      const OnboardingDurableReconciliationEvidence.resumable(),
  };
}
