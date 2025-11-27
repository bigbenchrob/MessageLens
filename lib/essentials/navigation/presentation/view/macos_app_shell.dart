import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../logging/application/navigation_logger.dart';
import '../../../window_state/feature_level_providers.dart';
import '../../domain/entities/features/chats_spec.dart';
import '../../domain/entities/features/contacts_spec.dart';
import '../../domain/entities/features/import_spec.dart';
import '../../domain/entities/features/messages_spec.dart';
import '../../domain/entities/features/settings_spec.dart';
import '../../domain/entities/features/workbench_spec.dart';
import '../../domain/entities/panel_stack.dart';
import '../../domain/entities/view_spec.dart';
import '../../domain/navigation_constants.dart';
import '../../feature_level_providers.dart';
import '../view_model/panel_widget_providers.dart';

/// Basic macOS window with two sidebars
class MacosAppShell extends ConsumerStatefulWidget {
  const MacosAppShell({super.key});

  @override
  ConsumerState<MacosAppShell> createState() => _MacosAppShellState();
}

class _MacosAppShellState extends ConsumerState<MacosAppShell> {
  double? _sidebarWidth;
  double? _endSidebarWidth;
  double? _savedEndSidebarWidth; // Remember width when collapsed
  bool _endSidebarVisible = false;
  bool _initialized = false;
  Timer? _debounceTimer;
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
      final state = await svc.loadWindowState();
      if (mounted) {
        setState(() {
          _sidebarWidth = state.sidebarWidth;
          _endSidebarWidth = state.endSidebarWidth;
          _savedEndSidebarWidth = state.endSidebarWidth; // Remember last width
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

  void _debounceSave(Future<void> Function() op) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 120), () {
      op();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _windowFrameDebounce?.cancel();
    super.dispose();
  }

  void _handleEndSidebarContentChange(bool hasContent) {
    if (hasContent && !_endSidebarVisible) {
      // Restore sidebar to saved width
      setState(() {
        _endSidebarVisible = true;
        _endSidebarWidth = _savedEndSidebarWidth ?? 280.0;
      });
    } else if (!hasContent && _endSidebarVisible) {
      // Remember current width before collapsing
      setState(() {
        _savedEndSidebarWidth = _endSidebarWidth;
        _endSidebarVisible = false;
        _endSidebarWidth = 0.0;
      });
      // Save the collapsed state
      final windowSvc = ref.read(windowStateServiceProvider);
      _debounceSave(() async {
        await windowSvc.saveSidebarWidths(endSidebarWidth: 0.0);
      });
    }
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

    // Watch for right panel content changes and auto-show/hide sidebar
    ref.listen<Map<WindowPanel, PanelStack>>(panelsViewStateProvider, (
      previous,
      next,
    ) {
      final stack = next[WindowPanel.right];
      final hasContent = stack != null && !stack.isEmpty;
      _handleEndSidebarContentChange(hasContent);
    });

    return MacosWindow(
      onSidebarWidthChanged: (w) {
        final width = w < 0.0 ? 0.0 : w;
        setState(() {
          _sidebarWidth = width;
        });
        _debounceSave(() async {
          await windowSvc.saveSidebarWidths(sidebarWidth: width);
        });
      },
      onEndSidebarWidthChanged: (w) {
        final width = w < 0.0 ? 0.0 : w;
        setState(() {
          _endSidebarWidth = width;
        });
        _debounceSave(() async {
          await windowSvc.saveSidebarWidths(endSidebarWidth: width);
        });
      },
      sidebar: Sidebar(
        minWidth: 120,
        startWidth: _sidebarWidth ?? 320,
        builder: (context, scrollController) {
          return const Text('Left sidebar content removed');
          // return ref.watch(leftPanelWidgetProvider);
        },
      ),
      endSidebar: Sidebar(
        minWidth: 120,
        startWidth: _endSidebarWidth ?? 280,
        builder: (context, scrollController) {
          return ref.watch(rightPanelWidgetProvider);
        },
      ),
      child: MacosScaffold(
        toolBar: ToolBar(
          title: const Text('Remember This Text'),
          centerTitle: true,
          leading: MacosTooltip(
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
          actions: [
            ToolBarIconButton(
              label: 'Messages',
              icon: const MacosIcon(CupertinoIcons.chat_bubble),
              onPressed: () {
                const spec = ViewSpec.messages(
                  MessagesSpec.forChat(chatId: 42),
                );

                // Log the navigation action
                ref
                    .read(navigationLoggerProvider.notifier)
                    .logToolbarClick(
                      buttonLabel: 'Messages',
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
                      targetPanel: WindowPanel.right,
                      viewSpec: spec,
                    );

                // Perform the navigation
                ref
                    .read(panelsViewStateProvider.notifier)
                    .show(panel: WindowPanel.right, spec: spec);
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
              return ref.watch(centerPanelWidgetProvider);
            },
          ),
        ],
      ),
    );
  }
}

// Legacy placeholder widgets removed; dynamic providers now supply content.
