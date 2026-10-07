import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_czar/application/app_czar_assessment_provider.dart';
import '../../app_czar/application/app_czar_observation_reader.dart';
import '../../app_czar/domain/app_czar_models.dart';
import '../../archive_environment/domain/archive_mutation_operation.dart';
import '../../archive_environment/feature_level_providers.dart'
    show archiveMutationCoordinatorProvider;
import '../../onboarding/application/message_data_reset_service.dart';

part 'app_czar_local_data_repair_executor_provider.g.dart';

enum AppCzarLocalDataRepairExecutionResult { completed, staleEvidence }

final class AppCzarLocalDataRepairExecutionException implements Exception {
  const AppCzarLocalDataRepairExecutionException({
    required this.cause,
    required this.mutationMayHaveStarted,
  });

  final Object cause;
  final bool mutationMayHaveStarted;

  @override
  String toString() => 'Local Data Repair failed: $cause';
}

abstract interface class AppCzarLocalDataRepairExecutor {
  Future<AppCzarLocalDataRepairExecutionResult> run({
    required AppCzarLocalDataRepairSafetyObservation expected,
    void Function()? onMutationAdmitted,
    bool Function()? isMutationStillAdmitted,
  });
}

final class _CallbackAppCzarLocalDataRepairExecutor
    implements AppCzarLocalDataRepairExecutor {
  const _CallbackAppCzarLocalDataRepairExecutor(this._run);

  final Future<AppCzarLocalDataRepairExecutionResult> Function({
    required AppCzarLocalDataRepairSafetyObservation expected,
    void Function()? onMutationAdmitted,
    bool Function()? isMutationStillAdmitted,
  })
  _run;

  @override
  Future<AppCzarLocalDataRepairExecutionResult> run({
    required AppCzarLocalDataRepairSafetyObservation expected,
    void Function()? onMutationAdmitted,
    bool Function()? isMutationStillAdmitted,
  }) => _run(
    expected: expected,
    onMutationAdmitted: onMutationAdmitted,
    isMutationStillAdmitted: isMutationStillAdmitted,
  );
}

final class _LocalDataRepairAdmissionClosed implements Exception {
  const _LocalDataRepairAdmissionClosed();
}

@Riverpod(keepAlive: true)
AppCzarLocalDataRepairExecutor appCzarLocalDataRepairExecutor(Ref ref) {
  return _CallbackAppCzarLocalDataRepairExecutor(({
    required expected,
    onMutationAdmitted,
    isMutationStillAdmitted,
  }) async {
    final reader = ref.read(appCzarObservationReaderProvider);
    if (reader is! AppCzarLocalDataRepairSafetyReader) {
      return AppCzarLocalDataRepairExecutionResult.staleEvidence;
    }
    final safetyReader = reader as AppCzarLocalDataRepairSafetyReader;
    final archive = await reader.readAttachmentArchive();
    final current = await safetyReader.readLocalDataRepairSafety(
      attachmentArchive: archive,
    );
    if (!current.mayResetDerivedStores ||
        !expected.hasSameMutationBinding(current)) {
      return AppCzarLocalDataRepairExecutionResult.staleEvidence;
    }
    if (isMutationStillAdmitted?.call() == false) {
      return AppCzarLocalDataRepairExecutionResult.staleEvidence;
    }

    var mutationMayHaveStarted = false;
    try {
      await ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .runWithCapability<void>(
            operation: ArchiveMutationOperation.localDataRepair,
            ownerLabel: 'app-czar-local-data-repair',
            action: (capability) async {
              if (isMutationStillAdmitted?.call() == false) {
                throw const _LocalDataRepairAdmissionClosed();
              }
              final admittedArchive = await reader.readAttachmentArchive();
              if (!admittedArchive.hasCompleteArchiveBinding ||
                  admittedArchive.archiveScopeIdentity !=
                      current.archiveScopeIdentity ||
                  admittedArchive.archiveGeneration !=
                      current.archiveGeneration) {
                throw const _LocalDataRepairAdmissionClosed();
              }
              mutationMayHaveStarted = true;
              onMutationAdmitted?.call();
              await ref
                  .read(messageDataResetServiceProvider)
                  .resetActiveDerivedDataForLocalDataRepair(capability);
            },
          );
    } on _LocalDataRepairAdmissionClosed {
      return AppCzarLocalDataRepairExecutionResult.staleEvidence;
    } on Object catch (error) {
      throw AppCzarLocalDataRepairExecutionException(
        cause: error,
        mutationMayHaveStarted: mutationMayHaveStarted,
      );
    }
    return AppCzarLocalDataRepairExecutionResult.completed;
  });
}
