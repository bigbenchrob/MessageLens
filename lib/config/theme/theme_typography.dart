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
  /// Strongest typographic element in the sidebar – serves as a header
  /// for the chat and message data below.
  TextStyle get heroTitle => _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: _colors.content.textPrimary,
  );

  /// Secondary contact line (auto-generated name when different from display name).
  /// De-emphasized to allow title to dominate.
  TextStyle get heroSubtitle => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: _colors.content.textTertiary,
  );

  /// Metadata line below hero card title (message counts, date range).
  /// Lowest emphasis in the hero card hierarchy.
  TextStyle get heroMeta => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: _colors.content.textTertiary,
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
    color: _colors.content.textTertiary,
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

  // ---------------------------------------------------------------------------
  // Contact picker
  // ---------------------------------------------------------------------------

  /// Initial-letter badge inside contact rows (22 px circle).
  /// Neutral gray, matching the badge background.
  TextStyle get contactBadgeInitial => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: _colors.content.textTertiary,
    height: 1,
  );

  /// Section label above picker groups (e.g., "RECENTS").
  /// Uppercase, tracked-out, very low contrast — whispers "section label".
  TextStyle get pickerSectionLabel => _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: _colors.content.textTertiary.withValues(alpha: 0.6),
  );

  // ---------------------------------------------------------------------------
  // Cassette card typography
  // ---------------------------------------------------------------------------
  // Hierarchy (highest to lowest emphasis):
  // 1. cassetteCardTitle – card title (e.g., "Short Names")
  // 2. cassetteCardSectionHeader – section header (e.g., "Display format")
  // 3. cassetteCardSubtitle – card description text
  // 4. cassetteCardFooter – footer/helper text

  /// Card title – heaviest element in the cassette card.
  /// Example: "Short Names"
  TextStyle get cassetteCardTitle => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: _colors.content.textPrimary,
  );

  /// Card subtitle/description – secondary to title, provides context.
  /// Example: "How contact names appear throughout the app"
  TextStyle get cassetteCardSubtitle => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: _colors.content.textTertiary,
  );

  /// Section header – defines scope of options beneath it.
  /// Must visually dominate the options, but be subordinate to card title.
  /// Example: "Display format"
  TextStyle get cassetteCardSectionHeader => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: _colors.content.textSecondary,
  );

  /// Footer text – lowest emphasis, explanatory.
  /// Example: "Nicknames override imported contact names..."
  TextStyle get cassetteCardFooter => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: _colors.content.textTertiary,
  );

  // ---------------------------------------------------------------------------
  // Info card typography (explanatory copy inside the cassette flow)
  // ---------------------------------------------------------------------------

  /// Optional heading line inside an info card.
  /// Example: “Stray emails”
  TextStyle get infoCardTitle => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: _colors.infoCard(InfoCard.textPrimary),
  );

  /// Main explanatory body copy inside info cards.
  TextStyle get infoCardBody => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: _colors.infoCard(InfoCard.textSecondary),
  );

  /// Lowest-emphasis informational copy.
  /// Example: “Coming soon”
  TextStyle get infoCardFootnote => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    height: 1.25,
    color: _colors.infoCard(InfoCard.textTertiary),
  );

  /// Terminology emphasis for app-specific terms inside info text.
  /// Use sparingly (terms of art only).
  TextStyle get infoCardTerm => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.35,
    color: _colors.infoCard(InfoCard.termInk),
  );

  // ---------------------------------------------------------------------------
  // Option list typography (radio buttons, toggles, menu choices)
  // ---------------------------------------------------------------------------
  // Used for vertical lists of selectable options. Reusable across cassette
  // cards, settings panels, and anywhere radio/toggle groups appear.
  //
  // Hierarchy:
  // - Selected option: emphasized, stable, obvious at a glance
  // - Unselected options: readable but visually quieter
  // - Helper text: smallest, lowest contrast

  /// Selected option label – emphasized via weight and color.
  /// Should feel "settled and stable" per guidelines.
  TextStyle get optionListLabelSelected => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: _colors.content.textPrimary,
  );

  /// Unselected option label – recedes via lighter weight and reduced contrast.
  /// Remains readable but doesn't compete for attention.
  TextStyle get optionListLabelUnselected => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: _colors.content.textSecondary,
  );

  /// Per-option helper text – explains behavior, lowest emphasis.
  /// Example: "Uses a custom name you set per contact"
  TextStyle get optionListHelper => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: _colors.content.textTertiary,
  );
}
