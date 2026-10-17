import 'dart:async';
import 'dart:ui' show AppExitResponse;

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
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_data_update_executor_provider.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/presentation/app_czar_data_update_screen.dart';
import 'package:remember_this_text/essentials/app_czar_diagnostic_review/presentation/app_czar_diagnostic_review_screen.dart';
import 'package:remember_this_text/essentials/app_czar_local_data_repair/application/app_czar_local_data_repair_controller.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/application/app_czar_onboarding_build_executor_provider.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/presentation/app_czar_onboarding_screen.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_session_controller.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_session_visual_initializer_provider.dart';
import 'package:remember_this_text/essentials/app_czar_source_access/application/app_czar_source_access_controller.dart';
import 'package:remember_this_text/essentials/app_czar_source_access/presentation/app_czar_source_access_screen.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_observation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/live_graph_update_worker.dart';
import 'package:remember_this_text/essentials/logging/feature_level_providers.dart'
    show activeBlockingPipelineIncidentProvider;
import 'package:remember_this_text/essentials/navigation/application/onboarding_center_panel_sync_controller.dart';
import 'package:remember_this_text/essentials/navigation/presentation/widgets/onboarding_center_panel_sync_observer.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/onboarding_journey_path.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/onboarding_overlay.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity_resolver_provider.dart';
import 'package:remember_this_text/features/environment_readiness/application/environment_readiness_actions_provider.dart';
import 'package:remember_this_text/features/environment_readiness/application/view_spec/resolver_tools/environment_readiness_surface_provider.dart';

void main() {
  testWidgets('Prompt 130 Onboarding host cancels a refused drain', (
    tester,
  ) async {
    final settings = _SourceExitSettings();
    final restarter = _ExitRestarter();
    final build = _NoOnboardingBuild();
    final owner = _ControlledOnboardingDrainFailure();
    final container = ProviderContainer(
      overrides: [
        appCzarObservationReaderProvider.overrideWithValue(
          const _SafeEmptyAccessDeniedReader(),
        ),
        fullDiskAccessProvider.overrideWithValue(settings),
        appCzarOnboardingBuildExecutorProvider.overrideWithValue(build),
        appCzarProcessRestarterProvider.overrideWithValue(restarter),
        appCzarOnboardingControllerProvider.overrideWith(() => owner),
      ],
    );
    Future<void>? exit;
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppCzarStartupHarness(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppCzarOnboardingScreen), findsOneWidget);
      expect(
        container.read(appCzarOnboardingControllerProvider.notifier),
        same(owner),
      );
      AppExitResponse? response;
      Object? failure;
      exit = tester.binding.handleRequestAppExit().then<void>(
        (value) {
          response = value;
        },
        onError: (Object error, StackTrace stack) {
          // Observe propagation at the test boundary; this is not a host catch.
          failure = error;
        },
      );
      await tester.pump();
      expect(owner.calls, 1);
      expect(response, isNull);
      expect(failure, isNull);
      owner.release.completeError(owner.refusal);
      await exit;
      expect(settings.calls, 0);
      expect(build.calls, 0);
      expect(restarter.calls, 0);
      printOnFailure(
        'Prompt130 injected drain refusal: '
        'response=$response identicalFailure=${identical(failure, owner.refusal)}',
      );
      expect(
        failure,
        isNull,
        reason: 'The unchanged host must handle refusal as cancellation.',
      );
      expect(response, AppExitResponse.cancel);
    } finally {
      if (!owner.release.isCompleted) {
        owner.release.complete();
      }
      await exit;
      settings.done.complete();
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    }
  });

  testWidgets('Prompt 129 Onboarding host waits for admitted Settings', (
    tester,
  ) async {
    final settings = _SourceExitSettings();
    final restarter = _ExitRestarter();
    final build = _NoOnboardingBuild();
    final container = ProviderContainer(
      overrides: [
        appCzarObservationReaderProvider.overrideWithValue(
          const _SafeEmptyAccessDeniedReader(),
        ),
        fullDiskAccessProvider.overrideWithValue(settings),
        appCzarOnboardingBuildExecutorProvider.overrideWithValue(build),
        appCzarProcessRestarterProvider.overrideWithValue(restarter),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AppCzarStartupHarness(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppCzarOnboardingScreen), findsOneWidget);
    final owner = container.read(appCzarOnboardingControllerProvider.notifier);
    final action = owner.openSystemSettings();
    AppExitResponse? response;
    final exit = tester.binding.handleRequestAppExit().then((value) {
      response = value;
      return value;
    });
    try {
      await tester.pump();
      final premature = response;
      expect(settings.calls, 1);
      settings.done.complete();
      await action;
      await tester.pump();
      expect(await exit, AppExitResponse.exit);
      expect(build.calls, 0);
      expect(restarter.calls, 0);
      expect(
        premature,
        isNull,
        reason: 'The real host must not grant exit while Settings is pending.',
      );
    } finally {
      if (!settings.done.isCompleted) {
        settings.done.complete();
      }
      await action;
      await exit;
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    }
  });

  for (final fail in [false, true]) {
    testWidgets('Prompt 131 host drains every Settings request failure=$fail', (
      tester,
    ) async {
      final settings = _SourceExitSettings();
      final secondPort = Completer<void>();
      settings.additional.add(secondPort);
      final restarter = _ExitRestarter();
      final build = _NoOnboardingBuild();
      final container = ProviderContainer(
        overrides: [
          appCzarObservationReaderProvider.overrideWithValue(
            const _SafeEmptyAccessDeniedReader(),
          ),
          fullDiskAccessProvider.overrideWithValue(settings),
          appCzarOnboardingBuildExecutorProvider.overrideWithValue(build),
          appCzarProcessRestarterProvider.overrideWithValue(restarter),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppCzarStartupHarness(),
        ),
      );
      await tester.pumpAndSettle();
      final owner = container.read(
        appCzarOnboardingControllerProvider.notifier,
      );
      final a = owner.openSystemSettings();
      final b = owner.openSystemSettings();
      AppExitResponse? response;
      final exit = tester.binding.handleRequestAppExit().then((value) {
        response = value;
        return value;
      });
      final duplicate = tester.binding.handleRequestAppExit();
      try {
        await tester.pump();
        expect(settings.calls, 2);
        expect(response, isNull);
        if (fail) {
          secondPort.completeError(StateError('Settings navigation failed'));
        } else {
          secondPort.complete();
        }
        await b;
        await tester.pump();
        expect(response, isNull);
        settings.done.complete();
        await a;
        await tester.pump();
        expect(
          await exit,
          fail ? AppExitResponse.cancel : AppExitResponse.exit,
        );
        expect(
          await duplicate,
          fail ? AppExitResponse.cancel : AppExitResponse.exit,
        );
        expect(restarter.calls, 0);
        expect(build.calls, 0);
      } finally {
        if (!settings.done.isCompleted) {
          settings.done.complete();
        }
        if (!secondPort.isCompleted) {
          secondPort.complete();
        }
        await Future.wait([a, b]);
        await exit;
        await duplicate;
        await tester.pumpWidget(const SizedBox.shrink());
        expect(
          await tester.binding.handleRequestAppExit(),
          AppExitResponse.exit,
        );
        container.dispose();
      }
    });
  }

  for (final fail in [false, true]) {
    testWidgets('Prompt 131 host cancels active restart failure=$fail', (
      tester,
    ) async {
      final settings = _SourceExitSettings();
      final restarter = _SourceExitRestarter(block: true);
      final container = ProviderContainer(
        overrides: [
          appCzarObservationReaderProvider.overrideWithValue(
            const _SafeEmptyAccessDeniedReader(),
          ),
          fullDiskAccessProvider.overrideWithValue(settings),
          appCzarOnboardingBuildExecutorProvider.overrideWithValue(
            _NoOnboardingBuild(),
          ),
          appCzarProcessRestarterProvider.overrideWithValue(restarter),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppCzarStartupHarness(),
        ),
      );
      await tester.pumpAndSettle();
      final owner = container.read(
        appCzarOnboardingControllerProvider.notifier,
      );
      final restart = owner
          .stopAndDrain(restart: true)
          .then<Object?>(
            (_) => null,
            onError: (Object error, StackTrace stack) => error,
          );
      try {
        await tester.pump();
        expect(restarter.calls, 1);
        expect(
          await tester.binding.handleRequestAppExit(),
          AppExitResponse.cancel,
        );
        expect(
          await tester.binding.handleRequestAppExit(),
          AppExitResponse.cancel,
        );
        if (fail) {
          restarter.done.completeError(StateError('restart refused'));
        } else {
          restarter.done.complete();
        }
        expect(await restart, fail ? isA<StateError>() : isNull);
        expect(
          await tester.binding.handleRequestAppExit(),
          fail ? AppExitResponse.cancel : AppExitResponse.exit,
        );
        expect(settings.calls, 0);
      } finally {
        if (!restarter.done.isCompleted) {
          restarter.done.complete();
        }
        await restart;
        settings.done.complete();
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
      }
    });
  }

  testWidgets(
    'Prompt 131 host keeps owner through invalidation and synchronous refusal',
    (tester) async {
      final owners = <_ControlledOnboardingDrainFailure>[];
      final settings = _SourceExitSettings();
      final container = ProviderContainer(
        overrides: [
          appCzarObservationReaderProvider.overrideWithValue(
            const _SafeEmptyAccessDeniedReader(),
          ),
          fullDiskAccessProvider.overrideWithValue(settings),
          appCzarOnboardingBuildExecutorProvider.overrideWithValue(
            _NoOnboardingBuild(),
          ),
          appCzarProcessRestarterProvider.overrideWithValue(_ExitRestarter()),
          appCzarOnboardingControllerProvider.overrideWith(() {
            final owner = _ControlledOnboardingDrainFailure(synchronous: true);
            owners.add(owner);
            return owner;
          }),
        ],
      );
      try {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const AppCzarStartupHarness(),
          ),
        );
        await tester.pumpAndSettle();
        expect(owners, hasLength(1));
        await tester.pump();
        expect(
          await tester.binding.handleRequestAppExit(),
          AppExitResponse.cancel,
        );
        expect(owners.first.calls, 1);
        container.invalidate(appCzarOnboardingControllerProvider);
        await tester.pumpAndSettle();
        // Riverpod rebuilds this notifier in place on invalidation. The host
        // must keep using the same selected instance, without re-registration.
        expect(owners, hasLength(1));
        expect(
          container.read(appCzarOnboardingControllerProvider.notifier),
          same(owners.first),
        );
        expect(
          await tester.binding.handleRequestAppExit(),
          AppExitResponse.cancel,
        );
        expect(owners.first.calls, 2);
        await tester.pumpWidget(const SizedBox.shrink());
        expect(
          await tester.binding.handleRequestAppExit(),
          AppExitResponse.exit,
        );
        expect(owners.first.calls, 2);
      } finally {
        for (final owner in owners) {
          owner.release.complete();
        }
        settings.done.complete();
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
      }
    },
  );

  for (final settingsAction in [true, false]) {
    for (final fail in [true, false]) {
      testWidgets(
        'Source Access host drains Settings=$settingsAction failure=$fail',
        (tester) async {
          final reader = _SourceExitReader();
          final settings = _SourceExitSettings();
          final restart = _SourceExitRestarter();
          final container = ProviderContainer(
            overrides: [
              appCzarAssessmentControllerProvider.overrideWith(
                _SourceExitAssessment.new,
              ),
              appCzarObservationReaderProvider.overrideWithValue(reader),
              fullDiskAccessProvider.overrideWithValue(settings),
              appCzarProcessRestarterProvider.overrideWithValue(restart),
            ],
          );
          addTearDown(container.dispose);
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: const AppCzarStartupHarness(),
            ),
          );
          expect(find.byType(AppCzarSourceAccessScreen), findsOneWidget);
          final owner = container.read(
            appCzarSourceAccessControllerProvider.notifier,
          );
          final action = settingsAction
              ? owner.openSystemSettings()
              : owner.checkAgain();
          await tester.pump();
          expect(settings.calls, settingsAction ? 1 : 0);
          expect(reader.calls, settingsAction ? 0 : 1);
          AppExitResponse? response;
          final exit = tester.binding.handleRequestAppExit().then((value) {
            response = value;
            return value;
          });
          final duplicate = tester.binding.handleRequestAppExit();
          await tester.pump();
          expect(response, isNull);
          expect(restart.calls, 0);
          if (settingsAction) {
            if (fail) {
              settings.done.completeError(StateError('Settings failed'));
            } else {
              settings.done.complete();
            }
          } else {
            if (fail) {
              reader.done.completeError(StateError('source failed'));
            } else {
              reader.done.complete(
                const AppCzarSourceObservation(
                  condition: AppCzarSourceCondition.readable,
                ),
              );
            }
          }
          await tester.pump();
          await action;
          expect(
            await exit,
            fail ? AppExitResponse.cancel : AppExitResponse.exit,
          );
          expect(
            await duplicate,
            fail ? AppExitResponse.cancel : AppExitResponse.exit,
          );
          expect(
            identical(
              owner,
              container.read(appCzarSourceAccessControllerProvider.notifier),
            ),
            isTrue,
          );
          expect(restart.calls, 0);
          await tester.pumpWidget(const SizedBox.shrink());
          expect(
            await tester.binding.handleRequestAppExit(),
            AppExitResponse.exit,
          );
        },
      );
    }
  }

  testWidgets(
    'Source Access exit refuses pending restart until actual settlement',
    (tester) async {
      final reader = _SourceExitReader();
      final settings = _SourceExitSettings();
      final restarter = _SourceExitRestarter(block: true);
      final container = ProviderContainer(
        overrides: [
          appCzarAssessmentControllerProvider.overrideWith(
            _SourceExitAssessment.new,
          ),
          appCzarObservationReaderProvider.overrideWithValue(reader),
          fullDiskAccessProvider.overrideWithValue(settings),
          appCzarProcessRestarterProvider.overrideWithValue(restarter),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppCzarStartupHarness(),
        ),
      );
      final owner = container.read(
        appCzarSourceAccessControllerProvider.notifier,
      );
      final check = owner.checkAgain();
      await tester.pump();
      reader.done.complete(const AppCzarSourceObservation.unknown('unknown'));
      await tester.pump();
      await check;
      final restart = owner.restartAndReassess();
      await tester.pump();
      expect(restarter.calls, 1);
      expect(
        await tester.binding.handleRequestAppExit(),
        AppExitResponse.cancel,
      );
      restarter.done.complete();
      await tester.pump();
      await restart;
      expect(await tester.binding.handleRequestAppExit(), AppExitResponse.exit);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final fail in [false, true]) {
    testWidgets('Data Update exit awaits work and refuses failure=$fail', (
      tester,
    ) async {
      final executor = _ExitExecutor();
      final restarter = _ExitRestarter();
      var constructions = 0;
      final container = ProviderContainer(
        overrides: [
          appCzarAssessmentControllerProvider.overrideWith(_ExitAssessment.new),
          appCzarDataUpdateExecutorProvider.overrideWith((ref) {
            constructions++;
            return executor;
          }),
          appCzarProcessRestarterProvider.overrideWithValue(restarter),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppCzarStartupHarness(),
        ),
      );
      await tester.pump();
      expect(find.byType(AppCzarDataUpdateScreen), findsOneWidget);
      expect(constructions, 1);
      expect(executor.calls, 1);
      AppExitResponse? response;
      final first = tester.binding.handleRequestAppExit().then((value) {
        response = value;
        return value;
      });
      final second = tester.binding.handleRequestAppExit();
      await tester.pump();
      expect(response, isNull);
      expect(restarter.calls, 0);
      if (fail) {
        executor.done.completeError(StateError('inert drain failure'));
      } else {
        executor.done.complete(_exitResult());
      }
      await tester.pump();
      expect(await first, fail ? AppExitResponse.cancel : AppExitResponse.exit);
      expect(
        await second,
        fail ? AppExitResponse.cancel : AppExitResponse.exit,
      );
      expect(executor.calls, 1);
      expect(restarter.calls, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(await tester.binding.handleRequestAppExit(), AppExitResponse.exit);
      expect(constructions, 1);
    });
  }
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
            fullDiskAccessProvider.overrideWithValue(
              _SourceExitSettings()..done.complete(),
            ),
            appCzarOnboardingBuildExecutorProvider.overrideWithValue(
              _NoOnboardingBuild(),
            ),
            appCzarProcessRestarterProvider.overrideWithValue(_ExitRestarter()),
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

final class _ExitAssessment extends AppCzarAssessmentController {
  @override
  AppCzarAssessmentState build() => AppCzarAssessmentState(
    generation: 7,
    assessment: AppCzarAssessment(
      facts: const [],
      diagnosisKind: AppCzarDiagnosisKind.sourceAheadOfLocal,
      diagnosis: 'synthetic',
      virtualCoordinator: AppCzarVirtualCoordinator.dataUpdate,
    ),
  );
}

final class _ExitExecutor implements AppCzarDataUpdateExecutor {
  final done = Completer<LiveGraphUpdateResult>();
  int calls = 0;
  @override
  Future<LiveGraphUpdateResult> run({LiveGraphUpdateObserver? onObservation}) {
    calls++;
    return done.future;
  }
}

final class _ExitRestarter implements AppCzarProcessRestarter {
  int calls = 0;
  @override
  Future<void> restartAndReassess() async {
    calls++;
  }
}

LiveGraphUpdateResult _exitResult() => const LiveGraphUpdateResult(
  prerequisites: LiveGraphUpdatePrerequisiteSnapshot(
    appDataReady: true,
    liveMaxRowId: 0,
    importedMaxSourceRowId: 0,
    liveImportableMessageCount: 0,
    importedMessageCount: 0,
  ),
  decision: StartupProbeDecision(
    shouldSchedule: false,
    reason: 'synthetic',
    trigger: StartupProbeTrigger.rowIdAdvanced,
  ),
);

final class _SourceExitAssessment extends AppCzarAssessmentController {
  @override
  AppCzarAssessmentState build() => AppCzarAssessmentState(
    generation: 9,
    source: const AppCzarSourceObservation(
      condition: AppCzarSourceCondition.accessDenied,
    ),
    assessment: AppCzarAssessment(
      facts: const [
        AppCzarFact(
          id: AppCzarFactId.messagesSourceReadable,
          label: 'source',
          truth: AppCzarTruth.falseValue,
          detail: 'synthetic',
        ),
      ],
      diagnosisKind: AppCzarDiagnosisKind.sourceAccessUnavailable,
      diagnosis: 'synthetic',
      virtualCoordinator: AppCzarVirtualCoordinator.sourceAccessRepair,
    ),
  );
}

final class _SourceExitReader extends _HealthyReader {
  final done = Completer<AppCzarSourceObservation>();
  int calls = 0;
  @override
  Future<AppCzarSourceObservation> readSource() {
    calls++;
    return done.future;
  }
}

final class _SourceExitSettings implements FullDiskAccess {
  final done = Completer<void>();
  final additional = <Completer<void>>[];
  int calls = 0;
  @override
  String get messagesDatabasePath => '/synthetic/messages';
  @override
  bool canReadMessagesDatabase() => false;
  @override
  MessagesSourceAccessResult inspectMessagesSourceAccess() =>
      MessagesSourceAccessResult.accessDenied;
  @override
  Future<void> openSettings() {
    calls++;
    return calls == 1 ? done.future : additional[calls - 2].future;
  }
}

final class _SourceExitRestarter implements AppCzarProcessRestarter {
  _SourceExitRestarter({this.block = false});
  final bool block;
  final done = Completer<void>();
  int calls = 0;
  @override
  Future<void> restartAndReassess() async {
    calls++;
    if (block) {
      await done.future;
    }
  }
}

final class _NoOnboardingBuild implements AppCzarOnboardingBuildExecutor {
  int calls = 0;
  @override
  Future<void> run({
    required ConversationGraphBuildObserver onObservation,
  }) async {
    calls += 1;
    throw StateError('Unexpected synthetic build admission');
  }
}

// Host-boundary fault injection only: normal admission/build and sealing remain
// inherited. This does not claim that the production owner implements refusal.
final class _ControlledOnboardingDrainFailure
    extends AppCzarOnboardingController {
  _ControlledOnboardingDrainFailure({this.synchronous = false});
  final bool synchronous;
  final release = Completer<void>();
  final refusal = StateError('synthetic Onboarding drain refused');
  int calls = 0;

  @override
  Future<void> stopAndDrain({bool restart = false}) {
    calls += 1;
    if (synchronous) {
      throw refusal;
    }
    return _failAfterDrain(restart);
  }

  Future<void> _failAfterDrain(bool restart) async {
    await super.stopAndDrain(restart: restart);
    await release.future;
  }
}
