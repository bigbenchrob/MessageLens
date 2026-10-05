import 'package:meta/meta.dart';

import 'app_czar_attachment_archive_repair_models.dart';

enum AppCzarAttachmentArchiveRepairPhase {
  dormant,
  inspecting,
  awaitingConfirmation,
  preserving,
  waitingForHuman,
  stopping,
  restartRequested,
  restartFailed,
  failed,
}

enum AppCzarAttachmentArchiveRepairFailureKind {
  inspectionFailed,
  preservationFailed,
  incoherentEvidence,
  drainFailed,
  restartFailed,
}

@immutable
final class AppCzarAttachmentArchiveRepairState {
  const AppCzarAttachmentArchiveRepairState({
    required this.phase,
    this.assessmentGeneration,
    this.occurrenceId,
    this.snapshot,
    this.preservedCount,
    this.preservationTotalCount,
    this.failureKind,
  });

  const AppCzarAttachmentArchiveRepairState.dormant()
    : this(phase: AppCzarAttachmentArchiveRepairPhase.dormant);

  final AppCzarAttachmentArchiveRepairPhase phase;
  final int? assessmentGeneration;
  final int? occurrenceId;
  final AppCzarAttachmentArchiveRepairSnapshot? snapshot;
  final int? preservedCount;
  final int? preservationTotalCount;
  final AppCzarAttachmentArchiveRepairFailureKind? failureKind;

  bool get isVisible => phase != AppCzarAttachmentArchiveRepairPhase.dormant;

  bool get canStartPreservation {
    return phase == AppCzarAttachmentArchiveRepairPhase.awaitingConfirmation &&
        snapshot?.hasAutomaticWork == true;
  }

  bool get canCheckAgain {
    return phase == AppCzarAttachmentArchiveRepairPhase.awaitingConfirmation ||
        phase == AppCzarAttachmentArchiveRepairPhase.waitingForHuman ||
        phase == AppCzarAttachmentArchiveRepairPhase.failed;
  }

  bool get canRetryRestart {
    return phase == AppCzarAttachmentArchiveRepairPhase.restartFailed;
  }

  AppCzarAttachmentArchiveRepairState copyWith({
    AppCzarAttachmentArchiveRepairPhase? phase,
    AppCzarAttachmentArchiveRepairSnapshot? snapshot,
    int? preservedCount,
    int? preservationTotalCount,
    AppCzarAttachmentArchiveRepairFailureKind? failureKind,
    bool clearProgress = false,
    bool clearFailure = false,
  }) {
    return AppCzarAttachmentArchiveRepairState(
      phase: phase ?? this.phase,
      assessmentGeneration: assessmentGeneration,
      occurrenceId: occurrenceId,
      snapshot: snapshot ?? this.snapshot,
      preservedCount: clearProgress
          ? null
          : preservedCount ?? this.preservedCount,
      preservationTotalCount: clearProgress
          ? null
          : preservationTotalCount ?? this.preservationTotalCount,
      failureKind: clearFailure ? null : failureKind ?? this.failureKind,
    );
  }
}
