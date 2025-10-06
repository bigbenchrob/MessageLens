import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_player/video_player.dart';

import '../view_model/messages_for_chat_provider.dart';
import '../widgets/url_preview_widget.dart';

class MessagesForChatView extends HookConsumerWidget {
  const MessagesForChatView({required this.chatId, super.key});

  final int chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final asyncMessages = ref.watch(messagesForChatProvider(chatId: chatId));
    final dateFormatter = DateFormat('MMM d, yyyy • h:mm a');

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

        return ColoredBox(
          color: const Color(0xFFF9FAFB),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: MacosScrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: ListView.separated(
                controller: scrollController,
                itemCount: messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _MessageBubble(
                    message: message,
                    dateFormatter: dateFormatter,
                  );
                },
              ),
            ),
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
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.dateFormatter});

  final ChatMessageListItem message;
  final DateFormat dateFormatter;

  /// Extracts URLs from message text using a simple regex pattern
  List<String> _extractUrls(String text) {
    final urlPattern = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );
    final matches = urlPattern.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MacosTheme.of(context).brightness == Brightness.dark;
    final bubbleColor = message.isFromMe
        ? const Color(0xFF007AFF)
        : (isDark ? const Color(0xFF2C2C33) : Colors.white);
    final textColor = message.isFromMe
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF1C1C1E));
    final metadataColor = message.isFromMe
        ? Colors.white.withValues(alpha: 0.9)
        : const Color(0xFF6B6B70);

    String formatTimestamp(DateTime? timestamp) {
      if (timestamp == null) {
        return 'Unknown time';
      }
      return dateFormatter.format(timestamp);
    }

    final urls = _extractUrls(message.text);
    final isPureUrlMessage =
        urls.length == 1 && message.text.trim() == urls.first;

    // Check if this message has a URL preview attachment
    final hasUrlPreview = message.attachments.any(
      (a) => a.isUrlPreview && a.localPath != null,
    );

    // If there's a URL preview, render differently (no bubble)
    if (hasUrlPreview) {
      final urlPreviewAttachment = message.attachments.firstWhere(
        (a) => a.isUrlPreview && a.localPath != null,
      );

      return Align(
        alignment: message.isFromMe
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: message.isFromMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Just the lozenge
              _UrlPreviewAttachment(
                attachmentPath: urlPreviewAttachment.localPath!,
                transferName: urlPreviewAttachment.transferName,
                messageText: message.text,
                isFromMe: message.isFromMe,
              ),
              const SizedBox(height: 6),
              // Metadata below the lozenge (grey on transparent)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.paperclip,
                      size: 12,
                      color: Color(0xFF6B6B70),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatTimestamp(message.sentAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B6B70),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ID: ${message.id}',
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFF6B6B70).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isPureUrlMessage) {
      return Align(
        alignment: message.isFromMe
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: message.isFromMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              UrlPreviewWidget(url: urls.first),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatTimestamp(message.sentAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B6B70),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ID: ${message.id}',
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFF6B6B70).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Regular message bubble (no URL preview)
    return Align(
      alignment: message.isFromMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: message.isFromMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isFromMe)
                  Text(
                    message.senderName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: metadataColor,
                    ),
                  ),
                // Display attachments
                if (message.attachments.isNotEmpty) ...[
                  for (final attachment in message.attachments) ...[
                    if (attachment.isImage && attachment.localPath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ImageAttachment(
                          imagePath: attachment.localPath!,
                          transferName: attachment.transferName,
                        ),
                      )
                    else if (attachment.isVideo && attachment.localPath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _VideoAttachment(
                          videoPath: attachment.localPath!,
                          transferName: attachment.transferName,
                        ),
                      ),
                  ],
                ],
                Text(
                  message.text,
                  style: TextStyle(fontSize: 15, height: 1.4, color: textColor),
                ),
                // Display URL previews if URLs are detected in message text
                () {
                  if (urls.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: message.isFromMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      for (final url in urls) ...[
                        UrlPreviewWidget(url: url, maxWidth: 380),
                        if (urls.indexOf(url) < urls.length - 1)
                          const SizedBox(height: 8),
                      ],
                    ],
                  );
                }(),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.hasAttachments)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          CupertinoIcons.paperclip,
                          size: 14,
                          color: metadataColor,
                        ),
                      ),
                    Text(
                      formatTimestamp(message.sentAt),
                      style: TextStyle(fontSize: 11, color: metadataColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ID: ${message.id}',
                      style: TextStyle(
                        fontSize: 10,
                        color: metadataColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _expandPath(String path) {
  if (path.startsWith('~/')) {
    final home = Platform.environment['HOME'] ?? '';
    return path.replaceFirst('~', home);
  }
  return path;
}

class _ImageAttachment extends StatelessWidget {
  const _ImageAttachment({required this.imagePath, this.transferName});

  final String imagePath;
  final String? transferName;

  @override
  Widget build(BuildContext context) {
    final expandedPath = _expandPath(imagePath);
    final file = File(expandedPath);

    // Check if file exists
    if (!file.existsSync()) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.photo, size: 32, color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                'Image not found',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              if (transferName != null)
                Text(
                  transferName!,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 300),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      size: 32,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Error loading image',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (transferName != null)
                      Text(
                        transferName!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VideoAttachment extends HookWidget {
  const _VideoAttachment({required this.videoPath, this.transferName});

  final String videoPath;
  final String? transferName;

  @override
  Widget build(BuildContext context) {
    final expandedPath = _expandPath(videoPath);
    final file = File(expandedPath);

    // Check if file exists
    if (!file.existsSync()) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.videocam, size: 32, color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                'Video not found',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              if (transferName != null)
                Text(
                  transferName!,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      );
    }

    final controller = useMemoized(
      () => VideoPlayerController.file(file)..initialize(),
      [expandedPath],
    );

    useEffect(() {
      return controller.dispose;
    }, [controller]);

    final isInitialized = useState(false);
    final isPlaying = useState(false);

    useMemoized(() {
      controller.addListener(() {
        if (controller.value.isInitialized && !isInitialized.value) {
          isInitialized.value = true;
        }
        isPlaying.value = controller.value.isPlaying;
      });
    }, [controller]);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 300),
        child: !isInitialized.value
            ? Container(
                width: 400,
                height: 300,
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : GestureDetector(
                onTap: () {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                    if (!isPlaying.value)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.play_fill,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _UrlPreviewAttachment extends StatelessWidget {
  const _UrlPreviewAttachment({
    required this.attachmentPath,
    this.transferName,
    required this.messageText,
    required this.isFromMe,
  });

  final String attachmentPath;
  final String? transferName;
  final String messageText;
  final bool isFromMe;

  String? _extractUrl(String text) {
    final urlPattern = RegExp(r'https?://[^\s]+', caseSensitive: false);
    final match = urlPattern.firstMatch(text);
    return match?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    final url = _extractUrl(messageText);

    // If no URL found in message text, show a fallback
    if (url == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.link, size: 16, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'URL Preview',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Use the new Apple native preview widget
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show any post text above the preview (URL removed)
        () {
          final textWithoutUrl = messageText.replaceAll(url, '').trim();
          if (textWithoutUrl.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              textWithoutUrl,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Color(0xFF1C1C1E),
              ),
            ),
          );
        }(),
        // Native Apple preview
        UrlPreviewWidget(url: url),
      ],
    );
  }
}
