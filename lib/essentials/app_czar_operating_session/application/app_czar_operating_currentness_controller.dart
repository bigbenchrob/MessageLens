import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_czar/domain/app_czar_models.dart';
import '../../app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import '../../conversation_graph/application/monitor/live_graph_update_worker.dart';
import '../domain/app_czar_operating_currentness_models.dart';
import '../domain/app_czar_operating_session_state.dart';
import 'app_czar_operating_currentness_classifier.dart';
import 'app_czar_operating_currentness_observer_provider.dart';
import 'app_czar_operating_live_update_executor_provider.dart';

part 'app_czar_operating_currentness_controller.g.dart';

@riverpod
Duration appCzarOperatingCurrentnessCadence(Ref ref) {
  return const Duration(seconds: 15);
}

final class AppCzarOperatingOccurrenceEndedException extends StateError {
  AppCzarOperatingOccurrenceEndedException(super.message);
}

@riverpod
class AppCzarOperatingCurrentnessController
    extends _$AppCzarOperatingCurrentnessController {
  Timer? _nextObservationTimer;
  Future<void>? _activeFlight;
  AppCzarOperatingArchiveBinding? _archiveBinding;
  late AppCzarOperatingSessionOccurrence _occurrence;
  late Duration _cadence;
  var _publicationEpoch = 0;
  var _started = false;
  var _acceptingWork = false;
  var _restartStarted = false;
  var _restartSuppressed = false;
  var _disposed = false;

  @override
  AppCzarOperatingCurrentnessState build(
    AppCzarOperatingSessionOccurrence occurrence,
  ) {
    _occurrence = occurrence;
    _cadence = ref.watch(appCzarOperatingCurrentnessCadenceProvider);
    ref.onDispose(() {
      _disposed = true;
      _stopSynchronously(publishStopped: false);
    });
    return AppCzarOperatingCurrentnessState.idle(occurrence);
  }

  /// Starts this exact occurrence after its Operating shell has mounted.
  void start() {
    if (_started || _disposed) {
      return;
    }
    _started = true;
    _acceptingWork = true;
    _publicationEpoch += 1;
    _beginObservationFlight();
  }

  /// Stops admission synchronously, then awaits the exact admitted flight.
  Future<void> stopAndDrain() {
    _restartSuppressed = true;
    _stopSynchronously(publishStopped: true);
    return _drainActiveFlight();
  }

  Future<void> _drainForRestart() {
    _stopSynchronously(publishStopped: false);
    return _drainActiveFlight();
  }

  Future<void> _drainActiveFlight() {
    final activeFlight = _activeFlight;
    return activeFlight ?? Future<void>.value();
  }

  /// Called only after the live issue state has received one presentation
  /// frame. The restart implementation exits directly, so drain must happen
  /// here rather than relying on application lifecycle callbacks.
  Future<void> restartAfterIssuePresented() async {
    if (_restartSuppressed ||
        _restartStarted ||
        state.phase != AppCzarOperatingCurrentnessPhase.issue) {
      return;
    }
    _restartStarted = true;
    state = state.copyWith(
      phase: AppCzarOperatingCurrentnessPhase.restarting,
      clearProgress: true,
    );
    await _drainForRestart();
    if (_restartSuppressed) {
      return;
    }
    try {
      await ref.read(appCzarProcessRestarterProvider).restartAndReassess();
    } on Object catch (error) {
      _restartStarted = false;
      state = state.copyWith(
        phase: AppCzarOperatingCurrentnessPhase.issue,
        issueKind: AppCzarOperatingCurrentnessIssueKind.updateFailed,
        issue: 'MessageLens could not restart for a fresh assessment: $error',
        clearProgress: true,
      );
    }
  }

  @visibleForTesting
  bool triggerObservationNow() {
    if (!_acceptingWork || _activeFlight != null) {
      return false;
    }
    _nextObservationTimer?.cancel();
    _nextObservationTimer = null;
    _beginObservationFlight();
    return true;
  }

  void _stopSynchronously({required bool publishStopped}) {
    _acceptingWork = false;
    _nextObservationTimer?.cancel();
    _nextObservationTimer = null;
    _publicationEpoch += 1;
    if (publishStopped && !_disposed) {
      state = state.copyWith(
        phase: AppCzarOperatingCurrentnessPhase.stopped,
        clearProgress: true,
        clearIssue: true,
      );
    }
  }

  void _beginObservationFlight() {
    if (!_acceptingWork || _activeFlight != null || _disposed) {
      return;
    }

    final completion = Completer<void>();
    final flight = completion.future;
    final epoch = _publicationEpoch;
    _activeFlight = flight;
    unawaited(
      Future<void>.sync(() => _runObservationCycle(epoch))
          .catchError((Object error, StackTrace stackTrace) {
            if (_canPublish(epoch)) {
              _publishIssue(
                epoch: epoch,
                kind: AppCzarOperatingCurrentnessIssueKind.updateFailed,
                detail: 'Operating currentness failed: $error',
              );
            }
          })
          .whenComplete(() {
            if (identical(_activeFlight, flight)) {
              _activeFlight = null;
            }
            if (!completion.isCompleted) {
              completion.complete();
            }
            if (_acceptingWork && !_disposed) {
              _scheduleNextObservation();
            }
          }),
    );
  }

  Future<void> _runObservationCycle(int epoch) async {
    final observer = ref.read(appCzarOperatingCurrentnessObserverProvider);
    final binding =
        _archiveBinding ?? await _establishArchiveBinding(observer, epoch);
    if (binding == null || !_canPublish(epoch)) {
      return;
    }
    _archiveBinding = binding;

    var observation = await observer.readCurrentness();
    if (!_canPublish(epoch)) {
      return;
    }
    var decision = classifyAppCzarOperatingCurrentness(observation);
    if (decision.disposition ==
        AppCzarOperatingCurrentnessDisposition.sourceUnstable) {
      observation = await observer.readCurrentness();
      if (!_canPublish(epoch)) {
        return;
      }
      decision = classifyAppCzarOperatingCurrentness(observation);
    }

    if (!_locationStillMatches(binding, observation.after.archiveLocation)) {
      _publishArchiveIssue(
        epoch: epoch,
        binding: binding,
        location: observation.after.archiveLocation,
      );
      return;
    }

    switch (decision.disposition) {
      case AppCzarOperatingCurrentnessDisposition.transient:
      case AppCzarOperatingCurrentnessDisposition.noChange:
        return;
      case AppCzarOperatingCurrentnessDisposition.sourceAhead:
        await _runSourceAheadUpdate(
          observer: observer,
          binding: binding,
          epoch: epoch,
        );
        return;
      case AppCzarOperatingCurrentnessDisposition.sourceUnreadable:
        _publishIssue(
          epoch: epoch,
          kind: AppCzarOperatingCurrentnessIssueKind.sourceUnreadable,
          detail: decision.detail,
        );
        return;
      case AppCzarOperatingCurrentnessDisposition.sourceUnknown:
        _publishIssue(
          epoch: epoch,
          kind: AppCzarOperatingCurrentnessIssueKind.sourceUnknown,
          detail: decision.detail,
        );
        return;
      case AppCzarOperatingCurrentnessDisposition.sourceUnstable:
        _publishIssue(
          epoch: epoch,
          kind: AppCzarOperatingCurrentnessIssueKind.sourceUnstable,
          detail: decision.detail,
        );
        return;
      case AppCzarOperatingCurrentnessDisposition.localContradiction:
        _publishIssue(
          epoch: epoch,
          kind: AppCzarOperatingCurrentnessIssueKind.localDatasetContradiction,
          detail: decision.detail,
        );
        return;
    }
  }

  Future<AppCzarOperatingArchiveBinding?> _establishArchiveBinding(
    AppCzarOperatingCurrentnessObserver observer,
    int epoch,
  ) async {
    final coverage = await observer.readCoverage();
    if (!_canPublish(epoch)) {
      return null;
    }
    if (!coverage.isCoherent) {
      return null;
    }

    final scope = _occurrence.admittedArchiveScopeIdentity;
    final probeGeneration = _occurrence.admittedArchiveProbeGeneration;
    final resolvedPath = _occurrence.admittedArchiveResolvedPath;
    if (scope == null ||
        scope.isEmpty ||
        probeGeneration == null ||
        probeGeneration < 0 ||
        resolvedPath == null ||
        resolvedPath.isEmpty) {
      _publishIssue(
        epoch: epoch,
        kind: AppCzarOperatingCurrentnessIssueKind
            .admittedArchiveBindingUnavailable,
        detail:
            'The admitted Operating occurrence does not contain one complete attachment archive binding.',
      );
      return null;
    }

    final binding = AppCzarOperatingArchiveBinding(
      scopeIdentity: scope,
      probeGeneration: probeGeneration,
      locationGeneration: coverage.after.archiveLocation.generation,
      resolvedPath: resolvedPath,
    );
    if (!binding.matchesLocation(coverage.after.archiveLocation)) {
      _publishArchiveIssue(
        epoch: epoch,
        binding: binding,
        location: coverage.after.archiveLocation,
      );
      return null;
    }
    if (!_validateArchiveEvidence(epoch, binding, coverage.archive)) {
      return null;
    }
    if (!_coverageIsComplete(coverage.archive)) {
      _publishCoverageIssue(epoch, coverage.archive);
      return null;
    }
    return binding;
  }

  Future<void> _runSourceAheadUpdate({
    required AppCzarOperatingCurrentnessObserver observer,
    required AppCzarOperatingArchiveBinding binding,
    required int epoch,
  }) async {
    _publish(
      epoch,
      state.copyWith(
        phase: AppCzarOperatingCurrentnessPhase.verifyingCoverage,
        clearProgress: true,
        clearIssue: true,
      ),
    );
    final preCoverage = await observer.readCoverage();
    if (!_canPublish(epoch)) {
      return;
    }
    if (!preCoverage.isCoherent) {
      _publish(epoch, AppCzarOperatingCurrentnessState.idle(_occurrence));
      return;
    }
    if (!binding.matchesLocation(preCoverage.after.archiveLocation)) {
      _publishArchiveIssue(
        epoch: epoch,
        binding: binding,
        location: preCoverage.after.archiveLocation,
      );
      return;
    }
    if (!_validateArchiveEvidence(epoch, binding, preCoverage.archive)) {
      return;
    }
    if (!_coverageIsComplete(preCoverage.archive)) {
      _publishCoverageIssue(epoch, preCoverage.archive);
      return;
    }
    if (!_archiveConditionPermitsMutation(preCoverage.archive.condition)) {
      _publishIssue(
        epoch: epoch,
        kind: AppCzarOperatingCurrentnessIssueKind.archiveUnavailable,
        detail:
            preCoverage.archive.issue ??
            'The admitted attachment archive is currently read-only and cannot preserve new attachments.',
      );
      return;
    }
    if (!preCoverage.after.archiveLocation.isWritableMutationEligible) {
      _publishArchiveIssue(
        epoch: epoch,
        binding: binding,
        location: preCoverage.after.archiveLocation,
      );
      return;
    }

    final admittedFence = preCoverage.after;
    final result = await ref
        .read(appCzarOperatingLiveUpdateExecutorProvider)
        .run(
          occurrence: _occurrence,
          requireCurrentOccurrence: () {
            _requireCurrentOccurrence(epoch);
          },
          requireCurrentPrecondition: () {
            return _requireCurrentMutationPrecondition(
              observer: observer,
              binding: binding,
              admittedFence: admittedFence,
              epoch: epoch,
            );
          },
          onObservation: (observation) {
            _observeWorker(epoch, observation);
          },
        );
    if (!_canPublish(epoch)) {
      return;
    }
    if (!result.performedUpdate) {
      _publishIssue(
        epoch: epoch,
        kind: AppCzarOperatingCurrentnessIssueKind.localDatasetContradiction,
        detail:
            'The source-ahead observation no longer matched the worker prerequisites.',
      );
      return;
    }

    _publish(
      epoch,
      state.copyWith(
        phase: AppCzarOperatingCurrentnessPhase.verifyingCoverage,
        clearProgress: state.attachmentsExamined == null,
        clearIssue: true,
      ),
    );
    final postCoverage = await observer.readCoverage();
    if (!_canPublish(epoch)) {
      return;
    }
    if (!postCoverage.isCoherent) {
      _publishIssue(
        epoch: epoch,
        kind: AppCzarOperatingCurrentnessIssueKind.coverageUnknown,
        detail:
            'Required attachment coverage could not be verified after the live update.',
      );
      return;
    }
    if (!binding.matchesLocation(postCoverage.after.archiveLocation)) {
      _publishArchiveIssue(
        epoch: epoch,
        binding: binding,
        location: postCoverage.after.archiveLocation,
      );
      return;
    }
    if (!_validateArchiveEvidence(epoch, binding, postCoverage.archive)) {
      return;
    }
    if (!_coverageIsComplete(postCoverage.archive)) {
      _publishCoverageIssue(epoch, postCoverage.archive);
      return;
    }
    if (!_archiveConditionPermitsMutation(postCoverage.archive.condition)) {
      _publishIssue(
        epoch: epoch,
        kind: AppCzarOperatingCurrentnessIssueKind.archiveUnavailable,
        detail:
            postCoverage.archive.issue ??
            'The admitted attachment archive became read-only during the live update.',
      );
      return;
    }
    if (!postCoverage.after.archiveLocation.isWritableMutationEligible) {
      _publishArchiveIssue(
        epoch: epoch,
        binding: binding,
        location: postCoverage.after.archiveLocation,
      );
      return;
    }

    _publish(epoch, AppCzarOperatingCurrentnessState.idle(_occurrence));
  }

  Future<void> _requireCurrentMutationPrecondition({
    required AppCzarOperatingCurrentnessObserver observer,
    required AppCzarOperatingArchiveBinding binding,
    required AppCzarOperatingReadFence admittedFence,
    required int epoch,
  }) async {
    _requireCurrentOccurrence(epoch);
    final current = await observer.readFence();
    _requireCurrentOccurrence(epoch);
    if (current.messageDataGeneration != admittedFence.messageDataGeneration ||
        current.mutation.lastReleasedAtMicroseconds !=
            admittedFence.mutation.lastReleasedAtMicroseconds ||
        !binding.matchesLocation(current.archiveLocation) ||
        !current.archiveLocation.isWritableMutationEligible) {
      throw AppCzarOperatingOccurrenceEndedException(
        'The admitted source/archive precondition changed before the worker ran.',
      );
    }
  }

  void _requireCurrentOccurrence(int epoch) {
    if (!_canPublish(epoch)) {
      throw AppCzarOperatingOccurrenceEndedException(
        'The Operating occurrence stopped during live update admission.',
      );
    }
  }

  void _observeWorker(int epoch, LiveGraphUpdateObservation observation) {
    if (!_canPublish(epoch)) {
      return;
    }
    switch (observation.kind) {
      case LiveGraphUpdateObservationKind.checkingPrerequisites:
        _publish(
          epoch,
          state.copyWith(
            phase: AppCzarOperatingCurrentnessPhase.updating,
            clearProgress: true,
            clearIssue: true,
          ),
        );
        break;
      case LiveGraphUpdateObservationKind.prerequisitesRead:
        _publish(
          epoch,
          state.copyWith(
            phase: AppCzarOperatingCurrentnessPhase.updating,
            clearProgress: true,
            clearIssue: true,
          ),
        );
        break;
      case LiveGraphUpdateObservationKind.graphBuild:
        final graph = observation.graphBuild!;
        _publish(
          epoch,
          state.copyWith(
            phase: AppCzarOperatingCurrentnessPhase.updating,
            suboperation: graph.suboperation,
            completedWorkCount: graph.completedWorkCount,
            totalWorkCount: graph.totalWorkCount,
            clearProgress: graph.completedWorkCount == null,
            clearIssue: true,
          ),
        );
        break;
      case LiveGraphUpdateObservationKind.preservingAttachments:
        _publish(
          epoch,
          state.copyWith(
            phase: AppCzarOperatingCurrentnessPhase.preservingAttachments,
            clearProgress: true,
            clearIssue: true,
          ),
        );
        break;
      case LiveGraphUpdateObservationKind.attachmentsPreserved:
        final result = observation.attachmentResult!;
        _publish(
          epoch,
          AppCzarOperatingCurrentnessState(
            occurrence: _occurrence,
            phase: AppCzarOperatingCurrentnessPhase.verifyingCoverage,
            attachmentsExamined: result.totalScanned,
            attachmentsPreserved: result.newlyArchived,
            attachmentsSkipped: result.skipped,
            attachmentsFailed: result.failed,
          ),
        );
        break;
    }
  }

  bool _coverageIsComplete(AppCzarArchiveObservation archive) {
    final conditionSupportsCoverage = switch (archive.condition) {
      AppCzarArchiveCondition.available ||
      AppCzarArchiveCondition.readOnly ||
      AppCzarArchiveCondition.notCreated => true,
      AppCzarArchiveCondition.unavailable ||
      AppCzarArchiveCondition.unknown => false,
    };
    return conditionSupportsCoverage &&
        archive.hasCoherentCoverageBinding &&
        archive.coverage.condition ==
            AppCzarAttachmentCoverageCondition.complete;
  }

  bool _archiveConditionPermitsMutation(AppCzarArchiveCondition condition) {
    return switch (condition) {
      AppCzarArchiveCondition.available ||
      AppCzarArchiveCondition.notCreated => true,
      AppCzarArchiveCondition.readOnly ||
      AppCzarArchiveCondition.unavailable ||
      AppCzarArchiveCondition.unknown => false,
    };
  }

  bool _validateArchiveEvidence(
    int epoch,
    AppCzarOperatingArchiveBinding binding,
    AppCzarArchiveObservation archive,
  ) {
    switch (archive.condition) {
      case AppCzarArchiveCondition.unknown:
        _publishIssue(
          epoch: epoch,
          kind: AppCzarOperatingCurrentnessIssueKind.coverageUnknown,
          detail:
              archive.issue ??
              'Fresh attachment archive evidence was inconclusive.',
        );
        return false;
      case AppCzarArchiveCondition.unavailable:
        _publishIssue(
          epoch: epoch,
          kind: AppCzarOperatingCurrentnessIssueKind.archiveUnavailable,
          detail:
              archive.issue ??
              'The admitted attachment archive is not currently available.',
        );
        return false;
      case AppCzarArchiveCondition.available:
      case AppCzarArchiveCondition.readOnly:
      case AppCzarArchiveCondition.notCreated:
        break;
    }

    if (binding.matchesArchive(archive)) {
      return true;
    }
    if (_hasPositiveArchiveBindingMismatch(binding, archive)) {
      _publishIssue(
        epoch: epoch,
        kind: AppCzarOperatingCurrentnessIssueKind.archiveChanged,
        detail:
            'Fresh attachment archive identity or generation no longer matches the archive admitted for this Operating occurrence.',
      );
      return false;
    }
    _publishIssue(
      epoch: epoch,
      kind: AppCzarOperatingCurrentnessIssueKind.coverageUnknown,
      detail:
          archive.coverage.issue ??
          'Fresh attachment archive evidence did not contain one complete authentic binding.',
    );
    return false;
  }

  bool _hasPositiveArchiveBindingMismatch(
    AppCzarOperatingArchiveBinding binding,
    AppCzarArchiveObservation archive,
  ) {
    final archiveScope = archive.archiveScopeIdentity;
    final archiveGeneration = archive.archiveGeneration;
    final archivePath = archive.resolvedPath;
    final coverageScope = archive.coverage.archiveScopeIdentity;
    final coverageGeneration = archive.coverage.archiveGeneration;
    return (archiveScope != null &&
            archiveScope.isNotEmpty &&
            archiveScope != binding.scopeIdentity) ||
        (archiveGeneration != null &&
            archiveGeneration >= 0 &&
            archiveGeneration != binding.probeGeneration) ||
        (archivePath != null &&
            archivePath.isNotEmpty &&
            archivePath != binding.resolvedPath) ||
        (coverageScope != null &&
            coverageScope.isNotEmpty &&
            coverageScope != binding.scopeIdentity) ||
        (coverageGeneration != null &&
            coverageGeneration >= 0 &&
            coverageGeneration != binding.probeGeneration);
  }

  bool _locationStillMatches(
    AppCzarOperatingArchiveBinding binding,
    AppCzarOperatingArchiveLocationEvidence location,
  ) {
    return binding.matchesLocation(location);
  }

  void _publishCoverageIssue(int epoch, AppCzarArchiveObservation archive) {
    if (archive.coverage.condition ==
        AppCzarAttachmentCoverageCondition.incomplete) {
      _publishIssue(
        epoch: epoch,
        kind: AppCzarOperatingCurrentnessIssueKind.coverageIncomplete,
        detail:
            'Required attachment coverage is incomplete for the current local graph.',
      );
      return;
    }
    _publishIssue(
      epoch: epoch,
      kind: AppCzarOperatingCurrentnessIssueKind.coverageUnknown,
      detail:
          archive.coverage.issue ??
          'Required attachment coverage could not be verified for the current local graph.',
    );
  }

  void _publishArchiveIssue({
    required int epoch,
    required AppCzarOperatingArchiveBinding binding,
    required AppCzarOperatingArchiveLocationEvidence location,
  }) {
    final identityChanged =
        location.generation != binding.locationGeneration ||
        location.resolvedPath != binding.resolvedPath;
    final unavailable =
        !location.isReadable ||
        (!identityChanged && !location.isWritableMutationEligible);
    _publishIssue(
      epoch: epoch,
      kind: unavailable
          ? AppCzarOperatingCurrentnessIssueKind.archiveUnavailable
          : AppCzarOperatingCurrentnessIssueKind.archiveChanged,
      detail: unavailable
          ? location.issue ??
                'The admitted attachment archive is not currently available for preservation.'
          : 'The attachment archive changed from generation '
                '${binding.locationGeneration} to ${location.generation}.',
    );
  }

  void _publishIssue({
    required int epoch,
    required AppCzarOperatingCurrentnessIssueKind kind,
    required String detail,
  }) {
    if (!_canPublish(epoch)) {
      return;
    }
    state = state.copyWith(
      phase: AppCzarOperatingCurrentnessPhase.issue,
      issueKind: kind,
      issue: detail,
      clearProgress: true,
    );
    _acceptingWork = false;
    _nextObservationTimer?.cancel();
    _nextObservationTimer = null;
  }

  void _publish(int epoch, AppCzarOperatingCurrentnessState next) {
    if (_canPublish(epoch)) {
      state = next;
    }
  }

  bool _canPublish(int epoch) {
    return !_disposed &&
        _acceptingWork &&
        _publicationEpoch == epoch &&
        state.occurrence == _occurrence;
  }

  void _scheduleNextObservation() {
    if (!_acceptingWork || _disposed || _activeFlight != null) {
      return;
    }
    _nextObservationTimer?.cancel();
    _nextObservationTimer = Timer(_cadence, () {
      _nextObservationTimer = null;
      _beginObservationFlight();
    });
  }
}
