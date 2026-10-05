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
