import 'package:flutter/material.dart';

import '../view_model/messages_for_chat_provider.dart';
import '../view_model/new_display_widgets.dart';
import 'url_preview_widget.dart';

class MessageLinkPreviewCard extends StatelessWidget {
  const MessageLinkPreviewCard({
    super.key,
    required this.message,
    this.maxWidth = 420,
  });

  final ChatMessageListItem message;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return _LinkPreviewContent(message: message, maxWidth: maxWidth);
  }
}

class _LinkPreviewContent extends StatelessWidget {
  const _LinkPreviewContent({required this.message, required this.maxWidth});

  final ChatMessageListItem message;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final urls = _extractUrls(message.text);
    if (urls.isEmpty) {
      return _LinkPreviewError(
        messageId: message.id,
        error: 'Message does not contain a URL.',
      );
    }

    final firstUrl = urls.first;
    final sender = message.isFromMe ? 'You' : message.senderName;

    return Align(
      alignment: message.isFromMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: message.isFromMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            UrlPreviewWidget(url: firstUrl, maxWidth: maxWidth),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
              child: MetadataLine(
                sender: sender,
                sentAt: message.sentAt ?? DateTime.now(),
                messageId: message.id,
              ),
            ),
          ],
        ),
      ),
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
}

class _LinkPreviewError extends StatelessWidget {
  const _LinkPreviewError({required this.messageId, required this.error});

  final int messageId;
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF5C2C7)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, size: 16, color: Color(0xFFD14343)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Unable to load link preview for message $messageId: $error',
                style: const TextStyle(color: Color(0xFFD14343), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
