import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../providers.dart';
import '../../../logging/application/navigation_logger.dart';
import '../../../onboarding/application/onboarding_gate_provider.dart';
import '../../../onboarding/domain/import_spec.dart';
import '../../../onboarding/domain/onboarding_status.dart';
import '../../../onboarding/domain/spec_classes/onboarding_view_spec.dart';
import '../../../onboarding/presentation/onboarding_overlay.dart';
import '../../../window_state/feature_level_providers.dart';
import '../../application/sidebar_mode_provider.dart';
import '../../domain/entities/view_spec.dart';
import '../../domain/navigation_constants.dart';
import '../../domain/sidebar_mode.dart';
import '../../feature_level_providers.dart';
import '../widgets/app_mode_toggle.dart';
import 'workspace_layout.dart';

/// macOS window with a fixed navigation column and primary content canvas.
class MacosAppShell extends ConsumerStatefulWidget {
  const MacosAppShell({super.key});

  @override
  ConsumerState<MacosAppShell> createState() => _MacosAppShellState();
}

class _MacosAppShellState extends ConsumerState<MacosAppShell> {
  static const double _toolbarHorizontalPadding = 8.0;
  static const double _toolbarVerticalPadding = 4.0;
  bool _initialized = false;
  Timer? _windowFrameDebounce;
  DateTime _lastFrameSave = DateTime.fromMillisecondsSinceEpoch(0);
  bool _pendingTrailingFrameSave = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final svc = ref.read(windowStateServiceProvider);
      await svc.loadWindowState();
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _windowFrameDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final windowSvc = ref.watch(windowStateServiceProvider);

    // Capture window size/position after each frame (debounced)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastFrameSave).inMilliseconds;

      // Throttle: only allow an immediate save if > 1500ms since last save
      if (elapsed > 1500) {
        _lastFrameSave = now;
        windowSvc.saveCurrentWindowState();
        _pendingTrailingFrameSave = false;
      } else {
        // Schedule a trailing save 1600ms after last immediate save
        _pendingTrailingFrameSave = true;
        _windowFrameDebounce?.cancel();
        final delay = 1600 - elapsed;
        _windowFrameDebounce = Timer(Duration(milliseconds: delay), () {
          if (_pendingTrailingFrameSave) {
            _lastFrameSave = DateTime.now();
            _pendingTrailingFrameSave = false;
            windowSvc.saveCurrentWindowState();
          }
        });
      }
    });

    final onboardingStatus = ref.watch(onboardingGateProvider);
    final showOnboarding = onboardingStatus != OnboardingStatus.notNeeded;

    return Stack(
      children: [
        MacosWindow(
          child: MacosScaffold(
            toolBar: ToolBar(
              // Position mode toggle above sidebar, other controls above center panel.
              padding: const EdgeInsets.only(
                left: _toolbarHorizontalPadding,
                right: _toolbarHorizontalPadding,
                top: _toolbarVerticalPadding,
                bottom: _toolbarVerticalPadding,
              ),
              title: const Text('MessageLens'),
              centerTitle: true,
              leading: const AppModeToggle(),
              actions: [
                ToolBarIconButton(
                  label: 'Import',
                  icon: const MacosIcon(CupertinoIcons.square_arrow_down),
                  onPressed: () {
                    ref
                        .read(activeSidebarModeProvider.notifier)
                        .setMode(SidebarMode.messages);

                    const spec = ViewSpec.import(ImportSpec.forImport());

                    // Log the navigation action
                    ref
                        .read(navigationLoggerProvider.notifier)
                        .logToolbarClick(
                          buttonLabel: 'Import',
                          targetPanel: WindowPanel.center,
                          viewSpec: spec,
                        );

                    // Perform the navigation
                    ref
                        .read(
                          panelsViewStateProvider(
                            SidebarMode.messages,
                          ).notifier,
                        )
                        .show(panel: WindowPanel.center, spec: spec);
                  },
                  showLabel: false,
                ),
                ToolBarIconButton(
                  label: 'Onboarding',
                  icon: const MacosIcon(CupertinoIcons.rocket),
                  onPressed: () {
                    ref
                        .read(activeSidebarModeProvider.notifier)
                        .setMode(SidebarMode.messages);

                    const spec = ViewSpec.onboarding(OnboardingSpec.devPanel());

                    ref
                        .read(navigationLoggerProvider.notifier)
                        .logToolbarClick(
                          buttonLabel: 'Onboarding',
                          targetPanel: WindowPanel.center,
                          viewSpec: spec,
                        );

                    ref
                        .read(
                          panelsViewStateProvider(
                            SidebarMode.messages,
                          ).notifier,
                        )
                        .show(panel: WindowPanel.center, spec: spec);
                  },
                  showLabel: false,
                ),
                () {
                  final themeMode = ref.watch(switchableDarkModeProvider);
                  final (IconData icon, String tooltip) = switch (themeMode) {
                    ThemeMode.system => (
                      CupertinoIcons.circle_lefthalf_fill,
                      'Theme: System (click to switch to Light)',
                    ),
                    ThemeMode.light => (
                      CupertinoIcons.sun_max_fill,
                      'Theme: Light (click to switch to Dark)',
                    ),
                    ThemeMode.dark => (
                      CupertinoIcons.moon_stars_fill,
                      'Theme: Dark (click to switch to System)',
                    ),
                  };
                  return ToolBarIconButton(
                    label: tooltip,
                    icon: MacosIcon(icon),
                    onPressed: () {
                      ref.read(switchableDarkModeProvider.notifier).cycle();
                    },
                    showLabel: false,
                  );
                }(),
              ],
            ),
            children: [
              ContentArea(
                builder: (context, scrollController) {
                  final activeMode = ref.watch(activeSidebarModeProvider);
                  return IndexedStack(
                    index: activeMode == SidebarMode.messages ? 0 : 1,
                    children: const [
                      WorkspaceLayout(mode: SidebarMode.messages),
                      WorkspaceLayout(mode: SidebarMode.settings),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        if (showOnboarding) const OnboardingOverlay(),
      ],
    );
  }
}

// Legacy placeholder widgets removed; dynamic providers now supply content.
