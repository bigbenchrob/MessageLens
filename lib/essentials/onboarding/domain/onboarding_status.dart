/// The lifecycle state of the first-run onboarding overlay.
enum OnboardingStatus {
  /// Both databases exist and contain data — no overlay needed.
  notNeeded,

  /// First run detected — show welcome panel with "Import" button.
  awaitingUserAction,

  /// Import orchestrator is running.
  importing,

  /// Migration orchestrator is running.
  migrating,

  /// Both pipelines succeeded — show summary with "Get Started" or "Done".
  complete,

  /// Reimport triggered from settings — skip welcome, go straight to import.
  reimporting,

  /// Reimport migration phase.
  reimportMigrating,

  /// Reimport finished — show summary with "Done" button.
  reimportComplete,
}
