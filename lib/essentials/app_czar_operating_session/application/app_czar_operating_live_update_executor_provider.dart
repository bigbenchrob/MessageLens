import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/domain.dart' show ArchiveMutationOperation;
import '../../archive_environment/feature_level_providers.dart'
    show archiveMutationCoordinatorProvider;
import '../../conversation_graph/application/monitor/live_graph_update_worker.dart';
import '../domain/app_czar_operating_session_state.dart';

part 'app_czar_operating_live_update_executor_provider.g.dart';

abstract interface class AppCzarOperatingLiveUpdateExecutor {
  Future<LiveGraphUpdateResult> run({
    required AppCzarOperatingSessionOccurrence occurrence,
    required void Function() requireCurrentOccurrence,
    required Future<void> Function() requireCurrentPrecondition,
    LiveGraphUpdateObserver? onObservation,
  });
}

final class AdmittedAppCzarOperatingLiveUpdateExecutor
    implements AppCzarOperatingLiveUpdateExecutor {
  const AdmittedAppCzarOperatingLiveUpdateExecutor({
    required Future<LiveGraphUpdateResult> Function({
      required AppCzarOperatingSessionOccurrence occurrence,
      required void Function() requireCurrentOccurrence,
      required Future<void> Function() requireCurrentPrecondition,
      LiveGraphUpdateObserver? onObservation,
    })
    runAdmitted,
  }) : _runAdmitted = runAdmitted;

  final Future<LiveGraphUpdateResult> Function({
    required AppCzarOperatingSessionOccurrence occurrence,
    required void Function() requireCurrentOccurrence,
    required Future<void> Function() requireCurrentPrecondition,
    LiveGraphUpdateObserver? onObservation,
  })
  _runAdmitted;

  @override
  Future<LiveGraphUpdateResult> run({
    required AppCzarOperatingSessionOccurrence occurrence,
    required void Function() requireCurrentOccurrence,
    required Future<void> Function() requireCurrentPrecondition,
    LiveGraphUpdateObserver? onObservation,
  }) {
    return _runAdmitted(
      occurrence: occurrence,
      requireCurrentOccurrence: requireCurrentOccurrence,
      requireCurrentPrecondition: requireCurrentPrecondition,
      onObservation: onObservation,
    );
  }
}

@Riverpod(keepAlive: true)
AppCzarOperatingLiveUpdateExecutor appCzarOperatingLiveUpdateExecutor(Ref ref) {
  return AdmittedAppCzarOperatingLiveUpdateExecutor(
    runAdmitted:
        ({
          required occurrence,
          required requireCurrentOccurrence,
          required requireCurrentPrecondition,
          onObservation,
        }) async {
          requireCurrentOccurrence();
          await requireCurrentPrecondition();
          return ref
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<LiveGraphUpdateResult>(
                operation: ArchiveMutationOperation.liveGraphUpdate,
                ownerLabel: 'app-czar-operating-${occurrence.processSequence}',
                action: (capability) async {
                  requireCurrentOccurrence();
                  capability.requireOperation(
                    ArchiveMutationOperation.liveGraphUpdate,
                  );
                  await requireCurrentPrecondition();
                  final worker = await ref.read(
                    liveGraphUpdateWorkerProvider.future,
                  );
                  requireCurrentOccurrence();
                  capability.requireOperation(
                    ArchiveMutationOperation.liveGraphUpdate,
                  );
                  final result = await worker.run(onObservation: onObservation);
                  capability.requireOperation(
                    ArchiveMutationOperation.liveGraphUpdate,
                  );
                  requireCurrentOccurrence();
                  return result;
                },
              );
        },
  );
}
