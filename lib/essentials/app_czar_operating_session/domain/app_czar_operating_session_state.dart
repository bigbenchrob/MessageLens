import 'package:meta/meta.dart';

enum AppCzarOperatingSessionPhase {
  dormant,
  restoringVisualWindowState,
  admitted,
  draining,
  failed,
}

/// Process-local identity and admitted archive evidence for one Operating
/// Session occurrence.
///
/// This is observation evidence only. It is not attachment-root mutation
/// authority and cannot be used in place of a writable-root lease.
@immutable
final class AppCzarOperatingSessionOccurrence {
  const AppCzarOperatingSessionOccurrence({
    required this.processSequence,
    required this.assessmentGeneration,
    required this.admittedArchiveScopeIdentity,
    required this.admittedArchiveProbeGeneration,
    required this.admittedArchiveResolvedPath,
  });

  final int processSequence;
  final int assessmentGeneration;
  final String? admittedArchiveScopeIdentity;
  final int? admittedArchiveProbeGeneration;
  final String? admittedArchiveResolvedPath;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppCzarOperatingSessionOccurrence &&
            processSequence == other.processSequence &&
            assessmentGeneration == other.assessmentGeneration &&
            admittedArchiveScopeIdentity ==
                other.admittedArchiveScopeIdentity &&
            admittedArchiveProbeGeneration ==
                other.admittedArchiveProbeGeneration &&
            admittedArchiveResolvedPath == other.admittedArchiveResolvedPath;
  }

  @override
  int get hashCode => Object.hash(
    processSequence,
    assessmentGeneration,
    admittedArchiveScopeIdentity,
    admittedArchiveProbeGeneration,
    admittedArchiveResolvedPath,
  );
}

@immutable
final class AppCzarOperatingSessionState {
  const AppCzarOperatingSessionState({
    required this.phase,
    this.assessmentGeneration,
    this.occurrence,
    this.failure,
  });

  const AppCzarOperatingSessionState.dormant()
    : this(phase: AppCzarOperatingSessionPhase.dormant);

  final AppCzarOperatingSessionPhase phase;
  final int? assessmentGeneration;
  final AppCzarOperatingSessionOccurrence? occurrence;
  final String? failure;

  bool get isVisible => phase != AppCzarOperatingSessionPhase.dormant;

  bool get isEntryInFlight =>
      phase == AppCzarOperatingSessionPhase.restoringVisualWindowState;

  bool get isAdmitted => phase == AppCzarOperatingSessionPhase.admitted;

  /// Whether the exact occurrence must continue owning the Operating shell.
  ///
  /// Draining deliberately keeps the shell and its currentness-family watcher
  /// alive until every admitted observation and mutation Ball has returned.
  bool get ownsOperatingShell =>
      phase == AppCzarOperatingSessionPhase.admitted ||
      phase == AppCzarOperatingSessionPhase.draining;
}
