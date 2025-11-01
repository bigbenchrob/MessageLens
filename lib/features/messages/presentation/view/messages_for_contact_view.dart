import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../new_display_widgets.dart';
import '../view_model/attachment_info.dart';
import '../view_model/contact_messages_ordinal_provider.dart';
import '../view_model/message_by_contact_ordinal_provider.dart';
import '../view_model/messages_for_chat_provider.dart';
import '../widgets/message_link_preview_card.dart';

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
    final ordinalAsync = ref.watch(
      contactMessagesOrdinalProvider(contactId: contactId),
    );

    // Jump to specific month when scrollToDate is provided
    useEffect(() {
      if (scrollToDate == null) {
        return null;
      }

      final normalized = DateTime(scrollToDate!.year, scrollToDate!.month);
      final monthKey =
          '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}';

      Future.microtask(() async {
        final ordinalState = ref.read(
          contactMessagesOrdinalProvider(contactId: contactId),
        );
        if (ordinalState.hasValue) {
          await ref
              .read(
                contactMessagesOrdinalProvider(contactId: contactId).notifier,
              )
              .jumpToMonth(monthKey);
        }
      });

      return null;
    }, [contactId, scrollToDate]);

    return ordinalAsync.when<Widget>(
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

        // Start at the last (most recent) message, unless scrollToDate is specified
        final initialIndex = scrollToDate == null && state.totalCount > 0
            ? state.totalCount - 1
            : 0;

        return Column(
          children: [
            // Header showing contact info and message count
            _ContactMessagesHeader(
              contactId: contactId,
              totalMessages: state.totalCount,
            ),
            // Message list
            Expanded(
              child: ScrollablePositionedList.builder(
                initialScrollIndex: initialIndex,
                itemScrollController: state.itemScrollController,
                itemPositionsListener: state.itemPositionsListener,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.totalCount,
                itemBuilder: (context, ordinal) {
                  final isLast = ordinal == state.totalCount - 1;
                  return _ContactOrdinalMessageRow(
                    key: ValueKey('contact-msg-ordinal-$ordinal'),
                    contactId: contactId,
                    ordinal: ordinal,
                    buildMessage: (message) =>
                        _buildMessageEntry(context, message, isLast: isLast),
                  );
                },
              ),
            ),
          ],
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
  }

  Widget _buildMessageEntry(
    BuildContext context,
    ChatMessageListItem message, {
    required bool isLast,
  }) {
    return Padding(
      padding: MsgTheme.convoHPad(),
      child: Column(
        children: [_buildMessageTile(message), if (!isLast) MsgTheme.gapMD],
      ),
    );
  }

  Widget _buildMessageTile(ChatMessageListItem message) {
    final urls = _extractUrls(message.text);
    final isPureUrlMessage =
        urls.length == 1 && message.text.trim() == urls.first;

    final urlPreviewAttachment = message.attachments
        .cast<AttachmentInfo?>()
        .firstWhere((attachment) {
          return attachment != null &&
              attachment.isUrlPreview &&
              attachment.localPath != null;
        }, orElse: () => null);

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
    );
  }

  List<String> _extractUrls(String text) {
    final urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);
    return urlRegex.allMatches(text).map((m) => m.group(0)!).toList();
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
    final headerBackground = isDark ? const Color(0xFF1F1F24) : Colors.white;
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
  final Widget Function(ChatMessageListItem) buildMessage;

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
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
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
