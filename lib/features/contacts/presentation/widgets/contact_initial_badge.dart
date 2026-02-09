import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';

/// Muted initial-letter badge for contact rows.
///
/// Renders a neutral circular badge with the first letter of the contact's
/// display name. Gives each row a visual anchor without being loud.
///
/// Uses [ThemeColors.contactBadge] for background/foreground colors and
/// [ThemeTypography.contactBadgeInitial] for the letter style.
class ContactInitialBadge extends ConsumerWidget {
  const ContactInitialBadge({
    super.key,
    required this.displayName,
    this.size = 22.0,
  });

  /// The contact's display name. The first character is extracted and
  /// uppercased for the badge. Falls back to '?' if empty.
  final String displayName;

  /// Diameter of the badge circle. Defaults to 22px (≈ cap-height × 1.6).
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.contactBadge.background,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(initial, style: typography.contactBadgeInitial),
        ),
      ),
    );
  }
}
