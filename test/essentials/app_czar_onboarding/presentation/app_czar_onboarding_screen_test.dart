import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/domain/app_czar_onboarding_state.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/presentation/app_czar_onboarding_screen.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_observation.dart';

void main() {
  testWidgets('build progress uses the shared worker vocabulary', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AppCzarOnboardingState(
          phase: AppCzarOnboardingPhase.building,
          suboperation: ConversationGraphBuildSuboperation.importMessages,
          completedWorkCount: 12,
          totalWorkCount: 20,
        ),
      ),
    );

    expect(find.text('Building your MessageLens library'), findsOneWidget);
    expect(find.text('Importing messages — 12 of 20'), findsOneWidget);
    expect(find.textContaining('Journey'), findsNothing);
  });

  testWidgets(
    'unavailable Contacts is literal and does not claim access denial',
    (tester) async {
      await tester.pumpWidget(
        _host(
          const AppCzarOnboardingState(
            phase: AppCzarOnboardingPhase.contactsNeedHuman,
            contactsCondition: AppCzarContactsPrerequisiteCondition.unavailable,
            issue: 'No viable address book folders found.',
          ),
        ),
      );

      expect(find.text('Check Again'), findsOneWidget);
      expect(find.text('Open System Settings'), findsNothing);
      expect(find.textContaining('no viable current database'), findsOneWidget);
      expect(find.textContaining('denied'), findsNothing);
    },
  );

  testWidgets(
    'unavailable Messages is literal and does not offer privacy settings',
    (tester) async {
      await tester.pumpWidget(
        _host(
          const AppCzarOnboardingState(
            phase: AppCzarOnboardingPhase.sourceNeedsHuman,
            sourceCondition: AppCzarSourceCondition.unavailable,
            issue: 'The current Messages database does not exist.',
          ),
        ),
      );

      expect(find.text('Check Again'), findsOneWidget);
      expect(find.text('Open System Settings'), findsNothing);
      expect(find.textContaining('database is unavailable'), findsOneWidget);
      expect(find.textContaining('denied'), findsNothing);
    },
  );
}

Widget _host(AppCzarOnboardingState state) {
  return ProviderScope(
    overrides: <Override>[
      appCzarOnboardingControllerProvider.overrideWith(
        () => _FixedOnboardingController(state),
      ),
    ],
    child: const MacosApp(home: AppCzarOnboardingScreen()),
  );
}

final class _FixedOnboardingController extends AppCzarOnboardingController {
  _FixedOnboardingController(this.fixedState);

  final AppCzarOnboardingState fixedState;

  @override
  AppCzarOnboardingState build() => fixedState;
}
