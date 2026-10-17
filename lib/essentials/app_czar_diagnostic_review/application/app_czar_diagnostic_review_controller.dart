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
  bool _restartActive = false;
  bool _stopped = false;
  bool _disposed = false;
  Object? _drainFailure;
  StackTrace? _drainFailureStack;

  @override
  AppCzarDiagnosticReviewState build() {
    ref.onDispose(() {
      _disposed = true;
      _seal();
    });
    ref.listen(appCzarAssessmentControllerProvider, (_, next) {
      _considerAssessment(next);
      if (!_disposed) {
        state = _current;
      }
    });
    _considerAssessment(ref.read(appCzarAssessmentControllerProvider));
    return _current;
  }

  void _considerAssessment(AppCzarAssessmentState assessment) {
    if (_stopped) {
      return;
    }
    _latestAssessment = assessment;
    final occurrence = _occurrence;
    if (occurrence == null) {
      if (shouldExecuteAppCzarDiagnosticReview(assessment)) {
        _captureOccurrence(assessment);
      }
    } else if (!_isExactCurrentOccurrence(occurrence)) {
      _closeStaleOccurrence(occurrence);
    }
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
    _seal();
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
    // Own queued work before publishing or invoking a reentrant port.
    final action = Future<void>.microtask(() async {
      if (_stopped ||
          _publicationGeneration != publicationGeneration ||
          !_isExactCurrentOccurrence(occurrence)) {
        return;
      }
      _restartActive = true;
      await _restartAtProcessBoundary(occurrence, publicationGeneration);
    });
    _activeLifecycleAction = action;
    // Preserve the approved completion boundary; the admitted action itself
    // remains owned and returned to callers, with failures retained below.
    unawaited(
      action.whenComplete(() {
        if (identical(_activeLifecycleAction, action)) {
          _restartActive = false;
          _activeLifecycleAction = null;
        }
      }),
    );
    _publish(
      AppCzarDiagnosticReviewState(
        phase: AppCzarDiagnosticReviewPhase.draining,
        actionAdmissionOpen: false,
        occurrence: occurrence,
      ),
    );
    return action;
  }

  Future<void> _restartAtProcessBoundary(
    AppCzarDiagnosticReviewOccurrence occurrence,
    int publicationGeneration,
  ) async {
    try {
      await ref.read(appCzarProcessRestarterProvider).restartAndReassess();
      _drainFailure = null;
      _drainFailureStack = null;
    } on Object catch (error, stack) {
      _drainFailure ??= error;
      _drainFailureStack ??= stack;
      if (_stopped ||
          _occurrence != occurrence ||
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
    _seal();
    if (!_disposed && occurrence != null) {
      _publish(
        AppCzarDiagnosticReviewState(
          phase: AppCzarDiagnosticReviewPhase.quitRequested,
          actionAdmissionOpen: false,
          occurrence: occurrence,
        ),
      );
    }
    if (_restartActive) {
      throw StateError('Diagnostic Review restart is still active.');
    }
    // Sealing revokes queued port dispatch; this only waits for retirement.
    await _activeLifecycleAction;
    if (_drainFailure case final failure?) {
      Error.throwWithStackTrace(failure, _drainFailureStack!);
    }
  }

  void _seal() {
    _stopped = true;
    _acceptingActions = false;
    _publicationGeneration += 1;
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
