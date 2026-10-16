import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_development_composition_policy.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_production_composition_eligibility_policy.dart';
import 'package:remember_this_text/essentials/app_czar/application/production_app_czar_activation.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_session_controller.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/presentation/app_czar_operating_currentness_status.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_action.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_action_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/start_fresh_service_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_action_dispatcher.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/resolver_tools/settings_reset_message_data_action_availability_provider.dart';
import 'package:remember_this_text/main.dart';

// Only repository source is read. No synthetic path is opened. No widget tree,
// assessment/controller, real action, service or mutation coordinator is mounted.
void main() {
  test('executable: eligible synthetic production remains legacy', () {
    final authority = _authority(development: false);
    final eligible = const AppCzarProductionCompositionEligibilityPolicy()
        .isEligible(authority);
    expect(eligible, isTrue);
    expect(ProductionAppCzarActivation.disabled.isEnabled, isFalse);
    expect(
      selectMessageLensStartupPresentation(
        appCzarDevelopmentCompositionEnabled:
            const AppCzarDevelopmentCompositionPolicy().admits(authority),
        appCzarProductionCompositionEligible: eligible,
        productionAppCzarActivation: ProductionAppCzarActivation.disabled,
      ),
      MessageLensStartupPresentation.legacyStartup,
    );
  });

  test('executable: synthetic admitted development selects harness', () {
    final authority = _authority(development: true);
    expect(
      selectMessageLensStartupPresentation(
        appCzarDevelopmentCompositionEnabled:
            const AppCzarDevelopmentCompositionPolicy().admits(authority),
        appCzarProductionCompositionEligible:
            const AppCzarProductionCompositionEligibilityPolicy().isEligible(
              authority,
            ),
        productionAppCzarActivation: ProductionAppCzarActivation.disabled,
      ),
      MessageLensStartupPresentation.appCzarHarness,
    );
  });

  test('executable pure admission: current facts need no reset proof', () {
    final state = _currentAssessment();
    expect(shouldExecuteAppCzarOperatingSession(state), isTrue);
    expect(
      shouldExecuteAppCzarOperatingSession(AppCzarAssessmentState.initial(1)),
      isFalse,
    );
    expect(AppCzarVirtualCoordinator.values, hasLength(7));
  });

  test(
    'executable declaration only: neutral workspace has no legacy overlays',
    () {
      final workspace = buildAppCzarOperatingSessionWorkspace();
      expect(workspace.key, AppCzarOperatingSessionApp.workspaceKey);
      expect(workspace.fullWindowOverlays, isEmpty);
      expect(workspace.sidebarVisibilityOwnerBuilder, isNull);
      expect(workspace.showConversationGraphStatusAction, isFalse);
      expect(workspace.centerOverlayObservers, hasLength(1));
      expect(
        workspace.centerOverlayObservers.single,
        isA<AppCzarOperatingCurrentnessStatusHost>(),
      );
      // This does not mount the shell or claim transitive runtime nonconstruction.
    },
  );

  for (final visible in [false, true]) {
    test(
      'MISSING SAFEGUARD: reset dispatch reaches inert action; visible=$visible',
      () async {
        var actionConstructions = 0;
        var forbiddenServiceConstructions = 0;
        final spy = _InertAction();
        final container = ProviderContainer(
          overrides: [
            settingsResetMessageDataActionAvailableProvider.overrideWith(
              (ref) => visible,
            ),
            advancedStartFreshActionProvider.overrideWith((ref) {
              actionConstructions += 1;
              return spy;
            }),
            startFreshServiceProvider.overrideWith((ref) {
              forbiddenServiceConstructions += 1;
              throw StateError('Real service must never be resolved');
            }),
          ],
        );
        addTearDown(container.dispose);
        expect(
          container.read(settingsResetMessageDataActionAvailableProvider),
          visible,
        );
        final dispatcher = container.read(
          sidebarActionDispatcherProvider.notifier,
        );
        expect(actionConstructions, 0);
        expect(spy.requests, 0);
        for (var request = 1; request <= 2; request++) {
          await dispatcher.dispatch(
            intent: const ResetMessageDataRequested(),
            context: const SidebarActionDispatchContext(
              sidebarMode: SidebarMode.settings,
            ),
          );
          expect(actionConstructions, 1);
          expect(spy.requests, request);
          expect(forbiddenServiceConstructions, 0);
        }
        expect(container.exists(startFreshServiceProvider), isFalse);
        expect(spy.retries, 0);
        expect(spy.dismissals, 0);
      },
    );
  }

  test('SOURCE ONLY: root override policies are development-keyed', () {
    final source = _source('main.dart');
    for (final provider in [
      'sidebarNavigationRestorationEnabledProvider',
      'settingsResetMessageDataActionAvailableProvider',
    ]) {
      expect(
        source,
        contains(
          '$provider.overrideWith((ref) {\n'
          '        return !appCzarDevelopmentCompositionEnabled;',
        ),
      );
    }
  });

  test('SOURCE ONLY: neutral shell excludes legacy root and ambient monitor', () {
    final source = _source(
      'essentials/app_czar_operating_session/presentation/app_czar_operating_session_app.dart',
    );
    for (final forbidden in [
      'StartupApp(',
      'ProductionMacosAppShell(',
      'AdvancedStartFreshOverlayHost(',
      'chatDbChangeMonitorProvider',
      'onboardingJourneyControllerProvider',
    ]) {
      expect(source, isNot(contains(forbidden)));
    }
  });

  test('SOURCE ONLY: selected controller builds schedule automatic work', () {
    final contracts = <String, String>{
      'app_czar_data_update': 'Future<void>.microtask(_runSelectedUpdate)',
      'app_czar_onboarding': '_schedule(_selfLocateAndContinue)',
      'app_czar_local_data_repair': 'Future<void>.microtask(()',
    };
    for (final entry in contracts.entries) {
      final source = _source(
        'essentials/${entry.key}/application/${entry.key}_controller.dart',
      );
      final build = source.substring(
        source.indexOf(' build() {'),
        source.indexOf('    return _current;'),
      );
      expect(build, contains(entry.value));
      expect(build, contains('appCzarAssessmentControllerProvider'));
    }
  });

  test('SOURCE ONLY: action/service/operation edges remain callable', () {
    expect(
      _source(
        'essentials/onboarding/application/advanced_start_fresh_action_provider.dart',
      ),
      contains('ref.read(startFreshServiceProvider.future)'),
    );
    expect(
      _source(
        'essentials/onboarding/application/start_fresh_service_provider.dart',
      ),
      contains('operation: ArchiveMutationOperation.startFresh'),
    );
    final dispatcher = _source(
      'essentials/sidebar/application/sidebar_action_dispatcher.dart',
    );
    expect(dispatcher, contains('await startFreshAction.request()'));
    expect(
      dispatcher,
      isNot(contains('settingsResetMessageDataActionAvailableProvider')),
    );
  });

  test('typed distinctness and SOURCE ONLY protected graph refusal', () {
    expect(
      ArchiveMutationOperation.localDataRepair,
      isNot(ArchiveMutationOperation.startFresh),
    );
    expect(
      const AppCzarLocalDataRepairSafetyObservation.unknown(
        issue: 'synthetic',
      ).mayResetDerivedStores,
      isFalse,
    );
    final reader = _source(
      'essentials/app_czar/infrastructure/sqlite_app_czar_local_data_repair_safety_reader.dart',
    );
    expect(reader, contains('if (graphResult.consequentialRowCount > 0)'));
    expect(
      reader,
      contains(
        'AppCzarLocalDataRepairSafetyCondition.protectedMaterialPresent',
      ),
    );
    final executor = _source(
      'essentials/app_czar_local_data_repair/application/app_czar_local_data_repair_executor_provider.dart',
    );
    expect(executor, contains('ArchiveMutationOperation.localDataRepair'));
    expect(executor, isNot(contains('ArchiveMutationOperation.startFresh')));
  });

  test('SOURCE ONLY: bounded neutral support/Operating seams have no reset edge', () {
    // Deliberately bounded: not an exhaustive feature interaction proof.
    for (final path in [
      'essentials/search/application/search_service_provider.dart',
      'essentials/conversation_graph/application/conversation_favourites/conversation_favourite_actions_provider.dart',
      'features/conversations/application/conversation_tags/conversation_tag_actions_provider.dart',
      'features/contacts/application/sidebar_cassette_spec/resolver_tools/contact_favorite_actions_provider.dart',
      'essentials/logging/application/diagnostic_report_provider.dart',
      'features/environment_summary/application/environment_summary_provider.dart',
      'essentials/app_czar_operating_session/application/app_czar_operating_session_controller.dart',
      'essentials/app_czar_operating_session/application/app_czar_operating_currentness_controller.dart',
    ]) {
      final source = _source(path);
      expect(source, isNot(contains('startFreshServiceProvider')));
      expect(source, isNot(contains('advancedStartFreshActionProvider')));
      expect(source, isNot(contains('reconstruction')));
    }
  });
}

String _source(String relativePath) =>
    File('lib/$relativePath').readAsStringSync();

ArchiveAccessAuthority _authority({required bool development}) {
  // Synthetic already-admitted value; not a native/signature admission test.
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: development
          ? ArchiveEnvironment.development
          : ArchiveEnvironment.production,
      buildIdentity: development
          ? ArchiveBuildIdentity.developmentDebug
          : ArchiveBuildIdentity.productionRelease,
      archiveInstanceId: ArchiveInstanceId(
        'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      ),
      canonicalRootPath: '/synthetic-unopened-root',
      bundleIdentifier: development
          ? 'com.bigbenchsoftware.MessageLens.development'
          : ArchiveIdentityValidator.defaultProductionBundleIdentifier,
      productName: development
          ? 'MessageLens Development'
          : ArchiveIdentityValidator.defaultProductionProductName,
    ),
  );
}

final class _InertAction implements AdvancedStartFreshAction {
  int requests = 0;
  int retries = 0;
  int dismissals = 0;

  @override
  Future<AdvancedStartFreshActionResult> request() async {
    requests += 1;
    return AdvancedStartFreshActionResult.cancelled;
  }

  @override
  Future<AdvancedStartFreshActionResult> retry({
    required int occurrence,
  }) async {
    retries += 1;
    throw StateError('Unexpected retry');
  }

  @override
  void dismissFailure({required int occurrence}) {
    dismissals += 1;
    throw StateError('Unexpected dismissal');
  }
}

AppCzarAssessmentState _currentAssessment() {
  return AppCzarAssessmentState(
    generation: 1,
    attachmentArchive: const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Synthetic',
      resolvedPath: '/synthetic-unopened-root',
      archiveScopeIdentity: 'synthetic-scope',
      archiveGeneration: 1,
      coverage: AppCzarAttachmentCoverageObservation(
        condition: AppCzarAttachmentCoverageCondition.complete,
        requiredCount: 1,
        coveredCount: 1,
        missingCount: 0,
        unverifiableCount: 0,
        archiveScopeIdentity: 'synthetic-scope',
        archiveGeneration: 1,
      ),
      repairability: AppCzarAttachmentRepairabilityObservation(
        condition: AppCzarAttachmentRepairOpportunityCondition.absent,
        availableFromMessagesCount: 0,
        sourceAbsentCount: 0,
        sourceUnknownCount: 0,
        recordBackedRecoveryCount: 0,
        unsafeOrConflictingCount: 0,
        archiveScopeIdentity: 'synthetic-scope',
        archiveGeneration: 1,
      ),
    ),
    assessment: AppCzarAssessment(
      facts: [
        for (final id in AppCzarFactId.values)
          AppCzarFact(
            id: id,
            label: id.name,
            detail: 'Synthetic fact',
            truth:
                id == AppCzarFactId.sourceAheadOfLocal ||
                    id == AppCzarFactId.attachmentRepairOpportunityPresent
                ? AppCzarTruth.falseValue
                : AppCzarTruth.trueValue,
          ),
      ],
      diagnosisKind: AppCzarDiagnosisKind.healthyCurrentInstallation,
      diagnosis: 'Synthetic current installation',
      virtualCoordinator: AppCzarVirtualCoordinator.operatingSession,
    ),
  );
}
