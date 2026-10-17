import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_czar/application/app_czar_assessment_provider.dart';
import '../../app_czar/domain/app_czar_models.dart';
import '../../app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import '../domain/app_czar_local_data_repair_state.dart';
import 'app_czar_local_data_repair_executor_provider.dart';

part 'app_czar_local_data_repair_controller.g.dart';

@visibleForTesting
bool shouldExecuteAppCzarLocalDataRepair(AppCzarAssessmentState state) {
  return state.assessment?.virtualCoordinator ==
          AppCzarVirtualCoordinator.localDataRepair &&
      state.localDataRepairSafety?.mayResetDerivedStores == true;
}

@Riverpod(keepAlive: true)
class AppCzarLocalDataRepairController
    extends _$AppCzarLocalDataRepairController {
  AppCzarLocalDataRepairState _current =
      const AppCzarLocalDataRepairState.dormant();
  int? _startedGeneration;
  bool _acceptingWork = true;
  int _publicationGeneration = 0;
  Future<void>? _activeRun;

  bool _stopped = false;
  bool _restartActive = false;
  Future<void>? _restartFlight;
  Object? _drainFailure;
  StackTrace? _drainFailureStack;
  AppCzarAssessmentState? _admittedAssessment;

  @override
  AppCzarLocalDataRepairState build() {
    ref.onDispose(_seal);
    ref.listen(appCzarAssessmentControllerProvider, (_, next) {
      _considerAssessment(next);
      if (!_stopped) {
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
    if (_startedGeneration != null) {
      if (!identical(assessment, _admittedAssessment)) {
        _seal();
      }
      return;
    }
    if (shouldExecuteAppCzarLocalDataRepair(assessment)) {
      _admittedAssessment = assessment;
      _startedGeneration = assessment.generation;
      _current = AppCzarLocalDataRepairState(
        phase: AppCzarLocalDataRepairPhase.revalidating,
        assessmentGeneration: assessment.generation,
      );
      // Retain the scheduled worker before any executor can reenter this owner.
      _activeRun = Future<void>.microtask(() async {
        if (!_acceptingWork) {
          return;
        }
        await _run(assessment.localDataRepairSafety!, _publicationGeneration);
      });
    }
  }

  Future<void> _run(
    AppCzarLocalDataRepairSafetyObservation expected,
    int publicationGeneration,
  ) async {
    try {
      await ref
          .read(appCzarLocalDataRepairExecutorProvider)
          .run(
            expected: expected,
            isMutationStillAdmitted: () =>
                _acceptingWork &&
                publicationGeneration == _publicationGeneration,
            onMutationAdmitted: () {
              _publish(
                AppCzarLocalDataRepairState(
                  phase: AppCzarLocalDataRepairPhase.resetting,
                  assessmentGeneration: _startedGeneration,
                ),
                publicationGeneration,
              );
            },
          );
      _queueRestart(publicationGeneration);
    } on AppCzarLocalDataRepairExecutionException catch (error, stack) {
      if (!_acceptingWork) {
        _retainFailure(error, stack);
      } else if (error.mutationMayHaveStarted) {
        _queueRestart(publicationGeneration, priorFailure: error);
      } else {
        _publishFailure(error, publicationGeneration);
      }
    } on Object catch (error, stack) {
      if (!_acceptingWork) {
        _retainFailure(error, stack);
      } else {
        _publishFailure(error, publicationGeneration);
      }
    }
  }

  void _queueRestart(int generation, {Object? priorFailure}) {
    if (_stopped || generation != _publicationGeneration) {
      return;
    }
    if (_restartFlight != null) {
      return;
    }
    _publish(
      AppCzarLocalDataRepairState(
        phase: AppCzarLocalDataRepairPhase.restartRequested,
        assessmentGeneration: _startedGeneration,
      ),
      generation,
    );
    _acceptingWork = false;
    // Work never awaits this flight. It must settle before restart dispatch,
    // because the restarter may call this owner's ordinary drain itself.
    final flight = Future<void>.microtask(() async {
      try {
        await _activeRun;
        if (_stopped || generation != _publicationGeneration) {
          return;
        }
        _restartActive = true;
        await ref.read(appCzarProcessRestarterProvider).restartAndReassess();
        _drainFailure = null;
        _drainFailureStack = null;
      } on Object catch (error, stack) {
        _retainFailure(error, stack);
        if (!_stopped && generation == _publicationGeneration) {
          _current = AppCzarLocalDataRepairState(
            phase: AppCzarLocalDataRepairPhase.failed,
            assessmentGeneration: _startedGeneration,
            failure: priorFailure == null
                ? '$error'
                : '$priorFailure; restart failed: $error',
          );
          state = _current;
        }
      } finally {
        _restartActive = false;
        _restartFlight = null;
      }
    });
    _restartFlight = flight;
  }

  void _retainFailure(Object error, StackTrace stack) {
    _drainFailure ??= error;
    _drainFailureStack ??= stack;
  }

  void _seal() {
    _stopped = true;
    _acceptingWork = false;
    _publicationGeneration += 1;
  }

  void _publishFailure(Object error, int publicationGeneration) {
    _publish(
      AppCzarLocalDataRepairState(
        phase: AppCzarLocalDataRepairPhase.failed,
        assessmentGeneration: _startedGeneration,
        failure: '$error',
      ),
      publicationGeneration,
    );
  }

  Future<void> stopAndDrain() async {
    _seal();
    await _activeRun;
    if (_restartActive) {
      throw StateError('Local Data Repair restart is still active.');
    }
    // Sealing revokes queued dispatch; await its actual retirement.
    await _restartFlight;
    if (_drainFailure case final failure?) {
      Error.throwWithStackTrace(failure, _drainFailureStack!);
    }
  }

  Future<void> restartAndReassess() {
    if (_stopped) {
      return Future<void>.value();
    }
    if (_restartFlight case final flight?) {
      return flight;
    }
    if (_current.phase != AppCzarLocalDataRepairPhase.failed) {
      return Future<void>.value();
    }
    _queueRestart(_publicationGeneration);
    return _restartFlight ?? Future<void>.value();
  }

  void _publish(AppCzarLocalDataRepairState value, int publicationGeneration) {
    if (!_acceptingWork || publicationGeneration != _publicationGeneration) {
      return;
    }
    _current = value;
    state = value;
  }
}
