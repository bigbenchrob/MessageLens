import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'onboarding_environment_report_provider.dart'
    show onboardingDevOverridesProvider;
import 'onboarding_gate_provider.dart';

part 'onboarding_readiness_actions_provider.g.dart';

@riverpod
class OnboardingReadinessActions extends _$OnboardingReadinessActions {
  @override
  FutureOr<void> build() {}

  void recheckReadiness({required bool clearSimulationOverride}) {
    if (clearSimulationOverride) {
      ref.read(onboardingDevOverridesProvider.notifier).clearAll();
    }
    ref.read(onboardingGateProvider.notifier).refreshEnvironment();
  }
}
