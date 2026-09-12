import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_evidence_reader.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_integrity_validator.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_validation_service.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/onboarding/domain/startup_installation_validation.dart';

void main() {
  group('healthy bounded startup', () {
    test('admits a completed installation without deep validation', () async {
      final validator = _RecordingIntegrityValidator();
      final states = await _service(
        evidence: _healthyEvidence(),
        validator: validator,
      ).validateForStartup(archiveRootPath: '/not-used').toList();

      expect(states.map((state) => state.runtimeType), <Type>[
        StartupBoundedInspectionInProgress,
        StartupBoundedInspectionPassed,
        StartupAdmissionGranted,
      ]);
      expect(validator.calls, isEmpty);
      expect(
        (states.last as StartupAdmissionGranted).basis,
        StartupAdmissionBasis.boundedInspection,
      );
    });
  });

  group('startup escalation policy', () {
    test(
      'missing required object scans only the implicated database',
      () async {
        final validator = _RecordingIntegrityValidator();
        final states = await _service(
          evidence: _healthyEvidence(
            graph: _failedDatabase(
              InstallationBoundedInspectionFailureKind.missingRequiredObject,
            ),
          ),
          validator: validator,
        ).validateForStartup(archiveRootPath: '/not-used').toList();

        expect(validator.calls, <InstallationDatabaseKey>[
          InstallationDatabaseKey.conversationGraph,
        ]);
        expect(states, contains(isA<StartupIntegrityValidationRequired>()));
        expect(states.last, isA<StartupAdmissionWithheld>());
      },
    );

    test(
      'invalid SQLite and targeted-read failures require deep checks',
      () async {
        for (final failureKind in <InstallationBoundedInspectionFailureKind>[
          InstallationBoundedInspectionFailureKind.invalidSqlite,
          InstallationBoundedInspectionFailureKind.targetedReadFailure,
        ]) {
          final validator = _RecordingIntegrityValidator();
          final states = await _service(
            evidence: _healthyEvidence(graph: _failedDatabase(failureKind)),
            validator: validator,
          ).validateForStartup(archiveRootPath: '/not-used').toList();

          expect(validator.calls, <InstallationDatabaseKey>[
            InstallationDatabaseKey.conversationGraph,
          ], reason: failureKind.name);
          expect(
            states
                .whereType<StartupIntegrityValidationRequired>()
                .single
                .requirement
                .triggers,
            contains(
              failureKind ==
                      InstallationBoundedInspectionFailureKind.invalidSqlite
                  ? InstallationIntegrityValidationTrigger.invalidSqlite
                  : InstallationIntegrityValidationTrigger.targetedReadFailure,
            ),
          );
        }
      },
    );

    test(
      'malformed onboarding snapshot targets the overlay database',
      () async {
        final validator = _RecordingIntegrityValidator();
        final states = await _service(
          evidence: _healthyEvidence(
            overlay: const InstallationDatabaseEvidence.passed(userVersion: 8),
            operationSnapshotFailure:
                const InstallationBoundedInspectionFailure(
                  kind: InstallationBoundedInspectionFailureKind
                      .malformedOnboardingSnapshot,
                  message: 'bad snapshot',
                ),
          ),
          validator: validator,
        ).validateForStartup(archiveRootPath: '/not-used').toList();

        expect(validator.calls, <InstallationDatabaseKey>[
          InstallationDatabaseKey.overlay,
        ]);
        expect(states.last, isA<StartupAdmissionWithheld>());
      },
    );

    test('import and graph count mismatch deep-checks both stores', () async {
      final validator = _RecordingIntegrityValidator();
      final states = await _service(
        evidence: _healthyEvidence(
          graph: const InstallationDatabaseEvidence.passed(
            userVersion: 3,
            messageCount: 9,
            chatCount: 2,
            chatMessageEdgeCount: 9,
          ),
        ),
        validator: validator,
      ).validateForStartup(archiveRootPath: '/not-used').toList();

      expect(validator.calls, <InstallationDatabaseKey>[
        InstallationDatabaseKey.sourceScopedImport,
        InstallationDatabaseKey.conversationGraph,
      ]);
      expect(states.last, isA<StartupAdmissionWithheld>());
    });

    test('interrupted onboarding validates every existing store', () async {
      final validator = _RecordingIntegrityValidator();
      final states = await _service(
        evidence: _healthyEvidence(
          overlay: const InstallationDatabaseEvidence.passed(userVersion: 8),
          presence: const InstallationDatabaseEvidence.passed(userVersion: 9),
          operationSnapshot: _interruptedSnapshot(),
        ),
        validator: validator,
      ).validateForStartup(archiveRootPath: '/not-used').toList();

      expect(validator.calls, <InstallationDatabaseKey>[
        InstallationDatabaseKey.overlay,
        InstallationDatabaseKey.sourceScopedImport,
        InstallationDatabaseKey.conversationGraph,
        InstallationDatabaseKey.presence,
      ]);
      expect(states, contains(isA<StartupIntegrityValidationPassed>()));
    });

    test('running and failed onboarding also require validation', () async {
      for (final snapshot in <OnboardingOperationSnapshot>[
        _runningSnapshot(),
        _failedSnapshot(),
      ]) {
        final validator = _RecordingIntegrityValidator();
        final states = await _service(
          evidence: _healthyEvidence(operationSnapshot: snapshot),
          validator: validator,
        ).validateForStartup(archiveRootPath: '/not-used').toList();

        expect(validator.calls, <InstallationDatabaseKey>[
          InstallationDatabaseKey.sourceScopedImport,
          InstallationDatabaseKey.conversationGraph,
        ], reason: snapshot.status.name);
        expect(
          states
              .whereType<StartupIntegrityValidationRequired>()
              .single
              .requirement
              .triggers,
          contains(
            InstallationIntegrityValidationTrigger
                .onboardingOperationRequiresValidation,
          ),
        );
      }
    });

    test('contention blocks without being reported as corruption', () async {
      final validator = _RecordingIntegrityValidator();
      final states = await _service(
        evidence: _healthyEvidence(
          graph: const InstallationDatabaseEvidence(
            boundedInspectionStatus:
                InstallationBoundedInspectionStatus.contention,
            failure: InstallationBoundedInspectionFailure(
              kind: InstallationBoundedInspectionFailureKind.unknown,
              message: 'database is locked',
            ),
          ),
        ),
        validator: validator,
      ).validateForStartup(archiveRootPath: '/not-used').toList();

      expect(validator.calls, isEmpty);
      expect(states.last, isA<StartupValidationBlocked>());
    });

    test('future schema fails closed without a deep check', () async {
      final validator = _RecordingIntegrityValidator();
      final states = await _service(
        evidence: _healthyEvidence(
          graph: const InstallationDatabaseEvidence(
            boundedInspectionStatus:
                InstallationBoundedInspectionStatus.unsupportedSchema,
            userVersion: 4,
            currentSchemaVersion: 3,
          ),
        ),
        validator: validator,
      ).validateForStartup(archiveRootPath: '/not-used').toList();

      expect(validator.calls, isEmpty);
      expect(states.last, isA<StartupAdmissionWithheld>());
    });

    test('older supported schema must pass deep validation', () async {
      final validator = _RecordingIntegrityValidator();
      final states = await _service(
        evidence: _healthyEvidence(
          source: const InstallationDatabaseEvidence.passed(
            userVersion: 9,
            currentSchemaVersion: 10,
            messageCount: 10,
            nonLiveSourceCount: 0,
          ),
        ),
        validator: validator,
      ).validateForStartup(archiveRootPath: '/not-used').toList();

      expect(validator.calls, <InstallationDatabaseKey>[
        InstallationDatabaseKey.sourceScopedImport,
      ]);
      expect(
        states
            .whereType<StartupIntegrityValidationRequired>()
            .single
            .requirement
            .triggers,
        contains(InstallationIntegrityValidationTrigger.olderSupportedSchema),
      );
      expect(states.last, isA<StartupAdmissionGranted>());
    });
  });

  group('deep validation outcomes', () {
    test('physical failure remains restricted', () async {
      final validator = _RecordingIntegrityValidator(
        statuses:
            const <
              InstallationDatabaseKey,
              InstallationIntegrityValidationStatus
            >{
              InstallationDatabaseKey.conversationGraph:
                  InstallationIntegrityValidationStatus.failed,
            },
      );
      final states = await _service(
        evidence: _healthyEvidence(
          graph: _failedDatabase(
            InstallationBoundedInspectionFailureKind.targetedReadFailure,
          ),
        ),
        validator: validator,
      ).validateForStartup(archiveRootPath: '/not-used').toList();

      final failure = states.last as StartupIntegrityValidationFailed;
      expect(
        failure.installationState.kind,
        MessageLensInstallationStateKind.remediationRequired,
      );
      expect(failure.report.passed, isFalse);
    });

    test('deep pass cannot override a structural failure', () async {
      final states = await _service(
        evidence: _healthyEvidence(
          graph: _failedDatabase(
            InstallationBoundedInspectionFailureKind.missingRequiredObject,
          ),
        ),
        validator: _RecordingIntegrityValidator(),
      ).validateForStartup(archiveRootPath: '/not-used').toList();

      expect(states, contains(isA<StartupIntegrityValidationPassed>()));
      expect(states.last, isA<StartupAdmissionWithheld>());
    });
  });
}

MessageLensInstallationValidationService _service({
  required MessageLensInstallationEvidence evidence,
  required MessageLensInstallationIntegrityValidator validator,
}) {
  return MessageLensInstallationValidationService(
    evidenceReader: _FakeEvidenceReader(evidence),
    integrityValidator: validator,
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
  InstallationDatabaseEvidence overlay =
      const InstallationDatabaseEvidence.absent(),
  InstallationDatabaseEvidence presence =
      const InstallationDatabaseEvidence.absent(),
  OnboardingOperationSnapshot operationSnapshot =
      const OnboardingOperationSnapshot.idle(),
  InstallationBoundedInspectionFailure? operationSnapshotFailure,
}) {
  return MessageLensInstallationEvidence(
    sourceScopedImport: source,
    conversationGraph: graph,
    overlay: overlay,
    presence: presence,
    hasRetiredDerivedArtifacts: false,
    operationSnapshot: operationSnapshot,
    operationSnapshotFailure: operationSnapshotFailure,
  );
}

InstallationDatabaseEvidence _failedDatabase(
  InstallationBoundedInspectionFailureKind kind,
) {
  return InstallationDatabaseEvidence(
    boundedInspectionStatus: InstallationBoundedInspectionStatus.failed,
    userVersion: 3,
    currentSchemaVersion: 3,
    failure: InstallationBoundedInspectionFailure(
      kind: kind,
      message: kind.name,
    ),
  );
}

OnboardingOperationSnapshot _interruptedSnapshot() {
  return _runningSnapshot().interrupt(
    observedAtUtc: DateTime.utc(2026, 9, 12, 1),
  );
}

OnboardingOperationSnapshot _runningSnapshot() {
  return OnboardingOperationSnapshot.running(
    operationId: OnboardingOperationId('123e4567-e89b-42d3-a456-426614174030'),
    processSessionId: OnboardingProcessSessionId(
      '123e4567-e89b-42d3-a456-426614174031',
    ),
    kind: OnboardingOperationKind.initialImport,
    stage: OnboardingOperationStage.messageDataBuild,
    observedAtUtc: DateTime.utc(2026, 9, 12),
  );
}

OnboardingOperationSnapshot _failedSnapshot() {
  return _runningSnapshot().fail(
    failure: OnboardingOperationFailure(
      category: OnboardingOperationFailureCategory.messageDataBuild,
      occurredAtUtc: DateTime.utc(2026, 9, 12, 1),
      summary: 'test failure',
      recoveryDisposition:
          OnboardingOperationRecoveryDisposition.retryFromSafeBoundary,
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

final class _RecordingIntegrityValidator
    implements MessageLensInstallationIntegrityValidator {
  _RecordingIntegrityValidator({
    this.statuses =
        const <
          InstallationDatabaseKey,
          InstallationIntegrityValidationStatus
        >{},
  });

  final Map<InstallationDatabaseKey, InstallationIntegrityValidationStatus>
  statuses;
  final calls = <InstallationDatabaseKey>[];

  @override
  Future<InstallationDatabaseIntegrityValidation> validateDatabase({
    required String archiveRootPath,
    required InstallationDatabaseKey database,
  }) async {
    calls.add(database);
    final status =
        statuses[database] ?? InstallationIntegrityValidationStatus.passed;
    return InstallationDatabaseIntegrityValidation(
      database: database,
      status: status,
      failure: status == InstallationIntegrityValidationStatus.passed
          ? null
          : 'test failure',
    );
  }
}
