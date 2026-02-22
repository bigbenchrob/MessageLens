import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../colors/theme_colors.dart';
import '../spacing/app_spacing.dart';

/// Cassette content wrapper for the sidebar.
///
/// Provides:
/// - Consistent padding and rhythm
/// - Selection/hover states
/// - **NO card borders or shadows**
///
/// ## Usage
///
/// Wrap cassette content (the cassette returns content only):
///
/// ```dart
/// CassetteChrome(
///   isSelected: isThisCassetteSelected,
///   onTap: () => selectThisCassette(),
///   child: Column(
///     crossAxisAlignment: CrossAxisAlignment.start,
///     children: [
///       Text('Cassette Title', style: typography.cassetteCardTitle),
///       SizedBox(height: AppSpacing.xs),
///       Text('Description', style: typography.cassetteCardSubtitle),
///     ],
///   ),
/// )
/// ```
///
/// ## Design Contract
///
/// - Cassettes must NOT style themselves with borders, shadows, or backgrounds.
/// - Styling comes from token roles and structural wrapper context.
/// - This wrapper owns: padding, rhythm, selection states.
/// - Individual cassettes own: content layout and text hierarchy.
class CassetteChrome extends ConsumerWidget {
  const CassetteChrome({
    required this.child,
    this.isSelected = false,
    this.isHovered = false,
    this.onTap,
    this.padding,
    super.key,
  });

  /// The cassette content.
  final Widget child;

  /// Whether this cassette is currently selected.
  final bool isSelected;

  /// Whether this cassette is currently hovered.
  ///
  /// For use with mouse region/gesture detector in parent widget.
  final bool isHovered;

  /// Callback when the cassette is tapped.
  final VoidCallback? onTap;

  /// Custom padding override.
  ///
  /// If null, uses standard cassette padding:
  /// - Horizontal: [AppSpacing.md]
  /// - Vertical: [AppSpacing.sm]
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    // Determine background color based on state
    Color bgColor;
    if (isSelected) {
      bgColor = colors.surfaces.selected;
    } else if (isHovered) {
      bgColor = colors.surfaces.hover;
    } else {
      bgColor = const Color(0x00000000); // Transparent
    }

    final effectivePadding =
        padding ??
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );

    final content = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

/// A stateful wrapper that handles hover state internally.
///
/// Use this when you want hover behavior without managing it yourself:
///
/// ```dart
/// CassetteItem(
///   isSelected: isSelected,
///   onTap: handleTap,
///   child: MyCassetteContent(),
/// )
/// ```
class CassetteItem extends StatefulWidget {
  const CassetteItem({
    required this.child,
    this.isSelected = false,
    this.onTap,
    this.padding,
    super.key,
  });

  final Widget child;
  final bool isSelected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  State<CassetteItem> createState() => _CassetteItemState();
}

class _CassetteItemState extends State<CassetteItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: CassetteChrome(
        isSelected: widget.isSelected,
        isHovered: _isHovered,
        onTap: widget.onTap,
        padding: widget.padding,
        child: widget.child,
      ),
    );
  }
}

/// Spacing between cassette items in the sidebar.
///
/// Use this as a gap widget between cassettes:
///
/// ```dart
/// Column(
///   children: [
///     CassetteItem(child: Cassette1()),
///     const CassetteGap(),
///     CassetteItem(child: Cassette2()),
///   ],
/// )
/// ```
class CassetteGap extends StatelessWidget {
  const CassetteGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: AppSpacing.cassetteGap);
  }
}
