import '../../archive_environment/domain/archive_build_identity.dart';
import '../../archive_environment/domain/archive_environment.dart';
import 'message_lens_installation_state.dart';
import 'startup_installation_validation.dart';

const int startupValidationTelemetrySchemaVersion = 1;
const String startupValidationPolicyVersion = 'bounded-escalation-v1';

enum StartupValidationEventKind {
  validationStarted,
  boundedInspectionCompleted,
  integrityDecision,
  integrityCheckStarted,
  integrityCheckCompleted,
  admissionDecided,
}

enum StartupValidationSchemaDisposition {
  absent,
  current,
  olderSupported,
  unsupported,
  unknown,
}

enum StartupValidationIntegrityDecision {
  notRequired,
  required,
  rejectedUnsupportedSchema,
  rejectedNoExistingTarget,
  blockedByContention,
}

enum StartupValidationTriggerCategory {
  structural,
  logicalReconciliation,
  onboardingState,
  olderSchema,
  integritySuspicion,
  other,
}

enum StartupValidationIntegrityResult {
  passed,
  failed,
  busyOrLocked,
  ioError,
  unexpectedError,
}

enum StartupValidationAdmissionOutcome { granted, withheld, blocked }

enum StartupValidationContentionCategory { busyOrLocked }

enum StartupValidationBlockedReasonCode {
  boundedInspectionContention,
  deepIntegrityContention,
}

final class StartupValidationTelemetryEvent {
  const StartupValidationTelemetryEvent._({
    required this.kind,
    required this.validationId,
    required this.occurredAtUtc,
    this.archiveEnvironment,
    this.buildIdentity,
    this.database,
    this.databaseExists,
    this.observedSchemaVersion,
    this.currentSchemaVersion,
    this.schemaDisposition,
    this.boundedInspectionStatus,
    this.boundedFailureKind,
    this.sqliteResultCode,
    this.contentionCategory,
    this.durationMicroseconds,
    this.integrityDecision,
    this.integrityTriggers = const <InstallationIntegrityValidationTrigger>[],
    this.triggerCategories = const <StartupValidationTriggerCategory>[],
    this.integrityTargets = const <InstallationDatabaseKey>[],
    this.integrityResult,
    this.integrityFailureKind,
    this.installationKind,
    this.installationReasonCode,
    this.blockedReasonCode,
    this.admissionBasis,
    this.admissionOutcome,
    this.totalDurationMicroseconds,
  });

  factory StartupValidationTelemetryEvent.validationStarted({
    required int validationId,
    required DateTime occurredAtUtc,
    required ArchiveEnvironment? archiveEnvironment,
    required ArchiveBuildIdentity? buildIdentity,
  }) {
    return StartupValidationTelemetryEvent._(
      kind: StartupValidationEventKind.validationStarted,
      validationId: validationId,
      occurredAtUtc: occurredAtUtc,
      archiveEnvironment: archiveEnvironment,
      buildIdentity: buildIdentity,
    );
  }

  factory StartupValidationTelemetryEvent.boundedInspectionCompleted({
    required int validationId,
    required DateTime occurredAtUtc,
    required InstallationDatabaseKey database,
    required InstallationDatabaseEvidence evidence,
  }) {
    return StartupValidationTelemetryEvent._(
      kind: StartupValidationEventKind.boundedInspectionCompleted,
      validationId: validationId,
      occurredAtUtc: occurredAtUtc,
      database: database,
      databaseExists: evidence.exists,
      observedSchemaVersion: evidence.userVersion,
      currentSchemaVersion: evidence.currentSchemaVersion,
      schemaDisposition: _schemaDisposition(evidence),
      boundedInspectionStatus: evidence.boundedInspectionStatus,
      boundedFailureKind: evidence.failure?.kind,
      sqliteResultCode: evidence.failure?.sqliteResultCode,
      contentionCategory:
          evidence.boundedInspectionStatus ==
              InstallationBoundedInspectionStatus.contention
          ? StartupValidationContentionCategory.busyOrLocked
          : null,
      durationMicroseconds: evidence.inspectionDurationMicroseconds,
    );
  }

  factory StartupValidationTelemetryEvent.integrityDecision({
    required int validationId,
    required DateTime occurredAtUtc,
    required StartupValidationIntegrityDecision decision,
    Iterable<InstallationIntegrityValidationTrigger> triggers =
        const <InstallationIntegrityValidationTrigger>[],
    Iterable<InstallationDatabaseKey> targets =
        const <InstallationDatabaseKey>[],
  }) {
    final triggerList =
        List<InstallationIntegrityValidationTrigger>.unmodifiable(triggers);
    return StartupValidationTelemetryEvent._(
      kind: StartupValidationEventKind.integrityDecision,
      validationId: validationId,
      occurredAtUtc: occurredAtUtc,
      integrityDecision: decision,
      integrityTriggers: triggerList,
      triggerCategories: List<StartupValidationTriggerCategory>.unmodifiable(
        triggerList.map(_triggerCategory).toSet(),
      ),
      integrityTargets: List<InstallationDatabaseKey>.unmodifiable(targets),
    );
  }

  factory StartupValidationTelemetryEvent.integrityCheckStarted({
    required int validationId,
    required DateTime occurredAtUtc,
    required InstallationDatabaseKey database,
  }) {
    return StartupValidationTelemetryEvent._(
      kind: StartupValidationEventKind.integrityCheckStarted,
      validationId: validationId,
      occurredAtUtc: occurredAtUtc,
      database: database,
    );
  }

  factory StartupValidationTelemetryEvent.integrityCheckCompleted({
    required int validationId,
    required DateTime occurredAtUtc,
    required InstallationDatabaseIntegrityValidation result,
    required int durationMicroseconds,
  }) {
    return StartupValidationTelemetryEvent._(
      kind: StartupValidationEventKind.integrityCheckCompleted,
      validationId: validationId,
      occurredAtUtc: occurredAtUtc,
      database: result.database,
      integrityResult: _integrityResult(result),
      integrityFailureKind: result.failureKind,
      sqliteResultCode: result.sqliteResultCode,
      contentionCategory:
          result.status == InstallationIntegrityValidationStatus.contention
          ? StartupValidationContentionCategory.busyOrLocked
          : null,
      durationMicroseconds: durationMicroseconds,
    );
  }

  factory StartupValidationTelemetryEvent.admissionDecided({
    required int validationId,
    required DateTime occurredAtUtc,
    required MessageLensInstallationState installationState,
    required StartupValidationAdmissionOutcome outcome,
    required int totalDurationMicroseconds,
    StartupAdmissionBasis? basis,
    StartupValidationBlockedReasonCode? blockedReasonCode,
  }) {
    return StartupValidationTelemetryEvent._(
      kind: StartupValidationEventKind.admissionDecided,
      validationId: validationId,
      occurredAtUtc: occurredAtUtc,
      installationKind: installationState.kind,
      installationReasonCode: installationState.reasonCode,
      blockedReasonCode: blockedReasonCode,
      admissionBasis: basis,
      admissionOutcome: outcome,
      totalDurationMicroseconds: totalDurationMicroseconds,
    );
  }

  final StartupValidationEventKind kind;
  final int validationId;
  final DateTime occurredAtUtc;
  final ArchiveEnvironment? archiveEnvironment;
  final ArchiveBuildIdentity? buildIdentity;
  final InstallationDatabaseKey? database;
  final bool? databaseExists;
  final int? observedSchemaVersion;
  final int? currentSchemaVersion;
  final StartupValidationSchemaDisposition? schemaDisposition;
  final InstallationBoundedInspectionStatus? boundedInspectionStatus;
  final InstallationBoundedInspectionFailureKind? boundedFailureKind;
  final int? sqliteResultCode;
  final StartupValidationContentionCategory? contentionCategory;
  final int? durationMicroseconds;
  final StartupValidationIntegrityDecision? integrityDecision;
  final List<InstallationIntegrityValidationTrigger> integrityTriggers;
  final List<StartupValidationTriggerCategory> triggerCategories;
  final List<InstallationDatabaseKey> integrityTargets;
  final StartupValidationIntegrityResult? integrityResult;
  final InstallationIntegrityValidationFailureKind? integrityFailureKind;
  final MessageLensInstallationStateKind? installationKind;
  final MessageLensInstallationReasonCode? installationReasonCode;
  final StartupValidationBlockedReasonCode? blockedReasonCode;
  final StartupAdmissionBasis? admissionBasis;
  final StartupValidationAdmissionOutcome? admissionOutcome;
  final int? totalDurationMicroseconds;

  String get eventName {
    return switch (kind) {
      StartupValidationEventKind.validationStarted =>
        'startup_validation_started',
      StartupValidationEventKind.boundedInspectionCompleted =>
        'startup_bounded_inspection_completed',
      StartupValidationEventKind.integrityDecision =>
        'startup_integrity_decision',
      StartupValidationEventKind.integrityCheckStarted =>
        'startup_integrity_check_started',
      StartupValidationEventKind.integrityCheckCompleted =>
        'startup_integrity_check_completed',
      StartupValidationEventKind.admissionDecided =>
        'startup_admission_decided',
    };
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'event': eventName,
      'validation_id': validationId,
      'occurred_at_utc': occurredAtUtc.toIso8601String(),
      if (kind == StartupValidationEventKind.validationStarted) ...{
        'telemetry_schema_version': startupValidationTelemetrySchemaVersion,
        'validation_policy_version': startupValidationPolicyVersion,
      },
      if (archiveEnvironment != null)
        'archive_environment': archiveEnvironment!.serializedName,
      if (buildIdentity != null)
        'build_identity': buildIdentity!.serializedName,
      if (database != null) ...{'database_key': database!.name},
      if (databaseExists != null) 'exists': databaseExists,
      if (observedSchemaVersion != null)
        'observed_schema_version': observedSchemaVersion,
      if (currentSchemaVersion != null)
        'current_schema_version': currentSchemaVersion,
      if (schemaDisposition != null)
        'schema_disposition': schemaDisposition!.name,
      if (boundedInspectionStatus != null)
        'bounded_result': boundedInspectionStatus!.name,
      if (boundedFailureKind != null)
        'bounded_failure_category': boundedFailureKind!.name,
      if (sqliteResultCode != null) 'sqlite_result_code': sqliteResultCode,
      if (contentionCategory != null)
        'contention_category': contentionCategory!.name,
      if (durationMicroseconds != null)
        'duration_microseconds': durationMicroseconds,
      if (integrityDecision != null)
        'integrity_decision': integrityDecision!.name,
      if (integrityTriggers.isNotEmpty)
        'integrity_triggers': integrityTriggers
            .map((value) => value.name)
            .toList(),
      if (triggerCategories.isNotEmpty)
        'trigger_categories': triggerCategories
            .map((value) => value.name)
            .toList(),
      if (integrityTargets.isNotEmpty)
        'integrity_targets': integrityTargets
            .map((value) => value.name)
            .toList(),
      if (integrityResult != null) 'integrity_result': integrityResult!.name,
      if (integrityFailureKind != null)
        'integrity_failure_category': integrityFailureKind!.name,
      if (installationKind != null)
        'installation_classification': installationKind!.name,
      if (installationReasonCode != null)
        'reason_code': installationReasonCode!.name,
      if (blockedReasonCode != null)
        'blocked_reason_code': blockedReasonCode!.name,
      if (admissionBasis != null) 'admission_basis': admissionBasis!.name,
      if (admissionOutcome != null) 'admission_outcome': admissionOutcome!.name,
      if (totalDurationMicroseconds != null)
        'total_duration_microseconds': totalDurationMicroseconds,
    };
  }
}

final class StartupValidationTelemetrySnapshot {
  StartupValidationTelemetrySnapshot({
    required Iterable<StartupValidationTelemetryEvent> events,
  }) : events = List<StartupValidationTelemetryEvent>.unmodifiable(events);

  final List<StartupValidationTelemetryEvent> events;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'telemetry_schema_version': startupValidationTelemetrySchemaVersion,
      'validation_policy_version': startupValidationPolicyVersion,
      'events': events.map((event) => event.toJson()).toList(),
    };
  }
}

abstract interface class StartupValidationTelemetrySnapshotSource {
  StartupValidationTelemetrySnapshot snapshot();
}

StartupValidationSchemaDisposition _schemaDisposition(
  InstallationDatabaseEvidence evidence,
) {
  if (!evidence.exists) {
    return StartupValidationSchemaDisposition.absent;
  }
  if (evidence.boundedInspectionStatus ==
      InstallationBoundedInspectionStatus.unsupportedSchema) {
    return StartupValidationSchemaDisposition.unsupported;
  }
  final observed = evidence.userVersion;
  final current = evidence.currentSchemaVersion;
  if (observed == null || current == null) {
    return StartupValidationSchemaDisposition.unknown;
  }
  if (observed == current) {
    return StartupValidationSchemaDisposition.current;
  }
  if (observed < current) {
    return StartupValidationSchemaDisposition.olderSupported;
  }
  return StartupValidationSchemaDisposition.unsupported;
}

StartupValidationTriggerCategory _triggerCategory(
  InstallationIntegrityValidationTrigger trigger,
) {
  return switch (trigger) {
    InstallationIntegrityValidationTrigger.missingRequiredObject =>
      StartupValidationTriggerCategory.structural,
    InstallationIntegrityValidationTrigger.importGraphLogicalMismatch ||
    InstallationIntegrityValidationTrigger.graphTopologyMismatch =>
      StartupValidationTriggerCategory.logicalReconciliation,
    InstallationIntegrityValidationTrigger.malformedOnboardingSnapshot ||
    InstallationIntegrityValidationTrigger
        .onboardingOperationRequiresValidation =>
      StartupValidationTriggerCategory.onboardingState,
    InstallationIntegrityValidationTrigger.olderSupportedSchema =>
      StartupValidationTriggerCategory.olderSchema,
    InstallationIntegrityValidationTrigger.zeroByteDatabase ||
    InstallationIntegrityValidationTrigger.invalidSqlite ||
    InstallationIntegrityValidationTrigger.sqliteCorrupt ||
    InstallationIntegrityValidationTrigger.ioFailure ||
    InstallationIntegrityValidationTrigger.targetedReadFailure =>
      StartupValidationTriggerCategory.integritySuspicion,
    InstallationIntegrityValidationTrigger.destructiveJournalCompatibility ||
    InstallationIntegrityValidationTrigger.startFreshMutationBoundary ||
    InstallationIntegrityValidationTrigger.explicitRequest ||
    InstallationIntegrityValidationTrigger.unknownFailure =>
      StartupValidationTriggerCategory.other,
  };
}

StartupValidationIntegrityResult _integrityResult(
  InstallationDatabaseIntegrityValidation result,
) {
  if (result.status == InstallationIntegrityValidationStatus.passed) {
    return StartupValidationIntegrityResult.passed;
  }
  if (result.status == InstallationIntegrityValidationStatus.contention) {
    return StartupValidationIntegrityResult.busyOrLocked;
  }
  return switch (result.failureKind) {
    InstallationIntegrityValidationFailureKind.ioFailure =>
      StartupValidationIntegrityResult.ioError,
    InstallationIntegrityValidationFailureKind.unexpectedFailure =>
      StartupValidationIntegrityResult.unexpectedError,
    InstallationIntegrityValidationFailureKind.missingOrEmpty ||
    InstallationIntegrityValidationFailureKind.integrityFailure ||
    InstallationIntegrityValidationFailureKind.sqliteFailure ||
    null => StartupValidationIntegrityResult.failed,
  };
}
