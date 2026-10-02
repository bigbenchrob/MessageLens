import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:remember_this_text/essentials/navigation/presentation/widgets/onboarding_sidebar_visibility_owner.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_presentation_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/advanced_start_fresh_presentation.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_journey_state.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/advanced_start_fresh_overlay.dart';

void main() {
  testWidgets('preparing surface blocks the previous Settings presentation', (
    tester,
  ) async {
    var oldSettingsActionCount = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Center(
                  child: FilledButton(
                    onPressed: () {
                      oldSettingsActionCount += 1;
                    },
                    child: const Text('Old Settings action'),
                  ),
                ),
                const Positioned.fill(
                  child: AdvancedStartFreshOverlay(
                    presentation: AdvancedStartFreshPresentation(
                      occurrence: 1,
                      phase: AdvancedStartFreshPresentationPhase.preparing,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(AdvancedStartFreshOverlay.surfaceKey), findsOneWidget);
    expect(find.text('Preparing a fresh start'), findsOneWidget);
    await tester.tap(find.text('Old Settings action'), warnIfMissed: false);
    expect(oldSettingsActionCount, 0);
  });

  testWidgets('typed retryable failure exposes recovery actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: AdvancedStartFreshOverlay(
              presentation: AdvancedStartFreshPresentation(
                occurrence: 3,
                phase: AdvancedStartFreshPresentationPhase.failed,
                failure: AdvancedStartFreshFailure(
                  kind: AdvancedStartFreshFailureKind.mutationUnavailable,
                  summary: 'Another data operation is active.',
                  canRetry: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text("MessageLens couldn't start fresh"), findsOneWidget);
    expect(find.text('Another data operation is active.'), findsOneWidget);
    expect(
      find.byKey(AdvancedStartFreshOverlay.retryButtonKey),
      findsOneWidget,
    );
    expect(
      find.byKey(AdvancedStartFreshOverlay.dismissButtonKey),
      findsOneWidget,
    );
  });

  testWidgets('typed ineligibility explains that reset is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: AdvancedStartFreshOverlay(
              presentation: AdvancedStartFreshPresentation(
                occurrence: 4,
                phase: AdvancedStartFreshPresentationPhase.failed,
                failure: AdvancedStartFreshFailure(
                  kind: AdvancedStartFreshFailureKind.installationIneligible,
                  summary: 'No data was changed.',
                  canRetry: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Reset Message Data is unavailable'), findsOneWidget);
    expect(find.text('No data was changed.'), findsOneWidget);
    expect(find.byKey(AdvancedStartFreshOverlay.retryButtonKey), findsNothing);
    expect(
      find.byKey(AdvancedStartFreshOverlay.dismissButtonKey),
      findsOneWidget,
    );
  });

  testWidgets('verified virgin state yields to Onboarding presentation', (
    tester,
  ) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingJourneyCoordinatorProvider.overrideWith(
            _TestOnboardingJourneyCoordinator.new,
          ),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return const MaterialApp(
              home: Scaffold(
                body: Stack(children: [AdvancedStartFreshOverlayHost()]),
              ),
            );
          },
        ),
      ),
    );

    final presentation = container.read(
      advancedStartFreshPresentationControllerProvider.notifier,
    );
    final occurrence = presentation.beginPreparing();
    presentation.showVerifiedVirgin(expectedOccurrence: occurrence);
    await tester.pump();
    expect(find.byKey(AdvancedStartFreshOverlay.surfaceKey), findsOneWidget);

    (container.read(onboardingJourneyCoordinatorProvider.notifier)
            as _TestOnboardingJourneyCoordinator)
        .setTestJourney(const OnboardingCheckingPrerequisites(occurrence: 2));
    await tester.pump();

    expect(
      find.byKey(AdvancedStartFreshOverlay.surfaceKey),
      findsOneWidget,
      reason:
          'the operation surface must cover the sidebar-reconciliation frame',
    );

    await tester.pump();

    expect(find.byKey(AdvancedStartFreshOverlay.surfaceKey), findsNothing);
    expect(
      container.read(advancedStartFreshPresentationControllerProvider).phase,
      AdvancedStartFreshPresentationPhase.idle,
    );
  });

  testWidgets(
    'verified surface covers sidebar closure before Onboarding is revealed',
    (tester) async {
      late ProviderContainer container;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingJourneyCoordinatorProvider.overrideWith(
              _TestOnboardingJourneyCoordinator.new,
            ),
          ],
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return const _SidebarHandoffHarness();
            },
          ),
        ),
      );

      final presentation = container.read(
        advancedStartFreshPresentationControllerProvider.notifier,
      );
      final occurrence = presentation.beginPreparing();
      presentation.showVerifiedVirgin(expectedOccurrence: occurrence);
      await tester.pump();

      expect(find.text('sidebar shown'), findsOneWidget);
      expect(find.byKey(AdvancedStartFreshOverlay.surfaceKey), findsOneWidget);

      (container.read(onboardingJourneyCoordinatorProvider.notifier)
              as _TestOnboardingJourneyCoordinator)
          .setTestJourney(const OnboardingCheckingPrerequisites(occurrence: 2));
      await tester.pump();

      expect(find.text('sidebar shown'), findsOneWidget);
      expect(
        find.byKey(AdvancedStartFreshOverlay.surfaceKey),
        findsOneWidget,
        reason: 'the still-open sidebar must remain covered',
      );

      await tester.pump();

      expect(find.text('sidebar hidden'), findsOneWidget);
      expect(find.byKey(AdvancedStartFreshOverlay.surfaceKey), findsNothing);
    },
  );
}

final class _TestOnboardingJourneyCoordinator
    extends OnboardingJourneyCoordinator {
  @override
  OnboardingJourneyState build() {
    return const OnboardingNormalApplication(occurrence: 1);
  }

  void setTestJourney(OnboardingJourneyState journey) {
    state = journey;
  }
}

class _SidebarHandoffHarness extends ConsumerStatefulWidget {
  const _SidebarHandoffHarness();

  @override
  ConsumerState<_SidebarHandoffHarness> createState() =>
      _SidebarHandoffHarnessState();
}

class _SidebarHandoffHarnessState
    extends ConsumerState<_SidebarHandoffHarness> {
  bool _sidebarShown = true;

  @override
  Widget build(BuildContext context) {
    final status = ref
        .watch(onboardingJourneyCoordinatorProvider)
        .compatibilityStatus;
    return MaterialApp(
      home: MacosWindowScope(
        constraints: const BoxConstraints.tightFor(width: 900, height: 720),
        isSidebarShown: _sidebarShown,
        isEndSidebarShown: false,
        sidebarToggler: () {
          setState(() {
            _sidebarShown = !_sidebarShown;
          });
        },
        endSidebarToggler: () {},
        child: Builder(
          builder: (context) {
            final scope = MacosWindowScope.of(context);
            return Stack(
              children: [
                Text(scope.isSidebarShown ? 'sidebar shown' : 'sidebar hidden'),
                OnboardingSidebarVisibilityOwner(status: status),
                const AdvancedStartFreshOverlayHost(),
              ],
            );
          },
        ),
      ),
    );
  }
}
