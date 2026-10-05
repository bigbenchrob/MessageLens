import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_data_update_controller.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_data_update_executor_provider.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/domain/app_czar_data_update_state.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_report.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/live_graph_update_worker.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_service_provider.dart';

void main() {
  test('only the Data Update virtual mapping is executable', () {
    for (final coordinator in AppCzarVirtualCoordinator.values) {
      final state = AppCzarAssessmentState(
        generation: 4,
        assessment: AppCzarAssessment(
          facts: const <AppCzarFact>[],
          diagnosisKind: AppCzarDiagnosisKind.sourceAheadOfLocal,
          diagnosis: 'test diagnosis',
          virtualCoordinator: coordinator,
        ),
      );

      expect(
        shouldExecuteAppCzarDataUpdate(state),
        coordinator == AppCzarVirtualCoordinator.dataUpdate,
        reason:
            '${coordinator.name} must remain virtual unless it is dataUpdate',
      );
    }
  });

  test(
    'one Data Update assessment creates one execution and one restart',
    () async {
      final executor = _SuccessfulExecutor();
      final restarter = _RecordingRestarter(
        onRestart: () {
          expect(executor.active, isFalse);
        },
      );
      final container = ProviderContainer(
        overrides: [
          appCzarObservationReaderProvider.overrideWithValue(
            const _DataUpdateReader(),
          ),
          appCzarDataUpdateExecutorProvider.overrideWithValue(executor),
          appCzarProcessRestarterProvider.overrideWithValue(restarter),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarDataUpdateControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await restarter.called.future.timeout(const Duration(seconds: 2));

      final state = container.read(appCzarDataUpdateControllerProvider);
      expect(state.phase, AppCzarDataUpdatePhase.restartRequested);
      expect(state.sourceMessageCount, 108);
      expect(state.localMessageCount, 100);
      expect(state.messagesToImport, 8);
      expect(state.attachmentsExamined, 1);
      expect(state.attachmentsPreserved, 1);
      expect(executor.calls, 1);
      expect(restarter.calls, 1);

      await container
          .read(appCzarAssessmentControllerProvider.notifier)
          .runAgain();
      await Future<void>.delayed(Duration.zero);
      expect(executor.calls, 1);
      expect(restarter.calls, 1);
    },
  );

  test('worker failure stays factual and requires explicit restart', () async {
    final executor = _FailingExecutor();
    final restarter = _RecordingRestarter();
    final container = ProviderContainer(
      overrides: [
        appCzarObservationReaderProvider.overrideWithValue(
          const _DataUpdateReader(),
        ),
        appCzarDataUpdateExecutorProvider.overrideWithValue(executor),
        appCzarProcessRestarterProvider.overrideWithValue(restarter),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      appCzarDataUpdateControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await _waitForPhase(container, AppCzarDataUpdatePhase.failed);

    final failed = container.read(appCzarDataUpdateControllerProvider);
    expect(failed.failure, contains('source became unavailable'));
    expect(executor.calls, 1);
    expect(restarter.calls, 0);
    expect(
      container
          .read(appCzarAssessmentControllerProvider)
          .assessment
          ?.virtualCoordinator,
      AppCzarVirtualCoordinator.dataUpdate,
    );

    await container
        .read(appCzarDataUpdateControllerProvider.notifier)
        .restartAndReassess();
    expect(restarter.calls, 1);
  });

  test(
    'restart is requested only after the mutation tenure is released',
    () async {
      late ProviderContainer container;
      final restarter = _RecordingRestarter(
        onRestart: () {
          final mutation = container.read(archiveMutationCoordinatorProvider);
          expect(mutation.isLocked, isFalse);
          expect(mutation.holdCount, 0);
          expect(mutation.lastReleasedAtUtc, isNotNull);
        },
      );
      final worker = LiveGraphUpdateWorker(
        readPrerequisites: () async {
          return const LiveGraphUpdatePrerequisiteSnapshot(
            appDataReady: true,
            liveMaxRowId: 108,
            importedMaxSourceRowId: 100,
            liveImportableMessageCount: 108,
            importedMessageCount: 100,
          );
        },
        runGraphBuild: (_) async => _report(),
        preserveAttachments: (_) async {
          return const AttachmentArchiveResult(
            totalScanned: 1,
            newlyArchived: 1,
            skipped: 0,
            failed: 0,
          );
        },
      );
      container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            _testAuthority(),
          ),
          appCzarObservationReaderProvider.overrideWithValue(
            const _DataUpdateReader(),
          ),
          liveGraphUpdateWorkerProvider.overrideWith((ref) async => worker),
          appCzarProcessRestarterProvider.overrideWithValue(restarter),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarDataUpdateControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await restarter.called.future.timeout(const Duration(seconds: 2));

      expect(restarter.calls, 1);
      expect(
        container.read(appCzarDataUpdateControllerProvider).phase,
        AppCzarDataUpdatePhase.restartRequested,
      );
    },
  );
}

Future<void> _waitForPhase(
  ProviderContainer container,
  AppCzarDataUpdatePhase phase,
) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (container.read(appCzarDataUpdateControllerProvider).phase == phase) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Timed out waiting for ${phase.name}.');
}

final class _SuccessfulExecutor implements AppCzarDataUpdateExecutor {
  int calls = 0;
  bool active = false;

  @override
  Future<LiveGraphUpdateResult> run({
    LiveGraphUpdateObserver? onObservation,
  }) async {
    calls++;
    active = true;
    const prerequisites = LiveGraphUpdatePrerequisiteSnapshot(
      appDataReady: true,
      liveMaxRowId: 108,
      importedMaxSourceRowId: 100,
      liveImportableMessageCount: 108,
      importedMessageCount: 100,
    );
    onObservation?.call(
      const LiveGraphUpdateObservation.checkingPrerequisites(),
    );
    onObservation?.call(
      const LiveGraphUpdateObservation.prerequisitesRead(prerequisites),
    );
    onObservation?.call(
      const LiveGraphUpdateObservation.preservingAttachments(),
    );
    const attachments = AttachmentArchiveResult(
      totalScanned: 1,
      newlyArchived: 1,
      skipped: 0,
      failed: 0,
    );
    onObservation?.call(
      const LiveGraphUpdateObservation.attachmentsPreserved(attachments),
    );
    await Future<void>.delayed(Duration.zero);
    active = false;
    return LiveGraphUpdateResult(
      prerequisites: prerequisites,
      decision: const StartupProbeDecision(
        shouldSchedule: true,
        reason: 'source cursor advanced',
        trigger: StartupProbeTrigger.rowIdAdvanced,
      ),
      graphBuildReport: _report(),
      attachmentResult: attachments,
    );
  }
}

final class _FailingExecutor implements AppCzarDataUpdateExecutor {
  int calls = 0;

  @override
  Future<LiveGraphUpdateResult> run({
    LiveGraphUpdateObserver? onObservation,
  }) async {
    calls++;
    throw StateError('source became unavailable before mutation');
  }
}

final class _RecordingRestarter implements AppCzarProcessRestarter {
  _RecordingRestarter({this.onRestart});

  final void Function()? onRestart;
  final Completer<void> called = Completer<void>();
  int calls = 0;

  @override
  Future<void> restartAndReassess() async {
    calls++;
    onRestart?.call();
    if (!called.isCompleted) {
      called.complete();
    }
  }
}

final class _DataUpdateReader implements AppCzarObservationReader {
  const _DataUpdateReader();

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    return const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Test archive',
      archiveScopeIdentity: 'test-scope',
      archiveGeneration: 0,
      coverage: _completeCoverage,
      repairability: _completeRepairability,
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async {
    return const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 3,
      messageCount: 100,
      chatCount: 4,
      chatMessageEdgeCount: 100,
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() async {
    return const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 10,
      messageCount: 100,
      liveMessageCount: 100,
      liveMaxSourceRowId: 100,
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readOverlay() async {
    return const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 8,
    );
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    return const AppCzarRootObservation(admitted: true, path: '/tmp/test-root');
  }

  @override
  Future<AppCzarSourceObservation> readSource() async {
    return const AppCzarSourceObservation(
      condition: AppCzarSourceCondition.readable,
      messageCount: 108,
      maxRowId: 108,
      sampleStable: true,
    );
  }
}

const _completeCoverage = AppCzarAttachmentCoverageObservation(
  condition: AppCzarAttachmentCoverageCondition.complete,
  requiredCount: 1,
  coveredCount: 1,
  missingCount: 0,
  unverifiableCount: 0,
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
);

const _completeRepairability = AppCzarAttachmentRepairabilityObservation(
  condition: AppCzarAttachmentRepairOpportunityCondition.absent,
  availableFromMessagesCount: 0,
  sourceAbsentCount: 0,
  sourceUnknownCount: 0,
  recordBackedRecoveryCount: 0,
  unsafeOrConflictingCount: 0,
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
);

ArchiveAccessAuthority _testAuthority() {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.test,
      buildIdentity: ArchiveBuildIdentity.testHarness,
      archiveInstanceId: ArchiveInstanceId(
        '22222222-2222-4222-8222-222222222222',
      ),
      canonicalRootPath: '/tmp/app-czar-controller-test',
      bundleIdentifier: 'test.bundle',
      productName: 'MessageLens Test',
    ),
  );
}

ConversationGraphBuildReport _report() {
  final startedAt = DateTime.utc(2026, 10, 2, 12);
  return ConversationGraphBuildReport(
    startedAt: startedAt,
    finishedAt: startedAt.add(const Duration(seconds: 1)),
    completedStageNames: const <String>['import_messages', 'project_messages'],
    stageTimings: const <ConversationGraphBuildStageTiming>[],
    messageImportResult: const MessageImportResult(
      startedAfterSourceRowId: 100,
      insertedMessageCount: 8,
      lastImportedSourceRowId: 108,
    ),
    richTextEnrichmentResult: const MessageRichTextEnrichmentResult(
      candidateMessageCount: 8,
      enrichedMessageCount: 8,
      missingExtractionCount: 0,
      extractorAvailable: true,
    ),
    messageProjectionResult: const MessageProjectionResult(
      examinedMessageCount: 8,
      insertedMessageCount: 8,
    ),
  );
}
