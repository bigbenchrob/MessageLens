import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Import the sidebar cassette widget coordinator to build the left panel.
// The provider defined there (cassetteWidgetCoordinatorProvider) exposes the list
// of cassette widgets that compose the sidebar.  We wrap these in a
// Column to produce the left panel surface.
import '../../../sidebar/application/cassette_widget_coordinator_provider.dart';
import '../../../sidebar/presentation/view/sidebar_cassette_card.dart';
import '../../domain/entities/panel_stack.dart';
import '../../domain/navigation_constants.dart';
import '../../domain/sidebar_mode.dart';
import '../../feature_level_providers.dart';
import 'panel_coordinator_provider.dart';

part 'panel_widget_providers.g.dart';

/// Widget provider for center panel
@riverpod
Widget centerPanelWidget(Ref ref, SidebarMode mode) {
  final stack = ref.watch(
    panelsViewStateProvider(mode).select(
      (stacks) => stacks[WindowPanel.center] ?? const PanelStack.empty(),
    ),
  );
  return ref
      .read(panelCoordinatorProvider(mode).notifier)
      .buildPanelSurface(WindowPanel.center, stack);
}

/// Widget provider for left panel (sidebar).
///
/// This provider builds the left panel by reading the current list of
/// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
/// is wrapped in a [Column] so that the cassettes are laid out vertically.
@riverpod
Widget leftPanelWidget(Ref ref, SidebarMode mode) {
  // Watch the list of cassette widgets from the coordinator.  Whenever the
  // cassette rack changes (e.g. due to menu selections), the coordinator
  // updates this list, causing the left panel to rebuild.
  final cassetteWidgets = ref.watch(cassetteWidgetCoordinatorProvider(mode));
  return MouseRegion(
    child: _LeftSidebarSurface(cassetteWidgets: cassetteWidgets),
  );
}

class _LeftSidebarSurface extends StatelessWidget {
  const _LeftSidebarSurface({required this.cassetteWidgets});

  final List<Widget> cassetteWidgets;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final controls = <Widget>[];
        final content = <({Widget widget, bool shouldExpand})>[];

        for (final widget in cassetteWidgets) {
          final constrained = ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: widget,
          );

          // Control and naked cards go at the top, don't expand
          if (widget is SidebarCassetteCard &&
              (widget.isControl || widget.isNaked)) {
            controls.add(constrained);
          } else {
            final shouldExpand =
                widget is! SidebarCassetteCard || widget.shouldExpand;
            content.add((widget: constrained, shouldExpand: shouldExpand));
          }
        }

        return CustomScrollView(
          slivers: [
            for (final control in controls) SliverToBoxAdapter(child: control),
            if (content.isNotEmpty)
              SliverFillRemaining(
                hasScrollBody: true,
                child: _ContentFillColumn(children: content),
              ),
          ],
        );
      },
    );
  }
}

class _ContentFillColumn extends StatelessWidget {
  const _ContentFillColumn({required this.children});

  final List<({Widget widget, bool shouldExpand})> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in children)
          if (item.shouldExpand) Expanded(child: item.widget) else item.widget,
      ],
    );
  }
}
