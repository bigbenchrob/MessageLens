// lib/config/theme_typography.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import './colors/theme_colors.dart';

part 'theme_typography.g.dart';

@riverpod
ThemeTypography themeTypography(ThemeTypographyRef ref) {
  final colors = ref.watch(themeColorsProvider.notifier);
  return ThemeTypography(colors);
}

/// Semantic typography tokens for the app.
/// These styles encode *hierarchy* and *intent*, not just appearance.
class ThemeTypography {
  ThemeTypography(this._colors);

  final ThemeColors _colors;

  // ---------------------------------------------------------------------------
  // Base styles
  // ---------------------------------------------------------------------------

  TextStyle get _base => TextStyle(
    fontFamilyFallback: const ['.SF Pro Text', '.SF Pro Display'],
    color: _colors.content.textPrimary,
    height: 1.25,
  );

  TextStyle get _tabular =>
      _base.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  // ---------------------------------------------------------------------------
  // Sidebar – top control (“Show: Contacts”)
  // ---------------------------------------------------------------------------

  /// “Show:” — control label, not content.
  TextStyle get controlLabel => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: _colors.content.textTertiary,
  );

  /// “Contacts” — selected control value.
  TextStyle get controlValue => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _colors.content.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Sidebar – hero contact card
  // ---------------------------------------------------------------------------

  /// Primary contact name (“Claire”).
  /// Strongest typographic element in the sidebar.
  TextStyle get heroTitle => _base.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: _colors.content.textPrimary,
  );

  /// Secondary contact line (full name).
  TextStyle get heroSubtitle => _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: _colors.content.textSecondary,
  );

  // ---------------------------------------------------------------------------
  // Heatmap / data visualization
  // ---------------------------------------------------------------------------

  /// Instructional copy:
  /// “Click a month to view messages.”
  TextStyle get vizInstruction => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: _colors.content.textTertiary,
  );

  /// Year labels down the left side of the heatmap.
  TextStyle get vizAxisLabel => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: _colors.content.textSecondary,
  );

  /// Summary metadata:
  /// “75,549 Messages · Jan 2014 → Nov 2025”
  TextStyle get vizMeta => _tabular.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: _colors.content.textSecondary,
  );

  // ---------------------------------------------------------------------------
  // General-purpose text
  // ---------------------------------------------------------------------------

  TextStyle get body => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: _colors.content.textPrimary,
  );

  TextStyle get caption => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: _colors.content.textTertiary,
  );
}
