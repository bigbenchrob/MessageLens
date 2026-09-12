import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/navigation/application/app_navigator_key.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_action_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_presentation_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_state_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/start_fresh_service.dart';
import 'package:remember_this_text/essentials/onboarding/application/start_fresh_service_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/advanced_start_fresh_presentation.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/essentials/onboarding/domain/startup_installation_validation.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/advanced_start_fresh_overlay.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/widget_builders/settings_action_list.dart';

void main() {
  testWidgets(
    'Settings confirmation visibly owns presentation before reset begins',
    (tester) async {
      final trace = <String>[];
      var installationStateReadCount = 0;
      final service = _RecordingStartFreshService(trace: trace);
      late ProviderContainer container;
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(
            service: service,
            trace: trace,
            onInstallationStateRead: () {
              installationStateReadCount += 1;
            },
          ),
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return MaterialApp(
                navigatorKey: appNavigatorKey,
                home: Scaffold(
                  body: Stack(
                    children: [
                      const Center(child: _ResetSettingsAction()),
                      _TracedOperationHost(trace: trace),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await container.read(messageLensInstallationStateProvider.future);
      expect(installationStateReadCount, 1);
      expect(container.exists(advancedStartFreshActionProvider), isFalse);
      await _openAndAcceptAuthorization(tester);

      expect(find.text('Start with a clean MessageLens setup?'), findsNothing);
      expect(container.exists(advancedStartFreshActionProvider), isTrue);
      expect(find.byKey(AdvancedStartFreshOverlay.surfaceKey), findsOneWidget);
      expect(find.text('Preparing a fresh start'), findsOneWidget);
      expect(
        identical(
          ProviderScope.containerOf(
            tester.element(find.byType(SettingsActionList)),
          ),
          ProviderScope.containerOf(
            tester.element(find.byType(AdvancedStartFreshOverlay)),
          ),
        ),
        isTrue,
      );
      expect(service.entryPoints, [
        StartFreshEntryPoint.completedInstallationAdvancedReset,
      ]);
      expect(installationStateReadCount, 1);
      expect(trace, [
        'preparing-host-built',
        'service-resolved',
        'service-started',
      ]);
    },
  );

  testWidgets('verified virgin operation yields automatically to Onboarding', (
    tester,
  ) async {
    final service = _RecordingStartFreshService(trace: <String>[]);
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(service: service),
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(
              navigatorKey: appNavigatorKey,
              home: const Scaffold(
                body: Stack(
                  children: [
                    _ResetSettingsAction(),
                    AdvancedStartFreshOverlayHost(),
                    _OnboardingOwnershipMarker(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    await _openAndAcceptAuthorization(tester);
    service.completion.complete(_virginResult);
    await tester.pump();
    expect(find.text('Starting Onboarding'), findsOneWidget);

    (container.read(onboardingGateProvider.notifier) as _TestOnboardingGate)
        .setTestStatus(OnboardingStatus.awaitingUserAction);
    await tester.pump();
    await tester.pump();

    expect(find.byKey(AdvancedStartFreshOverlay.surfaceKey), findsNothing);
    expect(find.text('Onboarding owns presentation'), findsOneWidget);
  });

  testWidgets('reset failure becomes a typed visible operation outcome', (
    tester,
  ) async {
    final service = _RecordingStartFreshService(trace: <String>[]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(service: service),
        child: MaterialApp(
          navigatorKey: appNavigatorKey,
          home: const Scaffold(
            body: Stack(
              children: [
                _ResetSettingsAction(),
                AdvancedStartFreshOverlayHost(),
              ],
            ),
          ),
        ),
      ),
    );

    await _openAndAcceptAuthorization(tester);
    service.completion.completeError(StateError('test reset failure'));
    await tester.pump();
    await tester.pump();

    expect(find.text("MessageLens couldn't start fresh"), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.text('Return to Settings'), findsOneWidget);
  });
}

List<Override> _overrides({
  required _RecordingStartFreshService service,
  List<String>? trace,
  VoidCallback? onInstallationStateRead,
}) {
  return [
    messageLensInstallationStateProvider.overrideWith((ref) {
      onInstallationStateRead?.call();
      return Stream<StartupInstallationValidationState>.value(
        _completedValidation,
      );
    }),
    startFreshServiceProvider.overrideWith((ref) async {
      trace?.add('service-resolved');
      return service;
    }),
    onboardingGateProvider.overrideWith(_TestOnboardingGate.new),
  ];
}

Future<void> _openAndAcceptAuthorization(WidgetTester tester) async {
  await tester.tap(find.text('Reset message data…'));
  await tester.pumpAndSettle();
  expect(find.text('Start with a clean MessageLens setup?'), findsOneWidget);

  // Keep the modal alive across frames to exercise the provider lifecycle.
  await tester.pump(const Duration(milliseconds: 16));
  await tester.pump(const Duration(milliseconds: 16));
  await tester.tap(find.widgetWithText(FilledButton, 'Start Fresh'));
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  expect(find.text('Preparing a fresh start'), findsOneWidget);
}

const _completedState = MessageLensInstallationState(
  kind: MessageLensInstallationStateKind.completed,
  reason: 'healthy completed test installation',
);

const _completedValidation = StartupAdmissionGranted(
  installationState: _completedState,
  basis: StartupAdmissionBasis.boundedInspection,
);

const _virginResult = StartFreshResult(
  verifiedState: MessageLensInstallationState(
    kind: MessageLensInstallationStateKind.virgin,
    reason: 'verified virgin test installation',
  ),
);

final class _RecordingStartFreshService implements StartFreshService {
  _RecordingStartFreshService({required this.trace});

  final List<String> trace;
  final entryPoints = <StartFreshEntryPoint>[];
  final completion = Completer<StartFreshResult>();

  @override
  Future<StartFreshResult> startFresh({
    StartFreshEntryPoint entryPoint =
        StartFreshEntryPoint.incompleteInstallation,
  }) async {
    entryPoints.add(entryPoint);
    trace.add('service-started');
    return completion.future;
  }
}

final class _TestOnboardingGate extends OnboardingGate {
  @override
  OnboardingStatus build() => OnboardingStatus.notNeeded;

  void setTestStatus(OnboardingStatus status) {
    state = status;
  }
}

final class _TracedOperationHost extends ConsumerWidget {
  const _TracedOperationHost({required this.trace});

  final List<String> trace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation = ref.watch(
      advancedStartFreshPresentationControllerProvider,
    );
    if (presentation.phase == AdvancedStartFreshPresentationPhase.preparing &&
        !trace.contains('preparing-host-built')) {
      trace.add('preparing-host-built');
    }
    return const AdvancedStartFreshOverlayHost();
  }
}

final class _OnboardingOwnershipMarker extends ConsumerWidget {
  const _OnboardingOwnershipMarker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(onboardingGateProvider);
    if (status != OnboardingStatus.awaitingUserAction) {
      return const SizedBox.shrink();
    }
    return const Text('Onboarding owns presentation');
  }
}

final class _ResetSettingsAction extends StatelessWidget {
  const _ResetSettingsAction();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 320,
      child: SettingsActionList(
        actions: [
          SidebarActionDescriptor(
            label: 'Reset message data…',
            intent: ResetMessageDataRequested(),
          ),
        ],
        cassetteIndex: 1,
      ),
    );
  }
}
