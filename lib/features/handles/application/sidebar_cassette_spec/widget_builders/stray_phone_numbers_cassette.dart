import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../../config/theme/theme.dart';

/// Placeholder cassette for displaying phone numbers that are not matched to
/// any contact in the address book.
class StrayPhoneNumbersCassette extends ConsumerWidget {
  const StrayPhoneNumbersCassette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeColorsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Stray phone numbers',
          style: AppTheme.typography(context).headline.copyWith(
            color: colors.content.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This cassette will display phone numbers from the Messages database that have not been matched to any contact in your address book.',
          style: AppTheme.typography(
            context,
          ).callout.copyWith(color: colors.content.textSecondary),
        ),
        const SizedBox(height: 14),
        Text(
          'Coming soon',
          style: AppTheme.typography(context).body.copyWith(
            color: colors.content.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
