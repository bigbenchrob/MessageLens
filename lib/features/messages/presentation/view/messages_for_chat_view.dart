import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../new_display_widgets.dart';
import '../view_model/chat_message_search_provider.dart';
import '../view_model/chat_messages_pager_provider.dart';
import '../view_model/messages_for_chat_provider.dart';
import '../widgets/message_link_preview_card.dart';

class MessagesForChatView extends HookConsumerWidget {
  const MessagesForChatView({required this.chatId, super.key});

  final int chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagerAsync = ref.watch(chatMessagesPagerProvider(chatId: chatId));
    final scrollController = useScrollController();
    final searchScrollController = useScrollController();
    final hasAutoScrolled = useRef(false);
    final prevLoadingOlder = useRef(false);
    final previousMaxExtent = useRef<double?>(null);
    final previousScrollOffset = useRef<double?>(null);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final debouncedQuery = useState('');

    useEffect(() {
      hasAutoScrolled.value = false;
      searchController.text = '';
      searchQuery.value = '';
      debouncedQuery.value = '';
      return null;
    }, [chatId]);

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
        if (scrollController.position.pixels <= 160) {
          ref
              .read(chatMessagesPagerProvider(chatId: chatId).notifier)
              .loadOlder();
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController, chatId, isSearching]);

    useEffect(() {
      if (isSearching) {
        return null;
      }

      pagerAsync.whenOrNull(
        data: (state) {
          if (!hasAutoScrolled.value && state.messages.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                scrollController.jumpTo(
                  scrollController.position.maxScrollExtent,
                );
                hasAutoScrolled.value = true;
              }
            });
          }
        },
      );
      return null;
    }, [pagerAsync.valueOrNull?.messages.length, isSearching]);

    useEffect(
      () {
        if (isSearching) {
          return null;
        }

        final state = pagerAsync.valueOrNull;
        final isLoadingOlder = state?.isLoadingOlder ?? false;

        if (isLoadingOlder && !prevLoadingOlder.value) {
          if (scrollController.hasClients) {
            previousMaxExtent.value = scrollController.position.maxScrollExtent;
            previousScrollOffset.value = scrollController.position.pixels;
          }
        }

        if (!isLoadingOlder && prevLoadingOlder.value) {
          if (scrollController.hasClients &&
              previousMaxExtent.value != null &&
              previousScrollOffset.value != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!scrollController.hasClients) {
                return;
              }
              final newMaxExtent = scrollController.position.maxScrollExtent;
              final delta = newMaxExtent - previousMaxExtent.value!;
              final target = (previousScrollOffset.value! + delta).clamp(
                0.0,
                scrollController.position.maxScrollExtent,
              );
              scrollController.jumpTo(target);
            });
          }
          previousMaxExtent.value = null;
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
          padding: const EdgeInsets.only(top: 12, bottom: 24),
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
              return _buildMessageEntry(context, message, isLast: isLast);
            }

            final message = messages[index];
            final isLast = index == messages.length - 1;
            return _buildMessageEntry(context, message, isLast: isLast);
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
                padding: MsgTheme.convoHPad(
                  context,
                ).add(const EdgeInsets.only(bottom: 8)),
                child: Text(
                  '$label for "${debouncedQuery.value}"',
                  style: MsgTheme.metadata,
                ),
              );
            }

            final messageIndex = index - 1;
            final message = results[messageIndex];
            final isLast = index == itemCount - 1;
            return _buildMessageEntry(
              context,
              message,
              isLast: isLast,
              highlightText: debouncedQuery.value,
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
            padding: MsgTheme.convoHPad(
              context,
            ).add(const EdgeInsets.fromLTRB(0, 12, 0, 8)),
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
      padding: MsgTheme.convoHPad(context),
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
        messageId: message.id,
        maxWidth: MsgTheme.maxBubbleWidth,
      );
    }

    if (imageAttachments.isNotEmpty) {
      final attachment = imageAttachments.first;
      return ImageMessageTile(
        isMe: message.isFromMe,
        file: File(_expandPath(attachment.localPath!)),
        sender: message.senderName,
        sentAt: message.sentAt ?? DateTime.now(),
        messageId: message.id,
      );
    }

    if (videoAttachments.isNotEmpty) {
      final attachment = videoAttachments.first;
      return VideoMessageTile(
        isMe: message.isFromMe,
        file: File(_expandPath(attachment.localPath!)),
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

  String _expandPath(String path) {
    if (path.startsWith('~/')) {
      final home = Platform.environment['HOME'] ?? '';
      return path.replaceFirst('~', home);
    }
    return path;
  }
}
