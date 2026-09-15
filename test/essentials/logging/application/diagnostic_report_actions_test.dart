import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/logging/application/diagnostic_report_actions.dart';
import 'package:remember_this_text/essentials/logging/application/diagnostic_report_exporter.dart';
import 'package:remember_this_text/essentials/logging/domain/diagnostic_report_presentation_result.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';

void main() {
  test('exportDiagnosticReport delegates through exporter boundary', () async {
    final exporter = _FakeDiagnosticReportExporter();

    final result = await exportDiagnosticReport(exporter);

    expect(result.exportPath, '/tmp/report');
    expect(exporter.requests, hasLength(1));
    expect(
      exporter.requests.single.subjectPrefix,
      'MessageLens Diagnostic Report',
    );
    expect(
      exporter.requests.single.recipientEmail,
      developerDiagnosticRecipientEmail,
    );
  });

  test('buildOnboardingFailureReportHeaderLines includes failure context', () {
    final report = OnboardingEnvironmentReport(
      state: OnboardingEnvironmentState.graphProjectionFailed,
      blockerKind: OnboardingBlockerKind.graphProjectionFailed,
      syncPlausibility: OnboardingSyncPlausibility.unknown,
      messagesDatabase: const OnboardingDatabaseProbe(
        path: 'messages.db',
        exists: true,
        readable: true,
        rowCount: 123,
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
        rowCount: 123,
      ),
      conversationGraph: OnboardingDatabaseProbe(
        path: appDatabaseFileName(AppDatabaseFile.conversationGraph),
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
      lastImportFailure: const OnboardingPipelineFailure(
        phase: OnboardingPipelinePhase.import,
        batchId: 1,
        message: 'import failed',
      ),
      lastGraphProjectionFailure: const OnboardingPipelineFailure(
        phase: OnboardingPipelinePhase.graphProjection,
        batchId: 1,
        message: 'foreign key failed',
      ),
      lastGraphProjectionFailureRecordedAt: DateTime.utc(2026, 4, 14, 12, 0, 0),
      operationSnapshot: _interruptedRichTextSnapshot(),
    );

    final headerLines = buildOnboardingFailureReportHeaderLines(
      report,
      operationFailureSummary:
          'Verified archive checkpoint required for messageDataReset',
    );

    expect(headerLines, contains('Context: onboarding_failure'));
    expect(headerLines, contains('State: graphProjectionFailed'));
    expect(headerLines, contains('Blocker: graphProjectionFailed'));
    expect(headerLines, contains('Operation status: interrupted'));
    expect(headerLines, contains('Operation stage: messageDataBuild'));
    expect(headerLines, contains('Operation substage: extractingRichText'));
    expect(headerLines, contains('Operation progress: 24000 / 123561'));
    expect(
      headerLines,
      contains(
        'Operation failure: Verified archive checkpoint required for messageDataReset',
      ),
    );
    expect(headerLines, contains('Import failure: import failed'));
    expect(
      headerLines,
      contains('Graph projection failure: foreign key failed'),
    );
    expect(
      headerLines,
      contains('Failure recorded at: 2026-04-14T12:00:00.000Z'),
    );
    expect(
      headerLines,
      contains(
        'Source-scoped import ledger: path=${appDatabaseFileName(AppDatabaseFile.sourceScopedImport)}; exists=true; readable=true; rows=123',
      ),
    );
    expect(
      headerLines,
      contains(
        'Conversation graph: path=${appDatabaseFileName(AppDatabaseFile.conversationGraph)}; exists=true; readable=true; rows=0',
      ),
    );
  });

  test('onboarding failure export includes the operation failure', () async {
    final exporter = _FakeDiagnosticReportExporter();
    const report = OnboardingEnvironmentReport(
      state: OnboardingEnvironmentState.readyToImport,
      blockerKind: OnboardingBlockerKind.sourceScopedImportDatabaseEmpty,
      syncPlausibility: OnboardingSyncPlausibility.unknown,
      messagesDatabase: OnboardingDatabaseProbe(
        path: 'messages.db',
        exists: true,
        readable: true,
        rowCount: 5200,
      ),
      addressBookDatabase: OnboardingDatabaseProbe(
        path: 'addressbook.db',
        exists: true,
        readable: true,
      ),
      overlayDatabase: OnboardingDatabaseProbe(
        path: 'overlay.db',
        exists: true,
        readable: true,
      ),
      sourceScopedImportDatabase: OnboardingDatabaseProbe(
        path: 'macos_import_ss.db',
        exists: true,
        readable: true,
        rowCount: 0,
      ),
      conversationGraph: OnboardingDatabaseProbe(
        path: 'working_ss.db',
        exists: true,
        readable: true,
        rowCount: 0,
      ),
      attachmentArchiveDirectory: OnboardingDatabaseProbe(
        path: 'attachment_archive',
        exists: true,
        readable: true,
      ),
      hasFullDiskAccess: true,
    );

    await exportOnboardingFailureDiagnosticReport(
      exporter,
      report: report,
      operationFailureSummary:
          'Verified archive checkpoint required for messageDataReset',
    );

    final request = exporter.requests.single;
    expect(
      request.attachedEmailBodyLines,
      contains(
        'Operation failure: Verified archive checkpoint required for messageDataReset',
      ),
    );
    expect(
      request.manualAttachmentEmailBodyLines,
      contains(
        'Operation failure: Verified archive checkpoint required for messageDataReset',
      ),
    );
    expect(
      request.headerLines,
      contains(
        'Operation failure: Verified archive checkpoint required for messageDataReset',
      ),
    );
  });
}

OnboardingOperationSnapshot _interruptedRichTextSnapshot() {
  final startedAt = DateTime.utc(2026, 9, 13, 12);
  return OnboardingOperationSnapshot.running(
        operationId: OnboardingOperationId(
          '123e4567-e89b-42d3-a456-426614174000',
        ),
        processSessionId: OnboardingProcessSessionId(
          '123e4567-e89b-42d3-a456-426614174001',
        ),
        kind: OnboardingOperationKind.initialImport,
        stage: OnboardingOperationStage.messageDataBuild,
        observedAtUtc: startedAt,
      )
      .observeProgress(
        observedAtUtc: startedAt.add(const Duration(seconds: 1)),
        substage: OnboardingOperationSubstage.extractingRichText,
        progress: const OnboardingOperationProgress(
          completedWorkUnits: 24000,
          totalWorkUnits: 123561,
        ),
      )
      .interrupt(observedAtUtc: startedAt.add(const Duration(seconds: 2)));
}

class _FakeDiagnosticReportExporter implements DiagnosticReportExporter {
  final requests = <DiagnosticReportExportRequest>[];

  @override
  Future<DiagnosticReportPresentationResult> exportAndPresent(
    DiagnosticReportExportRequest request,
  ) async {
    requests.add(request);
    return const DiagnosticReportPresentationResult(
      exportPath: '/tmp/report',
      attachedToMailDraft: false,
    );
  }
}
