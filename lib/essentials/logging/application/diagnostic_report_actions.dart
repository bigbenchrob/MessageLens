import '../../onboarding/domain/onboarding_environment_report.dart';
import '../domain/diagnostic_report_presentation_result.dart';
import '../domain/pipeline_incident_report.dart';
import 'diagnostic_report_exporter.dart';

const developerDiagnosticRecipientEmail = 'messagelens@gmail.com';

Future<DiagnosticReportPresentationResult> exportDiagnosticReport(
  DiagnosticReportExporter exporter,
) {
  return exporter.exportAndPresent(
    const DiagnosticReportExportRequest(
      recipientEmail: developerDiagnosticRecipientEmail,
      subjectPrefix: 'MessageLens Diagnostic Report',
      attachedEmailBodyLines: [
        'MessageLens attached the support bundle to this draft.',
        '',
        'Describe the issue here:',
      ],
      manualAttachmentEmailBodyLines: [
        'MessageLens prepared a support bundle but could not attach it automatically.',
        'It has been revealed in Finder so it can be attached manually.',
        '',
        'Describe the issue here:',
      ],
    ),
  );
}

Future<DiagnosticReportPresentationResult>
exportOnboardingFailureDiagnosticReport(
  DiagnosticReportExporter exporter, {
  required OnboardingEnvironmentReport report,
  String? operationFailureSummary,
}) {
  final operationFailureLine = _operationFailureLine(operationFailureSummary);
  return exporter.exportAndPresent(
    DiagnosticReportExportRequest(
      recipientEmail: developerDiagnosticRecipientEmail,
      subjectPrefix: 'MessageLens Onboarding Failure Report',
      attachedEmailBodyLines: [
        'MessageLens attached the support bundle to this draft.',
        '',
        'This report was prepared from the onboarding failure screen.',
        'Observed state: ${report.state.name}',
        'Blocker kind: ${report.blockerKind.name}',
        if (operationFailureLine != null) operationFailureLine,
        '',
        'Describe what happened just before setup failed:',
      ],
      manualAttachmentEmailBodyLines: [
        'MessageLens prepared a support bundle but could not attach it automatically.',
        'It has been revealed in Finder so it can be attached manually.',
        '',
        'This report was prepared from the onboarding failure screen.',
        'Observed state: ${report.state.name}',
        'Blocker kind: ${report.blockerKind.name}',
        if (operationFailureLine != null) operationFailureLine,
        '',
        'Describe what happened just before setup failed:',
      ],
      headerLines: buildOnboardingFailureReportHeaderLines(
        report,
        operationFailureSummary: operationFailureSummary,
      ),
    ),
  );
}

Future<DiagnosticReportPresentationResult>
exportPipelineIncidentDiagnosticReport(
  DiagnosticReportExporter exporter, {
  required PipelineIncidentReport report,
}) {
  return exporter.exportAndPresent(
    DiagnosticReportExportRequest(
      recipientEmail: developerDiagnosticRecipientEmail,
      subjectPrefix: 'MessageLens Pipeline Incident Report',
      attachedEmailBodyLines: [
        'MessageLens attached the support bundle to this draft.',
        '',
        'This report was prepared from the pipeline incident screen.',
        'Observed stage: ${report.stage.displayLabel}',
        'Headline: ${report.headline}',
        '',
        'Describe what happened just before the failure appeared:',
      ],
      manualAttachmentEmailBodyLines: [
        'MessageLens prepared a support bundle but could not attach it automatically.',
        'It has been revealed in Finder so it can be attached manually.',
        '',
        'This report was prepared from the pipeline incident screen.',
        'Observed stage: ${report.stage.displayLabel}',
        'Headline: ${report.headline}',
        '',
        'Describe what happened just before the failure appeared:',
      ],
      headerLines: buildPipelineIncidentReportHeaderLines(report),
    ),
  );
}

List<String> buildOnboardingFailureReportHeaderLines(
  OnboardingEnvironmentReport report, {
  String? operationFailureSummary,
}) {
  final lines = <String>[
    'Context: onboarding_failure',
    'State: ${report.state.name}',
    'Blocker: ${report.blockerKind.name}',
    'Operation status: ${report.operationSnapshot.status.name}',
    if (report.operationSnapshot.currentStage case final stage?)
      'Operation stage: ${stage.name}',
    if (report.operationSnapshot.currentSubstage case final substage?)
      'Operation substage: ${substage.name}',
    if (report.operationSnapshot.progress case final progress?)
      'Operation progress: ${progress.completedWorkUnits} / ${progress.totalWorkUnits}',
    if (_operationFailureLine(operationFailureSummary) case final line?) line,
    'Full Disk Access: ${report.hasFullDiskAccess ? 'available' : 'missing'}',
    _describeProbe(label: 'Messages database', probe: report.messagesDatabase),
    _describeProbe(
      label: 'Contacts database',
      probe: report.addressBookDatabase,
      unavailableMessage: report.addressBookFailureMessage ?? 'unavailable',
    ),
    _describeProbe(
      label: 'Source-scoped import ledger',
      probe: report.sourceScopedImportDatabase,
    ),
    _describeProbe(
      label: 'Conversation graph',
      probe: report.conversationGraph,
    ),
  ];

  final importMessage = report.importFailureMessage;
  if (importMessage != null && importMessage.isNotEmpty) {
    lines.add('Import failure: $importMessage');
  }

  final graphProjectionMessage = report.graphProjectionFailureMessage;
  if (graphProjectionMessage != null && graphProjectionMessage.isNotEmpty) {
    lines.add('Graph projection failure: $graphProjectionMessage');
  }

  final recordedAt = report.latestFailureRecordedAt;
  if (recordedAt != null) {
    lines.add('Failure recorded at: ${recordedAt.toUtc().toIso8601String()}');
  }

  lines.add('');
  return lines;
}

String? _operationFailureLine(String? summary) {
  final normalized = summary?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return 'Operation failure: $normalized';
}

List<String> buildPipelineIncidentReportHeaderLines(
  PipelineIncidentReport report,
) {
  final lines = <String>[
    'Context: pipeline_incident',
    'Stage: ${report.stage.displayLabel}',
    'Headline: ${report.headline}',
    'Summary: ${report.summary}',
    'Blocking incident: ${report.hasBlockingIncident}',
    'Batch id: ${report.batchId}',
    'Recorded at: ${report.recordedAtUtc.toUtc().toIso8601String()}',
  ];

  for (final entry in report.entries) {
    lines.add(
      'Entry [${entry.severity.name}/${entry.stage.displayLabel}]: ${entry.summary}',
    );
    if (entry.code != null && entry.code!.isNotEmpty) {
      lines.add('Entry code: ${entry.code}');
    }
    if (entry.detail != null && entry.detail!.isNotEmpty) {
      lines.add('Entry detail: ${entry.detail}');
    }
  }

  lines.add('');
  return lines;
}

String _describeProbe({
  required String label,
  required OnboardingDatabaseProbe? probe,
  String unavailableMessage = 'not available',
}) {
  if (probe == null) {
    return '$label: $unavailableMessage';
  }

  return '$label: '
      'path=${probe.path}; '
      'exists=${probe.exists}; '
      'readable=${probe.readable}; '
      'rows=${probe.rowCount ?? 'unknown'}'
      '${probe.failureMessage == null ? '' : '; failure=${probe.failureMessage}'}';
}
