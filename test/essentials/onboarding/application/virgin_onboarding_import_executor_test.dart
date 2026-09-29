import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_controller.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_store.dart';
import 'package:remember_this_text/essentials/onboarding/application/virgin_onboarding_import_executor.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';

void main() {
  late _MemorySnapshotStore store;
  late OnboardingOperationSnapshotController controller;

  setUp(() async {
    store = _MemorySnapshotStore();
    controller = OnboardingOperationSnapshotController(
      store: store,
      processSessionId: OnboardingProcessSessionId(
        '123e4567-e89b-42d3-a456-426614174001',
      ),
      now: () => DateTime.utc(2026, 9, 2),
      newOperationId: () => '123e4567-e89b-42d3-a456-426614174010',
    );
    await controller.initialize();
  });

  tearDown(() async {
    await controller.dispose();
  });

  test('constructs fresh message data and advances to verification', () async {
    var buildCount = 0;
    final executor = VirginOnboardingImportExecutor(
      operationController: controller,
    );
    final operationId = await controller.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );

    final returnedOperationId = await executor.run(
      operationId: operationId,
      buildMessageData: (progress) async {
        buildCount += 1;
        await progress.observe(
          substage: OnboardingOperationSubstage.importingMessages,
          completedWorkUnits: 1,
          totalWorkUnits: 1,
        );
      },
    );

    expect(buildCount, 1);
    expect(returnedOperationId, operationId);
    expect(controller.current.operationId, operationId);
    expect(controller.current.kind, OnboardingOperationKind.initialImport);
    expect(
      controller.current.completedStages,
      contains(OnboardingOperationStage.messageDataBuild),
    );
    expect(
      controller.current.currentStage,
      OnboardingOperationStage.durableReadinessVerification,
    );
  });

  test(
    'construction failure preserves original error for coordinator',
    () async {
      final executor = VirginOnboardingImportExecutor(
        operationController: controller,
      );
      final operationId = await controller.begin(
        kind: OnboardingOperationKind.initialImport,
        initialStage: OnboardingOperationStage.messageDataBuild,
      );

      await expectLater(
        executor.run(
          operationId: operationId,
          buildMessageData: (_) async {
            throw StateError('synthetic fresh construction failure');
          },
        ),
        throwsStateError,
      );

      expect(controller.current.status, OnboardingOperationStatus.running);
      expect(controller.current.failure, isNull);
    },
  );
}

final class _MemorySnapshotStore implements OnboardingOperationSnapshotStore {
  OnboardingOperationSnapshot? snapshot;

  @override
  Future<OnboardingOperationSnapshot?> load() async => snapshot;

  @override
  Future<void> save(OnboardingOperationSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}
