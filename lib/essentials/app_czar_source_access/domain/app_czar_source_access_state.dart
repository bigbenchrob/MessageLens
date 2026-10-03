import 'package:meta/meta.dart';

enum AppCzarSourceAccessPhase {
  dormant,
  waitingForHuman,
  checking,
  inconclusive,
  restartRequested,
  restartFailed,
}

@immutable
final class AppCzarSourceAccessState {
  const AppCzarSourceAccessState({
    required this.phase,
    this.assessmentGeneration,
    this.sourceReason,
    this.settingsFailure,
    this.restartFailure,
  });

  const AppCzarSourceAccessState.dormant()
    : this(phase: AppCzarSourceAccessPhase.dormant);

  final AppCzarSourceAccessPhase phase;
  final int? assessmentGeneration;
  final String? sourceReason;
  final String? settingsFailure;
  final String? restartFailure;

  bool get isVisible => phase != AppCzarSourceAccessPhase.dormant;

  bool get canCheckAgain => phase == AppCzarSourceAccessPhase.waitingForHuman;

  bool get canRestartAndReassess =>
      phase == AppCzarSourceAccessPhase.inconclusive ||
      phase == AppCzarSourceAccessPhase.restartFailed;

  AppCzarSourceAccessState copyWith({
    AppCzarSourceAccessPhase? phase,
    String? sourceReason,
    String? settingsFailure,
    String? restartFailure,
    bool clearSettingsFailure = false,
    bool clearRestartFailure = false,
  }) {
    return AppCzarSourceAccessState(
      phase: phase ?? this.phase,
      assessmentGeneration: assessmentGeneration,
      sourceReason: sourceReason ?? this.sourceReason,
      settingsFailure: clearSettingsFailure
          ? null
          : settingsFailure ?? this.settingsFailure,
      restartFailure: clearRestartFailure
          ? null
          : restartFailure ?? this.restartFailure,
    );
  }
}
