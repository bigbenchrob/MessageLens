import '../../archive_environment/domain/archive_build_identity.dart';
import '../../archive_environment/domain/archive_environment.dart';
import '../domain/message_lens_installation_state.dart';
import '../domain/startup_installation_validation.dart';
import '../domain/startup_validation_telemetry.dart';
import 'message_lens_installation_evidence_reader.dart';
import 'message_lens_installation_integrity_policy.dart';
import 'message_lens_installation_integrity_validator.dart';
import 'message_lens_installation_state_classifier.dart';
import 'startup_validation_telemetry_buffer.dart';

final class FullInstallationValidationResult {
  const FullInstallationValidationResult({
    required this.evidence,
    required this.installationState,
    required this.integrityReport,
    required this.fullIntegrityValidated,
  });

  final MessageLensInstallationEvidence evidence;
  final MessageLensInstallationState installationState;
  final InstallationIntegrityValidationReport integrityReport;
  final bool fullIntegrityValidated;
}

abstract interface class MessageLensInstallationFullValidator {
  Future<FullInstallationValidationResult> validateFully({
    required String archiveRootPath,
    required InstallationIntegrityValidationTrigger trigger,
  });
}

final class MessageLensInstallationValidationService
    implements MessageLensInstallationFullValidator {
  const MessageLensInstallationValidationService({
    required this.evidenceReader,
    required this.integrityValidator,
    this.classifier = const MessageLensInstallationStateClassifier(),
    this.integrityPolicy = const MessageLensInstallationIntegrityPolicy(),
    this.telemetry,
    this.archiveEnvironment,
    this.buildIdentity,
  });

  final MessageLensInstallationEvidenceReader evidenceReader;
  final MessageLensInstallationIntegrityValidator integrityValidator;
  final MessageLensInstallationStateClassifier classifier;
  final MessageLensInstallationIntegrityPolicy integrityPolicy;
  final StartupValidationTelemetryBuffer? telemetry;
  final ArchiveEnvironment? archiveEnvironment;
  final ArchiveBuildIdentity? buildIdentity;

  Stream<StartupInstallationValidationState> validateForStartup({
    required String archiveRootPath,
  }) async* {
    final validationStopwatch = Stopwatch()..start();
    final validationId = telemetry?.beginValidation(
      archiveEnvironment: archiveEnvironment,
      buildIdentity: buildIdentity,
    );
    yield const StartupBoundedInspectionInProgress();
    final evidence = await evidenceReader.readBounded(
      archiveRootPath: archiveRootPath,
    );
    _recordBoundedInspection(validationId: validationId, evidence: evidence);
    final installationState = classifier.classify(evidence);
    final decision = integrityPolicy.decide(
      evidence: evidence,
      installationState: installationState,
    );

    switch (decision) {
      case StartupIntegrityNotRequired():
        _recordIntegrityDecision(
          validationId: validationId,
          decision: StartupValidationIntegrityDecision.notRequired,
        );
        yield StartupBoundedInspectionPassed(
          installationState: installationState,
        );
        await Future<void>.delayed(Duration.zero);
        final terminalState = _terminalState(
          installationState: installationState,
          basis: StartupAdmissionBasis.boundedInspection,
        );
        _recordTerminalState(
          validationId: validationId,
          terminalState: terminalState,
          validationStopwatch: validationStopwatch,
        );
        yield terminalState;
      case StartupIntegrityRejected():
        _recordIntegrityDecision(
          validationId: validationId,
          decision: _rejectedDecision(evidence),
        );
        final terminalState = StartupAdmissionWithheld(
          installationState: installationState,
          basis: StartupAdmissionBasis.boundedInspection,
        );
        _recordTerminalState(
          validationId: validationId,
          terminalState: terminalState,
          validationStopwatch: validationStopwatch,
        );
        yield terminalState;
      case StartupIntegrityBlocked(:final message):
        _recordIntegrityDecision(
          validationId: validationId,
          decision: StartupValidationIntegrityDecision.blockedByContention,
        );
        _recordBlockedAdmission(
          validationId: validationId,
          installationState: installationState,
          reasonCode:
              StartupValidationBlockedReasonCode.boundedInspectionContention,
          validationStopwatch: validationStopwatch,
        );
        yield StartupValidationBlocked(message: message);
      case StartupIntegrityRequired(:final requirement):
        _recordIntegrityDecision(
          validationId: validationId,
          decision: StartupValidationIntegrityDecision.required,
          requirement: requirement,
        );
        yield StartupIntegrityValidationRequired(requirement: requirement);
        final results = <InstallationDatabaseIntegrityValidation>[];
        for (var index = 0; index < requirement.targets.length; index++) {
          final database = requirement.targets[index];
          yield StartupIntegrityValidationInProgress(
            requirement: requirement,
            currentDatabase: database,
            completedDatabaseCount: index,
          );
          if (validationId != null) {
            telemetry?.record(
              StartupValidationTelemetryEvent.integrityCheckStarted(
                validationId: validationId,
                occurredAtUtc: DateTime.now().toUtc(),
                database: database,
              ),
            );
          }
          final integrityStopwatch = Stopwatch()..start();
          final result = await integrityValidator.validateDatabase(
            archiveRootPath: archiveRootPath,
            database: database,
          );
          integrityStopwatch.stop();
          if (validationId != null) {
            telemetry?.record(
              StartupValidationTelemetryEvent.integrityCheckCompleted(
                validationId: validationId,
                occurredAtUtc: DateTime.now().toUtc(),
                result: result,
                durationMicroseconds: integrityStopwatch.elapsedMicroseconds,
              ),
            );
          }
          results.add(result);
          if (result.status ==
              InstallationIntegrityValidationStatus.contention) {
            _recordBlockedAdmission(
              validationId: validationId,
              installationState: installationState,
              reasonCode:
                  StartupValidationBlockedReasonCode.deepIntegrityContention,
              validationStopwatch: validationStopwatch,
            );
            yield StartupValidationBlocked(
              message:
                  'A deeper database check could not continue because '
                  '${database.name} is busy or locked.',
            );
            return;
          }
        }

        final report = InstallationIntegrityValidationReport(results: results);
        if (!report.passed) {
          const failedState = MessageLensInstallationState(
            kind: MessageLensInstallationStateKind.remediationRequired,
            reason:
                'One or more MessageLens databases failed physical '
                'integrity validation.',
            reasonCode:
                MessageLensInstallationReasonCode.physicalIntegrityFailure,
          );
          _recordAdmission(
            validationId: validationId,
            installationState: failedState,
            outcome: StartupValidationAdmissionOutcome.withheld,
            basis: StartupAdmissionBasis.integrityValidation,
            validationStopwatch: validationStopwatch,
          );
          yield StartupIntegrityValidationFailed(
            installationState: failedState,
            report: report,
          );
          return;
        }

        yield StartupIntegrityValidationPassed(
          installationState: installationState,
          report: report,
        );
        await Future<void>.delayed(Duration.zero);
        final terminalState = _terminalState(
          installationState: installationState,
          basis: StartupAdmissionBasis.integrityValidation,
        );
        _recordTerminalState(
          validationId: validationId,
          terminalState: terminalState,
          validationStopwatch: validationStopwatch,
        );
        yield terminalState;
    }
  }

  @override
  Future<FullInstallationValidationResult> validateFully({
    required String archiveRootPath,
    required InstallationIntegrityValidationTrigger trigger,
  }) async {
    final evidence = await evidenceReader.readBounded(
      archiveRootPath: archiveRootPath,
    );
    final boundedState = classifier.classify(evidence);
    final databases = _databases(evidence);
    final existingTargets = _orderedDatabaseKeys.where(
      (key) => databases[key]?.exists == true,
    );

    final hasUnsupportedOrContendedDatabase = databases.values.any((database) {
      return database.boundedInspectionStatus ==
              InstallationBoundedInspectionStatus.unsupportedSchema ||
          database.boundedInspectionStatus ==
              InstallationBoundedInspectionStatus.contention;
    });
    if (hasUnsupportedOrContendedDatabase) {
      return FullInstallationValidationResult(
        evidence: evidence,
        installationState: boundedState,
        integrityReport: InstallationIntegrityValidationReport(
          results: const <InstallationDatabaseIntegrityValidation>[],
        ),
        fullIntegrityValidated: false,
      );
    }

    final results = <InstallationDatabaseIntegrityValidation>[];
    for (final database in existingTargets) {
      results.add(
        await integrityValidator.validateDatabase(
          archiveRootPath: archiveRootPath,
          database: database,
        ),
      );
    }
    final report = InstallationIntegrityValidationReport(results: results);
    final fullIntegrityValidated = report.passed;
    return FullInstallationValidationResult(
      evidence: evidence,
      installationState: fullIntegrityValidated
          ? boundedState
          : const MessageLensInstallationState(
              kind: MessageLensInstallationStateKind.remediationRequired,
              reason:
                  'One or more MessageLens databases did not pass the required '
                  'physical integrity validation.',
              reasonCode:
                  MessageLensInstallationReasonCode.physicalIntegrityFailure,
            ),
      integrityReport: report,
      fullIntegrityValidated: fullIntegrityValidated,
    );
  }

  StartupInstallationValidationState _terminalState({
    required MessageLensInstallationState installationState,
    required StartupAdmissionBasis basis,
  }) {
    if (installationState.mayContinue) {
      return StartupAdmissionGranted(
        installationState: installationState,
        basis: basis,
      );
    }
    return StartupAdmissionWithheld(
      installationState: installationState,
      basis: basis,
    );
  }

  void _recordBoundedInspection({
    required int? validationId,
    required MessageLensInstallationEvidence evidence,
  }) {
    if (validationId == null) {
      return;
    }
    for (final entry in _databases(evidence).entries) {
      telemetry?.record(
        StartupValidationTelemetryEvent.boundedInspectionCompleted(
          validationId: validationId,
          occurredAtUtc: DateTime.now().toUtc(),
          database: entry.key,
          evidence: entry.value,
        ),
      );
    }
  }

  void _recordIntegrityDecision({
    required int? validationId,
    required StartupValidationIntegrityDecision decision,
    InstallationIntegrityRequirement? requirement,
  }) {
    if (validationId == null) {
      return;
    }
    telemetry?.record(
      StartupValidationTelemetryEvent.integrityDecision(
        validationId: validationId,
        occurredAtUtc: DateTime.now().toUtc(),
        decision: decision,
        triggers:
            requirement?.triggers ??
            const <InstallationIntegrityValidationTrigger>[],
        targets: requirement?.targets ?? const <InstallationDatabaseKey>[],
      ),
    );
  }

  StartupValidationIntegrityDecision _rejectedDecision(
    MessageLensInstallationEvidence evidence,
  ) {
    final hasUnsupportedSchema = _databases(evidence).values.any((database) {
      return database.boundedInspectionStatus ==
          InstallationBoundedInspectionStatus.unsupportedSchema;
    });
    return hasUnsupportedSchema
        ? StartupValidationIntegrityDecision.rejectedUnsupportedSchema
        : StartupValidationIntegrityDecision.rejectedNoExistingTarget;
  }

  void _recordTerminalState({
    required int? validationId,
    required StartupInstallationValidationState terminalState,
    required Stopwatch validationStopwatch,
  }) {
    switch (terminalState) {
      case StartupAdmissionGranted(:final installationState, :final basis):
        _recordAdmission(
          validationId: validationId,
          installationState: installationState,
          outcome: StartupValidationAdmissionOutcome.granted,
          basis: basis,
          validationStopwatch: validationStopwatch,
        );
      case StartupAdmissionWithheld(:final installationState, :final basis):
        _recordAdmission(
          validationId: validationId,
          installationState: installationState,
          outcome: StartupValidationAdmissionOutcome.withheld,
          basis: basis,
          validationStopwatch: validationStopwatch,
        );
      case _:
        throw StateError('Expected a terminal startup admission state.');
    }
  }

  void _recordBlockedAdmission({
    required int? validationId,
    required MessageLensInstallationState installationState,
    required StartupValidationBlockedReasonCode reasonCode,
    required Stopwatch validationStopwatch,
  }) {
    if (validationId == null) {
      return;
    }
    validationStopwatch.stop();
    telemetry?.record(
      StartupValidationTelemetryEvent.admissionDecided(
        validationId: validationId,
        occurredAtUtc: DateTime.now().toUtc(),
        installationState: installationState,
        outcome: StartupValidationAdmissionOutcome.blocked,
        blockedReasonCode: reasonCode,
        totalDurationMicroseconds: validationStopwatch.elapsedMicroseconds,
      ),
    );
  }

  void _recordAdmission({
    required int? validationId,
    required MessageLensInstallationState installationState,
    required StartupValidationAdmissionOutcome outcome,
    required StartupAdmissionBasis basis,
    required Stopwatch validationStopwatch,
  }) {
    if (validationId == null) {
      return;
    }
    validationStopwatch.stop();
    telemetry?.record(
      StartupValidationTelemetryEvent.admissionDecided(
        validationId: validationId,
        occurredAtUtc: DateTime.now().toUtc(),
        installationState: installationState,
        outcome: outcome,
        basis: basis,
        totalDurationMicroseconds: validationStopwatch.elapsedMicroseconds,
      ),
    );
  }
}

const _orderedDatabaseKeys = <InstallationDatabaseKey>[
  InstallationDatabaseKey.overlay,
  InstallationDatabaseKey.sourceScopedImport,
  InstallationDatabaseKey.conversationGraph,
  InstallationDatabaseKey.presence,
];

Map<InstallationDatabaseKey, InstallationDatabaseEvidence> _databases(
  MessageLensInstallationEvidence evidence,
) {
  return <InstallationDatabaseKey, InstallationDatabaseEvidence>{
    InstallationDatabaseKey.overlay: evidence.overlay,
    InstallationDatabaseKey.sourceScopedImport: evidence.sourceScopedImport,
    InstallationDatabaseKey.conversationGraph: evidence.conversationGraph,
    InstallationDatabaseKey.presence: evidence.presence,
  };
}
