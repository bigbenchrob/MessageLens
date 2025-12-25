import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui/macos_ui.dart' as macos_ui;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../view_model/view_model_global/global_messages_view_model_provider.dart';
import '../view_model/view_model_global/hydration/message_by_global_ordinal_provider.dart';
import '../widgets/message_card.dart';

class GlobalTimelineV2View extends HookConsumerWidget {
  const GlobalTimelineV2View({this.scrollToDate, super.key});

  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final vm = ref.watch(globalMessagesViewModelProvider);
    final ordinalAsync = vm.ordinal;

    // Jump to month on initial load if scrollToDate provided
    // Otherwise jump to latest messages
    useEffect(() {
      if (scrollToDate != null && ordinalAsync.hasValue) {
        debugPrint(
          '🎯 GlobalTimelineV2View: scrollToDate provided: $scrollToDate, ordinal ready',
        );
        // Wait for next frame to ensure UI is fully built
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          debugPrint('🎯 GlobalTimelineV2View: Calling jumpToMonth');
          await ref
              .read(globalMessagesViewModelProvider.notifier)
              .jumpToMonth(scrollToDate!);
        });
      } else if (scrollToDate == null && ordinalAsync.hasValue) {
        debugPrint(
          '🎯 GlobalTimelineV2View: No scrollToDate, jumping to latest',
        );
        // Jump to latest messages on initial load
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await ref
              .read(globalMessagesViewModelProvider.notifier)
              .jumpToLatest();
        });
      } else if (scrollToDate != null) {
        debugPrint(
          '🎯 GlobalTimelineV2View: scrollToDate provided but ordinal not ready yet',
        );
      }
      return null;
    }, [scrollToDate, ordinalAsync.hasValue]);

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

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return _SkeletonRow(theme: theme);
        }

        return MessageCard(message: item, emphasizeSender: true);
      },
      loading: () => _SkeletonRow(theme: theme),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Row $ordinal failed: $error'),
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
