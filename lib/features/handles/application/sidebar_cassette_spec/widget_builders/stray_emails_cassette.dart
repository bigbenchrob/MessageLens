import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../../config/theme/theme_typography.dart';

/// Placeholder cassette for displaying email addresses that are not matched to
/// any contact in the address book.
class StrayEmailsCassette extends ConsumerWidget {
  const StrayEmailsCassette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Stray emails',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This cassette will display email addresses from the Messages database that have not been matched to any contact in your address book.',
          style: typography.callout.copyWith(
            color: colors.content.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Coming soon',
          style: typography.body.copyWith(
            color: colors.content.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
