import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

/// Placeholder cassette for the all-messages heatmap view.
class MessagesHeatmapCassette extends StatelessWidget {
  const MessagesHeatmapCassette({super.key});

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(
              CupertinoIcons.chart_bar_alt_fill,
              size: 18,
              color: Color(0xFF0A84FF),
            ),
            const SizedBox(width: 8),
            Text(
              'All messages heatmap',
              style: typography.title3.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'An overview of message volume across all conversations.',
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
                'We’ll show timeline heatmaps and quick filters here.',
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
