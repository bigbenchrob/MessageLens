import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// Pull in macOS‑specific colors for a more subtle border.
import 'package:macos_ui/macos_ui.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../config/theme/theme_typography.dart';

/// A reusable card container for sidebar cassette widgets.
///
/// This card applies a Mac‑like aesthetic with a light background,
/// subtle border and rounded corners, and a gentle shadow.  Wrap any
/// cassette widget in this card to visually separate it from other
/// components in the sidebar.
class SidebarCassetteCard extends ConsumerWidget {
  /// The child widget to display inside the card.
  final Widget child;

  /// Title shown at the top of the card.
  final String title;

  /// Optional descriptive subtitle displayed under the title.
  final String? subtitle;

  /// Padding inside the card around the child.
  final EdgeInsetsGeometry padding;

  /// Margin around the card relative to its parent.
  final EdgeInsetsGeometry margin;

  /// The border radius applied to the card’s corners.
  final double borderRadius;

  /// Whether this cassette is primarily a control surface (vs content).
  /// Control cassettes are visually de-emphasized to clarify hierarchy.
  final bool isControl;

  /// Whether this cassette should expand to fill available vertical space.
  final bool shouldExpand;

  const SidebarCassetteCard({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    this.borderRadius = 8.0,
    this.isControl = false,
    this.shouldExpand = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    final bbc = AppTheme.bbc(context);
    // Resolve a macOS control colour for the card background.  The control
    // colour is used by Apple to paint surfaces of controls and has a subtle
    // translucency (10% black on light mode, 25% white on dark mode).  Using
    // this as the card background keeps the look consistent with macOS
    // components without relying on the Material colour scheme.
    final backgroundColor = MacosDynamicColor.resolve(
      MacosColors.controlBackgroundColor,
      context,
    );

    final sidebarBackgroundColor = bbc.bbcSidebarBackground;

    // Use a lighter, macOS‑style separator colour for the card border.  If the
    // current theme is dark, use the dark variant of the separator colour;
    // otherwise use the light variant.  This yields a less prominent border
    // than the default Material divider colour.
    // Resolve a very subtle macOS label colour for the card border.  The
    // quaternaryLabelColor has only 10% opacity and is much lighter than the
    // separator colour, making the border far less prominent.  We resolve
    // it against the current context to pick the appropriate light/dark
    // variant automatically.
    final borderColor = MacosDynamicColor.resolve(
      MacosColors.quaternaryLabelColor,
      context,
    );

    final controlBackgroundColor = Color.alphaBlend(
      MacosDynamicColor.resolve(
        MacosColors.controlColor,
        context,
      ).withValues(alpha: 0.12),
      sidebarBackgroundColor,
    );

    final effectiveBackgroundColor = isControl
        ? controlBackgroundColor
        : backgroundColor;
    final effectiveMargin = isControl
        ? const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 4.0)
        : margin;
    final effectivePadding = isControl
        ? const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0)
        : padding;
    final effectiveBorderRadius = isControl ? 10.0 : borderRadius;
    final effectiveBorderColor = borderColor;

    final hasTitle = title.trim().isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final showHeader = hasTitle || hasSubtitle;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;

        return Container(
          margin: effectiveMargin,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            border: isControl ? null : Border.all(color: effectiveBorderColor),
            boxShadow: isControl ? const [] : bbc.bbcCardShadow,
          ),
          child: Padding(
            padding: effectivePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (showHeader) ...[
                  if (hasTitle) Text(title, style: typography.vizInstruction),
                  if (hasSubtitle) ...[
                    if (hasTitle) const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: AppTheme.cassetteHeaderSubtitleStyle(context),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
                if (hasBoundedHeight && shouldExpand)
                  Expanded(child: child)
                else
                  child,
              ],
            ),
          ),
        );
      },
    );
  }
}
