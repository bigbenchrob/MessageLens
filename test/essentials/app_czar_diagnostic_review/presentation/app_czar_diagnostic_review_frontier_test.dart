import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_evaluator.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar/presentation/app_czar_startup_harness.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import 'package:remember_this_text/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller.dart';
import 'package:remember_this_text/essentials/app_czar_diagnostic_review/presentation/app_czar_diagnostic_review_screen.dart';

void main() {
  final frontier = _diagnosticFrontier();

  test('the frozen Diagnostic frontier contains the audited 22 cases', () {
    expect(frontier, hasLength(22));
    expect(
      frontier.map((entry) => entry.number),
      orderedEquals(List<int>.generate(22, (index) => index + 1)),
    );
  });

  for (final entry in frontier) {
    testWidgets(
      '${entry.number}. ${entry.name} mounts exactly one Diagnostic host',
      (tester) async {
        final assessment = _state(entry.observations, entry.number);
        expect(
          assessment.assessment!.virtualCoordinator,
          AppCzarVirtualCoordinator.diagnosticReview,
          reason: entry.name,
        );
        expect(shouldExecuteAppCzarDiagnosticReview(assessment), isTrue);

        await tester.pumpWidget(
          ProviderScope(
            overrides: <Override>[
              appCzarAssessmentControllerProvider.overrideWith(
                () => _FixedAssessmentController(assessment),
              ),
              appCzarProcessRestarterProvider.overrideWithValue(
                const _InertRestarter(),
              ),
              appCzarDiagnosticReviewClockProvider.overrideWithValue(
                () => DateTime.utc(2026, 10, 9, 12, entry.number),
              ),
            ],
            child: const AppCzarStartupHarness(),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(AppCzarDiagnosticReviewScreen.screenKey),
          findsOneWidget,
        );
        expect(find.text(assessment.assessment!.diagnosis), findsOneWidget);
        expect(find.byKey(AppCzarAssessmentScreen.screenKey), findsNothing);
        expect(find.byType(AppCzarStartupHarness), findsOneWidget);
      },
    );
  }

  test('conclusive neighboring frontiers retain their exact owners', () {
    final cases = <String, (AppCzarObservationSet, AppCzarVirtualCoordinator)>{
      'archive unavailable': (
        _observations(archive: _unavailableArchive),
        AppCzarVirtualCoordinator.attachmentArchiveRepair,
      ),
      'safe-empty construction': (
        _safeEmptyObservations(),
        AppCzarVirtualCoordinator.onboarding,
      ),
      'reconstructible partial local data': (
        _partialObservations(safety: _reconstructibleSafety),
        AppCzarVirtualCoordinator.localDataRepair,
      ),
      'source access denied': (
        _observations(
          source: const AppCzarSourceObservation(
            condition: AppCzarSourceCondition.accessDenied,
            issue: 'The bounded source read was denied.',
          ),
        ),
        AppCzarVirtualCoordinator.sourceAccessRepair,
      ),
      'actionable attachment work': (
        _observations(archive: _actionableArchive),
        AppCzarVirtualCoordinator.attachmentArchiveRepair,
      ),
      'source ahead': (
        _observations(
          source: const AppCzarSourceObservation(
            condition: AppCzarSourceCondition.readable,
            messageCount: 101,
            maxRowId: 101,
            sampleStable: true,
          ),
        ),
        AppCzarVirtualCoordinator.dataUpdate,
      ),
      'healthy Operating': (
        _observations(),
        AppCzarVirtualCoordinator.operatingSession,
      ),
      'Operating with conclusive source-absent debt': (
        _observations(archive: _sourceAbsentDebtArchive),
        AppCzarVirtualCoordinator.operatingSession,
      ),
    };

    for (final MapEntry(key: name, value: value) in cases.entries) {
      expect(
        const AppCzarEvaluator().evaluate(value.$1).virtualCoordinator,
        value.$2,
        reason: name,
      );
    }
  });
}

List<_FrontierCase> _diagnosticFrontier() {
  return <_FrontierCase>[
    _FrontierCase(
      1,
      'root observation is not admitted',
      _observations(
        root: const AppCzarRootObservation(
          admitted: false,
          path: '/test/rejected-root',
        ),
      ),
    ),
    _FrontierCase(
      2,
      'initial-construction scope is unknown',
      _observations(
        scope: const AppCzarInitialConstructionScopeObservation.unknown(
          'The bounded scope read did not complete.',
        ),
      ),
    ),
    _FrontierCase(
      3,
      'initial scope contains retired or unsupported material',
      _observations(
        scope: const AppCzarInitialConstructionScopeObservation(
          condition: AppCzarInitialConstructionScopeCondition
              .retiredOrUnsupportedMaterial,
          importMessageCount: 100,
          graphMessageCount: 100,
          graphChatCount: 4,
          graphEdgeCount: 100,
          nonLiveSourceCount: 0,
          hasRetiredDerivedArtifacts: true,
          issue: 'Retired derived material is present.',
        ),
      ),
    ),
    _FrontierCase(
      4,
      'initial scope is unhealthy',
      _observations(
        scope: const AppCzarInitialConstructionScopeObservation(
          condition: AppCzarInitialConstructionScopeCondition.unhealthy,
          importMessageCount: null,
          graphMessageCount: null,
          graphChatCount: null,
          graphEdgeCount: null,
          nonLiveSourceCount: null,
          hasRetiredDerivedArtifacts: false,
          issue: 'A required store failed bounded inspection.',
        ),
      ),
    ),
    _FrontierCase(
      5,
      'a local store is unhealthy',
      _observations(
        importStore: const AppCzarDatabaseObservation(
          condition: AppCzarDatabaseCondition.unhealthy,
          issue: 'SQLite reported that the file is not a database.',
        ),
      ),
    ),
    _FrontierCase(
      6,
      'a local store is unknown',
      _observations(
        graphStore: const AppCzarDatabaseObservation.unknown(
          'The graph store could not be inspected.',
        ),
      ),
    ),
    _FrontierCase(
      7,
      'archive availability is unknown',
      _observations(
        archive: AppCzarArchiveObservation.unknown(
          'The configured archive could not be assessed.',
        ),
      ),
    ),
    _FrontierCase(
      8,
      'safe-empty archive binding is incomplete',
      _safeEmptyObservations(
        archive: const AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.available,
          label: 'Unbound archive',
          archiveScopeIdentity: 'test-scope',
          archiveGeneration: 0,
          coverage: _zeroCoverage,
          repairability: _zeroRepairability,
        ),
      ),
    ),
    _FrontierCase(
      9,
      'safe-empty Contacts evidence is invalid',
      _safeEmptyObservations(
        contacts: const AppCzarContactsPrerequisiteObservation(
          condition: AppCzarContactsPrerequisiteCondition.invalidOrCorrupt,
          issue: 'The Contacts store is invalid.',
        ),
      ),
    ),
    _FrontierCase(
      10,
      'safe-empty source readability is unknown',
      _safeEmptyObservations(
        source: const AppCzarSourceObservation.unknown(
          'The current source read was inconclusive.',
        ),
      ),
    ),
    _FrontierCase(
      11,
      'safe-empty source sample is unstable',
      _safeEmptyObservations(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.readable,
          messageCount: 100,
          maxRowId: 100,
          sampleStable: false,
          issue: 'The two bounded samples differed.',
        ),
      ),
    ),
    _FrontierCase(
      12,
      'partial protected data is not proven reconstructible',
      _partialObservations(safety: _protectedSafety),
    ),
    _FrontierCase(
      13,
      'established-dataset source readability is unknown',
      _observations(
        source: const AppCzarSourceObservation.unknown(
          'The current source read was inconclusive.',
        ),
      ),
    ),
    _FrontierCase(
      14,
      'established-dataset source sample is unstable',
      _observations(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.readable,
          messageCount: 100,
          maxRowId: 100,
          sampleStable: false,
          issue: 'The two bounded samples differed.',
        ),
      ),
    ),
    _FrontierCase(
      15,
      'inspected import and graph do not prove one complete dataset',
      _partialObservations(
        graphStore: const AppCzarDatabaseObservation(
          condition: AppCzarDatabaseCondition.healthy,
          schemaVersion: 3,
          messageCount: 99,
          chatCount: 4,
          chatMessageEdgeCount: 99,
        ),
      ),
    ),
    _FrontierCase(
      16,
      'coverage binding is incoherent',
      _observations(archive: _staleCoverageArchive),
    ),
    _FrontierCase(
      17,
      'repairability binding is incoherent',
      _observations(archive: _staleRepairabilityArchive),
    ),
    _FrontierCase(
      18,
      'incomplete coverage has unsafe current evidence',
      _observations(archive: _unsafeIncompleteArchive),
    ),
    _FrontierCase(
      19,
      'complete coverage conflicts with repairability evidence',
      _observations(archive: _completeCoverageConflictArchive),
    ),
    _FrontierCase(
      20,
      'source and local delta comparability is not established',
      _observations(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.readable,
          messageCount: 100,
          sampleStable: true,
        ),
      ),
    ),
    _FrontierCase(
      21,
      'source count and high-water are behind local evidence',
      _observations(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.readable,
          messageCount: 99,
          maxRowId: 99,
          sampleStable: true,
        ),
      ),
    ),
    _FrontierCase(
      22,
      'late authentic archive location binding is missing',
      _observations(archive: _missingLocationArchive),
    ),
  ];
}

AppCzarObservationSet _observations({
  AppCzarRootObservation root = const AppCzarRootObservation(
    admitted: true,
    path: '/test/root',
  ),
  AppCzarInitialConstructionScopeObservation scope = _consequentialScope,
  AppCzarSourceObservation source = _settledSource,
  AppCzarContactsPrerequisiteObservation contacts = _viableContacts,
  AppCzarDatabaseObservation importStore = _healthyImport,
  AppCzarDatabaseObservation graphStore = _healthyGraph,
  AppCzarDatabaseObservation overlay = _healthyOverlay,
  AppCzarArchiveObservation archive = _completeArchive,
  AppCzarLocalDataRepairSafetyObservation safety = _unknownSafety,
}) {
  return AppCzarObservationSet(
    root: root,
    initialConstructionScope: scope,
    source: source,
    contactsPrerequisite: contacts,
    importStore: importStore,
    graphStore: graphStore,
    overlay: overlay,
    attachmentArchive: archive,
    localDataRepairSafety: safety,
  );
}

AppCzarObservationSet _safeEmptyObservations({
  AppCzarSourceObservation source = _settledSource,
  AppCzarContactsPrerequisiteObservation contacts = _viableContacts,
  AppCzarArchiveObservation archive = _completeArchive,
}) {
  return _observations(
    scope: _safeEmptyScope,
    source: source,
    contacts: contacts,
    importStore: const AppCzarDatabaseObservation.absent(),
    graphStore: const AppCzarDatabaseObservation.absent(),
    overlay: const AppCzarDatabaseObservation.absent(),
    archive: archive,
  );
}

AppCzarObservationSet _partialObservations({
  AppCzarDatabaseObservation graphStore =
      const AppCzarDatabaseObservation.absent(),
  AppCzarLocalDataRepairSafetyObservation safety = _unknownSafety,
}) {
  return _observations(
    scope: const AppCzarInitialConstructionScopeObservation(
      condition: AppCzarInitialConstructionScopeCondition.consequentialData,
      importMessageCount: 1,
      graphMessageCount: 0,
      graphChatCount: 0,
      graphEdgeCount: 0,
      nonLiveSourceCount: 0,
      hasRetiredDerivedArtifacts: false,
      issue: 'Consequential partial data is present.',
    ),
    importStore: const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 10,
      messageCount: 1,
      liveMessageCount: 1,
      liveMaxSourceRowId: 1,
    ),
    graphStore: graphStore,
    safety: safety,
  );
}

AppCzarAssessmentState _state(
  AppCzarObservationSet observations,
  int generation,
) {
  return AppCzarAssessmentState(
    generation: generation,
    root: observations.root,
    initialConstructionScope: observations.initialConstructionScope,
    source: observations.source,
    contactsPrerequisite: observations.contactsPrerequisite,
    importStore: observations.importStore,
    graphStore: observations.graphStore,
    overlay: observations.overlay,
    attachmentArchive: observations.attachmentArchive,
    localDataRepairSafety: observations.localDataRepairSafety,
    assessment: const AppCzarEvaluator().evaluate(observations),
  );
}

final class _FrontierCase {
  const _FrontierCase(this.number, this.name, this.observations);

  final int number;
  final String name;
  final AppCzarObservationSet observations;
}

final class _FixedAssessmentController extends AppCzarAssessmentController {
  _FixedAssessmentController(this._assessment);

  final AppCzarAssessmentState _assessment;

  @override
  AppCzarAssessmentState build() => _assessment;
}

final class _InertRestarter implements AppCzarProcessRestarter {
  const _InertRestarter();

  @override
  Future<void> restartAndReassess() async {}
}

const _settledSource = AppCzarSourceObservation(
  condition: AppCzarSourceCondition.readable,
  messageCount: 100,
  maxRowId: 100,
  sampleStable: true,
);

const _healthyImport = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  schemaVersion: 10,
  messageCount: 100,
  liveMessageCount: 100,
  liveMaxSourceRowId: 100,
);

const _healthyGraph = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  schemaVersion: 3,
  messageCount: 100,
  chatCount: 4,
  chatMessageEdgeCount: 100,
);

const _healthyOverlay = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  schemaVersion: 8,
);

const _viableContacts = AppCzarContactsPrerequisiteObservation(
  condition: AppCzarContactsPrerequisiteCondition.viableEmpty,
  contactCount: 0,
  viableStoreCount: 1,
);

const _consequentialScope = AppCzarInitialConstructionScopeObservation(
  condition: AppCzarInitialConstructionScopeCondition.consequentialData,
  importMessageCount: 100,
  graphMessageCount: 100,
  graphChatCount: 4,
  graphEdgeCount: 100,
  nonLiveSourceCount: 0,
  hasRetiredDerivedArtifacts: false,
  issue: 'A complete local dataset is present.',
);

const _safeEmptyScope = AppCzarInitialConstructionScopeObservation(
  condition: AppCzarInitialConstructionScopeCondition.safeEmpty,
  importMessageCount: 0,
  graphMessageCount: 0,
  graphChatCount: 0,
  graphEdgeCount: 0,
  nonLiveSourceCount: 0,
  hasRetiredDerivedArtifacts: false,
  issue: null,
);

const _completeCoverage = AppCzarAttachmentCoverageObservation(
  condition: AppCzarAttachmentCoverageCondition.complete,
  requiredCount: 1,
  coveredCount: 1,
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

const _zeroRepairability = AppCzarAttachmentRepairabilityObservation(
  condition: AppCzarAttachmentRepairOpportunityCondition.absent,
  availableFromMessagesCount: 0,
  sourceAbsentCount: 0,
  sourceUnknownCount: 0,
  recordBackedRecoveryCount: 0,
  unsafeOrConflictingCount: 0,
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
);

const _completeArchive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.available,
  label: 'Test archive',
  resolvedPath: '/test/archive',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
  coverage: _completeCoverage,
  repairability: _zeroRepairability,
);

const _unavailableArchive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.unavailable,
  label: 'Unavailable archive',
  coverage: AppCzarAttachmentCoverageObservation.unknown(
    issue: 'The archive is unavailable.',
  ),
  issue: 'The archive is unavailable.',
);

const _actionableArchive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.available,
  label: 'Actionable archive',
  resolvedPath: '/test/archive',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
  coverage: AppCzarAttachmentCoverageObservation(
    condition: AppCzarAttachmentCoverageCondition.incomplete,
    requiredCount: 2,
    coveredCount: 1,
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
);

const _sourceAbsentDebtArchive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.available,
  label: 'Debt archive',
  resolvedPath: '/test/archive',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
  coverage: AppCzarAttachmentCoverageObservation(
    condition: AppCzarAttachmentCoverageCondition.incomplete,
    requiredCount: 3,
    coveredCount: 1,
    missingCount: 2,
    unverifiableCount: 0,
    archiveScopeIdentity: 'test-scope',
    archiveGeneration: 0,
  ),
  repairability: AppCzarAttachmentRepairabilityObservation(
    condition: AppCzarAttachmentRepairOpportunityCondition.absent,
    availableFromMessagesCount: 0,
    sourceAbsentCount: 2,
    sourceUnknownCount: 0,
    recordBackedRecoveryCount: 0,
    unsafeOrConflictingCount: 0,
    archiveScopeIdentity: 'test-scope',
    archiveGeneration: 0,
  ),
);

const _staleCoverageArchive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.available,
  label: 'Stale coverage archive',
  resolvedPath: '/test/archive',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 1,
  coverage: _completeCoverage,
  repairability: AppCzarAttachmentRepairabilityObservation(
    condition: AppCzarAttachmentRepairOpportunityCondition.absent,
    availableFromMessagesCount: 0,
    sourceAbsentCount: 0,
    sourceUnknownCount: 0,
    recordBackedRecoveryCount: 0,
    unsafeOrConflictingCount: 0,
    archiveScopeIdentity: 'test-scope',
    archiveGeneration: 1,
  ),
);

const _staleRepairabilityArchive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.available,
  label: 'Stale repairability archive',
  resolvedPath: '/test/archive',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
  coverage: _completeCoverage,
  repairability: AppCzarAttachmentRepairabilityObservation(
    condition: AppCzarAttachmentRepairOpportunityCondition.absent,
    availableFromMessagesCount: 0,
    sourceAbsentCount: 0,
    sourceUnknownCount: 0,
    recordBackedRecoveryCount: 0,
    unsafeOrConflictingCount: 0,
    archiveScopeIdentity: 'test-scope',
    archiveGeneration: 1,
  ),
);

const _unsafeIncompleteArchive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.available,
  label: 'Unsafe incomplete archive',
  resolvedPath: '/test/archive',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
  coverage: AppCzarAttachmentCoverageObservation(
    condition: AppCzarAttachmentCoverageCondition.incomplete,
    requiredCount: 2,
    coveredCount: 1,
    missingCount: 1,
    unverifiableCount: 0,
    archiveScopeIdentity: 'test-scope',
    archiveGeneration: 0,
  ),
  repairability: AppCzarAttachmentRepairabilityObservation.unknown(
    issue: 'One uncovered payload has conflicting current evidence.',
    availableFromMessagesCount: 0,
    sourceAbsentCount: 0,
    sourceUnknownCount: 0,
    recordBackedRecoveryCount: 0,
    unsafeOrConflictingCount: 1,
    archiveScopeIdentity: 'test-scope',
    archiveGeneration: 0,
  ),
);

const _completeCoverageConflictArchive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.available,
  label: 'Conflicting complete archive',
  resolvedPath: '/test/archive',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
  coverage: _completeCoverage,
  repairability: AppCzarAttachmentRepairabilityObservation.unknown(
    issue: 'Repairability evidence conflicts with complete coverage.',
    availableFromMessagesCount: 1,
    sourceAbsentCount: 0,
    sourceUnknownCount: 0,
    recordBackedRecoveryCount: 0,
    unsafeOrConflictingCount: 0,
    archiveScopeIdentity: 'test-scope',
    archiveGeneration: 0,
  ),
);

const _missingLocationArchive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.available,
  label: 'Location-less archive',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
  coverage: _completeCoverage,
  repairability: _zeroRepairability,
);

const _unknownSafety = AppCzarLocalDataRepairSafetyObservation.unknown(
  issue: 'Local repair safety is not required for this complete dataset.',
);

const _protectedSafety = AppCzarLocalDataRepairSafetyObservation(
  condition: AppCzarLocalDataRepairSafetyCondition.protectedMaterialPresent,
  archiveRootPath: '/test/root',
  archiveInstanceId: 'test-instance',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
  sourceFingerprint: null,
  evidenceFingerprint: null,
  resetFootprint: <String>[],
  consequentialRowCounts: <String, int>{'messages': 1},
  issue: 'Protected material is present.',
);

const _reconstructibleSafety = AppCzarLocalDataRepairSafetyObservation(
  condition: AppCzarLocalDataRepairSafetyCondition.rebuildableLiveOnlyPartial,
  archiveRootPath: '/test/root',
  archiveInstanceId: 'test-instance',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
  sourceFingerprint: 'source-fingerprint',
  evidenceFingerprint: 'evidence-fingerprint',
  resetFootprint: <String>['macos_import_ss.db', 'working_ss.db'],
  consequentialRowCounts: <String, int>{'messages': 1},
);
