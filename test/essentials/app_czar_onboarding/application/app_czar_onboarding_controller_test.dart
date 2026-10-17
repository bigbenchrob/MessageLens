import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/application/app_czar_onboarding_build_executor_provider.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/domain/app_czar_onboarding_state.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_observation.dart';
import 'package:remember_this_text/essentials/onboarding/application/fda_settings_opening_adapter.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access.dart';
import 'package:remember_this_text/essentials/onboarding/application/real_fda_settings_opening_authority_provider.dart';

void main() {
  for (final failSettings in [false, true]) {
    test('Prompt 129 Settings drain failure=$failSettings', () async {
      final reader = _OnboardingReader(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.accessDenied,
        ),
      );
      final executor = _BuildExecutor();
      final restarter = _Restarter();
      final container = _container(reader, executor, restarter);
      final waiting = Completer<void>();
      container.listen(appCzarOnboardingControllerProvider, (_, next) {
        if (next.phase == AppCzarOnboardingPhase.sourceNeedsHuman &&
            !waiting.isCompleted) {
          waiting.complete();
        }
      }, fireImmediately: true);
      await waiting.future;
      await _flushOnboardingMicrotasks();
      final owner = container.read(
        appCzarOnboardingControllerProvider.notifier,
      );
      final before = container.read(appCzarOnboardingControllerProvider);
      final settings = Completer<void>();
      _fullDiskAccess.pending = settings;
      final action = owner.openSystemSettings();
      var drained = false;
      Object? drainFailure;
      final drain = owner.stopAndDrain().then(
        (_) {
          drained = true;
        },
        onError: (Object error, StackTrace stack) {
          drained = true;
          drainFailure = error;
        },
      );
      try {
        await _flushOnboardingMicrotasks();
        final premature = drained;
        expect(_fullDiskAccess.openSettingsCalls, 1);
        if (failSettings) {
          settings.completeError(StateError('synthetic Settings failure'));
        } else {
          settings.complete();
        }
        await action;
        await drain;
        final latePublication = !identical(
          before,
          container.read(appCzarOnboardingControllerProvider),
        );
        // Keep both observations visible even when the pending assertion fails.
        printOnFailure(
          'Prompt129 Settings failure=$failSettings '
          'prematureDrain=$premature latePublication=$latePublication',
        );
        expect(premature, isFalse);
        expect(latePublication, isFalse);
        expect(drainFailure, failSettings ? isA<StateError>() : isNull);
        expect(executor.calls, 0);
        expect(restarter.calls, 0);
      } finally {
        if (!settings.isCompleted) {
          settings.complete();
        }
        await action;
        await drain;
        if (!executor.started.isCompleted) {
          executor.started.complete();
        }
        if (!executor.release.isCompleted) {
          executor.release.complete();
        }
        if (!restarter.called.isCompleted) {
          restarter.called.complete();
        }
        container.dispose();
      }
    });
  }

  test(
    'Prompt 129 stop must not start a queued reassessment restart',
    () async {
      final executor = _BuildExecutor(block: true);
      final restarter = _Restarter();
      final restartRelease = Completer<void>();
      restarter.pending = restartRelease;
      final container = _container(_OnboardingReader(), executor, restarter);
      container.listen(
        appCzarOnboardingControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await executor.started.future;
      try {
        await container
            .read(appCzarAssessmentControllerProvider.notifier)
            .runAgain();
        await container.pump();
        expect(restarter.calls, 0);
        final owner = container.read(
          appCzarOnboardingControllerProvider.notifier,
        );
        final drain = owner.stopAndDrain();
        executor.release.complete();
        await drain;
        await _flushOnboardingMicrotasks();
        printOnFailure(
          'Prompt129 queued restart: drain returned; '
          'restartCalls=${restarter.calls}; '
          'restartSettled=${restartRelease.isCompleted}; SettingsCalls='
          '${_fullDiskAccess.openSettingsCalls}',
        );
        expect(
          restarter.calls,
          0,
          reason:
              'Ordinary stop must not initiate a queued restart after sealing.',
        );
      } finally {
        if (!executor.release.isCompleted) {
          executor.release.complete();
        }
        restartRelease.complete();
        await _flushOnboardingMicrotasks();
        container.dispose();
      }
    },
  );

  for (final failSecond in [false, true]) {
    test(
      'Prompt 131 all Settings flights settle failure=$failSecond',
      () async {
        final scenario = await _DrainScenario.human();
        try {
          final first = Completer<void>();
          final second = Completer<void>();
          scenario.settings.pendingFlights.addAll([first, second]);
          final a = scenario.owner.openSystemSettings();
          final b = scenario.owner.openSystemSettings();
          final before = scenario.container.read(
            appCzarOnboardingControllerProvider,
          );
          var finished = false;
          final drain = _drainOutcome(scenario.owner).then((result) {
            finished = true;
            return result;
          });
          final duplicate = _drainOutcome(scenario.owner);
          await scenario.owner.openSystemSettings();
          await scenario.owner.checkAgain();
          expect(scenario.settings.openSettingsCalls, 2);
          if (failSecond) {
            second.completeError(StateError('second Settings failed'));
          } else {
            second.complete();
          }
          await b;
          await _flushOnboardingMicrotasks();
          expect(finished, isFalse);
          expect(
            scenario.container.read(appCzarOnboardingControllerProvider),
            same(before),
          );
          first.complete();
          await a;
          expect(await drain, failSecond ? isA<StateError>() : isNull);
          expect(await duplicate, failSecond ? isA<StateError>() : isNull);
          expect(
            await _drainOutcome(scenario.owner),
            failSecond ? isA<StateError>() : isNull,
          );
          expect(scenario.restarter.calls, 0);
        } finally {
          await scenario.close();
        }
      },
    );
  }

  test(
    'Prompt 131 handled Settings failure is not retroactive drain failure',
    () async {
      final scenario = await _DrainScenario.human();
      try {
        final port = Completer<void>();
        scenario.settings.pending = port;
        final action = scenario.owner.openSystemSettings();
        port.completeError(StateError('handled before seal'));
        await action;
        expect(
          scenario.container.read(appCzarOnboardingControllerProvider).issue,
          contains('handled before seal'),
        );
        expect(await _drainOutcome(scenario.owner), isNull);
        await scenario.owner.openSystemSettings();
        expect(scenario.settings.openSettingsCalls, 1);
      } finally {
        await scenario.close();
      }
    },
  );

  for (final buildOverlap in [false, true]) {
    test(
      'Prompt 131 Settings overlaps ${buildOverlap ? 'build' : 'prerequisites'}',
      () async {
        final scenario = await _DrainScenario.human(blockBuild: buildOverlap);
        try {
          final port = Completer<void>();
          scenario.settings.pending = port;
          final action = scenario.owner.openSystemSettings();
          if (buildOverlap) {
            scenario.reader.source = _readableSource;
          } else {
            scenario.reader.nextSource = Completer<AppCzarSourceObservation>();
          }
          final check = scenario.owner.checkAgain();
          if (buildOverlap) {
            await scenario.executor.started.future;
          } else {
            await _flushOnboardingMicrotasks();
            expect(scenario.reader.sourceReads, 3);
          }
          final before = scenario.container.read(
            appCzarOnboardingControllerProvider,
          );
          var finished = false;
          final drain = _drainOutcome(scenario.owner).then((value) {
            finished = true;
            return value;
          });
          port.complete();
          await action;
          await _flushOnboardingMicrotasks();
          expect(finished, isFalse);
          if (buildOverlap) {
            scenario.executor.release.complete();
          } else {
            scenario.reader.nextSource!.complete(scenario.reader.source);
          }
          await check;
          expect(await drain, isNull);
          expect(
            scenario.container.read(appCzarOnboardingControllerProvider),
            same(before),
          );
          expect(scenario.restarter.calls, 0);
        } finally {
          await scenario.close();
        }
      },
    );
  }

  test('Prompt 131 Settings registration precedes reentrant stop', () async {
    final scenario = await _DrainScenario.human();
    try {
      final port = Completer<void>();
      Future<Object?>? drain;
      var finished = false;
      scenario.settings.onOpen = () {
        drain = _drainOutcome(scenario.owner).then((value) {
          finished = true;
          return value;
        });
        return port.future;
      };
      final action = scenario.owner.openSystemSettings();
      await _flushOnboardingMicrotasks();
      expect(finished, isFalse);
      port.complete();
      await action;
      expect(await drain, isNull);
    } finally {
      await scenario.close();
    }
  });

  for (final failRestart in [false, true]) {
    test(
      'Prompt 131 active restart refuses stop failure=$failRestart',
      () async {
        final scenario = await _DrainScenario.human();
        try {
          final release = Completer<void>();
          scenario.restarter.pending = release;
          final restart = scenario.owner.stopAndDrain(restart: true);
          // The explicit caller may receive the retained restart failure.
          final observed = restart.then<Object?>(
            (_) => null,
            onError: (Object error, StackTrace stack) => error,
          );
          await scenario.restarter.called.future;
          final before = scenario.container.read(
            appCzarOnboardingControllerProvider,
          );
          expect(await _drainOutcome(scenario.owner), isA<StateError>());
          expect(await _drainOutcome(scenario.owner), isA<StateError>());
          if (failRestart) {
            release.completeError(StateError('restart failed'));
          } else {
            release.complete();
          }
          expect(await observed, failRestart ? isA<StateError>() : isNull);
          expect(
            await _drainOutcome(scenario.owner),
            failRestart ? isA<StateError>() : isNull,
          );
          expect(
            scenario.container.read(appCzarOnboardingControllerProvider),
            same(before),
          );
          expect(scenario.restarter.calls, 1);
        } finally {
          await scenario.close();
        }
      },
    );
  }

  test(
    'Prompt 131 restarter reentrant drain refuses without self-await',
    () async {
      final scenario = await _DrainScenario.human();
      try {
        Object? refusal;
        scenario.restarter.onRestart = () async {
          refusal = await _drainOutcome(scenario.owner);
        };
        await scenario.owner.stopAndDrain(restart: true);
        expect(refusal, isA<StateError>());
        expect(scenario.restarter.calls, 1);
        expect(await _drainOutcome(scenario.owner), isNull);
      } finally {
        await scenario.close();
      }
    },
  );

  test('Prompt 131 repeated explicit restart drains Settings once', () async {
    final scenario = await _DrainScenario.human();
    try {
      final port = Completer<void>();
      scenario.settings.pending = port;
      final action = scenario.owner.openSystemSettings();
      final first = scenario.owner.stopAndDrain(restart: true);
      final second = scenario.owner.stopAndDrain(restart: true);
      await _flushOnboardingMicrotasks();
      expect(scenario.restarter.calls, 0);
      port.complete();
      await action;
      await Future.wait([first, second]);
      expect(scenario.restarter.calls, 1);
    } finally {
      await scenario.close();
    }
  });

  test('Prompt 131 ordinary stop supersedes explicit queued restart', () async {
    final scenario = await _DrainScenario.human();
    try {
      final port = Completer<void>();
      scenario.settings.pending = port;
      final action = scenario.owner.openSystemSettings();
      final restart = scenario.owner.stopAndDrain(restart: true);
      final stop = scenario.owner.stopAndDrain();
      port.complete();
      await Future.wait([action, restart, stop]);
      await scenario.owner.stopAndDrain(restart: true);
      expect(scenario.restarter.calls, 0);
    } finally {
      await scenario.close();
    }
  });

  for (final dispose in [false, true]) {
    test(
      'Prompt 131 retired Settings cannot publish dispose=$dispose',
      () async {
        final scenario = await _DrainScenario.human();
        var disposed = false;
        try {
          final port = Completer<void>();
          scenario.settings.pending = port;
          final action = scenario.owner.openSystemSettings();
          if (dispose) {
            scenario.container.dispose();
            disposed = true;
          } else {
            await scenario.container
                .read(appCzarAssessmentControllerProvider.notifier)
                .runAgain();
            await scenario.container.pump();
          }
          final stop = _drainOutcome(scenario.owner);
          await scenario.owner.openSystemSettings();
          port.completeError(StateError('retired Settings'));
          await action;
          expect(await stop, isA<StateError>());
          expect(scenario.settings.openSettingsCalls, 1);
          expect(scenario.restarter.calls, 0);
        } finally {
          await scenario.close(alreadyDisposed: disposed);
        }
      },
    );
  }

  for (final buildFailure in [false, true]) {
    test(
      'Prompt 131 sealed work failure refuses build=$buildFailure',
      () async {
        final scenario = await _DrainScenario.human(
          blockBuild: buildFailure,
          failBuild: buildFailure,
        );
        try {
          if (buildFailure) {
            scenario.reader.source = _readableSource;
          } else {
            scenario.reader.nextSource = Completer<AppCzarSourceObservation>();
          }
          final check = scenario.owner.checkAgain();
          if (buildFailure) {
            await scenario.executor.started.future;
          } else {
            await _flushOnboardingMicrotasks();
          }
          final before = scenario.container.read(
            appCzarOnboardingControllerProvider,
          );
          final stop = _drainOutcome(scenario.owner);
          if (buildFailure) {
            scenario.executor.release.complete();
          } else {
            scenario.reader.nextSource!.completeError(
              StateError('prerequisite failed'),
            );
          }
          await check;
          expect(await stop, isA<StateError>());
          expect(
            scenario.container.read(appCzarOnboardingControllerProvider),
            same(before),
          );
          expect(scenario.restarter.calls, 0);
        } finally {
          await scenario.close();
        }
      },
    );
  }

  test(
    'Prompt 131 repeated assessments request only one intentional restart',
    () async {
      final scenario = await _DrainScenario.human();
      try {
        final release = Completer<void>();
        scenario.restarter.pending = release;
        await scenario.container
            .read(appCzarAssessmentControllerProvider.notifier)
            .runAgain();
        await scenario.restarter.called.future;
        await scenario.container
            .read(appCzarAssessmentControllerProvider.notifier)
            .runAgain();
        await _flushOnboardingMicrotasks();
        expect(scenario.restarter.calls, 1);
        expect(await _drainOutcome(scenario.owner), isA<StateError>());
        release.complete();
        await _flushOnboardingMicrotasks();
        expect(await _drainOutcome(scenario.owner), isNull);
        expect(scenario.restarter.calls, 1);
      } finally {
        await scenario.close();
      }
    },
  );

  test('safe empty viable occurrence builds once and restarts once', () async {
    final reader = _OnboardingReader();
    final executor = _BuildExecutor();
    final restarter = _Restarter();
    final container = _container(reader, executor, restarter);
    addTearDown(container.dispose);

    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    await restarter.called.future.timeout(const Duration(seconds: 2));

    expect(executor.calls, 1);
    expect(restarter.calls, 1);
    expect(
      container.read(appCzarOnboardingControllerProvider).phase,
      AppCzarOnboardingPhase.restarting,
    );
  });

  test(
    'source denial stays in Onboarding and Check Again reuses reader',
    () async {
      final reader = _OnboardingReader(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.accessDenied,
          issue: 'denied',
        ),
      );
      final executor = _BuildExecutor();
      final restarter = _Restarter();
      final container = _container(reader, executor, restarter);
      addTearDown(container.dispose);
      container.listen(
        appCzarOnboardingControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );

      await _waitForPhase(container, AppCzarOnboardingPhase.sourceNeedsHuman);
      expect(executor.calls, 0);
      expect(restarter.calls, 0);

      reader.source = _readableSource;
      await container
          .read(appCzarOnboardingControllerProvider.notifier)
          .checkAgain();
      await restarter.called.future.timeout(const Duration(seconds: 2));
      expect(reader.sourceReads, greaterThanOrEqualTo(2));
      expect(executor.calls, 1);
    },
  );

  test(
    'unavailable source remains a literal Onboarding prerequisite',
    () async {
      final reader = _OnboardingReader(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.unavailable,
          issue: 'The Messages database does not exist.',
        ),
      );
      final executor = _BuildExecutor();
      final restarter = _Restarter();
      final container = _container(reader, executor, restarter);
      addTearDown(container.dispose);
      container.listen(
        appCzarOnboardingControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );

      await _waitForPhase(container, AppCzarOnboardingPhase.sourceNeedsHuman);
      expect(executor.calls, 0);
      expect(restarter.calls, 0);
      expect(
        container.read(appCzarOnboardingControllerProvider).sourceCondition,
        AppCzarSourceCondition.unavailable,
      );

      await container
          .read(appCzarOnboardingControllerProvider.notifier)
          .openSystemSettings();
      expect(
        container.read(realFdaSettingsOpeningAuthorityProvider),
        isA<FdaSettingsOpeningAdapter>(),
      );
      expect(_fullDiskAccess.openSettingsCalls, 0);
    },
  );

  test('ordinary stop drains the active build without restarting', () async {
    final executor = _BuildExecutor(block: true);
    final restarter = _Restarter();
    final container = _container(_OnboardingReader(), executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    await executor.started.future.timeout(const Duration(seconds: 2));

    var drained = false;
    final drain = container
        .read(appCzarOnboardingControllerProvider.notifier)
        .stopAndDrain()
        .then((_) => drained = true);
    await Future<void>.delayed(Duration.zero);
    expect(drained, isFalse);
    executor.release.complete();
    await drain;

    expect(restarter.calls, 0);
  });

  test(
    'assessment generation change drains active build before restart',
    () async {
      final executor = _BuildExecutor(block: true);
      final restarter = _Restarter();
      final container = _container(_OnboardingReader(), executor, restarter);
      addTearDown(container.dispose);
      container.listen(
        appCzarOnboardingControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await executor.started.future.timeout(const Duration(seconds: 2));

      final reassessment = container
          .read(appCzarAssessmentControllerProvider.notifier)
          .runAgain();
      await reassessment;
      await Future<void>.delayed(Duration.zero);
      expect(restarter.calls, 0);

      executor.release.complete();
      await restarter.called.future.timeout(const Duration(seconds: 2));

      expect(executor.calls, 1);
      expect(restarter.calls, 1);
    },
  );

  test('source UNKNOWN after admission drains and restarts', () async {
    final reader = _OnboardingReader(
      sourceAfterAssessment: const AppCzarSourceObservation.unknown(
        'inconclusive',
      ),
    );
    final executor = _BuildExecutor();
    final restarter = _Restarter();
    final container = _container(reader, executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    await restarter.called.future.timeout(const Duration(seconds: 2));
    expect(executor.calls, 0);
    expect(restarter.calls, 1);
  });

  test('Contacts human condition remains inside Onboarding', () async {
    final reader = _OnboardingReader(
      contacts: const AppCzarContactsPrerequisiteObservation(
        condition: AppCzarContactsPrerequisiteCondition.accessDenied,
        issue: 'current read denied',
      ),
    );
    final executor = _BuildExecutor();
    final restarter = _Restarter();
    final container = _container(reader, executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    await _waitForPhase(container, AppCzarOnboardingPhase.contactsNeedHuman);
    expect(executor.calls, 0);
    expect(restarter.calls, 0);
  });

  test(
    'unavailable Contacts remains a literal Onboarding prerequisite',
    () async {
      final reader = _OnboardingReader(
        contacts: const AppCzarContactsPrerequisiteObservation(
          condition: AppCzarContactsPrerequisiteCondition.unavailable,
          issue: 'No viable current Contacts database exists.',
        ),
      );
      final executor = _BuildExecutor();
      final restarter = _Restarter();
      final container = _container(reader, executor, restarter);
      addTearDown(container.dispose);
      container.listen(
        appCzarOnboardingControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );

      await _waitForPhase(container, AppCzarOnboardingPhase.contactsNeedHuman);
      expect(executor.calls, 0);
      expect(restarter.calls, 0);
    },
  );

  test('invalid Contacts evidence restarts without building', () async {
    final reader = _OnboardingReader(
      contactsAfterAssessment: const AppCzarContactsPrerequisiteObservation(
        condition: AppCzarContactsPrerequisiteCondition.invalidOrCorrupt,
        issue: 'The selected database is invalid.',
      ),
    );
    final executor = _BuildExecutor();
    final restarter = _Restarter();
    final container = _container(reader, executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    await restarter.called.future.timeout(const Duration(seconds: 2));
    expect(executor.calls, 0);
    expect(restarter.calls, 1);
  });

  test('Contacts UNKNOWN after admission restarts without building', () async {
    final reader = _OnboardingReader(
      contactsAfterAssessment:
          const AppCzarContactsPrerequisiteObservation.unknown('changed'),
    );
    final executor = _BuildExecutor();
    final restarter = _Restarter();
    final container = _container(reader, executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    await restarter.called.future.timeout(const Duration(seconds: 2));
    expect(executor.calls, 0);
    expect(restarter.calls, 1);
  });

  test('changed physical scope invalidates the admitted occurrence', () async {
    final reader = _OnboardingReader(
      scopeAfterAssessment: const AppCzarInitialConstructionScopeObservation(
        condition: AppCzarInitialConstructionScopeCondition.consequentialData,
        importMessageCount: 1,
        graphMessageCount: 0,
        graphChatCount: 0,
        graphEdgeCount: 0,
        nonLiveSourceCount: 0,
        hasRetiredDerivedArtifacts: false,
        issue: 'A row appeared after admission.',
      ),
    );
    final executor = _BuildExecutor();
    final restarter = _Restarter();
    final container = _container(reader, executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    await restarter.called.future.timeout(const Duration(seconds: 2));
    expect(reader.scopeReads, greaterThanOrEqualTo(2));
    expect(executor.calls, 0);
    expect(restarter.calls, 1);
  });

  test(
    'prerequisite read failure restarts instead of remaining pending',
    () async {
      final reader = _OnboardingReader(throwOnSecondSourceRead: true);
      final executor = _BuildExecutor();
      final restarter = _Restarter();
      final container = _container(reader, executor, restarter);
      addTearDown(container.dispose);
      container.listen(
        appCzarOnboardingControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );

      await restarter.called.future.timeout(const Duration(seconds: 2));
      expect(executor.calls, 0);
      expect(restarter.calls, 1);
    },
  );

  test('build failure restarts once for fresh classification', () async {
    final executor = _BuildExecutor(fail: true);
    final restarter = _Restarter();
    final container = _container(_OnboardingReader(), executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    await restarter.called.future.timeout(const Duration(seconds: 2));
    expect(executor.calls, 1);
    expect(restarter.calls, 1);
  });

  test('stale build progress cannot publish after stop begins', () async {
    final executor = _BuildExecutor(block: true);
    final container = _container(_OnboardingReader(), executor, _Restarter());
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    await executor.started.future.timeout(const Duration(seconds: 2));
    final beforeStop = container.read(appCzarOnboardingControllerProvider);

    final drain = container
        .read(appCzarOnboardingControllerProvider.notifier)
        .stopAndDrain();
    executor.publishProgress(completed: 2);
    expect(
      container.read(appCzarOnboardingControllerProvider).completedWorkCount,
      beforeStop.completedWorkCount,
    );
    executor.release.complete();
    await drain;
  });

  test(
    'only the exact Onboarding disposition satisfies execution predicate',
    () {
      for (final coordinator in AppCzarVirtualCoordinator.values) {
        expect(
          shouldExecuteAppCzarOnboarding(
            _assessmentState(coordinator: coordinator),
          ),
          coordinator == AppCzarVirtualCoordinator.onboarding,
          reason: coordinator.name,
        );
      }
    },
  );
}

ProviderContainer _container(
  _OnboardingReader reader,
  _BuildExecutor executor,
  _Restarter restarter,
) {
  _fullDiskAccess = _RecordingFullDiskAccess();
  return ProviderContainer(
    overrides: [
      appCzarObservationReaderProvider.overrideWithValue(reader),
      appCzarOnboardingBuildExecutorProvider.overrideWithValue(executor),
      appCzarProcessRestarterProvider.overrideWithValue(restarter),
      realFdaSettingsOpeningAuthorityProvider.overrideWithValue(
        FdaSettingsOpeningAdapter(fullDiskAccess: _fullDiskAccess),
      ),
    ],
  );
}

late _RecordingFullDiskAccess _fullDiskAccess;

final class _RecordingFullDiskAccess implements FullDiskAccess {
  var openSettingsCalls = 0;
  Completer<void>? pending;
  final pendingFlights = <Completer<void>>[];
  Future<void> Function()? onOpen;

  @override
  String get messagesDatabasePath => '/tmp/chat.db';

  @override
  bool canReadMessagesDatabase() => false;

  @override
  MessagesSourceAccessResult inspectMessagesSourceAccess() {
    return MessagesSourceAccessResult.unavailable;
  }

  @override
  Future<void> openSettings() async {
    openSettingsCalls += 1;
    if (onOpen != null) {
      await onOpen!();
    } else if (pendingFlights.isNotEmpty) {
      await pendingFlights[openSettingsCalls - 1].future;
    } else {
      await pending?.future;
    }
  }
}

Future<void> _waitForPhase(
  ProviderContainer container,
  AppCzarOnboardingPhase phase,
) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (container.read(appCzarOnboardingControllerProvider).phase == phase) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Did not reach ${phase.name}.');
}

final class _OnboardingReader
    implements
        AppCzarObservationReader,
        AppCzarInitialConstructionScopeReader,
        AppCzarContactsPrerequisiteReader {
  _OnboardingReader({
    this.source = _readableSource,
    this.sourceAfterAssessment,
    this.throwOnSecondSourceRead = false,
    this.scopeAfterAssessment,
    this.contacts = _viableContacts,
    this.contactsAfterAssessment,
  });

  AppCzarSourceObservation source;
  final AppCzarSourceObservation? sourceAfterAssessment;
  final bool throwOnSecondSourceRead;
  final AppCzarInitialConstructionScopeObservation? scopeAfterAssessment;
  AppCzarContactsPrerequisiteObservation contacts;
  final AppCzarContactsPrerequisiteObservation? contactsAfterAssessment;
  int scopeReads = 0;
  int sourceReads = 0;
  int contactsReads = 0;
  Completer<AppCzarSourceObservation>? nextSource;

  @override
  Future<AppCzarInitialConstructionScopeObservation>
  readInitialConstructionScope() async {
    scopeReads += 1;
    if (scopeReads > 1 && scopeAfterAssessment != null) {
      return scopeAfterAssessment!;
    }
    return _safeEmptyScope;
  }

  @override
  Future<AppCzarContactsPrerequisiteObservation>
  readContactsPrerequisite() async {
    contactsReads += 1;
    if (contactsReads > 1 && contactsAfterAssessment != null) {
      return contactsAfterAssessment!;
    }
    return contacts;
  }

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    return _archive;
  }

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async {
    return const AppCzarDatabaseObservation.absent();
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() async {
    return const AppCzarDatabaseObservation.absent();
  }

  @override
  Future<AppCzarDatabaseObservation> readOverlay() async {
    return const AppCzarDatabaseObservation.absent();
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    return const AppCzarRootObservation(admitted: true, path: '/tmp/root');
  }

  @override
  Future<AppCzarSourceObservation> readSource() async {
    sourceReads += 1;
    if (sourceReads > 2 && nextSource != null) {
      return nextSource!.future;
    }
    if (sourceReads > 1 && throwOnSecondSourceRead) {
      throw StateError('source read failed');
    }
    if (sourceReads > 1 && sourceAfterAssessment != null) {
      return sourceAfterAssessment!;
    }
    return source;
  }
}

final class _BuildExecutor implements AppCzarOnboardingBuildExecutor {
  _BuildExecutor({this.block = false, this.fail = false});

  final bool block;
  final bool fail;
  final Completer<void> started = Completer<void>();
  final Completer<void> release = Completer<void>();
  int calls = 0;
  ConversationGraphBuildObserver? _observer;

  void publishProgress({required int completed}) {
    _observer?.call(
      ConversationGraphBuildObservation(
        suboperation: ConversationGraphBuildSuboperation.importMessages,
        kind: ConversationGraphBuildObservationKind.progress,
        completedWorkCount: completed,
        totalWorkCount: 2,
      ),
    );
  }

  @override
  Future<void> run({
    required ConversationGraphBuildObserver onObservation,
  }) async {
    calls += 1;
    if (!started.isCompleted) {
      started.complete();
    }
    _observer = onObservation;
    onObservation(
      const ConversationGraphBuildObservation(
        suboperation: ConversationGraphBuildSuboperation.importMessages,
        kind: ConversationGraphBuildObservationKind.progress,
        completedWorkCount: 1,
        totalWorkCount: 2,
      ),
    );
    if (block) {
      await release.future;
    }
    if (fail) {
      throw StateError('build failed after admission');
    }
  }
}

final class _Restarter implements AppCzarProcessRestarter {
  Completer<void>? pending;
  Future<void> Function()? onRestart;
  final Completer<void> called = Completer<void>();
  int calls = 0;

  @override
  Future<void> restartAndReassess() async {
    calls += 1;
    if (!called.isCompleted) {
      called.complete();
    }
    await onRestart?.call();
    await pending?.future;
  }
}

const _readableSource = AppCzarSourceObservation(
  condition: AppCzarSourceCondition.readable,
  messageCount: 10,
  maxRowId: 10,
  sampleStable: true,
);

const _safeEmptyScope = AppCzarInitialConstructionScopeObservation(
  condition: AppCzarInitialConstructionScopeCondition.safeEmpty,
  importMessageCount: 0,
  graphMessageCount: 0,
  graphChatCount: 0,
  graphEdgeCount: 0,
  nonLiveSourceCount: 0,
  hasRetiredDerivedArtifacts: false,
  issue: null,
);

const _viableContacts = AppCzarContactsPrerequisiteObservation(
  condition: AppCzarContactsPrerequisiteCondition.viableEmpty,
  contactCount: 0,
  viableStoreCount: 1,
);

const _archive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.notCreated,
  label: 'Default archive',
  archiveScopeIdentity: 'scope',
  archiveGeneration: 0,
  resolvedPath: '/tmp/root/attachment_archive',
  coverage: AppCzarAttachmentCoverageObservation(
    condition: AppCzarAttachmentCoverageCondition.complete,
    requiredCount: 0,
    coveredCount: 0,
    missingCount: 0,
    unverifiableCount: 0,
    archiveScopeIdentity: 'scope',
    archiveGeneration: 0,
  ),
  repairability: AppCzarAttachmentRepairabilityObservation(
    condition: AppCzarAttachmentRepairOpportunityCondition.absent,
    availableFromMessagesCount: 0,
    sourceAbsentCount: 0,
    sourceUnknownCount: 0,
    recordBackedRecoveryCount: 0,
    unsafeOrConflictingCount: 0,
    archiveScopeIdentity: 'scope',
    archiveGeneration: 0,
  ),
);

AppCzarAssessmentState _assessmentState({
  required AppCzarVirtualCoordinator coordinator,
}) {
  return AppCzarAssessmentState(
    generation: 1,
    root: const AppCzarRootObservation(admitted: true, path: '/tmp/root'),
    initialConstructionScope: _safeEmptyScope,
    source: _readableSource,
    contactsPrerequisite: _viableContacts,
    importStore: const AppCzarDatabaseObservation.absent(),
    graphStore: const AppCzarDatabaseObservation.absent(),
    overlay: const AppCzarDatabaseObservation.absent(),
    attachmentArchive: _archive,
    assessment: AppCzarAssessment(
      facts: const <AppCzarFact>[
        AppCzarFact(
          id: AppCzarFactId.developmentRootAdmitted,
          label: 'root',
          truth: AppCzarTruth.trueValue,
          detail: 'admitted',
        ),
        AppCzarFact(
          id: AppCzarFactId.initialConstructionScopeSafe,
          label: 'scope',
          truth: AppCzarTruth.trueValue,
          detail: 'safe',
        ),
        AppCzarFact(
          id: AppCzarFactId.messagesSourceReadable,
          label: 'source',
          truth: AppCzarTruth.trueValue,
          detail: 'readable',
        ),
        AppCzarFact(
          id: AppCzarFactId.attachmentArchiveAvailable,
          label: 'archive',
          truth: AppCzarTruth.trueValue,
          detail: 'available',
        ),
      ],
      diagnosisKind: AppCzarDiagnosisKind.incompleteLocalDataset,
      diagnosis: 'test',
      virtualCoordinator: coordinator,
    ),
  );
}

Future<void> _flushOnboardingMicrotasks() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.microtask(() {});
  }
}

Future<Object?> _drainOutcome(AppCzarOnboardingController owner) {
  return owner.stopAndDrain().then<Object?>(
    (_) => null,
    onError: (Object error, StackTrace stack) => error,
  );
}

final class _DrainScenario {
  _DrainScenario(
    this.reader,
    this.executor,
    this.restarter,
    this.container,
    this.settings,
    this.owner,
  );
  final _OnboardingReader reader;
  final _BuildExecutor executor;
  final _Restarter restarter;
  final ProviderContainer container;
  final _RecordingFullDiskAccess settings;
  final AppCzarOnboardingController owner;

  static Future<_DrainScenario> human({
    bool blockBuild = false,
    bool failBuild = false,
  }) async {
    final reader = _OnboardingReader(
      source: const AppCzarSourceObservation(
        condition: AppCzarSourceCondition.accessDenied,
      ),
    );
    final executor = _BuildExecutor(block: blockBuild, fail: failBuild);
    final restarter = _Restarter();
    final container = _container(reader, executor, restarter);
    final ready = Completer<void>();
    container.listen(appCzarOnboardingControllerProvider, (_, next) {
      if (next.phase == AppCzarOnboardingPhase.sourceNeedsHuman &&
          !ready.isCompleted) {
        ready.complete();
      }
    }, fireImmediately: true);
    await ready.future;
    await _flushOnboardingMicrotasks();
    return _DrainScenario(
      reader,
      executor,
      restarter,
      container,
      _fullDiskAccess,
      container.read(appCzarOnboardingControllerProvider.notifier),
    );
  }

  Future<void> close({bool alreadyDisposed = false}) async {
    for (final barrier in [
      settings.pending,
      ...settings.pendingFlights,
      executor.started,
      executor.release,
      restarter.called,
      restarter.pending,
    ]) {
      if (barrier != null && !barrier.isCompleted) {
        barrier.complete();
      }
    }
    if (reader.nextSource != null && !reader.nextSource!.isCompleted) {
      reader.nextSource!.complete(reader.source);
    }
    await _drainOutcome(owner);
    await _flushOnboardingMicrotasks();
    if (!alreadyDisposed) {
      container.dispose();
    }
  }
}
