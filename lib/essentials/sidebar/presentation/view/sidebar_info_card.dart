import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';

/// A “soft” informational card for explanatory text.
///
/// Intent:
/// - Lives in the cassette flow (so it *is* a card)
/// - Lighter than SidebarCassetteCard (no shadow, subtle tint)
/// - Optional title + body + footnote
/// - Optional [action] widget rendered below body as a footnote-action
///   (mutually exclusive with [footnote])
class SidebarInfoCard extends ConsumerWidget {
  const SidebarInfoCard({
    super.key,
    this.title,
    required this.body,
    this.footnote,
    this.action,
    this.margin = const EdgeInsets.symmetric(
      vertical: AppSpacing.sm,
      horizontal: AppSpacing.md,
    ),
    this.padding = const EdgeInsets.all(AppSpacing.md),
  }) : assert(
         footnote == null || action == null,
         'SidebarInfoCard cannot have both a footnote and an action.',
       );

  final String? title;
  final InlineSpan body;
  final String? footnote;

  /// Optional escape-hatch action rendered at the bottom of the card.
  ///
  /// Reads as a footnote-action — muted, lightweight, no divider.
  /// Mutually exclusive with [footnote].
  final Widget? action;

  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    final hasTitle = title != null && title!.trim().isNotEmpty;
    final hasFootnote = footnote != null && footnote!.trim().isNotEmpty;

    // No visual chrome: transparent background, no border.
    // The SidebarPlane provides the background.
    return Padding(
      padding: margin,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasTitle) ...[
              Text(title!, style: typography.infoCardTitle),
              const SizedBox(height: AppSpacing.sm),
            ],
            RichText(
              text: TextSpan(style: typography.infoCardBody, children: [body]),
            ),
            if (hasFootnote) ...[
              const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
              Text(footnote!, style: typography.infoCardFootnote),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
