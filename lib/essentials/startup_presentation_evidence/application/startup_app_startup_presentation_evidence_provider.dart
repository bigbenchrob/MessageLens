import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../onboarding/domain/onboarding_operation_snapshot.dart';
import '../../onboarding/domain/startup_validation_telemetry.dart';
import '../../onboarding/feature_level_providers.dart'
    show
        onboardingOperationControllerProvider,
        startupValidationTelemetryProvider;
import '../domain/startup_presentation_evidence.dart';

part 'startup_app_startup_presentation_evidence_provider.g.dart';

@riverpod
StartupPresentationEvidence startupAppStartupPresentationEvidence(Ref ref) {
  if (!ref.exists(startupValidationTelemetryProvider)) {
    return StartupPresentationEvidence.unavailable(
      composition: StartupPresentationComposition.startupApp,
      reason: 'No StartupApp admission evidence is live in this process.',
    );
  }
  final snapshot = ref.watch(startupValidationTelemetryProvider).snapshot();
  for (final event in snapshot.events.reversed) {
    if (event.kind == StartupValidationEventKind.admissionDecided) {
      return StartupPresentationEvidence.startupApp(
        installationState: event.installationKind?.name,
        admissionBasis: event.admissionBasis?.name,
      );
    }
  }
  return StartupPresentationEvidence.unavailable(
    composition: StartupPresentationComposition.startupApp,
    reason: 'No StartupApp admission decision has been recorded.',
  );
}

@riverpod
Future<StartupSupportEvidence> startupAppStartupSupportEvidence(Ref ref) async {
  final operationController = await ref.watch(
    onboardingOperationControllerProvider.future,
  );
  final telemetry = ref.watch(startupValidationTelemetryProvider).snapshot();
  final operation = operationController.current;
  final presentation = ref.watch(startupAppStartupPresentationEvidenceProvider);
  return StartupSupportEvidence(
    presentation: presentation,
    headerDescription: 'startup validation, onboarding operation evidence',
    artifacts: <StartupSupportArtifact>[
      StartupSupportArtifact(
        kind: StartupSupportArtifactKind.startupValidation,
        json: telemetry.toJson(),
      ),
      StartupSupportArtifact(
        kind: StartupSupportArtifactKind.onboardingOperation,
        json: _operationJson(operation),
      ),
    ],
  );
}

Map<String, Object?> _operationJson(OnboardingOperationSnapshot snapshot) {
  final progress = snapshot.progress;
  final failure = snapshot.failure;
  return <String, Object?>{
    'schema_version': 1,
    'status': snapshot.status.name,
    if (snapshot.kind case final kind?) 'kind': kind.name,
    if (snapshot.currentStage case final stage?) 'stage': stage.name,
    if (snapshot.currentSubstage case final substage?)
      'substage': substage.name,
    if (snapshot.startedAtUtc case final startedAt?)
      'started_at_utc': startedAt.toUtc().toIso8601String(),
    if (snapshot.lastProgressObservedAtUtc case final observedAt?)
      'last_progress_observed_at_utc': observedAt.toUtc().toIso8601String(),
    if (snapshot.finishedAtUtc case final finishedAt?)
      'finished_at_utc': finishedAt.toUtc().toIso8601String(),
    if (progress != null)
      'progress': <String, Object?>{
        'completed_work_units': progress.completedWorkUnits,
        'total_work_units': progress.totalWorkUnits,
      },
    'source_anomaly_counts': snapshot.sourceAnomalyCounts.toJson(),
    if (failure != null)
      'failure': <String, Object?>{
        'category': failure.category.name,
        'recovery_disposition': failure.recoveryDisposition.name,
      },
    'privacy_notes': <String>[
      'Operation and aggregate progress evidence only.',
      'Operation identifiers, source row identifiers, content, and paths are omitted.',
    ],
  };
}
