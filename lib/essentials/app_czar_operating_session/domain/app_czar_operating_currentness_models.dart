import 'package:meta/meta.dart';

import '../../app_czar/domain/app_czar_models.dart';
import '../../conversation_graph/application/conversation_graph_build_observation.dart';
import 'app_czar_operating_session_state.dart';

enum AppCzarOperatingCurrentnessPhase {
  idle,
  updating,
  preservingAttachments,
  verifyingCoverage,
  issue,
  restarting,
  stopped,
}

enum AppCzarOperatingCurrentnessIssueKind {
  admittedArchiveBindingUnavailable,
  sourceUnreadable,
  sourceUnknown,
  sourceUnstable,
  localDatasetContradiction,
  archiveChanged,
  archiveUnavailable,
  coverageIncomplete,
  coverageUnknown,
  updateFailed,
}

@immutable
final class AppCzarOperatingCurrentnessState {
  const AppCzarOperatingCurrentnessState({
    required this.occurrence,
    required this.phase,
    this.suboperation,
    this.completedWorkCount,
    this.totalWorkCount,
    this.attachmentsExamined,
    this.attachmentsPreserved,
    this.attachmentsSkipped,
    this.attachmentsFailed,
    this.issueKind,
    this.issue,
  });

  factory AppCzarOperatingCurrentnessState.idle(
    AppCzarOperatingSessionOccurrence occurrence,
  ) {
    return AppCzarOperatingCurrentnessState(
      occurrence: occurrence,
      phase: AppCzarOperatingCurrentnessPhase.idle,
    );
  }

  final AppCzarOperatingSessionOccurrence occurrence;
  final AppCzarOperatingCurrentnessPhase phase;
  final ConversationGraphBuildSuboperation? suboperation;
  final int? completedWorkCount;
  final int? totalWorkCount;
  final int? attachmentsExamined;
  final int? attachmentsPreserved;
  final int? attachmentsSkipped;
  final int? attachmentsFailed;
  final AppCzarOperatingCurrentnessIssueKind? issueKind;
  final String? issue;

  bool get hasVisibleStatus {
    return switch (phase) {
      AppCzarOperatingCurrentnessPhase.idle ||
      AppCzarOperatingCurrentnessPhase.stopped => false,
      _ => true,
    };
  }

  bool get requiresRestartPresentation =>
      phase == AppCzarOperatingCurrentnessPhase.issue;

  AppCzarOperatingCurrentnessState copyWith({
    AppCzarOperatingCurrentnessPhase? phase,
    ConversationGraphBuildSuboperation? suboperation,
    int? completedWorkCount,
    int? totalWorkCount,
    int? attachmentsExamined,
    int? attachmentsPreserved,
    int? attachmentsSkipped,
    int? attachmentsFailed,
    AppCzarOperatingCurrentnessIssueKind? issueKind,
    String? issue,
    bool clearProgress = false,
    bool clearIssue = false,
  }) {
    return AppCzarOperatingCurrentnessState(
      occurrence: occurrence,
      phase: phase ?? this.phase,
      suboperation: clearProgress ? null : suboperation ?? this.suboperation,
      completedWorkCount: clearProgress
          ? null
          : completedWorkCount ?? this.completedWorkCount,
      totalWorkCount: clearProgress
          ? null
          : totalWorkCount ?? this.totalWorkCount,
      attachmentsExamined: clearProgress
          ? null
          : attachmentsExamined ?? this.attachmentsExamined,
      attachmentsPreserved: clearProgress
          ? null
          : attachmentsPreserved ?? this.attachmentsPreserved,
      attachmentsSkipped: clearProgress
          ? null
          : attachmentsSkipped ?? this.attachmentsSkipped,
      attachmentsFailed: clearProgress
          ? null
          : attachmentsFailed ?? this.attachmentsFailed,
      issueKind: clearIssue ? null : issueKind ?? this.issueKind,
      issue: clearIssue ? null : issue ?? this.issue,
    );
  }
}

@immutable
final class AppCzarOperatingArchiveLocationEvidence {
  const AppCzarOperatingArchiveLocationEvidence({
    required this.generation,
    required this.isReadable,
    required this.isWritableMutationEligible,
    required this.resolvedPath,
    this.issue,
  });

  final int generation;
  final bool isReadable;
  final bool isWritableMutationEligible;
  final String? resolvedPath;
  final String? issue;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppCzarOperatingArchiveLocationEvidence &&
            generation == other.generation &&
            isReadable == other.isReadable &&
            isWritableMutationEligible == other.isWritableMutationEligible &&
            resolvedPath == other.resolvedPath &&
            issue == other.issue;
  }

  @override
  int get hashCode => Object.hash(
    generation,
    isReadable,
    isWritableMutationEligible,
    resolvedPath,
    issue,
  );
}

@immutable
final class AppCzarOperatingMutationFence {
  const AppCzarOperatingMutationFence({
    required this.isActive,
    required this.revisionToken,
    required this.lastReleasedAtMicroseconds,
  });

  final bool isActive;
  final Object revisionToken;
  final int? lastReleasedAtMicroseconds;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppCzarOperatingMutationFence &&
            isActive == other.isActive &&
            identical(revisionToken, other.revisionToken) &&
            lastReleasedAtMicroseconds == other.lastReleasedAtMicroseconds;
  }

  @override
  int get hashCode => Object.hash(
    isActive,
    identityHashCode(revisionToken),
    lastReleasedAtMicroseconds,
  );
}

@immutable
final class AppCzarOperatingReadFence {
  const AppCzarOperatingReadFence({
    required this.messageDataGeneration,
    required this.archiveLocation,
    required this.mutation,
  });

  final int messageDataGeneration;
  final AppCzarOperatingArchiveLocationEvidence archiveLocation;
  final AppCzarOperatingMutationFence mutation;

  bool get isQuiescent => !mutation.isActive;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppCzarOperatingReadFence &&
            messageDataGeneration == other.messageDataGeneration &&
            archiveLocation == other.archiveLocation &&
            mutation == other.mutation;
  }

  @override
  int get hashCode =>
      Object.hash(messageDataGeneration, archiveLocation, mutation);
}

@immutable
final class AppCzarOperatingCurrentnessObservation {
  const AppCzarOperatingCurrentnessObservation({
    required this.before,
    required this.after,
    this.source,
    this.importStore,
    this.graphStore,
  });

  final AppCzarOperatingReadFence before;
  final AppCzarOperatingReadFence after;
  final AppCzarSourceObservation? source;
  final AppCzarDatabaseObservation? importStore;
  final AppCzarDatabaseObservation? graphStore;

  bool get isCoherent =>
      before.isQuiescent &&
      before == after &&
      source != null &&
      importStore != null &&
      graphStore != null;
}

@immutable
final class AppCzarOperatingCoverageObservation {
  const AppCzarOperatingCoverageObservation({
    required this.before,
    required this.after,
    required this.archive,
  });

  final AppCzarOperatingReadFence before;
  final AppCzarOperatingReadFence after;
  final AppCzarArchiveObservation archive;

  bool get isCoherent => before.isQuiescent && before == after;
}

@immutable
final class AppCzarOperatingArchiveBinding {
  const AppCzarOperatingArchiveBinding({
    required this.scopeIdentity,
    required this.probeGeneration,
    required this.locationGeneration,
    required this.resolvedPath,
  });

  final String scopeIdentity;
  final int probeGeneration;
  final int locationGeneration;
  final String resolvedPath;

  bool matchesLocation(AppCzarOperatingArchiveLocationEvidence location) {
    return location.isReadable &&
        location.generation == locationGeneration &&
        location.resolvedPath == resolvedPath;
  }

  bool matchesArchive(AppCzarArchiveObservation archive) {
    return archive.archiveScopeIdentity == scopeIdentity &&
        archive.archiveGeneration == probeGeneration &&
        archive.resolvedPath == resolvedPath &&
        archive.coverage.archiveScopeIdentity == scopeIdentity &&
        archive.coverage.archiveGeneration == probeGeneration &&
        archive.hasCoherentCoverageBinding;
  }
}

enum AppCzarOperatingCurrentnessDisposition {
  noChange,
  sourceAhead,
  sourceUnreadable,
  sourceUnknown,
  sourceUnstable,
  localContradiction,
  transient,
}

@immutable
final class AppCzarOperatingCurrentnessDecision {
  const AppCzarOperatingCurrentnessDecision({
    required this.disposition,
    required this.detail,
  });

  final AppCzarOperatingCurrentnessDisposition disposition;
  final String detail;
}
