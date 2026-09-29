import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/onboarding_journey_state.dart';
import 'onboarding_gate_provider.dart';
import 'onboarding_journey_coordinator_provider.dart';
import 'onboarding_readiness_actions_provider.dart';

part 'onboarding_overlay_actions_provider.g.dart';

@riverpod
class OnboardingOverlayActions extends _$OnboardingOverlayActions {
  @override
  FutureOr<void> build() {}

  Future<void> openFullDiskAccessSettings() async {
    await ref.read(onboardingGateProvider.notifier).openFdaSettings();
  }

  void recheckEnvironment() {
    ref
        .read(onboardingReadinessActionsProvider.notifier)
        .recheckReadiness(clearSimulationOverride: false);
  }

  Future<void> startVirginImportAndGraphBuild(
    OnboardingJourneyActionContext actionContext,
  ) async {
    await ref
        .read(onboardingGateProvider.notifier)
        .startVirginImportAndGraphBuild(actionContext: actionContext);
  }

  Future<void> retryFailedOperation(
    OnboardingJourneyActionContext actionContext,
  ) async {
    await ref
        .read(onboardingGateProvider.notifier)
        .retryFailedOperation(actionContext: actionContext);
  }

  Future<void> continueInterruptedOperation(
    OnboardingJourneyActionContext actionContext,
  ) async {
    await ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .continueInterruptedOperation(actionContext: actionContext);
  }

  void acceptLocalMessageHistory(OnboardingJourneyActionContext actionContext) {
    ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .acceptLocalMessageHistory(actionContext: actionContext);
  }

  void dismiss(OnboardingJourneyActionContext actionContext) {
    ref
        .read(onboardingGateProvider.notifier)
        .dismiss(actionContext: actionContext);
  }
}
