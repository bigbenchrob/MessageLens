import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_evaluator.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import 'package:remember_this_text/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller.dart';
import 'package:remember_this_text/essentials/app_czar_diagnostic_review/domain/app_czar_diagnostic_review_state.dart';

void main() {
  test('only a completed Diagnostic Review assessment is executable', () {
    expect(
      shouldExecuteAppCzarDiagnosticReview(AppCzarAssessmentState.initial(0)),
      isFalse,
    );
    for (final coordinator in AppCzarVirtualCoordinator.values) {
      final state = AppCzarAssessmentState(
        generation: 4,
        assessment: AppCzarAssessment(
          facts: const <AppCzarFact>[],
          diagnosisKind:
              AppCzarDiagnosisKind.contradictoryOrInsufficientEvidence,
          diagnosis: 'test diagnosis',
          virtualCoordinator: coordinator,
        ),
      );

      expect(
        shouldExecuteAppCzarDiagnosticReview(state),
        coordinator == AppCzarVirtualCoordinator.diagnosticReview,
      );
    }
  });

  test('captures one immutable assessment occurrence and injected time', () {
    final assessment = _diagnosticState(generation: 7);
    final clock = DateTime.utc(2026, 10, 9, 12, 30);
    final container = _container(
      assessment: assessment,
      restarter: _RecordingRestarter(),
      clock: clock,
    );
    addTearDown(container.dispose);

    final state = container.read(appCzarDiagnosticReviewControllerProvider);

    expect(state.phase, AppCzarDiagnosticReviewPhase.presenting);
    expect(state.actionAdmissionOpen, isTrue);
    expect(state.occurrence!.assessmentGeneration, 7);
    expect(state.occurrence!.capturedAssessmentState, same(assessment));
    expect(state.occurrence!.capturedAt, clock);
  });

  test('Try Assessment Again is single-flight and restart-only', () async {
    final restarter = _RecordingRestarter(block: true);
    final container = _container(
      assessment: _diagnosticState(),
      restarter: restarter,
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      appCzarDiagnosticReviewControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final controller = container.read(
      appCzarDiagnosticReviewControllerProvider.notifier,
    );

    final first = controller.tryAssessmentAgain();
    final second = controller.tryAssessmentAgain();
    await Future<void>.delayed(Duration.zero);

    expect(restarter.calls, 1);
    expect(
      container.read(appCzarDiagnosticReviewControllerProvider).phase,
      AppCzarDiagnosticReviewPhase.draining,
    );

    restarter.release();
    await Future.wait(<Future<void>>[first, second]);
    expect(restarter.calls, 1);
  });

  test('time advancing cannot trigger observation or restart work', () async {
    final restarter = _RecordingRestarter();
    final assessment = _diagnosticState(generation: 9);
    final container = _container(
      assessment: assessment,
      restarter: restarter,
      clock: DateTime.utc(2026, 10, 9, 12, 45),
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      appCzarDiagnosticReviewControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final before = container.read(appCzarDiagnosticReviewControllerProvider);

    await Future<void>.delayed(const Duration(milliseconds: 25));
    final after = container.read(appCzarDiagnosticReviewControllerProvider);

    expect(after, same(before));
    expect(after.occurrence!.capturedAssessmentState, same(assessment));
    expect(after.occurrence!.assessmentGeneration, 9);
    expect(after.occurrence!.capturedAt, DateTime.utc(2026, 10, 9, 12, 45));
    expect(restarter.calls, 0);
  });

  test(
    'simultaneous quit and restart cannot schedule another restart',
    () async {
      final restarter = _RecordingRestarter(block: true);
      final container = _container(
        assessment: _diagnosticState(),
        restarter: restarter,
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        appCzarDiagnosticReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final controller = container.read(
        appCzarDiagnosticReviewControllerProvider.notifier,
      );

      final restart = controller.tryAssessmentAgain();
      await Future<void>.delayed(Duration.zero);
      final quit = controller.stopAndDrain();
      final staleRestart = controller.tryAssessmentAgain();

      expect(restarter.calls, 1);
      expect(
        container.read(appCzarDiagnosticReviewControllerProvider).phase,
        AppCzarDiagnosticReviewPhase.quitRequested,
      );

      restarter.release();
      await Future.wait(<Future<void>>[restart, quit, staleRestart]);
      expect(restarter.calls, 1);
    },
  );

  test('restart failure is literal and enables one explicit retry', () async {
    final restarter = _RecordingRestarter(
      failures: <Object>[StateError('detached relaunch unavailable')],
    );
    final container = _container(
      assessment: _diagnosticState(),
      restarter: restarter,
    );
    addTearDown(container.dispose);
    final controller = container.read(
      appCzarDiagnosticReviewControllerProvider.notifier,
    );

    await controller.tryAssessmentAgain();
    final failed = container.read(appCzarDiagnosticReviewControllerProvider);

    expect(failed.phase, AppCzarDiagnosticReviewPhase.restartFailed);
    expect(failed.actionAdmissionOpen, isTrue);
    expect(failed.failure, contains('detached relaunch unavailable'));

    await controller.tryAssessmentAgain();
    expect(restarter.calls, 2);
  });

  test('replacement assessment identity makes stale actions inert', () async {
    final fixed = _FixedAssessmentController(_diagnosticState(generation: 2));
    final restarter = _RecordingRestarter();
    final container = ProviderContainer(
      overrides: <Override>[
        appCzarAssessmentControllerProvider.overrideWith(() => fixed),
        appCzarProcessRestarterProvider.overrideWithValue(restarter),
        appCzarDiagnosticReviewClockProvider.overrideWithValue(
          () => DateTime.utc(2026, 10, 9),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      appCzarDiagnosticReviewControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final controller = container.read(
      appCzarDiagnosticReviewControllerProvider.notifier,
    );

    fixed.replace(_diagnosticState(generation: 3));
    await Future<void>.delayed(Duration.zero);
    await controller.tryAssessmentAgain();

    expect(restarter.calls, 0);
    expect(
      container.read(appCzarDiagnosticReviewControllerProvider).phase,
      AppCzarDiagnosticReviewPhase.draining,
    );
  });

  test('Quit drain does not call the process restarter', () async {
    final restarter = _RecordingRestarter();
    final container = _container(
      assessment: _diagnosticState(),
      restarter: restarter,
    );
    addTearDown(container.dispose);
    final controller = container.read(
      appCzarDiagnosticReviewControllerProvider.notifier,
    );

    await controller.stopAndDrain();

    expect(restarter.calls, 0);
    expect(
      container.read(appCzarDiagnosticReviewControllerProvider).phase,
      AppCzarDiagnosticReviewPhase.quitRequested,
    );
  });
}

ProviderContainer _container({
  required AppCzarAssessmentState assessment,
  required _RecordingRestarter restarter,
  DateTime? clock,
}) {
  return ProviderContainer(
    overrides: <Override>[
      appCzarAssessmentControllerProvider.overrideWith(
        () => _FixedAssessmentController(assessment),
      ),
      appCzarProcessRestarterProvider.overrideWithValue(restarter),
      appCzarDiagnosticReviewClockProvider.overrideWithValue(
        () => clock ?? DateTime.utc(2026, 10, 9),
      ),
    ],
  );
}

final class _FixedAssessmentController extends AppCzarAssessmentController {
  _FixedAssessmentController(this._fixed);

  AppCzarAssessmentState _fixed;

  @override
  AppCzarAssessmentState build() => _fixed;

  void replace(AppCzarAssessmentState next) {
    _fixed = next;
    state = next;
  }
}

final class _RecordingRestarter implements AppCzarProcessRestarter {
  _RecordingRestarter({this.block = false, List<Object>? failures})
    : _failures = failures ?? <Object>[];

  final bool block;
  final List<Object> _failures;
  final Completer<void> _release = Completer<void>();
  int calls = 0;

  void release() {
    if (!_release.isCompleted) {
      _release.complete();
    }
  }

  @override
  Future<void> restartAndReassess() async {
    calls += 1;
    if (_failures.isNotEmpty) {
      throw _failures.removeAt(0);
    }
    if (block) {
      await _release.future;
    }
  }
}

AppCzarAssessmentState _diagnosticState({int generation = 1}) {
  final observations = AppCzarObservationSet(
    root: const AppCzarRootObservation(admitted: true, path: '/test/root'),
    source: const AppCzarSourceObservation.unknown(
      'The source probe was inconclusive.',
    ),
    importStore: const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 10,
      messageCount: 100,
      liveMessageCount: 100,
      liveMaxSourceRowId: 100,
    ),
    graphStore: const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 3,
      messageCount: 100,
      chatCount: 4,
      chatMessageEdgeCount: 100,
    ),
    overlay: const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 8,
    ),
    attachmentArchive: const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Test archive',
      archiveScopeIdentity: 'test-scope',
      archiveGeneration: 0,
      resolvedPath: '/test/archive',
      coverage: _completeCoverage,
      repairability: _completeRepairability,
    ),
  );
  return AppCzarAssessmentState(
    generation: generation,
    root: observations.root,
    initialConstructionScope: observations.initialConstructionScope,
    source: observations.source,
    contactsPrerequisite: observations.contactsPrerequisite,
    importStore: observations.importStore,
    graphStore: observations.graphStore,
    overlay: observations.overlay,
    attachmentArchive: observations.attachmentArchive,
    localDataRepairSafety: observations.localDataRepairSafety,
    assessment: const AppCzarEvaluator().evaluate(observations),
  );
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
