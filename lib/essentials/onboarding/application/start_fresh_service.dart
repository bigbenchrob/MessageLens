import '../../archive_environment/domain/archive_mutation_operation.dart';
import '../../archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability;
import '../../presence/domain/repositories/presence_schedule_run_maintenance.dart';
import '../domain/message_lens_installation_state.dart';
import '../domain/startup_installation_validation.dart';
import 'message_data_reset_service.dart';
import 'message_lens_installation_validation_service.dart';
import 'onboarding_failure_store.dart';
import 'onboarding_operation_snapshot_controller.dart';

final class StartFreshResult {
  const StartFreshResult({required this.verifiedState});

  final MessageLensInstallationState verifiedState;
}

final class StartFreshVirginVerificationException implements Exception {
  const StartFreshVirginVerificationException({required this.verifiedState});

  final MessageLensInstallationState verifiedState;

  @override
  String toString() {
    return 'Start Fresh did not establish the virgin installation contract: '
        '${verifiedState.kind.name} (${verifiedState.reason})';
  }
}

enum StartFreshEntryPoint {
  incompleteInstallation,
  completedInstallationAdvancedReset,
}

abstract interface class StartFreshService {
  Future<StartFreshResult> startFresh({
    StartFreshEntryPoint entryPoint =
        StartFreshEntryPoint.incompleteInstallation,
  });
}

final class StartFreshServiceImpl implements StartFreshService {
  const StartFreshServiceImpl({
    required this.archiveRootPath,
    required this.requiredSourcesScheduleId,
    required this.readCurrentState,
    required this.runWithMutationAuthority,
    required this.messageDataResetService,
    required this.operationController,
    required this.failureStore,
    required this.presenceRepository,
    required this.fullValidator,
    required this.refreshAfterReset,
  });

  final String archiveRootPath;
  final int requiredSourcesScheduleId;
  final Future<MessageLensInstallationState> Function() readCurrentState;
  final Future<StartFreshResult> Function(
    Future<StartFreshResult> Function(ArchiveMutationCapability capability)
    action,
  )
  runWithMutationAuthority;
  final MessageDataResetService messageDataResetService;
  final OnboardingOperationSnapshotController operationController;
  final OnboardingFailureStore failureStore;
  final PresenceScheduleRunMaintenance presenceRepository;
  final MessageLensInstallationFullValidator fullValidator;
  final void Function() refreshAfterReset;

  @override
  Future<StartFreshResult> startFresh({
    StartFreshEntryPoint entryPoint =
        StartFreshEntryPoint.incompleteInstallation,
  }) async {
    final currentState = await readCurrentState();
    if (!_isEligible(currentState: currentState, entryPoint: entryPoint)) {
      throw StateError(
        'Start Fresh through ${entryPoint.name} is unavailable for '
        '${currentState.kind.name}: '
        '${currentState.reason}',
      );
    }

    return runWithMutationAuthority((capability) async {
      capability.requireOperation(ArchiveMutationOperation.startFresh);

      // Clear intent evidence first. Every later step is idempotent, so a
      // process interruption converges to completed durable data or an
      // abandoned installation that can safely request Start Fresh again.
      await operationController.resetToIdle();
      await failureStore.clearSourceImportFailure();
      await failureStore.clearGraphProjectionFailure();

      if (await presenceRepository.definitionExists(
        requiredSourcesScheduleId,
      )) {
        await presenceRepository.supersedeRunFromBeginning(
          requiredSourcesScheduleId,
        );
      }

      await messageDataResetService.resetDerivedDataForStartFresh(capability);

      final validation = await fullValidator.validateFully(
        archiveRootPath: archiveRootPath,
        trigger:
            InstallationIntegrityValidationTrigger.startFreshMutationBoundary,
      );
      final verifiedState = validation.installationState;
      if (!validation.fullIntegrityValidated ||
          verifiedState.kind != MessageLensInstallationStateKind.virgin) {
        throw StartFreshVirginVerificationException(
          verifiedState: verifiedState,
        );
      }

      refreshAfterReset();
      return StartFreshResult(verifiedState: verifiedState);
    });
  }

  bool _isEligible({
    required MessageLensInstallationState currentState,
    required StartFreshEntryPoint entryPoint,
  }) {
    return switch (entryPoint) {
      StartFreshEntryPoint.incompleteInstallation => currentState.mayStartFresh,
      StartFreshEntryPoint.completedInstallationAdvancedReset =>
        currentState.kind == MessageLensInstallationStateKind.completed,
    };
  }
}
