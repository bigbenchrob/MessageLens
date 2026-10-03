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
  test('exactly Data Update and Source Access Repair are executable', () {
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
  for (var attempt = 0; attempt < 100; attempt += 1) {
    if (container.read(appCzarSourceAccessControllerProvider).phase == phase) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Timed out waiting for ${phase.name}.');
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
  int openCalls = 0;

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
  }
}

final class _RecordingRestarter implements AppCzarProcessRestarter {
  int calls = 0;

  @override
  Future<void> restartAndReassess() async {
    calls += 1;
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
);
