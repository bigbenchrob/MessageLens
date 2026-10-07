import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/app_czar_local_data_repair/application/app_czar_local_data_repair_controller.dart';
import 'package:remember_this_text/essentials/app_czar_local_data_repair/domain/app_czar_local_data_repair_state.dart';
import 'package:remember_this_text/essentials/app_czar_local_data_repair/presentation/app_czar_local_data_repair_screen.dart';

void main() {
  testWidgets('revalidation copy is current, literal, and non-destructive', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AppCzarLocalDataRepairState(
          phase: AppCzarLocalDataRepairPhase.revalidating,
          assessmentGeneration: 7,
        ),
      ),
    );

    expect(find.byKey(AppCzarLocalDataRepairScreen.screenKey), findsOneWidget);
    expect(find.text('Rechecking local repair safety'), findsOneWidget);
    expect(find.textContaining('Nothing has been deleted'), findsOneWidget);
    expect(find.textContaining('previous import'), findsNothing);
    expect(find.textContaining('Onboarding'), findsNothing);
  });

  testWidgets('admitted repair names only the exact derived-store action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AppCzarLocalDataRepairState(
          phase: AppCzarLocalDataRepairPhase.resetting,
          assessmentGeneration: 7,
        ),
      ),
    );

    expect(find.text('Preparing a clean local rebuild'), findsOneWidget);
    expect(
      find.textContaining('only the two rebuildable derived message stores'),
      findsOneWidget,
    );
    expect(find.textContaining('nothing can be lost'), findsNothing);
    expect(find.textContaining('repair succeeded'), findsNothing);
  });

  testWidgets('failure makes no success claim and offers reassessment', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AppCzarLocalDataRepairState(
          phase: AppCzarLocalDataRepairPhase.failed,
          assessmentGeneration: 7,
          failure: 'Current safety evidence could not be established.',
        ),
      ),
    );

    expect(find.text('Local data repair needs attention'), findsOneWidget);
    expect(
      find.textContaining('stopped without claiming success'),
      findsOneWidget,
    );
    expect(find.text('Restart and reassess'), findsOneWidget);
    expect(find.textContaining('repair succeeded'), findsNothing);
  });
}

Widget _host(AppCzarLocalDataRepairState state) {
  return ProviderScope(
    overrides: <Override>[
      appCzarLocalDataRepairControllerProvider.overrideWith(
        () => _FixedLocalDataRepairController(state),
      ),
    ],
    child: const MacosApp(home: AppCzarLocalDataRepairScreen()),
  );
}

final class _FixedLocalDataRepairController
    extends AppCzarLocalDataRepairController {
  _FixedLocalDataRepairController(this.fixedState);

  final AppCzarLocalDataRepairState fixedState;

  @override
  AppCzarLocalDataRepairState build() => fixedState;
}
