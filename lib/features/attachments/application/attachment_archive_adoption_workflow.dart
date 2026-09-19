import 'package:meta/meta.dart';

import '../domain/entities/attachment_archive_adoption.dart';
import '../domain/entities/attachment_archive_candidate_verification.dart';

enum AttachmentArchiveAdoptionWorkflowStage {
  currentArchive,
  checking,
  candidateComplete,
  candidateBehind,
  candidateInvalid,
  sourceUnavailable,
  candidateUnavailable,
  verificationFailed,
  archiveChanged,
  verificationEvidenceInvalid,
  candidateNoLongerWritable,
  switching,
  success,
  rollbackRestoredPrevious,
  rollbackPendingPreviousUnavailable,
  configurationConflict,
  failed,
}

/// Process-local Settings state for checking and adopting an existing archive.
///
/// This model intentionally carries no bookmark, configuration authority,
/// structural fingerprint, or complete verification result.
@immutable
final class AttachmentArchiveAdoptionWorkflowState {
  const AttachmentArchiveAdoptionWorkflowState({
    required this.stage,
    required this.executionEnabled,
    this.sourcePath,
    this.candidatePath,
    this.candidateVolumeName,
    this.candidateIsAdoptable = false,
    this.progress,
    this.requiredFileCount,
    this.requiredBytes,
    this.verifiedFileCount,
    this.verifiedBytes,
    this.allowedExtraCount,
    this.allowedExtraBytes,
    this.missingCount,
    this.missingBytes,
    this.issue,
  });

  const AttachmentArchiveAdoptionWorkflowState.currentArchive({
    required bool executionEnabled,
  }) : this(
         stage: AttachmentArchiveAdoptionWorkflowStage.currentArchive,
         executionEnabled: executionEnabled,
       );

  final AttachmentArchiveAdoptionWorkflowStage stage;
  final bool executionEnabled;
  final String? sourcePath;
  final String? candidatePath;
  final String? candidateVolumeName;
  final bool candidateIsAdoptable;
  final AttachmentArchiveVerificationProgress? progress;
  final int? requiredFileCount;
  final int? requiredBytes;
  final int? verifiedFileCount;
  final int? verifiedBytes;
  final int? allowedExtraCount;
  final int? allowedExtraBytes;
  final int? missingCount;
  final int? missingBytes;
  final String? issue;

  bool get canUseCandidate {
    return executionEnabled &&
        stage == AttachmentArchiveAdoptionWorkflowStage.candidateComplete &&
        candidateIsAdoptable;
  }
}

/// Narrow application boundary used by the ephemeral Settings workflow.
abstract interface class AttachmentArchiveAdoptionExecutor {
  Future<AttachmentArchiveAdoptionResult> adopt(
    AttachmentArchiveCandidateComplete verification,
  );
}
