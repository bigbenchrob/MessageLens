import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/theme.dart';

/// Placeholder cassette for unmatched phone numbers and emails.
class UnmatchedHandlesCassette extends StatelessWidget {
  const UnmatchedHandlesCassette({super.key});

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;
    final bbc = AppTheme.bbc(context);
    final badgeColor = bbc.bbcPrimaryOne;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bbc.bbcCardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bbc.bbcBorderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 20,
            color: badgeColor,
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
                    color: bbc.bbcSubheadText,
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
