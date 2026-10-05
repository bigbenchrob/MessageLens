import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar/presentation/app_czar_startup_harness.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_data_update_executor_provider.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/presentation/app_czar_data_update_screen.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_observation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_report.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/live_graph_update_worker.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_service_provider.dart';

void main() {
  testWidgets('Data Update replaces assessment with actual worker progress', (
    tester,
  ) async {
    final executor = _ControlledExecutor();
    final restarter = _FakeRestarter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appCzarObservationReaderProvider.overrideWithValue(
            const _DataUpdateReader(),
          ),
          appCzarDataUpdateExecutorProvider.overrideWithValue(executor),
          appCzarProcessRestarterProvider.overrideWithValue(restarter),
        ],
        child: const AppCzarStartupHarness(),
      ),
    );
    await _pumpUntilFound(tester, AppCzarDataUpdateScreen.screenKey);
    await _pumpUntilText(tester, '3 / 8');

    expect(find.byKey(AppCzarDataUpdateScreen.screenKey), findsOneWidget);
    expect(find.byKey(AppCzarAssessmentScreen.screenKey), findsNothing);
    expect(find.byKey(AppCzarAssessmentScreen.runAgainKey), findsNothing);
    expect(find.text('Source messages'), findsOneWidget);
    expect(find.text('MessageLens messages'), findsOneWidget);
    expect(find.text('Messages to import'), findsOneWidget);
    expect(find.text('108'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('Importing messages'), findsOneWidget);
    expect(find.text('3 / 8'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
    expect(find.text('Conversations'), findsNothing);

    executor.complete();
    await tester.pumpAndSettle();

    expect(find.text('Restarting MessageLens'), findsOneWidget);
    expect(find.text('Attachments examined'), findsOneWidget);
    expect(find.text('New attachments preserved'), findsOneWidget);
    expect(restarter.calls, 1);
  });

  testWidgets('literal failure offers only restart and reassess', (
    tester,
  ) async {
    final restarter = _FakeRestarter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appCzarObservationReaderProvider.overrideWithValue(
            const _DataUpdateReader(),
          ),
          appCzarDataUpdateExecutorProvider.overrideWithValue(
            const _FailingExecutor(),
          ),
          appCzarProcessRestarterProvider.overrideWithValue(restarter),
        ],
        child: const AppCzarStartupHarness(),
      ),
    );
    await _pumpUntilFound(tester, AppCzarDataUpdateScreen.failureKey);

    expect(find.textContaining('worker source read failed'), findsOneWidget);
    expect(find.text('Restart and reassess'), findsOneWidget);
    expect(find.text('Operating Session'), findsNothing);
    expect(find.text('Conversations'), findsNothing);

    await tester.tap(find.byKey(AppCzarDataUpdateScreen.restartKey));
    await tester.pumpAndSettle();
    expect(restarter.calls, 1);
    expect(find.text('Restarting MessageLens'), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Key key) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.pump(const Duration(milliseconds: 10));
    if (find.byKey(key).evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for $key.');
}

Future<void> _pumpUntilText(WidgetTester tester, String text) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.pump(const Duration(milliseconds: 10));
    if (find.text(text).evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for $text.');
}

final class _ControlledExecutor implements AppCzarDataUpdateExecutor {
  final Completer<void> _release = Completer<void>();

  void complete() {
    if (!_release.isCompleted) {
      _release.complete();
    }
  }

  @override
  Future<LiveGraphUpdateResult> run({
    LiveGraphUpdateObserver? onObservation,
  }) async {
    const prerequisites = LiveGraphUpdatePrerequisiteSnapshot(
      appDataReady: true,
      liveMaxRowId: 108,
      importedMaxSourceRowId: 100,
      liveImportableMessageCount: 108,
      importedMessageCount: 100,
    );
    onObservation?.call(
      const LiveGraphUpdateObservation.prerequisitesRead(prerequisites),
    );
    onObservation?.call(
      const LiveGraphUpdateObservation.graphBuild(
        ConversationGraphBuildObservation(
          suboperation: ConversationGraphBuildSuboperation.importMessages,
          kind: ConversationGraphBuildObservationKind.progress,
          completedWorkCount: 3,
          totalWorkCount: 8,
        ),
      ),
    );
    await _release.future;
    onObservation?.call(
      const LiveGraphUpdateObservation.preservingAttachments(),
    );
    const attachments = AttachmentArchiveResult(
      totalScanned: 1,
      newlyArchived: 1,
      skipped: 0,
      failed: 0,
    );
    onObservation?.call(
      const LiveGraphUpdateObservation.attachmentsPreserved(attachments),
    );
    return LiveGraphUpdateResult(
      prerequisites: prerequisites,
      decision: const StartupProbeDecision(
        shouldSchedule: true,
        reason: 'source ahead',
        trigger: StartupProbeTrigger.rowIdAdvanced,
      ),
      graphBuildReport: _report(),
      attachmentResult: attachments,
    );
  }
}

final class _FailingExecutor implements AppCzarDataUpdateExecutor {
  const _FailingExecutor();

  @override
  Future<LiveGraphUpdateResult> run({LiveGraphUpdateObserver? onObservation}) {
    throw StateError('worker source read failed');
  }
}

final class _FakeRestarter implements AppCzarProcessRestarter {
  int calls = 0;

  @override
  Future<void> restartAndReassess() async {
    calls++;
  }
}

final class _DataUpdateReader implements AppCzarObservationReader {
  const _DataUpdateReader();

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    return const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Test archive',
      archiveScopeIdentity: 'test-scope',
      archiveGeneration: 0,
      coverage: _completeCoverage,
      repairability: _completeRepairability,
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async {
    return const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 3,
      messageCount: 100,
      chatCount: 4,
      chatMessageEdgeCount: 100,
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() async {
    return const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 10,
      messageCount: 100,
      liveMessageCount: 100,
      liveMaxSourceRowId: 100,
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readOverlay() async {
    return const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 8,
    );
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    return const AppCzarRootObservation(admitted: true, path: '/tmp/test-root');
  }

  @override
  Future<AppCzarSourceObservation> readSource() async {
    return const AppCzarSourceObservation(
      condition: AppCzarSourceCondition.readable,
      messageCount: 108,
      maxRowId: 108,
      sampleStable: true,
    );
  }
}

const _completeCoverage = AppCzarAttachmentCoverageObservation(
  condition: AppCzarAttachmentCoverageCondition.complete,
  requiredCount: 1,
  coveredCount: 1,
  missingCount: 0,
  unverifiableCount: 0,
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
);

const _completeRepairability = AppCzarAttachmentRepairabilityObservation(
  condition: AppCzarAttachmentRepairOpportunityCondition.absent,
  availableFromMessagesCount: 0,
  sourceAbsentCount: 0,
  sourceUnknownCount: 0,
  recordBackedRecoveryCount: 0,
  unsafeOrConflictingCount: 0,
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
);

ConversationGraphBuildReport _report() {
  final startedAt = DateTime.utc(2026, 10, 2, 12);
  return ConversationGraphBuildReport(
    startedAt: startedAt,
    finishedAt: startedAt.add(const Duration(seconds: 1)),
    completedStageNames: const <String>['import_messages', 'project_messages'],
    stageTimings: const <ConversationGraphBuildStageTiming>[],
    messageImportResult: const MessageImportResult(
      startedAfterSourceRowId: 100,
      insertedMessageCount: 8,
      lastImportedSourceRowId: 108,
    ),
    richTextEnrichmentResult: const MessageRichTextEnrichmentResult(
      candidateMessageCount: 8,
      enrichedMessageCount: 8,
      missingExtractionCount: 0,
      extractorAvailable: true,
    ),
    messageProjectionResult: const MessageProjectionResult(
      examinedMessageCount: 8,
      insertedMessageCount: 8,
    ),
  );
}
