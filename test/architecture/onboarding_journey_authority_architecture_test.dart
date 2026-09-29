import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_test/flutter_test.dart';

const _rawConversationGraphControllerPath =
    'lib/essentials/conversation_graph/application/'
    'conversation_graph_build_controller_provider.dart';
const _rawConversationGraphBarrelPath =
    'lib/essentials/conversation_graph/feature_level_providers.dart';
const _overlayFailureStoragePath =
    'lib/essentials/onboarding/infrastructure/persistence/'
    'overlay_onboarding_failure_storage.dart';
const _attachmentLocationProviderPath =
    'lib/features/attachments/application/'
    'attachment_archive_location_provider.dart';
const _attachmentLocationControllerPath =
    'lib/features/attachments/application/'
    'attachment_archive_location_controller.dart';
const _onboardingSemanticTrustedBoundaries = <String>{
  'lib/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart',
  'lib/essentials/onboarding/domain/onboarding_journey_state.dart',
  'lib/essentials/onboarding/domain/onboarding_journey_operation_projection.dart',
  'lib/essentials/onboarding/feature_level_providers.dart',
  'lib/essentials/logging/feature_level_providers.dart',
  'lib/essentials/navigation/application/panel_coordinator_provider.dart',
  'lib/essentials/navigation/application/panel_widget_providers.dart',
  'lib/essentials/sidebar/application/sidebar_action_dispatcher.dart',
  'lib/essentials/onboarding/presentation/onboarding_dev_panel.dart',
  'lib/essentials/onboarding/application/onboarding_dev_panel_actions_provider.dart',
  'lib/essentials/onboarding/presentation/advanced_start_fresh_overlay.dart',
  'lib/essentials/onboarding/application/start_fresh_service_provider.dart',
  'lib/essentials/conversation_graph/presentation/status/conversation_graph_status_sheet.dart',
  'lib/features/settings/application/historical_archives_workflow_panel_model_provider.dart',
  // The shell composes the ordinary conversations UI as well as onboarding.
  // Conversation rendering may legitimately use the graph but is not an
  // onboarding semantic adapter or evidence path.
  'lib/essentials/navigation/presentation/layout/search_page_conversation_track_occupants.dart',
  'lib/features/messages/presentation/layout/unfamiliar_sources_message_track_occupants.dart',
  'lib/features/messages/presentation/layout/search_page_message_evidence_track_occupants.dart',
  'lib/features/messages/presentation/layout/contacts_page_message_track_occupants.dart',
  'lib/features/messages/presentation/layout/recovered_messages_page_track_occupants.dart',
  'lib/features/conversations/presentation/layout/contacts_page_conversation_track_occupants.dart',
  'lib/features/conversations/presentation/widgets/conversation_signature_card.dart',
};
const _onboardingSemanticAuditRootExclusions = <String>{
  'lib/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart',
  'lib/essentials/onboarding/presentation/onboarding_dev_panel.dart',
};
const _primaryOnboardingEvidenceImplementationPaths = <String>{
  'lib/essentials/onboarding/application/full_disk_access_provider.dart',
  'lib/essentials/onboarding/application/onboarding_environment_report_provider.dart',
  'lib/essentials/onboarding/application/onboarding_operation_snapshot_provider.dart',
  'lib/essentials/onboarding/application/onboarding_operation_snapshot_controller.dart',
  'lib/essentials/onboarding/application/onboarding_operation_reconciliation.dart',
  _rawConversationGraphControllerPath,
  _rawConversationGraphBarrelPath,
};

void main() {
  const journeyStatePath =
      'lib/essentials/onboarding/domain/onboarding_journey_state.dart';
  const projectionPath =
      'lib/essentials/onboarding/domain/'
      'onboarding_journey_operation_projection.dart';
  const coordinatorPath =
      'lib/essentials/onboarding/application/'
      'onboarding_journey_coordinator_provider.dart';
  const environmentReportPath =
      'lib/essentials/onboarding/application/'
      'onboarding_environment_report_provider.dart';
  const coordinatorTestPath =
      'test/essentials/onboarding/application/'
      'onboarding_journey_coordinator_provider_test.dart';
  const overlayPath =
      'lib/essentials/onboarding/presentation/onboarding_overlay.dart';
  const shellPath =
      'lib/essentials/navigation/presentation/view/macos_app_shell.dart';
  const centerPanelObserverPath =
      'lib/essentials/navigation/presentation/widgets/'
      'onboarding_center_panel_sync_observer.dart';
  const panelCoordinatorPath =
      'lib/essentials/navigation/application/panel_coordinator_provider.dart';
  const panelWidgetProvidersPath =
      'lib/essentials/navigation/application/panel_widget_providers.dart';
  const sidebarActionDispatcherPath =
      'lib/essentials/sidebar/application/sidebar_action_dispatcher.dart';
  const advancedStartFreshPath =
      'lib/essentials/onboarding/presentation/'
      'advanced_start_fresh_overlay.dart';
  const readinessPanelPath =
      'lib/features/environment_readiness/presentation/view/'
      'environment_readiness_panel_view.dart';
  const pipelineIncidentPanelPath =
      'lib/features/environment_readiness/presentation/view/'
      'pipeline_incident_panel_view.dart';
  const devPanelPath =
      'lib/essentials/onboarding/presentation/onboarding_dev_panel.dart';
  const devPanelActionsPath =
      'lib/essentials/onboarding/application/'
      'onboarding_dev_panel_actions_provider.dart';
  const onboardingBarrelPath =
      'lib/essentials/onboarding/feature_level_providers.dart';
  const loggingBarrelPath =
      'lib/essentials/logging/feature_level_providers.dart';
  const startFreshProviderPath =
      'lib/essentials/onboarding/application/start_fresh_service_provider.dart';
  const graphStatusSheetPath =
      'lib/essentials/conversation_graph/presentation/status/'
      'conversation_graph_status_sheet.dart';
  const historicalArchivesWorkflowModelPath =
      'lib/features/settings/application/'
      'historical_archives_workflow_panel_model_provider.dart';

  test(
    'production onboarding semantic dependencies terminate at Journey state',
    () {
      const evidenceImplementationPaths =
          _primaryOnboardingEvidenceImplementationPaths;
      const intentAdapterEvidencePaths = <String>{
        ...evidenceImplementationPaths,
      };
      const trustedBoundaries = _onboardingSemanticTrustedBoundaries;
      final productionSurfaces = _productionOnboardingSemanticConsumerPaths(
        sourceReader: _readSource,
      );

      expect(productionSurfaces, contains(overlayPath));
      expect(productionSurfaces, contains(advancedStartFreshPath));
      expect(productionSurfaces, contains(readinessPanelPath));
      expect(productionSurfaces, contains(pipelineIncidentPanelPath));
      expect(productionSurfaces, contains(shellPath));
      expect(productionSurfaces, contains(centerPanelObserverPath));

      for (final root in productionSurfaces) {
        if (trustedBoundaries.contains(root) ||
            _onboardingSemanticAuditRootExclusions.contains(root)) {
          continue;
        }
        final traversal = _transitiveLocalDependencies(
          root,
          stopAt: trustedBoundaries,
          stopWhen: (path) => _isTransitivelySafeIntentAdapter(
            path,
            evidenceImplementationPaths: intentAdapterEvidencePaths,
            trustedBoundaries: trustedBoundaries,
            dependencyReader: _localDependencies,
            sourceReader: _readSource,
          ),
        );
        final sideDoors = traversal.dependencies
            .where(evidenceImplementationPaths.contains)
            .toList(growable: false);
        expect(
          sideDoors,
          isEmpty,
          reason:
              '$root reaches raw Onboarding evidence outside the Journey '
              'authority boundary:\n${sideDoors.map(traversal.chainTo).join('\n')}',
        );
        final semanticDependencies = traversal.dependencies.where((path) {
          final source = _readSource(path);
          return _sourceConsumesJourneySemantics(source) ||
              source.contains('FutureOr<void> build()');
        });
        final unlawfulBarrelImports = _unlawfulOnboardingBarrelImports(
          semanticDependencies,
          sourceReader: _readSource,
        );
        expect(
          unlawfulBarrelImports,
          isEmpty,
          reason:
              '$root reaches the Onboarding provider barrel without a narrow '
              'Journey/intent-only import:\n${unlawfulBarrelImports.map((finding) {
                final path = finding.split(' imports').first;
                return '${traversal.chainTo(path)}\n$finding';
              }).join('\n')}',
        );
        final unlawfulLoggingImports = _unlawfulLoggingBarrelImports(
          semanticDependencies,
          sourceReader: _readSource,
        );
        expect(
          unlawfulLoggingImports,
          isEmpty,
          reason:
              '$root reaches the Logging provider barrel without a narrow '
              'diagnostic/intent import:\n${unlawfulLoggingImports.join('\n')}',
        );

        expect(
          _sourceConsumesJourneySemantics(_readSource(root)),
          isTrue,
          reason: '$root must be a mechanically discovered semantic consumer.',
        );
      }
    },
  );

  test('overlay renders typed Journey state and its operation projection', () {
    final overlay = File(overlayPath).readAsStringSync();

    expect(overlay, contains('onboardingJourneyCoordinatorProvider'));
    expect(overlay, contains('OnboardingJourneyOperationProjection'));
    expect(overlay, isNot(contains('onboardingGateProvider')));
    expect(overlay, isNot(contains('switch (status)')));
  });

  test('every active operation Episode requires a bound projection', () {
    final journeyState = File(journeyStatePath).readAsStringSync();
    final projection = File(projectionPath).readAsStringSync();

    expect(
      projection,
      contains('final class OnboardingJourneyOperationProjection'),
    );
    expect(projection, contains('final OnboardingOperationId operationId'));
    for (final episode in <String>[
      'OnboardingRecoveringDerivedData',
      'OnboardingPreparingImport',
      'OnboardingBuildingLocalData',
      'OnboardingVerifyingDurableReadiness',
      'OnboardingOperationInterrupted',
      'OnboardingReimporting',
      'OnboardingReadyToStart',
      'OnboardingReimportReady',
    ]) {
      final declaration = _classDeclaration(journeyState, episode);
      expect(
        declaration,
        contains('required this.operation'),
        reason: '$episode must be impossible to construct without identity.',
      );
    }
  });

  test('Journey owner is listener-driven and never self-invalidates', () {
    final coordinator = File(coordinatorPath).readAsStringSync();
    final build = _methodBody(
      coordinator,
      'OnboardingJourneyState build()',
      'OnboardingJourneyState _reconstructInitialJourney',
    );

    expect(build, contains('ref.listen'));
    expect(build, isNot(contains('ref.watch')));
    expect(coordinator, isNot(contains('ref.invalidateSelf()')));
  });

  test('production cannot invalidate the Journey authority', () {
    final offenders = <String>[];
    for (final file in _dartFilesUnder('lib')) {
      final source = file.readAsStringSync();
      if (source.contains(
            'ref.invalidate(onboardingJourneyCoordinatorProvider',
          ) ||
          source.contains(
            'ref.invalidate(\n      onboardingJourneyCoordinatorProvider',
          )) {
        offenders.add(file.path);
      }
    }

    expect(offenders, isEmpty);
  });

  test('shell does not initiate operation reconciliation independently', () {
    final shell = File(shellPath).readAsStringSync();

    expect(shell, isNot(contains('onboardingOperationReconciliationProvider')));
    expect(shell, contains('onboardingJourneyCoordinatorProvider'));
    expect(shell, isNot(contains('onboardingEnvironmentReportProvider')));
    expect(shell, isNot(contains('onboardingOperationSnapshotProvider')));
    expect(shell, isNot(contains('conversationGraphBuildControllerProvider')));
    expect(
      RegExp(r'ref\.watch\(onboarding\w+Provider').allMatches(shell).length,
      1,
      reason:
          'The mixed-purpose app shell may watch only the Journey coordinator; '
          'focused Onboarding surfaces are censused transitively below.',
    );
  });

  test('retained traversal stops are mechanically bounded', () {
    const startFreshActionPath =
        'lib/essentials/onboarding/application/'
        'advanced_start_fresh_action_provider.dart';
    const startFreshPresentationPath =
        'lib/essentials/onboarding/application/'
        'advanced_start_fresh_presentation_provider.dart';
    const startFreshDialogPath =
        'lib/essentials/onboarding/presentation/'
        'start_fresh_authorization_dialog.dart';
    const intentActionPaths = <String>{
      'lib/essentials/onboarding/application/onboarding_overlay_actions_provider.dart',
      'lib/essentials/onboarding/application/onboarding_readiness_actions_provider.dart',
      'lib/features/environment_readiness/application/environment_readiness_actions_provider.dart',
      'lib/features/environment_readiness/application/pipeline_incident_actions_provider.dart',
    };
    const evidenceImplementationPaths =
        _primaryOnboardingEvidenceImplementationPaths;
    const trustedBoundaries = <String>{
      coordinatorPath,
      journeyStatePath,
      projectionPath,
      onboardingBarrelPath,
      loggingBarrelPath,
      panelCoordinatorPath,
      panelWidgetProvidersPath,
      sidebarActionDispatcherPath,
      devPanelPath,
      devPanelActionsPath,
      advancedStartFreshPath,
      startFreshProviderPath,
      graphStatusSheetPath,
      historicalArchivesWorkflowModelPath,
    };
    final devPanel = _readSource(devPanelPath);
    final startFreshAction = _readSource(startFreshActionPath);
    final startFreshPresentation = _readSource(startFreshPresentationPath);
    final startFreshDialog = _readSource(startFreshDialogPath);
    final startFreshProvider = _readSource(startFreshProviderPath);
    final graphStatusSheet = _readSource(graphStatusSheetPath);

    expect(devPanel, contains('Diagnostic-only developer panel'));
    expect(devPanel, contains('onboardingEnvironmentReportProvider'));
    expect(devPanel, contains('conversationGraphBuildControllerProvider'));
    final rawPresentationConsumers =
        _dartFilesUnder('lib/essentials/onboarding/presentation')
            .where((file) {
              final source = file.readAsStringSync();
              return source.contains('onboardingEnvironmentReportProvider') ||
                  source.contains('onboardingOperationSnapshotProvider') ||
                  source.contains('conversationGraphBuildControllerProvider');
            })
            .map((file) => file.path)
            .toSet();
    expect(rawPresentationConsumers, <String>{devPanelPath});
    expect(
      _localImportersOf(devPanelPath),
      <String>{
        'lib/essentials/navigation/application/panel_coordinator_provider.dart',
      },
      reason:
          'The raw-evidence development panel must remain behind its one '
          'typed ViewSpec rendering seam.',
    );
    expect(_localImportersOf(devPanelActionsPath), <String>{devPanelPath});

    expect(startFreshAction, contains('AdvancedStartFreshAction'));
    expect(startFreshAction, isNot(contains('OnboardingJourneyState')));
    expect(
      startFreshAction,
      isNot(contains('onboardingEnvironmentReportProvider')),
    );
    expect(
      startFreshAction,
      isNot(contains('onboardingOperationSnapshotProvider')),
    );
    expect(startFreshPresentation, contains('AdvancedStartFreshPresentation'));
    expect(startFreshPresentation, isNot(contains('OnboardingJourneyState')));
    expect(startFreshPresentation, isNot(contains('onboardingEnvironment')));
    expect(startFreshPresentation, isNot(contains('onboardingOperation')));
    expect(startFreshProvider, contains('Future<StartFreshService>'));
    expect(startFreshProvider, isNot(contains('OnboardingJourneyState')));
    expect(startFreshProvider, isNot(contains('/presentation/')));
    expect(graphStatusSheet, contains('ConversationGraphStatusSheet'));
    expect(graphStatusSheet, isNot(contains('OnboardingJourney')));
    expect(graphStatusSheet, isNot(contains('onboardingGateProvider')));
    expect(
      graphStatusSheet,
      isNot(contains('onboardingJourneyCoordinatorProvider')),
    );

    expect(startFreshDialog, contains('showStartFreshAuthorizationDialog'));
    expect(startFreshDialog, isNot(contains('onboardingEnvironment')));
    expect(startFreshDialog, isNot(contains('onboardingOperation')));

    for (final actionPath in intentActionPaths) {
      final action = _readSource(actionPath);
      expect(action, contains('FutureOr<void> build()'));
      expect(action, isNot(contains('ref.watch')));
      expect(action, isNot(contains('state =')));
      expect(
        _isTransitivelySafeIntentAdapter(
          actionPath,
          evidenceImplementationPaths: evidenceImplementationPaths,
          trustedBoundaries: trustedBoundaries,
          dependencyReader: _localDependencies,
          sourceReader: _readSource,
        ),
        isTrue,
        reason:
            '$actionPath must remain transitively intent-only before it can '
            'terminate semantic traversal.',
      );
    }
  });

  test('semantic census traverses wrappers anywhere under lib', () {
    const root = 'lib/features/example/presentation/onboarding_surface.dart';
    const wrapper = 'lib/shared/read_models/onboarding_read_model.dart';
    const rawEvidence =
        'lib/essentials/onboarding/application/'
        'onboarding_environment_report_provider.dart';
    final graph = <String, Set<String>>{
      root: <String>{wrapper},
      wrapper: <String>{rawEvidence},
      rawEvidence: <String>{},
    };
    final sources = <String, String>{
      root: 'OnboardingJourneyState renderJourney();',
      wrapper: 'Object readOnboardingEvidence();',
      rawEvidence: '',
    };

    final roots = _productionOnboardingSemanticConsumerPaths(
      paths: sources.keys,
      sourceReader: (path) => sources[path] ?? '',
    );
    expect(roots, contains(root));

    final traversal = _transitiveLocalDependencies(
      root,
      stopAt: const <String>{coordinatorPath},
      dependencyReader: (path) => graph[path] ?? const <String>{},
    );

    expect(traversal.dependencies, contains(rawEvidence));
    expect(traversal.chainTo(rawEvidence), '$root -> $wrapper -> $rawEvidence');
  });

  test('semantic census discovers OnboardingStatus-only consumers', () {
    const root =
        'lib/features/example/presentation/onboarding_status_view.dart';
    final roots = _productionOnboardingSemanticConsumerPaths(
      paths: const <String>[root],
      sourceReader: (_) => 'Widget render(OnboardingStatus status);',
    );

    expect(roots, <String>{root});
  });

  test('primary evidence census rejects a raw graph side door', () {
    const root = 'lib/features/example/presentation/onboarding_surface.dart';
    const wrapper = 'lib/shared/read_models/raw_graph_read_model.dart';
    final graph = <String, Set<String>>{
      root: <String>{wrapper},
      wrapper: <String>{_rawConversationGraphBarrelPath},
      _rawConversationGraphBarrelPath: <String>{
        _rawConversationGraphControllerPath,
      },
      _rawConversationGraphControllerPath: <String>{},
    };
    final sources = <String, String>{
      root: 'OnboardingStatus renderStatus();',
      wrapper: 'Object readRawGraphEvidence();',
      _rawConversationGraphBarrelPath: '',
      _rawConversationGraphControllerPath: '',
    };
    final roots = _productionOnboardingSemanticConsumerPaths(
      paths: sources.keys,
      sourceReader: (path) => sources[path] ?? '',
    );
    final traversal = _transitiveLocalDependencies(
      root,
      stopAt: const <String>{},
      dependencyReader: (path) => graph[path] ?? const <String>{},
    );
    final sideDoors = traversal.dependencies
        .where(_primaryOnboardingEvidenceImplementationPaths.contains)
        .toSet();

    expect(roots, contains(root));
    expect(sideDoors, <String>{
      _rawConversationGraphBarrelPath,
      _rawConversationGraphControllerPath,
    });
  });

  test('intent action adapters cannot hide raw semantic evidence', () {
    const root = 'lib/features/example/presentation/onboarding_surface.dart';
    const actionAdapter =
        'lib/features/example/application/onboarding_actions.dart';
    const rawEvidence =
        'lib/essentials/onboarding/application/'
        'onboarding_operation_snapshot_provider.dart';
    final graph = <String, Set<String>>{
      root: <String>{actionAdapter},
      actionAdapter: <String>{rawEvidence},
      rawEvidence: <String>{},
    };
    final sources = <String, String>{
      root: 'OnboardingJourneyState renderJourney();',
      actionAdapter:
          'class Actions { FutureOr<void> build() {} void retry() {} }',
      rawEvidence: '',
    };
    const evidencePaths = <String>{rawEvidence};
    const trusted = <String>{coordinatorPath};

    final traversal = _transitiveLocalDependencies(
      root,
      stopAt: trusted,
      stopWhen: (path) => _isTransitivelySafeIntentAdapter(
        path,
        evidenceImplementationPaths: evidencePaths,
        trustedBoundaries: trusted,
        dependencyReader: (path) => graph[path] ?? const <String>{},
        sourceReader: (path) => sources[path] ?? '',
      ),
      dependencyReader: (path) => graph[path] ?? const <String>{},
    );

    expect(traversal.dependencies, contains(rawEvidence));
    expect(
      traversal.chainTo(rawEvidence),
      '$root -> $actionAdapter -> $rawEvidence',
    );
    expect(
      _isTransitivelySafeIntentAdapter(
        actionAdapter,
        evidenceImplementationPaths: evidencePaths,
        trustedBoundaries: trusted,
        dependencyReader: (path) => graph[path] ?? const <String>{},
        sourceReader: (path) => sources[path] ?? '',
      ),
      isFalse,
    );
  });

  test(
    'shell-imported wrappers cannot hide raw graph evidence under real boundaries',
    () {
      const wrapper = 'lib/shared/read_models/shell_onboarding_state.dart';
      const rawEvidence = _rawConversationGraphBarrelPath;
      final graph = <String, Set<String>>{
        shellPath: <String>{wrapper},
        wrapper: <String>{rawEvidence},
        rawEvidence: <String>{},
      };
      final traversal = _transitiveLocalDependencies(
        shellPath,
        stopAt: _onboardingSemanticTrustedBoundaries,
        dependencyReader: (path) => graph[path] ?? const <String>{},
      );

      expect(traversal.dependencies, contains(rawEvidence));
      expect(
        traversal.chainTo(rawEvidence),
        '$shellPath -> $wrapper -> $rawEvidence',
      );
    },
  );

  test('configuration imports remain transitively censused', () {
    const root = 'lib/features/example/presentation/onboarding_surface.dart';
    const config = 'lib/config/example/onboarding_config.dart';
    const wrapper = 'lib/shared/read_models/config_onboarding_state.dart';
    const rawEvidence =
        'lib/essentials/onboarding/application/'
        'onboarding_operation_snapshot_provider.dart';
    final graph = <String, Set<String>>{
      root: <String>{config},
      config: <String>{wrapper},
      wrapper: <String>{rawEvidence},
      rawEvidence: <String>{},
    };
    final traversal = _transitiveLocalDependencies(
      root,
      stopAt: const <String>{coordinatorPath},
      dependencyReader: (path) => graph[path] ?? const <String>{},
    );

    expect(traversal.dependencies, contains(rawEvidence));
    expect(
      traversal.chainTo(rawEvidence),
      '$root -> $config -> $wrapper -> $rawEvidence',
    );
  });

  test('genuinely narrow intent adapters terminate traversal', () {
    const root = 'lib/features/example/presentation/onboarding_surface.dart';
    const actionAdapter =
        'lib/features/example/application/onboarding_actions.dart';
    final graph = <String, Set<String>>{
      root: <String>{actionAdapter},
      actionAdapter: <String>{coordinatorPath},
      coordinatorPath: <String>{},
    };
    final sources = <String, String>{
      root: 'OnboardingJourneyState renderJourney();',
      actionAdapter:
          'class Actions { FutureOr<void> build() {} void retry() {} }',
      coordinatorPath: '',
    };
    const trusted = <String>{coordinatorPath};

    final safe = _isTransitivelySafeIntentAdapter(
      actionAdapter,
      evidenceImplementationPaths: const <String>{},
      trustedBoundaries: trusted,
      dependencyReader: (path) => graph[path] ?? const <String>{},
      sourceReader: (path) => sources[path] ?? '',
    );
    final traversal = _transitiveLocalDependencies(
      root,
      stopAt: trusted,
      stopWhen: (path) => path == actionAdapter && safe,
      dependencyReader: (path) => graph[path] ?? const <String>{},
    );

    expect(safe, isTrue);
    expect(traversal.dependencies, <String>{root, actionAdapter});
  });

  test('development raw-evidence panel is one bounded exception', () {
    final rawPresentationConsumers = _dartFilesUnder('lib')
        .where((file) => file.path.contains('/presentation/'))
        .where((file) {
          final source = file.readAsStringSync();
          return _sourceConsumesJourneySemantics(source) &&
              (source.contains('onboardingEnvironmentReportProvider') ||
                  source.contains('onboardingOperationSnapshotProvider') ||
                  source.contains('conversationGraphBuildControllerProvider'));
        })
        .map((file) => file.path)
        .toSet();

    expect(rawPresentationConsumers, <String>{devPanelPath});
    expect(
      _readSource(devPanelPath),
      contains('Diagnostic-only developer panel'),
    );
  });

  test(
    'aggregate and admitted environment reads remain structurally distinct',
    () {
      final unit = _parseUnit(environmentReportPath);
      final aggregate = _topLevelFunction(unit, 'onboardingEnvironmentReport');
      final admitted = _topLevelFunction(
        unit,
        'readAdmittedOnboardingEnvironmentEvidence',
      );
      final materialRead = _topLevelFunction(
        unit,
        '_readMaterialOnboardingEvidence',
      );
      final admittedMaterialRead = _topLevelFunction(
        unit,
        '_readAdmittedMaterialOnboardingEvidence',
      );
      final failureRead = _topLevelFunction(
        unit,
        '_readPersistedFailureEvidence',
      );
      final evaluator = _classMethod(
        unit,
        '_OnboardingEnvironmentEvaluator',
        'evaluate',
      );

      expect(
        aggregate.functionExpression.parameters?.toSource(),
        isNot(contains('ArchiveMutationCapability')),
      );
      expect(
        _invocationsNamed(aggregate, 'select'),
        hasLength(1),
        reason: 'The aggregate path must continue observing coarse lock state.',
      );
      expect(
        admitted.functionExpression.parameters?.toSource(),
        allOf(
          contains('ArchiveMutationCapability capability'),
          contains('ArchiveMutationOperation expectedOperation'),
        ),
      );
      expect(
        _identifierNames(admitted),
        containsAll(<String>{
          'openConversationGraphConnection',
          'openPersistentArchiveStore',
        }),
      );
      expect(_directAwaitedInvocationNames(admitted), <String>[
        '_readAdmittedMaterialOnboardingEvidence',
        '_readAdmittedMaterialOnboardingEvidence',
      ]);
      for (final awaitExpression in _directAwaitExpressions(admitted)) {
        final invocation = awaitExpression.expression as MethodInvocation;
        expect(
          _namedArgument(invocation, 'requirePersistentArchiveStoreAdmission'),
          isNotNull,
        );
      }
      expect(
        admitted.toSource(),
        contains('_maximumAdmittedMaterialEvidenceAttempts'),
      );
      expect(admitted.toSource(), contains('first.hasSameRevisionAs(second)'));
      expect(
        admitted.toSource(),
        allOf(
          contains('did not stabilize after one bounded'),
          contains('retry.'),
        ),
      );

      _expectAdmissionBracketsSingleAwait(materialRead);
      expect(_directAwaitedInvocationNames(admittedMaterialRead), <String>[
        '_readPersistedFailureEvidence',
        'readAttachmentArchiveLocationEvidenceWithAdmission',
        '_readMaterialOnboardingEvidence',
      ]);
      expect(
        _namedArgument(
          _directAwaitExpressions(admittedMaterialRead)[0].expression
              as MethodInvocation,
          'requirePersistentArchiveStoreAdmission',
        ),
        isNotNull,
      );
      expect(
        _namedArgument(
          _directAwaitExpressions(admittedMaterialRead)[1].expression
              as MethodInvocation,
          'requirePersistentArchiveStoreAdmission',
        ),
        isNotNull,
      );
      expect(
        _namedArgument(
          _directAwaitExpressions(admittedMaterialRead)[2].expression
              as MethodInvocation,
          'requireCurrentAdmission',
        ),
        isNotNull,
      );
      expect(_directAwaitedInvocationNames(failureRead), <String>[
        '_readMaterialOnboardingEvidence',
        '_readMaterialOnboardingEvidence',
      ]);
      for (final awaitExpression in _directAwaitExpressions(failureRead)) {
        final invocation = awaitExpression.expression as MethodInvocation;
        expect(
          _namedArgument(invocation, 'requireCurrentAdmission'),
          isNotNull,
        );
        expect(
          invocation.toSource(),
          contains('requirePersistentArchiveStoreAdmission:'),
        );
      }
      expect(
        _allAwaitExpressions(evaluator),
        isEmpty,
        reason:
            'Protected probes must run only in the synchronous evaluator after '
            'the final async admission checkpoint.',
      );

      final lastAwait = _directAwaitExpressions(admitted).last;
      final inputRead = _invocationsNamed(
        admitted,
        '_readOnboardingEnvironmentInputs',
      ).single;
      expect(inputRead.offset, greaterThan(lastAwait.end));
      expect(
        inputRead.toSource(),
        allOf(
          contains('coherentEvidence.addressBookEither'),
          contains('coherentEvidence.attachmentArchiveLocation'),
          contains('coherentEvidence.failureEvidence'),
        ),
        reason:
            'Only a matching final material sample may reach the evaluator.',
      );
    },
  );

  test(
    'actual admitted protected I/O requires immediate proof checkpoints',
    () async {
      final failureUnit = await _resolveUnit(_overlayFailureStoragePath);
      final sourceFailureRead = _classMethod(
        failureUnit,
        'OverlayOnboardingFailureStorage',
        'loadSourceImportFailureEntry',
      );
      final graphKeyRead = _classMethod(
        failureUnit,
        'OverlayOnboardingFailureStorage',
        '_loadGraphProjectionFailureFromKey',
      );
      final graphFailureRead = _classMethod(
        failureUnit,
        'OverlayOnboardingFailureStorage',
        'loadGraphProjectionFailureEntry',
      );
      final controllerUnit = await _resolveUnit(
        _attachmentLocationControllerPath,
      );
      final controllerLoad = _classMethod(
        controllerUnit,
        'AttachmentArchiveLocationController',
        'load',
      );
      final bookmarkResolution = _classMethod(
        controllerUnit,
        'AttachmentArchiveLocationController',
        '_resolveCustom',
      );
      final availableCustom = _classMethod(
        controllerUnit,
        'AttachmentArchiveLocationController',
        '_availableCustomState',
      );
      final persistConfiguration = _classMethod(
        controllerUnit,
        'AttachmentArchiveLocationController',
        '_persistConfigurationUnchecked',
      );
      final locationEvidence = _topLevelFunction(
        await _resolveUnit(_attachmentLocationProviderPath),
        'readAttachmentArchiveLocationEvidenceWithAdmission',
      );

      expect(
        _protectedIoCheckpointViolations(
          <AstNode>[sourceFailureRead],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == '_readOverlaySetting',
          approvedCallback: _formalParameterElement(
            sourceFailureRead,
            'requirePersistentArchiveStoreAdmission',
          ),
        ),
        isEmpty,
      );
      expect(
        _protectedIoCheckpointViolations(
          <AstNode>[graphKeyRead],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == '_readOverlaySetting',
          approvedCallback: _formalParameterElement(
            graphKeyRead,
            'requirePersistentArchiveStoreAdmission',
          ),
        ),
        isEmpty,
      );
      expect(
        _protectedIoCheckpointViolations(
          <AstNode>[controllerLoad],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == 'readSetting',
          approvedCallback: _formalParameterElement(
            controllerLoad,
            'requirePersistentArchiveStoreAdmission',
          ),
        ),
        isEmpty,
      );
      expect(
        _protectedIoCheckpointViolations(
          <AstNode>[availableCustom],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == '_persistConfigurationUnchecked',
          approvedCallback: _formalParameterElement(
            availableCustom,
            'requirePersistentArchiveStoreAdmission',
          ),
        ),
        isEmpty,
      );
      expect(
        _protectedIoCheckpointViolations(
          <AstNode>[persistConfiguration],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == 'writeSetting' &&
              invocation.target?.toSource() == '_settingsStore',
          allowCallerProofBeforeEntry: true,
        ),
        isEmpty,
        reason:
            'The concrete bookmark settings write must remain synchronous '
            'from its separately audited caller proof, or renew proof after '
            'any inner await.',
      );
      expect(
        _protectedIoCheckpointViolations(
          <AstNode>[bookmarkResolution],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == 'resolveBookmark',
          approvedCallback: _formalParameterElement(
            bookmarkResolution,
            'requirePersistentArchiveStoreAdmission',
          ),
        ),
        isEmpty,
      );
      expect(
        _missingApprovedCheckpointsAfter(
          <AstNode>[bookmarkResolution],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == 'resolveBookmark',
          approvedCallback: _formalParameterElement(
            bookmarkResolution,
            'requirePersistentArchiveStoreAdmission',
          ),
        ),
        isEmpty,
      );
      expect(
        _protectedIoCheckpointViolations(
          <AstNode>[locationEvidence],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == 'read' &&
              invocation.toSource().contains(
                'attachmentArchiveSettingsStoreProvider.future',
              ),
          approvedCallback: _formalParameterElement(
            locationEvidence,
            'requirePersistentArchiveStoreAdmission',
          ),
        ),
        isEmpty,
      );
      expect(
        _missingApprovedCheckpointsAfter(
          <AstNode>[locationEvidence],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == 'read' &&
              invocation.toSource().contains(
                'attachmentArchiveSettingsStoreProvider.future',
              ),
          approvedCallback: _formalParameterElement(
            locationEvidence,
            'requirePersistentArchiveStoreAdmission',
          ),
        ),
        isEmpty,
      );
      final fallbackInvocations = _invocationsNamed(
        graphFailureRead,
        '_loadGraphProjectionFailureFromKey',
      );
      expect(fallbackInvocations, hasLength(2));
      expect(
        _protectedIoCheckpointViolations(
          <AstNode>[graphFailureRead],
          protectedInvocation: (invocation) =>
              identical(invocation, fallbackInvocations.last),
          approvedCallback: _formalParameterElement(
            graphFailureRead,
            'requirePersistentArchiveStoreAdmission',
          ),
        ),
        isEmpty,
        reason: 'The historical fallback must re-prove admission.',
      );

      expect(
        _callbackPropagationViolations(
          caller: locationEvidence,
          callerCallback: _formalParameterElement(
            locationEvidence,
            'requirePersistentArchiveStoreAdmission',
          ),
          callee: controllerLoad,
          calleeCallback: _formalParameterElement(
            controllerLoad,
            'requirePersistentArchiveStoreAdmission',
          ),
          argumentName: 'requirePersistentArchiveStoreAdmission',
          expectedCallCount: 1,
        ),
        isEmpty,
      );
      expect(
        _callbackPropagationViolations(
          caller: controllerLoad,
          callerCallback: _formalParameterElement(
            controllerLoad,
            'requirePersistentArchiveStoreAdmission',
          ),
          callee: bookmarkResolution,
          calleeCallback: _formalParameterElement(
            bookmarkResolution,
            'requirePersistentArchiveStoreAdmission',
          ),
          argumentName: 'requirePersistentArchiveStoreAdmission',
          expectedCallCount: 1,
        ),
        isEmpty,
      );
      expect(
        _callbackPropagationViolations(
          caller: bookmarkResolution,
          callerCallback: _formalParameterElement(
            bookmarkResolution,
            'requirePersistentArchiveStoreAdmission',
          ),
          callee: availableCustom,
          calleeCallback: _formalParameterElement(
            availableCustom,
            'requirePersistentArchiveStoreAdmission',
          ),
          argumentName: 'requirePersistentArchiveStoreAdmission',
          expectedCallCount: 2,
        ),
        isEmpty,
        reason:
            'The admitted attachment/custom path must forward the exact '
            'non-null proof callback through every layer.',
      );

      final unsafeWrapper = _virtualProtectedWrite('''
  await someAsyncBoundary();
  await _settingsStore.writeSetting('key');
''');
      expect(
        _protectedIoCheckpointViolations(
          <AstNode>[unsafeWrapper],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == 'writeSetting',
          allowCallerProofBeforeEntry: true,
        ),
        isNotEmpty,
        reason:
            'An inner await in the persistence wrapper must invalidate the '
            'caller proof before the concrete write.',
      );

      final renewedWrapper = _virtualProtectedWrite('''
  await someAsyncBoundary();
  requirePersistentArchiveStoreAdmission();
  await _settingsStore.writeSetting('key');
''');
      expect(
        _protectedIoCheckpointViolations(
          <AstNode>[renewedWrapper],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == 'writeSetting',
          allowCallerProofBeforeEntry: true,
        ),
        isEmpty,
        reason:
            'A renewed approved checkpoint after the inner await must admit '
            'the concrete write.',
      );

      final checkpointMutations = <String, String>{
        'conditional checkpoint': '''
  await someAsyncBoundary();
  if (someCondition) {
    requirePersistentArchiveStoreAdmission();
  }
  await _settingsStore.writeSetting('key');
''',
        'wrong receiver': '''
  await someAsyncBoundary();
  fake.requirePersistentArchiveStoreAdmission();
  await _settingsStore.writeSetting('key');
''',
        'wrong branch': '''
  await someAsyncBoundary();
  if (denyPath) {
    requirePersistentArchiveStoreAdmission();
    return;
  }
  await _settingsStore.writeSetting('key');
''',
        'await after valid checkpoint': '''
  requirePersistentArchiveStoreAdmission();
  await anotherAsyncBoundary();
  await _settingsStore.writeSetting('key');
''',
      };
      for (final MapEntry(:key, :value) in checkpointMutations.entries) {
        final mutation = _virtualProtectedWrite(value);
        expect(
          _protectedIoCheckpointViolations(
            <AstNode>[mutation],
            protectedInvocation: (invocation) =>
                invocation.methodName.name == 'writeSetting',
            allowCallerProofBeforeEntry: true,
          ),
          isNotEmpty,
          reason: '$key must not satisfy persistent-store proof dominance.',
        );
      }

      final bindingFixture = await _resolveVirtualUnit(
        _protectedIoBindingFixtureSource,
      );
      final validBinding = _classMethod(
        bindingFixture,
        'VirtualSettingsWriter',
        'valid',
      );
      final shadowedBinding = _classMethod(
        bindingFixture,
        'VirtualSettingsWriter',
        'shadowed',
      );
      final unrelatedBinding = _classMethod(
        bindingFixture,
        'VirtualSettingsWriter',
        'unrelatedCallable',
      );
      expect(
        _protectedIoCheckpointViolations(
          <AstNode>[validBinding],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == 'writeSetting',
          approvedCallback: _formalParameterElement(validBinding, 'proof'),
        ),
        isEmpty,
      );
      expect(
        _protectedIoCheckpointViolations(
          <AstNode>[shadowedBinding],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == 'writeSetting',
          approvedCallback: _formalParameterElement(shadowedBinding, 'proof'),
        ),
        isNotEmpty,
        reason:
            'A same-named local callable must not impersonate the admitted '
            'formal proof callback.',
      );
      expect(
        _protectedIoCheckpointViolations(
          <AstNode>[unrelatedBinding],
          protectedInvocation: (invocation) =>
              invocation.methodName.name == 'writeSetting',
          approvedCallback: _formalParameterElement(unrelatedBinding, 'proof'),
        ),
        isNotEmpty,
        reason:
            'A same-named local alias to an unrelated callable must not '
            'impersonate the admitted formal proof callback.',
      );

      final callee = _classMethod(bindingFixture, 'ProofCallee', 'read');
      final validPropagation = _classMethod(
        bindingFixture,
        'ProofCaller',
        'valid',
      );
      final nullPropagation = _classMethod(
        bindingFixture,
        'ProofCaller',
        'dropsProof',
      );
      expect(
        _callbackPropagationViolations(
          caller: validPropagation,
          callerCallback: _formalParameterElement(validPropagation, 'proof'),
          callee: callee,
          calleeCallback: _formalParameterElement(callee, 'proof'),
          argumentName: 'proof',
          expectedCallCount: 1,
        ),
        isEmpty,
      );
      expect(
        _callbackPropagationViolations(
          caller: nullPropagation,
          callerCallback: _formalParameterElement(nullPropagation, 'proof'),
          callee: callee,
          calleeCallback: _formalParameterElement(callee, 'proof'),
          argumentName: 'proof',
          expectedCallCount: 1,
        ),
        isNotEmpty,
        reason: 'An admitted layer must not weaken the proof callback to null.',
      );
    },
  );

  test('only Journey coordinator invokes admitted environment evidence', () {
    final importers = <String>[];
    for (final file in _dartFilesUnder('lib')) {
      if (file.path == environmentReportPath) {
        continue;
      }
      if (file.readAsStringSync().contains(
        'readAdmittedOnboardingEnvironmentEvidence(',
      )) {
        importers.add(file.path);
      }
    }

    expect(importers, <String>[coordinatorPath]);
  });

  test('the four Journey commands require typed archive capabilities', () {
    final unit = _parseUnit(coordinatorPath);
    final commands = <MethodDeclaration>[
      _classMethod(
        unit,
        'OnboardingJourneyCoordinator',
        '_runNewInitialImport',
      ),
      _classMethod(unit, 'OnboardingJourneyCoordinator', '_runNewReimport'),
      _classMethod(
        unit,
        'OnboardingJourneyCoordinator',
        'continueInterruptedOperation',
      ),
      _classMethod(
        unit,
        'OnboardingJourneyCoordinator',
        '_runAutomaticRecovery',
      ),
    ];
    final admissions = commands
        .expand((command) => _invocationsNamed(command, 'runWithCapability'))
        .toList(growable: false);

    expect(admissions, hasLength(4));
    expect(
      commands
          .expand((command) => _invocationsNamed(command, 'run'))
          .where(
            (invocation) =>
                invocation.target?.toSource().contains(
                  'archiveMutationCoordinatorProvider',
                ) ??
                false,
          ),
      isEmpty,
      reason:
          'Protected Onboarding commands must not retain a capability-free '
          'archive admission path.',
    );
    expect(
      admissions
          .map(
            (invocation) => _namedArgument(invocation, 'operation').toSource(),
          )
          .toList(growable: false),
      <String>[
        'operation: ArchiveMutationOperation.onboardingImport',
        'operation: ArchiveMutationOperation.onboardingImport',
        'operation: ArchiveMutationOperation.onboardingImport',
        'operation: ArchiveMutationOperation.automaticRecovery',
      ],
    );
    expect(
      commands
          .expand(
            (command) => _invocationsNamed(
              command,
              'readAdmittedOnboardingEnvironmentEvidence',
            ),
          )
          .length,
      5,
      reason:
          'Initial import, reimport, continuation, automatic-recovery begin, '
          'and automatic-recovery reset each need a fresh owner read.',
    );
  });

  test('each command keeps pre-admission and owner-currentness predicates', () {
    final coordinator = _readSource(coordinatorPath);

    for (final predicate in <String>[
      '_latestReportAllowsInitialImport(',
      '_latestReportAllowsReimport(',
      '_latestReportAllowsInterruptedContinuation(',
      '_latestReportAllowsAutomaticRecovery(',
    ]) {
      expect(coordinator, contains(predicate));
    }
    for (final predicate in <String>[
      'predicate: _reportAllowsInitialImport',
      'predicate: _reportAllowsReimport',
      '_reportAllowsInterruptedContinuation(',
      'predicate: _reportAllowsAutomaticRecovery',
    ]) {
      expect(coordinator, contains(predicate));
    }
    expect(coordinator, contains('_commandRetainsBinding('));
    expect(coordinator, contains('_commandOwnsBoundOperation('));
    expect(
      coordinator,
      contains("'prerequisites changed before automatic recovery reset'"),
    );
  });

  test('maintenance evidence cannot invent normal application state', () {
    final coordinator = _readSource(coordinatorPath);
    final mapping = _methodBody(
      coordinator,
      'OnboardingJourneyState _journeyFromEnvironment',
      'OnboardingJourneyState _journeyForOperation',
    );
    final ingest = _methodBody(
      coordinator,
      'void _ingestEnvironmentReport',
      'void _ingestOperationEvidence',
    );

    expect(
      mapping,
      contains('report.state == OnboardingEnvironmentState.ready'),
    );
    expect(
      mapping,
      isNot(
        contains(
          'report.state == OnboardingEnvironmentState.maintenanceInProgress) {\n'
          '      return OnboardingNormalApplication',
        ),
      ),
    );
    expect(
      ingest,
      contains(
        'report.state == OnboardingEnvironmentState.maintenanceInProgress',
      ),
    );
    expect(
      ingest.indexOf('_reportHasExternalPrerequisiteBlocker(report)'),
      lessThan(
        ingest.indexOf(
          'report.state == OnboardingEnvironmentState.maintenanceInProgress',
        ),
      ),
      reason: 'Hard blockers must outrank maintenance-only retention.',
    );
  });

  test('critical tenure tests use real Feature 35 authorities', () async {
    final unit = await _resolveUnit(coordinatorTestPath);
    final main = _topLevelFunction(unit, 'main');
    final fixtureCreate = _classMethod(unit, '_JourneyFixture', 'create');
    final body = _realFeedbackGroupBody(main);
    final environmentProvider = _referencedElement(
      unit,
      'onboardingEnvironmentReportProvider',
      libraryUriContains: 'onboarding_environment_report_provider',
    );
    final providerContainer = _referencedInterfaceElement(
      unit,
      'ProviderContainer',
      libraryUriContains: 'package:riverpod/',
    );

    final extendedTypes = _classDeclarations(unit)
        .map(
          (declaration) => declaration.extendsClause?.superclass.name2.lexeme,
        )
        .whereType<String>()
        .toSet();
    expect(extendedTypes, isNot(contains('ArchiveMutationCoordinator')));
    expect(extendedTypes, isNot(contains('ExclusiveAuthorityRegistry')));
    expect(
      _fixtureRealismViolations(
        unit: unit,
        create: fixtureCreate,
        criticalBody: body,
      ),
      isEmpty,
      reason:
          'The fixture helper must preserve the real global Environment and '
          'both Feature 35 authorities, return its real observation recorder, '
          'and make all four tests wait through that exact recorder.',
    );
    expect(
      _fixtureBindingViolations(
        unit: unit,
        create: fixtureCreate,
        criticalBody: body,
        environmentProvider: environmentProvider,
        providerContainer: providerContainer,
      ),
      isEmpty,
      reason:
          'The critical listener, recorder, returned fixture, and waits must '
          'form one declaration-authenticated chain from the actual '
          'ProviderContainer and global Environment provider.',
    );

    final validVirtualUnit = _parseVirtualFixturePolicyUnit();
    expect(
      _fixtureRealismViolations(
        unit: validVirtualUnit,
        create: _classMethod(validVirtualUnit, '_JourneyFixture', 'create'),
        criticalBody: _realFeedbackGroupBody(
          _topLevelFunction(validVirtualUnit, 'main'),
        ),
      ),
      isEmpty,
      reason: 'The connected virtual fixture must satisfy the real policy.',
    );

    final fixtureMutations = <String, CompilationUnit>{
      'ignored real-feedback flag': _parseVirtualFixturePolicyUnit(
        conditionEnvironmentOverride: false,
      ),
      'replaced Feature 35 authorities': _parseVirtualFixturePolicyUnit(
        replaceAuthorities: true,
      ),
      'dead real-provider recorder': _parseVirtualFixturePolicyUnit(
        listenerRecorder: 'deadEnvironmentReports',
      ),
      'critical waits use a fake recorder': _parseVirtualFixturePolicyUnit(
        waitField: 'fakeEnvironmentReports',
      ),
      'returned observation handle is fake': _parseVirtualFixturePolicyUnit(
        returnedRecorder: 'fakeEnvironmentReports',
      ),
      'unrelated fake can satisfy real recorder':
          _parseVirtualFixturePolicyUnit(injectFakeRecorderWrite: true),
    };
    for (final MapEntry(:key, value: mutationUnit)
        in fixtureMutations.entries) {
      expect(
        _fixtureRealismViolations(
          unit: mutationUnit,
          create: _classMethod(mutationUnit, '_JourneyFixture', 'create'),
          criticalBody: _realFeedbackGroupBody(
            _topLevelFunction(mutationUnit, 'main'),
          ),
        ),
        isNotEmpty,
        reason: '$key must fail the repository fixture-realism policy.',
      );
    }

    for (final mutation
        in <
              String,
              ({
                bool alternateContainer,
                bool fakeContainer,
                bool fakeProvider,
                bool shadowListenerPayload,
                String fixtureInitializer,
              })
            >{
              'valid renamed locals': (
                alternateContainer: false,
                fakeContainer: false,
                fakeProvider: false,
                shadowListenerPayload: false,
                fixtureInitializer: 'direct',
              ),
              'fake local container': (
                alternateContainer: false,
                fakeContainer: true,
                fakeProvider: false,
                shadowListenerPayload: false,
                fixtureInitializer: 'direct',
              ),
              'alternate ProviderContainer': (
                alternateContainer: true,
                fakeContainer: false,
                fakeProvider: false,
                shadowListenerPayload: false,
                fixtureInitializer: 'direct',
              ),
              'fake local provider': (
                alternateContainer: false,
                fakeContainer: false,
                fakeProvider: true,
                shadowListenerPayload: false,
                fixtureInitializer: 'direct',
              ),
              'shadowed listener payload': (
                alternateContainer: false,
                fakeContainer: false,
                fakeProvider: false,
                shadowListenerPayload: true,
                fixtureInitializer: 'direct',
              ),
              'discarded real fixture creation': (
                alternateContainer: false,
                fakeContainer: false,
                fakeProvider: false,
                shadowListenerPayload: false,
                fixtureInitializer: 'discarded',
              ),
              'conditional fixture source': (
                alternateContainer: false,
                fakeContainer: false,
                fakeProvider: false,
                shadowListenerPayload: false,
                fixtureInitializer: 'conditional',
              ),
              'wrapper returns fake fixture': (
                alternateContainer: false,
                fakeContainer: false,
                fakeProvider: false,
                shadowListenerPayload: false,
                fixtureInitializer: 'wrapper',
              ),
            }
            .entries) {
      final resolved = await _resolveVirtualUnit(
        _fixtureBindingSource(
          alternateContainer: mutation.value.alternateContainer,
          fakeContainer: mutation.value.fakeContainer,
          fakeProvider: mutation.value.fakeProvider,
          shadowListenerPayload: mutation.value.shadowListenerPayload,
          fixtureInitializer: mutation.value.fixtureInitializer,
        ),
      );
      final violations = _fixtureBindingViolations(
        unit: resolved,
        create: _classMethod(resolved, '_JourneyFixture', 'create'),
        criticalBody: _realFeedbackGroupBody(
          _topLevelFunction(resolved, 'main'),
        ),
        environmentProvider: _topLevelVariableElement(
          resolved,
          'onboardingEnvironmentReportProvider',
        ),
        providerContainer: _classElement(resolved, 'ProviderContainer'),
      );
      if (mutation.key == 'valid renamed locals') {
        expect(
          violations,
          isEmpty,
          reason: 'Harmless local renames must preserve the connected chain.',
        );
      } else {
        expect(
          violations,
          isNotEmpty,
          reason:
              '${mutation.key} must not satisfy the binding-aware fixture '
              'policy.',
        );
      }
    }
  });

  test('the admitted evidence seam remains internal and non-ambient', () {
    final barrel = _readSource(onboardingBarrelPath);
    final admitted = _methodBody(
      _readSource(environmentReportPath),
      'readAdmittedOnboardingEnvironmentEvidence(',
      '_OnboardingEnvironmentInputs _readOnboardingEnvironmentInputs',
    );

    expect(
      barrel,
      isNot(contains('readAdmittedOnboardingEnvironmentEvidence')),
    );
    expect(admitted, isNot(contains('@riverpod')));
    expect(admitted, isNot(contains('FutureProvider')));
    expect(admitted, isNot(contains('currentCapability')));
    expect(admitted, isNot(contains('currentBall')));
    expect(admitted, isNot(contains('ownerId')));
    expect(admitted, isNot(contains('ownerLabel')));
    expect(admitted, isNot(contains('diagnosticOccurrence')));
    expect(admitted, isNot(contains('.isLocked')));
  });

  test('presentation and Journey values cannot carry tenure proof', () {
    final presentationOffenders = <String>[];
    for (final file in _dartFilesUnder('lib')) {
      if (!file.path.contains('/presentation/')) {
        continue;
      }
      final source = file.readAsStringSync();
      if (source.contains('ArchiveMutationCapability') ||
          source.contains('ExclusiveAuthorityTenure') ||
          source.contains('exclusiveAuthorityRegistryProvider') ||
          source.contains('dbMaintenanceLockProvider')) {
        presentationOffenders.add(file.path);
      }
    }
    expect(presentationOffenders, isEmpty);

    for (final path in <String>[
      journeyStatePath,
      projectionPath,
      'lib/essentials/onboarding/domain/onboarding_operation_snapshot.dart',
    ]) {
      final source = _readSource(path);
      expect(source, isNot(contains('ArchiveMutationCapability')));
      expect(source, isNot(contains('ArchiveMutationResourceAdmission')));
      expect(source, isNot(contains('ExclusiveAuthorityTenure')));
      expect(source, isNot(contains('ExclusiveAuthorityKey')));
    }
  });

  test(
    'final semantic guards dominate every Journey mutation boundary',
    () async {
      final unit = await _resolveUnit(coordinatorPath);
      final commandOrigins = _CommandBindingOrigins(
        coordinator: _classElement(unit, 'OnboardingJourneyCoordinator'),
        reportReader: _topLevelFunction(
          await _resolveUnit(environmentReportPath),
          'readAdmittedOnboardingEnvironmentEvidence',
        ).declaredFragment!.element,
        controllerType: _classElement(
          await _resolveUnit(
            'lib/essentials/onboarding/application/'
            'onboarding_operation_snapshot_controller.dart',
          ),
          'OnboardingOperationSnapshotController',
        ),
        capabilityType: _classElement(
          await _resolveUnit(
            'lib/essentials/archive_environment/application/'
            'archive_mutation_coordinator_provider.dart',
          ),
          'ArchiveMutationCapability',
        ),
        resetServiceType: _classElement(
          await _resolveUnit(
            'lib/essentials/onboarding/application/'
            'message_data_reset_service.dart',
          ),
          'MessageDataResetService',
        ),
        controllerProvider: _referencedElement(
          unit,
          'onboardingOperationControllerProvider',
          libraryUriContains: 'onboarding_operation_snapshot_provider',
        ),
        resetServiceProvider: _referencedElement(
          unit,
          'messageDataResetServiceProvider',
          libraryUriContains: 'message_data_reset_service',
        ),
        refReadMethod: _referencedElement(
          unit,
          'read',
          libraryUriContains: 'package:riverpod/src/framework.dart',
        ),
      );
      final initial = _classMethod(
        unit,
        'OnboardingJourneyCoordinator',
        '_runNewInitialImport',
      );
      final reimport = _classMethod(
        unit,
        'OnboardingJourneyCoordinator',
        '_runNewReimport',
      );
      final continuation = _classMethod(
        unit,
        'OnboardingJourneyCoordinator',
        'continueInterruptedOperation',
      );
      final recovery = _classMethod(
        unit,
        'OnboardingJourneyCoordinator',
        '_runAutomaticRecovery',
      );

      _expectDominatingCommandGuard(
        method: initial,
        spec: _initialImportGuardSpec,
      );
      _expectDominatingCommandGuard(method: reimport, spec: _reimportGuardSpec);
      _expectDominatingCommandGuard(
        method: continuation,
        spec: _continuationGuardSpec,
      );
      _expectDominatingCommandGuard(
        method: recovery,
        spec: _automaticRecoveryBeginGuardSpec,
      );
      _expectDominatingCommandGuard(
        method: recovery,
        spec: _automaticRecoveryResetGuardSpec,
      );
      for (final (method, spec) in <(MethodDeclaration, _CommandGuardSpec)>[
        (initial, _initialImportGuardSpec),
        (reimport, _reimportGuardSpec),
        (continuation, _continuationGuardSpec),
        (recovery, _automaticRecoveryBeginGuardSpec),
        (recovery, _automaticRecoveryResetGuardSpec),
      ]) {
        expect(
          _commandBindingViolations(
            method: method,
            spec: spec,
            origins: commandOrigins,
          ),
          isEmpty,
          reason:
              '${method.name.lexeme}/${spec.mutationName} must bind every '
              'guard, proof, value, and mutation to its reviewed declaration.',
        );
      }

      expect(
        _virtualInitialImportCommandViolations('''
    capability.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(token, context) ||
        !_reportAllowsCommand(
          admittedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    beginAttempted = true;
    await controller.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
'''),
        isEmpty,
        reason: 'The exact accepted rejecting-guard shape must remain valid.',
      );

      final commandMutations = <String, String>{
        'inverted guard polarity': '''
    capability.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (_commandAndActionAreCurrent(token, context) &&
        _reportAllowsCommand(
          admittedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    beginAttempted = true;
    await controller.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
''',
        'unsafe Boolean operator': '''
    capability.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(token, context) &&
        !_reportAllowsCommand(
          admittedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    beginAttempted = true;
    await controller.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
''',
        'required report conjunct removed': '''
    capability.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(token, context)) {
      return;
    }
    beginAttempted = true;
    await controller.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
''',
        'currentness negation removed': '''
    capability.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (_commandAndActionAreCurrent(token, context) ||
        !_reportAllowsCommand(
          admittedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    beginAttempted = true;
    await controller.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
''',
        'real guard moved before await with dummy nearby guard': '''
    capability.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(token, context) ||
        !_reportAllowsCommand(
          admittedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    await refreshEvidence();
    capability.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(token, context) ||
        !_reportAllowsCommand(
          admittedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      observeOnly();
    }
    beginAttempted = true;
    await controller.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
''',
      };
      for (final MapEntry(:key, :value) in commandMutations.entries) {
        expect(
          _virtualInitialImportCommandViolations(value),
          isNotEmpty,
          reason: '$key must fail the exact command-boundary policy.',
        );
      }

      final virtualContinuation = _parseVirtualCommand('''
    capability.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandRetainsBinding(token, actionContext, binding) ||
        controller.current.operationId != binding.operationId ||
        controller.current.processSessionId != binding.processSessionId ||
        controller.current.status != OnboardingOperationStatus.interrupted ||
        !_reportAllowsCommand(
          admittedReport,
          predicate: (report) => _reportAllowsInterruptedContinuation(
            report,
            controller.current,
          ),
        )) {
      return;
    }
    await controller.resume(operationId: binding.operationId);
''');
      expect(
        _commandGuardViolations(
          method: virtualContinuation,
          spec: _continuationGuardSpec,
        ),
        isEmpty,
        reason: 'The exact continuation binding guard must be recognized.',
      );

      final bindingUnit = await _resolveVirtualUnit(
        _commandBindingFixtureSource,
      );
      final virtualOrigins = _virtualCommandBindingOrigins(bindingUnit);
      final renamedPositive = _classMethod(
        bindingUnit,
        'OnboardingJourneyCoordinator',
        'renamedPositive',
      );
      expect(
        _commandBindingViolations(
          method: renamedPositive,
          spec: _initialImportGuardSpec,
          origins: virtualOrigins,
        ),
        isEmpty,
        reason:
            'Harmless local renames must not fail the binding-aware policy.',
      );
      for (final methodName in <String>[
        'shadowedCurrentnessHelper',
        'shadowedReportHelper',
        'shadowedPredicate',
        'wrongClaimedValue',
        'lookalikeMutation',
        'sameSpelledUnrelatedToken',
        'conditionalControllerProvenance',
        'discardedControllerRead',
        'conditionalReportProvenance',
        'discardedReportRead',
      ]) {
        expect(
          _commandBindingViolations(
            method: _classMethod(
              bindingUnit,
              'OnboardingJourneyCoordinator',
              methodName,
            ),
            spec: _initialImportGuardSpec,
            origins: virtualOrigins,
          ),
          isNotEmpty,
          reason:
              '$methodName must fail even though its source spelling resembles '
              'the reviewed command boundary.',
        );
      }
      expect(
        _commandBindingViolations(
          method: _classMethod(
            bindingUnit,
            'OnboardingJourneyCoordinator',
            'fakeResetAccessor',
          ),
          spec: _automaticRecoveryResetGuardSpec,
          origins: virtualOrigins,
        ),
        isNotEmpty,
        reason:
            'A same-signature reset accessor must not satisfy the exact '
            'Ref.read/provider binding.',
      );
    },
  );
}

CompilationUnit _parseUnit(String path) {
  final result = parseString(
    content: _readSource(path),
    path: path,
    throwIfDiagnostics: false,
  );
  expect(
    result.errors,
    isEmpty,
    reason: '$path must parse before its architecture can be inspected.',
  );
  return result.unit;
}

AnalysisContextCollection? _projectAnalysisContexts;

Future<CompilationUnit> _resolveUnit(String path) async {
  final absolutePath = File(path).absolute.path;
  final contexts = _projectAnalysisContexts ??= AnalysisContextCollection(
    includedPaths: <String>[Directory.current.absolute.path],
    sdkPath: _dartSdkPath(),
  );
  final result = await contexts
      .contextFor(absolutePath)
      .currentSession
      .getResolvedUnit(absolutePath);
  expect(
    result,
    isA<ResolvedUnitResult>(),
    reason: '$path must resolve before binding identity can be inspected.',
  );
  return (result as ResolvedUnitResult).unit;
}

Future<CompilationUnit> _resolveVirtualUnit(String source) async {
  final directory = Directory.systemTemp.createTempSync(
    'messagelens_onboarding_binding_policy_',
  );
  final file = File('${directory.path}/policy.dart')..writeAsStringSync(source);
  AnalysisContextCollection? contexts;
  try {
    contexts = AnalysisContextCollection(
      includedPaths: <String>[file.path],
      sdkPath: _dartSdkPath(),
    );
    final result = await contexts
        .contextFor(file.path)
        .currentSession
        .getResolvedUnit(file.path);
    expect(
      result,
      isA<ResolvedUnitResult>(),
      reason: 'The virtual binding-policy fixture must resolve.',
    );
    return (result as ResolvedUnitResult).unit;
  } finally {
    await contexts?.dispose();
    directory.deleteSync(recursive: true);
  }
}

String _dartSdkPath() {
  final configuredRoot = Platform.environment['FLUTTER_ROOT'];
  if (configuredRoot != null) {
    return '$configuredRoot/bin/cache/dart-sdk';
  }
  const cacheMarker = '/bin/cache/';
  final executable = Platform.resolvedExecutable;
  final markerIndex = executable.indexOf(cacheMarker);
  if (markerIndex >= 0) {
    return '${executable.substring(0, markerIndex)}'
        '/bin/cache/dart-sdk';
  }
  throw StateError('Unable to locate the Flutter-bundled Dart SDK.');
}

FunctionDeclaration _topLevelFunction(CompilationUnit unit, String name) {
  return unit.declarations.whereType<FunctionDeclaration>().singleWhere(
    (declaration) => declaration.name.lexeme == name,
  );
}

MethodDeclaration _classMethod(
  CompilationUnit unit,
  String className,
  String methodName,
) {
  final declaration = _classDeclarations(
    unit,
  ).singleWhere((candidate) => candidate.name.lexeme == className);
  return declaration.members.whereType<MethodDeclaration>().singleWhere(
    (method) => method.name.lexeme == methodName,
  );
}

List<ClassDeclaration> _classDeclarations(CompilationUnit unit) {
  return unit.declarations.whereType<ClassDeclaration>().toList(
    growable: false,
  );
}

InterfaceElement2 _classElement(CompilationUnit unit, String className) {
  final declaration = _classDeclarations(
    unit,
  ).singleWhere((candidate) => candidate.name.lexeme == className);
  final element = declaration.declaredFragment?.element;
  expect(
    element,
    isNotNull,
    reason: '$className must resolve to its declared interface element.',
  );
  return element!;
}

Element2 _topLevelVariableElement(CompilationUnit unit, String name) {
  final declaration = unit.declarations
      .whereType<TopLevelVariableDeclaration>()
      .expand((candidate) => candidate.variables.variables)
      .singleWhere((candidate) => candidate.name.lexeme == name);
  final element = declaration.declaredFragment?.element;
  expect(
    element,
    isNotNull,
    reason: '$name must resolve to its declared top-level element.',
  );
  return element!;
}

InterfaceElement2 _referencedInterfaceElement(
  CompilationUnit unit,
  String name, {
  required String libraryUriContains,
}) {
  final visitor = _NamedTypeVisitor(name);
  unit.accept(visitor);
  final elements = visitor.types
      .map((type) => type.element2)
      .whereType<InterfaceElement2>()
      .where(
        (element) =>
            element.library2.uri.toString().contains(libraryUriContains),
      )
      .map((element) => element.nonSynthetic2)
      .whereType<InterfaceElement2>()
      .toSet();
  expect(
    elements,
    hasLength(1),
    reason: '$name must resolve to one reviewed interface declaration.',
  );
  return elements.single;
}

Element2 _referencedElement(
  CompilationUnit unit,
  String name, {
  required String libraryUriContains,
}) {
  final visitor = _IdentifierElementVisitor(name);
  unit.accept(visitor);
  final elements = visitor.identifiers
      .map((identifier) => identifier.element)
      .whereType<Element2>()
      .where(
        (element) =>
            element.library2?.uri.toString().contains(libraryUriContains) ??
            false,
      )
      .map((element) => element.nonSynthetic2)
      .toSet();
  expect(
    elements,
    hasLength(1),
    reason: '$name must resolve to one reviewed declaration origin.',
  );
  return elements.single;
}

List<MethodInvocation> _invocationsNamed(AstNode node, String name) {
  final visitor = _InvocationVisitor(name);
  node.accept(visitor);
  return visitor.invocations;
}

List<AwaitExpression> _allAwaitExpressions(AstNode node) {
  final visitor = _AwaitVisitor();
  node.accept(visitor);
  return visitor.expressions;
}

List<AwaitExpression> _directAwaitExpressions(FunctionDeclaration function) {
  return _allAwaitExpressions(function.functionExpression.body);
}

List<String> _directAwaitedInvocationNames(FunctionDeclaration function) {
  return _directAwaitExpressions(function)
      .map((expression) => expression.expression)
      .whereType<MethodInvocation>()
      .map((invocation) => invocation.methodName.name)
      .toList(growable: false);
}

Set<String> _identifierNames(AstNode node) {
  final visitor = _IdentifierVisitor();
  node.accept(visitor);
  return visitor.names;
}

NamedExpression _namedArgument(MethodInvocation invocation, String name) {
  return _namedArgumentOrNull(invocation, name) ??
      (throw StateError(
        'Missing named argument $name on ${invocation.methodName.name}.',
      ));
}

NamedExpression? _namedArgumentOrNull(
  MethodInvocation invocation,
  String name,
) {
  return _namedArgumentInListOrNull(invocation.argumentList, name);
}

NamedExpression? _namedArgumentInListOrNull(
  ArgumentList argumentList,
  String name,
) {
  for (final argument in argumentList.arguments.whereType<NamedExpression>()) {
    if (argument.name.label.name == name) {
      return argument;
    }
  }
  return null;
}

String? _firstStringArgument(MethodInvocation invocation) {
  final arguments = invocation.argumentList.arguments;
  final first = arguments.isEmpty ? null : arguments.first;
  return first is SimpleStringLiteral ? first.value : null;
}

void _expectAdmissionBracketsSingleAwait(FunctionDeclaration function) {
  final awaits = _directAwaitExpressions(function);
  expect(awaits, hasLength(1));
  final awaitExpression = awaits.single;
  final admissionCalls = _invocationsNamed(function, 'call')
      .where(
        (invocation) =>
            invocation.target?.toSource() == 'requireCurrentAdmission',
      )
      .toList(growable: false);
  expect(
    admissionCalls.where(
      (invocation) => invocation.end <= awaitExpression.offset,
    ),
    hasLength(1),
  );
  expect(
    admissionCalls.where(
      (invocation) => invocation.offset >= awaitExpression.end,
    ),
    hasLength(1),
  );
}

List<String> _protectedIoCheckpointViolations(
  Iterable<AstNode> roots, {
  required bool Function(MethodInvocation invocation) protectedInvocation,
  bool allowCallerProofBeforeEntry = false,
  Element2? approvedCallback,
}) {
  final findings = <String>[];
  for (final root in roots) {
    for (final invocation in _allMethodInvocations(
      root,
    ).where(protectedInvocation)) {
      final earlierAwaits = _allAwaitExpressions(root)
          .where((expression) => expression.end <= invocation.offset)
          .toList(growable: false);
      if (allowCallerProofBeforeEntry && earlierAwaits.isEmpty) {
        continue;
      }
      final preceding = _adjacentStatement(invocation, before: true);
      if (preceding == null ||
          !_isApprovedPersistentStoreCheckpoint(
            preceding,
            root,
            approvedCallback: approvedCallback,
          )) {
        findings.add(
          'Missing dominating approved checkpoint before '
          '${invocation.toSource()} at '
          '${invocation.offset}.',
        );
        continue;
      }
      if (earlierAwaits.isNotEmpty &&
          preceding.offset <= earlierAwaits.last.end) {
        findings.add(
          'The approved checkpoint before ${invocation.toSource()} does not '
          'follow the most recent await.',
        );
      }
    }
  }
  return findings;
}

List<String> _missingApprovedCheckpointsAfter(
  Iterable<AstNode> roots, {
  required bool Function(MethodInvocation invocation) protectedInvocation,
  Element2? approvedCallback,
}) {
  final findings = <String>[];
  for (final root in roots) {
    for (final invocation in _allMethodInvocations(
      root,
    ).where(protectedInvocation)) {
      final following = _adjacentStatement(invocation, before: false);
      if (following == null ||
          !_isApprovedPersistentStoreCheckpoint(
            following,
            root,
            approvedCallback: approvedCallback,
          )) {
        findings.add(
          'Missing checkpoint after ${invocation.toSource()} at '
          '${invocation.offset}.',
        );
      }
    }
  }
  return findings;
}

Statement? _adjacentStatement(AstNode node, {required bool before}) {
  AstNode? cursor = node;
  while (cursor != null) {
    while (cursor != null && cursor is! Statement) {
      cursor = cursor.parent;
    }
    if (cursor is! Statement) {
      return null;
    }
    final statement = cursor;
    final parent = statement.parent;
    if (parent is Block) {
      final index = parent.statements.indexOf(statement);
      final adjacentIndex = before ? index - 1 : index + 1;
      if (adjacentIndex >= 0 && adjacentIndex < parent.statements.length) {
        return parent.statements[adjacentIndex];
      }
    }
    cursor = statement.parent;
  }
  return null;
}

bool _isApprovedPersistentStoreCheckpoint(
  Statement statement,
  AstNode auditedRoot, {
  Element2? approvedCallback,
}) {
  const callbackName = 'requirePersistentArchiveStoreAdmission';
  final legacyNameMatch =
      approvedCallback == null &&
      _formalParameterNames(auditedRoot).contains(callbackName);
  if ((!legacyNameMatch && approvedCallback == null) ||
      statement is! ExpressionStatement) {
    return false;
  }
  final expression = statement.expression;
  if (expression is FunctionExpressionInvocation) {
    final function = expression.function;
    return approvedCallback != null &&
        function is SimpleIdentifier &&
        _sameElement(function.element, approvedCallback);
  }
  if (expression is! MethodInvocation) {
    return false;
  }
  if (expression.target == null) {
    return approvedCallback == null
        ? expression.methodName.name == callbackName
        : _sameElement(expression.methodName.element, approvedCallback);
  }
  final target = expression.target;
  if (expression.methodName.name != 'call' || target is! SimpleIdentifier) {
    return false;
  }
  return approvedCallback == null
      ? target.name == callbackName
      : _sameElement(target.element, approvedCallback);
}

Element2 _formalParameterElement(AstNode root, String name) {
  final parameters = switch (root) {
    MethodDeclaration(:final parameters) => parameters,
    FunctionDeclaration(functionExpression: final function) =>
      function.parameters,
    _ => null,
  };
  final parameter = parameters?.parameters.singleWhere(
    (candidate) => candidate.name?.lexeme == name,
  );
  final element = parameter?.declaredFragment?.element;
  expect(
    element,
    isNotNull,
    reason: '$name must resolve to its declared formal parameter.',
  );
  return element!;
}

List<String> _callbackPropagationViolations({
  required AstNode caller,
  required Element2 callerCallback,
  required AstNode callee,
  required Element2 calleeCallback,
  required String argumentName,
  required int expectedCallCount,
}) {
  final calleeElement = switch (callee) {
    MethodDeclaration(:final declaredFragment) => declaredFragment?.element,
    FunctionDeclaration(:final declaredFragment) => declaredFragment?.element,
    _ => null,
  };
  if (calleeElement == null) {
    return const <String>['The propagated-to declaration is unresolved.'];
  }
  final calls = _allMethodInvocations(caller)
      .where(
        (invocation) =>
            _sameElement(invocation.methodName.element, calleeElement),
      )
      .toList(growable: false);
  final findings = <String>[];
  if (calls.length != expectedCallCount) {
    findings.add(
      'Expected $expectedCallCount calls bound to ${calleeElement.displayName}; '
      'found ${calls.length}.',
    );
  }
  for (final call in calls) {
    final argument = _namedArgumentOrNull(call, argumentName)?.expression;
    if (argument is! SimpleIdentifier ||
        !_sameElement(argument.element, callerCallback)) {
      findings.add(
        '${call.toSource()} does not forward the caller formal callback.',
      );
    }
  }
  final calleeUsesItsFormal = _allMethodInvocations(callee).any((invocation) {
    final target = invocation.target;
    return invocation.methodName.name == 'call' &&
        target is SimpleIdentifier &&
        _sameElement(target.element, calleeCallback);
  });
  if (!calleeUsesItsFormal) {
    findings.add('The callee never invokes its own callback formal.');
  }
  return findings;
}

const _protectedIoBindingFixtureSource = '''
class Store {
  Future<void> writeSetting(String key) async {}
}

class VirtualSettingsWriter {
  final Store store = Store();

  Future<void> valid(void Function() proof) async {
    proof();
    await store.writeSetting('key');
  }

  Future<void> shadowed(void Function() proof) async {
    {
      void proof() {}
      proof();
      await store.writeSetting('key');
    }
  }

  Future<void> unrelatedCallable(void Function() proof) async {
    void fakeProof() {}
    {
      final proof = fakeProof;
      proof();
      await store.writeSetting('key');
    }
  }
}

class ProofCallee {
  Future<void> read({void Function()? proof}) async {
    proof?.call();
  }
}

class ProofCaller {
  final ProofCallee callee = ProofCallee();

  Future<void> valid(void Function() proof) async {
    await callee.read(proof: proof);
  }

  Future<void> dropsProof(void Function() proof) async {
    await callee.read(proof: null);
  }
}
''';

Set<String> _formalParameterNames(AstNode root) {
  final parameters = switch (root) {
    MethodDeclaration(:final parameters) => parameters,
    FunctionDeclaration(functionExpression: final function) =>
      function.parameters,
    _ => null,
  };
  if (parameters == null) {
    return const <String>{};
  }
  return parameters.parameters
      .map((parameter) => parameter.name?.lexeme)
      .whereType<String>()
      .toSet();
}

MethodDeclaration _virtualProtectedWrite(String body) {
  final unit = parseString(
    content:
        '''
class VirtualSettingsWriter {
  Future<void> write(
    void Function() requirePersistentArchiveStoreAdmission,
  ) async {
$body
  }
}
''',
  ).unit;
  return _classMethod(unit, 'VirtualSettingsWriter', 'write');
}

List<MethodInvocation> _allMethodInvocations(AstNode node) {
  final visitor = _AllInvocationVisitor();
  node.accept(visitor);
  return visitor.invocations;
}

List<String> _fixtureRealismViolations({
  required CompilationUnit unit,
  required MethodDeclaration create,
  required FunctionExpression criticalBody,
}) {
  final findings = <String>[];
  if (!_formalParameterNames(
    create,
  ).contains('useRealGlobalEnvironmentFeedback')) {
    findings.add('The fixture does not expose the real-feedback selection.');
  }
  final overrides = _allMethodInvocations(create).where(
    (invocation) => invocation.methodName.name.startsWith('overrideWith'),
  );
  final environmentOverrides = overrides
      .where(
        (invocation) => invocation.toSource().contains(
          'onboardingEnvironmentReportProvider',
        ),
      )
      .toList(growable: false);
  if (environmentOverrides.length != 1) {
    findings.add(
      'The fixture must have exactly one conditional Environment override.',
    );
  }
  for (final override in environmentOverrides) {
    final conditional = _ancestorIfElement(override);
    if (conditional == null ||
        conditional.expression.toSource() !=
            '!useRealGlobalEnvironmentFeedback') {
      findings.add(
        'The Environment override is not gated by the real-feedback flag.',
      );
    }
  }
  for (final providerName in <String>{
    'archiveMutationCoordinatorProvider',
    'exclusiveAuthorityRegistryProvider',
  }) {
    if (overrides.any(
      (invocation) => invocation.toSource().contains(providerName),
    )) {
      findings.add('$providerName is replaced by the fixture.');
    }
  }

  final fixtureClass = _classDeclarations(
    unit,
  ).singleWhere((declaration) => declaration.name.lexeme == '_JourneyFixture');
  final fixtureFieldNames = fixtureClass.members
      .whereType<FieldDeclaration>()
      .expand((field) => field.fields.variables)
      .map((variable) => variable.name.lexeme)
      .toSet();
  if (!fixtureFieldNames.contains('globalEnvironmentReports')) {
    findings.add('The fixture does not expose the real observation recorder.');
  }

  final recorder = _variableNamed(create, 'globalEnvironmentReports');
  if (!_isInstanceCreationOf(
    recorder?.initializer,
    '_GlobalEnvironmentReportRecorder',
  )) {
    findings.add('The real observation recorder is not constructed locally.');
  }

  final subscription = _variableNamed(create, 'globalEnvironmentSubscription');
  final listen = subscription?.initializer;
  if (listen is! MethodInvocation ||
      listen.methodName.name != 'listen' ||
      listen.target?.toSource() != 'container') {
    findings.add('The fixture does not subscribe through its real container.');
  } else {
    final positional = listen.argumentList.arguments
        .where((argument) => argument is! NamedExpression)
        .toList(growable: false);
    if (positional.length < 2 ||
        positional.first.toSource() != 'onboardingEnvironmentReportProvider') {
      findings.add(
        'The fixture does not listen to the global Environment provider.',
      );
    } else {
      final listener = positional[1];
      final recordCalls = listener is FunctionExpression
          ? _invocationsNamed(listener, 'record')
                .where(
                  (invocation) =>
                      invocation.target?.toSource() ==
                          'globalEnvironmentReports' &&
                      invocation.argumentList.arguments.length == 1 &&
                      invocation.argumentList.arguments.single.toSource() ==
                          'next',
                )
                .toList(growable: false)
          : const <MethodInvocation>[];
      if (recordCalls.length != 1) {
        findings.add(
          'The global Environment listener does not record into the returned '
          'real recorder.',
        );
      }
    }
    final fireImmediately = _namedArgumentOrNull(listen, 'fireImmediately');
    if (fireImmediately?.expression.toSource() != 'true') {
      findings.add('The real Environment listener is not fired immediately.');
    }
  }
  final writesToRealRecorder = _invocationsNamed(create, 'record')
      .where(
        (invocation) =>
            invocation.target?.toSource() == 'globalEnvironmentReports',
      )
      .toList(growable: false);
  if (writesToRealRecorder.length != 1) {
    findings.add(
      'The real recorder must be written exactly once, by the global '
      'Environment listener.',
    );
  }

  final returnedFixtures = _fixtureConstructionArguments(create);
  if (returnedFixtures.length != 1) {
    findings.add('The fixture does not return exactly one _JourneyFixture._.');
  } else {
    final returnedRecorder = _namedArgumentInListOrNull(
      returnedFixtures.single,
      'globalEnvironmentReports',
    );
    final returnedSubscription = _namedArgumentInListOrNull(
      returnedFixtures.single,
      'globalEnvironmentSubscription',
    );
    if (returnedRecorder?.expression.toSource() != 'globalEnvironmentReports') {
      findings.add('The returned fixture is not bound to the real recorder.');
    }
    if (returnedSubscription?.expression.toSource() !=
        'globalEnvironmentSubscription') {
      findings.add(
        'The returned fixture does not retain the real provider subscription.',
      );
    }
  }

  findings.addAll(_criticalRealFeedbackWaitViolations(criticalBody));
  return findings;
}

List<String> _fixtureBindingViolations({
  required CompilationUnit unit,
  required MethodDeclaration create,
  required FunctionExpression criticalBody,
  required Element2 environmentProvider,
  required InterfaceElement2 providerContainer,
}) {
  final findings = <String>[];
  final fixtureType = _classElement(unit, '_JourneyFixture');
  final recorderType = _classElement(unit, '_GlobalEnvironmentReportRecorder');
  final listenMethod = providerContainer.getMethod2('listen');
  final recordMethod = recorderType.getMethod2('record');
  final waitMethod = recorderType.getMethod2('waitFor');
  final createMethod = fixtureType.getMethod2('create');
  final containerField = fixtureType.getField2('container');
  final recorderField = fixtureType.getField2('globalEnvironmentReports');
  if (listenMethod == null ||
      recordMethod == null ||
      waitMethod == null ||
      createMethod == null ||
      containerField == null ||
      recorderField == null) {
    return const <String>[
      'The reviewed fixture/container/recorder declarations are incomplete.',
    ];
  }

  final authenticListens = _allMethodInvocations(create)
      .where((invocation) {
        if (!_sameElement(invocation.methodName.element, listenMethod)) {
          return false;
        }
        final positional = invocation.argumentList.arguments
            .where((argument) => argument is! NamedExpression)
            .toList(growable: false);
        return positional.length >= 2 &&
            positional.first is SimpleIdentifier &&
            _sameElement(
              (positional.first as SimpleIdentifier).element,
              environmentProvider,
            );
      })
      .toList(growable: false);
  if (authenticListens.length != 1) {
    final finding = <String>[
      'The fixture must contain exactly one listen call bound to the actual ',
      'ProviderContainer.listen and top-level Environment provider; found ',
      '${authenticListens.length}.',
    ].join();
    return <String>[finding];
  }
  final listen = authenticListens.single;
  final containerTarget = listen.target;
  Element2? containerElement;
  if (containerTarget is! SimpleIdentifier) {
    findings.add('The authentic listener has no local container receiver.');
  } else {
    containerElement = containerTarget.element;
    final declaration = _variableForElement(create, containerTarget.element);
    final initializer = declaration?.initializer;
    final constructedType = initializer is InstanceCreationExpression
        ? initializer.constructorName.type.element2
        : null;
    if (!_sameElement(constructedType, providerContainer)) {
      findings.add(
        'The listener receiver is not the actual locally constructed '
        'ProviderContainer.',
      );
    }
  }

  final subscription = _variableWhoseInitializerContains(create, listen);
  final positional = listen.argumentList.arguments
      .where((argument) => argument is! NamedExpression)
      .toList(growable: false);
  final listener = positional.length > 1 ? positional[1] : null;
  final listenerParameters = listener is FunctionExpression
      ? listener.parameters?.parameters
      : null;
  final reportFormal =
      listenerParameters != null && listenerParameters.length > 1
      ? listenerParameters[1].declaredFragment?.element
      : null;
  final recordCalls = listener is FunctionExpression
      ? _allMethodInvocations(listener)
            .where(
              (invocation) =>
                  _sameElement(invocation.methodName.element, recordMethod),
            )
            .toList(growable: false)
      : const <MethodInvocation>[];
  if (recordCalls.length != 1 ||
      recordCalls.single.target is! SimpleIdentifier) {
    findings.add(
      'The authentic Environment listener does not write exactly once to the '
      'reviewed recorder type.',
    );
    return findings;
  }
  final recordArguments = recordCalls.single.argumentList.arguments;
  final recordedPayload = recordArguments.length == 1
      ? recordArguments.single
      : null;
  if (reportFormal == null ||
      recordedPayload is! SimpleIdentifier ||
      !_sameElement(recordedPayload.element, reportFormal)) {
    findings.add(
      'The authentic Environment listener does not record its exact report '
      'payload formal.',
    );
  }
  final recorderReference = recordCalls.single.target! as SimpleIdentifier;
  final recorder = _variableForElement(create, recorderReference.element);
  final recorderInitializer = recorder?.initializer;
  final recorderConstructedType =
      recorderInitializer is InstanceCreationExpression
      ? recorderInitializer.constructorName.type.element2
      : null;
  if (!_sameElement(recorderConstructedType, recorderType)) {
    findings.add('The listener recorder is not locally constructed.');
  }
  final recorderElement = recorder?.declaredFragment?.element;
  final subscriptionElement = subscription?.declaredFragment?.element;
  final writes = _allMethodInvocations(create)
      .where((invocation) {
        final target = invocation.target;
        return _sameElement(invocation.methodName.element, recordMethod) &&
            target is SimpleIdentifier &&
            _sameElement(target.element, recorderElement);
      })
      .toList(growable: false);
  if (writes.length != 1) {
    findings.add('The connected recorder has an unauthenticated writer.');
  }

  final returned = _fixtureConstructionArguments(create);
  if (returned.length != 1) {
    findings.add('The fixture return construction is ambiguous.');
  } else {
    final returnedRecorder = _namedArgumentInListOrNull(
      returned.single,
      'globalEnvironmentReports',
    )?.expression;
    final returnedSubscription = _namedArgumentInListOrNull(
      returned.single,
      'globalEnvironmentSubscription',
    )?.expression;
    final returnedContainer = _namedArgumentInListOrNull(
      returned.single,
      'container',
    )?.expression;
    if (returnedContainer is! SimpleIdentifier ||
        !_sameElement(returnedContainer.element, containerElement)) {
      findings.add(
        'The returned fixture owns a different ProviderContainer from the '
        'listener.',
      );
    }
    if (returnedRecorder is! SimpleIdentifier ||
        !_sameElement(returnedRecorder.element, recorderElement)) {
      findings.add('The returned fixture carries a different recorder.');
    }
    if (returnedSubscription is! SimpleIdentifier ||
        !_sameElement(returnedSubscription.element, subscriptionElement)) {
      findings.add('The returned fixture carries a different subscription.');
    }
  }

  final tests = _invocationsNamed(criticalBody, 'test');
  if (tests.length != 4) {
    findings.add('The critical group does not contain exactly four tests.');
    return findings;
  }
  for (final testInvocation in tests) {
    final arguments = testInvocation.argumentList.arguments;
    final callback = arguments.length > 1 ? arguments[1] : null;
    if (callback is! FunctionExpression) {
      findings.add('A critical test has no callback.');
      continue;
    }
    final fixtureVariables = _allVariableDeclarations(callback)
        .where((declaration) {
          final initializer = declaration.initializer;
          if (initializer == null) {
            return false;
          }
          final createCall = _directValueInvocation(initializer);
          return createCall != null &&
              _sameElement(createCall.methodName.element, createMethod);
        })
        .toList(growable: false);
    if (fixtureVariables.length != 1) {
      findings.add(
        'A critical test does not receive exactly one actual fixture.',
      );
      continue;
    }
    final fixtureElement = fixtureVariables.single.declaredFragment?.element;
    final waits = _allMethodInvocations(callback)
        .where((invocation) {
          if (!_sameElement(invocation.methodName.element, waitMethod)) {
            return false;
          }
          final fieldAccess = _fieldAccessBinding(invocation.target);
          return _sameElement(fieldAccess?.base, fixtureElement) &&
              _sameElement(fieldAccess?.field, recorderField);
        })
        .toList(growable: false);
    if (waits.length != 1) {
      findings.add(
        'A critical test does not wait through the exact recorder field '
        'returned by its actual fixture.',
      );
    }
  }
  return findings;
}

({Element2? base, Element2? field})? _fieldAccessBinding(
  Expression? expression,
) {
  if (expression is PrefixedIdentifier) {
    return (
      base: expression.prefix.element,
      field: expression.identifier.element,
    );
  }
  if (expression is PropertyAccess) {
    final target = expression.realTarget;
    if (target is SimpleIdentifier) {
      return (base: target.element, field: expression.propertyName.element);
    }
  }
  return null;
}

VariableDeclaration? _variableForElement(AstNode root, Element2? element) {
  if (element == null) {
    return null;
  }
  for (final declaration in _allVariableDeclarations(root)) {
    if (_sameElement(declaration.declaredFragment?.element, element)) {
      return declaration;
    }
  }
  return null;
}

VariableDeclaration? _variableWhoseInitializerContains(
  AstNode root,
  AstNode expected,
) {
  for (final declaration in _allVariableDeclarations(root)) {
    final initializer = declaration.initializer;
    if (initializer != null &&
        expected.offset >= initializer.offset &&
        expected.end <= initializer.end) {
      return declaration;
    }
  }
  return null;
}

List<String> _criticalRealFeedbackWaitViolations(
  FunctionExpression criticalBody,
) {
  final findings = <String>[];
  final tests = _invocationsNamed(criticalBody, 'test');
  if (tests.length != 4) {
    return <String>[
      'The real aggregate-maintenance group must contain exactly four tests.',
    ];
  }
  for (final testInvocation in tests) {
    final arguments = testInvocation.argumentList.arguments;
    final callback = arguments.length > 1 ? arguments[1] : null;
    if (callback is! FunctionExpression) {
      findings.add('A critical real-feedback test has no function body.');
      continue;
    }
    final fixture = _variableNamed(callback, 'fixture');
    final fixtureInitializer = fixture?.initializer;
    final fixtureName = fixture?.name.lexeme;
    final createCalls = fixtureInitializer == null
        ? const <MethodInvocation>[]
        : _invocationsNamed(fixtureInitializer, 'create')
              .where(
                (invocation) =>
                    invocation.target?.toSource() == '_JourneyFixture',
              )
              .toList(growable: false);
    if (createCalls.length != 1 ||
        _namedArgumentOrNull(
              createCalls.single,
              'useRealGlobalEnvironmentFeedback',
            )?.expression.toSource() !=
            'true') {
      findings.add(
        'A critical test does not create its fixture in real-feedback mode.',
      );
      continue;
    }
    final waits = _invocationsNamed(callback, 'waitFor')
        .where(
          (invocation) =>
              invocation.target?.toSource() ==
                  '$fixtureName.globalEnvironmentReports' &&
              invocation.argumentList.arguments.length == 1 &&
              invocation.argumentList.arguments.single.toSource() ==
                  'OnboardingEnvironmentState.maintenanceInProgress',
        )
        .toList(growable: false);
    if (waits.length != 1) {
      findings.add(
        'A critical test does not wait for maintenance through the exact '
        'real recorder returned by its fixture.',
      );
    }
  }
  if (_invocationsNamed(criticalBody, 'overrideWith').isNotEmpty) {
    findings.add(
      'Critical tests replace providers inside the real-loop group.',
    );
  }
  if (_invocationsNamed(criticalBody, 'record').isNotEmpty) {
    findings.add(
      'Critical tests must not inject reports into their observation recorder.',
    );
  }
  return findings;
}

FunctionExpression _realFeedbackGroupBody(FunctionDeclaration main) {
  final group = _invocationsNamed(main, 'group').singleWhere(
    (invocation) =>
        _firstStringArgument(invocation) ==
        'real aggregate-maintenance feedback loop',
  );
  return group.argumentList.arguments[1] as FunctionExpression;
}

CompilationUnit _parseVirtualFixturePolicyUnit({
  bool conditionEnvironmentOverride = true,
  bool replaceAuthorities = false,
  String listenerRecorder = 'globalEnvironmentReports',
  String returnedRecorder = 'globalEnvironmentReports',
  String waitField = 'globalEnvironmentReports',
  bool injectFakeRecorderWrite = false,
}) {
  final testBodies = List<String>.generate(
    4,
    (index) =>
        '''
    test('critical $index', () async {
      final fixture = await _JourneyFixture.create(
        useRealGlobalEnvironmentFeedback: true,
      );
      await fixture.$waitField.waitFor(
        OnboardingEnvironmentState.maintenanceInProgress,
      );
    });
''',
  ).join();
  final conditional = conditionEnvironmentOverride
      ? 'if (!useRealGlobalEnvironmentFeedback)'
      : '';
  final authorityOverrides = replaceAuthorities
      ? '''
      archiveMutationCoordinatorProvider.overrideWith(fakeCoordinator),
      exclusiveAuthorityRegistryProvider.overrideWith(fakeRegistry),
'''
      : '';
  final fakeRecorderWrite = injectFakeRecorderWrite
      ? '''
    fakeSource.listen(
      (next) => globalEnvironmentReports.record(next),
    );
'''
      : '';
  return parseString(
    content:
        '''
void main() {
  group('real aggregate-maintenance feedback loop', () {
$testBodies
  });
}

class _JourneyFixture {
  _JourneyFixture._({
    required this.globalEnvironmentReports,
    required this.fakeEnvironmentReports,
    required this.globalEnvironmentSubscription,
  });

  final _GlobalEnvironmentReportRecorder globalEnvironmentReports;
  final _GlobalEnvironmentReportRecorder fakeEnvironmentReports;
  final Object globalEnvironmentSubscription;

  static Future<_JourneyFixture> create({
    bool useRealGlobalEnvironmentFeedback = false,
  }) async {
    final overrides = [
      $conditional
        onboardingEnvironmentReportProvider.overrideWith((ref) async => fake),
$authorityOverrides
    ];
    final container = ProviderContainer(overrides: overrides);
    final globalEnvironmentReports = _GlobalEnvironmentReportRecorder();
    final fakeEnvironmentReports = _GlobalEnvironmentReportRecorder();
    final deadEnvironmentReports = _GlobalEnvironmentReportRecorder();
    final globalEnvironmentSubscription = container.listen(
      onboardingEnvironmentReportProvider,
      (_, next) => $listenerRecorder.record(next),
      fireImmediately: true,
    );
$fakeRecorderWrite
    return _JourneyFixture._(
      globalEnvironmentReports: $returnedRecorder,
      fakeEnvironmentReports: fakeEnvironmentReports,
      globalEnvironmentSubscription: globalEnvironmentSubscription,
    );
  }
}
''',
  ).unit;
}

String _fixtureBindingSource({
  required bool alternateContainer,
  required bool fakeContainer,
  required bool fakeProvider,
  required bool shadowListenerPayload,
  required String fixtureInitializer,
}) {
  final listenerContainer = fakeContainer || alternateContainer
      ? 'listenerContainer'
      : 'renamedContainer';
  final listenerContainerDeclaration = fakeContainer
      ? 'final listenerContainer = FakeProviderContainer(overrides: overrides);'
      : alternateContainer
      ? 'final listenerContainer = ProviderContainer(overrides: overrides);'
      : '';
  final providerShadow = fakeProvider
      ? 'final onboardingEnvironmentReportProvider = Provider<Report>();'
      : '';
  final fixtureExpression = switch (fixtureInitializer) {
    'direct' =>
      '''
await _JourneyFixture.create(
        useRealGlobalEnvironmentFeedback: true,
      )''',
    'discarded' =>
      '''
await (() async {
        await _JourneyFixture.create(
          useRealGlobalEnvironmentFeedback: true,
        );
        return unrelatedFixture;
      })()''',
    'conditional' =>
      '''
(true
        ? await _JourneyFixture.create(
            useRealGlobalEnvironmentFeedback: true,
          )
        : unrelatedFixture)''',
    'wrapper' =>
      '''
replaceFixture(
        await _JourneyFixture.create(
          useRealGlobalEnvironmentFeedback: true,
        ),
        unrelatedFixture,
      )''',
    _ => throw ArgumentError.value(
      fixtureInitializer,
      'fixtureInitializer',
      'Unknown virtual fixture initializer.',
    ),
  };
  final listener = shadowListenerPayload
      ? '''
(_, next) {
        {
          final next = Report();
          renamedRecorder.record(next);
        }
      }'''
      : '(_, next) => renamedRecorder.record(next)';
  final testBodies = List<String>.generate(
    4,
    (index) =>
        '''
    test('critical $index', () async {
      final renamedFixture = $fixtureExpression;
      await renamedFixture.globalEnvironmentReports.waitFor(
        OnboardingEnvironmentState.maintenanceInProgress,
      );
    });
''',
  ).join();
  return '''
enum OnboardingEnvironmentState { maintenanceInProgress }

class Report {}

class Provider<T> {
  Provider<T> overrideWith(Object replacement) => this;
}

final onboardingEnvironmentReportProvider = Provider<Report>();

class Subscription {}

class ProviderContainer {
  ProviderContainer({required List<Object> overrides});

  Subscription listen<T>(
    Provider<T> provider,
    void Function(Object?, T) listener, {
    bool fireImmediately = false,
  }) => Subscription();
}

class FakeProviderContainer {
  FakeProviderContainer({required List<Object> overrides});

  Subscription listen<T>(
    Provider<T> provider,
    void Function(Object?, T) listener, {
    bool fireImmediately = false,
  }) => Subscription();
}

void group(String name, void Function() body) => body();
void test(String name, Future<void> Function() body) {}

late _JourneyFixture unrelatedFixture;

_JourneyFixture replaceFixture(
  _JourneyFixture authenticFixture,
  _JourneyFixture replacementFixture,
) => replacementFixture;

void main() {
  group('real aggregate-maintenance feedback loop', () {
$testBodies
  });
}

class _GlobalEnvironmentReportRecorder {
  void record(Report report) {}

  Future<void> waitFor(OnboardingEnvironmentState state) async {}
}

class _JourneyFixture {
  _JourneyFixture._({
    required this.container,
    required this.globalEnvironmentReports,
    required this.globalEnvironmentSubscription,
  });

  final ProviderContainer container;
  final _GlobalEnvironmentReportRecorder globalEnvironmentReports;
  final Subscription globalEnvironmentSubscription;

  static Future<_JourneyFixture> create({
    bool useRealGlobalEnvironmentFeedback = false,
  }) async {
    $providerShadow
    final overrides = <Object>[
      if (!useRealGlobalEnvironmentFeedback)
        onboardingEnvironmentReportProvider.overrideWith(
          (ref) async => Report(),
        ),
    ];
    final renamedContainer = ProviderContainer(overrides: overrides);
    $listenerContainerDeclaration
    final renamedRecorder = _GlobalEnvironmentReportRecorder();
    final renamedSubscription = $listenerContainer.listen(
      onboardingEnvironmentReportProvider,
      $listener,
      fireImmediately: true,
    );
    return _JourneyFixture._(
      container: renamedContainer,
      globalEnvironmentReports: renamedRecorder,
      globalEnvironmentSubscription: renamedSubscription,
    );
  }
}
''';
}

VariableDeclaration? _variableNamed(AstNode root, String name) {
  final visitor = _VariableDeclarationVisitor(name);
  root.accept(visitor);
  return visitor.declarations.length == 1 ? visitor.declarations.single : null;
}

bool _isInstanceCreationOf(Expression? expression, String typeName) {
  if (expression is InstanceCreationExpression) {
    return expression.constructorName.type.name2.lexeme == typeName;
  }
  return expression is MethodInvocation &&
      expression.target == null &&
      expression.methodName.name == typeName;
}

List<InstanceCreationExpression> _allInstanceCreations(AstNode node) {
  final visitor = _InstanceCreationVisitor();
  node.accept(visitor);
  return visitor.creations;
}

List<ArgumentList> _fixtureConstructionArguments(AstNode root) {
  final arguments = <ArgumentList>[
    ..._allInstanceCreations(root)
        .where(
          (creation) =>
              creation.constructorName.type.name2.lexeme == '_JourneyFixture' &&
              creation.constructorName.name?.name == '_',
        )
        .map((creation) => creation.argumentList),
    ..._allMethodInvocations(root)
        .where(
          (invocation) =>
              invocation.target?.toSource() == '_JourneyFixture' &&
              invocation.methodName.name == '_',
        )
        .map((invocation) => invocation.argumentList),
  ];
  return arguments;
}

const _initialImportGuardSpec = _CommandGuardSpec(
  mutationName: 'begin',
  mutationTarget: 'controller',
  operationName: 'onboardingImport',
  requiredMutationArguments: <String, String>{
    'kind': 'OnboardingOperationKind.initialImport',
    'initialStage': 'OnboardingOperationStage.messageDataBuild',
  },
  rejectionKeys: <String>{
    '!call:_commandAndActionAreCurrent',
    '!report:admittedReport:_reportAllowsInitialImport',
  },
  allowedAssignments: <String, String>{'beginAttempted': 'true'},
);

const _reimportGuardSpec = _CommandGuardSpec(
  mutationName: 'begin',
  mutationTarget: 'controller',
  operationName: 'onboardingImport',
  requiredMutationArguments: <String, String>{
    'kind': 'OnboardingOperationKind.reimport',
    'initialStage': 'OnboardingOperationStage.environmentPreparation',
  },
  rejectionKeys: <String>{
    '!call:_commandAndActionAreCurrent',
    '!report:admittedReport:_reportAllowsReimport',
  },
  allowedAssignments: <String, String>{'beginAttempted': 'true'},
);

const _continuationGuardSpec = _CommandGuardSpec(
  mutationName: 'resume',
  mutationTarget: 'controller',
  operationName: 'onboardingImport',
  requiredMutationArguments: <String, String>{
    'operationId': 'binding.operationId',
  },
  rejectionKeys: <String>{
    '!call:_commandRetainsBinding',
    '!=:controller.current.operationId:binding.operationId',
    '!=:controller.current.processSessionId:binding.processSessionId',
    '!=:controller.current.status:OnboardingOperationStatus.interrupted',
    '!report:admittedReport:_reportAllowsInterruptedContinuation',
  },
);

const _automaticRecoveryBeginGuardSpec = _CommandGuardSpec(
  mutationName: 'begin',
  mutationTarget: 'controller',
  operationName: 'automaticRecovery',
  requiredMutationArguments: <String, String>{
    'kind': 'OnboardingOperationKind.automaticRecovery',
    'initialStage': 'OnboardingOperationStage.automaticRecoveryReset',
  },
  rejectionKeys: <String>{
    '!call:_commandAndActionAreCurrent',
    '!report:admittedReport:_reportAllowsAutomaticRecovery',
  },
  allowedAssignments: <String, String>{'beginAttempted': 'true'},
);

const _automaticRecoveryResetGuardSpec = _CommandGuardSpec(
  mutationName: 'resetDerivedData',
  mutationTarget: 'ref.read(messageDataResetServiceProvider)',
  operationName: 'automaticRecovery',
  rejectionKeys: <String>{
    '!call:_commandOwnsBoundOperation',
    '!report:resetReport:_reportAllowsAutomaticRecovery',
  },
  rejectionReturnSource: 'false',
);

final class _CommandGuardSpec {
  const _CommandGuardSpec({
    required this.mutationName,
    required this.mutationTarget,
    required this.operationName,
    this.requiredMutationArguments = const <String, String>{},
    required this.rejectionKeys,
    this.rejectionReturnSource,
    this.allowedAssignments = const <String, String>{},
  });

  final String mutationName;
  final String mutationTarget;
  final String operationName;
  final Map<String, String> requiredMutationArguments;
  final Set<String> rejectionKeys;
  final String? rejectionReturnSource;
  final Map<String, String> allowedAssignments;
}

final class _CommandBindingOrigins {
  const _CommandBindingOrigins({
    required this.coordinator,
    required this.reportReader,
    required this.controllerType,
    required this.capabilityType,
    required this.resetServiceType,
    required this.controllerProvider,
    required this.resetServiceProvider,
    required this.refReadMethod,
  });

  final InterfaceElement2 coordinator;
  final Element2 reportReader;
  final InterfaceElement2 controllerType;
  final InterfaceElement2 capabilityType;
  final InterfaceElement2 resetServiceType;
  final Element2 controllerProvider;
  final Element2 resetServiceProvider;
  final Element2 refReadMethod;

  Element2 coordinatorMethod(String name) {
    return coordinator.getMethod2(name) ??
        (throw StateError('Missing coordinator method $name.'));
  }
}

_CommandBindingOrigins _virtualCommandBindingOrigins(CompilationUnit unit) {
  return _CommandBindingOrigins(
    coordinator: _classElement(unit, 'OnboardingJourneyCoordinator'),
    reportReader: _topLevelFunction(
      unit,
      'readAdmittedOnboardingEnvironmentEvidence',
    ).declaredFragment!.element,
    controllerType: _classElement(
      unit,
      'OnboardingOperationSnapshotController',
    ),
    capabilityType: _classElement(unit, 'ArchiveMutationCapability'),
    resetServiceType: _classElement(unit, 'MessageDataResetService'),
    controllerProvider: _topLevelVariableElement(
      unit,
      'onboardingOperationControllerProvider',
    ),
    resetServiceProvider: _topLevelVariableElement(
      unit,
      'messageDataResetServiceProvider',
    ),
    refReadMethod: _classElement(unit, 'Ref').getMethod2('read')!,
  );
}

List<String> _commandBindingViolations({
  required MethodDeclaration method,
  required _CommandGuardSpec spec,
  required _CommandBindingOrigins origins,
}) {
  final expectedMutation = spec.mutationName == 'resetDerivedData'
      ? origins.resetServiceType.getMethod2(spec.mutationName)
      : origins.controllerType.getMethod2(spec.mutationName);
  if (expectedMutation == null) {
    return <String>['The reviewed ${spec.mutationName} declaration is absent.'];
  }
  final roles = _commandValueRoles(
    method: method,
    spec: spec,
    origins: origins,
  );
  final mutations = _allMethodInvocations(method)
      .where(
        (invocation) =>
            _sameElement(invocation.methodName.element, expectedMutation) &&
            _matchesBoundCommandMutation(
              invocation,
              spec: spec,
              origins: origins,
              roles: roles,
            ),
      )
      .toList(growable: false);
  if (mutations.length != 1) {
    final finding = <String>[
      '${method.name.lexeme} must contain exactly one mutation bound to the ',
      'reviewed ${spec.mutationName} declaration; found ',
      '${mutations.length}.',
    ].join();
    return <String>[finding];
  }

  final mutation = mutations.single;
  final mutationStatement = _enclosingStatement(mutation);
  final block = mutationStatement?.parent;
  if (mutationStatement == null || block is! Block) {
    return <String>['${spec.mutationName} is not in a binding-audited block.'];
  }
  final mutationIndex = block.statements.indexOf(mutationStatement);
  final candidateGuards = block.statements
      .take(mutationIndex)
      .whereType<IfStatement>()
      .where(
        (statement) => _sameStringSet(
          _bindingRejectingConditionKeys(
            statement.expression,
            spec: spec,
            origins: origins,
            roles: roles,
          ),
          spec.rejectionKeys,
        ),
      )
      .toList(growable: false);
  if (candidateGuards.isEmpty) {
    final finding = <String>[
      'No declaration-authenticated rejecting guard dominates ',
      '${spec.mutationName} in ${method.name.lexeme}.',
    ].join();
    return <String>[finding];
  }

  final findings = <String>[];
  final guard = candidateGuards.last;
  final terminalReturn = _terminalReturn(guard.thenStatement);
  if (terminalReturn == null ||
      terminalReturn.expression?.toSource() != spec.rejectionReturnSource) {
    findings.add(
      'The declaration-authenticated guard has the wrong return shape.',
    );
  }
  final guardIndex = block.statements.indexOf(guard);
  if (guardIndex == 0 ||
      !_isBoundCapabilityProof(
        block.statements[guardIndex - 1],
        operationName: spec.operationName,
        origins: origins,
      )) {
    findings.add(
      'The guard is not immediately preceded by proof from the admitted '
      'ArchiveMutationCapability formal.',
    );
  }
  if (_allAwaitExpressions(method).any(
    (expression) =>
        expression.offset >= guard.end && expression.end <= mutation.offset,
  )) {
    findings.add('An await occurs after the authenticated complete guard.');
  }
  for (final statement in block.statements.sublist(
    guardIndex + 1,
    mutationIndex,
  )) {
    if (_isBindingSafeCommandAssignment(statement)) {
      continue;
    }
    findings.add(
      'Unexpected statement exists between the authenticated guard and '
      'mutation: ${statement.toSource()}',
    );
  }
  return findings;
}

Map<Element2, String> _commandValueRoles({
  required MethodDeclaration method,
  required _CommandGuardSpec spec,
  required _CommandBindingOrigins origins,
}) {
  final roles = <Element2, String>{};
  final claimMethod = origins.coordinatorMethod('_claimCommand');
  final bindingField = origins.coordinator.getField2('_operationBinding');
  final reportRole =
      spec.rejectionKeys.any((key) => key.contains('resetReport'))
      ? 'resetReport'
      : 'admittedReport';
  final declarations = _allVariableDeclarations(method);

  for (final declaration in declarations) {
    final element = declaration.declaredFragment?.element;
    final initializer = declaration.initializer;
    if (element == null || initializer == null) {
      continue;
    }
    final directInvocation = _directValueInvocation(initializer);
    if (directInvocation != null &&
        _sameElement(directInvocation.methodName.element, claimMethod)) {
      roles[element] = 'token';
      final arguments = directInvocation.argumentList.arguments;
      if (arguments.length == 1 && arguments.single is SimpleIdentifier) {
        final contextElement = (arguments.single as SimpleIdentifier).element;
        if (contextElement != null) {
          roles[contextElement] = 'context';
        }
      }
    }
    if (_isDirectProviderReadValue(
          initializer,
          origins: origins,
          provider: origins.controllerProvider,
          requireFutureMember: true,
        ) &&
        _sameElement(
          _interfaceElementOf(declaration.declaredFragment?.element),
          origins.controllerType,
        )) {
      roles[element] = 'controller';
    }
    if (directInvocation != null &&
        _sameElement(
          directInvocation.methodName.element,
          origins.reportReader,
        )) {
      roles[element] = reportRole;
    }
    if (initializer is SimpleIdentifier &&
        _sameElement(initializer.element, bindingField)) {
      roles[element] = 'binding';
    }
  }

  final beginMethod = origins.controllerType.getMethod2('begin');
  for (final declaration in declarations) {
    final element = declaration.declaredFragment?.element;
    final initializer = declaration.initializer;
    if (element == null || initializer == null || beginMethod == null) {
      continue;
    }
    final directInvocation = _directValueInvocation(initializer);
    if (directInvocation != null &&
        _sameElement(directInvocation.methodName.element, beginMethod) &&
        _bindingExpressionKey(directInvocation.target, roles) == 'controller') {
      roles[element] = 'operationId';
    }
  }
  return roles;
}

bool _matchesBoundCommandMutation(
  MethodInvocation invocation, {
  required _CommandGuardSpec spec,
  required _CommandBindingOrigins origins,
  required Map<Element2, String> roles,
}) {
  if (spec.mutationName == 'resetDerivedData') {
    final target = invocation.target;
    if (target is! MethodInvocation ||
        !_isProviderReadInvocation(
          target,
          origins: origins,
          provider: origins.resetServiceProvider,
          requireFutureMember: false,
        )) {
      return false;
    }
  } else if (_bindingExpressionKey(invocation.target, roles) != 'controller') {
    return false;
  }
  final namedArguments = invocation.argumentList.arguments
      .whereType<NamedExpression>()
      .toList(growable: false);
  if (namedArguments.length != spec.requiredMutationArguments.length) {
    return false;
  }
  for (final MapEntry(:key, :value) in spec.requiredMutationArguments.entries) {
    final argument = _namedArgumentOrNull(invocation, key)?.expression;
    if (_bindingExpressionKey(argument, roles) != value) {
      return false;
    }
  }
  return true;
}

Set<String>? _bindingRejectingConditionKeys(
  Expression expression, {
  required _CommandGuardSpec spec,
  required _CommandBindingOrigins origins,
  required Map<Element2, String> roles,
}) {
  final atoms = _flattenDisjunction(expression);
  final keys = <String>{};
  for (final atom in atoms) {
    final key = _bindingRejectionAtomKey(
      atom,
      spec: spec,
      origins: origins,
      roles: roles,
    );
    if (key == null || !keys.add(key)) {
      return null;
    }
  }
  return keys;
}

String? _bindingRejectionAtomKey(
  Expression expression, {
  required _CommandGuardSpec spec,
  required _CommandBindingOrigins origins,
  required Map<Element2, String> roles,
}) {
  final unwrapped = _unparenthesized(expression);
  if (unwrapped is PrefixExpression && unwrapped.operator.lexeme == '!') {
    final operand = _unparenthesized(unwrapped.operand);
    if (operand is! MethodInvocation) {
      return null;
    }
    final currentness = _boundCurrentnessCallKey(
      operand,
      origins: origins,
      roles: roles,
    );
    if (currentness != null) {
      return '!call:$currentness';
    }
    if (!_sameElement(
      operand.methodName.element,
      origins.coordinatorMethod('_reportAllowsCommand'),
    )) {
      return null;
    }
    final positional = operand.argumentList.arguments
        .where((argument) => argument is! NamedExpression)
        .toList(growable: false);
    if (positional.length != 1) {
      return null;
    }
    final reportRole = _bindingExpressionKey(positional.single, roles);
    if (reportRole != 'admittedReport' && reportRole != 'resetReport') {
      return null;
    }
    final predicate = _boundReportPredicateName(
      operand,
      origins: origins,
      roles: roles,
    );
    return predicate == null ? null : '!report:$reportRole:$predicate';
  }
  if (unwrapped is BinaryExpression && unwrapped.operator.lexeme == '!=') {
    return '!=:${_bindingExpressionKey(unwrapped.leftOperand, roles)}:'
        '${_bindingExpressionKey(unwrapped.rightOperand, roles)}';
  }
  return null;
}

String? _boundCurrentnessCallKey(
  MethodInvocation invocation, {
  required _CommandBindingOrigins origins,
  required Map<Element2, String> roles,
}) {
  final methodByName = <String, List<String>>{
    '_commandAndActionAreCurrent': <String>['token', 'context'],
    '_commandRetainsBinding': <String>['token', 'context', 'binding'],
    '_commandOwnsBoundOperation': <String>['token', 'operationId'],
  };
  for (final MapEntry(:key, :value) in methodByName.entries) {
    if (!_sameElement(
      invocation.methodName.element,
      origins.coordinatorMethod(key),
    )) {
      continue;
    }
    final actual = invocation.argumentList.arguments
        .map((argument) => _bindingExpressionKey(argument, roles))
        .toList(growable: false);
    if (actual.any((role) => role == null)) {
      return null;
    }
    return _sameStringList(actual.cast<String>(), value) ? key : null;
  }
  return null;
}

String? _boundReportPredicateName(
  MethodInvocation reportGuard, {
  required _CommandBindingOrigins origins,
  required Map<Element2, String> roles,
}) {
  final predicate = _namedArgumentOrNull(reportGuard, 'predicate')?.expression;
  for (final name in <String>[
    '_reportAllowsInitialImport',
    '_reportAllowsReimport',
    '_reportAllowsAutomaticRecovery',
  ]) {
    if (predicate is SimpleIdentifier &&
        _sameElement(predicate.element, origins.coordinatorMethod(name))) {
      return name;
    }
  }
  if (predicate is! FunctionExpression ||
      predicate.parameters?.parameters.length != 1) {
    return null;
  }
  final formal =
      predicate.parameters!.parameters.single.declaredFragment?.element;
  final body = predicate.body;
  if (formal == null ||
      body is! ExpressionFunctionBody ||
      body.expression is! MethodInvocation) {
    return null;
  }
  final invocation = body.expression as MethodInvocation;
  const continuationName = '_reportAllowsInterruptedContinuation';
  if (!_sameElement(
        invocation.methodName.element,
        origins.coordinatorMethod(continuationName),
      ) ||
      invocation.argumentList.arguments.length != 2) {
    return null;
  }
  final arguments = invocation.argumentList.arguments;
  final reportArgument = arguments.first;
  if (reportArgument is! SimpleIdentifier ||
      !_sameElement(reportArgument.element, formal) ||
      _bindingExpressionKey(arguments[1], roles) != 'controller.current') {
    return null;
  }
  return continuationName;
}

String? _bindingExpressionKey(
  Expression? expression,
  Map<Element2, String> roles,
) {
  if (expression == null) {
    return null;
  }
  final unwrapped = _unparenthesized(expression);
  final enumKey = _resolvedEnumConstantKey(unwrapped);
  if (enumKey != null) {
    return enumKey;
  }
  if (unwrapped is SimpleIdentifier) {
    final element = unwrapped.element;
    return element == null ? null : roles[element];
  }
  if (unwrapped is PrefixedIdentifier) {
    final prefix = _bindingExpressionKey(unwrapped.prefix, roles);
    return prefix == null ? null : '$prefix.${unwrapped.identifier.name}';
  }
  if (unwrapped is PropertyAccess) {
    final target = _bindingExpressionKey(unwrapped.realTarget, roles);
    return target == null ? null : '$target.${unwrapped.propertyName.name}';
  }
  return null;
}

MethodInvocation? _directValueInvocation(Expression expression) {
  var value = _unparenthesized(expression);
  if (value is AwaitExpression) {
    value = _unparenthesized(value.expression);
  }
  if (value is PostfixExpression && value.operator.lexeme == '!') {
    value = _unparenthesized(value.operand);
  }
  return value is MethodInvocation ? value : null;
}

bool _isDirectProviderReadValue(
  Expression expression, {
  required _CommandBindingOrigins origins,
  required Element2 provider,
  required bool requireFutureMember,
}) {
  final invocation = _directValueInvocation(expression);
  return invocation != null &&
      _isProviderReadInvocation(
        invocation,
        origins: origins,
        provider: provider,
        requireFutureMember: requireFutureMember,
      );
}

bool _isProviderReadInvocation(
  MethodInvocation invocation, {
  required _CommandBindingOrigins origins,
  required Element2 provider,
  required bool requireFutureMember,
}) {
  if (!_sameElement(invocation.methodName.element, origins.refReadMethod) ||
      invocation.argumentList.arguments.length != 1) {
    return false;
  }
  final argument = invocation.argumentList.arguments.single;
  if (!requireFutureMember) {
    return argument is SimpleIdentifier &&
        _sameElement(argument.element, provider);
  }
  if (argument is PrefixedIdentifier) {
    return _sameElement(argument.prefix.element, provider) &&
        argument.identifier.name == 'future';
  }
  if (argument is PropertyAccess) {
    final target = argument.realTarget;
    return target is SimpleIdentifier &&
        _sameElement(target.element, provider) &&
        argument.propertyName.name == 'future';
  }
  return false;
}

String? _resolvedEnumConstantKey(Expression expression) {
  final identifier = switch (expression) {
    PrefixedIdentifier(:final identifier) => identifier,
    PropertyAccess(:final propertyName) => propertyName,
    _ => null,
  };
  final referencedElement = identifier?.element;
  final element = referencedElement is PropertyAccessorElement2
      ? referencedElement.variable3
      : referencedElement;
  if (element is! FieldElement2 || !element.isEnumConstant) {
    return null;
  }
  return '${element.enclosingElement2.displayName}.${element.displayName}';
}

bool _isBoundCapabilityProof(
  Statement statement, {
  required String operationName,
  required _CommandBindingOrigins origins,
}) {
  if (statement is! ExpressionStatement ||
      statement.expression is! MethodInvocation) {
    return false;
  }
  final invocation = statement.expression as MethodInvocation;
  final expectedMethod = origins.capabilityType.getMethod2('requireOperation');
  final target = invocation.target;
  return expectedMethod != null &&
      _sameElement(invocation.methodName.element, expectedMethod) &&
      target is SimpleIdentifier &&
      target.element is FormalParameterElement &&
      _sameElement(
        _interfaceElementOf(target.element),
        origins.capabilityType,
      ) &&
      invocation.argumentList.arguments.length == 1 &&
      _resolvedEnumConstantKey(invocation.argumentList.arguments.single) ==
          'ArchiveMutationOperation.$operationName';
}

bool _isBindingSafeCommandAssignment(Statement statement) {
  if (statement is! ExpressionStatement ||
      statement.expression is! AssignmentExpression) {
    return false;
  }
  final assignment = statement.expression as AssignmentExpression;
  final target = assignment.leftHandSide;
  final targetElement = target is SimpleIdentifier ? target.element : null;
  return assignment.operator.lexeme == '=' &&
      target is SimpleIdentifier &&
      targetElement is LocalVariableElement2 &&
      targetElement.type.isDartCoreBool &&
      assignment.rightHandSide is BooleanLiteral &&
      (assignment.rightHandSide as BooleanLiteral).value &&
      _allAwaitExpressions(statement).isEmpty;
}

InterfaceElement2? _interfaceElementOf(Element2? element) {
  final type = element is VariableElement2 ? element.type : null;
  return type is InterfaceType ? type.element3 : null;
}

bool _sameElement(Element2? left, Element2? right) {
  return left != null &&
      right != null &&
      identical(left.nonSynthetic2, right.nonSynthetic2);
}

List<VariableDeclaration> _allVariableDeclarations(AstNode node) {
  final visitor = _AllVariableDeclarationVisitor();
  node.accept(visitor);
  return visitor.declarations;
}

const _commandBindingFixtureSource = '''
enum ArchiveMutationOperation { onboardingImport, automaticRecovery }
enum OnboardingOperationKind { initialImport, reimport, automaticRecovery }
enum OnboardingOperationStage {
  messageDataBuild,
  environmentPreparation,
  automaticRecoveryReset,
}

class Provider<T> {
  const Provider();

  Provider<Future<T>> get future => const Provider<Future<T>>();
}

final onboardingOperationControllerProvider =
    Provider<OnboardingOperationSnapshotController>();
final messageDataResetServiceProvider = Provider<MessageDataResetService>();

class Ref {
  T read<T>(Provider<T> provider) => throw UnimplementedError();
}

class Context {}
class Report {}

Future<Report> readAdmittedOnboardingEnvironmentEvidence() async => Report();

class ArchiveMutationCapability {
  void requireOperation(ArchiveMutationOperation operation) {}
}

class OnboardingOperationSnapshotController {
  OnboardingOperationSnapshotController();

  Future<int> begin({
    required OnboardingOperationKind kind,
    required OnboardingOperationStage initialStage,
  }) async => 1;

  Future<void> resume({required int operationId}) async {}
}

class LookalikeController {
  Future<int> begin({
    required OnboardingOperationKind kind,
    required OnboardingOperationStage initialStage,
  }) async => 1;
}

abstract interface class MessageDataResetService {
  Future<void> resetDerivedData();
}

class FakeResetAccessor {
  MessageDataResetService read(Provider<MessageDataResetService> provider) =>
      throw UnimplementedError();
}

class OnboardingJourneyCoordinator {
  Object? _operationBinding;
  final Ref ref = Ref();
  final FakeResetAccessor fakeResetAccessor = FakeResetAccessor();

  int? _claimCommand(Context context) => 1;
  bool _commandAndActionAreCurrent(int token, Context context) => true;
  bool _commandRetainsBinding(int token, Context context, Object binding) =>
      true;
  bool _commandOwnsBoundOperation(int token, int operationId) => true;
  bool _reportAllowsCommand(
    Report report, {
    required bool Function(Report) predicate,
  }) => predicate(report);
  bool _reportAllowsInitialImport(Report report) => true;
  bool _reportAllowsReimport(Report report) => true;
  bool _reportAllowsAutomaticRecovery(Report report) => true;
  bool _reportAllowsInterruptedContinuation(
    Report report,
    Object snapshot,
  ) => true;

  Future<void> renamedPositive(
    Context renamedContext,
    ArchiveMutationCapability admittedProof,
  ) async {
    final renamedToken = _claimCommand(renamedContext)!;
    final renamedController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final renamedReport =
        await readAdmittedOnboardingEnvironmentEvidence();
    admittedProof.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(renamedToken, renamedContext) ||
        !_reportAllowsCommand(
          renamedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    await renamedController.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
  }

  Future<void> shadowedCurrentnessHelper(
    Context renamedContext,
    ArchiveMutationCapability admittedProof,
  ) async {
    final renamedToken = _claimCommand(renamedContext)!;
    final renamedController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final renamedReport =
        await readAdmittedOnboardingEnvironmentEvidence();
    bool _commandAndActionAreCurrent(int token, Context context) => true;
    admittedProof.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(renamedToken, renamedContext) ||
        !_reportAllowsCommand(
          renamedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    await renamedController.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
  }

  Future<void> shadowedPredicate(
    Context renamedContext,
    ArchiveMutationCapability admittedProof,
  ) async {
    final renamedToken = _claimCommand(renamedContext)!;
    final renamedController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final renamedReport =
        await readAdmittedOnboardingEnvironmentEvidence();
    bool _reportAllowsInitialImport(Report report) => true;
    admittedProof.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(renamedToken, renamedContext) ||
        !_reportAllowsCommand(
          renamedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    await renamedController.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
  }

  Future<void> shadowedReportHelper(
    Context renamedContext,
    ArchiveMutationCapability admittedProof,
  ) async {
    final renamedToken = _claimCommand(renamedContext)!;
    final renamedController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final renamedReport =
        await readAdmittedOnboardingEnvironmentEvidence();
    bool _reportAllowsCommand(
      Report report, {
      required bool Function(Report) predicate,
    }) => true;
    admittedProof.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(renamedToken, renamedContext) ||
        !_reportAllowsCommand(
          renamedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    await renamedController.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
  }

  Future<void> wrongClaimedValue(
    Context renamedContext,
    ArchiveMutationCapability admittedProof,
  ) async {
    final renamedToken = _claimCommand(renamedContext)!;
    final unrelatedToken = renamedToken + 1;
    final renamedController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final renamedReport =
        await readAdmittedOnboardingEnvironmentEvidence();
    admittedProof.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(unrelatedToken, renamedContext) ||
        !_reportAllowsCommand(
          renamedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    await renamedController.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
  }

  Future<void> lookalikeMutation(
    Context renamedContext,
    ArchiveMutationCapability admittedProof,
  ) async {
    final renamedToken = _claimCommand(renamedContext)!;
    final renamedController = LookalikeController();
    final renamedReport =
        await readAdmittedOnboardingEnvironmentEvidence();
    admittedProof.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(renamedToken, renamedContext) ||
        !_reportAllowsCommand(
          renamedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    await renamedController.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
  }

  Future<void> sameSpelledUnrelatedToken(
    Context renamedContext,
    ArchiveMutationCapability admittedProof,
  ) async {
    final token = _claimCommand(renamedContext)!;
    final renamedController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final renamedReport =
        await readAdmittedOnboardingEnvironmentEvidence();
    {
      final token = token + 1;
      admittedProof.requireOperation(ArchiveMutationOperation.onboardingImport);
      if (!_commandAndActionAreCurrent(token, renamedContext) ||
          !_reportAllowsCommand(
            renamedReport,
            predicate: _reportAllowsInitialImport,
          )) {
        return;
      }
      await renamedController.begin(
        kind: OnboardingOperationKind.initialImport,
        initialStage: OnboardingOperationStage.messageDataBuild,
      );
    }
  }

  Future<void> conditionalControllerProvenance(
    Context renamedContext,
    ArchiveMutationCapability admittedProof,
  ) async {
    final renamedToken = _claimCommand(renamedContext)!;
    final unrelatedController = OnboardingOperationSnapshotController();
    final renamedController = true
        ? await ref.read(onboardingOperationControllerProvider.future)
        : unrelatedController;
    final renamedReport =
        await readAdmittedOnboardingEnvironmentEvidence();
    admittedProof.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(renamedToken, renamedContext) ||
        !_reportAllowsCommand(
          renamedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    await renamedController.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
  }

  Future<void> discardedControllerRead(
    Context renamedContext,
    ArchiveMutationCapability admittedProof,
  ) async {
    final renamedToken = _claimCommand(renamedContext)!;
    final unrelatedController = OnboardingOperationSnapshotController();
    final renamedController = await (() async {
      await ref.read(onboardingOperationControllerProvider.future);
      return unrelatedController;
    })();
    final renamedReport =
        await readAdmittedOnboardingEnvironmentEvidence();
    admittedProof.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(renamedToken, renamedContext) ||
        !_reportAllowsCommand(
          renamedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    await renamedController.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
  }

  Future<void> conditionalReportProvenance(
    Context renamedContext,
    ArchiveMutationCapability admittedProof,
  ) async {
    final renamedToken = _claimCommand(renamedContext)!;
    final renamedController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final renamedReport = true
        ? await readAdmittedOnboardingEnvironmentEvidence()
        : Report();
    admittedProof.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(renamedToken, renamedContext) ||
        !_reportAllowsCommand(
          renamedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    await renamedController.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
  }

  Future<void> discardedReportRead(
    Context renamedContext,
    ArchiveMutationCapability admittedProof,
  ) async {
    final renamedToken = _claimCommand(renamedContext)!;
    final renamedController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final renamedReport = await (() async {
      await readAdmittedOnboardingEnvironmentEvidence();
      return Report();
    })();
    admittedProof.requireOperation(ArchiveMutationOperation.onboardingImport);
    if (!_commandAndActionAreCurrent(renamedToken, renamedContext) ||
        !_reportAllowsCommand(
          renamedReport,
          predicate: _reportAllowsInitialImport,
        )) {
      return;
    }
    await renamedController.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.messageDataBuild,
    );
  }

  Future<bool> fakeResetAccessor(
    Context renamedContext,
    ArchiveMutationCapability admittedProof,
  ) async {
    final renamedToken = _claimCommand(renamedContext)!;
    final renamedController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final operationId = await renamedController.begin(
      kind: OnboardingOperationKind.automaticRecovery,
      initialStage: OnboardingOperationStage.environmentPreparation,
    );
    final resetReport =
        await readAdmittedOnboardingEnvironmentEvidence();
    admittedProof.requireOperation(ArchiveMutationOperation.automaticRecovery);
    if (!_commandOwnsBoundOperation(renamedToken, operationId) ||
        !_reportAllowsCommand(
          resetReport,
          predicate: _reportAllowsAutomaticRecovery,
        )) {
      return false;
    }
    await fakeResetAccessor
        .read(messageDataResetServiceProvider)
        .resetDerivedData();
    return true;
  }
}
''';

IfElement? _ancestorIfElement(AstNode node) {
  var current = node.parent;
  while (current != null && current is! IfElement) {
    current = current.parent;
  }
  return current as IfElement?;
}

void _expectDominatingCommandGuard({
  required MethodDeclaration method,
  required _CommandGuardSpec spec,
}) {
  expect(
    _commandGuardViolations(method: method, spec: spec),
    isEmpty,
    reason:
        '${method.name.lexeme} must have one complete rejecting guard that '
        'dominates ${spec.mutationName} without an intervening await.',
  );
}

List<String> _commandGuardViolations({
  required MethodDeclaration method,
  required _CommandGuardSpec spec,
}) {
  final findings = <String>[];
  final mutations = _invocationsNamed(method, spec.mutationName)
      .where((invocation) => _matchesCommandMutation(invocation, spec))
      .toList(growable: false);
  if (mutations.length != 1) {
    return <String>[
      '${method.name.lexeme} must contain exactly one audited ${spec.mutationName} mutation; found ${mutations.length}.',
    ];
  }
  final mutation = mutations.single;
  final mutationStatement = _enclosingStatement(mutation);
  final block = mutationStatement?.parent;
  if (mutationStatement == null || block is! Block) {
    return <String>[
      '${spec.mutationName} is not in a structurally audited block.',
    ];
  }
  final mutationIndex = block.statements.indexOf(mutationStatement);
  final priorStatements = block.statements.take(mutationIndex).toList();
  final candidateGuards = priorStatements
      .whereType<IfStatement>()
      .where(
        (statement) => _sameStringSet(
          _rejectingConditionKeys(statement.expression),
          spec.rejectionKeys,
        ),
      )
      .toList(growable: false);
  if (candidateGuards.isEmpty) {
    return <String>[
      'No exact rejecting guard dominates ${spec.mutationName} in ${method.name.lexeme}.',
    ];
  }
  final guard = candidateGuards.last;
  final terminalReturn = _terminalReturn(guard.thenStatement);
  if (terminalReturn == null ||
      terminalReturn.expression?.toSource() != spec.rejectionReturnSource) {
    findings.add(
      'The complete guard does not reject with the required return shape.',
    );
  }
  final guardIndex = block.statements.indexOf(guard);
  if (guardIndex == 0) {
    findings.add('The complete guard lacks an exact capability proof.');
  } else {
    final capabilityStatement = block.statements[guardIndex - 1];
    if (!_isExactCapabilityProof(capabilityStatement, spec.operationName)) {
      findings.add(
        'The complete guard is not immediately preceded by the exact '
        '${spec.operationName} capability proof.',
      );
    }
  }
  final interveningAwaits = _allAwaitExpressions(method).where(
    (expression) =>
        expression.offset >= guard.end && expression.end <= mutation.offset,
  );
  if (interveningAwaits.isNotEmpty) {
    findings.add('An await occurs after the complete guard.');
  }
  for (final statement in block.statements.sublist(
    guardIndex + 1,
    mutationIndex,
  )) {
    if (_isAllowedCommandAssignment(statement, spec)) {
      continue;
    }
    findings.add(
      'Unexpected statement exists between the complete guard and mutation: '
      '${statement.toSource()}',
    );
  }
  return findings;
}

bool _matchesCommandMutation(
  MethodInvocation invocation,
  _CommandGuardSpec spec,
) {
  if (invocation.target?.toSource() != spec.mutationTarget) {
    return false;
  }
  final namedArguments = invocation.argumentList.arguments
      .whereType<NamedExpression>()
      .toList(growable: false);
  if (namedArguments.length != spec.requiredMutationArguments.length) {
    return false;
  }
  for (final MapEntry(:key, :value) in spec.requiredMutationArguments.entries) {
    if (_namedArgumentOrNull(invocation, key)?.expression.toSource() != value) {
      return false;
    }
  }
  return true;
}

Set<String>? _rejectingConditionKeys(Expression expression) {
  final atoms = _flattenDisjunction(expression);
  final keys = <String>{};
  for (final atom in atoms) {
    final key = _rejectionAtomKey(atom);
    if (key == null || !keys.add(key)) {
      return null;
    }
  }
  return keys;
}

bool _sameStringSet(Set<String>? left, Set<String> right) {
  return left != null && left.length == right.length && left.containsAll(right);
}

List<Expression> _flattenDisjunction(Expression expression) {
  final unwrapped = _unparenthesized(expression);
  if (unwrapped is BinaryExpression && unwrapped.operator.lexeme == '||') {
    return <Expression>[
      ..._flattenDisjunction(unwrapped.leftOperand),
      ..._flattenDisjunction(unwrapped.rightOperand),
    ];
  }
  return <Expression>[unwrapped];
}

String? _rejectionAtomKey(Expression expression) {
  final unwrapped = _unparenthesized(expression);
  if (unwrapped is PrefixExpression && unwrapped.operator.lexeme == '!') {
    final operand = _unparenthesized(unwrapped.operand);
    if (operand is! MethodInvocation) {
      return null;
    }
    final callKey = _commandCurrentnessCallKey(operand);
    if (callKey != null) {
      return '!call:$callKey';
    }
    if (operand.methodName.name != '_reportAllowsCommand') {
      return null;
    }
    final positional = operand.argumentList.arguments
        .where((argument) => argument is! NamedExpression)
        .toList(growable: false);
    if (positional.length != 1) {
      return null;
    }
    final predicate = _reportPredicateName(operand);
    return predicate == null
        ? null
        : '!report:${positional.single.toSource()}:$predicate';
  }
  if (unwrapped is BinaryExpression && unwrapped.operator.lexeme == '!=') {
    return '!=:${unwrapped.leftOperand.toSource()}:'
        '${unwrapped.rightOperand.toSource()}';
  }
  return null;
}

String? _commandCurrentnessCallKey(MethodInvocation invocation) {
  if (invocation.target != null) {
    return null;
  }
  final arguments = invocation.argumentList.arguments
      .map((argument) => argument.toSource())
      .toList(growable: false);
  final expectedArguments = switch (invocation.methodName.name) {
    '_commandAndActionAreCurrent' => const <String>['token', 'context'],
    '_commandRetainsBinding' => const <String>[
      'token',
      'actionContext',
      'binding',
    ],
    '_commandOwnsBoundOperation' => const <String>['token', 'operationId'],
    _ => null,
  };
  return expectedArguments != null &&
          _sameStringList(arguments, expectedArguments)
      ? invocation.methodName.name
      : null;
}

String? _reportPredicateName(MethodInvocation reportGuard) {
  if (reportGuard.target != null) {
    return null;
  }
  final predicate = _namedArgumentOrNull(reportGuard, 'predicate')?.expression;
  if (predicate is SimpleIdentifier) {
    return switch (predicate.name) {
      '_reportAllowsInitialImport' ||
      '_reportAllowsReimport' ||
      '_reportAllowsAutomaticRecovery' => predicate.name,
      _ => null,
    };
  }
  if (predicate is! FunctionExpression ||
      predicate.parameters?.parameters.length != 1 ||
      predicate.parameters?.parameters.single.name?.lexeme != 'report') {
    return null;
  }
  final body = predicate.body;
  if (body is! ExpressionFunctionBody || body.expression is! MethodInvocation) {
    return null;
  }
  final invocation = body.expression as MethodInvocation;
  if (invocation.target != null) {
    return null;
  }
  final arguments = invocation.argumentList.arguments
      .map((argument) => argument.toSource())
      .toList(growable: false);
  if (invocation.methodName.name != '_reportAllowsInterruptedContinuation' ||
      !_sameStringList(arguments, const <String>[
        'report',
        'controller.current',
      ])) {
    return null;
  }
  return invocation.methodName.name;
}

bool _sameStringList(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

Expression _unparenthesized(Expression expression) {
  var current = expression;
  while (current is ParenthesizedExpression) {
    current = current.expression;
  }
  return current;
}

bool _isExactCapabilityProof(Statement statement, String operationName) {
  if (statement is! ExpressionStatement ||
      statement.expression is! MethodInvocation) {
    return false;
  }
  final invocation = statement.expression as MethodInvocation;
  return invocation.methodName.name == 'requireOperation' &&
      invocation.target?.toSource() == 'capability' &&
      invocation.argumentList.arguments.length == 1 &&
      invocation.argumentList.arguments.single.toSource() ==
          'ArchiveMutationOperation.$operationName';
}

bool _isAllowedCommandAssignment(Statement statement, _CommandGuardSpec spec) {
  if (statement is! ExpressionStatement ||
      statement.expression is! AssignmentExpression) {
    return false;
  }
  final assignment = statement.expression as AssignmentExpression;
  return assignment.operator.lexeme == '=' &&
      spec.allowedAssignments[assignment.leftHandSide.toSource()] ==
          assignment.rightHandSide.toSource() &&
      _allAwaitExpressions(statement).isEmpty;
}

ReturnStatement? _terminalReturn(Statement statement) {
  if (statement is ReturnStatement) {
    return statement;
  }
  if (statement is Block && statement.statements.isNotEmpty) {
    final terminal = statement.statements.last;
    return terminal is ReturnStatement ? terminal : null;
  }
  return null;
}

MethodDeclaration _parseVirtualCommand(String body) {
  final unit = parseString(
    content:
        '''
class VirtualCommand {
  Future<void> run() async {
$body
  }
}
''',
  ).unit;
  return _classMethod(unit, 'VirtualCommand', 'run');
}

List<String> _virtualInitialImportCommandViolations(String body) {
  return _commandGuardViolations(
    method: _parseVirtualCommand(body),
    spec: _initialImportGuardSpec,
  );
}

Statement? _enclosingStatement(AstNode node) {
  AstNode? current = node;
  while (current != null && current is! Statement) {
    current = current.parent;
  }
  return current as Statement?;
}

final class _InvocationVisitor extends RecursiveAstVisitor<void> {
  _InvocationVisitor(this.name);

  final String name;
  final List<MethodInvocation> invocations = <MethodInvocation>[];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == name) {
      invocations.add(node);
    }
    super.visitMethodInvocation(node);
  }
}

final class _AllInvocationVisitor extends RecursiveAstVisitor<void> {
  final List<MethodInvocation> invocations = <MethodInvocation>[];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    invocations.add(node);
    super.visitMethodInvocation(node);
  }
}

final class _AwaitVisitor extends RecursiveAstVisitor<void> {
  final List<AwaitExpression> expressions = <AwaitExpression>[];

  @override
  void visitAwaitExpression(AwaitExpression node) {
    expressions.add(node);
    super.visitAwaitExpression(node);
  }
}

final class _IdentifierVisitor extends RecursiveAstVisitor<void> {
  final Set<String> names = <String>{};

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    names.add(node.name);
    super.visitSimpleIdentifier(node);
  }
}

final class _VariableDeclarationVisitor extends RecursiveAstVisitor<void> {
  _VariableDeclarationVisitor(this.name);

  final String name;
  final List<VariableDeclaration> declarations = <VariableDeclaration>[];

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (node.name.lexeme == name) {
      declarations.add(node);
    }
    super.visitVariableDeclaration(node);
  }
}

final class _AllVariableDeclarationVisitor extends RecursiveAstVisitor<void> {
  final List<VariableDeclaration> declarations = <VariableDeclaration>[];

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    declarations.add(node);
    super.visitVariableDeclaration(node);
  }
}

final class _NamedTypeVisitor extends RecursiveAstVisitor<void> {
  _NamedTypeVisitor(this.name);

  final String name;
  final List<NamedType> types = <NamedType>[];

  @override
  void visitNamedType(NamedType node) {
    if (node.name2.lexeme == name) {
      types.add(node);
    }
    super.visitNamedType(node);
  }
}

final class _IdentifierElementVisitor extends RecursiveAstVisitor<void> {
  _IdentifierElementVisitor(this.name);

  final String name;
  final List<SimpleIdentifier> identifiers = <SimpleIdentifier>[];

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == name) {
      identifiers.add(node);
    }
    super.visitSimpleIdentifier(node);
  }
}

final class _InstanceCreationVisitor extends RecursiveAstVisitor<void> {
  final List<InstanceCreationExpression> creations =
      <InstanceCreationExpression>[];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    creations.add(node);
    super.visitInstanceCreationExpression(node);
  }
}

String _classDeclaration(String source, String className) {
  final start = source.indexOf('final class $className');
  expect(start, isNonNegative, reason: 'Missing $className declaration.');
  final nextClass = source.indexOf('\nfinal class ', start + 1);
  return source.substring(start, nextClass < 0 ? source.length : nextClass);
}

String _methodBody(String source, String startNeedle, String endNeedle) {
  final start = source.indexOf(startNeedle);
  final end = source.indexOf(endNeedle, start);
  expect(start, isNonNegative, reason: 'Missing $startNeedle.');
  expect(end, greaterThan(start), reason: 'Missing $endNeedle.');
  return source.substring(start, end);
}

List<File> _dartFilesUnder(String path) {
  return Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList(growable: false);
}

Set<String> _productionOnboardingSemanticConsumerPaths({
  Iterable<String>? paths,
  required String Function(String path) sourceReader,
}) {
  final candidates =
      paths ??
      _dartFilesUnder('lib')
          .where((file) => !file.path.endsWith('.g.dart'))
          .map((file) => file.path);
  return candidates
      .where((path) => _sourceConsumesJourneySemantics(sourceReader(path)))
      .toSet();
}

bool _sourceConsumesJourneySemantics(String source) {
  final code = _sourceWithoutCommentsAndStrings(source);
  return RegExp(
    r'\b(?:OnboardingStatus|OnboardingJourney\w*|'
    r'onboardingJourneyCoordinatorProvider|'
    r'onboardingGateProvider|EnvironmentReadinessSurface\w*)\b',
  ).hasMatch(code);
}

String _sourceWithoutCommentsAndStrings(String source) {
  return source
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), ' ')
      .replaceAll(RegExp(r'//[^\n]*'), ' ')
      .replaceAll(RegExp(r"'''[\s\S]*?'''"), "''")
      .replaceAll(RegExp(r'"""[\s\S]*?"""'), '""')
      .replaceAll(RegExp(r"'(?:\\.|[^'\\])*'"), "''")
      .replaceAll(RegExp(r'"(?:\\.|[^"\\])*"'), '""');
}

_DependencyTraversal _transitiveLocalDependencies(
  String root, {
  required Set<String> stopAt,
  bool Function(String path)? stopWhen,
  Set<String> Function(String path) dependencyReader = _localDependencies,
}) {
  final dependencies = <String>{root};
  final parent = <String, String?>{root: null};
  final pending = <String>[root];
  while (pending.isNotEmpty) {
    final current = pending.removeLast();
    if (current != root &&
        (stopAt.contains(current) || (stopWhen?.call(current) ?? false))) {
      continue;
    }
    for (final dependency in dependencyReader(current)) {
      if (dependencies.add(dependency)) {
        parent[dependency] = current;
        if (_isTraversableLocalProductionDependency(dependency)) {
          pending.add(dependency);
        }
      }
    }
  }
  return _DependencyTraversal(
    root: root,
    dependencies: dependencies,
    parent: parent,
  );
}

bool _isTraversableLocalProductionDependency(String path) {
  return path.startsWith('lib/') && !path.endsWith('.g.dart');
}

bool _isTransitivelySafeIntentAdapter(
  String path, {
  required Set<String> evidenceImplementationPaths,
  required Set<String> trustedBoundaries,
  required Set<String> Function(String path) dependencyReader,
  required String Function(String path) sourceReader,
}) {
  final source = sourceReader(path);
  if (!source.contains('FutureOr<void> build()') ||
      source.contains('ref.watch') ||
      RegExp(r'\bstate\s*=').hasMatch(source)) {
    return false;
  }
  final traversal = _transitiveLocalDependencies(
    path,
    stopAt: trustedBoundaries,
    dependencyReader: dependencyReader,
  );
  for (final evidencePath in evidenceImplementationPaths) {
    if (!traversal.dependencies.contains(evidencePath)) {
      continue;
    }
    final importer = traversal.parent[evidencePath];
    if (evidencePath ==
            'lib/essentials/onboarding/application/'
                'onboarding_environment_report_provider.dart' &&
        importer != null &&
        _importsOnlyDevOverrides(sourceReader(importer))) {
      continue;
    }
    return false;
  }
  return _unlawfulOnboardingBarrelImports(
        traversal.dependencies,
        sourceReader: sourceReader,
      ).isEmpty &&
      _unlawfulLoggingBarrelImports(
        traversal.dependencies,
        sourceReader: sourceReader,
      ).isEmpty;
}

bool _importsOnlyDevOverrides(String source) {
  final directive = RegExp(
    r'''(?:^|\s)show\s+onboardingDevOverridesProvider(?:\s|$)''',
  );
  return directive.hasMatch(source) &&
      !source.contains('onboardingEnvironmentReportProvider');
}

Set<String> _localImportersOf(String importedPath) {
  return _dartFilesUnder('lib')
      .where((file) => _localDependencies(file.path).contains(importedPath))
      .map((file) => file.path)
      .toSet();
}

String _readSource(String path) => File(path).readAsStringSync();

Set<String> _localDependencies(String path) {
  final source = File(path).readAsStringSync();
  final dependencies = <String>{};
  final directivePattern = RegExp(
    r'''(?:import|export)\s+['"]([^'"]+)['"]([\s\S]*?);''',
  );
  for (final match in directivePattern.allMatches(source)) {
    final uri = match.group(1)!;
    final resolved = _resolveLocalDartUri(path, uri);
    if (resolved ==
            'lib/essentials/onboarding/application/'
                'onboarding_environment_report_provider.dart' &&
        _importsOnlyDevOverrides(match.group(2)!)) {
      continue;
    }
    if (resolved != null && File(resolved).existsSync()) {
      dependencies.add(resolved);
    }
  }
  return dependencies;
}

String? _resolveLocalDartUri(String sourcePath, String uri) {
  const packagePrefix = 'package:remember_this_text/';
  if (uri.startsWith(packagePrefix)) {
    return 'lib/${uri.substring(packagePrefix.length)}';
  }
  if (uri.startsWith('dart:') || uri.startsWith('package:')) {
    return null;
  }
  final sourceDirectory = File(sourcePath).absolute.parent.uri;
  final absolutePath = sourceDirectory.resolve(uri).toFilePath();
  final workspacePrefix = '${Directory.current.absolute.path}/';
  if (!absolutePath.startsWith(workspacePrefix)) {
    return null;
  }
  return absolutePath.substring(workspacePrefix.length);
}

List<String> _unlawfulOnboardingBarrelImports(
  Iterable<String> paths, {
  String Function(String path) sourceReader = _readSource,
}) {
  return _unlawfulBarrelImports(
    paths,
    barrelPath: 'lib/essentials/onboarding/feature_level_providers.dart',
    allowedSymbols: const <String>{
      'onboardingJourneyCoordinatorProvider',
      'onboardingGateProvider',
      'onboardingReadinessActionsProvider',
      'onboardingDevOverridesProvider',
    },
    sourceReader: sourceReader,
  );
}

List<String> _unlawfulLoggingBarrelImports(
  Iterable<String> paths, {
  String Function(String path) sourceReader = _readSource,
}) {
  return _unlawfulBarrelImports(
    paths,
    barrelPath: 'lib/essentials/logging/feature_level_providers.dart',
    allowedSymbols: const <String>{
      'activeBlockingPipelineIncidentProvider',
      'appLoggerProvider',
      'diagnosticReportExporterProvider',
      'pipelineIncidentTrackerProvider',
    },
    sourceReader: sourceReader,
  );
}

List<String> _unlawfulBarrelImports(
  Iterable<String> paths, {
  required String barrelPath,
  required Set<String> allowedSymbols,
  required String Function(String path) sourceReader,
}) {
  final findings = <String>[];
  final directivePattern = RegExp(r'''import\s+['"]([^'"]+)['"]([\s\S]*?);''');
  final shownSymbolPattern = RegExp(r'\b([A-Za-z_]\w*)\b');
  for (final path in paths) {
    final source = sourceReader(path);
    for (final match in directivePattern.allMatches(source)) {
      final uri = match.group(1)!;
      if (_resolveLocalDartUri(path, uri) != barrelPath) {
        continue;
      }
      final combinators = match.group(2)!;
      final showIndex = combinators.indexOf('show');
      if (showIndex < 0) {
        findings.add('$path imports the complete Onboarding provider barrel');
        continue;
      }
      final shownText = combinators.substring(showIndex + 'show'.length);
      final shownSymbols = shownSymbolPattern
          .allMatches(shownText)
          .map((match) => match.group(1)!)
          .toSet();
      final unlawful = shownSymbols.difference(allowedSymbols);
      if (unlawful.isNotEmpty) {
        findings.add('$path imports non-Journey symbols: $unlawful');
      }
    }
  }
  return findings;
}

final class _DependencyTraversal {
  const _DependencyTraversal({
    required this.root,
    required this.dependencies,
    required this.parent,
  });

  final String root;
  final Set<String> dependencies;
  final Map<String, String?> parent;

  String chainTo(String destination) {
    final chain = <String>[destination];
    var current = destination;
    while (current != root) {
      final previous = parent[current];
      if (previous == null) {
        break;
      }
      chain.add(previous);
      current = previous;
    }
    return chain.reversed.join(' -> ');
  }
}
