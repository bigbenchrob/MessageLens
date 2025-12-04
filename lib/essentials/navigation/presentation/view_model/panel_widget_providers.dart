import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Import the sidebar cassette widget coordinator to build the left panel.
// The provider defined there (cassetteWidgetCoordinatorProvider) exposes the list
// of cassette widgets that compose the sidebar.  We wrap these in a
// Column to produce the left panel surface.
import '../../../sidebar/application/cassette_widget_coordinator_provider.dart';
import '../../domain/entities/panel_stack.dart';
import '../../domain/navigation_constants.dart';
import '../../feature_level_providers.dart';
import 'panel_coordinator_provider.dart';

part 'panel_widget_providers.g.dart';

/// Widget provider for center panel
@riverpod
Widget centerPanelWidget(Ref ref) {
  final stack = ref.watch(
    panelsViewStateProvider.select(
      (stacks) => stacks[WindowPanel.center] ?? const PanelStack.empty(),
    ),
  );
  return ref
      .read(panelCoordinatorProvider.notifier)
      .buildPanelSurface(WindowPanel.center, stack);
}

/// Widget provider for right panel
@riverpod
Widget rightPanelWidget(Ref ref) {
  final stack = ref.watch(
    panelsViewStateProvider.select(
      (stacks) => stacks[WindowPanel.right] ?? const PanelStack.empty(),
    ),
  );
  return ref
      .read(panelCoordinatorProvider.notifier)
      .buildPanelSurface(WindowPanel.right, stack);
}

/// Widget provider for left panel (sidebar).
///
/// This provider builds the left panel by reading the current list of
/// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
/// is wrapped in a [Column] so that the cassettes are laid out vertically.
@riverpod
Widget leftPanelWidget(Ref ref) {
  // Watch the list of cassette widgets from the coordinator.  Whenever the
  // cassette rack changes (e.g. due to menu selections), the coordinator
  // updates this list, causing the left panel to rebuild.
  final cassetteWidgets = ref.watch(cassetteWidgetCoordinatorProvider);
  return Material(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: cassetteWidgets,
    ),
  );
}
