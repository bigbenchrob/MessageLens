import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';

/// A reusable card container for sidebar cassette widgets.
///
/// This card applies a Mac‑like aesthetic with a light background,
/// subtle border and rounded corners, and a gentle shadow.  Wrap any
/// cassette widget in this card to visually separate it from other
/// components in the sidebar.
class SidebarCassetteCard extends ConsumerWidget {
  final Widget child;

  final String title;
  final String? subtitle;

  /// NEW: Optional section label rendered by the card (not the feature).
  final String? sectionTitle;

  /// NEW: Optional footer/helper text rendered by the card (not the feature).
  final String? footerText;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final bool isControl;
  final bool isNaked;
  final bool shouldExpand;

  const SidebarCassetteCard({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.sectionTitle, // NEW
    this.footerText, // NEW
    // Left padding reduced to 12px to align title with naked dropdown text
    this.padding = const EdgeInsets.only(
      left: 12.0,
      top: 16.0,
      right: 16.0,
      bottom: 16.0,
    ),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    this.borderRadius = 8.0,
    this.isControl = false,
    this.isNaked = false,
    this.shouldExpand = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Naked mode: minimal wrapper with only horizontal margin for edge alignment
    // Vertical padding: small top, matches card margin bottom for proper spacing

    // In the naked mode, we only need spacing - no background, border, shadow,
    //  or other decoration. So a simple Padding widget is the most direct and
    //  efficient choice. Using Container there would work identically, but it
    //   would be unnecessarily heavy since Container checks for and potentially
    //    creates multiple internal widgets (for margin, padding, decoration,
    //     constraints, transforms, etc.) even when you're only using one feature.
    // 7550398a-eb91-4d07-865b-945ce5286379  cf248e04-f47d-4e25-8af9-c83fb4c5a9ad
    if (isNaked) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 12.0,
          right: 12.0,
          top: 4.0,
          bottom: 4.0,
        ),
        child: child,
      );
    }

    final typography = ref.watch(themeTypographyProvider);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    final backgroundColor = colors.cassetteCard(CassetteCard.background);
    final sidebarBackgroundColor = colors.surfaces.contentControl;
    final borderColor = colors.lines.borderSubtle;

    final controlBackgroundColor = Color.alphaBlend(
      colors.surfaces.control.withValues(alpha: 0.12),
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

    final hasTitle = title.trim().isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final hasSectionTitle =
        sectionTitle != null && sectionTitle!.trim().isNotEmpty;
    final hasFooter = footerText != null && footerText!.trim().isNotEmpty;

    final showHeader = hasTitle || hasSubtitle;

    /// Use layout builder to detect bounded height for expansion logic.
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;

        final body = child;

        // If the card is expanding, keep the child flexible inside the available space.
        // But note: sectionTitle/footer belong OUTSIDE the Expanded region.
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (showHeader) ...[
              if (hasTitle) Text(title, style: typography.cassetteCardTitle),
              if (hasSubtitle) ...[
                if (hasTitle) const SizedBox(height: 6),
                Text(subtitle!, style: typography.cassetteCardSubtitle),
              ],
              const SizedBox(height: 22),
            ],

            if (hasSectionTitle) ...[
              Text(sectionTitle!, style: typography.cassetteCardSectionHeader),
              const SizedBox(height: 8),
            ],

            if (hasBoundedHeight && shouldExpand)
              Expanded(child: body)
            else
              body,

            if (hasFooter) ...[
              const SizedBox(height: 12),
              Text(footerText!, style: typography.cassetteCardFooter),
            ],
          ],
        );

        return Container(
          margin: effectiveMargin,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            border: isControl ? null : Border.all(color: borderColor),
            boxShadow: isControl
                ? const []
                : [
                    BoxShadow(
                      color: colors.cassetteCard(CassetteCard.shadow),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Padding(padding: effectivePadding, child: content),
        );
      },
    );
  }
}
