import 'package:meta/meta.dart';

enum AppCzarOperatingSessionPhase {
  dormant,
  restoringVisualWindowState,
  admitted,
  failed,
}

@immutable
final class AppCzarOperatingSessionState {
  const AppCzarOperatingSessionState({
    required this.phase,
    this.assessmentGeneration,
    this.failure,
  });

  const AppCzarOperatingSessionState.dormant()
    : this(phase: AppCzarOperatingSessionPhase.dormant);

  final AppCzarOperatingSessionPhase phase;
  final int? assessmentGeneration;
  final String? failure;

  bool get isVisible => phase != AppCzarOperatingSessionPhase.dormant;

  bool get isEntryInFlight =>
      phase == AppCzarOperatingSessionPhase.restoringVisualWindowState;

  bool get isAdmitted => phase == AppCzarOperatingSessionPhase.admitted;
}
