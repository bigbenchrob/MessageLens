enum AdvancedStartFreshPresentationPhase {
  idle,
  preparing,
  verifiedVirgin,
  failed,
}

enum AdvancedStartFreshFailureKind {
  installationIneligible,
  installationStateUnavailable,
  mutationUnavailable,
  virginVerificationFailed,
  executionFailed,
}

final class AdvancedStartFreshFailure {
  const AdvancedStartFreshFailure({
    required this.kind,
    required this.summary,
    required this.canRetry,
  });

  final AdvancedStartFreshFailureKind kind;
  final String summary;
  final bool canRetry;
}

final class AdvancedStartFreshPresentation {
  const AdvancedStartFreshPresentation({
    required this.occurrence,
    required this.phase,
    this.failure,
  });

  const AdvancedStartFreshPresentation.idle()
    : this(occurrence: 0, phase: AdvancedStartFreshPresentationPhase.idle);

  final int occurrence;
  final AdvancedStartFreshPresentationPhase phase;
  final AdvancedStartFreshFailure? failure;

  bool get isVisible => phase != AdvancedStartFreshPresentationPhase.idle;
}
