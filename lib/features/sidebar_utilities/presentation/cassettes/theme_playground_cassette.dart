import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';

class ThemePlaygroundCassette extends ConsumerWidget {
  const ThemePlaygroundCassette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final isDark = colors.isDark;

    Widget swatch({required String label, required Color color}) {
      return Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.lines.borderSubtle),
            ),
            child: const SizedBox(width: 44, height: 20),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isDark ? 'Dark mode' : 'Light mode',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This cassette is a theme playground. Values should update live when switching system appearance.',
          style: typography.callout.copyWith(
            color: colors.content.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        // Surfaces
        swatch(label: 'surfaces.panel', color: colors.surfaces.panel),
        const SizedBox(height: 8),
        swatch(label: 'surfaces.surface', color: colors.surfaces.surface),
        const SizedBox(height: 8),
        swatch(label: 'surfaces.control', color: colors.surfaces.control),
        const SizedBox(height: 8),
        swatch(
          label: 'surfaces.surfaceRaised',
          color: colors.surfaces.surfaceRaised,
        ),
        const SizedBox(height: 12),
        // Text
        swatch(label: 'content.textPrimary', color: colors.content.textPrimary),
        const SizedBox(height: 8),
        swatch(
          label: 'content.textSecondary',
          color: colors.content.textSecondary,
        ),
        const SizedBox(height: 8),
        swatch(
          label: 'content.textTertiary',
          color: colors.content.textTertiary,
        ),
        const SizedBox(height: 14),
        Text(
          'Header text sample',
          style: typography.title2.copyWith(
            color: colors.content.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Body text sample — The quick brown fox jumps over the lazy dog.',
          style: typography.body.copyWith(color: colors.content.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'Subhead text sample — Secondary labels should remain readable.',
          style: typography.callout.copyWith(
            color: colors.content.textSecondary,
          ),
        ),
      ],
    );
  }
}
