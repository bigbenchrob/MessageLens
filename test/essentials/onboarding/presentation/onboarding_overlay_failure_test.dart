import 'package:flutter/material.dart' show Scaffold, ScaffoldMessenger;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/logging/application/diagnostic_report_exporter.dart';
import 'package:remember_this_text/essentials/logging/domain/diagnostic_report_presentation_result.dart';
import 'package:remember_this_text/essentials/logging/feature_level_providers.dart'
    show diagnosticReportExporterProvider;
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_journey_operation_projection.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_journey_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/onboarding_overlay.dart';

const _failureTitle = "MessageLens couldn't finish setup";
const _failureBody =
    "MessageLens couldn't finish preparing your browsing data. "
    'You can try again.';
const _technicalImportError =
    'SQLiteException(1): no such table: message_import_ledger';
const _technicalGraphError =
    'StateError: graph publication failed at /Users/example/graph.db';

void main() {
  testWidgets(
    'process-local preparation failure reuses calm retry and support surface',
    (tester) async {
      final gate = _FailureSurfaceGate(
        status: OnboardingStatus.preparationFailed,
      );
      final exporter = _RecordingDiagnosticReportExporter();

      await _pumpFailureOverlay(
        tester,
        gate: gate,
        exporter: exporter,
        journey: const OnboardingOperationFailed(
          occurrence: 1,
          summary: 'Verified archive checkpoint required for messageDataReset',
          compatibilityStatus: OnboardingStatus.preparationFailed,
          failureAction: OnboardingJourneyFailureAction.retryInitialImport,
        ),
        report: _failureReport(
          state: OnboardingEnvironmentState.readyToImport,
          blockerKind: OnboardingBlockerKind.none,
        ),
      );

      _expectSharedPrimaryFailureCopy();
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Send Report To Developer'), findsOneWidget);
      expect(find.text('Environment summary'), findsNothing);
      expect(find.text('What to check'), findsNothing);
      expect(find.textContaining('reset'), findsNothing);
      expect(find.textContaining('graph projection'), findsNothing);
      expect(find.textContaining('import ledger'), findsNothing);
      expect(find.textContaining('previous launch'), findsNothing);

      await tester.tap(find.text('Send Report To Developer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(exporter.requests, hasLength(1));
      expect(
        exporter.requests.single.headerLines,
        contains(
          'Operation failure: Verified archive checkpoint required for messageDataReset',
        ),
      );

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(gate.retryFailedOperationCallCount, 1);
    },
  );

  testWidgets(
    'import failure uses phase-neutral primary copy and still retries',
    (tester) async {
      final gate = _FailureSurfaceGate();

      await _pumpFailureOverlay(
        tester,
        gate: gate,
        journey: const OnboardingOperationFailed(
          occurrence: 1,
          summary: _technicalImportError,
          compatibilityStatus: OnboardingStatus.awaitingUserAction,
          failureAction: OnboardingJourneyFailureAction.retryInitialImport,
        ),
        report: _failureReport(
          state: OnboardingEnvironmentState.importFailed,
          blockerKind: OnboardingBlockerKind.importFailed,
          importRowCount: 0,
          importFailure: const OnboardingPipelineFailure(
            phase: OnboardingPipelinePhase.import,
            message: _technicalImportError,
          ),
        ),
      );

      _expectSharedPrimaryFailureCopy();
      expect(find.text('Import Attempt Failed'), findsNothing);
      expect(
        find.textContaining('last import attempt did not finish successfully'),
        findsNothing,
      );
      _expectEnvironmentSummaryAbsent();
      expect(find.text('What to check'), findsNothing);
      expect(find.text(_technicalImportError), findsNothing);
      expect(find.textContaining('previous launch'), findsNothing);
      expect(find.textContaining('clean import pass'), findsNothing);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Send Report To Developer'), findsOneWidget);
      _expectSupportTransportCaptionAbsent();

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(gate.retryFailedOperationCallCount, 1);
    },
  );

  testWidgets('manual-inspection failure does not invent a retry action', (
    tester,
  ) async {
    final gate = _FailureSurfaceGate();
    await _pumpFailureOverlay(
      tester,
      gate: gate,
      journey: OnboardingOperationFailed(
        occurrence: 1,
        summary: 'Manual inspection is required.',
        compatibilityStatus: OnboardingStatus.preparationFailed,
        failureAction: OnboardingJourneyFailureAction.none,
        operation: OnboardingJourneyOperationProjection(
          operationId: OnboardingOperationId(
            '123e4567-e89b-42d3-a456-426614174000',
          ),
          kind: OnboardingOperationKind.initialImport,
          phase: OnboardingJourneyOperationPhase.failed,
          stage: OnboardingOperationStage.messageDataBuild,
          substage: OnboardingOperationSubstage.importingMessages,
          progressRevision: 2,
          progress: null,
          failure: const OnboardingJourneyOperationFailure(
            category:
                OnboardingOperationFailureCategory.durableStateInconsistent,
            summary: 'Manual inspection is required.',
          ),
          availableActions: const <OnboardingJourneyOperationAction>{},
        ),
      ),
      report: _failureReport(
        state: OnboardingEnvironmentState.graphProjectionFailed,
        blockerKind: OnboardingBlockerKind.graphProjectionFailed,
      ),
    );

    expect(find.text('Try Again'), findsNothing);
    expect(gate.retryFailedOperationCallCount, 0);
  });

  testWidgets('graph failure hides diagnostics while support evidence remains', (
    tester,
  ) async {
    final gate = _FailureSurfaceGate();
    final exporter = _RecordingDiagnosticReportExporter();

    await _pumpFailureOverlay(
      tester,
      gate: gate,
      journey: const OnboardingOperationFailed(
        occurrence: 1,
        summary: _technicalGraphError,
        compatibilityStatus: OnboardingStatus.awaitingUserAction,
        failureAction: OnboardingJourneyFailureAction.retryInitialImport,
      ),
      exporter: exporter,
      report: _failureReport(
        state: OnboardingEnvironmentState.graphProjectionFailed,
        blockerKind: OnboardingBlockerKind.graphProjectionFailed,
        graphFailure: const OnboardingPipelineFailure(
          phase: OnboardingPipelinePhase.graphProjection,
          message: _technicalGraphError,
        ),
      ),
    );

    _expectSharedPrimaryFailureCopy();
    expect(find.text('Messages Could Not Be Prepared'), findsNothing);
    expect(find.textContaining('imported source data, but'), findsNothing);
    _expectEnvironmentSummaryAbsent();
    expect(find.text('What to check'), findsNothing);
    expect(find.text(_technicalGraphError), findsNothing);
    expect(find.textContaining('previous launch'), findsNothing);
    expect(
      find.textContaining('failure happened while preparing it for browsing'),
      findsNothing,
    );
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.text('Send Report To Developer'), findsOneWidget);
    _expectSupportTransportCaptionAbsent();

    await tester.tap(find.text('Try Again'));
    await tester.pump();
    expect(gate.retryFailedOperationCallCount, 1);

    await tester.tap(find.text('Send Report To Developer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(exporter.requests, hasLength(1));
    expect(
      exporter.requests.single.headerLines,
      contains('Graph projection failure: $_technicalGraphError'),
    );
    expect(
      exporter.requests.single.headerLines,
      contains('Failure recorded at: 2026-01-01T00:00:00.000Z'),
    );
    expect(
      find.text(
        'Support bundle prepared. It was opened in Finder so it can be attached manually.',
      ),
      findsOneWidget,
    );
  });

  for (final scenario
      in <
        ({
          String description,
          DiagnosticReportPresentationResult result,
          String feedback,
        })
      >[
        (
          description: 'email attachment success',
          result: const DiagnosticReportPresentationResult(
            exportPath: '/tmp/support-bundle.zip',
            attachedToMailDraft: true,
          ),
          feedback: 'Email draft prepared with the support bundle attached.',
        ),
        (
          description: 'Finder fallback',
          result: const DiagnosticReportPresentationResult(
            exportPath: '/tmp/support-bundle.zip',
            attachedToMailDraft: false,
          ),
          feedback:
              'Support bundle prepared. It was opened in Finder so it can be attached manually.',
        ),
        (
          description: 'report preparation failure',
          result: const DiagnosticReportPresentationResult(
            exportPath: null,
            attachedToMailDraft: false,
          ),
          feedback:
              'MessageLens could not prepare a diagnostic report right now.',
        ),
      ]) {
    testWidgets('support action retains ${scenario.description} feedback', (
      tester,
    ) async {
      final exporter = _RecordingDiagnosticReportExporter(scenario.result);

      await _pumpFailureOverlay(
        tester,
        gate: _FailureSurfaceGate(),
        exporter: exporter,
        report: _failureReport(
          state: OnboardingEnvironmentState.importFailed,
          blockerKind: OnboardingBlockerKind.importFailed,
          importFailure: const OnboardingPipelineFailure(
            phase: OnboardingPipelinePhase.import,
            message: _technicalImportError,
          ),
        ),
      );

      _expectSupportTransportCaptionAbsent();
      await tester.tap(find.text('Send Report To Developer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(exporter.requests, hasLength(1));
      expect(find.text(scenario.feedback), findsOneWidget);
    });
  }

  testWidgets('non-failure readiness retains Environment summary', (
    tester,
  ) async {
    await _pumpFailureOverlay(
      tester,
      gate: _FailureSurfaceGate(),
      report: _failureReport(
        state: OnboardingEnvironmentState.readyToImport,
        blockerKind: OnboardingBlockerKind.none,
      ),
    );

    expect(find.text('Ready to Import'), findsOneWidget);
    expect(find.text('Environment summary'), findsOneWidget);
    expect(
      find.textContaining('Full Disk Access', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Messages database', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Contacts database', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Imported message data', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Conversation browsing data', findRichText: true),
      findsOneWidget,
    );
  });
}

void _expectSharedPrimaryFailureCopy() {
  expect(find.text(_failureTitle), findsOneWidget);
  expect(find.text(_failureBody), findsOneWidget);

  for (final unsupportedPrimaryClaim in <String>[
    'Import completed',
    'Projection failed',
    'Graph Build Failed',
    'previous launch',
    'last launch',
  ]) {
    expect(
      find.text(unsupportedPrimaryClaim),
      findsNothing,
      reason: 'Unexpected primary claim: $unsupportedPrimaryClaim',
    );
  }
}

void _expectEnvironmentSummaryAbsent() {
  expect(find.text('Environment summary'), findsNothing);
  for (final label in <String>[
    'Full Disk Access',
    'Messages database',
    'Contacts database',
    'Imported message data',
    'Conversation browsing data',
  ]) {
    expect(
      find.textContaining(label, findRichText: true),
      findsNothing,
      reason: 'Unexpected environment summary row: $label',
    );
  }
}

void _expectSupportTransportCaptionAbsent() {
  expect(find.textContaining('try to open an email draft'), findsNothing);
  expect(
    find.textContaining('otherwise reveal the file in Finder'),
    findsNothing,
  );
}

Future<void> _pumpFailureOverlay(
  WidgetTester tester, {
  required _FailureSurfaceGate gate,
  required OnboardingEnvironmentReport report,
  _RecordingDiagnosticReportExporter? exporter,
  OnboardingJourneyState? journey,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 1600);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final resolvedExporter = exporter ?? _RecordingDiagnosticReportExporter();
  final resolvedJourney = switch (journey) {
    OnboardingOperationFailed(
      :final occurrence,
      :final summary,
      :final failureAction,
    ) =>
      OnboardingOperationFailed(
        occurrence: occurrence,
        summary: summary,
        compatibilityStatus: journey.compatibilityStatus,
        failureAction: failureAction,
        operation: journey.operation,
        evidence: OnboardingPrerequisiteEvidence(
          revision: 1,
          observedAtUtc: DateTime.utc(2026, 9, 24),
          report: report,
        ),
      ),
    _ => journey,
  };
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        onboardingGateProvider.overrideWith(() => gate),
        if (resolvedJourney != null)
          onboardingJourneyCoordinatorProvider.overrideWith(
            () => _FixedJourneyCoordinator(resolvedJourney),
          ),
        onboardingEnvironmentReportProvider.overrideWith((ref) async => report),
        diagnosticReportExporterProvider.overrideWith(
          (ref) async => resolvedExporter,
        ),
      ],
      child: const MacosApp(
        home: ScaffoldMessenger(child: Scaffold(body: OnboardingOverlay())),
      ),
    ),
  );
  await tester.pump();
}

final class _FixedJourneyCoordinator extends OnboardingJourneyCoordinator {
  _FixedJourneyCoordinator(this.journey);

  final OnboardingJourneyState journey;

  @override
  OnboardingJourneyState build() => journey;
}

OnboardingEnvironmentReport _failureReport({
  required OnboardingEnvironmentState state,
  required OnboardingBlockerKind blockerKind,
  OnboardingPipelineFailure? importFailure,
  OnboardingPipelineFailure? graphFailure,
  int importRowCount = 100,
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
    overlayDatabase: const OnboardingDatabaseProbe(
      path: 'overlay.db',
      exists: true,
      readable: true,
    ),
    sourceScopedImportDatabase: OnboardingDatabaseProbe(
      path: 'source_scoped_import.db',
      exists: true,
      readable: true,
      rowCount: importRowCount,
    ),
    conversationGraph: const OnboardingDatabaseProbe(
      path: 'conversation_graph.db',
      exists: true,
      readable: true,
      rowCount: 0,
    ),
    attachmentArchiveDirectory: const OnboardingDatabaseProbe(
      path: 'attachment_archive',
      exists: true,
      readable: true,
    ),
    hasFullDiskAccess: true,
    lastImportFailure: importFailure,
    lastGraphProjectionFailure: graphFailure,
    lastImportFailureRecordedAt: importFailure == null
        ? null
        : DateTime.utc(2026, 1, 1),
    lastGraphProjectionFailureRecordedAt: graphFailure == null
        ? null
        : DateTime.utc(2026, 1, 1),
    usingPersistedImportFailure: importFailure != null,
    usingPersistedGraphProjectionFailure: graphFailure != null,
  );
}

final class _FailureSurfaceGate extends OnboardingGate {
  _FailureSurfaceGate({this.status = OnboardingStatus.awaitingUserAction});

  final OnboardingStatus status;
  int startImportCallCount = 0;
  int retryFailedOperationCallCount = 0;

  @override
  OnboardingStatus build() {
    return status;
  }

  @override
  Future<void> startVirginImportAndGraphBuild({
    OnboardingJourneyActionContext? actionContext,
  }) async {
    startImportCallCount += 1;
  }

  @override
  Future<void> retryFailedOperation({
    OnboardingJourneyActionContext? actionContext,
  }) async {
    retryFailedOperationCallCount += 1;
  }
}

final class _RecordingDiagnosticReportExporter
    implements DiagnosticReportExporter {
  _RecordingDiagnosticReportExporter([
    this.result = const DiagnosticReportPresentationResult(
      exportPath: '/tmp/support-bundle.zip',
      attachedToMailDraft: false,
    ),
  ]);

  final DiagnosticReportPresentationResult result;
  final requests = <DiagnosticReportExportRequest>[];

  @override
  Future<DiagnosticReportPresentationResult> exportAndPresent(
    DiagnosticReportExportRequest request,
  ) async {
    requests.add(request);
    return result;
  }
}
