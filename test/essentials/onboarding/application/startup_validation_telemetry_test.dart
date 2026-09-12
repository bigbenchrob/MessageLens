import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_evidence_reader.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_integrity_validator.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_validation_service.dart';
import 'package:remember_this_text/essentials/onboarding/application/startup_validation_telemetry_buffer.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/onboarding/domain/startup_installation_validation.dart';
import 'package:remember_this_text/essentials/onboarding/domain/startup_validation_telemetry.dart';

void main() {
  test('healthy startup records bounded evidence and no deep checks', () async {
    final telemetry = StartupValidationTelemetryBuffer();

    await _service(
      evidence: _healthyEvidence(),
      validator: const _FakeIntegrityValidator(),
      telemetry: telemetry,
    ).validateForStartup(archiveRootPath: '/not-used').toList();

    final events = telemetry.snapshot().events;
    expect(events.first.kind, StartupValidationEventKind.validationStarted);
    expect(events.first.archiveEnvironment, ArchiveEnvironment.production);
    expect(events.first.buildIdentity, ArchiveBuildIdentity.productionRelease);
    expect(
      events
          .where(
            (event) =>
                event.kind ==
                StartupValidationEventKind.boundedInspectionCompleted,
          )
          .length,
      4,
    );
    expect(
      events.where(
        (event) =>
            event.kind == StartupValidationEventKind.integrityCheckStarted ||
            event.kind == StartupValidationEventKind.integrityCheckCompleted,
      ),
      isEmpty,
    );
    final decision = events.singleWhere(
      (event) => event.kind == StartupValidationEventKind.integrityDecision,
    );
    expect(
      decision.integrityDecision,
      StartupValidationIntegrityDecision.notRequired,
    );
    final finalEvent = events.last;
    expect(finalEvent.kind, StartupValidationEventKind.admissionDecided);
    expect(
      finalEvent.installationKind,
      MessageLensInstallationStateKind.completed,
    );
    expect(
      finalEvent.installationReasonCode,
      MessageLensInstallationReasonCode.durableStoresReconciled,
    );
    expect(finalEvent.admissionBasis, StartupAdmissionBasis.boundedInspection);
    expect(
      finalEvent.admissionOutcome,
      StartupValidationAdmissionOutcome.granted,
    );
    expect(finalEvent.totalDurationMicroseconds, greaterThanOrEqualTo(0));
  });

  test(
    'escalation records triggers, targets, and a passing deep check',
    () async {
      final telemetry = StartupValidationTelemetryBuffer();

      await _service(
        evidence: _healthyEvidence(
          graph: _failedGraph(
            InstallationBoundedInspectionFailureKind.missingRequiredObject,
          ),
        ),
        validator: const _FakeIntegrityValidator(),
        telemetry: telemetry,
      ).validateForStartup(archiveRootPath: '/not-used').toList();

      final events = telemetry.snapshot().events;
      final decision = events.singleWhere(
        (event) => event.kind == StartupValidationEventKind.integrityDecision,
      );
      expect(
        decision.integrityDecision,
        StartupValidationIntegrityDecision.required,
      );
      expect(
        decision.integrityTriggers,
        contains(InstallationIntegrityValidationTrigger.missingRequiredObject),
      );
      expect(
        decision.triggerCategories,
        contains(StartupValidationTriggerCategory.structural),
      );
      expect(decision.integrityTargets, <InstallationDatabaseKey>[
        InstallationDatabaseKey.conversationGraph,
      ]);
      expect(
        events.where(
          (event) =>
              event.kind == StartupValidationEventKind.integrityCheckStarted,
        ),
        hasLength(1),
      );
      final completion = events.singleWhere(
        (event) =>
            event.kind == StartupValidationEventKind.integrityCheckCompleted,
      );
      expect(completion.database, InstallationDatabaseKey.conversationGraph);
      expect(
        completion.integrityResult,
        StartupValidationIntegrityResult.passed,
      );
      expect(completion.durationMicroseconds, greaterThanOrEqualTo(0));
      expect(
        events.last.admissionOutcome,
        StartupValidationAdmissionOutcome.withheld,
      );
      expect(
        events.last.admissionBasis,
        StartupAdmissionBasis.integrityValidation,
      );
    },
  );

  test('deep failure records a typed failure and withheld admission', () async {
    final telemetry = StartupValidationTelemetryBuffer();

    await _service(
      evidence: _healthyEvidence(
        graph: _failedGraph(
          InstallationBoundedInspectionFailureKind.targetedReadFailure,
        ),
      ),
      validator: const _FakeIntegrityValidator(
        status: InstallationIntegrityValidationStatus.failed,
        failureKind:
            InstallationIntegrityValidationFailureKind.integrityFailure,
      ),
      telemetry: telemetry,
    ).validateForStartup(archiveRootPath: '/not-used').toList();

    final completion = telemetry.snapshot().events.singleWhere(
      (event) =>
          event.kind == StartupValidationEventKind.integrityCheckCompleted,
    );
    expect(completion.integrityResult, StartupValidationIntegrityResult.failed);
    expect(
      completion.integrityFailureKind,
      InstallationIntegrityValidationFailureKind.integrityFailure,
    );
    expect(
      telemetry.snapshot().events.last.installationReasonCode,
      MessageLensInstallationReasonCode.physicalIntegrityFailure,
    );
    expect(
      telemetry.snapshot().events.last.admissionOutcome,
      StartupValidationAdmissionOutcome.withheld,
    );
  });

  test('busy deep result is distinct from corruption', () async {
    final telemetry = StartupValidationTelemetryBuffer();

    await _service(
      evidence: _healthyEvidence(
        graph: _failedGraph(
          InstallationBoundedInspectionFailureKind.targetedReadFailure,
        ),
      ),
      validator: const _FakeIntegrityValidator(
        status: InstallationIntegrityValidationStatus.contention,
        sqliteResultCode: 5,
      ),
      telemetry: telemetry,
    ).validateForStartup(archiveRootPath: '/not-used').toList();

    final events = telemetry.snapshot().events;
    final completion = events.singleWhere(
      (event) =>
          event.kind == StartupValidationEventKind.integrityCheckCompleted,
    );
    expect(
      completion.integrityResult,
      StartupValidationIntegrityResult.busyOrLocked,
    );
    expect(completion.sqliteResultCode, 5);
    expect(
      completion.contentionCategory,
      StartupValidationContentionCategory.busyOrLocked,
    );
    expect(
      events.last.admissionOutcome,
      StartupValidationAdmissionOutcome.blocked,
    );
    expect(
      events.last.blockedReasonCode,
      StartupValidationBlockedReasonCode.deepIntegrityContention,
    );
    expect(
      jsonEncode(telemetry.snapshot().toJson()),
      isNot(contains('corrupt')),
    );
  });

  test(
    'bounded contention records busy or locked and blocks admission',
    () async {
      final telemetry = StartupValidationTelemetryBuffer();

      await _service(
        evidence: _healthyEvidence(
          graph: const InstallationDatabaseEvidence(
            boundedInspectionStatus:
                InstallationBoundedInspectionStatus.contention,
            failure: InstallationBoundedInspectionFailure(
              kind: InstallationBoundedInspectionFailureKind.unknown,
              message: 'excluded lock detail',
              sqliteResultCode: 5,
            ),
          ),
        ),
        validator: const _FakeIntegrityValidator(),
        telemetry: telemetry,
      ).validateForStartup(archiveRootPath: '/not-used').toList();

      final events = telemetry.snapshot().events;
      final graphEvent = events.singleWhere(
        (event) =>
            event.kind ==
                StartupValidationEventKind.boundedInspectionCompleted &&
            event.database == InstallationDatabaseKey.conversationGraph,
      );
      expect(
        graphEvent.boundedInspectionStatus,
        InstallationBoundedInspectionStatus.contention,
      );
      expect(
        graphEvent.contentionCategory,
        StartupValidationContentionCategory.busyOrLocked,
      );
      expect(graphEvent.sqliteResultCode, 5);
      expect(
        events
            .singleWhere(
              (event) =>
                  event.kind == StartupValidationEventKind.integrityDecision,
            )
            .integrityDecision,
        StartupValidationIntegrityDecision.blockedByContention,
      );
      expect(
        events.where(
          (event) =>
              event.kind == StartupValidationEventKind.integrityCheckStarted,
        ),
        isEmpty,
      );
      expect(
        events.last.admissionOutcome,
        StartupValidationAdmissionOutcome.blocked,
      );
      expect(
        events.last.blockedReasonCode,
        StartupValidationBlockedReasonCode.boundedInspectionContention,
      );
    },
  );

  test(
    'unsupported schema is distinct and does not run a deep check',
    () async {
      final telemetry = StartupValidationTelemetryBuffer();
      const sensitiveFailure =
          'Contact Pat at https://private.example and inspect message text';

      await _service(
        evidence: _healthyEvidence(
          graph: const InstallationDatabaseEvidence(
            boundedInspectionStatus:
                InstallationBoundedInspectionStatus.unsupportedSchema,
            userVersion: 4,
            currentSchemaVersion: 3,
            failure: InstallationBoundedInspectionFailure(
              kind: InstallationBoundedInspectionFailureKind.unknown,
              message: sensitiveFailure,
            ),
          ),
        ),
        validator: const _FakeIntegrityValidator(),
        telemetry: telemetry,
      ).validateForStartup(archiveRootPath: '/not-used').toList();

      final events = telemetry.snapshot().events;
      final graphEvent = events.singleWhere(
        (event) =>
            event.kind ==
                StartupValidationEventKind.boundedInspectionCompleted &&
            event.database == InstallationDatabaseKey.conversationGraph,
      );
      expect(
        graphEvent.schemaDisposition,
        StartupValidationSchemaDisposition.unsupported,
      );
      expect(
        graphEvent.boundedInspectionStatus,
        InstallationBoundedInspectionStatus.unsupportedSchema,
      );
      expect(
        events
            .singleWhere(
              (event) =>
                  event.kind == StartupValidationEventKind.integrityDecision,
            )
            .integrityDecision,
        StartupValidationIntegrityDecision.rejectedUnsupportedSchema,
      );
      expect(
        events.where(
          (event) =>
              event.kind == StartupValidationEventKind.integrityCheckStarted,
        ),
        isEmpty,
      );
      expect(
        jsonEncode(telemetry.snapshot().toJson()),
        isNot(contains(sensitiveFailure)),
      );
    },
  );

  test('buffer flushes once and retains events for support export', () {
    final telemetry = StartupValidationTelemetryBuffer();
    final validationId = telemetry.beginValidation(
      archiveEnvironment: ArchiveEnvironment.test,
      buildIdentity: ArchiveBuildIdentity.testHarness,
    );
    final flushed = <StartupValidationTelemetryEvent>[];

    telemetry.flushTo(flushed.add);
    telemetry.flushTo(flushed.add);
    telemetry.record(
      StartupValidationTelemetryEvent.integrityDecision(
        validationId: validationId,
        occurredAtUtc: DateTime.utc(2026, 9, 12),
        decision: StartupValidationIntegrityDecision.notRequired,
      ),
    );
    telemetry.flushTo(flushed.add);

    expect(flushed, hasLength(2));
    expect(telemetry.snapshot().events, hasLength(2));
    expect(flushed.first.eventName, 'startup_validation_started');
    expect(flushed.last.eventName, 'startup_integrity_decision');
  });
}

MessageLensInstallationValidationService _service({
  required MessageLensInstallationEvidence evidence,
  required MessageLensInstallationIntegrityValidator validator,
  required StartupValidationTelemetryBuffer telemetry,
}) {
  return MessageLensInstallationValidationService(
    evidenceReader: _FakeEvidenceReader(evidence),
    integrityValidator: validator,
    telemetry: telemetry,
    archiveEnvironment: ArchiveEnvironment.production,
    buildIdentity: ArchiveBuildIdentity.productionRelease,
  );
}

MessageLensInstallationEvidence _healthyEvidence({
  InstallationDatabaseEvidence source =
      const InstallationDatabaseEvidence.passed(
        userVersion: 10,
        messageCount: 10,
        nonLiveSourceCount: 0,
      ),
  InstallationDatabaseEvidence graph =
      const InstallationDatabaseEvidence.passed(
        userVersion: 3,
        messageCount: 10,
        chatCount: 2,
        chatMessageEdgeCount: 10,
      ),
}) {
  return MessageLensInstallationEvidence(
    sourceScopedImport: source,
    conversationGraph: graph,
    overlay: const InstallationDatabaseEvidence.absent(),
    presence: const InstallationDatabaseEvidence.absent(),
    hasRetiredDerivedArtifacts: false,
    operationSnapshot: const OnboardingOperationSnapshot.idle(),
  );
}

InstallationDatabaseEvidence _failedGraph(
  InstallationBoundedInspectionFailureKind kind,
) {
  return InstallationDatabaseEvidence(
    boundedInspectionStatus: InstallationBoundedInspectionStatus.failed,
    userVersion: 3,
    currentSchemaVersion: 3,
    failure: InstallationBoundedInspectionFailure(
      kind: kind,
      message: 'excluded from telemetry',
    ),
  );
}

final class _FakeEvidenceReader
    implements MessageLensInstallationEvidenceReader {
  const _FakeEvidenceReader(this.evidence);

  final MessageLensInstallationEvidence evidence;

  @override
  Future<MessageLensInstallationEvidence> readBounded({
    required String archiveRootPath,
  }) async {
    return evidence;
  }
}

final class _FakeIntegrityValidator
    implements MessageLensInstallationIntegrityValidator {
  const _FakeIntegrityValidator({
    this.status = InstallationIntegrityValidationStatus.passed,
    this.failureKind,
    this.sqliteResultCode,
  });

  final InstallationIntegrityValidationStatus status;
  final InstallationIntegrityValidationFailureKind? failureKind;
  final int? sqliteResultCode;

  @override
  Future<InstallationDatabaseIntegrityValidation> validateDatabase({
    required String archiveRootPath,
    required InstallationDatabaseKey database,
  }) async {
    return InstallationDatabaseIntegrityValidation(
      database: database,
      status: status,
      failure: status == InstallationIntegrityValidationStatus.passed
          ? null
          : 'excluded from telemetry',
      failureKind: failureKind,
      sqliteResultCode: sqliteResultCode,
    );
  }
}
