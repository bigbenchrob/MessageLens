// lib/widgets/message_tiles.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

/// ---- Design tokens & helpers ------------------------------------------------

class MsgTheme {
  // Sizing
  static const maxBubbleWidth = 520.0; // generous on macOS
  static const bubblePadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const mediaRadius = BorderRadius.all(Radius.circular(14));
  static const textRadius = BorderRadius.all(Radius.circular(16));
  static const gapXS = SizedBox(height: 4);
  static const gapSM = SizedBox(height: 8);
  static const gapMD = SizedBox(height: 12);

  // Colors
  static const bubbleBlue = Color(0xFF0A84FF); // macOS accent-ish blue
  static const bubbleGray = Color(0xFFE9E9EB); // iMessage-ish gray
  static const metadataGrey = Color(0xFF6E6E73); // SF secondary label-ish
  static const outline = Color(0x1F000000); // subtle border on white
  static const linkBannerBlack = Colors.black;

  // Text styles
  static TextStyle get bodyOnBlue =>
      const TextStyle(color: Colors.white, height: 1.25, fontSize: 14.5);

  static TextStyle get bodyOnGray =>
      const TextStyle(color: Colors.black, height: 1.25, fontSize: 14.5);

  static TextStyle get metadata =>
      const TextStyle(color: metadataGrey, fontSize: 11, height: 1.2);

  // Layout helper for left / right
  static Alignment alignmentFor(bool isMe) =>
      isMe ? Alignment.centerRight : Alignment.centerLeft;

  // Horizontal padding of the conversation viewport
  static EdgeInsets convoHPad(BuildContext context) =>
      const EdgeInsets.symmetric(horizontal: 14);
}

/// A thin shell that applies alignment (left/right), width clamp, and outer padding.
/// Everything sits on white; metadata also goes on white (by requirement).
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

/// The metadata line: tiny grey text on white background.
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
    final ts = TimeOfDay.fromDateTime(sentAt);
    final date = MaterialLocalizations.of(context).formatMediumDate(sentAt);
    final time = ts.format(context);
    return Text(
      '$sender • $date $time • ID: $messageId',
      style: MsgTheme.metadata,
    );
  }
}

/// ---- 1) Plain text message --------------------------------------------------

class TextMessageTile extends StatelessWidget {
  const TextMessageTile({
    super.key,
    required this.isMe,
    required this.text,
    required this.sender,
    required this.sentAt,
    required this.messageId,
  });

  final bool isMe;
  final String text;
  final String sender;
  final DateTime sentAt;
  final int messageId;

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? MsgTheme.bubbleBlue : MsgTheme.bubbleGray;
    final style = isMe ? MsgTheme.bodyOnBlue : MsgTheme.bodyOnGray;

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
        child: SelectableText(text, style: style),
      ),
    );
  }
}

/// ---- 2) Image message (full-size look, rounded corners) --------------------

class ImageMessageTile extends StatelessWidget {
  const ImageMessageTile({
    super.key,
    required this.isMe,
    required this.file,
    required this.sender,
    required this.sentAt,
    required this.messageId,
  });

  final bool isMe;
  final File file;
  final String sender;
  final DateTime sentAt;
  final int messageId;

  @override
  Widget build(BuildContext context) {
    return MessageShell(
      isMe: isMe,
      metadata: MetadataLine(
        sender: sender,
        sentAt: sentAt,
        messageId: messageId,
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
            child: Image.file(
              file,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}

/// ---- 3) Video message (rounded, with simple controls) ----------------------

class VideoMessageTile extends StatefulWidget {
  const VideoMessageTile({
    super.key,
    required this.isMe,
    required this.file,
    required this.sender,
    required this.sentAt,
    required this.messageId,
  });

  final bool isMe;
  final File file;
  final String sender;
  final DateTime sentAt;
  final int messageId;

  @override
  State<VideoMessageTile> createState() => _VideoMessageTileState();
}

class _VideoMessageTileState extends State<VideoMessageTile> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) setState(() => _ready = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!_ready) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final media = !_ready
        ? const AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        : AspectRatio(
            aspectRatio: _controller.value.aspectRatio == 0
                ? 16 / 9
                : _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                IgnorePointer(
                  ignoring: false,
                  child: GestureDetector(
                    onTap: _toggle,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                  ),
                ),
              ],
            ),
          );

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
          child: _IntrinsicSizedMedia(child: media),
        ),
      ),
    );
  }
}

/// ---- 4) Link preview (image → black URL banner → preview text) -------------
/// Pass in the values you obtain from Apple's LinkPresentation bridge.
/// Entire card (image + banner + preview text) is clickable. Metadata is not.
class LinkPreviewTile extends StatelessWidget {
  const LinkPreviewTile({
    super.key,
    required this.isMe,
    required this.url,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.previewImage, // full-size image bytes or from file
    this.previewImageWidget, // or provide a ready widget (e.g., Image.memory)
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
            // Black URL banner (white text), flush to image width
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
            if ((previewText ?? '').trim().isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                // stay on white; do not use blue/gray here
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
      child: InkWell(onTap: () => _launch(url), child: card),
    );
  }

  Future<void> _launch(Uri u) async {
    if (!await launchUrl(u, mode: LaunchMode.externalApplication)) {
      // Optionally show a snackbar in caller
    }
  }
}

/// ---- Shared: keep media looking "full-size" without tiny thumbnails --------
/// Expands media to a reasonable height while preserving intrinsic aspect.
/// - If the image/video is very tall (portrait), it will still look big but not
///   exceed a reasonable max height.
/// - If it’s landscape, it gets breathing room horizontally.
class _IntrinsicSizedMedia extends StatelessWidget {
  const _IntrinsicSizedMedia({required this.child});

  final Widget child;

  static const double _maxHeight = 420; // generous on desktop
  static const double _minHeight = 140;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, bc) {
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

/// ---- Example usage in a ListView -------------------------------------------
/// NOTE: Replace this with your real message model & builder switch.
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
      padding: MsgTheme.convoHPad(context),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final m = items[i];
        switch (m.type) {
          case MsgType.text:
            return TextMessageTile(
              isMe: m.isMe,
              text: m.text ?? '',
              sender: m.sender,
              sentAt: m.sentAt,
              messageId: m.messageId,
            );
          case MsgType.image:
            return ImageMessageTile(
              isMe: m.isMe,
              file: m.file!,
              sender: m.sender,
              sentAt: m.sentAt,
              messageId: m.messageId,
            );
          case MsgType.video:
            return VideoMessageTile(
              isMe: m.isMe,
              file: m.file!,
              sender: m.sender,
              sentAt: m.sentAt,
              messageId: m.messageId,
            );
          case MsgType.link:
            return LinkPreviewTile(
              isMe: m.isMe,
              url: m.url!,
              sender: m.sender,
              sentAt: m.sentAt,
              messageId: m.messageId,
              previewImage: m.file, // or use previewImageWidget:
              previewText: m.previewText,
            );
        }
      },
    );
  }
}
