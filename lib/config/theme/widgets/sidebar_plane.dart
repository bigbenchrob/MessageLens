import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../colors/theme_colors.dart';
import '../spacing/app_spacing.dart';

/// Plane A: Navigation surface wrapper.
///
/// Provides:
/// - Consistent panel background color
/// - Single divider on right edge (the only hard divider in the app)
/// - Standard panel padding
///
/// ## Usage
///
/// Wrap the sidebar root widget:
///
/// ```dart
/// SidebarPlane(
///   child: Column(
///     children: [
///       ContactPicker(),
///       CassetteRack(),
///       Heatmap(),
///     ],
///   ),
/// )
/// ```
///
/// ## Design Contract
///
/// - This is the ONLY place the sidebar ↔ content divider should exist.
/// - No additional dividers inside the sidebar.
/// - All sidebar elements share this single background.
class SidebarPlane extends ConsumerWidget {
  const SidebarPlane({
    required this.child,
    this.showDivider = true,
    this.width,
    super.key,
  });

  /// The sidebar content.
  final Widget child;

  /// Whether to show the right-edge divider separating sidebar from content.
  ///
  /// Defaults to true. Only disable if embedding within another container
  /// that provides its own separation.
  final bool showDivider;

  /// Optional explicit width. If null, uses parent constraints.
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    Widget content = ColoredBox(color: colors.surfaces.panel, child: child);

    if (showDivider) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaces.panel,
          border: Border(
            right: BorderSide(color: colors.lines.contentControlDivider),
          ),
        ),
        child: child,
      );
    }

    if (width != null) {
      content = SizedBox(width: width, child: content);
    }

    return content;
  }
}

/// Convenience extension for sidebar-specific spacing.
extension SidebarSpacing on AppSpacing {
  /// Standard horizontal padding for sidebar elements.
  ///
  /// All sidebar elements (picker, cassettes, heatmap) should use this
  /// to ensure left-edge alignment.
  static const EdgeInsets elementInsets = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
  );
}
