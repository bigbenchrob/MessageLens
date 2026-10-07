import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_local_data_repair/application/app_czar_local_data_repair_executor_provider.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart';

void main() {
  test(
    'fresh matching evidence executes under one released repair tenure',
    () async {
      final reset = _RecordingResetService();
      final container = _container(
        reader: _RepairReader(safety: _safeObservation),
        reset: reset,
      );
      addTearDown(container.dispose);

      final result = await container
          .read(appCzarLocalDataRepairExecutorProvider)
          .run(expected: _safeObservation);

      expect(result, AppCzarLocalDataRepairExecutionResult.completed);
      expect(reset.calls, 1);
      expect(reset.operation, ArchiveMutationOperation.localDataRepair);
      final mutation = container.read(archiveMutationCoordinatorProvider);
      expect(mutation.isLocked, isFalse);
      expect(mutation.holdCount, 0);
      expect(mutation.lastReleasedAtUtc, isNotNull);
    },
  );

  test('changed reconstructibility evidence cannot admit mutation', () async {
    final reset = _RecordingResetService();
    final changed = _safeObservation.copyWithForTest(
      sourceFingerprint: 'changed-source',
    );
    final container = _container(
      reader: _RepairReader(safety: changed),
      reset: reset,
    );
    addTearDown(container.dispose);

    final result = await container
        .read(appCzarLocalDataRepairExecutorProvider)
        .run(expected: _safeObservation);

    expect(result, AppCzarLocalDataRepairExecutionResult.staleEvidence);
    expect(reset.calls, 0);
  });

  test('closed occurrence cannot mutate after fresh revalidation', () async {
    final reset = _RecordingResetService();
    final container = _container(
      reader: _RepairReader(safety: _safeObservation),
      reset: reset,
    );
    addTearDown(container.dispose);

    final result = await container
        .read(appCzarLocalDataRepairExecutorProvider)
        .run(expected: _safeObservation, isMutationStillAdmitted: () => false);

    expect(result, AppCzarLocalDataRepairExecutionResult.staleEvidence);
    expect(reset.calls, 0);
  });

  test('archive rebinding while acquiring tenure prevents reset', () async {
    final reset = _RecordingResetService();
    final container = _container(
      reader: _RepairReader(
        safety: _safeObservation,
        archiveAfterRevalidation: _archiveObservation(scope: 'different-scope'),
      ),
      reset: reset,
    );
    addTearDown(container.dispose);

    final result = await container
        .read(appCzarLocalDataRepairExecutorProvider)
        .run(expected: _safeObservation);

    expect(result, AppCzarLocalDataRepairExecutionResult.staleEvidence);
    expect(reset.calls, 0);
  });

  test('failure after reset admission is marked restart-required', () async {
    final reset = _RecordingResetService(failure: StateError('delete failed'));
    final container = _container(
      reader: _RepairReader(safety: _safeObservation),
      reset: reset,
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(appCzarLocalDataRepairExecutorProvider)
          .run(expected: _safeObservation),
      throwsA(
        isA<AppCzarLocalDataRepairExecutionException>()
            .having(
              (error) => error.mutationMayHaveStarted,
              'mutationMayHaveStarted',
              isTrue,
            )
            .having((error) => error.cause, 'cause', isA<StateError>()),
      ),
    );
    expect(reset.calls, 1);
    expect(
      container.read(archiveMutationCoordinatorProvider).isLocked,
      isFalse,
    );
  });
}

ProviderContainer _container({
  required _RepairReader reader,
  required _RecordingResetService reset,
}) {
  return ProviderContainer(
    overrides: <Override>[
      admittedArchiveAccessAuthorityProvider.overrideWithValue(
        _testAuthority(),
      ),
      appCzarObservationReaderProvider.overrideWithValue(reader),
      messageDataResetServiceProvider.overrideWithValue(reset),
    ],
  );
}

final class _RepairReader
    implements AppCzarObservationReader, AppCzarLocalDataRepairSafetyReader {
  _RepairReader({
    required this.safety,
    AppCzarArchiveObservation? archiveAfterRevalidation,
  }) : _archiveAfterRevalidation = archiveAfterRevalidation;

  final AppCzarLocalDataRepairSafetyObservation safety;
  final AppCzarArchiveObservation? _archiveAfterRevalidation;
  var _archiveReads = 0;

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    _archiveReads += 1;
    if (_archiveReads > 1 && _archiveAfterRevalidation != null) {
      return _archiveAfterRevalidation;
    }
    return _archiveObservation();
  }

  @override
  Future<AppCzarLocalDataRepairSafetyObservation> readLocalDataRepairSafety({
    required AppCzarArchiveObservation attachmentArchive,
  }) async {
    return safety;
  }

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() {
    throw UnimplementedError();
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() {
    throw UnimplementedError();
  }

  @override
  Future<AppCzarDatabaseObservation> readOverlay() {
    throw UnimplementedError();
  }

  @override
  Future<AppCzarRootObservation> readRoot() {
    throw UnimplementedError();
  }

  @override
  Future<AppCzarSourceObservation> readSource() {
    throw UnimplementedError();
  }
}

final class _RecordingResetService implements MessageDataResetService {
  _RecordingResetService({this.failure});

  final Object? failure;
  int calls = 0;
  ArchiveMutationOperation? operation;

  @override
  Future<void> resetActiveDerivedDataForLocalDataRepair(
    ArchiveMutationCapability capability,
  ) async {
    calls += 1;
    operation = capability.operation;
    capability.requireOperation(ArchiveMutationOperation.localDataRepair);
    if (failure case final failure?) {
      throw failure;
    }
  }

  @override
  Future<void> resetDerivedData() {
    throw UnimplementedError();
  }

  @override
  Future<void> resetDerivedDataForStartFresh(
    ArchiveMutationCapability capability,
  ) {
    throw UnimplementedError();
  }
}

const _safeObservation = AppCzarLocalDataRepairSafetyObservation(
  condition: AppCzarLocalDataRepairSafetyCondition.rebuildableLiveOnlyPartial,
  archiveRootPath: '/tmp/app-czar-local-repair-test',
  archiveInstanceId: '22222222-2222-4222-8222-222222222222',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
  sourceFingerprint: 'source-fingerprint',
  evidenceFingerprint: 'evidence-fingerprint',
  resetFootprint: <String>['macos_import_ss.db', 'working_ss.db'],
  consequentialRowCounts: <String, int>{'messages': 1},
);

AppCzarArchiveObservation _archiveObservation({String scope = 'test-scope'}) {
  return AppCzarArchiveObservation(
    condition: AppCzarArchiveCondition.available,
    label: 'Fixture archive',
    archiveScopeIdentity: scope,
    archiveGeneration: 0,
    resolvedPath: '/tmp/app-czar-local-repair-test/attachment_archive',
    coverage: AppCzarAttachmentCoverageObservation(
      condition: AppCzarAttachmentCoverageCondition.complete,
      requiredCount: 0,
      coveredCount: 0,
      missingCount: 0,
      unverifiableCount: 0,
      archiveScopeIdentity: scope,
      archiveGeneration: 0,
    ),
    repairability: AppCzarAttachmentRepairabilityObservation(
      condition: AppCzarAttachmentRepairOpportunityCondition.absent,
      availableFromMessagesCount: 0,
      sourceAbsentCount: 0,
      sourceUnknownCount: 0,
      recordBackedRecoveryCount: 0,
      unsafeOrConflictingCount: 0,
      archiveScopeIdentity: scope,
      archiveGeneration: 0,
    ),
  );
}

ArchiveAccessAuthority _testAuthority() {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.test,
      buildIdentity: ArchiveBuildIdentity.testHarness,
      archiveInstanceId: ArchiveInstanceId(
        '22222222-2222-4222-8222-222222222222',
      ),
      canonicalRootPath: '/tmp/app-czar-local-repair-test',
      bundleIdentifier: 'test.bundle',
      productName: 'MessageLens Test',
    ),
  );
}

extension on AppCzarLocalDataRepairSafetyObservation {
  AppCzarLocalDataRepairSafetyObservation copyWithForTest({
    required String sourceFingerprint,
  }) {
    return AppCzarLocalDataRepairSafetyObservation(
      condition: condition,
      archiveRootPath: archiveRootPath,
      archiveInstanceId: archiveInstanceId,
      archiveScopeIdentity: archiveScopeIdentity,
      archiveGeneration: archiveGeneration,
      sourceFingerprint: sourceFingerprint,
      evidenceFingerprint: evidenceFingerprint,
      resetFootprint: resetFootprint,
      consequentialRowCounts: consequentialRowCounts,
      issue: issue,
    );
  }
}
