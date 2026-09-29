import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_journey_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';

void main() {
  group('onboardingGateProvider compatibility projection', () {
    test('publishes the Journey-owned compatibility status', () {
      final journey = _TestJourneyCoordinator(
        const OnboardingNormalApplication(occurrence: 1),
      );
      final container = ProviderContainer(
        overrides: [
          onboardingJourneyCoordinatorProvider.overrideWith(() => journey),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(onboardingGateProvider),
        OnboardingStatus.notNeeded,
      );

      journey.publish(
        const OnboardingOperationFailed(
          occurrence: 2,
          summary: 'Operation failed.',
          compatibilityStatus: OnboardingStatus.preparationFailed,
          failureAction: OnboardingJourneyFailureAction.retryInitialImport,
        ),
      );

      expect(
        container.read(onboardingGateProvider),
        OnboardingStatus.preparationFailed,
      );
    });

    test(
      'forwards stale-sensitive actions with their Journey context',
      () async {
        const context = OnboardingJourneyActionContext(
          occurrence: 7,
          episode: OnboardingJourneyEpisode.readyToImport,
          prerequisiteEvidenceRevision: 3,
          operationId: null,
        );
        final journey = _TestJourneyCoordinator(
          const OnboardingCheckingPrerequisites(occurrence: 1),
        );
        final container = ProviderContainer(
          overrides: [
            onboardingJourneyCoordinatorProvider.overrideWith(() => journey),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(onboardingGateProvider.notifier)
            .startVirginImportAndGraphBuild(actionContext: context);
        await container
            .read(onboardingGateProvider.notifier)
            .retryFailedOperation(actionContext: context);
        container
            .read(onboardingGateProvider.notifier)
            .dismiss(actionContext: context);

        expect(journey.startContext, same(context));
        expect(journey.retryContext, same(context));
        expect(journey.dismissContext, same(context));
      },
    );
  });
}

final class _TestJourneyCoordinator extends OnboardingJourneyCoordinator {
  _TestJourneyCoordinator(this.initialState);

  final OnboardingJourneyState initialState;
  OnboardingJourneyActionContext? startContext;
  OnboardingJourneyActionContext? retryContext;
  OnboardingJourneyActionContext? dismissContext;

  @override
  OnboardingJourneyState build() => initialState;

  void publish(OnboardingJourneyState next) {
    state = next;
  }

  @override
  Future<void> startVirginImportAndGraphBuild({
    required OnboardingJourneyActionContext actionContext,
  }) async {
    startContext = actionContext;
  }

  @override
  Future<void> retryFailedOperation({
    required OnboardingJourneyActionContext actionContext,
  }) async {
    retryContext = actionContext;
  }

  @override
  void dismiss({required OnboardingJourneyActionContext actionContext}) {
    dismissContext = actionContext;
  }
}
