import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/domain.dart'
    show ArchiveMutationDeniedException, ArchiveMutationOperation;
import '../../archive_environment/feature_level_providers.dart'
    show archiveMutationCoordinatorProvider;
import '../../conversation_graph/application/conversation_graph_build_observation.dart';
import '../../conversation_graph/feature_level_providers.dart'
    show conversationGraphBuildControllerProvider;
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../navigation/feature_level_providers.dart'
    show SidebarMode, activeSidebarModeProvider;
import '../domain/onboarding_environment_report.dart';
import '../domain/onboarding_journey_operation_projection.dart';
import '../domain/onboarding_journey_state.dart';
import '../domain/onboarding_operation_snapshot.dart';
import '../domain/onboarding_status.dart';
import 'full_disk_access_provider.dart';
import 'message_data_reset_service.dart';
import 'onboarding_durable_completion_verifier_provider.dart';
import 'onboarding_environment_report_provider.dart';
import 'onboarding_failure_storage_provider.dart';
import 'onboarding_operation_reconciliation.dart';
import 'onboarding_operation_snapshot_controller.dart';
import 'onboarding_operation_snapshot_provider.dart';
import 'virgin_onboarding_import_executor.dart';

part 'onboarding_journey_coordinator_provider.g.dart';

enum _AutomaticRecoveryDeferral { none, waitingForMutationRelease }

/// Sole authority for user-visible Onboarding Journey semantics.
///
/// Environment and operation providers publish evidence. This stable notifier
/// ingests that evidence, validates its currentness, and is the only component
/// that turns it into a user-visible Journey Episode.
@Riverpod(keepAlive: true)
class OnboardingJourneyCoordinator extends _$OnboardingJourneyCoordinator {
  OnboardingEnvironmentReport? _latestReport;
  OnboardingOperationSnapshot? _startupRetainedOperationEvidence;
  _OnboardingUnboundFailure? _retainedUnboundFailure;
  _OnboardingOperationBinding? _operationBinding;
  _AutomaticRecoveryDeferral _automaticRecoveryDeferral =
      _AutomaticRecoveryDeferral.none;
  bool _automaticRecoverySuppressed = false;
  bool _startupAdoptionOpen = true;
  bool _startupReportSettled = false;
  bool _startupSnapshotSettled = false;
  bool _localHistoryAccepted = false;
  int _nextJourneyOccurrence = 0;
  int _nextEvidenceRevision = 0;
  int _nextCommandToken = 0;
  int? _activeCommandToken;

  @override
  OnboardingJourneyState build() {
    ref.listen<AsyncValue<OnboardingEnvironmentReport>>(
      onboardingEnvironmentReportProvider,
      (_, next) {
        final report = next.valueOrNull;
        if (report != null) {
          _ingestEnvironmentReport(report);
        } else if (next.hasError) {
          _startupReportSettled = true;
          _closeStartupAdoptionIfSettled();
        }
      },
    );
    ref.listen<AsyncValue<OnboardingOperationSnapshot>>(
      onboardingOperationSnapshotProvider,
      (_, next) {
        final snapshot = next.valueOrNull;
        if (snapshot != null) {
          _ingestOperationEvidence(snapshot);
        } else if (next.hasError) {
          _startupSnapshotSettled = true;
          _closeStartupAdoptionIfSettled();
        }
      },
    );
    ref.listen<bool>(
      archiveMutationCoordinatorProvider.select((value) => value.isLocked),
      _handleMutationLockChanged,
      fireImmediately: true,
    );

    final initialReport = ref.read(onboardingEnvironmentReportProvider);
    final initialSnapshot = ref.read(onboardingOperationSnapshotProvider);
    _latestReport = initialReport.valueOrNull;
    _startupReportSettled = initialReport.hasValue || initialReport.hasError;
    _startupSnapshotSettled =
        initialSnapshot.hasValue || initialSnapshot.hasError;
    final initial = _reconstructInitialJourney(
      report: _latestReport,
      snapshot: initialSnapshot.valueOrNull,
    );
    _closeStartupAdoptionIfSettled();
    return initial;
  }

  OnboardingJourneyState _reconstructInitialJourney({
    required OnboardingEnvironmentReport? report,
    required OnboardingOperationSnapshot? snapshot,
  }) {
    if (snapshot != null &&
        snapshot.operationId != null &&
        snapshot.kind != null &&
        snapshot.currentStage != null) {
      if (snapshot.status == OnboardingOperationStatus.interrupted) {
        if (report == null || _reportHasExternalPrerequisiteBlocker(report)) {
          _startupRetainedOperationEvidence = snapshot;
        } else if (report.state == OnboardingEnvironmentState.ready) {
          unawaited(_reconcileHistoricalCompletion(report, snapshot));
        } else if (report.state !=
            OnboardingEnvironmentState.maintenanceInProgress) {
          return _journeyForReconstructedInterruption(
            snapshot,
            report: report,
            reason: 'reconstructed interrupted operation evidence',
          );
        } else {
          _startupRetainedOperationEvidence = snapshot;
        }
      } else if (snapshot.status == OnboardingOperationStatus.failed) {
        if (report == null || _reportHasExternalPrerequisiteBlocker(report)) {
          _startupRetainedOperationEvidence = snapshot;
        } else {
          return _bindReconstructedOperation(
            snapshot,
            report: report,
            reason: 'reconstructed a failed durable operation',
          );
        }
      } else if (snapshot.status == OnboardingOperationStatus.running) {
        return _bindReconstructedOperation(
          snapshot,
          report: report,
          reason: 'reconstructed current-process operation evidence',
        );
      }
    }
    if (report == null) {
      return OnboardingCheckingPrerequisites(
        occurrence: _newOccurrence(),
        transitionReason: 'awaiting coherent environment evidence',
      );
    }
    return _journeyFromEnvironment(
      report,
      reason: 'reconstructed from coherent environment evidence',
    );
  }

  void _ingestEnvironmentReport(OnboardingEnvironmentReport report) {
    _latestReport = report;
    _startupReportSettled = true;

    if (_activeCommandToken != null) {
      _closeStartupAdoptionIfSettled();
      return;
    }

    final currentBinding = _operationBinding;
    if (_reportHasExternalPrerequisiteBlocker(report) &&
        (currentBinding == null ||
            _bindingCanYieldToPrerequisites(currentBinding))) {
      _publish(
        _journeyFromEnvironment(
          report,
          reason: 'current prerequisites outrank retained operation evidence',
        ),
      );
      _closeStartupAdoptionIfSettled();
      return;
    }

    // Aggregate maintenance evidence describes unrelated-observer safety, not
    // a new user-visible Journey semantic. Cold reconstruction maps it to
    // checking; once a semantic Episode exists, maintenance alone retains it.
    if (report.state == OnboardingEnvironmentState.maintenanceInProgress) {
      _closeStartupAdoptionIfSettled();
      return;
    }

    final startupEvidence = _startupRetainedOperationEvidence;
    if (startupEvidence != null) {
      _startupRetainedOperationEvidence = null;
      _publishRetainedStartupEvidence(startupEvidence, report);
      _closeStartupAdoptionIfSettled();
      return;
    }

    final binding = _operationBinding;
    if (binding != null) {
      if (_bindingCanYieldToPrerequisites(binding)) {
        _publishRetainedBinding(binding, report);
      }
      _closeStartupAdoptionIfSettled();
      return;
    }

    final unboundFailure = _retainedUnboundFailure;
    if (unboundFailure != null) {
      _publishUnboundFailure(
        unboundFailure,
        report: report,
        reason: 'prerequisites permit the retained command failure',
      );
      _closeStartupAdoptionIfSettled();
      return;
    }

    _publish(
      _journeyFromEnvironment(
        report,
        reason: 'accepted coherent environment evidence',
      ),
    );
    _closeStartupAdoptionIfSettled();
    if (!_startupAdoptionOpen) {
      _maybeTriggerAutomaticRecovery(report);
    }
  }

  void _ingestOperationEvidence(OnboardingOperationSnapshot snapshot) {
    _startupSnapshotSettled = true;

    // begin()/resume() persist and synchronously publish before returning. The
    // command binds that exact durable result itself; an unbound callback must
    // never invent an operation-backed Journey occurrence.
    if (_activeCommandToken != null && _operationBinding == null) {
      _closeStartupAdoptionIfSettled();
      return;
    }

    final binding = _operationBinding;
    if (binding == null) {
      if (_startupAdoptionOpen) {
        _adoptUnboundStartupEvidence(snapshot);
      }
      // Unbound evidence is adoptable only during the one bounded startup
      // reconciliation window. After it closes, replayed/delayed snapshots
      // are durable history and cannot create a new Journey occurrence.
      final startupJustClosed = _closeStartupAdoptionIfSettled();
      final report = _latestReport;
      if (startupJustClosed &&
          _operationBinding == null &&
          _startupRetainedOperationEvidence == null &&
          _retainedUnboundFailure == null &&
          report != null) {
        _maybeTriggerAutomaticRecovery(report);
      }
      return;
    }

    _closeStartupAdoptionIfSettled();
    if (!_acceptsOperationEvidence(binding, snapshot)) {
      return;
    }
    binding
      ..snapshot = snapshot
      ..fingerprint = _operationFingerprint(snapshot);
    _publishJourneyForAcceptedOperation(
      binding,
      reason: 'accepted current operation evidence revision',
    );
  }

  bool _closeStartupAdoptionIfSettled() {
    if (!_startupAdoptionOpen ||
        !_startupReportSettled ||
        !_startupSnapshotSettled) {
      return false;
    }
    _startupAdoptionOpen = false;
    return true;
  }

  void _adoptUnboundStartupEvidence(OnboardingOperationSnapshot snapshot) {
    if (!_hasBindableOperationIdentity(snapshot)) {
      return;
    }
    final report = _latestReport;
    if (snapshot.status == OnboardingOperationStatus.failed ||
        snapshot.status == OnboardingOperationStatus.interrupted) {
      if (report == null || _reportHasExternalPrerequisiteBlocker(report)) {
        _startupRetainedOperationEvidence = snapshot;
        if (report != null) {
          _publish(
            _journeyFromEnvironment(
              report,
              reason:
                  'startup prerequisite evidence outranks retained operation evidence',
            ),
          );
        }
        return;
      }
      _publishRetainedStartupEvidence(snapshot, report);
      return;
    }
    if (snapshot.status == OnboardingOperationStatus.running) {
      _publish(
        _bindReconstructedOperation(
          snapshot,
          report: report,
          reason: 'accepted startup current-process operation evidence',
        ),
      );
    }
  }

  void _publishRetainedStartupEvidence(
    OnboardingOperationSnapshot snapshot,
    OnboardingEnvironmentReport report,
  ) {
    if (snapshot.status == OnboardingOperationStatus.failed) {
      _publish(
        _bindReconstructedOperation(
          snapshot,
          report: report,
          reason: 'prerequisites permit retained startup failure evidence',
        ),
      );
      return;
    }
    if (snapshot.status != OnboardingOperationStatus.interrupted) {
      return;
    }
    if (report.state == OnboardingEnvironmentState.ready) {
      _publish(
        _journeyFromEnvironment(
          report,
          reason: 'durable readiness supersedes historical interruption',
        ),
      );
      unawaited(_reconcileHistoricalCompletion(report, snapshot));
      return;
    }
    if (_reportAllowsInterruptedContinuation(report, snapshot)) {
      _publish(
        _journeyForReconstructedInterruption(
          snapshot,
          report: report,
          reason: 'prerequisites permit retained interruption evidence',
        ),
      );
      return;
    }
    final assessment = onboardingReconciliationEvidenceFrom(report, snapshot);
    if (snapshot.kind == OnboardingOperationKind.automaticRecovery ||
        assessment.state == OnboardingDurableReconciliationState.inconsistent) {
      _publish(
        _journeyForReconstructedInterruption(
          snapshot,
          report: report,
          reason: 'retained interruption cannot resume safely',
        ),
      );
      return;
    }
    _startupRetainedOperationEvidence = snapshot;
    _publish(
      _journeyFromEnvironment(
        report,
        reason: 'current environment still blocks interrupted setup',
      ),
    );
  }

  void _publishRetainedBinding(
    _OnboardingOperationBinding binding,
    OnboardingEnvironmentReport report,
  ) {
    if (binding.snapshot.status == OnboardingOperationStatus.interrupted &&
        report.state == OnboardingEnvironmentState.ready) {
      _operationBinding = null;
      _publish(
        _journeyFromEnvironment(
          report,
          reason: 'durable readiness supersedes retained interruption',
        ),
      );
      unawaited(_reconcileHistoricalCompletion(report, binding.snapshot));
      return;
    }
    if (binding.snapshot.status == OnboardingOperationStatus.interrupted &&
        !_reportAllowsInterruptedContinuation(report, binding.snapshot)) {
      _publish(
        _journeyFromEnvironment(
          report,
          reason: 'current environment blocks interrupted setup',
        ),
      );
      return;
    }
    if (state.operation?.operationId != binding.operationId) {
      binding.occurrence = _newOccurrence();
    }
    _publish(
      _journeyForOperation(
        binding,
        evidence: _prerequisiteEvidence(report),
        reason: 'fresh prerequisites permit retained operation evidence',
      ),
    );
  }

  bool _bindingCanYieldToPrerequisites(_OnboardingOperationBinding binding) {
    return binding.snapshot.status == OnboardingOperationStatus.failed ||
        binding.snapshot.status == OnboardingOperationStatus.interrupted;
  }

  bool _hasBindableOperationIdentity(OnboardingOperationSnapshot snapshot) {
    return snapshot.operationId != null &&
        snapshot.kind != null &&
        snapshot.processSessionId != null &&
        snapshot.currentStage != null;
  }

  OnboardingJourneyState _bindReconstructedOperation(
    OnboardingOperationSnapshot snapshot, {
    required OnboardingEnvironmentReport? report,
    required String reason,
  }) {
    final occurrence = _newOccurrence();
    final binding = _OnboardingOperationBinding(
      occurrence: occurrence,
      operationId: snapshot.operationId!,
      kind: snapshot.kind!,
      processSessionId: snapshot.processSessionId!,
      snapshot: snapshot,
      fingerprint: _operationFingerprint(snapshot),
    );
    _operationBinding = binding;
    return _journeyForOperation(
      binding,
      evidence: report == null ? null : _prerequisiteEvidence(report),
      reason: reason,
    );
  }

  OnboardingJourneyState _journeyForReconstructedInterruption(
    OnboardingOperationSnapshot snapshot, {
    required OnboardingEnvironmentReport report,
    required String reason,
  }) {
    if (snapshot.kind == OnboardingOperationKind.automaticRecovery) {
      return _bindReconstructedFailure(
        snapshot,
        report: report,
        summary:
            'Automatic recovery was interrupted and must restart from a new attempt.',
        reason: reason,
      );
    }
    final assessment = onboardingReconciliationEvidenceFrom(report, snapshot);
    return switch (assessment.state) {
      OnboardingDurableReconciliationState.resumable =>
        _bindReconstructedOperation(snapshot, report: report, reason: reason),
      OnboardingDurableReconciliationState.inconsistent =>
        _bindReconstructedFailure(
          snapshot,
          report: report,
          summary:
              assessment.failureSummary ??
              'The interrupted setup operation cannot resume safely.',
          reason: reason,
        ),
      OnboardingDurableReconciliationState.unavailable ||
      OnboardingDurableReconciliationState
          .completed => _bindReconstructedFailure(
        snapshot,
        report: report,
        summary:
            'The interrupted setup operation has no verified resume boundary.',
        reason: reason,
      ),
    };
  }

  OnboardingJourneyState _bindReconstructedFailure(
    OnboardingOperationSnapshot snapshot, {
    required OnboardingEnvironmentReport? report,
    required String summary,
    required String reason,
  }) {
    final occurrence = _newOccurrence();
    final binding = _OnboardingOperationBinding(
      occurrence: occurrence,
      operationId: snapshot.operationId!,
      kind: snapshot.kind!,
      processSessionId: snapshot.processSessionId!,
      snapshot: snapshot,
      fingerprint: _operationFingerprint(snapshot),
    );
    _operationBinding = binding;
    return OnboardingOperationFailed(
      occurrence: occurrence,
      operation: _projectionFrom(
        snapshot,
        phase: OnboardingJourneyOperationPhase.failed,
        failure: OnboardingJourneyOperationFailure(
          category: OnboardingOperationFailureCategory.durableStateInconsistent,
          summary: summary,
        ),
      ),
      summary: summary,
      compatibilityStatus: OnboardingStatus.preparationFailed,
      failureAction: _failureActionForOperation(snapshot),
      evidence: report == null ? null : _prerequisiteEvidence(report),
      transitionReason: reason,
    );
  }

  void _bindNewOperation(
    OnboardingOperationSnapshot snapshot, {
    required String reason,
  }) {
    final next = _bindReconstructedOperation(
      snapshot,
      report: _latestReport,
      reason: reason,
    );
    _publish(next);
  }

  bool _acceptsOperationEvidence(
    _OnboardingOperationBinding binding,
    OnboardingOperationSnapshot candidate,
  ) {
    if (state.occurrence != binding.occurrence ||
        state.operation?.operationId != binding.operationId ||
        candidate.operationId != binding.operationId ||
        candidate.kind != binding.kind ||
        candidate.processSessionId != binding.processSessionId) {
      return false;
    }
    final previous = binding.snapshot;
    if (candidate.progressRevision < previous.progressRevision) {
      return false;
    }
    if (candidate.progressRevision == previous.progressRevision) {
      final fingerprint = _operationFingerprint(candidate);
      if (fingerprint == binding.fingerprint ||
          !_isPermittedEqualRevisionStatusTransition(previous, candidate)) {
        return false;
      }
    }
    if (!_legalStatusTransition(previous.status, candidate.status)) {
      return false;
    }
    if (!_isValidStageAndSubstage(
      binding.kind,
      candidate.currentStage,
      candidate.currentSubstage,
    )) {
      return false;
    }
    if (_stageRank(binding.kind, candidate.currentStage) <
        _stageRank(binding.kind, previous.currentStage)) {
      return false;
    }
    if (candidate.currentStage == previous.currentStage &&
        _substageRank(candidate.currentSubstage) <
            _substageRank(previous.currentSubstage)) {
      return false;
    }
    final progress = candidate.progress;
    if (progress != null &&
        (progress.completedWorkUnits < 0 ||
            progress.totalWorkUnits < 0 ||
            progress.completedWorkUnits > progress.totalWorkUnits)) {
      return false;
    }
    return true;
  }

  bool _isPermittedEqualRevisionStatusTransition(
    OnboardingOperationSnapshot previous,
    OnboardingOperationSnapshot candidate,
  ) {
    return candidate.status != previous.status &&
        candidate.currentStage == previous.currentStage &&
        candidate.currentSubstage == previous.currentSubstage &&
        _sameStages(candidate.completedStages, previous.completedStages) &&
        candidate.progress == previous.progress &&
        candidate.sourceAnomalyCounts == previous.sourceAnomalyCounts;
  }

  bool _sameStages(
    List<OnboardingOperationStage> first,
    List<OnboardingOperationStage> second,
  ) {
    if (first.length != second.length) {
      return false;
    }
    for (var index = 0; index < first.length; index += 1) {
      if (first[index] != second[index]) {
        return false;
      }
    }
    return true;
  }

  bool _legalStatusTransition(
    OnboardingOperationStatus previous,
    OnboardingOperationStatus next,
  ) {
    return switch (previous) {
      OnboardingOperationStatus.running =>
        next == OnboardingOperationStatus.running ||
            next == OnboardingOperationStatus.interrupted ||
            next == OnboardingOperationStatus.failed ||
            next == OnboardingOperationStatus.completed,
      OnboardingOperationStatus.interrupted =>
        next == OnboardingOperationStatus.interrupted ||
            next == OnboardingOperationStatus.failed ||
            next == OnboardingOperationStatus.completed,
      OnboardingOperationStatus.failed =>
        next == OnboardingOperationStatus.failed,
      OnboardingOperationStatus.completed =>
        next == OnboardingOperationStatus.completed,
      OnboardingOperationStatus.idle => false,
    };
  }

  bool _reportHasExternalPrerequisiteBlocker(
    OnboardingEnvironmentReport report,
  ) {
    return report.state == OnboardingEnvironmentState.permissionBlocked ||
        report.blockerKind == OnboardingBlockerKind.messagesDatabaseMissing ||
        report.blockerKind == OnboardingBlockerKind.fullDiskAccessMissing ||
        report.blockerKind == OnboardingBlockerKind.addressBookUnavailable ||
        (report.state == OnboardingEnvironmentState.sourceSparseOrUnsynced &&
            !_localHistoryAccepted);
  }

  bool _latestReportAllowsInitialImport({required String blockedReason}) {
    return _latestReportAllowsCommand(
      blockedReason: blockedReason,
      predicate: _reportAllowsInitialImport,
    );
  }

  bool _latestReportAllowsReimport({required String blockedReason}) {
    return _latestReportAllowsCommand(
      blockedReason: blockedReason,
      predicate: _reportAllowsReimport,
    );
  }

  bool _latestReportAllowsInterruptedContinuation(
    OnboardingOperationSnapshot snapshot, {
    required String blockedReason,
  }) {
    return _latestReportAllowsCommand(
      blockedReason: blockedReason,
      predicate: (report) =>
          _reportAllowsInterruptedContinuation(report, snapshot),
    );
  }

  bool _latestReportAllowsAutomaticRecovery({required String blockedReason}) {
    return _latestReportAllowsCommand(
      blockedReason: blockedReason,
      predicate: _reportAllowsAutomaticRecovery,
    );
  }

  bool _latestReportAllowsCommand({
    required String blockedReason,
    required bool Function(OnboardingEnvironmentReport report) predicate,
  }) {
    final report = _latestReport;
    if (report == null) {
      refreshEnvironment();
      return false;
    }
    return _reportAllowsCommand(
      report,
      blockedReason: blockedReason,
      predicate: predicate,
    );
  }

  bool _reportAllowsCommand(
    OnboardingEnvironmentReport report, {
    required String blockedReason,
    required bool Function(OnboardingEnvironmentReport report) predicate,
  }) {
    if (predicate(report)) {
      return true;
    }
    _publish(_journeyFromEnvironment(report, reason: blockedReason));
    return false;
  }

  bool _reportAllowsInitialImport(OnboardingEnvironmentReport report) {
    if (_reportHasExternalPrerequisiteBlocker(report) ||
        report.shouldResetAppDatabasesBeforeImport) {
      return false;
    }
    return report.state == OnboardingEnvironmentState.readyToImport ||
        (report.state == OnboardingEnvironmentState.sourceSparseOrUnsynced &&
            _localHistoryAccepted);
  }

  bool _reportAllowsReimport(OnboardingEnvironmentReport report) {
    return !_reportHasExternalPrerequisiteBlocker(report) &&
        !report.shouldResetAppDatabasesBeforeImport &&
        report.state == OnboardingEnvironmentState.ready;
  }

  bool _reportAllowsAutomaticRecovery(OnboardingEnvironmentReport report) {
    return !_reportHasExternalPrerequisiteBlocker(report) &&
        report.shouldResetAppDatabasesBeforeImport;
  }

  _RetainedRetryEvidence _takeRetainedRetryEvidence() {
    if (state is! OnboardingOperationFailed) {
      return const _RetainedRetryEvidence();
    }
    final retained = _RetainedRetryEvidence(
      binding: _operationBinding,
      unboundFailure: _retainedUnboundFailure,
    );
    _operationBinding = null;
    _retainedUnboundFailure = null;
    return retained;
  }

  void _restoreRetainedRetryEvidence(_RetainedRetryEvidence retained) {
    _operationBinding ??= retained.binding;
    _retainedUnboundFailure ??= retained.unboundFailure;
  }

  OnboardingJourneyFailureAction _failureActionForOperation(
    OnboardingOperationSnapshot snapshot,
  ) {
    final failure = snapshot.failure;
    if (failure != null &&
        failure.recoveryDisposition !=
            OnboardingOperationRecoveryDisposition.retryFromSafeBoundary) {
      return OnboardingJourneyFailureAction.none;
    }
    return switch (snapshot.kind!) {
      OnboardingOperationKind.initialImport =>
        OnboardingJourneyFailureAction.retryInitialImport,
      OnboardingOperationKind.reimport =>
        OnboardingJourneyFailureAction.retryReimport,
      OnboardingOperationKind.automaticRecovery =>
        OnboardingJourneyFailureAction.retryAutomaticRecovery,
    };
  }

  void _publishUnboundFailure(
    _OnboardingUnboundFailure failure, {
    required OnboardingEnvironmentReport? report,
    required String reason,
  }) {
    _publish(
      OnboardingOperationFailed(
        occurrence: _newOccurrence(),
        summary: failure.summary,
        compatibilityStatus: OnboardingStatus.preparationFailed,
        failureAction: failure.action,
        evidence: report == null ? null : _prerequisiteEvidence(report),
        transitionReason: reason,
      ),
    );
  }

  OnboardingJourneyState _journeyFromEnvironment(
    OnboardingEnvironmentReport report, {
    required String reason,
  }) {
    final evidence = _prerequisiteEvidence(report);
    if (report.state == OnboardingEnvironmentState.permissionBlocked ||
        report.blockerKind == OnboardingBlockerKind.messagesDatabaseMissing ||
        report.blockerKind == OnboardingBlockerKind.fullDiskAccessMissing) {
      return OnboardingNeedsMessagesAccess(
        occurrence: _newOccurrence(),
        evidence: evidence,
        transitionReason: reason,
      );
    }
    if (report.blockerKind == OnboardingBlockerKind.addressBookUnavailable) {
      return OnboardingNeedsContactsAccess(
        occurrence: _newOccurrence(),
        evidence: evidence,
        transitionReason: reason,
      );
    }
    if (report.state == OnboardingEnvironmentState.sourceSparseOrUnsynced &&
        !_localHistoryAccepted) {
      return OnboardingNeedsLocalHistoryConfirmation(
        occurrence: _newOccurrence(),
        evidence: evidence,
        transitionReason: reason,
      );
    }
    if (report.shouldResetAppDatabasesBeforeImport ||
        report.state == OnboardingEnvironmentState.importFailed ||
        report.state == OnboardingEnvironmentState.graphProjectionFailed) {
      return OnboardingOperationFailed(
        occurrence: _newOccurrence(),
        summary:
            report.resetAppDatabasesReason ??
            report.importFailureMessage ??
            report.graphProjectionFailureMessage ??
            'The previous onboarding operation did not finish.',
        compatibilityStatus: OnboardingStatus.awaitingUserAction,
        failureAction: OnboardingJourneyFailureAction.recheckEnvironment,
        evidence: evidence,
        transitionReason: reason,
      );
    }
    if (report.state == OnboardingEnvironmentState.readyToImport ||
        (report.state == OnboardingEnvironmentState.sourceSparseOrUnsynced &&
            _localHistoryAccepted)) {
      return OnboardingReadyToImport(
        occurrence: _newOccurrence(),
        evidence: evidence,
        localHistoryAccepted: _localHistoryAccepted,
        transitionReason: reason,
      );
    }
    if (report.state == OnboardingEnvironmentState.ready) {
      return OnboardingNormalApplication(
        occurrence: _newOccurrence(),
        evidence: evidence,
        transitionReason: reason,
      );
    }
    return OnboardingCheckingPrerequisites(
      occurrence: _newOccurrence(),
      transitionReason: reason,
    );
  }

  OnboardingJourneyState _journeyForOperation(
    _OnboardingOperationBinding binding, {
    OnboardingPrerequisiteEvidence? evidence,
    required String reason,
  }) {
    final snapshot = binding.snapshot;
    final projection = _projectionFrom(snapshot);
    if (snapshot.status == OnboardingOperationStatus.interrupted) {
      return OnboardingOperationInterrupted(
        occurrence: binding.occurrence,
        operation: projection,
        evidence: evidence,
        transitionReason: reason,
      );
    }
    if (snapshot.status == OnboardingOperationStatus.failed) {
      return OnboardingOperationFailed(
        occurrence: binding.occurrence,
        operation: projection,
        summary:
            snapshot.failure?.summary ??
            'The current onboarding operation did not finish.',
        compatibilityStatus: OnboardingStatus.preparationFailed,
        failureAction: _failureActionForOperation(snapshot),
        evidence: evidence,
        transitionReason: reason,
      );
    }
    if (snapshot.status == OnboardingOperationStatus.completed) {
      return switch (snapshot.kind!) {
        OnboardingOperationKind.initialImport => OnboardingReadyToStart(
          occurrence: binding.occurrence,
          operation: projection,
          transitionReason: reason,
        ),
        OnboardingOperationKind.reimport => OnboardingReimportReady(
          occurrence: binding.occurrence,
          operation: projection,
          transitionReason: reason,
        ),
        OnboardingOperationKind.automaticRecovery =>
          OnboardingRecoveringDerivedData(
            occurrence: binding.occurrence,
            operation: projection,
            transitionReason: reason,
          ),
      };
    }
    return switch (snapshot.kind!) {
      OnboardingOperationKind.automaticRecovery =>
        OnboardingRecoveringDerivedData(
          occurrence: binding.occurrence,
          operation: projection,
          transitionReason: reason,
        ),
      OnboardingOperationKind.reimport => OnboardingReimporting(
        occurrence: binding.occurrence,
        operation: projection,
        status:
            snapshot.currentStage == OnboardingOperationStage.messageDataBuild
            ? OnboardingStatus.reimportBuildingGraph
            : OnboardingStatus.reimporting,
        transitionReason: reason,
      ),
      OnboardingOperationKind.initialImport => switch (snapshot.currentStage!) {
        OnboardingOperationStage.environmentPreparation =>
          OnboardingPreparingImport(
            occurrence: binding.occurrence,
            operation: projection,
            transitionReason: reason,
          ),
        OnboardingOperationStage.messageDataBuild =>
          OnboardingBuildingLocalData(
            occurrence: binding.occurrence,
            operation: projection,
            transitionReason: reason,
          ),
        OnboardingOperationStage.durableReadinessVerification =>
          OnboardingVerifyingDurableReadiness(
            occurrence: binding.occurrence,
            operation: projection,
            transitionReason: reason,
          ),
        OnboardingOperationStage.automaticRecoveryReset =>
          OnboardingPreparingImport(
            occurrence: binding.occurrence,
            operation: projection,
            transitionReason: reason,
          ),
      },
    };
  }

  OnboardingJourneyOperationProjection _projectionFrom(
    OnboardingOperationSnapshot snapshot, {
    OnboardingJourneyOperationPhase? phase,
    OnboardingJourneyOperationFailure? failure,
  }) {
    final rawProgress = snapshot.progress;
    final progress = rawProgress != null && rawProgress.totalWorkUnits > 0
        ? OnboardingJourneyOperationProgress(
            completedWorkUnits: rawProgress.completedWorkUnits,
            totalWorkUnits: rawProgress.totalWorkUnits,
          )
        : null;
    final resolvedPhase =
        phase ??
        switch (snapshot.status) {
          OnboardingOperationStatus.running =>
            OnboardingJourneyOperationPhase.active,
          OnboardingOperationStatus.interrupted =>
            OnboardingJourneyOperationPhase.interrupted,
          OnboardingOperationStatus.failed =>
            OnboardingJourneyOperationPhase.failed,
          OnboardingOperationStatus.completed =>
            OnboardingJourneyOperationPhase.verified,
          OnboardingOperationStatus.idle => throw StateError(
            'Idle evidence cannot become a Journey operation projection.',
          ),
        };
    final rawFailure = snapshot.failure;
    final resolvedFailure =
        failure ??
        (rawFailure == null
            ? null
            : OnboardingJourneyOperationFailure(
                category: rawFailure.category,
                summary: rawFailure.summary,
              ));
    final actions = switch (resolvedPhase) {
      OnboardingJourneyOperationPhase.active =>
        const <OnboardingJourneyOperationAction>{},
      OnboardingJourneyOperationPhase.interrupted =>
        snapshot.kind == OnboardingOperationKind.automaticRecovery
            ? const <OnboardingJourneyOperationAction>{}
            : const <OnboardingJourneyOperationAction>{
                OnboardingJourneyOperationAction.continueSetup,
              },
      OnboardingJourneyOperationPhase.failed =>
        rawFailure == null ||
                rawFailure.recoveryDisposition ==
                    OnboardingOperationRecoveryDisposition.retryFromSafeBoundary
            ? const <OnboardingJourneyOperationAction>{
                OnboardingJourneyOperationAction.retry,
              }
            : const <OnboardingJourneyOperationAction>{},
      OnboardingJourneyOperationPhase.verified =>
        snapshot.kind == OnboardingOperationKind.automaticRecovery
            ? const <OnboardingJourneyOperationAction>{}
            : const <OnboardingJourneyOperationAction>{
                OnboardingJourneyOperationAction.acknowledgeCompletion,
              },
    };
    return OnboardingJourneyOperationProjection(
      operationId: snapshot.operationId!,
      kind: snapshot.kind!,
      phase: resolvedPhase,
      stage: snapshot.currentStage!,
      substage: snapshot.currentSubstage,
      progressRevision: snapshot.progressRevision,
      progress: progress,
      failure: resolvedFailure,
      availableActions: actions,
    );
  }

  void _publishJourneyForAcceptedOperation(
    _OnboardingOperationBinding binding, {
    required String reason,
  }) {
    final nextEpisode = _episodeFor(binding.snapshot);
    if (state.episode != nextEpisode) {
      binding.occurrence = _newOccurrence();
    }
    _publish(
      _journeyForOperation(
        binding,
        evidence: _latestReport == null
            ? null
            : _prerequisiteEvidence(_latestReport!),
        reason: reason,
      ),
    );
  }

  OnboardingJourneyEpisode _episodeFor(OnboardingOperationSnapshot snapshot) {
    if (snapshot.status == OnboardingOperationStatus.interrupted) {
      return OnboardingJourneyEpisode.operationInterrupted;
    }
    if (snapshot.status == OnboardingOperationStatus.failed) {
      return OnboardingJourneyEpisode.operationFailed;
    }
    if (snapshot.status == OnboardingOperationStatus.completed) {
      return snapshot.kind == OnboardingOperationKind.reimport
          ? OnboardingJourneyEpisode.reimportReady
          : snapshot.kind == OnboardingOperationKind.initialImport
          ? OnboardingJourneyEpisode.readyToStart
          : OnboardingJourneyEpisode.recoveringDerivedData;
    }
    if (snapshot.kind == OnboardingOperationKind.automaticRecovery) {
      return OnboardingJourneyEpisode.recoveringDerivedData;
    }
    if (snapshot.kind == OnboardingOperationKind.reimport) {
      return OnboardingJourneyEpisode.reimporting;
    }
    return switch (snapshot.currentStage!) {
      OnboardingOperationStage.environmentPreparation =>
        OnboardingJourneyEpisode.preparingImport,
      OnboardingOperationStage.messageDataBuild =>
        OnboardingJourneyEpisode.buildingLocalData,
      OnboardingOperationStage.durableReadinessVerification =>
        OnboardingJourneyEpisode.verifyingDurableReadiness,
      OnboardingOperationStage.automaticRecoveryReset =>
        OnboardingJourneyEpisode.preparingImport,
    };
  }

  /// Starts fresh derived-store construction for a proven Virgin installation.
  Future<void> startVirginImportAndGraphBuild({
    required OnboardingJourneyActionContext actionContext,
  }) async {
    if (state is! OnboardingReadyToImport || !_actionIsCurrent(actionContext)) {
      return;
    }
    await _runNewInitialImport(actionContext);
  }

  Future<void> _runNewInitialImport(
    OnboardingJourneyActionContext context,
  ) async {
    final token = _claimCommand(context);
    if (token == null) {
      return;
    }
    final retainedRetryEvidence = _takeRetainedRetryEvidence();
    var beginAttempted = false;
    var replacementFailurePublished = false;
    try {
      if (!_commandAndActionAreCurrent(token, context)) {
        return;
      }
      if (!ref.read(onboardingFullDiskAccessProvider)) {
        refreshEnvironment();
        return;
      }
      if (!_latestReportAllowsInitialImport(
        blockedReason: 'prerequisites changed before first import admission',
      )) {
        return;
      }
      await ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .runWithCapability<void>(
            operation: ArchiveMutationOperation.onboardingImport,
            ownerLabel: 'onboarding-first-run',
            action: (capability) async {
              final controller = await ref.read(
                onboardingOperationControllerProvider.future,
              );
              if (!_commandAndActionAreCurrent(token, context)) {
                return;
              }
              final admittedReport =
                  await readAdmittedOnboardingEnvironmentEvidence(
                    ref,
                    capability: capability,
                    expectedOperation:
                        ArchiveMutationOperation.onboardingImport,
                  );
              capability.requireOperation(
                ArchiveMutationOperation.onboardingImport,
              );
              if (!_commandAndActionAreCurrent(token, context) ||
                  !_reportAllowsCommand(
                    admittedReport,
                    blockedReason:
                        'prerequisites changed before first import began',
                    predicate: _reportAllowsInitialImport,
                  )) {
                return;
              }
              beginAttempted = true;
              final operationId = await controller.begin(
                kind: OnboardingOperationKind.initialImport,
                initialStage: OnboardingOperationStage.messageDataBuild,
              );
              _bindNewOperation(
                controller.current,
                reason:
                    'durable initial-import identity bound before execution',
              );
              await VirginOnboardingImportExecutor(
                operationController: controller,
              ).run(
                operationId: operationId,
                buildMessageData: (progress) => _runConversationGraphBuild(
                  owner: 'onboarding-first-run',
                  progress: progress,
                ),
              );
              await _verifyAndComplete(
                controller: controller,
                operationId: operationId,
              );
            },
          );
    } catch (error, stackTrace) {
      replacementFailurePublished = true;
      await _publishFailureBeforeSideEffects(
        error: error,
        stackTrace: stackTrace,
        fallbackCategory: OnboardingOperationFailureCategory.unexpected,
        unboundFailureAction: OnboardingJourneyFailureAction.retryInitialImport,
        logMessage: 'Fresh onboarding operation failed',
      );
    } finally {
      if (!beginAttempted && !replacementFailurePublished) {
        _restoreRetainedRetryEvidence(retainedRetryEvidence);
      }
      _releaseCommand(token);
    }
  }

  Future<void> startReimport({
    required OnboardingJourneyActionContext actionContext,
  }) async {
    if (state is! OnboardingNormalApplication ||
        !_actionIsCurrent(actionContext)) {
      return;
    }
    await _runNewReimport(actionContext);
  }

  Future<void> _runNewReimport(OnboardingJourneyActionContext context) async {
    final token = _claimCommand(context);
    if (token == null) {
      return;
    }
    final retainedRetryEvidence = _takeRetainedRetryEvidence();
    var beginAttempted = false;
    var replacementFailurePublished = false;
    try {
      if (!_commandAndActionAreCurrent(token, context) ||
          !_latestReportAllowsReimport(
            blockedReason: 'prerequisites changed before reimport admission',
          )) {
        return;
      }
      await ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .runWithCapability<void>(
            operation: ArchiveMutationOperation.onboardingImport,
            ownerLabel: 'settings-reimport',
            action: (capability) async {
              final controller = await ref.read(
                onboardingOperationControllerProvider.future,
              );
              if (!_commandAndActionAreCurrent(token, context)) {
                return;
              }
              final admittedReport =
                  await readAdmittedOnboardingEnvironmentEvidence(
                    ref,
                    capability: capability,
                    expectedOperation:
                        ArchiveMutationOperation.onboardingImport,
                  );
              capability.requireOperation(
                ArchiveMutationOperation.onboardingImport,
              );
              if (!_commandAndActionAreCurrent(token, context) ||
                  !_reportAllowsCommand(
                    admittedReport,
                    blockedReason:
                        'prerequisites changed before reimport began',
                    predicate: _reportAllowsReimport,
                  )) {
                return;
              }
              beginAttempted = true;
              final operationId = await controller.begin(
                kind: OnboardingOperationKind.reimport,
                initialStage: OnboardingOperationStage.environmentPreparation,
              );
              _bindNewOperation(
                controller.current,
                reason: 'durable reimport identity bound before execution',
              );
              await _runReimportWork(controller, operationId);
              await _verifyAndComplete(
                controller: controller,
                operationId: operationId,
              );
            },
          );
    } catch (error, stackTrace) {
      replacementFailurePublished = true;
      await _publishFailureBeforeSideEffects(
        error: error,
        stackTrace: stackTrace,
        fallbackCategory:
            OnboardingOperationFailureCategory.environmentPreparation,
        unboundFailureAction: OnboardingJourneyFailureAction.retryReimport,
        logMessage: 'Settings reimport operation failed',
      );
    } finally {
      if (!beginAttempted && !replacementFailurePublished) {
        _restoreRetainedRetryEvidence(retainedRetryEvidence);
      }
      _releaseCommand(token);
    }
  }

  Future<void> retryFailedOperation({
    required OnboardingJourneyActionContext actionContext,
  }) async {
    final failed = state;
    if (failed is! OnboardingOperationFailed ||
        !_actionIsCurrent(actionContext)) {
      return;
    }
    final operation = failed.operation;
    if (failed.failureAction == OnboardingJourneyFailureAction.none ||
        (operation != null &&
            !operation.availableActions.contains(
              OnboardingJourneyOperationAction.retry,
            ))) {
      return;
    }
    final report = _latestReport;
    if (report != null && _reportHasExternalPrerequisiteBlocker(report)) {
      _ingestEnvironmentReport(report);
      return;
    }
    switch (failed.failureAction) {
      case OnboardingJourneyFailureAction.retryInitialImport:
        await _runNewInitialImport(actionContext);
      case OnboardingJourneyFailureAction.retryReimport:
        await _runNewReimport(actionContext);
      case OnboardingJourneyFailureAction.retryAutomaticRecovery:
        _automaticRecoverySuppressed = false;
        if (report == null) {
          refreshEnvironment();
        } else {
          await _runAutomaticRecovery(actionContext, report);
        }
      case OnboardingJourneyFailureAction.recheckEnvironment:
        _automaticRecoverySuppressed = false;
        refreshEnvironment();
      case OnboardingJourneyFailureAction.none:
        return;
    }
  }

  Future<void> continueInterruptedOperation({
    required OnboardingJourneyActionContext actionContext,
  }) async {
    final interrupted = state;
    final binding = _operationBinding;
    if (interrupted is! OnboardingOperationInterrupted ||
        binding == null ||
        !interrupted.operation.availableActions.contains(
          OnboardingJourneyOperationAction.continueSetup,
        ) ||
        !_actionIsCurrent(actionContext)) {
      return;
    }
    final token = _claimCommand(actionContext);
    if (token == null) {
      return;
    }
    try {
      if (!_commandRetainsBinding(token, actionContext, binding) ||
          !_latestReportAllowsInterruptedContinuation(
            binding.snapshot,
            blockedReason: 'current prerequisites block interrupted setup',
          )) {
        return;
      }
      await ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .runWithCapability<void>(
            operation: ArchiveMutationOperation.onboardingImport,
            ownerLabel: 'onboarding-explicit-continue',
            action: (capability) async {
              final controller = await ref.read(
                onboardingOperationControllerProvider.future,
              );
              if (!_commandRetainsBinding(token, actionContext, binding) ||
                  controller.current.operationId != binding.operationId ||
                  controller.current.processSessionId !=
                      binding.processSessionId ||
                  controller.current.status !=
                      OnboardingOperationStatus.interrupted) {
                return;
              }
              final admittedReport =
                  await readAdmittedOnboardingEnvironmentEvidence(
                    ref,
                    capability: capability,
                    expectedOperation:
                        ArchiveMutationOperation.onboardingImport,
                  );
              capability.requireOperation(
                ArchiveMutationOperation.onboardingImport,
              );
              if (!_commandRetainsBinding(token, actionContext, binding) ||
                  controller.current.operationId != binding.operationId ||
                  controller.current.processSessionId !=
                      binding.processSessionId ||
                  controller.current.status !=
                      OnboardingOperationStatus.interrupted ||
                  !_reportAllowsCommand(
                    admittedReport,
                    blockedReason:
                        'prerequisites changed before interrupted work resumed',
                    predicate: (report) => _reportAllowsInterruptedContinuation(
                      report,
                      controller.current,
                    ),
                  )) {
                return;
              }
              await controller.resume(operationId: binding.operationId);
              binding
                ..processSessionId = controller.current.processSessionId!
                ..snapshot = controller.current
                ..fingerprint = _operationFingerprint(controller.current);
              _publishJourneyForAcceptedOperation(
                binding,
                reason: 'human explicitly resumed the durable operation',
              );
              await _resumeOperationWork(controller, binding);
            },
          );
    } catch (error, stackTrace) {
      await _publishFailureBeforeSideEffects(
        error: error,
        stackTrace: stackTrace,
        fallbackCategory: OnboardingOperationFailureCategory.unexpected,
        unboundFailureAction: OnboardingJourneyFailureAction.none,
        logMessage: 'Interrupted onboarding continuation failed',
      );
    } finally {
      _releaseCommand(token);
    }
  }

  Future<void> _resumeOperationWork(
    OnboardingOperationSnapshotController controller,
    _OnboardingOperationBinding binding,
  ) async {
    final operationId = binding.operationId;
    final stage = controller.current.currentStage!;
    switch (binding.kind) {
      case OnboardingOperationKind.initialImport:
        if (stage != OnboardingOperationStage.durableReadinessVerification) {
          await VirginOnboardingImportExecutor(
            operationController: controller,
          ).run(
            operationId: operationId,
            buildMessageData: (progress) => _runConversationGraphBuild(
              owner: 'onboarding-explicit-continue',
              progress: progress,
            ),
          );
        }
        await _verifyAndComplete(
          controller: controller,
          operationId: operationId,
        );
      case OnboardingOperationKind.reimport:
        if (stage == OnboardingOperationStage.environmentPreparation) {
          await controller.runStage<void>(
            operationId: operationId,
            stage: OnboardingOperationStage.environmentPreparation,
            action: (progress) async {
              await progress.observe(
                substage: OnboardingOperationSubstage.resettingDerivedData,
              );
              await ref
                  .read(messageDataResetServiceProvider)
                  .resetDerivedData();
            },
          );
        }
        if (controller.current.currentStage !=
            OnboardingOperationStage.durableReadinessVerification) {
          await controller.runStage<void>(
            operationId: operationId,
            stage: OnboardingOperationStage.messageDataBuild,
            action: (progress) => _runConversationGraphBuild(
              owner: 'settings-reimport-explicit-continue',
              progress: progress,
            ),
          );
          await controller.enterStage(
            operationId: operationId,
            stage: OnboardingOperationStage.durableReadinessVerification,
          );
        }
        await _verifyAndComplete(
          controller: controller,
          operationId: operationId,
        );
      case OnboardingOperationKind.automaticRecovery:
        await controller.runStage<void>(
          operationId: operationId,
          stage: OnboardingOperationStage.automaticRecoveryReset,
          action: (progress) async {
            await progress.observe(
              substage: OnboardingOperationSubstage.resettingDerivedData,
            );
            await ref.read(messageDataResetServiceProvider).resetDerivedData();
          },
        );
        await controller.complete(
          operationId: operationId,
          proof: OnboardingDerivedResetCompletedProof(
            verifiedAtUtc: DateTime.now().toUtc(),
          ),
        );
        await controller.resetToIdle();
        _operationBinding = null;
        refreshEnvironment();
    }
  }

  Future<void> _runReimportWork(
    OnboardingOperationSnapshotController controller,
    OnboardingOperationId operationId,
  ) async {
    await controller.runStage<void>(
      operationId: operationId,
      stage: OnboardingOperationStage.environmentPreparation,
      action: (progress) async {
        await progress.observe(
          substage: OnboardingOperationSubstage.resettingDerivedData,
        );
        await ref.read(messageDataResetServiceProvider).resetDerivedData();
      },
    );
    await controller.runStage<void>(
      operationId: operationId,
      stage: OnboardingOperationStage.messageDataBuild,
      action: (progress) => _runConversationGraphBuild(
        owner: 'settings-reimport',
        progress: progress,
      ),
    );
    await controller.enterStage(
      operationId: operationId,
      stage: OnboardingOperationStage.durableReadinessVerification,
    );
  }

  Future<void> _verifyAndComplete({
    required OnboardingOperationSnapshotController controller,
    required OnboardingOperationId operationId,
  }) async {
    await controller.reportProgress(
      operationId: operationId,
      substage: OnboardingOperationSubstage.verifyingDurableReadiness,
      progress: null,
    );
    final proof = await ref
        .read(onboardingDurableCompletionVerifierProvider)
        .verifyInstallationReady();
    await controller.complete(operationId: operationId, proof: proof);
  }

  Future<void> _publishFailureBeforeSideEffects({
    required Object error,
    required StackTrace stackTrace,
    required OnboardingOperationFailureCategory fallbackCategory,
    required OnboardingJourneyFailureAction unboundFailureAction,
    required String logMessage,
  }) async {
    final binding = _operationBinding;
    final category = binding == null
        ? fallbackCategory
        : _failureCategoryForStage(binding.snapshot.currentStage);
    final summary = _boundedSummary(error);

    // This assignment is intentionally first. Every operation failure has a
    // valid Journey destination even when every durable diagnostic write fails.
    if (binding == null) {
      final failure = _OnboardingUnboundFailure(
        summary: summary,
        action: unboundFailureAction,
      );
      _retainedUnboundFailure = failure;
      _publishUnboundFailure(
        failure,
        report: _latestReport,
        reason: logMessage,
      );
    } else {
      binding.occurrence = _newOccurrence();
      final durableFailure = OnboardingOperationFailure(
        category: category,
        occurredAtUtc: DateTime.now().toUtc(),
        summary: summary,
        recoveryDisposition:
            OnboardingOperationRecoveryDisposition.retryFromSafeBoundary,
      );
      final projectionFailure = OnboardingJourneyOperationFailure(
        category: category,
        summary: summary,
      );
      final failedProjection = switch (binding.snapshot.status) {
        OnboardingOperationStatus.running ||
        OnboardingOperationStatus.interrupted => () {
          binding
            ..snapshot = binding.snapshot.fail(failure: durableFailure)
            ..fingerprint = _operationFingerprint(binding.snapshot);
          return _projectionFrom(binding.snapshot);
        }(),
        OnboardingOperationStatus.failed => _projectionFrom(binding.snapshot),
        OnboardingOperationStatus.completed => _projectionFrom(
          binding.snapshot,
          phase: OnboardingJourneyOperationPhase.failed,
          failure: projectionFailure,
        ),
        OnboardingOperationStatus.idle => throw StateError(
          'A bound onboarding operation cannot have idle evidence.',
        ),
      };
      if (binding.snapshot.status == OnboardingOperationStatus.completed) {
        _operationBinding = null;
        _retainedUnboundFailure = _OnboardingUnboundFailure(
          summary: summary,
          action: _failureActionForOperation(binding.snapshot),
        );
      }
      _publish(
        OnboardingOperationFailed(
          occurrence: binding.occurrence,
          operation: failedProjection,
          summary: summary,
          compatibilityStatus: OnboardingStatus.preparationFailed,
          failureAction: _failureActionForOperation(binding.snapshot),
          evidence: _latestReport == null
              ? null
              : _prerequisiteEvidence(_latestReport!),
          transitionReason: logMessage,
        ),
      );
    }

    if (binding != null) {
      try {
        final controller = await ref.read(
          onboardingOperationControllerProvider.future,
        );
        if ((controller.current.status == OnboardingOperationStatus.running ||
                controller.current.status ==
                    OnboardingOperationStatus.interrupted) &&
            controller.current.operationId == binding.operationId) {
          await controller.fail(
            operationId: binding.operationId,
            category: category,
            summary: summary,
            recoveryDisposition:
                OnboardingOperationRecoveryDisposition.retryFromSafeBoundary,
          );
        }
      } catch (_) {
        // Journey failure is already authoritative. Preserve the original
        // operation error as the primary diagnostic.
      }
    }
    if (category == OnboardingOperationFailureCategory.messageDataBuild) {
      try {
        await ref
            .read(onboardingFailureStorageProvider)
            .saveGraphProjectionFailure(
              message: 'Conversation graph build failed: $summary',
              recordedAt: DateTime.now().toUtc(),
            );
      } catch (_) {
        // Independent diagnostic persistence must not replace Journey failure.
      }
    }
    try {
      ref
          .read(appLoggerProvider.notifier)
          .error(
            '$logMessage: $summary',
            source: 'OnboardingJourneyCoordinator',
            context: {'stackTrace': stackTrace.toString()},
          );
    } catch (_) {
      // Logging is best effort after user-visible failure publication.
    }
    try {
      ref.invalidate(onboardingEnvironmentReportProvider);
    } catch (_) {
      // Evidence refresh is independent of the already-published failure.
    }

    final report = _latestReport;
    final retainedBinding = _operationBinding;
    if (report != null &&
        _reportHasExternalPrerequisiteBlocker(report) &&
        (retainedBinding == null ||
            _bindingCanYieldToPrerequisites(retainedBinding))) {
      _publish(
        _journeyFromEnvironment(
          report,
          reason:
              'current prerequisites displaced the retained operation failure',
        ),
      );
    }
  }

  OnboardingOperationFailureCategory _failureCategoryForStage(
    OnboardingOperationStage? stage,
  ) {
    return switch (stage) {
      OnboardingOperationStage.environmentPreparation ||
      OnboardingOperationStage.automaticRecoveryReset =>
        OnboardingOperationFailureCategory.environmentPreparation,
      OnboardingOperationStage.messageDataBuild =>
        OnboardingOperationFailureCategory.messageDataBuild,
      OnboardingOperationStage.durableReadinessVerification =>
        OnboardingOperationFailureCategory.durableReadinessVerification,
      null => OnboardingOperationFailureCategory.unexpected,
    };
  }

  Future<void> _runConversationGraphBuild({
    required String owner,
    required OnboardingProgressReporter progress,
  }) async {
    var observationWriteTail = Future<void>.value();
    void observeBuild(ConversationGraphBuildObservation observation) {
      if (observation.kind == ConversationGraphBuildObservationKind.completed) {
        return;
      }
      observationWriteTail = observationWriteTail.then((_) {
        return progress.observe(
          substage: _onboardingSubstage(observation.suboperation),
          completedWorkUnits: observation.completedWorkCount,
          totalWorkUnits: observation.totalWorkCount,
          lastCompletedSourceRowId: observation.lastCompletedSourceRowId,
          anomalyCounts: observation.anomalyCounts,
        );
      });
    }

    try {
      await ref
          .read(conversationGraphBuildControllerProvider.notifier)
          .runOnce(owner: owner, onObservation: observeBuild);
    } finally {
      await observationWriteTail;
    }
    await ref
        .read(onboardingFailureStorageProvider)
        .clearGraphProjectionFailure();
  }

  Future<void> openFdaSettings() async {
    await ref.read(fullDiskAccessProvider).openSettings();
  }

  void refreshEnvironment() {
    ref.invalidate(onboardingFullDiskAccessProvider);
    ref.invalidate(onboardingEnvironmentReportProvider);
  }

  void acceptLocalMessageHistory({
    required OnboardingJourneyActionContext actionContext,
  }) {
    if (state is! OnboardingNeedsLocalHistoryConfirmation ||
        !_actionIsCurrent(actionContext)) {
      return;
    }
    _localHistoryAccepted = true;
    final report = _latestReport;
    if (report != null) {
      _ingestEnvironmentReport(report);
    }
  }

  void dismiss({required OnboardingJourneyActionContext actionContext}) {
    if (!_actionIsCurrent(actionContext) ||
        (state is! OnboardingReadyToStart &&
            state is! OnboardingReimportReady) ||
        !state.operation!.availableActions.contains(
          OnboardingJourneyOperationAction.acknowledgeCompletion,
        )) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      acknowledgeTerminal(actionContext: actionContext);
    });
  }

  void acknowledgeTerminal({
    required OnboardingJourneyActionContext actionContext,
  }) {
    if (!_actionIsCurrent(actionContext) ||
        (state is! OnboardingReadyToStart &&
            state is! OnboardingReimportReady) ||
        !state.operation!.availableActions.contains(
          OnboardingJourneyOperationAction.acknowledgeCompletion,
        )) {
      return;
    }
    _operationBinding = null;
    final report = _latestReport;
    _publish(
      OnboardingNormalApplication(
        occurrence: _newOccurrence(),
        evidence: report == null ? null : _prerequisiteEvidence(report),
        transitionReason: 'human acknowledged terminal onboarding Episode',
      ),
    );
    ref.read(activeSidebarModeProvider.notifier).setMode(SidebarMode.messages);
    ref.invalidate(onboardingEnvironmentReportProvider);
  }

  OnboardingJourneyDiagnosticSnapshot diagnosticSnapshot({
    String installationClassification = 'not observed by coordinator',
  }) {
    final current = state;
    final report = current.evidence?.report;
    return OnboardingJourneyDiagnosticSnapshot(
      episode: current.episode,
      occurrence: current.occurrence,
      evidenceRevision: current.evidence?.revision,
      environmentState: report?.state,
      blockerKind: report?.blockerKind,
      operationStatus: current.operation?.phase.name ?? 'unavailable',
      installationClassification: installationClassification,
      lastTransitionReason: current.transitionReason,
    );
  }

  void _maybeTriggerAutomaticRecovery(OnboardingEnvironmentReport report) {
    if (!report.shouldResetAppDatabasesBeforeImport ||
        _automaticRecoverySuppressed ||
        _activeCommandToken != null ||
        _operationBinding != null) {
      return;
    }
    _automaticRecoverySuppressed = true;
    final context = state.actionContext;
    scheduleMicrotask(() => unawaited(_runAutomaticRecovery(context, report)));
  }

  Future<void> _runAutomaticRecovery(
    OnboardingJourneyActionContext context,
    OnboardingEnvironmentReport report,
  ) async {
    final token = _claimCommand(context);
    if (token == null) {
      return;
    }
    final retainedRetryEvidence = _takeRetainedRetryEvidence();
    var beginAttempted = false;
    var replacementFailurePublished = false;
    try {
      if (!_commandAndActionAreCurrent(token, context) ||
          !_latestReportAllowsAutomaticRecovery(
            blockedReason:
                'prerequisites changed before automatic recovery admission',
          )) {
        _automaticRecoverySuppressed = false;
        return;
      }
      await ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .runWithCapability<void>(
            operation: ArchiveMutationOperation.automaticRecovery,
            ownerLabel: 'onboarding-automatic-recovery',
            action: (capability) async {
              final controller = await ref.read(
                onboardingOperationControllerProvider.future,
              );
              if (!_commandAndActionAreCurrent(token, context)) {
                return;
              }
              final admittedReport =
                  await readAdmittedOnboardingEnvironmentEvidence(
                    ref,
                    capability: capability,
                    expectedOperation:
                        ArchiveMutationOperation.automaticRecovery,
                  );
              capability.requireOperation(
                ArchiveMutationOperation.automaticRecovery,
              );
              if (!_commandAndActionAreCurrent(token, context) ||
                  !_reportAllowsCommand(
                    admittedReport,
                    blockedReason:
                        'prerequisites changed before automatic recovery began',
                    predicate: _reportAllowsAutomaticRecovery,
                  )) {
                _automaticRecoverySuppressed = false;
                return;
              }
              beginAttempted = true;
              final operationId = await controller.begin(
                kind: OnboardingOperationKind.automaticRecovery,
                initialStage: OnboardingOperationStage.automaticRecoveryReset,
              );
              _bindNewOperation(
                controller.current,
                reason: 'durable automatic-recovery identity bound',
              );
              final resetCompleted = await controller.runStage<bool>(
                operationId: operationId,
                stage: OnboardingOperationStage.automaticRecoveryReset,
                action: (progress) async {
                  await progress.observe(
                    substage: OnboardingOperationSubstage.resettingDerivedData,
                  );
                  final resetReport =
                      await readAdmittedOnboardingEnvironmentEvidence(
                        ref,
                        capability: capability,
                        expectedOperation:
                            ArchiveMutationOperation.automaticRecovery,
                      );
                  capability.requireOperation(
                    ArchiveMutationOperation.automaticRecovery,
                  );
                  if (!_commandOwnsBoundOperation(token, operationId) ||
                      !_reportAllowsCommand(
                        resetReport,
                        blockedReason:
                            'prerequisites changed before automatic recovery reset',
                        predicate: _reportAllowsAutomaticRecovery,
                      )) {
                    return false;
                  }
                  await ref
                      .read(messageDataResetServiceProvider)
                      .resetDerivedData();
                  return true;
                },
              );
              if (!resetCompleted) {
                await _retainBlockedAutomaticRecoveryEvidence(
                  controller,
                  operationId,
                );
                return;
              }
              await controller.complete(
                operationId: operationId,
                proof: OnboardingDerivedResetCompletedProof(
                  verifiedAtUtc: DateTime.now().toUtc(),
                ),
              );
              await controller.resetToIdle();
              _operationBinding = null;
              _automaticRecoverySuppressed = false;
              refreshEnvironment();
            },
          );
    } on ArchiveMutationDeniedException {
      _automaticRecoveryDeferral =
          _AutomaticRecoveryDeferral.waitingForMutationRelease;
      if (!ref.read(archiveMutationCoordinatorProvider).isLocked) {
        _automaticRecoveryDeferral = _AutomaticRecoveryDeferral.none;
        _automaticRecoverySuppressed = false;
        refreshEnvironment();
      }
    } catch (error, stackTrace) {
      replacementFailurePublished = true;
      await _publishFailureBeforeSideEffects(
        error: error,
        stackTrace: stackTrace,
        fallbackCategory:
            OnboardingOperationFailureCategory.environmentPreparation,
        unboundFailureAction:
            OnboardingJourneyFailureAction.retryAutomaticRecovery,
        logMessage:
            'Automatic onboarding recovery failed (${report.resetAppDatabasesReason ?? 'unspecified reason'})',
      );
    } finally {
      if (!beginAttempted && !replacementFailurePublished) {
        _restoreRetainedRetryEvidence(retainedRetryEvidence);
      }
      _releaseCommand(token);
    }
  }

  Future<void> _retainBlockedAutomaticRecoveryEvidence(
    OnboardingOperationSnapshotController controller,
    OnboardingOperationId operationId,
  ) async {
    final binding = _operationBinding;
    if (binding == null || binding.operationId != operationId) {
      return;
    }
    const summary =
        'Automatic recovery stopped because current prerequisites no longer '
        'permit the reset.';
    final failure = OnboardingOperationFailure(
      category: OnboardingOperationFailureCategory.environmentPreparation,
      occurredAtUtc: DateTime.now().toUtc(),
      summary: summary,
      recoveryDisposition:
          OnboardingOperationRecoveryDisposition.retryFromSafeBoundary,
    );
    binding
      ..snapshot = binding.snapshot.fail(failure: failure)
      ..fingerprint = _operationFingerprint(binding.snapshot);
    try {
      await controller.fail(
        operationId: operationId,
        category: failure.category,
        summary: summary,
        recoveryDisposition: failure.recoveryDisposition,
      );
      binding
        ..snapshot = controller.current
        ..fingerprint = _operationFingerprint(controller.current);
    } catch (error, stackTrace) {
      try {
        ref
            .read(appLoggerProvider.notifier)
            .warn(
              'Could not persist blocked automatic recovery evidence: $error',
              source: 'OnboardingJourneyCoordinator',
              context: {'stackTrace': stackTrace.toString()},
            );
      } catch (_) {
        // The typed prerequisite Episode is already authoritative.
      }
    }
  }

  void _handleMutationLockChanged(bool? previous, bool next) {
    if (previous == true &&
        !next &&
        _automaticRecoveryDeferral ==
            _AutomaticRecoveryDeferral.waitingForMutationRelease) {
      _automaticRecoveryDeferral = _AutomaticRecoveryDeferral.none;
      _automaticRecoverySuppressed = false;
      refreshEnvironment();
    }
  }

  Future<void> _reconcileHistoricalCompletion(
    OnboardingEnvironmentReport report,
    OnboardingOperationSnapshot snapshot,
  ) async {
    try {
      final controller = await ref.read(
        onboardingOperationControllerProvider.future,
      );
      if (controller.current.operationId == snapshot.operationId &&
          controller.current.status == OnboardingOperationStatus.interrupted) {
        await controller.reconcile(
          onboardingReconciliationEvidenceFrom(report, snapshot),
        );
      }
    } catch (error, stackTrace) {
      try {
        ref
            .read(appLoggerProvider.notifier)
            .warn(
              'Historical onboarding reconciliation failed: $error',
              source: 'OnboardingJourneyCoordinator',
              context: {'stackTrace': stackTrace.toString()},
            );
      } catch (_) {
        // Reconciliation is diagnostic once current readiness is established.
      }
    }
  }

  bool _reportAllowsInterruptedContinuation(
    OnboardingEnvironmentReport report,
    OnboardingOperationSnapshot snapshot,
  ) {
    if (_reportHasExternalPrerequisiteBlocker(report) ||
        snapshot.kind == OnboardingOperationKind.automaticRecovery) {
      return false;
    }
    return onboardingReconciliationEvidenceFrom(report, snapshot).state ==
        OnboardingDurableReconciliationState.resumable;
  }

  int? _claimCommand(OnboardingJourneyActionContext context) {
    if (_activeCommandToken != null || !_actionIsCurrent(context)) {
      return null;
    }
    final token = ++_nextCommandToken;
    _activeCommandToken = token;
    return token;
  }

  bool _commandAndActionAreCurrent(
    int token,
    OnboardingJourneyActionContext context,
  ) {
    return _activeCommandToken == token && _actionIsCurrent(context);
  }

  bool _commandRetainsBinding(
    int token,
    OnboardingJourneyActionContext context,
    _OnboardingOperationBinding binding,
  ) {
    return _commandAndActionAreCurrent(token, context) &&
        identical(_operationBinding, binding) &&
        state.operation?.operationId == binding.operationId;
  }

  bool _commandOwnsBoundOperation(
    int token,
    OnboardingOperationId operationId,
  ) {
    return _activeCommandToken == token &&
        _operationBinding?.operationId == operationId &&
        state.operation?.operationId == operationId;
  }

  void _releaseCommand(int token) {
    if (_activeCommandToken == token) {
      _activeCommandToken = null;
    }
  }

  bool _actionIsCurrent(OnboardingJourneyActionContext context) {
    final current = state.actionContext;
    return current.occurrence == context.occurrence &&
        current.episode == context.episode &&
        current.prerequisiteEvidenceRevision ==
            context.prerequisiteEvidenceRevision &&
        current.operationId == context.operationId;
  }

  void _publish(OnboardingJourneyState next) {
    state = next;
  }

  int _newOccurrence() => ++_nextJourneyOccurrence;

  OnboardingPrerequisiteEvidence _prerequisiteEvidence(
    OnboardingEnvironmentReport report,
  ) {
    return OnboardingPrerequisiteEvidence(
      revision: ++_nextEvidenceRevision,
      observedAtUtc: DateTime.now().toUtc(),
      report: report,
    );
  }

  String _boundedSummary(Object error) {
    final normalized = error.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 500) {
      return normalized;
    }
    return '${normalized.substring(0, 497)}...';
  }
}

final class _OnboardingOperationBinding {
  _OnboardingOperationBinding({
    required this.occurrence,
    required this.operationId,
    required this.kind,
    required this.processSessionId,
    required this.snapshot,
    required this.fingerprint,
  });

  int occurrence;
  final OnboardingOperationId operationId;
  final OnboardingOperationKind kind;
  OnboardingProcessSessionId processSessionId;
  OnboardingOperationSnapshot snapshot;
  String fingerprint;
}

final class _OnboardingUnboundFailure {
  const _OnboardingUnboundFailure({
    required this.summary,
    required this.action,
  });

  final String summary;
  final OnboardingJourneyFailureAction action;
}

final class _RetainedRetryEvidence {
  const _RetainedRetryEvidence({this.binding, this.unboundFailure});

  final _OnboardingOperationBinding? binding;
  final _OnboardingUnboundFailure? unboundFailure;
}

String _operationFingerprint(OnboardingOperationSnapshot snapshot) {
  final progress = snapshot.progress;
  return <Object?>[
    snapshot.status.name,
    snapshot.currentStage?.name,
    snapshot.currentSubstage?.name,
    snapshot.progressRevision,
    progress?.completedWorkUnits,
    progress?.totalWorkUnits,
    progress?.lastCompletedSourceRowId,
    snapshot.failure?.category.name,
    snapshot.failure?.summary,
    snapshot.finishedAtUtc?.toIso8601String(),
  ].join('|');
}

int _stageRank(OnboardingOperationKind kind, OnboardingOperationStage? stage) {
  if (stage == null) {
    return -1;
  }
  return switch (kind) {
    OnboardingOperationKind.initialImport => switch (stage) {
      OnboardingOperationStage.environmentPreparation => 0,
      OnboardingOperationStage.messageDataBuild => 1,
      OnboardingOperationStage.durableReadinessVerification => 2,
      OnboardingOperationStage.automaticRecoveryReset => 0,
    },
    OnboardingOperationKind.reimport => switch (stage) {
      OnboardingOperationStage.environmentPreparation => 0,
      OnboardingOperationStage.messageDataBuild => 1,
      OnboardingOperationStage.durableReadinessVerification => 2,
      OnboardingOperationStage.automaticRecoveryReset => 0,
    },
    OnboardingOperationKind.automaticRecovery => switch (stage) {
      OnboardingOperationStage.automaticRecoveryReset => 0,
      OnboardingOperationStage.environmentPreparation => 0,
      OnboardingOperationStage.messageDataBuild => 1,
      OnboardingOperationStage.durableReadinessVerification => 2,
    },
  };
}

bool _isValidStageAndSubstage(
  OnboardingOperationKind kind,
  OnboardingOperationStage? stage,
  OnboardingOperationSubstage? substage,
) {
  if (stage == null) {
    return false;
  }
  final stageBelongsToKind = switch (kind) {
    OnboardingOperationKind.initialImport =>
      stage == OnboardingOperationStage.messageDataBuild ||
          stage == OnboardingOperationStage.durableReadinessVerification,
    OnboardingOperationKind.reimport =>
      stage == OnboardingOperationStage.environmentPreparation ||
          stage == OnboardingOperationStage.messageDataBuild ||
          stage == OnboardingOperationStage.durableReadinessVerification,
    OnboardingOperationKind.automaticRecovery =>
      stage == OnboardingOperationStage.automaticRecoveryReset,
  };
  if (!stageBelongsToKind || substage == null) {
    return stageBelongsToKind;
  }
  return switch (stage) {
    OnboardingOperationStage.environmentPreparation =>
      substage == OnboardingOperationSubstage.preparingEnvironment ||
          substage == OnboardingOperationSubstage.resettingDerivedData,
    OnboardingOperationStage.messageDataBuild =>
      substage != OnboardingOperationSubstage.preparingEnvironment &&
          substage != OnboardingOperationSubstage.resettingDerivedData &&
          substage != OnboardingOperationSubstage.verifyingDurableReadiness,
    OnboardingOperationStage.durableReadinessVerification =>
      substage == OnboardingOperationSubstage.verifyingDurableReadiness,
    OnboardingOperationStage.automaticRecoveryReset =>
      substage == OnboardingOperationSubstage.resettingDerivedData,
  };
}

int _substageRank(OnboardingOperationSubstage? substage) {
  if (substage == null) {
    return -1;
  }
  return OnboardingOperationSubstage.values.indexOf(substage);
}

OnboardingOperationSubstage _onboardingSubstage(
  ConversationGraphBuildSuboperation suboperation,
) {
  return switch (suboperation) {
    ConversationGraphBuildSuboperation.importChats =>
      OnboardingOperationSubstage.importingChats,
    ConversationGraphBuildSuboperation.importHandles =>
      OnboardingOperationSubstage.importingHandles,
    ConversationGraphBuildSuboperation.importContacts =>
      OnboardingOperationSubstage.importingContacts,
    ConversationGraphBuildSuboperation.importContactEmailChannels =>
      OnboardingOperationSubstage.importingContactEmailChannels,
    ConversationGraphBuildSuboperation.importContactPhoneChannels =>
      OnboardingOperationSubstage.importingContactPhoneChannels,
    ConversationGraphBuildSuboperation.importMessages =>
      OnboardingOperationSubstage.importingMessages,
    ConversationGraphBuildSuboperation.extractRichText =>
      OnboardingOperationSubstage.extractingRichText,
    ConversationGraphBuildSuboperation.persistRichText =>
      OnboardingOperationSubstage.persistingRichText,
    ConversationGraphBuildSuboperation.importAttachments =>
      OnboardingOperationSubstage.importingAttachments,
    ConversationGraphBuildSuboperation.importChatMessageRelationships =>
      OnboardingOperationSubstage.importingChatMessageRelationships,
    ConversationGraphBuildSuboperation.importChatHandleRelationships =>
      OnboardingOperationSubstage.importingChatHandleRelationships,
    ConversationGraphBuildSuboperation.importMessageAttachmentRelationships =>
      OnboardingOperationSubstage.importingMessageAttachmentRelationships,
    ConversationGraphBuildSuboperation.projectHandles =>
      OnboardingOperationSubstage.projectingHandles,
    ConversationGraphBuildSuboperation.projectContacts =>
      OnboardingOperationSubstage.projectingContacts,
    ConversationGraphBuildSuboperation.projectChatHandleRelationships =>
      OnboardingOperationSubstage.projectingChatHandleRelationships,
    ConversationGraphBuildSuboperation.projectConversations =>
      OnboardingOperationSubstage.projectingConversations,
    ConversationGraphBuildSuboperation.projectMessages =>
      OnboardingOperationSubstage.projectingMessages,
    ConversationGraphBuildSuboperation.projectAttachments =>
      OnboardingOperationSubstage.projectingAttachments,
    ConversationGraphBuildSuboperation.projectChatMessageRelationships =>
      OnboardingOperationSubstage.projectingChatMessageRelationships,
    ConversationGraphBuildSuboperation.projectMessageAttachmentRelationships =>
      OnboardingOperationSubstage.projectingMessageAttachmentRelationships,
  };
}
