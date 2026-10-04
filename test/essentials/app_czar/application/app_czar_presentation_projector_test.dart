import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_evaluator.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_presentation_projector.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';

void main() {
  const projector = AppCzarPresentationProjector();

  test('readable source copy never asserts Full Disk Access', () {
    final presentation = projector.project(_state(_healthyObservations()));
    final copy = _allCopy(presentation);

    expect(copy, isNot(contains('Full Disk Access')));
    expect(
      presentation.row(AppCzarPresentationRowId.messagesDatabase).value,
      'Readable — 100 messages',
    );
  });

  test('unreadable source does not assert Full Disk Access disabled', () {
    final presentation = projector.project(
      _state(
        _healthyObservations(
          source: const AppCzarSourceObservation(
            condition: AppCzarSourceCondition.accessDenied,
            issue: 'macOS denied access to the Messages database.',
          ),
        ),
      ),
    );

    expect(_allCopy(presentation), isNot(contains('Full Disk Access')));
    expect(
      presentation.row(AppCzarPresentationRowId.messagesDatabase).value,
      'Cannot currently be read',
    );
    expect(
      presentation.diagnosis,
      'The current Messages source cannot be inspected with the available access.',
    );
    expect(presentation.virtualCoordinator, 'Source Access Repair');
  });

  test('healthy FALSE source-ahead fact presents as healthy zero', () {
    final state = _state(_healthyObservations());
    final fact = state.assessment!.fact(AppCzarFactId.sourceAheadOfLocal);
    final row = projector
        .project(state)
        .row(AppCzarPresentationRowId.newMessages);

    expect(fact.truth, AppCzarTruth.falseValue);
    expect(row.value, '0');
    expect(row.detail, 'Source and MessageLens are current.');
    expect(row.significance, AppCzarPresentationSignificance.healthy);
  });

  test('raw FALSE does not generically choose attention significance', () {
    final observations = _healthyObservations(
      importStore: const AppCzarDatabaseObservation.absent(),
      graphStore: const AppCzarDatabaseObservation.absent(),
    );
    final state = _state(observations);
    final importFact = state.assessment!.fact(AppCzarFactId.importStoreHealthy);
    final importRow = projector
        .project(state)
        .row(AppCzarPresentationRowId.importStore);

    expect(importFact.truth, AppCzarTruth.falseValue);
    expect(
      importRow.significance,
      AppCzarPresentationSignificance.informational,
    );
    expect(
      projector
          .project(state)
          .row(AppCzarPresentationRowId.localDataset)
          .significance,
      AppCzarPresentationSignificance.attention,
    );
  });

  test('healthy current state remains cautiously diagnosed', () {
    final presentation = projector.project(_state(_healthyObservations()));

    expect(
      presentation.diagnosis,
      'This appears to be a healthy current MessageLens installation.',
    );
    expect(presentation.virtualCoordinator, 'Operating Session');
  });

  test('positive source delta presents actionable information', () {
    final presentation = projector.project(
      _state(
        _healthyObservations(
          source: const AppCzarSourceObservation(
            condition: AppCzarSourceCondition.readable,
            messageCount: 110,
            maxRowId: 110,
            sampleStable: true,
          ),
        ),
      ),
    );
    final row = presentation.row(AppCzarPresentationRowId.newMessages);

    expect(row.value, '10');
    expect(row.significance, AppCzarPresentationSignificance.informational);
    expect(row.detail, contains('available for MessageLens to update'));
    expect(presentation.virtualCoordinator, 'Data Update');
  });

  test('inconclusive source remains visibly unknown with literal reason', () {
    final presentation = projector.project(
      _state(
        _healthyObservations(
          source: const AppCzarSourceObservation.unknown(
            'The source probe returned no conclusive result.',
          ),
        ),
      ),
    );
    final row = presentation.row(AppCzarPresentationRowId.messagesDatabase);

    expect(row.value, 'Readability unknown');
    expect(row.detail, 'The source probe returned no conclusive result.');
    expect(row.significance, AppCzarPresentationSignificance.unknown);
  });

  test('unavailable source cannot claim count or high-water', () {
    final presentation = projector.project(
      _state(
        _healthyObservations(
          source: const AppCzarSourceObservation(
            condition: AppCzarSourceCondition.unavailable,
            issue: 'The Messages database is unavailable.',
          ),
        ),
      ),
    );
    final row = presentation.row(AppCzarPresentationRowId.messagesDatabase);
    final copy = <String>[row.value, row.detail, ...row.evidence].join(' ');

    expect(copy, isNot(contains('message count')));
    expect(copy, isNot(contains('High-water')));
    expect(copy, isNot(matches(RegExp(r'\b100\b'))));
  });

  test('provenance includes only source evidence that is present', () {
    final readable = projector
        .project(_state(_healthyObservations()))
        .row(AppCzarPresentationRowId.messagesDatabase);
    final unknown = projector
        .project(
          _state(
            _healthyObservations(
              source: const AppCzarSourceObservation.unknown('Probe stopped.'),
            ),
          ),
        )
        .row(AppCzarPresentationRowId.messagesDatabase);

    expect(readable.evidence, contains('Message count: 100.'));
    expect(readable.evidence, contains('High-water: 100.'));
    expect(unknown.evidence, isNot(contains('Message count: 100.')));
    expect(unknown.evidence, isNot(contains('High-water: 100.')));
    expect(unknown.evidence, contains('Probe stopped.'));
  });

  test('each resolved row declares its supporting fact identity', () {
    final presentation = projector.project(_state(_healthyObservations()));

    expect(
      presentation.rows,
      everyElement(
        predicate<AppCzarPresentationRow>((row) => row.factIds.isNotEmpty),
      ),
    );
    expect(
      presentation.row(AppCzarPresentationRowId.newMessages).factIds,
      <AppCzarFactId>[
        AppCzarFactId.sourceLocalDeltaKnown,
        AppCzarFactId.sourceAheadOfLocal,
      ],
    );
  });

  test('pending projection publishes no unsupported evidence', () {
    final presentation = projector.project(AppCzarAssessmentState.initial(7));

    expect(presentation.complete, isFalse);
    expect(
      presentation.rows,
      everyElement(
        predicate<AppCzarPresentationRow>(
          (row) =>
              row.significance == AppCzarPresentationSignificance.pending &&
              row.factIds.isEmpty &&
              row.evidence.isEmpty,
        ),
      ),
    );
  });

  test('complete coverage uses literal N-of-N Fair-Witness copy', () {
    final row = projector
        .project(_state(_healthyObservations()))
        .row(AppCzarPresentationRowId.attachmentCoverage);

    expect(row.value, 'Complete — 4 of 4 required payloads covered');
    expect(row.significance, AppCzarPresentationSignificance.healthy);
  });

  test('incomplete coverage reports only the proven uncovered count', () {
    final row = projector
        .project(
          _state(
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
              ),
            ),
          ),
        )
        .row(AppCzarPresentationRowId.attachmentCoverage);

    expect(row.value, 'Incomplete — 2 required payloads are not covered');
    expect(row.significance, AppCzarPresentationSignificance.attention);
    expect(
      _allCopy(projector.project(_state(_healthyObservations()))),
      isNot(contains('/source/')),
    );
  });

  test('UNKNOWN coverage publishes its bounded literal reason', () {
    final row = projector
        .project(
          _state(
            _healthyObservations(
              attachmentArchive: const AppCzarArchiveObservation(
                condition: AppCzarArchiveCondition.available,
                label: 'Toshiba',
                archiveScopeIdentity: 'test-scope',
                archiveGeneration: 0,
                coverage: AppCzarAttachmentCoverageObservation.unknown(
                  issue: 'Coverage evidence changed during inspection.',
                  archiveScopeIdentity: 'test-scope',
                  archiveGeneration: 0,
                ),
              ),
            ),
          ),
        )
        .row(AppCzarPresentationRowId.attachmentCoverage);

    expect(row.value, 'Could not be established');
    expect(row.detail, 'Coverage evidence changed during inspection.');
    expect(row.significance, AppCzarPresentationSignificance.unknown);
  });

  test('stale COMPLETE evidence presents as UNKNOWN, never healthy', () {
    final row = projector
        .project(
          _state(
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
              ),
            ),
          ),
        )
        .row(AppCzarPresentationRowId.attachmentCoverage);

    expect(row.value, 'Could not be established');
    expect(row.significance, AppCzarPresentationSignificance.unknown);
    expect(row.detail, contains('not coherently bound'));
  });
}

AppCzarAssessmentState _state(AppCzarObservationSet observations) {
  return AppCzarAssessmentState(
    generation: 0,
    root: observations.root,
    source: observations.source,
    importStore: observations.importStore,
    graphStore: observations.graphStore,
    overlay: observations.overlay,
    attachmentArchive: observations.attachmentArchive,
    assessment: const AppCzarEvaluator().evaluate(observations),
  );
}

String _allCopy(AppCzarAssessmentPresentation presentation) {
  return <String>[
    presentation.diagnosis,
    presentation.virtualCoordinator,
    for (final row in presentation.rows)
      <String>[row.label, row.value, row.detail, ...row.evidence].join(' '),
  ].join(' ');
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
  AppCzarArchiveObservation attachmentArchive = const AppCzarArchiveObservation(
    condition: AppCzarArchiveCondition.available,
    label: 'Toshiba',
    resolvedPath: '/Volumes/Toshiba/archive',
    archiveScopeIdentity: 'test-scope',
    archiveGeneration: 0,
    coverage: _completeCoverage,
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
    overlay: const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 8,
    ),
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
