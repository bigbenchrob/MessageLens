import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../../config/theme/theme_typography.dart';

/// Placeholder cassette for unmatched phone numbers and emails.
class UnmatchedHandlesCassette extends ConsumerWidget {
  const UnmatchedHandlesCassette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cassetteCard(CassetteCard.background),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.lines.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 20,
            color: colors.accents.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Coming soon',
                  style: typography.headline.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A filtered list of unmatched handles will appear here.',
                  style: typography.caption1.copyWith(
                    color: colors.content.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
