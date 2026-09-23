import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/attachments/feature_level_providers.dart'
    show
        BulkArchivePhase,
        attachmentArchiveLocationProvider,
        attachmentArchiveServiceProvider,
        shouldScheduleBoundedAttachmentArchiveReconnectSweep;
import '../../../archive_environment/domain.dart'
    show ArchiveMutationDeniedException, ArchiveMutationOperation;
import '../../../archive_environment/feature_level_providers.dart'
    show ArchiveMutationCoordinatorState, archiveMutationCoordinatorProvider;
import '../../../db/feature_level_providers/conversation_graph_readiness_provider.dart'
    show conversationGraphReadinessProvider;
import '../../../db/feature_level_providers/message_data_version_provider.dart'
    show messageDataVersionProvider;
import '../../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../../paths/feature_level_providers.dart' show pathsHelperProvider;
import '../../../source_scoped_import/domain/known_sources.dart';
import '../conversation_graph_build_controller_provider.dart';
import '../conversation_graph_build_report.dart';
import '../conversation_graph_build_service_provider.dart';
import 'chat_db_monitor_runtime_environment_provider.dart';
import 'chat_db_source_probe_reader.dart';
import 'chat_db_source_probe_reader_provider.dart';
import 'import_ledger_probe_reader_provider.dart';

part 'chat_db_change_monitor_provider.g.dart';

enum StartupProbeTrigger { rowIdAdvanced, ledgerCountLagging }

const _chatDbMonitorExecutionOwner = 'chat-db-monitor';

class StartupProbeDecision {
  const StartupProbeDecision({
    required this.shouldSchedule,
    required this.reason,
    this.trigger,
  });

  final bool shouldSchedule;
  final String reason;
  final StartupProbeTrigger? trigger;
}

@visibleForTesting
bool shouldAllowAutomaticIncrementalWork({required bool appDataReady}) {
  return appDataReady;
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

@visibleForTesting
String buildConversationGraphBuildSummaryLog({
  required ConversationGraphBuildReport report,
}) {
  final timeLabel = _formatLocalClockTime(report.finishedAt);
  final durationMs = report.finishedAt
      .difference(report.startedAt)
      .inMilliseconds;
  final slowestStageLabel = _formatSlowestGraphBuildStage(report);
  return 'Conversation graph build at $timeLabel completed in ${durationMs}ms: '
      '${report.completedStageNames.length} stage(s), '
      '${report.messageImportResult.insertedMessageCount} imported graph message(s), '
      '${report.richTextEnrichmentResult.enrichedMessageCount} enriched text row(s), '
      '${report.messageProjectionResult.insertedMessageCount} projected graph message row(s), '
      'slowest stage: $slowestStageLabel.';
}

@visibleForTesting
String buildChatDbPollingFailureMessage(Object error) {
  return 'chat.db polling read failed: $error';
}

String _formatSlowestGraphBuildStage(ConversationGraphBuildReport report) {
  if (report.stageTimings.isEmpty) {
    return 'no stage timings';
  }
  final slowestStage = report.stageTimings.reduce((left, right) {
    return left.durationMs >= right.durationMs ? left : right;
  });
  return '${slowestStage.stageName} ${slowestStage.durationMs}ms';
}

@visibleForTesting
StartupProbeDecision gateStartupProbeDecisionForAppDataReadiness({
  required StartupProbeDecision decision,
  required bool appDataReady,
}) {
  if (!decision.shouldSchedule || appDataReady) {
    return decision;
  }

  return const StartupProbeDecision(
    shouldSchedule: false,
    reason: 'app data graph is not ready; skipping automatic graph update',
  );
}

@visibleForTesting
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

class ChatDbChangeMonitorState {
  const ChatDbChangeMonitorState({
    this.lastMaxRowId,
    this.lastChangeDetected,
    this.lastError,
  });

  final int? lastMaxRowId;
  final DateTime? lastChangeDetected;
  final String? lastError;

  ChatDbChangeMonitorState copyWith({
    int? lastMaxRowId,
    DateTime? lastChangeDetected,
    String? lastError,
    bool clearError = false,
  }) {
    return ChatDbChangeMonitorState(
      lastMaxRowId: lastMaxRowId ?? this.lastMaxRowId,
      lastChangeDetected: lastChangeDetected ?? this.lastChangeDetected,
      lastError: clearError ? null : lastError ?? this.lastError,
    );
  }
}

@Riverpod(keepAlive: true)
class ChatDbChangeMonitor extends _$ChatDbChangeMonitor {
  static const Duration _attachmentSweepInterval = Duration(minutes: 5);

  Timer? _debounceTimer;
  Timer? _pollingTimer;
  Timer? _attachmentSweepTimer;
  bool _importInFlight = false;
  bool _attachmentSweepInFlight = false;
  bool _pendingProbe = false;
  bool _retryWhenGateReleases = false;
  String? _chatDbPath;
  StartupProbeTrigger? _pendingProbeTrigger;
  late ChatDbSourceProbeReader _sourceProbeReader;

  @override //#FLOW:chatdb:build
  ChatDbChangeMonitorState build() {
    _sourceProbeReader = ref.read(chatDbSourceProbeReaderProvider);
    final runtimeEnvironment = ref.read(
      chatDbMonitorRuntimeEnvironmentProvider,
    );
    if (!runtimeEnvironment.supportsChatDbMonitoring) {
      return const ChatDbChangeMonitorState();
    }

    //#FLOW:chatdb:gate-listener
    ref.listen(archiveMutationCoordinatorProvider, _handleExecutionGateChange);
    ref.listen(attachmentArchiveLocationProvider, (previous, next) {
      final before = previous?.valueOrNull;
      final current = next.valueOrNull;
      if (current != null &&
          shouldScheduleBoundedAttachmentArchiveReconnectSweep(
            previous: before,
            current: current,
          )) {
        unawaited(_runAttachmentSweep());
      }
    });
    // #FLOW:chatdb:init
    // Resolves chat.db path and starts monitor setup.
    //#FLOW:chatdb:init-call
    unawaited(_initialize());

    ref.onDispose(() {
      _debounceTimer?.cancel();
      _pollingTimer?.cancel();
      _attachmentSweepTimer?.cancel();
    });

    return const ChatDbChangeMonitorState();
  }

  Future<void> _initialize() async {
    try {
      final pathsHelper = await ref.read(pathsHelperProvider.future);
      final chatDbPath = pathsHelper.chatDBPath;
      _chatDbPath = chatDbPath;

      await _reconcileLocalAccountHandleIdentity();
      await _primeMaxRowId(chatDbPath);

      // Immediate startup check catches messages that arrived while the app
      // was closed, before the regular polling interval begins.
      await _checkForNewMessagesOnStartup(chatDbPath);

      _startPolling(chatDbPath);
      _startAttachmentSweep();
    } catch (error, stackTrace) {
      _handleError('Failed to initialize chat.db monitor: $error', stackTrace);
    }
  }

  Future<void> _reconcileLocalAccountHandleIdentity() async {
    try {
      await ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .run<void>(
            operation:
                ArchiveMutationOperation.localAccountIdentityReconciliation,
            ownerLabel: _chatDbMonitorExecutionOwner,
            action: () async {
              final graphBuildService = await ref.read(
                conversationGraphBuildServiceProvider.future,
              );
              final report = await graphBuildService
                  .reconcileLocalAccountHandleIdentity();
              if (report.updatedGraphHandleCount > 0) {
                ref.read(messageDataVersionProvider.notifier).bump();
              }
              ref
                  .read(appLoggerProvider.notifier)
                  .info(
                    'Local-account handle reconciliation examined '
                    '${report.examinedHandleCount} imported handle(s), identified '
                    '${report.localAccountHandleCount} local handle(s), updated '
                    '${report.updatedImportHandleCount} import annotation(s), and projected '
                    '${report.updatedGraphHandleCount} graph annotation(s).',
                    source: 'ChatDbMonitor',
                  );
            },
          );
    } on ArchiveMutationDeniedException {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Skipped local-account handle reconciliation because another archive mutation owns execution authority.',
            source: 'ChatDbMonitor',
          );
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Local-account handle reconciliation failed: $error',
            source: 'ChatDbMonitor',
            context: {'stackTrace': '$stackTrace'},
          );
    }
  }

  Future<void> _runLiveGraphUpdate({
    required StartupProbeTrigger pendingTrigger,
    required int currentMaxRowId,
    required DateTime now,
    required DateTime updateStartedAt,
    required int newMessageCount,
  }) async {
    await runGraphMutationBeforeAttachmentPreservation(
      runGraphMutation: () {
        return ref
            .read(archiveMutationCoordinatorProvider.notifier)
            .run<ConversationGraphBuildReport>(
              operation: ArchiveMutationOperation.liveGraphUpdate,
              ownerLabel: _chatDbMonitorExecutionOwner,
              action: () async {
                ref
                    .read(appLoggerProvider.notifier)
                    .info(
                      'Building app-facing conversation graph before attachment archive',
                      source: 'ChatDbMonitor',
                    );
                ref
                    .read(appLoggerProvider.notifier)
                    .info(
                      'Triggering conversation graph build',
                      source: 'ChatDbMonitor',
                    );

                final graphBuildReport = await ref
                    .read(conversationGraphBuildControllerProvider.notifier)
                    .runOnce(owner: _chatDbMonitorExecutionOwner);
                ref
                    .read(appLoggerProvider.notifier)
                    .info(
                      buildConversationGraphBuildSummaryLog(
                        report: graphBuildReport,
                      ),
                      source: 'ChatDbMonitor',
                    );
                state = state.copyWith(
                  lastMaxRowId: currentMaxRowId,
                  lastChangeDetected: now,
                  clearError: true,
                );

                _logLiveGraphUpdateComplete(
                  pendingTrigger: pendingTrigger,
                  updateStartedAt: updateStartedAt,
                  newMessageCount: newMessageCount,
                  graphBuildReport: graphBuildReport,
                );
                return graphBuildReport;
              },
            );
      },
      // Graph mutation authority has ended before this callback begins. The
      // attachment archive acquires its own mutation scope and therefore does
      // not prolong the graph update while it hashes and copies payloads.
      preserveAttachments: (graphBuildReport) async {
        try {
          final archiveResult = await ref
              .read(attachmentArchiveServiceProvider.notifier)
              .archiveGraphMessageSourceRange(
                sourceId: liveChatDbSourceId,
                startedAfterSourceRowId: graphBuildReport
                    .messageImportResult
                    .startedAfterSourceRowId,
                lastImportedSourceRowId: graphBuildReport
                    .messageImportResult
                    .lastImportedSourceRowId,
              );
          ref
              .read(appLoggerProvider.notifier)
              .info(
                'Graph attachment archive completed: '
                '${archiveResult.newlyArchived} archived, '
                '${archiveResult.skipped} skipped, '
                '${archiveResult.failed} failed.',
                source: 'ChatDbMonitor',
              );
        } on ArchiveMutationDeniedException {
          ref
              .read(appLoggerProvider.notifier)
              .debug(
                'Deferred attachment preservation because another archive '
                'mutation acquired authority after the graph update. The '
                'rolling attachment sweep remains responsible for '
                'convergence.',
                source: 'ChatDbMonitor',
              );
        }
      },
    );
  }

  /// Check for new messages immediately on startup.
  ///
  /// This catches messages that arrived while the app was closed, before the
  /// first polling interval begins.
  Future<void> _checkForNewMessagesOnStartup(String chatDbPath) async {
    try {
      final importLedgerProbeReader = await ref.read(
        importLedgerProbeReaderProvider.future,
      );
      final currentMaxRowId = _readMaxRowId(chatDbPath);
      final importLedgerSnapshot = await importLedgerProbeReader.readForSource(
        liveChatDbSourceId,
      );
      final importedMaxRowId = importLedgerSnapshot.maxSourceRowId;
      final liveImportableMessageCount = _readImportableMessageCount(
        chatDbPath,
      );
      final importedMessageCount = importLedgerSnapshot.messageCount;
      final decision = resolveStartupProbeDecision(
        liveMaxRowId: currentMaxRowId,
        importedMaxSourceRowId: importedMaxRowId,
        liveImportableMessageCount: liveImportableMessageCount,
        importedMessageCount: importedMessageCount,
      );
      final summary =
          'Startup consistency probe: '
          'live MAX(ROWID)=$currentMaxRowId, '
          'graph import MAX(source_rowid)=${importedMaxRowId ?? 'null'}, '
          'live importable count=$liveImportableMessageCount, '
          'graph import message count=$importedMessageCount. '
          'Reason: ${decision.reason}.';

      if (decision.shouldSchedule && decision.trigger != null) {
        final gatedDecision = gateStartupProbeDecisionForAppDataReadiness(
          decision: decision,
          appDataReady: await _isAppDataReadyForAutomaticWork(),
        );
        if (!gatedDecision.shouldSchedule) {
          _logAppDataNotReadySkip();
          return;
        }

        ref
            .read(appLoggerProvider.notifier)
            .info(
              '$summary Scheduling live graph update.',
              source: 'ChatDbMonitor',
            );
        _scheduleProbe(trigger: decision.trigger!);
      } else {
        ref
            .read(appLoggerProvider.notifier)
            .info(
              '$summary No incremental work scheduled.',
              source: 'ChatDbMonitor',
            );
      }
    } catch (error, stackTrace) {
      // Non-fatal - polling will catch up
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Startup check failed: $error',
            source: 'ChatDbMonitor',
            context: {'stackTrace': '$stackTrace'},
          );
    }
  }

  Future<bool> _isAppDataReadyForAutomaticWork() async {
    final readiness = await ref.read(conversationGraphReadinessProvider.future);
    return shouldAllowAutomaticIncrementalWork(appDataReady: readiness.isReady);
  }

  void _logAppDataNotReadySkip() {
    ref
        .read(appLoggerProvider.notifier)
        .info(
          'app data graph is not ready; skipping automatic graph update.',
          source: 'ChatDbMonitor',
        );
  }

  Future<void> _primeMaxRowId(String chatDbPath) async {
    try {
      // CRITICAL: Prime from the source-scoped import ledger, not chat.db.
      // This ensures we detect messages that arrived before app launch
      // but after the last import batch completed.
      final importLedgerProbeReader = await ref.read(
        importLedgerProbeReaderProvider.future,
      );
      final importLedgerSnapshot = await importLedgerProbeReader.readForSource(
        liveChatDbSourceId,
      );
      final importedMaxRowId = importLedgerSnapshot.maxSourceRowId;

      // Use imported max if available, otherwise fall back to chat.db
      final maxRowId = importedMaxRowId ?? _readMaxRowId(chatDbPath);
      state = state.copyWith(lastMaxRowId: maxRowId, clearError: true);
    } catch (error, stackTrace) {
      _handleError('Unable to prime MAX(ROWID): $error', stackTrace);
    }
  }

  void _startPolling(String chatDbPath) {
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      try {
        final currentMaxRowId = _readMaxRowId(chatDbPath);
        final previousMaxRowId = state.lastMaxRowId;

        if (previousMaxRowId != null && currentMaxRowId > previousMaxRowId) {
          _scheduleProbe(trigger: StartupProbeTrigger.rowIdAdvanced);
        }
      } catch (error, stackTrace) {
        _handleError(buildChatDbPollingFailureMessage(error), stackTrace);
      }
    });
  }

  void _startAttachmentSweep() {
    _attachmentSweepTimer = Timer.periodic(_attachmentSweepInterval, (timer) {
      unawaited(_runAttachmentSweep());
    });
  }

  Future<void> _runAttachmentSweep() async {
    if (_importInFlight || _attachmentSweepInFlight) {
      return;
    }

    final archiveProgress = ref.read(attachmentArchiveServiceProvider);
    if (archiveProgress.phase == BulkArchivePhase.running ||
        archiveProgress.phase == BulkArchivePhase.paused) {
      return;
    }

    _attachmentSweepInFlight = true;

    try {
      final archiveService = ref.read(
        attachmentArchiveServiceProvider.notifier,
      );
      final sweepResult = await archiveService.archiveNextGraphSweepChunk();

      if (sweepResult.newlyArchived > 0 || sweepResult.failed > 0) {
        ref
            .read(appLoggerProvider.notifier)
            .info(
              'Attachment maintenance sweep completed: '
              '${sweepResult.newlyArchived} archived, '
              '${sweepResult.skipped} skipped, '
              '${sweepResult.failed} failed.',
              source: 'ChatDbMonitor',
            );
      }
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Attachment maintenance sweep failed: $error',
            source: 'ChatDbMonitor',
            context: {'stackTrace': '$stackTrace'},
          );
    } finally {
      _attachmentSweepInFlight = false;
    }
  }

  void _scheduleProbe({required StartupProbeTrigger trigger}) {
    _pendingProbe = true;
    _pendingProbeTrigger = switch ((_pendingProbeTrigger, trigger)) {
      (StartupProbeTrigger.ledgerCountLagging, _) =>
        StartupProbeTrigger.ledgerCountLagging,
      (_, StartupProbeTrigger.ledgerCountLagging) =>
        StartupProbeTrigger.ledgerCountLagging,
      _ => trigger,
    };
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      unawaited(_processPendingChanges());
    });
  }

  Future<void> _processPendingChanges() async {
    if (!_pendingProbe || _importInFlight) {
      return;
    }

    final chatDbPath = _chatDbPath;
    if (chatDbPath == null) {
      _pendingProbe = false;
      return;
    }

    _importInFlight = true;
    int? attemptPreviousMaxRowId;
    DateTime? attemptDetectedAt;

    try {
      while (_pendingProbe) {
        _pendingProbe = false;
        final pendingTrigger =
            _pendingProbeTrigger ?? StartupProbeTrigger.rowIdAdvanced;
        _pendingProbeTrigger = null;

        if (!await _isAppDataReadyForAutomaticWork()) {
          _logAppDataNotReadySkip();
          _restoreStableCursor(
            previousMaxRowId: attemptPreviousMaxRowId,
            detectedAt: attemptDetectedAt,
          );
          continue;
        }

        final currentMaxRowId = _readMaxRowId(chatDbPath);
        final previousMaxRowId = state.lastMaxRowId;
        final shouldBypassRowIdGate =
            pendingTrigger == StartupProbeTrigger.ledgerCountLagging;

        if (!shouldBypassRowIdGate &&
            previousMaxRowId != null &&
            currentMaxRowId <= previousMaxRowId) {
          continue;
        }

        final now = DateTime.now();
        final updateStartedAt = DateTime.now();
        final newMessageCount = previousMaxRowId != null
            ? currentMaxRowId - previousMaxRowId
            : 0;

        attemptPreviousMaxRowId = previousMaxRowId;
        attemptDetectedAt = now;
        state = state.copyWith(lastChangeDetected: now, clearError: true);

        ref
            .read(appLoggerProvider.notifier)
            .info(
              shouldBypassRowIdGate
                  ? 'Ledger inconsistency detected: live/imported counts diverged while MAX(ROWID) remained $currentMaxRowId. Running recovery import.'
                  : 'New messages detected: $newMessageCount message(s), MAX(ROWID): $previousMaxRowId → $currentMaxRowId',
              source: 'ChatDbMonitor',
            );

        ref
            .read(appLoggerProvider.notifier)
            .info('Triggering live graph update', source: 'ChatDbMonitor');

        try {
          await _runLiveGraphUpdate(
            pendingTrigger: pendingTrigger,
            currentMaxRowId: currentMaxRowId,
            now: now,
            updateStartedAt: updateStartedAt,
            newMessageCount: newMessageCount,
          );
        } on ArchiveMutationDeniedException {
          _retryWhenGateReleases = true;
          ref
              .read(appLoggerProvider.notifier)
              .debug(
                'Skipping live graph update because another import or graph update is already running',
                source: 'ChatDbMonitor',
              );
          continue;
        }

        _retryWhenGateReleases = false;
        attemptPreviousMaxRowId = null;
        attemptDetectedAt = null;
      }
    } catch (error, stackTrace) {
      _restoreStableCursor(
        previousMaxRowId: attemptPreviousMaxRowId,
        detectedAt: attemptDetectedAt,
      );
      _handleError('Change detection failed: $error', stackTrace);
    } finally {
      _importInFlight = false;

      if (_pendingProbe) {
        unawaited(_processPendingChanges());
      }
    }
  }

  void _logLiveGraphUpdateComplete({
    required StartupProbeTrigger pendingTrigger,
    required DateTime updateStartedAt,
    required int newMessageCount,
    required ConversationGraphBuildReport graphBuildReport,
  }) {
    final timeLabel = _formatLocalClockTime(DateTime.now());
    final durationMs = DateTime.now()
        .difference(updateStartedAt)
        .inMilliseconds;
    final triggerLabel = switch (pendingTrigger) {
      StartupProbeTrigger.ledgerCountLagging => 'ledger recovery',
      StartupProbeTrigger.rowIdAdvanced => 'rowid advance',
    };

    ref
        .read(appLoggerProvider.notifier)
        .info(
          'Live graph update at $timeLabel completed in ${durationMs}ms: '
          '$newMessageCount new source row(s) detected by $triggerLabel; '
          '${graphBuildReport.messageImportResult.insertedMessageCount} '
          'imported graph message(s), '
          '${graphBuildReport.messageProjectionResult.insertedMessageCount} '
          'projected graph message row(s). Live polling updates only the '
          'source-scoped conversation graph.',
          source: 'ChatDbMonitor',
        );
  }

  int _readMaxRowId(String chatDbPath) {
    return _sourceProbeReader.readMaxRowId(chatDbPath);
  }

  int _readImportableMessageCount(String chatDbPath) {
    return _sourceProbeReader.readImportableMessageCount(chatDbPath);
  }

  void _handleError(String message, StackTrace? stackTrace) {
    state = state.copyWith(lastError: message);
    ref
        .read(appLoggerProvider.notifier)
        .error(
          message,
          source: 'ChatDbMonitor',
          context: {if (stackTrace != null) 'stackTrace': '$stackTrace'},
        );
  }

  void _handleExecutionGateChange(
    ArchiveMutationCoordinatorState? previous,
    ArchiveMutationCoordinatorState next,
  ) {
    final gateJustReleased =
        previous?.isLocked == true && next.isLocked == false;
    if (!gateJustReleased || !_retryWhenGateReleases) {
      return;
    }

    _retryWhenGateReleases = false;
    ref
        .read(appLoggerProvider.notifier)
        .debug(
          'Execution gate released. Retrying pending live graph update immediately',
          source: 'ChatDbMonitor',
        );
    _scheduleProbe(trigger: StartupProbeTrigger.rowIdAdvanced);
  }

  void _restoreStableCursor({
    required int? previousMaxRowId,
    required DateTime? detectedAt,
  }) {
    state = state.copyWith(
      lastMaxRowId: previousMaxRowId,
      lastChangeDetected: detectedAt,
    );
  }
}

String _formatLocalClockTime(DateTime timestamp) {
  final local = timestamp.toLocal();
  final hour = local.hour == 0
      ? 12
      : (local.hour > 12 ? local.hour - 12 : local.hour);
  final minute = local.minute.toString().padLeft(2, '0');
  final suffix = local.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}
