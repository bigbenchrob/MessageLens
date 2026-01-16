import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../application/panel_widget_providers.dart';
import '../../domain/sidebar_mode.dart';

class WorkspaceLayout extends ConsumerWidget {
  const WorkspaceLayout({super.key, required this.mode});

  final SidebarMode mode;

  static const double _navigationColumnWidth = 320;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state to trigger rebuilds on theme/mode changes.
    ref.watch(themeColorsProvider);
    // Read the notifier to access color methods.
    final colors = ref.read(themeColorsProvider.notifier);
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
            child: ref.watch(leftPanelWidgetProvider(mode)),
          ),
        ),
        Expanded(
          child: Stack(children: [ref.watch(centerPanelWidgetProvider(mode))]),
        ),
      ],
    );
  }
}
