import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/domain.dart' show ArchiveMutationOperation;
import '../../archive_environment/feature_level_providers.dart'
    show archiveMutationCoordinatorProvider;
import '../../conversation_graph/application/monitor/live_graph_update_worker.dart';

part 'app_czar_data_update_executor_provider.g.dart';

abstract interface class AppCzarDataUpdateExecutor {
  Future<LiveGraphUpdateResult> run({LiveGraphUpdateObserver? onObservation});
}

final class AdmittedAppCzarDataUpdateExecutor
    implements AppCzarDataUpdateExecutor {
  const AdmittedAppCzarDataUpdateExecutor({
    required Future<LiveGraphUpdateResult> Function(
      LiveGraphUpdateObserver? onObservation,
    )
    runAdmitted,
  }) : _runAdmitted = runAdmitted;

  final Future<LiveGraphUpdateResult> Function(
    LiveGraphUpdateObserver? onObservation,
  )
  _runAdmitted;

  @override
  Future<LiveGraphUpdateResult> run({LiveGraphUpdateObserver? onObservation}) {
    return _runAdmitted(onObservation);
  }
}

@Riverpod(keepAlive: true)
AppCzarDataUpdateExecutor appCzarDataUpdateExecutor(Ref ref) {
  return AdmittedAppCzarDataUpdateExecutor(
    runAdmitted: (onObservation) {
      return ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .runWithCapability<LiveGraphUpdateResult>(
            operation: ArchiveMutationOperation.liveGraphUpdate,
            ownerLabel: 'app-czar-data-update',
            action: (capability) async {
              capability.requireOperation(
                ArchiveMutationOperation.liveGraphUpdate,
              );
              final worker = await ref.read(
                liveGraphUpdateWorkerProvider.future,
              );
              final result = await worker.run(onObservation: onObservation);
              capability.requireOperation(
                ArchiveMutationOperation.liveGraphUpdate,
              );
              return result;
            },
          );
    },
  );
}
