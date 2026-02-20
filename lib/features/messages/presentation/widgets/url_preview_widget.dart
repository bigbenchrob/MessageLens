import 'dart:async';

import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../essentials/services/native_link_preview_service.dart';

const double _cardHeight = 226;
const double _mediaHeight = 130;
const Duration _fallbackDelay = Duration(seconds: 10);
const Duration _transitionDuration = Duration(milliseconds: 180);

/// Rich URL preview widget for displaying link metadata in messages.
/// Shows image, title, and site name with a clean, tappable design while
/// keeping the layout stable when previews load asynchronously.
class UrlPreviewWidget extends StatefulWidget {
  const UrlPreviewWidget({required this.url, this.maxWidth = 400, super.key});

  final String url;
  final double maxWidth;

  @override
  State<UrlPreviewWidget> createState() => _UrlPreviewWidgetState();
}

class _UrlPreviewWidgetState extends State<UrlPreviewWidget> {
  final _previewService = NativeLinkPreviewService();

  NativeLinkMetadata? _metadata;
  bool _showFallback = false;
  Timer? _fallbackTimer;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMetadata(resetState: false));
  }

  @override
  void didUpdateWidget(covariant UrlPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      unawaited(_loadMetadata(resetState: true));
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMetadata({required bool resetState}) async {
    _fallbackTimer?.cancel();
    final requestId = ++_requestId;

    if (resetState && mounted) {
      setState(() {
        _metadata = null;
        _showFallback = false;
      });
    } else {
      _metadata = null;
      _showFallback = false;
    }

    _fallbackTimer = Timer(_fallbackDelay, () {
      if (!mounted || requestId != _requestId || _metadata != null) {
        return;
      }
      setState(() {
        _showFallback = true;
      });
    });

    try {
      final metadata = await _previewService.fetchMetadata(widget.url);
      if (!mounted || requestId != _requestId) {
        return;
      }

      _fallbackTimer?.cancel();

      if (metadata != null) {
        setState(() {
          _metadata = metadata;
          _showFallback = false;
        });
      } else {
        setState(() {
          _showFallback = true;
        });
      }
    } catch (_) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      _fallbackTimer?.cancel();
      setState(() {
        _showFallback = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _metadata != null
        ? _buildNativePreview(_metadata!)
        : _showFallback
        ? _buildLinkFallback()
        : _buildLoadingWidget();

    return AnimatedSwitcher(
      duration: _transitionDuration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: child,
    );
  }

  Widget _buildLoadingWidget() {
    // Show a lightweight placeholder with domain info while loading
    // This feels much faster than a spinner
    return SizedBox(
      key: const ValueKey('loading'),
      width: _effectiveMaxWidth,
      height: _cardHeight,
      child: GestureDetector(
        onTap: () => _launchUrl(widget.url),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: _effectiveMaxWidth,
              minHeight: _cardHeight,
            ),
            decoration: _cardDecoration,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Placeholder image area with subtle shimmer
                const SizedBox(
                  height: _mediaHeight,
                  child: ColoredBox(color: Color(0xFFE5E5E9)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _extractDomain(widget.url),
                          style: const TextStyle(
                            fontSize: 11,
                            color: MacosColors.systemGrayColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Show URL while title loads
                        Text(
                          widget.url,
                          style: const TextStyle(
                            fontSize: 13,
                            color: MacosColors.systemGrayColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkFallback() {
    return SizedBox(
      key: const ValueKey('fallback'),
      width: _effectiveMaxWidth,
      height: _cardHeight,
      child: GestureDetector(
        onTap: () => _launchUrl(widget.url),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: _effectiveMaxWidth,
              minHeight: _cardHeight,
            ),
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.link,
                      size: 24,
                      color: MacosColors.systemBlueColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _extractDomain(widget.url),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.url,
                            style: const TextStyle(
                              fontSize: 11,
                              color: MacosColors.systemBlueColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap to open in browser',
                            style: TextStyle(
                              fontSize: 10,
                              color: MacosColors.systemGrayColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: MacosColors.systemGrayColor,
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

  Widget _buildNativePreview(NativeLinkMetadata metadata) {
    final normalizedTitle = _normalizedTitle(metadata);

    return SizedBox(
      key: const ValueKey('native'),
      width: _effectiveMaxWidth,
      height: _cardHeight,
      child: GestureDetector(
        onTap: () => _launchUrl(widget.url),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: _effectiveMaxWidth,
              minHeight: _cardHeight,
            ),
            decoration: _cardDecoration,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PreviewMedia(metadata: metadata, mediaHeight: _mediaHeight),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _extractDomain(metadata.url ?? widget.url),
                          style: const TextStyle(
                            fontSize: 11,
                            color: MacosColors.systemGrayColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _AdaptivePreviewText(
                            text: normalizedTitle ?? widget.url,
                            baseStyle: TextStyle(
                              fontSize: normalizedTitle != null ? 16 : 14,
                              fontWeight: normalizedTitle != null
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: Colors.black,
                            ),
                            maxLines: normalizedTitle != null ? 3 : 2,
                            minFontSize: normalizedTitle != null ? 12 : 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _normalizedTitle(NativeLinkMetadata metadata) {
    final rawTitle = metadata.title?.trim();
    if (rawTitle == null || rawTitle.isEmpty) {
      return null;
    }
    return rawTitle;
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return url;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      debugPrint('Could not launch $url');
    }
  }

  BoxDecoration get _cardDecoration {
    return BoxDecoration(
      color: MacosColors.controlBackgroundColor,
      border: Border.all(color: MacosColors.separatorColor),
      borderRadius: BorderRadius.circular(12),
    );
  }

  double get _effectiveMaxWidth {
    return widget.maxWidth * 0.8;
  }
}

class _PreviewMedia extends StatelessWidget {
  const _PreviewMedia({required this.metadata, required this.mediaHeight});

  final NativeLinkMetadata metadata;
  final double mediaHeight;

  @override
  Widget build(BuildContext context) {
    final previewBytes = metadata.imageData ?? metadata.iconData;
    final isIconFallback =
        metadata.imageData == null && metadata.iconData != null;

    if (previewBytes == null) {
      return SizedBox(
        height: mediaHeight,
        child: const ColoredBox(color: Color(0xFFE5E5E9)),
      );
    }

    return SizedBox(
      height: mediaHeight,
      child: Container(
        decoration: isIconFallback
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE9ECF5), Color(0xFFD5DAE8)],
                ),
              )
            : null,
        clipBehavior: isIconFallback ? Clip.antiAlias : Clip.none,
        child: Image.memory(
          previewBytes,
          fit: BoxFit.cover,
          filterQuality: isIconFallback
              ? FilterQuality.high
              : FilterQuality.low,
          errorBuilder: (context, error, stackTrace) {
            return const ColoredBox(color: Color(0xFFE5E5E9));
          },
        ),
      ),
    );
  }
}

class _AdaptivePreviewText extends StatelessWidget {
  const _AdaptivePreviewText({
    required this.text,
    required this.baseStyle,
    required this.maxLines,
    required this.minFontSize,
  });

  final String text;
  final TextStyle baseStyle;
  final int maxLines;
  final double minFontSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final direction = Directionality.of(context);
        final painter = TextPainter(
          textDirection: direction,
          maxLines: maxLines,
        );

        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : double.infinity;

        var tryFontSize = baseStyle.fontSize ?? 14;
        const decrement = 0.5;

        while (tryFontSize >= minFontSize) {
          painter.text = TextSpan(
            text: text,
            style: baseStyle.copyWith(fontSize: tryFontSize),
          );
          painter.layout(maxWidth: maxWidth);

          final exceedsHeight =
              maxHeight != double.infinity && painter.height > maxHeight;
          if (!painter.didExceedMaxLines && !exceedsHeight) {
            return Text(
              text,
              style: baseStyle.copyWith(fontSize: tryFontSize),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            );
          }

          tryFontSize -= decrement;
        }

        return Text(
          text,
          style: baseStyle.copyWith(fontSize: minFontSize),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        );
      },
    );
  }
}
