import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/theme.dart';

class ContactHighlightRow extends StatelessWidget {
  const ContactHighlightRow({
    super.key,
    required this.displayName,
    required this.shortName,
    this.summaryLine,
    required this.isHighlighted,
    this.useHeroTitleStyle = false,
    this.contentPadding,
    this.contentLeftGutter,
    this.onTap,
  });

  final String displayName;
  final String shortName;
  final String? summaryLine;
  final bool isHighlighted;
  final bool useHeroTitleStyle;
  final EdgeInsets? contentPadding;
  final double? contentLeftGutter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);

    final titleStyle = useHeroTitleStyle
        ? AppTheme.cassetteHeroTitleStyle(context)
        : theme.typography.body;

    final pill = DecoratedBox(
      decoration: BoxDecoration(
        color: isHighlighted
            ? theme.primaryColor.withValues(alpha: 0.15)
            : MacosColors.controlBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            if (contentLeftGutter != null) SizedBox(width: contentLeftGutter),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: titleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (shortName != displayName)
                    Text(
                      shortName,
                      style: theme.typography.caption2.copyWith(
                        color: MacosColors.secondaryLabelColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (summaryLine != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      summaryLine!,
                      style: theme.typography.caption1.copyWith(
                        color: MacosColors.secondaryLabelColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final onTapCallback = onTap;
    if (onTapCallback == null) {
      return pill;
    }

    return GestureDetector(
      onTap: onTapCallback,
      behavior: HitTestBehavior.opaque,
      child: pill,
    );
  }
}

class ContactHeroHeaderHighlight extends StatelessWidget {
  const ContactHeroHeaderHighlight({
    super.key,
    required this.displayName,
    required this.shortName,
    required this.summaryLine,
    required this.onChange,
  });

  final String displayName;
  final String shortName;
  final String summaryLine;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);

    final tint = theme.primaryColor.withValues(alpha: 0.10);
    final accent = theme.primaryColor.withValues(alpha: 0.75);
    final linkColor = theme.primaryColor;
    final linkBaseStyle = theme.typography.body.copyWith(color: linkColor);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: const SizedBox(width: 4),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: AppTheme.cassetteHeroTitleStyle(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _HoverLink(
                          label: 'change…',
                          baseStyle: linkBaseStyle,
                          onTap: onChange,
                        ),
                      ],
                    ),
                    if (shortName != displayName)
                      Text(
                        shortName,
                        style: theme.typography.caption2.copyWith(
                          color: MacosColors.secondaryLabelColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      summaryLine,
                      style: theme.typography.caption1.copyWith(
                        color: MacosColors.secondaryLabelColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverLink extends StatefulWidget {
  const _HoverLink({
    required this.label,
    required this.baseStyle,
    required this.onTap,
  });

  final String label;
  final TextStyle baseStyle;
  final VoidCallback onTap;

  @override
  State<_HoverLink> createState() => _HoverLinkState();
}

class _HoverLinkState extends State<_HoverLink> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseStyle.color;
    final hoverColor = baseColor?.withValues(alpha: 0.85);
    final active = _isHovering || _isPressed;
    final style = widget.baseStyle.copyWith(
      color: active ? hoverColor : baseColor,
      decoration: active ? TextDecoration.underline : TextDecoration.none,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Listener(
        onPointerDown: (_) {
          setState(() {
            _isPressed = true;
          });
        },
        onPointerUp: (_) {
          setState(() {
            _isPressed = false;
          });
        },
        onPointerCancel: (_) {
          setState(() {
            _isPressed = false;
          });
        },
        child: InkWell(
          onTap: widget.onTap,
          onHover: (isHovering) {
            if (_isHovering == isHovering) {
              return;
            }
            setState(() {
              _isHovering = isHovering;
            });
          },
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: Text(widget.label, style: style),
          ),
        ),
      ),
    );
  }
}
