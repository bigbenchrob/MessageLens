import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_report.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/chat_db_change_monitor_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/live_graph_update_worker.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';

void main() {
  group('runGraphMutationBeforeAttachmentPreservation', () {
    test('releases graph work before attachment preservation begins', () async {
      var graphMutationActive = false;
      final events = <String>[];

      final result = await runGraphMutationBeforeAttachmentPreservation<int>(
        runGraphMutation: () async {
          graphMutationActive = true;
          events.add('graph-start');
          await Future<void>.delayed(Duration.zero);
          events.add('graph-end');
          graphMutationActive = false;
          return 42;
        },
        preserveAttachments: (graphResult) async {
          expect(graphMutationActive, isFalse);
          expect(graphResult, 42);
          events.add('attachments');
        },
      );

      expect(result, 42);
      expect(events, <String>['graph-start', 'graph-end', 'attachments']);
    });

    test(
      'does not begin attachment preservation when graph work fails',
      () async {
        var attachmentPreservationStarted = false;

        await expectLater(
          runGraphMutationBeforeAttachmentPreservation<void>(
            runGraphMutation: () => Future<void>.error(StateError('failed')),
            preserveAttachments: (_) async {
              attachmentPreservationStarted = true;
            },
          ),
          throwsStateError,
        );

        expect(attachmentPreservationStarted, isFalse);
      },
    );
  });

  group('resolveStartupProbeDecision', () {
    test(
      'max rowid equal but imported count lower schedules incremental work',
      () {
        final decision = resolveStartupProbeDecision(
          liveMaxRowId: 135533,
          importedMaxSourceRowId: 135533,
          liveImportableMessageCount: 119351,
          importedMessageCount: 109742,
        );

        expect(decision.shouldSchedule, isTrue);
        expect(decision.trigger, StartupProbeTrigger.ledgerCountLagging);
        expect(
          decision.reason,
          'live importable message count exceeds imported message count',
        );
      },
    );

    test('max rowid equal and counts equal schedules no work', () {
      final decision = resolveStartupProbeDecision(
        liveMaxRowId: 135533,
        importedMaxSourceRowId: 135533,
        liveImportableMessageCount: 119351,
        importedMessageCount: 119351,
      );

      expect(decision.shouldSchedule, isFalse);
      expect(decision.trigger, isNull);
      expect(
        decision.reason,
        'ledger cursor and importable message count are current',
      );
    });

    test('max rowid greater schedules incremental work', () {
      final decision = resolveStartupProbeDecision(
        liveMaxRowId: 135534,
        importedMaxSourceRowId: 135533,
        liveImportableMessageCount: 119352,
        importedMessageCount: 119351,
      );

      expect(decision.shouldSchedule, isTrue);
      expect(decision.trigger, StartupProbeTrigger.rowIdAdvanced);
      expect(
        decision.reason,
        'live MAX(ROWID) is ahead of imported MAX(source_rowid)',
      );
    });
  });

  group('shouldAllowAutomaticIncrementalWork', () {
    test('blocks automatic graph update when app data is not ready', () {
      expect(shouldAllowAutomaticIncrementalWork(appDataReady: false), isFalse);
    });

    test('preserves automatic graph update when app data is ready', () {
      expect(shouldAllowAutomaticIncrementalWork(appDataReady: true), isTrue);
    });
  });

  group('gateStartupProbeDecisionForAppDataReadiness', () {
    test('suppresses startup graph update when app data is not ready', () {
      const wouldSchedule = StartupProbeDecision(
        shouldSchedule: true,
        trigger: StartupProbeTrigger.rowIdAdvanced,
        reason: 'live MAX(ROWID) is ahead of imported MAX(source_rowid)',
      );

      final gated = gateStartupProbeDecisionForAppDataReadiness(
        decision: wouldSchedule,
        appDataReady: false,
      );

      expect(gated.shouldSchedule, isFalse);
      expect(gated.trigger, isNull);
      expect(
        gated.reason,
        'app data graph is not ready; skipping automatic graph update',
      );
    });

    test('preserves startup graph update when projection is ready', () {
      const wouldSchedule = StartupProbeDecision(
        shouldSchedule: true,
        trigger: StartupProbeTrigger.rowIdAdvanced,
        reason: 'live MAX(ROWID) is ahead of imported MAX(source_rowid)',
      );

      final gated = gateStartupProbeDecisionForAppDataReadiness(
        decision: wouldSchedule,
        appDataReady: true,
      );

      expect(gated.shouldSchedule, isTrue);
      expect(gated.trigger, StartupProbeTrigger.rowIdAdvanced);
    });
  });

  group('buildConversationGraphBuildSummaryLog', () {
    test('summarizes graph import enrichment and projection counts', () {
      final report = ConversationGraphBuildReport(
        startedAt: DateTime.utc(2026, 5, 30, 12, 0),
        finishedAt: DateTime.utc(2026, 5, 30, 12, 0, 2),
        completedStageNames: const <String>[
          'import_messages',
          'enrich_missing_text',
          'project_messages',
        ],
        stageTimings: [
          ConversationGraphBuildStageTiming(
            stageName: 'import_messages',
            startedAt: DateTime.utc(2026, 5, 30, 12, 0),
            finishedAt: DateTime.utc(2026, 5, 30, 12, 0, 1),
          ),
          ConversationGraphBuildStageTiming(
            stageName: 'project_messages',
            startedAt: DateTime.utc(2026, 5, 30, 12, 0, 1),
            finishedAt: DateTime.utc(2026, 5, 30, 12, 0, 2),
          ),
        ],
        messageImportResult: const MessageImportResult(
          startedAfterSourceRowId: 100,
          insertedMessageCount: 2,
          lastImportedSourceRowId: 102,
        ),
        richTextEnrichmentResult: const MessageRichTextEnrichmentResult(
          candidateMessageCount: 3,
          enrichedMessageCount: 1,
          missingExtractionCount: 2,
          extractorAvailable: true,
        ),
        messageProjectionResult: const MessageProjectionResult(
          examinedMessageCount: 4,
          insertedMessageCount: 2,
        ),
      );

      final summary = buildConversationGraphBuildSummaryLog(report: report);

      expect(summary, contains('completed in 2000ms'));
      expect(summary, contains('3 stage(s)'));
      expect(summary, contains('2 imported graph message(s)'));
      expect(summary, contains('1 enriched text row(s)'));
      expect(summary, contains('2 projected graph message row(s)'));
      expect(summary, contains('slowest stage: import_messages 1000ms'));
    });
  });

  group('buildChatDbPollingFailureMessage', () {
    test('preserves the polling read failure cause', () {
      expect(
        buildChatDbPollingFailureMessage('permission denied'),
        'chat.db polling read failed: permission denied',
      );
    });
  });
}
