/// custom MacOs based theme for the application.
library config.theme;

import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

export 'widgets/theme_widgets.dart';

/// Centralized theme helpers for the app.
///
/// This file intentionally keeps theme concerns in one place so UI elements can
/// reference shared styles instead of re-inventing them per feature.
///
/// Sections are grouped for future growth:
/// - Colors: dynamic colors and semantic palette accessors
/// - Typography: app-level text styles and helpers
/// - Components: reusable component builders (buttons, cards, etc.)
abstract class AppTheme {
  const AppTheme._();

  // --------------------------------------------------------------------------
  // Colors
  // --------------------------------------------------------------------------

  /// Big Bench colors.
  ///
  /// This is a small, opinionated palette layer on top of `macos_ui` that
  /// provides:
  /// - a numeric grayscale ramp (`bbcOne`..`bbcSix`) that flips meaningfully
  ///   between light and dark mode
  /// - a semantic palette (`bbcHeaderText`, `bbcCardBackground`, etc.) that we
  ///   try to use by default inside the app UI.
  ///
  /// All values are either `CupertinoDynamicColor` from `MacosColors` or are
  /// computed by resolving/blending dynamic colors against the current
  /// `BuildContext`, so they respond to system dark mode automatically.
  static BbcColors bbc(BuildContext context) {
    return BbcColors._(context);
  }

  static Color primaryColor(BuildContext context) {
    return MacosTheme.of(context).primaryColor;
  }

  static Color onPrimaryColor(BuildContext context) {
    // PushButton may adjust its internal foreground based on focus/activation.
    // Treat primary buttons as “always on primary” to keep labels readable.
    return MacosColors.white;
  }

  static Color primaryButtonFillColor(BuildContext context) {
    // Use a resolved color so the fill is stable across focus changes.
    return MacosDynamicColor.resolve(primaryColor(context), context);
  }

  // --------------------------------------------------------------------------
  // Typography
  // --------------------------------------------------------------------------

  static MacosTypography typography(BuildContext context) {
    return MacosTheme.of(context).typography;
  }

  // --------------------------------------------------------------------------
  // Components: Sidebar cassettes
  // --------------------------------------------------------------------------

  static TextStyle cassetteHeaderTitleStyle(BuildContext context) {
    return typography(context).callout.copyWith(
      fontWeight: FontWeight.w500,
      color: MacosColors.tertiaryLabelColor,
    );
  }

  static TextStyle cassetteHeaderSubtitleStyle(BuildContext context) {
    return typography(
      context,
    ).body.copyWith(color: MacosColors.secondaryLabelColor);
  }

  static TextStyle cassetteHeroTitleStyle(BuildContext context) {
    return cassetteHeaderTitleStyle(context);
  }
}

/// A context-bound palette so callers can't forget to resolve dynamic colors.
class BbcColors {
  BbcColors._(this._context);

  final BuildContext _context;

  static const Color _darkControlBackground = Color(0xFF2E3233);
  static const Color _darkDivider = Color(0xFF424647);
  static const Color _darkHighlight = Color(0xFFB98F36);
  static const Color _darkText = Color(0xFFE0E1E1);
  static const Color _black = Color(0xFF000000);
  static const Color _white = Color(0xFFFFFFFF);

  bool get _isDark => MacosTheme.of(_context).brightness.isDark;

  Color _resolve(Color color) {
    return MacosDynamicColor.resolve(color, _context);
  }

  // --------------------------------------------------------------------------
  // Numeric grayscale (bbcOne..bbcSix)
  //
  // Goal: In light mode, bbcOne is darkest and bbcSix is lightest.
  // In dark mode, the ramp flips to keep "one" meaningfully strong.
  // --------------------------------------------------------------------------

  /// Strongest text / darkest gray in light mode; brightest gray in dark mode.
  Color get bbcOne => _isDark ? _darkText : _resolve(MacosColors.labelColor);

  /// Primary body text / secondary-strong.
  Color get bbcTwo =>
      _isDark ? _darkText : _resolve(MacosColors.controlTextColor);

  /// Secondary text.
  Color get bbcThree => _isDark
      ? Color.lerp(_darkText, _black, 0.35)!
      : _resolve(MacosColors.secondaryLabelColor);

  /// Tertiary/disabled-ish text and subtle accents.
  Color get bbcFour => _isDark
      ? Color.lerp(_darkText, _black, 0.55)!
      : _resolve(MacosColors.tertiaryLabelColor);

  /// Hairlines/borders.
  Color get bbcFive =>
      _isDark ? _darkDivider : _resolve(MacosColors.quaternaryLabelColor);

  /// Lightest surface in light mode; deepest surface in dark mode.
  Color get bbcSix => _isDark
      ? _darkControlBackground
      : _resolve(MacosColors.controlBackgroundColor);

  /// Primary sidebar surface.
  ///
  /// Important: this should resolve to the standard macOS sidebar backdrop,
  /// not the app window background. In dark mode, `windowBackgroundColor` can
  /// resolve very light depending on material/elevation, which makes the
  /// sidebar appear white.
  Color get bbcSidebarBackground {
    if (_isDark) {
      return _darkControlBackground;
    }

    // Use the macOS control background dynamic color (sidebar-like surface).
    return _resolve(MacosColors.controlBackgroundColor);
  }

  /// Background tint for the fixed navigation column surface.
  ///
  /// Blends a subtle control tint over the standard sidebar background so
  /// the column reads as a separate surface in both light and dark modes.
  Color get bbcNavigationColumnBackground {
    final base = bbcSidebarBackground;
    final tint = _resolve(MacosColors.controlColor);
    final alpha = _isDark ? 0.18 : 0.08;
    return Color.alphaBlend(tint.withValues(alpha: alpha), base);
  }

  /// Divider color separating the navigation column from the content canvas.
  Color get bbcNavigationColumnDivider {
    if (_isDark) {
      return _darkDivider;
    }
    final divider = _resolve(MacosColors.separatorColor);
    return divider.withValues(alpha: 0.18);
  }

  /// Baseline background for non-sidebar panels.
  ///
  /// This should match the `MacosWindow` background/canvas used by the center
  /// and right panels.
  Color get bbcPanelBackground => _isDark
      ? _darkControlBackground
      : _resolve(MacosTheme.of(_context).canvasColor);

  // --------------------------------------------------------------------------
  // Semantic palette
  // --------------------------------------------------------------------------

  /// Preferred primary accent.
  Color get bbcPrimaryOne => _isDark ? _darkHighlight : _darkHighlight;

  /// Alternate accent for highlights/warnings.
  Color get bbcPrimaryTwo =>
      _isDark ? _darkHighlight : _resolve(MacosColors.systemOrangeColor);

  Color get bbcHeaderText => bbcOne;
  Color get bbcBodyText => bbcTwo;
  Color get bbcSubheadText => bbcThree;
  Color get bbcHintText => bbcFour;

  Color get bbcDivider =>
      _isDark ? _darkDivider : _resolve(MacosColors.separatorColor);
  Color get bbcBorderSubtle => _isDark ? _darkDivider : bbcFive;

  Color get bbcCardBackground => bbcSix;

  /// Foreground color for control chrome rendered on dark control surfaces.
  ///
  /// Some `MacosColors.*LabelColor` values can resolve unexpectedly dark in
  /// certain macOS sidebar/material stacks. This token provides a reliable,
  /// high-contrast foreground for control menus.
  Color get bbcControlText {
    return _isDark ? _darkText : bbcBodyText;
  }

  /// A slightly lifted surface for “control” chrome in dark mode.
  ///
  /// In dark mode, `controlBackgroundColor` can read as near-black in some
  /// sidebar contexts. This token provides a consistent, slightly lifted
  /// surface for top-level controls without stealing focus from content.
  Color get bbcControlSurface {
    if (_isDark) {
      return _darkHighlight;
    }

    final base = bbcSidebarBackground;
    return Color.alphaBlend(
      _resolve(MacosColors.controlColor).withValues(alpha: 0.18),
      base,
    );
  }

  /// Surface used for expandable control panels (e.g. the TopChatMenu list).
  ///
  /// Slightly lighter than `bbcControlSurface` in dark mode so the panel reads
  /// as a distinct element instead of a “black slab”.
  Color get bbcControlPanelSurface {
    if (_isDark) {
      return _darkControlBackground;
    }

    return bbcCardBackgroundTinted;
  }

  /// A slightly tinted surface for nested panels/menus.
  Color get bbcCardBackgroundTinted {
    if (_isDark) {
      return Color.alphaBlend(
        _darkHighlight.withValues(alpha: 0.08),
        _darkControlBackground,
      );
    }

    return Color.alphaBlend(
      _resolve(MacosColors.controlColor).withValues(alpha: 0.10),
      bbcCardBackground,
    );
  }

  /// Shadow optimized for the active brightness.
  ///
  /// Keep it very subtle; macOS dark mode wants less blur/opacity.
  List<BoxShadow> get bbcCardShadow {
    return [
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: _isDark ? 0.20 : 0.12),
        blurRadius: _isDark ? 3.0 : 4.0,
        offset: const Offset(0, 2),
      ),
    ];
  }

  List<Color> get dropdownBorderLayers {
    if (_isDark) {
      return [
        Color.lerp(_darkControlBackground, _black, 0.65)!,
        Color.lerp(_darkControlBackground, _black, 0.35)!,
        Color.lerp(_darkControlBackground, _white, 0.12)!,
        Color.lerp(_darkControlBackground, _black, 0.20)!,
      ];
    }

    final base = _resolve(MacosColors.separatorColor);
    return [
      Color.lerp(base, _white, 0.18)!,
      Color.lerp(base, _white, 0.08)!,
      Color.lerp(base, _black, 0.12)!,
      Color.lerp(base, _black, 0.24)!,
    ];
  }
}
