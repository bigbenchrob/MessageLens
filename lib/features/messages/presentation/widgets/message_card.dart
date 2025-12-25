import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../view_model/shared/display_widgets/new_display_widgets.dart';
import '../view_model/shared/hydration/attachment_info.dart';
import '../view_model/shared/hydration/messages_for_handle_provider.dart';
import 'message_link_preview_card.dart';

/// Shared message card widget used in both contact messages and global timeline views.
/// Handles all message types: text, images, videos, and link previews.
class MessageCard extends ConsumerWidget {
  const MessageCard({
    required this.message,
    this.emphasizeSender = false,
    super.key,
  });

  final MessageListItem message;

  /// If true, renders the sender name more prominently (for global timeline).
  /// If false, uses standard sender styling (for contact messages).
  final bool emphasizeSender;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.canvasColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with sender name and date
            Row(
              children: [
                Expanded(
                  child: Text(
                    message.senderName,
                    style: emphasizeSender
                        ? theme.typography.title3.copyWith(
                            fontWeight: FontWeight.w700,
                          )
                        : theme.typography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                ),
                if (message.sentAt != null)
                  Text(
                    _formatMessageDate(message.sentAt!),
                    style: theme.typography.callout.copyWith(
                      color: theme.typography.callout.color?.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Message content (text, image, video, or link preview)
            _buildMessageContent(context),
          ],
        ),
      ),
    );
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
        maxWidth: 600, // MsgTheme.maxBubbleWidth
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
    return Text(message.text, style: MacosTheme.of(context).typography.body);
  }

  List<String> _extractUrls(String text) {
    final urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);
    return urlRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }
}

/// Formats a message date for display.
/// Shows time for today, "Yesterday" + time, or full date for older messages.
String _formatMessageDate(DateTime date) {
  final now = DateTime.now();
  final localDate = date.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final messageDate = DateTime(localDate.year, localDate.month, localDate.day);

  final difference = today.difference(messageDate).inDays;

  if (difference == 0) {
    // Today: show time only
    return DateFormat('h:mm a').format(localDate);
  } else if (difference == 1) {
    // Yesterday
    return 'Yesterday ${DateFormat('h:mm a').format(localDate)}';
  } else if (difference < 7) {
    // This week: show day name
    return DateFormat('EEE h:mm a').format(localDate);
  } else if (localDate.year == now.year) {
    // This year: show month and day
    return DateFormat('MMM d, h:mm a').format(localDate);
  } else {
    // Previous years: show full date
    return DateFormat('MMM d, yyyy').format(localDate);
  }
}
