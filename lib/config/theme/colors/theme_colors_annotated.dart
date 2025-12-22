// lib/config/theme_colors.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers.dart'
    show platformBrightnessProvider, switchableDarkModeProvider;

part 'theme_colors_annotated.g.dart';

// =============================================================================
// Theme color tokens (semantic guidance)
//
// Goal: keep widget code semantic and consistent.
// Prefer to reference colors by *role* rather than picking ad-hoc hex values.
//
// Mental model (back → front):
//   canvas → panel → surface → control → content
//
// - canvas: window/app background; the “air” everything sits in
// - panel: large app regions (sidebar, inspector, panes)
// - surface: grouped content inside panels (cards, groups, sections)
// - control: interactive elements on surfaces (buttons, inputs)
// - content: text/icons/data drawn on top
//
// Grayscale intent:
// - GrayTone.one:   primary ink (titles/body text, primary icons)
// - GrayTone.two:   dense secondary ink (optional; data-heavy UIs)
// - GrayTone.three: secondary ink (labels, metadata, supporting copy)
// - GrayTone.four:  tertiary/hint ink (hints, footnotes, de-emphasis)
// - GrayTone.five:  lines/chrome (dividers, borders, hairlines)
// - GrayTone.six:   base material (backgrounds, panels, muted fills)
//
// Accents intent:
// - BrandHighlight.primary:   actionable (menus, selection, focus rings, links)
// - BrandHighlight.secondary: supporting (progress, sub-selection, contextual)
// =============================================================================

/// Immutable light/dark pair.
///
/// Define tokens as a pair, then resolve them based on current brightness.
/// This keeps “what color means” separate from “is the system in dark mode?”.

class BBColor {
  const BBColor(this.light, this.dark);

  final Color light;
  final Color dark;

  Color resolve(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// Grayscale tokens we previously called bbcOne..bbcSix.
///
/// Extending the enum keeps related tokens grouped and lets us expose helpers.
enum GrayTone {
  /// Primary ink. Use for main text and primary icons.
  one,

  /// Dense secondary ink (optional). Use sparingly for data-heavy UIs.
  two,

  /// Secondary ink. Use for labels, metadata, and supporting text.
  three,

  /// Tertiary/hint ink. Use for hints, footnotes, and de-emphasized text.
  four,

  /// Lines & chrome. Use for dividers/borders (not text).
  five,

  /// Base material. Use for backgrounds/panels (not text).
  six;

  static const Map<GrayTone, BBColor> _palette = {
    GrayTone.one: BBColor(Color(0xFF1E1F20), Color(0xFFE0E1E1)),
    GrayTone.two: BBColor(Color(0xFF343638), Color(0xFFDADEE0)),
    GrayTone.three: BBColor(Color(0xFF5B6062), Color(0xFFC8CDCF)),
    GrayTone.four: BBColor(Color(0xFF7F8587), Color(0xFFABB0B2)),
    GrayTone.five: BBColor(Color(0xFFA8AEB0), Color(0xFF424647)),
    GrayTone.six: BBColor(Color(0xFFE7EAEC), Color(0xFF2E3233)),
  };

  BBColor get pair => _palette[this]!;
}

/// Brand/accent highlight tokens.
enum BrandHighlight {
  /// Actionable accent (menus, selection, focus ring, links).
  primary,

  /// Supporting accent (progress, contextual emphasis).
  secondary;

  static const Map<BrandHighlight, BBColor> _palette = {
    BrandHighlight.primary: BBColor(Color(0xFF007AFF), Color(0xFF0A84FF)),
    BrandHighlight.secondary: BBColor(Color(0xFF5AC8FA), Color(0xFF64D2FF)),
  };

  BBColor get pair => _palette[this]!;
}

/// Semantic tokens for cassette card components.
enum CassetteCard {
  /// Card background surface.
  background,

  /// Primary text for titles.
  titleText,

  /// Secondary text for subtitles/metadata.
  subtitleText,

  /// Divider/border inside the card.
  divider,

  /// Shadow ink for elevation.
  shadow;

  static const Map<CassetteCard, BBColor> _palette = {
    CassetteCard.background: BBColor(Color(0xFFFFFFFF), Color(0xFF2E3233)),
    CassetteCard.titleText: BBColor(Color(0xFF1E1F20), Color(0xFFE0E1E1)),
    CassetteCard.subtitleText: BBColor(Color(0xFF7F8587), Color(0xFFABB0B2)),
    CassetteCard.divider: BBColor(Color(0xFFA8AEB0), Color(0xFF424647)),
    CassetteCard.shadow: BBColor(Color(0x1F000000), Color(0x33000000)),
  };

  BBColor get pair => _palette[this]!;
}

@riverpod
class ThemeColors extends _$ThemeColors {
  /// Riverpod Notifier that:
  /// - tracks the effective [Brightness] (system vs user override), and
  /// - resolves all color tokens against that brightness.
  ///
  /// Typical use:
  /// ```dart
  /// // In build():
  /// final theme = ref.watch(themeColorsProvider);
  /// // Elsewhere (or after watching once):
  /// final colors = ref.read(themeColorsProvider.notifier);
  /// final bg = colors.cassetteCard(CassetteCard.background);
  /// ```
  ///
  /// Note: If you build a more hierarchical API later (e.g. `colors.surfaces.panel`),
  /// keep this notifier as the single source of truth for “what mode are we in?”

  @override
  Brightness build() {
    return _resolveBrightness();
  }

  /// Resolve a gray token to a concrete [Color] for the current brightness.
  Color gray(GrayTone tone) => tone.pair.resolve(state);

  /// Resolve a brand highlight token (accent) for the current brightness.
  Color brandHighlight(BrandHighlight tone) => tone.pair.resolve(state);

  /// Resolve a CassetteCard component token for the current brightness.
  Color cassetteCard(CassetteCard tone) => tone.pair.resolve(state);

  // Convenience getters for gray tones
  Color get grayOne => gray(GrayTone.one);
  Color get grayTwo => gray(GrayTone.two);
  Color get grayThree => gray(GrayTone.three);
  Color get grayFour => gray(GrayTone.four);
  Color get grayFive => gray(GrayTone.five);
  Color get graySix => gray(GrayTone.six);

  Brightness _resolveBrightness() {
    if (ref.exists(switchableDarkModeProvider)) {
      final themeMode = ref.watch(switchableDarkModeProvider);
      if (themeMode == ThemeMode.dark) {
        return Brightness.dark;
      }
      if (themeMode == ThemeMode.light) {
        return Brightness.light;
      }
      // fall through to system below when ThemeMode.system
    }

    return ref.watch(platformBrightnessProvider);
  }
}
