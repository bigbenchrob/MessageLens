import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme.dart';

class ThemePlaygroundCassette extends StatelessWidget {
  const ThemePlaygroundCassette({super.key});

  @override
  Widget build(BuildContext context) {
    final bbc = AppTheme.bbc(context);
    final isDark = MacosTheme.of(context).brightness.isDark;

    Widget swatch({required String label, required Color color}) {
      return Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: MacosTheme.of(context).typography.caption1.copyWith(
                color: bbc.bbcSubheadText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: bbc.bbcBorderSubtle),
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
          style: MacosTheme.of(context).typography.headline.copyWith(
            color: bbc.bbcHeaderText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This cassette is a theme playground. Values should update live when switching system appearance.',
          style: MacosTheme.of(
            context,
          ).typography.callout.copyWith(color: bbc.bbcSubheadText),
        ),
        const SizedBox(height: 14),
        // Surfaces
        swatch(label: 'bbcSidebarBackground', color: bbc.bbcSidebarBackground),
        const SizedBox(height: 8),
        swatch(label: 'bbcCardBackground', color: bbc.bbcCardBackground),
        const SizedBox(height: 8),
        swatch(label: 'bbcControlSurface', color: bbc.bbcControlSurface),
        const SizedBox(height: 8),
        swatch(
          label: 'bbcControlPanelSurface',
          color: bbc.bbcControlPanelSurface,
        ),
        const SizedBox(height: 12),
        // Text
        swatch(label: 'bbcHeaderText', color: bbc.bbcHeaderText),
        const SizedBox(height: 8),
        swatch(label: 'bbcBodyText', color: bbc.bbcBodyText),
        const SizedBox(height: 8),
        swatch(label: 'bbcControlText', color: bbc.bbcControlText),
        const SizedBox(height: 14),
        Text(
          'Header text sample',
          style: MacosTheme.of(context).typography.title2.copyWith(
            color: bbc.bbcHeaderText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Body text sample — The quick brown fox jumps over the lazy dog.',
          style: MacosTheme.of(
            context,
          ).typography.body.copyWith(color: bbc.bbcBodyText),
        ),
        const SizedBox(height: 6),
        Text(
          'Subhead text sample — Secondary labels should remain readable.',
          style: MacosTheme.of(
            context,
          ).typography.callout.copyWith(color: bbc.bbcSubheadText),
        ),
      ],
    );
  }
}
