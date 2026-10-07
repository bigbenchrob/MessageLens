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

  @override
  AppCzarLocalDataRepairState build() {
    final assessment = ref.watch(appCzarAssessmentControllerProvider);
    if (_startedGeneration == null &&
        shouldExecuteAppCzarLocalDataRepair(assessment)) {
      _startedGeneration = assessment.generation;
      _current = AppCzarLocalDataRepairState(
        phase: AppCzarLocalDataRepairPhase.revalidating,
        assessmentGeneration: assessment.generation,
      );
      Future<void>.microtask(() {
        if (!_acceptingWork) {
          return;
        }
        final publicationGeneration = _publicationGeneration;
        _activeRun = _run(
          assessment.localDataRepairSafety!,
          publicationGeneration,
        );
      });
    }
    return _current;
  }

  Future<void> _run(
    AppCzarLocalDataRepairSafetyObservation expected,
    int publicationGeneration,
  ) async {
    try {
      final result = await ref
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
      if (result == AppCzarLocalDataRepairExecutionResult.staleEvidence) {
        await _restartForFreshAssessment(publicationGeneration);
        return;
      }
      await _restartForFreshAssessment(publicationGeneration);
    } on AppCzarLocalDataRepairExecutionException catch (error) {
      if (error.mutationMayHaveStarted) {
        await _restartAfterMutation(error, publicationGeneration);
        return;
      }
      _publishFailure(error, publicationGeneration);
    } on Object catch (error) {
      _publishFailure(error, publicationGeneration);
    } finally {
      _activeRun = null;
    }
  }

  Future<void> _restartAfterMutation(
    Object originalError,
    int publicationGeneration,
  ) async {
    await _restartForFreshAssessment(
      publicationGeneration,
      priorFailure: originalError,
    );
  }

  Future<void> _restartForFreshAssessment(
    int publicationGeneration, {
    Object? priorFailure,
  }) async {
    if (!_acceptingWork || publicationGeneration != _publicationGeneration) {
      return;
    }
    _publish(
      AppCzarLocalDataRepairState(
        phase: AppCzarLocalDataRepairPhase.restartRequested,
        assessmentGeneration: _startedGeneration,
      ),
      publicationGeneration,
    );
    _acceptingWork = false;
    _publicationGeneration += 1;
    try {
      await ref.read(appCzarProcessRestarterProvider).restartAndReassess();
    } on Object catch (restartError) {
      if (_publicationGeneration != publicationGeneration + 1) {
        return;
      }
      final failure = priorFailure == null
          ? '$restartError'
          : '$priorFailure; restart failed: $restartError';
      _current = AppCzarLocalDataRepairState(
        phase: AppCzarLocalDataRepairPhase.failed,
        assessmentGeneration: _startedGeneration,
        failure: failure,
      );
      state = _current;
    }
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
    _acceptingWork = false;
    _publicationGeneration += 1;
    await _activeRun;
  }

  Future<void> restartAndReassess() async {
    await ref.read(appCzarProcessRestarterProvider).restartAndReassess();
  }

  void _publish(AppCzarLocalDataRepairState value, int publicationGeneration) {
    if (!_acceptingWork || publicationGeneration != _publicationGeneration) {
      return;
    }
    _current = value;
    state = value;
  }
}
