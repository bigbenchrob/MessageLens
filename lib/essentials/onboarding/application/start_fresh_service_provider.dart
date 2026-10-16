import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/domain.dart' show ArchiveMutationOperation;
import '../../archive_environment/feature_level_providers.dart'
    show
        ArchiveResetAdmissionBinding,
        ArchiveResetDenied,
        ArchiveResetDenialReason,
        archiveResetAdmissionProvider,
        archiveAccessAuthorityProvider,
        archiveMutationCoordinatorProvider;
import '../../presence/domain/repositories/presence_schedule_run_maintenance.dart';
import '../domain/startup_installation_validation.dart';
import '../infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import '../infrastructure/persistence/sqlite_message_lens_installation_integrity_validator.dart';
import 'message_data_reset_service.dart';
import 'message_lens_installation_state_provider.dart';
import 'message_lens_installation_validation_service.dart';
import 'onboarding_environment_report_provider.dart';
import 'onboarding_failure_storage_provider.dart';
import 'onboarding_gate_provider.dart';
import 'onboarding_operation_snapshot_provider.dart';
import 'required_sources_readiness_schedule.dart';
import 'required_sources_readiness_scheduler_provider.dart';
import 'start_fresh_service.dart';

part 'start_fresh_service_provider.g.dart';

@Riverpod(keepAlive: true)
Future<StartFreshService> startFreshService(Ref ref) async {
  late final ArchiveResetAdmissionBinding resetBinding;
  try {
    resetBinding = ref.read(archiveResetAdmissionProvider).bind();
  } on Object {
    throw const ArchiveResetDenied(ArchiveResetDenialReason.unavailable);
  }
  ref.onDispose(resetBinding.close);
  resetBinding.requireAllowed(ArchiveMutationOperation.startFresh);
  Future<T> readWhileCurrent<T>(Future<T> Function() read) async {
    resetBinding.requireAllowed(ArchiveMutationOperation.startFresh);
    try {
      return await read();
    } finally {
      resetBinding.requireAllowed(ArchiveMutationOperation.startFresh);
    }
  }

  final operationController = await readWhileCurrent(
    () => ref.watch(onboardingOperationControllerProvider.future),
  );
  final executablePresenceRepository = await readWhileCurrent(
    () => ref.watch(requiredSourcesReadinessRepositoryProvider.future),
  );
  resetBinding.requireAllowed(ArchiveMutationOperation.startFresh);
  if (executablePresenceRepository is! PresenceScheduleRunMaintenance) {
    throw StateError(
      'The required-sources repository does not support run maintenance.',
    );
  }
  final presenceRepository =
      executablePresenceRepository as PresenceScheduleRunMaintenance;
  final authority = ref.watch(archiveAccessAuthorityProvider);
  const fullValidator = MessageLensInstallationValidationService(
    evidenceReader: SqliteMessageLensInstallationEvidenceReader(),
    integrityValidator: SqliteMessageLensInstallationIntegrityValidator(),
  );

  resetBinding.requireAllowed(ArchiveMutationOperation.startFresh);
  final resetService = ref.watch(messageDataResetServiceProvider);
  resetBinding.requireAllowed(ArchiveMutationOperation.startFresh);
  final failureStore = ref.watch(onboardingFailureStorageProvider);
  resetBinding.requireAllowed(ArchiveMutationOperation.startFresh);
  return StartFreshServiceImpl(
    resetBinding: resetBinding,
    archiveRootPath: authority.rootPath,
    requiredSourcesScheduleId: requiredSourcesReadinessScheduleId,
    readCurrentState: () async {
      final validation = await fullValidator.validateFully(
        archiveRootPath: authority.rootPath,
        trigger:
            InstallationIntegrityValidationTrigger.startFreshMutationBoundary,
      );
      return validation.installationState;
    },
    runWithMutationAuthority: (action) {
      return ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .runWithCapability(
            operation: ArchiveMutationOperation.startFresh,
            ownerLabel: 'onboarding-start-fresh',
            action: action,
          );
    },
    messageDataResetService: resetService,
    operationController: operationController,
    failureStore: failureStore,
    presenceRepository: presenceRepository,
    fullValidator: fullValidator,
    refreshAfterReset: () {
      ref.invalidate(messageLensInstallationStateProvider);
      ref.invalidate(requiredSourcesReadinessSchedulerProvider);
      ref.invalidate(requiredSourcesReadinessAcceptedProvider);
      ref.invalidate(onboardingEnvironmentReportProvider);
      ref.read(onboardingGateProvider.notifier).refreshEnvironment();
    },
  );
}
