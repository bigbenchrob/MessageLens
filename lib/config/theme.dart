/// custom MacOs based theme for the application.
library config.theme;

import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

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
    return typography(context).title2.copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle cassetteHeaderSubtitleStyle(BuildContext context) {
    return typography(
      context,
    ).body.copyWith(color: MacosColors.secondaryLabelColor);
  }

  static TextStyle cassetteHeroTitleStyle(BuildContext context) {
    return cassetteHeaderTitleStyle(context);
  }

  // --------------------------------------------------------------------------
  // Components: Buttons
  // --------------------------------------------------------------------------

  /// Primary action button used throughout the app.
  ///
  /// Mirrors the style used by the “Choose new contact” button in the contacts
  /// hero cassette: regular control size, padded label, and the app primary
  /// color.
  static Widget primaryButton({
    required BuildContext context,
    required String label,
    required VoidCallback? onPressed,
    ControlSize controlSize = ControlSize.regular,
    EdgeInsetsGeometry padding = const EdgeInsets.only(
      left: 14,
      right: 14,
      top: 7,
      bottom: 9,
    ),
    Widget? leading,
  }) {
    final textStyle = typography(context).body.copyWith(
      color: onPrimaryColor(context),
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );

    final child = leading == null
        ? Text(label, style: textStyle)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: 8),
              Text(label, style: textStyle),
            ],
          );

    return AppPrimaryButton(
      controlSize: controlSize,
      onPressed: onPressed,
      child: DefaultTextStyle.merge(
        style: textStyle,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// A context-bound palette so callers can't forget to resolve dynamic colors.
class BbcColors {
  BbcColors._(this._context);

  final BuildContext _context;

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
  Color get bbcOne => _resolve(MacosColors.labelColor);

  /// Primary body text / secondary-strong.
  Color get bbcTwo => _resolve(MacosColors.controlTextColor);

  /// Secondary text.
  Color get bbcThree => _resolve(MacosColors.secondaryLabelColor);

  /// Tertiary/disabled-ish text and subtle accents.
  Color get bbcFour => _resolve(MacosColors.tertiaryLabelColor);

  /// Hairlines/borders.
  Color get bbcFive => _resolve(MacosColors.quaternaryLabelColor);

  /// Lightest surface in light mode; deepest surface in dark mode.
  Color get bbcSix => _resolve(MacosColors.controlBackgroundColor);

  /// Primary sidebar surface.
  ///
  /// Important: this should resolve to the standard macOS sidebar backdrop,
  /// not the app window background. In dark mode, `windowBackgroundColor` can
  /// resolve very light depending on material/elevation, which makes the
  /// sidebar appear white.
  Color get bbcSidebarBackground {
    // Use the macOS control background dynamic color (sidebar-like surface).
    return _resolve(MacosColors.controlBackgroundColor);
  }

  /// Baseline background for non-sidebar panels.
  ///
  /// This should match the `MacosWindow` background/canvas used by the center
  /// and right panels.
  Color get bbcPanelBackground => _resolve(MacosTheme.of(_context).canvasColor);

  // --------------------------------------------------------------------------
  // Semantic palette
  // --------------------------------------------------------------------------

  /// Preferred primary accent.
  Color get bbcPrimaryOne => _resolve(MacosTheme.of(_context).primaryColor);

  /// Alternate accent for highlights/warnings.
  Color get bbcPrimaryTwo => _resolve(MacosColors.systemOrangeColor);

  Color get bbcHeaderText => bbcOne;
  Color get bbcBodyText => bbcTwo;
  Color get bbcSubheadText => bbcThree;
  Color get bbcHintText => bbcFour;

  Color get bbcDivider => _resolve(MacosColors.separatorColor);
  Color get bbcBorderSubtle => bbcFive;

  Color get bbcCardBackground => bbcSix;

  /// Foreground color for control chrome rendered on dark control surfaces.
  ///
  /// Some `MacosColors.*LabelColor` values can resolve unexpectedly dark in
  /// certain macOS sidebar/material stacks. This token provides a reliable,
  /// high-contrast foreground for control menus.
  Color get bbcControlText {
    final isDark = MacosTheme.of(_context).brightness.isDark;
    return isDark ? _resolve(MacosColors.controlTextColor) : bbcBodyText;
  }

  /// A slightly lifted surface for “control” chrome in dark mode.
  ///
  /// In dark mode, `controlBackgroundColor` can read as near-black in some
  /// sidebar contexts. This token provides a consistent, slightly lifted
  /// surface for top-level controls without stealing focus from content.
  Color get bbcControlSurface {
    final isDark = MacosTheme.of(_context).brightness.isDark;
    final base = bbcSidebarBackground;

    if (!isDark) {
      return base;
    }

    // In dark mode, create a “lifted” control surface by blending a neutral
    // control tint over the window background (not over controlBackgroundColor,
    // which can be nearly black in sidebar contexts).
    return Color.alphaBlend(
      _resolve(MacosColors.controlColor).withValues(alpha: 0.28),
      base,
    );
  }

  /// Surface used for expandable control panels (e.g. the TopChatMenu list).
  ///
  /// Slightly lighter than `bbcControlSurface` in dark mode so the panel reads
  /// as a distinct element instead of a “black slab”.
  Color get bbcControlPanelSurface {
    final isDark = MacosTheme.of(_context).brightness.isDark;

    if (!isDark) {
      return bbcCardBackgroundTinted;
    }

    return Color.alphaBlend(
      _resolve(MacosColors.controlColor).withValues(alpha: 0.16),
      bbcSidebarBackground,
    );
  }

  /// A slightly tinted surface for nested panels/menus.
  Color get bbcCardBackgroundTinted {
    return Color.alphaBlend(
      _resolve(MacosColors.controlColor).withValues(alpha: 0.10),
      bbcCardBackground,
    );
  }

  /// Shadow optimized for the active brightness.
  ///
  /// Keep it very subtle; macOS dark mode wants less blur/opacity.
  List<BoxShadow> get bbcCardShadow {
    final isDark = MacosTheme.of(_context).brightness.isDark;
    return [
      BoxShadow(
        color: (isDark ? const Color(0xFF000000) : const Color(0xFF000000))
            .withValues(alpha: isDark ? 0.20 : 0.12),
        blurRadius: isDark ? 3.0 : 4.0,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

class AppPrimaryButton extends StatefulWidget {
  const AppPrimaryButton({
    required this.child,
    required this.onPressed,
    this.controlSize = ControlSize.regular,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final ControlSize controlSize;

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    final baseColor = AppTheme.primaryButtonFillColor(context);
    final fillColor = !enabled
        ? baseColor.withValues(alpha: 0.45)
        : _isPressed
        ? baseColor.withValues(alpha: 0.82)
        : _isHovered
        ? baseColor.withValues(alpha: 0.92)
        : baseColor;

    final height = switch (widget.controlSize) {
      ControlSize.large => 32.0,
      ControlSize.regular => 34.0,
      ControlSize.small => 24.0,
      ControlSize.mini => 20.0,
    };

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (!enabled) {
          return;
        }
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _isPressed = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: enabled
            ? (_) {
                setState(() {
                  _isPressed = true;
                });
              }
            : null,
        onTapUp: enabled
            ? (_) {
                setState(() {
                  _isPressed = false;
                });
              }
            : null,
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          height: height,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: enabled
                ? const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
