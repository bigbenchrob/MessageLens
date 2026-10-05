import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_currentness_controller.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_currentness_observer_provider.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_session_controller.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_session_visual_initializer_provider.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/domain/app_czar_operating_currentness_models.dart';
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
        AppCzarFactId.attachmentCoverageComplete,
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

      final otherwiseValid = _operatingAssessmentState();
      expect(
        shouldExecuteAppCzarOperatingSession(
          AppCzarAssessmentState(
            generation: otherwiseValid.generation,
            attachmentArchive: const AppCzarArchiveObservation(
              condition: AppCzarArchiveCondition.available,
              label: 'Incomplete binding',
              resolvedPath: '/tmp/test-archive',
              archiveScopeIdentity: 'test-scope',
              archiveGeneration: 0,
              coverage: AppCzarAttachmentCoverageObservation.unknown(
                issue: 'Coverage binding was omitted.',
              ),
            ),
            assessment: otherwiseValid.assessment,
          ),
        ),
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

  test(
    'generation replacement keeps the old shell until its exact flight drains',
    () async {
      final initializer = _ControlledVisualInitializer()..release();
      final observer = _BlockingCurrentnessObserver();
      final container = _container(initializer, observer: observer);
      addTearDown(container.dispose);
      final sessionSubscription = container.listen(
        appCzarOperatingSessionControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sessionSubscription.close);
      await _waitForPhase(container, AppCzarOperatingSessionPhase.admitted);
      final oldOccurrence = container
          .read(appCzarOperatingSessionControllerProvider)
          .occurrence!;
      final currentnessProvider = appCzarOperatingCurrentnessControllerProvider(
        oldOccurrence,
      );
      final currentnessSubscription = container.listen(
        currentnessProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(currentnessSubscription.close);
      container.read(currentnessProvider.notifier).start();
      await observer.started.future;

      final rerun = container
          .read(appCzarAssessmentControllerProvider.notifier)
          .runAgain();
      await _waitForPhase(container, AppCzarOperatingSessionPhase.draining);
      final draining = container.read(
        appCzarOperatingSessionControllerProvider,
      );
      expect(draining.ownsOperatingShell, isTrue);
      expect(draining.occurrence, oldOccurrence);
      expect(observer.release.isCompleted, isFalse);

      await rerun;
      expect(
        container.read(appCzarOperatingSessionControllerProvider).phase,
        AppCzarOperatingSessionPhase.draining,
      );
      observer.complete();
      await _waitForGenerationPhase(
        container,
        generation: 1,
        phase: AppCzarOperatingSessionPhase.admitted,
      );

      final replacement = container.read(
        appCzarOperatingSessionControllerProvider,
      );
      expect(replacement.occurrence, isNot(oldOccurrence));
      expect(
        container.read(currentnessProvider).phase,
        AppCzarOperatingCurrentnessPhase.stopped,
      );
    },
  );

  test(
    'same-generation admission loss drains before releasing the shell',
    () async {
      final initializer = _ControlledVisualInitializer()..release();
      final observer = _BlockingCurrentnessObserver();
      final container = ProviderContainer(
        overrides: <Override>[
          appCzarAssessmentControllerProvider.overrideWith(
            _MutableAssessmentController.new,
          ),
          appCzarOperatingSessionVisualInitializerProvider.overrideWithValue(
            initializer,
          ),
          appCzarOperatingCurrentnessObserverProvider.overrideWithValue(
            observer,
          ),
        ],
      );
      addTearDown(container.dispose);
      final sessionSubscription = container.listen(
        appCzarOperatingSessionControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sessionSubscription.close);
      await _waitForPhase(container, AppCzarOperatingSessionPhase.admitted);
      final occurrence = container
          .read(appCzarOperatingSessionControllerProvider)
          .occurrence!;
      final currentnessProvider = appCzarOperatingCurrentnessControllerProvider(
        occurrence,
      );
      final currentnessSubscription = container.listen(
        currentnessProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(currentnessSubscription.close);
      container.read(currentnessProvider.notifier).start();
      await observer.started.future;

      final assessment = container.read(
        appCzarAssessmentControllerProvider.notifier,
      );
      expect(assessment, isA<_MutableAssessmentController>());
      (assessment as _MutableAssessmentController).publish(
        _operatingAssessmentState(
          truthOverrides: const <AppCzarFactId, AppCzarTruth>{
            AppCzarFactId.sourceAheadOfLocal: AppCzarTruth.trueValue,
          },
        ),
      );
      await _waitForPhase(container, AppCzarOperatingSessionPhase.draining);
      expect(
        container.read(appCzarOperatingSessionControllerProvider).occurrence,
        occurrence,
      );
      expect(
        container
            .read(appCzarOperatingSessionControllerProvider)
            .ownsOperatingShell,
        isTrue,
      );

      observer.complete();
      await _waitForPhase(container, AppCzarOperatingSessionPhase.failed);
      expect(
        container
            .read(appCzarOperatingSessionControllerProvider)
            .ownsOperatingShell,
        isFalse,
      );
      expect(
        container.read(currentnessProvider).phase,
        AppCzarOperatingCurrentnessPhase.stopped,
      );
      final failed = container.read(appCzarOperatingSessionControllerProvider);
      expect(failed.failure, contains('facts that admitted'));
      expect(failed.failure, isNot(contains('generation changed')));
    },
  );
}

ProviderContainer _container(
  AppCzarOperatingSessionVisualInitializer initializer, {
  AppCzarOperatingCurrentnessObserver? observer,
}) {
  return ProviderContainer(
    overrides: [
      appCzarObservationReaderProvider.overrideWithValue(
        const _OperatingReader(),
      ),
      appCzarOperatingSessionVisualInitializerProvider.overrideWithValue(
        initializer,
      ),
      if (observer != null)
        appCzarOperatingCurrentnessObserverProvider.overrideWithValue(observer),
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
    attachmentArchive: const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Test archive',
      resolvedPath: '/tmp/test-archive',
      archiveScopeIdentity: 'test-scope',
      archiveGeneration: 0,
      coverage: _completeCoverage,
    ),
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
      archiveScopeIdentity: 'test-scope',
      archiveGeneration: 0,
      coverage: _completeCoverage,
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

const _completeCoverage = AppCzarAttachmentCoverageObservation(
  condition: AppCzarAttachmentCoverageCondition.complete,
  requiredCount: 1,
  coveredCount: 1,
  missingCount: 0,
  unverifiableCount: 0,
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
);

final class _BlockingCurrentnessObserver
    implements AppCzarOperatingCurrentnessObserver {
  final Completer<AppCzarOperatingCoverageObservation> release =
      Completer<AppCzarOperatingCoverageObservation>();
  final Completer<void> started = Completer<void>();

  void complete() {
    if (!release.isCompleted) {
      release.complete(_coverageObservation());
    }
  }

  @override
  Future<AppCzarOperatingCoverageObservation> readCoverage() {
    if (!started.isCompleted) {
      started.complete();
    }
    return release.future;
  }

  @override
  Future<AppCzarOperatingCurrentnessObservation> readCurrentness() async {
    throw StateError('Currentness must not be read before blocked coverage.');
  }

  @override
  Future<AppCzarOperatingReadFence> readFence() async => _readFence();
}

final class _MutableAssessmentController extends AppCzarAssessmentController {
  @override
  AppCzarAssessmentState build() => _operatingAssessmentState();

  void publish(AppCzarAssessmentState next) {
    state = next;
  }
}

AppCzarOperatingCoverageObservation _coverageObservation() {
  final fence = _readFence();
  return AppCzarOperatingCoverageObservation(
    before: fence,
    after: fence,
    archive: const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Test archive',
      resolvedPath: '/tmp/test-archive',
      archiveScopeIdentity: 'test-scope',
      archiveGeneration: 0,
      coverage: _completeCoverage,
    ),
  );
}

AppCzarOperatingReadFence _readFence() {
  final token = Object();
  return AppCzarOperatingReadFence(
    messageDataGeneration: 1,
    archiveLocation: const AppCzarOperatingArchiveLocationEvidence(
      generation: 0,
      isReadable: true,
      isWritableMutationEligible: true,
      resolvedPath: '/tmp/test-archive',
    ),
    mutation: AppCzarOperatingMutationFence(
      isActive: false,
      revisionToken: token,
      lastReleasedAtMicroseconds: null,
    ),
  );
}
