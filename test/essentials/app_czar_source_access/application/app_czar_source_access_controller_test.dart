import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_data_update_controller.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import 'package:remember_this_text/essentials/app_czar_source_access/application/app_czar_source_access_controller.dart';
import 'package:remember_this_text/essentials/app_czar_source_access/domain/app_czar_source_access_state.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access_provider.dart';

void main() {
  test('exactly two restart coordinators are executable top-level', () {
    final executable = <AppCzarVirtualCoordinator>[];
    for (final coordinator in AppCzarVirtualCoordinator.values) {
      final state = _assessmentState(
        coordinator: coordinator,
        truth: AppCzarTruth.falseValue,
        sourceCondition: AppCzarSourceCondition.accessDenied,
      );
      if (shouldExecuteAppCzarDataUpdate(state) ||
          shouldExecuteAppCzarSourceAccessRepair(state)) {
        executable.add(coordinator);
      }
    }

    expect(executable, <AppCzarVirtualCoordinator>[
      AppCzarVirtualCoordinator.sourceAccessRepair,
      AppCzarVirtualCoordinator.dataUpdate,
    ]);
  });

  test('only exact conclusive Source Access Repair mapping is executable', () {
    for (final coordinator in AppCzarVirtualCoordinator.values) {
      final state = _assessmentState(
        coordinator: coordinator,
        truth: AppCzarTruth.falseValue,
        sourceCondition: AppCzarSourceCondition.accessDenied,
      );
      expect(
        shouldExecuteAppCzarSourceAccessRepair(state),
        coordinator == AppCzarVirtualCoordinator.sourceAccessRepair,
      );
    }

    expect(
      shouldExecuteAppCzarSourceAccessRepair(
        _assessmentState(
          coordinator: AppCzarVirtualCoordinator.sourceAccessRepair,
          truth: AppCzarTruth.unknown,
          sourceCondition: AppCzarSourceCondition.unknown,
        ),
      ),
      isFalse,
    );
  });

  test('selected and dormant construction perform no port actions', () async {
    for (final selected in [true, false]) {
      final f = _fixture(selected: selected);
      expect(f.reader.calls, 0);
      expect(f.settings.openCalls, 0);
      expect(f.restarter.calls, 0);
      await f.owner.stopAndDrain();
      await f.owner.openSystemSettings();
      await f.owner.checkAgain();
      await f.owner.restartAndReassess();
      expect(f.reader.calls, 0);
      expect(f.settings.openCalls, 0);
      expect(f.restarter.calls, 0);
    }
  });

  for (final settingsAction in [true, false]) {
    for (final fails in [false, true]) {
      test(
        'drain waits for Settings=$settingsAction and refuses failure=$fails',
        () async {
          final done = Completer<void>();
          final settings = _FakeFullDiskAccess(action: () => done.future);
          final f = _fixture(settings: settings);
          final action = settingsAction
              ? f.owner.openSystemSettings()
              : f.owner.checkAgain();
          await (settingsAction
              ? settings.started.future
              : f.reader.started.future);
          final before = f.container.read(
            appCzarSourceAccessControllerProvider,
          );
          var drained = false;
          final drain = f.owner.stopAndDrain().then((_) {
            drained = true;
          });
          final duplicate = f.owner.stopAndDrain();
          final expectations = fails
              ? Future.wait([
                  expectLater(drain, throwsStateError),
                  expectLater(duplicate, throwsStateError),
                ])
              : Future.wait([drain, duplicate]);
          await f.owner.checkAgain();
          await f.owner.openSystemSettings();
          await f.owner.restartAndReassess();
          expect(drained, isFalse);
          expect(f.restarter.calls, 0);
          if (settingsAction) {
            if (fails) {
              done.completeError(StateError('synthetic Settings failure'));
            } else {
              done.complete();
            }
          } else {
            if (fails) {
              f.reader.done.completeError(StateError('synthetic read failure'));
            } else {
              f.reader.done.complete(
                const AppCzarSourceObservation(
                  condition: AppCzarSourceCondition.readable,
                ),
              );
            }
            done.complete();
          }
          await action;
          await expectations;
          expect(
            f.container.read(appCzarSourceAccessControllerProvider),
            same(before),
          );
          expect(f.restarter.calls, 0);
          expect(f.settings.openCalls, settingsAction ? 1 : 0);
          expect(f.reader.calls, settingsAction ? 0 : 1);
        },
      );
    }
  }

  for (final condition in AppCzarSourceCondition.values) {
    test('source outcome stays exact: ${condition.name}', () async {
      final f = _fixture();
      final check = f.owner.checkAgain();
      await f.reader.started.future;
      await f.owner.checkAgain();
      f.reader.done.complete(
        AppCzarSourceObservation(condition: condition, issue: 'literal result'),
      );
      await check;
      expect(f.reader.calls, 1);
      final state = f.container.read(appCzarSourceAccessControllerProvider);
      expect(state.phase, switch (condition) {
        AppCzarSourceCondition.readable =>
          AppCzarSourceAccessPhase.restartRequested,
        AppCzarSourceCondition.unknown => AppCzarSourceAccessPhase.inconclusive,
        _ => AppCzarSourceAccessPhase.waitingForHuman,
      });
      expect(
        f.restarter.calls,
        condition == AppCzarSourceCondition.readable ? 1 : 0,
      );
    });
  }

  test(
    'open-admission Settings, source and restart errors retain reporting',
    () async {
      final f = _fixture(
        settings: _FakeFullDiskAccess(
          action: () async {
            throw StateError('settings');
          },
        ),
        restarter: _RecordingRestarter(
          action: () async {
            throw StateError('restart');
          },
        ),
      );
      await f.owner.openSystemSettings();
      expect(
        f.container.read(appCzarSourceAccessControllerProvider).settingsFailure,
        contains('settings'),
      );
      final check = f.owner.checkAgain();
      await f.reader.started.future;
      f.reader.done.completeError(StateError('source'));
      await check;
      expect(
        f.container.read(appCzarSourceAccessControllerProvider).phase,
        AppCzarSourceAccessPhase.inconclusive,
      );
      expect(
        f.container.read(appCzarSourceAccessControllerProvider).sourceReason,
        contains('source'),
      );
      await f.owner.restartAndReassess();
      expect(
        f.container.read(appCzarSourceAccessControllerProvider).phase,
        AppCzarSourceAccessPhase.restartFailed,
      );
      expect(
        f.container.read(appCzarSourceAccessControllerProvider).restartFailure,
        contains('restart'),
      );
    },
  );

  test(
    'pending restart refuses reentrant and external drain without self-await',
    () async {
      late AppCzarSourceAccessController owner;
      final reentered = Completer<void>();
      final release = Completer<void>();
      final restart = _RecordingRestarter(
        action: () async {
          await expectLater(owner.stopAndDrain(), throwsStateError);
          reentered.complete();
          await release.future;
        },
      );
      final f = _fixture(restarter: restart);
      owner = f.owner;
      final check = owner.checkAgain();
      await f.reader.started.future;
      f.reader.done.complete(const AppCzarSourceObservation.unknown('unknown'));
      await check;
      final run = owner.restartAndReassess();
      await owner.restartAndReassess();
      await reentered.future;
      await expectLater(owner.stopAndDrain(), throwsStateError);
      expect(restart.calls, 1);
      release.complete();
      await run;
      await owner.stopAndDrain(); // Only now is the restart actually settled.
    },
  );

  test('quit seals a queued manual restart before port dispatch', () async {
    final f = _fixture();
    final check = f.owner.checkAgain();
    await f.reader.started.future;
    f.reader.done.complete(const AppCzarSourceObservation.unknown('unknown'));
    await check;
    final restart = f.owner.restartAndReassess();
    await expectLater(f.owner.stopAndDrain(), throwsStateError);
    await restart;
    await f.owner.stopAndDrain();
    expect(f.restarter.calls, 0);
  });

  test('drain waits for both independent non-restart flights', () async {
    final release = Completer<void>();
    final settings = _FakeFullDiskAccess(action: () => release.future);
    final f = _fixture(settings: settings);
    final open = f.owner.openSystemSettings();
    final check = f.owner.checkAgain();
    await settings.started.future;
    await f.reader.started.future;
    var settled = false;
    final drain = f.owner.stopAndDrain().then((_) {
      settled = true;
    });
    release.complete();
    await open;
    expect(settled, isFalse);
    expect(f.restarter.calls, 0);
    f.reader.done.complete(
      const AppCzarSourceObservation(
        condition: AppCzarSourceCondition.readable,
      ),
    );
    await check;
    await drain;
    expect(settled, isTrue);
    expect(f.restarter.calls, 0);
  });

  test(
    'restart waits for independent Settings request before dispatch',
    () async {
      final release = Completer<void>();
      final settings = _FakeFullDiskAccess(action: () => release.future);
      final f = _fixture(settings: settings);
      final open = f.owner.openSystemSettings();
      await settings.started.future;
      final check = f.owner.checkAgain();
      await f.reader.started.future;
      f.reader.done.complete(
        const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.readable,
        ),
      );
      await Future<void>.value();
      expect(f.restarter.calls, 0);
      release.complete();
      await Future.wait([open, check]);
      expect(f.restarter.calls, 1);
    },
  );

  test(
    'stop between readable publication and dispatch prevents restart',
    () async {
      final f = _fixture();
      Future<void>? drain;
      final sub = f.container.listen(appCzarSourceAccessControllerProvider, (
        _,
        next,
      ) {
        if (next.phase == AppCzarSourceAccessPhase.restartRequested) {
          drain = f.owner.stopAndDrain();
        }
      });
      addTearDown(sub.close);
      final check = f.owner.checkAgain();
      await f.reader.started.future;
      f.reader.done.complete(
        const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.readable,
        ),
      );
      await check;
      expect(drain, isNotNull);
      await drain;
      expect(f.restarter.calls, 0);
    },
  );

  for (final dispose in [true, false]) {
    test('late source result suppressed on dispose=$dispose', () async {
      final f = _fixture(disposeAtTeardown: !dispose);
      final check = f.owner.checkAgain();
      await f.reader.started.future;
      final before = f.container.read(appCzarSourceAccessControllerProvider);
      if (dispose) {
        f.container.dispose();
      } else {
        (f.container.read(appCzarAssessmentControllerProvider.notifier)
                as _SelectedAssessment)
            .replace();
      }
      f.reader.done.complete(
        const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.readable,
        ),
      );
      await check;
      await f.owner.stopAndDrain();
      expect(f.restarter.calls, 0);
      if (!dispose) {
        expect(
          f.container.read(appCzarSourceAccessControllerProvider),
          same(before),
        );
      }
    });
  }

  test(
    'characterization: Settings and source check settle independently',
    () async {
      final settingsDone = Completer<void>();
      final sourceDone = Completer<AppCzarSourceObservation>();
      final settings = _FakeFullDiskAccess(action: () => settingsDone.future);
      final restarter = _RecordingRestarter();
      final reader = _SourceAccessReader(retests: [sourceDone.future]);
      final container = _container(reader, settings, restarter);
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarSourceAccessControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      await _waitForPhase(container, AppCzarSourceAccessPhase.waitingForHuman);
      expect(settings.openCalls, 0);
      expect(reader.sourceReads, 1); // Initial fake assessment only.
      final owner = container.read(
        appCzarSourceAccessControllerProvider.notifier,
      );
      var settingsSettled = false;
      final settingsRun = owner.openSystemSettings().then((_) {
        settingsSettled = true;
      });
      final check = owner.checkAgain();
      await owner.openSystemSettings();
      expect(settings.openCalls, 1);
      expect(restarter.calls, 0);
      sourceDone.complete(
        const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.accessDenied,
        ),
      );
      await check;
      expect(settingsSettled, isFalse);
      settingsDone.complete();
      await settingsRun;
      expect(restarter.calls, 0);
    },
  );

  test('starts once and opening Settings is navigation only', () async {
    final reader = _SourceAccessReader(
      retests: <Future<AppCzarSourceObservation>>[],
    );
    final settings = _FakeFullDiskAccess();
    final restarter = _RecordingRestarter();
    final container = _container(reader, settings, restarter);
    addTearDown(container.dispose);
    final subscription = container.listen(
      appCzarSourceAccessControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await _waitForPhase(container, AppCzarSourceAccessPhase.waitingForHuman);
    final before = container.read(appCzarSourceAccessControllerProvider);

    await container
        .read(appCzarSourceAccessControllerProvider.notifier)
        .openSystemSettings();

    final after = container.read(appCzarSourceAccessControllerProvider);
    expect(settings.openCalls, 1);
    expect(after.phase, AppCzarSourceAccessPhase.waitingForHuman);
    expect(after.sourceReason, before.sourceReason);
    expect(reader.sourceReads, 1);
    expect(restarter.calls, 0);

    await container
        .read(appCzarAssessmentControllerProvider.notifier)
        .runAgain();
    expect(
      container
          .read(appCzarSourceAccessControllerProvider)
          .assessmentGeneration,
      0,
    );
  });

  test(
    'Check Again is single-flight and readable requests one restart',
    () async {
      final retest = Completer<AppCzarSourceObservation>();
      final reader = _SourceAccessReader(
        retests: <Future<AppCzarSourceObservation>>[retest.future],
      );
      final restarter = _RecordingRestarter();
      final container = _container(reader, _FakeFullDiskAccess(), restarter);
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarSourceAccessControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      await _waitForPhase(container, AppCzarSourceAccessPhase.waitingForHuman);

      final controller = container.read(
        appCzarSourceAccessControllerProvider.notifier,
      );
      final first = controller.checkAgain();
      final duplicate = controller.checkAgain();
      await duplicate;
      expect(reader.sourceReads, 2);
      expect(
        container.read(appCzarSourceAccessControllerProvider).phase,
        AppCzarSourceAccessPhase.checking,
      );

      retest.complete(
        const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.readable,
          messageCount: 108,
          maxRowId: 108,
          sampleStable: true,
        ),
      );
      await first;

      final state = container.read(appCzarSourceAccessControllerProvider);
      expect(state.phase, AppCzarSourceAccessPhase.restartRequested);
      expect(
        state.sourceReason,
        contains('read-only Messages source check succeeded'),
      );
      expect(restarter.calls, 1);
      await controller.checkAgain();
      await controller.restartAndReassess();
      expect(restarter.calls, 1);
    },
  );

  test('still-unreadable retest remains with current literal reason', () async {
    final reader = _SourceAccessReader(
      retests: <Future<AppCzarSourceObservation>>[
        Future<AppCzarSourceObservation>.value(
          const AppCzarSourceObservation(
            condition: AppCzarSourceCondition.unavailable,
            issue: 'The Messages volume is not currently available.',
          ),
        ),
      ],
    );
    final restarter = _RecordingRestarter();
    final container = _container(reader, _FakeFullDiskAccess(), restarter);
    addTearDown(container.dispose);
    final subscription = container.listen(
      appCzarSourceAccessControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await _waitForPhase(container, AppCzarSourceAccessPhase.waitingForHuman);

    await container
        .read(appCzarSourceAccessControllerProvider.notifier)
        .checkAgain();

    final state = container.read(appCzarSourceAccessControllerProvider);
    expect(state.phase, AppCzarSourceAccessPhase.waitingForHuman);
    expect(
      state.sourceReason,
      'The Messages volume is not currently available.',
    );
    expect(restarter.calls, 0);
  });

  test('UNKNOWN retest leaves jurisdiction and only permits restart', () async {
    final reader = _SourceAccessReader(
      retests: <Future<AppCzarSourceObservation>>[
        Future<AppCzarSourceObservation>.value(
          const AppCzarSourceObservation.unknown(
            'The current read-only result was inconclusive.',
          ),
        ),
      ],
    );
    final restarter = _RecordingRestarter();
    final container = _container(reader, _FakeFullDiskAccess(), restarter);
    addTearDown(container.dispose);
    final subscription = container.listen(
      appCzarSourceAccessControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await _waitForPhase(container, AppCzarSourceAccessPhase.waitingForHuman);

    final controller = container.read(
      appCzarSourceAccessControllerProvider.notifier,
    );
    await controller.checkAgain();

    final inconclusive = container.read(appCzarSourceAccessControllerProvider);
    expect(inconclusive.phase, AppCzarSourceAccessPhase.inconclusive);
    expect(inconclusive.sourceReason, contains('inconclusive'));
    expect(inconclusive.sourceReason, isNot(contains('denied')));
    expect(inconclusive.canCheckAgain, isFalse);
    expect(restarter.calls, 0);

    await controller.checkAgain();
    expect(reader.sourceReads, 2);
    await controller.restartAndReassess();
    await controller.restartAndReassess();
    expect(restarter.calls, 1);
  });
}

ProviderContainer _container(
  AppCzarObservationReader reader,
  FullDiskAccess settings,
  AppCzarProcessRestarter restarter,
) {
  return ProviderContainer(
    overrides: [
      appCzarObservationReaderProvider.overrideWithValue(reader),
      fullDiskAccessProvider.overrideWithValue(settings),
      appCzarProcessRestarterProvider.overrideWithValue(restarter),
    ],
  );
}

Future<void> _waitForPhase(
  ProviderContainer container,
  AppCzarSourceAccessPhase phase,
) async {
  final ready = Completer<void>();
  final subscription = container.listen(appCzarSourceAccessControllerProvider, (
    _,
    next,
  ) {
    if (next.phase == phase && !ready.isCompleted) {
      ready.complete();
    }
  }, fireImmediately: true);
  try {
    await ready.future;
  } finally {
    subscription.close();
  }
}

AppCzarAssessmentState _assessmentState({
  required AppCzarVirtualCoordinator coordinator,
  required AppCzarTruth truth,
  required AppCzarSourceCondition sourceCondition,
}) {
  return AppCzarAssessmentState(
    generation: 7,
    source: AppCzarSourceObservation(
      condition: sourceCondition,
      issue: 'Current source result.',
    ),
    assessment: AppCzarAssessment(
      facts: <AppCzarFact>[
        AppCzarFact(
          id: AppCzarFactId.messagesSourceReadable,
          label: 'Messages database readable',
          truth: truth,
          detail: 'Current source result.',
        ),
      ],
      diagnosisKind: truth == AppCzarTruth.falseValue
          ? AppCzarDiagnosisKind.sourceAccessUnavailable
          : AppCzarDiagnosisKind.contradictoryOrInsufficientEvidence,
      diagnosis: 'Current assessment.',
      virtualCoordinator: coordinator,
    ),
  );
}

final class _SourceAccessReader implements AppCzarObservationReader {
  _SourceAccessReader({required List<Future<AppCzarSourceObservation>> retests})
    : _retests = retests;

  final List<Future<AppCzarSourceObservation>> _retests;
  int sourceReads = 0;

  @override
  Future<AppCzarSourceObservation> readSource() {
    sourceReads += 1;
    if (sourceReads == 1) {
      return Future<AppCzarSourceObservation>.value(
        const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.accessDenied,
          issue: 'macOS denied this read-only Messages database access.',
        ),
      );
    }
    return _retests[sourceReads - 2];
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    return const AppCzarRootObservation(
      admitted: true,
      path: '/Volumes/WD_ELEMENTS/MessageLens Development',
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() async => _importStore;

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async => _graphStore;

  @override
  Future<AppCzarDatabaseObservation> readOverlay() async => _overlay;

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async => _archive;
}

final class _FakeFullDiskAccess implements FullDiskAccess {
  _FakeFullDiskAccess({this.action});
  final Future<void> Function()? action;
  int openCalls = 0;
  final started = Completer<void>();

  @override
  String get messagesDatabasePath => '/test/Library/Messages/chat.db';

  @override
  bool canReadMessagesDatabase() => false;

  @override
  MessagesSourceAccessResult inspectMessagesSourceAccess() =>
      MessagesSourceAccessResult.accessDenied;

  @override
  Future<void> openSettings() async {
    openCalls += 1;
    if (!started.isCompleted) {
      started.complete();
    }
    await action?.call();
  }
}

final class _RecordingRestarter implements AppCzarProcessRestarter {
  _RecordingRestarter({this.action});
  final Future<void> Function()? action;
  int calls = 0;

  @override
  Future<void> restartAndReassess() async {
    calls += 1;
    await action?.call();
  }
}

const _importStore = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  schemaVersion: 10,
  messageCount: 100,
  liveMessageCount: 100,
  liveMaxSourceRowId: 100,
);
const _graphStore = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  schemaVersion: 3,
  messageCount: 100,
  chatCount: 4,
  chatMessageEdgeCount: 100,
);
const _overlay = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  schemaVersion: 8,
);
const _archive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.available,
  label: 'Test archive',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
  coverage: _completeCoverage,
);
const _completeCoverage = AppCzarAttachmentCoverageObservation(
  condition: AppCzarAttachmentCoverageCondition.complete,
  requiredCount: 1,
  coveredCount: 1,
  missingCount: 0,
  unverifiableCount: 0,
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
);

final class _SelectedAssessment extends AppCzarAssessmentController {
  @override
  AppCzarAssessmentState build() => _assessmentState(
    coordinator: AppCzarVirtualCoordinator.sourceAccessRepair,
    truth: AppCzarTruth.falseValue,
    sourceCondition: AppCzarSourceCondition.accessDenied,
  );
  void replace() {
    state = AppCzarAssessmentState.initial(8);
  }
}

final class _DormantAssessment extends AppCzarAssessmentController {
  @override
  AppCzarAssessmentState build() => AppCzarAssessmentState.initial(0);
}

final class _ControlledReader implements AppCzarObservationReader {
  final done = Completer<AppCzarSourceObservation>();
  final started = Completer<void>();
  int calls = 0;
  @override
  Future<AppCzarSourceObservation> readSource() {
    calls++;
    if (!started.isCompleted) {
      started.complete();
    }
    return done.future;
  }

  @override
  Future<AppCzarRootObservation> readRoot() async =>
      const AppCzarRootObservation(admitted: true, path: '/synthetic');
  @override
  Future<AppCzarDatabaseObservation> readImportStore() async => _importStore;
  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async => _graphStore;
  @override
  Future<AppCzarDatabaseObservation> readOverlay() async => _overlay;
  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async => _archive;
}

({
  ProviderContainer container,
  AppCzarSourceAccessController owner,
  _ControlledReader reader,
  _FakeFullDiskAccess settings,
  _RecordingRestarter restarter,
})
_fixture({
  bool selected = true,
  _FakeFullDiskAccess? settings,
  _RecordingRestarter? restarter,
  bool disposeAtTeardown = true,
}) {
  final reader = _ControlledReader();
  final opener = settings ?? _FakeFullDiskAccess();
  final restart = restarter ?? _RecordingRestarter();
  final container = ProviderContainer(
    overrides: [
      appCzarAssessmentControllerProvider.overrideWith(
        selected ? _SelectedAssessment.new : _DormantAssessment.new,
      ),
      appCzarObservationReaderProvider.overrideWithValue(reader),
      fullDiskAccessProvider.overrideWithValue(opener),
      appCzarProcessRestarterProvider.overrideWithValue(restart),
    ],
  );
  if (disposeAtTeardown) {
    addTearDown(container.dispose);
  }
  final sub = container.listen(
    appCzarSourceAccessControllerProvider,
    (_, _) {},
    fireImmediately: true,
  );
  if (disposeAtTeardown) {
    addTearDown(sub.close);
  }
  return (
    container: container,
    owner: container.read(appCzarSourceAccessControllerProvider.notifier),
    reader: reader,
    settings: opener,
    restarter: restart,
  );
}
