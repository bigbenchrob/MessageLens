// lib/config/theme_colors.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers.dart'
    show platformBrightnessProvider, switchableDarkModeProvider;

part 'theme_colors.g.dart';

/// Immutable light/dark pair.
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
  one,
  two,
  three,
  four,
  five,
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

@riverpod
class ThemeColors extends _$ThemeColors {
  @override
  Brightness build() {
    return _resolveBrightness();
  }

  Color gray(GrayTone tone) => tone.pair.resolve(state);

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
