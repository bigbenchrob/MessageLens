import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_attachment_archive_repair/application/app_czar_attachment_archive_repair_controller.dart';
import 'package:remember_this_text/essentials/app_czar_attachment_archive_repair/application/app_czar_attachment_archive_repair_executor_provider.dart';
import 'package:remember_this_text/essentials/app_czar_attachment_archive_repair/domain/app_czar_attachment_archive_repair_models.dart';
import 'package:remember_this_text/essentials/app_czar_attachment_archive_repair/domain/app_czar_attachment_archive_repair_state.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart';

void main() {
  testWidgets(
    'Prompt 137 completed restart does not dispatch again on assessment events',
    (tester) async {
      final executor = _BarrierExecutor();
      final restart = _BarrierRestarter();
      final container = _fixedContainer(
        _QueueExecutorFactory([executor]),
        restart,
      );
      final owner = container.read(
        appCzarAttachmentArchiveRepairControllerProvider.notifier,
      );
      await tester.pump();
      executor.inspection.complete(_completeObservation());
      await tester.pump();
      restart.done.complete();
      await tester.pump();
      (container.read(appCzarAssessmentControllerProvider.notifier)
              as _FixedRepairAssessment)
          .replace(_repairAssessmentState(generation: 1));
      await tester.pump();
      await owner.retryRestart();
      await owner.stopAndDrain();
      container.dispose();
      expect(restart.calls, 1);
    },
  );

  testWidgets(
    'Prompt 137 stop revokes preservation scheduled before port entry',
    (tester) async {
      final executor = _BarrierExecutor();
      final restart = _BarrierRestarter();
      final container = _fixedContainer(
        _QueueExecutorFactory([executor]),
        restart,
      );
      final owner = container.read(
        appCzarAttachmentArchiveRepairControllerProvider.notifier,
      );
      await tester.pump();
      final authorization = _authorization(count: 1);
      executor.inspection.complete(
        _incompleteObservation(
          snapshot: _snapshot(
            available: 1,
            absent: 2,
            authorization: authorization,
          ),
        ),
      );
      await tester.pump();
      final action = owner.startPreservation(authorization);
      final stop = owner.stopAndDrain();
      await tester.pump();
      await Future.wait([action, stop]);
      container.dispose();
      expect(executor.preserveCalls, 0);
      expect(restart.calls, 0);
    },
  );

  testWidgets('Prompt 137 stop revokes queued human retry before port entry', (
    tester,
  ) async {
    final executor = _BarrierExecutor();
    final restart = _BarrierRestarter();
    final container = _fixedContainer(
      _QueueExecutorFactory([executor]),
      restart,
    );
    final owner = container.read(
      appCzarAttachmentArchiveRepairControllerProvider.notifier,
    );
    await tester.pump();
    executor.inspection.complete(_completeObservation());
    await tester.pump();
    restart.done.completeError(StateError('first restart failed'));
    await tester.pump();
    final retry = owner.retryRestart();
    final duplicate = owner.retryRestart();
    final stop = expectLater(owner.stopAndDrain(), throwsStateError);
    await tester.pump();
    await Future.wait([retry, duplicate, stop]);
    container.dispose();
    expect(restart.calls, 1);
  });

  testWidgets(
    'Prompt 137 disposal before scheduler prevents executor construction',
    (tester) async {
      final factory = _QueueExecutorFactory([_BarrierExecutor()]);
      final container = _fixedContainer(factory, _BarrierRestarter());
      final owner = container.read(
        appCzarAttachmentArchiveRepairControllerProvider.notifier,
      );
      container.dispose();
      await tester.pump();
      await owner.stopAndDrain();
      expect(factory.createCalls, 0);
    },
  );

  for (final failBatch in [false, true]) {
    testWidgets('Prompt 137 pending preservation drain failure=$failBatch', (
      tester,
    ) async {
      final executor = _BarrierExecutor();
      final restart = _BarrierRestarter();
      final factory = _QueueExecutorFactory([executor]);
      final container = _fixedContainer(factory, restart);
      final owner = container.read(
        appCzarAttachmentArchiveRepairControllerProvider.notifier,
      );
      await tester.pump();
      final authorization = _authorization(count: 1);
      executor.inspection.complete(
        _incompleteObservation(
          snapshot: _snapshot(
            available: 1,
            absent: 2,
            authorization: authorization,
          ),
        ),
      );
      await tester.pump();
      final action = owner.startPreservation(authorization);
      final duplicate = owner.startPreservation(authorization);
      await tester.pump();
      var settled = false;
      Object? failure;
      final drain = owner.stopAndDrain().then(
        (_) {
          settled = true;
        },
        onError: (Object e) {
          failure = e;
        },
      );
      final repeated = owner.stopAndDrain().then(
        (_) {},
        onError: (Object _) {},
      );
      await tester.pump();
      final pending = !settled && failure == null;
      final stoppedState = container.read(
        appCzarAttachmentArchiveRepairControllerProvider,
      );
      executor.progress?.call(
        const AppCzarAttachmentArchiveRepairProgress(
          completedCount: 1,
          totalCount: 1,
        ),
      );
      if (failBatch) {
        executor.preservation.completeError(StateError('inert batch failure'));
      } else {
        executor.preservation.complete(_completeObservation());
      }
      await tester.pump();
      await Future.wait([action, duplicate, drain, repeated]);
      await owner.startPreservation(authorization);
      await owner.checkAgain();
      await owner.retryRestart();
      final after = container.read(
        appCzarAttachmentArchiveRepairControllerProvider,
      );
      container.dispose();
      expect(pending, isTrue);
      expect(failure, failBatch ? isStateError : isNull);
      expect(settled, !failBatch);
      expect(identical(stoppedState, after), isTrue);
      expect(executor.preserveCalls, 1);
      expect(executor.stopCalls, 1);
      expect(factory.createCalls, 1);
      expect(restart.calls, 0);
    });
  }

  for (final failDrain in [false, true]) {
    testWidgets(
      'Prompt 137 check drain is owned and seals replacement failure=$failDrain',
      (tester) async {
        final executor = _BarrierExecutor()..drainBarrier = Completer<void>();
        final factory = _QueueExecutorFactory([executor]);
        final container = _fixedContainer(factory, _BarrierRestarter());
        final owner = container.read(
          appCzarAttachmentArchiveRepairControllerProvider.notifier,
        );
        await tester.pump();
        executor.inspection.complete(
          _incompleteObservation(snapshot: _snapshot(available: 0, absent: 3)),
        );
        await tester.pump();
        final check = owner.checkAgain();
        final duplicate = owner.checkAgain();
        await tester.pump();
        var finished = false;
        Object? failure;
        final stop = owner.stopAndDrain().then(
          (_) {
            finished = true;
          },
          onError: (Object e) {
            failure = e;
          },
        );
        await tester.pump();
        final pending = !finished && failure == null;
        if (failDrain) {
          executor.drainBarrier!.completeError(
            StateError('inert executor drain failure'),
          );
        } else {
          executor.drainBarrier!.complete();
        }
        await tester.pump();
        await Future.wait([check, duplicate, stop]);
        container.dispose();
        expect(pending, isTrue);
        expect(failure, failDrain ? isStateError : isNull);
        expect(factory.createCalls, 1);
        expect(executor.stopCalls, 1);
      },
    );
  }

  for (final duringPreservation in [false, true]) {
    testWidgets(
      'Prompt 137 stale assessment queued restart revoked batch=$duringPreservation',
      (tester) async {
        final executor = _BarrierExecutor();
        final restart = _BarrierRestarter();
        final factory = _QueueExecutorFactory([executor]);
        final container = _fixedContainer(factory, restart);
        final owner = container.read(
          appCzarAttachmentArchiveRepairControllerProvider.notifier,
        );
        await tester.pump();
        Future<void>? action;
        if (duringPreservation) {
          final auth = _authorization(count: 1);
          executor.inspection.complete(
            _incompleteObservation(
              snapshot: _snapshot(available: 1, absent: 2, authorization: auth),
            ),
          );
          await tester.pump();
          action = owner.startPreservation(auth);
          await tester.pump();
        }
        (container.read(appCzarAssessmentControllerProvider.notifier)
                as _FixedRepairAssessment)
            .replace(
              _repairAssessmentState(
                generation: 1,
                resolvedPath: '/synthetic/replacement',
              ),
            );
        await tester.pump();
        var finished = false;
        final stop = owner.stopAndDrain().then((_) {
          finished = true;
        });
        await tester.pump();
        final pending = !finished;
        (duringPreservation ? executor.preservation : executor.inspection)
            .complete(_completeObservation());
        await tester.pump();
        await action;
        await stop;
        container.dispose();
        expect(pending, isTrue);
        expect(restart.calls, 0);
        expect(factory.createCalls, 1);
      },
    );
  }

  for (final kind in [
    AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
    AppCzarAttachmentArchiveRepairObservationKind.sourceAccessLost,
    AppCzarAttachmentArchiveRepairObservationKind.archiveBindingChanged,
  ]) {
    testWidgets('Prompt 137 stopped terminal evidence cannot dispatch $kind', (
      tester,
    ) async {
      final executor = _BarrierExecutor();
      final restart = _BarrierRestarter();
      final container = _fixedContainer(
        _QueueExecutorFactory([executor]),
        restart,
      );
      final owner = container.read(
        appCzarAttachmentArchiveRepairControllerProvider.notifier,
      );
      await tester.pump();
      final stop = owner.stopAndDrain();
      executor.inspection.complete(
        AppCzarAttachmentArchiveRepairObservation(
          kind: kind,
          binding: _binding(),
        ),
      );
      await tester.pump();
      await stop;
      final state = container.read(
        appCzarAttachmentArchiveRepairControllerProvider,
      );
      container.dispose();
      expect(state.phase, AppCzarAttachmentArchiveRepairPhase.stopping);
      expect(state.snapshot, isNull);
      expect(restart.calls, 0);
    });
  }

  testWidgets(
    'Prompt 137 factory synchronous stop retains construction and drains returned executor',
    (tester) async {
      final executor = _BarrierExecutor()..drainBarrier = Completer<void>();
      final factory = _CallbackFactory(executor);
      final container = _fixedContainer(factory, _BarrierRestarter());
      final owner = container.read(
        appCzarAttachmentArchiveRepairControllerProvider.notifier,
      );
      var finished = false;
      Future<void>? stop;
      factory.onCreate = () {
        stop = owner.stopAndDrain().then((_) {
          finished = true;
        });
      };
      await tester.pump();
      final pending = !finished;
      executor.drainBarrier!.complete();
      await tester.pump();
      await stop;
      container.dispose();
      expect(pending, isTrue);
      expect(executor.inspectCalls, 0);
      expect(executor.stopCalls, 1);
    },
  );

  testWidgets(
    'Prompt 137 retry coalesces and active restart refuses ordinary quit',
    (tester) async {
      final executor = _BarrierExecutor();
      final restart = _BarrierRestarter();
      final container = _fixedContainer(
        _QueueExecutorFactory([executor]),
        restart,
      );
      final owner = container.read(
        appCzarAttachmentArchiveRepairControllerProvider.notifier,
      );
      await tester.pump();
      executor.inspection.complete(_completeObservation());
      await tester.pump();
      restart.done.completeError(StateError('inert restart failure'));
      await tester.pump();
      final failed = container
          .read(appCzarAttachmentArchiveRepairControllerProvider)
          .phase;
      restart.done = Completer<void>();
      final retry = owner.retryRestart();
      final duplicate = owner.retryRestart();
      await tester.pump();
      Object? refusal;
      await owner.stopAndDrain().then(
        (_) {},
        onError: (Object e) {
          refusal = e;
        },
      );
      final pending = !restart.done.isCompleted;
      restart.done.complete();
      await tester.pump();
      await Future.wait([retry, duplicate]);
      await owner.stopAndDrain();
      await owner.retryRestart();
      container.dispose();
      expect(failed, AppCzarAttachmentArchiveRepairPhase.restartFailed);
      expect(refusal, isStateError);
      expect(pending, isTrue);
      expect(restart.calls, 2);
    },
  );

  testWidgets('Prompt 137 late restart failure retained after permanent stop', (
    tester,
  ) async {
    final executor = _BarrierExecutor();
    final restart = _BarrierRestarter();
    final container = _fixedContainer(
      _QueueExecutorFactory([executor]),
      restart,
    );
    final owner = container.read(
      appCzarAttachmentArchiveRepairControllerProvider.notifier,
    );
    await tester.pump();
    executor.inspection.complete(_completeObservation());
    await tester.pump();
    await expectLater(owner.stopAndDrain(), throwsStateError);
    final stopped = container.read(
      appCzarAttachmentArchiveRepairControllerProvider,
    );
    restart.done.completeError(StateError('late restart failure'));
    await tester.pump();
    await expectLater(owner.stopAndDrain(), throwsStateError);
    await owner.retryRestart();
    expect(
      container
          .read(appCzarAttachmentArchiveRepairControllerProvider)
          .failureKind,
      stopped.failureKind,
    );
    container.dispose();
    expect(restart.calls, 1);
  });

  testWidgets('Prompt 137 disposal seals publication but drain still waits', (
    tester,
  ) async {
    final executor = _BarrierExecutor();
    final restart = _BarrierRestarter();
    final container = _fixedContainer(
      _QueueExecutorFactory([executor]),
      restart,
    );
    final owner = container.read(
      appCzarAttachmentArchiveRepairControllerProvider.notifier,
    );
    await tester.pump();
    container.dispose();
    var finished = false;
    final drain = owner.stopAndDrain().then((_) {
      finished = true;
    });
    await tester.pump();
    final pending = !finished;
    executor.inspection.complete(_completeObservation());
    await tester.pump();
    await drain;
    expect(pending, isTrue);
    expect(restart.calls, 0);
  });

  testWidgets('Prompt 137 stop before scheduler prevents construction', (
    tester,
  ) async {
    final executor = _BarrierExecutor();
    final factory = _QueueExecutorFactory([executor]);
    final container = _fixedContainer(factory, _BarrierRestarter());
    final owner = container.read(
      appCzarAttachmentArchiveRepairControllerProvider.notifier,
    );
    final drain = owner.stopAndDrain();
    await tester.pump();
    // Always release a legacy admitted inspection before asserting the red.
    executor.inspection.complete(_completeObservation());
    await drain;
    container.dispose();
    expect(factory.createCalls, 0);
    expect(executor.inspectCalls, 0);
  });

  testWidgets(
    'Prompt 137 reentrant active restart refuses without self-await',
    (tester) async {
      final executor = _BarrierExecutor();
      final restart = _BarrierRestarter();
      final container = _fixedContainer(
        _QueueExecutorFactory([executor]),
        restart,
      );
      final owner = container.read(
        appCzarAttachmentArchiveRepairControllerProvider.notifier,
      );
      Object? refusal;
      var drained = false;
      Future<void>? reentrant;
      restart.onEntry = () {
        reentrant = owner.stopAndDrain().then(
          (_) {
            drained = true;
          },
          onError: (Object error) {
            refusal = error;
          },
        );
      };
      await tester.pump();
      executor.inspection.complete(_completeObservation());
      await tester.pump();
      final refusedWhilePending = refusal is StateError;
      final drainedWhilePending = drained;
      restart.done.complete();
      await tester.pump();
      await reentrant;
      await owner.stopAndDrain();
      container.dispose();
      expect(restart.calls, 1);
      expect(drainedWhilePending, isFalse);
      expect(refusedWhilePending, isTrue);
    },
  );

  testWidgets('Prompt 137 pending inspection error is retained after stop', (
    tester,
  ) async {
    final executor = _BarrierExecutor();
    final restart = _BarrierRestarter();
    final container = _fixedContainer(
      _QueueExecutorFactory([executor]),
      restart,
    );
    final owner = container.read(
      appCzarAttachmentArchiveRepairControllerProvider.notifier,
    );
    await tester.pump();
    Object? failure;
    var finished = false;
    final drain = owner.stopAndDrain().then(
      (_) {
        finished = true;
      },
      onError: (Object error) {
        failure = error;
      },
    );
    await tester.pump();
    final pending = !finished && failure == null;
    executor.inspection.completeError(StateError('inert inspection failure'));
    await tester.pump();
    await drain;
    container.dispose();
    expect(pending, isTrue);
    expect(failure, isStateError);
    expect(restart.calls, 0);
  });

  group('shouldExecuteAppCzarAttachmentArchiveRepair', () {
    test('accepts only coherently bound conclusive incomplete coverage', () {
      final state = _repairAssessmentState();
      expect(shouldExecuteAppCzarAttachmentArchiveRepair(state), isTrue);
      expect(
        shouldExecuteAppCzarAttachmentArchiveRepair(
          state,
          expectedAssessmentGeneration: 9,
        ),
        isFalse,
      );
    });

    test('rejects the other attachment-repair virtual diagnosis', () {
      expect(
        shouldExecuteAppCzarAttachmentArchiveRepair(
          _repairAssessmentState(
            diagnosisKind: AppCzarDiagnosisKind.attachmentArchiveUnavailable,
          ),
        ),
        isFalse,
      );
    });

    test('rejects conclusive source-absent-only coverage debt', () {
      expect(
        shouldExecuteAppCzarAttachmentArchiveRepair(
          _repairAssessmentState(
            repairOpportunityTruth: AppCzarTruth.falseValue,
            repairOpportunityCondition:
                AppCzarAttachmentRepairOpportunityCondition.absent,
            availableFromMessagesCount: 0,
            sourceAbsentCount: 3,
          ),
        ),
        isFalse,
      );
    });

    test('rejects UNKNOWN, duplicate, or missing required facts', () {
      expect(
        shouldExecuteAppCzarAttachmentArchiveRepair(
          _repairAssessmentState(coverageTruth: AppCzarTruth.unknown),
        ),
        isFalse,
      );
      expect(
        shouldExecuteAppCzarAttachmentArchiveRepair(
          _repairAssessmentState(archiveTruth: AppCzarTruth.unknown),
        ),
        isFalse,
      );
      expect(
        shouldExecuteAppCzarAttachmentArchiveRepair(
          _repairAssessmentState(duplicateCoverageFact: true),
        ),
        isFalse,
      );
      expect(
        shouldExecuteAppCzarAttachmentArchiveRepair(
          _repairAssessmentState(omitArchiveFact: true),
        ),
        isFalse,
      );
    });

    test('rejects incomplete or stale archive binding evidence', () {
      expect(
        shouldExecuteAppCzarAttachmentArchiveRepair(
          _repairAssessmentState(resolvedPath: '   '),
        ),
        isFalse,
      );
      expect(
        shouldExecuteAppCzarAttachmentArchiveRepair(
          _repairAssessmentState(scopeIdentity: ''),
        ),
        isFalse,
      );
      expect(
        shouldExecuteAppCzarAttachmentArchiveRepair(
          _repairAssessmentState(
            coverageCondition: AppCzarAttachmentCoverageCondition.unknown,
          ),
        ),
        isFalse,
      );
      expect(
        shouldExecuteAppCzarAttachmentArchiveRepair(
          _repairAssessmentState(coverageGeneration: 3),
        ),
        isFalse,
      );
    });
  });

  test(
    'fresh inspection publishes aggregates and waits for explicit preservation',
    () async {
      final executor = _FakeExecutor(
        inspection: _incompleteObservation(
          snapshot: _snapshot(available: 2, absent: 1),
        ),
        preservation: _completeObservation(),
      );
      final restarter = _RecordingRestarter(
        onRestart: () {
          expect(executor.active, isFalse);
        },
      );
      final container = _container(
        factory: _QueueExecutorFactory([executor]),
        restarter: restarter,
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarAttachmentArchiveRepairControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await _waitForPhase(
        container,
        AppCzarAttachmentArchiveRepairPhase.awaitingConfirmation,
      );
      final inspected = container.read(
        appCzarAttachmentArchiveRepairControllerProvider,
      );
      expect(inspected.snapshot?.requiredCount, 13);
      expect(inspected.snapshot?.coveredCount, 10);
      expect(inspected.snapshot?.needAttentionCount, 3);
      expect(inspected.snapshot?.nextBatchAuthorization?.itemCount, 2);
      expect(inspected.snapshot?.nextBatchAuthorization?.totalKnownBytes, 4096);
      expect(executor.inspectCalls, 1);
      expect(executor.preserveCalls, 0);
      expect(restarter.calls, 0);

      await container
          .read(appCzarAttachmentArchiveRepairControllerProvider.notifier)
          .startPreservation(inspected.snapshot!.nextBatchAuthorization!);

      expect(executor.preserveCalls, 1);
      expect(
        executor.receivedAuthorizations.single.planIdentity,
        'plan-current',
      );
      expect(executor.receivedAuthorizations.single.itemCount, 2);
      expect(executor.receivedAuthorizations.single.totalKnownBytes, 4096);
      expect(executor.stopCalls, 1);
      expect(restarter.calls, 1);
      expect(
        container.read(appCzarAttachmentArchiveRepairControllerProvider).phase,
        AppCzarAttachmentArchiveRepairPhase.restartRequested,
      );
    },
  );

  test(
    'unknown batch bytes remain visible but cannot admit mutation',
    () async {
      final executor = _FakeExecutor(
        inspection: _incompleteObservation(
          snapshot: _snapshot(
            available: 2,
            absent: 1,
            authorization: _authorization(count: 2, knownBytes: null),
          ),
        ),
      );
      final restarter = _RecordingRestarter();
      final container = _container(
        factory: _QueueExecutorFactory([executor]),
        restarter: restarter,
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarAttachmentArchiveRepairControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await _waitForPhase(
        container,
        AppCzarAttachmentArchiveRepairPhase.waitingForHuman,
      );
      final state = container.read(
        appCzarAttachmentArchiveRepairControllerProvider,
      );
      expect(state.snapshot?.nextBatchAuthorization?.itemCount, 2);
      expect(state.snapshot?.nextBatchAuthorization?.totalKnownBytes, isNull);
      expect(state.canStartPreservation, isFalse);

      await container
          .read(appCzarAttachmentArchiveRepairControllerProvider.notifier)
          .startPreservation(state.snapshot!.nextBatchAuthorization!);

      expect(executor.preserveCalls, 0);
      expect(restarter.calls, 0);
    },
  );

  test(
    'one confirmation executes one batch and requires the newly published plan',
    () async {
      final firstAuthorization = _authorization(
        identity: 'plan-first',
        count: 2,
        knownBytes: 4096,
      );
      final secondAuthorization = _authorization(
        identity: 'plan-second',
        count: 1,
        knownBytes: 512,
      );
      final executor = _FakeExecutor(
        inspection: _incompleteObservation(
          snapshot: _snapshot(
            available: 3,
            absent: 0,
            authorization: firstAuthorization,
          ),
        ),
        preservations: [
          _incompleteObservation(
            snapshot: _snapshot(
              available: 1,
              absent: 0,
              covered: 12,
              authorization: secondAuthorization,
            ),
          ),
          _completeObservation(),
        ],
      );
      final restarter = _RecordingRestarter();
      final container = _container(
        factory: _QueueExecutorFactory([executor]),
        restarter: restarter,
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarAttachmentArchiveRepairControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await _waitForPhase(
        container,
        AppCzarAttachmentArchiveRepairPhase.awaitingConfirmation,
      );
      final controller = container.read(
        appCzarAttachmentArchiveRepairControllerProvider.notifier,
      );
      await controller.startPreservation(firstAuthorization);

      final afterFirst = container.read(
        appCzarAttachmentArchiveRepairControllerProvider,
      );
      expect(
        afterFirst.phase,
        AppCzarAttachmentArchiveRepairPhase.awaitingConfirmation,
      );
      expect(
        afterFirst.snapshot?.nextBatchAuthorization,
        same(secondAuthorization),
      );
      expect(executor.preserveCalls, 1);
      expect(executor.receivedAuthorizations.single, same(firstAuthorization));
      expect(restarter.calls, 0);

      await controller.startPreservation(firstAuthorization);

      expect(executor.preserveCalls, 1);
      expect(
        container
            .read(appCzarAttachmentArchiveRepairControllerProvider)
            .snapshot
            ?.nextBatchAuthorization,
        same(secondAuthorization),
      );

      await controller.startPreservation(secondAuthorization);

      expect(executor.preserveCalls, 2);
      expect(executor.receivedAuthorizations[0], same(firstAuthorization));
      expect(executor.receivedAuthorizations[1], same(secondAuthorization));
      expect(restarter.calls, 1);
      expect(
        container.read(appCzarAttachmentArchiveRepairControllerProvider).phase,
        AppCzarAttachmentArchiveRepairPhase.restartRequested,
      );
    },
  );

  test('duplicate confirmation is single-flight', () async {
    final preservation = Completer<AppCzarAttachmentArchiveRepairObservation>();
    final executor = _FakeExecutor(
      inspection: _incompleteObservation(
        snapshot: _snapshot(available: 2, absent: 1),
      ),
      preservationCompleter: preservation,
    );
    final restarter = _RecordingRestarter();
    final container = _container(
      factory: _QueueExecutorFactory([executor]),
      restarter: restarter,
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      appCzarAttachmentArchiveRepairControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await _waitForPhase(
      container,
      AppCzarAttachmentArchiveRepairPhase.awaitingConfirmation,
    );
    final controller = container.read(
      appCzarAttachmentArchiveRepairControllerProvider.notifier,
    );
    final authorization = container
        .read(appCzarAttachmentArchiveRepairControllerProvider)
        .snapshot!
        .nextBatchAuthorization!;
    final first = controller.startPreservation(authorization);
    final duplicate = controller.startPreservation(authorization);
    await Future<void>.delayed(Duration.zero);

    expect(executor.preserveCalls, 1);
    preservation.complete(_completeObservation());
    await Future.wait([first, duplicate]);
    expect(executor.preserveCalls, 1);
    expect(restarter.calls, 1);
  });

  test(
    'unknown evidence after one authorized batch drains and restarts',
    () async {
      final executor = _FakeExecutor(
        inspection: _incompleteObservation(
          snapshot: _snapshot(available: 2, absent: 1),
        ),
        preservation: AppCzarAttachmentArchiveRepairObservation(
          kind: AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
          binding: _binding(),
        ),
      );
      final restarter = _RecordingRestarter(
        onRestart: () {
          expect(executor.active, isFalse);
        },
      );
      final container = _container(
        factory: _QueueExecutorFactory([executor]),
        restarter: restarter,
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarAttachmentArchiveRepairControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await _waitForPhase(
        container,
        AppCzarAttachmentArchiveRepairPhase.awaitingConfirmation,
      );
      await container
          .read(appCzarAttachmentArchiveRepairControllerProvider.notifier)
          .startPreservation(
            container
                .read(appCzarAttachmentArchiveRepairControllerProvider)
                .snapshot!
                .nextBatchAuthorization!,
          );

      expect(executor.preserveCalls, 1);
      expect(executor.stopCalls, 1);
      expect(restarter.calls, 1);
      expect(
        container.read(appCzarAttachmentArchiveRepairControllerProvider).phase,
        AppCzarAttachmentArchiveRepairPhase.restartRequested,
      );
    },
  );

  test('manual-only deficit remains visible without a restart loop', () async {
    final first = _FakeExecutor(
      inspection: _incompleteObservation(
        snapshot: _snapshot(available: 0, absent: 3),
      ),
    );
    final second = _FakeExecutor(
      inspection: _incompleteObservation(
        occurrenceId: 1,
        snapshot: _snapshot(available: 0, absent: 2, unknown: 1),
      ),
    );
    final factory = _QueueExecutorFactory([first, second]);
    final restarter = _RecordingRestarter();
    final container = _container(factory: factory, restarter: restarter);
    addTearDown(container.dispose);
    final subscription = container.listen(
      appCzarAttachmentArchiveRepairControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await _waitForPhase(
      container,
      AppCzarAttachmentArchiveRepairPhase.waitingForHuman,
    );
    expect(restarter.calls, 0);

    final controller = container.read(
      appCzarAttachmentArchiveRepairControllerProvider.notifier,
    );
    final firstCheck = controller.checkAgain();
    final duplicateCheck = controller.checkAgain();
    await Future.wait([firstCheck, duplicateCheck]);
    await _waitForPhase(
      container,
      AppCzarAttachmentArchiveRepairPhase.waitingForHuman,
    );

    expect(factory.createCalls, 2);
    expect(first.stopCalls, 1);
    expect(second.inspectCalls, 1);
    expect(restarter.calls, 0);
    expect(
      container
          .read(appCzarAttachmentArchiveRepairControllerProvider)
          .occurrenceId,
      1,
    );
  });

  test(
    'equivalent canonical archive path remains the current binding',
    () async {
      final executor = _FakeExecutor(
        inspection: _incompleteObservation(
          snapshot: _snapshot(available: 0, absent: 3),
        ),
      );
      final restarter = _RecordingRestarter();
      final container = _container(
        factory: _QueueExecutorFactory([executor]),
        restarter: restarter,
        observationReader: _RepairReader(
          resolvedPath: '/Volumes/Test/./attachment_archive/',
        ),
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarAttachmentArchiveRepairControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await _waitForPhase(
        container,
        AppCzarAttachmentArchiveRepairPhase.waitingForHuman,
      );

      expect(restarter.calls, 0);
      expect(executor.inspectCalls, 1);
    },
  );

  test('provider-driven archive binding change drains and restarts instead of '
      're-admitting in process', () async {
    final reader = _RepairReader();
    final inspection = Completer<AppCzarAttachmentArchiveRepairObservation>();
    final executor = _FakeExecutor(
      inspectionCompleter: inspection,
      stopObservation: AppCzarAttachmentArchiveRepairObservation(
        kind: AppCzarAttachmentArchiveRepairObservationKind.stopped,
        binding: _binding(),
      ),
    );
    final factory = _QueueExecutorFactory([executor]);
    final restarter = _RecordingRestarter(
      onRestart: () {
        expect(executor.active, isFalse);
      },
    );
    final container = _container(
      factory: factory,
      restarter: restarter,
      observationReader: reader,
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      appCzarAttachmentArchiveRepairControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await _waitForPhase(
      container,
      AppCzarAttachmentArchiveRepairPhase.inspecting,
    );
    expect(executor.active, isTrue);
    reader.resolvedPath = '/Volumes/Replacement/attachment_archive';
    await container
        .read(appCzarAssessmentControllerProvider.notifier)
        .runAgain();
    await _waitForPhase(
      container,
      AppCzarAttachmentArchiveRepairPhase.restartRequested,
    );

    expect(executor.stopCalls, 1);
    expect(executor.active, isFalse);
    expect(restarter.calls, 1);
    expect(factory.createCalls, 1);
    expect(
      container.read(appCzarAttachmentArchiveRepairControllerProvider).phase,
      AppCzarAttachmentArchiveRepairPhase.restartRequested,
    );
  });

  test(
    'factory failure can be retried as a fresh one-use occurrence',
    () async {
      final executor = _FakeExecutor(
        inspection: _incompleteObservation(
          occurrenceId: 1,
          snapshot: _snapshot(available: 0, absent: 3),
        ),
      );
      final factory = _InitiallyFailingExecutorFactory(executor);
      final restarter = _RecordingRestarter();
      final container = _container(factory: factory, restarter: restarter);
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarAttachmentArchiveRepairControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await _waitForPhase(
        container,
        AppCzarAttachmentArchiveRepairPhase.failed,
      );
      await container
          .read(appCzarAttachmentArchiveRepairControllerProvider.notifier)
          .checkAgain();
      await _waitForPhase(
        container,
        AppCzarAttachmentArchiveRepairPhase.waitingForHuman,
      );

      expect(factory.createCalls, 2);
      expect(executor.inspectCalls, 1);
      expect(restarter.calls, 0);
    },
  );

  for (final terminalKind in <AppCzarAttachmentArchiveRepairObservationKind>[
    AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
    AppCzarAttachmentArchiveRepairObservationKind.sourceAccessLost,
    AppCzarAttachmentArchiveRepairObservationKind.archiveBindingChanged,
  ]) {
    test('$terminalKind drains before fresh-process reassessment', () async {
      final executor = _FakeExecutor(
        inspection: AppCzarAttachmentArchiveRepairObservation(
          kind: terminalKind,
          binding: _binding(),
        ),
      );
      final restarter = _RecordingRestarter(
        onRestart: () {
          expect(executor.active, isFalse);
          expect(executor.stopCalls, 1);
        },
      );
      final container = _container(
        factory: _QueueExecutorFactory([executor]),
        restarter: restarter,
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarAttachmentArchiveRepairControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await _waitForPhase(
        container,
        AppCzarAttachmentArchiveRepairPhase.restartRequested,
      );
      expect(restarter.calls, 1);
    });
  }

  test('mismatched occurrence evidence fails closed through restart', () async {
    final executor = _FakeExecutor(
      inspection: _incompleteObservation(
        occurrenceId: 44,
        snapshot: _snapshot(available: 1, absent: 2),
      ),
    );
    final restarter = _RecordingRestarter();
    final container = _container(
      factory: _QueueExecutorFactory([executor]),
      restarter: restarter,
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      appCzarAttachmentArchiveRepairControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await _waitForPhase(
      container,
      AppCzarAttachmentArchiveRepairPhase.restartRequested,
    );
    expect(executor.preserveCalls, 0);
    expect(restarter.calls, 1);
  });

  test('stopAndDrain stops a pending occurrence without restarting', () async {
    final inspection = Completer<AppCzarAttachmentArchiveRepairObservation>();
    final executor = _FakeExecutor(
      inspectionCompleter: inspection,
      stopObservation: AppCzarAttachmentArchiveRepairObservation(
        kind: AppCzarAttachmentArchiveRepairObservationKind.stopped,
        binding: _binding(),
      ),
    );
    final restarter = _RecordingRestarter();
    final container = _container(
      factory: _QueueExecutorFactory([executor]),
      restarter: restarter,
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      appCzarAttachmentArchiveRepairControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await _waitForPhase(
      container,
      AppCzarAttachmentArchiveRepairPhase.inspecting,
    );
    await container
        .read(appCzarAttachmentArchiveRepairControllerProvider.notifier)
        .stopAndDrain();

    expect(executor.stopCalls, 1);
    expect(executor.active, isFalse);
    expect(restarter.calls, 0);
    expect(
      container.read(appCzarAttachmentArchiveRepairControllerProvider).phase,
      AppCzarAttachmentArchiveRepairPhase.stopping,
    );
  });
}

ProviderContainer _container({
  required AppCzarAttachmentArchiveRepairExecutorFactory factory,
  required AppCzarProcessRestarter restarter,
  AppCzarObservationReader? observationReader,
}) {
  return ProviderContainer(
    overrides: [
      appCzarObservationReaderProvider.overrideWithValue(
        observationReader ?? _RepairReader(),
      ),
      appCzarAttachmentArchiveRepairExecutorFactoryProvider.overrideWithValue(
        factory,
      ),
      appCzarProcessRestarterProvider.overrideWithValue(restarter),
    ],
  );
}

Future<void> _waitForPhase(
  ProviderContainer container,
  AppCzarAttachmentArchiveRepairPhase phase,
) async {
  for (var attempt = 0; attempt < 200; attempt += 1) {
    if (container
            .read(appCzarAttachmentArchiveRepairControllerProvider)
            .phase ==
        phase) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Timed out waiting for ${phase.name}.');
}

AppCzarAssessmentState _repairAssessmentState({
  int generation = 4,
  AppCzarDiagnosisKind diagnosisKind =
      AppCzarDiagnosisKind.attachmentArchiveCoverageIncomplete,
  AppCzarTruth coverageTruth = AppCzarTruth.falseValue,
  AppCzarTruth archiveTruth = AppCzarTruth.trueValue,
  AppCzarAttachmentCoverageCondition coverageCondition =
      AppCzarAttachmentCoverageCondition.incomplete,
  String scopeIdentity = 'scope-a',
  int archiveGeneration = 0,
  int? coverageGeneration,
  String resolvedPath = '/Volumes/Test/attachment_archive',
  bool duplicateCoverageFact = false,
  bool omitArchiveFact = false,
  AppCzarTruth repairOpportunityTruth = AppCzarTruth.trueValue,
  AppCzarAttachmentRepairOpportunityCondition repairOpportunityCondition =
      AppCzarAttachmentRepairOpportunityCondition.present,
  int availableFromMessagesCount = 3,
  int sourceAbsentCount = 0,
}) {
  final coverage = AppCzarAttachmentCoverageObservation(
    condition: coverageCondition,
    requiredCount:
        coverageCondition == AppCzarAttachmentCoverageCondition.unknown
        ? null
        : 13,
    coveredCount:
        coverageCondition == AppCzarAttachmentCoverageCondition.unknown
        ? null
        : 10,
    missingCount:
        coverageCondition == AppCzarAttachmentCoverageCondition.unknown
        ? null
        : 3,
    unverifiableCount:
        coverageCondition == AppCzarAttachmentCoverageCondition.unknown
        ? null
        : 0,
    archiveScopeIdentity: scopeIdentity,
    archiveGeneration: coverageGeneration ?? archiveGeneration,
  );
  final repairability = AppCzarAttachmentRepairabilityObservation(
    condition: repairOpportunityCondition,
    availableFromMessagesCount: availableFromMessagesCount,
    sourceAbsentCount: sourceAbsentCount,
    sourceUnknownCount: 0,
    recordBackedRecoveryCount: 0,
    unsafeOrConflictingCount: 0,
    archiveScopeIdentity: scopeIdentity,
    archiveGeneration: archiveGeneration,
  );
  final facts = <AppCzarFact>[
    AppCzarFact(
      id: AppCzarFactId.attachmentCoverageComplete,
      label: 'coverage',
      truth: coverageTruth,
      detail: 'test',
    ),
    AppCzarFact(
      id: AppCzarFactId.attachmentRepairOpportunityPresent,
      label: 'repair opportunity',
      truth: repairOpportunityTruth,
      detail: 'test',
    ),
    if (duplicateCoverageFact)
      AppCzarFact(
        id: AppCzarFactId.attachmentCoverageComplete,
        label: 'duplicate coverage',
        truth: coverageTruth,
        detail: 'test',
      ),
    if (!omitArchiveFact)
      AppCzarFact(
        id: AppCzarFactId.attachmentArchiveAvailable,
        label: 'archive',
        truth: archiveTruth,
        detail: 'test',
      ),
  ];
  return AppCzarAssessmentState(
    generation: generation,
    attachmentArchive: AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Archive',
      coverage: coverage,
      repairability: repairability,
      archiveScopeIdentity: scopeIdentity,
      archiveGeneration: archiveGeneration,
      resolvedPath: resolvedPath,
    ),
    assessment: AppCzarAssessment(
      facts: facts,
      diagnosisKind: diagnosisKind,
      diagnosis: 'test',
      virtualCoordinator: AppCzarVirtualCoordinator.attachmentArchiveRepair,
    ),
  );
}

AppCzarAttachmentArchiveRepairBinding _binding({int occurrenceId = 0}) {
  return AppCzarAttachmentArchiveRepairBinding(
    occurrenceId: occurrenceId,
    assessmentGeneration: 0,
    archiveScopeIdentity: 'scope-a',
    archiveGeneration: 0,
    resolvedArchivePath: '/Volumes/Test/attachment_archive',
  );
}

AppCzarAttachmentArchiveRepairSnapshot _snapshot({
  required int available,
  required int absent,
  int unknown = 0,
  int covered = 10,
  AppCzarAttachmentArchiveRepairBatchAuthorization? authorization,
}) {
  return AppCzarAttachmentArchiveRepairSnapshot(
    requiredCount: 13,
    coveredCount: covered,
    availableFromMessagesCount: available,
    sourceAbsentCount: absent,
    sourceUnknownCount: unknown,
    recordBackedRecoveryCount: 0,
    unsafeOrConflictingCount: 13 - covered - available - absent - unknown,
    nextBatchAuthorization: available == 0
        ? null
        : authorization ?? _authorization(count: available),
  );
}

AppCzarAttachmentArchiveRepairBatchAuthorization _authorization({
  String identity = 'plan-current',
  required int count,
  int? knownBytes = 4096,
}) {
  return AppCzarAttachmentArchiveRepairBatchAuthorization(
    planIdentity: identity,
    itemCount: count,
    totalKnownBytes: knownBytes,
  );
}

AppCzarAttachmentArchiveRepairObservation _incompleteObservation({
  int occurrenceId = 0,
  required AppCzarAttachmentArchiveRepairSnapshot snapshot,
}) {
  return AppCzarAttachmentArchiveRepairObservation(
    kind: AppCzarAttachmentArchiveRepairObservationKind.coverageIncomplete,
    binding: _binding(occurrenceId: occurrenceId),
    snapshot: snapshot,
  );
}

AppCzarAttachmentArchiveRepairObservation _completeObservation() {
  return AppCzarAttachmentArchiveRepairObservation(
    kind: AppCzarAttachmentArchiveRepairObservationKind.coverageComplete,
    binding: _binding(),
    snapshot: const AppCzarAttachmentArchiveRepairSnapshot(
      requiredCount: 13,
      coveredCount: 13,
      availableFromMessagesCount: 0,
      sourceAbsentCount: 0,
      sourceUnknownCount: 0,
      recordBackedRecoveryCount: 0,
      unsafeOrConflictingCount: 0,
    ),
  );
}

final class _QueueExecutorFactory
    implements AppCzarAttachmentArchiveRepairExecutorFactory {
  _QueueExecutorFactory(this.executors);

  final List<AppCzarAttachmentArchiveRepairExecutor> executors;
  var createCalls = 0;

  @override
  AppCzarAttachmentArchiveRepairExecutor create() {
    final executor = executors[createCalls];
    createCalls += 1;
    return executor;
  }
}

final class _InitiallyFailingExecutorFactory
    implements AppCzarAttachmentArchiveRepairExecutorFactory {
  _InitiallyFailingExecutorFactory(this.executor);

  final AppCzarAttachmentArchiveRepairExecutor executor;
  var createCalls = 0;

  @override
  AppCzarAttachmentArchiveRepairExecutor create() {
    createCalls += 1;
    if (createCalls == 1) {
      throw StateError('Simulated factory failure.');
    }
    return executor;
  }
}

final class _FakeExecutor implements AppCzarAttachmentArchiveRepairExecutor {
  _FakeExecutor({
    this.inspection,
    this.preservation,
    this.preservations,
    this.inspectionCompleter,
    this.preservationCompleter,
    this.stopObservation,
  });

  final AppCzarAttachmentArchiveRepairObservation? inspection;
  final AppCzarAttachmentArchiveRepairObservation? preservation;
  final List<AppCzarAttachmentArchiveRepairObservation>? preservations;
  final Completer<AppCzarAttachmentArchiveRepairObservation>?
  inspectionCompleter;
  final Completer<AppCzarAttachmentArchiveRepairObservation>?
  preservationCompleter;
  final AppCzarAttachmentArchiveRepairObservation? stopObservation;

  var inspectCalls = 0;
  var preserveCalls = 0;
  var stopCalls = 0;
  var active = false;
  final receivedAuthorizations =
      <AppCzarAttachmentArchiveRepairBatchAuthorization>[];

  @override
  Future<AppCzarAttachmentArchiveRepairObservation> inspectCurrent({
    required AppCzarAttachmentArchiveRepairBinding binding,
  }) async {
    inspectCalls += 1;
    active = true;
    try {
      return inspectionCompleter == null
          ? inspection!
          : await inspectionCompleter!.future;
    } finally {
      active = false;
    }
  }

  @override
  Future<AppCzarAttachmentArchiveRepairObservation> preserveAuthorizedBatch({
    required AppCzarAttachmentArchiveRepairBinding binding,
    required AppCzarAttachmentArchiveRepairBatchAuthorization authorization,
    AppCzarAttachmentArchiveRepairProgressObserver? onProgress,
  }) async {
    preserveCalls += 1;
    receivedAuthorizations.add(authorization);
    active = true;
    try {
      onProgress?.call(
        AppCzarAttachmentArchiveRepairProgress(
          completedCount: authorization.itemCount,
          totalCount: authorization.itemCount,
        ),
      );
      final completer = preservationCompleter;
      if (completer != null) {
        return await completer.future;
      }
      final queued = preservations;
      if (queued != null) {
        return queued[preserveCalls - 1];
      }
      return preservation!;
    } finally {
      active = false;
    }
  }

  @override
  Future<void> stopAndDrain() async {
    stopCalls += 1;
    final completer = inspectionCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(stopObservation!);
    }
    while (active) {
      await Future<void>.delayed(Duration.zero);
    }
  }
}

final class _RecordingRestarter implements AppCzarProcessRestarter {
  _RecordingRestarter({this.onRestart});

  final void Function()? onRestart;
  var calls = 0;

  @override
  Future<void> restartAndReassess() async {
    calls += 1;
    onRestart?.call();
  }
}

final class _RepairReader implements AppCzarObservationReader {
  _RepairReader({this.resolvedPath = '/Volumes/Test/attachment_archive'});

  String resolvedPath;

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    return AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Archive',
      archiveScopeIdentity: 'scope-a',
      archiveGeneration: 0,
      resolvedPath: resolvedPath,
      coverage: const AppCzarAttachmentCoverageObservation(
        condition: AppCzarAttachmentCoverageCondition.incomplete,
        requiredCount: 13,
        coveredCount: 10,
        missingCount: 3,
        unverifiableCount: 0,
        archiveScopeIdentity: 'scope-a',
        archiveGeneration: 0,
      ),
      repairability: const AppCzarAttachmentRepairabilityObservation(
        condition: AppCzarAttachmentRepairOpportunityCondition.present,
        availableFromMessagesCount: 3,
        sourceAbsentCount: 0,
        sourceUnknownCount: 0,
        recordBackedRecoveryCount: 0,
        unsafeOrConflictingCount: 0,
        archiveScopeIdentity: 'scope-a',
        archiveGeneration: 0,
      ),
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
    return const AppCzarRootObservation(admitted: true, path: '/test/root');
  }

  @override
  Future<AppCzarSourceObservation> readSource() async {
    return const AppCzarSourceObservation(
      condition: AppCzarSourceCondition.readable,
      messageCount: 100,
      maxRowId: 100,
      sampleStable: true,
    );
  }
}

// Prompt 137: only inert ports, installed before the actual owner is built.
ProviderContainer _fixedContainer(
  AppCzarAttachmentArchiveRepairExecutorFactory factory,
  AppCzarProcessRestarter restart,
) => ProviderContainer(
  overrides: [
    appCzarAssessmentControllerProvider.overrideWith(
      _FixedRepairAssessment.new,
    ),
    appCzarAttachmentArchiveRepairExecutorFactoryProvider.overrideWithValue(
      factory,
    ),
    appCzarProcessRestarterProvider.overrideWithValue(restart),
  ],
);

class _FixedRepairAssessment extends AppCzarAssessmentController {
  @override
  AppCzarAssessmentState build() => _repairAssessmentState(generation: 0);
  void replace(AppCzarAssessmentState next) {
    state = next;
  }
}

class _BarrierExecutor implements AppCzarAttachmentArchiveRepairExecutor {
  final inspection = Completer<AppCzarAttachmentArchiveRepairObservation>();
  final preservation = Completer<AppCzarAttachmentArchiveRepairObservation>();
  int inspectCalls = 0;
  int preserveCalls = 0;
  int stopCalls = 0;
  Future<void>? pending;
  Completer<void>? drainBarrier;
  AppCzarAttachmentArchiveRepairProgressObserver? progress;
  @override
  Future<AppCzarAttachmentArchiveRepairObservation> inspectCurrent({
    required AppCzarAttachmentArchiveRepairBinding binding,
  }) {
    inspectCalls++;
    pending = inspection.future.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return inspection.future;
  }

  @override
  Future<AppCzarAttachmentArchiveRepairObservation> preserveAuthorizedBatch({
    required AppCzarAttachmentArchiveRepairBinding binding,
    required AppCzarAttachmentArchiveRepairBatchAuthorization authorization,
    AppCzarAttachmentArchiveRepairProgressObserver? onProgress,
  }) {
    preserveCalls++;
    progress = onProgress;
    pending = preservation.future.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return preservation.future;
  }

  @override
  Future<void> stopAndDrain() async {
    stopCalls++;
    await pending;
    await drainBarrier?.future;
  }
}

class _BarrierRestarter implements AppCzarProcessRestarter {
  var done = Completer<void>();
  void Function()? onEntry;
  int calls = 0;
  @override
  Future<void> restartAndReassess() {
    calls++;
    onEntry?.call();
    return done.future;
  }
}

class _CallbackFactory
    implements AppCzarAttachmentArchiveRepairExecutorFactory {
  _CallbackFactory(this.executor);
  final AppCzarAttachmentArchiveRepairExecutor executor;
  void Function()? onCreate;
  @override
  AppCzarAttachmentArchiveRepairExecutor create() {
    onCreate?.call();
    return executor;
  }
}
