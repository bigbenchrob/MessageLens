import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart'
    show ArchiveMutationOperation;
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show
        ArchiveMutationCoordinator,
        ArchiveMutationCoordinatorState,
        ArchiveMutationCapability,
        admittedArchiveAccessAuthorityProvider,
        archiveMutationCoordinatorProvider;
import 'package:remember_this_text/essentials/conversation_graph/application/archives/source_scoped_archive_graph_import_service.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/archives/source_scoped_archive_graph_projection_observation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/archives/source_scoped_archive_graph_removal_service.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/attachments/attachment_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_handle_joins/chat_to_handle_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_message_joins/chat_to_message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chats/chat_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/handles/handle_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/message_attachment_joins/message_to_attachment_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/feature_level_providers.dart'
    show
        sourceScopedArchiveGraphImportServiceProvider,
        sourceScopedArchiveGraphRemovalServiceProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/messages_source/feature_level_providers.dart'
    show currentMessagesSourcePathProvider;
import 'package:remember_this_text/essentials/navigation/application/sidebar_mode_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/archives/historical_messages_archive_source_registrar.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/archives/source_scoped_archive_import_service.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/attachments/attachment_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_handle_joins/chat_handle_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_message_joins/chat_message_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chats/chat_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/handles/handle_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/message_attachment_joins/message_attachment_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages_lineage_admission_authority.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages_lineage_admission_authority_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/messages_lineage_admission.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_attachment_recovery_batch_executor.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_attachment_recovery_batch_executor_provider.dart';
import 'package:remember_this_text/features/attachments/domain/entities/message_lens_attachment_recovery.dart';
import 'package:remember_this_text/features/attachments/domain/entities/message_lens_attachment_recovery_donor.dart';
import 'package:remember_this_text/features/settings/application/archive_source_inspection.dart';
import 'package:remember_this_text/features/settings/application/archive_source_inspector_provider.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_folder_chooser.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_folder_chooser_provider.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_sources.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_sources_provider.dart';
import 'package:remember_this_text/features/settings/application/historical_archives_workflow_panel_model_provider.dart';
import 'package:remember_this_text/features/settings/application/message_lens_historical_archive_preflight.dart';
import 'package:remember_this_text/features/settings/application/message_lens_historical_archive_preflight_provider.dart';
import 'package:remember_this_text/features/settings/infrastructure/repositories/archive_source_inspection_repository.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  const currentMessagesDatabasePath = '/Users/test/Library/Messages/chat.db';

  group('Historical Archives typed presentation state', () {
    test('hub owns no candidate, selected source, progress, or reference', () {
      final state = buildInitialHistoricalArchivesWorkflowState();

      expect(state.presentation, isA<HistoricalArchivesHubState>());
      expect(state.presentation.data, isNull);
      expect(state.inspectionEvidence, isNull);
      expect(state.selectedKnownSourceKey, isNull);
      expect(state.importProgress, isNull);
      expect(state.removalProgress, isNull);
      expect(state.knownSourceReference, isNull);
    });

    test('ready candidate can own evidence but no operation progress', () {
      final state = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesReadyToAddState(
          lineageAdmission: _testSameLineageAdmission(),
          data: _testPresentationData(),
          evidence: _testInspectionEvidence(),
        ),
      );

      expect(state.inspectionEvidence, isNotNull);
      expect(state.selectedKnownSourceKey, isNull);
      expect(state.importProgress, isNull);
      expect(state.removalProgress, isNull);
    });

    test('import and removal progress are owned by disjoint variants', () {
      final importing = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesImportingState(
          lineageAdmission: _testSameLineageAdmission(),
          data: _testPresentationData(),
          evidence: _testInspectionEvidence(),
          progress: const HistoricalArchiveImportProgress(),
        ),
      );
      final removing = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesRemovingState(
          data: _testPresentationData(),
          facts: _testImportedSourceFacts(),
          progress: const HistoricalArchiveRemovalProgress(),
        ),
      );

      expect(importing.importProgress, isNotNull);
      expect(importing.removalProgress, isNull);
      expect(removing.importProgress, isNull);
      expect(removing.removalProgress, isNotNull);
    });

    test('notices and orange references are exclusive hub variants', () {
      final duplicate = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesDuplicateNoticeState(
          notice: HistoricalArchivesDuplicateFolderNotice(
            identity: _identity(
              'historical-messages-archive:/tmp/archive/chat.db',
            ),
            noticeOccurrence: 1,
            presentationSessionOccurrence: 1,
          ),
        ),
      );
      final reference = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesKnownSourceReferenceState(
          reference: HistoricalArchivesKnownSourceReference(
            identity: _identity(
              'historical-messages-archive:/tmp/archive/chat.db',
            ),
            referenceOccurrence: 2,
          ),
        ),
      );

      expect(duplicate.duplicateFolderNotice, isNotNull);
      expect(duplicate.knownSourceReference, isNull);
      expect(reference.duplicateFolderNotice, isNull);
      expect(reference.knownSourceReference, isNotNull);
    });
  });

  group('buildHistoricalArchivesWorkflowPanelModel', () {
    test(
      'projects title occupancy exhaustively from all 17 typed variants',
      () {
        final data = _testPresentationData();
        final evidence = _testInspectionEvidence();
        final facts = _testImportedSourceFacts();
        final cases =
            <
              ({
                String name,
                HistoricalArchivesPresentationState presentation,
                bool titleVisible,
              })
            >[
              (
                name: 'hub',
                presentation: const HistoricalArchivesHubState(),
                titleVisible: false,
              ),
              (
                name: 'duplicate notice',
                presentation: HistoricalArchivesDuplicateNoticeState(
                  notice: HistoricalArchivesDuplicateFolderNotice(
                    identity: _identity(
                      'historical-messages-archive:/tmp/archive/chat.db',
                    ),
                    noticeOccurrence: 1,
                    presentationSessionOccurrence: 1,
                  ),
                ),
                titleVisible: false,
              ),
              (
                name: 'invalid notice',
                presentation: const HistoricalArchivesInvalidNoticeState(
                  notice: HistoricalArchivesInvalidFolderNotice(
                    noticeOccurrence: 1,
                    presentationSessionOccurrence: 1,
                  ),
                ),
                titleVisible: false,
              ),
              (
                name: 'success notice',
                presentation: const HistoricalArchivesImportSuccessNoticeState(
                  notice: HistoricalArchivesImportSuccessNotice(
                    noticeOccurrence: 1,
                    presentationSessionOccurrence: 1,
                  ),
                ),
                titleVisible: false,
              ),
              (
                name: 'lineage notice',
                presentation: const HistoricalArchivesLineageNoticeState(
                  notice: HistoricalArchivesLineageNotice(
                    status: MessagesLineageAdmissionStatus.insufficientEvidence,
                    noticeOccurrence: 1,
                    presentationSessionOccurrence: 1,
                  ),
                ),
                titleVisible: false,
              ),
              (
                name: 'known-source reference',
                presentation: HistoricalArchivesKnownSourceReferenceState(
                  reference: HistoricalArchivesKnownSourceReference(
                    identity: _identity(
                      'historical-messages-archive:/tmp/archive/chat.db',
                    ),
                    referenceOccurrence: 1,
                  ),
                ),
                titleVisible: false,
              ),
              (
                name: 'MessageLens notice',
                presentation: const HistoricalArchivesMessageLensNoticeState(
                  notice: HistoricalArchivesMessageLensNotice(
                    kind: HistoricalArchivesMessageLensNoticeKind.invalidFolder,
                    noticeOccurrence: 1,
                    presentationSessionOccurrence: 1,
                  ),
                ),
                titleVisible: false,
              ),
              (
                name: 'inspecting MessageLens archive',
                presentation:
                    const HistoricalArchivesMessageLensInspectingState(
                      folderPath: '/tmp/donor',
                      inspectionOccurrence: 1,
                    ),
                titleVisible: true,
              ),
              (
                name: 'MessageLens archive ready',
                presentation: HistoricalArchivesMessageLensReadyState(
                  evidence: _messageLensReady(
                    recoverableCount: 3,
                    recoverableBytes: 8192,
                  ),
                ),
                titleVisible: true,
              ),
              (
                name: 'inspecting candidate',
                presentation: HistoricalArchivesInspectingCandidateState(
                  data: data,
                  inspectionOccurrence: 1,
                ),
                titleVisible: true,
              ),
              (
                name: 'inspection failed',
                presentation: HistoricalArchivesInspectionFailedState(
                  data: data,
                  evidence: evidence,
                ),
                titleVisible: true,
              ),
              (
                name: 'ready to add',
                presentation: HistoricalArchivesReadyToAddState(
                  lineageAdmission: _testSameLineageAdmission(),
                  data: data,
                  evidence: evidence,
                ),
                titleVisible: true,
              ),
              (
                name: 'existing source',
                presentation: HistoricalArchivesExistingSourceState(
                  data: data,
                  facts: facts,
                ),
                titleVisible: false,
              ),
              (
                name: 'importing',
                presentation: HistoricalArchivesImportingState(
                  lineageAdmission: _testSameLineageAdmission(),
                  data: data,
                  evidence: evidence,
                  progress: const HistoricalArchiveImportProgress(),
                ),
                titleVisible: true,
              ),
              (
                name: 'import failed',
                presentation: HistoricalArchivesImportFailedState(
                  lineageAdmission: _testSameLineageAdmission(),
                  data: data,
                  evidence: evidence,
                  progress: const HistoricalArchiveImportProgress(),
                  failureDetail: 'fixture failure',
                ),
                titleVisible: true,
              ),
              (
                name: 'removing',
                presentation: HistoricalArchivesRemovingState(
                  data: data,
                  facts: facts,
                  progress: const HistoricalArchiveRemovalProgress(),
                ),
                titleVisible: true,
              ),
              (
                name: 'removal failed',
                presentation: HistoricalArchivesRemovalFailedState(
                  data: data,
                  facts: facts,
                  progress: const HistoricalArchiveRemovalProgress(),
                  failureDetail: 'fixture failure',
                ),
                titleVisible: true,
              ),
            ];

        for (final testCase in cases) {
          final model = buildHistoricalArchivesWorkflowPanelModel(
            executionGateState: const ArchiveMutationCoordinatorState(),
            isMaintenanceLocked: false,
            workflowState: HistoricalArchivesWorkflowState(
              presentation: testCase.presentation,
            ),
            currentMessagesDatabasePath: currentMessagesDatabasePath,
          );

          expect(
            model.centerPageTitleVisible,
            testCase.titleVisible,
            reason: testCase.name,
          );
        }
      },
    );

    test('projects the empty workflow as a silent hub', () {
      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: false,
        workflowState: buildInitialHistoricalArchivesWorkflowState(),
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );

      expect(model.isHub, isTrue);
      expect(model.narratorPresentation, isNull);
    });

    test(
      'reports available execution gate when no shared pipeline owns it',
      () {
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: buildInitialHistoricalArchivesWorkflowState(),
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );

        expect(
          model.executionGate.status,
          HistoricalArchivesExecutionGateStatus.available,
        );
        expect(model.executionGate.statusLabel, 'Available');
        expect(model.statusLabel, 'No archive selected');
        expect(model.importButtonEnabled, isFalse);
        expect(model.importButtonDetail, contains('folder is selected'));
        expect(model.activityLog.last.label, 'Waiting');
      },
    );

    test(
      'reports busy execution gate when source-scoped import pipeline owns it',
      () {
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(
            operation: ArchiveMutationOperation.graphBuild,
            ownerId: 'db-import-control#1',
            ownerLabel: 'db-import-control',
            holdCount: 1,
          ),
          isMaintenanceLocked: false,
          workflowState: buildInitialHistoricalArchivesWorkflowState(),
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );

        expect(
          model.executionGate.status,
          HistoricalArchivesExecutionGateStatus.busy,
        );
        expect(
          model.executionGate.detail,
          contains('Source import or graph projection'),
        );
        expect(model.statusLabel, 'Execution Gate Busy');
        expect(
          model.summaryText,
          contains('already importing or preparing message data'),
        );
        expect(
          model.importButtonDetail,
          contains('source import or graph projection'),
        );
        expect(model.activityLog.last.label, 'Execution gate busy');
      },
    );

    test(
      'reports blocked execution gate when maintenance lock is active without gate ownership',
      () {
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: true,
          workflowState: buildInitialHistoricalArchivesWorkflowState(),
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );

        expect(
          model.executionGate.status,
          HistoricalArchivesExecutionGateStatus.blocked,
        );
        expect(model.executionGate.statusLabel, 'Blocked');
        expect(model.statusLabel, 'Execution Gate Blocked');
        expect(model.importButtonDetail, contains('maintenance operation'));
        expect(model.activityLog.last.label, 'Maintenance lock active');
      },
    );

    test('reports ready source state after successful preflight', () {
      final workflowState = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesReadyToAddState(
          lineageAdmission: _testSameLineageAdmission(),
          data: _testPresentationData(
            folderPath: '/tmp/Archive-2017',
            sourceLabel: 'Archive-2017',
            attachmentsStatusLabel: 'Found',
            preflightSummaryLines: const ['Total messages: 42'],
            dryRunSummaryLines: const ['Estimated new messages: unavailable'],
            activityLog: const [
              HistoricalArchivesLogEntryViewModel(
                label: 'Preflight complete',
                message: 'Ready for the next slice.',
              ),
            ],
          ),
          evidence: _testInspectionEvidence(
            folderPath: '/tmp/Archive-2017',
            sourceLabel: 'Archive-2017',
            attachmentsStatusLabel: 'Found',
          ),
        ),
      );

      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: false,
        workflowState: workflowState,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );

      expect(model.statusLabel, 'Archive Source Ready');
      expect(model.summaryText, contains('completed source preflight'));
      expect(model.selectedFolderPath, '/tmp/Archive-2017');
      expect(model.preflightSummaryLines.single, 'Total messages: 42');
      expect(model.importButtonEnabled, isTrue);
      expect(
        model.importButtonDetail,
        contains('Archive rows remain isolated'),
      );
      expect(
        model.importSafetySummaryLines,
        contains(
          'Begin Import adds messages from "Archive-2017" without replacing current message data.',
        ),
      );
      expect(
        model.importSafetySummaryLines,
        contains('The live Messages database is not modified.'),
      );
      expect(
        model.importSafetySummaryLines,
        contains(
          'User settings, favourites, and manual labels remain in the overlay database.',
        ),
      );
      expect(
        model.importSafetySummaryLines,
        contains(
          'Archive messages keep separate source identity even when GUIDs overlap with live messages.',
        ),
      );
      expect(
        model.archiveManagementSummaryLines,
        contains('Removal target chat.db: /tmp/Archive-2017/chat.db'),
      );
      expect(
        model.archiveManagementSummaryLines,
        contains('Source-scoped archive removal: available after preflight'),
      );
      expect(model.removeImportedArchiveDataEnabled, isFalse);
      expect(
        model.removeImportedArchiveDataDetail,
        contains('source-scoped import rows'),
      );
    });

    test(
      'keeps a valid candidate visibly ready while gate availability refreshes',
      () {
        final workflowState = HistoricalArchivesWorkflowState(
          presentation: HistoricalArchivesReadyToAddState(
            lineageAdmission: _testSameLineageAdmission(),
            data: _testPresentationData(
              folderPath: '/tmp/Archive-2017',
              sourceLabel: 'Archive-2017',
              attachmentsStatusLabel: 'Found',
            ),
            evidence: _testInspectionEvidence(
              folderPath: '/tmp/Archive-2017',
              sourceLabel: 'Archive-2017',
              attachmentsStatusLabel: 'Found',
            ),
          ),
        );

        final available = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: workflowState,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        final busy = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(
            operation: ArchiveMutationOperation.liveGraphUpdate,
            ownerId: 'live-update#1',
            ownerLabel: 'live-update',
            holdCount: 1,
          ),
          isMaintenanceLocked: false,
          workflowState: workflowState,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );

        expect(
          available.narratorPresentation?.kind,
          HistoricalArchivesNarratorPresentationKind.readyForImport,
        );
        expect(
          busy.narratorPresentation?.kind,
          HistoricalArchivesNarratorPresentationKind.readyForImport,
        );
        expect(available.importButtonEnabled, isTrue);
        expect(busy.importButtonEnabled, isFalse);
        expect(busy.narratorPresentation?.detailsLines, isNotEmpty);
      },
    );

    test('projects typed ready evidence without summary-string parsing', () {
      const evidence = HistoricalArchivesInspectionEvidence(
        sourceIdentity: null,
        folderPath: '/tmp/archive',
        chatDbPath: '/tmp/archive/chat.db',
        sourceLabel: 'archive',
        chatDbStatus: ArchiveSourceInspectionStatus.readable,
        attachmentsStatusLabel: 'Found',
        totalMessages: 8882,
        totalChats: 140,
        totalHandles: 220,
        missingGuids: 0,
        earliestMessageUtc: '2012-07-25T08:00:00.000Z',
        latestMessageUtc: '2017-06-11T08:00:00.000Z',
        dateRangeUnavailableReason: null,
        dryRunNewMessages: 2369,
        dryRunDuplicateMessages: 6513,
        dryRunComparableMessages: 8882,
        dryRunUnavailableReason: null,
      );
      final workflowState = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesReadyToAddState(
          lineageAdmission: _testSameLineageAdmission(),
          data: _testPresentationData(
            folderPath: evidence.folderPath,
            chatDbPath: evidence.chatDbPath,
            sourceLabel: evidence.sourceLabel,
            chatDbStatus: evidence.chatDbStatus,
            attachmentsStatusLabel: evidence.attachmentsStatusLabel,
          ),
          evidence: evidence,
        ),
      );

      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: false,
        workflowState: workflowState,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );

      final presentation = model.narratorPresentation!;
      expect(
        presentation.kind,
        HistoricalArchivesNarratorPresentationKind.readyForImport,
      );
      expect(presentation.narratorText, contains('July 2012'));
      expect(
        presentation.instrumentationRows.map((row) => row.value),
        containsAll(['8,882', 'Jul 2012 – Jun 2017', '2,369', '6,513']),
      );
      expect(model.importButtonEnabled, isTrue);
    });

    test('derives import narration from typed scope progression', () {
      HistoricalArchivesNarratorPresentationViewModel presentationFor({
        required HistoricalArchiveImportProgress progress,
        String? failureDetail,
      }) {
        final failed = failureDetail != null;
        final data = _testPresentationData();
        final evidence = _testInspectionEvidence();
        final workflowState = HistoricalArchivesWorkflowState(
          presentation: failed
              ? HistoricalArchivesImportFailedState(
                  lineageAdmission: _testSameLineageAdmission(),
                  data: data,
                  evidence: evidence,
                  progress: progress,
                  failureDetail: failureDetail,
                )
              : HistoricalArchivesImportingState(
                  lineageAdmission: _testSameLineageAdmission(),
                  data: data,
                  evidence: evidence,
                  progress: progress,
                ),
        );
        return buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: !failed,
          workflowState: workflowState,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        ).narratorPresentation!;
      }

      const sourceNarrator = 'Adding this Messages folder to MessageLens.';
      const combinedHistoryNarrator =
          'The messages from this folder are added. Now I\u2019m updating your '
          'combined MessageLens history so everything appears together.';

      expect(
        presentationFor(
          progress: const HistoricalArchiveImportProgress(
            addingMessages: HistoricalArchiveImportStageStatus.running,
          ),
        ).narratorText,
        sourceNarrator,
      );
      expect(
        presentationFor(
          progress: const HistoricalArchiveImportProgress(
            addingMessages: HistoricalArchiveImportStageStatus.succeeded,
          ),
        ).narratorText,
        sourceNarrator,
      );
      expect(
        presentationFor(
          progress: const HistoricalArchiveImportProgress(
            addingMessages: HistoricalArchiveImportStageStatus.succeeded,
            preparingConversations: HistoricalArchiveImportStageStatus.running,
          ),
        ).narratorText,
        combinedHistoryNarrator,
      );
      expect(
        presentationFor(
          progress: const HistoricalArchiveImportProgress(
            addingMessages: HistoricalArchiveImportStageStatus.succeeded,
            preparingConversations:
                HistoricalArchiveImportStageStatus.succeeded,
            verifyingImport: HistoricalArchiveImportStageStatus.running,
            graphProjectionProgress: SourceScopedArchiveGraphProjectionProgress(
              activeUnit: SourceScopedArchiveGraphProjectionUnit.relationships,
              completedUnitCount: 5,
              totalUnitCount: 5,
              completedWorkCount: 150000,
              totalWorkCount: 150000,
            ),
          ),
        ).narratorText,
        isNull,
      );
      expect(
        presentationFor(
          progress: const HistoricalArchiveImportProgress(
            addingMessages: HistoricalArchiveImportStageStatus.succeeded,
            preparingConversations:
                HistoricalArchiveImportStageStatus.succeeded,
          ),
        ).narratorText,
        isNull,
      );
      expect(
        presentationFor(
          progress: const HistoricalArchiveImportProgress(
            addingMessages: HistoricalArchiveImportStageStatus.succeeded,
            preparingConversations:
                HistoricalArchiveImportStageStatus.succeeded,
            verifyingImport: HistoricalArchiveImportStageStatus.failed,
          ),
          failureDetail: 'Final verification failed.',
        ).narratorText,
        isNull,
      );
      expect(
        presentationFor(
          progress: const HistoricalArchiveImportProgress(
            addingMessages: HistoricalArchiveImportStageStatus.failed,
          ),
          failureDetail: 'Source import failed.',
        ).narratorText,
        "MessageLens couldn't finish adding this folder.",
      );
      expect(
        presentationFor(
          progress: const HistoricalArchiveImportProgress(
            addingMessages: HistoricalArchiveImportStageStatus.succeeded,
          ),
          failureDetail: 'Graph preparation did not begin.',
        ).narratorText,
        "MessageLens couldn't finish adding this folder.",
      );
    });

    test('maps real import progress into directed instrumentation', () {
      final workflowState = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesImportingState(
          lineageAdmission: _testSameLineageAdmission(),
          data: _testPresentationData(),
          evidence: _testInspectionEvidence(),
          progress: const HistoricalArchiveImportProgress(
            addingMessages: HistoricalArchiveImportStageStatus.succeeded,
            preparingConversations: HistoricalArchiveImportStageStatus.running,
            verifyingImport: HistoricalArchiveImportStageStatus.waiting,
            graphProjectionProgress: SourceScopedArchiveGraphProjectionProgress(
              activeUnit: SourceScopedArchiveGraphProjectionUnit.messages,
              completedUnitCount: 2,
              totalUnitCount: 5,
              completedWorkCount: 500,
              totalWorkCount: 1000,
            ),
          ),
        ),
      );

      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: true,
        workflowState: workflowState,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );

      expect(
        model.narratorPresentation?.kind,
        HistoricalArchivesNarratorPresentationKind.importingArchive,
      );
      expect(
        model.narratorPresentation?.narratorText,
        'The messages from this folder are added. Now I\u2019m updating your '
        'combined MessageLens history so everything appears together.',
      );
      expect(
        model.narratorPresentation?.instrumentationRows
            .map((row) => (row.label, row.value))
            .toList(),
        const [
          ('Adding messages from this folder', 'Done'),
          ('Preparing conversations for browsing', 'Working'),
          ('Participants', 'Done'),
          ('Conversations', 'Done'),
          ('Messages', '500 / 1,000'),
          ('Attachments', 'Waiting'),
          ('Relationships', 'Waiting'),
          ('Checking that import finished', 'Waiting'),
        ],
      );
      expect(model.importButtonEnabled, isFalse);
    });

    test('preserves completed stages when a later import stage fails', () {
      const evidence = HistoricalArchivesInspectionEvidence(
        sourceIdentity: null,
        folderPath: '/tmp/archive',
        chatDbPath: '/tmp/archive/chat.db',
        sourceLabel: 'archive',
        chatDbStatus: ArchiveSourceInspectionStatus.readable,
        attachmentsStatusLabel: 'Not found',
        totalMessages: 42,
        totalChats: 4,
        totalHandles: 7,
        missingGuids: 0,
        earliestMessageUtc: '2012-07-25T08:00:00.000Z',
        latestMessageUtc: '2017-06-11T08:00:00.000Z',
        dateRangeUnavailableReason: null,
        dryRunNewMessages: 42,
        dryRunDuplicateMessages: 0,
        dryRunComparableMessages: 42,
        dryRunUnavailableReason: null,
      );
      final workflowState = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesImportFailedState(
          lineageAdmission: _testSameLineageAdmission(),
          data: _testPresentationData(folderPath: evidence.folderPath),
          evidence: evidence,
          failureDetail: 'Graph projection failed.',
          progress: const HistoricalArchiveImportProgress(
            addingMessages: HistoricalArchiveImportStageStatus.succeeded,
            preparingConversations: HistoricalArchiveImportStageStatus.failed,
            verifyingImport: HistoricalArchiveImportStageStatus.waiting,
          ),
        ),
      );

      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: false,
        workflowState: workflowState,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );

      expect(
        model.narratorPresentation?.kind,
        HistoricalArchivesNarratorPresentationKind.importFailed,
      );
      expect(
        model.narratorPresentation?.narratorText,
        'The messages from this folder are added. Now I\u2019m updating your '
        'combined MessageLens history so everything appears together.',
      );
      expect(
        model.narratorPresentation?.instrumentationRows
            .map((row) => row.value)
            .toList(),
        const ['Done', 'Failed', 'Waiting'],
      );
      expect(model.importButtonEnabled, isTrue);
      expect(
        model.narratorPresentation?.detailsLines,
        contains('Graph projection failed.'),
      );
    });

    test('ready projection reports an unavailable comparison honestly', () {
      const evidence = HistoricalArchivesInspectionEvidence(
        sourceIdentity: null,
        folderPath: '/tmp/archive',
        chatDbPath: '/tmp/archive/chat.db',
        sourceLabel: 'archive',
        chatDbStatus: ArchiveSourceInspectionStatus.readable,
        attachmentsStatusLabel: 'Not found',
        totalMessages: 42,
        totalChats: 4,
        totalHandles: 7,
        missingGuids: 0,
        earliestMessageUtc: null,
        latestMessageUtc: null,
        dateRangeUnavailableReason: 'No usable dates were found.',
        dryRunNewMessages: null,
        dryRunDuplicateMessages: null,
        dryRunComparableMessages: null,
        dryRunUnavailableReason: 'Graph comparison is unavailable.',
      );
      final workflowState = HistoricalArchivesWorkflowState(
        presentation: HistoricalArchivesReadyToAddState(
          lineageAdmission: _testSameLineageAdmission(),
          data: _testPresentationData(
            folderPath: evidence.folderPath,
            preflightDetail: 'Source checks succeeded without comparison.',
          ),
          evidence: evidence,
        ),
      );

      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: false,
        workflowState: workflowState,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );

      expect(
        model.narratorPresentation!.instrumentationRows,
        contains(
          isA<HistoricalArchivesInstrumentationRowViewModel>()
              .having((row) => row.label, 'label', 'Message comparison')
              .having((row) => row.value, 'value', 'Unavailable'),
        ),
      );
      expect(model.importButtonEnabled, isTrue);
    });

    test(
      'ready projection refuses internally incoherent comparison evidence',
      () {
        const evidence = HistoricalArchivesInspectionEvidence(
          sourceIdentity: null,
          folderPath: '/tmp/archive',
          chatDbPath: '/tmp/archive/chat.db',
          sourceLabel: 'archive',
          chatDbStatus: ArchiveSourceInspectionStatus.readable,
          attachmentsStatusLabel: 'Not found',
          totalMessages: 8882,
          totalChats: 4,
          totalHandles: 7,
          missingGuids: 0,
          earliestMessageUtc: '2012-07-25T08:00:00.000Z',
          latestMessageUtc: '2017-06-11T08:00:00.000Z',
          dateRangeUnavailableReason: null,
          dryRunNewMessages: -6513,
          dryRunDuplicateMessages: 15395,
          dryRunComparableMessages: 8882,
          dryRunUnavailableReason: null,
        );
        final workflowState = HistoricalArchivesWorkflowState(
          presentation: HistoricalArchivesReadyToAddState(
            lineageAdmission: _testSameLineageAdmission(),
            data: _testPresentationData(folderPath: evidence.folderPath),
            evidence: evidence,
          ),
        );

        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: workflowState,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );

        expect(
          model.narratorPresentation?.instrumentationRows,
          contains(
            isA<HistoricalArchivesInstrumentationRowViewModel>()
                .having((row) => row.label, 'label', 'Message comparison')
                .having((row) => row.value, 'value', 'Unavailable'),
          ),
        );
        expect(
          model.narratorPresentation?.instrumentationRows.map(
            (row) => row.value,
          ),
          isNot(contains('-6,513')),
        );
        expect(
          model.narratorPresentation?.instrumentationRows.map(
            (row) => row.value,
          ),
          isNot(contains('15,395')),
        );
      },
    );

    test(
      'failed inspection distinguishes deterministic and retryable failure',
      () {
        HistoricalArchivesWorkflowPanelViewModel buildFailure(
          ArchiveSourceInspectionStatus chatDbStatus,
        ) {
          final workflowState = HistoricalArchivesWorkflowState(
            presentation: HistoricalArchivesInspectionFailedState(
              data: _testPresentationData(
                chatDbStatus: chatDbStatus,
                preflightStatus: HistoricalArchivesPreflightStatus.failed,
                preflightStatusLabel: 'Preflight failed',
                preflightDetail: 'Inspection failed for testing.',
              ),
              evidence: _testInspectionEvidence(chatDbStatus: chatDbStatus),
            ),
          );
          return buildHistoricalArchivesWorkflowPanelModel(
            executionGateState: const ArchiveMutationCoordinatorState(),
            isMaintenanceLocked: false,
            workflowState: workflowState,
            currentMessagesDatabasePath: currentMessagesDatabasePath,
          );
        }

        expect(
          buildFailure(
            ArchiveSourceInspectionStatus.missing,
          ).narratorPresentation!.retryInspectionEnabled,
          isFalse,
        );
        expect(
          buildFailure(
            ArchiveSourceInspectionStatus.readFailed,
          ).narratorPresentation!.retryInspectionEnabled,
          isTrue,
        );
      },
    );
  });

  group('HistoricalArchivesWorkflow narrator lifecycle', () {
    test('arm switching creates a virgin destination hub', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final workflow = container.read(
        historicalArchivesWorkflowProvider.notifier,
      );

      workflow.selectSourceType(
        HistoricalArchiveSourceType.messageLensDataFolders,
      );
      var state = container.read(historicalArchivesWorkflowProvider);
      expect(state.presentation, isA<HistoricalArchivesHubState>());
      expect(
        state.sourceType,
        HistoricalArchiveSourceType.messageLensDataFolders,
      );
      expect(state.selectedFolderPath, isNull);
      expect(state.messageLensNotice, isNull);

      workflow.selectSourceType(HistoricalArchiveSourceType.messagesFolders);
      state = container.read(historicalArchivesWorkflowProvider);
      expect(state.presentation, isA<HistoricalArchivesHubState>());
      expect(state.sourceType, HistoricalArchiveSourceType.messagesFolders);
      expect(state.selectedFolderPath, isNull);
    });

    test(
      'arm switching discards completed transient candidate evidence',
      () async {
        final container = ProviderContainer(
          overrides: [
            messageLensHistoricalArchivePreflightProvider.overrideWith(
              (ref) async => _FakeMessageLensHistoricalArchivePreflight(
                _messageLensReady(recoverableCount: 3, recoverableBytes: 8192),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        workflow.selectSourceType(
          HistoricalArchiveSourceType.messageLensDataFolders,
        );
        await workflow.loadMessageLensFolder(folderPath: '/tmp/donor');
        expect(
          container.read(historicalArchivesWorkflowProvider).presentation,
          isA<HistoricalArchivesMessageLensReadyState>(),
        );

        workflow.selectSourceType(HistoricalArchiveSourceType.messagesFolders);
        var state = container.read(historicalArchivesWorkflowProvider);
        expect(state.presentation, isA<HistoricalArchivesHubState>());
        expect(state.sourceType, HistoricalArchiveSourceType.messagesFolders);
        expect(state.selectedFolderPath, isNull);

        workflow.selectSourceType(
          HistoricalArchiveSourceType.messageLensDataFolders,
        );
        state = container.read(historicalArchivesWorkflowProvider);
        expect(state.presentation, isA<HistoricalArchivesHubState>());
        expect(
          state.sourceType,
          HistoricalArchiveSourceType.messageLensDataFolders,
        );
        expect(state.selectedFolderPath, isNull);
      },
    );

    test('active mutation mechanically blocks source-arm switching', () {
      final container = ProviderContainer(
        overrides: [
          historicalArchivesWorkflowProvider.overrideWith(
            () => _MutationOwnedHistoricalArchivesWorkflow(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final workflow = container.read(
        historicalArchivesWorkflowProvider.notifier,
      );
      final before = container.read(historicalArchivesWorkflowProvider);
      expect(before.presentation, isA<HistoricalArchivesImportingState>());
      expect(before.sourceTypeSwitchEnabled, isFalse);

      workflow.selectSourceType(
        HistoricalArchiveSourceType.messageLensDataFolders,
      );

      final after = container.read(historicalArchivesWorkflowProvider);
      expect(after.presentation, isA<HistoricalArchivesImportingState>());
      expect(after.sourceType, HistoricalArchiveSourceType.messagesFolders);
    });

    test('MessageLens ready evidence remains typed and exact', () async {
      final preflight = _FakeMessageLensHistoricalArchivePreflight(
        _messageLensReady(recoverableCount: 3, recoverableBytes: 8192),
      );
      final container = ProviderContainer(
        overrides: [
          messageLensHistoricalArchivePreflightProvider.overrideWith(
            (ref) async => preflight,
          ),
        ],
      );
      addTearDown(container.dispose);
      final workflow = container.read(
        historicalArchivesWorkflowProvider.notifier,
      );
      workflow.selectSourceType(
        HistoricalArchiveSourceType.messageLensDataFolders,
      );

      await workflow.loadMessageLensFolder(folderPath: '/tmp/donor');

      final state = container.read(historicalArchivesWorkflowProvider);
      expect(
        state.presentation,
        isA<HistoricalArchivesMessageLensReadyState>(),
      );
      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: false,
        workflowState: state,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );
      expect(
        model.narratorPresentation?.kind,
        HistoricalArchivesNarratorPresentationKind.messageLensReady,
      );
      expect(
        model.narratorPresentation?.instrumentationRows.map(
          (row) => (row.label, row.value),
        ),
        containsAll(const [
          ('Recoverable attachments', '3'),
          ('Recoverable size', '8.00 KB'),
        ]),
      );
      expect(preflight.inspectedFolders, const ['/tmp/donor']);
    });

    test(
      'MessageLens recovery paints first, reports real stages, dwells, and returns to hub after acknowledgement',
      () async {
        final archiveFixture = await TestArchiveFixture.create(
          prefix: 'historical_archives_message_lens_recovery_test_',
        );
        addTearDown(archiveFixture.dispose);
        final ready = _messageLensReady(
          recoverableCount: 3,
          recoverableBytes: 60,
        );
        final runner = _ControlledMessageLensAttachmentRecoveryBatchRunner();
        final container = ProviderContainer(
          overrides: [
            admittedArchiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            messageLensHistoricalArchivePreflightProvider.overrideWith(
              (ref) async => _FakeMessageLensHistoricalArchivePreflight(ready),
            ),
            messageLensAttachmentRecoveryBatchExecutorProvider(
              donorArchiveRoot: '/tmp/donor',
            ).overrideWith((ref) async => runner),
          ],
        );
        addTearDown(container.dispose);
        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        workflow.selectSourceType(
          HistoricalArchiveSourceType.messageLensDataFolders,
        );
        await workflow.loadMessageLensFolder(folderPath: '/tmp/donor');

        final frameBarrier = Completer<void>();
        final recovery = workflow.recoverMessageLensAttachments(
          waitForOperationPresentation: () => frameBarrier.future,
        );
        await Future<void>.delayed(Duration.zero);

        var state = container.read(historicalArchivesWorkflowProvider);
        expect(
          state.presentation,
          isA<HistoricalArchivesMessageLensRecoveringState>(),
        );
        expect(runner.callCount, 0);

        frameBarrier.complete();
        await _waitUntil(() => runner.callCount == 1);
        state = container.read(historicalArchivesWorkflowProvider);
        final active = state.presentation;
        expect(active, isA<HistoricalArchivesMessageLensRecoveringState>());
        expect(
          (active as HistoricalArchivesMessageLensRecoveringState)
              .progress
              .stage,
          MessageLensAttachmentRecoveryBatchStage.installingPayloads,
        );
        var model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: container.read(
            archiveMutationCoordinatorProvider,
          ),
          isMaintenanceLocked: false,
          workflowState: state,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          model.narratorPresentation?.instrumentationRows.map(
            (row) => (row.label, row.status),
          ),
          contains(const (
            'Recovering attachment files',
            HistoricalArchivesInstrumentationStatus.working,
          )),
        );

        runner.release.complete();
        await _waitUntil(() {
          final presentation = container
              .read(historicalArchivesWorkflowProvider)
              .presentation;
          return presentation is HistoricalArchivesMessageLensRecoveringState &&
              presentation.progress.stage ==
                  MessageLensAttachmentRecoveryBatchStage.complete;
        });
        state = container.read(historicalArchivesWorkflowProvider);
        model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: container.read(
            archiveMutationCoordinatorProvider,
          ),
          isMaintenanceLocked: false,
          workflowState: state,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          model.narratorPresentation?.instrumentationRows,
          everyElement(
            isA<HistoricalArchivesInstrumentationRowViewModel>().having(
              (row) => row.status,
              'status',
              HistoricalArchivesInstrumentationStatus.resolved,
            ),
          ),
        );
        expect(state.messageLensNotice, isNull);

        await recovery;
        state = container.read(historicalArchivesWorkflowProvider);
        expect(
          state.messageLensNotice?.kind,
          HistoricalArchivesMessageLensNoticeKind.recoveryComplete,
        );
        expect(state.messageLensNotice?.recoveredCount, 3);
        final notice = state.messageLensNotice!;
        workflow.dismissMessageLensNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );
        expect(
          container.read(historicalArchivesWorkflowProvider).presentation,
          isA<HistoricalArchivesHubState>(),
        );
      },
    );

    test(
      'MessageLens inspection paints truthful state before preflight starts',
      () async {
        final preflight = _FakeMessageLensHistoricalArchivePreflight(
          _messageLensReady(recoverableCount: 3, recoverableBytes: 8192),
        );
        final frameBarrier = Completer<void>();
        final container = ProviderContainer(
          overrides: [
            messageLensHistoricalArchivePreflightProvider.overrideWith(
              (ref) async => preflight,
            ),
          ],
        );
        addTearDown(container.dispose);
        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        workflow.selectSourceType(
          HistoricalArchiveSourceType.messageLensDataFolders,
        );

        final inspection = workflow.loadMessageLensFolder(
          folderPath: '/tmp/donor',
          waitForInspectionPresentation: () => frameBarrier.future,
        );
        await Future<void>.delayed(Duration.zero);

        final beforeFrame = container.read(historicalArchivesWorkflowProvider);
        expect(
          beforeFrame.presentation,
          isA<HistoricalArchivesMessageLensInspectingState>(),
        );
        expect(preflight.inspectedFolders, isEmpty);

        frameBarrier.complete();
        await inspection;

        expect(preflight.inspectedFolders, const ['/tmp/donor']);
      },
    );

    test(
      'MessageLens progress projects real numerator and denominator',
      () async {
        final releaseAfterProgress = Completer<void>();
        final preflight = _FakeMessageLensHistoricalArchivePreflight(
          _messageLensReady(recoverableCount: 3, recoverableBytes: 8192),
          progress: const MessageLensHistoricalArchivePreflightProgress(
            phase:
                MessageLensHistoricalArchivePreflightPhase.donorPayloadPresence,
            completedUnits: 250,
            totalUnits: 1000,
          ),
          releaseAfterProgress: releaseAfterProgress,
        );
        final container = ProviderContainer(
          overrides: [
            messageLensHistoricalArchivePreflightProvider.overrideWith(
              (ref) async => preflight,
            ),
          ],
        );
        addTearDown(container.dispose);
        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        workflow.selectSourceType(
          HistoricalArchiveSourceType.messageLensDataFolders,
        );

        final inspection = workflow.loadMessageLensFolder(
          folderPath: '/tmp/donor',
        );
        await Future<void>.delayed(Duration.zero);

        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: container.read(historicalArchivesWorkflowProvider),
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          model.narratorPresentation?.instrumentationRows.map(
            (row) => (row.label, row.value),
          ),
          contains(('Checking donor attachment files', '250 / 1,000')),
        );

        releaseAfterProgress.complete();
        await inspection;
      },
    );

    test(
      'legacy MessageLens ready evidence does not require archive identity',
      () async {
        final container = ProviderContainer(
          overrides: [
            messageLensHistoricalArchivePreflightProvider.overrideWith(
              (ref) async => _FakeMessageLensHistoricalArchivePreflight(
                _messageLensReady(
                  recoverableCount: 3,
                  recoverableBytes: 8192,
                  format:
                      MessageLensAttachmentRecoveryDonorFormat.importSchemaV8,
                  archiveInstanceId: null,
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        workflow.selectSourceType(
          HistoricalArchiveSourceType.messageLensDataFolders,
        );

        await workflow.loadMessageLensFolder(folderPath: '/tmp/donor');

        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: container.read(historicalArchivesWorkflowProvider),
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        final details = model.narratorPresentation!.detailsLines;
        expect(
          details,
          contains('Donor format: Historical MessageLens import schema 8'),
        );
        expect(
          details.where((line) => line.startsWith('Archive instance:')),
          isEmpty,
        );
      },
    );

    test(
      'zero recoverable attachments is an informational hub notice',
      () async {
        final container = ProviderContainer(
          overrides: [
            messageLensHistoricalArchivePreflightProvider.overrideWith(
              (ref) async => _FakeMessageLensHistoricalArchivePreflight(
                _messageLensReady(recoverableCount: 0, recoverableBytes: 0),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        workflow.selectSourceType(
          HistoricalArchiveSourceType.messageLensDataFolders,
        );

        await workflow.loadMessageLensFolder(folderPath: '/tmp/donor');

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(state.isHub, isTrue);
        expect(
          state.messageLensNotice?.kind,
          HistoricalArchivesMessageLensNoticeKind.nothingRecoverable,
        );
        expect(
          state.sourceType,
          HistoricalArchiveSourceType.messageLensDataFolders,
        );
      },
    );

    for (final entry
        in <
          (MessagesLineageAdmission, HistoricalArchivesMessageLensNoticeKind)
        >[
          (
            _testContradictoryLineageAdmission(),
            HistoricalArchivesMessageLensNoticeKind.contradictoryLineage,
          ),
          (
            _testInsufficientLineageAdmission(),
            HistoricalArchivesMessageLensNoticeKind.insufficientLineage,
          ),
        ]) {
      test(
        'MessageLens ${entry.$1.status.name} is a typed hub notice',
        () async {
          final container = ProviderContainer(
            overrides: [
              messageLensHistoricalArchivePreflightProvider.overrideWith(
                (ref) async => _FakeMessageLensHistoricalArchivePreflight(
                  MessageLensHistoricalArchiveLineageRejected(
                    admission: entry.$1,
                  ),
                ),
              ),
            ],
          );
          addTearDown(container.dispose);
          final workflow = container.read(
            historicalArchivesWorkflowProvider.notifier,
          );
          workflow.selectSourceType(
            HistoricalArchiveSourceType.messageLensDataFolders,
          );

          await workflow.loadMessageLensFolder(folderPath: '/tmp/donor');

          final state = container.read(historicalArchivesWorkflowProvider);
          expect(state.isHub, isTrue);
          expect(state.messageLensNotice?.kind, entry.$2);
        },
      );
    }

    test(
      'folder choice enters real inspection and resolves automatically',
      () async {
        final inspectionCompleter = Completer<ArchiveSourceInspection>();
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => const _FakeFolderChooser('/tmp/archive'),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async =>
                  _CompletingArchiveSourceInspector(inspectionCompleter.future),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => const _FakeHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final operation = container
            .read(historicalArchivesWorkflowProvider.notifier)
            .chooseMessagesFolder();
        await Future<void>.delayed(Duration.zero);

        expect(
          container.read(historicalArchivesWorkflowProvider).presentation,
          isA<HistoricalArchivesInspectingCandidateState>(),
        );

        inspectionCompleter.complete(
          ArchiveSourceInspection(
            folderPath: '/tmp/archive',
            sourceLabel: 'archive',
            chatDbPath: '/tmp/archive/chat.db',
            sourceIdentity: _identity(
              'historical-messages-archive:/tmp/archive/chat.db',
            ),
            chatDbStatus: ArchiveSourceInspectionStatus.readable,
            attachmentsStatusLabel: 'Not found',
            detail: 'Archive source is readable.',
            dryRunEstimate: const ArchiveSourceDryRunEstimate.available(
              comparableGuidCount: 42,
              duplicateGuidCount: 10,
              newGuidCount: 32,
            ),
            totalMessages: 42,
            totalChats: 4,
            totalHandles: 7,
            missingGuids: 0,
            earliestMessageUtc: '2012-07-25T08:00:00.000Z',
            latestMessageUtc: '2017-06-11T08:00:00.000Z',
          ),
        );
        await operation;

        final resolvedState = container.read(
          historicalArchivesWorkflowProvider,
        );
        expect(
          resolvedState.presentation,
          isA<HistoricalArchivesReadyToAddState>(),
        );
        expect(resolvedState.inspectionEvidence?.totalMessages, 42);
      },
    );

    test(
      'cancel abandons the ready candidate without starting new work',
      () async {
        final coordinator = _ImmediateArchiveMutationCoordinator();
        final folderChooser = _RecordingFolderChooser('/tmp/archive');
        final archiveSources = _RecordingHistoricalArchiveSources();
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            archiveMutationCoordinatorProvider.overrideWith(() => coordinator),
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => folderChooser,
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => archiveSources,
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.chooseMessagesFolder();
        expect(
          container.read(historicalArchivesWorkflowProvider).presentation,
          isA<HistoricalArchivesReadyToAddState>(),
        );

        workflow.cancelAddArchive();

        final cancelled = container.read(historicalArchivesWorkflowProvider);
        expect(cancelled.presentation, isA<HistoricalArchivesHubState>());
        expect(cancelled.selectedFolderPath, isNull);
        expect(cancelled.selectedKnownSourceKey, isNull);
        expect(cancelled.knownSourceReference, isNull);
        expect(folderChooser.callCount, 1);
        expect(coordinator.runCallCount, 0);
        expect(archiveSources.upsertCallCount, 1);
      },
    );

    for (final admission in <MessagesLineageAdmission>[
      _testContradictoryLineageAdmission(),
      _testInsufficientLineageAdmission(),
    ]) {
      test(
        '${admission.status.name} returns to hub notice without registration or import authorization',
        () async {
          final archiveSources = _RecordingHistoricalArchiveSources();
          final coordinator = _ImmediateArchiveMutationCoordinator();
          final container = ProviderContainer(
            overrides: [
              messagesLineageAdmissionAuthorityProvider.overrideWith(
                (ref) async => _FixedLineageAuthority(admission),
              ),
              archiveMutationCoordinatorProvider.overrideWith(
                () => coordinator,
              ),
              archiveSourceInspectorProvider.overrideWith(
                (ref) async => const _ImmediateArchiveSourceInspector(),
              ),
              historicalArchiveSourcesProvider.overrideWith(
                (ref) async => archiveSources,
              ),
              historicalArchiveImportedSourceLookupProvider.overrideWith(
                (ref) async => _FakeImportedSourceLookup(),
              ),
            ],
          );
          addTearDown(container.dispose);

          final workflow = container.read(
            historicalArchivesWorkflowProvider.notifier,
          );
          await workflow.loadFolder(folderPath: '/tmp/archive');

          final rejected = container.read(historicalArchivesWorkflowProvider);
          expect(
            rejected.presentation,
            isA<HistoricalArchivesLineageNoticeState>(),
          );
          expect(rejected.lineageNotice?.status, admission.status);
          expect(rejected.isHub, isTrue);
          expect(archiveSources.upsertCallCount, 0);

          await workflow.beginImportForSelectedSource();
          expect(coordinator.runCallCount, 0);
        },
      );
    }

    test(
      'authorization paints import ownership before work and dwells on real completion',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final releaseOperationPresentation = Completer<void>();
        final releaseImport = Completer<void>();
        final importedSourceLookup = _MutableImportedSourceLookup(match: null);
        final graphImportService = _ControlledArchiveGraphImportService((
          observer,
        ) async {
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
              transition: SourceScopedArchiveGraphImportStageTransition.started,
            ),
          );
          await releaseImport.future;
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
              transition:
                  SourceScopedArchiveGraphImportStageTransition.completed,
            ),
          );
          _emitCompleteGraphProjection(observer);
          importedSourceLookup.match = HistoricalArchiveImportedSourceMatch(
            identity: _identity(sourceKey),
            sourceId: 3,
            importedMessageCount: 42,
          );
          return _successfulArchiveGraphImportResult(sourceKey: sourceKey);
        });
        final archiveSources = _RecordingHistoricalArchiveSources();
        final coordinator = _ImmediateArchiveMutationCoordinator();
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            archiveMutationCoordinatorProvider.overrideWith(() => coordinator),
            sourceScopedArchiveGraphImportServiceProvider.overrideWith(
              (ref) async => graphImportService,
            ),
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => const _FakeFolderChooser('/tmp/archive'),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => archiveSources,
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => importedSourceLookup,
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.chooseMessagesFolder();

        final import = workflow.beginImportForSelectedSource(
          waitForOperationPresentation: () =>
              releaseOperationPresentation.future,
        );
        final duplicateAuthorization = workflow.beginImportForSelectedSource();

        final authorized = container.read(historicalArchivesWorkflowProvider);
        expect(
          authorized.presentation,
          isA<HistoricalArchivesImportingState>(),
        );
        expect(graphImportService.callCount, 0);
        expect(archiveSources.successfulImportUpdateCount, 0);

        await duplicateAuthorization;
        await Future<void>.delayed(Duration.zero);
        expect(graphImportService.callCount, 0);
        expect(coordinator.runCallCount, 0);

        releaseOperationPresentation.complete();
        await _waitUntil(() => graphImportService.callCount == 1);
        expect(coordinator.runCallCount, 1);
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .importProgress
              ?.statusFor(HistoricalArchiveImportStage.addingMessages),
          HistoricalArchiveImportStageStatus.running,
        );

        releaseImport.complete();
        await _waitUntil(
          () =>
              container
                  .read(historicalArchivesWorkflowProvider)
                  .importProgress
                  ?.isComplete ==
              true,
        );

        final completed = container.read(historicalArchivesWorkflowProvider);
        expect(completed.presentation, isA<HistoricalArchivesImportingState>());
        expect(
          HistoricalArchiveImportStage.values.map(
            completed.importProgress!.statusFor,
          ),
          everyElement(HistoricalArchiveImportStageStatus.succeeded),
        );
        expect(completed.knownSourceReference, isNull);
        expect(completed.selectedKnownSourceKey, isNull);
        expect(completed.importSuccessNotice, isNull);
        expect(archiveSources.successfulImportUpdateCount, 1);
        expect(
          historicalArchivesTerminalCompletedDwellDuration,
          const Duration(milliseconds: 1500),
        );

        final dwellStopwatch = Stopwatch()..start();
        await import;
        dwellStopwatch.stop();
        expect(
          dwellStopwatch.elapsed,
          greaterThanOrEqualTo(const Duration(milliseconds: 1250)),
        );
        expect(
          dwellStopwatch.elapsed,
          lessThan(const Duration(milliseconds: 2000)),
        );

        final settled = container.read(historicalArchivesWorkflowProvider);
        expect(
          settled.presentation,
          isA<HistoricalArchivesImportSuccessNoticeState>(),
        );
        expect(settled.importProgress, isNull);
        expect(settled.knownSourceReference, isNull);
        expect(settled.selectedKnownSourceKey, isNull);
        expect(settled.importSuccessNotice, isNotNull);
        expect(archiveSources.successfulImportUpdateCount, 1);

        final notice = settled.importSuccessNotice!;
        workflow.dismissImportSuccessNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );
        final acknowledged = container.read(historicalArchivesWorkflowProvider);
        expect(acknowledged.importSuccessNotice, isNull);
        expect(acknowledged.presentation, isA<HistoricalArchivesHubState>());
        expect(acknowledged.selectedKnownSourceKey, isNull);
        expect(acknowledged.knownSourceReference, isNull);
        expect(archiveSources.successfulImportUpdateCount, 1);
      },
    );

    test(
      'abandoned import presentation cannot enter mutation authority after frame wait',
      () async {
        final frameBarrier = Completer<void>();
        final coordinator = _ImmediateArchiveMutationCoordinator();
        final graphImportService = _ControlledArchiveGraphImportService((
          observer,
        ) async {
          return _successfulArchiveGraphImportResult(
            sourceKey: 'historical-messages-archive:/tmp/archive/chat.db',
          );
        });
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            archiveMutationCoordinatorProvider.overrideWith(() => coordinator),
            sourceScopedArchiveGraphImportServiceProvider.overrideWith(
              (ref) async => graphImportService,
            ),
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => const _FakeFolderChooser('/tmp/archive'),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => const _FakeHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.chooseMessagesFolder();

        final import = workflow.beginImportForSelectedSource(
          waitForOperationPresentation: () => frameBarrier.future,
        );
        expect(
          container.read(historicalArchivesWorkflowProvider).presentation,
          isA<HistoricalArchivesImportingState>(),
        );

        workflow.clearSelection();
        frameBarrier.complete();
        await import;

        expect(coordinator.runCallCount, 0);
        expect(graphImportService.callCount, 0);
        expect(
          container.read(historicalArchivesWorkflowProvider).presentation,
          isA<HistoricalArchivesHubState>(),
        );
      },
    );

    test(
      'an older success dwell cannot clear a newer ready candidate',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final importedSourceLookup = _MutableImportedSourceLookup(match: null);
        final graphImportService = _ControlledArchiveGraphImportService((
          observer,
        ) async {
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
              transition: SourceScopedArchiveGraphImportStageTransition.started,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
              transition:
                  SourceScopedArchiveGraphImportStageTransition.completed,
            ),
          );
          _emitCompleteGraphProjection(observer);
          importedSourceLookup.match = HistoricalArchiveImportedSourceMatch(
            identity: _identity(sourceKey),
            sourceId: 3,
            importedMessageCount: 42,
          );
          return _successfulArchiveGraphImportResult(sourceKey: sourceKey);
        });
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            archiveMutationCoordinatorProvider.overrideWith(
              () => _ImmediateArchiveMutationCoordinator(),
            ),
            sourceScopedArchiveGraphImportServiceProvider.overrideWith(
              (ref) async => graphImportService,
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => _RecordingHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => importedSourceLookup,
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.loadFolder(folderPath: '/tmp/archive');
        final oldImport = workflow.beginImportForSelectedSource();
        await _waitUntil(
          () =>
              container
                  .read(historicalArchivesWorkflowProvider)
                  .importProgress
                  ?.isComplete ==
              true,
        );

        importedSourceLookup.match = null;
        workflow.resetPresentationContext();
        await workflow.loadFolder(folderPath: '/tmp/new-archive');
        expect(
          container.read(historicalArchivesWorkflowProvider).presentation,
          isA<HistoricalArchivesReadyToAddState>(),
        );

        await oldImport;
        final newer = container.read(historicalArchivesWorkflowProvider);
        expect(newer.presentation, isA<HistoricalArchivesReadyToAddState>());
        expect(newer.selectedFolderPath, '/tmp/new-archive');
        expect(newer.importSuccessNotice, isNull);
      },
    );

    test(
      'partial graph failure preserves its last truthful unit and never dwells',
      () async {
        final graphImportService = _ControlledArchiveGraphImportService((
          observer,
        ) async {
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
              transition: SourceScopedArchiveGraphImportStageTransition.started,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
              transition:
                  SourceScopedArchiveGraphImportStageTransition.completed,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage
                  .projectingConversationGraph,
              transition: SourceScopedArchiveGraphImportStageTransition.started,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage
                  .projectingConversationGraph,
              transition:
                  SourceScopedArchiveGraphImportStageTransition.progressed,
              projectionProgress: SourceScopedArchiveGraphProjectionProgress(
                activeUnit: SourceScopedArchiveGraphProjectionUnit.messages,
                completedUnitCount: 2,
                totalUnitCount: 5,
                completedWorkCount: 500,
                totalWorkCount: 1000,
              ),
            ),
          );
          throw StateError('graph projection failed for testing');
        });
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            archiveMutationCoordinatorProvider.overrideWith(
              () => _ImmediateArchiveMutationCoordinator(),
            ),
            sourceScopedArchiveGraphImportServiceProvider.overrideWith(
              (ref) async => graphImportService,
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => _RecordingHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.loadFolder(folderPath: '/tmp/archive');
        await workflow.beginImportForSelectedSource();

        final failed = container.read(historicalArchivesWorkflowProvider);
        expect(failed.presentation, isA<HistoricalArchivesImportFailedState>());
        expect(
          failed.importProgress?.statusFor(
            HistoricalArchiveImportStage.preparingConversations,
          ),
          HistoricalArchiveImportStageStatus.failed,
        );
        expect(
          failed.importProgress?.graphProjectionProgress?.activeUnit,
          SourceScopedArchiveGraphProjectionUnit.messages,
        );
        expect(
          failed.importProgress?.graphProjectionProgress?.completedUnitCount,
          2,
        );
        expect(
          failed.importProgress?.graphProjectionProgress?.totalUnitCount,
          5,
        );
        expect(
          buildHistoricalArchivesWorkflowPanelModel(
                executionGateState: const ArchiveMutationCoordinatorState(),
                isMaintenanceLocked: false,
                workflowState: failed,
                currentMessagesDatabasePath: currentMessagesDatabasePath,
              ).narratorPresentation?.instrumentationRows
              .singleWhere((row) => row.label == 'Messages')
              .value,
          'Failed · 500 / 1,000',
        );
        expect(failed.knownSourceReference, isNull);
        expect(failed.selectedKnownSourceKey, isNull);
        expect(failed.importSuccessNotice, isNull);
      },
    );

    test('stale success dismissal cannot change a newer presentation', () {
      final workflow = _ControllableHistoricalArchivesWorkflow();
      final container = ProviderContainer(
        overrides: [
          messagesLineageAdmissionAuthorityProvider.overrideWith(
            (ref) async => const _SameLineageAuthority(),
          ),
          historicalArchivesWorkflowProvider.overrideWith(() => workflow),
        ],
      );
      addTearDown(container.dispose);
      container.read(historicalArchivesWorkflowProvider);

      workflow.emitImportSuccessNotice();
      workflow.resetPresentationContext();
      workflow.emitNewCandidate();

      workflow.dismissImportSuccessNotice(
        noticeOccurrence: 1,
        presentationSessionOccurrence: 0,
      );

      final state = container.read(historicalArchivesWorkflowProvider);
      expect(state.presentation, isA<HistoricalArchivesReadyToAddState>());
      expect(state.selectedFolderPath, '/tmp/new-archive');
    });

    testWidgets(
      'duplicate add restores hub and emits a bounded reference only after dismissal',
      (tester) async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final archiveSources = _RecordingHistoricalArchiveSources([
          _successfullyImportedArchiveSource(sourceKey: sourceKey),
        ]);
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => const _FakeFolderChooser('/tmp/archive'),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => archiveSources,
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(
                matchingFolderPath: '/tmp/archive',
                match: HistoricalArchiveImportedSourceMatch(
                  identity: _identity(sourceKey),
                  sourceId: 3,
                  importedMessageCount: 42,
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.chooseMessagesFolder();

        final recognized = container.read(historicalArchivesWorkflowProvider);
        expect(
          recognized.presentation,
          isA<HistoricalArchivesDuplicateNoticeState>(),
        );
        expect(recognized.duplicateFolderNotice?.sourceKey, sourceKey);
        expect(recognized.duplicateFolderNotice?.noticeOccurrence, 1);
        expect(recognized.knownSourceReference, isNull);
        expect(recognized.selectedKnownSourceKey, isNull);
        expect(recognized.selectedFolderPath, isNull);
        expect(archiveSources.upsertCallCount, 0);

        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: recognized,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(model.isHub, isTrue);
        expect(model.narratorPresentation, isNull);
        expect(model.importButtonEnabled, isFalse);

        final firstNotice = recognized.duplicateFolderNotice!;
        workflow.dismissDuplicateFolderNotice(
          noticeOccurrence: firstNotice.noticeOccurrence,
          presentationSessionOccurrence:
              firstNotice.presentationSessionOccurrence,
        );
        final firstReference = container.read(
          historicalArchivesWorkflowProvider,
        );
        expect(firstReference.duplicateFolderNotice, isNull);
        expect(firstReference.knownSourceReference?.sourceKey, sourceKey);
        expect(firstReference.knownSourceReference?.referenceOccurrence, 1);
        expect(
          firstReference.presentation,
          isA<HistoricalArchivesKnownSourceReferenceState>(),
        );
        await tester.pump(const Duration(milliseconds: 2000));

        await workflow.chooseMessagesFolder();
        final repeated = container.read(historicalArchivesWorkflowProvider);
        expect(repeated.duplicateFolderNotice?.noticeOccurrence, 2);
        expect(repeated.knownSourceReference, isNull);

        final repeatedNotice = repeated.duplicateFolderNotice!;
        workflow.dismissDuplicateFolderNotice(
          noticeOccurrence: repeatedNotice.noticeOccurrence,
          presentationSessionOccurrence:
              repeatedNotice.presentationSessionOccurrence,
        );
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .knownSourceReference
              ?.referenceOccurrence,
          2,
        );

        await tester.pump(const Duration(milliseconds: 1000));
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .knownSourceReference
              ?.referenceOccurrence,
          2,
        );
        await tester.pump(const Duration(milliseconds: 2749));
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .knownSourceReference,
          isNotNull,
        );
        await tester.pump(const Duration(milliseconds: 1));
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .knownSourceReference,
          isNull,
        );
      },
    );

    test(
      'missing chat db rejects the add before persistence and restores the hub',
      () async {
        final archiveSources = _RecordingHistoricalArchiveSources();
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => const _FakeFolderChooser('/tmp/not-an-archive'),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _MissingArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => archiveSources,
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.chooseMessagesFolder();

        final rejected = container.read(historicalArchivesWorkflowProvider);
        expect(
          rejected.presentation,
          isA<HistoricalArchivesInvalidNoticeState>(),
        );
        expect(rejected.invalidFolderNotice?.noticeOccurrence, 1);
        expect(rejected.selectedFolderPath, isNull);
        expect(rejected.inspectionEvidence, isNull);
        expect(rejected.duplicateFolderNotice, isNull);
        expect(rejected.knownSourceReference, isNull);
        expect(rejected.selectedKnownSourceKey, isNull);
        expect(archiveSources.upsertCallCount, 0);

        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: rejected,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(model.isHub, isTrue);
        expect(model.narratorPresentation, isNull);
        expect(model.importButtonEnabled, isFalse);

        final notice = rejected.invalidFolderNotice!;
        workflow.dismissInvalidFolderNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );

        final dismissed = container.read(historicalArchivesWorkflowProvider);
        expect(dismissed.invalidFolderNotice, isNull);
        expect(dismissed.presentation, isA<HistoricalArchivesHubState>());
        expect(dismissed.knownSourceReference, isNull);
        expect(dismissed.selectedKnownSourceKey, isNull);
        expect(archiveSources.upsertCallCount, 0);
      },
    );

    test(
      'late invalid-folder dismissal cannot revive an abandoned session',
      () async {
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _MissingArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => const _FakeHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.loadFolder(folderPath: '/tmp/not-an-archive');
        final notice = container
            .read(historicalArchivesWorkflowProvider)
            .invalidFolderNotice!;

        workflow.resetPresentationContext();
        workflow.dismissInvalidFolderNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(state.presentation, isA<HistoricalArchivesHubState>());
        expect(state.invalidFolderNotice, isNull);
        expect(state.knownSourceReference, isNull);
        expect(state.selectedKnownSourceKey, isNull);
      },
    );

    test(
      'read failure remains an inspection failure, not invalid folder',
      () async {
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ReadFailedArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => const _FakeHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(historicalArchivesWorkflowProvider.notifier)
            .loadFolder(folderPath: '/tmp/unreadable-archive');

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(
          state.presentation,
          isA<HistoricalArchivesInspectionFailedState>(),
        );
        expect(state.invalidFolderNotice, isNull);
        expect(state.chatDbStatusLabel, 'Read failed');
      },
    );

    test(
      'late duplicate dismissal cannot create a reference after navigation reset',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => _FakeHistoricalArchiveSources([
                _successfullyImportedArchiveSource(sourceKey: sourceKey),
              ]),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(
                matchingFolderPath: '/tmp/archive',
                match: HistoricalArchiveImportedSourceMatch(
                  identity: _identity(sourceKey),
                  sourceId: 3,
                  importedMessageCount: 42,
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.loadFolder(folderPath: '/tmp/archive');
        final notice = container
            .read(historicalArchivesWorkflowProvider)
            .duplicateFolderNotice!;

        workflow.resetPresentationContext();
        workflow.dismissDuplicateFolderNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(state.presentation, isA<HistoricalArchivesHubState>());
        expect(state.duplicateFolderNotice, isNull);
        expect(state.knownSourceReference, isNull);
      },
    );

    test(
      'remembered source with no imported messages remains eligible for add flow',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final source = HistoricalArchiveSourceMetadata(
          identity: _identity(sourceKey),
          sourceChatDb: '/tmp/archive/chat.db',
          folderPath: '/tmp/archive',
          sourceLabel: 'Archive',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Not found',
          totalMessages: 42,
          earliestMessageUtc: '2012-07-25T08:00:00.000Z',
          latestMessageUtc: '2017-06-11T08:00:00.000Z',
          preflightStatusLabel: 'Previously inspected',
          dryRunNewMessages: 42,
          dryRunDuplicateMessages: 0,
          lastImportFinishedAtUtc: null,
          lastImportSuccess: null,
          lastImportError: null,
          lastImportedMessageCount: null,
        );
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => const _FakeFolderChooser('/tmp/archive'),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => const _FakeHistoricalArchiveSources(),
            ),
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => [source],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(historicalArchivesWorkflowProvider.notifier)
            .chooseMessagesFolder();

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(state.presentation, isA<HistoricalArchivesReadyToAddState>());
        expect(state.knownSourceReference, isNull);
        expect(
          await container.read(historicalArchiveSourceMetadataProvider.future),
          [source],
        );
      },
    );

    test(
      'known-source navigation uses canonical identity without a reference event',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => [
                HistoricalArchiveSourceMetadata(
                  identity: _identity(sourceKey),
                  sourceChatDb: '/tmp/archive/chat.db',
                  folderPath: '/tmp/archive',
                  sourceLabel: 'Archive',
                  chatDbStatusLabel: 'Found and readable',
                  attachmentsStatusLabel: 'Found',
                  totalMessages: 42,
                  earliestMessageUtc: '2012-07-25T08:00:00.000Z',
                  latestMessageUtc: '2017-06-11T08:00:00.000Z',
                  preflightStatusLabel: 'Preflight complete',
                  dryRunNewMessages: 0,
                  dryRunDuplicateMessages: 42,
                  lastImportFinishedAtUtc: '2026-08-10T18:30:00.000Z',
                  lastImportSuccess: true,
                  lastImportError: null,
                  lastImportedMessageCount: 42,
                ),
              ],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(
                match: HistoricalArchiveImportedSourceMatch(
                  identity: _identity(sourceKey),
                  sourceId: 3,
                  importedMessageCount: 42,
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(historicalArchivesWorkflowProvider.notifier)
            .showKnownSource(identity: _identity(sourceKey));

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(
          state.presentation,
          isA<HistoricalArchivesExistingSourceState>(),
        );
        expect(state.selectedFolderPath, '/tmp/archive');
        expect(state.selectedKnownSourceKey, sourceKey);
        expect(state.knownSourceReference, isNull);
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: state,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(model.narratorPresentation, isNull);
        expect(
          model.existingSourcePresentation?.sourceTypeStatement,
          'This is a Mac Messages folder.',
        );
        expect(
          model.existingSourcePresentation?.importDateStatement,
          'You added it to MessageLens on Aug 10, 2026.',
        );
        expect(
          model.existingSourcePresentation?.contentsStatement,
          'It contains 42 messages sent or received between July 2012 and June 2017.',
        );
        expect(
          model.existingSourcePresentation?.detailsLines,
          contains('Folder: /tmp/archive'),
        );
        expect(model.importButtonEnabled, isFalse);
        expect(model.removeImportedArchiveDataEnabled, isTrue);
      },
    );

    test(
      'selected source removal exposes real ordered stages then returns to hub',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final source = HistoricalArchiveSourceMetadata(
          identity: _identity(sourceKey),
          sourceChatDb: '/tmp/archive/chat.db',
          folderPath: '/tmp/archive',
          sourceLabel: 'Archive',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Found',
          totalMessages: 42,
          earliestMessageUtc: '2012-07-25T08:00:00.000Z',
          latestMessageUtc: '2017-06-11T08:00:00.000Z',
          preflightStatusLabel: 'Imported successfully',
          dryRunNewMessages: 0,
          dryRunDuplicateMessages: 42,
          lastImportFinishedAtUtc: '2026-08-10T18:30:00.000Z',
          lastImportSuccess: true,
          lastImportError: null,
          lastImportedMessageCount: 42,
        );
        final verificationCompleter =
            Completer<HistoricalArchiveImportedSourceMatch?>();
        final lookup = _FinalVerificationImportedSourceLookup(
          match: HistoricalArchiveImportedSourceMatch(
            identity: _identity(sourceKey),
            sourceId: 3,
            importedMessageCount: 42,
          ),
          verificationCompleter: verificationCompleter,
        );
        final factsRemovalCompleter = Completer<void>();
        final graphRebuildCompleter = Completer<void>();
        final removalService = _RecordingArchiveRemovalService((
          observer,
        ) async {
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.started,
            ),
          );
          await factsRemovalCompleter.future;
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.completed,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage
                  .rebuildingConversationGraph,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.started,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage
                  .rebuildingConversationGraph,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.progressed,
              projectionProgress: SourceScopedArchiveGraphProjectionProgress(
                activeUnit: SourceScopedArchiveGraphProjectionUnit.messages,
                completedUnitCount: 2,
                totalUnitCount: 5,
                completedWorkCount: 120,
                totalWorkCount: 200,
              ),
            ),
          );
          await graphRebuildCompleter.future;
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage
                  .rebuildingConversationGraph,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.completed,
            ),
          );
          return const SourceScopedArchiveGraphRemovalResult(
            sourceId: 3,
            deletionResult: null,
            graphReprojected: true,
          );
        });
        final coordinator = _ImmediateArchiveMutationCoordinator();
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            archiveMutationCoordinatorProvider.overrideWith(() => coordinator),
            sourceScopedArchiveGraphRemovalServiceProvider.overrideWith(
              (ref) async => removalService,
            ),
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => [source],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => lookup,
            ),
            currentMessagesSourcePathProvider.overrideWith(
              (ref) => currentMessagesDatabasePath,
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.showKnownSource(identity: _identity(sourceKey));

        final removal = workflow.removeImportedArchiveDataForSelectedSource();
        await Future<void>.delayed(Duration.zero);

        final running = container.read(historicalArchivesWorkflowProvider);
        final runningModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: running,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(running.presentation, isA<HistoricalArchivesRemovingState>());
        expect(running.selectedKnownSourceKey, sourceKey);
        expect(
          runningModel.narratorPresentation?.kind,
          HistoricalArchivesNarratorPresentationKind.removingSource,
        );
        expect(
          runningModel.narratorPresentation?.narratorText,
          'Removing the messages added from this folder.',
        );
        expect(
          runningModel.narratorPresentation?.instrumentationRows
              .map((row) => (row.label, row.value))
              .toList(),
          const [
            ('Removing messages added from this folder', 'Working'),
            ('Updating your MessageLens history', 'Waiting'),
            ('Checking that removal finished', 'Waiting'),
          ],
        );
        expect(removalService.callCount, 1);
        expect(coordinator.runCallCount, 1);

        factsRemovalCompleter.complete();
        await Future<void>.delayed(Duration.zero);
        final rebuildingModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: container.read(historicalArchivesWorkflowProvider),
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          rebuildingModel.narratorPresentation?.instrumentationRows
              .map((row) => (row.label, row.value, row.indentationLevel))
              .toList(),
          const [
            ('Removing messages added from this folder', 'Done', 0),
            ('Updating your MessageLens history', 'Working', 0),
            ('Participants', 'Done', 1),
            ('Conversations', 'Done', 1),
            ('Messages', '120 / 200', 1),
            ('Attachments', 'Waiting', 1),
            ('Relationships', 'Waiting', 1),
            ('Checking that removal finished', 'Waiting', 0),
          ],
        );
        expect(
          rebuildingModel.narratorPresentation?.narratorText,
          'Those messages are removed. Now I’m updating your remaining '
          'MessageLens history so everything stays together.',
        );

        graphRebuildCompleter.complete();
        await Future<void>.delayed(Duration.zero);
        final verifyingModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: container.read(historicalArchivesWorkflowProvider),
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          verifyingModel.narratorPresentation?.instrumentationRows
              .map((row) => row.value)
              .toList(),
          const [
            'Done',
            'Done',
            'Done',
            'Done',
            'Done',
            'Done',
            'Done',
            'Working',
          ],
        );
        expect(verifyingModel.narratorPresentation?.narratorText, isNull);

        verificationCompleter.complete(null);
        await _waitUntil(
          () =>
              container
                  .read(historicalArchivesWorkflowProvider)
                  .removalProgress
                  ?.isComplete ==
              true,
        );
        final allDone = container.read(historicalArchivesWorkflowProvider);
        final allDoneModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: allDone,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(allDone.presentation, isA<HistoricalArchivesRemovingState>());
        expect(allDoneModel.narratorPresentation?.narratorText, isNull);
        expect(
          allDoneModel.narratorPresentation?.instrumentationRows.map(
            (row) => row.value,
          ),
          everyElement('Done'),
        );
        await removal;

        final completed = container.read(historicalArchivesWorkflowProvider);
        final completedModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: completed,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(completed.presentation, isA<HistoricalArchivesHubState>());
        expect(completed.selectedKnownSourceKey, isNull);
        expect(completed.selectedFolderPath, isNull);
        expect(completedModel.isHub, isTrue);
        expect(completedModel.narratorPresentation, isNull);
        expect(completedModel.existingSourcePresentation, isNull);
        expect(
          await container.read(historicalArchiveSourceMetadataProvider.future),
          [source],
        );
      },
    );

    test(
      'failed graph rebuild preserves stage truth while imported facts remain',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final source = HistoricalArchiveSourceMetadata(
          identity: _identity(sourceKey),
          sourceChatDb: '/tmp/archive/chat.db',
          folderPath: '/tmp/archive',
          sourceLabel: 'Archive',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Found',
          totalMessages: 42,
          earliestMessageUtc: '2012-07-25T08:00:00.000Z',
          latestMessageUtc: '2017-06-11T08:00:00.000Z',
          preflightStatusLabel: 'Imported successfully',
          dryRunNewMessages: 0,
          dryRunDuplicateMessages: 42,
          lastImportFinishedAtUtc: '2026-08-10T18:30:00.000Z',
          lastImportSuccess: true,
          lastImportError: null,
          lastImportedMessageCount: 42,
        );
        final lookup = _MutableImportedSourceLookup(
          match: HistoricalArchiveImportedSourceMatch(
            identity: _identity(sourceKey),
            sourceId: 3,
            importedMessageCount: 42,
          ),
        );
        final removalService = _RecordingArchiveRemovalService((
          observer,
        ) async {
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.started,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.completed,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage
                  .rebuildingConversationGraph,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.started,
            ),
          );
          throw StateError('projection failed');
        });
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            archiveMutationCoordinatorProvider.overrideWith(
              _ImmediateArchiveMutationCoordinator.new,
            ),
            sourceScopedArchiveGraphRemovalServiceProvider.overrideWith(
              (ref) async => removalService,
            ),
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => [source],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => lookup,
            ),
            currentMessagesSourcePathProvider.overrideWith(
              (ref) => currentMessagesDatabasePath,
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.showKnownSource(identity: _identity(sourceKey));
        await workflow.removeImportedArchiveDataForSelectedSource();

        final failed = container.read(historicalArchivesWorkflowProvider);
        final failedModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: failed,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          failed.presentation,
          isA<HistoricalArchivesRemovalFailedState>(),
        );
        expect(failed.selectedKnownSourceKey, sourceKey);
        expect(failed.removalFailureDetail, contains('projection failed'));
        expect(
          failedModel.narratorPresentation?.instrumentationRows
              .map((row) => row.value)
              .toList(),
          const ['Done', "Couldn't finish", 'Waiting'],
        );
        expect(
          failedModel.narratorPresentation?.kind,
          HistoricalArchivesNarratorPresentationKind.removalFailed,
        );
        expect(failedModel.removeImportedArchiveDataEnabled, isFalse);
        expect(removalService.callCount, 1);
      },
    );

    test(
      'partial failure after fact deletion cannot falsely return to hub',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final source = HistoricalArchiveSourceMetadata(
          identity: _identity(sourceKey),
          sourceChatDb: '/tmp/archive/chat.db',
          folderPath: '/tmp/archive',
          sourceLabel: 'Archive',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Found',
          totalMessages: 42,
          earliestMessageUtc: '2012-07-25T08:00:00.000Z',
          latestMessageUtc: '2017-06-11T08:00:00.000Z',
          preflightStatusLabel: 'Imported successfully',
          dryRunNewMessages: 0,
          dryRunDuplicateMessages: 42,
          lastImportFinishedAtUtc: '2026-08-10T18:30:00.000Z',
          lastImportSuccess: true,
          lastImportError: null,
          lastImportedMessageCount: 42,
        );
        final lookup = _MutableImportedSourceLookup(
          match: HistoricalArchiveImportedSourceMatch(
            identity: _identity(sourceKey),
            sourceId: 3,
            importedMessageCount: 42,
          ),
        );
        final removalService = _RecordingArchiveRemovalService((
          observer,
        ) async {
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.started,
            ),
          );
          lookup.match = null;
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.completed,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage
                  .rebuildingConversationGraph,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.started,
            ),
          );
          throw StateError('projection failed after deletion');
        });
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            archiveMutationCoordinatorProvider.overrideWith(
              _ImmediateArchiveMutationCoordinator.new,
            ),
            sourceScopedArchiveGraphRemovalServiceProvider.overrideWith(
              (ref) async => removalService,
            ),
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => [source],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => lookup,
            ),
            currentMessagesSourcePathProvider.overrideWith(
              (ref) => currentMessagesDatabasePath,
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.showKnownSource(identity: _identity(sourceKey));
        await workflow.removeImportedArchiveDataForSelectedSource();

        final failed = container.read(historicalArchivesWorkflowProvider);
        final failedModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: failed,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          failed.presentation,
          isA<HistoricalArchivesRemovalFailedState>(),
        );
        expect(failed.selectedKnownSourceKey, sourceKey);
        expect(
          failed.removalFailureDetail,
          contains('Messages from this folder are no longer present'),
        );
        expect(
          failedModel.narratorPresentation?.instrumentationRows
              .map((row) => row.value)
              .toList(),
          const ['Done', "Couldn't finish", 'Waiting'],
        );
        expect(failedModel.isHub, isFalse);
        expect(failedModel.narratorPresentation, isNotNull);
      },
    );

    test(
      'remembered unimported source cannot establish selected context',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => [
                HistoricalArchiveSourceMetadata(
                  identity: _identity(sourceKey),
                  sourceChatDb: '/tmp/archive/chat.db',
                  folderPath: '/tmp/archive',
                  sourceLabel: 'Archive',
                  chatDbStatusLabel: 'Found and readable',
                  attachmentsStatusLabel: 'Found',
                  totalMessages: 42,
                  earliestMessageUtc: '2012-07-25T08:00:00.000Z',
                  latestMessageUtc: '2017-06-11T08:00:00.000Z',
                  preflightStatusLabel: 'Preflight complete',
                  dryRunNewMessages: 32,
                  dryRunDuplicateMessages: 10,
                  lastImportFinishedAtUtc: null,
                  lastImportSuccess: null,
                  lastImportError: null,
                  lastImportedMessageCount: null,
                ),
              ],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(historicalArchivesWorkflowProvider.notifier)
            .showKnownSource(identity: _identity(sourceKey));

        final state = container.read(historicalArchivesWorkflowProvider);
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: state,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(state.presentation, isA<HistoricalArchivesHubState>());
        expect(state.selectedKnownSourceKey, isNull);
        expect(model.isHub, isTrue);
        expect(model.narratorPresentation, isNull);
        expect(model.importButtonEnabled, isFalse);
      },
    );

    test(
      'leaving Historical Archives clears transient selection but not source facts',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final source = HistoricalArchiveSourceMetadata(
          identity: _identity(sourceKey),
          sourceChatDb: '/tmp/archive/chat.db',
          folderPath: '/tmp/archive',
          sourceLabel: 'Archive',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Found',
          totalMessages: 42,
          earliestMessageUtc: '2012-07-25T08:00:00.000Z',
          latestMessageUtc: '2017-06-11T08:00:00.000Z',
          preflightStatusLabel: 'Imported successfully',
          dryRunNewMessages: 0,
          dryRunDuplicateMessages: 42,
          lastImportFinishedAtUtc: null,
          lastImportSuccess: true,
          lastImportError: null,
          lastImportedMessageCount: 42,
        );
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => [source],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(
                match: HistoricalArchiveImportedSourceMatch(
                  identity: _identity(sourceKey),
                  sourceId: 3,
                  importedMessageCount: 42,
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        container
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.settings);
        container
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(
              SettingsMenuActionId.historicalArchives,
            );

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.showKnownSource(identity: _identity(sourceKey));
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .selectedKnownSourceKey,
          sourceKey,
        );

        container
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.messages);

        final reset = container.read(historicalArchivesWorkflowProvider);
        expect(reset.presentation, isA<HistoricalArchivesHubState>());
        expect(reset.selectedKnownSourceKey, isNull);
        expect(reset.knownSourceReference, isNull);
        expect(
          await container.read(historicalArchiveSourceMetadataProvider.future),
          [source],
        );

        container
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.settings);
        expect(
          container.read(historicalArchivesWorkflowProvider).presentation,
          isA<HistoricalArchivesHubState>(),
        );
      },
    );

    test(
      'late folder inspection cannot revive an abandoned add context',
      () async {
        final inspectionCompleter = Completer<ArchiveSourceInspection>();
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => const _FakeFolderChooser('/tmp/archive'),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async =>
                  _CompletingArchiveSourceInspector(inspectionCompleter.future),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => const _FakeHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);
        container
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.settings);
        container
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(
              SettingsMenuActionId.historicalArchives,
            );

        final operation = container
            .read(historicalArchivesWorkflowProvider.notifier)
            .chooseMessagesFolder();
        await Future<void>.delayed(Duration.zero);
        container
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.messages);

        inspectionCompleter.complete(
          ArchiveSourceInspection(
            folderPath: '/tmp/archive',
            sourceLabel: 'archive',
            chatDbPath: '/tmp/archive/chat.db',
            sourceIdentity: _identity(
              'historical-messages-archive:/tmp/archive/chat.db',
            ),
            chatDbStatus: ArchiveSourceInspectionStatus.readable,
            attachmentsStatusLabel: 'Not found',
            detail: 'Archive source is readable.',
            dryRunEstimate: const ArchiveSourceDryRunEstimate.available(
              comparableGuidCount: 42,
              duplicateGuidCount: 10,
              newGuidCount: 32,
            ),
            totalMessages: 42,
            totalChats: 4,
            totalHandles: 7,
            missingGuids: 0,
            earliestMessageUtc: '2012-07-25T08:00:00.000Z',
            latestMessageUtc: '2017-06-11T08:00:00.000Z',
          ),
        );
        await operation;

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(state.presentation, isA<HistoricalArchivesHubState>());
        expect(state.selectedKnownSourceKey, isNull);
        expect(state.knownSourceReference, isNull);
      },
    );

    test(
      'abandoned lineage verification cannot persist candidate metadata',
      () async {
        final lineageAuthority = _CompletingLineageAuthority();
        final archiveSources = _RecordingHistoricalArchiveSources();
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => lineageAuthority,
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => archiveSources,
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);
        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );

        final inspection = workflow.loadFolder(folderPath: '/tmp/archive');
        await _waitUntil(() => lineageAuthority.macVerificationCallCount == 1);
        workflow.clearSelection();
        lineageAuthority.complete(_testSameLineageAdmission());
        await inspection;

        expect(archiveSources.upsertCallCount, 0);
        expect(
          container.read(historicalArchivesWorkflowProvider).presentation,
          isA<HistoricalArchivesHubState>(),
        );
      },
    );

    test(
      'older same-session inspection cannot replace a newer candidate',
      () async {
        final inspector = _PerFolderArchiveSourceInspector();
        final container = ProviderContainer(
          overrides: [
            messagesLineageAdmissionAuthorityProvider.overrideWith(
              (ref) async => const _SameLineageAuthority(),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => inspector,
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => const _FakeHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);
        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );

        final older = workflow.loadFolder(folderPath: '/tmp/older');
        await _waitUntil(() => inspector.hasRequest('/tmp/older'));
        final newer = workflow.loadFolder(folderPath: '/tmp/newer');
        await _waitUntil(() => inspector.hasRequest('/tmp/newer'));

        inspector.complete('/tmp/newer');
        await newer;
        inspector.complete('/tmp/older');
        await older;

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(state.presentation, isA<HistoricalArchivesReadyToAddState>());
        expect(state.selectedFolderPath, '/tmp/newer');
      },
    );
  });

  group('preflightHistoricalArchivesFolder', () {
    late ConversationGraphDatabase graphDb;

    setUp(() {
      graphDb = ConversationGraphDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await graphDb.close();
    });

    test('reads source counts from a selected archive folder', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'historical-archives-preflight-',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final chatDbPath = '${tempDirectory.path}/chat.db';
      final database = sqlite3.open(chatDbPath);
      try {
        database.execute('CREATE TABLE message (guid TEXT);');
        database.execute('CREATE TABLE chat (id INTEGER PRIMARY KEY);');
        database.execute('CREATE TABLE handle (id INTEGER PRIMARY KEY);');
        database.execute(
          "INSERT INTO message (guid) VALUES ('m1'), ('m2'), (NULL);",
        );
        database.execute('INSERT INTO chat (id) VALUES (1), (2);');
        database.execute('INSERT INTO handle (id) VALUES (1), (2), (3);');
      } finally {
        database.dispose();
      }

      Directory('${tempDirectory.path}/Attachments').createSync();

      await graphDb.executeSql('''
INSERT INTO messages (ss_id, guid, is_from_me) VALUES
           (1, 'm1', 0), (2, 'm1', 0), (3, 'projected-only', 0)''');

      final result = await preflightHistoricalArchivesFolder(
        folderPath: tempDirectory.path,
        archiveSourceInspector: ArchiveSourceInspectionRepository(
          graphDb: graphDb,
        ),
      );

      expect(
        result.preflight.status,
        HistoricalArchivesPreflightStatus.completeReadyToImport,
      );
      expect(result.chatDbStatusLabel, 'Found and readable');
      expect(result.attachmentsStatusLabel, 'Found');
      expect(result.preflightSummaryLines, contains('Total messages: 3'));
      expect(result.preflightSummaryLines, contains('Total chats: 2'));
      expect(result.preflightSummaryLines, contains('Total handles: 3'));
      expect(
        result.preflightSummaryLines,
        contains('Rows with missing GUIDs: 1'),
      );
      expect(
        result.preflightSummaryLines,
        contains('Likely already imported: 1 comparable source rows'),
      );
      expect(
        result.preflightSummaryLines,
        contains('Likely new rows: 1 comparable source rows'),
      );
      expect(
        result.dryRunSummaryLines,
        contains(
          'Estimated new messages: 1 comparable source rows not already imported',
        ),
      );
      expect(
        result.dryRunSummaryLines,
        contains(
          'Estimated duplicates: 1 comparable source rows already imported',
        ),
      );
      expect(result.activityLog[1].label, 'Dry run ready');
    });

    test(
      'reports date range diagnostic when source date column is absent',
      () async {
        final tempDirectory = await Directory.systemTemp.createTemp(
          'historical-archives-preflight-no-date-',
        );
        addTearDown(() async {
          if (tempDirectory.existsSync()) {
            await tempDirectory.delete(recursive: true);
          }
        });

        final chatDbPath = '${tempDirectory.path}/chat.db';
        final database = sqlite3.open(chatDbPath);
        try {
          database.execute('CREATE TABLE message (guid TEXT);');
          database.execute('CREATE TABLE chat (id INTEGER PRIMARY KEY);');
          database.execute('CREATE TABLE handle (id INTEGER PRIMARY KEY);');
          database.execute("INSERT INTO message (guid) VALUES ('m1');");
        } finally {
          database.dispose();
        }

        final result = await preflightHistoricalArchivesFolder(
          folderPath: tempDirectory.path,
          archiveSourceInspector: ArchiveSourceInspectionRepository(
            graphDb: graphDb,
          ),
        );

        expect(
          result.preflight.status,
          HistoricalArchivesPreflightStatus.completeReadyToImport,
        );
        expect(
          result.preflightSummaryLines,
          contains('Earliest message: unavailable'),
        );
        expect(
          result.preflightSummaryLines,
          contains('Latest message: unavailable'),
        );
        expect(
          result.preflightSummaryLines.any(
            (line) => line.startsWith('Date range diagnostic:'),
          ),
          isTrue,
        );
      },
    );

    test('fails preflight when the selected folder has no chat db', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'historical-archives-preflight-missing-',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final result = await preflightHistoricalArchivesFolder(
        folderPath: tempDirectory.path,
        archiveSourceInspector: ArchiveSourceInspectionRepository(
          graphDb: graphDb,
        ),
      );

      expect(result.preflight.status, HistoricalArchivesPreflightStatus.failed);
      expect(result.chatDbStatusLabel, 'Missing');
      expect(result.preflight.detail, contains('does not contain chat.db'));
      expect(result.activityLog.single.label, 'Preflight failed');
    });
  });
}

SameMessagesLineageAdmission _testSameLineageAdmission() {
  return MessagesLineageAdmission.fromEvidence(
        const MessagesLineageEvidence(
          candidateRecordCount: 80,
          usableCandidateIdentityCount: 80,
          blankCandidateGuidCount: 0,
          inconsistentCandidateIdentityCount: 0,
          duplicateCandidateRowIdCount: 0,
          currentRowsInCandidateRangeCount: 80,
          comparableCount: 80,
          matchingCount: 80,
          contradictionCount: 0,
          missingCurrentRowCount: 0,
          unusableCurrentGuidCount: 0,
          matchingRowIdBandCount: 4,
          candidateSourceShapeIsCoherent: true,
          currentSourceShapeIsCoherent: true,
        ),
      )
      as SameMessagesLineageAdmission;
}

MessagesLineageAdmission _testContradictoryLineageAdmission() {
  return MessagesLineageAdmission.fromEvidence(
    const MessagesLineageEvidence(
      candidateRecordCount: 80,
      usableCandidateIdentityCount: 80,
      blankCandidateGuidCount: 0,
      inconsistentCandidateIdentityCount: 0,
      duplicateCandidateRowIdCount: 0,
      currentRowsInCandidateRangeCount: 80,
      comparableCount: 80,
      matchingCount: 79,
      contradictionCount: 1,
      missingCurrentRowCount: 0,
      unusableCurrentGuidCount: 0,
      matchingRowIdBandCount: 4,
      candidateSourceShapeIsCoherent: true,
      currentSourceShapeIsCoherent: true,
    ),
  );
}

MessagesLineageAdmission _testInsufficientLineageAdmission() {
  return MessagesLineageAdmission.fromEvidence(
    const MessagesLineageEvidence(
      candidateRecordCount: 20,
      usableCandidateIdentityCount: 20,
      blankCandidateGuidCount: 0,
      inconsistentCandidateIdentityCount: 0,
      duplicateCandidateRowIdCount: 0,
      currentRowsInCandidateRangeCount: 20,
      comparableCount: 20,
      matchingCount: 20,
      contradictionCount: 0,
      missingCurrentRowCount: 0,
      unusableCurrentGuidCount: 0,
      matchingRowIdBandCount: 4,
      candidateSourceShapeIsCoherent: true,
      currentSourceShapeIsCoherent: true,
    ),
  );
}

final class _SameLineageAuthority implements MessagesLineageAdmissionAuthority {
  const _SameLineageAuthority();

  @override
  Future<MessagesLineageAdmission> verifyMacMessagesCandidate({
    required String candidateChatDatabasePath,
  }) async => _testSameLineageAdmission();

  @override
  Future<MessagesLineageAdmission> verifyMessageLensCandidate({
    required String candidateImportLedgerPath,
  }) async => _testSameLineageAdmission();
}

final class _CompletingLineageAuthority
    implements MessagesLineageAdmissionAuthority {
  final _macVerification = Completer<MessagesLineageAdmission>();
  var macVerificationCallCount = 0;

  void complete(MessagesLineageAdmission admission) {
    _macVerification.complete(admission);
  }

  @override
  Future<MessagesLineageAdmission> verifyMacMessagesCandidate({
    required String candidateChatDatabasePath,
  }) {
    macVerificationCallCount += 1;
    return _macVerification.future;
  }

  @override
  Future<MessagesLineageAdmission> verifyMessageLensCandidate({
    required String candidateImportLedgerPath,
  }) async => _testSameLineageAdmission();
}

final class _FixedLineageAuthority
    implements MessagesLineageAdmissionAuthority {
  const _FixedLineageAuthority(this.admission);

  final MessagesLineageAdmission admission;

  @override
  Future<MessagesLineageAdmission> verifyMacMessagesCandidate({
    required String candidateChatDatabasePath,
  }) async => admission;

  @override
  Future<MessagesLineageAdmission> verifyMessageLensCandidate({
    required String candidateImportLedgerPath,
  }) async => admission;
}

HistoricalArchivesPresentationData _testPresentationData({
  String folderPath = '/tmp/archive',
  String? chatDbPath,
  String sourceLabel = 'archive',
  ArchiveSourceInspectionStatus chatDbStatus =
      ArchiveSourceInspectionStatus.readable,
  String attachmentsStatusLabel = 'Not found',
  HistoricalArchivesPreflightStatus preflightStatus =
      HistoricalArchivesPreflightStatus.completeReadyToImport,
  String preflightStatusLabel = 'Preflight complete',
  String preflightDetail = 'Source checks succeeded.',
  List<String> preflightSummaryLines = const [],
  List<String> dryRunSummaryLines = const [],
  List<String> importSafetySummaryLines = const [],
  List<String> resultSummaryLines = const [],
  List<HistoricalArchivesLogEntryViewModel> activityLog = const [],
  List<HistoricalArchivesWorkflowPhaseViewModel> phases = const [],
}) {
  return HistoricalArchivesPresentationData(
    preflight: HistoricalArchivesPreflightViewModel(
      status: preflightStatus,
      statusLabel: preflightStatusLabel,
      detail: preflightDetail,
    ),
    selectedFolderPath: folderPath,
    archiveRemovalTargetChatDbPath: chatDbPath ?? '$folderPath/chat.db',
    chatDbStatus: chatDbStatus,
    attachmentsStatusLabel: attachmentsStatusLabel,
    sourceLabel: sourceLabel,
    preflightSummaryLines: preflightSummaryLines,
    dryRunSummaryLines: dryRunSummaryLines,
    importSafetySummaryLines: importSafetySummaryLines,
    resultSummaryLines: resultSummaryLines,
    activityLog: activityLog,
    phases: phases,
  );
}

HistoricalArchivesInspectionEvidence _testInspectionEvidence({
  String folderPath = '/tmp/archive',
  String? chatDbPath,
  String sourceLabel = 'archive',
  ArchiveSourceInspectionStatus chatDbStatus =
      ArchiveSourceInspectionStatus.readable,
  String attachmentsStatusLabel = 'Not found',
}) {
  return HistoricalArchivesInspectionEvidence(
    sourceIdentity: chatDbStatus == ArchiveSourceInspectionStatus.readable
        ? HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
            chatDbPath ?? '$folderPath/chat.db',
          )
        : null,
    folderPath: folderPath,
    chatDbPath: chatDbPath ?? '$folderPath/chat.db',
    sourceLabel: sourceLabel,
    chatDbStatus: chatDbStatus,
    attachmentsStatusLabel: attachmentsStatusLabel,
    totalMessages: null,
    totalChats: null,
    totalHandles: null,
    missingGuids: null,
    earliestMessageUtc: null,
    latestMessageUtc: null,
    dateRangeUnavailableReason: 'Not supplied by this fixture.',
    dryRunNewMessages: null,
    dryRunDuplicateMessages: null,
    dryRunComparableMessages: null,
    dryRunUnavailableReason: 'Not supplied by this fixture.',
  );
}

HistoricalArchivesImportedSourceFacts _testImportedSourceFacts() {
  return HistoricalArchivesImportedSourceFacts(
    identity: _identity('historical-messages-archive:/tmp/archive/chat.db'),
    importedMessageCount: 42,
    earliestMessageUtc: '2012-07-25T08:00:00.000Z',
    latestMessageUtc: '2017-06-11T08:00:00.000Z',
    successfulImportFinishedAtUtc: '2026-08-19T12:00:00.000Z',
  );
}

MessageLensHistoricalArchiveReady _messageLensReady({
  required int recoverableCount,
  required int recoverableBytes,
  MessageLensAttachmentRecoveryDonorFormat format =
      MessageLensAttachmentRecoveryDonorFormat.currentMarkerV1,
  String? archiveInstanceId = '123e4567-e89b-42d3-a456-426614174000',
}) {
  final candidates = <MessageLensAttachmentRecoveryCandidate>[
    for (var index = 0; index < recoverableCount; index++)
      MessageLensAttachmentRecoveryCandidate(
        archiveCompatibilityKey: ArchiveCompatibilityKey(
          messageGuid: 'message-lens-recovery-message-$index',
          importAttachmentId: index + 1,
        ),
        classification: MessageLensAttachmentRecoveryClassification.recoverable,
        recoverableBytes:
            recoverableBytes ~/ recoverableCount +
            (index < recoverableBytes % recoverableCount ? 1 : 0),
        donorArchiveRelativePath: 'donor/$index.bin',
        donorPayloadSha256: null,
      ),
  ];
  return MessageLensHistoricalArchiveReady(
    donor: MessageLensAttachmentRecoveryDonor(
      rootPath: '/tmp/donor',
      format: format,
      archiveInstanceId: archiveInstanceId,
    ),
    lineageAdmission: _testSameLineageAdmission(),
    attachmentPreflight: MessageLensAttachmentRecoveryPreflight(
      candidates: candidates,
      funnel: MessageLensAttachmentRecoveryFunnel(
        donorPayloadClaimCount: recoverableCount,
        donorRelationshipEvidenceCount: recoverableCount,
        currentRelationshipEvidenceCount: recoverableCount,
        donorRelationshipUnmatchedCount: 0,
        messageMatchedCount: recoverableCount,
        attachmentMatchedCount: recoverableCount,
        donorPayloadPresentCount: recoverableCount,
        currentPayloadPresentCount: 0,
        duplicateClaimsCollapsedCount: 0,
      ),
      examinedCount: recoverableCount,
      recoverableCount: recoverableCount,
      recoverableBytes: recoverableBytes,
      alreadyPresentCount: 0,
      donorMissingCount: 0,
      messageMismatchCount: 0,
      attachmentMismatchCount: 0,
      conflictCount: 0,
      ambiguousCount: 0,
      unsafeDonorPathCount: 0,
    ),
  );
}

final class _ControlledMessageLensAttachmentRecoveryBatchRunner
    implements MessageLensAttachmentRecoveryBatchRunner {
  final Completer<void> release = Completer<void>();
  var callCount = 0;

  @override
  Future<MessageLensAttachmentRecoveryBatchResult> execute({
    required ArchiveMutationCapability mutationCapability,
    required MessageLensAttachmentRecoveryDonor donor,
    required SameMessagesLineageAdmission lineageAdmission,
    required MessageLensAttachmentRecoveryPreflight preflight,
    required List<MessageLensAttachmentRecoveryCandidate>
    preflightApprovedCandidates,
    MessageLensAttachmentRecoveryBatchProgressObserver? onProgress,
  }) async {
    mutationCapability.requireOperation(
      ArchiveMutationOperation.attachmentReconciliation,
    );
    callCount += 1;
    onProgress?.call(
      MessageLensAttachmentRecoveryBatchProgress(
        stage: MessageLensAttachmentRecoveryBatchStage.installingPayloads,
        totalAttachments: preflightApprovedCandidates.length,
        verifiedAttachments: preflightApprovedCandidates.length,
        processedAttachments: 1,
        recoveredAttachments: 1,
        totalBytes: preflight.recoverableBytes,
        verifiedBytes: preflight.recoverableBytes,
        copiedBytes: preflightApprovedCandidates.first.recoverableBytes,
        terminallyVerifiedAttachments: 0,
      ),
    );
    await release.future;
    onProgress?.call(
      MessageLensAttachmentRecoveryBatchProgress(
        stage: MessageLensAttachmentRecoveryBatchStage.complete,
        totalAttachments: preflightApprovedCandidates.length,
        verifiedAttachments: preflightApprovedCandidates.length,
        processedAttachments: preflightApprovedCandidates.length,
        recoveredAttachments: preflightApprovedCandidates.length,
        totalBytes: preflight.recoverableBytes,
        verifiedBytes: preflight.recoverableBytes,
        copiedBytes: preflight.recoverableBytes,
        terminallyVerifiedAttachments: preflightApprovedCandidates.length,
      ),
    );
    return MessageLensAttachmentRecoveryBatchResult(
      outcomes: [
        for (final candidate in preflightApprovedCandidates)
          MessageLensAttachmentRecoveryItemOutcome(
            candidate: candidate,
            status: MessageLensAttachmentRecoveryItemStatus.installed,
            installedBytes: candidate.recoverableBytes,
            archiveRelativePath:
                'installed/${candidate.archiveCompatibilityKey.storageKeySegment}',
          ),
      ],
      recoveredCount: preflightApprovedCandidates.length,
      recoveredBytes: preflight.recoverableBytes,
      alreadyPresentCount: 0,
      couldNotRecoverCount: 0,
      terminallyVerifiedCount: preflightApprovedCandidates.length,
      remainingRecoverableCount: 0,
    );
  }
}

final class _FakeMessageLensHistoricalArchivePreflight
    implements MessageLensHistoricalArchivePreflight {
  _FakeMessageLensHistoricalArchivePreflight(
    this.result, {
    this.progress,
    this.releaseAfterProgress,
  });

  final MessageLensHistoricalArchivePreflightResult result;
  final MessageLensHistoricalArchivePreflightProgress? progress;
  final Completer<void>? releaseAfterProgress;
  final List<String> inspectedFolders = [];

  @override
  Future<MessageLensHistoricalArchivePreflightResult> inspect({
    required String folderPath,
    MessageLensHistoricalArchivePreflightProgressObserver? onProgress,
    bool Function()? isCancelled,
  }) async {
    inspectedFolders.add(folderPath);
    if (progress case final progress?) {
      onProgress?.call(progress);
      await releaseAfterProgress?.future;
    }
    return result;
  }
}

final class _MutationOwnedHistoricalArchivesWorkflow
    extends HistoricalArchivesWorkflow {
  @override
  HistoricalArchivesWorkflowState build() {
    return HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesImportingState(
        lineageAdmission: _testSameLineageAdmission(),
        data: _testPresentationData(),
        evidence: _testInspectionEvidence(),
        progress: const HistoricalArchiveImportProgress(),
      ),
    );
  }
}

final class _ControllableHistoricalArchivesWorkflow
    extends HistoricalArchivesWorkflow {
  @override
  HistoricalArchivesWorkflowState build() =>
      buildInitialHistoricalArchivesWorkflowState();

  void emitImportSuccessNotice() {
    state = const HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesImportSuccessNoticeState(
        notice: HistoricalArchivesImportSuccessNotice(
          noticeOccurrence: 1,
          presentationSessionOccurrence: 0,
        ),
      ),
    );
  }

  void emitNewCandidate() {
    state = HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesReadyToAddState(
        lineageAdmission: _testSameLineageAdmission(),
        data: _testPresentationData(folderPath: '/tmp/new-archive'),
        evidence: _testInspectionEvidence(folderPath: '/tmp/new-archive'),
      ),
    );
  }
}

final class _FakeFolderChooser implements HistoricalArchiveFolderChooser {
  const _FakeFolderChooser(this.folderPath);

  final String folderPath;

  @override
  Future<String?> chooseMessagesFolder() async => folderPath;

  @override
  Future<String?> chooseMessageLensFolder() async => folderPath;
}

final class _RecordingFolderChooser implements HistoricalArchiveFolderChooser {
  _RecordingFolderChooser(this.folderPath);

  final String folderPath;
  var callCount = 0;

  @override
  Future<String?> chooseMessagesFolder() async {
    callCount += 1;
    return folderPath;
  }

  @override
  Future<String?> chooseMessageLensFolder() async {
    callCount += 1;
    return folderPath;
  }
}

final class _CompletingArchiveSourceInspector
    implements ArchiveSourceInspector {
  const _CompletingArchiveSourceInspector(this.inspection);

  final Future<ArchiveSourceInspection> inspection;

  @override
  Future<ArchiveSourceInspection> inspectFolder({required String folderPath}) {
    return inspection;
  }
}

final class _PerFolderArchiveSourceInspector implements ArchiveSourceInspector {
  final _requests = <String, Completer<ArchiveSourceInspection>>{};

  bool hasRequest(String folderPath) => _requests.containsKey(folderPath);

  void complete(String folderPath) {
    _requests[folderPath]!.complete(
      ArchiveSourceInspection(
        folderPath: folderPath,
        sourceLabel: folderPath.split('/').last,
        chatDbPath: '$folderPath/chat.db',
        sourceIdentity:
            HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
              '$folderPath/chat.db',
            ),
        chatDbStatus: ArchiveSourceInspectionStatus.readable,
        attachmentsStatusLabel: 'Not found',
        detail: 'Archive source is readable.',
        dryRunEstimate: const ArchiveSourceDryRunEstimate.available(
          comparableGuidCount: 42,
          duplicateGuidCount: 10,
          newGuidCount: 32,
        ),
        totalMessages: 42,
        totalChats: 4,
        totalHandles: 7,
        missingGuids: 0,
        earliestMessageUtc: '2012-07-25T08:00:00.000Z',
        latestMessageUtc: '2017-06-11T08:00:00.000Z',
      ),
    );
  }

  @override
  Future<ArchiveSourceInspection> inspectFolder({required String folderPath}) {
    final completer = Completer<ArchiveSourceInspection>();
    _requests[folderPath] = completer;
    return completer.future;
  }
}

final class _ImmediateArchiveSourceInspector implements ArchiveSourceInspector {
  const _ImmediateArchiveSourceInspector();

  @override
  Future<ArchiveSourceInspection> inspectFolder({required String folderPath}) {
    return Future.value(
      ArchiveSourceInspection(
        folderPath: folderPath,
        sourceLabel: 'archive',
        chatDbPath: '$folderPath/chat.db',
        sourceIdentity:
            HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
              '$folderPath/chat.db',
            ),
        chatDbStatus: ArchiveSourceInspectionStatus.readable,
        attachmentsStatusLabel: 'Not found',
        detail: 'Archive source is readable.',
        dryRunEstimate: const ArchiveSourceDryRunEstimate.available(
          comparableGuidCount: 42,
          duplicateGuidCount: 42,
          newGuidCount: 0,
        ),
        totalMessages: 42,
        totalChats: 4,
        totalHandles: 7,
        missingGuids: 0,
        earliestMessageUtc: '2012-07-25T08:00:00.000Z',
        latestMessageUtc: '2017-06-11T08:00:00.000Z',
      ),
    );
  }
}

final class _MissingArchiveSourceInspector implements ArchiveSourceInspector {
  const _MissingArchiveSourceInspector();

  @override
  Future<ArchiveSourceInspection> inspectFolder({required String folderPath}) {
    return Future.value(
      ArchiveSourceInspection(
        folderPath: folderPath,
        sourceLabel: 'not-an-archive',
        chatDbPath: '$folderPath/chat.db',
        chatDbStatus: ArchiveSourceInspectionStatus.missing,
        attachmentsStatusLabel: 'Not found',
        detail: 'The selected folder does not contain chat.db.',
        dryRunEstimate: const ArchiveSourceDryRunEstimate.unavailable(
          unavailableReason: 'source chat.db is missing.',
        ),
      ),
    );
  }
}

final class _ReadFailedArchiveSourceInspector
    implements ArchiveSourceInspector {
  const _ReadFailedArchiveSourceInspector();

  @override
  Future<ArchiveSourceInspection> inspectFolder({required String folderPath}) {
    return Future.value(
      ArchiveSourceInspection(
        folderPath: folderPath,
        sourceLabel: 'unreadable-archive',
        chatDbPath: '$folderPath/chat.db',
        chatDbStatus: ArchiveSourceInspectionStatus.readFailed,
        attachmentsStatusLabel: 'Not found',
        detail: 'MessageLens could not safely read chat.db.',
        dryRunEstimate: const ArchiveSourceDryRunEstimate.unavailable(
          unavailableReason: 'source chat.db could not be read safely.',
        ),
      ),
    );
  }
}

final class _FakeImportedSourceLookup
    implements HistoricalArchiveImportedSourceLookup {
  _FakeImportedSourceLookup({this.matchingFolderPath, this.match});

  final String? matchingFolderPath;
  final HistoricalArchiveImportedSourceMatch? match;

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSource({
    required HistoricalArchiveSourceIdentity identity,
  }) async {
    if (matchingFolderPath != null &&
        identity.canonicalSourcePath != '$matchingFolderPath/chat.db') {
      return null;
    }
    return match?.identity == identity ? match : null;
  }
}

final class _MutableImportedSourceLookup
    implements HistoricalArchiveImportedSourceLookup {
  _MutableImportedSourceLookup({required this.match});

  HistoricalArchiveImportedSourceMatch? match;

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSource({
    required HistoricalArchiveSourceIdentity identity,
  }) async {
    return match?.identity == identity ? match : null;
  }
}

final class _FinalVerificationImportedSourceLookup
    implements HistoricalArchiveImportedSourceLookup {
  _FinalVerificationImportedSourceLookup({
    required this.match,
    required this.verificationCompleter,
  });

  final HistoricalArchiveImportedSourceMatch match;
  final Completer<HistoricalArchiveImportedSourceMatch?> verificationCompleter;
  var _identityLookupCount = 0;

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSource({
    required HistoricalArchiveSourceIdentity identity,
  }) {
    _identityLookupCount += 1;
    if (_identityLookupCount == 1) {
      return Future.value(match.identity == identity ? match : null);
    }
    return verificationCompleter.future;
  }
}

final class _ControlledArchiveGraphImportService
    implements SourceScopedArchiveGraphImportService {
  _ControlledArchiveGraphImportService(this._importAndProject);

  final Future<SourceScopedArchiveGraphImportResult> Function(
    SourceScopedArchiveGraphImportObserver? observer,
  )
  _importAndProject;
  var callCount = 0;

  @override
  Future<SourceScopedArchiveGraphImportResult> importAndProject({
    required String folderPath,
    String? sourceLabel,
    SourceScopedArchiveGraphImportObserver? onObservation,
  }) async {
    callCount += 1;
    return _importAndProject(onObservation);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _RecordingArchiveRemovalService
    implements SourceScopedArchiveGraphRemovalService {
  _RecordingArchiveRemovalService(this._remove);

  final Future<SourceScopedArchiveGraphRemovalResult> Function(
    SourceScopedArchiveGraphRemovalObserver? observer,
  )
  _remove;
  var callCount = 0;

  @override
  Future<SourceScopedArchiveGraphRemovalResult> removeArchiveSource({
    required HistoricalArchiveSourceIdentity sourceIdentity,
    SourceScopedArchiveGraphRemovalObserver? onObservation,
  }) async {
    callCount += 1;
    return _remove(onObservation);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _ImmediateArchiveMutationCoordinator
    extends ArchiveMutationCoordinator {
  var runCallCount = 0;

  @override
  ArchiveMutationCoordinatorState build() {
    return const ArchiveMutationCoordinatorState();
  }

  @override
  Future<T> run<T>({
    required ArchiveMutationOperation operation,
    required String ownerLabel,
    required Future<T> Function() action,
  }) async {
    runCallCount += 1;
    return action();
  }
}

final class _FakeHistoricalArchiveSources implements HistoricalArchiveSources {
  const _FakeHistoricalArchiveSources([
    this.sources = const <HistoricalArchiveSourceMetadata>[],
  ]);

  final List<HistoricalArchiveSourceMetadata> sources;

  @override
  Future<List<HistoricalArchiveSourceMetadata>> readKnownSources() async =>
      sources;

  @override
  Future<void> upsertSourceMetadata(
    HistoricalArchiveSourceMetadataUpdate update,
  ) async {}
}

final class _RecordingHistoricalArchiveSources
    implements HistoricalArchiveSources {
  _RecordingHistoricalArchiveSources([
    this.sources = const <HistoricalArchiveSourceMetadata>[],
  ]);

  final List<HistoricalArchiveSourceMetadata> sources;
  var upsertCallCount = 0;
  var successfulImportUpdateCount = 0;

  @override
  Future<List<HistoricalArchiveSourceMetadata>> readKnownSources() async =>
      sources;

  @override
  Future<void> upsertSourceMetadata(
    HistoricalArchiveSourceMetadataUpdate update,
  ) async {
    upsertCallCount += 1;
    if (update.lastImportSuccess == true) {
      successfulImportUpdateCount += 1;
    }
  }
}

Future<void> _waitUntil(bool Function() predicate) async {
  final stopwatch = Stopwatch()..start();
  while (!predicate()) {
    if (stopwatch.elapsed > const Duration(seconds: 2)) {
      fail('Timed out waiting for asynchronous workflow state.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void _emitCompleteGraphProjection(
  SourceScopedArchiveGraphImportObserver? observer,
) {
  observer?.call(
    const SourceScopedArchiveGraphImportObservation(
      stage: SourceScopedArchiveGraphImportStage.projectingConversationGraph,
      transition: SourceScopedArchiveGraphImportStageTransition.started,
    ),
  );
  for (
    var index = 0;
    index < SourceScopedArchiveGraphProjectionUnit.values.length;
    index += 1
  ) {
    observer?.call(
      SourceScopedArchiveGraphImportObservation(
        stage: SourceScopedArchiveGraphImportStage.projectingConversationGraph,
        transition: SourceScopedArchiveGraphImportStageTransition.progressed,
        projectionProgress: SourceScopedArchiveGraphProjectionProgress(
          activeUnit: SourceScopedArchiveGraphProjectionUnit.values[index],
          completedUnitCount: index,
          totalUnitCount: SourceScopedArchiveGraphProjectionUnit.values.length,
        ),
      ),
    );
  }
  observer?.call(
    const SourceScopedArchiveGraphImportObservation(
      stage: SourceScopedArchiveGraphImportStage.projectingConversationGraph,
      transition: SourceScopedArchiveGraphImportStageTransition.completed,
    ),
  );
}

SourceScopedArchiveGraphImportResult _successfulArchiveGraphImportResult({
  required String sourceKey,
}) {
  return SourceScopedArchiveGraphImportResult(
    importResult: SourceScopedArchiveImportResult(
      registration: HistoricalMessagesArchiveSourceRegistration(
        sourceId: 3,
        identity: _identity(sourceKey),
        sourceLabel: 'archive',
        selectedFolderPath: '/tmp/archive',
        chatDbPath: '/tmp/archive/chat.db',
      ),
      messages: const MessageImportResult(
        startedAfterSourceRowId: 0,
        insertedMessageCount: 42,
        lastImportedSourceRowId: 42,
      ),
      chats: const ChatImportResult(examinedChatCount: 4, insertedChatCount: 4),
      handles: const HandleImportResult(
        startedAfterSourceRowId: 0,
        insertedHandleCount: 7,
        lastImportedSourceRowId: 7,
      ),
      attachments: const AttachmentImportResult(
        startedAfterSourceRowId: 0,
        examinedAttachmentCount: 0,
        insertedAttachmentCount: 0,
        lastImportedSourceRowId: null,
      ),
      chatMessageEdges: const ChatMessageJoinImportResult(
        examinedJoinCount: 42,
        insertedJoinCount: 42,
      ),
      chatHandleEdges: const ChatHandleJoinImportResult(
        examinedJoinCount: 7,
        insertedJoinCount: 7,
      ),
      messageAttachmentEdges: const MessageAttachmentJoinImportResult(
        examinedJoinCount: 0,
        insertedJoinCount: 0,
      ),
      textEnrichment: const MessageRichTextEnrichmentResult(
        candidateMessageCount: 0,
        enrichedMessageCount: 0,
        missingExtractionCount: 0,
        extractorAvailable: true,
      ),
    ),
    projectionResult: const SourceScopedArchiveGraphProjectionResult(
      handles: HandleProjectionResult(
        examinedHandleCount: 7,
        insertedHandleCount: 7,
      ),
      chatHandleEdges: ChatToHandleProjectionResult(
        examinedEdgeCount: 7,
        insertedEdgeCount: 7,
      ),
      chats: ChatProjectionResult(examinedChatCount: 4, insertedChatCount: 4),
      messages: MessageProjectionResult(
        examinedMessageCount: 42,
        insertedMessageCount: 42,
      ),
      attachments: AttachmentProjectionResult(
        examinedAttachmentCount: 0,
        insertedAttachmentCount: 0,
      ),
      chatMessageEdges: ChatToMessageProjectionResult(
        examinedEdgeCount: 42,
        insertedEdgeCount: 42,
      ),
      messageAttachmentEdges: MessageToAttachmentProjectionResult(
        examinedEdgeCount: 0,
        insertedEdgeCount: 0,
      ),
    ),
  );
}

HistoricalArchiveSourceMetadata _successfullyImportedArchiveSource({
  required String sourceKey,
}) {
  return HistoricalArchiveSourceMetadata(
    identity: _identity(sourceKey),
    sourceChatDb: '/tmp/archive/chat.db',
    folderPath: '/tmp/archive',
    sourceLabel: 'archive',
    chatDbStatusLabel: 'Found and readable',
    attachmentsStatusLabel: 'Not found',
    preflightStatusLabel: 'Imported successfully',
    totalMessages: 42,
    earliestMessageUtc: '2012-07-25T08:00:00.000Z',
    latestMessageUtc: '2017-06-11T08:00:00.000Z',
    dryRunNewMessages: 42,
    dryRunDuplicateMessages: 0,
    lastImportFinishedAtUtc: '2026-08-19T12:00:00.000Z',
    lastImportSuccess: true,
    lastImportError: null,
    lastImportedMessageCount: 42,
  );
}

HistoricalArchiveSourceIdentity _identity(String sourceKey) {
  return HistoricalArchiveSourceIdentity.fromPersistedValue(sourceKey);
}
