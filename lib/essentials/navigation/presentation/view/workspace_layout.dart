import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/theme.dart';
import '../../application/panel_widget_providers.dart';
import '../../domain/sidebar_mode.dart';

class WorkspaceLayout extends ConsumerWidget {
  const WorkspaceLayout({super.key, required this.mode});

  final SidebarMode mode;

  static const double _navigationColumnWidth = 320;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SidebarPlane(
          width: _navigationColumnWidth,
          child: ref.watch(leftPanelWidgetProvider(mode)),
        ),
        Expanded(
          child: ContentPlane(
            child: ref.watch(centerPanelWidgetProvider(mode)),
          ),
        ),
      ],
    );
  }
}
