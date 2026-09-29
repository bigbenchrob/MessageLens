import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/onboarding/domain/onboarding_journey_state.dart';
import '../../../essentials/onboarding/feature_level_providers.dart'
    show
        onboardingGateProvider,
        onboardingJourneyCoordinatorProvider,
        onboardingReadinessActionsProvider;

part 'environment_readiness_actions_provider.g.dart';

@riverpod
class EnvironmentReadinessActions extends _$EnvironmentReadinessActions {
  @override
  FutureOr<void> build() {}

  Future<void> openFdaSettings() async {
    await ref.read(onboardingGateProvider.notifier).openFdaSettings();
  }

  void refreshEnvironment() {
    ref.read(onboardingGateProvider.notifier).refreshEnvironment();
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

  void acceptLocalMessageHistory(OnboardingJourneyActionContext actionContext) {
    ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .acceptLocalMessageHistory(actionContext: actionContext);
  }

  void clearSimulationsAndRefresh() {
    ref
        .read(onboardingReadinessActionsProvider.notifier)
        .recheckReadiness(clearSimulationOverride: true);
  }
}
