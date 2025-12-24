import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui/macos_ui.dart' as macos_ui;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../view_model/global_messages/global_messages_view_model.dart';
import '../view_model/global_messages/hydration/message_by_global_ordinal_provider.dart';

class GlobalTimelineV2View extends HookConsumerWidget {
  const GlobalTimelineV2View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final vm = ref.watch(globalMessagesViewModelProvider);

    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Global timeline'),
        actions: [
          ToolBarIconButton(
            icon: const MacosIcon(CupertinoIcons.arrow_down_to_line),
            label: 'Jump to latest',
            onPressed: () => ref
                .read(globalMessagesViewModelProvider.notifier)
                .jumpToLatest(),
            showLabel: false,
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: MacosTextField(
                          controller: vm.searchController,
                          placeholder: 'Search all messages',
                          clearButtonMode:
                              macos_ui.OverlayVisibilityMode.editing,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _SearchModeToggle(mode: vm.searchMode),
                    ],
                  ),
                ),
                Expanded(
                  child: vm.ordinal.when(
                    data: (ordinalState) {
                      if (ordinalState.totalCount == 0) {
                        return Center(
                          child: Text(
                            'No messages indexed yet.',
                            style: theme.typography.title3,
                          ),
                        );
                      }

                      return ScrollablePositionedList.builder(
                        itemScrollController: ordinalState.itemScrollController,
                        itemPositionsListener:
                            ordinalState.itemPositionsListener,
                        itemCount: ordinalState.totalCount,
                        itemBuilder: (context, index) {
                          return _GlobalTimelineV2Row(ordinal: index);
                        },
                      );
                    },
                    loading: () => const Center(child: ProgressCircle()),
                    error: (error, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Unable to load timeline: $error'),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SearchModeToggle extends ConsumerWidget {
  const _SearchModeToggle({required this.mode});

  final GlobalMessagesSearchMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PushButton(
          controlSize: ControlSize.small,
          secondary: mode != GlobalMessagesSearchMode.allTerms,
          onPressed: () => ref
              .read(globalMessagesViewModelProvider.notifier)
              .setSearchMode(GlobalMessagesSearchMode.allTerms),
          child: const Text('All terms'),
        ),
        const SizedBox(width: 8),
        PushButton(
          controlSize: ControlSize.small,
          secondary: mode != GlobalMessagesSearchMode.anyTerm,
          onPressed: () => ref
              .read(globalMessagesViewModelProvider.notifier)
              .setSearchMode(GlobalMessagesSearchMode.anyTerm),
          child: const Text('Any term'),
        ),
      ],
    );
  }
}

class _GlobalTimelineV2Row extends ConsumerWidget {
  const _GlobalTimelineV2Row({required this.ordinal});

  final int ordinal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final itemAsync = ref.watch(
      messageByGlobalOrdinalProvider(ordinal: ordinal),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: itemAsync.when(
        data: (item) {
          if (item == null) {
            return _SkeletonRow(theme: theme);
          }

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.canvasColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.senderName,
                  style: theme.typography.title3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(item.text, style: theme.typography.body),
              ],
            ),
          );
        },
        loading: () => _SkeletonRow(theme: theme),
        error: (error, _) => Text('Row $ordinal failed: $error'),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.theme});

  final MacosThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
