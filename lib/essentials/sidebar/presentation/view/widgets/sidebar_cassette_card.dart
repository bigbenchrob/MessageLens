import 'package:flutter/material.dart';
// Pull in macOS‑specific colors for a more subtle border.
import 'package:macos_ui/macos_ui.dart';

/// A reusable card container for sidebar cassette widgets.
///
/// This card applies a Mac‑like aesthetic with a light background,
/// subtle border and rounded corners, and a gentle shadow.  Wrap any
/// cassette widget in this card to visually separate it from other
/// components in the sidebar.
class SidebarCassetteCard extends StatelessWidget {
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

  const SidebarCassetteCard({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve a macOS control colour for the card background.  The control
    // colour is used by Apple to paint surfaces of controls and has a subtle
    // translucency (10% black on light mode, 25% white on dark mode).  Using
    // this as the card background keeps the look consistent with macOS
    // components without relying on the Material colour scheme.
    final backgroundColor = MacosDynamicColor.resolve(
      MacosColors.controlBackgroundColor,
      context,
    );

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

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000), // subtle shadow
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: MacosTheme.of(
                context,
              ).typography.title2.copyWith(fontWeight: FontWeight.w700),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: MacosTheme.of(context).typography.body.copyWith(
                  color: MacosColors.secondaryLabelColor,
                ),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
