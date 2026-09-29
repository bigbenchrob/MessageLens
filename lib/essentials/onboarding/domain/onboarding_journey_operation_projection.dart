import 'package:meta/meta.dart';

import 'onboarding_operation_snapshot.dart';

enum OnboardingJourneyOperationPhase { active, interrupted, failed, verified }

enum OnboardingJourneyOperationAction {
  continueSetup,
  retry,
  acknowledgeCompletion,
}

@immutable
final class OnboardingJourneyOperationProgress {
  const OnboardingJourneyOperationProgress({
    required this.completedWorkUnits,
    required this.totalWorkUnits,
  }) : assert(completedWorkUnits >= 0),
       assert(totalWorkUnits > 0),
       assert(completedWorkUnits <= totalWorkUnits);

  final int completedWorkUnits;
  final int totalWorkUnits;

  double get fraction => completedWorkUnits / totalWorkUnits;
}

@immutable
final class OnboardingJourneyOperationFailure {
  const OnboardingJourneyOperationFailure({
    required this.category,
    required this.summary,
  });

  final OnboardingOperationFailureCategory category;
  final String summary;
}

/// Journey-owned, presentation-safe interpretation of durable operation
/// evidence.
///
/// This is deliberately narrower than [OnboardingOperationSnapshot]. It has no
/// process identity, persistence vocabulary, recovery authority, or mutation
/// capability. Widgets may render it but cannot reinterpret raw evidence.
@immutable
final class OnboardingJourneyOperationProjection {
  OnboardingJourneyOperationProjection({
    required this.operationId,
    required this.kind,
    required this.phase,
    required this.stage,
    required this.substage,
    required this.progressRevision,
    required this.progress,
    required this.failure,
    required Set<OnboardingJourneyOperationAction> availableActions,
  }) : availableActions = Set.unmodifiable(availableActions);

  final OnboardingOperationId operationId;
  final OnboardingOperationKind kind;
  final OnboardingJourneyOperationPhase phase;
  final OnboardingOperationStage stage;
  final OnboardingOperationSubstage? substage;
  final int progressRevision;
  final OnboardingJourneyOperationProgress? progress;
  final OnboardingJourneyOperationFailure? failure;
  final Set<OnboardingJourneyOperationAction> availableActions;

  bool get isActive => phase == OnboardingJourneyOperationPhase.active;
}
