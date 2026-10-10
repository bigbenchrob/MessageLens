import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/util/date_label_formatter.dart';
import '../../../essentials/archive_environment/domain.dart'
    show ArchiveMutationDeniedException, ArchiveMutationOperation;
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCoordinatorState, archiveMutationCoordinatorProvider;
import '../../../essentials/conversation_graph/feature_level_providers.dart'
    show
        SourceScopedArchiveGraphImportObservation,
        SourceScopedArchiveGraphProjectionProgress,
        SourceScopedArchiveGraphProjectionUnit,
        SourceScopedArchiveGraphImportStage,
        SourceScopedArchiveGraphImportStageTransition,
        SourceScopedArchiveGraphRemovalObservation,
        SourceScopedArchiveGraphRemovalStage,
        SourceScopedArchiveGraphRemovalStageTransition,
        sourceScopedArchiveGraphImportServiceProvider,
        sourceScopedArchiveGraphRemovalServiceProvider;
import '../../../essentials/db/feature_level_providers.dart'
    show dbMaintenanceLockProvider;
import '../../../essentials/db/feature_level_providers/message_data_version_provider.dart'
    show messageDataVersionProvider;
import '../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../../../essentials/messages_source/feature_level_providers.dart'
    show currentMessagesSourcePathProvider;
import '../../../essentials/navigation/feature_level_providers.dart'
    show SidebarMode, activeSidebarModeProvider;
import '../../../essentials/sidebar/feature_level_providers.dart'
    show sidebarFlowProvider;
import '../../../essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
import '../../../essentials/source_scoped_import/domain/messages_lineage_admission.dart';
import '../../../essentials/source_scoped_import/feature_level_providers.dart'
    show messagesLineageAdmissionAuthorityProvider;
import '../../attachments/domain/entities/message_lens_attachment_recovery.dart'
    show
        MessageLensAttachmentRecoveryClassification,
        MessageLensAttachmentRecoveryPreflight;
import '../../attachments/feature_level_providers.dart'
    show
        MessageLensAttachmentRecoveryBatchProgress,
        MessageLensAttachmentRecoveryBatchResult,
        MessageLensAttachmentRecoveryBatchStage,
        messageLensAttachmentRecoveryBatchExecutorProvider;
import '../../sidebar_utilities/domain/sidebar_utilities_constants.dart'
    show SettingsMenuActionId;
import 'archive_source_inspection.dart';
import 'archive_source_inspector_provider.dart';
import 'historical_archive_folder_chooser_provider.dart';
import 'historical_archive_sources.dart';
import 'historical_archive_sources_provider.dart';
import 'message_lens_historical_archive_preflight.dart';
import 'message_lens_historical_archive_preflight_provider.dart';

part 'historical_archives_workflow_panel_model_provider.g.dart';

const _historicalArchivesTestingOwner = 'historical-archives-testing-clear';

void _logHistoricalArchivesWarning(
  Ref ref, {
  required String message,
  required Object error,
  required StackTrace stackTrace,
}) {
  ref
      .read(appLoggerProvider.notifier)
      .warn(
        message,
        source: 'HistoricalArchivesWorkflow',
        context: {
          'error': error.toString(),
          'stack': stackTrace.toString().split('\n').take(5).join('\n'),
        },
      );
}

void _logMessageLensAttachmentPreflight(
  Ref ref,
  MessageLensAttachmentRecoveryPreflight preflight,
) {
  final funnel = preflight.funnel;
  ref
      .read(appLoggerProvider.notifier)
      .info(
        'MessageLens attachment-recovery preflight completed',
        source: 'HistoricalArchivesWorkflow',
        context: {
          'donorPayloadClaims': funnel.donorPayloadClaimCount,
          'donorRelationshipEvidence': funnel.donorRelationshipEvidenceCount,
          'currentRelationshipEvidence':
              funnel.currentRelationshipEvidenceCount,
          'donorRelationshipUnmatched': funnel.donorRelationshipUnmatchedCount,
          'messageIdentitiesMatched': funnel.messageMatchedCount,
          'attachmentIdentitiesMatched': funnel.attachmentMatchedCount,
          'donorPayloadsPhysicallyValid': funnel.donorPayloadPresentCount,
          'currentPayloadsPhysicallyValid': funnel.currentPayloadPresentCount,
          'recoverable': preflight.recoverableCount,
          'alreadyPresent': preflight.alreadyPresentCount,
          'donorMissing': preflight.donorMissingCount,
          'messageMismatch': preflight.messageMismatchCount,
          'attachmentMismatch': preflight.attachmentMismatchCount,
          'conflict': preflight.conflictCount,
          'ambiguous': preflight.ambiguousCount,
          'unsafeDonorPath': preflight.unsafeDonorPathCount,
          'duplicateClaimsCollapsed': funnel.duplicateClaimsCollapsedCount,
          'terminalClassifications': preflight.terminalClassificationCount,
          'countsReconcile': preflight.classificationCountsReconcile,
        },
      );
}

enum HistoricalArchivesExecutionGateStatus { available, busy, blocked }

enum HistoricalArchiveSourceType { messagesFolders, messageLensDataFolders }

final class HistoricalArchivesExecutionGateViewModel {
  const HistoricalArchivesExecutionGateViewModel({
    required this.status,
    required this.statusLabel,
    required this.detail,
  });

  final HistoricalArchivesExecutionGateStatus status;
  final String statusLabel;
  final String detail;
}

enum HistoricalArchivesPreflightStatus {
  waitingForFolder,
  running,
  completeReadyToImport,
  failed,
}

/// Ephemeral presentation state only. [identity] identifies the archive;
/// [referenceOccurrence] identifies a fresh "look here" event in this process.
final class HistoricalArchivesKnownSourceReference {
  const HistoricalArchivesKnownSourceReference({
    required this.identity,
    required this.referenceOccurrence,
  });

  final HistoricalArchiveSourceIdentity identity;
  final int referenceOccurrence;

  String get sourceKey => identity.value;
}

/// One-use presentation notice for a failed add attempt.
///
/// The source key identifies the existing sidebar object. Both occurrences are
/// process-only guards; none of this state is archive metadata.
sealed class HistoricalArchivesNotice {
  const HistoricalArchivesNotice();
}

final class HistoricalArchivesDuplicateFolderNotice
    extends HistoricalArchivesNotice {
  const HistoricalArchivesDuplicateFolderNotice({
    required this.identity,
    required this.noticeOccurrence,
    required this.presentationSessionOccurrence,
  }) : super();

  final HistoricalArchiveSourceIdentity identity;
  final int noticeOccurrence;
  final int presentationSessionOccurrence;

  String get sourceKey => identity.value;
}

/// One-use presentation notice for a folder that did not qualify as an archive.
///
/// It deliberately carries no folder identity or inspection evidence. The two
/// occurrences exist only to prevent stale modal completion from changing a
/// later presentation session.
final class HistoricalArchivesInvalidFolderNotice
    extends HistoricalArchivesNotice {
  const HistoricalArchivesInvalidFolderNotice({
    required this.noticeOccurrence,
    required this.presentationSessionOccurrence,
  }) : super();

  final int noticeOccurrence;
  final int presentationSessionOccurrence;
}

/// One-use presentation notice for a Messages-lineage admission failure.
///
/// It carries only the typed outcome and process-local stale-event guards. It
/// is not source metadata and never identifies a sidebar object.
final class HistoricalArchivesLineageNotice extends HistoricalArchivesNotice {
  const HistoricalArchivesLineageNotice({
    required this.status,
    required this.noticeOccurrence,
    required this.presentationSessionOccurrence,
  }) : assert(status != MessagesLineageAdmissionStatus.sameLineage),
       super();

  final MessagesLineageAdmissionStatus status;
  final int noticeOccurrence;
  final int presentationSessionOccurrence;
}

/// One-use acknowledgement of a terminally successful archive import.
///
/// Both occurrences are process-only guards. Import finalization and source
/// membership are complete before this notice exists.
final class HistoricalArchivesImportSuccessNotice
    extends HistoricalArchivesNotice {
  const HistoricalArchivesImportSuccessNotice({
    required this.noticeOccurrence,
    required this.presentationSessionOccurrence,
  }) : super();

  final int noticeOccurrence;
  final int presentationSessionOccurrence;
}

enum HistoricalArchivesMessageLensNoticeKind {
  invalidFolder,
  incompatibleArchive,
  contradictoryLineage,
  insufficientLineage,
  nothingRecoverable,
  recoveryComplete,
  recoveryFinished,
}

final class HistoricalArchivesMessageLensNotice
    extends HistoricalArchivesNotice {
  const HistoricalArchivesMessageLensNotice({
    required this.kind,
    required this.noticeOccurrence,
    required this.presentationSessionOccurrence,
    this.detail,
    this.recoveredCount,
    this.couldNotRecoverCount,
  });

  final HistoricalArchivesMessageLensNoticeKind kind;
  final int noticeOccurrence;
  final int presentationSessionOccurrence;
  final String? detail;
  final int? recoveredCount;
  final int? couldNotRecoverCount;
}

const historicalArchivesReferenceFadeInDuration = Duration(milliseconds: 750);
const historicalArchivesReferenceHoldDuration = Duration(milliseconds: 1000);
const historicalArchivesReferenceFadeOutDuration = Duration(milliseconds: 2000);
const historicalArchivesReferenceLifetime = Duration(milliseconds: 3750);
const historicalArchivesTerminalCompletedDwellDuration = Duration(
  milliseconds: 1500,
);

final class HistoricalArchivesInspectionEvidence {
  const HistoricalArchivesInspectionEvidence({
    required this.sourceIdentity,
    required this.folderPath,
    required this.chatDbPath,
    required this.sourceLabel,
    required this.chatDbStatus,
    required this.attachmentsStatusLabel,
    required this.totalMessages,
    required this.totalChats,
    required this.totalHandles,
    required this.missingGuids,
    required this.earliestMessageUtc,
    required this.latestMessageUtc,
    required this.dateRangeUnavailableReason,
    required this.dryRunNewMessages,
    required this.dryRunDuplicateMessages,
    required this.dryRunComparableMessages,
    required this.dryRunUnavailableReason,
    this.successfulImportFinishedAtUtc,
  });

  final HistoricalArchiveSourceIdentity? sourceIdentity;
  final String folderPath;
  final String chatDbPath;
  final String sourceLabel;
  final ArchiveSourceInspectionStatus chatDbStatus;
  final String attachmentsStatusLabel;
  final int? totalMessages;
  final int? totalChats;
  final int? totalHandles;
  final int? missingGuids;
  final String? earliestMessageUtc;
  final String? latestMessageUtc;
  final String? dateRangeUnavailableReason;
  final int? dryRunNewMessages;
  final int? dryRunDuplicateMessages;
  final int? dryRunComparableMessages;
  final String? dryRunUnavailableReason;
  final String? successfulImportFinishedAtUtc;

  String get chatDbStatusLabel => chatDbStatus.label;
}

enum HistoricalArchivesNarratorPresentationKind {
  noSource,
  inspectingSource,
  inspectingMessageLensSource,
  inspectionFailed,
  readyForImport,
  messageLensReady,
  recoveringMessageLensAttachments,
  messageLensRecoveryFailed,
  knownSource,
  importingArchive,
  importFailed,
  removingSource,
  removalFailed,
}

enum HistoricalArchivesInstrumentationStatus {
  waiting,
  working,
  resolved,
  failed,
}

enum HistoricalArchiveRemovalStage {
  removingImportedMessages,
  updatingMessageLensHistory,
  verifyingRemoval,
}

enum HistoricalArchiveRemovalStageStatus {
  waiting,
  running,
  succeeded,
  skipped,
  failed,
}

enum HistoricalArchiveImportStage {
  addingMessages,
  preparingConversations,
  verifyingImport,
}

enum HistoricalArchiveImportStageStatus { waiting, running, succeeded, failed }

final class HistoricalArchiveImportProgress {
  const HistoricalArchiveImportProgress({
    this.addingMessages = HistoricalArchiveImportStageStatus.waiting,
    this.preparingConversations = HistoricalArchiveImportStageStatus.waiting,
    this.verifyingImport = HistoricalArchiveImportStageStatus.waiting,
    this.graphProjectionProgress,
  });

  final HistoricalArchiveImportStageStatus addingMessages;
  final HistoricalArchiveImportStageStatus preparingConversations;
  final HistoricalArchiveImportStageStatus verifyingImport;
  final SourceScopedArchiveGraphProjectionProgress? graphProjectionProgress;

  HistoricalArchiveImportStageStatus statusFor(
    HistoricalArchiveImportStage stage,
  ) {
    return switch (stage) {
      HistoricalArchiveImportStage.addingMessages => addingMessages,
      HistoricalArchiveImportStage.preparingConversations =>
        preparingConversations,
      HistoricalArchiveImportStage.verifyingImport => verifyingImport,
    };
  }

  HistoricalArchiveImportProgress withStage(
    HistoricalArchiveImportStage stage,
    HistoricalArchiveImportStageStatus status,
  ) {
    return HistoricalArchiveImportProgress(
      addingMessages: stage == HistoricalArchiveImportStage.addingMessages
          ? status
          : addingMessages,
      preparingConversations:
          stage == HistoricalArchiveImportStage.preparingConversations
          ? status
          : preparingConversations,
      verifyingImport: stage == HistoricalArchiveImportStage.verifyingImport
          ? status
          : verifyingImport,
      graphProjectionProgress: graphProjectionProgress,
    );
  }

  HistoricalArchiveImportProgress withGraphProjectionProgress(
    SourceScopedArchiveGraphProjectionProgress progress,
  ) {
    return HistoricalArchiveImportProgress(
      addingMessages: addingMessages,
      preparingConversations: preparingConversations,
      verifyingImport: verifyingImport,
      graphProjectionProgress: progress,
    );
  }

  bool get isComplete {
    return addingMessages == HistoricalArchiveImportStageStatus.succeeded &&
        preparingConversations ==
            HistoricalArchiveImportStageStatus.succeeded &&
        verifyingImport == HistoricalArchiveImportStageStatus.succeeded;
  }
}

final class HistoricalArchiveRemovalProgress {
  const HistoricalArchiveRemovalProgress({
    this.removingImportedMessages = HistoricalArchiveRemovalStageStatus.waiting,
    this.updatingMessageLensHistory =
        HistoricalArchiveRemovalStageStatus.waiting,
    this.verifyingRemoval = HistoricalArchiveRemovalStageStatus.waiting,
    this.graphProjectionProgress,
  });

  final HistoricalArchiveRemovalStageStatus removingImportedMessages;
  final HistoricalArchiveRemovalStageStatus updatingMessageLensHistory;
  final HistoricalArchiveRemovalStageStatus verifyingRemoval;
  final SourceScopedArchiveGraphProjectionProgress? graphProjectionProgress;

  HistoricalArchiveRemovalStageStatus statusFor(
    HistoricalArchiveRemovalStage stage,
  ) {
    return switch (stage) {
      HistoricalArchiveRemovalStage.removingImportedMessages =>
        removingImportedMessages,
      HistoricalArchiveRemovalStage.updatingMessageLensHistory =>
        updatingMessageLensHistory,
      HistoricalArchiveRemovalStage.verifyingRemoval => verifyingRemoval,
    };
  }

  HistoricalArchiveRemovalProgress withStage(
    HistoricalArchiveRemovalStage stage,
    HistoricalArchiveRemovalStageStatus status,
  ) {
    return HistoricalArchiveRemovalProgress(
      removingImportedMessages:
          stage == HistoricalArchiveRemovalStage.removingImportedMessages
          ? status
          : removingImportedMessages,
      updatingMessageLensHistory:
          stage == HistoricalArchiveRemovalStage.updatingMessageLensHistory
          ? status
          : updatingMessageLensHistory,
      verifyingRemoval: stage == HistoricalArchiveRemovalStage.verifyingRemoval
          ? status
          : verifyingRemoval,
      graphProjectionProgress: graphProjectionProgress,
    );
  }

  HistoricalArchiveRemovalProgress withGraphProjectionProgress(
    SourceScopedArchiveGraphProjectionProgress progress,
  ) {
    return HistoricalArchiveRemovalProgress(
      removingImportedMessages: removingImportedMessages,
      updatingMessageLensHistory: updatingMessageLensHistory,
      verifyingRemoval: verifyingRemoval,
      graphProjectionProgress: progress,
    );
  }

  bool get isComplete {
    final historyUpdateComplete =
        updatingMessageLensHistory ==
            HistoricalArchiveRemovalStageStatus.succeeded ||
        updatingMessageLensHistory ==
            HistoricalArchiveRemovalStageStatus.skipped;
    return removingImportedMessages ==
            HistoricalArchiveRemovalStageStatus.succeeded &&
        historyUpdateComplete &&
        verifyingRemoval == HistoricalArchiveRemovalStageStatus.succeeded;
  }

  HistoricalArchiveRemovalStage? get runningStage {
    for (final stage in HistoricalArchiveRemovalStage.values) {
      if (statusFor(stage) == HistoricalArchiveRemovalStageStatus.running) {
        return stage;
      }
    }
    return null;
  }
}

final class HistoricalArchivesInstrumentationRowViewModel {
  const HistoricalArchivesInstrumentationRowViewModel({
    required this.label,
    required this.value,
    required this.status,
    this.indentationLevel = 0,
  });

  final String label;
  final String value;
  final HistoricalArchivesInstrumentationStatus status;
  final int indentationLevel;
}

final class HistoricalArchivesNarratorPresentationViewModel {
  const HistoricalArchivesNarratorPresentationViewModel({
    required this.kind,
    required this.narratorText,
    required this.instrumentationRows,
    required this.detailsLines,
    required this.retryInspectionEnabled,
  });

  final HistoricalArchivesNarratorPresentationKind kind;
  final String? narratorText;
  final List<HistoricalArchivesInstrumentationRowViewModel> instrumentationRows;
  final List<String> detailsLines;
  final bool retryInspectionEnabled;
}

final class HistoricalArchivesExistingSourcePresentationViewModel {
  const HistoricalArchivesExistingSourcePresentationViewModel({
    required this.sourceTypeStatement,
    required this.importDateStatement,
    required this.contentsStatement,
    required this.detailsLines,
    this.removalFailureStatement,
  });

  final String sourceTypeStatement;
  final String? importDateStatement;
  final String? contentsStatement;
  final List<String> detailsLines;
  final String? removalFailureStatement;
}

final class HistoricalArchivesPreflightViewModel {
  const HistoricalArchivesPreflightViewModel({
    required this.status,
    required this.statusLabel,
    required this.detail,
  });

  final HistoricalArchivesPreflightStatus status;
  final String statusLabel;
  final String detail;
}

final class HistoricalArchivesLogEntryViewModel {
  const HistoricalArchivesLogEntryViewModel({
    required this.label,
    required this.message,
  });

  final String label;
  final String message;
}

enum HistoricalArchivesWorkflowPhaseStatus {
  waiting,
  running,
  succeeded,
  failed,
  skipped,
}

final class HistoricalArchivesWorkflowPhaseViewModel {
  const HistoricalArchivesWorkflowPhaseViewModel({
    required this.label,
    required this.status,
    required this.detail,
  });

  final String label;
  final HistoricalArchivesWorkflowPhaseStatus status;
  final String detail;
}

final class HistoricalArchivesPresentationData {
  const HistoricalArchivesPresentationData({
    required this.preflight,
    required this.selectedFolderPath,
    required this.archiveRemovalTargetChatDbPath,
    required this.chatDbStatus,
    required this.attachmentsStatusLabel,
    required this.sourceLabel,
    required this.preflightSummaryLines,
    required this.dryRunSummaryLines,
    required this.importSafetySummaryLines,
    required this.resultSummaryLines,
    required this.activityLog,
    required this.phases,
  });

  final HistoricalArchivesPreflightViewModel preflight;
  final String selectedFolderPath;
  final String archiveRemovalTargetChatDbPath;
  final ArchiveSourceInspectionStatus chatDbStatus;
  final String attachmentsStatusLabel;
  final String sourceLabel;
  final List<String> preflightSummaryLines;
  final List<String> dryRunSummaryLines;
  final List<String> importSafetySummaryLines;
  final List<String> resultSummaryLines;
  final List<HistoricalArchivesLogEntryViewModel> activityLog;
  final List<HistoricalArchivesWorkflowPhaseViewModel> phases;

  String get chatDbStatusLabel => chatDbStatus.label;

  HistoricalArchivesPresentationData copyWith({
    HistoricalArchivesPreflightViewModel? preflight,
    ArchiveSourceInspectionStatus? chatDbStatus,
    String? attachmentsStatusLabel,
    String? sourceLabel,
    List<String>? preflightSummaryLines,
    List<String>? dryRunSummaryLines,
    List<String>? importSafetySummaryLines,
    List<String>? resultSummaryLines,
    List<HistoricalArchivesLogEntryViewModel>? activityLog,
    List<HistoricalArchivesWorkflowPhaseViewModel>? phases,
  }) {
    return HistoricalArchivesPresentationData(
      preflight: preflight ?? this.preflight,
      selectedFolderPath: selectedFolderPath,
      archiveRemovalTargetChatDbPath: archiveRemovalTargetChatDbPath,
      chatDbStatus: chatDbStatus ?? this.chatDbStatus,
      attachmentsStatusLabel:
          attachmentsStatusLabel ?? this.attachmentsStatusLabel,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      preflightSummaryLines:
          preflightSummaryLines ?? this.preflightSummaryLines,
      dryRunSummaryLines: dryRunSummaryLines ?? this.dryRunSummaryLines,
      importSafetySummaryLines:
          importSafetySummaryLines ?? this.importSafetySummaryLines,
      resultSummaryLines: resultSummaryLines ?? this.resultSummaryLines,
      activityLog: activityLog ?? this.activityLog,
      phases: phases ?? this.phases,
    );
  }
}

sealed class HistoricalArchivesPresentationState {
  const HistoricalArchivesPresentationState();

  HistoricalArchivesPresentationData? get data;
}

final class HistoricalArchivesHubState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesHubState({
    this.sourceType = HistoricalArchiveSourceType.messagesFolders,
  });

  final HistoricalArchiveSourceType sourceType;

  @override
  HistoricalArchivesPresentationData? get data => null;
}

final class HistoricalArchivesMessageLensNoticeState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesMessageLensNoticeState({required this.notice});

  final HistoricalArchivesMessageLensNotice notice;

  @override
  HistoricalArchivesPresentationData? get data => null;
}

final class HistoricalArchivesMessageLensInspectingState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesMessageLensInspectingState({
    required this.folderPath,
    required this.inspectionOccurrence,
    this.progress,
  });

  final String folderPath;
  final int inspectionOccurrence;
  final MessageLensHistoricalArchivePreflightProgress? progress;

  @override
  HistoricalArchivesPresentationData? get data => null;
}

final class HistoricalArchivesMessageLensReadyState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesMessageLensReadyState({required this.evidence});

  final MessageLensHistoricalArchiveReady evidence;

  @override
  HistoricalArchivesPresentationData? get data => null;
}

final class HistoricalArchivesMessageLensRecoveringState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesMessageLensRecoveringState({
    required this.evidence,
    required this.operationOccurrence,
    required this.progress,
  });

  final MessageLensHistoricalArchiveReady evidence;
  final int operationOccurrence;
  final MessageLensAttachmentRecoveryBatchProgress progress;

  @override
  HistoricalArchivesPresentationData? get data => null;
}

final class HistoricalArchivesMessageLensRecoveryFailedState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesMessageLensRecoveryFailedState({
    required this.evidence,
    required this.progress,
    required this.failureDetail,
  });

  final MessageLensHistoricalArchiveReady evidence;
  final MessageLensAttachmentRecoveryBatchProgress progress;
  final String failureDetail;

  @override
  HistoricalArchivesPresentationData? get data => null;
}

final class HistoricalArchivesDuplicateNoticeState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesDuplicateNoticeState({required this.notice});

  final HistoricalArchivesDuplicateFolderNotice notice;

  @override
  HistoricalArchivesPresentationData? get data => null;
}

final class HistoricalArchivesInvalidNoticeState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesInvalidNoticeState({required this.notice});

  final HistoricalArchivesInvalidFolderNotice notice;

  @override
  HistoricalArchivesPresentationData? get data => null;
}

final class HistoricalArchivesLineageNoticeState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesLineageNoticeState({required this.notice});

  final HistoricalArchivesLineageNotice notice;

  @override
  HistoricalArchivesPresentationData? get data => null;
}

final class HistoricalArchivesImportSuccessNoticeState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesImportSuccessNoticeState({required this.notice});

  final HistoricalArchivesImportSuccessNotice notice;

  @override
  HistoricalArchivesPresentationData? get data => null;
}

final class HistoricalArchivesKnownSourceReferenceState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesKnownSourceReferenceState({required this.reference});

  final HistoricalArchivesKnownSourceReference reference;

  @override
  HistoricalArchivesPresentationData? get data => null;
}

final class HistoricalArchivesInspectingCandidateState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesInspectingCandidateState({
    required this.data,
    required this.inspectionOccurrence,
  });

  @override
  final HistoricalArchivesPresentationData data;
  final int inspectionOccurrence;
}

final class HistoricalArchivesInspectionFailedState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesInspectionFailedState({
    required this.data,
    required this.evidence,
  });

  @override
  final HistoricalArchivesPresentationData data;
  final HistoricalArchivesInspectionEvidence evidence;
}

final class HistoricalArchivesReadyToAddState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesReadyToAddState({
    required this.data,
    required this.evidence,
    required this.lineageAdmission,
  });

  @override
  final HistoricalArchivesPresentationData data;
  final HistoricalArchivesInspectionEvidence evidence;
  final SameMessagesLineageAdmission lineageAdmission;
}

final class HistoricalArchivesImportedSourceFacts {
  const HistoricalArchivesImportedSourceFacts({
    required this.identity,
    required this.importedMessageCount,
    required this.earliestMessageUtc,
    required this.latestMessageUtc,
    required this.successfulImportFinishedAtUtc,
  });

  final HistoricalArchiveSourceIdentity identity;
  final int importedMessageCount;
  final String? earliestMessageUtc;
  final String? latestMessageUtc;
  final String? successfulImportFinishedAtUtc;
}

final class HistoricalArchivesExistingSourceState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesExistingSourceState({
    required this.data,
    required this.facts,
    this.managementFailureDetail,
  });

  @override
  final HistoricalArchivesPresentationData data;
  final HistoricalArchivesImportedSourceFacts facts;
  final String? managementFailureDetail;
}

final class HistoricalArchivesImportingState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesImportingState({
    required this.data,
    required this.evidence,
    required this.progress,
    required this.lineageAdmission,
  });

  @override
  final HistoricalArchivesPresentationData data;
  final HistoricalArchivesInspectionEvidence evidence;
  final HistoricalArchiveImportProgress progress;
  final SameMessagesLineageAdmission lineageAdmission;
}

final class HistoricalArchivesImportFailedState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesImportFailedState({
    required this.data,
    required this.evidence,
    required this.progress,
    required this.failureDetail,
    required this.lineageAdmission,
  });

  @override
  final HistoricalArchivesPresentationData data;
  final HistoricalArchivesInspectionEvidence evidence;
  final HistoricalArchiveImportProgress progress;
  final String failureDetail;
  final SameMessagesLineageAdmission lineageAdmission;
}

final class HistoricalArchivesRemovingState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesRemovingState({
    required this.data,
    required this.facts,
    required this.progress,
  });

  @override
  final HistoricalArchivesPresentationData data;
  final HistoricalArchivesImportedSourceFacts facts;
  final HistoricalArchiveRemovalProgress progress;
}

final class HistoricalArchivesRemovalFailedState
    extends HistoricalArchivesPresentationState {
  const HistoricalArchivesRemovalFailedState({
    required this.data,
    required this.facts,
    required this.progress,
    required this.failureDetail,
  });

  @override
  final HistoricalArchivesPresentationData data;
  final HistoricalArchivesImportedSourceFacts facts;
  final HistoricalArchiveRemovalProgress progress;
  final String failureDetail;
}

final class HistoricalArchivesWorkflowState {
  const HistoricalArchivesWorkflowState({required this.presentation});

  final HistoricalArchivesPresentationState presentation;

  bool get isHub => switch (presentation) {
    HistoricalArchivesHubState() ||
    HistoricalArchivesMessageLensNoticeState() ||
    HistoricalArchivesDuplicateNoticeState() ||
    HistoricalArchivesInvalidNoticeState() ||
    HistoricalArchivesLineageNoticeState() ||
    HistoricalArchivesImportSuccessNoticeState() ||
    HistoricalArchivesKnownSourceReferenceState() => true,
    _ => false,
  };

  HistoricalArchiveSourceType get sourceType => switch (presentation) {
    HistoricalArchivesHubState(:final sourceType) => sourceType,
    HistoricalArchivesMessageLensNoticeState() ||
    HistoricalArchivesMessageLensInspectingState() ||
    HistoricalArchivesMessageLensReadyState() ||
    HistoricalArchivesMessageLensRecoveringState() ||
    HistoricalArchivesMessageLensRecoveryFailedState() =>
      HistoricalArchiveSourceType.messageLensDataFolders,
    _ => HistoricalArchiveSourceType.messagesFolders,
  };

  bool get sourceTypeSwitchEnabled =>
      presentation is! HistoricalArchivesImportingState &&
      presentation is! HistoricalArchivesRemovingState &&
      presentation is! HistoricalArchivesMessageLensRecoveringState;

  HistoricalArchivesPresentationData get _data =>
      presentation.data ?? _historicalArchivesHubPresentationData;

  HistoricalArchivesPreflightViewModel get preflight => _data.preflight;
  String? get selectedFolderPath => switch (presentation) {
    HistoricalArchivesMessageLensInspectingState(:final folderPath) =>
      folderPath,
    HistoricalArchivesMessageLensReadyState(:final evidence) =>
      evidence.donor.rootPath,
    HistoricalArchivesMessageLensRecoveringState(:final evidence) ||
    HistoricalArchivesMessageLensRecoveryFailedState(
      :final evidence,
    ) => evidence.donor.rootPath,
    _ => presentation.data?.selectedFolderPath,
  };
  String? get archiveRemovalTargetChatDbPath =>
      presentation.data?.archiveRemovalTargetChatDbPath;
  ArchiveSourceInspectionStatus get chatDbStatus => _data.chatDbStatus;
  String get chatDbStatusLabel => _data.chatDbStatusLabel;
  String get attachmentsStatusLabel => _data.attachmentsStatusLabel;
  String get sourceLabel => _data.sourceLabel;
  List<String> get preflightSummaryLines => _data.preflightSummaryLines;
  List<String> get dryRunSummaryLines => _data.dryRunSummaryLines;
  List<String> get importSafetySummaryLines => _data.importSafetySummaryLines;
  List<String> get resultSummaryLines => _data.resultSummaryLines;
  List<HistoricalArchivesLogEntryViewModel> get activityLog =>
      _data.activityLog;
  List<HistoricalArchivesWorkflowPhaseViewModel> get phases => _data.phases;

  HistoricalArchivesInspectionEvidence? get inspectionEvidence =>
      switch (presentation) {
        HistoricalArchivesInspectionFailedState(:final evidence) ||
        HistoricalArchivesReadyToAddState(:final evidence) ||
        HistoricalArchivesImportingState(:final evidence) ||
        HistoricalArchivesImportFailedState(:final evidence) => evidence,
        HistoricalArchivesHubState() ||
        HistoricalArchivesMessageLensNoticeState() ||
        HistoricalArchivesMessageLensInspectingState() ||
        HistoricalArchivesMessageLensReadyState() ||
        HistoricalArchivesMessageLensRecoveringState() ||
        HistoricalArchivesMessageLensRecoveryFailedState() ||
        HistoricalArchivesDuplicateNoticeState() ||
        HistoricalArchivesInvalidNoticeState() ||
        HistoricalArchivesLineageNoticeState() ||
        HistoricalArchivesImportSuccessNoticeState() ||
        HistoricalArchivesKnownSourceReferenceState() ||
        HistoricalArchivesInspectingCandidateState() ||
        HistoricalArchivesExistingSourceState() ||
        HistoricalArchivesRemovingState() ||
        HistoricalArchivesRemovalFailedState() => null,
      };

  HistoricalArchivesImportedSourceFacts? get importedSourceFacts =>
      switch (presentation) {
        HistoricalArchivesExistingSourceState(:final facts) ||
        HistoricalArchivesRemovingState(:final facts) ||
        HistoricalArchivesRemovalFailedState(:final facts) => facts,
        _ => null,
      };

  HistoricalArchiveSourceIdentity? get selectedKnownSourceIdentity =>
      switch (presentation) {
        HistoricalArchivesExistingSourceState(:final facts) ||
        HistoricalArchivesRemovingState(:final facts) ||
        HistoricalArchivesRemovalFailedState(:final facts) => facts.identity,
        _ => null,
      };

  String? get selectedKnownSourceKey => selectedKnownSourceIdentity?.value;

  String? get removalFailureDetail => switch (presentation) {
    HistoricalArchivesExistingSourceState(:final managementFailureDetail) =>
      managementFailureDetail,
    HistoricalArchivesRemovalFailedState(:final failureDetail) => failureDetail,
    _ => null,
  };

  HistoricalArchiveRemovalProgress? get removalProgress =>
      switch (presentation) {
        HistoricalArchivesRemovingState(:final progress) ||
        HistoricalArchivesRemovalFailedState(:final progress) => progress,
        _ => null,
      };

  String? get importFailureDetail => switch (presentation) {
    HistoricalArchivesImportFailedState(:final failureDetail) => failureDetail,
    _ => null,
  };

  HistoricalArchiveImportProgress? get importProgress => switch (presentation) {
    HistoricalArchivesImportingState(:final progress) ||
    HistoricalArchivesImportFailedState(:final progress) => progress,
    _ => null,
  };

  HistoricalArchivesDuplicateFolderNotice? get duplicateFolderNotice =>
      switch (presentation) {
        HistoricalArchivesDuplicateNoticeState(:final notice) => notice,
        _ => null,
      };

  HistoricalArchivesInvalidFolderNotice? get invalidFolderNotice =>
      switch (presentation) {
        HistoricalArchivesInvalidNoticeState(:final notice) => notice,
        _ => null,
      };

  HistoricalArchivesLineageNotice? get lineageNotice => switch (presentation) {
    HistoricalArchivesLineageNoticeState(:final notice) => notice,
    _ => null,
  };

  HistoricalArchivesMessageLensNotice? get messageLensNotice =>
      switch (presentation) {
        HistoricalArchivesMessageLensNoticeState(:final notice) => notice,
        _ => null,
      };

  HistoricalArchivesImportSuccessNotice? get importSuccessNotice =>
      switch (presentation) {
        HistoricalArchivesImportSuccessNoticeState(:final notice) => notice,
        _ => null,
      };

  HistoricalArchivesKnownSourceReference? get knownSourceReference =>
      switch (presentation) {
        HistoricalArchivesKnownSourceReferenceState(:final reference) =>
          reference,
        _ => null,
      };

  HistoricalArchivesWorkflowState copyWith({
    HistoricalArchivesPresentationState? presentation,
  }) {
    return HistoricalArchivesWorkflowState(
      presentation: presentation ?? this.presentation,
    );
  }
}

HistoricalArchivesPresentationState _withPresentationData(
  HistoricalArchivesPresentationState presentation,
  HistoricalArchivesPresentationData data,
) {
  return switch (presentation) {
    HistoricalArchivesHubState() => presentation,
    HistoricalArchivesMessageLensNoticeState() => presentation,
    HistoricalArchivesMessageLensInspectingState() => presentation,
    HistoricalArchivesMessageLensReadyState() => presentation,
    HistoricalArchivesMessageLensRecoveringState() => presentation,
    HistoricalArchivesMessageLensRecoveryFailedState() => presentation,
    HistoricalArchivesDuplicateNoticeState() => presentation,
    HistoricalArchivesInvalidNoticeState() => presentation,
    HistoricalArchivesLineageNoticeState() => presentation,
    HistoricalArchivesImportSuccessNoticeState() => presentation,
    HistoricalArchivesKnownSourceReferenceState() => presentation,
    HistoricalArchivesInspectingCandidateState(:final inspectionOccurrence) =>
      HistoricalArchivesInspectingCandidateState(
        data: data,
        inspectionOccurrence: inspectionOccurrence,
      ),
    HistoricalArchivesInspectionFailedState(:final evidence) =>
      HistoricalArchivesInspectionFailedState(data: data, evidence: evidence),
    HistoricalArchivesReadyToAddState(
      :final evidence,
      :final lineageAdmission,
    ) =>
      HistoricalArchivesReadyToAddState(
        data: data,
        evidence: evidence,
        lineageAdmission: lineageAdmission,
      ),
    HistoricalArchivesExistingSourceState(
      :final facts,
      :final managementFailureDetail,
    ) =>
      HistoricalArchivesExistingSourceState(
        data: data,
        facts: facts,
        managementFailureDetail: managementFailureDetail,
      ),
    HistoricalArchivesImportingState(
      :final evidence,
      :final progress,
      :final lineageAdmission,
    ) =>
      HistoricalArchivesImportingState(
        data: data,
        evidence: evidence,
        progress: progress,
        lineageAdmission: lineageAdmission,
      ),
    HistoricalArchivesImportFailedState(
      :final evidence,
      :final progress,
      :final failureDetail,
      :final lineageAdmission,
    ) =>
      HistoricalArchivesImportFailedState(
        data: data,
        evidence: evidence,
        progress: progress,
        failureDetail: failureDetail,
        lineageAdmission: lineageAdmission,
      ),
    HistoricalArchivesRemovingState(:final facts, :final progress) =>
      HistoricalArchivesRemovingState(
        data: data,
        facts: facts,
        progress: progress,
      ),
    HistoricalArchivesRemovalFailedState(
      :final facts,
      :final progress,
      :final failureDetail,
    ) =>
      HistoricalArchivesRemovalFailedState(
        data: data,
        facts: facts,
        progress: progress,
        failureDetail: failureDetail,
      ),
  };
}

final class HistoricalArchivesFolderPreflightResult {
  const HistoricalArchivesFolderPreflightResult({
    required this.sourceIdentity,
    required this.preflight,
    required this.selectedFolderPath,
    required this.archiveRemovalTargetChatDbPath,
    required this.chatDbStatus,
    required this.attachmentsStatusLabel,
    required this.sourceLabel,
    required this.totalMessages,
    required this.totalChats,
    required this.totalHandles,
    required this.missingGuids,
    required this.earliestMessageUtc,
    required this.latestMessageUtc,
    required this.dryRunNewMessages,
    required this.dryRunDuplicateMessages,
    required this.dryRunComparableMessages,
    required this.preflightSummaryLines,
    required this.dryRunSummaryLines,
    required this.activityLog,
    required this.phases,
    this.dateRangeUnavailableReason,
    this.dryRunUnavailableReason,
  });

  final HistoricalArchiveSourceIdentity? sourceIdentity;
  final HistoricalArchivesPreflightViewModel preflight;
  final String selectedFolderPath;
  final String archiveRemovalTargetChatDbPath;
  final ArchiveSourceInspectionStatus chatDbStatus;
  final String attachmentsStatusLabel;
  final String sourceLabel;
  final int? totalMessages;
  final int? totalChats;
  final int? totalHandles;
  final int? missingGuids;
  final String? earliestMessageUtc;
  final String? latestMessageUtc;
  final int? dryRunNewMessages;
  final int? dryRunDuplicateMessages;
  final int? dryRunComparableMessages;
  final String? dateRangeUnavailableReason;
  final String? dryRunUnavailableReason;
  final List<String> preflightSummaryLines;
  final List<String> dryRunSummaryLines;
  final List<HistoricalArchivesLogEntryViewModel> activityLog;
  final List<HistoricalArchivesWorkflowPhaseViewModel> phases;

  String get chatDbStatusLabel => chatDbStatus.label;
}

final class HistoricalArchivesWorkflowPanelViewModel {
  const HistoricalArchivesWorkflowPanelViewModel({
    this.sourceType = HistoricalArchiveSourceType.messagesFolders,
    required this.statusLabel,
    required this.summaryText,
    required this.executionGate,
    required this.preflight,
    required this.selectedFolderPath,
    required this.chatDbStatusLabel,
    required this.attachmentsStatusLabel,
    required this.sourceLabel,
    required this.preflightSummaryLines,
    required this.dryRunSummaryLines,
    required this.importSafetySummaryLines,
    required this.importButtonEnabled,
    required this.importButtonDetail,
    required this.archiveRemovalTargetChatDbPath,
    required this.archiveManagementSummaryLines,
    required this.removeImportedArchiveDataEnabled,
    required this.removeImportedArchiveDataDetail,
    required this.activityLog,
    required this.resultSummaryLines,
    required this.phases,
    required this.centerPageTitleVisible,
    this.isHub = false,
    this.narratorPresentation,
    this.existingSourcePresentation,
  });

  final HistoricalArchiveSourceType sourceType;
  final String statusLabel;
  final String summaryText;
  final HistoricalArchivesExecutionGateViewModel executionGate;
  final HistoricalArchivesPreflightViewModel preflight;
  final String? selectedFolderPath;
  final String chatDbStatusLabel;
  final String attachmentsStatusLabel;
  final String sourceLabel;
  final List<String> preflightSummaryLines;
  final List<String> dryRunSummaryLines;
  final List<String> importSafetySummaryLines;
  final bool importButtonEnabled;
  final String importButtonDetail;
  final String? archiveRemovalTargetChatDbPath;
  final List<String> archiveManagementSummaryLines;
  final bool removeImportedArchiveDataEnabled;
  final String removeImportedArchiveDataDetail;
  final List<HistoricalArchivesLogEntryViewModel> activityLog;
  final List<String> resultSummaryLines;
  final List<HistoricalArchivesWorkflowPhaseViewModel> phases;
  final bool centerPageTitleVisible;
  final bool isHub;
  final HistoricalArchivesNarratorPresentationViewModel? narratorPresentation;
  final HistoricalArchivesExistingSourcePresentationViewModel?
  existingSourcePresentation;
}

const _historicalArchivesHubPresentationData = HistoricalArchivesPresentationData(
  preflight: HistoricalArchivesPreflightViewModel(
    status: HistoricalArchivesPreflightStatus.waitingForFolder,
    statusLabel: 'Waiting for folder selection',
    detail:
        'Choose an older Messages folder to unlock preflight checks and dry-run estimates.',
  ),
  selectedFolderPath: '',
  archiveRemovalTargetChatDbPath: '',
  chatDbStatus: ArchiveSourceInspectionStatus.unavailable,
  attachmentsStatusLabel: 'Not checked yet',
  sourceLabel: 'Not proposed yet',
  preflightSummaryLines: [
    'Total messages: waiting for folder selection',
    'Total chats: waiting for folder selection',
    'Total handles: waiting for folder selection',
    'Rows with missing GUIDs: waiting for folder selection',
    'Earliest message: waiting for folder selection',
    'Latest message: waiting for folder selection',
    'Likely already imported: waiting for folder selection',
    'Likely new rows: waiting for folder selection',
  ],
  dryRunSummaryLines: [
    'Estimated new messages: waiting for preflight',
    'Estimated duplicates: waiting for preflight',
  ],
  importSafetySummaryLines: [
    'Waiting for preflight before archive import safety can be confirmed.',
  ],
  resultSummaryLines: [
    'No archive import has run yet.',
    'Imported archive messages will become visible after MessageLens finishes preparing them.',
  ],
  activityLog: [
    HistoricalArchivesLogEntryViewModel(
      label: 'Archive workflow ready',
      message:
          'Historical Archives is visible, but no folder has been selected yet.',
    ),
    HistoricalArchivesLogEntryViewModel(
      label: 'Waiting',
      message:
          'Choose a folder to begin preflight evidence and dry-run estimation.',
    ),
  ],
  phases: [
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Reading archive source',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for a folder to be selected.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Preparing archive records',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'No archive source has started yet.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Importing archive messages',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Archive import starts after you run Begin Import.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Preparing messages for browsing',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Browsing preparation begins after archive import succeeds.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Post-projection rebuild steps are still waiting.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing shared evidence surfaces',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail:
          'Shared message evidence surfaces are unchanged until refresh completes.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'No archive workflow has completed yet.',
    ),
  ],
);

HistoricalArchivesWorkflowState buildInitialHistoricalArchivesWorkflowState({
  HistoricalArchiveSourceType sourceType =
      HistoricalArchiveSourceType.messagesFolders,
}) {
  return HistoricalArchivesWorkflowState(
    presentation: HistoricalArchivesHubState(sourceType: sourceType),
  );
}

@Riverpod(keepAlive: true)
class HistoricalArchivesWorkflow extends _$HistoricalArchivesWorkflow {
  var _nextInspectionOccurrence = 0;
  var _nextReferenceOccurrence = 0;
  var _nextDuplicateNoticeOccurrence = 0;
  var _nextInvalidFolderNoticeOccurrence = 0;
  var _nextLineageNoticeOccurrence = 0;
  var _nextImportSuccessNoticeOccurrence = 0;
  var _nextMessageLensNoticeOccurrence = 0;
  var _nextMessageLensRecoveryOccurrence = 0;
  var _presentationSessionOccurrence = 0;
  Timer? _referenceClearTimer;

  @override
  HistoricalArchivesWorkflowState build() {
    ref.onDispose(() {
      _referenceClearTimer?.cancel();
    });
    ref.listen(activeSidebarModeProvider, (previous, next) {
      if (previous == SidebarMode.settings && next != SidebarMode.settings) {
        resetPresentationContext();
      }
    });
    ref.listen(
      sidebarFlowProvider.select((value) => value.persistentSettingsContext),
      (previous, next) {
        if (previous == SettingsMenuActionId.historicalArchives &&
            next != SettingsMenuActionId.historicalArchives) {
          resetPresentationContext();
        }
      },
    );
    return buildInitialHistoricalArchivesWorkflowState();
  }

  Future<void> chooseMessagesFolder() async {
    final presentationSessionOccurrence = _presentationSessionOccurrence;
    final folderChooser = ref.read(historicalArchiveFolderChooserProvider);
    final folderPath = await folderChooser.chooseMessagesFolder();
    if (folderPath == null ||
        presentationSessionOccurrence != _presentationSessionOccurrence) {
      return;
    }

    await loadFolder(
      folderPath: folderPath,
      presentationSessionOccurrence: presentationSessionOccurrence,
    );
  }

  Future<void> chooseMessageLensFolder({
    Future<void> Function()? waitForInspectionPresentation,
  }) async {
    if (state.sourceType !=
        HistoricalArchiveSourceType.messageLensDataFolders) {
      return;
    }
    final presentationSessionOccurrence = _presentationSessionOccurrence;
    final folderChooser = ref.read(historicalArchiveFolderChooserProvider);
    final folderPath = await folderChooser.chooseMessageLensFolder();
    if (folderPath == null ||
        presentationSessionOccurrence != _presentationSessionOccurrence ||
        state.sourceType !=
            HistoricalArchiveSourceType.messageLensDataFolders) {
      return;
    }
    await loadMessageLensFolder(
      folderPath: folderPath,
      presentationSessionOccurrence: presentationSessionOccurrence,
      waitForInspectionPresentation: waitForInspectionPresentation,
    );
  }

  void selectSourceType(HistoricalArchiveSourceType sourceType) {
    if (!state.sourceTypeSwitchEnabled || state.sourceType == sourceType) {
      return;
    }
    resetPresentationContext(sourceType: sourceType);
  }

  Future<void> loadMessageLensFolder({
    required String folderPath,
    int? presentationSessionOccurrence,
    Future<void> Function()? waitForInspectionPresentation,
  }) async {
    if (state.sourceType !=
        HistoricalArchiveSourceType.messageLensDataFolders) {
      return;
    }
    final expectedSession =
        presentationSessionOccurrence ?? _presentationSessionOccurrence;
    _nextInspectionOccurrence += 1;
    final inspectionOccurrence = _nextInspectionOccurrence;
    state = HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesMessageLensInspectingState(
        folderPath: folderPath,
        inspectionOccurrence: inspectionOccurrence,
        progress: const MessageLensHistoricalArchivePreflightProgress(
          phase: MessageLensHistoricalArchivePreflightPhase
              .structuralQualification,
          completedUnits: 0,
          totalUnits: 1,
        ),
      ),
    );
    if (waitForInspectionPresentation != null) {
      await waitForInspectionPresentation();
      if (!_ownsMessageLensInspection(
        presentationSessionOccurrence: expectedSession,
        inspectionOccurrence: inspectionOccurrence,
      )) {
        return;
      }
    }

    final MessageLensHistoricalArchivePreflightResult result;
    try {
      final preflight = await ref.read(
        messageLensHistoricalArchivePreflightProvider.future,
      );
      result = await preflight.inspect(
        folderPath: folderPath,
        onProgress: (progress) {
          if (!_ownsMessageLensInspection(
            presentationSessionOccurrence: expectedSession,
            inspectionOccurrence: inspectionOccurrence,
          )) {
            return;
          }
          state = HistoricalArchivesWorkflowState(
            presentation: HistoricalArchivesMessageLensInspectingState(
              folderPath: folderPath,
              inspectionOccurrence: inspectionOccurrence,
              progress: progress,
            ),
          );
        },
        isCancelled: () => !_ownsMessageLensInspection(
          presentationSessionOccurrence: expectedSession,
          inspectionOccurrence: inspectionOccurrence,
        ),
      );
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message: 'MessageLens archive preflight could not be completed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!_ownsMessageLensInspection(
        presentationSessionOccurrence: expectedSession,
        inspectionOccurrence: inspectionOccurrence,
      )) {
        return;
      }
      _showMessageLensNotice(
        kind: HistoricalArchivesMessageLensNoticeKind.incompatibleArchive,
        detail: error.toString(),
      );
      return;
    }

    if (!_ownsMessageLensInspection(
      presentationSessionOccurrence: expectedSession,
      inspectionOccurrence: inspectionOccurrence,
    )) {
      return;
    }
    switch (result) {
      case MessageLensHistoricalArchiveInvalidFolder():
        _showMessageLensNotice(
          kind: HistoricalArchivesMessageLensNoticeKind.invalidFolder,
        );
      case MessageLensHistoricalArchiveIncompatible(:final detail):
        _showMessageLensNotice(
          kind: HistoricalArchivesMessageLensNoticeKind.incompatibleArchive,
          detail: detail,
        );
      case MessageLensHistoricalArchiveLineageRejected(:final admission):
        _showMessageLensNotice(
          kind:
              admission.status ==
                  MessagesLineageAdmissionStatus.contradictoryLineage
              ? HistoricalArchivesMessageLensNoticeKind.contradictoryLineage
              : HistoricalArchivesMessageLensNoticeKind.insufficientLineage,
        );
      case MessageLensHistoricalArchivePreflightCancelled():
        return;
      case MessageLensHistoricalArchiveReady(:final attachmentPreflight):
        _logMessageLensAttachmentPreflight(ref, attachmentPreflight);
        if (attachmentPreflight.recoverableCount == 0) {
          _showMessageLensNotice(
            kind: HistoricalArchivesMessageLensNoticeKind.nothingRecoverable,
          );
          return;
        }
        state = HistoricalArchivesWorkflowState(
          presentation: HistoricalArchivesMessageLensReadyState(
            evidence: result,
          ),
        );
    }
  }

  bool _ownsMessageLensInspection({
    required int presentationSessionOccurrence,
    required int inspectionOccurrence,
  }) {
    final presentation = state.presentation;
    return presentationSessionOccurrence == _presentationSessionOccurrence &&
        presentation is HistoricalArchivesMessageLensInspectingState &&
        presentation.inspectionOccurrence == inspectionOccurrence;
  }

  Future<void> recoverMessageLensAttachments({
    Future<void> Function()? waitForOperationPresentation,
  }) async {
    final ready = state.presentation;
    if (ready is! HistoricalArchivesMessageLensReadyState) {
      return;
    }
    final recoverableCandidates = ready.evidence.attachmentPreflight.candidates
        .where(
          (candidate) =>
              candidate.classification ==
              MessageLensAttachmentRecoveryClassification.recoverable,
        )
        .toList(growable: false);
    if (recoverableCandidates.isEmpty) {
      return;
    }

    final presentationSessionOccurrence = _presentationSessionOccurrence;
    _nextMessageLensRecoveryOccurrence += 1;
    final operationOccurrence = _nextMessageLensRecoveryOccurrence;
    var progress = MessageLensAttachmentRecoveryBatchProgress(
      stage: MessageLensAttachmentRecoveryBatchStage.verifyingDonorPayloads,
      totalAttachments: recoverableCandidates.length,
      verifiedAttachments: 0,
      processedAttachments: 0,
      recoveredAttachments: 0,
      totalBytes: ready.evidence.attachmentPreflight.recoverableBytes,
      verifiedBytes: 0,
      copiedBytes: 0,
      terminallyVerifiedAttachments: 0,
    );
    state = HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesMessageLensRecoveringState(
        evidence: ready.evidence,
        operationOccurrence: operationOccurrence,
        progress: progress,
      ),
    );
    if (waitForOperationPresentation != null) {
      await waitForOperationPresentation();
      if (!_ownsMessageLensRecovery(
        presentationSessionOccurrence: presentationSessionOccurrence,
        operationOccurrence: operationOccurrence,
      )) {
        return;
      }
    }

    try {
      final executor = await ref.read(
        messageLensAttachmentRecoveryBatchExecutorProvider(
          donorArchiveRoot: ready.evidence.donor.rootPath,
        ).future,
      );
      final result = await ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .runWithCapability<MessageLensAttachmentRecoveryBatchResult>(
            operation: ArchiveMutationOperation.attachmentReconciliation,
            ownerLabel: 'historical-archives-attachment-recovery',
            action: (capability) => executor.execute(
              mutationCapability: capability,
              donor: ready.evidence.donor,
              lineageAdmission: ready.evidence.lineageAdmission,
              preflight: ready.evidence.attachmentPreflight,
              preflightApprovedCandidates: recoverableCandidates,
              onProgress: (nextProgress) {
                progress = nextProgress;
                if (!_ownsMessageLensRecovery(
                  presentationSessionOccurrence: presentationSessionOccurrence,
                  operationOccurrence: operationOccurrence,
                )) {
                  return;
                }
                state = HistoricalArchivesWorkflowState(
                  presentation: HistoricalArchivesMessageLensRecoveringState(
                    evidence: ready.evidence,
                    operationOccurrence: operationOccurrence,
                    progress: nextProgress,
                  ),
                );
              },
            ),
          );
      if (!_ownsMessageLensRecovery(
        presentationSessionOccurrence: presentationSessionOccurrence,
        operationOccurrence: operationOccurrence,
      )) {
        return;
      }
      await Future<void>.delayed(
        historicalArchivesTerminalCompletedDwellDuration,
      );
      if (!_ownsMessageLensRecovery(
        presentationSessionOccurrence: presentationSessionOccurrence,
        operationOccurrence: operationOccurrence,
      )) {
        return;
      }
      _showMessageLensNotice(
        kind: result.fullyRecovered
            ? HistoricalArchivesMessageLensNoticeKind.recoveryComplete
            : HistoricalArchivesMessageLensNoticeKind.recoveryFinished,
        recoveredCount: result.recoveredCount,
        couldNotRecoverCount: result.couldNotRecoverCount,
      );
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message: 'MessageLens attachment recovery could not be completed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!_ownsMessageLensRecovery(
        presentationSessionOccurrence: presentationSessionOccurrence,
        operationOccurrence: operationOccurrence,
      )) {
        return;
      }
      state = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesMessageLensRecoveryFailedState(
          evidence: ready.evidence,
          progress: progress,
          failureDetail: error.toString(),
        ),
      );
    }
  }

  bool _ownsMessageLensRecovery({
    required int presentationSessionOccurrence,
    required int operationOccurrence,
  }) {
    final presentation = state.presentation;
    return presentationSessionOccurrence == _presentationSessionOccurrence &&
        presentation is HistoricalArchivesMessageLensRecoveringState &&
        presentation.operationOccurrence == operationOccurrence;
  }

  void _showMessageLensNotice({
    required HistoricalArchivesMessageLensNoticeKind kind,
    String? detail,
    int? recoveredCount,
    int? couldNotRecoverCount,
  }) {
    _nextMessageLensNoticeOccurrence += 1;
    state = HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesMessageLensNoticeState(
        notice: HistoricalArchivesMessageLensNotice(
          kind: kind,
          noticeOccurrence: _nextMessageLensNoticeOccurrence,
          presentationSessionOccurrence: _presentationSessionOccurrence,
          detail: detail,
          recoveredCount: recoveredCount,
          couldNotRecoverCount: couldNotRecoverCount,
        ),
      ),
    );
  }

  Future<void> loadFolder({
    required String folderPath,
    int? presentationSessionOccurrence,
  }) async {
    final expectedPresentationSessionOccurrence =
        presentationSessionOccurrence ?? _presentationSessionOccurrence;
    _nextInspectionOccurrence += 1;
    final inspectionOccurrence = _nextInspectionOccurrence;
    state = HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesInspectingCandidateState(
        inspectionOccurrence: inspectionOccurrence,
        data: HistoricalArchivesPresentationData(
          preflight: const HistoricalArchivesPreflightViewModel(
            status: HistoricalArchivesPreflightStatus.running,
            statusLabel: 'Preflight running',
            detail:
                'Checking archive structure and reading source message counts.',
          ),
          selectedFolderPath: folderPath,
          archiveRemovalTargetChatDbPath: path.join(folderPath, 'chat.db'),
          chatDbStatus: ArchiveSourceInspectionStatus.unavailable,
          attachmentsStatusLabel: 'Checking...',
          sourceLabel: path.basename(folderPath),
          preflightSummaryLines:
              _historicalArchivesHubPresentationData.preflightSummaryLines,
          dryRunSummaryLines:
              _historicalArchivesHubPresentationData.dryRunSummaryLines,
          importSafetySummaryLines:
              _historicalArchivesHubPresentationData.importSafetySummaryLines,
          resultSummaryLines:
              _historicalArchivesHubPresentationData.resultSummaryLines,
          activityLog: [
            HistoricalArchivesLogEntryViewModel(
              label: 'Reading archive…',
              message: 'Inspecting ${path.basename(folderPath)}.',
            ),
          ],
          phases: _runningPreflightPhases(),
        ),
      ),
    );

    ArchiveSourceInspector? archiveSourceInspector;
    HistoricalArchiveSources? archiveSources;
    HistoricalArchiveImportedSourceLookup? importedSourceLookup;
    try {
      archiveSourceInspector = await ref.read(
        archiveSourceInspectorProvider.future,
      );
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message: 'Archive source inspector unavailable during preflight',
        error: error,
        stackTrace: stackTrace,
      );
    }
    try {
      archiveSources = await ref.read(historicalArchiveSourcesProvider.future);
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message:
            'Historical archive sources boundary unavailable during preflight',
        error: error,
        stackTrace: stackTrace,
      );
    }
    try {
      importedSourceLookup = await ref.read(
        historicalArchiveImportedSourceLookupProvider.future,
      );
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message:
            'Historical archive imported-source lookup unavailable during preflight',
        error: error,
        stackTrace: stackTrace,
      );
    }

    final result = await preflightHistoricalArchivesFolder(
      folderPath: folderPath,
      archiveSourceInspector: archiveSourceInspector,
    );

    final importedSourceMatch = await _findImportedSourceMatch(
      lookup: importedSourceLookup,
      result: result,
    );

    if (!_ownsCandidateInspection(
      presentationSessionOccurrence: expectedPresentationSessionOccurrence,
      inspectionOccurrence: inspectionOccurrence,
    )) {
      return;
    }

    if (_isInvalidFolderQualificationFailure(result)) {
      _nextInvalidFolderNoticeOccurrence += 1;
      state = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesInvalidNoticeState(
          notice: HistoricalArchivesInvalidFolderNotice(
            noticeOccurrence: _nextInvalidFolderNoticeOccurrence,
            presentationSessionOccurrence: _presentationSessionOccurrence,
          ),
        ),
      );
      return;
    }

    if (importedSourceMatch != null &&
        await _hasSuccessfulImportMetadata(
          archiveSources: archiveSources,
          identity: importedSourceMatch.identity,
        )) {
      _nextDuplicateNoticeOccurrence += 1;
      state = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesDuplicateNoticeState(
          notice: HistoricalArchivesDuplicateFolderNotice(
            identity: importedSourceMatch.identity,
            noticeOccurrence: _nextDuplicateNoticeOccurrence,
            presentationSessionOccurrence: _presentationSessionOccurrence,
          ),
        ),
      );
      return;
    }

    MessagesLineageAdmission lineageAdmission;
    try {
      final authority = await ref.read(
        messagesLineageAdmissionAuthorityProvider.future,
      );
      lineageAdmission = await authority.verifyMacMessagesCandidate(
        candidateChatDatabasePath: result.archiveRemovalTargetChatDbPath,
      );
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message: 'Messages-lineage admission could not be completed',
        error: error,
        stackTrace: stackTrace,
      );
      lineageAdmission = MessagesLineageAdmission.fromEvidence(
        const MessagesLineageEvidence(
          candidateRecordCount: 0,
          usableCandidateIdentityCount: 0,
          blankCandidateGuidCount: 0,
          inconsistentCandidateIdentityCount: 0,
          duplicateCandidateRowIdCount: 0,
          currentRowsInCandidateRangeCount: 0,
          comparableCount: 0,
          matchingCount: 0,
          contradictionCount: 0,
          missingCurrentRowCount: 0,
          unusableCurrentGuidCount: 0,
          matchingRowIdBandCount: 0,
          candidateSourceShapeIsCoherent: false,
          currentSourceShapeIsCoherent: false,
        ),
      );
    }

    if (!_ownsCandidateInspection(
      presentationSessionOccurrence: expectedPresentationSessionOccurrence,
      inspectionOccurrence: inspectionOccurrence,
    )) {
      return;
    }

    if (lineageAdmission is! SameMessagesLineageAdmission) {
      _nextLineageNoticeOccurrence += 1;
      state = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesLineageNoticeState(
          notice: HistoricalArchivesLineageNotice(
            status: lineageAdmission.status,
            noticeOccurrence: _nextLineageNoticeOccurrence,
            presentationSessionOccurrence: _presentationSessionOccurrence,
          ),
        ),
      );
      return;
    }

    if (!_ownsCandidateInspection(
      presentationSessionOccurrence: expectedPresentationSessionOccurrence,
      inspectionOccurrence: inspectionOccurrence,
    )) {
      return;
    }

    await _persistHistoricalArchiveSourceIfEligible(
      archiveSources: archiveSources,
      result: result,
    );

    if (!_ownsCandidateInspection(
      presentationSessionOccurrence: expectedPresentationSessionOccurrence,
      inspectionOccurrence: inspectionOccurrence,
    )) {
      return;
    }

    state = _workflowStateFromPreflightResult(
      result,
      lineageAdmission: lineageAdmission,
    );
  }

  bool _ownsCandidateInspection({
    required int presentationSessionOccurrence,
    required int inspectionOccurrence,
  }) {
    final presentation = state.presentation;
    return presentationSessionOccurrence == _presentationSessionOccurrence &&
        presentation is HistoricalArchivesInspectingCandidateState &&
        presentation.inspectionOccurrence == inspectionOccurrence;
  }

  Future<void> showKnownSource({
    required HistoricalArchiveSourceIdentity identity,
  }) async {
    final presentationSessionOccurrence = _presentationSessionOccurrence;
    final sources = await ref.read(
      historicalArchiveSourceMetadataProvider.future,
    );
    HistoricalArchiveSourceMetadata? source;
    for (final candidate in sources) {
      if (candidate.identity == identity) {
        source = candidate;
        break;
      }
    }
    if (source == null ||
        presentationSessionOccurrence != _presentationSessionOccurrence) {
      return;
    }

    HistoricalArchiveImportedSourceMatch? importedSourceMatch;
    try {
      final lookup = await ref.read(
        historicalArchiveImportedSourceLookupProvider.future,
      );
      importedSourceMatch = await lookup.findImportedSource(identity: identity);
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message:
            'Historical archive imported-source classification failed during known-source navigation',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (presentationSessionOccurrence != _presentationSessionOccurrence) {
      return;
    }

    if (importedSourceMatch == null) {
      resetPresentationContext();
      return;
    }

    state = _workflowStateFromKnownSourceMetadata(
      source,
      importedMessageCount: importedSourceMatch.importedMessageCount,
      selectedKnownSourceIdentity: identity,
    );
  }

  void clearSelection() {
    resetPresentationContext();
  }

  void cancelAddArchive() {
    if (state.presentation is! HistoricalArchivesInspectingCandidateState &&
        state.presentation is! HistoricalArchivesInspectionFailedState &&
        state.presentation is! HistoricalArchivesReadyToAddState &&
        state.presentation is! HistoricalArchivesMessageLensInspectingState &&
        state.presentation is! HistoricalArchivesMessageLensReadyState &&
        state.presentation
            is! HistoricalArchivesMessageLensRecoveryFailedState) {
      return;
    }
    resetPresentationContext();
  }

  void dismissDuplicateFolderNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    final presentation = state.presentation;
    if (presentation is! HistoricalArchivesDuplicateNoticeState) {
      return;
    }
    final notice = presentation.notice;
    if (notice.noticeOccurrence != noticeOccurrence ||
        notice.presentationSessionOccurrence != presentationSessionOccurrence ||
        _presentationSessionOccurrence != presentationSessionOccurrence) {
      return;
    }

    _referenceClearTimer?.cancel();
    _nextReferenceOccurrence += 1;
    final referenceOccurrence = _nextReferenceOccurrence;
    state = HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesKnownSourceReferenceState(
        reference: HistoricalArchivesKnownSourceReference(
          identity: notice.identity,
          referenceOccurrence: referenceOccurrence,
        ),
      ),
    );
    _referenceClearTimer = Timer(historicalArchivesReferenceLifetime, () {
      _clearKnownSourceReference(
        referenceOccurrence: referenceOccurrence,
        presentationSessionOccurrence: presentationSessionOccurrence,
      );
    });
  }

  void dismissInvalidFolderNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    final presentation = state.presentation;
    if (presentation is! HistoricalArchivesInvalidNoticeState) {
      return;
    }
    final notice = presentation.notice;
    if (notice.noticeOccurrence != noticeOccurrence ||
        notice.presentationSessionOccurrence != presentationSessionOccurrence ||
        _presentationSessionOccurrence != presentationSessionOccurrence) {
      return;
    }

    state = buildInitialHistoricalArchivesWorkflowState();
  }

  void dismissLineageNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    final presentation = state.presentation;
    if (presentation is! HistoricalArchivesLineageNoticeState) {
      return;
    }
    final notice = presentation.notice;
    if (notice.noticeOccurrence != noticeOccurrence ||
        notice.presentationSessionOccurrence != presentationSessionOccurrence ||
        _presentationSessionOccurrence != presentationSessionOccurrence) {
      return;
    }
    state = buildInitialHistoricalArchivesWorkflowState();
  }

  void dismissImportSuccessNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    final presentation = state.presentation;
    if (presentation is! HistoricalArchivesImportSuccessNoticeState) {
      return;
    }
    final notice = presentation.notice;
    if (notice.noticeOccurrence != noticeOccurrence ||
        notice.presentationSessionOccurrence != presentationSessionOccurrence ||
        _presentationSessionOccurrence != presentationSessionOccurrence) {
      return;
    }

    state = buildInitialHistoricalArchivesWorkflowState();
  }

  void dismissMessageLensNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    final presentation = state.presentation;
    if (presentation is! HistoricalArchivesMessageLensNoticeState) {
      return;
    }
    final notice = presentation.notice;
    if (notice.noticeOccurrence != noticeOccurrence ||
        notice.presentationSessionOccurrence != presentationSessionOccurrence ||
        _presentationSessionOccurrence != presentationSessionOccurrence) {
      return;
    }
    state = buildInitialHistoricalArchivesWorkflowState(
      sourceType: HistoricalArchiveSourceType.messageLensDataFolders,
    );
  }

  void resetPresentationContext({HistoricalArchiveSourceType? sourceType}) {
    final destinationSourceType = sourceType ?? state.sourceType;
    _presentationSessionOccurrence += 1;
    _referenceClearTimer?.cancel();
    _referenceClearTimer = null;
    if (state.presentation case HistoricalArchivesHubState(
      sourceType: final currentSourceType,
    ) when currentSourceType == destinationSourceType) {
      return;
    }
    state = buildInitialHistoricalArchivesWorkflowState(
      sourceType: destinationSourceType,
    );
  }

  void _clearKnownSourceReference({
    required int referenceOccurrence,
    required int presentationSessionOccurrence,
  }) {
    if (_presentationSessionOccurrence != presentationSessionOccurrence ||
        state.presentation is! HistoricalArchivesKnownSourceReferenceState ||
        (state.presentation as HistoricalArchivesKnownSourceReferenceState)
                .reference
                .referenceOccurrence !=
            referenceOccurrence) {
      return;
    }
    state = buildInitialHistoricalArchivesWorkflowState(
      sourceType: state.sourceType,
    );
    _referenceClearTimer = null;
  }

  Future<void> retrySelectedFolderInspection() async {
    final presentation = state.presentation;
    if (presentation is! HistoricalArchivesInspectionFailedState) {
      return;
    }

    await loadFolder(folderPath: presentation.data.selectedFolderPath);
  }

  Future<void> removeImportedArchiveDataForSelectedSource() async {
    final selectedPresentation = state.presentation;
    if (selectedPresentation is! HistoricalArchivesExistingSourceState) {
      _prependActivityLog(
        const HistoricalArchivesLogEntryViewModel(
          label: 'No selected imported folder',
          message:
              'Select a folder under Folders Already Added before removing it from MessageLens.',
        ),
      );
      return;
    }

    final selectedFolderPath = selectedPresentation.data.selectedFolderPath;
    final selectedSourceIdentity = selectedPresentation.facts.identity;
    final selectedSourceState = HistoricalArchivesExistingSourceState(
      data: selectedPresentation.data,
      facts: selectedPresentation.facts,
    );
    final removalPresentationSessionOccurrence = _presentationSessionOccurrence;
    const initialProgress = HistoricalArchiveRemovalProgress();

    final selectedChatDbPath = path.join(selectedFolderPath, 'chat.db');
    if (_isCurrentMacChatDbPath(
      selectedChatDbPath,
      currentMessagesDatabasePath: ref.read(currentMessagesSourcePathProvider),
    )) {
      _prependActivityLog(
        const HistoricalArchivesLogEntryViewModel(
          label: 'Current Messages source protected',
          message:
              'Remove Imported Archive Data refuses to target the live ~/Library/Messages/chat.db source. Choose an archive folder instead.',
        ),
      );
      return;
    }

    try {
      await ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .run<void>(
            operation: ArchiveMutationOperation.historicalArchiveRemoval,
            ownerLabel: _historicalArchivesTestingOwner,
            action: () async {
              state = HistoricalArchivesWorkflowState(
                presentation: HistoricalArchivesRemovingState(
                  data: selectedSourceState.data.copyWith(
                    preflight: const HistoricalArchivesPreflightViewModel(
                      status: HistoricalArchivesPreflightStatus.running,
                      statusLabel: 'Removing folder',
                      detail:
                          "Removing this folder's messages from MessageLens.",
                    ),
                    activityLog: [
                      HistoricalArchivesLogEntryViewModel(
                        label: 'Removing folder…',
                        message:
                            'Removing messages added from ${path.basename(selectedFolderPath)}.',
                      ),
                      ...selectedSourceState.data.activityLog,
                    ],
                    phases: _archiveRemovalPhases(initialProgress),
                  ),
                  facts: selectedSourceState.facts,
                  progress: initialProgress,
                ),
              );

              final removalService = await ref.read(
                sourceScopedArchiveGraphRemovalServiceProvider.future,
              );
              await removalService.removeArchiveSource(
                sourceIdentity: selectedSourceIdentity,
                onObservation: (observation) {
                  try {
                    _applyRemovalObservation(
                      observation,
                      sourceIdentity: selectedSourceIdentity,
                      presentationSessionOccurrence:
                          removalPresentationSessionOccurrence,
                    );
                  } catch (error, stackTrace) {
                    _logHistoricalArchivesWarning(
                      ref,
                      message:
                          'Historical archive removal progress could not be presented',
                      error: error,
                      stackTrace: stackTrace,
                    );
                  }
                },
              );
              _setRemovalStageStatus(
                stage: HistoricalArchiveRemovalStage.verifyingRemoval,
                status: HistoricalArchiveRemovalStageStatus.running,
                sourceIdentity: selectedSourceIdentity,
                presentationSessionOccurrence:
                    removalPresentationSessionOccurrence,
              );
              ref.read(messageDataVersionProvider.notifier).bump();

              final importedSourceLookup = await ref.read(
                historicalArchiveImportedSourceLookupProvider.future,
              );
              final remainingSource = await importedSourceLookup
                  .findImportedSource(identity: selectedSourceIdentity);
              if (!_ownsCurrentRemovalPresentation(
                sourceIdentity: selectedSourceIdentity,
                presentationSessionOccurrence:
                    removalPresentationSessionOccurrence,
              )) {
                return;
              }
              if (remainingSource != null) {
                _setRemovalStageStatus(
                  stage: HistoricalArchiveRemovalStage.verifyingRemoval,
                  status: HistoricalArchiveRemovalStageStatus.failed,
                  sourceIdentity: selectedSourceIdentity,
                  presentationSessionOccurrence:
                      removalPresentationSessionOccurrence,
                );
                final current = state.presentation;
                if (current is HistoricalArchivesRemovingState) {
                  state = state.copyWith(
                    presentation: HistoricalArchivesRemovalFailedState(
                      data: current.data,
                      facts: current.facts,
                      progress: current.progress,
                      failureDetail:
                          'The removal operation finished, but ${remainingSource.importedMessageCount} messages from this folder are still part of MessageLens.',
                    ),
                  );
                }
                return;
              }

              _setRemovalStageStatus(
                stage: HistoricalArchiveRemovalStage.verifyingRemoval,
                status: HistoricalArchiveRemovalStageStatus.succeeded,
                sourceIdentity: selectedSourceIdentity,
                presentationSessionOccurrence:
                    removalPresentationSessionOccurrence,
              );
            },
          );
      await _dwellOnCompletedRemovalThenReturnToHub(
        sourceIdentity: selectedSourceIdentity,
        presentationSessionOccurrence: removalPresentationSessionOccurrence,
      );
    } on ArchiveMutationDeniedException catch (error) {
      if (_presentationSessionOccurrence !=
              removalPresentationSessionOccurrence ||
          state.selectedKnownSourceIdentity != selectedSourceIdentity) {
        return;
      }
      state = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesExistingSourceState(
          data: selectedSourceState.data.copyWith(
            activityLog: [
              HistoricalArchivesLogEntryViewModel(
                label: 'Removal unavailable',
                message:
                    '${_describeExecutionOwnerLabel(error.currentOwner)} currently owns archive mutation authority.',
              ),
              ...selectedSourceState.data.activityLog,
            ],
          ),
          facts: selectedSourceState.facts,
          managementFailureDetail:
              'MessageLens could not remove this folder because another message-data operation is running. Its messages remain part of MessageLens.',
        ),
      );
    } catch (error) {
      final detail = 'Archive data removal failed: $error';
      ref.read(messageDataVersionProvider.notifier).bump();
      HistoricalArchiveImportedSourceMatch? remainingSource;
      var membershipWasVerified = false;
      try {
        final importedSourceLookup = await ref.read(
          historicalArchiveImportedSourceLookupProvider.future,
        );
        remainingSource = await importedSourceLookup.findImportedSource(
          identity: selectedSourceIdentity,
        );
        membershipWasVerified = true;
      } catch (lookupError, stackTrace) {
        _logHistoricalArchivesWarning(
          ref,
          message:
              'Historical archive membership could not be rechecked after removal failure',
          error: lookupError,
          stackTrace: stackTrace,
        );
      }
      if (!_ownsCurrentRemovalPresentation(
        sourceIdentity: selectedSourceIdentity,
        presentationSessionOccurrence: removalPresentationSessionOccurrence,
      )) {
        return;
      }
      final failedProgress = _failedCurrentRemovalProgress(
        state.removalProgress ?? initialProgress,
      );
      final durableTruthDetail = !membershipWasVerified
          ? 'MessageLens could not verify whether messages from this folder still remain.'
          : remainingSource == null
          ? 'Messages from this folder are no longer present, but MessageLens did not finish updating its browsing data.'
          : '${remainingSource.importedMessageCount} messages from this folder still remain in MessageLens.';
      final failureDetail = '$detail $durableTruthDetail';
      final current = state.presentation;
      if (current is HistoricalArchivesRemovingState ||
          current is HistoricalArchivesRemovalFailedState) {
        final currentData = switch (current) {
          HistoricalArchivesRemovingState(:final data) ||
          HistoricalArchivesRemovalFailedState(:final data) => data,
          _ => throw StateError('Expected removal presentation.'),
        };
        final data = currentData.copyWith(
          preflight: HistoricalArchivesPreflightViewModel(
            status: HistoricalArchivesPreflightStatus.failed,
            statusLabel: 'Folder removal failed',
            detail: failureDetail,
          ),
          activityLog: [
            HistoricalArchivesLogEntryViewModel(
              label: 'Archive removal failed',
              message: failureDetail,
            ),
            ...currentData.activityLog,
          ],
          phases: _archiveRemovalPhases(
            failedProgress,
            failureDetail: failureDetail,
          ),
        );
        final facts = current is HistoricalArchivesRemovingState
            ? current.facts
            : (current as HistoricalArchivesRemovalFailedState).facts;
        state = state.copyWith(
          presentation: HistoricalArchivesRemovalFailedState(
            data: data,
            facts: facts,
            progress: failedProgress,
            failureDetail: failureDetail,
          ),
        );
      }
    }
  }

  void _applyRemovalObservation(
    SourceScopedArchiveGraphRemovalObservation observation, {
    required HistoricalArchiveSourceIdentity sourceIdentity,
    required int presentationSessionOccurrence,
  }) {
    if (observation.transition ==
        SourceScopedArchiveGraphRemovalStageTransition.progressed) {
      final projectionProgress = observation.projectionProgress;
      if (projectionProgress != null) {
        _setRemovalGraphProjectionProgress(
          projectionProgress,
          sourceIdentity: sourceIdentity,
          presentationSessionOccurrence: presentationSessionOccurrence,
        );
      }
      return;
    }
    final stage = switch (observation.stage) {
      SourceScopedArchiveGraphRemovalStage.removingImportedFacts =>
        HistoricalArchiveRemovalStage.removingImportedMessages,
      SourceScopedArchiveGraphRemovalStage.rebuildingConversationGraph =>
        HistoricalArchiveRemovalStage.updatingMessageLensHistory,
    };
    final status = switch (observation.transition) {
      SourceScopedArchiveGraphRemovalStageTransition.started =>
        HistoricalArchiveRemovalStageStatus.running,
      SourceScopedArchiveGraphRemovalStageTransition.completed =>
        HistoricalArchiveRemovalStageStatus.succeeded,
      SourceScopedArchiveGraphRemovalStageTransition.skipped =>
        HistoricalArchiveRemovalStageStatus.skipped,
      SourceScopedArchiveGraphRemovalStageTransition.progressed =>
        throw StateError('Progress observations are handled separately.'),
    };
    _setRemovalStageStatus(
      stage: stage,
      status: status,
      sourceIdentity: sourceIdentity,
      presentationSessionOccurrence: presentationSessionOccurrence,
    );
  }

  void _setRemovalGraphProjectionProgress(
    SourceScopedArchiveGraphProjectionProgress projectionProgress, {
    required HistoricalArchiveSourceIdentity sourceIdentity,
    required int presentationSessionOccurrence,
  }) {
    if (!_ownsCurrentRemovalPresentation(
      sourceIdentity: sourceIdentity,
      presentationSessionOccurrence: presentationSessionOccurrence,
    )) {
      return;
    }
    final current = state.presentation as HistoricalArchivesRemovingState;
    final progress = current.progress.withGraphProjectionProgress(
      projectionProgress,
    );
    state = state.copyWith(
      presentation: HistoricalArchivesRemovingState(
        data: current.data.copyWith(phases: _archiveRemovalPhases(progress)),
        facts: current.facts,
        progress: progress,
      ),
    );
  }

  void _setRemovalStageStatus({
    required HistoricalArchiveRemovalStage stage,
    required HistoricalArchiveRemovalStageStatus status,
    required HistoricalArchiveSourceIdentity sourceIdentity,
    required int presentationSessionOccurrence,
  }) {
    if (!_ownsCurrentRemovalPresentation(
      sourceIdentity: sourceIdentity,
      presentationSessionOccurrence: presentationSessionOccurrence,
    )) {
      return;
    }
    final current = state.presentation as HistoricalArchivesRemovingState;
    final progress = current.progress.withStage(stage, status);
    state = state.copyWith(
      presentation: HistoricalArchivesRemovingState(
        data: current.data.copyWith(phases: _archiveRemovalPhases(progress)),
        facts: current.facts,
        progress: progress,
      ),
    );
  }

  bool _ownsCurrentRemovalPresentation({
    required HistoricalArchiveSourceIdentity sourceIdentity,
    required int presentationSessionOccurrence,
  }) {
    return _presentationSessionOccurrence == presentationSessionOccurrence &&
        state.presentation is HistoricalArchivesRemovingState &&
        (state.presentation as HistoricalArchivesRemovingState)
                .facts
                .identity ==
            sourceIdentity;
  }

  Future<void> beginImportForSelectedSource({
    Future<void> Function()? waitForOperationPresentation,
  }) async {
    final authorizedPresentation = state.presentation;
    final (
      candidateData,
      candidateEvidence,
      lineageAdmission,
    ) = switch (authorizedPresentation) {
      HistoricalArchivesReadyToAddState(
        :final data,
        :final evidence,
        :final lineageAdmission,
      ) =>
        (data, evidence, lineageAdmission),
      HistoricalArchivesImportFailedState(
        :final data,
        :final evidence,
        :final lineageAdmission,
      ) =>
        (data, evidence, lineageAdmission),
      _ => (null, null, null),
    };
    if (candidateData == null ||
        candidateEvidence == null ||
        lineageAdmission == null) {
      return;
    }

    final selectedFolderPath = candidateData.selectedFolderPath;

    final selectedChatDbPath = path.join(selectedFolderPath, 'chat.db');
    if (_isCurrentMacChatDbPath(
      selectedChatDbPath,
      currentMessagesDatabasePath: ref.read(currentMessagesSourcePathProvider),
    )) {
      _prependActivityLog(
        const HistoricalArchivesLogEntryViewModel(
          label: 'Current Messages source protected',
          message:
              'Historical Archives refuses to import the live ~/Library/Messages/chat.db source. Choose an archive folder instead.',
        ),
      );
      return;
    }

    final importPresentationSessionOccurrence = _presentationSessionOccurrence;
    const initialProgress = HistoricalArchiveImportProgress();
    state = HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesImportingState(
        data: candidateData.copyWith(
          preflight: const HistoricalArchivesPreflightViewModel(
            status: HistoricalArchivesPreflightStatus.running,
            statusLabel: 'Adding Messages folder',
            detail:
                'MessageLens is adding this folder and preparing its conversations for browsing.',
          ),
        ),
        evidence: candidateEvidence,
        progress: initialProgress,
        lineageAdmission: lineageAdmission,
      ),
    );

    // The authorization state is already true. The presentation boundary can
    // now wait for a painted operation frame before admitted database work.
    if (waitForOperationPresentation case final waitForPresentation?) {
      await waitForPresentation();
    } else {
      await Future<void>.delayed(Duration.zero);
    }

    if (!_ownsCurrentImportPresentation(
      presentationSessionOccurrence: importPresentationSessionOccurrence,
    )) {
      return;
    }

    try {
      await ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .run<void>(
            operation: ArchiveMutationOperation.historicalArchiveImport,
            ownerLabel: 'historical-archives-import',
            action: () async {
              final archiveGraphImportService = await ref.read(
                sourceScopedArchiveGraphImportServiceProvider.future,
              );
              final archiveSources = await ref.read(
                historicalArchiveSourcesProvider.future,
              );
              final archiveResult = await archiveGraphImportService
                  .importAndProject(
                    folderPath: selectedFolderPath,
                    sourceLabel: candidateData.sourceLabel,
                    onObservation: (observation) {
                      _applyImportObservation(
                        observation: observation,
                        presentationSessionOccurrence:
                            importPresentationSessionOccurrence,
                      );
                    },
                  );
              ref.read(messageDataVersionProvider.notifier).bump();

              _setImportStageStatus(
                stage: HistoricalArchiveImportStage.verifyingImport,
                status: HistoricalArchiveImportStageStatus.running,
                presentationSessionOccurrence:
                    importPresentationSessionOccurrence,
              );

              ArchiveSourceInspector? archiveSourceInspector;
              try {
                archiveSourceInspector = await ref.read(
                  archiveSourceInspectorProvider.future,
                );
              } catch (error, stackTrace) {
                _logHistoricalArchivesWarning(
                  ref,
                  message: 'Archive source inspector unavailable after import',
                  error: error,
                  stackTrace: stackTrace,
                );
              }

              final refreshedResult = await preflightHistoricalArchivesFolder(
                folderPath: selectedFolderPath,
                archiveSourceInspector: archiveSourceInspector,
              );
              if (refreshedResult.preflight.status !=
                      HistoricalArchivesPreflightStatus.completeReadyToImport ||
                  refreshedResult.chatDbStatus !=
                      ArchiveSourceInspectionStatus.readable) {
                throw StateError(
                  'Final source verification did not confirm a readable Messages archive.',
                );
              }

              final importedSourceLookup = await ref.read(
                historicalArchiveImportedSourceLookupProvider.future,
              );
              final sourceIdentity =
                  archiveResult.importResult.registration.identity;
              final importedSourceMatch = await importedSourceLookup
                  .findImportedSource(identity: sourceIdentity);
              if (importedSourceMatch == null ||
                  importedSourceMatch.importedMessageCount <= 0) {
                throw StateError(
                  'Final import verification found no imported messages for the archive source.',
                );
              }
              final importedMessageCount =
                  importedSourceMatch.importedMessageCount;

              final completedAtUtc = DateTime.now().toUtc().toIso8601String();
              await archiveSources.upsertSourceMetadata(
                HistoricalArchiveSourceMetadataUpdate(
                  identity: sourceIdentity,
                  sourceChatDb: selectedChatDbPath,
                  folderPath: selectedFolderPath,
                  sourceLabel: refreshedResult.sourceLabel,
                  chatDbStatusLabel: refreshedResult.chatDbStatusLabel,
                  attachmentsStatusLabel:
                      refreshedResult.attachmentsStatusLabel,
                  preflightStatusLabel: 'Imported successfully',
                  preflightDetail:
                      'Archive import completed and messages were prepared for browsing.',
                  totalMessages: refreshedResult.totalMessages,
                  totalChats: refreshedResult.totalChats,
                  totalHandles: refreshedResult.totalHandles,
                  missingGuids: refreshedResult.missingGuids,
                  earliestMessageUtc: refreshedResult.earliestMessageUtc,
                  latestMessageUtc: refreshedResult.latestMessageUtc,
                  dryRunNewMessages: refreshedResult.dryRunNewMessages,
                  dryRunDuplicateMessages:
                      refreshedResult.dryRunDuplicateMessages,
                  lastImportFinishedAtUtc: completedAtUtc,
                  lastImportSuccess: true,
                  lastImportedMessageCount: importedMessageCount,
                  updatedAtUtc: completedAtUtc,
                ),
              );
              ref.invalidate(historicalArchiveSourceMetadataProvider);
              _setImportStageStatus(
                stage: HistoricalArchiveImportStage.verifyingImport,
                status: HistoricalArchiveImportStageStatus.succeeded,
                presentationSessionOccurrence:
                    importPresentationSessionOccurrence,
              );
              ref.read(messageDataVersionProvider.notifier).bump();
              return;
            },
          );
      await _dwellOnCompletedImportThenReturnToHub(
        presentationSessionOccurrence: importPresentationSessionOccurrence,
      );
    } on ArchiveMutationDeniedException catch (error) {
      if (_ownsCurrentImportPresentation(
        presentationSessionOccurrence: importPresentationSessionOccurrence,
      )) {
        final restoredData = candidateData.copyWith(
          activityLog: [
            HistoricalArchivesLogEntryViewModel(
              label: 'Execution gate busy',
              message:
                  '${_describeExecutionOwnerLabel(error.currentOwner)} currently owns archive mutation authority. Archive import must wait.',
            ),
            ...candidateData.activityLog,
          ],
        );
        state = HistoricalArchivesWorkflowState(
          presentation: _withPresentationData(
            authorizedPresentation,
            restoredData,
          ),
        );
      }
    } catch (error, stackTrace) {
      final detail = 'Archive import failed: $error';
      final failedAtUtc = DateTime.now().toUtc().toIso8601String();
      try {
        final archiveSources = await ref.read(
          historicalArchiveSourcesProvider.future,
        );
        final evidence = candidateEvidence;
        await archiveSources.upsertSourceMetadata(
          HistoricalArchiveSourceMetadataUpdate(
            identity: _requireReadableSourceIdentity(evidence.sourceIdentity),
            sourceChatDb: selectedChatDbPath,
            folderPath: selectedFolderPath,
            sourceLabel: candidateData.sourceLabel,
            chatDbStatusLabel: candidateData.chatDbStatusLabel,
            attachmentsStatusLabel: candidateData.attachmentsStatusLabel,
            preflightStatusLabel: 'Import incomplete',
            preflightDetail: detail,
            totalMessages: evidence.totalMessages,
            totalChats: evidence.totalChats,
            totalHandles: evidence.totalHandles,
            missingGuids: evidence.missingGuids,
            earliestMessageUtc: evidence.earliestMessageUtc,
            latestMessageUtc: evidence.latestMessageUtc,
            dryRunNewMessages: evidence.dryRunNewMessages,
            dryRunDuplicateMessages: evidence.dryRunDuplicateMessages,
            lastImportFinishedAtUtc: failedAtUtc,
            lastImportSuccess: false,
            lastImportError: detail,
            updatedAtUtc: failedAtUtc,
          ),
        );
        ref.invalidate(historicalArchiveSourceMetadataProvider);
      } catch (metadataError, metadataStackTrace) {
        _logHistoricalArchivesWarning(
          ref,
          message: 'Unable to record incomplete archive import metadata',
          error: metadataError,
          stackTrace: metadataStackTrace,
        );
      }
      ref.read(messageDataVersionProvider.notifier).bump();
      if (_ownsCurrentImportPresentation(
        presentationSessionOccurrence: importPresentationSessionOccurrence,
      )) {
        final current = state.presentation;
        final progress = current is HistoricalArchivesImportingState
            ? current.progress
            : initialProgress;
        final failedProgress = _progressWithRunningImportStageFailed(progress);
        state = state.copyWith(
          presentation: HistoricalArchivesImportFailedState(
            data: candidateData.copyWith(
              preflight: HistoricalArchivesPreflightViewModel(
                status: HistoricalArchivesPreflightStatus.failed,
                statusLabel: 'Import incomplete',
                detail: detail,
              ),
            ),
            evidence: candidateEvidence,
            progress: failedProgress,
            failureDetail: detail,
            lineageAdmission: lineageAdmission,
          ),
        );
      }
      _logHistoricalArchivesWarning(
        ref,
        message: 'Historical archive import did not complete',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _applyImportObservation({
    required SourceScopedArchiveGraphImportObservation observation,
    required int presentationSessionOccurrence,
  }) {
    if (observation.transition ==
        SourceScopedArchiveGraphImportStageTransition.progressed) {
      final projectionProgress = observation.projectionProgress;
      if (observation.stage ==
              SourceScopedArchiveGraphImportStage.projectingConversationGraph &&
          projectionProgress != null) {
        _setGraphProjectionProgress(
          progress: projectionProgress,
          presentationSessionOccurrence: presentationSessionOccurrence,
        );
      }
      return;
    }

    final stage = switch (observation.stage) {
      SourceScopedArchiveGraphImportStage.importingSourceFacts =>
        HistoricalArchiveImportStage.addingMessages,
      SourceScopedArchiveGraphImportStage.projectingConversationGraph =>
        HistoricalArchiveImportStage.preparingConversations,
    };
    final status = switch (observation.transition) {
      SourceScopedArchiveGraphImportStageTransition.started =>
        HistoricalArchiveImportStageStatus.running,
      SourceScopedArchiveGraphImportStageTransition.completed =>
        HistoricalArchiveImportStageStatus.succeeded,
      SourceScopedArchiveGraphImportStageTransition.progressed =>
        throw StateError('Progress observations are handled separately.'),
    };
    _setImportStageStatus(
      stage: stage,
      status: status,
      presentationSessionOccurrence: presentationSessionOccurrence,
    );
  }

  void _setGraphProjectionProgress({
    required SourceScopedArchiveGraphProjectionProgress progress,
    required int presentationSessionOccurrence,
  }) {
    if (!_ownsCurrentImportPresentation(
      presentationSessionOccurrence: presentationSessionOccurrence,
    )) {
      return;
    }
    final current = state.presentation as HistoricalArchivesImportingState;
    final updatedProgress = current.progress.withGraphProjectionProgress(
      progress,
    );
    state = state.copyWith(
      presentation: HistoricalArchivesImportingState(
        data: current.data,
        evidence: current.evidence,
        progress: updatedProgress,
        lineageAdmission: current.lineageAdmission,
      ),
    );
  }

  void _setImportStageStatus({
    required HistoricalArchiveImportStage stage,
    required HistoricalArchiveImportStageStatus status,
    required int presentationSessionOccurrence,
  }) {
    if (!_ownsCurrentImportPresentation(
      presentationSessionOccurrence: presentationSessionOccurrence,
    )) {
      return;
    }
    final current = state.presentation as HistoricalArchivesImportingState;
    final progress = current.progress.withStage(stage, status);
    state = state.copyWith(
      presentation: HistoricalArchivesImportingState(
        data: current.data,
        evidence: current.evidence,
        progress: progress,
        lineageAdmission: current.lineageAdmission,
      ),
    );
  }

  bool _ownsCurrentImportPresentation({
    required int presentationSessionOccurrence,
  }) {
    return _presentationSessionOccurrence == presentationSessionOccurrence &&
        state.presentation is HistoricalArchivesImportingState;
  }

  HistoricalArchiveImportProgress _progressWithRunningImportStageFailed(
    HistoricalArchiveImportProgress progress,
  ) {
    for (final stage in HistoricalArchiveImportStage.values) {
      if (progress.statusFor(stage) ==
          HistoricalArchiveImportStageStatus.running) {
        return progress.withStage(
          stage,
          HistoricalArchiveImportStageStatus.failed,
        );
      }
    }
    return progress.withStage(
      HistoricalArchiveImportStage.addingMessages,
      HistoricalArchiveImportStageStatus.failed,
    );
  }

  Future<void> _dwellOnCompletedImportThenReturnToHub({
    required int presentationSessionOccurrence,
  }) async {
    if (!_ownsCurrentImportPresentation(
          presentationSessionOccurrence: presentationSessionOccurrence,
        ) ||
        state.importProgress?.isComplete != true) {
      return;
    }
    await Future<void>.delayed(
      historicalArchivesTerminalCompletedDwellDuration,
    );
    if (!_ownsCurrentImportPresentation(
          presentationSessionOccurrence: presentationSessionOccurrence,
        ) ||
        state.importProgress?.isComplete != true) {
      return;
    }
    _nextImportSuccessNoticeOccurrence += 1;
    state = HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesImportSuccessNoticeState(
        notice: HistoricalArchivesImportSuccessNotice(
          noticeOccurrence: _nextImportSuccessNoticeOccurrence,
          presentationSessionOccurrence: presentationSessionOccurrence,
        ),
      ),
    );
  }

  Future<void> _dwellOnCompletedRemovalThenReturnToHub({
    required HistoricalArchiveSourceIdentity sourceIdentity,
    required int presentationSessionOccurrence,
  }) async {
    if (!_ownsCurrentRemovalPresentation(
          sourceIdentity: sourceIdentity,
          presentationSessionOccurrence: presentationSessionOccurrence,
        ) ||
        state.removalProgress?.isComplete != true) {
      return;
    }
    await Future<void>.delayed(
      historicalArchivesTerminalCompletedDwellDuration,
    );
    if (!_ownsCurrentRemovalPresentation(
          sourceIdentity: sourceIdentity,
          presentationSessionOccurrence: presentationSessionOccurrence,
        ) ||
        state.removalProgress?.isComplete != true) {
      return;
    }
    resetPresentationContext();
  }

  void _prependActivityLog(HistoricalArchivesLogEntryViewModel entry) {
    final presentation = state.presentation;
    final data = presentation.data;
    if (data == null) {
      return;
    }
    state = state.copyWith(
      presentation: _withPresentationData(
        presentation,
        data.copyWith(activityLog: [entry, ...data.activityLog]),
      ),
    );
  }

  Future<HistoricalArchiveImportedSourceMatch?> _findImportedSourceMatch({
    required HistoricalArchiveImportedSourceLookup? lookup,
    required HistoricalArchivesFolderPreflightResult result,
  }) async {
    if (lookup == null ||
        result.chatDbStatus != ArchiveSourceInspectionStatus.readable ||
        result.sourceIdentity == null) {
      return null;
    }

    try {
      return await lookup.findImportedSource(identity: result.sourceIdentity!);
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message:
            'Historical archive imported-source classification failed during preflight',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<bool> _hasSuccessfulImportMetadata({
    required HistoricalArchiveSources? archiveSources,
    required HistoricalArchiveSourceIdentity identity,
  }) async {
    if (archiveSources == null) {
      return false;
    }
    try {
      final sources = await archiveSources.readKnownSources();
      return sources.any(
        (source) =>
            source.identity == identity && source.lastImportSuccess == true,
      );
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message:
            'Unable to verify finalized archive membership during folder inspection',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> _persistHistoricalArchiveSourceIfEligible({
    required HistoricalArchiveSources? archiveSources,
    required HistoricalArchivesFolderPreflightResult result,
  }) async {
    if (archiveSources == null) {
      return;
    }
    if (result.chatDbStatus != ArchiveSourceInspectionStatus.readable) {
      return;
    }
    final sourceIdentity = result.sourceIdentity;
    if (sourceIdentity == null) {
      throw StateError('Readable archive source has no canonical identity.');
    }

    await archiveSources.upsertSourceMetadata(
      HistoricalArchiveSourceMetadataUpdate(
        identity: sourceIdentity,
        sourceChatDb: result.archiveRemovalTargetChatDbPath,
        folderPath: result.selectedFolderPath,
        sourceLabel: result.sourceLabel,
        chatDbStatusLabel: result.chatDbStatusLabel,
        attachmentsStatusLabel: result.attachmentsStatusLabel,
        preflightStatusLabel: result.preflight.statusLabel,
        preflightDetail: result.preflight.detail,
        totalMessages: result.totalMessages,
        totalChats: result.totalChats,
        totalHandles: result.totalHandles,
        missingGuids: result.missingGuids,
        earliestMessageUtc: result.earliestMessageUtc,
        latestMessageUtc: result.latestMessageUtc,
        dryRunNewMessages: result.dryRunNewMessages,
        dryRunDuplicateMessages: result.dryRunDuplicateMessages,
        updatedAtUtc: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }
}

@riverpod
HistoricalArchivesWorkflowPanelViewModel historicalArchivesWorkflowPanelModel(
  Ref ref,
) {
  final executionGateState = ref.watch(archiveMutationCoordinatorProvider);
  final isMaintenanceLocked = ref.watch(dbMaintenanceLockProvider);
  final workflowState = ref.watch(historicalArchivesWorkflowProvider);
  final currentMessagesDatabasePath = ref.watch(
    currentMessagesSourcePathProvider,
  );

  return buildHistoricalArchivesWorkflowPanelModel(
    executionGateState: executionGateState,
    isMaintenanceLocked: isMaintenanceLocked,
    workflowState: workflowState,
    currentMessagesDatabasePath: currentMessagesDatabasePath,
  );
}

HistoricalArchivesWorkflowPanelViewModel
buildHistoricalArchivesWorkflowPanelModel({
  required ArchiveMutationCoordinatorState executionGateState,
  required bool isMaintenanceLocked,
  required HistoricalArchivesWorkflowState workflowState,
  required String currentMessagesDatabasePath,
}) {
  final executionGate = _buildExecutionGateViewModel(
    executionGateState: executionGateState,
    isMaintenanceLocked: isMaintenanceLocked,
  );

  final statusLabel = switch (executionGate.status) {
    HistoricalArchivesExecutionGateStatus.available => _availableStatusLabel(
      workflowState,
    ),
    HistoricalArchivesExecutionGateStatus.busy => 'Execution Gate Busy',
    HistoricalArchivesExecutionGateStatus.blocked => 'Execution Gate Blocked',
  };

  final summaryText = switch (executionGate.status) {
    HistoricalArchivesExecutionGateStatus.available => _availableSummaryText(
      workflowState,
    ),
    HistoricalArchivesExecutionGateStatus.busy =>
      'MessageLens is already importing or preparing message data. Historical Archives stays visible so you can inspect the workflow, but import cannot begin until the current task finishes.',
    HistoricalArchivesExecutionGateStatus.blocked =>
      'Message data maintenance is currently blocking new archive work. Historical Archives remains visible, but import cannot begin until maintenance completes and the execution gate becomes available again.',
  };

  final importButtonDetail = switch (executionGate.status) {
    HistoricalArchivesExecutionGateStatus.available =>
      _availableImportButtonDetail(
        workflowState,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      ),
    HistoricalArchivesExecutionGateStatus.busy =>
      'Import is unavailable because ${_describeExecutionOwnerPhrase(executionGateState.ownerLabel)} currently owns archive mutation authority.',
    HistoricalArchivesExecutionGateStatus.blocked =>
      'Import is unavailable while reset or another maintenance operation is holding the message-data lock.',
  };

  final importButtonEnabled = _importButtonEnabled(
    executionGate: executionGate,
    workflowState: workflowState,
    currentMessagesDatabasePath: currentMessagesDatabasePath,
  );

  return HistoricalArchivesWorkflowPanelViewModel(
    sourceType: workflowState.sourceType,
    statusLabel: statusLabel,
    summaryText: summaryText,
    executionGate: executionGate,
    preflight: workflowState.preflight,
    selectedFolderPath: workflowState.selectedFolderPath,
    chatDbStatusLabel: workflowState.chatDbStatusLabel,
    attachmentsStatusLabel: workflowState.attachmentsStatusLabel,
    sourceLabel: workflowState.sourceLabel,
    preflightSummaryLines: workflowState.preflightSummaryLines,
    dryRunSummaryLines: workflowState.dryRunSummaryLines,
    importSafetySummaryLines: _importSafetySummaryLines(
      workflowState,
      currentMessagesDatabasePath: currentMessagesDatabasePath,
    ),
    importButtonEnabled: importButtonEnabled,
    importButtonDetail: importButtonDetail,
    archiveRemovalTargetChatDbPath:
        workflowState.archiveRemovalTargetChatDbPath,
    archiveManagementSummaryLines: _archiveManagementSummaryLines(
      workflowState,
    ),
    removeImportedArchiveDataEnabled: _removeImportedArchiveDataEnabled(
      executionGate: executionGate,
      workflowState: workflowState,
      currentMessagesDatabasePath: currentMessagesDatabasePath,
    ),
    removeImportedArchiveDataDetail: _removeImportedArchiveDataDetail(
      executionGateState: executionGateState,
      isMaintenanceLocked: isMaintenanceLocked,
      workflowState: workflowState,
      currentMessagesDatabasePath: currentMessagesDatabasePath,
    ),
    activityLog: _buildActivityLog(
      executionGateState: executionGateState,
      isMaintenanceLocked: isMaintenanceLocked,
      workflowState: workflowState,
    ),
    resultSummaryLines: workflowState.resultSummaryLines,
    phases: workflowState.phases,
    centerPageTitleVisible: switch (workflowState.presentation) {
      HistoricalArchivesInspectingCandidateState() ||
      HistoricalArchivesMessageLensInspectingState() ||
      HistoricalArchivesMessageLensReadyState() ||
      HistoricalArchivesMessageLensRecoveringState() ||
      HistoricalArchivesMessageLensRecoveryFailedState() ||
      HistoricalArchivesInspectionFailedState() ||
      HistoricalArchivesReadyToAddState() ||
      HistoricalArchivesImportingState() ||
      HistoricalArchivesImportFailedState() ||
      HistoricalArchivesRemovingState() ||
      HistoricalArchivesRemovalFailedState() => true,
      HistoricalArchivesHubState() ||
      HistoricalArchivesMessageLensNoticeState() ||
      HistoricalArchivesDuplicateNoticeState() ||
      HistoricalArchivesInvalidNoticeState() ||
      HistoricalArchivesLineageNoticeState() ||
      HistoricalArchivesImportSuccessNoticeState() ||
      HistoricalArchivesKnownSourceReferenceState() ||
      HistoricalArchivesExistingSourceState() => false,
    },
    isHub: workflowState.isHub,
    narratorPresentation: _buildNarratorPresentation(
      workflowState: workflowState,
      executionGate: executionGate,
      importButtonEnabled: importButtonEnabled,
    ),
    existingSourcePresentation: _buildExistingSourcePresentation(
      workflowState: workflowState,
      executionGate: executionGate,
    ),
  );
}

HistoricalArchivesExistingSourcePresentationViewModel?
_buildExistingSourcePresentation({
  required HistoricalArchivesWorkflowState workflowState,
  required HistoricalArchivesExecutionGateViewModel executionGate,
}) {
  final presentation = workflowState.presentation;
  if (presentation is! HistoricalArchivesExistingSourceState) {
    return null;
  }

  final facts = presentation.facts;
  final importDate = DateLabelFormatter.fullDateFromIso(
    facts.successfulImportFinishedAtUtc,
  );
  final detailsLines = _inspectionDetailsLines(
    workflowState: workflowState,
    executionGate: executionGate,
    importButtonEnabled: false,
  );

  return HistoricalArchivesExistingSourcePresentationViewModel(
    sourceTypeStatement: 'This is a Mac Messages folder.',
    importDateStatement: importDate == null
        ? null
        : 'You added it to MessageLens on $importDate.',
    contentsStatement: _existingSourceContentsStatement(facts),
    detailsLines: [
      ...detailsLines,
      'Imported messages: ${_formattedCount(facts.importedMessageCount)}',
      if (facts.earliestMessageUtc case final earliest?)
        'Earliest message UTC: $earliest',
      if (facts.latestMessageUtc case final latest?)
        'Latest message UTC: $latest',
      if (workflowState.removalFailureDetail case final String failureDetail)
        'Removal detail: $failureDetail',
      if (facts.successfulImportFinishedAtUtc case final completedAtUtc?)
        'Successful import completed UTC: $completedAtUtc',
    ],
    removalFailureStatement: workflowState.removalFailureDetail == null
        ? null
        : "MessageLens couldn't remove this folder. Its messages are still part of MessageLens.",
  );
}

String? _existingSourceContentsStatement(
  HistoricalArchivesImportedSourceFacts facts,
) {
  final earliest = _monthYearLong(facts.earliestMessageUtc);
  final latest = _monthYearLong(facts.latestMessageUtc);
  if (earliest != null && latest != null) {
    return 'It contains ${_formattedCount(facts.importedMessageCount)} messages sent or '
        'received between $earliest and $latest.';
  }
  return 'It contains ${_formattedCount(facts.importedMessageCount)} messages.';
}

HistoricalArchivesNarratorPresentationViewModel? _buildNarratorPresentation({
  required HistoricalArchivesWorkflowState workflowState,
  required HistoricalArchivesExecutionGateViewModel executionGate,
  required bool importButtonEnabled,
}) {
  final presentation = workflowState.presentation;
  if (presentation is HistoricalArchivesHubState ||
      presentation is HistoricalArchivesMessageLensNoticeState ||
      presentation is HistoricalArchivesDuplicateNoticeState ||
      presentation is HistoricalArchivesInvalidNoticeState ||
      presentation is HistoricalArchivesImportSuccessNoticeState ||
      presentation is HistoricalArchivesKnownSourceReferenceState ||
      presentation is HistoricalArchivesExistingSourceState) {
    return null;
  }

  if (presentation is HistoricalArchivesRemovingState ||
      presentation is HistoricalArchivesRemovalFailedState) {
    final failed = presentation is HistoricalArchivesRemovalFailedState;
    final progress = failed
        ? presentation.progress
        : (presentation as HistoricalArchivesRemovingState).progress;
    return HistoricalArchivesNarratorPresentationViewModel(
      kind: failed
          ? HistoricalArchivesNarratorPresentationKind.removalFailed
          : HistoricalArchivesNarratorPresentationKind.removingSource,
      narratorText: _removalNarratorText(progress),
      instrumentationRows: _removalInstrumentationRows(progress),
      detailsLines: [
        'Your original Messages folder and its files were not changed.',
        if (workflowState.removalFailureDetail case final String failureDetail)
          failureDetail,
      ],
      retryInspectionEnabled: false,
    );
  }

  if (presentation is HistoricalArchivesImportingState ||
      presentation is HistoricalArchivesImportFailedState) {
    final failed = presentation is HistoricalArchivesImportFailedState;
    final progress = failed
        ? presentation.progress
        : (presentation as HistoricalArchivesImportingState).progress;
    return HistoricalArchivesNarratorPresentationViewModel(
      kind: failed
          ? HistoricalArchivesNarratorPresentationKind.importFailed
          : HistoricalArchivesNarratorPresentationKind.importingArchive,
      narratorText: _importNarratorText(progress: progress, failed: failed),
      instrumentationRows: _importInstrumentationRows(progress),
      detailsLines: [
        ..._inspectionDetailsLines(
          workflowState: workflowState,
          executionGate: executionGate,
        ),
        'The original Messages folder and its files are read-only input and were not changed.',
        if (workflowState.importFailureDetail case final String failureDetail)
          failureDetail,
      ],
      retryInspectionEnabled: false,
    );
  }

  if (presentation is HistoricalArchivesMessageLensRecoveringState ||
      presentation is HistoricalArchivesMessageLensRecoveryFailedState) {
    final failed =
        presentation is HistoricalArchivesMessageLensRecoveryFailedState;
    final progress = failed
        ? presentation.progress
        : (presentation as HistoricalArchivesMessageLensRecoveringState)
              .progress;
    final evidence =
        presentation is HistoricalArchivesMessageLensRecoveryFailedState
        ? presentation.evidence
        : (presentation as HistoricalArchivesMessageLensRecoveringState)
              .evidence;
    return HistoricalArchivesNarratorPresentationViewModel(
      kind: failed
          ? HistoricalArchivesNarratorPresentationKind.messageLensRecoveryFailed
          : HistoricalArchivesNarratorPresentationKind
                .recoveringMessageLensAttachments,
      narratorText: failed
          ? "MessageLens couldn't finish recovering these attachments."
          : 'Recovering missing attachments from this MessageLens folder.',
      instrumentationRows: _messageLensRecoveryInstrumentationRows(
        progress,
        failed: failed,
      ),
      detailsLines: [
        'Folder: ${evidence.donor.rootPath}',
        'The donor folder remains read-only.',
        if (presentation is HistoricalArchivesMessageLensRecoveryFailedState)
          presentation.failureDetail,
      ],
      retryInspectionEnabled: false,
    );
  }

  return switch (presentation) {
    HistoricalArchivesHubState() ||
    HistoricalArchivesMessageLensNoticeState() ||
    HistoricalArchivesDuplicateNoticeState() ||
    HistoricalArchivesInvalidNoticeState() ||
    HistoricalArchivesLineageNoticeState() ||
    HistoricalArchivesImportSuccessNoticeState() ||
    HistoricalArchivesKnownSourceReferenceState() =>
      const HistoricalArchivesNarratorPresentationViewModel(
        kind: HistoricalArchivesNarratorPresentationKind.noSource,
        narratorText: 'Add an older Messages archive to extend your history.',
        instrumentationRows: [],
        detailsLines: [
          'No Messages archive folder is selected.',
          'Choose a folder and MessageLens will inspect it before offering any import decision.',
        ],
        retryInspectionEnabled: false,
      ),
    HistoricalArchivesInspectingCandidateState() =>
      HistoricalArchivesNarratorPresentationViewModel(
        kind: HistoricalArchivesNarratorPresentationKind.inspectingSource,
        narratorText: 'Let\u2019s see what\u2019s in this Messages folder.',
        instrumentationRows: const [
          HistoricalArchivesInstrumentationRowViewModel(
            label: 'Inspecting archive source',
            value: 'Working',
            status: HistoricalArchivesInstrumentationStatus.working,
          ),
        ],
        detailsLines: _inspectionDetailsLines(
          workflowState: workflowState,
          executionGate: executionGate,
        ),
        retryInspectionEnabled: false,
      ),
    HistoricalArchivesMessageLensInspectingState(
      :final folderPath,
      :final progress,
    ) =>
      HistoricalArchivesNarratorPresentationViewModel(
        kind: HistoricalArchivesNarratorPresentationKind
            .inspectingMessageLensSource,
        narratorText: _messageLensPreflightNarrator(progress),
        instrumentationRows: _messageLensPreflightInstrumentationRows(progress),
        detailsLines: [
          'Folder: $folderPath',
          'No donor data is being changed.',
        ],
        retryInspectionEnabled: false,
      ),
    HistoricalArchivesInspectionFailedState() =>
      HistoricalArchivesNarratorPresentationViewModel(
        kind: HistoricalArchivesNarratorPresentationKind.inspectionFailed,
        narratorText: _failedInspectionNarrator(workflowState),
        instrumentationRows: [
          HistoricalArchivesInstrumentationRowViewModel(
            label: 'Messages database',
            value: workflowState.chatDbStatusLabel,
            status: HistoricalArchivesInstrumentationStatus.failed,
          ),
        ],
        detailsLines: _inspectionDetailsLines(
          workflowState: workflowState,
          executionGate: executionGate,
        ),
        retryInspectionEnabled: _inspectionCanBeRetried(workflowState),
      ),
    HistoricalArchivesReadyToAddState() =>
      HistoricalArchivesNarratorPresentationViewModel(
        kind: HistoricalArchivesNarratorPresentationKind.readyForImport,
        narratorText: _readyNarrator(workflowState.inspectionEvidence),
        instrumentationRows: _readyInstrumentationRows(
          workflowState.inspectionEvidence,
        ),
        detailsLines: _inspectionDetailsLines(
          workflowState: workflowState,
          executionGate: executionGate,
          importButtonEnabled: importButtonEnabled,
        ),
        retryInspectionEnabled: false,
      ),
    HistoricalArchivesMessageLensReadyState(:final evidence) => HistoricalArchivesNarratorPresentationViewModel(
      kind: HistoricalArchivesNarratorPresentationKind.messageLensReady,
      narratorText:
          'This folder comes from the same Messages history. I found attachments that are missing from MessageLens.',
      instrumentationRows: [
        HistoricalArchivesInstrumentationRowViewModel(
          label: 'Recoverable attachments',
          value: _formattedCount(evidence.attachmentPreflight.recoverableCount),
          status: HistoricalArchivesInstrumentationStatus.resolved,
        ),
        HistoricalArchivesInstrumentationRowViewModel(
          label: 'Recoverable size',
          value: _formattedByteCount(
            evidence.attachmentPreflight.recoverableBytes,
          ),
          status: HistoricalArchivesInstrumentationStatus.resolved,
        ),
      ],
      detailsLines: [
        'Folder: ${evidence.donor.rootPath}',
        'Donor format: ${evidence.donor.format.diagnosticLabel}',
        if (evidence.donor.archiveInstanceId case final archiveInstanceId?)
          'Archive instance: $archiveInstanceId',
        'Donor payload claims: ${_formattedCount(evidence.attachmentPreflight.funnel.donorPayloadClaimCount)}',
        'Donor relationship evidence: ${_formattedCount(evidence.attachmentPreflight.funnel.donorRelationshipEvidenceCount)}',
        'Current relationship evidence: ${_formattedCount(evidence.attachmentPreflight.funnel.currentRelationshipEvidenceCount)}',
        'Claims without one donor relationship: ${_formattedCount(evidence.attachmentPreflight.funnel.donorRelationshipUnmatchedCount)}',
        'Message identities matched: ${_formattedCount(evidence.attachmentPreflight.funnel.messageMatchedCount)}',
        'Attachment identities matched: ${_formattedCount(evidence.attachmentPreflight.funnel.attachmentMatchedCount)}',
        'Donor payloads physically valid: ${_formattedCount(evidence.attachmentPreflight.funnel.donorPayloadPresentCount)}',
        'Current matched payloads physically valid: ${_formattedCount(evidence.attachmentPreflight.funnel.currentPayloadPresentCount)}',
        'Relationships examined: ${_formattedCount(evidence.attachmentPreflight.examinedCount)}',
        'Already present: ${_formattedCount(evidence.attachmentPreflight.alreadyPresentCount)}',
        'Donor payload missing: ${_formattedCount(evidence.attachmentPreflight.donorMissingCount)}',
        'Message mismatches: ${_formattedCount(evidence.attachmentPreflight.messageMismatchCount)}',
        'Attachment mismatches: ${_formattedCount(evidence.attachmentPreflight.attachmentMismatchCount)}',
        'Conflicts: ${_formattedCount(evidence.attachmentPreflight.conflictCount)}',
        'Ambiguous: ${_formattedCount(evidence.attachmentPreflight.ambiguousCount)}',
        'Unsafe donor paths: ${_formattedCount(evidence.attachmentPreflight.unsafeDonorPathCount)}',
        'Duplicate claims collapsed: ${_formattedCount(evidence.attachmentPreflight.funnel.duplicateClaimsCollapsedCount)}',
        'Terminal classifications: ${_formattedCount(evidence.attachmentPreflight.terminalClassificationCount)}',
        'Classification counts reconcile: ${evidence.attachmentPreflight.classificationCountsReconcile ? 'Yes' : 'No'}',
        for (final timing in evidence.phaseTimings)
          '${_messageLensPreflightPhaseLabel(timing.phase)}: ${timing.elapsed.inMilliseconds} ms',
        'Recovery requires an explicit user command and attachment-reconciliation authority.',
      ],
      retryInspectionEnabled: false,
    ),
    HistoricalArchivesExistingSourceState() ||
    HistoricalArchivesImportingState() ||
    HistoricalArchivesImportFailedState() ||
    HistoricalArchivesRemovingState() ||
    HistoricalArchivesRemovalFailedState() ||
    HistoricalArchivesMessageLensRecoveringState() ||
    HistoricalArchivesMessageLensRecoveryFailedState() => null,
  };
}

List<HistoricalArchivesInstrumentationRowViewModel>
_messageLensRecoveryInstrumentationRows(
  MessageLensAttachmentRecoveryBatchProgress progress, {
  bool failed = false,
}) {
  final verifyingStatus = switch (progress.stage) {
    MessageLensAttachmentRecoveryBatchStage.verifyingDonorPayloads =>
      failed
          ? HistoricalArchivesInstrumentationStatus.failed
          : HistoricalArchivesInstrumentationStatus.working,
    _ => HistoricalArchivesInstrumentationStatus.resolved,
  };
  final recoveringStatus = switch (progress.stage) {
    MessageLensAttachmentRecoveryBatchStage.verifyingDonorPayloads =>
      HistoricalArchivesInstrumentationStatus.waiting,
    MessageLensAttachmentRecoveryBatchStage.installingPayloads =>
      failed
          ? HistoricalArchivesInstrumentationStatus.failed
          : HistoricalArchivesInstrumentationStatus.working,
    MessageLensAttachmentRecoveryBatchStage.finalVerification ||
    MessageLensAttachmentRecoveryBatchStage.complete =>
      HistoricalArchivesInstrumentationStatus.resolved,
  };
  final finalStatus = switch (progress.stage) {
    MessageLensAttachmentRecoveryBatchStage.finalVerification =>
      failed
          ? HistoricalArchivesInstrumentationStatus.failed
          : HistoricalArchivesInstrumentationStatus.working,
    MessageLensAttachmentRecoveryBatchStage.complete =>
      HistoricalArchivesInstrumentationStatus.resolved,
    _ => HistoricalArchivesInstrumentationStatus.waiting,
  };
  return [
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Verifying attachment files',
      value:
          '${_formattedCount(progress.verifiedAttachments)} / '
          '${_formattedCount(progress.totalAttachments)}'
          ' · ${_formattedByteCount(progress.verifiedBytes)} / '
          '${_formattedByteCount(progress.totalBytes)}',
      status: verifyingStatus,
    ),
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Recovering attachment files',
      value:
          '${_formattedCount(progress.recoveredAttachments)} / '
          '${_formattedCount(progress.totalAttachments)}'
          ' · ${_formattedByteCount(progress.copiedBytes)} / '
          '${_formattedByteCount(progress.totalBytes)}',
      status: recoveringStatus,
    ),
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Checking that recovery finished',
      value:
          '${_formattedCount(progress.terminallyVerifiedAttachments)} / '
          '${_formattedCount(progress.totalAttachments)}',
      status: finalStatus,
    ),
  ];
}

String _messageLensPreflightNarrator(
  MessageLensHistoricalArchivePreflightProgress? progress,
) {
  if (progress != null &&
      progress.phase.index >
          MessageLensHistoricalArchivePreflightPhase.lineageAdmission.index) {
    return 'This folder matches your Messages history. Now I’m checking which attachments are missing here.';
  }
  return 'I’ll check this MessageLens folder for attachments that are missing here.';
}

List<HistoricalArchivesInstrumentationRowViewModel>
_messageLensPreflightInstrumentationRows(
  MessageLensHistoricalArchivePreflightProgress? progress,
) {
  const stages =
      <({String label, MessageLensHistoricalArchivePreflightPhase finalPhase})>[
        (
          label: 'Verifying this MessageLens folder',
          finalPhase:
              MessageLensHistoricalArchivePreflightPhase.lineageAdmission,
        ),
        (
          label: 'Reading attachment records',
          finalPhase:
              MessageLensHistoricalArchivePreflightPhase.donorPayloadEvidence,
        ),
        (
          label: 'Matching attachments',
          finalPhase:
              MessageLensHistoricalArchivePreflightPhase.relationshipMatching,
        ),
        (
          label: 'Checking current attachment files',
          finalPhase:
              MessageLensHistoricalArchivePreflightPhase.currentPayloadPresence,
        ),
        (
          label: 'Checking donor attachment files',
          finalPhase:
              MessageLensHistoricalArchivePreflightPhase.donorPayloadPresence,
        ),
        (
          label: 'Calculating recovery summary',
          finalPhase: MessageLensHistoricalArchivePreflightPhase.classification,
        ),
      ];
  final current = progress?.phase.index ?? 0;
  return [
    for (final stage in stages)
      HistoricalArchivesInstrumentationRowViewModel(
        label: stage.label,
        value: current > stage.finalPhase.index
            ? 'Done'
            : current <= stage.finalPhase.index &&
                  _stageContainsPhase(stage.finalPhase, progress?.phase)
            ? _messageLensPreflightProgressValue(progress)
            : 'Waiting',
        status: current > stage.finalPhase.index
            ? HistoricalArchivesInstrumentationStatus.resolved
            : _stageContainsPhase(stage.finalPhase, progress?.phase)
            ? HistoricalArchivesInstrumentationStatus.working
            : HistoricalArchivesInstrumentationStatus.waiting,
      ),
  ];
}

bool _stageContainsPhase(
  MessageLensHistoricalArchivePreflightPhase finalPhase,
  MessageLensHistoricalArchivePreflightPhase? currentPhase,
) {
  if (currentPhase == null) {
    return finalPhase ==
        MessageLensHistoricalArchivePreflightPhase.lineageAdmission;
  }
  final startIndex = switch (finalPhase) {
    MessageLensHistoricalArchivePreflightPhase.lineageAdmission => 0,
    MessageLensHistoricalArchivePreflightPhase.donorPayloadEvidence =>
      MessageLensHistoricalArchivePreflightPhase.donorAttachmentEvidence.index,
    MessageLensHistoricalArchivePreflightPhase.relationshipMatching =>
      MessageLensHistoricalArchivePreflightPhase.relationshipMatching.index,
    MessageLensHistoricalArchivePreflightPhase.currentPayloadPresence =>
      MessageLensHistoricalArchivePreflightPhase.currentPayloadPresence.index,
    MessageLensHistoricalArchivePreflightPhase.donorPayloadPresence =>
      MessageLensHistoricalArchivePreflightPhase.donorPayloadPresence.index,
    MessageLensHistoricalArchivePreflightPhase.classification =>
      MessageLensHistoricalArchivePreflightPhase.classification.index,
    _ => finalPhase.index,
  };
  return currentPhase.index >= startIndex &&
      currentPhase.index <= finalPhase.index;
}

String _messageLensPreflightProgressValue(
  MessageLensHistoricalArchivePreflightProgress? progress,
) {
  if (progress == null || progress.totalUnits == null) {
    return 'Working';
  }
  if (progress.totalUnits == 1 && progress.completedUnits == 0) {
    return 'Working';
  }
  return '${_formattedCount(progress.completedUnits)} / '
      '${_formattedCount(progress.totalUnits)}';
}

String _messageLensPreflightPhaseLabel(
  MessageLensHistoricalArchivePreflightPhase phase,
) {
  return switch (phase) {
    MessageLensHistoricalArchivePreflightPhase.structuralQualification =>
      'Structural qualification',
    MessageLensHistoricalArchivePreflightPhase.compatibilityInspection =>
      'Compatibility inspection',
    MessageLensHistoricalArchivePreflightPhase.lineageAdmission =>
      'Messages lineage admission',
    MessageLensHistoricalArchivePreflightPhase.donorAttachmentEvidence =>
      'Donor attachment evidence',
    MessageLensHistoricalArchivePreflightPhase.currentAttachmentEvidence =>
      'Current attachment evidence',
    MessageLensHistoricalArchivePreflightPhase.donorPayloadEvidence =>
      'Donor payload evidence',
    MessageLensHistoricalArchivePreflightPhase.relationshipMatching =>
      'Attachment relationship matching',
    MessageLensHistoricalArchivePreflightPhase.currentPayloadPresence =>
      'Current payload presence',
    MessageLensHistoricalArchivePreflightPhase.donorPayloadPresence =>
      'Donor payload presence',
    MessageLensHistoricalArchivePreflightPhase.classification =>
      'Classification and aggregation',
  };
}

String _formattedByteCount(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  const units = ['KB', 'MB', 'GB', 'TB'];
  var value = bytes / 1024;
  var unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex += 1;
  }
  final decimals = value >= 10 ? 1 : 2;
  return '${value.toStringAsFixed(decimals)} ${units[unitIndex]}';
}

String? _importNarratorText({
  required HistoricalArchiveImportProgress progress,
  required bool failed,
}) {
  if (progress.verifyingImport != HistoricalArchiveImportStageStatus.waiting ||
      progress.preparingConversations ==
          HistoricalArchiveImportStageStatus.succeeded) {
    return null;
  }
  if (progress.preparingConversations ==
          HistoricalArchiveImportStageStatus.running ||
      progress.preparingConversations ==
          HistoricalArchiveImportStageStatus.failed) {
    return 'The messages from this folder are added. Now I\u2019m updating your '
        'combined MessageLens history so everything appears together.';
  }
  if (failed) {
    return "MessageLens couldn't finish adding this folder.";
  }
  return 'Adding this Messages folder to MessageLens.';
}

List<HistoricalArchivesInstrumentationRowViewModel> _importInstrumentationRows(
  HistoricalArchiveImportProgress progress,
) {
  final rows = <HistoricalArchivesInstrumentationRowViewModel>[
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Adding messages from this folder',
      value: _importStageValue(progress.addingMessages),
      status: _importInstrumentationStatus(progress.addingMessages),
    ),
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Preparing conversations for browsing',
      value: _importStageValue(progress.preparingConversations),
      status: _importInstrumentationStatus(progress.preparingConversations),
    ),
  ];
  final projection = progress.graphProjectionProgress;
  if (projection != null) {
    rows.addAll(
      _graphProjectionInstrumentationRows(
        projection: projection,
        stageSucceeded:
            progress.preparingConversations ==
            HistoricalArchiveImportStageStatus.succeeded,
        stageFailed:
            progress.preparingConversations ==
            HistoricalArchiveImportStageStatus.failed,
      ),
    );
  }
  rows.add(
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Checking that import finished',
      value: _importStageValue(progress.verifyingImport),
      status: _importInstrumentationStatus(progress.verifyingImport),
    ),
  );
  return rows;
}

List<HistoricalArchivesInstrumentationRowViewModel>
_graphProjectionInstrumentationRows({
  required SourceScopedArchiveGraphProjectionProgress projection,
  required bool stageSucceeded,
  required bool stageFailed,
}) {
  return [
    for (final unit in SourceScopedArchiveGraphProjectionUnit.values)
      HistoricalArchivesInstrumentationRowViewModel(
        label: _graphProjectionUnitLabel(unit),
        value: _graphProjectionUnitValue(
          unit: unit,
          projection: projection,
          stageSucceeded: stageSucceeded,
          stageFailed: stageFailed,
        ),
        status: _graphProjectionUnitStatus(
          unit: unit,
          projection: projection,
          stageSucceeded: stageSucceeded,
          stageFailed: stageFailed,
        ),
        indentationLevel: 1,
      ),
  ];
}

String _graphProjectionUnitLabel(SourceScopedArchiveGraphProjectionUnit unit) {
  return switch (unit) {
    SourceScopedArchiveGraphProjectionUnit.participants => 'Participants',
    SourceScopedArchiveGraphProjectionUnit.conversations => 'Conversations',
    SourceScopedArchiveGraphProjectionUnit.messages => 'Messages',
    SourceScopedArchiveGraphProjectionUnit.attachments => 'Attachments',
    SourceScopedArchiveGraphProjectionUnit.relationships => 'Relationships',
  };
}

HistoricalArchivesInstrumentationStatus _graphProjectionUnitStatus({
  required SourceScopedArchiveGraphProjectionUnit unit,
  required SourceScopedArchiveGraphProjectionProgress projection,
  required bool stageSucceeded,
  required bool stageFailed,
}) {
  if (stageSucceeded) {
    return HistoricalArchivesInstrumentationStatus.resolved;
  }
  if (unit.index < projection.activeUnit.index) {
    return HistoricalArchivesInstrumentationStatus.resolved;
  }
  if (unit.index > projection.activeUnit.index) {
    return HistoricalArchivesInstrumentationStatus.waiting;
  }
  if (stageFailed) {
    return HistoricalArchivesInstrumentationStatus.failed;
  }
  return HistoricalArchivesInstrumentationStatus.working;
}

String _graphProjectionUnitValue({
  required SourceScopedArchiveGraphProjectionUnit unit,
  required SourceScopedArchiveGraphProjectionProgress projection,
  required bool stageSucceeded,
  required bool stageFailed,
}) {
  final status = _graphProjectionUnitStatus(
    unit: unit,
    projection: projection,
    stageSucceeded: stageSucceeded,
    stageFailed: stageFailed,
  );
  if (status == HistoricalArchivesInstrumentationStatus.resolved) {
    return 'Done';
  }
  if (status == HistoricalArchivesInstrumentationStatus.waiting) {
    return 'Waiting';
  }

  final completedWorkCount = projection.completedWorkCount;
  final totalWorkCount = projection.totalWorkCount;
  final progressLabel = completedWorkCount != null && totalWorkCount != null
      ? '${_formattedCount(completedWorkCount)} / ${_formattedCount(totalWorkCount)}'
      : 'Working';
  if (status == HistoricalArchivesInstrumentationStatus.failed) {
    return progressLabel == 'Working' ? 'Failed' : 'Failed · $progressLabel';
  }
  return progressLabel;
}

String _importStageValue(HistoricalArchiveImportStageStatus status) {
  return switch (status) {
    HistoricalArchiveImportStageStatus.waiting => 'Waiting',
    HistoricalArchiveImportStageStatus.running => 'Working',
    HistoricalArchiveImportStageStatus.succeeded => 'Done',
    HistoricalArchiveImportStageStatus.failed => 'Failed',
  };
}

HistoricalArchivesInstrumentationStatus _importInstrumentationStatus(
  HistoricalArchiveImportStageStatus status,
) {
  return switch (status) {
    HistoricalArchiveImportStageStatus.waiting =>
      HistoricalArchivesInstrumentationStatus.waiting,
    HistoricalArchiveImportStageStatus.running =>
      HistoricalArchivesInstrumentationStatus.working,
    HistoricalArchiveImportStageStatus.succeeded =>
      HistoricalArchivesInstrumentationStatus.resolved,
    HistoricalArchiveImportStageStatus.failed =>
      HistoricalArchivesInstrumentationStatus.failed,
  };
}

String _failedInspectionNarrator(HistoricalArchivesWorkflowState state) {
  return switch (state.chatDbStatus) {
    ArchiveSourceInspectionStatus.missing =>
      'This folder does not contain a Messages database.',
    ArchiveSourceInspectionStatus.readFailed =>
      'MessageLens couldn\u2019t read the Messages database in this folder.',
    ArchiveSourceInspectionStatus.readable ||
    ArchiveSourceInspectionStatus.unavailable =>
      'MessageLens couldn\u2019t establish that this is a readable Messages archive.',
  };
}

bool _inspectionCanBeRetried(HistoricalArchivesWorkflowState state) {
  return state.chatDbStatus != ArchiveSourceInspectionStatus.missing;
}

String _readyNarrator(HistoricalArchivesInspectionEvidence? evidence) {
  final earliest = _monthYearLong(evidence?.earliestMessageUtc);
  if (earliest == null) {
    return 'Good. This archive can extend your MessageLens history.';
  }
  return 'Good. This archive can extend your history back to $earliest.';
}

List<HistoricalArchivesInstrumentationRowViewModel> _readyInstrumentationRows(
  HistoricalArchivesInspectionEvidence? evidence,
) {
  if (evidence == null) {
    return const [];
  }

  final rows = <HistoricalArchivesInstrumentationRowViewModel>[
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Messages database',
      value: evidence.chatDbStatus == ArchiveSourceInspectionStatus.readable
          ? 'Found'
          : evidence.chatDbStatusLabel,
      status: HistoricalArchivesInstrumentationStatus.resolved,
    ),
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Messages',
      value: _formattedCount(evidence.totalMessages),
      status: HistoricalArchivesInstrumentationStatus.resolved,
    ),
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Dates',
      value: _dateRangeLabel(
        evidence.earliestMessageUtc,
        evidence.latestMessageUtc,
      ),
      status: HistoricalArchivesInstrumentationStatus.resolved,
    ),
  ];

  if (evidence.dryRunNewMessages != null &&
      evidence.dryRunDuplicateMessages != null &&
      _hasCoherentComparisonEvidence(evidence)) {
    rows.addAll([
      HistoricalArchivesInstrumentationRowViewModel(
        label: 'New to MessageLens',
        value: _formattedCount(evidence.dryRunNewMessages),
        status: HistoricalArchivesInstrumentationStatus.resolved,
      ),
      HistoricalArchivesInstrumentationRowViewModel(
        label: 'Already represented',
        value: _formattedCount(evidence.dryRunDuplicateMessages),
        status: HistoricalArchivesInstrumentationStatus.resolved,
      ),
    ]);
  } else {
    rows.add(
      const HistoricalArchivesInstrumentationRowViewModel(
        label: 'Message comparison',
        value: 'Unavailable',
        status: HistoricalArchivesInstrumentationStatus.resolved,
      ),
    );
  }

  return rows;
}

bool _hasCoherentComparisonEvidence(
  HistoricalArchivesInspectionEvidence evidence,
) {
  final comparable = evidence.dryRunComparableMessages;
  final newMessages = evidence.dryRunNewMessages;
  final represented = evidence.dryRunDuplicateMessages;
  if (comparable == null || newMessages == null || represented == null) {
    return false;
  }
  if (comparable < 0 || newMessages < 0 || represented < 0) {
    return false;
  }
  if (newMessages + represented != comparable) {
    return false;
  }
  final totalMessages = evidence.totalMessages;
  return totalMessages == null || comparable <= totalMessages;
}

List<String> _inspectionDetailsLines({
  required HistoricalArchivesWorkflowState workflowState,
  required HistoricalArchivesExecutionGateViewModel executionGate,
  bool? importButtonEnabled,
}) {
  final evidence = workflowState.inspectionEvidence;
  final selectedFolderPath = workflowState.selectedFolderPath;
  final chatDbPath =
      evidence?.chatDbPath ??
      (selectedFolderPath == null
          ? null
          : path.join(selectedFolderPath, 'chat.db'));

  return [
    if (selectedFolderPath != null) 'Folder: $selectedFolderPath',
    if (chatDbPath != null) 'Messages database: $chatDbPath',
    'Source label: ${workflowState.sourceLabel}',
    'Messages database status: ${workflowState.chatDbStatusLabel}',
    'Attachments folder: ${workflowState.attachmentsStatusLabel}',
    if (evidence?.totalChats case final totalChats?)
      'Chats: ${_formattedCount(totalChats)}',
    if (evidence?.totalHandles case final totalHandles?)
      'Handles: ${_formattedCount(totalHandles)}',
    if (evidence?.missingGuids case final missingGuids?)
      'Rows with missing GUIDs: ${_formattedCount(missingGuids)}',
    if (evidence?.earliestMessageUtc case final earliest?)
      'Earliest message UTC: $earliest',
    if (evidence?.latestMessageUtc case final latest?)
      'Latest message UTC: $latest',
    if (evidence?.dateRangeUnavailableReason case final reason?)
      'Date range diagnostic: $reason',
    if (evidence?.dryRunUnavailableReason case final reason?)
      'GUID comparison unavailable: $reason',
    if (evidence?.dryRunComparableMessages case final comparableMessages?)
      'Comparable source GUIDs: ${_formattedCount(comparableMessages)}',
    'GUID comparison: distinct source GUIDs are compared with distinct GUIDs already represented in MessageLens.',
    'Archive mutation authority: ${executionGate.statusLabel} (${executionGate.detail})',
    if (importButtonEnabled != null)
      'Import authorization: ${importButtonEnabled ? 'available' : 'not currently available'}',
    'Inspection detail: ${workflowState.preflight.detail}',
    for (final entry in workflowState.activityLog)
      '${entry.label}: ${entry.message}',
  ];
}

String _formattedCount(int? value) {
  if (value == null) {
    return 'Unavailable';
  }
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

String _dateRangeLabel(String? earliestUtc, String? latestUtc) {
  final earliest = _monthYearShort(earliestUtc);
  final latest = _monthYearShort(latestUtc);
  if (earliest == null || latest == null) {
    return 'Unavailable';
  }
  return '$earliest \u2013 $latest';
}

String? _monthYearLong(String? isoUtc) {
  final date = isoUtc == null ? null : DateTime.tryParse(isoUtc)?.toUtc();
  if (date == null) {
    return null;
  }
  return '${_longMonthNames[date.month - 1]} ${date.year}';
}

String? _monthYearShort(String? isoUtc) {
  final date = isoUtc == null ? null : DateTime.tryParse(isoUtc)?.toUtc();
  if (date == null) {
    return null;
  }
  return '${_shortMonthNames[date.month - 1]} ${date.year}';
}

const _longMonthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _shortMonthNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

HistoricalArchivesExecutionGateViewModel _buildExecutionGateViewModel({
  required ArchiveMutationCoordinatorState executionGateState,
  required bool isMaintenanceLocked,
}) {
  if (isMaintenanceLocked) {
    return const HistoricalArchivesExecutionGateViewModel(
      status: HistoricalArchivesExecutionGateStatus.blocked,
      statusLabel: 'Blocked',
      detail:
          'Message data reset or another maintenance operation is currently active.',
    );
  }

  if (executionGateState.isLocked) {
    return HistoricalArchivesExecutionGateViewModel(
      status: HistoricalArchivesExecutionGateStatus.busy,
      statusLabel: 'Busy',
      detail:
          '${_describeExecutionOwnerLabel(executionGateState.ownerLabel)} currently owns archive mutation authority.',
    );
  }

  return const HistoricalArchivesExecutionGateViewModel(
    status: HistoricalArchivesExecutionGateStatus.available,
    statusLabel: 'Available',
    detail: 'No other import, preparation, or reset task is running.',
  );
}

List<HistoricalArchivesLogEntryViewModel> _buildActivityLog({
  required ArchiveMutationCoordinatorState executionGateState,
  required bool isMaintenanceLocked,
  required HistoricalArchivesWorkflowState workflowState,
}) {
  if (isMaintenanceLocked) {
    return [
      ...workflowState.activityLog,
      const HistoricalArchivesLogEntryViewModel(
        label: 'Maintenance lock active',
        message:
            'Reset or another maintenance flow is active. Historical archive import cannot begin until that lock is released.',
      ),
    ];
  }

  if (executionGateState.isLocked) {
    return [
      ...workflowState.activityLog,
      HistoricalArchivesLogEntryViewModel(
        label: 'Execution gate busy',
        message:
            '${_describeExecutionOwnerLabel(executionGateState.ownerLabel)} is running now. Historical archive import must wait until that operation owner finishes.',
      ),
    ];
  }

  return workflowState.activityLog;
}

List<String> _importSafetySummaryLines(
  HistoricalArchivesWorkflowState workflowState, {
  required String currentMessagesDatabasePath,
}) {
  final selectedFolderPath = workflowState.selectedFolderPath;
  final selectedChatDbPath = selectedFolderPath == null
      ? null
      : path.join(selectedFolderPath, 'chat.db');

  if (selectedChatDbPath != null &&
      _isCurrentMacChatDbPath(
        selectedChatDbPath,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      )) {
    return const [
      'Live Messages source detected: import is disabled for this folder.',
      'Choose an older Messages archive folder instead.',
    ];
  }

  return switch (workflowState.preflight.status) {
    HistoricalArchivesPreflightStatus.waitingForFolder => const [
      'Choose an archive folder before importing.',
      'MessageLens will run preflight before enabling Begin Import.',
    ],
    HistoricalArchivesPreflightStatus.running => const [
      'Preflight is still reading the selected folder.',
      'Begin Import stays disabled until source checks complete.',
    ],
    HistoricalArchivesPreflightStatus.failed => const [
      'Begin Import is disabled because the selected folder failed preflight.',
      'No archive messages will be imported from this source until it passes.',
    ],
    HistoricalArchivesPreflightStatus.completeReadyToImport => [
      'Begin Import adds messages from "${workflowState.sourceLabel}" without replacing current message data.',
      'The live Messages database is not modified.',
      'User settings, favourites, and manual labels remain in the overlay database.',
      'Archive messages keep separate source identity even when GUIDs overlap with live messages.',
    ],
  };
}

String _availableStatusLabel(HistoricalArchivesWorkflowState workflowState) {
  if (workflowState.presentation is HistoricalArchivesImportFailedState) {
    return 'Import Incomplete';
  }
  if (workflowState.presentation is HistoricalArchivesExistingSourceState) {
    return 'Archive Already Imported';
  }
  return switch (workflowState.preflight.status) {
    HistoricalArchivesPreflightStatus.waitingForFolder => 'No archive selected',
    HistoricalArchivesPreflightStatus.running => 'Reading Archive Source',
    HistoricalArchivesPreflightStatus.completeReadyToImport =>
      'Archive Source Ready',
    HistoricalArchivesPreflightStatus.failed => 'Archive Preflight Failed',
  };
}

String _availableSummaryText(HistoricalArchivesWorkflowState workflowState) {
  if (workflowState.presentation is HistoricalArchivesImportFailedState) {
    return 'MessageLens did not finish adding this folder. Completed work remains visible, and the same source-scoped operation can be tried again.';
  }
  if (workflowState.presentation is HistoricalArchivesExistingSourceState) {
    return 'The selected folder matches an archive source that already has imported messages in MessageLens.';
  }
  return switch (workflowState.preflight.status) {
    HistoricalArchivesPreflightStatus.waitingForFolder =>
      'Historical archive import is a durable, step-by-step workflow. Choose an older Messages folder, review preflight evidence, then import it before messages become visible in MessageLens.',
    HistoricalArchivesPreflightStatus.running =>
      'Historical Archives is reading the selected source folder now. The workflow remains visible while source checks gather basic message, chat, handle, and GUID evidence.',
    HistoricalArchivesPreflightStatus.completeReadyToImport =>
      'Historical Archives has completed source preflight for the selected folder. Review the source metadata and message counts, then run archive import when the evidence looks correct.',
    HistoricalArchivesPreflightStatus.failed =>
      'Historical Archives could not validate the selected folder as a usable Messages source. Review the failure details, then choose a different folder or fix the source contents before trying again.',
  };
}

String _availableImportButtonDetail(
  HistoricalArchivesWorkflowState workflowState, {
  required String currentMessagesDatabasePath,
}) {
  if (workflowState.presentation is HistoricalArchivesImportFailedState) {
    return 'Try Again repeats the idempotent source-scoped import and verifies the complete result before the folder becomes an added archive.';
  }
  if (workflowState.presentation is HistoricalArchivesExistingSourceState) {
    return 'Import is not offered because this archive is already part of MessageLens.';
  }
  final selectedFolderPath = workflowState.selectedFolderPath;
  final selectedChatDbPath = selectedFolderPath == null
      ? null
      : path.join(selectedFolderPath, 'chat.db');

  if (selectedChatDbPath != null &&
      _isCurrentMacChatDbPath(
        selectedChatDbPath,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      )) {
    return 'Historical Archives does not import the live current_mac Messages source. Choose an archive folder instead.';
  }

  return switch (workflowState.preflight.status) {
    HistoricalArchivesPreflightStatus.waitingForFolder =>
      'Import stays disabled until a folder is selected and preflight completes.',
    HistoricalArchivesPreflightStatus.running =>
      'Import stays disabled while Historical Archives is reading source structure and counts.',
    HistoricalArchivesPreflightStatus.completeReadyToImport =>
      'Source checks are complete. Begin Import will add archive messages and refresh browsing data. Archive rows remain isolated from the live Messages source.',
    HistoricalArchivesPreflightStatus.failed =>
      'Import stays disabled until the selected folder passes source preflight.',
  };
}

bool _importButtonEnabled({
  required HistoricalArchivesExecutionGateViewModel executionGate,
  required HistoricalArchivesWorkflowState workflowState,
  required String currentMessagesDatabasePath,
}) {
  if (workflowState.presentation is HistoricalArchivesExistingSourceState) {
    return false;
  }
  if (executionGate.status != HistoricalArchivesExecutionGateStatus.available) {
    return false;
  }

  final selectedFolderPath = workflowState.selectedFolderPath;
  if (selectedFolderPath == null) {
    return false;
  }

  if (_isCurrentMacChatDbPath(
    path.join(selectedFolderPath, 'chat.db'),
    currentMessagesDatabasePath: currentMessagesDatabasePath,
  )) {
    return false;
  }

  if (workflowState.presentation is HistoricalArchivesImportFailedState) {
    return true;
  }

  return workflowState.presentation is HistoricalArchivesReadyToAddState &&
      workflowState.preflight.status ==
          HistoricalArchivesPreflightStatus.completeReadyToImport;
}

List<String> _archiveManagementSummaryLines(
  HistoricalArchivesWorkflowState workflowState,
) {
  final targetPath = workflowState.archiveRemovalTargetChatDbPath;

  if (targetPath == null) {
    return const [
      'Removal target chat.db: waiting for folder selection',
      'Source-scoped archive removal: waiting for folder selection',
    ];
  }

  return [
    'Removal target chat.db: $targetPath',
    'Source-scoped archive removal: available after preflight',
  ];
}

bool _removeImportedArchiveDataEnabled({
  required HistoricalArchivesExecutionGateViewModel executionGate,
  required HistoricalArchivesWorkflowState workflowState,
  required String currentMessagesDatabasePath,
}) {
  final targetPath = workflowState.archiveRemovalTargetChatDbPath;
  if (workflowState.presentation is! HistoricalArchivesExistingSourceState) {
    return false;
  }
  if (executionGate.status != HistoricalArchivesExecutionGateStatus.available) {
    return false;
  }
  if (workflowState.preflight.status ==
      HistoricalArchivesPreflightStatus.running) {
    return false;
  }
  if (targetPath == null) {
    return false;
  }
  if (_isCurrentMacChatDbPath(
    targetPath,
    currentMessagesDatabasePath: currentMessagesDatabasePath,
  )) {
    return false;
  }
  return true;
}

String _removeImportedArchiveDataDetail({
  required ArchiveMutationCoordinatorState executionGateState,
  required bool isMaintenanceLocked,
  required HistoricalArchivesWorkflowState workflowState,
  required String currentMessagesDatabasePath,
}) {
  final targetPath = workflowState.archiveRemovalTargetChatDbPath;
  if (executionGateState.isLocked) {
    return 'Removal is unavailable because ${_describeExecutionOwnerPhrase(executionGateState.ownerLabel)} currently owns archive mutation authority.';
  }
  if (isMaintenanceLocked) {
    return 'Removal is unavailable while reset or another maintenance operation is holding the message-data lock.';
  }
  if (workflowState.preflight.status ==
      HistoricalArchivesPreflightStatus.running) {
    return 'Removal stays disabled while Historical Archives is still reading source state.';
  }
  if (targetPath == null) {
    return 'Choose an archive folder first so MessageLens can identify which source-scoped archive rows would be removed.';
  }
  if (_isCurrentMacChatDbPath(
    targetPath,
    currentMessagesDatabasePath: currentMessagesDatabasePath,
  )) {
    return 'Removal is unavailable for the live current_mac Messages source.';
  }
  return 'Removing imported archive data will delete source-scoped import rows for this selected source, then reproject the conversation graph from the remaining import facts.';
}

Future<HistoricalArchivesFolderPreflightResult>
preflightHistoricalArchivesFolder({
  required String folderPath,
  ArchiveSourceInspector? archiveSourceInspector,
}) async {
  final inspection =
      await (archiveSourceInspector ??
              const _UnavailableArchiveSourceInspector())
          .inspectFolder(folderPath: folderPath);
  if (!inspection.isReadable) {
    return _failedPreflightResult(
      folderPath: inspection.folderPath,
      sourceLabel: inspection.sourceLabel,
      detail: inspection.detail,
      archiveRemovalTargetChatDbPath: inspection.chatDbPath,
      chatDbStatus: inspection.chatDbStatus,
      attachmentsStatusLabel: inspection.attachmentsStatusLabel,
    );
  }

  final dryRunEstimate = inspection.dryRunEstimate;
  final sourceIdentity = _requireReadableSourceIdentity(
    inspection.sourceIdentity,
  );
  return HistoricalArchivesFolderPreflightResult(
    sourceIdentity: sourceIdentity,
    preflight: HistoricalArchivesPreflightViewModel(
      status: HistoricalArchivesPreflightStatus.completeReadyToImport,
      statusLabel: 'Preflight complete',
      detail: inspection.detail,
    ),
    selectedFolderPath: inspection.folderPath,
    archiveRemovalTargetChatDbPath: inspection.chatDbPath,
    chatDbStatus: inspection.chatDbStatus,
    attachmentsStatusLabel: inspection.attachmentsStatusLabel,
    sourceLabel: inspection.sourceLabel,
    totalMessages: inspection.totalMessages,
    totalChats: inspection.totalChats,
    totalHandles: inspection.totalHandles,
    missingGuids: inspection.missingGuids,
    earliestMessageUtc: inspection.earliestMessageUtc,
    latestMessageUtc: inspection.latestMessageUtc,
    dryRunNewMessages: dryRunEstimate.isAvailable
        ? dryRunEstimate.newGuidCount
        : null,
    dryRunDuplicateMessages: dryRunEstimate.isAvailable
        ? dryRunEstimate.duplicateGuidCount
        : null,
    dryRunComparableMessages: dryRunEstimate.isAvailable
        ? dryRunEstimate.comparableGuidCount
        : null,
    dateRangeUnavailableReason: inspection.dateRangeUnavailableReason,
    dryRunUnavailableReason: dryRunEstimate.unavailableReason,
    preflightSummaryLines: [
      'Total messages: ${inspection.totalMessages}',
      'Total chats: ${inspection.totalChats}',
      'Total handles: ${inspection.totalHandles}',
      'Rows with missing GUIDs: ${inspection.missingGuids}',
      'Earliest message: ${_dateSummaryLabel(inspection.earliestMessageUtc)}',
      'Latest message: ${_dateSummaryLabel(inspection.latestMessageUtc)}',
      if (inspection.dateRangeUnavailableReason case final reason?)
        'Date range diagnostic: $reason',
      if (dryRunEstimate.isAvailable)
        'Likely already imported: ${dryRunEstimate.duplicateGuidCount} comparable source rows'
      else
        'Likely already imported: unavailable',
      if (dryRunEstimate.isAvailable)
        'Likely new rows: ${dryRunEstimate.newGuidCount} comparable source rows'
      else
        'Likely new rows: unavailable',
    ],
    dryRunSummaryLines: [
      if (dryRunEstimate.isAvailable)
        'Estimated new messages: ${dryRunEstimate.newGuidCount} comparable source rows not already imported'
      else
        'Estimated new messages: comparison unavailable',
      if (dryRunEstimate.isAvailable)
        'Estimated duplicates: ${dryRunEstimate.duplicateGuidCount} comparable source rows already imported'
      else
        'Estimated duplicates: comparison unavailable',
    ],
    activityLog: [
      HistoricalArchivesLogEntryViewModel(
        label: 'Reading archive…',
        message: 'Read source counts from ${inspection.sourceLabel}.',
      ),
      HistoricalArchivesLogEntryViewModel(
        label: dryRunEstimate.isAvailable
            ? 'Dry run ready'
            : 'Dry run unavailable',
        message: dryRunEstimate.isAvailable
            ? 'Compared ${dryRunEstimate.comparableGuidCount} source rows against existing imported messages.'
            : dryRunEstimate.unavailableReason!,
      ),
      const HistoricalArchivesLogEntryViewModel(
        label: 'Preflight complete',
        message:
            'The selected archive folder passed source checks and is ready for archive import.',
      ),
    ],
    phases: const [
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Reading archive source',
        status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
        detail: 'Archive source metadata and counts were read successfully.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Preparing archive records',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Normalization begins when you run archive import.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Importing archive messages',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Archive import begins when you run Begin Import.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Preparing messages for browsing',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Graph projection begins only after successful archive import.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Rebuilding indexes/search/heatmap support tables',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Rebuild steps are still waiting.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Refreshing shared evidence surfaces',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail:
            'Shared message evidence surfaces are unchanged until refresh completes.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Complete',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'No archive workflow has completed yet.',
      ),
    ],
  );
}

bool _isInvalidFolderQualificationFailure(
  HistoricalArchivesFolderPreflightResult result,
) {
  return result.chatDbStatus == ArchiveSourceInspectionStatus.missing;
}

final class _UnavailableArchiveSourceInspector
    implements ArchiveSourceInspector {
  const _UnavailableArchiveSourceInspector();

  @override
  Future<ArchiveSourceInspection> inspectFolder({
    required String folderPath,
  }) async {
    return ArchiveSourceInspection(
      folderPath: folderPath,
      sourceLabel: path.basename(folderPath),
      chatDbPath: path.join(folderPath, 'chat.db'),
      chatDbStatus: ArchiveSourceInspectionStatus.unavailable,
      attachmentsStatusLabel: 'Unavailable',
      detail:
          'Archive source inspection is unavailable because the inspection service could not be constructed.',
      dryRunEstimate: const ArchiveSourceDryRunEstimate.unavailable(
        unavailableReason: 'archive source inspection service unavailable.',
      ),
    );
  }
}

HistoricalArchivesWorkflowState _workflowStateFromPreflightResult(
  HistoricalArchivesFolderPreflightResult result, {
  required SameMessagesLineageAdmission lineageAdmission,
}) {
  final data = HistoricalArchivesPresentationData(
    preflight: result.preflight,
    selectedFolderPath: result.selectedFolderPath,
    archiveRemovalTargetChatDbPath: result.archiveRemovalTargetChatDbPath,
    chatDbStatus: result.chatDbStatus,
    attachmentsStatusLabel: result.attachmentsStatusLabel,
    sourceLabel: result.sourceLabel,
    preflightSummaryLines: result.preflightSummaryLines,
    dryRunSummaryLines: result.dryRunSummaryLines,
    importSafetySummaryLines:
        _historicalArchivesHubPresentationData.importSafetySummaryLines,
    resultSummaryLines:
        _historicalArchivesHubPresentationData.resultSummaryLines,
    activityLog: result.activityLog,
    phases: result.phases,
  );
  final evidence = HistoricalArchivesInspectionEvidence(
    sourceIdentity: result.sourceIdentity,
    folderPath: result.selectedFolderPath,
    chatDbPath: result.archiveRemovalTargetChatDbPath,
    sourceLabel: result.sourceLabel,
    chatDbStatus: result.chatDbStatus,
    attachmentsStatusLabel: result.attachmentsStatusLabel,
    totalMessages: result.totalMessages,
    totalChats: result.totalChats,
    totalHandles: result.totalHandles,
    missingGuids: result.missingGuids,
    earliestMessageUtc: result.earliestMessageUtc,
    latestMessageUtc: result.latestMessageUtc,
    dateRangeUnavailableReason: result.dateRangeUnavailableReason,
    dryRunNewMessages: result.dryRunNewMessages,
    dryRunDuplicateMessages: result.dryRunDuplicateMessages,
    dryRunComparableMessages: result.dryRunComparableMessages,
    dryRunUnavailableReason: result.dryRunUnavailableReason,
  );
  return HistoricalArchivesWorkflowState(
    presentation:
        result.preflight.status ==
            HistoricalArchivesPreflightStatus.completeReadyToImport
        ? HistoricalArchivesReadyToAddState(
            data: data,
            evidence: evidence,
            lineageAdmission: lineageAdmission,
          )
        : HistoricalArchivesInspectionFailedState(
            data: data,
            evidence: evidence,
          ),
  );
}

HistoricalArchivesWorkflowState _workflowStateFromKnownSourceMetadata(
  HistoricalArchiveSourceMetadata source, {
  required int importedMessageCount,
  required HistoricalArchiveSourceIdentity selectedKnownSourceIdentity,
}) {
  final facts = HistoricalArchivesImportedSourceFacts(
    identity: selectedKnownSourceIdentity,
    importedMessageCount: importedMessageCount,
    earliestMessageUtc: source.earliestMessageUtc,
    latestMessageUtc: source.latestMessageUtc,
    successfulImportFinishedAtUtc: source.lastImportSuccess == true
        ? source.lastImportFinishedAtUtc
        : null,
  );
  final data = HistoricalArchivesPresentationData(
    preflight: const HistoricalArchivesPreflightViewModel(
      status: HistoricalArchivesPreflightStatus.waitingForFolder,
      statusLabel: 'Already imported',
      detail:
          'The source-scoped import ledger contains messages for this archive.',
    ),
    selectedFolderPath: source.folderPath,
    archiveRemovalTargetChatDbPath: source.sourceChatDb,
    chatDbStatus: ArchiveSourceInspectionStatus.readable,
    attachmentsStatusLabel: source.attachmentsStatusLabel,
    sourceLabel: source.sourceLabel,
    preflightSummaryLines: const [],
    dryRunSummaryLines: const [],
    importSafetySummaryLines:
        _historicalArchivesHubPresentationData.importSafetySummaryLines,
    resultSummaryLines:
        _historicalArchivesHubPresentationData.resultSummaryLines,
    activityLog: const [],
    phases: _historicalArchivesHubPresentationData.phases,
  );
  return HistoricalArchivesWorkflowState(
    presentation: HistoricalArchivesExistingSourceState(
      data: data,
      facts: facts,
    ),
  );
}

HistoricalArchivesFolderPreflightResult _failedPreflightResult({
  required String folderPath,
  required String sourceLabel,
  required String detail,
  required String archiveRemovalTargetChatDbPath,
  required ArchiveSourceInspectionStatus chatDbStatus,
  required String attachmentsStatusLabel,
}) {
  return HistoricalArchivesFolderPreflightResult(
    sourceIdentity: null,
    preflight: HistoricalArchivesPreflightViewModel(
      status: HistoricalArchivesPreflightStatus.failed,
      statusLabel: 'Preflight failed',
      detail: detail,
    ),
    selectedFolderPath: folderPath,
    archiveRemovalTargetChatDbPath: archiveRemovalTargetChatDbPath,
    chatDbStatus: chatDbStatus,
    attachmentsStatusLabel: attachmentsStatusLabel,
    sourceLabel: sourceLabel,
    totalMessages: null,
    totalChats: null,
    totalHandles: null,
    missingGuids: null,
    earliestMessageUtc: null,
    latestMessageUtc: null,
    dryRunNewMessages: null,
    dryRunDuplicateMessages: null,
    dryRunComparableMessages: null,
    preflightSummaryLines: const [
      'Total messages: unavailable',
      'Total chats: unavailable',
      'Total handles: unavailable',
      'Rows with missing GUIDs: unavailable',
      'Earliest message: unavailable',
      'Latest message: unavailable',
      'Likely already imported: unavailable',
      'Likely new rows: unavailable',
    ],
    dryRunSummaryLines: const [
      'Estimated new messages: unavailable',
      'Estimated duplicates: unavailable',
    ],
    activityLog: [
      HistoricalArchivesLogEntryViewModel(
        label: 'Preflight failed',
        message: detail,
      ),
    ],
    phases: const [
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Reading archive source',
        status: HistoricalArchivesWorkflowPhaseStatus.failed,
        detail: 'Archive source validation failed.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Preparing archive records',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Importing archive messages',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Preparing messages for browsing',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Rebuilding indexes/search/heatmap support tables',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Refreshing shared evidence surfaces',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Complete',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'No archive workflow has completed yet.',
      ),
    ],
  );
}

String _dateSummaryLabel(String? utcIsoString) {
  final parsed = utcIsoString == null ? null : DateTime.tryParse(utcIsoString);
  if (parsed == null) {
    return 'unavailable';
  }

  final utc = parsed.toUtc();
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '${utc.year}-$month-$day';
}

bool _isCurrentMacChatDbPath(
  String sourceChatDbPath, {
  required String currentMessagesDatabasePath,
}) {
  return path.normalize(sourceChatDbPath) ==
      path.normalize(currentMessagesDatabasePath);
}

List<HistoricalArchivesWorkflowPhaseViewModel> _runningPreflightPhases() {
  return const [
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Reading archive source',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail: 'Inspecting folder structure and source counts.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Preparing archive records',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Importing archive messages',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Preparing messages for browsing',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing shared evidence surfaces',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'No archive workflow has completed yet.',
    ),
  ];
}

HistoricalArchiveRemovalProgress _failedCurrentRemovalProgress(
  HistoricalArchiveRemovalProgress progress,
) {
  final failedStage =
      progress.runningStage ??
      HistoricalArchiveRemovalStage.values.firstWhere(
        (stage) =>
            progress.statusFor(stage) ==
            HistoricalArchiveRemovalStageStatus.waiting,
        orElse: () => HistoricalArchiveRemovalStage.verifyingRemoval,
      );
  return progress.withStage(
    failedStage,
    HistoricalArchiveRemovalStageStatus.failed,
  );
}

List<HistoricalArchivesInstrumentationRowViewModel> _removalInstrumentationRows(
  HistoricalArchiveRemovalProgress progress,
) {
  final rows = <HistoricalArchivesInstrumentationRowViewModel>[
    HistoricalArchivesInstrumentationRowViewModel(
      label: _removalStageLabel(
        HistoricalArchiveRemovalStage.removingImportedMessages,
      ),
      value: _removalStageValue(progress.removingImportedMessages),
      status: _removalInstrumentationStatus(progress.removingImportedMessages),
    ),
    HistoricalArchivesInstrumentationRowViewModel(
      label: _removalStageLabel(
        HistoricalArchiveRemovalStage.updatingMessageLensHistory,
      ),
      value: _removalStageValue(progress.updatingMessageLensHistory),
      status: _removalInstrumentationStatus(
        progress.updatingMessageLensHistory,
      ),
    ),
  ];
  final projection = progress.graphProjectionProgress;
  if (projection != null) {
    rows.addAll(
      _graphProjectionInstrumentationRows(
        projection: projection,
        stageSucceeded:
            progress.updatingMessageLensHistory ==
            HistoricalArchiveRemovalStageStatus.succeeded,
        stageFailed:
            progress.updatingMessageLensHistory ==
            HistoricalArchiveRemovalStageStatus.failed,
      ),
    );
  }
  rows.add(
    HistoricalArchivesInstrumentationRowViewModel(
      label: _removalStageLabel(HistoricalArchiveRemovalStage.verifyingRemoval),
      value: _removalStageValue(progress.verifyingRemoval),
      status: _removalInstrumentationStatus(progress.verifyingRemoval),
    ),
  );
  return rows;
}

String? _removalNarratorText(HistoricalArchiveRemovalProgress progress) {
  if (progress.verifyingRemoval !=
      HistoricalArchiveRemovalStageStatus.waiting) {
    return null;
  }
  if (progress.updatingMessageLensHistory !=
      HistoricalArchiveRemovalStageStatus.waiting) {
    return 'Those messages are removed. Now I’m updating your remaining '
        'MessageLens history so everything stays together.';
  }
  return 'Removing the messages added from this folder.';
}

List<HistoricalArchivesWorkflowPhaseViewModel> _archiveRemovalPhases(
  HistoricalArchiveRemovalProgress progress, {
  String? failureDetail,
}) {
  return [
    for (final stage in HistoricalArchiveRemovalStage.values)
      HistoricalArchivesWorkflowPhaseViewModel(
        label: _removalStageLabel(stage),
        status: _removalWorkflowPhaseStatus(progress.statusFor(stage)),
        detail:
            progress.statusFor(stage) ==
                    HistoricalArchiveRemovalStageStatus.failed &&
                failureDetail != null
            ? failureDetail
            : _removalStageValue(progress.statusFor(stage)),
      ),
  ];
}

String _removalStageLabel(HistoricalArchiveRemovalStage stage) {
  return switch (stage) {
    HistoricalArchiveRemovalStage.removingImportedMessages =>
      'Removing messages added from this folder',
    HistoricalArchiveRemovalStage.updatingMessageLensHistory =>
      'Updating your MessageLens history',
    HistoricalArchiveRemovalStage.verifyingRemoval =>
      'Checking that removal finished',
  };
}

String _removalStageValue(HistoricalArchiveRemovalStageStatus status) {
  return switch (status) {
    HistoricalArchiveRemovalStageStatus.waiting => 'Waiting',
    HistoricalArchiveRemovalStageStatus.running => 'Working',
    HistoricalArchiveRemovalStageStatus.succeeded => 'Done',
    HistoricalArchiveRemovalStageStatus.skipped => 'Not needed',
    HistoricalArchiveRemovalStageStatus.failed => "Couldn't finish",
  };
}

HistoricalArchivesInstrumentationStatus _removalInstrumentationStatus(
  HistoricalArchiveRemovalStageStatus status,
) {
  return switch (status) {
    HistoricalArchiveRemovalStageStatus.waiting =>
      HistoricalArchivesInstrumentationStatus.waiting,
    HistoricalArchiveRemovalStageStatus.running =>
      HistoricalArchivesInstrumentationStatus.working,
    HistoricalArchiveRemovalStageStatus.succeeded ||
    HistoricalArchiveRemovalStageStatus.skipped =>
      HistoricalArchivesInstrumentationStatus.resolved,
    HistoricalArchiveRemovalStageStatus.failed =>
      HistoricalArchivesInstrumentationStatus.failed,
  };
}

HistoricalArchivesWorkflowPhaseStatus _removalWorkflowPhaseStatus(
  HistoricalArchiveRemovalStageStatus status,
) {
  return switch (status) {
    HistoricalArchiveRemovalStageStatus.waiting =>
      HistoricalArchivesWorkflowPhaseStatus.waiting,
    HistoricalArchiveRemovalStageStatus.running =>
      HistoricalArchivesWorkflowPhaseStatus.running,
    HistoricalArchiveRemovalStageStatus.succeeded =>
      HistoricalArchivesWorkflowPhaseStatus.succeeded,
    HistoricalArchiveRemovalStageStatus.skipped =>
      HistoricalArchivesWorkflowPhaseStatus.skipped,
    HistoricalArchiveRemovalStageStatus.failed =>
      HistoricalArchivesWorkflowPhaseStatus.failed,
  };
}

String _describeExecutionOwnerLabel(String? owner) {
  return switch (owner) {
    'db-import-control' => 'Source import or graph projection',
    'chat-db-monitor' => 'Automatic chat monitor import',
    null => 'Another workflow',
    _ => 'Execution owner "$owner"',
  };
}

String _describeExecutionOwnerPhrase(String? owner) {
  return switch (owner) {
    'db-import-control' => 'source import or graph projection',
    'chat-db-monitor' => 'automatic chat monitor import',
    null => 'another workflow',
    _ => 'execution owner "$owner"',
  };
}

HistoricalArchiveSourceIdentity _requireReadableSourceIdentity(
  HistoricalArchiveSourceIdentity? identity,
) {
  if (identity == null) {
    throw StateError('Readable archive source has no canonical identity.');
  }
  return identity;
}
