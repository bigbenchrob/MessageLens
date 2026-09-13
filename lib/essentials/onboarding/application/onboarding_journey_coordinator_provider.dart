import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/domain.dart'
    show ArchiveMutationDeniedException, ArchiveMutationOperation;
import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider, archiveMutationCoordinatorProvider;
import '../../conversation_graph/application/conversation_graph_build_observation.dart';
import '../../conversation_graph/feature_level_providers.dart'
    show conversationGraphBuildControllerProvider;
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../navigation/feature_level_providers.dart'
    show SidebarMode, activeSidebarModeProvider;
import '../domain/onboarding_environment_report.dart';
import '../domain/onboarding_journey_state.dart';
import '../domain/onboarding_operation_snapshot.dart';
import '../domain/onboarding_status.dart';
import 'database_existence_checker.dart';
import 'full_disk_access_provider.dart';
import 'message_data_reset_service.dart';
import 'onboarding_database_probe_reader_provider.dart';
import 'onboarding_durable_completion_verifier_provider.dart';
import 'onboarding_environment_report_provider.dart';
import 'onboarding_failure_storage_provider.dart';
import 'onboarding_operation_snapshot_controller.dart';
import 'onboarding_operation_snapshot_provider.dart';
import 'virgin_onboarding_import_executor.dart';

part 'onboarding_journey_coordinator_provider.g.dart';

enum _AutomaticRecoveryDeferral {
  none,
  waitingForMutationRelease,
  awaitingFreshEnvironment,
}

/// Sole authority for the active typed Onboarding Journey Episode.
///
/// Prerequisite providers, durable operation state, lifecycle callbacks, and
/// widgets contribute evidence or intent. This coordinator applies blocker
/// priority and transition policy, admits operational work through the archive
/// mutation boundary, and publishes exactly one [OnboardingJourneyState].
@Riverpod(keepAlive: true)
class OnboardingJourneyCoordinator extends _$OnboardingJourneyCoordinator {
  OnboardingStatus? _workflowOverrideStatus;
  bool _automaticRecoveryInFlight = false;
  bool _automaticRecoverySuppressed = false;
  _AutomaticRecoveryDeferral _automaticRecoveryDeferral =
      _AutomaticRecoveryDeferral.none;
  bool _mutationCoordinatorIsLocked = false;
  OnboardingStatus? _lastLoggedResolvedStatus;
  OnboardingEnvironmentState? _lastLoggedEnvironmentState;
  OnboardingBlockerKind? _lastLoggedBlockerKind;
  bool? _lastLoggedHasPopulatedAppDatabases;
  int _nextJourneyOccurrence = 0;
  int _nextEvidenceRevision = 0;
  bool _localHistoryAccepted = false;
  Object? _lastOperationFailure;

  @override
  OnboardingJourneyState build() {
    ref.listen<bool>(
      archiveMutationCoordinatorProvider.select((state) => state.isLocked),
      _handleMutationLockChanged,
      fireImmediately: true,
    );

    final reportAsync = ref.watch(onboardingEnvironmentReportProvider);
    if (!reportAsync.isLoading && !reportAsync.hasError) {
      final report = reportAsync.valueOrNull;
      if (report != null) {
        _handleEnvironmentReport(report);
      }
    }

    final resolvedStatus = resolveBuildStatus(
      reportAsync: reportAsync,
      workflowOverrideStatus: _workflowOverrideStatus,
      fallbackBuildStatus: _fallbackBuildStatus,
    );

    _maybeLogResolvedStatus(
      resolvedStatus: resolvedStatus,
      report: reportAsync.valueOrNull,
    );

    return _journeyStateFor(
      status: resolvedStatus,
      report: reportAsync.valueOrNull,
      reason: 'resolved from coherent environment evidence',
    );
  }

  void _maybeLogResolvedStatus({
    required OnboardingStatus resolvedStatus,
    required OnboardingEnvironmentReport? report,
  }) {
    final hasPopulatedAppDatabases = report?.hasPopulatedAppDatabases;
    final shouldLog =
        _lastLoggedResolvedStatus != resolvedStatus ||
        _lastLoggedEnvironmentState != report?.state ||
        _lastLoggedBlockerKind != report?.blockerKind ||
        _lastLoggedHasPopulatedAppDatabases != hasPopulatedAppDatabases;

    if (!shouldLog) {
      return;
    }

    _lastLoggedResolvedStatus = resolvedStatus;
    _lastLoggedEnvironmentState = report?.state;
    _lastLoggedBlockerKind = report?.blockerKind;
    _lastLoggedHasPopulatedAppDatabases = hasPopulatedAppDatabases;

    final logContext = <String, dynamic>{
      'resolvedStatus': resolvedStatus.name,
      'workflowOverrideStatus': _workflowOverrideStatus?.name,
      'environmentState': report?.state.name,
      'environmentBlocker': report?.blockerKind.name,
      'hasFullDiskAccess': report?.hasFullDiskAccess,
      'hasPopulatedAppDatabases': hasPopulatedAppDatabases,
      'sourceScopedImportDbExists': report?.sourceScopedImportDatabase.exists,
      'sourceScopedImportDbRowCount':
          report?.sourceScopedImportDatabase.rowCount,
      'conversationGraphExists': report?.conversationGraph.exists,
      'conversationGraphRowCount': report?.conversationGraph.rowCount,
      'shouldResetAppDatabasesBeforeImport':
          report?.shouldResetAppDatabasesBeforeImport,
      'resetAppDatabasesReason': report?.resetAppDatabasesReason,
      'operationStatus': report?.operationSnapshot.status.name,
      'operationStage': report?.operationSnapshot.currentStage?.name,
      'operationSubstage': report?.operationSnapshot.currentSubstage?.name,
    };

    final logger = ref.read(appLoggerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logger.info(
        'Resolved onboarding gate status',
        source: 'OnboardingJourneyCoordinator',
        context: logContext,
      );
    });
  }

  static OnboardingStatus resolveBuildStatus({
    required AsyncValue<OnboardingEnvironmentReport> reportAsync,
    required OnboardingStatus? workflowOverrideStatus,
    required OnboardingStatus Function() fallbackBuildStatus,
  }) {
    if (_shouldPreserveWorkflowOverride(workflowOverrideStatus)) {
      return workflowOverrideStatus!;
    }

    return reportAsync.when(
      data: _classifyStatusFromReport,
      loading: fallbackBuildStatus,
      error: (_, __) => fallbackBuildStatus(),
    );
  }

  static OnboardingStatus _classifyStatusFromReport(
    OnboardingEnvironmentReport report,
  ) {
    return switch (report.state) {
      OnboardingEnvironmentState.permissionBlocked =>
        OnboardingStatus.awaitingFda,
      OnboardingEnvironmentState.ready ||
      OnboardingEnvironmentState.maintenanceInProgress =>
        OnboardingStatus.notNeeded,
      OnboardingEnvironmentState.importFailed ||
      OnboardingEnvironmentState.graphProjectionFailed ||
      OnboardingEnvironmentState.sourceUnavailable ||
      OnboardingEnvironmentState.sourceSparseOrUnsynced ||
      OnboardingEnvironmentState.readyToImport =>
        OnboardingStatus.awaitingUserAction,
    };
  }

  OnboardingJourneyState _journeyStateFor({
    required OnboardingStatus status,
    required OnboardingEnvironmentReport? report,
    required String reason,
  }) {
    final occurrence = ++_nextJourneyOccurrence;
    final evidence = report == null
        ? null
        : OnboardingPrerequisiteEvidence(
            revision: ++_nextEvidenceRevision,
            observedAtUtc: DateTime.now().toUtc(),
            report: report,
          );

    if (status == OnboardingStatus.awaitingFda && evidence != null) {
      return OnboardingNeedsMessagesAccess(
        occurrence: occurrence,
        evidence: evidence,
        transitionReason: reason,
      );
    }
    if (status == OnboardingStatus.awaitingUserAction && evidence != null) {
      if (evidence.report.shouldResetAppDatabasesBeforeImport) {
        return OnboardingOperationFailed(
          occurrence: occurrence,
          summary:
              evidence.report.incompleteOperationSummary ??
              evidence.report.resetAppDatabasesReason ??
              'Existing derived data requires recovery before a fresh import.',
          compatibilityStatus: OnboardingStatus.awaitingUserAction,
          evidence: evidence,
          transitionReason: reason,
        );
      }
      if (evidence.report.state == OnboardingEnvironmentState.importFailed ||
          evidence.report.state ==
              OnboardingEnvironmentState.graphProjectionFailed) {
        return OnboardingOperationFailed(
          occurrence: occurrence,
          summary:
              evidence.report.incompleteOperationSummary ??
              evidence.report.importFailureMessage ??
              evidence.report.graphProjectionFailureMessage ??
              'The previous onboarding operation did not finish.',
          compatibilityStatus: OnboardingStatus.awaitingUserAction,
          evidence: evidence,
          transitionReason: reason,
        );
      }
      if (evidence.report.blockerKind ==
          OnboardingBlockerKind.addressBookUnavailable) {
        return OnboardingNeedsContactsAccess(
          occurrence: occurrence,
          evidence: evidence,
          transitionReason: reason,
        );
      }
      if (evidence.report.state ==
              OnboardingEnvironmentState.sourceSparseOrUnsynced &&
          !_localHistoryAccepted) {
        return OnboardingNeedsLocalHistoryConfirmation(
          occurrence: occurrence,
          evidence: evidence,
          transitionReason: reason,
        );
      }
      if (evidence.report.state == OnboardingEnvironmentState.readyToImport ||
          (evidence.report.state ==
                  OnboardingEnvironmentState.sourceSparseOrUnsynced &&
              _localHistoryAccepted)) {
        return OnboardingReadyToImport(
          occurrence: occurrence,
          evidence: evidence,
          localHistoryAccepted: _localHistoryAccepted,
          transitionReason: reason,
        );
      }
      if (evidence.report.blockerKind ==
              OnboardingBlockerKind.messagesDatabaseMissing ||
          evidence.report.blockerKind ==
              OnboardingBlockerKind.fullDiskAccessMissing) {
        return OnboardingNeedsMessagesAccess(
          occurrence: occurrence,
          evidence: evidence,
          transitionReason: reason,
        );
      }
    }

    return switch (status) {
      OnboardingStatus.recoveringFailedAttempt =>
        OnboardingRecoveringDerivedData(
          occurrence: occurrence,
          transitionReason: reason,
        ),
      OnboardingStatus.preparationFailed => OnboardingOperationFailed(
        occurrence: occurrence,
        summary:
            _lastOperationFailure?.toString() ??
            'The current onboarding operation did not finish.',
        compatibilityStatus: OnboardingStatus.preparationFailed,
        evidence: evidence,
        transitionReason: reason,
      ),
      OnboardingStatus.importing => OnboardingPreparingImport(
        occurrence: occurrence,
        transitionReason: reason,
      ),
      OnboardingStatus.buildingGraph => OnboardingBuildingLocalData(
        occurrence: occurrence,
        transitionReason: reason,
      ),
      OnboardingStatus.complete => OnboardingReadyToStart(
        occurrence: occurrence,
        transitionReason: reason,
      ),
      OnboardingStatus.notNeeded => OnboardingNormalApplication(
        occurrence: occurrence,
        evidence: evidence,
        transitionReason: reason,
      ),
      OnboardingStatus.reimporting ||
      OnboardingStatus.reimportBuildingGraph => OnboardingReimporting(
        occurrence: occurrence,
        status: status,
        transitionReason: reason,
      ),
      OnboardingStatus.reimportComplete => OnboardingReimportReady(
        occurrence: occurrence,
        transitionReason: reason,
      ),
      OnboardingStatus.awaitingFda ||
      OnboardingStatus.awaitingUserAction => OnboardingCheckingPrerequisites(
        occurrence: occurrence,
        transitionReason: reason,
      ),
    };
  }

  static bool _shouldPreserveWorkflowOverride(OnboardingStatus? status) {
    return switch (status) {
      OnboardingStatus.recoveringFailedAttempt ||
      OnboardingStatus.preparationFailed ||
      OnboardingStatus.importing ||
      OnboardingStatus.buildingGraph ||
      OnboardingStatus.complete ||
      OnboardingStatus.reimporting ||
      OnboardingStatus.reimportBuildingGraph ||
      OnboardingStatus.reimportComplete ||
      OnboardingStatus.awaitingUserAction => true,
      null ||
      OnboardingStatus.awaitingFda ||
      OnboardingStatus.notNeeded => false,
    };
  }

  OnboardingStatus _fallbackBuildStatus() {
    if (!ref.read(onboardingFullDiskAccessProvider)) {
      return OnboardingStatus.awaitingFda;
    }

    final checker = DatabaseExistenceChecker(
      ref.read(onboardingDatabaseProbeReaderProvider),
    );
    final hasData = checker.hasPopulatedDatabases(
      ref.read(archiveAccessAuthorityProvider).rootPath,
    );
    if (hasData) {
      return OnboardingStatus.notNeeded;
    }

    return OnboardingStatus.awaitingUserAction;
  }

  /// Starts fresh derived-store construction for a proven Virgin installation.
  Future<void> startVirginImportAndGraphBuild() async {
    if (state is! OnboardingReadyToImport) {
      return;
    }

    // A known missing source permission is a prerequisite Episode, not import
    // preparation. The admitted action repeats this proof to cover revocation
    // after the presentation frame but before source access.
    if (!ref.read(onboardingFullDiskAccessProvider)) {
      _clearWorkflowOverride();
      _publishStatus(
        OnboardingStatus.awaitingFda,
        reason: 'Messages source proof failed before import presentation',
      );
      return;
    }

    // First-run presentation ownership must be established before mutation
    // admission activates maintenance state. Otherwise readiness can briefly
    // project normal-application state and reveal the normal sidebar.
    _setWorkflowOverride(OnboardingStatus.importing);
    await _waitForEndOfFrame();

    final OnboardingOperationId? operationId;
    try {
      operationId = await ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .run<OnboardingOperationId?>(
            operation: ArchiveMutationOperation.onboardingImport,
            ownerLabel: 'onboarding-first-run',
            action: _runAdmittedVirginImport,
          );
    } catch (error, stackTrace) {
      _enterPreparationFailure(
        error: error,
        stackTrace: stackTrace,
        logMessage: 'Fresh onboarding mutation admission failed',
      );
      return;
    }
    if (operationId == null) {
      return;
    }
    await _verifyAndCompleteInstallation(
      operationId: operationId,
      completionStatus: OnboardingStatus.complete,
    );
  }

  Future<OnboardingOperationId?> _runAdmittedVirginImport() async {
    ref
        .read(appLoggerProvider.notifier)
        .info(
          'Starting fresh onboarding conversation graph build',
          source: 'OnboardingJourneyCoordinator',
        );

    // Gate 2 safety check: verify we can still read chat.db before
    // committing to the import.  If FDA was revoked after the earlier
    // check, fall back to the FDA screen.
    if (!ref.read(onboardingFullDiskAccessProvider)) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Aborting fresh onboarding import because Messages database is no longer readable',
            source: 'OnboardingJourneyCoordinator',
          );
      _clearWorkflowOverride();
      _publishStatus(
        OnboardingStatus.awaitingFda,
        reason: 'Messages source proof failed immediately before import',
      );
      return null;
    }

    final operationController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    _setWorkflowOverride(OnboardingStatus.buildingGraph);
    await _waitForEndOfFrame();
    try {
      final operationId =
          await VirginOnboardingImportExecutor(
            operationController: operationController,
          ).run(
            buildMessageData: (progress) => _runConversationGraphBuild(
              owner: 'onboarding-first-run',
              progress: progress,
            ),
          );
      ref
          .read(appLoggerProvider.notifier)
          .info(
            'Fresh onboarding conversation graph build completed successfully',
            source: 'OnboardingJourneyCoordinator',
          );
      return operationId;
    } catch (error) {
      await _recordConversationGraphBuildFailure(error);
      _finishFirstRunWithFailure();
      return null;
    }
  }

  /// Requests a fresh evaluation of a failed/partial installation.
  ///
  /// This intent cannot enter the Virgin import executor. Durable evidence must
  /// first drive the existing recovery path and reclassify the installation as
  /// ready for fresh construction.
  Future<void> retryFailedOperation() async {
    if (state is! OnboardingOperationFailed) {
      return;
    }
    _automaticRecoverySuppressed = false;
    _clearWorkflowOverride();
    ref.invalidate(onboardingEnvironmentReportProvider);
    await ref.read(onboardingEnvironmentReportProvider.future);
  }

  /// Wait until the current frame has finished painting.
  ///
  /// Unlike [Future.delayed] with [Duration.zero] (which fires between
  /// microtasks, before the frame pipeline), this uses
  /// [WidgetsBinding.addPostFrameCallback] to guarantee that layout and
  /// paint have completed — meaning any widgets that depend on our state
  /// change have already mounted and started watching providers.
  Future<void> _waitForEndOfFrame() {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      completer.complete();
    });
    return completer.future;
  }

  /// Open System Settings to the Full Disk Access pane.
  Future<void> openFdaSettings() async {
    await ref.read(fullDiskAccessProvider).openSettings();
  }

  void refreshEnvironment() {
    _automaticRecoveryDeferral = _AutomaticRecoveryDeferral.none;
    _automaticRecoverySuppressed = false;
    _clearWorkflowOverride();
    ref.invalidate(onboardingFullDiskAccessProvider);
    ref.invalidate(onboardingEnvironmentReportProvider);
    ref.invalidateSelf();
  }

  void acceptLocalMessageHistory() {
    final current = state;
    if (current is! OnboardingNeedsLocalHistoryConfirmation) {
      return;
    }
    _localHistoryAccepted = true;
    _publishStatus(
      OnboardingStatus.awaitingUserAction,
      report: current.evidence!.report,
      reason: 'human accepted the locally observed Messages history',
    );
  }

  /// Trigger a full reimport from settings.
  ///
  /// Unlike [startVirginImportAndGraphBuild], this can be called when the app is
  /// already running with populated databases.  It shows the same
  /// progress overlay but uses the reimport-specific status values so the UI
  /// can distinguish first-run from settings-triggered graph rebuild.
  Future<void> startReimport() async {
    if (state is! OnboardingNormalApplication) {
      return;
    }

    final operationId = await ref
        .read(archiveMutationCoordinatorProvider.notifier)
        .run<OnboardingOperationId?>(
          operation: ArchiveMutationOperation.onboardingImport,
          ownerLabel: 'settings-reimport',
          action: _startReimport,
        );
    if (operationId == null) {
      return;
    }
    await _verifyAndCompleteInstallation(
      operationId: operationId,
      completionStatus: OnboardingStatus.reimportComplete,
    );
  }

  Future<OnboardingOperationId?> _startReimport() async {
    final operationController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final operationId = await operationController.begin(
      kind: OnboardingOperationKind.reimport,
      initialStage: OnboardingOperationStage.environmentPreparation,
    );
    // Clean out previous derived graph/import data so the build reimports
    // everything from the live source while preserving overlays and archive
    // files.
    try {
      await operationController.runStage<void>(
        operationId: operationId,
        stage: OnboardingOperationStage.environmentPreparation,
        failureCategory:
            OnboardingOperationFailureCategory.environmentPreparation,
        action: (progress) async {
          await progress.observe(
            substage: OnboardingOperationSubstage.resettingDerivedData,
          );
          await ref.read(messageDataResetServiceProvider).resetDerivedData();
        },
      );
    } catch (error, stackTrace) {
      _enterPreparationFailure(
        error: error,
        stackTrace: stackTrace,
        logMessage: 'Settings reimport preparation failed',
      );
      return null;
    }

    // ── Graph rebuild phase ──
    _setWorkflowOverride(OnboardingStatus.reimporting);
    await _waitForEndOfFrame();
    _setWorkflowOverride(OnboardingStatus.reimportBuildingGraph);
    await _waitForEndOfFrame();
    try {
      await operationController.runStage<void>(
        operationId: operationId,
        stage: OnboardingOperationStage.messageDataBuild,
        failureCategory: OnboardingOperationFailureCategory.messageDataBuild,
        action: (progress) => _runConversationGraphBuild(
          owner: 'settings-reimport',
          progress: progress,
        ),
      );
    } catch (error) {
      await _recordConversationGraphBuildFailure(error);
      _finishReimportWithFailure();
      return null;
    }

    await operationController.enterStage(
      operationId: operationId,
      stage: OnboardingOperationStage.durableReadinessVerification,
    );
    return operationId;
  }

  /// Dismiss the overlay and switch to the Messages sidebar.
  ///
  /// Deferred to the next frame so the [ModalBarrier] in the overlay is not
  /// removed during an active gesture callback (avoids the
  /// `!_debugDuringDeviceUpdate` assertion in mouse_tracker.dart).
  void dismiss() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearWorkflowOverride();
      ref
          .read(activeSidebarModeProvider.notifier)
          .setMode(SidebarMode.messages);
      _publishStatus(
        OnboardingStatus.notNeeded,
        reason: 'human acknowledged terminal onboarding Episode',
      );
    });
  }

  void _setWorkflowOverride(OnboardingStatus status) {
    _workflowOverrideStatus = status;
    _publishStatus(status, reason: 'operation workflow state changed');
  }

  void _publishStatus(
    OnboardingStatus status, {
    OnboardingEnvironmentReport? report,
    required String reason,
  }) {
    _publishJourneyState(
      _journeyStateFor(
        status: status,
        report:
            report ?? ref.read(onboardingEnvironmentReportProvider).valueOrNull,
        reason: reason,
      ),
      reason: reason,
    );
  }

  void _publishJourneyState(
    OnboardingJourneyState next, {
    required String reason,
  }) {
    if (!onboardingJourneyAllowsCommandedTransition(
      state.compatibilityStatus,
      next.compatibilityStatus,
    )) {
      throw StateError(
        'Onboarding Journey cannot transition from '
        '${state.compatibilityStatus.name} to ${next.compatibilityStatus.name}: $reason',
      );
    }
    state = next;
  }

  void _clearWorkflowOverride() {
    _workflowOverrideStatus = null;
  }

  void _maybeTriggerAutomaticRecovery(OnboardingEnvironmentReport report) {
    if (_workflowOverrideStatus == OnboardingStatus.preparationFailed) {
      return;
    }

    if (!report.shouldResetAppDatabasesBeforeImport) {
      _automaticRecoveryDeferral = _AutomaticRecoveryDeferral.none;
      _automaticRecoverySuppressed = false;
      return;
    }

    if (_automaticRecoveryInFlight || _automaticRecoverySuppressed) {
      return;
    }

    _automaticRecoveryInFlight = true;
    _automaticRecoverySuppressed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runAutomaticRecovery(report));
    });
  }

  void _handleEnvironmentReport(OnboardingEnvironmentReport report) {
    if (_automaticRecoveryDeferral ==
        _AutomaticRecoveryDeferral.awaitingFreshEnvironment) {
      _automaticRecoveryDeferral = _AutomaticRecoveryDeferral.none;
      _automaticRecoverySuppressed = false;
    }
    _maybeTriggerAutomaticRecovery(report);
  }

  Future<void> _runAutomaticRecovery(OnboardingEnvironmentReport report) async {
    final coordinator = ref.read(archiveMutationCoordinatorProvider.notifier);
    final logger = ref.read(appLoggerProvider.notifier);
    try {
      await coordinator.run<void>(
        operation: ArchiveMutationOperation.automaticRecovery,
        ownerLabel: 'onboarding-automatic-recovery',
        action: () => _runAdmittedAutomaticRecovery(report),
      );
    } on ArchiveMutationDeniedException catch (error) {
      _automaticRecoveryInFlight = false;
      _automaticRecoverySuppressed = true;
      _automaticRecoveryDeferral =
          _AutomaticRecoveryDeferral.waitingForMutationRelease;
      _clearWorkflowOverride();
      logger.warn(
        'Deferred automatic onboarding recovery because archive mutation authority is busy: $error',
        source: 'OnboardingJourneyCoordinator',
      );
      if (!_mutationCoordinatorIsLocked) {
        _requestFreshEnvironmentAfterMutation();
      }
    } catch (error, stackTrace) {
      _automaticRecoveryInFlight = false;
      _automaticRecoverySuppressed = true;
      _enterPreparationFailure(
        error: error,
        stackTrace: stackTrace,
        logMessage: 'Automatic onboarding recovery admission failed',
      );
    }
  }

  Future<void> _runAdmittedAutomaticRecovery(
    OnboardingEnvironmentReport report,
  ) async {
    final operationController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final operationId = await operationController.begin(
      kind: OnboardingOperationKind.automaticRecovery,
      initialStage: OnboardingOperationStage.automaticRecoveryReset,
    );
    try {
      _setWorkflowOverride(OnboardingStatus.recoveringFailedAttempt);
      await _waitForEndOfFrame();
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Auto-resetting app databases before onboarding retry: ${report.resetAppDatabasesReason ?? 'no reason provided'}',
            source: 'OnboardingJourneyCoordinator',
          );
      await operationController.runStage<void>(
        operationId: operationId,
        stage: OnboardingOperationStage.automaticRecoveryReset,
        failureCategory:
            OnboardingOperationFailureCategory.environmentPreparation,
        action: (progress) async {
          await progress.observe(
            substage: OnboardingOperationSubstage.resettingDerivedData,
          );
          await ref.read(messageDataResetServiceProvider).resetDerivedData();
        },
      );
      await operationController.complete(
        operationId: operationId,
        proof: OnboardingDerivedResetCompletedProof(
          verifiedAtUtc: DateTime.now().toUtc(),
        ),
      );
      await operationController.resetToIdle();
    } catch (error, stackTrace) {
      _automaticRecoveryInFlight = false;
      _automaticRecoverySuppressed = true;
      _enterPreparationFailure(
        error: error,
        stackTrace: stackTrace,
        logMessage: 'Automatic onboarding DB reset failed',
      );
      return;
    }

    _automaticRecoveryInFlight = false;
    _clearWorkflowOverride();
    ref.invalidate(onboardingEnvironmentReportProvider);
    ref.invalidateSelf();
    _publishStatus(
      OnboardingStatus.awaitingUserAction,
      reason: 'automatic recovery completed and prerequisites require review',
    );
  }

  void _handleMutationLockChanged(bool? previous, bool next) {
    _mutationCoordinatorIsLocked = next;
    final mutationAuthorityJustBecameIdle = previous == true && !next;
    if (!mutationAuthorityJustBecameIdle ||
        _automaticRecoveryDeferral !=
            _AutomaticRecoveryDeferral.waitingForMutationRelease) {
      return;
    }

    _requestFreshEnvironmentAfterMutation();
  }

  void _requestFreshEnvironmentAfterMutation() {
    if (_automaticRecoveryDeferral !=
        _AutomaticRecoveryDeferral.waitingForMutationRelease) {
      return;
    }

    // Claim this release event before invalidating so the lifecycle listener
    // and denial catch cannot request duplicate evaluations. The denied report
    // is discarded; the next provider result is the only recovery authority.
    _automaticRecoveryDeferral =
        _AutomaticRecoveryDeferral.awaitingFreshEnvironment;
    ref.invalidate(onboardingEnvironmentReportProvider);
  }

  void _enterPreparationFailure({
    required Object error,
    required StackTrace stackTrace,
    required String logMessage,
  }) {
    _automaticRecoverySuppressed = true;
    _lastOperationFailure = error;
    ref
        .read(appLoggerProvider.notifier)
        .error(
          '$logMessage: $error',
          source: 'OnboardingJourneyCoordinator',
          context: {'stackTrace': stackTrace.toString()},
        );
    _setWorkflowOverride(OnboardingStatus.preparationFailed);
  }

  OnboardingJourneyDiagnosticSnapshot diagnosticSnapshot({
    String installationClassification = 'not observed by coordinator',
  }) {
    final current = state;
    final report = current.evidence?.report;
    final operation = ref.read(onboardingOperationSnapshotProvider).valueOrNull;
    return OnboardingJourneyDiagnosticSnapshot(
      episode: current.episode,
      occurrence: current.occurrence,
      evidenceRevision: current.evidence?.revision,
      environmentState: report?.state,
      blockerKind: report?.blockerKind,
      operationStatus: operation?.status.name ?? 'unavailable',
      installationClassification: installationClassification,
      lastTransitionReason: current.transitionReason,
    );
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
    await _clearConversationGraphBuildFailure();
  }

  Future<void> _recordConversationGraphBuildFailure(Object error) async {
    final storage = ref.read(onboardingFailureStorageProvider);
    await storage.saveGraphProjectionFailure(
      message: 'Conversation graph build failed: $error',
      recordedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> _clearConversationGraphBuildFailure() async {
    final storage = ref.read(onboardingFailureStorageProvider);
    await storage.clearGraphProjectionFailure();
  }

  Future<void> _verifyAndCompleteInstallation({
    required OnboardingOperationId operationId,
    required OnboardingStatus completionStatus,
  }) async {
    final operationController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    try {
      if (completionStatus == OnboardingStatus.complete) {
        _publishJourneyState(
          OnboardingVerifyingDurableReadiness(
            occurrence: ++_nextJourneyOccurrence,
            transitionReason: 'import completed; verifying durable readiness',
          ),
          reason: 'import completed; verifying durable readiness',
        );
        await _waitForEndOfFrame();
      }
      await operationController.reportProgress(
        operationId: operationId,
        substage: OnboardingOperationSubstage.verifyingDurableReadiness,
        progress: null,
      );
      final proof = await ref
          .read(onboardingDurableCompletionVerifierProvider)
          .verifyInstallationReady();
      await operationController.complete(
        operationId: operationId,
        proof: proof,
      );
      _setWorkflowOverride(completionStatus);
    } catch (error, stackTrace) {
      if (operationController.current.status ==
              OnboardingOperationStatus.running &&
          operationController.current.operationId == operationId) {
        await operationController.fail(
          operationId: operationId,
          category:
              OnboardingOperationFailureCategory.durableReadinessVerification,
          summary: error.toString(),
          recoveryDisposition:
              OnboardingOperationRecoveryDisposition.retryFromSafeBoundary,
        );
      }
      _enterPreparationFailure(
        error: error,
        stackTrace: stackTrace,
        logMessage: 'Durable onboarding completion verification failed',
      );
    }
  }

  void _finishFirstRunWithFailure() {
    ref
        .read(appLoggerProvider.notifier)
        .warn(
          'Fresh onboarding conversation graph build failed; returning to awaiting user action',
          source: 'OnboardingJourneyCoordinator',
        );
    _clearWorkflowOverride();
    ref.invalidate(onboardingEnvironmentReportProvider);
    _setWorkflowOverride(OnboardingStatus.awaitingUserAction);
  }

  void _finishReimportWithFailure() {
    ref
        .read(appLoggerProvider.notifier)
        .warn(
          'Settings-triggered reimport failed; returning to awaiting user action',
          source: 'OnboardingJourneyCoordinator',
        );
    _clearWorkflowOverride();
    ref.invalidate(onboardingEnvironmentReportProvider);
    _setWorkflowOverride(OnboardingStatus.awaitingUserAction);
  }
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
