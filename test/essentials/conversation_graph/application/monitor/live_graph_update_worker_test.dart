import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_observation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_report.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/live_graph_update_worker.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_service_provider.dart';

void main() {
  test(
    'revalidates a later source boundary and invokes proven workers once',
    () async {
      var graphRuns = 0;
      var attachmentRuns = 0;
      final events = <LiveGraphUpdateObservation>[];
      final worker = LiveGraphUpdateWorker(
        readPrerequisites: () async {
          return const LiveGraphUpdatePrerequisiteSnapshot(
            appDataReady: true,
            liveMaxRowId: 105,
            importedMaxSourceRowId: 90,
            liveImportableMessageCount: 105,
            importedMessageCount: 90,
          );
        },
        runGraphBuild: (observer) async {
          graphRuns++;
          observer(
            const ConversationGraphBuildObservation(
              suboperation: ConversationGraphBuildSuboperation.importMessages,
              kind: ConversationGraphBuildObservationKind.progress,
              completedWorkCount: 15,
              totalWorkCount: 15,
            ),
          );
          return _report(startedAfter: 90, lastImported: 105, inserted: 15);
        },
        preserveAttachments: (report) async {
          attachmentRuns++;
          expect(report.messageImportResult.lastImportedSourceRowId, 105);
          return const AttachmentArchiveResult(
            totalScanned: 2,
            newlyArchived: 1,
            skipped: 1,
            failed: 0,
          );
        },
      );

      final result = await worker.run(onObservation: events.add);

      expect(graphRuns, 1);
      expect(attachmentRuns, 1);
      expect(result.performedUpdate, isTrue);
      expect(result.prerequisites.messagesToImport, 15);
      expect(result.decision.trigger, StartupProbeTrigger.rowIdAdvanced);
      expect(
        events.map((event) => event.kind),
        <LiveGraphUpdateObservationKind>[
          LiveGraphUpdateObservationKind.checkingPrerequisites,
          LiveGraphUpdateObservationKind.prerequisitesRead,
          LiveGraphUpdateObservationKind.graphBuild,
          LiveGraphUpdateObservationKind.preservingAttachments,
          LiveGraphUpdateObservationKind.attachmentsPreserved,
        ],
      );
    },
  );

  test('source failure before mutation invokes neither worker', () async {
    var graphRuns = 0;
    var attachmentRuns = 0;
    final worker = LiveGraphUpdateWorker(
      readPrerequisites: () {
        throw StateError('macOS denied source access');
      },
      runGraphBuild: (_) async {
        graphRuns++;
        return _report(startedAfter: 0, lastImported: 1, inserted: 1);
      },
      preserveAttachments: (_) async {
        attachmentRuns++;
        return _emptyAttachments;
      },
    );

    await expectLater(
      worker.run(),
      throwsA(
        isA<StateError>().having(
          (error) => '$error',
          'literal failure',
          contains('macOS denied source access'),
        ),
      ),
    );
    expect(graphRuns, 0);
    expect(attachmentRuns, 0);
  });

  test(
    'unready local data fails before graph or attachment mutation',
    () async {
      var graphRuns = 0;
      var attachmentRuns = 0;
      final worker = LiveGraphUpdateWorker(
        readPrerequisites: () async {
          return const LiveGraphUpdatePrerequisiteSnapshot(
            appDataReady: false,
            liveMaxRowId: 101,
            importedMaxSourceRowId: 100,
            liveImportableMessageCount: 101,
            importedMessageCount: 100,
          );
        },
        runGraphBuild: (_) async {
          graphRuns++;
          return _report(startedAfter: 100, lastImported: 101, inserted: 1);
        },
        preserveAttachments: (_) async {
          attachmentRuns++;
          return _emptyAttachments;
        },
      );

      await expectLater(
        worker.run(),
        throwsA(isA<LiveGraphUpdatePrerequisiteException>()),
      );
      expect(graphRuns, 0);
      expect(attachmentRuns, 0);
    },
  );

  test('already-reconciled worker snapshot performs no mutation', () async {
    var graphRuns = 0;
    var attachmentRuns = 0;
    final worker = LiveGraphUpdateWorker(
      readPrerequisites: () async {
        return const LiveGraphUpdatePrerequisiteSnapshot(
          appDataReady: true,
          liveMaxRowId: 100,
          importedMaxSourceRowId: 100,
          liveImportableMessageCount: 100,
          importedMessageCount: 100,
        );
      },
      runGraphBuild: (_) async {
        graphRuns++;
        return _report(startedAfter: 100, lastImported: 100, inserted: 0);
      },
      preserveAttachments: (_) async {
        attachmentRuns++;
        return _emptyAttachments;
      },
    );

    final result = await worker.run();

    expect(result.performedUpdate, isFalse);
    expect(result.decision.shouldSchedule, isFalse);
    expect(graphRuns, 0);
    expect(attachmentRuns, 0);
  });
}

const _emptyAttachments = AttachmentArchiveResult(
  totalScanned: 0,
  newlyArchived: 0,
  skipped: 0,
  failed: 0,
);

ConversationGraphBuildReport _report({
  required int startedAfter,
  required int lastImported,
  required int inserted,
}) {
  final startedAt = DateTime.utc(2026, 10, 2, 12);
  return ConversationGraphBuildReport(
    startedAt: startedAt,
    finishedAt: startedAt.add(const Duration(seconds: 1)),
    completedStageNames: const <String>['import_messages', 'project_messages'],
    stageTimings: const <ConversationGraphBuildStageTiming>[],
    messageImportResult: MessageImportResult(
      startedAfterSourceRowId: startedAfter,
      insertedMessageCount: inserted,
      lastImportedSourceRowId: lastImported,
    ),
    richTextEnrichmentResult: const MessageRichTextEnrichmentResult(
      candidateMessageCount: 0,
      enrichedMessageCount: 0,
      missingExtractionCount: 0,
      extractorAvailable: true,
    ),
    messageProjectionResult: MessageProjectionResult(
      examinedMessageCount: inserted,
      insertedMessageCount: inserted,
    ),
  );
}
