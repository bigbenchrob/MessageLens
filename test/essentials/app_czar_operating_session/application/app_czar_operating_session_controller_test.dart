import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_session_controller.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_session_visual_initializer_provider.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/domain/app_czar_operating_session_state.dart';

void main() {
  group('shouldExecuteAppCzarOperatingSession', () {
    test('accepts only the exact healthy/current Operating fact set', () {
      expect(
        shouldExecuteAppCzarOperatingSession(_operatingAssessmentState()),
        isTrue,
      );

      for (final coordinator in AppCzarVirtualCoordinator.values) {
        if (coordinator == AppCzarVirtualCoordinator.operatingSession) {
          continue;
        }
        expect(
          shouldExecuteAppCzarOperatingSession(
            _operatingAssessmentState(coordinator: coordinator),
          ),
          isFalse,
          reason: '${coordinator.name} must not admit Operating Session.',
        );
      }
    });

    test('fails closed for every non-current or incomplete fact', () {
      const requiredTrueFacts = <AppCzarFactId>{
        AppCzarFactId.developmentRootAdmitted,
        AppCzarFactId.messagesSourceReadable,
        AppCzarFactId.sourceSampleStable,
        AppCzarFactId.importStoreHealthy,
        AppCzarFactId.graphStoreHealthy,
        AppCzarFactId.overlayHealthy,
        AppCzarFactId.localDatasetComplete,
        AppCzarFactId.attachmentArchiveAvailable,
        AppCzarFactId.sourceLocalDeltaKnown,
      };
      for (final factId in requiredTrueFacts) {
        expect(
          shouldExecuteAppCzarOperatingSession(
            _operatingAssessmentState(
              truthOverrides: <AppCzarFactId, AppCzarTruth>{
                factId: AppCzarTruth.unknown,
              },
            ),
          ),
          isFalse,
          reason: '${factId.name} UNKNOWN must fail closed.',
        );
        expect(
          shouldExecuteAppCzarOperatingSession(
            _operatingAssessmentState(
              truthOverrides: <AppCzarFactId, AppCzarTruth>{
                factId: AppCzarTruth.falseValue,
              },
            ),
          ),
          isFalse,
          reason: '${factId.name} FALSE must fail closed.',
        );
      }

      expect(
        shouldExecuteAppCzarOperatingSession(
          _operatingAssessmentState(
            truthOverrides: const <AppCzarFactId, AppCzarTruth>{
              AppCzarFactId.sourceAheadOfLocal: AppCzarTruth.trueValue,
            },
          ),
        ),
        isFalse,
      );
      expect(
        shouldExecuteAppCzarOperatingSession(
          _operatingAssessmentState(
            truthOverrides: const <AppCzarFactId, AppCzarTruth>{
              AppCzarFactId.sourceAheadOfLocal: AppCzarTruth.unknown,
            },
          ),
        ),
        isFalse,
      );
      expect(
        shouldExecuteAppCzarOperatingSession(
          _operatingAssessmentState(omittedFact: AppCzarFactId.overlayHealthy),
        ),
        isFalse,
      );
      expect(
        shouldExecuteAppCzarOperatingSession(
          _operatingAssessmentState(
            duplicateFact: AppCzarFactId.overlayHealthy,
          ),
        ),
        isFalse,
      );
      expect(
        shouldExecuteAppCzarOperatingSession(AppCzarAssessmentState.initial(9)),
        isFalse,
      );
    });
  });

  test(
    'delayed visual initialization admits the exact generation once',
    () async {
      final initializer = _ControlledVisualInitializer();
      final container = _container(initializer);
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarOperatingSessionControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await _waitForPhase(
        container,
        AppCzarOperatingSessionPhase.restoringVisualWindowState,
      );
      await initializer.started;
      expect(initializer.calls, 1);
      expect(
        container
            .read(appCzarOperatingSessionControllerProvider)
            .assessmentGeneration,
        0,
      );
      expect(
        container.read(appCzarOperatingSessionControllerProvider).isAdmitted,
        isFalse,
      );

      for (var read = 0; read < 5; read += 1) {
        container.read(appCzarOperatingSessionControllerProvider);
      }
      expect(initializer.calls, 1);

      initializer.release();
      await _waitForPhase(container, AppCzarOperatingSessionPhase.admitted);
      expect(initializer.calls, 1);
      expect(
        container.read(appCzarOperatingSessionControllerProvider).isAdmitted,
        isTrue,
      );
    },
  );

  test(
    'a newer exact assessment gets one occurrence and stale completion cannot win',
    () async {
      final initializer = _ControlledVisualInitializer();
      final container = _container(initializer);
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarOperatingSessionControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await _waitForPhase(
        container,
        AppCzarOperatingSessionPhase.restoringVisualWindowState,
      );
      await initializer.started;
      expect(initializer.calls, 1);

      await container
          .read(appCzarAssessmentControllerProvider.notifier)
          .runAgain();
      await _waitForGenerationPhase(
        container,
        generation: 1,
        phase: AppCzarOperatingSessionPhase.restoringVisualWindowState,
      );
      expect(initializer.calls, 2);

      initializer.release();
      await _waitForGenerationPhase(
        container,
        generation: 1,
        phase: AppCzarOperatingSessionPhase.admitted,
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        container
            .read(appCzarOperatingSessionControllerProvider)
            .assessmentGeneration,
        1,
      );
      expect(initializer.calls, 2);
      expect(
        container.read(appCzarOperatingSessionControllerProvider).isAdmitted,
        isTrue,
      );
    },
  );

  test('visual initialization failure does not admit Operating', () async {
    final initializer = _ControlledVisualInitializer(
      failure: StateError('window state unavailable'),
    );
    final container = _container(initializer);
    addTearDown(container.dispose);
    final subscription = container.listen(
      appCzarOperatingSessionControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await _waitForPhase(
      container,
      AppCzarOperatingSessionPhase.restoringVisualWindowState,
    );
    await initializer.started;
    initializer.release();
    await _waitForPhase(container, AppCzarOperatingSessionPhase.failed);

    final failed = container.read(appCzarOperatingSessionControllerProvider);
    expect(failed.assessmentGeneration, 0);
    expect(failed.failure, contains('window state unavailable'));
    expect(failed.isAdmitted, isFalse);
    expect(initializer.calls, 1);
  });
}

ProviderContainer _container(
  AppCzarOperatingSessionVisualInitializer initializer,
) {
  return ProviderContainer(
    overrides: [
      appCzarObservationReaderProvider.overrideWithValue(
        const _OperatingReader(),
      ),
      appCzarOperatingSessionVisualInitializerProvider.overrideWithValue(
        initializer,
      ),
    ],
  );
}

Future<void> _waitForPhase(
  ProviderContainer container,
  AppCzarOperatingSessionPhase phase,
) async {
  for (var attempt = 0; attempt < 100; attempt += 1) {
    if (container.read(appCzarOperatingSessionControllerProvider).phase ==
        phase) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Timed out waiting for ${phase.name}.');
}

Future<void> _waitForGenerationPhase(
  ProviderContainer container, {
  required int generation,
  required AppCzarOperatingSessionPhase phase,
}) async {
  for (var attempt = 0; attempt < 100; attempt += 1) {
    final state = container.read(appCzarOperatingSessionControllerProvider);
    if (state.assessmentGeneration == generation && state.phase == phase) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Timed out waiting for generation $generation in ${phase.name}.');
}

AppCzarAssessmentState _operatingAssessmentState({
  AppCzarVirtualCoordinator coordinator =
      AppCzarVirtualCoordinator.operatingSession,
  Map<AppCzarFactId, AppCzarTruth> truthOverrides =
      const <AppCzarFactId, AppCzarTruth>{},
  AppCzarFactId? omittedFact,
  AppCzarFactId? duplicateFact,
}) {
  final facts = <AppCzarFact>[
    for (final factId in AppCzarFactId.values)
      if (factId != omittedFact)
        AppCzarFact(
          id: factId,
          label: factId.name,
          truth:
              truthOverrides[factId] ??
              (factId == AppCzarFactId.sourceAheadOfLocal
                  ? AppCzarTruth.falseValue
                  : AppCzarTruth.trueValue),
          detail: 'Current ${factId.name} evidence.',
        ),
    if (duplicateFact != null)
      AppCzarFact(
        id: duplicateFact,
        label: duplicateFact.name,
        truth: AppCzarTruth.trueValue,
        detail: 'Duplicate test evidence.',
      ),
  ];
  return AppCzarAssessmentState(
    generation: 9,
    assessment: AppCzarAssessment(
      facts: facts,
      diagnosisKind: AppCzarDiagnosisKind.healthyCurrentInstallation,
      diagnosis: 'Current evidence selects Operating Session.',
      virtualCoordinator: coordinator,
    ),
  );
}

final class _ControlledVisualInitializer
    implements AppCzarOperatingSessionVisualInitializer {
  _ControlledVisualInitializer({this.failure});

  final Object? failure;
  final Completer<void> _release = Completer<void>();
  final Completer<void> _started = Completer<void>();
  int calls = 0;

  Future<void> get started => _started.future;

  void release() {
    if (!_release.isCompleted) {
      _release.complete();
    }
  }

  @override
  Future<void> initializeVisualWindowState() async {
    calls += 1;
    if (!_started.isCompleted) {
      _started.complete();
    }
    await _release.future;
    final currentFailure = failure;
    if (currentFailure != null) {
      throw currentFailure;
    }
  }
}

final class _OperatingReader implements AppCzarObservationReader {
  const _OperatingReader();

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    return const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Test archive',
      resolvedPath: '/tmp/test-archive',
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
      messageCount: 100,
      maxRowId: 100,
      sampleStable: true,
    );
  }
}
