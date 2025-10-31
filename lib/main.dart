// ignore_for_file: unnecessary_overrides, use_setters_to_change_properties

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' as sched;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import './providers.dart';
import 'essentials/db_importers/application/monitor/chat_db_change_monitor_provider.dart';
import 'essentials/navigation/application/router.dart';
import 'essentials/window_state/feature_level_providers.dart';
import 'frb_generated.dart';

/// This method initializes macos_window_utils and styles the window.
Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig(
    // toolbarStyle: NSWindowToolbarStyle.unified, // default
    toolbarStyle: NSWindowToolbarStyle.expanded,
  );
  await config.apply();
}

class _MyDelegate extends NSWindowDelegate {
  ProviderContainer? _container;
  Timer? _pendingSave;

  void setContainer(ProviderContainer container) {
    _container = container;
  }

  @override
  void windowDidResize() {
    super.windowDidResize();
    _scheduleWindowStateSave();
  }

  @override
  void windowDidMove() {
    super.windowDidMove();
    _scheduleWindowStateSave();
  }

  @override
  void windowDidEndLiveResize() {
    super.windowDidEndLiveResize();
    _scheduleWindowStateSave();
  }

  @override
  void windowDidChangeScreen() {
    super.windowDidChangeScreen();
    final container = _container;
    if (container == null) {
      return;
    }

    // Cancel any in-flight save while the window is transitioning between displays.
    _pendingSave?.cancel();

    () async {
      final service = container.read(windowStateServiceProvider);
      await service.reconcileAfterScreenChange();
      _scheduleWindowStateSave();
    }();
  }

  void _scheduleWindowStateSave() {
    final container = _container;
    if (container != null) {
      _pendingSave?.cancel();
      _pendingSave = Timer(const Duration(milliseconds: 240), () {
        container
            .read(windowStateServiceProvider)
            .saveCurrentWindowState() // Use the method that preserves sidebar widths
            .catchError((error) {
              // Silently ignore errors in background saves
            });
      });
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize Rust library for URL preview parsing
  await RustLib.init();

  await _configureMacosWindowUtils();

  // Initialize Media Kit
  MediaKit.ensureInitialized();

  /// By default, enableWindowDelegate is set to false to ensure compatibility
  /// with other plugins. Set it to true if you wish to use NSWindowDelegate.
  /// WindowManipulator.initialize(enableWindowDelegate: true);\
  final delegate = _MyDelegate();
  // ignore: unused_local_variable
  final handle = WindowManipulator.addNSWindowDelegate(delegate);

  final brightness =
      sched.SchedulerBinding.instance.platformDispatcher.platformBrightness;

  // Create provider container
  final container = ProviderContainer(
    overrides: [
      // Initialize platform brightness immediately
      platformBrightnessProvider.overrideWith((ref) => brightness),
    ],
  );

  // Set up the delegate to access the container
  delegate.setContainer(container);

  // Restore window state
  try {
    await container.read(windowStateServiceProvider).restoreWindowState();
  } catch (e) {
    // If window state restoration fails, continue with default state
    debugPrint('Failed to restore window state: $e');
  }

  ///todo: remove
  /// Slow down scrolling so jumps are observable during debugging
  //sched.timeDilation = 5.0;

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    ref.watch(chatDbChangeMonitorProvider);

    return MacosApp.router(
      title: 'remember_that_text',
      theme: MacosThemeData.light().copyWith(),
      darkTheme: MacosThemeData.dark().copyWith(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
