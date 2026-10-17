import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import 'package:remember_this_text/essentials/app_czar_local_data_repair/application/app_czar_local_data_repair_controller.dart';
import 'package:remember_this_text/essentials/app_czar_local_data_repair/application/app_czar_local_data_repair_executor_provider.dart';
import 'package:remember_this_text/essentials/app_czar_local_data_repair/domain/app_czar_local_data_repair_state.dart';

void main() {
  for (final automatic in [false, true]) {
    test(
      'Prompt 133 pending ${automatic ? 'automatic' : 'manual'} restart refuses drain',
      () async {
        final executor = _ControlledExecutor();
        final restarter = _BarrierRestarter();
        final container = _container(executor: executor, restarter: restarter);
        final subscription = _listen(container);
        Future<void>? action;
        try {
          await executor.started.future;
          if (automatic) {
            executor.completeWithStaleEvidence();
          } else {
            executor.completeWithFailure(
              const AppCzarLocalDataRepairExecutionException(
                cause: 'synthetic refusal',
                mutationMayHaveStarted: false,
              ),
            );
            await _phase(container, AppCzarLocalDataRepairPhase.failed);
            action = container
                .read(appCzarLocalDataRepairControllerProvider.notifier)
                .restartAndReassess();
          }
          await restarter.started.future;
          final owner = container.read(
            appCzarLocalDataRepairControllerProvider.notifier,
          );
          final duplicate = owner.restartAndReassess();
          expect(restarter.calls, 1);
          Object? failure;
          var succeeded = false;
          final drain = container
              .read(appCzarLocalDataRepairControllerProvider.notifier)
              .stopAndDrain()
              .then<void>(
                (_) {
                  succeeded = true;
                },
                onError: (Object error) {
                  failure = error;
                },
              );
          final secondDrain = expectLater(
            owner.stopAndDrain(),
            throwsStateError,
          );
          // A microtask barrier observes completion/refusal without releasing the port.
          await Future<void>.microtask(() {});
          await Future<void>.microtask(() {});
          final observed = failure;
          final prematureSuccess = succeeded;
          restarter.done.complete();
          await action;
          await drain;
          await secondDrain;
          await duplicate;
          await owner.stopAndDrain();
          expect(restarter.calls, 1);
          expect(prematureSuccess, isFalse);
          expect(observed, isA<StateError>());
        } finally {
          if (!restarter.done.isCompleted) {
            restarter.done.complete();
          }
          await action;
          subscription.close();
          container.dispose();
        }
      },
    );
  }

  test(
    'stop before retry resolves no restarter and never revives admission',
    () async {
      final executor = _ControlledExecutor();
      var resolutions = 0;
      final container = ProviderContainer(
        overrides: [
          appCzarAssessmentControllerProvider.overrideWith(
            _RepairAssessmentController.new,
          ),
          appCzarLocalDataRepairExecutorProvider.overrideWithValue(executor),
          appCzarProcessRestarterProvider.overrideWith((ref) {
            resolutions += 1;
            return _RecordingRestarter();
          }),
        ],
      );
      final sub = _listen(container);
      final owner = container.read(
        appCzarLocalDataRepairControllerProvider.notifier,
      );
      await executor.started.future;
      executor.completeWithFailure(
        const AppCzarLocalDataRepairExecutionException(
          cause: 'before mutation',
          mutationMayHaveStarted: false,
        ),
      );
      await _phase(container, AppCzarLocalDataRepairPhase.failed);
      await owner.stopAndDrain();
      await owner.restartAndReassess();
      await owner.stopAndDrain();
      expect(resolutions, 0);
      expect(executor.runs, 1);
      expect(executor.mutationWasAdmitted, isFalse);
      sub.close();
      container.dispose();
    },
  );

  for (final failure in [false, true]) {
    test('two stops retain actual work settlement failure=$failure', () async {
      final executor = _ControlledExecutor();
      final restarter = _RecordingRestarter();
      final container = _container(executor: executor, restarter: restarter);
      final sub = _listen(container);
      final owner = container.read(
        appCzarLocalDataRepairControllerProvider.notifier,
      );
      await executor.started.future;
      final before = container.read(appCzarLocalDataRepairControllerProvider);
      var settled = 0;
      final errors = <Object>[];
      Future<void> stop() => owner.stopAndDrain().then<void>(
        (_) {
          settled += 1;
        },
        onError: (Object error) {
          errors.add(error);
          settled += 1;
        },
      );
      final first = stop();
      final second = stop();
      await Future<void>.microtask(() {});
      expect(settled, 0);
      expect(executor.isMutationStillAdmitted!(), isFalse);
      if (failure) {
        executor.completeWithFailure(StateError('late work failure'));
      } else {
        executor.completeWithStaleEvidence();
      }
      await Future.wait([first, second]);
      expect(settled, 2);
      expect(errors.length, failure ? 2 : 0);
      expect(restarter.calls, 0);
      expect(
        container.read(appCzarLocalDataRepairControllerProvider),
        same(before),
      );
      sub.close();
      container.dispose();
    });
  }

  for (final outcome in ['success', 'stale', 'post-mutation failure']) {
    test('stop at queued automatic $outcome prevents port dispatch', () async {
      final executor = _ControlledExecutor();
      final restarter = _RecordingRestarter();
      final container = _container(executor: executor, restarter: restarter);
      final sub = _listen(container);
      final owner = container.read(
        appCzarLocalDataRepairControllerProvider.notifier,
      );
      final stopped = Completer<void>();
      final watcher = container.listen(
        appCzarLocalDataRepairControllerProvider,
        (_, next) {
          if (next.phase == AppCzarLocalDataRepairPhase.restartRequested) {
            stopped.complete(owner.stopAndDrain());
          }
        },
      );
      await executor.started.future;
      if (outcome == 'success') {
        executor.completeWithSuccess();
      } else if (outcome == 'stale') {
        executor.completeWithStaleEvidence();
      } else {
        executor.completeWithFailure(
          const AppCzarLocalDataRepairExecutionException(
            cause: 'synthetic postcondition',
            mutationMayHaveStarted: true,
          ),
        );
      }
      await stopped.future;
      expect(restarter.calls, 0);
      expect(executor.runs, 1);
      watcher.close();
      sub.close();
      container.dispose();
    });
  }

  for (final automatic in [false, true]) {
    test(
      'restart reenters drain without self-await automatic=$automatic',
      () async {
        final executor = _ControlledExecutor();
        late AppCzarLocalDataRepairController owner;
        final settled = Completer<void>();
        final restarter = _CallbackRestarter(() async {
          await expectLater(owner.stopAndDrain(), throwsStateError);
          settled.complete();
        });
        final container = _container(executor: executor, restarter: restarter);
        final sub = _listen(container);
        owner = container.read(
          appCzarLocalDataRepairControllerProvider.notifier,
        );
        await executor.started.future;
        Future<void>? action;
        if (automatic) {
          executor.completeWithStaleEvidence();
        } else {
          executor.completeWithFailure(
            const AppCzarLocalDataRepairExecutionException(
              cause: 'synthetic refusal',
              mutationMayHaveStarted: false,
            ),
          );
          await _phase(container, AppCzarLocalDataRepairPhase.failed);
          action = owner.restartAndReassess();
        }
        await settled.future;
        await action;
        // Port completion precedes this queued observation; no timeout fakes drainage.
        await Future<void>.microtask(() {});
        await owner.stopAndDrain();
        expect(restarter.calls, 1);
        sub.close();
        container.dispose();
      },
    );
  }

  for (final synchronous in [false, true]) {
    for (final stopFirst in [false, true]) {
      test(
        'restart failure retained synchronous=$synchronous stopFirst=$stopFirst',
        () async {
          final executor = _ControlledExecutor();
          final started = Completer<void>();
          final release = Completer<void>();
          final error = StateError('restart failed');
          final restarter = _CallbackRestarter(() {
            started.complete();
            if (synchronous) {
              throw error;
            }
            return release.future;
          });
          final container = _container(
            executor: executor,
            restarter: restarter,
          );
          final sub = _listen(container);
          final owner = container.read(
            appCzarLocalDataRepairControllerProvider.notifier,
          );
          await executor.started.future;
          executor.completeWithFailure(
            const AppCzarLocalDataRepairExecutionException(
              cause: 'synthetic refusal',
              mutationMayHaveStarted: false,
            ),
          );
          await _phase(container, AppCzarLocalDataRepairPhase.failed);
          final action = owner.restartAndReassess();
          await started.future;
          final before = container.read(
            appCzarLocalDataRepairControllerProvider,
          );
          if (stopFirst) {
            await expectLater(owner.stopAndDrain(), throwsStateError);
          }
          if (!synchronous) {
            release.completeError(error);
          } else {
            release.complete();
          }
          await action;
          if (stopFirst) {
            expect(
              container.read(appCzarLocalDataRepairControllerProvider),
              same(before),
            );
          } else {
            expect(
              container.read(appCzarLocalDataRepairControllerProvider).failure,
              contains('restart failed'),
            );
          }
          await expectLater(owner.stopAndDrain(), throwsA(same(error)));
          await expectLater(owner.stopAndDrain(), throwsA(same(error)));
          sub.close();
          container.dispose();
        },
      );
    }
  }

  for (final dispose in [false, true]) {
    for (final restarting in [false, true]) {
      test(
        'retirement suppresses late continuation dispose=$dispose restarting=$restarting',
        () async {
          final executor = _ControlledExecutor();
          final restarter = _BarrierRestarter();
          final container = _container(
            executor: executor,
            restarter: restarter,
          );
          final sub = _listen(container);
          final owner = container.read(
            appCzarLocalDataRepairControllerProvider.notifier,
          );
          await executor.started.future;
          if (restarting) {
            executor.completeWithStaleEvidence();
            await restarter.started.future;
          }
          final before = container.read(
            appCzarLocalDataRepairControllerProvider,
          );
          if (dispose) {
            sub.close();
            container.dispose();
          } else {
            (container.read(appCzarAssessmentControllerProvider.notifier)
                    as _RepairAssessmentController)
                .retire();
          }
          expect(executor.isMutationStillAdmitted!(), isFalse);
          if (restarting) {
            await expectLater(owner.stopAndDrain(), throwsStateError);
            restarter.done.completeError(StateError('late restart failure'));
            await Future<void>.microtask(() {});
            await expectLater(owner.stopAndDrain(), throwsStateError);
          } else {
            executor.completeWithStaleEvidence();
            await owner.stopAndDrain();
            expect(restarter.calls, 0);
            restarter.done.complete();
          }
          await owner.restartAndReassess();
          expect(executor.runs, 1);
          if (!dispose) {
            expect(
              container.read(appCzarLocalDataRepairControllerProvider),
              same(before),
            );
            sub.close();
            container.dispose();
          }
        },
      );
    }
  }

  test('a live failed automatic restart can be retried once', () async {
    final executor = _ControlledExecutor();
    var calls = 0;
    final restarter = _CallbackRestarter(() {
      calls += 1;
      if (calls == 1) {
        throw StateError('first failure');
      }
      return Future<void>.value();
    });
    final container = _container(executor: executor, restarter: restarter);
    final sub = _listen(container);
    final owner = container.read(
      appCzarLocalDataRepairControllerProvider.notifier,
    );
    await executor.started.future;
    executor.completeWithStaleEvidence();
    await _phase(container, AppCzarLocalDataRepairPhase.failed);
    await owner.restartAndReassess();
    await owner.stopAndDrain();
    expect(calls, 2);
    expect(executor.runs, 1);
    sub.close();
    container.dispose();
  });

  test('only exact proven Local Data Repair disposition executes', () {
    for (final coordinator in AppCzarVirtualCoordinator.values) {
      expect(
        shouldExecuteAppCzarLocalDataRepair(
          _assessmentState(coordinator: coordinator),
        ),
        coordinator == AppCzarVirtualCoordinator.localDataRepair,
      );
    }
    expect(
      shouldExecuteAppCzarLocalDataRepair(
        _assessmentState(
          coordinator: AppCzarVirtualCoordinator.localDataRepair,
          safety: const AppCzarLocalDataRepairSafetyObservation.unknown(
            issue: 'Safety is unknown.',
          ),
        ),
      ),
      isFalse,
    );
  });

  test('successful reset closes admission before one restart', () async {
    final executor = _ControlledExecutor()..completeWithSuccess();
    final restarter = _RecordingRestarter(
      onRestart: () => expect(executor.isMutationStillAdmitted!(), isFalse),
    );
    final container = _container(executor: executor, restarter: restarter);
    addTearDown(container.dispose);
    final subscription = _listen(container);
    addTearDown(subscription.close);

    await _waitForRestart(restarter);

    expect(executor.runs, 1);
    expect(executor.expected, _safeObservation);
    expect(executor.mutationWasAdmitted, isTrue);
    expect(restarter.calls, 1);
    expect(
      container.read(appCzarLocalDataRepairControllerProvider).phase,
      AppCzarLocalDataRepairPhase.restartRequested,
    );
  });

  test(
    'stale pre-mutation evidence restarts without admitting mutation',
    () async {
      final executor = _ControlledExecutor()..completeWithStaleEvidence();
      final restarter = _RecordingRestarter(
        onRestart: () => expect(executor.isMutationStillAdmitted!(), isFalse),
      );
      final container = _container(executor: executor, restarter: restarter);
      addTearDown(container.dispose);
      final subscription = _listen(container);
      addTearDown(subscription.close);

      await _waitForRestart(restarter);

      expect(executor.mutationWasAdmitted, isFalse);
      expect(restarter.calls, 1);
    },
  );

  test('post-admission reset or postcondition failure restarts', () async {
    final executor = _ControlledExecutor();
    final restarter = _RecordingRestarter();
    final container = _container(executor: executor, restarter: restarter);
    addTearDown(container.dispose);
    final subscription = _listen(container);
    addTearDown(subscription.close);
    await executor.started.future;
    executor.completeWithFailure(
      const AppCzarLocalDataRepairExecutionException(
        cause: 'physical postcondition failed',
        mutationMayHaveStarted: true,
      ),
    );

    await _waitForRestart(restarter);

    expect(executor.mutationWasAdmitted, isTrue);
    expect(restarter.calls, 1);
  });

  test('pre-mutation failure performs no restart or mutation claim', () async {
    final executor = _ControlledExecutor();
    final restarter = _RecordingRestarter();
    final container = _container(executor: executor, restarter: restarter);
    addTearDown(container.dispose);
    final subscription = _listen(container);
    addTearDown(subscription.close);
    await executor.started.future;
    executor.completeWithFailure(
      const AppCzarLocalDataRepairExecutionException(
        cause: 'authority refused',
        mutationMayHaveStarted: false,
      ),
    );

    await _waitForPhase(container, AppCzarLocalDataRepairPhase.failed);

    expect(executor.mutationWasAdmitted, isFalse);
    expect(restarter.calls, 0);
  });

  test('ordinary quit closes admission and drains without restart', () async {
    final executor = _ControlledExecutor();
    final restarter = _RecordingRestarter();
    final container = _container(executor: executor, restarter: restarter);
    addTearDown(container.dispose);
    final subscription = _listen(container);
    addTearDown(subscription.close);
    await executor.started.future;

    final drain = container
        .read(appCzarLocalDataRepairControllerProvider.notifier)
        .stopAndDrain();
    expect(executor.isMutationStillAdmitted!(), isFalse);
    executor.completeWithStaleEvidence();
    await drain;

    expect(restarter.calls, 0);
    expect(executor.mutationWasAdmitted, isFalse);
  });

  test('restart failure remains factual and retryable', () async {
    final executor = _ControlledExecutor()..completeWithSuccess();
    final restarter = _RecordingRestarter(failure: StateError('no relaunch'));
    final container = _container(executor: executor, restarter: restarter);
    addTearDown(container.dispose);
    final subscription = _listen(container);
    addTearDown(subscription.close);

    await _waitForPhase(container, AppCzarLocalDataRepairPhase.failed);

    final state = container.read(appCzarLocalDataRepairControllerProvider);
    expect(state.failure, contains('no relaunch'));
    expect(restarter.calls, 1);
  });
}

ProviderContainer _container({
  required _ControlledExecutor executor,
  required AppCzarProcessRestarter restarter,
}) {
  return ProviderContainer(
    overrides: <Override>[
      appCzarAssessmentControllerProvider.overrideWith(
        _RepairAssessmentController.new,
      ),
      appCzarLocalDataRepairExecutorProvider.overrideWithValue(executor),
      appCzarProcessRestarterProvider.overrideWithValue(restarter),
    ],
  );
}

ProviderSubscription<AppCzarLocalDataRepairState> _listen(
  ProviderContainer container,
) {
  return container.listen(
    appCzarLocalDataRepairControllerProvider,
    (_, _) {},
    fireImmediately: true,
  );
}

Future<void> _waitForRestart(_RecordingRestarter restarter) async {
  for (var attempt = 0; attempt < 100; attempt += 1) {
    if (restarter.calls > 0) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Timed out waiting for restart.');
}

Future<void> _waitForPhase(
  ProviderContainer container,
  AppCzarLocalDataRepairPhase phase,
) async {
  for (var attempt = 0; attempt < 100; attempt += 1) {
    if (container.read(appCzarLocalDataRepairControllerProvider).phase ==
        phase) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Timed out waiting for ${phase.name}.');
}

final class _RepairAssessmentController extends AppCzarAssessmentController {
  @override
  AppCzarAssessmentState build() => _assessmentState();

  void retire() {
    state = _assessmentState(
      coordinator: AppCzarVirtualCoordinator.diagnosticReview,
    );
  }
}

final class _ControlledExecutor implements AppCzarLocalDataRepairExecutor {
  final Completer<AppCzarLocalDataRepairExecutionResult> _completion =
      Completer<AppCzarLocalDataRepairExecutionResult>();
  final Completer<void> started = Completer<void>();
  AppCzarLocalDataRepairSafetyObservation? expected;
  bool Function()? isMutationStillAdmitted;
  var mutationWasAdmitted = false;
  var runs = 0;

  void completeWithSuccess() {
    if (!_completion.isCompleted) {
      _completion.complete(AppCzarLocalDataRepairExecutionResult.completed);
    }
  }

  void completeWithStaleEvidence() {
    if (!_completion.isCompleted) {
      _completion.complete(AppCzarLocalDataRepairExecutionResult.staleEvidence);
    }
  }

  void completeWithFailure(Object error) {
    if (!_completion.isCompleted) {
      _completion.completeError(error);
    }
  }

  @override
  Future<AppCzarLocalDataRepairExecutionResult> run({
    required AppCzarLocalDataRepairSafetyObservation expected,
    void Function()? onMutationAdmitted,
    bool Function()? isMutationStillAdmitted,
  }) async {
    runs += 1;
    this.expected = expected;
    this.isMutationStillAdmitted = isMutationStillAdmitted;
    if (!started.isCompleted) {
      started.complete();
    }
    try {
      final result = await _completion.future;
      if (result == AppCzarLocalDataRepairExecutionResult.completed) {
        mutationWasAdmitted = true;
        onMutationAdmitted?.call();
      }
      return result;
    } on AppCzarLocalDataRepairExecutionException catch (error) {
      if (error.mutationMayHaveStarted) {
        mutationWasAdmitted = true;
        onMutationAdmitted?.call();
      }
      rethrow;
    }
  }
}

final class _RecordingRestarter implements AppCzarProcessRestarter {
  _RecordingRestarter({this.failure, this.onRestart});

  final Object? failure;
  final void Function()? onRestart;
  var calls = 0;

  @override
  Future<void> restartAndReassess() async {
    calls += 1;
    onRestart?.call();
    if (failure case final failure?) {
      throw failure;
    }
  }
}

AppCzarAssessmentState _assessmentState({
  AppCzarVirtualCoordinator coordinator =
      AppCzarVirtualCoordinator.localDataRepair,
  AppCzarLocalDataRepairSafetyObservation safety = _safeObservation,
}) {
  return AppCzarAssessmentState(
    generation: 7,
    localDataRepairSafety: safety,
    assessment: AppCzarAssessment(
      facts: const <AppCzarFact>[],
      diagnosisKind: AppCzarDiagnosisKind.localDataNeedsRepair,
      diagnosis: 'The partial live-derived dataset is reconstructible.',
      virtualCoordinator: coordinator,
    ),
  );
}

const _safeObservation = AppCzarLocalDataRepairSafetyObservation(
  condition: AppCzarLocalDataRepairSafetyCondition.rebuildableLiveOnlyPartial,
  archiveRootPath: '/tmp/app-czar-local-repair-controller-test',
  archiveInstanceId: '22222222-2222-4222-8222-222222222222',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
  sourceFingerprint: 'source-fingerprint',
  evidenceFingerprint: 'evidence-fingerprint',
  resetFootprint: <String>['macos_import_ss.db', 'working_ss.db'],
  consequentialRowCounts: <String, int>{'messages': 1},
);

Future<void> _phase(
  ProviderContainer container,
  AppCzarLocalDataRepairPhase phase,
) async {
  if (container.read(appCzarLocalDataRepairControllerProvider).phase == phase) {
    return;
  }
  final reached = Completer<void>();
  final subscription = container.listen(
    appCzarLocalDataRepairControllerProvider,
    (_, next) {
      if (next.phase == phase && !reached.isCompleted) {
        reached.complete();
      }
    },
  );
  try {
    await reached.future;
  } finally {
    subscription.close();
  }
}

final class _BarrierRestarter implements AppCzarProcessRestarter {
  final started = Completer<void>();
  final done = Completer<void>();
  int calls = 0;
  @override
  Future<void> restartAndReassess() {
    calls += 1;
    if (!started.isCompleted) {
      started.complete();
    }
    return done.future;
  }
}

final class _CallbackRestarter implements AppCzarProcessRestarter {
  _CallbackRestarter(this.callback);
  final Future<void> Function() callback;
  int calls = 0;
  @override
  Future<void> restartAndReassess() {
    calls += 1;
    return callback();
  }
}
