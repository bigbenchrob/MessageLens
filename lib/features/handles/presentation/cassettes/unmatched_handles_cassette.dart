import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

/// Placeholder cassette for unmatched phone numbers and emails.
class UnmatchedHandlesCassette extends StatelessWidget {
  const UnmatchedHandlesCassette({super.key});

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;
    final badgeColor = MacosTheme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 18,
              color: badgeColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Unmatched phone numbers & emails',
              style: typography.title3.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Link stray handles to contacts to keep conversations organized.',
          style: typography.caption1.copyWith(
            color: MacosColors.secondaryLabelColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MacosDynamicColor.resolve(
              MacosColors.controlBackgroundColor,
              context,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: MacosDynamicColor.resolve(
                MacosColors.quaternaryLabelColor,
                context,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: MacosColors.secondaryLabelColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
