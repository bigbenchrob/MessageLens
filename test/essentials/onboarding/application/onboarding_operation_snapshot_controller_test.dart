import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_controller.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_store.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_import_anomaly_counts.dart';

void main() {
  late _MemorySnapshotStore store;
  late _TestClock clock;
  late OnboardingOperationSnapshotController controller;

  setUp(() async {
    store = _MemorySnapshotStore();
    clock = _TestClock();
    controller = _controller(
      store: store,
      sessionId: '123e4567-e89b-42d3-a456-426614174001',
      operationId: '123e4567-e89b-42d3-a456-426614174010',
      clock: clock,
    );
    await controller.initialize();
  });

  tearDown(() async {
    await controller.dispose();
  });

  Future<void> interruptIntoNewProcess() async {
    await _begin(controller);
    await controller.dispose();
    controller = _controller(
      store: store,
      sessionId: '123e4567-e89b-42d3-a456-426614174002',
      operationId: '123e4567-e89b-42d3-a456-426614174011',
      clock: clock,
    );
    await controller.initialize();
  }

  test('begin, stage transition, and real progress are persisted', () async {
    final operationId = await controller.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.environmentPreparation,
    );
    clock.advance();
    await controller.enterStage(
      operationId: operationId,
      stage: OnboardingOperationStage.messageDataBuild,
    );
    clock.advance();
    await controller.reportProgress(
      operationId: operationId,
      progress: const OnboardingOperationProgress(
        completedWorkUnits: 10,
        totalWorkUnits: 20,
        anomalyCounts: SourceImportAnomalyCounts(
          preservedUnnormalizedHandleCount: 1,
        ),
      ),
    );

    expect(controller.current.status, OnboardingOperationStatus.running);
    expect(controller.current.completedStages, <OnboardingOperationStage>[
      OnboardingOperationStage.environmentPreparation,
    ]);
    expect(controller.current.progress?.completedWorkUnits, 10);
    expect(controller.current.progress?.preservedUnnormalizedCount, 1);
    expect(controller.current.preservedUnnormalizedHandleCount, 1);
    expect(controller.current.progressRevision, 3);
    expect(store.writeCount, 3);
  });

  test('synchronous stage exception remains coordinator-owned', () async {
    final operationId = await _begin(controller);

    await expectLater(
      controller.runStage<void>(
        operationId: operationId,
        stage: OnboardingOperationStage.messageDataBuild,
        action: (_) {
          throw StateError('synchronous failure');
        },
      ),
      throwsStateError,
    );

    expect(controller.current.status, OnboardingOperationStatus.running);
    expect(controller.current.failure, isNull);
  });

  test('asynchronous Future failure remains coordinator-owned', () async {
    final operationId = await _begin(controller);

    await expectLater(
      controller.runStage<void>(
        operationId: operationId,
        stage: OnboardingOperationStage.messageDataBuild,
        action: (_) async {
          await Future<void>.delayed(Duration.zero);
          throw StateError('asynchronous failure');
        },
      ),
      throwsStateError,
    );

    expect(controller.current.status, OnboardingOperationStatus.running);
    expect(controller.current.failure, isNull);
  });

  test('progress stream failure leaves a typed failure', () async {
    final operationId = await _begin(controller);
    final progress = StreamController<int>();

    final result = controller.runStage<void>(
      operationId: operationId,
      stage: OnboardingOperationStage.messageDataBuild,
      action: (reporter) async {
        await for (final completed in progress.stream) {
          await reporter.observe(
            substage: OnboardingOperationSubstage.importingMessages,
            completedWorkUnits: completed,
            totalWorkUnits: 10,
          );
        }
      },
    );
    final failureExpectation = expectLater(result, throwsStateError);
    progress.add(1);
    await Future<void>.delayed(Duration.zero);
    progress.addError(StateError('stream failure'));
    await progress.close();

    await failureExpectation;
    expect(controller.current.status, OnboardingOperationStatus.running);
    expect(controller.current.failure, isNull);
    expect(
      controller.current.currentSubstage,
      OnboardingOperationSubstage.importingMessages,
    );
    expect(controller.current.progress?.completedWorkUnits, 1);
  });

  test('completion requires durable proof compatible with operation', () async {
    final operationId = await _begin(controller);
    await controller.reportProgress(
      operationId: operationId,
      progress: const OnboardingOperationProgress(
        completedWorkUnits: 1,
        totalWorkUnits: 1,
        anomalyCounts: SourceImportAnomalyCounts(
          preservedUnnormalizedHandleCount: 1,
        ),
      ),
    );
    await controller.enterStage(
      operationId: operationId,
      stage: OnboardingOperationStage.durableReadinessVerification,
    );

    expect(
      () => controller.complete(
        operationId: operationId,
        proof: OnboardingDerivedResetCompletedProof(verifiedAtUtc: clock.now()),
      ),
      throwsStateError,
    );

    await controller.complete(
      operationId: operationId,
      proof: OnboardingInstallationReadyProof(
        verifiedAtUtc: clock.now(),
        sourceScopedImportRows: 100,
        conversationGraphRows: 100,
      ),
    );

    expect(controller.current.status, OnboardingOperationStatus.completed);
    expect(controller.current.preservedUnnormalizedHandleCount, 1);
    expect(
      controller.current.completedStages,
      contains(OnboardingOperationStage.durableReadinessVerification),
    );
  });

  test('new process converts persisted running to interrupted', () async {
    await _begin(controller);
    await controller.dispose();

    controller = _controller(
      store: store,
      sessionId: '123e4567-e89b-42d3-a456-426614174002',
      operationId: '123e4567-e89b-42d3-a456-426614174011',
      clock: clock,
    );
    await controller.initialize();

    expect(controller.current.status, OnboardingOperationStatus.interrupted);
    expect(controller.current.failure, isNull);
  });

  test('resume retains UUID and moves evidence to current session', () async {
    final operationId = await _begin(controller);
    await controller.dispose();

    final resumedSession = OnboardingProcessSessionId(
      '123e4567-e89b-42d3-a456-426614174002',
    );
    controller = OnboardingOperationSnapshotController(
      store: store,
      processSessionId: resumedSession,
      now: clock.now,
      newOperationId: () => '123e4567-e89b-42d3-a456-426614174011',
    );
    await controller.initialize();
    final interruptedRevision = controller.current.progressRevision;

    final resumedId = await controller.resume(operationId: operationId);

    expect(resumedId, operationId);
    expect(controller.current.operationId, operationId);
    expect(controller.current.status, OnboardingOperationStatus.running);
    expect(controller.current.processSessionId, resumedSession);
    expect(controller.current.progressRevision, interruptedRevision + 1);
  });

  test('durable completion truth overrides interrupted snapshot', () async {
    await interruptIntoNewProcess();

    await controller.reconcile(
      OnboardingDurableReconciliationEvidence.completed(
        proof: OnboardingInstallationReadyProof(
          verifiedAtUtc: clock.now(),
          sourceScopedImportRows: 200,
          conversationGraphRows: 180,
        ),
      ),
    );

    expect(controller.current.status, OnboardingOperationStatus.completed);
  });

  test(
    'resumable durable truth keeps interruption distinct from failure',
    () async {
      await interruptIntoNewProcess();

      await controller.reconcile(
        const OnboardingDurableReconciliationEvidence.resumable(),
      );

      expect(controller.current.status, OnboardingOperationStatus.interrupted);
    },
  );

  test('inconsistent durable truth creates typed terminal failure', () async {
    await interruptIntoNewProcess();

    await controller.reconcile(
      const OnboardingDurableReconciliationEvidence.inconsistent(
        failureSummary: 'Graph projection is incomplete.',
      ),
    );

    expect(controller.current.status, OnboardingOperationStatus.failed);
    expect(
      controller.current.failure?.category,
      OnboardingOperationFailureCategory.durableStateInconsistent,
    );
  });

  test('stale operation identity cannot publish progress', () async {
    await _begin(controller);

    await expectLater(
      controller.reportProgress(
        operationId: OnboardingOperationId(
          '123e4567-e89b-42d3-a456-426614174099',
        ),
        progress: null,
      ),
      throwsStateError,
    );
  });

  test('representative progress cadence remains bounded', () async {
    final operationId = await _begin(controller);
    for (var batch = 1; batch <= 20; batch += 1) {
      await controller.reportProgress(
        operationId: operationId,
        progress: OnboardingOperationProgress(
          completedWorkUnits: batch,
          totalWorkUnits: 20,
        ),
      );
    }

    expect(store.writeCount, 21);
    expect(store.writeCount, lessThan(1000));
  });

  test('identical substage progress is not persisted as new work', () async {
    final operationId = await _begin(controller);
    const progress = OnboardingOperationProgress(
      completedWorkUnits: 1000,
      totalWorkUnits: 2500,
      lastCompletedSourceRowId: 4000,
    );
    await controller.reportProgress(
      operationId: operationId,
      substage: OnboardingOperationSubstage.importingMessages,
      progress: progress,
    );
    final revisionAfterRealProgress = controller.current.progressRevision;
    final writesAfterRealProgress = store.writeCount;

    clock.advance();
    await controller.reportProgress(
      operationId: operationId,
      substage: OnboardingOperationSubstage.importingMessages,
      progress: progress,
    );

    expect(controller.current.progressRevision, revisionAfterRealProgress);
    expect(store.writeCount, writesAfterRealProgress);
  });
}

Future<OnboardingOperationId> _begin(
  OnboardingOperationSnapshotController controller,
) {
  return controller.begin(
    kind: OnboardingOperationKind.initialImport,
    initialStage: OnboardingOperationStage.environmentPreparation,
  );
}

OnboardingOperationSnapshotController _controller({
  required _MemorySnapshotStore store,
  required String sessionId,
  required String operationId,
  required _TestClock clock,
}) {
  return OnboardingOperationSnapshotController(
    store: store,
    processSessionId: OnboardingProcessSessionId(sessionId),
    now: clock.now,
    newOperationId: () => operationId,
  );
}

final class _MemorySnapshotStore implements OnboardingOperationSnapshotStore {
  OnboardingOperationSnapshot? snapshot;
  int writeCount = 0;

  @override
  Future<OnboardingOperationSnapshot?> load() async => snapshot;

  @override
  Future<void> save(OnboardingOperationSnapshot snapshot) async {
    writeCount += 1;
    this.snapshot = snapshot;
  }
}

final class _TestClock {
  DateTime _value = DateTime.utc(2026, 8, 23, 12);

  DateTime now() => _value;

  void advance() {
    _value = _value.add(const Duration(seconds: 1));
  }
}
