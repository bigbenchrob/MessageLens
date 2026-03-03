import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' show ControlSize;

import '../colors/theme_colors.dart';

class AppPrimaryButton extends ConsumerStatefulWidget {
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
  ConsumerState<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends ConsumerState<AppPrimaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final baseColor = colors.accents.primary;
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
