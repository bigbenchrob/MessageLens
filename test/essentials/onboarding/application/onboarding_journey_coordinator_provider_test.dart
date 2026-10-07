import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/domain_driven_development/value_objects.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_controller_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_observation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_report.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_state.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/chat_db_change_monitor_provider.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/db/application/conversation_graph_readiness.dart';
import 'package:remember_this_text/essentials/exclusive_authority/feature_level_providers.dart';
import 'package:remember_this_text/essentials/logging/application/app_logger.dart';
import 'package:remember_this_text/essentials/logging/domain/log_entry.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_database_probe_reader.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_database_probe_reader_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_durable_completion_verifier_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_failure_storage_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_failure_store.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_controller.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_store.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_journey_operation_projection.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_journey_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/features/address_book_folders/application/address_book_folder_providers.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_entity.dart';
import 'package:remember_this_text/features/address_book_folders/domain/failures/folder_retrieval_failure.dart';
import 'package:remember_this_text/features/address_book_folders/domain/value_objects/value_objects.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store.dart';
import 'package:remember_this_text/features/attachments/feature_level_providers.dart'
    show
        AttachmentArchiveLocation,
        AttachmentArchiveLocationState,
        attachmentArchiveLocationProvider,
        attachmentArchiveSettingsStoreProvider;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('deterministic prerequisite replay', () {
    test('FDA absent, leave app, FDA restored', () async {
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.permissionBlocked,
          blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
          hasFullDiskAccess: false,
        ),
      );
      addTearDown(fixture.dispose);

      expect(fixture.journey, isA<OnboardingNeedsMessagesAccess>());
      fixture.reports.current = _report(
        state: OnboardingEnvironmentState.readyToImport,
        blockerKind: OnboardingBlockerKind.none,
      );
      await fixture.refreshReport();

      expect(fixture.journey, isA<OnboardingReadyToImport>());
    });

    test('local history confirmation advances only its occurrence', () async {
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.sourceSparseOrUnsynced,
          blockerKind: OnboardingBlockerKind.sourceDataSparseOrUnsynced,
        ),
      );
      addTearDown(fixture.dispose);
      final before = fixture.journey;

      fixture.coordinator.acceptLocalMessageHistory(
        actionContext: before.actionContext,
      );

      expect(fixture.journey, isA<OnboardingReadyToImport>());
      expect(fixture.journey.occurrence, isNot(before.occurrence));
    });

    test('Contacts blocker remains a typed prerequisite Episode', () async {
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.sourceUnavailable,
          blockerKind: OnboardingBlockerKind.addressBookUnavailable,
        ),
      );
      addTearDown(fixture.dispose);

      expect(fixture.journey, isA<OnboardingNeedsContactsAccess>());
    });

    test('delayed action from a prior occurrence is rejected', () async {
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.readyToImport,
          blockerKind: OnboardingBlockerKind.none,
        ),
      );
      addTearDown(fixture.dispose);
      final staleContext = fixture.journey.actionContext;
      fixture.reports.current = _report(
        state: OnboardingEnvironmentState.permissionBlocked,
        blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
        hasFullDiskAccess: false,
      );
      await fixture.refreshReport();

      await fixture.coordinator.startVirginImportAndGraphBuild(
        actionContext: staleContext,
      );

      expect(fixture.journey, isA<OnboardingNeedsMessagesAccess>());
      expect(fixture.controller.current.status, OnboardingOperationStatus.idle);
    });
  });

  group('post-await prerequisite currentness', () {
    test('Retry cannot begin after prerequisites regress while held', () async {
      final graph = _ReplayGraphController(failuresBeforeSuccess: 1);
      final fixture = await _JourneyFixture.create(graph: graph);
      addTearDown(fixture.dispose);
      await fixture.coordinator.startVirginImportAndGraphBuild(
        actionContext: fixture.journey.actionContext,
      );
      final failed = fixture.journey as OnboardingOperationFailed;
      final failedOperationId = failed.operation!.operationId;
      fixture.holdNextControllerAcquisition();

      final retry = fixture.coordinator.retryFailedOperation(
        actionContext: failed.actionContext,
      );
      await fixture.controllerAccess.requested;
      fixture.reports.current = _report(
        state: OnboardingEnvironmentState.permissionBlocked,
        blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
        hasFullDiskAccess: false,
      );
      await fixture.refreshReport();
      expect(fixture.journey, same(failed));

      fixture.controllerAccess.release();
      await retry;

      expect(fixture.journey, isA<OnboardingNeedsMessagesAccess>());
      expect(fixture.controller.current.operationId, failedOperationId);
      expect(
        fixture.controller.current.status,
        OnboardingOperationStatus.failed,
      );
      expect(graph.runCount, 1);

      fixture.reports.current = _report(
        state: OnboardingEnvironmentState.readyToImport,
        blockerKind: OnboardingBlockerKind.none,
      );
      await fixture.refreshReport();
      final resurfaced = fixture.journey as OnboardingOperationFailed;
      expect(resurfaced.operation?.operationId, failedOperationId);
    });

    test(
      'Continue Setup cannot resume after prerequisites regress while held',
      () async {
        final persisted = _interruptedSnapshot();
        final fixture = await _JourneyFixture.create(
          persisted: persisted,
          useRealGlobalEnvironmentFeedback: true,
        );
        addTearDown(fixture.dispose);
        final interrupted = fixture.journey as OnboardingOperationInterrupted;
        fixture.holdNextControllerAcquisition();

        final continuation = fixture.coordinator.continueInterruptedOperation(
          actionContext: interrupted.actionContext,
        );
        await fixture.controllerAccess.requested;
        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.sourceUnavailable,
          blockerKind: OnboardingBlockerKind.addressBookUnavailable,
        );
        await fixture.refreshReport();
        expect(fixture.journey, same(interrupted));

        fixture.controllerAccess.release();
        await continuation;

        expect(fixture.journey, isA<OnboardingNeedsContactsAccess>());
        expect(fixture.controller.current.operationId, persisted.operationId);
        expect(
          fixture.controller.current.processSessionId,
          persisted.processSessionId,
        );
        expect(
          fixture.controller.current.status,
          OnboardingOperationStatus.interrupted,
        );
      },
    );

    test(
      'reimport cannot begin after prerequisites regress while held',
      () async {
        final reset = _ReplayResetService();
        final fixture = await _JourneyFixture.create(
          report: _report(
            state: OnboardingEnvironmentState.ready,
            blockerKind: OnboardingBlockerKind.none,
          ),
          resetService: reset,
          useRealGlobalEnvironmentFeedback: true,
        );
        addTearDown(fixture.dispose);
        final normal = fixture.journey as OnboardingNormalApplication;
        fixture.holdNextControllerAcquisition();

        final reimport = fixture.coordinator.startReimport(
          actionContext: normal.actionContext,
        );
        await fixture.controllerAccess.requested;
        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.sourceUnavailable,
          blockerKind: OnboardingBlockerKind.addressBookUnavailable,
        );
        await fixture.refreshReport();
        expect(fixture.journey, same(normal));

        fixture.controllerAccess.release();
        await reimport;

        expect(fixture.journey, isA<OnboardingNeedsContactsAccess>());
        expect(
          fixture.controller.current.status,
          OnboardingOperationStatus.idle,
        );
        expect(reset.callCount, 0);
      },
    );

    test(
      'automatic recovery cannot begin after prerequisites regress while held',
      () async {
        final reset = _ReplayResetService();
        final fixture = await _JourneyFixture.create(
          report: _report(
            state: OnboardingEnvironmentState.graphProjectionFailed,
            blockerKind: OnboardingBlockerKind.graphProjectionFailed,
            shouldReset: true,
          ),
          resetService: reset,
          holdControllerInitially: true,
          useRealGlobalEnvironmentFeedback: true,
        );
        addTearDown(fixture.dispose);
        await fixture.controllerAccess.requested;
        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.permissionBlocked,
          blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
          hasFullDiskAccess: false,
        );
        await fixture.refreshReport();

        fixture.controllerAccess.release();
        await _drainMicrotasks();

        expect(fixture.journey, isA<OnboardingNeedsMessagesAccess>());
        expect(
          fixture.controller.current.status,
          OnboardingOperationStatus.idle,
        );
        expect(reset.callCount, 0);
      },
    );

    test(
      'automatic reset rechecks prerequisites after progress persistence',
      () async {
        final progressSaveStarted = Completer<void>();
        final releaseProgressSave = Completer<void>();
        final reset = _ReplayResetService();
        final fixture = await _JourneyFixture.create(
          report: _report(
            state: OnboardingEnvironmentState.graphProjectionFailed,
            blockerKind: OnboardingBlockerKind.graphProjectionFailed,
            shouldReset: true,
          ),
          resetService: reset,
          resettingProgressSaveStarted: progressSaveStarted,
          releaseResettingProgressSave: releaseProgressSave,
          useRealGlobalEnvironmentFeedback: true,
        );
        addTearDown(fixture.dispose);
        await progressSaveStarted.future;
        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.permissionBlocked,
          blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
          hasFullDiskAccess: false,
        );
        await fixture.refreshReport();

        releaseProgressSave.complete();
        await _drainMicrotasks();

        expect(fixture.journey, isA<OnboardingNeedsMessagesAccess>());
        expect(
          fixture.controller.current.status,
          OnboardingOperationStatus.failed,
        );
        expect(reset.callCount, 0);
      },
    );

    test(
      'initial import cannot begin after readiness supersedes it while held',
      () async {
        final graph = _ReplayGraphController();
        final fixture = await _JourneyFixture.create(
          graph: graph,
          useRealGlobalEnvironmentFeedback: true,
        );
        addTearDown(fixture.dispose);
        final readyToImport = fixture.journey as OnboardingReadyToImport;
        fixture.holdNextControllerAcquisition();

        final import = fixture.coordinator.startVirginImportAndGraphBuild(
          actionContext: readyToImport.actionContext,
        );
        await fixture.controllerAccess.requested;
        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.ready,
          blockerKind: OnboardingBlockerKind.none,
        );
        await fixture.refreshReport();
        expect(fixture.journey, same(readyToImport));

        fixture.controllerAccess.release();
        await import;

        expect(fixture.journey, isA<OnboardingNormalApplication>());
        expect(
          fixture.controller.current.status,
          OnboardingOperationStatus.idle,
        );
        expect(fixture.controller.current.operationId, isNull);
        expect(graph.runCount, 0);
      },
    );

    test('explicit reimport requires the latest normal-ready report', () async {
      final reset = _ReplayResetService();
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.ready,
          blockerKind: OnboardingBlockerKind.none,
        ),
        resetService: reset,
        useRealGlobalEnvironmentFeedback: true,
      );
      addTearDown(fixture.dispose);
      final normal = fixture.journey as OnboardingNormalApplication;
      fixture.holdNextControllerAcquisition();

      final reimport = fixture.coordinator.startReimport(
        actionContext: normal.actionContext,
      );
      await fixture.controllerAccess.requested;
      fixture.reports.current = _report(
        state: OnboardingEnvironmentState.readyToImport,
        blockerKind: OnboardingBlockerKind.none,
      );
      await fixture.refreshReport();
      expect(fixture.journey, same(normal));

      fixture.controllerAccess.release();
      await reimport;

      expect(fixture.journey, isA<OnboardingReadyToImport>());
      expect(fixture.controller.current.status, OnboardingOperationStatus.idle);
      expect(fixture.controller.current.operationId, isNull);
      expect(reset.callCount, 0);
    });

    test(
      'Continue Setup is inert after readiness supersedes interruption',
      () async {
        final persisted = _interruptedSnapshot();
        final fixture = await _JourneyFixture.create(
          persisted: persisted,
          useRealGlobalEnvironmentFeedback: true,
        );
        addTearDown(fixture.dispose);
        final interrupted = fixture.journey as OnboardingOperationInterrupted;
        fixture.holdNextControllerAcquisition();

        final continuation = fixture.coordinator.continueInterruptedOperation(
          actionContext: interrupted.actionContext,
        );
        await fixture.controllerAccess.requested;
        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.ready,
          blockerKind: OnboardingBlockerKind.none,
        );
        await fixture.refreshReport();
        expect(fixture.journey, same(interrupted));

        fixture.controllerAccess.release();
        await continuation;

        expect(fixture.journey, isA<OnboardingNormalApplication>());
        expect(fixture.controller.current.operationId, persisted.operationId);
        expect(
          fixture.controller.current.processSessionId,
          persisted.processSessionId,
        );
        expect(
          fixture.controller.current.status,
          OnboardingOperationStatus.interrupted,
        );
        final afterWithdrawal = fixture.journey;
        await fixture.coordinator.continueInterruptedOperation(
          actionContext: interrupted.actionContext,
        );
        expect(fixture.journey, same(afterWithdrawal));
      },
    );

    test(
      'automatic recovery cannot begin after reset requirement is withdrawn',
      () async {
        final reset = _ReplayResetService();
        final fixture = await _JourneyFixture.create(
          report: _report(
            state: OnboardingEnvironmentState.graphProjectionFailed,
            blockerKind: OnboardingBlockerKind.graphProjectionFailed,
            shouldReset: true,
          ),
          resetService: reset,
          holdControllerInitially: true,
          useRealGlobalEnvironmentFeedback: true,
        );
        addTearDown(fixture.dispose);
        await fixture.controllerAccess.requested;
        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.ready,
          blockerKind: OnboardingBlockerKind.none,
        );
        await fixture.refreshReport();

        fixture.controllerAccess.release();
        await _drainMicrotasks();

        expect(fixture.journey, isA<OnboardingNormalApplication>());
        expect(
          fixture.controller.current.status,
          OnboardingOperationStatus.idle,
        );
        expect(fixture.controller.current.operationId, isNull);
        expect(reset.callCount, 0);
      },
    );

    test(
      'automatic reset stops when reset requirement clears after begin',
      () async {
        final progressSaveStarted = Completer<void>();
        final releaseProgressSave = Completer<void>();
        final reset = _ReplayResetService();
        final fixture = await _JourneyFixture.create(
          report: _report(
            state: OnboardingEnvironmentState.graphProjectionFailed,
            blockerKind: OnboardingBlockerKind.graphProjectionFailed,
            shouldReset: true,
          ),
          resetService: reset,
          resettingProgressSaveStarted: progressSaveStarted,
          releaseResettingProgressSave: releaseProgressSave,
          useRealGlobalEnvironmentFeedback: true,
        );
        addTearDown(fixture.dispose);
        await progressSaveStarted.future;
        final operationId = fixture.controller.current.operationId;
        expect(operationId, isNotNull);
        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.ready,
          blockerKind: OnboardingBlockerKind.none,
        );
        await fixture.refreshReport();

        releaseProgressSave.complete();
        await fixture.globalEnvironmentReports.waitFor(
          OnboardingEnvironmentState.ready,
        );
        await _drainMicrotasks();

        expect(fixture.journey, isA<OnboardingOperationFailed>());
        expect(fixture.controller.current.operationId, operationId);
        expect(
          fixture.controller.current.status,
          OnboardingOperationStatus.failed,
        );
        expect(reset.callCount, 0);
      },
    );
  });

  group('real aggregate-maintenance feedback loop', () {
    test(
      'initial import survives its own aggregate maintenance report',
      () async {
        final graph = _ReplayGraphController();
        final fixture = await _JourneyFixture.create(
          graph: graph,
          holdControllerInitially: true,
          useRealGlobalEnvironmentFeedback: true,
        );
        addTearDown(fixture.dispose);
        final authorized = fixture.journey;

        final command = fixture.coordinator.startVirginImportAndGraphBuild(
          actionContext: authorized.actionContext,
        );
        await fixture.controllerAccess.requested;
        final maintenance = await fixture.globalEnvironmentReports.waitFor(
          OnboardingEnvironmentState.maintenanceInProgress,
        );
        await _drainMicrotasks();

        expect(maintenance.blockerKind, OnboardingBlockerKind.none);
        expect(fixture.journey, same(authorized));
        fixture.controllerAccess.release();
        await command;

        expect(graph.runCount, 1);
        expect(fixture.journey, isA<OnboardingReadyToStart>());
      },
    );

    test('reimport survives its own aggregate maintenance report', () async {
      final reset = _ReplayResetService();
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.ready,
          blockerKind: OnboardingBlockerKind.none,
        ),
        resetService: reset,
        holdControllerInitially: true,
        useRealGlobalEnvironmentFeedback: true,
      );
      addTearDown(fixture.dispose);
      final authorized = fixture.journey;

      final command = fixture.coordinator.startReimport(
        actionContext: authorized.actionContext,
      );
      await fixture.controllerAccess.requested;
      await fixture.globalEnvironmentReports.waitFor(
        OnboardingEnvironmentState.maintenanceInProgress,
      );
      await _drainMicrotasks();

      expect(fixture.journey, same(authorized));
      fixture.controllerAccess.release();
      await command;

      expect(reset.callCount, 1);
      expect(fixture.journey, isA<OnboardingReimportReady>());
    });

    test(
      'Continue Setup survives its own aggregate maintenance report',
      () async {
        final persisted = _interruptedSnapshot();
        final fixture = await _JourneyFixture.create(
          persisted: persisted,
          holdControllerInitially: true,
          useRealGlobalEnvironmentFeedback: true,
        );
        addTearDown(fixture.dispose);
        final authorized = fixture.journey as OnboardingOperationInterrupted;

        final command = fixture.coordinator.continueInterruptedOperation(
          actionContext: authorized.actionContext,
        );
        await fixture.controllerAccess.requested;
        await fixture.globalEnvironmentReports.waitFor(
          OnboardingEnvironmentState.maintenanceInProgress,
        );
        await _drainMicrotasks();

        expect(fixture.journey, same(authorized));
        fixture.controllerAccess.release();
        await command;

        expect(fixture.journey, isA<OnboardingReadyToStart>());
        expect(fixture.journey.operation?.operationId, persisted.operationId);
      },
    );

    test(
      'automatic recovery survives its own aggregate maintenance report',
      () async {
        final reset = _ReplayResetService();
        final fixture = await _JourneyFixture.create(
          report: _report(
            state: OnboardingEnvironmentState.graphProjectionFailed,
            blockerKind: OnboardingBlockerKind.graphProjectionFailed,
            shouldReset: true,
          ),
          resetService: reset,
          holdControllerInitially: true,
          useRealGlobalEnvironmentFeedback: true,
        );
        addTearDown(fixture.dispose);
        await fixture.controllerAccess.requested;
        final maintenance = await fixture.globalEnvironmentReports.waitFor(
          OnboardingEnvironmentState.maintenanceInProgress,
        );
        await _drainMicrotasks();

        expect(maintenance.blockerKind, OnboardingBlockerKind.none);
        fixture.controllerAccess.release();
        await reset.called;
        await _drainMicrotasks();

        expect(reset.callCount, 1);
      },
    );
  });

  group('maintenance presentation truth', () {
    test('cold startup with maintenance evidence remains checking', () async {
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.maintenanceInProgress,
          blockerKind: OnboardingBlockerKind.none,
        ),
      );
      addTearDown(fixture.dispose);

      expect(fixture.journey, isA<OnboardingCheckingPrerequisites>());
    });

    test('maintenance alone retains established normal state', () async {
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.ready,
          blockerKind: OnboardingBlockerKind.none,
        ),
      );
      addTearDown(fixture.dispose);
      final established = fixture.journey;

      fixture.reports.current = _report(
        state: OnboardingEnvironmentState.maintenanceInProgress,
        blockerKind: OnboardingBlockerKind.none,
      );
      await fixture.refreshReport();

      expect(established, isA<OnboardingNormalApplication>());
      expect(fixture.journey, isA<OnboardingNormalApplication>());
    });

    test('maintenance alone retains Ready to Import', () async {
      final fixture = await _JourneyFixture.create();
      addTearDown(fixture.dispose);
      final established = fixture.journey;

      fixture.reports.current = _report(
        state: OnboardingEnvironmentState.maintenanceInProgress,
        blockerKind: OnboardingBlockerKind.none,
      );
      await fixture.refreshReport();

      expect(established, isA<OnboardingReadyToImport>());
      expect(fixture.journey, isA<OnboardingReadyToImport>());
    });

    test('maintenance alone retains a visible failure', () async {
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.graphProjectionFailed,
          blockerKind: OnboardingBlockerKind.graphProjectionFailed,
        ),
      );
      addTearDown(fixture.dispose);
      final established = fixture.journey;
      expect(established, isA<OnboardingOperationFailed>());

      fixture.reports.current = _report(
        state: OnboardingEnvironmentState.maintenanceInProgress,
        blockerKind: OnboardingBlockerKind.none,
      );
      await fixture.refreshReport();

      expect(fixture.journey, isA<OnboardingOperationFailed>());
      expect(
        (fixture.journey as OnboardingOperationFailed).summary,
        (established as OnboardingOperationFailed).summary,
      );
    });

    test('maintenance alone retains an interrupted operation', () async {
      final fixture = await _JourneyFixture.create(
        persisted: _interruptedSnapshot(),
      );
      addTearDown(fixture.dispose);
      final established = fixture.journey;
      expect(established, isA<OnboardingOperationInterrupted>());

      fixture.reports.current = _report(
        state: OnboardingEnvironmentState.maintenanceInProgress,
        blockerKind: OnboardingBlockerKind.none,
      );
      await fixture.refreshReport();

      expect(fixture.journey, isA<OnboardingOperationInterrupted>());
      expect(
        fixture.journey.operation?.operationId,
        established.operation?.operationId,
      );
    });

    test('hard prerequisite blockers still displace maintenance', () async {
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.maintenanceInProgress,
          blockerKind: OnboardingBlockerKind.none,
        ),
      );
      addTearDown(fixture.dispose);

      fixture.reports.current = _report(
        state: OnboardingEnvironmentState.permissionBlocked,
        blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
        hasFullDiskAccess: false,
      );
      await fixture.refreshReport();

      expect(fixture.journey, isA<OnboardingNeedsMessagesAccess>());
    });

    test('complete evidence after maintenance advances normally', () async {
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.maintenanceInProgress,
          blockerKind: OnboardingBlockerKind.none,
        ),
      );
      addTearDown(fixture.dispose);

      fixture.reports.current = _report(
        state: OnboardingEnvironmentState.ready,
        blockerKind: OnboardingBlockerKind.none,
      );
      await fixture.refreshReport();

      expect(fixture.journey, isA<OnboardingNormalApplication>());
    });
  });

  group('operation replay', () {
    test(
      'first import success binds one UUID through terminal proof',
      () async {
        final fixture = await _JourneyFixture.create(
          useRealGlobalEnvironmentFeedback: true,
        );
        addTearDown(fixture.dispose);
        final context = fixture.journey.actionContext;

        await fixture.coordinator.startVirginImportAndGraphBuild(
          actionContext: context,
        );

        final terminal = fixture.journey;
        expect(terminal, isA<OnboardingReadyToStart>());
        expect(terminal.operation?.operationId, fixture.firstOperationId);
        expect(
          terminal.operation?.phase,
          OnboardingJourneyOperationPhase.verified,
        );
        expect(
          fixture.controller.current.status,
          OnboardingOperationStatus.completed,
        );
      },
    );

    test('first import failure retries with a new UUID and succeeds', () async {
      final graph = _ReplayGraphController(failuresBeforeSuccess: 1);
      final fixture = await _JourneyFixture.create(graph: graph);
      addTearDown(fixture.dispose);

      await fixture.coordinator.startVirginImportAndGraphBuild(
        actionContext: fixture.journey.actionContext,
      );
      final failed = fixture.journey;
      expect(failed, isA<OnboardingOperationFailed>());
      final failedId = failed.operation!.operationId;

      await fixture.coordinator.retryFailedOperation(
        actionContext: failed.actionContext,
      );

      expect(fixture.journey, isA<OnboardingReadyToStart>());
      expect(fixture.journey.operation?.operationId, isNot(failedId));
      expect(graph.runCount, 2);
    });

    test('retry admission failure remains UUID-less', () async {
      final fixture = await _JourneyFixture.create(
        graph: _ReplayGraphController(failuresBeforeSuccess: 1),
      );
      addTearDown(fixture.dispose);
      await fixture.coordinator.startVirginImportAndGraphBuild(
        actionContext: fixture.journey.actionContext,
      );
      final firstFailure = fixture.journey as OnboardingOperationFailed;
      expect(firstFailure.operation, isNotNull);
      final authorityHold = await fixture.holdArchiveAuthority();
      final currentFailure = fixture.journey as OnboardingOperationFailed;

      await fixture.coordinator.retryFailedOperation(
        actionContext: currentFailure.actionContext,
      );

      final admissionFailure = fixture.journey as OnboardingOperationFailed;
      expect(admissionFailure.operation, isNull);
      expect(admissionFailure.summary, contains('Archive mutation denied'));
      expect(
        admissionFailure.failureAction,
        OnboardingJourneyFailureAction.retryInitialImport,
      );
      await authorityHold.release();
    });

    test(
      'durable verification failure publishes Journey failure first',
      () async {
        final verifier = _ReplayVerifier(failuresBeforeSuccess: 1);
        final fixture = await _JourneyFixture.create(verifier: verifier);
        addTearDown(fixture.dispose);

        await fixture.coordinator.startVirginImportAndGraphBuild(
          actionContext: fixture.journey.actionContext,
        );

        final failed = fixture.journey as OnboardingOperationFailed;
        expect(failed.operation, isNotNull);
        expect(
          failed.operation!.failure?.category,
          OnboardingOperationFailureCategory.durableReadinessVerification,
        );
        expect(failed.summary, contains('synthetic verification failure'));
      },
    );

    test(
      'completion evidence persistence failure still reaches Journey',
      () async {
        final fixture = await _JourneyFixture.create(
          failCompletionSnapshotWrites: true,
        );
        addTearDown(fixture.dispose);

        await fixture.coordinator.startVirginImportAndGraphBuild(
          actionContext: fixture.journey.actionContext,
        );

        final failed = fixture.journey as OnboardingOperationFailed;
        expect(failed.summary, contains('snapshot completion persistence'));
        expect(
          failed.operation?.failure?.category,
          OnboardingOperationFailureCategory.durableReadinessVerification,
        );
        expect(
          fixture.controller.current.status,
          OnboardingOperationStatus.failed,
        );
      },
    );

    test(
      'diagnostic persistence failures cannot mask the primary failure',
      () async {
        final fixture = await _JourneyFixture.create(
          graph: _ReplayGraphController(failuresBeforeSuccess: 1),
          failTerminalSnapshotWrites: true,
          failureStore: _MemoryFailureStore(throwOnWrites: true),
        );
        addTearDown(fixture.dispose);

        await fixture.coordinator.startVirginImportAndGraphBuild(
          actionContext: fixture.journey.actionContext,
        );

        final failed = fixture.journey as OnboardingOperationFailed;
        expect(failed.summary, contains('synthetic graph failure'));
        expect(
          failed.operation?.failure?.category,
          OnboardingOperationFailureCategory.messageDataBuild,
        );
        expect(
          fixture.controller.current.status,
          OnboardingOperationStatus.running,
        );
      },
    );

    test(
      'UUID-less first-import admission failure retries first import',
      () async {
        final fixture = await _JourneyFixture.create(
          useRealGlobalEnvironmentFeedback: true,
        );
        addTearDown(fixture.dispose);
        final authorityHold = await fixture.holdArchiveAuthority();

        await fixture.coordinator.startVirginImportAndGraphBuild(
          actionContext: fixture.journey.actionContext,
        );

        final failed = fixture.journey as OnboardingOperationFailed;
        expect(failed.operation, isNull);
        expect(failed.summary, contains('Archive mutation denied'));
        expect(
          failed.failureAction,
          OnboardingJourneyFailureAction.retryInitialImport,
        );
        await authorityHold.release();
        final currentFailure = fixture.journey as OnboardingOperationFailed;

        await fixture.coordinator.retryFailedOperation(
          actionContext: currentFailure.actionContext,
        );

        expect(fixture.journey, isA<OnboardingReadyToStart>());
      },
    );

    test('UUID-less reimport begin failure retries reimport', () async {
      final reset = _ReplayResetService();
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.ready,
          blockerKind: OnboardingBlockerKind.none,
        ),
        beginSnapshotFailuresBeforeSuccess: 1,
        resetService: reset,
      );
      addTearDown(fixture.dispose);

      await fixture.coordinator.startReimport(
        actionContext: fixture.journey.actionContext,
      );

      final failed = fixture.journey as OnboardingOperationFailed;
      expect(failed.operation, isNull);
      expect(
        failed.failureAction,
        OnboardingJourneyFailureAction.retryReimport,
      );
      expect(failed.summary, contains('snapshot begin persistence failure'));

      await fixture.coordinator.retryFailedOperation(
        actionContext: failed.actionContext,
      );

      expect(fixture.journey, isA<OnboardingReimportReady>());
      expect(reset.callCount, 1);
    });

    test('automatic recovery denial re-evaluates without a UUID', () async {
      final fixture = await _JourneyFixture.create(
        reportResolver: (readCount) => readCount == 1
            ? _report(
                state: OnboardingEnvironmentState.graphProjectionFailed,
                blockerKind: OnboardingBlockerKind.graphProjectionFailed,
                shouldReset: true,
              )
            : _report(
                state: OnboardingEnvironmentState.readyToImport,
                blockerKind: OnboardingBlockerKind.none,
              ),
        holdArchiveAuthorityInitially: true,
      );
      addTearDown(fixture.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(fixture.journey, isA<OnboardingReadyToImport>());
      expect(fixture.controller.current.operationId, isNull);
    });

    test(
      'automatic recovery publishes bound work once and re-evaluates',
      () async {
        final reset = _ReplayResetService();
        final fixture = await _JourneyFixture.create(
          reportResolver: (readCount) => readCount == 1
              ? _report(
                  state: OnboardingEnvironmentState.graphProjectionFailed,
                  blockerKind: OnboardingBlockerKind.graphProjectionFailed,
                  shouldReset: true,
                )
              : _report(
                  state: OnboardingEnvironmentState.readyToImport,
                  blockerKind: OnboardingBlockerKind.none,
                ),
          resetService: reset,
        );
        addTearDown(fixture.dispose);
        await _drainMicrotasks();

        expect(reset.callCount, 1);
        expect(fixture.reports.readCount, 2);
        expect(fixture.journey, isA<OnboardingReadyToImport>());
        expect(
          fixture.controller.current.status,
          OnboardingOperationStatus.idle,
        );
      },
    );

    test(
      'release before denial handling still re-evaluates evidence',
      () async {
        final reset = _ReplayResetService();
        final fixture = await _JourneyFixture.create(
          reportResolver: (readCount) => readCount == 1
              ? _report(
                  state: OnboardingEnvironmentState.graphProjectionFailed,
                  blockerKind: OnboardingBlockerKind.graphProjectionFailed,
                  shouldReset: true,
                )
              : _report(
                  state: OnboardingEnvironmentState.readyToImport,
                  blockerKind: OnboardingBlockerKind.none,
                ),
          resetService: reset,
          holdArchiveAuthorityInitially: true,
        );
        addTearDown(fixture.dispose);
        await _drainMicrotasks();

        expect(reset.callCount, 0);
        expect(fixture.reports.readCount, 2);
        expect(fixture.journey, isA<OnboardingReadyToImport>());
      },
    );

    test('terminal acknowledgement validates occurrence', () async {
      final fixture = await _JourneyFixture.create();
      addTearDown(fixture.dispose);
      await fixture.coordinator.startVirginImportAndGraphBuild(
        actionContext: fixture.journey.actionContext,
      );
      final terminalContext = fixture.journey.actionContext;
      fixture.reports.current = _report(
        state: OnboardingEnvironmentState.ready,
        blockerKind: OnboardingBlockerKind.none,
      );
      await fixture.refreshReport();

      fixture.coordinator.acknowledgeTerminal(actionContext: terminalContext);

      expect(fixture.journey, isA<OnboardingNormalApplication>());
      final normalOccurrence = fixture.journey.occurrence;
      fixture.coordinator.acknowledgeTerminal(actionContext: terminalContext);
      expect(fixture.journey.occurrence, normalOccurrence);
    });

    test('interrupted import requires Continue Setup and keeps UUID', () async {
      final persisted = _interruptedSnapshot();
      final fixture = await _JourneyFixture.create(persisted: persisted);
      addTearDown(fixture.dispose);

      final interrupted = fixture.journey as OnboardingOperationInterrupted;
      expect(
        interrupted.operation.availableActions,
        contains(OnboardingJourneyOperationAction.continueSetup),
      );
      await fixture.coordinator.continueInterruptedOperation(
        actionContext: interrupted.actionContext,
      );

      expect(fixture.journey, isA<OnboardingReadyToStart>());
      expect(fixture.journey.operation?.operationId, persisted.operationId);
      expect(
        fixture.controller.current.processSessionId,
        fixture.processSessionId,
      );
      final completed = fixture.journey;
      await fixture.coordinator.continueInterruptedOperation(
        actionContext: interrupted.actionContext,
      );
      expect(fixture.journey, same(completed));
    });

    test(
      'interruption without an exact safe boundary becomes failure',
      () async {
        final fixture = await _JourneyFixture.create(
          persisted: _interruptedSnapshotWithoutSubstage(),
        );
        addTearDown(fixture.dispose);

        final failed = fixture.journey as OnboardingOperationFailed;
        expect(failed.summary, contains('no verified safe resume boundary'));
        expect(
          failed.operation?.availableActions,
          contains(OnboardingJourneyOperationAction.retry),
        );
      },
    );

    test(
      'interrupted automatic recovery becomes a retryable failure',
      () async {
        final fixture = await _JourneyFixture.create(
          persisted: _interruptedAutomaticRecoverySnapshot(),
        );
        addTearDown(fixture.dispose);

        final failed = fixture.journey as OnboardingOperationFailed;
        expect(failed.summary, contains('must restart from a new attempt'));
        expect(
          failed.operation?.availableActions,
          contains(OnboardingJourneyOperationAction.retry),
        );
      },
    );

    test('missing FDA outranks retained failure evidence', () async {
      final persisted = _manualInspectionFailureSnapshot();
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.permissionBlocked,
          blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
          hasFullDiskAccess: false,
        ),
        persisted: persisted,
      );
      addTearDown(fixture.dispose);

      expect(fixture.journey, isA<OnboardingNeedsMessagesAccess>());
      expect(fixture.journey.operation, isNull);
    });

    test(
      'missing Messages source outranks retained failure evidence',
      () async {
        final fixture = await _JourneyFixture.create(
          report: _report(
            state: OnboardingEnvironmentState.sourceUnavailable,
            blockerKind: OnboardingBlockerKind.messagesDatabaseMissing,
          ),
          persisted: _manualInspectionFailureSnapshot(),
        );
        addTearDown(fixture.dispose);

        expect(fixture.journey, isA<OnboardingNeedsMessagesAccess>());
      },
    );

    test('local-history blocker outranks retained failure evidence', () async {
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.sourceSparseOrUnsynced,
          blockerKind: OnboardingBlockerKind.sourceDataSparseOrUnsynced,
        ),
        persisted: _manualInspectionFailureSnapshot(),
      );
      addTearDown(fixture.dispose);

      expect(fixture.journey, isA<OnboardingNeedsLocalHistoryConfirmation>());
    });

    test('Contacts blocker outranks retained failure evidence', () async {
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.sourceUnavailable,
          blockerKind: OnboardingBlockerKind.addressBookUnavailable,
        ),
        persisted: _manualInspectionFailureSnapshot(),
      );
      addTearDown(fixture.dispose);

      expect(fixture.journey, isA<OnboardingNeedsContactsAccess>());
    });

    test(
      'new FDA loss displaces visible failure and compatible evidence restores it',
      () async {
        final persisted = _manualInspectionFailureSnapshot();
        final fixture = await _JourneyFixture.create(persisted: persisted);
        addTearDown(fixture.dispose);
        final firstFailure = fixture.journey as OnboardingOperationFailed;

        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.permissionBlocked,
          blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
          hasFullDiskAccess: false,
        );
        await fixture.refreshReport();

        final blocked = fixture.journey;
        expect(blocked, isA<OnboardingNeedsMessagesAccess>());
        expect(blocked.operation, isNull);
        await fixture.coordinator.retryFailedOperation(
          actionContext: firstFailure.actionContext,
        );
        expect(fixture.journey, same(blocked));

        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.readyToImport,
          blockerKind: OnboardingBlockerKind.none,
        );
        await fixture.refreshReport();

        final restored = fixture.journey as OnboardingOperationFailed;
        expect(restored.operation?.operationId, persisted.operationId);
        expect(restored.summary, 'manual inspection required');
        expect(restored.failureAction, OnboardingJourneyFailureAction.none);
        expect(restored.occurrence, isNot(firstFailure.occurrence));
        expect(restored.occurrence, isNot(blocked.occurrence));
      },
    );

    test(
      'prerequisite regression hides Continue Setup until compatibility returns',
      () async {
        final persisted = _interruptedSnapshot();
        final fixture = await _JourneyFixture.create(persisted: persisted);
        addTearDown(fixture.dispose);
        final firstInterrupted =
            fixture.journey as OnboardingOperationInterrupted;

        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.sourceUnavailable,
          blockerKind: OnboardingBlockerKind.addressBookUnavailable,
        );
        await fixture.refreshReport();

        final blocked = fixture.journey;
        expect(blocked, isA<OnboardingNeedsContactsAccess>());
        expect(blocked.operation, isNull);
        await fixture.coordinator.continueInterruptedOperation(
          actionContext: firstInterrupted.actionContext,
        );
        expect(fixture.journey, same(blocked));
        expect(
          fixture.controller.current.status,
          OnboardingOperationStatus.interrupted,
        );

        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.readyToImport,
          blockerKind: OnboardingBlockerKind.none,
        );
        await fixture.refreshReport();

        final restored = fixture.journey as OnboardingOperationInterrupted;
        expect(restored.operation.operationId, persisted.operationId);
        expect(
          restored.operation.availableActions,
          contains(OnboardingJourneyOperationAction.continueSetup),
        );
        expect(restored.occurrence, isNot(firstInterrupted.occurrence));
      },
    );

    test('restart ignores completed snapshot as historical evidence', () async {
      final completed = _completedSnapshot();
      final fixture = await _JourneyFixture.create(
        report: _report(
          state: OnboardingEnvironmentState.ready,
          blockerKind: OnboardingBlockerKind.none,
        ),
        persisted: completed,
      );
      addTearDown(fixture.dispose);

      expect(fixture.journey, isA<OnboardingNormalApplication>());
      expect(fixture.journey.operation, isNull);
    });
  });

  group('failure publication ordering', () {
    test('Journey failure precedes snapshot failure persistence', () async {
      late _JourneyFixture fixture;
      var boundaryObserved = 0;
      fixture = await _JourneyFixture.create(
        graph: _ReplayGraphController(failuresBeforeSuccess: 1),
        failTerminalSnapshotWrites: true,
        onFailedSnapshotSave: () {
          boundaryObserved += 1;
          _expectPrimaryGraphFailure(fixture);
        },
      );
      addTearDown(fixture.dispose);

      await fixture.coordinator.startVirginImportAndGraphBuild(
        actionContext: fixture.journey.actionContext,
      );

      expect(boundaryObserved, 1);
      _expectPrimaryGraphFailure(fixture);
    });

    test('Journey failure precedes graph failure-store persistence', () async {
      late _JourneyFixture fixture;
      var boundaryObserved = 0;
      fixture = await _JourneyFixture.create(
        graph: _ReplayGraphController(failuresBeforeSuccess: 1),
        failureStore: _MemoryFailureStore(
          throwOnWrites: true,
          onWrite: () {
            boundaryObserved += 1;
            _expectPrimaryGraphFailure(fixture);
          },
        ),
      );
      addTearDown(fixture.dispose);

      await fixture.coordinator.startVirginImportAndGraphBuild(
        actionContext: fixture.journey.actionContext,
      );

      expect(boundaryObserved, 1);
      _expectPrimaryGraphFailure(fixture);
    });

    test('Journey failure precedes logger acquisition', () async {
      late _JourneyFixture fixture;
      var boundaryObserved = 0;
      fixture = await _JourneyFixture.create(
        graph: _ReplayGraphController(failuresBeforeSuccess: 1),
        appLogger: _ThrowingBuildAppLogger(() {
          boundaryObserved += 1;
          _expectPrimaryGraphFailure(fixture);
        }),
      );
      addTearDown(fixture.dispose);

      await fixture.coordinator.startVirginImportAndGraphBuild(
        actionContext: fixture.journey.actionContext,
      );

      expect(boundaryObserved, 1);
      _expectPrimaryGraphFailure(fixture);
    });

    test('Journey failure precedes logger write', () async {
      late _JourneyFixture fixture;
      var boundaryObserved = 0;
      fixture = await _JourneyFixture.create(
        graph: _ReplayGraphController(failuresBeforeSuccess: 1),
        appLogger: _ThrowingWriteAppLogger(() {
          boundaryObserved += 1;
          _expectPrimaryGraphFailure(fixture);
        }),
      );
      addTearDown(fixture.dispose);

      await fixture.coordinator.startVirginImportAndGraphBuild(
        actionContext: fixture.journey.actionContext,
      );

      expect(boundaryObserved, 1);
      _expectPrimaryGraphFailure(fixture);
    });

    test('Journey failure precedes evidence refresh', () async {
      late _JourneyFixture fixture;
      var boundaryObserved = 0;
      fixture = await _JourneyFixture.create(
        graph: _ReplayGraphController(failuresBeforeSuccess: 1),
        throwOnReportRefresh: true,
        onReportRead: (readCount) {
          if (readCount > 1) {
            boundaryObserved += 1;
            _expectPrimaryGraphFailure(fixture);
          }
        },
      );
      addTearDown(fixture.dispose);

      await fixture.coordinator.startVirginImportAndGraphBuild(
        actionContext: fixture.journey.actionContext,
      );
      await _drainMicrotasks();

      expect(boundaryObserved, greaterThanOrEqualTo(1));
      _expectPrimaryGraphFailure(fixture);
    });
  });

  group('hostile asynchronous noise', () {
    test(
      'retired operation A failure cannot leave normal application',
      () async {
        final fixture = await _JourneyFixture.create();
        addTearDown(fixture.dispose);
        await fixture.coordinator.startVirginImportAndGraphBuild(
          actionContext: fixture.journey.actionContext,
        );
        final completedA = fixture.controller.current;
        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.ready,
          blockerKind: OnboardingBlockerKind.none,
        );
        fixture.coordinator.acknowledgeTerminal(
          actionContext: fixture.journey.actionContext,
        );
        await _drainMicrotasks();
        final normal = fixture.journey;
        expect(normal, isA<OnboardingNormalApplication>());

        fixture.evidence.inject(_replayedFailure(completedA));
        await _drainMicrotasks();

        expect(fixture.journey, same(normal));
        expect(fixture.journey.occurrence, normal.occurrence);
      },
    );

    test(
      'retired operation A interruption cannot leave normal application',
      () async {
        final fixture = await _JourneyFixture.create();
        addTearDown(fixture.dispose);
        await fixture.coordinator.startVirginImportAndGraphBuild(
          actionContext: fixture.journey.actionContext,
        );
        final completedA = fixture.controller.current;
        fixture.reports.current = _report(
          state: OnboardingEnvironmentState.ready,
          blockerKind: OnboardingBlockerKind.none,
        );
        fixture.coordinator.acknowledgeTerminal(
          actionContext: fixture.journey.actionContext,
        );
        await _drainMicrotasks();
        final normal = fixture.journey;
        expect(normal, isA<OnboardingNormalApplication>());

        fixture.evidence.inject(_replayedInterruption(completedA));
        await _drainMicrotasks();

        expect(fixture.journey, same(normal));
        expect(fixture.journey.occurrence, normal.occurrence);
      },
    );

    test('legitimate startup interruption is adopted exactly once', () async {
      final persisted = _interruptedSnapshot();
      final fixture = await _JourneyFixture.create(persisted: persisted);
      addTearDown(fixture.dispose);
      final adopted = fixture.journey as OnboardingOperationInterrupted;

      fixture.evidence.inject(persisted);
      await _drainMicrotasks();

      expect(fixture.journey, same(adopted));
      expect(fixture.journey.occurrence, adopted.occurrence);
      expect(fixture.journey.operation?.operationId, persisted.operationId);
    });

    test('running command survives environment reconstruction', () async {
      final graph = _ReplayGraphController(hold: Completer<void>());
      final fixture = await _JourneyFixture.create(graph: graph);
      addTearDown(fixture.dispose);
      final command = fixture.coordinator.startVirginImportAndGraphBuild(
        actionContext: fixture.journey.actionContext,
      );
      await graph.started.future;
      final active = fixture.journey;
      expect(active, isA<OnboardingBuildingLocalData>());

      fixture.reports.current = _report(
        state: OnboardingEnvironmentState.maintenanceInProgress,
        blockerKind: OnboardingBlockerKind.none,
      );
      await fixture.refreshReport();
      expect(
        fixture.journey.operation?.operationId,
        active.operation?.operationId,
      );

      graph.hold!.complete();
      await command;
      expect(fixture.journey, isA<OnboardingReadyToStart>());
    });

    test(
      'late/regressing/contradictory evidence cannot replace binding',
      () async {
        final graph = _ReplayGraphController(hold: Completer<void>());
        final fixture = await _JourneyFixture.create(graph: graph);
        addTearDown(fixture.dispose);
        final command = fixture.coordinator.startVirginImportAndGraphBuild(
          actionContext: fixture.journey.actionContext,
        );
        await graph.started.future;
        final bound = fixture.journey.operation!;

        fixture.evidence.inject(_interruptedSnapshot());
        fixture.evidence.inject(
          _contradictoryEqualRevisionProgress(fixture.controller.current),
        );
        fixture.evidence.inject(
          _oldSessionEvidence(fixture.controller.current),
        );
        await Future<void>.delayed(Duration.zero);

        expect(fixture.journey.operation?.operationId, bound.operationId);
        expect(fixture.journey, isA<OnboardingBuildingLocalData>());
        graph.hold!.complete();
        await command;
      },
    );

    test('illegal stage/substage evidence cannot advance Journey', () async {
      final graph = _ReplayGraphController(hold: Completer<void>());
      final fixture = await _JourneyFixture.create(graph: graph);
      addTearDown(fixture.dispose);
      final command = fixture.coordinator.startVirginImportAndGraphBuild(
        actionContext: fixture.journey.actionContext,
      );
      await graph.started.future;
      await _drainMicrotasks();

      fixture.evidence.inject(
        _illegalVerificationSubstage(fixture.controller.current),
      );
      await _drainMicrotasks();

      expect(fixture.journey, isA<OnboardingBuildingLocalData>());
      expect(
        fixture.journey.operation?.stage,
        OnboardingOperationStage.messageDataBuild,
      );
      graph.hold!.complete();
      await command;
    });

    test(
      'legacy equal-revision terminal evidence is accepted only once',
      () async {
        final running = OnboardingOperationSnapshot.running(
          operationId: OnboardingOperationId(
            '123e4567-e89b-42d3-a456-426614174020',
          ),
          processSessionId: OnboardingProcessSessionId(
            '123e4567-e89b-42d3-a456-426614174099',
          ),
          kind: OnboardingOperationKind.initialImport,
          stage: OnboardingOperationStage.messageDataBuild,
          observedAtUtc: DateTime.utc(2026, 9, 24, 11),
        );
        final fixture = await _JourneyFixture.create(persisted: running);
        addTearDown(fixture.dispose);

        final failed = _legacyEqualRevisionFailure(running, 'legacy failure');
        fixture.evidence.inject(failed);
        await _drainMicrotasks();
        final accepted = fixture.journey as OnboardingOperationFailed;
        expect(accepted.summary, contains('legacy failure'));

        fixture.evidence.inject(
          _legacyEqualRevisionFailure(running, 'contradictory replacement'),
        );
        await _drainMicrotasks();
        expect(fixture.journey, same(accepted));
      },
    );

    test(
      'operation A evidence and Retry callback cannot alter operation B',
      () async {
        final graph = _ReplayGraphController(failuresBeforeSuccess: 1);
        final fixture = await _JourneyFixture.create(graph: graph);
        addTearDown(fixture.dispose);

        await fixture.coordinator.startVirginImportAndGraphBuild(
          actionContext: fixture.journey.actionContext,
        );
        final failedA = fixture.journey as OnboardingOperationFailed;
        final actionA = failedA.actionContext;
        final evidenceA = fixture.controller.current;

        await fixture.coordinator.retryFailedOperation(actionContext: actionA);
        final terminalB = fixture.journey as OnboardingReadyToStart;
        final operationB = terminalB.operation.operationId;
        expect(operationB, isNot(evidenceA.operationId));

        fixture.evidence.inject(evidenceA);
        fixture.evidence.inject(_replayedInterruption(evidenceA));
        await fixture.coordinator.retryFailedOperation(actionContext: actionA);
        await _drainMicrotasks();

        expect(fixture.journey, same(terminalB));
        expect(fixture.journey.operation?.operationId, operationB);
        expect(graph.runCount, 2);
      },
    );
  });
}

void _expectPrimaryGraphFailure(_JourneyFixture fixture) {
  final journey = fixture.journey;
  expect(journey, isA<OnboardingOperationFailed>());
  expect(
    (journey as OnboardingOperationFailed).summary,
    contains('synthetic graph failure'),
  );
}

final class _ControllerAccessGate {
  Completer<void>? _requested;
  Completer<void>? _release;

  Future<void> get requested => _requested?.future ?? Future<void>.value();

  void holdNext() {
    if (_release != null) {
      throw StateError('Controller acquisition is already held.');
    }
    _requested = Completer<void>();
    _release = Completer<void>();
  }

  Future<OnboardingOperationSnapshotController> read(
    OnboardingOperationSnapshotController controller,
  ) async {
    final requested = _requested;
    final release = _release;
    if (requested == null || release == null) {
      return controller;
    }
    if (!requested.isCompleted) {
      requested.complete();
    }
    await release.future;
    _requested = null;
    _release = null;
    return controller;
  }

  void release() {
    final release = _release;
    if (release == null || release.isCompleted) {
      throw StateError('Controller acquisition is not held.');
    }
    release.complete();
  }
}

final class _JourneyFixture {
  _JourneyFixture._({
    required this.container,
    required this.reports,
    required this.globalEnvironmentReports,
    required this.globalEnvironmentSubscription,
    required this.controller,
    required this.controllerAccess,
    required this.evidence,
    required this.processSessionId,
    required this.authorityHolds,
  });

  final ProviderContainer container;
  final _MutableReportSource reports;
  final _GlobalEnvironmentReportRecorder globalEnvironmentReports;
  final ProviderSubscription<AsyncValue<OnboardingEnvironmentReport>>
  globalEnvironmentSubscription;
  final OnboardingOperationSnapshotController controller;
  final _ControllerAccessGate controllerAccess;
  final _EvidenceHub evidence;
  final OnboardingProcessSessionId processSessionId;
  final List<_ExclusiveAuthorityHold> authorityHolds;

  OnboardingJourneyCoordinator get coordinator =>
      container.read(onboardingJourneyCoordinatorProvider.notifier);
  OnboardingJourneyState get journey =>
      container.read(onboardingJourneyCoordinatorProvider);
  OnboardingOperationId get firstOperationId =>
      OnboardingOperationId('123e4567-e89b-42d3-a456-426614174010');

  static Future<_JourneyFixture> create({
    OnboardingEnvironmentReport? report,
    OnboardingEnvironmentReport Function(int readCount)? reportResolver,
    OnboardingOperationSnapshot? persisted,
    _ReplayGraphController? graph,
    _ReplayVerifier? verifier,
    bool failTerminalSnapshotWrites = false,
    bool failCompletionSnapshotWrites = false,
    int beginSnapshotFailuresBeforeSuccess = 0,
    void Function()? onFailedSnapshotSave,
    OnboardingFailureStore? failureStore,
    MessageDataResetService? resetService,
    AppLogger? appLogger,
    void Function(int readCount)? onReportRead,
    bool throwOnReportRefresh = false,
    bool holdControllerInitially = false,
    Completer<void>? resettingProgressSaveStarted,
    Completer<void>? releaseResettingProgressSave,
    bool holdArchiveAuthorityInitially = false,
    bool useRealGlobalEnvironmentFeedback = false,
  }) async {
    final reports = _MutableReportSource(
      report ??
          _report(
            state: OnboardingEnvironmentState.readyToImport,
            blockerKind: OnboardingBlockerKind.none,
          ),
      resolver: reportResolver,
      onRead: onReportRead,
      throwAfterFirstRead: throwOnReportRefresh,
    );
    final store = _MemorySnapshotStore(
      failTerminalWrites: failTerminalSnapshotWrites,
      failCompletionWrites: failCompletionSnapshotWrites,
      beginFailuresBeforeSuccess: beginSnapshotFailuresBeforeSuccess,
      onFailedSave: onFailedSnapshotSave,
      resettingProgressSaveStarted: resettingProgressSaveStarted,
      releaseResettingProgressSave: releaseResettingProgressSave,
    )..snapshot = persisted;
    final session = OnboardingProcessSessionId(
      '123e4567-e89b-42d3-a456-426614174099',
    );
    var nextId = 10;
    final controller = OnboardingOperationSnapshotController(
      store: store,
      processSessionId: session,
      now: () => DateTime.utc(2026, 9, 24, 12, 0, nextId),
      newOperationId: () {
        final suffix = nextId.toString().padLeft(3, '0');
        nextId += 1;
        return '123e4567-e89b-42d3-a456-426614174$suffix';
      },
    );
    await controller.initialize();
    final controllerAccess = _ControllerAccessGate();
    if (holdControllerInitially) {
      controllerAccess.holdNext();
    }
    final evidence = _EvidenceHub(controller);
    final archiveAuthority = ArchiveAccessAuthority(
      identity: ResolvedArchiveIdentity(
        environment: ArchiveEnvironment.test,
        buildIdentity: ArchiveBuildIdentity.testHarness,
        archiveInstanceId: ArchiveInstanceId(
          'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        ),
        canonicalRootPath: '/test/onboarding-archive',
        bundleIdentifier: 'com.bigbenchsoftware.MessageLens.tests',
        productName: 'MessageLens Tests',
      ),
    );
    final probeReader = _ReportBackedProbeReader(reports);
    final container = ProviderContainer(
      overrides: <Override>[
        if (!useRealGlobalEnvironmentFeedback)
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => reports.read(),
          ),
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          archiveAuthority,
        ),
        onboardingFullDiskAccessProvider.overrideWith(
          (ref) => reports.current.hasFullDiskAccess,
        ),
        onboardingMessagesDatabasePathProvider.overrideWith(
          (ref) => _ReportBackedProbeReader.messagesPath,
        ),
        onboardingDatabaseDirectoryPathProvider.overrideWith(
          (ref) => _ReportBackedProbeReader.archiveRootPath,
        ),
        onboardingDatabaseProbeReaderProvider.overrideWithValue(probeReader),
        futureGetFolderAggregateProvider.overrideWith((ref) async {
          if (reports.current.blockerKind ==
              OnboardingBlockerKind.addressBookUnavailable) {
            return left(
              const FolderRetrievalFailure(message: 'Contacts unavailable'),
            );
          }
          return right(_testAddressBookAggregate());
        }),
        attachmentArchiveLocationProvider.overrideWith(
          () => _TestAttachmentArchiveLocation(),
        ),
        attachmentArchiveSettingsStoreProvider.overrideWith(
          (ref) async => _TestAttachmentArchiveSettingsStore(),
        ),
        onboardingOperationControllerProvider.overrideWith(
          (ref) => controllerAccess.read(controller),
        ),
        onboardingOperationSnapshotProvider.overrideWith(
          (ref) => evidence.stream,
        ),
        conversationGraphBuildControllerProvider.overrideWith(
          () => graph ?? _ReplayGraphController(),
        ),
        chatDbChangeMonitorProvider.overrideWith(_TestChatDbChangeMonitor.new),
        onboardingDurableCompletionVerifierProvider.overrideWithValue(
          verifier ?? _ReplayVerifier(),
        ),
        onboardingFailureStorageProvider.overrideWithValue(
          failureStore ?? _MemoryFailureStore(),
        ),
        if (appLogger != null) appLoggerProvider.overrideWith(() => appLogger),
        if (resetService != null)
          messageDataResetServiceProvider.overrideWithValue(resetService),
      ],
    );
    final globalEnvironmentReports = _GlobalEnvironmentReportRecorder();
    final globalEnvironmentSubscription = container.listen(
      onboardingEnvironmentReportProvider,
      (_, next) => globalEnvironmentReports.record(next),
      fireImmediately: true,
    );
    final authorityHolds = <_ExclusiveAuthorityHold>[];
    if (holdArchiveAuthorityInitially) {
      authorityHolds.add(await _ExclusiveAuthorityHold.acquire(container));
    }
    container.read(onboardingJourneyCoordinatorProvider);
    await container.read(onboardingEnvironmentReportProvider.future);
    await container.read(onboardingOperationSnapshotProvider.future);
    await Future<void>.delayed(Duration.zero);
    return _JourneyFixture._(
      container: container,
      reports: reports,
      globalEnvironmentReports: globalEnvironmentReports,
      globalEnvironmentSubscription: globalEnvironmentSubscription,
      controller: controller,
      controllerAccess: controllerAccess,
      evidence: evidence,
      processSessionId: session,
      authorityHolds: authorityHolds,
    );
  }

  Future<void> refreshReport() async {
    container.invalidate(onboardingFullDiskAccessProvider);
    container.invalidate(futureGetFolderAggregateProvider);
    container.invalidate(onboardingEnvironmentReportProvider);
    await container.read(onboardingEnvironmentReportProvider.future);
    await Future<void>.delayed(Duration.zero);
  }

  void holdNextControllerAcquisition() {
    controllerAccess.holdNext();
    container.invalidate(onboardingOperationControllerProvider);
  }

  Future<_ExclusiveAuthorityHold> holdArchiveAuthority() async {
    final hold = await _ExclusiveAuthorityHold.acquire(container);
    authorityHolds.add(hold);
    return hold;
  }

  Future<void> dispose() async {
    for (final hold in authorityHolds.reversed) {
      await hold.release();
    }
    globalEnvironmentSubscription.close();
    container.dispose();
    await evidence.dispose();
    await controller.dispose();
  }
}

final class _GlobalEnvironmentReportRecorder {
  final List<OnboardingEnvironmentReport> reports =
      <OnboardingEnvironmentReport>[];
  final Map<
    OnboardingEnvironmentState,
    List<Completer<OnboardingEnvironmentReport>>
  >
  _waiters =
      <
        OnboardingEnvironmentState,
        List<Completer<OnboardingEnvironmentReport>>
      >{};

  void record(AsyncValue<OnboardingEnvironmentReport> next) {
    final report = next.valueOrNull;
    if (report == null) {
      return;
    }
    reports.add(report);
    final waiters = _waiters.remove(report.state);
    if (waiters == null) {
      return;
    }
    for (final waiter in waiters) {
      if (!waiter.isCompleted) {
        waiter.complete(report);
      }
    }
  }

  Future<OnboardingEnvironmentReport> waitFor(
    OnboardingEnvironmentState state,
  ) {
    for (final report in reports.reversed) {
      if (report.state == state) {
        return Future<OnboardingEnvironmentReport>.value(report);
      }
    }
    final waiter = Completer<OnboardingEnvironmentReport>();
    _waiters
        .putIfAbsent(state, () => <Completer<OnboardingEnvironmentReport>>[])
        .add(waiter);
    return waiter.future;
  }
}

final class _ThrowingBuildAppLogger extends AppLogger {
  _ThrowingBuildAppLogger(this.onBuild);

  final void Function() onBuild;

  @override
  List<LogEntry> build() {
    onBuild();
    throw StateError('synthetic logger acquisition failure');
  }
}

final class _ThrowingWriteAppLogger extends AppLogger {
  _ThrowingWriteAppLogger(this.onError);

  final void Function() onError;

  @override
  List<LogEntry> build() => <LogEntry>[];

  @override
  void error(String message, {String? source, Map<String, dynamic>? context}) {
    onError();
    throw StateError('synthetic logger write failure');
  }
}

final class _EvidenceHub {
  _EvidenceHub(this._operationController) {
    final controller = _operationController;
    _subscription = controller.changes.listen(_controller.add);
  }

  final OnboardingOperationSnapshotController _operationController;
  final StreamController<OnboardingOperationSnapshot> _controller =
      StreamController<OnboardingOperationSnapshot>.broadcast(sync: true);
  late final StreamSubscription<OnboardingOperationSnapshot> _subscription;

  Stream<OnboardingOperationSnapshot> get stream async* {
    yield _operationController.current;
    yield* _controller.stream;
  }

  void inject(OnboardingOperationSnapshot snapshot) {
    _controller.add(snapshot);
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
  }
}

final class _ExclusiveAuthorityHold {
  _ExclusiveAuthorityHold._({required this.releaseSignal, required this.run});

  final Completer<void> releaseSignal;
  final Future<void> run;
  bool _released = false;

  static Future<_ExclusiveAuthorityHold> acquire(
    ProviderContainer container,
  ) async {
    final acquired = Completer<void>();
    final release = Completer<void>();
    final run = container
        .read(exclusiveAuthorityRegistryProvider.notifier)
        .runExclusive<void>(
          authority: ExclusiveAuthorityKey.archiveMutation,
          ownerLabel: 'test-external-archive-owner',
          action: (_) async {
            acquired.complete();
            await release.future;
          },
        );
    await acquired.future;
    return _ExclusiveAuthorityHold._(releaseSignal: release, run: run);
  }

  Future<void> release() async {
    if (_released) {
      return;
    }
    _released = true;
    releaseSignal.complete();
    await run;
  }
}

final class _ReportBackedProbeReader implements OnboardingDatabaseProbeReader {
  _ReportBackedProbeReader(this.reports);

  static const String archiveRootPath = '/test/onboarding-archive';
  static const String messagesPath = '/test/messages.db';
  static const String addressBookPath = '/test/AddressBook-v22.abcddb';

  final _MutableReportSource reports;

  String get _importPath => appDatabasePath(
    AppDatabaseFile.sourceScopedImport,
    databaseDirectory: archiveRootPath,
  );

  String get _graphPath => appDatabasePath(
    AppDatabaseFile.conversationGraph,
    databaseDirectory: archiveRootPath,
  );

  @override
  OnboardingDatabaseProbe probeFile(String filePath, {int? rowCount}) {
    final report = reports.current;
    if (filePath == messagesPath) {
      final missing =
          report.blockerKind == OnboardingBlockerKind.messagesDatabaseMissing;
      return OnboardingDatabaseProbe(
        path: filePath,
        exists: !missing,
        readable: !missing && report.hasFullDiskAccess,
        rowCount: rowCount,
      );
    }
    return OnboardingDatabaseProbe(
      path: filePath,
      exists: true,
      readable: true,
      rowCount: rowCount,
    );
  }

  @override
  OnboardingDatabaseProbe probeDirectory(String directoryPath) {
    return OnboardingDatabaseProbe(
      path: directoryPath,
      exists: true,
      readable: true,
    );
  }

  @override
  int? readTableCount({
    required String dbPath,
    required String tableName,
    bool queryOnly = false,
  }) {
    final report = reports.current;
    if (dbPath == messagesPath) {
      if (tableName == 'attachment') {
        return 0;
      }
      return report.state == OnboardingEnvironmentState.sourceSparseOrUnsynced
          ? 0
          : 100;
    }
    if (dbPath == _importPath) {
      if (report.state == OnboardingEnvironmentState.ready ||
          report.shouldResetAppDatabasesBeforeImport) {
        return 100;
      }
      return 0;
    }
    if (dbPath == _graphPath) {
      if (report.state == OnboardingEnvironmentState.ready) {
        return 100;
      }
      if (report.shouldResetAppDatabasesBeforeImport) {
        return 1;
      }
      return 0;
    }
    return null;
  }

  @override
  ConversationGraphReadiness readConversationGraphReadiness(String dbPath) {
    final ready = reports.current.state == OnboardingEnvironmentState.ready;
    return ConversationGraphReadiness(
      isReady: ready,
      reason: ready ? 'ready' : 'test graph is not ready',
      messageCount: ready ? 100 : 0,
      chatCount: ready ? 1 : 0,
      chatToMessageEdgeCount: ready ? 1 : 0,
    );
  }
}

final class _TestAttachmentArchiveLocation extends AttachmentArchiveLocation {
  @override
  Future<AttachmentArchiveLocationState> build() async {
    return AttachmentArchiveLocationState.defaultAvailable(
      archiveRootPath:
          '${_ReportBackedProbeReader.archiveRootPath}/attachment_archive',
    );
  }
}

final class _TestAttachmentArchiveSettingsStore
    implements AttachmentArchiveSettingsStore {
  @override
  Future<void> clearArchivedAttachmentRecords() async {}

  @override
  Future<String?> readSetting(String key) async => null;

  @override
  Future<void> writeSetting({
    required String key,
    required String value,
  }) async {}
}

final class _TestChatDbChangeMonitor extends ChatDbChangeMonitor {
  @override
  ChatDbChangeMonitorState build() {
    return const ChatDbChangeMonitorState(lastMaxRowId: 100);
  }
}

final class _ReplayResetService implements MessageDataResetService {
  int callCount = 0;
  final Completer<void> _called = Completer<void>();

  Future<void> get called => _called.future;

  @override
  Future<void> resetDerivedData() async {
    callCount += 1;
    if (!_called.isCompleted) {
      _called.complete();
    }
  }

  @override
  Future<void> resetDerivedDataForStartFresh(
    ArchiveMutationCapability capability,
  ) async {
    throw UnsupportedError('Start Fresh is outside this replay fixture.');
  }

  @override
  Future<void> resetActiveDerivedDataForLocalDataRepair(
    ArchiveMutationCapability capability,
  ) async {
    throw UnsupportedError('Local Data Repair is outside this replay fixture.');
  }
}

final class _ReplayGraphController extends ConversationGraphBuildController {
  _ReplayGraphController({this.failuresBeforeSuccess = 0, this.hold});

  int failuresBeforeSuccess;
  final Completer<void>? hold;
  final Completer<void> started = Completer<void>();
  int runCount = 0;

  @override
  ConversationGraphBuildState build() =>
      const ConversationGraphBuildState.idle();

  @override
  Future<ConversationGraphBuildReport> runOnce({
    String owner = 'test',
    ConversationGraphBuildObserver? onObservation,
  }) async {
    runCount += 1;
    if (!started.isCompleted) {
      started.complete();
    }
    onObservation?.call(
      const ConversationGraphBuildObservation(
        suboperation: ConversationGraphBuildSuboperation.importMessages,
        kind: ConversationGraphBuildObservationKind.progress,
        completedWorkCount: 5,
        totalWorkCount: 10,
      ),
    );
    if (hold != null) {
      await hold!.future;
    }
    if (failuresBeforeSuccess > 0) {
      failuresBeforeSuccess -= 1;
      throw StateError('synthetic graph failure');
    }
    final observedAt = DateTime.utc(2026, 9, 24, 12);
    return ConversationGraphBuildReport(
      startedAt: observedAt,
      finishedAt: observedAt.add(const Duration(seconds: 1)),
      completedStageNames: const <String>[],
      stageTimings: const <ConversationGraphBuildStageTiming>[],
      messageImportResult: const MessageImportResult(
        startedAfterSourceRowId: 0,
        insertedMessageCount: 10,
        lastImportedSourceRowId: 10,
      ),
      richTextEnrichmentResult: const MessageRichTextEnrichmentResult(
        candidateMessageCount: 0,
        enrichedMessageCount: 0,
        missingExtractionCount: 0,
        extractorAvailable: true,
      ),
      messageProjectionResult: const MessageProjectionResult(
        examinedMessageCount: 10,
        insertedMessageCount: 10,
      ),
    );
  }
}

final class _ReplayVerifier implements OnboardingDurableCompletionVerifier {
  _ReplayVerifier({this.failuresBeforeSuccess = 0});

  int failuresBeforeSuccess;

  @override
  Future<OnboardingInstallationReadyProof> verifyInstallationReady() async {
    if (failuresBeforeSuccess > 0) {
      failuresBeforeSuccess -= 1;
      throw StateError('synthetic verification failure');
    }
    return OnboardingInstallationReadyProof(
      verifiedAtUtc: DateTime.utc(2026, 9, 24, 12, 1),
      sourceScopedImportRows: 10,
      conversationGraphRows: 10,
    );
  }
}

final class _MemorySnapshotStore implements OnboardingOperationSnapshotStore {
  _MemorySnapshotStore({
    this.failTerminalWrites = false,
    this.failCompletionWrites = false,
    this.beginFailuresBeforeSuccess = 0,
    this.onFailedSave,
    this.resettingProgressSaveStarted,
    this.releaseResettingProgressSave,
  });

  final bool failTerminalWrites;
  final bool failCompletionWrites;
  int beginFailuresBeforeSuccess;
  final void Function()? onFailedSave;
  final Completer<void>? resettingProgressSaveStarted;
  final Completer<void>? releaseResettingProgressSave;
  OnboardingOperationSnapshot? snapshot;

  @override
  Future<OnboardingOperationSnapshot?> load() async => snapshot;

  @override
  Future<void> save(OnboardingOperationSnapshot snapshot) async {
    if (snapshot.status == OnboardingOperationStatus.running &&
        snapshot.currentSubstage ==
            OnboardingOperationSubstage.resettingDerivedData) {
      final started = resettingProgressSaveStarted;
      if (started != null && !started.isCompleted) {
        started.complete();
      }
      final release = releaseResettingProgressSave;
      if (release != null) {
        await release.future;
      }
    }
    if (beginFailuresBeforeSuccess > 0 &&
        snapshot.status == OnboardingOperationStatus.running) {
      beginFailuresBeforeSuccess -= 1;
      throw StateError('synthetic snapshot begin persistence failure');
    }
    if (failTerminalWrites &&
        snapshot.status == OnboardingOperationStatus.failed) {
      onFailedSave?.call();
      throw StateError('synthetic snapshot failure persistence failure');
    }
    if (snapshot.status == OnboardingOperationStatus.failed) {
      onFailedSave?.call();
    }
    if (failCompletionWrites &&
        snapshot.status == OnboardingOperationStatus.completed) {
      throw StateError('synthetic snapshot completion persistence failure');
    }
    this.snapshot = snapshot;
  }
}

final class _MemoryFailureStore implements OnboardingFailureStore {
  _MemoryFailureStore({this.throwOnWrites = false, this.onWrite});

  final bool throwOnWrites;
  final void Function()? onWrite;

  @override
  Future<void> clearGraphProjectionFailure() async {}
  @override
  Future<void> clearSourceImportFailure() async {}
  @override
  Future<OnboardingPipelineFailure?> loadGraphProjectionFailure() async => null;
  @override
  Future<PersistedOnboardingGraphProjectionFailure?>
  loadGraphProjectionFailureEntry({
    void Function()? requirePersistentArchiveStoreAdmission,
  }) async {
    requirePersistentArchiveStoreAdmission?.call();
    return null;
  }

  @override
  Future<OnboardingPipelineFailure?> loadSourceImportFailure() async => null;
  @override
  Future<PersistedOnboardingSourceImportFailure?> loadSourceImportFailureEntry({
    void Function()? requirePersistentArchiveStoreAdmission,
  }) async {
    requirePersistentArchiveStoreAdmission?.call();
    return null;
  }

  @override
  Future<void> saveGraphProjectionFailure({
    required String message,
    int batchId = 0,
    DateTime? recordedAt,
  }) async {
    onWrite?.call();
    if (throwOnWrites) {
      throw StateError('synthetic diagnostic failure persistence failure');
    }
  }

  @override
  Future<void> saveImportFailure({
    required String message,
    int batchId = 0,
    DateTime? recordedAt,
    List<String> warnings = const <String>[],
  }) async {
    onWrite?.call();
    if (throwOnWrites) {
      throw StateError('synthetic diagnostic failure persistence failure');
    }
  }
}

final class _MutableReportSource {
  _MutableReportSource(
    this.current, {
    this.resolver,
    this.onRead,
    this.throwAfterFirstRead = false,
  });

  OnboardingEnvironmentReport current;
  final OnboardingEnvironmentReport Function(int readCount)? resolver;
  final void Function(int readCount)? onRead;
  final bool throwAfterFirstRead;
  int readCount = 0;

  OnboardingEnvironmentReport read() {
    readCount += 1;
    onRead?.call(readCount);
    if (throwAfterFirstRead && readCount > 1) {
      throw StateError('synthetic environment refresh failure');
    }
    current = resolver?.call(readCount) ?? current;
    return current;
  }
}

OnboardingOperationSnapshot _interruptedSnapshot() {
  final observedAt = DateTime.utc(2026, 9, 23, 12);
  return OnboardingOperationSnapshot.running(
        operationId: OnboardingOperationId(
          '123e4567-e89b-42d3-a456-426614174000',
        ),
        processSessionId: OnboardingProcessSessionId(
          '123e4567-e89b-42d3-a456-426614174001',
        ),
        kind: OnboardingOperationKind.initialImport,
        stage: OnboardingOperationStage.messageDataBuild,
        observedAtUtc: observedAt,
      )
      .observeProgress(
        observedAtUtc: observedAt.add(const Duration(seconds: 1)),
        substage: OnboardingOperationSubstage.importingMessages,
        progress: const OnboardingOperationProgress(
          completedWorkUnits: 5,
          totalWorkUnits: 10,
        ),
      )
      .interrupt(observedAtUtc: observedAt.add(const Duration(seconds: 2)));
}

OnboardingOperationSnapshot _completedSnapshot() {
  return _interruptedSnapshot().complete(
    verifiedAtUtc: DateTime.utc(2026, 9, 23, 12, 2),
  );
}

OnboardingOperationSnapshot _manualInspectionFailureSnapshot() {
  return _interruptedSnapshot().fail(
    failure: OnboardingOperationFailure(
      category: OnboardingOperationFailureCategory.durableStateInconsistent,
      occurredAtUtc: DateTime.utc(2026, 9, 24, 12),
      summary: 'manual inspection required',
      recoveryDisposition:
          OnboardingOperationRecoveryDisposition.manualInspectionRequired,
    ),
  );
}

OnboardingOperationSnapshot _interruptedSnapshotWithoutSubstage() {
  final observedAt = DateTime.utc(2026, 9, 23, 12);
  return OnboardingOperationSnapshot.running(
    operationId: OnboardingOperationId('123e4567-e89b-42d3-a456-426614174000'),
    processSessionId: OnboardingProcessSessionId(
      '123e4567-e89b-42d3-a456-426614174001',
    ),
    kind: OnboardingOperationKind.initialImport,
    stage: OnboardingOperationStage.messageDataBuild,
    observedAtUtc: observedAt,
  ).interrupt(observedAtUtc: observedAt.add(const Duration(seconds: 1)));
}

OnboardingOperationSnapshot _interruptedAutomaticRecoverySnapshot() {
  final observedAt = DateTime.utc(2026, 9, 23, 12);
  return OnboardingOperationSnapshot.running(
        operationId: OnboardingOperationId(
          '123e4567-e89b-42d3-a456-426614174000',
        ),
        processSessionId: OnboardingProcessSessionId(
          '123e4567-e89b-42d3-a456-426614174001',
        ),
        kind: OnboardingOperationKind.automaticRecovery,
        stage: OnboardingOperationStage.automaticRecoveryReset,
        observedAtUtc: observedAt,
      )
      .observeProgress(
        observedAtUtc: observedAt.add(const Duration(seconds: 1)),
        substage: OnboardingOperationSubstage.resettingDerivedData,
      )
      .interrupt(observedAtUtc: observedAt.add(const Duration(seconds: 2)));
}

OnboardingOperationSnapshot _contradictoryEqualRevisionProgress(
  OnboardingOperationSnapshot current,
) {
  final currentProgress = current.progress;
  final replacementProgress = OnboardingOperationProgress(
    completedWorkUnits: currentProgress == null
        ? 0
        : currentProgress.completedWorkUnits > 0
        ? currentProgress.completedWorkUnits - 1
        : 0,
    totalWorkUnits: currentProgress?.totalWorkUnits ?? 1,
  );
  final json = Map<String, Object?>.from(current.toJson())
    ..['progress'] = replacementProgress.toJson();
  return OnboardingOperationSnapshot.fromJson(json);
}

OnboardingOperationSnapshot _legacyEqualRevisionFailure(
  OnboardingOperationSnapshot current,
  String summary,
) {
  final occurredAt = DateTime.utc(2026, 9, 24, 12, 2);
  final json = Map<String, Object?>.from(current.toJson())
    ..['status'] = OnboardingOperationStatus.failed.name
    ..['failure'] = OnboardingOperationFailure(
      category: OnboardingOperationFailureCategory.unexpected,
      occurredAtUtc: occurredAt,
      summary: summary,
      recoveryDisposition:
          OnboardingOperationRecoveryDisposition.retryFromSafeBoundary,
    ).toJson()
    ..['finished_at_utc'] = occurredAt.toIso8601String();
  return OnboardingOperationSnapshot.fromJson(json);
}

OnboardingOperationSnapshot _replayedFailure(
  OnboardingOperationSnapshot snapshot,
) {
  final occurredAt = DateTime.utc(2026, 9, 24, 12, 30);
  final json = Map<String, Object?>.from(snapshot.toJson())
    ..['status'] = OnboardingOperationStatus.failed.name
    ..['failure'] = OnboardingOperationFailure(
      category: OnboardingOperationFailureCategory.unexpected,
      occurredAtUtc: occurredAt,
      summary: 'delayed operation A failure',
      recoveryDisposition:
          OnboardingOperationRecoveryDisposition.retryFromSafeBoundary,
    ).toJson()
    ..['finished_at_utc'] = occurredAt.toIso8601String();
  return OnboardingOperationSnapshot.fromJson(json);
}

OnboardingOperationSnapshot _replayedInterruption(
  OnboardingOperationSnapshot snapshot,
) {
  final json = Map<String, Object?>.from(snapshot.toJson())
    ..['status'] = OnboardingOperationStatus.interrupted.name
    ..['failure'] = null
    ..['finished_at_utc'] = null;
  return OnboardingOperationSnapshot.fromJson(json);
}

OnboardingOperationSnapshot _oldSessionEvidence(
  OnboardingOperationSnapshot current,
) {
  final json = Map<String, Object?>.from(current.toJson())
    ..['process_session_id'] = '123e4567-e89b-42d3-a456-426614174088'
    ..['progress_revision'] = current.progressRevision + 1;
  return OnboardingOperationSnapshot.fromJson(json);
}

OnboardingOperationSnapshot _illegalVerificationSubstage(
  OnboardingOperationSnapshot current,
) {
  final json = Map<String, Object?>.from(current.toJson())
    ..['current_stage'] =
        OnboardingOperationStage.durableReadinessVerification.name
    ..['current_substage'] =
        OnboardingOperationSubstage.resettingDerivedData.name
    ..['progress_revision'] = current.progressRevision + 1;
  return OnboardingOperationSnapshot.fromJson(json);
}

Future<void> _drainMicrotasks() async {
  for (var index = 0; index < 10; index += 1) {
    await Future<void>.delayed(Duration.zero);
  }
}

OnboardingEnvironmentReport _report({
  required OnboardingEnvironmentState state,
  required OnboardingBlockerKind blockerKind,
  bool hasFullDiskAccess = true,
  bool shouldReset = false,
}) {
  return OnboardingEnvironmentReport(
    state: state,
    blockerKind: blockerKind,
    syncPlausibility: OnboardingSyncPlausibility.unknown,
    messagesDatabase: const OnboardingDatabaseProbe(
      path: 'messages.db',
      exists: true,
      readable: true,
      rowCount: 100,
    ),
    addressBookDatabase: const OnboardingDatabaseProbe(
      path: 'addressbook.db',
      exists: true,
      readable: true,
      rowCount: 10,
    ),
    overlayDatabase: OnboardingDatabaseProbe(
      path: appDatabaseFileName(AppDatabaseFile.overlay),
      exists: true,
      readable: true,
    ),
    sourceScopedImportDatabase: OnboardingDatabaseProbe(
      path: appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
      exists: true,
      readable: true,
      rowCount: state == OnboardingEnvironmentState.ready ? 100 : 0,
    ),
    conversationGraph: OnboardingDatabaseProbe(
      path: appDatabaseFileName(AppDatabaseFile.conversationGraph),
      exists: true,
      readable: true,
      rowCount: state == OnboardingEnvironmentState.ready ? 100 : 0,
    ),
    attachmentArchiveDirectory: const OnboardingDatabaseProbe(
      path: 'attachment_archive',
      exists: true,
      readable: true,
    ),
    hasFullDiskAccess: hasFullDiskAccess,
    shouldResetAppDatabasesBeforeImport: shouldReset,
    resetAppDatabasesReason: shouldReset
        ? 'Synthetic incomplete derived data.'
        : null,
  );
}

AddressBookFolderAggregate _testAddressBookAggregate() {
  return AddressBookFolderAggregate([
    AddressBookFolderEntity(
      path: FolderPathValueObject(_ReportBackedProbeReader.addressBookPath),
      shortPath: AddressBookFolderShortPath('TEST-SOURCE'),
      lastCreationDate: FolderCreationDate(DateTime.utc(2026, 9, 24)),
      lastModificationDate: FolderModificationDate(DateTime.utc(2026, 9, 24)),
      recordCount: NonZeroInt(10),
    ),
  ]);
}
