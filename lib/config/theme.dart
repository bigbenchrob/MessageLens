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
