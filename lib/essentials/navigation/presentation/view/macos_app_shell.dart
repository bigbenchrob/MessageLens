import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../providers.dart';
import '../../../db_onboarding/application/db_onboarding_bootstrap_guard.dart';
import '../../../db_onboarding/application/db_onboarding_state_provider.dart';
import '../../../db_onboarding/domain/db_onboarding_phase.dart';
import '../../../db_onboarding/presentation/view/db_onboarding_panel.dart';
import '../../../logging/application/navigation_logger.dart';
import '../../../window_state/feature_level_providers.dart';
import '../../application/sidebar_mode_provider.dart';
import '../../domain/entities/features/chats_spec.dart';
import '../../domain/entities/features/contacts_spec.dart';
import '../../domain/entities/features/db_setup_spec.dart';
import '../../domain/entities/features/import_spec.dart';
import '../../domain/entities/features/workbench_spec.dart';
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

    // Check if onboarding is required and get current onboarding state
    final onboardingRequiredAsync = ref.watch(dbOnboardingRequiredProvider);
    final onboardingState = ref.watch(dbOnboardingStateNotifierProvider);
    final showOnboarding = onboardingRequiredAsync.maybeWhen(
      data: (required) =>
          required &&
          onboardingState.currentPhase != DbOnboardingPhase.complete,
      orElse: () => false,
    );

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
              title: const Text('Remember This Text'),
              centerTitle: true,
              leading: const AppModeToggle(),
              actions: [
                ToolBarIconButton(
                  label: 'Chats',
                  icon: const MacosIcon(CupertinoIcons.chat_bubble_2),
                  onPressed: () {
                    ref
                        .read(activeSidebarModeProvider.notifier)
                        .setMode(SidebarMode.messages);

                    const spec = ViewSpec.chats(ChatsSpec.recent(limit: null));

                    // Log the navigation action
                    ref
                        .read(navigationLoggerProvider.notifier)
                        .logToolbarClick(
                          buttonLabel: 'Chats',
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
                  label: 'Contacts',
                  icon: const MacosIcon(CupertinoIcons.person_2),
                  onPressed: () {
                    ref
                        .read(activeSidebarModeProvider.notifier)
                        .setMode(SidebarMode.messages);

                    const spec = ViewSpec.contacts(ContactsSpec.list());

                    // Log the navigation action
                    ref
                        .read(navigationLoggerProvider.notifier)
                        .logToolbarClick(
                          buttonLabel: 'Contacts',
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
                  label: 'Onboarding Dev',
                  icon: const MacosIcon(CupertinoIcons.person_badge_plus),
                  onPressed: () {
                    ref
                        .read(activeSidebarModeProvider.notifier)
                        .setMode(SidebarMode.messages);

                    const spec = ViewSpec.dbSetup(DbSetupSpec.developerTools());

                    ref
                        .read(navigationLoggerProvider.notifier)
                        .logToolbarClick(
                          buttonLabel: 'Onboarding Dev',
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
                ToolBarIconButton(
                  label: 'Workbench',
                  icon: const MacosIcon(CupertinoIcons.hammer),
                  onPressed: () {
                    ref
                        .read(activeSidebarModeProvider.notifier)
                        .setMode(SidebarMode.messages);

                    const spec = ViewSpec.workbench(WorkbenchSpec.panel());

                    ref
                        .read(navigationLoggerProvider.notifier)
                        .logToolbarClick(
                          buttonLabel: 'Workbench',
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
        // Onboarding overlay - shown on first run until setup is complete
        if (showOnboarding) const Positioned.fill(child: DbOnboardingPanel()),
      ],
    );
  }
}

class _SimpleHoverTest extends StatefulWidget {
  @override
  State<_SimpleHoverTest> createState() => _SimpleHoverTestState();
}

class _SimpleHoverTestState extends State<_SimpleHoverTest> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('🔥 SHELL TEST: Tapped');
        },
        onHover: (hovering) {
          print('🔥 SHELL TEST InkWell: onHover=$hovering');
          setState(() {
            _isHovered = hovering;
          });
        },
        child: Container(
          width: 300,
          height: 60,
          decoration: BoxDecoration(
            color: _isHovered ? Colors.red : Colors.yellow,
            border: Border.all(color: Colors.black, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            _isHovered ? 'HOVERING IN SHELL!' : 'Hover over me (InkWell test)',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// Legacy placeholder widgets removed; dynamic providers now supply content.
