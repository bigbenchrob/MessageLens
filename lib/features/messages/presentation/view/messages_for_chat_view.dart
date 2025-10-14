import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../new_display_widgets.dart';
import '../view_model/messages_for_chat_provider.dart';
import '../widgets/message_link_preview_card.dart';

class MessagesForChatView extends HookConsumerWidget {
  const MessagesForChatView({required this.chatId, super.key});

  final int chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMessages = ref.watch(messagesForChatProvider(chatId: chatId));

    return asyncMessages.when(
      data: (messages) {
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

        return Material(
          color: Colors.white,
          child: ListView.builder(
            padding: MsgTheme.convoHPad(context),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return _buildMessageTile(message);
            },
          ),
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

  Widget _buildMessageTile(ChatMessageListItem message) {
    final urls = _extractUrls(message.text);
    final isPureUrlMessage =
        urls.length == 1 && message.text.trim() == urls.first;

    final AttachmentInfo? urlPreviewAttachment = _findAttachment(
      message.attachments,
      (attachment) {
        return attachment.isUrlPreview && attachment.localPath != null;
      },
    );

    final Iterable<AttachmentInfo> imageAttachments = message.attachments.where(
      (attachment) => attachment.isImage && attachment.localPath != null,
    );
    final Iterable<AttachmentInfo> videoAttachments = message.attachments.where(
      (attachment) => attachment.isVideo && attachment.localPath != null,
    );

    if (urlPreviewAttachment != null || isPureUrlMessage) {
      return MessageLinkPreviewCard(
        messageId: message.id,
        maxWidth: MsgTheme.maxBubbleWidth,
      );
    }

    if (imageAttachments.isNotEmpty) {
      final AttachmentInfo attachment = imageAttachments.first;
      return ImageMessageTile(
        isMe: message.isFromMe,
        file: File(_expandPath(attachment.localPath!)),
        sender: message.senderName,
        sentAt: message.sentAt ?? DateTime.now(),
        messageId: message.id,
      );
    }

    if (videoAttachments.isNotEmpty) {
      final AttachmentInfo attachment = videoAttachments.first;
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
