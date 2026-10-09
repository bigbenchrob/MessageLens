import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar/presentation/app_czar_startup_harness.dart';
import 'package:remember_this_text/essentials/app_czar_attachment_archive_repair/application/app_czar_attachment_archive_repair_controller.dart';
import 'package:remember_this_text/essentials/app_czar_attachment_archive_repair/application/app_czar_attachment_archive_repair_executor_provider.dart';
import 'package:remember_this_text/essentials/app_czar_attachment_archive_repair/presentation/app_czar_attachment_archive_repair_screen.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_data_update_controller.dart';
import 'package:remember_this_text/essentials/app_czar_diagnostic_review/presentation/app_czar_diagnostic_review_screen.dart';
import 'package:remember_this_text/essentials/app_czar_local_data_repair/application/app_czar_local_data_repair_controller.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/presentation/app_czar_onboarding_screen.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_session_controller.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_session_visual_initializer_provider.dart';
import 'package:remember_this_text/essentials/app_czar_source_access/application/app_czar_source_access_controller.dart';
import 'package:remember_this_text/essentials/logging/feature_level_providers.dart'
    show activeBlockingPipelineIncidentProvider;
import 'package:remember_this_text/essentials/navigation/application/onboarding_center_panel_sync_controller.dart';
import 'package:remember_this_text/essentials/navigation/presentation/widgets/onboarding_center_panel_sync_observer.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/onboarding_journey_path.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/onboarding_overlay.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity_resolver_provider.dart';
import 'package:remember_this_text/features/environment_readiness/application/environment_readiness_actions_provider.dart';
import 'package:remember_this_text/features/environment_readiness/application/view_spec/resolver_tools/environment_readiness_surface_provider.dart';

void main() {
  testWidgets(
    'healthy current evidence replaces assessment with Operating once',
    (tester) async {
      var displayIdentityResolverBuilds = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appCzarObservationReaderProvider.overrideWithValue(
              const _HealthyReader(),
            ),
            appCzarOperatingSessionVisualInitializerProvider.overrideWithValue(
              const _ImmediateVisualInitializer(),
            ),
            displayIdentityResolverProvider.overrideWith((ref) async {
              displayIdentityResolverBuilds += 1;
              throw StateError('Operating test child must remain isolated.');
            }),
          ],
          child: const AppCzarStartupHarness(
            operatingSessionApp: SizedBox(
              key: Key('admitted-operating-session'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('admitted-operating-session')),
        findsOneWidget,
      );
      expect(find.byKey(AppCzarAssessmentScreen.screenKey), findsNothing);
      expect(displayIdentityResolverBuilds, 0);
    },
  );

  testWidgets(
    'Operating visual admission disables reassessment and reports once after entry',
    (tester) async {
      final initializer = _BlockingVisualInitializer();
      var operatingAdmissionReports = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appCzarObservationReaderProvider.overrideWithValue(
              const _HealthyReader(),
            ),
            appCzarOperatingSessionVisualInitializerProvider.overrideWithValue(
              initializer,
            ),
          ],
          child: AppCzarStartupHarness(
            operatingSessionApp: const SizedBox(
              key: Key('admitted-operating-session'),
            ),
            onOperatingAdmitted: () {
              operatingAdmissionReports += 1;
            },
          ),
        ),
      );

      for (
        var attempt = 0;
        attempt < 100 && !initializer.hasStarted;
        attempt += 1
      ) {
        await tester.pump(const Duration(milliseconds: 1));
      }
      expect(initializer.hasStarted, isTrue);
      final runAgain = tester.widget<TextButton>(
        find.byKey(AppCzarAssessmentScreen.runAgainKey),
      );
      expect(runAgain.onPressed, isNull);
      expect(operatingAdmissionReports, 0);

      initializer.release();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('admitted-operating-session')),
        findsOneWidget,
      );
      expect(operatingAdmissionReports, 1);
      await tester.pump();
      expect(operatingAdmissionReports, 1);
    },
  );

  testWidgets('shows genuine pending state before evidence resolves', (
    tester,
  ) async {
    var displayIdentityResolverBuilds = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appCzarObservationReaderProvider.overrideWithValue(
            _NeverCompletingReader(),
          ),
          displayIdentityResolverProvider.overrideWith((ref) async {
            displayIdentityResolverBuilds += 1;
            throw StateError('Assessment must not construct identities.');
          }),
        ],
        child: const AppCzarStartupHarness(),
      ),
    );
    await tester.pump();

    expect(find.text('Still assessing…'), findsOneWidget);
    expect(find.text('Not selected yet'), findsOneWidget);
    expect(find.text('Checking'), findsNWidgets(13));
    expect(find.textContaining('Full Disk Access'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(displayIdentityResolverBuilds, 0);
  });

  testWidgets(
    'archive unavailability remains diagnostic and does not execute repair',
    (tester) async {
      final factory = _RejectingRepairExecutorFactory();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appCzarObservationReaderProvider.overrideWithValue(
              const _ArchiveVariantReader(_unavailableArchive),
            ),
            appCzarAttachmentArchiveRepairExecutorFactoryProvider
                .overrideWithValue(factory),
          ],
          child: const AppCzarStartupHarness(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(AppCzarAssessmentScreen.screenKey), findsOneWidget);
      expect(
        find.byKey(AppCzarAttachmentArchiveRepairScreen.screenKey),
        findsNothing,
      );
      expect(find.text('Attachment Archive Repair'), findsOneWidget);
      expect(factory.createCalls, 0);
    },
  );

  testWidgets(
    'coverage UNKNOWN remains diagnostic and does not execute repair',
    (tester) async {
      final factory = _RejectingRepairExecutorFactory();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appCzarObservationReaderProvider.overrideWithValue(
              const _ArchiveVariantReader(_unknownCoverageArchive),
            ),
            appCzarAttachmentArchiveRepairExecutorFactoryProvider
                .overrideWithValue(factory),
          ],
          child: const AppCzarStartupHarness(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(AppCzarDiagnosticReviewScreen.screenKey),
        findsOneWidget,
      );
      expect(
        find.byKey(AppCzarAttachmentArchiveRepairScreen.screenKey),
        findsNothing,
      );
      expect(
        find.text('MessageLens needs a diagnostic review'),
        findsOneWidget,
      );
      expect(factory.createCalls, 0);
    },
  );

  testWidgets(
    'Diagnostic first branch constructs no specialist or legacy authority',
    (tester) async {
      final forbiddenAuthorityObserver = _ProviderInitializationObserver({
        appCzarAttachmentArchiveRepairControllerProvider,
        appCzarDataUpdateControllerProvider,
        appCzarLocalDataRepairControllerProvider,
        appCzarOnboardingControllerProvider,
        appCzarOperatingSessionControllerProvider,
        appCzarSourceAccessControllerProvider,
        onboardingJourneyCoordinatorProvider,
        onboardingGateProvider,
        onboardingCenterPanelSyncControllerProvider,
        activeBlockingPipelineIncidentProvider,
        environmentReadinessSurfaceProvider,
        environmentReadinessActionsProvider,
      });
      await tester.pumpWidget(
        ProviderScope(
          observers: [forbiddenAuthorityObserver],
          overrides: [
            appCzarObservationReaderProvider.overrideWithValue(
              const _ArchiveVariantReader(_unknownCoverageArchive),
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
      expect(forbiddenAuthorityObserver.initializedProviders, isEmpty);
    },
  );

  testWidgets(
    'AppCzar Onboarding owns accessDenied without legacy semantic authority',
    (tester) async {
      final forbiddenAuthorityObserver = _ProviderInitializationObserver({
        onboardingJourneyCoordinatorProvider,
        onboardingGateProvider,
        onboardingCenterPanelSyncControllerProvider,
        activeBlockingPipelineIncidentProvider,
        environmentReadinessSurfaceProvider,
        environmentReadinessActionsProvider,
      });
      await tester.pumpWidget(
        ProviderScope(
          observers: [forbiddenAuthorityObserver],
          overrides: [
            appCzarObservationReaderProvider.overrideWithValue(
              const _SafeEmptyAccessDeniedReader(),
            ),
          ],
          child: const AppCzarStartupHarness(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppCzarOnboardingScreen), findsOneWidget);
      expect(find.text('Messages access needs attention'), findsOneWidget);
      expect(find.text('Open System Settings'), findsOneWidget);
      expect(find.text('Check Again'), findsOneWidget);
      expect(find.byType(OnboardingOverlay), findsNothing);
      expect(find.byType(OnboardingJourneyPath), findsNothing);
      expect(find.byType(OnboardingCenterPanelSyncObserver), findsNothing);
      for (final railLabel in <String>[
        'Messages',
        'History',
        'Contacts',
        'Ready',
        'Import',
        'Start',
      ]) {
        expect(find.text(railLabel), findsNothing);
      }
      expect(forbiddenAuthorityObserver.initializedProviders, isEmpty);
    },
  );
}

final class _ProviderInitializationObserver extends ProviderObserver {
  _ProviderInitializationObserver(this.targets);

  final Set<ProviderBase<Object?>> targets;
  final Set<ProviderBase<Object?>> initializedProviders = {};

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    if (targets.contains(provider)) {
      initializedProviders.add(provider);
    }
  }
}

final class _RejectingRepairExecutorFactory
    implements AppCzarAttachmentArchiveRepairExecutorFactory {
  var createCalls = 0;

  @override
  AppCzarAttachmentArchiveRepairExecutor create() {
    createCalls += 1;
    throw StateError('Repair must not execute for this assessment.');
  }
}

final class _ArchiveVariantReader implements AppCzarObservationReader {
  const _ArchiveVariantReader(this.archive);

  final AppCzarArchiveObservation archive;

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async => archive;

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async {
    return const _HealthyReader().readGraphStore();
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() async {
    return const _HealthyReader().readImportStore();
  }

  @override
  Future<AppCzarDatabaseObservation> readOverlay() async {
    return const _HealthyReader().readOverlay();
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    return const _HealthyReader().readRoot();
  }

  @override
  Future<AppCzarSourceObservation> readSource() async {
    return const _HealthyReader().readSource();
  }
}

const _unavailableArchive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.unavailable,
  label: 'Unavailable archive',
  coverage: AppCzarAttachmentCoverageObservation.unknown(
    issue: 'Archive unavailable.',
  ),
  issue: 'Archive unavailable.',
);

const _unknownCoverageArchive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.available,
  label: 'Archive',
  archiveScopeIdentity: 'scope-a',
  archiveGeneration: 0,
  resolvedPath: '/Volumes/Test/attachment_archive',
  coverage: AppCzarAttachmentCoverageObservation.unknown(
    issue: 'Coverage inconclusive.',
    archiveScopeIdentity: 'scope-a',
    archiveGeneration: 0,
  ),
);

final class _ImmediateVisualInitializer
    implements AppCzarOperatingSessionVisualInitializer {
  const _ImmediateVisualInitializer();

  @override
  Future<void> initializeVisualWindowState() async {}
}

final class _BlockingVisualInitializer
    implements AppCzarOperatingSessionVisualInitializer {
  final Completer<void> _release = Completer<void>();
  bool hasStarted = false;

  void release() {
    if (!_release.isCompleted) {
      _release.complete();
    }
  }

  @override
  Future<void> initializeVisualWindowState() async {
    hasStarted = true;
    await _release.future;
  }
}

final class _HealthyReader implements AppCzarObservationReader {
  const _HealthyReader();

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    return const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Toshiba',
      archiveScopeIdentity: 'test-scope',
      archiveGeneration: 0,
      resolvedPath: '/test/archive',
      coverage: _completeCoverage,
      repairability: _completeRepairability,
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async {
    return const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 3,
      messageCount: 100,
      chatCount: 4,
      chatMessageEdgeCount: 100,
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() async {
    return const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 10,
      messageCount: 100,
      liveMessageCount: 100,
      liveMaxSourceRowId: 100,
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readOverlay() async {
    return const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 8,
    );
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    return const AppCzarRootObservation(
      admitted: true,
      path: '/Volumes/WD_ELEMENTS/MessageLens Development',
    );
  }

  @override
  Future<AppCzarSourceObservation> readSource() async {
    return const AppCzarSourceObservation(
      condition: AppCzarSourceCondition.readable,
      messageCount: 100,
      maxRowId: 100,
      sampleStable: true,
    );
  }
}

final class _SafeEmptyAccessDeniedReader
    implements
        AppCzarObservationReader,
        AppCzarInitialConstructionScopeReader,
        AppCzarContactsPrerequisiteReader {
  const _SafeEmptyAccessDeniedReader();

  @override
  Future<AppCzarInitialConstructionScopeObservation>
  readInitialConstructionScope() async {
    return const AppCzarInitialConstructionScopeObservation(
      condition: AppCzarInitialConstructionScopeCondition.safeEmpty,
      importMessageCount: 0,
      graphMessageCount: 0,
      graphChatCount: 0,
      graphEdgeCount: 0,
      nonLiveSourceCount: 0,
      hasRetiredDerivedArtifacts: false,
      issue: null,
    );
  }

  @override
  Future<AppCzarContactsPrerequisiteObservation>
  readContactsPrerequisite() async {
    return const AppCzarContactsPrerequisiteObservation(
      condition: AppCzarContactsPrerequisiteCondition.viableEmpty,
      contactCount: 0,
      viableStoreCount: 1,
    );
  }

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    return const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.notCreated,
      label: 'Default attachment archive',
      archiveScopeIdentity: 'test-scope',
      archiveGeneration: 0,
      resolvedPath: '/test/attachment_archive',
      coverage: AppCzarAttachmentCoverageObservation.unknown(
        issue: 'No conversation graph exists yet.',
        archiveScopeIdentity: 'test-scope',
        archiveGeneration: 0,
      ),
      repairability: AppCzarAttachmentRepairabilityObservation.unknown(
        issue: 'No conversation graph exists yet.',
        archiveScopeIdentity: 'test-scope',
        archiveGeneration: 0,
      ),
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async {
    return const AppCzarDatabaseObservation.absent();
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() async {
    return const AppCzarDatabaseObservation.absent();
  }

  @override
  Future<AppCzarDatabaseObservation> readOverlay() async {
    return const AppCzarDatabaseObservation.absent();
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    return const AppCzarRootObservation(admitted: true, path: '/test/root');
  }

  @override
  Future<AppCzarSourceObservation> readSource() async {
    return const AppCzarSourceObservation(
      condition: AppCzarSourceCondition.accessDenied,
      issue: 'macOS denied the current read-only source check.',
    );
  }
}

const _completeCoverage = AppCzarAttachmentCoverageObservation(
  condition: AppCzarAttachmentCoverageCondition.complete,
  requiredCount: 1,
  coveredCount: 1,
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

final class _NeverCompletingReader implements AppCzarObservationReader {
  final _never = Completer<void>().future;

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    await _never;
    throw StateError('unreachable');
  }

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async {
    await _never;
    throw StateError('unreachable');
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() async {
    await _never;
    throw StateError('unreachable');
  }

  @override
  Future<AppCzarDatabaseObservation> readOverlay() async {
    await _never;
    throw StateError('unreachable');
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    await _never;
    throw StateError('unreachable');
  }

  @override
  Future<AppCzarSourceObservation> readSource() async {
    await _never;
    throw StateError('unreachable');
  }
}
