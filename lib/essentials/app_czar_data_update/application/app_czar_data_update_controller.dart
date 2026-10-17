import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_czar/application/app_czar_assessment_provider.dart';
import '../../app_czar/domain/app_czar_models.dart';
import '../../conversation_graph/application/monitor/live_graph_update_worker.dart';
import '../domain/app_czar_data_update_state.dart';
import 'app_czar_data_update_executor_provider.dart';
import 'app_czar_process_restarter_provider.dart';

part 'app_czar_data_update_controller.g.dart';

@visibleForTesting
bool shouldExecuteAppCzarDataUpdate(AppCzarAssessmentState assessmentState) {
  return assessmentState.assessment?.virtualCoordinator ==
      AppCzarVirtualCoordinator.dataUpdate;
}

@Riverpod(keepAlive: true)
class AppCzarDataUpdateController extends _$AppCzarDataUpdateController {
  AppCzarDataUpdateState _current = const AppCzarDataUpdateState.dormant();
  int? _startedGeneration;
  bool _restartRequested = false;
  bool _acceptingWork = true;
  Future<void>? _activeWork;
  Future<void>? _restartFlight;
  Object? _workFailure;
  StackTrace? _workFailureStack;

  @override
  AppCzarDataUpdateState build() {
    ref.onDispose(_sealAdmission);
    void considerAssessment(AppCzarAssessmentState assessment) {
      if (!_acceptingWork) {
        return;
      }
      if (_startedGeneration != null) {
        if (assessment.generation != _startedGeneration ||
            !shouldExecuteAppCzarDataUpdate(assessment)) {
          _sealAdmission();
        }
        return;
      }
      if (!shouldExecuteAppCzarDataUpdate(assessment)) {
        return;
      }
      _startedGeneration = assessment.generation;
      final sourceCount = assessment.source?.messageCount;
      final localCount = assessment.importStore?.liveMessageCount;
      _current = AppCzarDataUpdateState(
        phase: AppCzarDataUpdatePhase.preparing,
        assessmentGeneration: assessment.generation,
        sourceMessageCount: sourceCount,
        localMessageCount: localCount,
        messagesToImport: _positiveDelta(sourceCount, localCount),
      );
      final work = Future<void>.microtask(_runSelectedUpdate);
      _activeWork = work;
      // Own the post-work continuation separately from the drained future.
      _restartFlight = _restartAfterWork(work);
    }

    ref.listen(appCzarAssessmentControllerProvider, (_, next) {
      considerAssessment(next);
      _publish(_current);
    });
    considerAssessment(ref.read(appCzarAssessmentControllerProvider));
    return _current;
  }

  Future<void> _restartAfterWork(Future<void> work) async {
    try {
      await work;
      if (identical(_activeWork, work)) {
        _activeWork = null;
      }
      if (_acceptingWork && _workFailure == null) {
        await _requestRestart();
      }
    } on Object catch (error, stack) {
      _workFailure = error;
      _workFailureStack = stack;
      _publishFailure(error);
    }
  }

  void _sealAdmission() {
    _acceptingWork = false;
  }

  /// Seals synchronously; settlement never includes the restart callback.
  Future<void> stopAndDrain() async {
    _sealAdmission();
    await _activeWork;
    final failure = _workFailure;
    if (failure != null) {
      Error.throwWithStackTrace(failure, _workFailureStack!);
    }
  }

  Future<void> _runSelectedUpdate() async {
    if (!_acceptingWork) {
      return;
    }
    try {
      final result = await ref
          .read(appCzarDataUpdateExecutorProvider)
          .run(onObservation: _observeWorker);
      final attachmentResult = result.attachmentResult;
      if (attachmentResult?.isDeferred == true) {
        throw StateError(
          'Attachment preservation was deferred: '
          '${attachmentResult!.deferredReason!.name}.',
        );
      }
      if ((attachmentResult?.failed ?? 0) > 0) {
        throw StateError(
          'Attachment preservation reported '
          '${attachmentResult!.failed} failed payload(s).',
        );
      }
    } on Object catch (error, stack) {
      _workFailure = error;
      _workFailureStack = stack;
      _publishFailure(error);
    }
  }

  Future<void> restartAndReassess() async {
    if (!_acceptingWork || _current.phase != AppCzarDataUpdatePhase.failed) {
      return;
    }
    // A failed-state listener may invoke this before the work future settles.
    await _activeWork;
    await _requestRestart();
  }

  void _publishFailure(Object error) {
    _publish(
      _current.copyWith(
        phase: AppCzarDataUpdatePhase.failed,
        failure: '$error',
        clearGraphProgress: true,
      ),
    );
  }

  void _observeWorker(LiveGraphUpdateObservation observation) {
    switch (observation.kind) {
      case LiveGraphUpdateObservationKind.checkingPrerequisites:
        _publish(
          _current.copyWith(
            phase: AppCzarDataUpdatePhase.preparing,
            clearGraphProgress: true,
            clearFailure: true,
          ),
        );
        break;
      case LiveGraphUpdateObservationKind.prerequisitesRead:
        final prerequisites = observation.prerequisites!;
        _publish(
          _current.copyWith(
            phase: AppCzarDataUpdatePhase.updating,
            sourceMessageCount: prerequisites.liveImportableMessageCount,
            localMessageCount: prerequisites.importedMessageCount,
            messagesToImport: prerequisites.messagesToImport,
            clearGraphProgress: true,
            clearFailure: true,
          ),
        );
        break;
      case LiveGraphUpdateObservationKind.graphBuild:
        final graphObservation = observation.graphBuild!;
        _publish(
          _current.copyWith(
            phase: AppCzarDataUpdatePhase.updating,
            suboperation: graphObservation.suboperation,
            completedWorkCount: graphObservation.completedWorkCount,
            totalWorkCount: graphObservation.totalWorkCount,
            clearGraphProgress: graphObservation.completedWorkCount == null,
          ),
        );
        break;
      case LiveGraphUpdateObservationKind.preservingAttachments:
        _publish(
          _current.copyWith(
            phase: AppCzarDataUpdatePhase.preservingAttachments,
            clearGraphProgress: true,
          ),
        );
        break;
      case LiveGraphUpdateObservationKind.attachmentsPreserved:
        final result = observation.attachmentResult!;
        _publish(
          _current.copyWith(
            phase: AppCzarDataUpdatePhase.preservingAttachments,
            attachmentsExamined: result.totalScanned,
            attachmentsPreserved: result.newlyArchived,
            attachmentsSkipped: result.skipped,
            attachmentsFailed: result.failed,
            clearGraphProgress: true,
          ),
        );
        break;
    }
  }

  Future<void> _requestRestart() {
    if (!_acceptingWork) {
      return Future<void>.value();
    }
    if (_restartRequested) {
      return _restartFlight ?? Future<void>.value();
    }
    _restartRequested = true;
    // Own the dispatch microtask, so quit can seal admission before dispatch.
    final flight = Future<void>.microtask(() async {
      if (!_acceptingWork) {
        return;
      }
      _publish(
        _current.copyWith(
          phase: AppCzarDataUpdatePhase.restartRequested,
          clearGraphProgress: true,
          clearFailure: true,
        ),
      );
      if (!_acceptingWork) {
        return;
      }
      try {
        await ref.read(appCzarProcessRestarterProvider).restartAndReassess();
      } on Object catch (error) {
        _restartRequested = false;
        _publishFailure(error);
      }
    });
    _restartFlight = flight;
    return flight;
  }

  void _publish(AppCzarDataUpdateState next) {
    if (!_acceptingWork) {
      return;
    }
    _current = next;
    state = next;
  }
}

int? _positiveDelta(int? sourceCount, int? localCount) {
  if (sourceCount == null || localCount == null) {
    return null;
  }
  final delta = sourceCount - localCount;
  return delta > 0 ? delta : 0;
}
