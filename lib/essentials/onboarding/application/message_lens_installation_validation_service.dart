import '../domain/message_lens_installation_state.dart';
import '../domain/startup_installation_validation.dart';
import 'message_lens_installation_evidence_reader.dart';
import 'message_lens_installation_integrity_policy.dart';
import 'message_lens_installation_integrity_validator.dart';
import 'message_lens_installation_state_classifier.dart';

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
  });

  final MessageLensInstallationEvidenceReader evidenceReader;
  final MessageLensInstallationIntegrityValidator integrityValidator;
  final MessageLensInstallationStateClassifier classifier;
  final MessageLensInstallationIntegrityPolicy integrityPolicy;

  Stream<StartupInstallationValidationState> validateForStartup({
    required String archiveRootPath,
  }) async* {
    yield const StartupBoundedInspectionInProgress();
    final evidence = await evidenceReader.readBounded(
      archiveRootPath: archiveRootPath,
    );
    final installationState = classifier.classify(evidence);
    final decision = integrityPolicy.decide(
      evidence: evidence,
      installationState: installationState,
    );

    switch (decision) {
      case StartupIntegrityNotRequired():
        yield StartupBoundedInspectionPassed(
          installationState: installationState,
        );
        await Future<void>.delayed(Duration.zero);
        yield _terminalState(
          installationState: installationState,
          basis: StartupAdmissionBasis.boundedInspection,
        );
      case StartupIntegrityRejected():
        yield StartupAdmissionWithheld(
          installationState: installationState,
          basis: StartupAdmissionBasis.boundedInspection,
        );
      case StartupIntegrityBlocked(:final message):
        yield StartupValidationBlocked(message: message);
      case StartupIntegrityRequired(:final requirement):
        yield StartupIntegrityValidationRequired(requirement: requirement);
        final results = <InstallationDatabaseIntegrityValidation>[];
        for (var index = 0; index < requirement.targets.length; index++) {
          final database = requirement.targets[index];
          yield StartupIntegrityValidationInProgress(
            requirement: requirement,
            currentDatabase: database,
            completedDatabaseCount: index,
          );
          final result = await integrityValidator.validateDatabase(
            archiveRootPath: archiveRootPath,
            database: database,
          );
          results.add(result);
          if (result.status ==
              InstallationIntegrityValidationStatus.contention) {
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
          yield StartupIntegrityValidationFailed(
            installationState: const MessageLensInstallationState(
              kind: MessageLensInstallationStateKind.remediationRequired,
              reason:
                  'One or more MessageLens databases failed physical '
                  'integrity validation.',
            ),
            report: report,
          );
          return;
        }

        yield StartupIntegrityValidationPassed(
          installationState: installationState,
          report: report,
        );
        await Future<void>.delayed(Duration.zero);
        yield _terminalState(
          installationState: installationState,
          basis: StartupAdmissionBasis.integrityValidation,
        );
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
