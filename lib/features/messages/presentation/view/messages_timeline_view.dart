import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui/macos_ui.dart' as macos_ui;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../domain/value_objects/message_timeline_scope.dart';
import '../view_model/timeline/hydration/message_by_ordinal_provider.dart';
import '../view_model/timeline/message_timeline_view_model_provider.dart';
import '../widgets/message_card.dart';

/// Unified view for message timelines across all scopes.
///
/// Works with global, contact, and chat scopes using the same
/// virtual-scrolling infrastructure with scope-specific headers.
class MessagesTimelineView extends HookConsumerWidget {
  const MessagesTimelineView({
    required this.scope,
    this.scrollToDate,
    super.key,
  });

  /// The scope determining which messages to show.
  final MessageTimelineScope scope;

  /// Optional date to scroll to on initial load.
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final vm = ref.watch(messageTimelineViewModelProvider(scope: scope));
    final ordinalAsync = vm.ordinal;

    // Handle initial scroll positioning
    useEffect(() {
      if (scrollToDate != null && ordinalAsync.hasValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await ref
              .read(messageTimelineViewModelProvider(scope: scope).notifier)
              .jumpToDate(scrollToDate!);
        });
      } else if (scrollToDate == null && ordinalAsync.hasValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await ref
              .read(messageTimelineViewModelProvider(scope: scope).notifier)
              .jumpToLatest();
        });
      }
      return null;
    }, [scrollToDate, ordinalAsync.hasValue]);

    final contentBg = theme.brightness == Brightness.dark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFF2F2F7);

    // Build scope-specific scaffold
    return switch (scope) {
      GlobalTimelineScope() => _buildGlobalScaffold(context, ref, vm, theme),
      ContactTimelineScope(:final contactId) => _buildContactScaffold(
        context,
        ref,
        vm,
        theme,
        contactId,
        contentBg,
      ),
      ChatTimelineScope(:final chatId) => _buildChatScaffold(
        context,
        ref,
        vm,
        theme,
        chatId,
        contentBg,
      ),
    };
  }

  Widget _buildGlobalScaffold(
    BuildContext context,
    WidgetRef ref,
    MessageTimelineViewModelState vm,
    MacosThemeData theme,
  ) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Global timeline'),
        actions: [
          ToolBarIconButton(
            icon: const MacosIcon(CupertinoIcons.arrow_down_to_line),
            label: 'Jump to latest',
            onPressed: () => ref
                .read(messageTimelineViewModelProvider(scope: scope).notifier)
                .jumpToLatest(),
            showLabel: false,
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, _) {
            final contentBg = theme.brightness == Brightness.dark
                ? const Color(0xFF1C1C1E)
                : const Color(0xFFF2F2F7);
            return ColoredBox(
              color: contentBg,
              child: Column(
                children: [
                  _GlobalSearchBar(scope: scope, vm: vm),
                  Expanded(child: _buildMessageList(context, ref, vm, theme)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContactScaffold(
    BuildContext context,
    WidgetRef ref,
    MessageTimelineViewModelState vm,
    MacosThemeData theme,
    int contactId,
    Color contentBg,
  ) {
    return Material(
      color: contentBg,
      child: Column(
        children: [
          _ContactHeader(
            contactId: contactId,
            totalMessages: vm.ordinal.value?.totalCount ?? 0,
            theme: theme,
          ),
          const Divider(height: 1),
          _SimpleSearchBar(scope: scope, vm: vm),
          const Divider(height: 1),
          Expanded(child: _buildMessageList(context, ref, vm, theme)),
        ],
      ),
    );
  }

  Widget _buildChatScaffold(
    BuildContext context,
    WidgetRef ref,
    MessageTimelineViewModelState vm,
    MacosThemeData theme,
    int chatId,
    Color contentBg,
  ) {
    return Material(
      color: contentBg,
      child: Column(
        children: [
          _ChatHeader(
            chatId: chatId,
            totalMessages: vm.ordinal.value?.totalCount ?? 0,
            theme: theme,
          ),
          const Divider(height: 1),
          _SimpleSearchBar(scope: scope, vm: vm),
          const Divider(height: 1),
          Expanded(child: _buildMessageList(context, ref, vm, theme)),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    WidgetRef ref,
    MessageTimelineViewModelState vm,
    MacosThemeData theme,
  ) {
    if (vm.isSearching) {
      return _SearchResultsList(vm: vm);
    }

    return vm.ordinal.when(
      data: (ordinalState) {
        if (ordinalState.totalCount == 0) {
          return Center(
            child: Text(_emptyMessage, style: theme.typography.title3),
          );
        }

        return ScrollablePositionedList.builder(
          itemScrollController: ordinalState.itemScrollController,
          itemPositionsListener: ordinalState.itemPositionsListener,
          itemCount: ordinalState.totalCount,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            return _MessageRow(scope: scope, ordinal: index);
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
    );
  }

  String get _emptyMessage {
    return switch (scope) {
      GlobalTimelineScope() => 'No messages indexed yet.',
      ContactTimelineScope() => 'No messages with this contact yet.',
      ChatTimelineScope() => 'No messages in this chat yet.',
    };
  }
}

/// Search bar with mode toggle (for global scope).
class _GlobalSearchBar extends ConsumerWidget {
  const _GlobalSearchBar({required this.scope, required this.vm});

  final MessageTimelineScope scope;
  final MessageTimelineViewModelState vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: MacosTextField(
              controller: vm.searchController,
              placeholder: 'Search all messages',
              clearButtonMode: macos_ui.OverlayVisibilityMode.editing,
            ),
          ),
          const SizedBox(width: 12),
          _SearchModeToggle(scope: scope, mode: vm.searchMode),
        ],
      ),
    );
  }
}

/// Simple search bar without mode toggle (for contact/chat scopes).
class _SimpleSearchBar extends StatelessWidget {
  const _SimpleSearchBar({required this.scope, required this.vm});

  final MessageTimelineScope scope;
  final MessageTimelineViewModelState vm;

  @override
  Widget build(BuildContext context) {
    final placeholder = switch (scope) {
      GlobalTimelineScope() => 'Search all messages',
      ContactTimelineScope() => 'Search messages with this contact',
      ChatTimelineScope() => 'Search this conversation',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: MacosSearchField<String>(
        controller: vm.searchController,
        placeholder: placeholder,
        results: const [],
      ),
    );
  }
}

/// Search mode toggle buttons.
class _SearchModeToggle extends ConsumerWidget {
  const _SearchModeToggle({required this.scope, required this.mode});

  final MessageTimelineScope scope;
  final MessageSearchMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PushButton(
          controlSize: ControlSize.small,
          secondary: mode != MessageSearchMode.allTerms,
          onPressed: () => ref
              .read(messageTimelineViewModelProvider(scope: scope).notifier)
              .setSearchMode(MessageSearchMode.allTerms),
          child: const Text('All terms'),
        ),
        const SizedBox(width: 8),
        PushButton(
          controlSize: ControlSize.small,
          secondary: mode != MessageSearchMode.anyTerm,
          onPressed: () => ref
              .read(messageTimelineViewModelProvider(scope: scope).notifier)
              .setSearchMode(MessageSearchMode.anyTerm),
          child: const Text('Any term'),
        ),
      ],
    );
  }
}

/// Header for contact message view.
class _ContactHeader extends StatelessWidget {
  const _ContactHeader({
    required this.contactId,
    required this.totalMessages,
    required this.theme,
  });

  final int contactId;
  final int totalMessages;
  final MacosThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final countText = totalMessages.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Add contact name and avatar from contactId
          const Text(
            'All Messages',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '$countText messages across all conversations',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF98989D) : const Color(0xFF7A7A7F),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header for chat message view.
class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.chatId,
    required this.totalMessages,
    required this.theme,
  });

  final int chatId;
  final int totalMessages;
  final MacosThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final countText = totalMessages.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Add chat/handle info from chatId
          const Text(
            'Conversation',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '$countText messages',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF98989D) : const Color(0xFF7A7A7F),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single message row with hydration.
class _MessageRow extends ConsumerWidget {
  const _MessageRow({required this.scope, required this.ordinal});

  final MessageTimelineScope scope;
  final int ordinal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final itemAsync = ref.watch(
      messageByTimelineOrdinalProvider(scope: scope, ordinal: ordinal),
    );

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return _SkeletonRow(theme: theme);
        }
        return MessageCard(message: item);
      },
      loading: () => _SkeletonRow(theme: theme),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Row $ordinal failed: $error'),
      ),
    );
  }
}

/// Skeleton placeholder while message is loading.
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

/// Search results list.
class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({required this.vm});

  final MessageTimelineViewModelState vm;

  @override
  Widget build(BuildContext context) {
    return vm.searchResults.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Text('No matches found for "${vm.debouncedQuery}"'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return MessageCard(message: results[index]);
          },
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => Center(child: Text('Search failed: $error')),
    );
  }
}
