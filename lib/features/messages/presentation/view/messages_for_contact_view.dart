import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../view_model/shared/display_widgets/new_display_widgets.dart';
import '../view_model/shared/hydration/messages_for_handle_provider.dart';
import '../view_model/view_model_contact/contact_messages_view_model_provider.dart';
import '../widgets/message_card.dart';

/// View showing all messages with a specific contact across all chats/handles.
/// Messages are displayed in chronological order regardless of which conversation they came from.
class MessagesForContactView extends HookConsumerWidget {
  const MessagesForContactView({
    required this.contactId,
    this.scrollToDate,
    super.key,
  });

  final int contactId;
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(
      contactMessagesViewModelProvider(contactId: contactId),
    );
    final ordinalAsync = vm.ordinal;

    // Keeps scroll state stable while changing search query.
    final searchScrollController = useScrollController();

    // Initial positioning: default to latest, unless a scroll target is provided.
    // Kept out of list config to avoid list rebuild quirks.
    useEffect(() {
      if (scrollToDate != null && ordinalAsync.hasValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }

          Future.microtask(() async {
            final notifier = ref.read(
              contactMessagesViewModelProvider(contactId: contactId).notifier,
            );
            await notifier.jumpToMonthForDate(scrollToDate!);
          });
        });
      } else if (scrollToDate == null && ordinalAsync.hasValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }

          Future.microtask(() async {
            final notifier = ref.read(
              contactMessagesViewModelProvider(contactId: contactId).notifier,
            );
            await notifier.jumpToLatest();
          });
        });
      }

      return null;
    }, [contactId, scrollToDate, ordinalAsync.hasValue]);

    // VM-managed debounce/search results.
    final isSearching = vm.isSearching;
    final searchAsync = vm.searchResults;

    final messageListBody = ordinalAsync.when<Widget>(
      data: (state) {
        if (state.totalCount == 0) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.chat_bubble_text, size: 48),
                SizedBox(height: 12),
                Text(
                  'No messages with this contact yet.',
                  style: TextStyle(color: Color(0xFF7A7A7F)),
                ),
              ],
            ),
          );
        }

        return ScrollablePositionedList.builder(
          initialScrollIndex: 0,
          itemScrollController: state.itemScrollController,
          itemPositionsListener: state.itemPositionsListener,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.totalCount,
          itemBuilder: (context, ordinal) {
            return _ContactOrdinalMessageRow(
              key: ValueKey('contact-msg-ordinal-$ordinal'),
              contactId: contactId,
              ordinal: ordinal,
              buildMessage: (message) => MessageCard(message: message),
            );
          },
        );
      },
      loading: () => const Center(child: ProgressCircle(radius: 12)),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Unable to load messages. $error',
            style: const TextStyle(color: Color(0xFFD14343)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    final searchBody = searchAsync.when<Widget>(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No matches for "${vm.debouncedQuery}".',
                style: const TextStyle(color: Color(0xFF7A7A7F)),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final itemCount = results.length + 1;

        return ListView.builder(
          controller: searchScrollController,
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index == 0) {
              final label = results.length == 1
                  ? '1 match'
                  : '${results.length} matches';
              return Padding(
                padding: MsgTheme.convoHPad().add(
                  const EdgeInsets.only(bottom: 8),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF7A7A7F),
                    fontSize: 13,
                  ),
                ),
              );
            }

            final message = results[index - 1];
            return MessageCard(message: message);
          },
        );
      },
      loading: () => const Center(child: ProgressCircle(radius: 12)),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Search error. $error',
            style: const TextStyle(color: Color(0xFFD14343)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    final theme = MacosTheme.of(context);

    return Material(
      color: theme.brightness == Brightness.dark
          ? const Color(0xFF1C1C1E)
          : const Color(0xFFF2F2F7),
      child: Column(
        children: [
          // Header
          _ContactMessagesHeader(
            contactId: contactId,
            totalMessages: ordinalAsync.value?.totalCount ?? 0,
          ),
          const Divider(height: 1),
          // Search field
          Padding(
            padding: MsgTheme.convoHPad().add(
              const EdgeInsets.fromLTRB(0, 12, 0, 8),
            ),
            child: MacosSearchField<String>(
              controller: vm.searchController,
              placeholder: 'Search messages with this contact',
              results: const [],
            ),
          ),
          const Divider(height: 1),
          // Message list or search results
          Expanded(child: isSearching ? searchBody : messageListBody),
        ],
      ),
    );
  }
}

/// Header showing contact name and message count
class _ContactMessagesHeader extends ConsumerWidget {
  const _ContactMessagesHeader({
    required this.contactId,
    required this.totalMessages,
  });

  final int contactId;
  final int totalMessages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = MacosTheme.brightnessOf(context) == Brightness.dark;
    final headerBackground = isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFF2F2F7);
    final dividerColor = isDark
        ? const Color(0xFF38383D)
        : const Color(0xFFE5E5EA);

    // Format message count
    final countText = totalMessages.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );

    return ColoredBox(
      color: headerBackground,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: Add contact name and avatar
            const Text(
              'All Messages',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '$countText messages across all conversations',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF98989D)
                    : const Color(0xFF7A7A7F),
              ),
            ),
            const SizedBox(height: 12),
            ColoredBox(
              color: dividerColor,
              child: const SizedBox(height: 0.5, width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper around message loading that works with contact context.
/// Loads messages by contact ordinal instead of chat ordinal.
class _ContactOrdinalMessageRow extends ConsumerWidget {
  const _ContactOrdinalMessageRow({
    required this.contactId,
    required this.ordinal,
    required this.buildMessage,
    super.key,
  });

  final int contactId;
  final int ordinal;
  final Widget Function(MessageListItem) buildMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageAsync = ref.watch(
      messageByContactOrdinalProvider(contactId: contactId, ordinal: ordinal),
    );

    return messageAsync.when(
      data: (message) {
        if (message == null) {
          // Ordinal out of range or message not found
          return const SizedBox.shrink();
        }
        return buildMessage(message);
      },
      loading: () => const SizedBox(
        height: 60.0,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: ProgressCircle(radius: 8),
          ),
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'Error loading message',
            style: TextStyle(
              color: MacosTheme.brightnessOf(context) == Brightness.dark
                  ? const Color(0xFFD14343)
                  : const Color(0xFFB71C1C),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
