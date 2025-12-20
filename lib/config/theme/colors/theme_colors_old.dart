// lib/config/theme_colors.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers.dart'
    show platformBrightnessProvider, switchableDarkModeProvider;

part 'theme_colors_old.g.dart';

/// Immutable light/dark pair.
class BBColor {
  const BBColor(this.light, this.dark);

  final Color light;
  final Color dark;

  Color resolve(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// Root object returned by [themeColorsProvider].
///
/// Usage:
///   final colors = ref.watch(themeColorsProvider);
///   final bg = colors.cassetteCard.background;
///   final gray1 = colors.globals.gray.one;
class BBThemeColors {
  BBThemeColors(this.brightness)
    : globals = BBGlobals(brightness),
      cassetteCard = BBCassetteCardColors(brightness);

  final Brightness brightness;

  final BBGlobals globals;
  final BBCassetteCardColors cassetteCard;

  Color get grayOne => globals.gray.one;
  Color get grayTwo => globals.gray.two;
  Color get grayThree => globals.gray.three;
  Color get grayFour => globals.gray.four;
  Color get grayFive => globals.gray.five;
  Color get graySix => globals.gray.six;
}

/// Group: globally-defined tokens intended for reuse anywhere.
class BBGlobals {
  BBGlobals(this._b) : gray = BBGrayGlobals(_b), brand = BBBrandGlobals(_b);

  // ignore: unused_field
  final Brightness _b;

  final BBGrayGlobals gray;
  final BBBrandGlobals brand;
}

/// Global grays (formerly bbcOne..bbcSix).
/// These are the canonical definitions of the gray ramp.
// gray.one    → primary text
// gray.two    → secondary text
// gray.three  → tertiary text
// gray.four   → disabled / hint text
// gray.five   → dividers / outlines
// gray.six    → surfaces / backgrounds
class BBGrayGlobals {
  const BBGrayGlobals(this._b);

  final Brightness _b;
  Color _r(BBColor p) => p.resolve(_b);

  // Keep these as *the* canonical definitions.
  static const _onePair = BBColor(Color(0xFF1E1F20), Color(0xFFE0E1E1));
  static const _twoPair = BBColor(Color(0xFF343638), Color(0xFFDADEE0));
  static const _threePair = BBColor(Color(0xFF5B6062), Color(0xFFC8CDCF));
  static const _fourPair = BBColor(Color(0xFF7F8587), Color(0xFFABB0B2));
  static const _fivePair = BBColor(Color(0xFFA8AEB0), Color(0xFF424647));
  static const _sixPair = BBColor(Color(0xFFE7EAEC), Color(0xFF2E3233));

  Color get one => _r(_onePair);
  Color get two => _r(_twoPair);
  Color get three => _r(_threePair);
  Color get four => _r(_fourPair);
  Color get five => _r(_fivePair);
  Color get six => _r(_sixPair);
}

/// Global brand/accent highlight tokens.
class BBBrandGlobals {
  const BBBrandGlobals(this._b);

  final Brightness _b;
  Color _r(BBColor p) => p.resolve(_b);

  static const _primaryPair = BBColor(
    Color(0xFF2563EB), // light
    Color(0xFF60A5FA), // dark
  );
  static const _secondaryPair = BBColor(
    Color(0xFF0EA5A4), // light
    Color(0xFF5EEAD4), // dark
  );

  static const _tertiaryPair = BBColor(
    Color(0xFF64748B), // light
    Color(0xFF94A3B8), // dark
  );
  Color get primary => _r(_primaryPair);
  Color get secondary => _r(_secondaryPair);
  Color get tertiary => _r(_tertiaryPair);
}

/// Group: semantic colors for the CassetteCard component.
class BBCassetteCardColors {
  BBCassetteCardColors(this._b)
    : _globals = BBGlobals(_b); // ok to construct; inexpensive + immutable

  final Brightness _b;
  final BBGlobals _globals;

  Color _r(BBColor p) => p.resolve(_b);

  // If you want cassette card tokens to reuse globals, do it here.
  // This keeps single-source-of-truth hex values in BBGlobals.
  Color get background => _r(_backgroundPair);
  Color get titleText => _globals.gray.one; // reuse global canonical gray
  Color get subtitleText => _globals.gray.four;
  Color get divider => _globals.gray.five;
  Color get shadow => _r(_shadowPair);

  // Canonical definitions for cassette card-only values.
  static const _backgroundPair = BBColor(Color(0xFFFFFFFF), Color(0xFF2E3233));
  static const _shadowPair = BBColor(Color(0x1F000000), Color(0x33000000));
}

@riverpod
BBThemeColors themeColors(Ref ref) {
  Brightness resolveBrightness() {
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

  return BBThemeColors(resolveBrightness());
}
