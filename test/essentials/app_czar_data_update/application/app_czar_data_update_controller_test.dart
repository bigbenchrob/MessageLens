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
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_report.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/live_graph_update_worker.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart'
    show AttachmentArchiveMutationDeferredReason;
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
      await Future<void>.value();
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

  test('stop before scheduled execution constructs no executor', () async {
    var constructions = 0;
    final restarter = _RecordingRestarter();
    final container = ProviderContainer(
      overrides: [
        appCzarAssessmentControllerProvider.overrideWith(
          _SelectedAssessment.new,
        ),
        appCzarDataUpdateExecutorProvider.overrideWith((ref) {
          constructions++;
          return _ControlledExecutor();
        }),
        appCzarProcessRestarterProvider.overrideWithValue(restarter),
      ],
    );
    addTearDown(container.dispose);
    final owner = container.read(appCzarDataUpdateControllerProvider.notifier);
    await Future.wait([owner.stopAndDrain(), owner.stopAndDrain()]);
    expect(constructions, 0);
    expect(restarter.calls, 0);
  });

  for (final stage in ['prerequisite', 'graph', 'preservation']) {
    test('stop during $stage waits for executor settlement', () async {
      final executor = _ControlledExecutor(phased: true);
      final fixture = _lifecycleFixture(executor: executor);
      final owner = fixture.container.read(
        appCzarDataUpdateControllerProvider.notifier,
      );
      final stageIndex = [
        'prerequisite',
        'graph',
        'preservation',
      ].indexOf(stage);
      for (var index = 0; index < stageIndex; index++) {
        await executor.entered[index].future;
        executor.phases[index].complete();
      }
      await executor.entered[stageIndex].future;
      final before = fixture.container.read(
        appCzarDataUpdateControllerProvider,
      );
      var drained = false;
      final first = owner.stopAndDrain().then((_) {
        drained = true;
      });
      final second = owner.stopAndDrain();
      fixture.executor.observer?.call(
        const LiveGraphUpdateObservation.preservingAttachments(),
      );
      await Future<void>.value();
      expect(drained, isFalse);
      expect(fixture.restarter.calls, 0);
      expect(
        fixture.container.read(appCzarDataUpdateControllerProvider),
        same(before),
      );
      for (var index = stageIndex; index < executor.phases.length; index++) {
        executor.phases[index].complete();
        if (index + 1 < executor.phases.length) {
          await executor.entered[index + 1].future;
          expect(drained, isFalse);
          expect(fixture.restarter.calls, 0);
        }
      }
      fixture.executor.result.complete(await _SuccessfulExecutor().run());
      await Future.wait([first, second]);
      expect(drained, isTrue);
      expect(fixture.restarter.calls, 0);
      expect(fixture.executor.calls, 1);
    });
  }

  test(
    'deferred preservation fails and still permits explicit restart',
    () async {
      final fixture = _lifecycleFixture();
      await fixture.executor.started.future;
      final successful = await _SuccessfulExecutor().run();
      final failed = _waitForPhase(
        fixture.container,
        AppCzarDataUpdatePhase.failed,
      );
      fixture.executor.result.complete(
        LiveGraphUpdateResult(
          prerequisites: successful.prerequisites,
          decision: successful.decision,
          graphBuildReport: successful.graphBuildReport,
          attachmentResult: const AttachmentArchiveResult.deferred(
            AttachmentArchiveMutationDeferredReason.customArchiveUnavailable,
          ),
        ),
      );
      await failed;
      expect(
        fixture.container.read(appCzarDataUpdateControllerProvider).failure,
        contains('deferred'),
      );
      expect(fixture.restarter.calls, 0);
      await fixture.container
          .read(appCzarDataUpdateControllerProvider.notifier)
          .restartAndReassess();
      expect(fixture.restarter.calls, 1);
    },
  );

  test(
    'dormant controller constructs neither executor nor restarter',
    () async {
      var constructions = 0;
      final container = ProviderContainer(
        overrides: [
          appCzarAssessmentControllerProvider.overrideWith(
            _DormantAssessment.new,
          ),
          appCzarDataUpdateExecutorProvider.overrideWith((ref) {
            constructions++;
            return _ControlledExecutor();
          }),
          appCzarProcessRestarterProvider.overrideWith((ref) {
            constructions++;
            return _RecordingRestarter();
          }),
        ],
      );
      addTearDown(container.dispose);
      final owner = container.read(
        appCzarDataUpdateControllerProvider.notifier,
      );
      await owner.stopAndDrain();
      expect(constructions, 0);
    },
  );

  test('success racing stop cannot dispatch restart', () async {
    final fixture = _lifecycleFixture();
    final owner = fixture.container.read(
      appCzarDataUpdateControllerProvider.notifier,
    );
    await fixture.executor.started.future;
    fixture.executor.result.complete(await _SuccessfulExecutor().run());
    await owner.stopAndDrain();
    expect(fixture.restarter.calls, 0);
  });

  test('restarter reenters drain without awaiting itself', () async {
    late AppCzarDataUpdateController owner;
    final restarter = _RecordingRestarter(
      onRestart: () async {
        await owner.stopAndDrain();
      },
    );
    final fixture = _lifecycleFixture(restarter: restarter);
    owner = fixture.container.read(
      appCzarDataUpdateControllerProvider.notifier,
    );
    await fixture.executor.started.future;
    fixture.executor.result.complete(await _SuccessfulExecutor().run());
    await restarter.called.future;
    expect(restarter.calls, 1);
  });

  test('worker error, duplicate manual restart, and quit race', () async {
    final fixture = _lifecycleFixture();
    final owner = fixture.container.read(
      appCzarDataUpdateControllerProvider.notifier,
    );
    await fixture.executor.started.future;
    final failed = _waitForPhase(
      fixture.container,
      AppCzarDataUpdatePhase.failed,
    );
    fixture.executor.result.completeError(
      StateError('synthetic worker failure'),
    );
    await failed;
    final one = owner.restartAndReassess();
    final two = owner.restartAndReassess();
    await expectLater(owner.stopAndDrain(), throwsStateError);
    await Future.wait([one, two]);
    expect(fixture.restarter.calls, 0);
  });

  test('duplicate manual restart shares one dispatch', () async {
    final fixture = _lifecycleFixture();
    final owner = fixture.container.read(
      appCzarDataUpdateControllerProvider.notifier,
    );
    await fixture.executor.started.future;
    final failed = _waitForPhase(
      fixture.container,
      AppCzarDataUpdatePhase.failed,
    );
    fixture.executor.result.completeError(
      StateError('synthetic worker failure'),
    );
    await failed;
    await Future.wait([owner.restartAndReassess(), owner.restartAndReassess()]);
    expect(fixture.restarter.calls, 1);
  });

  test(
    'restarter failure is factual and never automatically retried',
    () async {
      final restarter = _RecordingRestarter(
        onRestart: () {
          throw StateError('inert restart failure');
        },
      );
      final fixture = _lifecycleFixture(restarter: restarter);
      fixture.container.read(appCzarDataUpdateControllerProvider);
      await fixture.executor.started.future;
      final failed = _waitForPhase(
        fixture.container,
        AppCzarDataUpdatePhase.failed,
      );
      fixture.executor.result.complete(await _SuccessfulExecutor().run());
      await failed;
      expect(
        fixture.container.read(appCzarDataUpdateControllerProvider).failure,
        contains('inert restart failure'),
      );
      expect(restarter.calls, 1);
      await fixture.container
          .read(appCzarDataUpdateControllerProvider.notifier)
          .stopAndDrain();
      expect(restarter.calls, 1);
    },
  );

  test('assessment replacement suppresses late results and restart', () async {
    final fixture = _lifecycleFixture();
    final owner = fixture.container.read(
      appCzarDataUpdateControllerProvider.notifier,
    );
    await fixture.executor.started.future;
    (fixture.container.read(appCzarAssessmentControllerProvider.notifier)
            as _SelectedAssessment)
        .replace();
    final before = fixture.container.read(appCzarDataUpdateControllerProvider);
    fixture.executor.observer?.call(
      const LiveGraphUpdateObservation.preservingAttachments(),
    );
    fixture.executor.result.complete(await _SuccessfulExecutor().run());
    await owner.stopAndDrain();
    expect(
      fixture.container.read(appCzarDataUpdateControllerProvider),
      same(before),
    );
    expect(fixture.restarter.calls, 0);
  });

  test('disposal suppresses late callback and failure publication', () async {
    final fixture = _lifecycleFixture(disposeAtTeardown: false);
    final owner = fixture.container.read(
      appCzarDataUpdateControllerProvider.notifier,
    );
    await fixture.executor.started.future;
    fixture.container.dispose();
    fixture.executor.observer?.call(
      const LiveGraphUpdateObservation.preservingAttachments(),
    );
    fixture.executor.result.completeError(StateError('after disposal'));
    await expectLater(owner.stopAndDrain(), throwsStateError);
    expect(fixture.restarter.calls, 0);
  });

  test('unsettled executor cannot produce quiescence', () async {
    final fixture = _lifecycleFixture();
    final owner = fixture.container.read(
      appCzarDataUpdateControllerProvider.notifier,
    );
    await fixture.executor.started.future;
    var settled = false;
    final drain = owner.stopAndDrain().then((_) {
      settled = true;
    });
    await Future<void>.value();
    expect(settled, isFalse);
    await owner.restartAndReassess();
    expect(settled, isFalse);
    expect(fixture.restarter.calls, 0);
    // Explicit cleanup; before this release no completion was possible.
    fixture.executor.result.complete(await _SuccessfulExecutor().run());
    await drain;
  });

  test('characterization: scheduled worker waits before restart', () async {
    final executor = _ControlledExecutor();
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
    expect(executor.calls, 0);
    await executor.started.future;
    expect(restarter.calls, 0);
    executor.result.complete(await _SuccessfulExecutor().run());
    await restarter.called.future;
    expect(executor.calls, 1);
    expect(restarter.calls, 1);
  });
}

Future<void> _waitForPhase(
  ProviderContainer container,
  AppCzarDataUpdatePhase phase,
) async {
  final reached = Completer<void>();
  final subscription = container.listen(appCzarDataUpdateControllerProvider, (
    _,
    next,
  ) {
    if (next.phase == phase && !reached.isCompleted) {
      reached.complete();
    }
  }, fireImmediately: true);
  try {
    await reached.future;
  } finally {
    subscription.close();
  }
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
    await Future<void>.value();
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

  final FutureOr<void> Function()? onRestart;
  final Completer<void> called = Completer<void>();
  int calls = 0;

  @override
  Future<void> restartAndReassess() async {
    calls++;
    await onRestart?.call();
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

final class _ControlledExecutor implements AppCzarDataUpdateExecutor {
  _ControlledExecutor({this.phased = false});
  final bool phased;
  final phases = List.generate(3, (_) => Completer<void>());
  final entered = List.generate(3, (_) => Completer<void>());
  final started = Completer<void>();
  final result = Completer<LiveGraphUpdateResult>();
  int calls = 0;
  LiveGraphUpdateObserver? observer;
  @override
  Future<LiveGraphUpdateResult> run({
    LiveGraphUpdateObserver? onObservation,
  }) async {
    calls++;
    observer = onObservation;
    started.complete();
    if (phased) {
      for (var index = 0; index < phases.length; index++) {
        entered[index].complete();
        await phases[index].future;
      }
    }
    return result.future;
  }
}

final class _SelectedAssessment extends AppCzarAssessmentController {
  @override
  AppCzarAssessmentState build() => AppCzarAssessmentState(
    generation: 7,
    assessment: AppCzarAssessment(
      facts: const [],
      diagnosisKind: AppCzarDiagnosisKind.sourceAheadOfLocal,
      diagnosis: 'synthetic',
      virtualCoordinator: AppCzarVirtualCoordinator.dataUpdate,
    ),
  );
  void replace() {
    state = AppCzarAssessmentState.initial(8);
  }
}

({
  ProviderContainer container,
  _ControlledExecutor executor,
  _RecordingRestarter restarter,
})
_lifecycleFixture({
  _RecordingRestarter? restarter,
  _ControlledExecutor? executor,
  bool disposeAtTeardown = true,
}) {
  executor ??= _ControlledExecutor();
  final restart = restarter ?? _RecordingRestarter();
  final container = ProviderContainer(
    overrides: [
      appCzarAssessmentControllerProvider.overrideWith(_SelectedAssessment.new),
      appCzarDataUpdateExecutorProvider.overrideWithValue(executor),
      appCzarProcessRestarterProvider.overrideWithValue(restart),
    ],
  );
  if (disposeAtTeardown) {
    addTearDown(container.dispose);
  }
  final subscription = container.listen(
    appCzarDataUpdateControllerProvider,
    (_, _) {},
    fireImmediately: true,
  );
  if (disposeAtTeardown) {
    addTearDown(subscription.close);
  }
  return (container: container, executor: executor, restarter: restart);
}

final class _DormantAssessment extends AppCzarAssessmentController {
  @override
  AppCzarAssessmentState build() => AppCzarAssessmentState.initial(0);
}
