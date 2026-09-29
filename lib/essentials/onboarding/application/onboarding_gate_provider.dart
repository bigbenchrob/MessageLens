import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/onboarding_journey_state.dart';
import '../domain/onboarding_status.dart';
import 'onboarding_journey_coordinator_provider.dart';

part 'onboarding_gate_provider.g.dart';

/// Read-only compatibility projection for established presentation consumers.
///
/// Journey transitions belong exclusively to [OnboardingJourneyCoordinator].
/// The forwarding methods preserve existing caller and test seams while every
/// intent is decided by that coordinator.
@Riverpod(keepAlive: true)
class OnboardingGate extends _$OnboardingGate {
  @override
  OnboardingStatus build() {
    return ref.watch(onboardingJourneyCoordinatorProvider).compatibilityStatus;
  }

  Future<void> openFdaSettings() async {
    await ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .openFdaSettings();
  }

  void refreshEnvironment() {
    ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .refreshEnvironment();
  }

  Future<void> startVirginImportAndGraphBuild({
    required OnboardingJourneyActionContext actionContext,
  }) async {
    await ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .startVirginImportAndGraphBuild(actionContext: actionContext);
  }

  Future<void> retryFailedOperation({
    required OnboardingJourneyActionContext actionContext,
  }) async {
    await ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .retryFailedOperation(actionContext: actionContext);
  }

  Future<void> startReimport({
    required OnboardingJourneyActionContext actionContext,
  }) async {
    await ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .startReimport(actionContext: actionContext);
  }

  void dismiss({required OnboardingJourneyActionContext actionContext}) {
    ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .dismiss(actionContext: actionContext);
  }
}
