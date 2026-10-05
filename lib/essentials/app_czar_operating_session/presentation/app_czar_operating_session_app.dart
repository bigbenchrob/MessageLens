import 'dart:ui' show AppExitResponse;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_mode/feature_level_providers.dart'
    show switchableDarkModeProvider;
import '../../navigation/application/app_navigator_key.dart';
import '../../navigation/presentation/view/macos_app_shell.dart';
import '../application/app_czar_operating_currentness_controller.dart';
import '../application/app_czar_operating_session_controller.dart';
import '../domain/app_czar_operating_session_state.dart';
import 'app_czar_operating_currentness_status.dart';

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
/// Keeping this composition explicit makes its one subordinate status slot
/// directly verifiable without mounting production startup.
MessageLensWorkspaceShell buildAppCzarOperatingSessionWorkspace() {
  return const MessageLensWorkspaceShell(
    key: AppCzarOperatingSessionApp.workspaceKey,
    centerOverlayObservers: <Widget>[AppCzarOperatingCurrentnessStatusHost()],
  );
}

/// Closes admission and drains the exact Operating occurrence before macOS is
/// permitted to terminate the process.
@visibleForTesting
Future<AppExitResponse> drainAppCzarOperatingExitRequest({
  required AppCzarOperatingSessionState session,
  required Future<void> Function(AppCzarOperatingSessionOccurrence occurrence)
  stopAndDrain,
}) async {
  final occurrence = session.ownsOperatingShell ? session.occurrence : null;
  if (occurrence != null) {
    await stopAndDrain(occurrence);
  }
  return AppExitResponse.exit;
}

/// Normal MessageLens UI admitted by one exact AppCzar assessment generation.
///
/// This root deliberately owns neither the legacy Journey decorations nor the
/// ambient chat database monitor.
class AppCzarOperatingSessionApp extends ConsumerStatefulWidget {
  const AppCzarOperatingSessionApp({super.key});

  static const workspaceKey = Key('app-czar-operating-workspace');

  @override
  ConsumerState<AppCzarOperatingSessionApp> createState() =>
      _AppCzarOperatingSessionAppState();
}

class _AppCzarOperatingSessionAppState
    extends ConsumerState<AppCzarOperatingSessionApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onExitRequested: _handleExitRequested,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  Future<AppExitResponse> _handleExitRequested() async {
    final session = ref.read(appCzarOperatingSessionControllerProvider);
    return drainAppCzarOperatingExitRequest(
      session: session,
      stopAndDrain: (occurrence) {
        return ref
            .read(
              appCzarOperatingCurrentnessControllerProvider(
                occurrence,
              ).notifier,
            )
            .stopAndDrain();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
