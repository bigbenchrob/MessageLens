import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/panel_stack.dart';
import '../../domain/navigation_constants.dart';
import '../../feature_level_providers.dart';

typedef PanelViewBuilder = Widget Function(PanelPage page);

/// Surface widget that displays a panel stack with tab strip
class PanelStackSurface extends ConsumerWidget {
  const PanelStackSurface({
    super.key,
    required this.panel,
    required this.stack,
    required this.buildPanel,
    required this.placeholder,
  });

  final WindowPanel panel;
  final PanelStack stack;
  final PanelViewBuilder buildPanel;
  final Widget placeholder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stack.isEmpty) {
      return placeholder;
    }

    final activeIndex = stack.activeIndex.clamp(0, stack.pages.length - 1);
    final children = <Widget>[
      for (final page in stack.pages)
        _KeepAlivePage(
          key: ValueKey<String>('panel:${panel.name}:${page.id}'),
          child: buildPanel(page),
        ),
    ];

    return Column(
      children: <Widget>[
        if (_shouldShowTabStrip(stack))
          _PanelTabStrip(panel: panel, stack: stack),
        Expanded(
          child: IndexedStack(index: activeIndex, children: children),
        ),
      ],
    );
  }

  bool _shouldShowTabStrip(PanelStack stack) {
    if (stack.pages.length > 1) {
      return true;
    }
    if (stack.pages.length == 1) {
      return stack.pages.first.isClosable;
    }
    return false;
  }
}

class _PanelTabStrip extends ConsumerWidget {
  const _PanelTabStrip({required this.panel, required this.stack});

  final WindowPanel panel;
  final PanelStack stack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tabs = stack.pages;

    return Material(
      color: theme.colorScheme.surface,
      elevation: 1,
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            final page = tabs[index];
            final selected = index == stack.activeIndex;
            return _TabChip(
              title: page.title,
              selected: selected,
              closable: page.isClosable,
              onSelect: () {
                ref
                    .read(panelsViewStateProvider.notifier)
                    .activate(panel: panel, index: index);
              },
              onClose: page.isClosable
                  ? () {
                      ref
                          .read(panelsViewStateProvider.notifier)
                          .closeAt(panel: panel, index: index);
                    }
                  : null,
            );
          },
          separatorBuilder: (_, __) => const SizedBox(width: 4),
          itemCount: tabs.length,
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.title,
    required this.selected,
    required this.closable,
    required this.onSelect,
    this.onClose,
  });

  final String title;
  final bool selected;
  final bool closable;
  final VoidCallback onSelect;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainerHighest;
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.dividerColor;

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (closable)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({super.key, required this.child});

  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
