import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/panels_view_state_provider.dart';
import '../../domain/entities/panel_stack.dart';
import '../../domain/navigation_constants.dart';
import 'panel_coordinator_provider.dart';

part 'panel_widget_providers.g.dart';

/// Widget provider for left panel
@riverpod
Widget leftPanelWidget(Ref ref) {
  final stacks = ref.watch(panelsViewStateProvider);
  final stack = stacks[WindowPanel.left] ?? const PanelStack.empty();
  return ref
      .read(panelCoordinatorProvider.notifier)
      .buildPanelSurface(WindowPanel.left, stack);
}

/// Widget provider for center panel
@riverpod
Widget centerPanelWidget(Ref ref) {
  final stacks = ref.watch(panelsViewStateProvider);
  final stack = stacks[WindowPanel.center] ?? const PanelStack.empty();
  return ref
      .read(panelCoordinatorProvider.notifier)
      .buildPanelSurface(WindowPanel.center, stack);
}

/// Widget provider for right panel
@riverpod
Widget rightPanelWidget(Ref ref) {
  final stacks = ref.watch(panelsViewStateProvider);
  final stack = stacks[WindowPanel.right] ?? const PanelStack.empty();
  return ref
      .read(panelCoordinatorProvider.notifier)
      .buildPanelSurface(WindowPanel.right, stack);
}
