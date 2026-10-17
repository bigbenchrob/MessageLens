import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_czar/application/app_czar_assessment_provider.dart';
import '../../app_czar/domain/app_czar_models.dart';
import '../../app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import '../domain/app_czar_attachment_archive_repair_models.dart';
import '../domain/app_czar_attachment_archive_repair_state.dart';
import 'app_czar_attachment_archive_repair_executor_provider.dart';

part 'app_czar_attachment_archive_repair_controller.g.dart';

@visibleForTesting
bool shouldExecuteAppCzarAttachmentArchiveRepair(
  AppCzarAssessmentState assessmentState, {
  int? expectedAssessmentGeneration,
}) {
  if (assessmentState.generation < 0 ||
      (expectedAssessmentGeneration != null &&
          assessmentState.generation != expectedAssessmentGeneration)) {
    return false;
  }

  final assessment = assessmentState.assessment;
  final archive = assessmentState.attachmentArchive;
  if (assessment == null || archive == null) {
    return false;
  }
  if (assessment.virtualCoordinator !=
          AppCzarVirtualCoordinator.attachmentArchiveRepair ||
      assessment.diagnosisKind !=
          AppCzarDiagnosisKind.attachmentArchiveCoverageIncomplete ||
      _uniqueFactTruth(assessment, AppCzarFactId.attachmentCoverageComplete) !=
          AppCzarTruth.falseValue ||
      _uniqueFactTruth(assessment, AppCzarFactId.attachmentArchiveAvailable) !=
          AppCzarTruth.trueValue) {
    return false;
  }

  final scopeIdentity = archive.archiveScopeIdentity;
  final archiveGeneration = archive.archiveGeneration;
  final resolvedPath = archive.resolvedPath;
  final repairability = archive.repairability;
  final repairOpportunityTruth = _uniqueFactTruth(
    assessment,
    AppCzarFactId.attachmentRepairOpportunityPresent,
  );
  final hasAutomaticRepairOpportunity =
      repairOpportunityTruth == AppCzarTruth.trueValue &&
      repairability.condition ==
          AppCzarAttachmentRepairOpportunityCondition.present &&
      (repairability.availableFromMessagesCount ?? 0) > 0;
  final hasRecordBackedRecovery =
      repairOpportunityTruth == AppCzarTruth.falseValue &&
      repairability.condition ==
          AppCzarAttachmentRepairOpportunityCondition.absent &&
      (repairability.recordBackedRecoveryCount ?? 0) > 0;
  return archive.coverage.condition ==
          AppCzarAttachmentCoverageCondition.incomplete &&
      archive.hasCoherentCoverageBinding &&
      archive.hasCoherentRepairabilityBinding &&
      (hasAutomaticRepairOpportunity || hasRecordBackedRecovery) &&
      scopeIdentity != null &&
      scopeIdentity.trim().isNotEmpty &&
      archiveGeneration != null &&
      archiveGeneration >= 0 &&
      resolvedPath != null &&
      resolvedPath.trim().isNotEmpty;
}

@Riverpod(keepAlive: true)
class AppCzarAttachmentArchiveRepairController
    extends _$AppCzarAttachmentArchiveRepairController {
  AppCzarAttachmentArchiveRepairState _current =
      const AppCzarAttachmentArchiveRepairState.dormant();
  AppCzarAttachmentArchiveRepairBinding? _activeBinding;
  AppCzarAttachmentArchiveRepairExecutor? _activeExecutor;
  Future<void>? _activeRun;
  Future<void>? _restartFlight;
  Future<void>? _ordinaryStopFlight;
  Future<void>? _executorDrain;
  var _executorDrainSucceeded = true;
  AppCzarAttachmentArchiveRepairExecutor? _drainingExecutor;
  Object? _drainFailure;
  StackTrace? _drainFailureStack;
  var _nextOccurrenceId = 0;
  var _restartRequested = false;
  var _restartActive = false;
  var _stopRequested = false;
  var _sealed = false;
  var _disposed = false;

  @override
  AppCzarAttachmentArchiveRepairState build() {
    ref.onDispose(() {
      _disposed = true;
      _sealed = true;
      _stopRequested = true;
    });
    ref.listen(appCzarAssessmentControllerProvider, (_, next) {
      _considerAssessment(next, publish: true);
    });
    _considerAssessment(
      ref.read(appCzarAssessmentControllerProvider),
      publish: false,
    );
    return _current;
  }

  void _considerAssessment(
    AppCzarAssessmentState assessment, {
    required bool publish,
  }) {
    if (_sealed) {
      return;
    }
    final binding = _activeBinding;
    if (binding != null && !_isCurrentAssessmentBinding(assessment, binding)) {
      _queueRestart(binding);
    } else if (binding == null &&
        _activeRun == null &&
        shouldExecuteAppCzarAttachmentArchiveRepair(assessment)) {
      _current = AppCzarAttachmentArchiveRepairState(
        phase: AppCzarAttachmentArchiveRepairPhase.inspecting,
        assessmentGeneration: assessment.generation,
        occurrenceId: _nextOccurrenceId,
      );
      final run = _scheduleOne(() => _beginOccurrence(assessment));
      if (publish) {
        _publish(_current);
      }
      // The retained flight owns construction as well as inspection.
      unawaited(run);
    }
  }

  Future<void> startPreservation(
    AppCzarAttachmentArchiveRepairBatchAuthorization authorization,
  ) {
    final binding = _activeBinding;
    final currentAuthorization = _current.snapshot?.nextBatchAuthorization;
    if (binding == null ||
        _sealed ||
        _stopRequested ||
        _activeRun != null ||
        !_current.canStartPreservation ||
        !identical(currentAuthorization, authorization) ||
        !_isCurrentBinding(binding)) {
      return Future<void>.value();
    }
    _resetExecutorDrain();
    final run = _scheduleOne(
      () => _preserveAuthorizedBatch(binding, authorization),
    );
    _publish(
      _current.copyWith(
        phase: AppCzarAttachmentArchiveRepairPhase.preserving,
        preservedCount: 0,
        preservationTotalCount: authorization.itemCount,
        clearFailure: true,
      ),
    );
    return _finishHumanAction(run);
  }

  Future<void> _finishHumanAction(Future<void> run) async {
    await run;
    await _restartFlight;
  }

  Future<void> checkAgain() {
    final binding = _activeBinding;
    if (binding == null ||
        _sealed ||
        _stopRequested ||
        _activeRun != null ||
        !_current.canCheckAgain) {
      return Future<void>.value();
    }
    _resetExecutorDrain();
    final run = _scheduleOne(() async {
      if (!await _drainExecutor()) {
        _publishFailure(
          binding,
          AppCzarAttachmentArchiveRepairFailureKind.drainFailed,
        );
        return;
      }
      if (_sealed || _stopRequested) {
        return;
      }
      final assessment = ref.read(appCzarAssessmentControllerProvider);
      if (!_isCurrentAssessmentBinding(assessment, binding)) {
        _queueRestart(binding);
        return;
      }
      await _beginOccurrence(assessment);
    });
    _publish(
      _current.copyWith(
        phase: AppCzarAttachmentArchiveRepairPhase.inspecting,
        clearProgress: true,
        clearFailure: true,
      ),
    );
    return _finishHumanAction(run);
  }

  Future<void> retryRestart() {
    if (_sealed) {
      return Future<void>.value();
    }
    final flight = _restartFlight;
    if (flight != null) {
      return flight;
    }
    final binding = _activeBinding;
    if (binding == null || !_current.canRetryRestart) {
      return Future<void>.value();
    }
    _resetExecutorDrain();
    _queueRestart(binding, retry: true);
    return _restartFlight ?? Future<void>.value();
  }

  /// Ordinary exit permanently seals admission. An active restart can call this
  /// method itself, so refusing it must precede every asynchronous wait.
  Future<void> stopAndDrain() async {
    _sealed = true;
    _stopRequested = true;
    if (!_disposed && _current.isVisible) {
      _publish(
        _current.copyWith(
          phase: AppCzarAttachmentArchiveRepairPhase.stopping,
          clearProgress: true,
        ),
      );
    }
    if (_restartActive) {
      throw StateError('Attachment Archive Repair restart is still active.');
    }
    // Register the whole ordinary drain before any executor port can reenter.
    _ordinaryStopFlight ??= Future<void>.microtask(() async {
      final executor = _activeExecutor;
      if (executor != null) {
        if (identical(_drainingExecutor, executor)) {
          await _executorDrain;
        } else {
          try {
            await executor.stopAndDrain();
          } on Object catch (error, stack) {
            _retainFailure(error, stack);
          }
        }
      }
      final activeRun = _activeRun;
      if (activeRun != null) {
        await activeRun;
      }
      // A factory entered before sealing may have returned a new executor.
      if (!identical(executor, _activeExecutor)) {
        await _drainExecutor();
      }
      await _restartFlight;
      final failure = _drainFailure;
      if (failure != null) {
        Error.throwWithStackTrace(failure, _drainFailureStack!);
      }
    });
    await _ordinaryStopFlight;
  }

  Future<void> _beginOccurrence(AppCzarAssessmentState assessment) async {
    if (_sealed || _stopRequested) {
      return;
    }
    final archive = assessment.attachmentArchive!;
    final binding = AppCzarAttachmentArchiveRepairBinding(
      occurrenceId: _nextOccurrenceId++,
      assessmentGeneration: assessment.generation,
      archiveScopeIdentity: archive.archiveScopeIdentity!,
      archiveGeneration: archive.archiveGeneration!,
      resolvedArchivePath: archive.resolvedPath!,
    );
    _activeBinding = binding;
    _activeExecutor = null;
    _current = AppCzarAttachmentArchiveRepairState(
      phase: AppCzarAttachmentArchiveRepairPhase.inspecting,
      assessmentGeneration: binding.assessmentGeneration,
      occurrenceId: binding.occurrenceId,
    );
    if (!_isCurrentBinding(binding)) {
      _queueRestart(binding);
      return;
    }
    try {
      _activeExecutor = ref
          .read(appCzarAttachmentArchiveRepairExecutorFactoryProvider)
          .create();
    } on Object catch (error, stack) {
      _retainFailure(error, stack);
      _publishFailure(
        binding,
        AppCzarAttachmentArchiveRepairFailureKind.inspectionFailed,
      );
      return;
    }
    if (_sealed || _stopRequested) {
      return;
    }
    _publish(_current);
    await _inspectCurrent(binding);
  }

  Future<void> _scheduleOne(Future<void> Function() action) {
    final run = Future<void>.microtask(() async {
      if (!_sealed && !_stopRequested) {
        await action();
      }
    });
    _activeRun = run;
    unawaited(
      run.whenComplete(() {
        if (identical(_activeRun, run)) {
          _activeRun = null;
        }
      }),
    );
    return run;
  }

  Future<bool> _drainExecutor() async {
    final executor = _activeExecutor;
    if (executor == null) {
      return true;
    }
    if (!identical(_drainingExecutor, executor)) {
      _drainingExecutor = executor;
      _executorDrainSucceeded = true;
      // Register before invoking a potentially reentrant executor port.
      _executorDrain = Future<void>.microtask(() async {
        try {
          await executor.stopAndDrain();
        } on Object catch (error, stack) {
          _executorDrainSucceeded = false;
          _retainFailure(error, stack);
        }
      });
    }
    await _executorDrain;
    return _executorDrainSucceeded;
  }

  void _retainFailure(Object error, StackTrace stack) {
    _drainFailure ??= error;
    _drainFailureStack ??= stack;
  }

  void _resetExecutorDrain() {
    // Explicit human retry may retry an executor drain that previously failed.
    _drainingExecutor = null;
    _executorDrain = null;
  }

  Future<void> _inspectCurrent(
    AppCzarAttachmentArchiveRepairBinding binding,
  ) async {
    final executor = _executorFor(binding);
    if (executor == null || _sealed || _stopRequested) {
      return;
    }
    AppCzarAttachmentArchiveRepairObservation observation;
    try {
      observation = await executor.inspectCurrent(binding: binding);
    } on Object catch (error, stack) {
      _retainFailure(error, stack);
      if (_canPublish(binding)) {
        _publishFailure(
          binding,
          AppCzarAttachmentArchiveRepairFailureKind.inspectionFailed,
        );
      }
      return;
    }
    await _handleObservation(binding, observation);
  }

  Future<void> _preserveAuthorizedBatch(
    AppCzarAttachmentArchiveRepairBinding binding,
    AppCzarAttachmentArchiveRepairBatchAuthorization authorization,
  ) async {
    final executor = _executorFor(binding);
    if (executor == null || _sealed || _stopRequested) {
      return;
    }
    AppCzarAttachmentArchiveRepairObservation observation;
    try {
      observation = await executor.preserveAuthorizedBatch(
        binding: binding,
        authorization: authorization,
        onProgress: (progress) {
          if (!_canPublish(binding) || !progress.isCoherent) {
            return;
          }
          _publish(
            _current.copyWith(
              phase: AppCzarAttachmentArchiveRepairPhase.preserving,
              preservedCount: progress.completedCount,
              preservationTotalCount: progress.totalCount,
            ),
          );
        },
      );
    } on Object catch (error, stack) {
      _retainFailure(error, stack);
      if (_canPublish(binding)) {
        _publishFailure(
          binding,
          AppCzarAttachmentArchiveRepairFailureKind.preservationFailed,
        );
      }
      return;
    }
    await _handleObservation(binding, observation);
  }

  Future<void> _handleObservation(
    AppCzarAttachmentArchiveRepairBinding binding,
    AppCzarAttachmentArchiveRepairObservation observation,
  ) async {
    if (_stopRequested || !_isActiveOccurrence(binding)) {
      return;
    }
    if (!_observationMatches(binding, observation)) {
      _queueRestart(binding);
      return;
    }
    if (!observation.isCoherent) {
      _publishFailure(
        binding,
        AppCzarAttachmentArchiveRepairFailureKind.incoherentEvidence,
      );
      return;
    }

    _drainFailure = null;
    _drainFailureStack = null;
    switch (observation.kind) {
      case AppCzarAttachmentArchiveRepairObservationKind.coverageComplete:
      case AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown:
      case AppCzarAttachmentArchiveRepairObservationKind.sourceAccessLost:
      case AppCzarAttachmentArchiveRepairObservationKind.archiveBindingChanged:
        _queueRestart(binding);
        return;
      case AppCzarAttachmentArchiveRepairObservationKind.coverageIncomplete:
        final snapshot = observation.snapshot!;
        _publish(
          AppCzarAttachmentArchiveRepairState(
            phase: snapshot.hasAutomaticWork
                ? AppCzarAttachmentArchiveRepairPhase.awaitingConfirmation
                : AppCzarAttachmentArchiveRepairPhase.waitingForHuman,
            assessmentGeneration: binding.assessmentGeneration,
            occurrenceId: binding.occurrenceId,
            snapshot: snapshot,
          ),
        );
        return;
      case AppCzarAttachmentArchiveRepairObservationKind.stopped:
        return;
    }
  }

  void _queueRestart(
    AppCzarAttachmentArchiveRepairBinding binding, {
    bool retry = false,
  }) {
    if (_sealed || !_isActiveOccurrence(binding) || _restartRequested) {
      return;
    }
    _restartRequested = true;
    _stopRequested = true;
    final priorRun = _activeRun;
    // This is separate from priorRun: a worker never awaits its own restart.
    final flight = Future<void>.microtask(() async {
      // Ask the executor to stop before waiting for its controller continuation.
      final drain = _drainExecutor();
      await priorRun;
      final drained = await drain;
      if (_sealed || !_isActiveOccurrence(binding)) {
        return;
      }
      if (!drained || (!retry && _drainFailure != null)) {
        _restartRequested = false;
        _publish(
          _current.copyWith(
            phase: AppCzarAttachmentArchiveRepairPhase.restartFailed,
            failureKind: AppCzarAttachmentArchiveRepairFailureKind.drainFailed,
          ),
        );
        return;
      }
      _restartActive = true;
      _publish(
        _current.copyWith(
          phase: AppCzarAttachmentArchiveRepairPhase.restartRequested,
          clearProgress: true,
          clearFailure: true,
        ),
      );
      try {
        if (_sealed) {
          return;
        }
        await ref.read(appCzarProcessRestarterProvider).restartAndReassess();
        _drainFailure = null;
        _drainFailureStack = null;
      } on Object catch (error, stack) {
        _restartRequested = false;
        _retainFailure(error, stack);
        if (!_sealed) {
          _publish(
            _current.copyWith(
              phase: AppCzarAttachmentArchiveRepairPhase.restartFailed,
              failureKind:
                  AppCzarAttachmentArchiveRepairFailureKind.restartFailed,
            ),
          );
        }
      } finally {
        _restartActive = false;
      }
    });
    _restartFlight = flight;
    unawaited(
      flight.whenComplete(() {
        if (identical(_restartFlight, flight)) {
          _restartFlight = null;
        }
      }),
    );
    _publish(
      _current.copyWith(
        phase: AppCzarAttachmentArchiveRepairPhase.stopping,
        clearProgress: true,
      ),
    );
  }

  void _publishFailure(
    AppCzarAttachmentArchiveRepairBinding binding,
    AppCzarAttachmentArchiveRepairFailureKind failureKind,
  ) {
    if (!_canPublish(binding)) {
      return;
    }
    _publish(
      _current.copyWith(
        phase: AppCzarAttachmentArchiveRepairPhase.failed,
        failureKind: failureKind,
        clearProgress: true,
      ),
    );
  }

  bool _observationMatches(
    AppCzarAttachmentArchiveRepairBinding binding,
    AppCzarAttachmentArchiveRepairObservation observation,
  ) {
    final observed = observation.binding;
    return observed.occurrenceId == binding.occurrenceId &&
        observed.assessmentGeneration == binding.assessmentGeneration &&
        observed.hasSameArchiveBinding(binding);
  }

  bool _isCurrentBinding(AppCzarAttachmentArchiveRepairBinding binding) {
    return _isCurrentAssessmentBinding(
      ref.read(appCzarAssessmentControllerProvider),
      binding,
    );
  }

  bool _isCurrentAssessmentBinding(
    AppCzarAssessmentState assessmentState,
    AppCzarAttachmentArchiveRepairBinding binding,
  ) {
    if (!shouldExecuteAppCzarAttachmentArchiveRepair(
      assessmentState,
      expectedAssessmentGeneration: binding.assessmentGeneration,
    )) {
      return false;
    }
    final archive = assessmentState.attachmentArchive!;
    return archive.archiveScopeIdentity == binding.archiveScopeIdentity &&
        archive.archiveGeneration == binding.archiveGeneration &&
        canonicalAppCzarAttachmentArchivePath(archive.resolvedPath!) ==
            binding.resolvedArchivePath;
  }

  bool _canPublish(AppCzarAttachmentArchiveRepairBinding binding) {
    return !_stopRequested &&
        _isActiveOccurrence(binding) &&
        _isCurrentBinding(binding);
  }

  bool _isActiveOccurrence(AppCzarAttachmentArchiveRepairBinding binding) {
    return identical(_activeBinding, binding);
  }

  AppCzarAttachmentArchiveRepairExecutor? _executorFor(
    AppCzarAttachmentArchiveRepairBinding binding,
  ) {
    return _isActiveOccurrence(binding) ? _activeExecutor : null;
  }

  void _publish(AppCzarAttachmentArchiveRepairState next) {
    if (_disposed) {
      return;
    }
    _current = next;
    state = next;
  }
}

AppCzarTruth? _uniqueFactTruth(
  AppCzarAssessment assessment,
  AppCzarFactId factId,
) {
  AppCzarTruth? truth;
  var matches = 0;
  for (final fact in assessment.facts) {
    if (fact.id == factId) {
      matches += 1;
      truth = fact.truth;
    }
  }
  return matches == 1 ? truth : null;
}
