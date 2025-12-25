import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../hydration/attachment_info.dart';

// ignore: avoid_classes_with_only_static_members
class MsgTheme {
  static const maxBubbleWidth = 520.0;
  static const bubblePadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const mediaRadius = BorderRadius.all(Radius.circular(14));
  static const textRadius = BorderRadius.all(Radius.circular(16));
  static const gapXS = SizedBox(height: 4);
  static const gapMD = SizedBox(height: 12);

  static const bubbleBlue = Color(0xFF0A84FF);
  static const bubbleGray = Color(0xFFE9E9EB);
  static const metadataGrey = Color(0xFF6E6E73);
  static const outline = Color(0x1F000000);
  static const linkBannerBlack = Colors.black;
  static const highlightOnBlue = Color(0xFF0056B3);
  static const highlightOnGray = Color(0xFFB3D7FF);

  static TextStyle get bodyOnBlue =>
      const TextStyle(color: Colors.white, height: 1.25, fontSize: 14.5);

  static TextStyle get bodyOnGray =>
      const TextStyle(color: Colors.black, height: 1.25, fontSize: 14.5);

  static TextStyle get metadata =>
      const TextStyle(color: metadataGrey, fontSize: 11, height: 1.2);

  static EdgeInsets convoHPad() => const EdgeInsets.symmetric(horizontal: 14);
}

class MessageShell extends StatelessWidget {
  const MessageShell({
    super.key,
    required this.isMe,
    required this.child,
    this.metadata,
  });

  final bool isMe;
  final Widget child;
  final Widget? metadata;

  @override
  Widget build(BuildContext context) {
    final bubbleRow = Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: MsgTheme.maxBubbleWidth),
          child: child,
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          bubbleRow,
          if (metadata != null) ...[MsgTheme.gapXS, metadata!],
        ],
      ),
    );
  }
}

class MetadataLine extends StatelessWidget {
  const MetadataLine({
    super.key,
    required this.sender,
    required this.sentAt,
    required this.messageId,
  });

  final String sender;
  final DateTime sentAt;
  final int messageId;

  @override
  Widget build(BuildContext context) {
    final formattedDateTime = _formatDateTime(sentAt);
    return Text(
      '$sender * $formattedDateTime * ID: $messageId',
      style: MsgTheme.metadata,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final year = dateTime.year;
    return '$weekday, $month $day, $year $hour12:$minute $amPm';
  }
}

class TextMessageTile extends StatelessWidget {
  const TextMessageTile({
    super.key,
    required this.isMe,
    required this.text,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.highlight,
  });

  final bool isMe;
  final String text;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? MsgTheme.bubbleBlue : MsgTheme.bubbleGray;
    final style = isMe ? MsgTheme.bodyOnBlue : MsgTheme.bodyOnGray;
    final highlightStyle = style.copyWith(
      backgroundColor: isMe
          ? MsgTheme.highlightOnBlue
          : MsgTheme.highlightOnGray,
    );
    final contentSpan = _buildContentSpan(
      baseStyle: style,
      highlightStyle: highlightStyle,
    );

    return MessageShell(
      isMe: isMe,
      metadata: MetadataLine(
        sender: sender,
        sentAt: sentAt,
        messageId: messageId,
      ),
      child: Container(
        padding: MsgTheme.bubblePadding,
        decoration: BoxDecoration(color: bg, borderRadius: MsgTheme.textRadius),
        child: SelectableText.rich(contentSpan),
      ),
    );
  }

  TextSpan _buildContentSpan({
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
  }) {
    final query = highlight?.trim();
    if (query == null || query.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;
    var matchIndex = lowerText.indexOf(lowerQuery, start);

    while (matchIndex != -1) {
      if (matchIndex > start) {
        spans.add(
          TextSpan(text: text.substring(start, matchIndex), style: baseStyle),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(matchIndex, matchIndex + query.length),
          style: highlightStyle,
        ),
      );
      start = matchIndex + query.length;
      matchIndex = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }

    if (spans.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    return TextSpan(children: spans);
  }
}

class ImageMessageTile extends StatelessWidget {
  const ImageMessageTile({
    super.key,
    required this.isMe,
    required this.attachment,
    required this.sender,
    required this.sentAt,
    required this.messageId,
  });

  final bool isMe;
  final AttachmentInfo attachment;
  final String sender;
  final DateTime sentAt;
  final int messageId;

  @override
  Widget build(BuildContext context) {
    final resolvedPath = attachment.resolvedLocalPath();
    final file = resolvedPath != null ? File(resolvedPath) : null;
    final exists = file?.existsSync() ?? false;
    final aspectRatio = attachment.aspectRatio ?? 4 / 3;

    return MessageShell(
      isMe: isMe,
      metadata: MetadataLine(
        sender: sender,
        sentAt: sentAt,
        messageId: messageId,
      ),
      child: ClipRRect(
        borderRadius: MsgTheme.mediaRadius,
        child: _IntrinsicSizedMedia(
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Colors.black12),
                if (exists)
                  Image.file(
                    file!,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  )
                else
                  const Center(child: Text('Image unavailable')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VideoMessageTile extends StatefulWidget {
  const VideoMessageTile({
    super.key,
    required this.isMe,
    required this.attachment,
    required this.sender,
    required this.sentAt,
    required this.messageId,
  });

  final bool isMe;
  final AttachmentInfo attachment;
  final String sender;
  final DateTime sentAt;
  final int messageId;

  @override
  State<VideoMessageTile> createState() => _VideoMessageTileState();
}

class _VideoMessageTileState extends State<VideoMessageTile> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final resolvedPath = widget.attachment.resolvedLocalPath();
    if (resolvedPath == null) {
      return;
    }
    final file = File(resolvedPath);
    if (!file.existsSync()) {
      return;
    }
    _controller = VideoPlayerController.file(file)
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _ready = true;
        });
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller == null || !_ready) {
      return;
    }
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = widget.attachment.aspectRatio ?? 16 / 9;
    final hasVideo = _controller != null;

    return MessageShell(
      isMe: widget.isMe,
      metadata: MetadataLine(
        sender: widget.sender,
        sentAt: widget.sentAt,
        messageId: widget.messageId,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: MsgTheme.mediaRadius,
          border: Border.all(color: MsgTheme.outline),
        ),
        child: ClipRRect(
          borderRadius: MsgTheme.mediaRadius,
          child: _IntrinsicSizedMedia(
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  const ColoredBox(color: Colors.black26),
                  if (hasVideo && _ready)
                    VideoPlayer(_controller!)
                  else if (hasVideo)
                    const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    const Center(child: Text('Video unavailable')),
                  if (hasVideo)
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _toggle,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: _controller!.value.isPlaying ? 0.0 : 1.0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _controller!.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (hasVideo && _ready)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LinkPreviewTile extends StatelessWidget {
  const LinkPreviewTile({
    super.key,
    required this.isMe,
    required this.url,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.previewImage,
    this.previewImageWidget,
    this.previewText,
  }) : assert(
         previewImage != null || previewImageWidget != null,
         'Provide either previewImage or previewImageWidget',
       );

  final bool isMe;
  final Uri url;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final File? previewImage;
  final Widget? previewImageWidget;
  final String? previewText;

  @override
  Widget build(BuildContext context) {
    final domain = url.host;
    final image =
        previewImageWidget ??
        Image.file(
          previewImage!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        );

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: MsgTheme.mediaRadius,
        border: Border.all(color: MsgTheme.outline),
      ),
      child: ClipRRect(
        borderRadius: MsgTheme.mediaRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _IntrinsicSizedMedia(child: image),
            Container(
              color: MsgTheme.linkBannerBlack,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                domain,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if ((previewText ?? '').trim().isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Text(
                  previewText!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return MessageShell(
      isMe: isMe,
      metadata: MetadataLine(
        sender: sender,
        sentAt: sentAt,
        messageId: messageId,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: () => _launch(url), child: card),
      ),
    );
  }

  Future<void> _launch(Uri target) async {
    if (!await launchUrl(target, mode: LaunchMode.externalApplication)) {
      // Optional: surface failure to caller.
    }
  }
}

class _IntrinsicSizedMedia extends StatelessWidget {
  const _IntrinsicSizedMedia({required this.child});

  final Widget child;

  static const double _maxHeight = 420;
  static const double _minHeight = 140;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _minHeight,
            maxHeight: _maxHeight,
          ),
          child: child,
        );
      },
    );
  }
}

enum MsgType { text, image, video, link }

class DemoMessage {
  DemoMessage({
    required this.type,
    required this.isMe,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.text,
    this.file,
    this.url,
    this.previewText,
  });

  final MsgType type;
  final bool isMe;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final String? text;
  final File? file;
  final Uri? url;
  final String? previewText;
}

class DemoConversationList extends StatelessWidget {
  const DemoConversationList({super.key, required this.items});

  final List<DemoMessage> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: MsgTheme.convoHPad(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final message = items[index];
        switch (message.type) {
          case MsgType.text:
            return TextMessageTile(
              isMe: message.isMe,
              text: message.text ?? '',
              sender: message.sender,
              sentAt: message.sentAt,
              messageId: message.messageId,
            );
          case MsgType.image:
            return ImageMessageTile(
              isMe: message.isMe,
              attachment: AttachmentInfo(
                id: message.messageId,
                localPath: message.file?.path,
                mimeType: 'image/*',
                transferName: message.file?.path,
              ),
              sender: message.sender,
              sentAt: message.sentAt,
              messageId: message.messageId,
            );
          case MsgType.video:
            return VideoMessageTile(
              isMe: message.isMe,
              attachment: AttachmentInfo(
                id: message.messageId,
                localPath: message.file?.path,
                mimeType: 'video/*',
                transferName: message.file?.path,
              ),
              sender: message.sender,
              sentAt: message.sentAt,
              messageId: message.messageId,
            );
          case MsgType.link:
            return LinkPreviewTile(
              isMe: message.isMe,
              url: message.url!,
              sender: message.sender,
              sentAt: message.sentAt,
              messageId: message.messageId,
              previewImage: message.file,
              previewText: message.previewText,
            );
        }
      },
    );
  }
}
