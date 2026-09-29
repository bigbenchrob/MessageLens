import '../domain/onboarding_operation_snapshot.dart';
import 'onboarding_operation_snapshot_controller.dart';

/// Executes the durable operation grammar for a positively authorized Virgin
/// first import.
///
/// This boundary can construct fresh derived stores through [buildMessageData].
/// It deliberately has no reset, recovery, checkpoint, adoption, or erase
/// dependency.
final class VirginOnboardingImportExecutor {
  const VirginOnboardingImportExecutor({
    required OnboardingOperationSnapshotController operationController,
  }) : _operationController = operationController;

  final OnboardingOperationSnapshotController _operationController;

  Future<OnboardingOperationId> run({
    required OnboardingOperationId operationId,
    required Future<void> Function(OnboardingProgressReporter progress)
    buildMessageData,
  }) async {
    await _operationController.runStage<void>(
      operationId: operationId,
      stage: OnboardingOperationStage.messageDataBuild,
      action: buildMessageData,
    );
    await _operationController.enterStage(
      operationId: operationId,
      stage: OnboardingOperationStage.durableReadinessVerification,
    );
    return operationId;
  }
}
