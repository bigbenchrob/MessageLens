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
  return archive.coverage.condition ==
          AppCzarAttachmentCoverageCondition.incomplete &&
      archive.hasCoherentCoverageBinding &&
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
  var _nextOccurrenceId = 0;
  var _checkInFlight = false;
  var _preservationInFlight = false;
  var _restartRequested = false;
  var _stopRequested = false;
  var _staleDrainInFlight = false;

  @override
  AppCzarAttachmentArchiveRepairState build() {
    final assessmentState = ref.watch(appCzarAssessmentControllerProvider);
    final binding = _activeBinding;
    if (binding != null &&
        !_isCurrentAssessmentBinding(assessmentState, binding)) {
      _beginStaleDrain(binding);
      return _current;
    }

    if (binding == null &&
        !_staleDrainInFlight &&
        shouldExecuteAppCzarAttachmentArchiveRepair(assessmentState)) {
      _beginOccurrence(assessmentState, publish: false);
    }
    return _current;
  }

  Future<void> startPreservation(
    AppCzarAttachmentArchiveRepairBatchAuthorization authorization,
  ) async {
    final binding = _activeBinding;
    final currentAuthorization = _current.snapshot?.nextBatchAuthorization;
    if (binding == null ||
        currentAuthorization == null ||
        !identical(currentAuthorization, authorization) ||
        !_current.canStartPreservation ||
        _preservationInFlight ||
        _checkInFlight ||
        _restartRequested ||
        _stopRequested ||
        !_isCurrentBinding(binding)) {
      return;
    }

    _preservationInFlight = true;
    try {
      _publish(
        _current.copyWith(
          phase: AppCzarAttachmentArchiveRepairPhase.preserving,
          preservedCount: 0,
          preservationTotalCount: authorization.itemCount,
          clearFailure: true,
        ),
      );
      await _runOne(() => _preserveAuthorizedBatch(binding, authorization));
    } finally {
      _preservationInFlight = false;
    }
  }

  Future<void> checkAgain() async {
    final oldBinding = _activeBinding;
    final oldExecutor = _activeExecutor;
    if (oldBinding == null ||
        !_current.canCheckAgain ||
        _checkInFlight ||
        _preservationInFlight ||
        _restartRequested ||
        _stopRequested) {
      return;
    }

    _checkInFlight = true;
    try {
      _publish(
        _current.copyWith(
          phase: AppCzarAttachmentArchiveRepairPhase.inspecting,
          clearProgress: true,
          clearFailure: true,
        ),
      );
      if (oldExecutor != null) {
        try {
          await oldExecutor.stopAndDrain();
        } on Object {
          if (_isActiveOccurrence(oldBinding)) {
            _publishFailure(
              oldBinding,
              AppCzarAttachmentArchiveRepairFailureKind.drainFailed,
            );
          }
          return;
        }
      }
      if (_activeBinding != oldBinding || _stopRequested) {
        return;
      }

      final assessmentState = ref.read(appCzarAssessmentControllerProvider);
      if (!shouldExecuteAppCzarAttachmentArchiveRepair(
        assessmentState,
        expectedAssessmentGeneration: oldBinding.assessmentGeneration,
      )) {
        await _restartForFreshAssessment(oldBinding);
        return;
      }

      _activeBinding = null;
      _activeExecutor = null;
      _beginOccurrence(assessmentState, publish: true);
    } finally {
      _checkInFlight = false;
    }
  }

  Future<void> retryRestart() async {
    final binding = _activeBinding;
    if (binding == null || !_current.canRetryRestart || _restartRequested) {
      return;
    }
    await _restartForFreshAssessment(binding);
  }

  /// Stops admission synchronously and then drains all active repair work.
  Future<void> stopAndDrain() async {
    final binding = _activeBinding;
    final executor = _activeExecutor;
    _stopRequested = true;
    if (binding != null && _current.isVisible) {
      _publish(
        _current.copyWith(
          phase: AppCzarAttachmentArchiveRepairPhase.stopping,
          clearProgress: true,
        ),
      );
    }
    if (executor != null) {
      try {
        await executor.stopAndDrain();
      } finally {
        final activeRun = _activeRun;
        if (activeRun != null) {
          await activeRun;
        }
      }
    } else {
      final activeRun = _activeRun;
      if (activeRun != null) {
        await activeRun;
      }
    }
  }

  void _beginOccurrence(
    AppCzarAssessmentState assessmentState, {
    required bool publish,
  }) {
    final archive = assessmentState.attachmentArchive!;
    final binding = AppCzarAttachmentArchiveRepairBinding(
      occurrenceId: _nextOccurrenceId,
      assessmentGeneration: assessmentState.generation,
      archiveScopeIdentity: archive.archiveScopeIdentity!,
      archiveGeneration: archive.archiveGeneration!,
      resolvedArchivePath: archive.resolvedPath!,
    );
    _nextOccurrenceId += 1;
    _stopRequested = false;
    _restartRequested = false;

    AppCzarAttachmentArchiveRepairExecutor executor;
    try {
      executor = ref
          .read(appCzarAttachmentArchiveRepairExecutorFactoryProvider)
          .create();
    } on Object {
      _activeBinding = binding;
      _activeExecutor = null;
      _current = AppCzarAttachmentArchiveRepairState(
        phase: AppCzarAttachmentArchiveRepairPhase.failed,
        assessmentGeneration: binding.assessmentGeneration,
        occurrenceId: binding.occurrenceId,
        failureKind: AppCzarAttachmentArchiveRepairFailureKind.inspectionFailed,
      );
      if (publish) {
        state = _current;
      }
      return;
    }

    _activeBinding = binding;
    _activeExecutor = executor;
    _current = AppCzarAttachmentArchiveRepairState(
      phase: AppCzarAttachmentArchiveRepairPhase.inspecting,
      assessmentGeneration: binding.assessmentGeneration,
      occurrenceId: binding.occurrenceId,
    );
    if (publish) {
      state = _current;
    }
    _scheduleOne(() => _inspectCurrent(binding));
  }

  void _scheduleOne(Future<void> Function() action) {
    final run = Future<void>.microtask(action);
    _activeRun = run;
    unawaited(
      run.whenComplete(() {
        if (_activeRun == run) {
          _activeRun = null;
        }
      }),
    );
  }

  Future<void> _runOne(Future<void> Function() action) async {
    final run = action();
    _activeRun = run;
    try {
      await run;
    } finally {
      if (_activeRun == run) {
        _activeRun = null;
      }
    }
  }

  Future<void> _inspectCurrent(
    AppCzarAttachmentArchiveRepairBinding binding,
  ) async {
    final executor = _executorFor(binding);
    if (executor == null) {
      return;
    }
    AppCzarAttachmentArchiveRepairObservation observation;
    try {
      observation = await executor.inspectCurrent(binding: binding);
    } on Object {
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
    if (executor == null) {
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
    } on Object {
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
      await _restartForFreshAssessment(binding);
      return;
    }
    if (!observation.isCoherent) {
      _publishFailure(
        binding,
        AppCzarAttachmentArchiveRepairFailureKind.incoherentEvidence,
      );
      return;
    }

    switch (observation.kind) {
      case AppCzarAttachmentArchiveRepairObservationKind.coverageComplete:
      case AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown:
      case AppCzarAttachmentArchiveRepairObservationKind.sourceAccessLost:
      case AppCzarAttachmentArchiveRepairObservationKind.archiveBindingChanged:
        await _restartForFreshAssessment(binding);
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

  Future<void> _restartForFreshAssessment(
    AppCzarAttachmentArchiveRepairBinding binding,
  ) async {
    if (!_isActiveOccurrence(binding) || _restartRequested) {
      return;
    }
    _restartRequested = true;
    _stopRequested = true;
    _publish(
      _current.copyWith(
        phase: AppCzarAttachmentArchiveRepairPhase.stopping,
        clearProgress: true,
        clearFailure: true,
      ),
    );
    final executor = _activeExecutor;
    if (executor != null) {
      try {
        await executor.stopAndDrain();
      } on Object {
        _restartRequested = false;
        _publish(
          _current.copyWith(
            phase: AppCzarAttachmentArchiveRepairPhase.restartFailed,
            failureKind: AppCzarAttachmentArchiveRepairFailureKind.drainFailed,
          ),
        );
        return;
      }
    }
    if (!_isActiveOccurrence(binding)) {
      return;
    }
    await _restartAfterSettledDrain(binding);
  }

  Future<void> _restartAfterSettledDrain(
    AppCzarAttachmentArchiveRepairBinding binding,
  ) async {
    if (!_isActiveOccurrence(binding)) {
      return;
    }
    _publish(
      _current.copyWith(
        phase: AppCzarAttachmentArchiveRepairPhase.restartRequested,
        clearProgress: true,
        clearFailure: true,
      ),
    );
    try {
      await ref.read(appCzarProcessRestarterProvider).restartAndReassess();
    } on Object {
      _restartRequested = false;
      _publish(
        _current.copyWith(
          phase: AppCzarAttachmentArchiveRepairPhase.restartFailed,
          failureKind: AppCzarAttachmentArchiveRepairFailureKind.restartFailed,
        ),
      );
    }
  }

  void _beginStaleDrain(AppCzarAttachmentArchiveRepairBinding binding) {
    if (_staleDrainInFlight) {
      return;
    }
    _staleDrainInFlight = true;
    _stopRequested = true;
    _current = _current.copyWith(
      phase: AppCzarAttachmentArchiveRepairPhase.stopping,
      clearProgress: true,
    );
    unawaited(_finishStaleDrain(binding));
  }

  Future<void> _finishStaleDrain(
    AppCzarAttachmentArchiveRepairBinding binding,
  ) async {
    var drainFailed = false;
    final executor = _executorFor(binding);
    if (executor != null) {
      try {
        await executor.stopAndDrain();
      } on Object {
        drainFailed = true;
      }
    }
    final activeRun = _activeRun;
    if (activeRun != null) {
      try {
        await activeRun;
      } on Object {
        drainFailed = true;
      }
    }
    if (!_isActiveOccurrence(binding)) {
      _staleDrainInFlight = false;
      return;
    }
    if (drainFailed) {
      _staleDrainInFlight = false;
      _restartRequested = false;
      _current = _current.copyWith(
        phase: AppCzarAttachmentArchiveRepairPhase.restartFailed,
        failureKind: AppCzarAttachmentArchiveRepairFailureKind.drainFailed,
      );
      state = _current;
      return;
    }
    _staleDrainInFlight = false;
    _restartRequested = true;
    await _restartAfterSettledDrain(binding);
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
