import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';

/// A full-bleed card for "back to previous state" navigation controls.
///
/// Unlike [SidebarCassetteCard] (content with chrome) or [SidebarInfoCard]
/// (explanatory text with tinted background), this card type is designed for
/// lightweight navigation affordances that need to span the full width of
/// the sidebar — no inset, no shadow, no border, no title/subtitle slots.
///
/// The child widget owns all internal padding, typography, and interaction
/// (hover states, tap targets, etc.). The card only provides:
/// - A subtle tinted background strip to visually separate the control
///   from surrounding cassette content.
/// - Consistent vertical margins to occupy the cassette flow without
///   competing with content cards.
///
/// ## Intended use cases
/// - "Change contact…" back-link after a contact is selected
/// - Future "back to …" navigation controls in other cascades
class SidebarNavigationCard extends ConsumerWidget {
  const SidebarNavigationCard({super.key, required this.child});

  /// The navigation control widget. Owns all internal layout and styling.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    // Subtle tinted strip — creates visual pause between menu and content.
    // Matches the control surface blend used by the child widget so there's
    // no visible seam between child ColoredBox and this outer surface.
    final stripColor = Color.alphaBlend(
      colors.surfaces.control.withValues(alpha: 0.08),
      colors.surfaces.contentControl,
    );

    return ColoredBox(color: stripColor, child: child);
  }
}
