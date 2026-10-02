import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_data_update_executor_provider.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_report.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/live_graph_update_worker.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_service_provider.dart';

void main() {
  test('holds one typed archive tenure until the worker returns', () async {
    late ProviderContainer container;
    var workerCalls = 0;
    final worker = LiveGraphUpdateWorker(
      readPrerequisites: () async {
        final mutation = container.read(archiveMutationCoordinatorProvider);
        expect(mutation.isLocked, isTrue);
        expect(mutation.operation, ArchiveMutationOperation.liveGraphUpdate);
        expect(mutation.holdCount, 1);
        return const LiveGraphUpdatePrerequisiteSnapshot(
          appDataReady: true,
          liveMaxRowId: 101,
          importedMaxSourceRowId: 100,
          liveImportableMessageCount: 101,
          importedMessageCount: 100,
        );
      },
      runGraphBuild: (_) async {
        workerCalls++;
        expect(
          container.read(archiveMutationCoordinatorProvider).isLocked,
          isTrue,
        );
        return _report();
      },
      preserveAttachments: (_) async {
        expect(
          container.read(archiveMutationCoordinatorProvider).isLocked,
          isTrue,
        );
        return const AttachmentArchiveResult(
          totalScanned: 0,
          newlyArchived: 0,
          skipped: 0,
          failed: 0,
        );
      },
    );
    container = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(_authority()),
        liveGraphUpdateWorkerProvider.overrideWith((ref) async => worker),
      ],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(appCzarDataUpdateExecutorProvider)
        .run();

    expect(result.performedUpdate, isTrue);
    expect(workerCalls, 1);
    final released = container.read(archiveMutationCoordinatorProvider);
    expect(released.isLocked, isFalse);
    expect(released.holdCount, 0);
    expect(released.lastReleasedAtUtc, isNotNull);
  });
}

ArchiveAccessAuthority _authority() {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.test,
      buildIdentity: ArchiveBuildIdentity.testHarness,
      archiveInstanceId: ArchiveInstanceId(
        '11111111-1111-4111-8111-111111111111',
      ),
      canonicalRootPath: '/tmp/app-czar-data-update-test',
      bundleIdentifier: 'test.bundle',
      productName: 'MessageLens Test',
    ),
  );
}

ConversationGraphBuildReport _report() {
  final startedAt = DateTime.utc(2026, 10, 2, 12);
  return ConversationGraphBuildReport(
    startedAt: startedAt,
    finishedAt: startedAt.add(const Duration(seconds: 1)),
    completedStageNames: const <String>['import_messages', 'project_messages'],
    stageTimings: const <ConversationGraphBuildStageTiming>[],
    messageImportResult: const MessageImportResult(
      startedAfterSourceRowId: 100,
      insertedMessageCount: 1,
      lastImportedSourceRowId: 101,
    ),
    richTextEnrichmentResult: const MessageRichTextEnrichmentResult(
      candidateMessageCount: 1,
      enrichedMessageCount: 1,
      missingExtractionCount: 0,
      extractorAvailable: true,
    ),
    messageProjectionResult: const MessageProjectionResult(
      examinedMessageCount: 1,
      insertedMessageCount: 1,
    ),
  );
}
