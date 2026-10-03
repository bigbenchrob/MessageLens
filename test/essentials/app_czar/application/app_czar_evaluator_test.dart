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
