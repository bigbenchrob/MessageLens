import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_mode/feature_level_providers.dart'
    show switchableDarkModeProvider;
import '../../navigation/application/app_navigator_key.dart';
import '../../navigation/presentation/view/macos_app_shell.dart';

part 'app_czar_operating_session_app.g.dart';

/// The one-route router owned by an admitted AppCzar Operating occurrence.
@Riverpod(keepAlive: true)
GoRouter appCzarOperatingSessionRouter(Ref ref) {
  final router = GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'app-czar-operating-home',
        builder: (context, state) => buildAppCzarOperatingSessionWorkspace(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

/// Builds the neutral workspace admitted by AppCzar Operating Stage One.
///
/// Keeping this composition explicit makes its deliberately empty semantic
/// decoration slots directly verifiable without mounting production startup.
MessageLensWorkspaceShell buildAppCzarOperatingSessionWorkspace() {
  return const MessageLensWorkspaceShell(
    key: AppCzarOperatingSessionApp.workspaceKey,
  );
}

/// Normal MessageLens UI admitted by one exact AppCzar assessment generation.
///
/// This root deliberately owns neither the legacy Journey decorations nor the
/// ambient chat database monitor.
class AppCzarOperatingSessionApp extends ConsumerWidget {
  const AppCzarOperatingSessionApp({super.key});

  static const workspaceKey = Key('app-czar-operating-workspace');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(switchableDarkModeProvider);
    final router = ref.watch(appCzarOperatingSessionRouterProvider);
    return MacosApp.router(
      title: 'MessageLens Development',
      theme: MacosThemeData.light().copyWith(),
      darkTheme: MacosThemeData.dark().copyWith(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
