import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../view_model/shared/display_widgets/new_display_widgets.dart';
import '../view_model/shared/hydration/attachment_info.dart';
import '../view_model/shared/hydration/messages_for_handle_provider.dart';
import 'message_link_preview_card.dart';

/// Shared message card widget used in both contact messages and global timeline views.
/// Handles all message types: text, images, videos, and link previews.
/// Uses bubble-style layout with metadata underneath.
class MessageCard extends ConsumerWidget {
  const MessageCard({required this.message, super.key});

  final MessageListItem message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildMessageContent(context);
  }

  Widget _buildMessageContent(BuildContext context) {
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

    // Link preview (has priority if present)
    if (urlPreviewAttachment != null || isPureUrlMessage) {
      return MessageLinkPreviewCard(
        message: message,
        maxWidth: MsgTheme.maxBubbleWidth,
      );
    }

    // Image attachment
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

    // Video attachment
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

    // Plain text message
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
