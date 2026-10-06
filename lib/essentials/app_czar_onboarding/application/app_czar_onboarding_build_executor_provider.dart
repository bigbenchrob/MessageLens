import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../conversation_graph/application/conversation_graph_build_controller_provider.dart';
import '../../conversation_graph/application/conversation_graph_build_observation.dart';

part 'app_czar_onboarding_build_executor_provider.g.dart';

abstract interface class AppCzarOnboardingBuildExecutor {
  Future<void> run({required ConversationGraphBuildObserver onObservation});
}

final class _ConversationGraphAppCzarOnboardingBuildExecutor
    implements AppCzarOnboardingBuildExecutor {
  const _ConversationGraphAppCzarOnboardingBuildExecutor(this._controller);

  final ConversationGraphBuildController _controller;

  @override
  Future<void> run({
    required ConversationGraphBuildObserver onObservation,
  }) async {
    await _controller.runOnce(
      owner: 'app-czar-onboarding',
      onObservation: onObservation,
    );
  }
}

@riverpod
AppCzarOnboardingBuildExecutor appCzarOnboardingBuildExecutor(Ref ref) {
  return _ConversationGraphAppCzarOnboardingBuildExecutor(
    ref.read(conversationGraphBuildControllerProvider.notifier),
  );
}
