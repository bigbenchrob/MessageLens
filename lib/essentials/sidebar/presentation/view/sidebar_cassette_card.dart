import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../view_model/sidebar_cassette_card_view_model.dart';

/// A content container for sidebar cassette widgets.
///
/// ## UI Sweep Changes
///
/// This widget now provides **content layout only**, not visual chrome.
/// Per the design contract:
/// - No card borders or shadows
/// - No distinct background (inherits from SidebarPlane)
/// - Styling comes from tokens and structural wrapper context
///
/// The cassette "card" is now a rhythm/spacing container that handles:
/// - Title and subtitle layout
/// - Section headers and footers
/// - Consistent padding using AppSpacing tokens
/// - Expansion behavior for variable-height content
///
/// Visual hierarchy comes from typography tokens, not card boundaries.
class SidebarCassetteCard extends ConsumerWidget {
  final Widget child;

  final String title;
  final String? subtitle;

  /// Optional section label rendered by the card (not the feature).
  final String? sectionTitle;

  /// Optional footer/helper text rendered by the card (not the feature).
  final String? footerText;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool isControl;
  final bool isNaked;
  final bool shouldExpand;

  /// Layout style controlling horizontal rails.
  /// When non-null, overrides [padding] and [margin] with style-derived values.
  final SidebarCardLayoutStyle? layoutStyle;

  const SidebarCassetteCard({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.sectionTitle,
    this.footerText,
    this.padding = const EdgeInsets.only(
      left: AppSpacing.md,
      top: AppSpacing.md,
      right: AppSpacing.md,
      bottom: AppSpacing.md,
    ),
    this.margin = const EdgeInsets.symmetric(
      vertical: AppSpacing.sm,
      horizontal: AppSpacing.md,
    ),
    this.isControl = false,
    this.isNaked = false,
    this.shouldExpand = false,
    this.layoutStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Naked mode: minimal wrapper with only horizontal margin for edge alignment
    if (isNaked) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: child,
      );
    }

    final typography = ref.watch(themeTypographyProvider);

    final hasTitle = title.trim().isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final hasSectionTitle =
        sectionTitle != null && sectionTitle!.trim().isNotEmpty;
    final hasFooter = footerText != null && footerText!.trim().isNotEmpty;

    final showHeader = hasTitle || hasSubtitle;

    // Compute effective margin/padding from layoutStyle or legacy properties
    final (effectiveMargin, effectivePadding, sectionTitleGap) =
        _computeLayout();

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;

        final body = child;

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (showHeader) ...[
              if (hasTitle) Text(title, style: typography.cassetteCardTitle),
              if (hasSubtitle) ...[
                if (hasTitle) const SizedBox(height: AppSpacing.xs),
                Text(subtitle!, style: typography.cassetteCardSubtitle),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],

            if (hasSectionTitle) ...[
              Text(sectionTitle!, style: typography.cassetteCardSectionHeader),
              SizedBox(height: sectionTitleGap),
            ],

            if (hasBoundedHeight && shouldExpand)
              Expanded(child: body)
            else
              body,

            if (hasFooter) ...[
              const SizedBox(height: AppSpacing.md),
              Text(footerText!, style: typography.cassetteCardFooter),
            ],
          ],
        );

        // No visual chrome: transparent background, no border, no shadow.
        // The SidebarPlane provides the background; this widget provides rhythm.
        return Padding(
          padding: effectiveMargin,
          child: Padding(padding: effectivePadding, child: content),
        );
      },
    );
  }

  /// Computes (margin, padding, sectionTitleGap) based on layoutStyle.
  (EdgeInsets, EdgeInsets, double) _computeLayout() {
    // Layout style takes precedence when specified
    if (layoutStyle != null) {
      return switch (layoutStyle!) {
        SidebarCardLayoutStyle.standard => (
          const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
          const EdgeInsets.all(AppSpacing.md),
          AppSpacing.sm,
        ),
        SidebarCardLayoutStyle.listDense => (
          const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: 0),
          const EdgeInsets.symmetric(horizontal: 12, vertical: AppSpacing.sm),
          AppSpacing.xs,
        ),
        SidebarCardLayoutStyle.controlAligned => (
          const EdgeInsets.symmetric(
            vertical: AppSpacing.xs,
            horizontal: AppSpacing.md,
          ),
          EdgeInsets.zero,
          0.0,
        ),
      };
    }

    // Legacy: isControl overrides
    if (isControl) {
      return (
        const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.sm,
          bottom: AppSpacing.xs,
        ),
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + AppSpacing.xs,
        ),
        AppSpacing.sm,
      );
    }

    // Legacy: use provided margin/padding
    return (margin as EdgeInsets, padding as EdgeInsets, AppSpacing.sm);
  }
}
