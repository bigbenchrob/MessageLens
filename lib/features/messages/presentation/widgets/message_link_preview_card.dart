import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../view_model/message_by_id_provider.dart';
import '../view_model/messages_for_chat_provider.dart';
import 'url_preview_widget.dart';

class MessageLinkPreviewCard extends ConsumerWidget {
  const MessageLinkPreviewCard({
    super.key,
    required this.messageId,
    this.maxWidth = 420,
  });

  final int messageId;
  final double maxWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMessage = ref.watch(messageByIdProvider(messageId: messageId));

    return asyncMessage.when<Widget>(
      data: (ChatMessageListItem message) =>
          _LinkPreviewContent(message: message, maxWidth: maxWidth),
      loading: () => const Center(child: ProgressCircle(radius: 12)),
      error: (Object error, _) =>
          _LinkPreviewError(messageId: messageId, error: error),
    );
  }
}

class _LinkPreviewContent extends StatelessWidget {
  const _LinkPreviewContent({required this.message, required this.maxWidth});

  final ChatMessageListItem message;
  final double maxWidth;

  static const _metadataColor = Color(0xFF6B6B70);
  static final _dateFormat = DateFormat('MMM d, yyyy • h:mm a');

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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTimestamp(message.sentAt),
                    style: const TextStyle(fontSize: 11, color: _metadataColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ID: ${message.id}',
                    style: const TextStyle(fontSize: 10, color: _metadataColor),
                  ),
                ],
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

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) {
      return 'Unknown time';
    }
    return _dateFormat.format(timestamp);
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
