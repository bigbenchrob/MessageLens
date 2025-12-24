import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../providers.dart';

import '../../../logging/application/navigation_logger.dart';
import '../../../window_state/feature_level_providers.dart';
import '../../domain/entities/features/chats_spec.dart';
import '../../domain/entities/features/contacts_spec.dart';
import '../../domain/entities/features/import_spec.dart';
import '../../domain/entities/features/settings_spec.dart';
import '../../domain/entities/features/workbench_spec.dart';
import '../../domain/entities/view_spec.dart';
import '../../domain/navigation_constants.dart';
import '../../feature_level_providers.dart';
import '../view_model/panel_widget_providers.dart';

/// macOS window with a fixed navigation column and primary content canvas.
class MacosAppShell extends ConsumerStatefulWidget {
  const MacosAppShell({super.key});

  @override
  ConsumerState<MacosAppShell> createState() => _MacosAppShellState();
}

class _MacosAppShellState extends ConsumerState<MacosAppShell> {
  static const double _navigationColumnWidth = 320;
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

    return MacosWindow(
      child: MacosScaffold(
        toolBar: ToolBar(
          // Offset toolbar contents so controls align with the center panel
          // while the background stretches across the full window width.
          padding: const EdgeInsets.only(
            left: _navigationColumnWidth + _toolbarHorizontalPadding,
            right: _toolbarHorizontalPadding,
            top: _toolbarVerticalPadding,
            bottom: _toolbarVerticalPadding,
          ),
          title: const Text('Remember This Text'),
          centerTitle: true,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MacosTooltip(
                message: 'Settings',
                useMousePosition: false,
                child: MacosIconButton(
                  icon: MacosIcon(
                    CupertinoIcons.gear_alt,
                    color: MacosTheme.brightnessOf(context).resolve(
                      const Color.fromRGBO(0, 0, 0, 0.65),
                      const Color.fromRGBO(255, 255, 255, 0.75),
                    ),
                    size: 18,
                  ),
                  boxConstraints: const BoxConstraints(
                    minHeight: 20,
                    minWidth: 20,
                    maxWidth: 48,
                    maxHeight: 38,
                  ),
                  onPressed: () {
                    const spec = ViewSpec.settings(
                      SettingsSpec.contactShortNames(),
                    );

                    ref
                        .read(navigationLoggerProvider.notifier)
                        .logToolbarClick(
                          buttonLabel: 'Settings',
                          targetPanel: WindowPanel.center,
                          viewSpec: spec,
                        );

                    ref
                        .read(panelsViewStateProvider.notifier)
                        .show(panel: WindowPanel.center, spec: spec);
                  },
                ),
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

                return MacosTooltip(
                  message: tooltip,
                  useMousePosition: false,
                  child: MacosIconButton(
                    icon: MacosIcon(
                      icon,
                      color: MacosTheme.brightnessOf(context).resolve(
                        const Color.fromRGBO(0, 0, 0, 0.65),
                        const Color.fromRGBO(255, 255, 255, 0.75),
                      ),
                      size: 18,
                    ),
                    boxConstraints: const BoxConstraints(
                      minHeight: 20,
                      minWidth: 20,
                      maxWidth: 48,
                      maxHeight: 38,
                    ),
                    onPressed: () {
                      ref.read(switchableDarkModeProvider.notifier).cycle();
                    },
                  ),
                );
              }(),
            ],
          ),
          actions: [
            ToolBarIconButton(
              label: 'Chats',
              icon: const MacosIcon(CupertinoIcons.chat_bubble_2),
              onPressed: () {
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
                    .read(panelsViewStateProvider.notifier)
                    .show(panel: WindowPanel.center, spec: spec);
              },
              showLabel: false,
            ),
            ToolBarIconButton(
              label: 'Contacts',
              icon: const MacosIcon(CupertinoIcons.person_2),
              onPressed: () {
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
                    .read(panelsViewStateProvider.notifier)
                    .show(panel: WindowPanel.center, spec: spec);
              },
              showLabel: false,
            ),
            ToolBarIconButton(
              label: 'Import',
              icon: const MacosIcon(CupertinoIcons.square_arrow_down),
              onPressed: () {
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
                    .read(panelsViewStateProvider.notifier)
                    .show(panel: WindowPanel.center, spec: spec);
              },
              showLabel: false,
            ),
            ToolBarIconButton(
              label: 'Workbench',
              icon: const MacosIcon(CupertinoIcons.hammer),
              onPressed: () {
                const spec = ViewSpec.workbench(WorkbenchSpec.panel());

                ref
                    .read(navigationLoggerProvider.notifier)
                    .logToolbarClick(
                      buttonLabel: 'Workbench',
                      targetPanel: WindowPanel.center,
                      viewSpec: spec,
                    );

                ref
                    .read(panelsViewStateProvider.notifier)
                    .show(panel: WindowPanel.center, spec: spec);
              },
              showLabel: false,
            ),
          ],
        ),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              final colors = ref.watch(themeColorsProvider.notifier);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: _navigationColumnWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surfaces.contentControl,
                        border: Border(
                          right: BorderSide(
                            color: colors.lines.contentControlDivider,
                            width: 1,
                          ),
                        ),
                      ),
                      child: ref.watch(leftPanelWidgetProvider),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [ref.watch(centerPanelWidgetProvider)],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
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
