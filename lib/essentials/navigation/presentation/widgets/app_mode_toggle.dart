import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' show MacosTooltip;

import '../../../../config/theme/colors/theme_colors.dart';
import '../../application/sidebar_mode_provider.dart';
import '../../domain/sidebar_mode.dart';

/// A mode-latch toggle between Messages and Settings modes.
///
/// Unlike a traditional segmented control where the active segment appears
/// "pressed", this latch inverts the visual metaphor:
/// - **Active segment**: Merges with the surrounding surface, losing button
///   affordance to indicate "you are here".
/// - **Inactive segment**: Retains button affordance (background, border)
///   to invite clicking.
///
/// This design emphasizes the binary, mutually-exclusive nature of the
/// application mode without suggesting that the active segment is a button.
class AppModeToggle extends ConsumerWidget {
  const AppModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(activeSidebarModeProvider);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return MacosTooltip(
      message: 'Switch between Messages and Settings',
      useMousePosition: false,
      child: _ModeLatch(
        colors: colors,
        activeIndex: mode == SidebarMode.messages ? 0 : 1,
        labels: const ['Messages', 'Settings'],
        onChanged: (index) {
          final newMode = index == 0
              ? SidebarMode.messages
              : SidebarMode.settings;
          ref.read(activeSidebarModeProvider.notifier).setMode(newMode);
        },
      ),
    );
  }
}

class _ModeLatch extends StatelessWidget {
  const _ModeLatch({
    required this.colors,
    required this.activeIndex,
    required this.labels,
    required this.onChanged,
  });

  final ThemeColors colors;
  final int activeIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          _LatchSegment(
            label: labels[i],
            isActive: i == activeIndex,
            isFirst: i == 0,
            isLast: i == labels.length - 1,
            colors: colors,
            onTap: () => onChanged(i),
          ),
        ],
      ],
    );
  }
}

class _LatchSegment extends StatefulWidget {
  const _LatchSegment({
    required this.label,
    required this.isActive,
    required this.isFirst,
    required this.isLast,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isFirst;
  final bool isLast;
  final ThemeColors colors;
  final VoidCallback onTap;

  @override
  State<_LatchSegment> createState() => _LatchSegmentState();
}

class _LatchSegmentState extends State<_LatchSegment> {
  bool _isHovered = false;

  BorderRadius get _borderRadius {
    const radius = Radius.circular(5);
    return BorderRadius.only(
      topLeft: widget.isFirst ? radius : Radius.zero,
      bottomLeft: widget.isFirst ? radius : Radius.zero,
      topRight: widget.isLast ? radius : Radius.zero,
      bottomRight: widget.isLast ? radius : Radius.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Active segment: transparent, merges with toolbar surface, no border
    // Inactive segment: muted text at rest; border + hover tint on hover
    final Color textColor;
    final Color? borderColor;
    final Color backgroundColor;

    if (widget.isActive) {
      // Active: no button affordance, text is prominent, merges with toolbar
      textColor = widget.colors.content.textPrimary;
      borderColor = null;
      backgroundColor = Colors.transparent;
    } else if (_isHovered) {
      // Inactive + hovered: show outline and subtle hover tint
      // Use textSecondary (not textPrimary) so hover doesn't outrank active
      textColor = widget.colors.content.textSecondary;
      borderColor = widget.colors.lines.dividerQuiet;
      backgroundColor = widget.colors.surfaces.hover;
    } else {
      // Inactive at rest: just muted text, no button affordance
      textColor = widget.colors.content.textSecondaryQuiet;
      borderColor = null;
      backgroundColor = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isActive
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isActive ? null : widget.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 28),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: _borderRadius,
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 0.5)
                  : null,
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
