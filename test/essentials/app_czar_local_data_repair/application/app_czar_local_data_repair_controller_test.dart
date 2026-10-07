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
  required _RecordingRestarter restarter,
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
