import 'dart:async';

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

  @override
  AppCzarDataUpdateState build() {
    final assessmentState = ref.watch(appCzarAssessmentControllerProvider);
    if (_startedGeneration == null &&
        shouldExecuteAppCzarDataUpdate(assessmentState)) {
      _startedGeneration = assessmentState.generation;
      final sourceCount = assessmentState.source?.messageCount;
      final localCount = assessmentState.importStore?.liveMessageCount;
      _current = AppCzarDataUpdateState(
        phase: AppCzarDataUpdatePhase.preparing,
        assessmentGeneration: assessmentState.generation,
        sourceMessageCount: sourceCount,
        localMessageCount: localCount,
        messagesToImport: _positiveDelta(sourceCount, localCount),
      );
      Future<void>.microtask(_runSelectedUpdate);
    }
    return _current;
  }

  Future<void> _runSelectedUpdate() async {
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
      await _requestRestart();
    } on Object catch (error) {
      _restartRequested = false;
      _publish(
        _current.copyWith(
          phase: AppCzarDataUpdatePhase.failed,
          failure: '$error',
          clearGraphProgress: true,
        ),
      );
    }
  }

  Future<void> restartAndReassess() async {
    if (_current.phase != AppCzarDataUpdatePhase.failed) {
      return;
    }
    try {
      await _requestRestart();
    } on Object catch (error) {
      _restartRequested = false;
      _publish(
        _current.copyWith(
          phase: AppCzarDataUpdatePhase.failed,
          failure: '$error',
        ),
      );
    }
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

  Future<void> _requestRestart() async {
    if (_restartRequested) {
      return;
    }
    _restartRequested = true;
    _publish(
      _current.copyWith(
        phase: AppCzarDataUpdatePhase.restartRequested,
        clearGraphProgress: true,
        clearFailure: true,
      ),
    );
    await ref.read(appCzarProcessRestarterProvider).restartAndReassess();
  }

  void _publish(AppCzarDataUpdateState next) {
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
