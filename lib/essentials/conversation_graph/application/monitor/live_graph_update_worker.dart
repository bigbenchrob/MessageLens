import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/attachments/feature_level_providers.dart'
    show AttachmentArchiveResult, attachmentArchiveServiceProvider;
import '../../../db/feature_level_providers/conversation_graph_readiness_provider.dart'
    show conversationGraphReadinessProvider;
import '../../../paths/feature_level_providers.dart' show pathsHelperProvider;
import '../../../source_scoped_import/domain/known_sources.dart';
import '../conversation_graph_build_controller_provider.dart';
import '../conversation_graph_build_observation.dart';
import '../conversation_graph_build_report.dart';
import 'chat_db_source_probe_reader_provider.dart';
import 'import_ledger_probe_reader_provider.dart';

part 'live_graph_update_worker.g.dart';

enum StartupProbeTrigger { rowIdAdvanced, ledgerCountLagging }

final class StartupProbeDecision {
  const StartupProbeDecision({
    required this.shouldSchedule,
    required this.reason,
    this.trigger,
  });

  final bool shouldSchedule;
  final String reason;
  final StartupProbeTrigger? trigger;
}

StartupProbeDecision resolveStartupProbeDecision({
  required int liveMaxRowId,
  required int? importedMaxSourceRowId,
  required int liveImportableMessageCount,
  required int importedMessageCount,
}) {
  if (importedMaxSourceRowId == null) {
    return const StartupProbeDecision(
      shouldSchedule: false,
      reason: 'no imported cursor available',
    );
  }

  if (liveMaxRowId > importedMaxSourceRowId) {
    return const StartupProbeDecision(
      shouldSchedule: true,
      trigger: StartupProbeTrigger.rowIdAdvanced,
      reason: 'live MAX(ROWID) is ahead of imported MAX(source_rowid)',
    );
  }

  if (liveImportableMessageCount > importedMessageCount) {
    return const StartupProbeDecision(
      shouldSchedule: true,
      trigger: StartupProbeTrigger.ledgerCountLagging,
      reason: 'live importable message count exceeds imported message count',
    );
  }

  return const StartupProbeDecision(
    shouldSchedule: false,
    reason: 'ledger cursor and importable message count are current',
  );
}

@visibleForTesting
Future<T> runGraphMutationBeforeAttachmentPreservation<T>({
  required Future<T> Function() runGraphMutation,
  required Future<void> Function(T graphResult) preserveAttachments,
}) async {
  final graphResult = await runGraphMutation();
  await preserveAttachments(graphResult);
  return graphResult;
}

final class LiveGraphUpdatePrerequisiteSnapshot {
  const LiveGraphUpdatePrerequisiteSnapshot({
    required this.appDataReady,
    required this.liveMaxRowId,
    required this.importedMaxSourceRowId,
    required this.liveImportableMessageCount,
    required this.importedMessageCount,
  });

  final bool appDataReady;
  final int liveMaxRowId;
  final int? importedMaxSourceRowId;
  final int liveImportableMessageCount;
  final int importedMessageCount;

  int get messagesToImport {
    final delta = liveImportableMessageCount - importedMessageCount;
    return delta > 0 ? delta : 0;
  }
}

enum LiveGraphUpdateObservationKind {
  checkingPrerequisites,
  prerequisitesRead,
  graphBuild,
  preservingAttachments,
  attachmentsPreserved,
}

final class LiveGraphUpdateObservation {
  const LiveGraphUpdateObservation._({
    required this.kind,
    this.prerequisites,
    this.graphBuild,
    this.attachmentResult,
  });

  const LiveGraphUpdateObservation.checkingPrerequisites()
    : this._(kind: LiveGraphUpdateObservationKind.checkingPrerequisites);

  const LiveGraphUpdateObservation.prerequisitesRead(
    LiveGraphUpdatePrerequisiteSnapshot prerequisites,
  ) : this._(
        kind: LiveGraphUpdateObservationKind.prerequisitesRead,
        prerequisites: prerequisites,
      );

  const LiveGraphUpdateObservation.graphBuild(
    ConversationGraphBuildObservation observation,
  ) : this._(
        kind: LiveGraphUpdateObservationKind.graphBuild,
        graphBuild: observation,
      );

  const LiveGraphUpdateObservation.preservingAttachments()
    : this._(kind: LiveGraphUpdateObservationKind.preservingAttachments);

  const LiveGraphUpdateObservation.attachmentsPreserved(
    AttachmentArchiveResult result,
  ) : this._(
        kind: LiveGraphUpdateObservationKind.attachmentsPreserved,
        attachmentResult: result,
      );

  final LiveGraphUpdateObservationKind kind;
  final LiveGraphUpdatePrerequisiteSnapshot? prerequisites;
  final ConversationGraphBuildObservation? graphBuild;
  final AttachmentArchiveResult? attachmentResult;
}

typedef LiveGraphUpdateObserver =
    void Function(LiveGraphUpdateObservation observation);

final class LiveGraphUpdateResult {
  const LiveGraphUpdateResult({
    required this.prerequisites,
    required this.decision,
    this.graphBuildReport,
    this.attachmentResult,
  });

  final LiveGraphUpdatePrerequisiteSnapshot prerequisites;
  final StartupProbeDecision decision;
  final ConversationGraphBuildReport? graphBuildReport;
  final AttachmentArchiveResult? attachmentResult;

  bool get performedUpdate => graphBuildReport != null;
}

final class LiveGraphUpdatePrerequisiteException extends StateError {
  LiveGraphUpdatePrerequisiteException(super.message);
}

final class LiveGraphUpdateWorker {
  const LiveGraphUpdateWorker({
    required Future<LiveGraphUpdatePrerequisiteSnapshot> Function()
    readPrerequisites,
    required Future<ConversationGraphBuildReport> Function(
      ConversationGraphBuildObserver observer,
    )
    runGraphBuild,
    required Future<AttachmentArchiveResult> Function(
      ConversationGraphBuildReport report,
    )
    preserveAttachments,
  }) : _readPrerequisites = readPrerequisites,
       _runGraphBuild = runGraphBuild,
       _preserveAttachments = preserveAttachments;

  final Future<LiveGraphUpdatePrerequisiteSnapshot> Function()
  _readPrerequisites;
  final Future<ConversationGraphBuildReport> Function(
    ConversationGraphBuildObserver observer,
  )
  _runGraphBuild;
  final Future<AttachmentArchiveResult> Function(
    ConversationGraphBuildReport report,
  )
  _preserveAttachments;

  Future<LiveGraphUpdateResult> run({
    LiveGraphUpdateObserver? onObservation,
  }) async {
    onObservation?.call(
      const LiveGraphUpdateObservation.checkingPrerequisites(),
    );
    final prerequisites = await _readPrerequisites();
    onObservation?.call(
      LiveGraphUpdateObservation.prerequisitesRead(prerequisites),
    );

    if (!prerequisites.appDataReady) {
      throw LiveGraphUpdatePrerequisiteException(
        'The complete local message dataset is no longer ready for an incremental update.',
      );
    }

    final decision = resolveStartupProbeDecision(
      liveMaxRowId: prerequisites.liveMaxRowId,
      importedMaxSourceRowId: prerequisites.importedMaxSourceRowId,
      liveImportableMessageCount: prerequisites.liveImportableMessageCount,
      importedMessageCount: prerequisites.importedMessageCount,
    );
    if (!decision.shouldSchedule) {
      return LiveGraphUpdateResult(
        prerequisites: prerequisites,
        decision: decision,
      );
    }

    late AttachmentArchiveResult attachmentResult;
    final report = await runGraphMutationBeforeAttachmentPreservation(
      runGraphMutation: () {
        return _runGraphBuild((observation) {
          onObservation?.call(
            LiveGraphUpdateObservation.graphBuild(observation),
          );
        });
      },
      preserveAttachments: (completedReport) async {
        onObservation?.call(
          const LiveGraphUpdateObservation.preservingAttachments(),
        );
        attachmentResult = await _preserveAttachments(completedReport);
        onObservation?.call(
          LiveGraphUpdateObservation.attachmentsPreserved(attachmentResult),
        );
      },
    );

    return LiveGraphUpdateResult(
      prerequisites: prerequisites,
      decision: decision,
      graphBuildReport: report,
      attachmentResult: attachmentResult,
    );
  }
}

@Riverpod(keepAlive: true)
Future<LiveGraphUpdateWorker> liveGraphUpdateWorker(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final sourceProbeReader = ref.watch(chatDbSourceProbeReaderProvider);
  final importLedgerProbeReader = await ref.watch(
    importLedgerProbeReaderProvider.future,
  );

  return LiveGraphUpdateWorker(
    readPrerequisites: () async {
      final readiness = await ref.read(
        conversationGraphReadinessProvider.future,
      );
      final liveMaxRowId = sourceProbeReader.readMaxRowId(
        pathsHelper.chatDBPath,
      );
      final liveImportableMessageCount = sourceProbeReader
          .readImportableMessageCount(pathsHelper.chatDBPath);
      final importLedgerSnapshot = await importLedgerProbeReader.readForSource(
        liveChatDbSourceId,
      );
      return LiveGraphUpdatePrerequisiteSnapshot(
        appDataReady: readiness.isReady,
        liveMaxRowId: liveMaxRowId,
        importedMaxSourceRowId: importLedgerSnapshot.maxSourceRowId,
        liveImportableMessageCount: liveImportableMessageCount,
        importedMessageCount: importLedgerSnapshot.messageCount,
      );
    },
    runGraphBuild: (observer) {
      return ref
          .read(conversationGraphBuildControllerProvider.notifier)
          .runOnce(owner: 'live-graph-update-worker', onObservation: observer);
    },
    preserveAttachments: (report) {
      return ref
          .read(attachmentArchiveServiceProvider.notifier)
          .archiveGraphMessageSourceRange(
            sourceId: liveChatDbSourceId,
            startedAfterSourceRowId:
                report.messageImportResult.startedAfterSourceRowId,
            lastImportedSourceRowId:
                report.messageImportResult.lastImportedSourceRowId,
          );
    },
  );
}
