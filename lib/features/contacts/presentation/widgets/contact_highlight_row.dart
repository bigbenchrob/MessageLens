import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme.dart';
import '../../../../config/theme/theme_typography.dart';

class ContactHighlightRow extends StatefulWidget {
  const ContactHighlightRow({
    super.key,
    required this.displayName,
    required this.shortName,
    this.summaryLine,
    this.useHeroTitleStyle = false,
    this.contentPadding,
    this.contentLeftGutter,
    this.onTap,
  });

  final String displayName;
  final String shortName;
  final String? summaryLine;
  final bool useHeroTitleStyle;
  final EdgeInsets? contentPadding;
  final double? contentLeftGutter;
  final VoidCallback? onTap;

  @override
  State<ContactHighlightRow> createState() => _ContactHighlightRowState();
}

class _ContactHighlightRowState extends State<ContactHighlightRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = MacosTheme.of(context);
        ref.watch(themeColorsProvider);
        final colors = ref.read(themeColorsProvider.notifier);

        final titleStyle = widget.useHeroTitleStyle
            ? AppTheme.cassetteHeroTitleStyle(context)
            : theme.typography.body.copyWith(color: colors.content.textPrimary);

        final content = Padding(
          padding:
              widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              if (widget.contentLeftGutter != null)
                SizedBox(width: widget.contentLeftGutter),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.displayName,
                      style: titleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.shortName != widget.displayName)
                      Text(
                        widget.shortName,
                        style: theme.typography.caption2.copyWith(
                          color: colors.content.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (widget.summaryLine != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.summaryLine!,
                        style: theme.typography.caption1.copyWith(
                          color: colors.content.textSecondary,
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
        );

        final decorated = DecoratedBox(
          decoration: BoxDecoration(
            color: _isHovered
                ? colors.accents.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: content,
        );

        final onTapCallback = widget.onTap;
        if (onTapCallback == null) {
          return MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: decorated,
          );
        }

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapCallback,
            child: decorated,
          ),
        );
      },
    );
  }
}

class ContactHeroHeaderHighlight extends ConsumerWidget {
  const ContactHeroHeaderHighlight({
    super.key,
    required this.displayName,
    required this.shortName,
  });

  final String displayName;
  final String shortName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the brightness state to trigger rebuilds
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    // Match the hover/selection style from the contact picker
    final backgroundColor = colors.accents.primary.withValues(alpha: 0.15);

    return SizedBox(
      height: 64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      shortName,
                      style: typography.heroTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (shortName != displayName)
                Text(
                  displayName,
                  style: typography.heroSubtitle,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
