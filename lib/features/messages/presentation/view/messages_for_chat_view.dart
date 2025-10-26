import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../new_display_widgets.dart';
import '../view_model/attachment_info.dart';
import '../view_model/chat_message_search_provider.dart';
import '../view_model/chat_messages_pager_provider.dart';
import '../view_model/messages_for_chat_provider.dart';
import '../widgets/message_link_preview_card.dart';

class MessagesForChatView extends HookConsumerWidget {
  const MessagesForChatView({
    required this.chatId,
    this.scrollToDate,
    super.key,
  });

  final int chatId;
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagerAsync = ref.watch(chatMessagesPagerProvider(chatId: chatId));
    final scrollController = useScrollController();
    final searchScrollController = useScrollController();
    final hasAutoScrolled = useRef(false);
    final prevLoadingOlder = useRef(false);
    final previousExtentBefore = useRef<double?>(null);
    final previousScrollOffset = useRef<double?>(null);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final debouncedQuery = useState('');

    void logJump(String message) {
      debugPrint('[MessagesForChatView] $message');
    }

    useEffect(() {
      hasAutoScrolled.value = false;
      searchController.text = '';
      searchQuery.value = '';
      debouncedQuery.value = '';
      return null;
    }, [chatId]);

    // Separate effect for scrollToDate changes (allows re-scrolling without reloading)
    useEffect(() {
      hasAutoScrolled.value = false;
      return null;
    }, [scrollToDate]);

    useEffect(() {
      if (scrollToDate == null) {
        return null;
      }

      final normalized = DateTime(scrollToDate!.year, scrollToDate!.month);
      Future.microtask(() async {
        await ref
            .read(chatMessagesPagerProvider(chatId: chatId).notifier)
            .ensureMonthLoaded(normalized);
      });

      return null;
    }, [chatId, scrollToDate]);

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    useEffect(() {
      final timer = Timer(const Duration(milliseconds: 250), () {
        final trimmed = searchQuery.value.trim();
        if (debouncedQuery.value != trimmed) {
          debouncedQuery.value = trimmed;
        }
      });
      return timer.cancel;
    }, [searchQuery.value]);

    final isSearching = debouncedQuery.value.isNotEmpty;

    useEffect(() {
      if (isSearching) {
        return null;
      }

      void listener() {
        if (!scrollController.hasClients) {
          return;
        }
        // Without reverse, older messages are at the top (lower scroll position)
        final currentPosition = scrollController.position.pixels;
        // Trigger when within 160 pixels of the top (older messages)
        if (currentPosition <= 160) {
          ref
              .read(chatMessagesPagerProvider(chatId: chatId).notifier)
              .loadOlder();
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController, chatId, isSearching]);

    useEffect(
      () {
        if (isSearching) {
          return null;
        }

        final state = pagerAsync.valueOrNull;
        if (state == null) {
          return null;
        }

        if (hasAutoScrolled.value || state.messages.isEmpty) {
          return null;
        }

        if (state.isLoadingOlder) {
          return null;
        }

        final targetDate = scrollToDate;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!scrollController.hasClients) {
            return;
          }

          if (targetDate != null) {
            final messages = state.messages;
            var targetIndex = -1;

            for (var i = 0; i < messages.length; i++) {
              final msgDate = messages[i].sentAt;
              if (msgDate != null &&
                  msgDate.year == targetDate.year &&
                  msgDate.month == targetDate.month) {
                targetIndex = i;
                break;
              }
            }

            if (targetIndex >= 0) {
              final totalScrollableRange =
                  scrollController.position.maxScrollExtent;
              final segmentCount = messages.length > 1
                  ? messages.length - 1
                  : 1;
              final normalizedIndex = targetIndex / segmentCount;
              final targetOffset = (normalizedIndex * totalScrollableRange)
                  .clamp(0.0, totalScrollableRange);
              logJump(
                'jumpTo month target='
                '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}'
                ' index=$targetIndex offset=$targetOffset range='
                '$totalScrollableRange',
              );
              scrollController.jumpTo(targetOffset);
              hasAutoScrolled.value = true;
              return;
            }

            if (!state.hasMore) {
              final bottomOffset = scrollController.position.maxScrollExtent;
              logJump(
                'jumpTo bottom (month not found, no more pages) '
                'offset=$bottomOffset messages=${messages.length}',
              );
              scrollController.jumpTo(bottomOffset);
              hasAutoScrolled.value = true;
            }

            return;
          }

          final latestOffset = scrollController.position.maxScrollExtent;
          logJump(
            'jumpTo bottom for latest messages '
            'offset=$latestOffset messages=${state.messages.length}',
          );
          scrollController.jumpTo(latestOffset);
          hasAutoScrolled.value = true;
        });

        return null;
      },
      [
        pagerAsync.valueOrNull?.messages.length,
        pagerAsync.valueOrNull?.isLoadingOlder,
        pagerAsync.valueOrNull?.hasMore,
        isSearching,
        scrollToDate,
      ],
    );

    useEffect(
      () {
        if (isSearching) {
          return null;
        }

        final state = pagerAsync.valueOrNull;
        final isLoadingOlder = state?.isLoadingOlder ?? false;

        if (isLoadingOlder && !prevLoadingOlder.value) {
          if (scrollController.hasClients) {
            previousExtentBefore.value = scrollController.position.extentBefore;
            previousScrollOffset.value = scrollController.position.pixels;
          }
        }

        if (!isLoadingOlder && prevLoadingOlder.value) {
          if (scrollController.hasClients &&
              previousExtentBefore.value != null &&
              previousScrollOffset.value != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!scrollController.hasClients) {
                return;
              }
              // When loading older messages at top, new content increases the
              // extentBefore value by exactly the height inserted above the
              // current viewport. Adjust by that delta so the same message
              // stays pinned after the load completes.
              final newExtentBefore = scrollController.position.extentBefore;
              final delta = newExtentBefore - previousExtentBefore.value!;
              final target = (previousScrollOffset.value! + delta).clamp(
                0.0,
                scrollController.position.maxScrollExtent,
              );
              logJump(
                'jumpTo after loadOlder prevExtent='
                '${previousExtentBefore.value} newExtent=$newExtentBefore '
                'delta=$delta prevOffset=${previousScrollOffset.value} '
                'target=$target maxExtent='
                '${scrollController.position.maxScrollExtent}',
              );
              scrollController.jumpTo(target);
            });
          }
          previousExtentBefore.value = null;
          previousScrollOffset.value = null;
        }

        prevLoadingOlder.value = isLoadingOlder;
        return null;
      },
      [
        pagerAsync.valueOrNull?.isLoadingOlder,
        pagerAsync.valueOrNull?.messages.length,
        isSearching,
      ],
    );

    final searchAsync = isSearching
        ? ref.watch(
            chatMessageSearchResultsProvider(
              chatId: chatId,
              query: debouncedQuery.value,
            ),
          )
        : const AsyncValue<List<ChatMessageListItem>>.data(
            <ChatMessageListItem>[],
          );

    final messageListBody = pagerAsync.when<Widget>(
      data: (state) {
        final messages = state.messages;

        if (messages.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.chat_bubble_text, size: 48),
                SizedBox(height: 12),
                Text(
                  'No messages in this chat yet.',
                  style: TextStyle(color: Color(0xFF7A7A7F)),
                ),
              ],
            ),
          );
        }

        final hasLoader = state.isLoadingOlder;
        final itemCount = messages.length + (hasLoader ? 1 : 0);

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (hasLoader) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: ProgressCircle(radius: 12)),
                );
              }

              final messageIndex = index - 1;
              final message = messages[messageIndex];
              final isLast = messageIndex == messages.length - 1;
              return KeyedSubtree(
                key: ValueKey(message.id),
                child: _buildMessageEntry(context, message, isLast: isLast),
              );
            }

            final message = messages[index];
            final isLast = index == messages.length - 1;
            return KeyedSubtree(
              key: ValueKey(message.id),
              child: _buildMessageEntry(context, message, isLast: isLast),
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
                'No matches for "${debouncedQuery.value}".',
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
                  '$label for "${debouncedQuery.value}"',
                  style: MsgTheme.metadata,
                ),
              );
            }

            final messageIndex = index - 1;
            final message = results[messageIndex];
            final isLast = index == itemCount - 1;
            return KeyedSubtree(
              key: ValueKey(message.id),
              child: _buildMessageEntry(
                context,
                message,
                isLast: isLast,
                highlightText: debouncedQuery.value,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: ProgressCircle(radius: 12)),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Unable to search messages. $error',
            style: const TextStyle(color: Color(0xFFD14343)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    final body = isSearching ? searchBody : messageListBody;

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: MsgTheme.convoHPad().add(
              const EdgeInsets.fromLTRB(0, 12, 0, 8),
            ),
            child: MacosSearchField<String>(
              controller: searchController,
              placeholder: 'Search this conversation',
              results: const [],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildMessageEntry(
    BuildContext context,
    ChatMessageListItem message, {
    required bool isLast,
    String? highlightText,
  }) {
    return Padding(
      padding: MsgTheme.convoHPad(),
      child: Column(
        children: [
          _buildMessageTile(message, highlightText: highlightText),
          if (!isLast) MsgTheme.gapMD,
        ],
      ),
    );
  }

  Widget _buildMessageTile(
    ChatMessageListItem message, {
    String? highlightText,
  }) {
    final urls = _extractUrls(message.text);
    final isPureUrlMessage =
        urls.length == 1 && message.text.trim() == urls.first;

    final urlPreviewAttachment = _findAttachment(message.attachments, (
      attachment,
    ) {
      return attachment.isUrlPreview && attachment.localPath != null;
    });

    final imageAttachments = message.attachments.where(
      (attachment) => attachment.isImage && attachment.localPath != null,
    );
    final videoAttachments = message.attachments.where(
      (attachment) => attachment.isVideo && attachment.localPath != null,
    );

    if (urlPreviewAttachment != null || isPureUrlMessage) {
      return MessageLinkPreviewCard(
        message: message,
        maxWidth: MsgTheme.maxBubbleWidth,
      );
    }

    if (imageAttachments.isNotEmpty) {
      final attachment = imageAttachments.first;
      return ImageMessageTile(
        isMe: message.isFromMe,
        attachment: attachment,
        sender: message.senderName,
        sentAt: message.sentAt ?? DateTime.now(),
        messageId: message.id,
      );
    }

    if (videoAttachments.isNotEmpty) {
      final attachment = videoAttachments.first;
      return VideoMessageTile(
        isMe: message.isFromMe,
        attachment: attachment,
        sender: message.senderName,
        sentAt: message.sentAt ?? DateTime.now(),
        messageId: message.id,
      );
    }

    return TextMessageTile(
      isMe: message.isFromMe,
      text: message.text,
      sender: message.senderName,
      sentAt: message.sentAt ?? DateTime.now(),
      messageId: message.id,
      highlight: highlightText,
    );
  }

  List<String> _extractUrls(String text) {
    final urlPattern = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );
    final matches = urlPattern.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  AttachmentInfo? _findAttachment(
    List<AttachmentInfo> attachments,
    bool Function(AttachmentInfo attachment) predicate,
  ) {
    for (final attachment in attachments) {
      if (predicate(attachment)) {
        return attachment;
      }
    }
    return null;
  }
}
