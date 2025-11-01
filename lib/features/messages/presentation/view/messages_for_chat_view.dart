import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../infrastructure/data_sources/message_index_data_source.dart';
import '../new_display_widgets.dart';
import '../view_model/attachment_info.dart';
import '../view_model/chat_header_info_provider.dart';
import '../view_model/chat_message_search_provider.dart';
import '../view_model/chat_messages_ordinal_provider.dart';
import '../view_model/messages_for_chat_provider.dart';
import '../widgets/message_link_preview_card.dart';
import '../widgets/ordinal_message_row.dart';

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
    final ordinalAsync = ref.watch(chatMessagesOrdinalProvider(chatId: chatId));
    final searchScrollController = useScrollController();
    final hasAutoScrolled = useRef(false);
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

    // Separate effect for scrollToDate changes (allows re-scrolling without reloading)
    useEffect(() {
      hasAutoScrolled.value = false;
      return null;
    }, [scrollToDate]);

    // Jump to specific month when scrollToDate is provided
    useEffect(() {
      if (scrollToDate == null) {
        return null;
      }

      final normalized = DateTime(scrollToDate!.year, scrollToDate!.month);
      final monthKey =
          '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}';
      print(
        '[MESSAGES_VIEW] scrollToDate effect triggered: '
        'raw=$scrollToDate, monthKey=$monthKey',
      );
      Future.microtask(() async {
        final ordinalState = ref.read(
          chatMessagesOrdinalProvider(chatId: chatId),
        );
        if (ordinalState.hasValue) {
          await ref
              .read(chatMessagesOrdinalProvider(chatId: chatId).notifier)
              .jumpToMonth(monthKey);
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

    // Ordinal system: No scroll listener needed - ScrollablePositionedList
    // automatically loads items on-demand as user scrolls

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
                  'No messages in this chat yet.',
                  style: TextStyle(color: Color(0xFF7A7A7F)),
                ),
              ],
            ),
          );
        }

        // Start at the last (most recent) message, unless scrollToDate is specified
        final initialIndex = scrollToDate == null && state.totalCount > 0
            ? state.totalCount - 1
            : 0;

        return ScrollablePositionedList.builder(
          initialScrollIndex: initialIndex,
          itemScrollController: state.itemScrollController,
          itemPositionsListener: state.itemPositionsListener,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.totalCount,
          itemBuilder: (context, ordinal) {
            final isLast = ordinal == state.totalCount - 1;
            return OrdinalMessageRow(
              key: ValueKey('msg-ordinal-$ordinal'),
              chatId: chatId,
              ordinal: ordinal,
              buildMessage: (message) =>
                  _buildMessageEntry(context, message, isLast: isLast),
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
      data: (info) => _MessagesHeader(info: info, chatId: chatId),
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

class _MessagesHeader extends HookConsumerWidget {
  const _MessagesHeader({required this.info, required this.chatId});

  final ChatHeaderInfo info;
  final int chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macosTheme = MacosTheme.of(context);
    final typography = macosTheme.typography;
    final isDark = macosTheme.brightness == Brightness.dark;

    // Track visible month based on scroll position
    final visibleMonth = useState<String?>('Oct 2025'); // Default to latest

    // Watch ordinal state to get position listener
    final ordinalAsync = ref.watch(chatMessagesOrdinalProvider(chatId: chatId));
    final dbAsync = ref.watch(driftWorkingDatabaseProvider);

    useEffect(() {
      return ordinalAsync.whenOrNull(
        data: (state) {
          void listener() {
            final positions = state.itemPositionsListener.itemPositions.value;
            if (positions.isNotEmpty) {
              // Get the topmost visible item
              final topItem = positions.reduce(
                (a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b,
              );

              // Query the month for this ordinal from message_index table
              dbAsync.whenData((db) {
                final indexSource = MessageIndexDataSource(db);
                indexSource.getMonthKeyForOrdinal(chatId, topItem.index).then((
                  monthKey,
                ) {
                  if (monthKey != null) {
                    visibleMonth.value = monthKey;
                  }
                });
              });
            }
          }

          state.itemPositionsListener.itemPositions.addListener(listener);
          return () => state.itemPositionsListener.itemPositions.removeListener(
            listener,
          );
        },
      );
    }, [ordinalAsync, dbAsync]);

    // Format display names
    final displayName = info.title;
    final subtitle = info.handles.isNotEmpty ? info.handles.first : null;

    // Format date range
    final dateRangeText = _formatDateRange(
      info.firstMessageDate,
      info.lastMessageDate,
    );

    // Format message count with spaces
    final messageCountText = _formatMessageCount(info.messageCount);

    final headerBackground = isDark ? const Color(0xFF1F1F24) : Colors.white;
    final dividerColor = isDark
        ? const Color(0xFF38383D)
        : const Color(0xFFE5E5EA);

    return ColoredBox(
      color: headerBackground,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line 1: Avatar + Name
            Row(
              children: [
                // Avatar or initials
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _generateAvatarColor(displayName, isDark),
                  child: Text(
                    _getInitials(displayName),
                    style: typography.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayName,
                    style: typography.title1.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Line 2: Handle (phone number/email)
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Text(
                  subtitle,
                  style: typography.body.copyWith(
                    fontSize: 13,
                    color:
                        (isDark
                                ? MacosColors.systemGrayColor
                                : MacosColors.systemGrayColor.darkColor)
                            .withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // Divider
            const SizedBox(height: 12),
            Container(height: 0.5, color: dividerColor),
            const SizedBox(height: 12),

            // Line 3: Metadata chips
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _InfoChip(label: '$messageCountText messages', isDark: isDark),
                if (dateRangeText != null)
                  _InfoChip(label: dateRangeText, isDark: isDark),
                // Animated month indicator
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _InfoChip(
                    key: ValueKey(visibleMonth.value),
                    label: 'Showing: ${visibleMonth.value ?? "—"}',
                    isDark: isDark,
                    isHighlighted: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) {
      return '?';
    }
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  Color _generateAvatarColor(String name, bool isDark) {
    // Generate consistent color based on name
    final hash = name.hashCode.abs();
    final colors = isDark
        ? [
            const Color(0xFF5E81AC),
            const Color(0xFFBF616A),
            const Color(0xFFD08770),
            const Color(0xFFEBCB8B),
            const Color(0xFFA3BE8C),
            const Color(0xFFB48EAD),
          ]
        : [
            const Color(0xFF4C9AFF),
            const Color(0xFFE94B3C),
            const Color(0xFFFF8B00),
            const Color(0xFFFFC400),
            const Color(0xFF36B37E),
            const Color(0xFF6554C0),
          ];
    return colors[hash % colors.length];
  }

  String? _formatDateRange(DateTime? first, DateTime? last) {
    if (first == null || last == null) {
      return null;
    }

    final firstFormat = DateFormat('MMM yyyy');
    final lastFormat = DateFormat('MMM yyyy');

    final firstStr = firstFormat.format(first);
    final lastStr = lastFormat.format(last);

    if (firstStr == lastStr) {
      return firstStr;
    }

    return '$firstStr – $lastStr';
  }

  String _formatMessageCount(int count) {
    // Format with spaces as thousands separator (e.g., "53 081")
    final str = count.toString();
    if (str.length <= 3) {
      return str;
    }

    final reversed = str.split('').reversed.toList();
    final chunks = <String>[];

    for (var i = 0; i < reversed.length; i += 3) {
      final end = i + 3;
      final chunk = reversed.sublist(
        i,
        end > reversed.length ? reversed.length : end,
      );
      chunks.add(chunk.reversed.join());
    }

    return chunks.reversed.join(' ');
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
    super.key,
    required this.label,
    required this.isDark,
    this.isHighlighted = false,
  });

  final String label;
  final bool isDark;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isHighlighted
        ? (isDark ? const Color(0xFF3A4A5C) : const Color(0xFFE0ECFF))
        : (isDark ? const Color(0xFF2D2D35) : const Color(0xFFF3F4F6));

    final textColor = isHighlighted
        ? (isDark ? const Color(0xFFBFD6FF) : const Color(0xFF1D4ED8))
        : (isDark ? const Color(0xFFAAB1C1) : const Color(0xFF6B7280));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: MacosTheme.of(context).typography.caption1.copyWith(
            color: textColor,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
