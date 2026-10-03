import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../presentation/view/production_macos_app_shell.dart';
import 'app_navigator_key.dart';

part 'router.g.dart';

/// Minimal router that just opens the macOS app window
/// All navigation is handled by the navigation orchestrator and panel system
@Riverpod(keepAlive: true)
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MacosAppShell(),
      ),
    ],
  );
}
