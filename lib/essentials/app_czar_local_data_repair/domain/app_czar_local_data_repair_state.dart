import 'package:meta/meta.dart';

enum AppCzarLocalDataRepairPhase {
  dormant,
  revalidating,
  resetting,
  restartRequested,
  failed,
}

@immutable
final class AppCzarLocalDataRepairState {
  const AppCzarLocalDataRepairState({
    required this.phase,
    this.assessmentGeneration,
    this.failure,
  });

  const AppCzarLocalDataRepairState.dormant()
    : this(phase: AppCzarLocalDataRepairPhase.dormant);

  final AppCzarLocalDataRepairPhase phase;
  final int? assessmentGeneration;
  final String? failure;

  bool get isVisible => phase != AppCzarLocalDataRepairPhase.dormant;
}
