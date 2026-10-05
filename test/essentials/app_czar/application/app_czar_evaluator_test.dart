import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_evaluator.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';

void main() {
  const evaluator = AppCzarEvaluator();

  test('same observations always produce the same selection', () {
    final first = evaluator.evaluate(_healthyObservations());
    final second = evaluator.evaluate(_healthyObservations());

    expect(second.diagnosisKind, first.diagnosisKind);
    expect(second.diagnosis, first.diagnosis);
    expect(second.virtualCoordinator, first.virtualCoordinator);
    expect(
      second.facts.map((fact) => fact.truth),
      orderedEquals(first.facts.map((fact) => fact.truth)),
    );
  });

  test('access denial makes only the observable source fact FALSE', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.accessDenied,
          issue: 'Access denied.',
        ),
      ),
    );

    expect(
      assessment.fact(AppCzarFactId.messagesSourceReadable).truth,
      AppCzarTruth.falseValue,
    );
    expect(
      assessment.facts.map((fact) => '${fact.label} ${fact.detail}').join(' '),
      isNot(contains('Full Disk Access')),
    );
    expect(
      assessment.diagnosis,
      'The current Messages source cannot be inspected with the available access.',
    );
  });

  test('healthy current evidence selects only Operating Session', () {
    final assessment = evaluator.evaluate(_healthyObservations());

    expect(
      assessment.diagnosisKind,
      AppCzarDiagnosisKind.healthyCurrentInstallation,
    );
    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.operatingSession,
    );
  });

  test('incomplete local dataset selects only Onboarding', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        importStore: const AppCzarDatabaseObservation.absent(),
        graphStore: const AppCzarDatabaseObservation.absent(),
      ),
    );

    expect(
      assessment.diagnosisKind,
      AppCzarDiagnosisKind.incompleteLocalDataset,
    );
    expect(assessment.virtualCoordinator, AppCzarVirtualCoordinator.onboarding);
  });

  test('absent local dataset reaches Onboarding before coverage UNKNOWN', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        importStore: const AppCzarDatabaseObservation.absent(),
        graphStore: const AppCzarDatabaseObservation.absent(),
        attachmentArchive: const AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.notCreated,
          label: 'Default attachment archive',
          coverage: AppCzarAttachmentCoverageObservation.unknown(
            issue: 'No conversation graph exists yet.',
          ),
        ),
      ),
    );

    expect(assessment.virtualCoordinator, AppCzarVirtualCoordinator.onboarding);
  });

  test('complete data plus inaccessible source selects source repair', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.accessDenied,
          issue: 'Access denied.',
        ),
      ),
    );

    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.sourceAccessRepair,
    );
    expect(
      assessment.diagnosisKind,
      AppCzarDiagnosisKind.sourceAccessUnavailable,
    );
  });

  test('unknown source readability selects diagnostics without denial', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        source: const AppCzarSourceObservation.unknown(
          'The bounded source probe was inconclusive.',
        ),
      ),
    );

    expect(
      assessment.fact(AppCzarFactId.messagesSourceReadable).truth,
      AppCzarTruth.unknown,
    );
    expect(
      assessment.diagnosisKind,
      AppCzarDiagnosisKind.contradictoryOrInsufficientEvidence,
    );
    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.diagnosticReview,
    );
    expect(assessment.diagnosis, isNot(contains('access')));
    expect(assessment.diagnosis, isNot(contains('Full Disk Access')));
  });

  test('readable source never selects source repair', () {
    final assessment = evaluator.evaluate(_healthyObservations());

    expect(
      assessment.fact(AppCzarFactId.messagesSourceReadable).truth,
      AppCzarTruth.trueValue,
    );
    expect(
      assessment.virtualCoordinator,
      isNot(AppCzarVirtualCoordinator.sourceAccessRepair),
    );
  });

  test('unavailable archive wins the current preservation tie rule', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.accessDenied,
          issue: 'Access denied.',
        ),
        attachmentArchive: const AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.unavailable,
          label: 'Toshiba',
          coverage: AppCzarAttachmentCoverageObservation.unknown(
            issue: 'Volume absent.',
          ),
          issue: 'Volume absent.',
        ),
      ),
    );

    expect(
      assessment.diagnosisKind,
      AppCzarDiagnosisKind.attachmentArchiveUnavailable,
    );
    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.attachmentArchiveRepair,
    );
  });

  test('insufficient local evidence selects one diagnostic coordinator', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        graphStore: const AppCzarDatabaseObservation.unknown(
          'Busy during bounded read.',
        ),
      ),
    );

    expect(
      assessment.diagnosisKind,
      AppCzarDiagnosisKind.contradictoryOrInsufficientEvidence,
    );
    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.diagnosticReview,
    );
  });

  test('contradictory high-water evidence fails closed to diagnostics', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.readable,
          messageCount: 99,
          maxRowId: 99,
          sampleStable: true,
        ),
      ),
    );

    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.diagnosticReview,
    );
  });

  test('source ahead of complete local data selects Data Update', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.readable,
          messageCount: 110,
          maxRowId: 110,
          sampleStable: true,
        ),
      ),
    );

    expect(assessment.diagnosisKind, AppCzarDiagnosisKind.sourceAheadOfLocal);
    expect(assessment.virtualCoordinator, AppCzarVirtualCoordinator.dataUpdate);
  });

  test('an unhealthy existing store selects Local Data Repair', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        graphStore: const AppCzarDatabaseObservation(
          condition: AppCzarDatabaseCondition.unhealthy,
          issue: 'Required table missing.',
        ),
      ),
    );

    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.localDataRepair,
    );
  });

  test('default archive not yet created does not invent a repair need', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        attachmentArchive: const AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.notCreated,
          label: 'Default attachment archive',
          resolvedPath: '/tmp/test-archive',
          archiveScopeIdentity: 'test-scope',
          archiveGeneration: 0,
          coverage: _zeroCoverage,
          repairability: _zeroRepairability,
        ),
      ),
    );

    expect(
      assessment.fact(AppCzarFactId.attachmentArchiveAvailable).truth,
      AppCzarTruth.trueValue,
    );
    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.operatingSession,
    );
  });

  test('read-only available archive can prove complete coverage', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        attachmentArchive: const AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.readOnly,
          label: 'Read-only fixture archive',
          resolvedPath: '/tmp/test-archive',
          archiveScopeIdentity: 'test-scope',
          archiveGeneration: 0,
          coverage: _completeCoverage,
          repairability: _completeRepairability,
        ),
      ),
    );

    expect(
      assessment.fact(AppCzarFactId.attachmentArchiveAvailable).truth,
      AppCzarTruth.trueValue,
    );
    expect(
      assessment.fact(AppCzarFactId.attachmentCoverageComplete).truth,
      AppCzarTruth.trueValue,
    );
    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.operatingSession,
    );
  });

  test('incomplete current coverage selects virtual archive repair', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        attachmentArchive: const AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.available,
          label: 'Toshiba',
          archiveScopeIdentity: 'test-scope',
          archiveGeneration: 0,
          coverage: AppCzarAttachmentCoverageObservation(
            condition: AppCzarAttachmentCoverageCondition.incomplete,
            requiredCount: 4,
            coveredCount: 2,
            missingCount: 2,
            unverifiableCount: 0,
            archiveScopeIdentity: 'test-scope',
            archiveGeneration: 0,
          ),
          repairability: AppCzarAttachmentRepairabilityObservation(
            condition: AppCzarAttachmentRepairOpportunityCondition.present,
            availableFromMessagesCount: 2,
            sourceAbsentCount: 0,
            sourceUnknownCount: 0,
            recordBackedRecoveryCount: 0,
            unsafeOrConflictingCount: 0,
            archiveScopeIdentity: 'test-scope',
            archiveGeneration: 0,
          ),
        ),
      ),
    );

    expect(
      assessment.fact(AppCzarFactId.attachmentArchiveAvailable).truth,
      AppCzarTruth.trueValue,
    );
    expect(
      assessment.fact(AppCzarFactId.attachmentCoverageComplete).truth,
      AppCzarTruth.falseValue,
    );
    expect(
      assessment.diagnosisKind,
      AppCzarDiagnosisKind.attachmentArchiveCoverageIncomplete,
    );
    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.attachmentArchiveRepair,
    );
  });

  test('source-access prerequisite remains ahead of coverage repair', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.accessDenied,
          issue: 'Access denied.',
        ),
        attachmentArchive: const AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.available,
          label: 'Toshiba',
          archiveScopeIdentity: 'test-scope',
          archiveGeneration: 0,
          coverage: AppCzarAttachmentCoverageObservation(
            condition: AppCzarAttachmentCoverageCondition.incomplete,
            requiredCount: 1,
            coveredCount: 0,
            missingCount: 1,
            unverifiableCount: 0,
            archiveScopeIdentity: 'test-scope',
            archiveGeneration: 0,
          ),
          repairability: AppCzarAttachmentRepairabilityObservation(
            condition: AppCzarAttachmentRepairOpportunityCondition.present,
            availableFromMessagesCount: 1,
            sourceAbsentCount: 0,
            sourceUnknownCount: 0,
            recordBackedRecoveryCount: 0,
            unsafeOrConflictingCount: 0,
            archiveScopeIdentity: 'test-scope',
            archiveGeneration: 0,
          ),
        ),
      ),
    );

    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.sourceAccessRepair,
    );
  });

  test('stale archive generation cannot authorize complete coverage', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        attachmentArchive: const AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.available,
          label: 'Toshiba',
          archiveScopeIdentity: 'current-scope',
          archiveGeneration: 4,
          coverage: AppCzarAttachmentCoverageObservation(
            condition: AppCzarAttachmentCoverageCondition.complete,
            requiredCount: 1,
            coveredCount: 1,
            missingCount: 0,
            unverifiableCount: 0,
            archiveScopeIdentity: 'current-scope',
            archiveGeneration: 3,
          ),
          repairability: AppCzarAttachmentRepairabilityObservation(
            condition: AppCzarAttachmentRepairOpportunityCondition.absent,
            availableFromMessagesCount: 0,
            sourceAbsentCount: 0,
            sourceUnknownCount: 0,
            recordBackedRecoveryCount: 0,
            unsafeOrConflictingCount: 0,
            archiveScopeIdentity: 'current-scope',
            archiveGeneration: 4,
          ),
        ),
      ),
    );

    expect(
      assessment.fact(AppCzarFactId.attachmentCoverageComplete).truth,
      AppCzarTruth.unknown,
    );
    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.diagnosticReview,
    );
  });

  test('incoherent complete counts cannot authorize Operating', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        attachmentArchive: const AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.available,
          label: 'Toshiba',
          archiveScopeIdentity: 'test-scope',
          archiveGeneration: 0,
          coverage: AppCzarAttachmentCoverageObservation(
            condition: AppCzarAttachmentCoverageCondition.complete,
            requiredCount: 2,
            coveredCount: 1,
            missingCount: 0,
            unverifiableCount: 0,
            archiveScopeIdentity: 'test-scope',
            archiveGeneration: 0,
          ),
          repairability: _zeroRepairability,
        ),
      ),
    );

    expect(
      assessment.fact(AppCzarFactId.attachmentCoverageComplete).truth,
      AppCzarTruth.unknown,
    );
    expect(
      assessment.virtualCoordinator,
      isNot(AppCzarVirtualCoordinator.operatingSession),
    );
  });

  test('UNKNOWN coverage fails closed to diagnostics despite availability', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        attachmentArchive: const AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.available,
          label: 'Toshiba',
          archiveScopeIdentity: 'test-scope',
          archiveGeneration: 0,
          coverage: AppCzarAttachmentCoverageObservation.unknown(
            issue: 'Required evidence changed during inspection.',
            archiveScopeIdentity: 'test-scope',
            archiveGeneration: 0,
          ),
        ),
      ),
    );

    expect(
      assessment.fact(AppCzarFactId.attachmentArchiveAvailable).truth,
      AppCzarTruth.trueValue,
    );
    expect(
      assessment.fact(AppCzarFactId.attachmentCoverageComplete).truth,
      AppCzarTruth.unknown,
    );
    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.diagnosticReview,
    );
  });

  test('known source-absent coverage debt admits Operating literally', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        attachmentArchive: const AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.available,
          label: 'Toshiba',
          resolvedPath: '/Volumes/Toshiba/archive',
          archiveScopeIdentity: 'test-scope',
          archiveGeneration: 0,
          coverage: AppCzarAttachmentCoverageObservation(
            condition: AppCzarAttachmentCoverageCondition.incomplete,
            requiredCount: 18281,
            coveredCount: 4446,
            missingCount: 13835,
            unverifiableCount: 0,
            archiveScopeIdentity: 'test-scope',
            archiveGeneration: 0,
          ),
          repairability: AppCzarAttachmentRepairabilityObservation(
            condition: AppCzarAttachmentRepairOpportunityCondition.absent,
            availableFromMessagesCount: 0,
            sourceAbsentCount: 13835,
            sourceUnknownCount: 0,
            recordBackedRecoveryCount: 0,
            unsafeOrConflictingCount: 0,
            archiveScopeIdentity: 'test-scope',
            archiveGeneration: 0,
          ),
        ),
      ),
    );

    expect(
      assessment.fact(AppCzarFactId.attachmentCoverageComplete).truth,
      AppCzarTruth.falseValue,
    );
    expect(
      assessment.fact(AppCzarFactId.attachmentRepairOpportunityPresent).truth,
      AppCzarTruth.falseValue,
    );
    expect(
      assessment.diagnosisKind,
      AppCzarDiagnosisKind.operatingWithKnownAttachmentDebt,
    );
    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.operatingSession,
    );
  });

  test('unknown source classification fails closed to diagnostics', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        attachmentArchive: const AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.available,
          label: 'Toshiba',
          resolvedPath: '/Volumes/Toshiba/archive',
          archiveScopeIdentity: 'test-scope',
          archiveGeneration: 0,
          coverage: AppCzarAttachmentCoverageObservation(
            condition: AppCzarAttachmentCoverageCondition.incomplete,
            requiredCount: 4,
            coveredCount: 2,
            missingCount: 2,
            unverifiableCount: 0,
            archiveScopeIdentity: 'test-scope',
            archiveGeneration: 0,
          ),
          repairability: AppCzarAttachmentRepairabilityObservation.unknown(
            issue: 'One current payload could not be inspected.',
            availableFromMessagesCount: 0,
            sourceAbsentCount: 1,
            sourceUnknownCount: 1,
            recordBackedRecoveryCount: 0,
            unsafeOrConflictingCount: 0,
            archiveScopeIdentity: 'test-scope',
            archiveGeneration: 0,
          ),
        ),
      ),
    );

    expect(
      assessment.fact(AppCzarFactId.attachmentCoverageComplete).truth,
      AppCzarTruth.falseValue,
    );
    expect(
      assessment.fact(AppCzarFactId.attachmentRepairOpportunityPresent).truth,
      AppCzarTruth.unknown,
    );
    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.diagnosticReview,
    );
  });

  test('record-backed recovery cannot silently admit Operating', () {
    final assessment = evaluator.evaluate(
      _healthyObservations(
        attachmentArchive: const AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.available,
          label: 'Toshiba',
          resolvedPath: '/Volumes/Toshiba/archive',
          archiveScopeIdentity: 'test-scope',
          archiveGeneration: 0,
          coverage: AppCzarAttachmentCoverageObservation(
            condition: AppCzarAttachmentCoverageCondition.incomplete,
            requiredCount: 4,
            coveredCount: 3,
            missingCount: 1,
            unverifiableCount: 0,
            archiveScopeIdentity: 'test-scope',
            archiveGeneration: 0,
          ),
          repairability: AppCzarAttachmentRepairabilityObservation(
            condition: AppCzarAttachmentRepairOpportunityCondition.absent,
            availableFromMessagesCount: 0,
            sourceAbsentCount: 0,
            sourceUnknownCount: 0,
            recordBackedRecoveryCount: 1,
            unsafeOrConflictingCount: 0,
            archiveScopeIdentity: 'test-scope',
            archiveGeneration: 0,
          ),
        ),
      ),
    );

    expect(
      assessment.virtualCoordinator,
      AppCzarVirtualCoordinator.attachmentArchiveRepair,
    );
  });
}

AppCzarObservationSet _healthyObservations({
  AppCzarSourceObservation source = const AppCzarSourceObservation(
    condition: AppCzarSourceCondition.readable,
    messageCount: 100,
    maxRowId: 100,
    sampleStable: true,
  ),
  AppCzarDatabaseObservation importStore = const AppCzarDatabaseObservation(
    condition: AppCzarDatabaseCondition.healthy,
    schemaVersion: 10,
    messageCount: 100,
    liveMessageCount: 100,
    liveMaxSourceRowId: 100,
  ),
  AppCzarDatabaseObservation graphStore = const AppCzarDatabaseObservation(
    condition: AppCzarDatabaseCondition.healthy,
    schemaVersion: 3,
    messageCount: 100,
    chatCount: 4,
    chatMessageEdgeCount: 100,
  ),
  AppCzarDatabaseObservation overlay = const AppCzarDatabaseObservation(
    condition: AppCzarDatabaseCondition.healthy,
    schemaVersion: 8,
  ),
  AppCzarArchiveObservation attachmentArchive = const AppCzarArchiveObservation(
    condition: AppCzarArchiveCondition.available,
    label: 'Toshiba',
    resolvedPath: '/Volumes/Toshiba/archive',
    archiveScopeIdentity: 'test-scope',
    archiveGeneration: 0,
    coverage: _completeCoverage,
    repairability: _completeRepairability,
  ),
}) {
  return AppCzarObservationSet(
    root: const AppCzarRootObservation(
      admitted: true,
      path: '/Volumes/WD_ELEMENTS/MessageLens Development',
    ),
    source: source,
    importStore: importStore,
    graphStore: graphStore,
    overlay: overlay,
    attachmentArchive: attachmentArchive,
  );
}

const _completeCoverage = AppCzarAttachmentCoverageObservation(
  condition: AppCzarAttachmentCoverageCondition.complete,
  requiredCount: 4,
  coveredCount: 4,
  missingCount: 0,
  unverifiableCount: 0,
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
);

const _zeroCoverage = AppCzarAttachmentCoverageObservation(
  condition: AppCzarAttachmentCoverageCondition.complete,
  requiredCount: 0,
  coveredCount: 0,
  missingCount: 0,
  unverifiableCount: 0,
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
);

const _completeRepairability = AppCzarAttachmentRepairabilityObservation(
  condition: AppCzarAttachmentRepairOpportunityCondition.absent,
  availableFromMessagesCount: 0,
  sourceAbsentCount: 0,
  sourceUnknownCount: 0,
  recordBackedRecoveryCount: 0,
  unsafeOrConflictingCount: 0,
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
);

const _zeroRepairability = _completeRepairability;
