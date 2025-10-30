import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../new_display_widgets.dart';
import '../view_model/attachment_info.dart';
import '../view_model/chat_header_info_provider.dart';
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
    final headerAsync = ref.watch(chatHeaderInfoProvider(chatId: chatId));
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
      print(
        '[MESSAGES_VIEW] scrollToDate effect triggered: '
        'raw=$scrollToDate, normalized=$normalized',
      );
      Future.microtask(() async {
        // Wait for the provider to finish its initial build with polling
        var retries = 0;
        while (retries < 50) {
          final pagerState = ref.read(
            chatMessagesPagerProvider(chatId: chatId),
          );
          if (pagerState.hasValue) {
            print('[MESSAGES_VIEW] Provider ready after $retries retries');
            // Provider is ready, now ensure the target month is loaded
            await ref
                .read(chatMessagesPagerProvider(chatId: chatId).notifier)
                .ensureMonthLoaded(normalized);
            break;
          }
          retries++;
          if (retries % 10 == 0) {
            print(
              '[MESSAGES_VIEW] Still waiting for provider (attempt $retries)',
            );
          }
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        if (retries >= 50) {
          print(
            '[MESSAGES_VIEW] Gave up waiting for provider after $retries attempts',
          );
        }
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
            final capturedExtentBefore = previousExtentBefore.value!;
            final capturedScrollOffset = previousScrollOffset.value!;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!scrollController.hasClients) {
                return;
              }
              // When loading older messages at top, new content increases the
              // extentBefore value by exactly the height inserted above the
              // current viewport. Adjust by that delta so the same message
              // stays pinned after the load completes.
              final newExtentBefore = scrollController.position.extentBefore;
              final delta = newExtentBefore - capturedExtentBefore;
              final target = (capturedScrollOffset + delta).clamp(
                0.0,
                scrollController.position.maxScrollExtent,
              );
              logJump(
                'jumpTo after loadOlder prevExtent='
                '$capturedExtentBefore newExtent=$newExtentBefore '
                'delta=$delta prevOffset=$capturedScrollOffset '
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
    final header = headerAsync.when(
      data: (info) => _MessagesHeader(info: info),
      loading: () => const _MessagesHeaderLoading(),
      error: (error, stackTrace) => _MessagesHeaderError(error: error),
    );

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          header,
          const Divider(height: 1),
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

class _MessagesHeader extends StatelessWidget {
  const _MessagesHeader({required this.info});

  final ChatHeaderInfo info;

  @override
  Widget build(BuildContext context) {
    final macosTheme = MacosTheme.of(context);
    final typography = macosTheme.typography;
    final isDark = macosTheme.brightness == Brightness.dark;

    final visibleParticipants = info.participants.length > 3
        ? [
            ...info.participants.take(3),
            '+${info.participants.length - 3} more',
          ]
        : info.participants;

    final visibleHandles = info.handles.length > 2
        ? [...info.handles.take(2), '+${info.handles.length - 2} more']
        : info.handles;

    final formatter = DateFormat('MMM d, yyyy • h:mm a');
    final lastLabel = info.lastMessageDate != null
        ? formatter.format(info.lastMessageDate!)
        : 'No messages yet';
    final messageLabel = info.messageCount == 1
        ? '1 message'
        : '${info.messageCount} messages';

    final metadataChips = <Widget>[
      _MetadataBadge(
        icon: CupertinoIcons.chat_bubble_text_fill,
        label: messageLabel,
        isDark: isDark,
      ),
      if (info.recency != null)
        _MetadataBadge(
          icon: CupertinoIcons.time,
          label: info.recency!.label,
          isDark: isDark,
        ),
      _MetadataBadge(
        icon: CupertinoIcons.calendar,
        label: lastLabel,
        isDark: isDark,
      ),
    ];

    final headerBackground = isDark ? const Color(0xFF1F1F24) : Colors.white;

    return ColoredBox(
      color: headerBackground,
      child: Padding(
        padding: MsgTheme.convoHPad().add(
          const EdgeInsets.fromLTRB(0, 16, 0, 12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Messages',
              style: typography.largeTitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              info.title,
              style: typography.title1.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: visibleParticipants
                  .map(
                    (name) => _InfoChip(
                      label: name,
                      isDark: isDark,
                      isSecondary: false,
                    ),
                  )
                  .toList(),
            ),
            if (visibleHandles.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: visibleHandles
                    .map(
                      (handle) => _InfoChip(
                        label: handle,
                        isDark: isDark,
                        isSecondary: true,
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 8, children: metadataChips),
          ],
        ),
      ),
    );
  }
}

class _MessagesHeaderLoading extends StatelessWidget {
  const _MessagesHeaderLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MsgTheme.convoHPad().add(
        const EdgeInsets.fromLTRB(0, 20, 0, 20),
      ),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: ProgressCircle(radius: 12),
      ),
    );
  }
}

class _MessagesHeaderError extends StatelessWidget {
  const _MessagesHeaderError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MsgTheme.convoHPad().add(
        const EdgeInsets.fromLTRB(0, 16, 0, 12),
      ),
      child: Text(
        'Unable to load conversation details. $error',
        style: const TextStyle(color: Color(0xFFD14343)),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.isDark,
    required this.isSecondary,
  });

  final String label;
  final bool isDark;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSecondary
        ? (isDark ? const Color(0xFF31313A) : const Color(0xFFF1F5F9))
        : (isDark ? const Color(0xFF24304D) : const Color(0xFFE0ECFF));
    final textColor = isSecondary
        ? (isDark ? const Color(0xFFC8CCD8) : const Color(0xFF4B5563))
        : (isDark ? const Color(0xFFBFD6FF) : const Color(0xFF1D4ED8));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: MacosTheme.of(context).typography.caption1.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MetadataBadge extends StatelessWidget {
  const _MetadataBadge({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark
        ? const Color(0xFF2D2D35)
        : const Color(0xFFF3F4F6);
    final foregroundColor = isDark
        ? const Color(0xFFAAB1C1)
        : const Color(0xFF4B5563);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: foregroundColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: MacosTheme.of(context).typography.caption1.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
