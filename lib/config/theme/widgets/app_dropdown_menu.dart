import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../theme.dart';

typedef AppDropdownItemBuilder<T> =
    Widget Function(BuildContext context, T value, {required bool isSelected});

class AppDropdownMenu<T> extends HookConsumerWidget {
  const AppDropdownMenu({
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
    super.key,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = useState(false);

    final equals = useMemoized(() => this.equals ?? (T a, T b) => a == b, [
      this.equals,
    ]);

    final setOpen = useCallback((bool value) {
      if (isOpen.value != value) {
        isOpen.value = value;
        onMenuVisibilityChanged?.call(value);
      }
    }, [isOpen, onMenuVisibilityChanged]);

    final toggleOpen = useCallback(() {
      setOpen(!isOpen.value);
    }, [setOpen, isOpen]);

    final handleSelection = useCallback((T option) {
      onSelected(option);
      setOpen(false);
    }, [onSelected, setOpen]);

    final bbc = AppTheme.bbc(context);
    final typography = AppTheme.typography(context);

    final controlFill = bbc.bbcControlSurface;
    final panelFill = bbc.bbcControlPanelSurface;
    final dividerColor = bbc.bbcDivider;
    final borderColor = bbc.bbcBorderSubtle;
    final borderLayers = bbc.dropdownBorderLayers;
    final labelColor = bbc.bbcControlText;

    final selectedLabel = optionLabelBuilder(selectedOption);

    final trigger = FocusableActionDetector(
      onShowFocusHighlight: (_) {},
      mouseCursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: toggleOpen,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: controlFill,
            borderRadius: triggerBorderRadius,
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: triggerPadding,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (leadingLabel != null) ...[
                  Text(
                    leadingLabel!,
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
                  isOpen.value ? openIcon : closedIcon,
                  size: trailingIconSize,
                  color: labelColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Widget buildDefaultRow(T option, bool Function(T, T) equals) {
      final isSelected = equals(option, selectedOption);
      final optionLabel = optionLabelBuilder(option);
      final selectedFill = bbc.bbcPrimaryOne;
      final selectedTextColor = bbc.bbcPrimaryOne;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          handleSelection(option);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected ? selectedFill.withValues(alpha: 0.16) : null,
          ),
          child: Padding(
            padding: itemPadding,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    optionLabel,
                    style: typography.callout.copyWith(
                      color: isSelected ? selectedTextColor : labelColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected && showSelectionCheckmark)
                  Icon(
                    CupertinoIcons.check_mark,
                    size: 14,
                    color: selectedTextColor,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildItemRow(
      BuildContext context,
      T option,
      bool Function(T, T) equals,
    ) {
      final builder = itemBuilder;
      if (builder != null) {
        final isSelected = equals(option, selectedOption);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            handleSelection(option);
          },
          child: builder(context, option, isSelected: isSelected),
        );
      }

      return buildDefaultRow(option, equals);
    }

    Widget buildItem(T option) {
      return _buildItemRow(context, option, equals);
    }

    Widget buildPanel() {
      return Padding(
        padding: panelMargin,
        child: SizedBox(
          width: expandToWidth ? double.infinity : null,
          child: _DropdownPanelDecoration(
            borderRadius: panelBorderRadius,
            backgroundColor: panelFill,
            borderLayers: borderLayers,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < options.length; i++) ...[
                  buildItem(options[i]),
                  if (showDividers && i < options.length - 1)
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
      padding: outerPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          trigger,
          AnimatedSize(
            duration: animationDuration,
            curve: animationCurve,
            alignment: Alignment.topCenter,
            child: isOpen.value ? buildPanel() : const SizedBox.shrink(),
          ),
        ],
      ),
    );

    if (expandToWidth) {
      content = SizedBox(width: double.infinity, child: content);
    }

    return content;
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

      final rect =
          Offset(offset, offset) &
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
