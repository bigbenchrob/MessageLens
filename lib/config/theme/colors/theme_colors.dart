// lib/config/theme_colors.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers.dart'
    show platformBrightnessProvider, switchableDarkModeProvider;

part 'theme_colors.g.dart';

/// Organized collection of theme color tokens.
/// Each token is defined as an immutable light/dark pair ([ColorPair]).
/// The [ThemeColors] provider resolves tokens based on the current brightness.
/// Usage:
/// final colors = ref.watch(themeColorsProvider);
/// final bg = colors.surfaces.canvas;
/// final gray1 = colors.globals.gray.one;

/// Immutable light/dark pair.
class ColorPair {
  const ColorPair(this.light, this.dark);

  final Color light;
  final Color dark;

  Color resolve(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// ============================================================================
/// Flow: ThemeColors provider
/// -------------------------------
/// 1. Define color tokens as ColorPair pairs (light/dark).
/// 2. Create ThemeColors Riverpod provider that resolves tokens based on
///    current brightness (system or user-selected).
/// 3. Organize tokens into semantic groups (globals, surfaces, content, etc.).
/// 4. Use ThemeColors provider throughout the app for consistent theming.
///
/// Each semantic class is intialized with a reference to ThemeColors (_t),
/// allowing it to resolve individual tokens as needed:
///
///   (1) Call methods like _t.grayOne, _t.brandHighlight(), etc.
///   (2) Access _t.isDark to determine current brightness
///    (3) Use _t.resolvePair() to resolve ColorPair pairs
/// ============================================================================

// ---------------------------------------------------------------------------
// Shared semantic color groups
//
// These groups are intended to be the *main* palette most widgets draw from,
// providing harmony across the app. Only create widget-specific palettes
// (e.g. CassetteCard) when a component truly needs multiple unique tokens.
// ---------------------------------------------------------------------------

/// Global, reusable primitives (grays + brand highlights).
class Globals {
  const Globals(this._t);

  final ThemeColors _t;

  GrayGlobals get gray => GrayGlobals(_t);
  BrandGlobals get brand => BrandGlobals(_t);
}

class GrayGlobals {
  const GrayGlobals(this._t);
  final ThemeColors _t;

  Color get one => _t.grayOne;
  Color get two => _t.grayTwo;
  Color get three => _t.grayThree;
  Color get four => _t.grayFour;
  Color get five => _t.grayFive;
  Color get six => _t.graySix;
}

class BrandGlobals {
  const BrandGlobals(this._t);
  final ThemeColors _t;

  Color get primary => _t.brandHighlight(BrandHighlight.primary);
  Color get secondary => _t.brandHighlight(BrandHighlight.secondary);

  /// A softer accent for background tints / atmosphere (not “actionable”).
  ///
  /// If you later add `BrandHighlight.tertiary`, you can wire this directly.
  Color get tertiary => _t.brandHighlight(BrandHighlight.tertiary);
}

/// Semantic surface fills (backgrounds and control fills).
class Surfaces {
  const Surfaces(this._t);
  final ThemeColors _t;

  Color _r(ColorPair p) => _t.resolvePair(p);

  /// Window/app background.
  Color get canvas => _t.globals.gray.six;

  /// Sidebar / inspector panel background.
  Color get panel => _r(const ColorPair(Color(0xFFF6F7F8), Color(0xFF232627)));

  /// Default surface for grouped content (cards, groups).
  Color get surface =>
      _r(const ColorPair(Color(0xFFFFFFFF), Color(0xFF2A2D2E)));

  /// Slightly elevated surface (popovers, sheets).
  Color get surfaceRaised =>
      _r(const ColorPair(Color(0xFFFFFFFF), Color(0xFF323638)));

  /// Fill for interactive controls (buttons, chips, inputs).
  Color get control =>
      _r(const ColorPair(Color(0xFFF2F3F5), Color(0xFF3A3E40)));

  /// Muted/disabled control fill.
  Color get controlMuted => _t.globals.gray.six;

  /// Hover fill (use over [surface]/[control]).
  Color get hover => _r(const ColorPair(Color(0x0A000000), Color(0x14FFFFFF)));

  /// Pressed fill (use over [surface]/[control]).
  Color get pressed =>
      _r(const ColorPair(Color(0x14000000), Color(0x1FFFFFFF)));

  /// Subtle selected row/tile background.
  ///
  /// Intentionally derived from the primary accent to feel "related" without
  /// competing with foreground selection indicators.
  Color get selected =>
      _t.accents.primary.withValues(alpha: _t.isDark ? 0.22 : 0.12);
}

/// Text + icon content colors.
class ContentColors {
  const ContentColors(this._t);
  final ThemeColors _t;

  Color get textPrimary => _t.globals.gray.one;
  Color get textSecondary => _t.globals.gray.three;
  Color get textTertiary => _t.globals.gray.four;
  Color get textDisabled =>
      _t.globals.gray.five.withValues(alpha: _t.isDark ? 0.65 : 0.7);

  Color get iconPrimary => textPrimary;
  Color get iconSecondary => textSecondary;
  Color get iconDisabled => textDisabled;
}

/// Dividers and borders.
class Lines {
  const Lines(this._t);
  final ThemeColors _t;

  Color _base() => _t.globals.gray.five;

  Color get divider => _base().withValues(alpha: _t.isDark ? 0.55 : 0.6);
  Color get borderSubtle => _base().withValues(alpha: _t.isDark ? 0.40 : 0.45);
  Color get border => _base().withValues(alpha: _t.isDark ? 0.65 : 0.70);
  Color get borderStrong =>
      _t.globals.gray.four.withValues(alpha: _t.isDark ? 0.85 : 0.85);

  /// A "layered" border recipe often useful for dropdowns/popovers.
  BorderLayers get dropdown => BorderLayers(outer: border, inner: borderSubtle);
}

/// Border recipe (outer + inner) for components that want a "layered" outline.
class BorderLayers {
  const BorderLayers({required this.outer, required this.inner});
  final Color outer;
  final Color inner;
}

/// Accent usage (semantic), backed by brand primitives.
class Accents {
  const Accents(this._t);
  final ThemeColors _t;

  Color get primary => _t.globals.brand.primary;
  Color get secondary => _t.globals.brand.secondary;
  Color get tertiary => _t.globals.brand.tertiary;

  /// Focus ring ink (usually primary accent with alpha).
  Color get focusRing => primary.withValues(alpha: _t.isDark ? 0.55 : 0.45);

  /// Foreground selection indicator (e.g. active tab underline).
  Color get selection => primary;
}

/// Shadows and scrims.
class Overlays {
  const Overlays(this._t);
  final ThemeColors _t;

  Color _r(ColorPair p) => _t.resolvePair(p);

  /// Modal background scrim.
  Color get scrim => _r(const ColorPair(Color(0x59000000), Color(0x73000000)));

  /// Generic shadow color (used with blur/spread to create elevation).
  Color get shadow => _r(const ColorPair(Color(0x1F000000), Color(0x33000000)));
}

enum GrayTone {
  one,
  two,
  three,
  four,
  five,
  six;

  static const Map<GrayTone, ColorPair> _palette = {
    GrayTone.one: ColorPair(Color(0xFF1E1F20), Color(0xFFE0E1E1)),
    GrayTone.two: ColorPair(Color(0xFF343638), Color(0xFFDADEE0)),
    GrayTone.three: ColorPair(Color(0xFF5B6062), Color(0xFFC8CDCF)),
    GrayTone.four: ColorPair(Color(0xFF7F8587), Color(0xFFABB0B2)),
    GrayTone.five: ColorPair(Color(0xFFA8AEB0), Color(0xFF424647)),
    GrayTone.six: ColorPair(Color(0xFFE7EAEC), Color(0xFF2E3233)),
  };

  ColorPair get pair => _palette[this]!;
}

/// Brand/accent highlight tokens.
enum BrandHighlight {
  primary,
  secondary,
  tertiary;

  static const Map<BrandHighlight, ColorPair> _palette = {
    BrandHighlight.primary: ColorPair(Color(0xFF007AFF), Color(0xFF0A84FF)),
    BrandHighlight.secondary: ColorPair(Color(0xFF5AC8FA), Color(0xFF64D2FF)),
    // Soft accent (atmosphere / subtle emphasis)
    BrandHighlight.tertiary: ColorPair(Color(0xFF64748B), Color(0xFF94A3B8)),
  };

  ColorPair get pair => _palette[this]!;
}

/// Semantic tokens for cassette card components.
enum CassetteCard {
  background,
  titleText,
  subtitleText,
  divider,
  shadow;

  static const Map<CassetteCard, ColorPair> _palette = {
    CassetteCard.background: ColorPair(Color(0xFFFFFFFF), Color(0xFF2E3233)),
    CassetteCard.titleText: ColorPair(Color(0xFF1E1F20), Color(0xFFE0E1E1)),
    CassetteCard.subtitleText: ColorPair(Color(0xFF7F8587), Color(0xFFABB0B2)),
    CassetteCard.divider: ColorPair(Color(0xFFA8AEB0), Color(0xFF424647)),
    CassetteCard.shadow: ColorPair(Color(0x1F000000), Color(0x33000000)),
  };

  ColorPair get pair => _palette[this]!;
}

@riverpod
class ThemeColors extends _$ThemeColors {
  @override
  Brightness build() {
    return _resolveBrightness();
  }

  Color gray(GrayTone tone) => tone.pair.resolve(state);
  Color brandHighlight(BrandHighlight tone) => tone.pair.resolve(state);
  Color cassetteCard(CassetteCard tone) => tone.pair.resolve(state);

  // Convenience getters for gray tones
  Color get grayOne => gray(GrayTone.one);
  Color get grayTwo => gray(GrayTone.two);
  Color get grayThree => gray(GrayTone.three);
  Color get grayFour => gray(GrayTone.four);
  Color get grayFive => gray(GrayTone.five);
  Color get graySix => gray(GrayTone.six);

  /// Resolve a raw [ColorPair] pair against the current brightness.
  Color resolvePair(ColorPair pair) => pair.resolve(state);

  /// True when the current brightness is dark.
  bool get isDark => state == Brightness.dark;

  // -------------------------------------------------------------------------
  // Shared semantic color groups (preferred API)
  // -------------------------------------------------------------------------

  Globals get globals => Globals(this);
  Surfaces get surfaces => Surfaces(this);
  ContentColors get content => ContentColors(this);
  Lines get lines => Lines(this);
  Accents get accents => Accents(this);
  Overlays get overlays => Overlays(this);

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
