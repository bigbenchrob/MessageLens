import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_live_update_executor_provider.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/domain/app_czar_operating_session_state.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_report.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/live_graph_update_worker.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_service_provider.dart';

void main() {
  test(
    'holds one live-update Ball and revalidates the occurrence inside it',
    () async {
      late ProviderContainer container;
      final workerEntered = Completer<void>();
      final releaseWorker = Completer<void>();
      final guardSamples = <({String guard, bool isLocked, int holdCount})>[];
      var graphRuns = 0;
      var attachmentRuns = 0;
      final worker = LiveGraphUpdateWorker(
        readPrerequisites: () async {
          _expectOneLiveUpdateTenure(container);
          workerEntered.complete();
          await releaseWorker.future;
          _expectOneLiveUpdateTenure(container);
          return _prerequisites;
        },
        runGraphBuild: (_) async {
          graphRuns++;
          _expectOneLiveUpdateTenure(container);
          return _report();
        },
        preserveAttachments: (_) async {
          attachmentRuns++;
          _expectOneLiveUpdateTenure(container);
          return _attachmentResult;
        },
      );
      container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            _authority(),
          ),
          liveGraphUpdateWorkerProvider.overrideWith((ref) async => worker),
        ],
      );
      addTearDown(container.dispose);

      final resultFuture = container
          .read(appCzarOperatingLiveUpdateExecutorProvider)
          .run(
            occurrence: _occurrence,
            requireCurrentOccurrence: () {
              final mutation = container.read(
                archiveMutationCoordinatorProvider,
              );
              guardSamples.add((
                guard: 'occurrence',
                isLocked: mutation.isLocked,
                holdCount: mutation.holdCount,
              ));
            },
            requireCurrentPrecondition: () async {
              final mutation = container.read(
                archiveMutationCoordinatorProvider,
              );
              guardSamples.add((
                guard: 'precondition',
                isLocked: mutation.isLocked,
                holdCount: mutation.holdCount,
              ));
            },
          );

      await workerEntered.future;
      expect(guardSamples, <({String guard, bool isLocked, int holdCount})>[
        (guard: 'occurrence', isLocked: false, holdCount: 0),
        (guard: 'precondition', isLocked: false, holdCount: 0),
        (guard: 'occurrence', isLocked: true, holdCount: 1),
        (guard: 'precondition', isLocked: true, holdCount: 1),
        (guard: 'occurrence', isLocked: true, holdCount: 1),
      ]);
      _expectOneLiveUpdateTenure(container);

      releaseWorker.complete();
      final result = await resultFuture;

      expect(result.performedUpdate, isTrue);
      expect(graphRuns, 1);
      expect(attachmentRuns, 1);
      expect(guardSamples, <({String guard, bool isLocked, int holdCount})>[
        (guard: 'occurrence', isLocked: false, holdCount: 0),
        (guard: 'precondition', isLocked: false, holdCount: 0),
        (guard: 'occurrence', isLocked: true, holdCount: 1),
        (guard: 'precondition', isLocked: true, holdCount: 1),
        (guard: 'occurrence', isLocked: true, holdCount: 1),
        (guard: 'occurrence', isLocked: true, holdCount: 1),
      ]);
      final released = container.read(archiveMutationCoordinatorProvider);
      expect(released.isLocked, isFalse);
      expect(released.holdCount, 0);
      expect(released.lastReleasedAtUtc, isNotNull);
    },
  );

  test(
    'expired occurrence proof rejects worker completion and releases Ball',
    () async {
      late ProviderContainer container;
      var occurrenceProofCalls = 0;
      var preconditionProofCalls = 0;
      var workerRuns = 0;
      final worker = LiveGraphUpdateWorker(
        readPrerequisites: () async {
          workerRuns++;
          _expectOneLiveUpdateTenure(container);
          return _prerequisites;
        },
        runGraphBuild: (_) async => _report(),
        preserveAttachments: (_) async => _attachmentResult,
      );
      container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            _authority(),
          ),
          liveGraphUpdateWorkerProvider.overrideWith((ref) async => worker),
        ],
      );
      addTearDown(container.dispose);

      final result = container
          .read(appCzarOperatingLiveUpdateExecutorProvider)
          .run(
            occurrence: _occurrence,
            requireCurrentOccurrence: () {
              occurrenceProofCalls++;
              if (occurrenceProofCalls == 4) {
                throw StateError('Operating occurrence retired');
              }
            },
            requireCurrentPrecondition: () async {
              preconditionProofCalls++;
            },
          );

      await expectLater(
        result,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Operating occurrence retired',
          ),
        ),
      );
      expect(workerRuns, 1);
      expect(occurrenceProofCalls, 4);
      expect(preconditionProofCalls, 2);
      final released = container.read(archiveMutationCoordinatorProvider);
      expect(released.isLocked, isFalse);
      expect(released.holdCount, 0);
      expect(released.lastReleasedAtUtc, isNotNull);
    },
  );

  test('rejected initial occurrence proof acquires no Ball', () async {
    var workerProviderReads = 0;
    var preconditionProofCalls = 0;
    final container = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(_authority()),
        liveGraphUpdateWorkerProvider.overrideWith((ref) async {
          workerProviderReads++;
          throw StateError('worker must not be resolved');
        }),
      ],
    );
    addTearDown(container.dispose);

    final result = container
        .read(appCzarOperatingLiveUpdateExecutorProvider)
        .run(
          occurrence: _occurrence,
          requireCurrentOccurrence: () {
            throw StateError('Operating occurrence is not current');
          },
          requireCurrentPrecondition: () async {
            preconditionProofCalls++;
          },
        );

    await expectLater(result, throwsA(isA<StateError>()));
    expect(workerProviderReads, 0);
    expect(preconditionProofCalls, 0);
    final mutation = container.read(archiveMutationCoordinatorProvider);
    expect(mutation.isLocked, isFalse);
    expect(mutation.holdCount, 0);
    expect(mutation.lastReleasedAtUtc, isNull);
  });
}

void _expectOneLiveUpdateTenure(ProviderContainer container) {
  final mutation = container.read(archiveMutationCoordinatorProvider);
  expect(mutation.isLocked, isTrue);
  expect(mutation.operation, ArchiveMutationOperation.liveGraphUpdate);
  expect(mutation.activeOperations, <ArchiveMutationOperation>[
    ArchiveMutationOperation.liveGraphUpdate,
  ]);
  expect(mutation.holdCount, 1);
  expect(mutation.ownerLabel, 'app-czar-operating-42');
}

const _occurrence = AppCzarOperatingSessionOccurrence(
  processSequence: 42,
  assessmentGeneration: 7,
  admittedArchiveScopeIdentity: 'scope-7',
  admittedArchiveProbeGeneration: 3,
  admittedArchiveResolvedPath: '/test/archive',
);

const _prerequisites = LiveGraphUpdatePrerequisiteSnapshot(
  appDataReady: true,
  liveMaxRowId: 101,
  importedMaxSourceRowId: 100,
  liveImportableMessageCount: 101,
  importedMessageCount: 100,
);

const _attachmentResult = AttachmentArchiveResult(
  totalScanned: 1,
  newlyArchived: 1,
  skipped: 0,
  failed: 0,
);

ArchiveAccessAuthority _authority() {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.test,
      buildIdentity: ArchiveBuildIdentity.testHarness,
      archiveInstanceId: ArchiveInstanceId(
        '11111111-1111-4111-8111-111111111111',
      ),
      canonicalRootPath: '/tmp/app-czar-operating-update-test',
      bundleIdentifier: 'test.bundle',
      productName: 'MessageLens Test',
    ),
  );
}

ConversationGraphBuildReport _report() {
  final startedAt = DateTime.utc(2026, 10, 4, 12);
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
