import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../colors/theme_colors.dart';

/// Plane B: Content surface wrapper.
///
/// Provides:
/// - Single continuous background for header, search, and message list
/// - No internal divisions or card semantics
///
/// ## Usage
///
/// Wrap the center panel root widget:
///
/// ```dart
/// ContentPlane(
///   child: Column(
///     children: [
///       Header(),
///       SearchBar(),
///       Expanded(child: MessageList()),
///     ],
///   ),
/// )
/// ```
///
/// ## Design Contract
///
/// - NO dividers between header/search/messages.
/// - NO cards, panels, or inset containers.
/// - Separation achieved via spacing and subtle tint shifts (≤2%) only.
/// - This is a reading surface, not a dashboard.
class ContentPlane extends ConsumerWidget {
  const ContentPlane({
    required this.child,
    this.useContentControlBackground = false,
    super.key,
  });

  /// The content (header + search + messages).
  final Widget child;

  /// Whether to use the mode-aware content control background instead of
  /// the neutral canvas.
  ///
  /// Use this for content control panels (e.g., settings) that need
  /// a slightly different tint based on sidebar mode.
  final bool useContentControlBackground;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    final bgColor = useContentControlBackground
        ? colors.surfaces.contentControl
        : colors.surfaces.canvas;

    return ColoredBox(
      color: bgColor,
      child: child,
    );
  }
}

/// A subtle background tint for search areas.
///
/// Use this when the search area needs a visual hint of interaction mode
/// without introducing borders, elevation, or card semantics.
///
/// ## Usage
///
/// ```dart
/// SearchAreaTint(
///   child: SearchBar(),
/// )
/// ```
///
/// ## Design Contract
///
/// - Tint delta must be ≤2% from content plane background.
/// - Must remain visually continuous with the content plane.
/// - NO borders, elevation, or card semantics.
class SearchAreaTint extends ConsumerWidget {
  const SearchAreaTint({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    // Subtle tint: blend 2% of textPrimary over canvas
    final tintColor = Color.alphaBlend(
      colors.content.textPrimary.withValues(alpha: 0.02),
      colors.surfaces.canvas,
    );

    return ColoredBox(
      color: tintColor,
      child: child,
    );
  }
}
