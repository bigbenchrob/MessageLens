import '../../../../essentials/onboarding/domain/onboarding_journey_state.dart';

enum EnvironmentReadinessEpisodeKind { checking, blocked, ready, failed }

enum EnvironmentReadinessTone { primary, warning, success, failure }

enum EnvironmentReadinessActionKind {
  openSettings,
  recheck,
  acceptLocalHistory,
  startImport,
  retryOperation,
  sendReport,
}

class EnvironmentReadinessAction {
  const EnvironmentReadinessAction({required this.kind, required this.label});

  final EnvironmentReadinessActionKind kind;
  final String label;
}

class EnvironmentReadinessEvidence {
  const EnvironmentReadinessEvidence({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class EnvironmentReadinessSurfaceViewModel {
  const EnvironmentReadinessSurfaceViewModel({
    required this.actionContext,
    required this.kind,
    required this.title,
    required this.body,
    required this.tone,
    required this.actions,
    required this.evidence,
    this.sanityEvidence,
    this.instructions = const <String>[],
  });

  final OnboardingJourneyActionContext actionContext;
  final EnvironmentReadinessEpisodeKind kind;
  final String title;
  final String body;
  final String? sanityEvidence;
  final EnvironmentReadinessTone tone;
  final List<String> instructions;
  final List<EnvironmentReadinessAction> actions;
  final List<EnvironmentReadinessEvidence> evidence;

  EnvironmentReadinessAction? get primaryAction {
    if (actions.isEmpty) {
      return null;
    }
    return actions.first;
  }

  List<EnvironmentReadinessAction> get secondaryActions {
    if (actions.length < 2) {
      return const <EnvironmentReadinessAction>[];
    }
    return actions.sublist(1);
  }
}
