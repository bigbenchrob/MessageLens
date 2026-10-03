import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/sidebar_mode_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/navigation/presentation/view/macos_app_shell.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_navigation_restoration_policy_provider.dart';
import 'package:remember_this_text/features/sidebar_utilities/feature_level_providers.dart'
    show TopChatMenuChoice, settingsResetMessageDataActionAvailableProvider;

void main() {
  test('Operating route starts with a neutral undecorated workspace', () {
    final container = ProviderContainer(
      overrides: [
        sidebarNavigationRestorationEnabledProvider.overrideWith(
          (ref) => false,
        ),
        settingsResetMessageDataActionAvailableProvider.overrideWith(
          (ref) => false,
        ),
      ],
    );
    addTearDown(container.dispose);

    final workspace = buildAppCzarOperatingSessionWorkspace();
    expect(workspace, isA<MessageLensWorkspaceShell>());
    expect(workspace.key, AppCzarOperatingSessionApp.workspaceKey);
    expect(workspace.normalSidebarShownByDefault, isTrue);
    expect(workspace.showConversationGraphStatusAction, isFalse);
    expect(workspace.sidebarVisibilityOwnerBuilder, isNull);
    expect(workspace.centerOverlayObservers, isEmpty);
    expect(workspace.fullWindowOverlays, isEmpty);

    expect(container.read(activeSidebarModeProvider), SidebarMode.messages);
    expect(container.read(sidebarFlowProvider), const SidebarFlowState());
    expect(
      container.read(sidebarFlowProvider).topMenuChoice,
      TopChatMenuChoice.conversations,
    );
    expect(
      container.read(sidebarNavigationRestorationEnabledProvider),
      isFalse,
    );
    expect(
      container.read(settingsResetMessageDataActionAvailableProvider),
      isFalse,
    );

    for (final mode in SidebarMode.values) {
      final panels = container.read(panelsViewStateProvider(mode));
      expect(panels[WindowPanel.center]?.isEmpty, isTrue);
      expect(panels[WindowPanel.right]?.isEmpty, isTrue);
    }
  });

  testWidgets('admitted Operating owns one top-level router application', (
    tester,
  ) async {
    final router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const SizedBox(key: Key('operating-router-child')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appCzarOperatingSessionRouterProvider.overrideWithValue(router),
        ],
        child: const AppCzarOperatingSessionApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppCzarOperatingSessionApp), findsOneWidget);
    expect(find.byKey(const Key('operating-router-child')), findsOneWidget);
  });
}
