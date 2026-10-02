import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_presentation_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/advanced_start_fresh_presentation.dart';

void main() {
  test('stale occurrences cannot replace or clear newer presentation', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(
      advancedStartFreshPresentationControllerProvider.notifier,
    );

    final first = controller.beginPreparing();
    final second = controller.beginPreparing();
    controller.showFailure(
      expectedOccurrence: first,
      failure: const AdvancedStartFreshFailure(
        kind: AdvancedStartFreshFailureKind.executionFailed,
        summary: 'stale',
        canRetry: true,
      ),
    );
    controller.dismiss(expectedOccurrence: first);

    final state = container.read(
      advancedStartFreshPresentationControllerProvider,
    );
    expect(first, 1);
    expect(second, 2);
    expect(state.occurrence, second);
    expect(state.phase, AdvancedStartFreshPresentationPhase.preparing);
  });

  test(
    'dismissal completion retains success ownership through handoff',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(
        advancedStartFreshPresentationControllerProvider.notifier,
      );
      final occurrence = controller.beginPreparing();
      controller.showVerifiedVirgin(expectedOccurrence: occurrence);
      var completed = false;
      final dismissal = controller
          .waitUntilDismissed(expectedOccurrence: occurrence)
          .then((_) {
            completed = true;
          });

      await Future<void>.value();
      expect(completed, isFalse);

      controller.dismiss(expectedOccurrence: occurrence);
      await dismissal;

      expect(completed, isTrue);
      expect(
        container.read(advancedStartFreshPresentationControllerProvider).phase,
        AdvancedStartFreshPresentationPhase.idle,
      );
    },
  );
}
