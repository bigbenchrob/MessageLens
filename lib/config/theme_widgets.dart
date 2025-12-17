import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

import 'theme.dart';

typedef AppDropdownItemBuilder<T> =
    Widget Function(BuildContext context, T value, {required bool isSelected});

/// Catalog of reusable widgets that adhere to the shared app theme.
abstract class AppThemeWidgets {
  const AppThemeWidgets._();

  /// Shared dropdown menu widget used throughout the app.
  static Widget dropdownMenu<T>({
    required List<T> options,
    required T selectedOption,
    required ValueChanged<T> onSelected,
    required String Function(T value) optionLabelBuilder,
    String? leadingLabel,
    AppDropdownItemBuilder<T>? itemBuilder,
    bool Function(T a, T b)? equals,
    EdgeInsetsGeometry outerPadding = const EdgeInsets.symmetric(vertical: 2.0),
    EdgeInsetsGeometry panelMargin = const EdgeInsets.only(top: 6.0),
    EdgeInsetsGeometry triggerPadding = const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 10.0,
    ),
    EdgeInsetsGeometry itemPadding = const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 10.0,
    ),
    BorderRadius triggerBorderRadius = const BorderRadius.all(
      Radius.circular(8.0),
    ),
    BorderRadius panelBorderRadius = const BorderRadius.all(
      Radius.circular(10.0),
    ),
    Duration animationDuration = const Duration(milliseconds: 140),
    Curve animationCurve = Curves.easeOut,
    bool expandToWidth = true,
    bool showDividers = true,
    bool showSelectionCheckmark = true,
    double trailingIconSize = 14,
    IconData closedIcon = CupertinoIcons.chevron_down,
    IconData openIcon = CupertinoIcons.chevron_up,
    ValueChanged<bool>? onMenuVisibilityChanged,
  }) {
    return _AppDropdownMenu<T>(
      options: options,
      selectedOption: selectedOption,
      onSelected: onSelected,
      optionLabelBuilder: optionLabelBuilder,
      leadingLabel: leadingLabel,
      itemBuilder: itemBuilder,
      equals: equals,
      outerPadding: outerPadding,
      panelMargin: panelMargin,
      triggerPadding: triggerPadding,
      itemPadding: itemPadding,
      triggerBorderRadius: triggerBorderRadius,
      panelBorderRadius: panelBorderRadius,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      expandToWidth: expandToWidth,
      showDividers: showDividers,
      showSelectionCheckmark: showSelectionCheckmark,
      trailingIconSize: trailingIconSize,
      closedIcon: closedIcon,
      openIcon: openIcon,
      onMenuVisibilityChanged: onMenuVisibilityChanged,
    );
  }

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
    final textStyle = AppTheme.typography(context).body.copyWith(
      color: AppTheme.onPrimaryColor(context),
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

class _DropdownPanelDecoration extends StatelessWidget {
  const _DropdownPanelDecoration({
    required this.child,
    required this.borderRadius,
    required this.backgroundColor,
    required this.borderLayers,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final List<Color> borderLayers;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CustomPaint(
        painter: _DropdownBorderPainter(
          borderRadius: borderRadius,
          colors: borderLayers,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: backgroundColor),
          child: child,
        ),
      ),
    );
  }
}

class _DropdownBorderPainter extends CustomPainter {
  const _DropdownBorderPainter({
    required this.borderRadius,
    required this.colors,
  });

  final BorderRadius borderRadius;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) {
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var index = 0; index < colors.length; index++) {
      final inset = index.toDouble();
      final offset = inset + 0.5;
      if (size.width <= offset * 2 || size.height <= offset * 2) {
        break;
      }

      paint.color = colors[index];

      final rect = Offset(offset, offset) &
          Size(size.width - offset * 2, size.height - offset * 2);
      final rrect = _insetBorderRadius(borderRadius, offset).toRRect(rect);

      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DropdownBorderPainter oldDelegate) {
    if (oldDelegate.borderRadius != borderRadius) {
      return true;
    }

    if (oldDelegate.colors.length != colors.length) {
      return true;
    }

    for (var i = 0; i < colors.length; i++) {
      if (oldDelegate.colors[i] != colors[i]) {
        return true;
      }
    }

    return false;
  }
}

BorderRadius _insetBorderRadius(BorderRadius radius, double inset) {
  if (inset == 0) {
    return radius;
  }

  Radius shrink(Radius original) {
    if (original == Radius.zero) {
      return Radius.zero;
    }
    final double x = math.max(0, original.x - inset);
    final double y = math.max(0, original.y - inset);
    return Radius.elliptical(x, y);
  }

  return BorderRadius.only(
    topLeft: shrink(radius.topLeft),
    topRight: shrink(radius.topRight),
    bottomLeft: shrink(radius.bottomLeft),
    bottomRight: shrink(radius.bottomRight),
  );
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

class _AppDropdownMenu<T> extends StatefulWidget {
  const _AppDropdownMenu({
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    required this.optionLabelBuilder,
    this.leadingLabel,
    this.itemBuilder,
    this.equals,
    required this.outerPadding,
    required this.panelMargin,
    required this.triggerPadding,
    required this.itemPadding,
    required this.triggerBorderRadius,
    required this.panelBorderRadius,
    required this.animationDuration,
    required this.animationCurve,
    required this.expandToWidth,
    required this.showDividers,
    required this.showSelectionCheckmark,
    required this.trailingIconSize,
    required this.closedIcon,
    required this.openIcon,
    this.onMenuVisibilityChanged,
  }) : assert(
         options.length > 0,
         'App dropdown menu requires at least one option.',
       );

  final List<T> options;
  final T selectedOption;
  final ValueChanged<T> onSelected;
  final String Function(T value) optionLabelBuilder;
  final String? leadingLabel;
  final AppDropdownItemBuilder<T>? itemBuilder;
  final bool Function(T a, T b)? equals;
  final EdgeInsetsGeometry outerPadding;
  final EdgeInsetsGeometry panelMargin;
  final EdgeInsetsGeometry triggerPadding;
  final EdgeInsetsGeometry itemPadding;
  final BorderRadius triggerBorderRadius;
  final BorderRadius panelBorderRadius;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool expandToWidth;
  final bool showDividers;
  final bool showSelectionCheckmark;
  final double trailingIconSize;
  final IconData closedIcon;
  final IconData openIcon;
  final ValueChanged<bool>? onMenuVisibilityChanged;

  @override
  State<_AppDropdownMenu<T>> createState() => _AppDropdownMenuState<T>();
}

class _AppDropdownMenuState<T> extends State<_AppDropdownMenu<T>>
    with TickerProviderStateMixin {
  bool _isOpen = false;

  bool Function(T a, T b) get _equals => widget.equals ?? (a, b) => a == b;

  void _setOpen(bool value) {
    if (_isOpen == value) {
      return;
    }
    setState(() {
      _isOpen = value;
    });
    widget.onMenuVisibilityChanged?.call(value);
  }

  void _toggleOpen() {
    _setOpen(!_isOpen);
  }

  void _handleSelection(T option) {
    widget.onSelected(option);
    _setOpen(false);
  }

  @override
  Widget build(BuildContext context) {
    final bbc = AppTheme.bbc(context);
    final typography = AppTheme.typography(context);

    final controlFill = bbc.bbcControlSurface;
    final panelFill = bbc.bbcControlPanelSurface;
    final dividerColor = bbc.bbcDivider;
    final borderColor = bbc.bbcBorderSubtle;
    final borderLayers = bbc.dropdownBorderLayers;
    final labelColor = bbc.bbcControlText;

    final selectedLabel = widget.optionLabelBuilder(widget.selectedOption);

    final trigger = FocusableActionDetector(
      onShowFocusHighlight: (_) {},
      mouseCursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleOpen,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: controlFill,
            borderRadius: widget.triggerBorderRadius,
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: widget.triggerPadding,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (widget.leadingLabel != null) ...[
                  Text(
                    widget.leadingLabel!,
                    style: typography.callout.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    selectedLabel,
                    style: typography.callout.copyWith(color: labelColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isOpen ? widget.openIcon : widget.closedIcon,
                  size: widget.trailingIconSize,
                  color: labelColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Widget buildDefaultRow(T option) {
      final isSelected = _equals(option, widget.selectedOption);
      final optionLabel = widget.optionLabelBuilder(option);
      final selectedFill = bbc.bbcPrimaryOne;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _handleSelection(option);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected ? selectedFill : null,
          ),
          child: Padding(
            padding: widget.itemPadding,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    optionLabel,
                    style: typography.callout.copyWith(
                      color: labelColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected && widget.showSelectionCheckmark)
                  Icon(CupertinoIcons.check_mark, size: 14, color: labelColor),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildItem(T option) {
      final builder = widget.itemBuilder;
      if (builder != null) {
        final isSelected = _equals(option, widget.selectedOption);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _handleSelection(option);
          },
          child: builder(context, option, isSelected: isSelected),
        );
      }

      return buildDefaultRow(option);
    }

    Widget buildPanel() {
      return Padding(
        padding: widget.panelMargin,
        child: SizedBox(
          width: widget.expandToWidth ? double.infinity : null,
          child: _DropdownPanelDecoration(
            borderRadius: widget.panelBorderRadius,
            backgroundColor: panelFill,
            borderLayers: borderLayers,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.options.length; i++) ...[
                  buildItem(widget.options[i]),
                  if (widget.showDividers && i < widget.options.length - 1)
                    SizedBox(
                      height: 1,
                      width: double.infinity,
                      child: ColoredBox(color: dividerColor),
                    ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    Widget content = Padding(
      padding: widget.outerPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          trigger,
          AnimatedSize(
            duration: widget.animationDuration,
            curve: widget.animationCurve,
            alignment: Alignment.topCenter,
            child: _isOpen ? buildPanel() : const SizedBox.shrink(),
          ),
        ],
      ),
    );

    if (widget.expandToWidth) {
      content = SizedBox(width: double.infinity, child: content);
    }

    return content;
  }
}
