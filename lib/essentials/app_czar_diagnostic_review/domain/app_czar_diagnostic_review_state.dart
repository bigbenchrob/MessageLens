import 'package:meta/meta.dart';

import '../../app_czar/domain/app_czar_models.dart';

enum AppCzarDiagnosticReviewPhase {
  dormant,
  presenting,
  draining,
  restartFailed,
  quitRequested,
}

@immutable
final class AppCzarDiagnosticReviewOccurrence {
  const AppCzarDiagnosticReviewOccurrence({
    required this.processSequence,
    required this.assessmentGeneration,
    required this.capturedAssessmentState,
    required this.capturedAt,
  });

  final int processSequence;
  final int assessmentGeneration;
  final AppCzarAssessmentState capturedAssessmentState;
  final DateTime capturedAt;
}

@immutable
final class AppCzarDiagnosticReviewState {
  const AppCzarDiagnosticReviewState({
    required this.phase,
    required this.actionAdmissionOpen,
    this.occurrence,
    this.failure,
  });

  const AppCzarDiagnosticReviewState.dormant()
    : this(
        phase: AppCzarDiagnosticReviewPhase.dormant,
        actionAdmissionOpen: false,
      );

  final AppCzarDiagnosticReviewPhase phase;
  final bool actionAdmissionOpen;
  final AppCzarDiagnosticReviewOccurrence? occurrence;
  final String? failure;

  bool get isVisible => phase != AppCzarDiagnosticReviewPhase.dormant;

  bool get canRequestRestart {
    return actionAdmissionOpen &&
        (phase == AppCzarDiagnosticReviewPhase.presenting ||
            phase == AppCzarDiagnosticReviewPhase.restartFailed);
  }
}
