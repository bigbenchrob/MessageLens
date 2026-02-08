import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';

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
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    this.padding = const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
    this.borderRadius = 10.0,
    this.showBorder = false,
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
  final double borderRadius;

  /// Default false: border is optional; the tint usually does enough.
  final bool showBorder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    final bg = colors.infoCard(InfoCard.background);
    final border = colors.infoCard(InfoCard.border);

    final hasTitle = title != null && title!.trim().isNotEmpty;
    final hasFootnote = footnote != null && footnote!.trim().isNotEmpty;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder ? Border.all(color: border) : null,
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasTitle) ...[
              Text(title!, style: typography.infoCardTitle),
              const SizedBox(height: 8),
            ],
            RichText(
              text: TextSpan(style: typography.infoCardBody, children: [body]),
            ),
            if (hasFootnote) ...[
              const SizedBox(height: 10),
              Text(footnote!, style: typography.infoCardFootnote),
            ],
            if (action != null) ...[const SizedBox(height: 10), action!],
          ],
        ),
      ),
    );
  }
}
