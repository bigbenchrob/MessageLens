import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_czar/application/app_czar_assessment_provider.dart';
import '../../app_czar/domain/app_czar_models.dart';
import '../../app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import '../domain/app_czar_diagnostic_review_state.dart';

part 'app_czar_diagnostic_review_controller.g.dart';

typedef AppCzarDiagnosticReviewClock = DateTime Function();

var _nextDiagnosticReviewOccurrenceSequence = 0;

bool shouldExecuteAppCzarDiagnosticReview(AppCzarAssessmentState state) {
  return state.isComplete &&
      state.generation >= 0 &&
      state.assessment?.virtualCoordinator ==
          AppCzarVirtualCoordinator.diagnosticReview;
}

@Riverpod(keepAlive: true)
AppCzarDiagnosticReviewClock appCzarDiagnosticReviewClock(Ref ref) {
  return DateTime.now;
}

@Riverpod(keepAlive: true)
class AppCzarDiagnosticReviewController
    extends _$AppCzarDiagnosticReviewController {
  AppCzarDiagnosticReviewState _current =
      const AppCzarDiagnosticReviewState.dormant();
  AppCzarDiagnosticReviewOccurrence? _occurrence;
  AppCzarAssessmentState? _latestAssessment;
  bool _acceptingActions = true;
  int _publicationGeneration = 0;
  Future<void>? _activeLifecycleAction;

  @override
  AppCzarDiagnosticReviewState build() {
    final assessment = ref.watch(appCzarAssessmentControllerProvider);
    _latestAssessment = assessment;
    final occurrence = _occurrence;
    if (occurrence == null) {
      if (shouldExecuteAppCzarDiagnosticReview(assessment)) {
        _captureOccurrence(assessment);
      }
    } else if (!_isExactCurrentOccurrence(occurrence)) {
      _closeStaleOccurrence(occurrence);
    }
    return _current;
  }

  void _captureOccurrence(AppCzarAssessmentState assessment) {
    final occurrence = AppCzarDiagnosticReviewOccurrence(
      processSequence: ++_nextDiagnosticReviewOccurrenceSequence,
      assessmentGeneration: assessment.generation,
      capturedAssessmentState: assessment,
      capturedAt: ref.read(appCzarDiagnosticReviewClockProvider)(),
    );
    _occurrence = occurrence;
    _acceptingActions = true;
    _current = AppCzarDiagnosticReviewState(
      phase: AppCzarDiagnosticReviewPhase.presenting,
      actionAdmissionOpen: true,
      occurrence: occurrence,
    );
  }

  void _closeStaleOccurrence(AppCzarDiagnosticReviewOccurrence occurrence) {
    _acceptingActions = false;
    _publicationGeneration += 1;
    _current = AppCzarDiagnosticReviewState(
      phase: AppCzarDiagnosticReviewPhase.draining,
      actionAdmissionOpen: false,
      occurrence: occurrence,
      failure:
          'The assessment generation changed. Restart MessageLens to admit a new diagnostic occurrence.',
    );
  }

  Future<void> tryAssessmentAgain() {
    final occurrence = _occurrence;
    if (occurrence == null ||
        !_acceptingActions ||
        _activeLifecycleAction != null ||
        !_isExactCurrentOccurrence(occurrence)) {
      return Future<void>.value();
    }

    _acceptingActions = false;
    _publicationGeneration += 1;
    final publicationGeneration = _publicationGeneration;
    _publish(
      AppCzarDiagnosticReviewState(
        phase: AppCzarDiagnosticReviewPhase.draining,
        actionAdmissionOpen: false,
        occurrence: occurrence,
      ),
    );
    final action = _restartAtProcessBoundary(occurrence, publicationGeneration);
    _activeLifecycleAction = action;
    unawaited(
      action.whenComplete(() {
        if (identical(_activeLifecycleAction, action)) {
          _activeLifecycleAction = null;
        }
      }),
    );
    return action;
  }

  Future<void> _restartAtProcessBoundary(
    AppCzarDiagnosticReviewOccurrence occurrence,
    int publicationGeneration,
  ) async {
    try {
      await ref.read(appCzarProcessRestarterProvider).restartAndReassess();
    } on Object catch (error) {
      if (_occurrence != occurrence ||
          _publicationGeneration != publicationGeneration ||
          !_isExactCurrentOccurrence(occurrence)) {
        return;
      }
      _acceptingActions = true;
      _publish(
        AppCzarDiagnosticReviewState(
          phase: AppCzarDiagnosticReviewPhase.restartFailed,
          actionAdmissionOpen: true,
          occurrence: occurrence,
          failure: '$error',
        ),
      );
    }
  }

  Future<void> stopAndDrain() async {
    final occurrence = _occurrence;
    _acceptingActions = false;
    _publicationGeneration += 1;
    if (occurrence != null) {
      _publish(
        AppCzarDiagnosticReviewState(
          phase: AppCzarDiagnosticReviewPhase.quitRequested,
          actionAdmissionOpen: false,
          occurrence: occurrence,
        ),
      );
    }
    await _activeLifecycleAction;
  }

  bool _isExactCurrentOccurrence(AppCzarDiagnosticReviewOccurrence occurrence) {
    final assessment = _latestAssessment;
    return assessment != null &&
        identical(assessment, occurrence.capturedAssessmentState) &&
        assessment.generation == occurrence.assessmentGeneration &&
        shouldExecuteAppCzarDiagnosticReview(assessment);
  }

  void _publish(AppCzarDiagnosticReviewState value) {
    _current = value;
    state = value;
  }
}
