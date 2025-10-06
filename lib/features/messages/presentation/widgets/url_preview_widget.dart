import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../essentials/services/native_link_preview_service.dart';

/// Rich URL preview widget for displaying link metadata in messages.
/// Shows image, title, and site name with a clean, tappable design.
///
/// Strategy (Simplified):
/// 1. Try Apple's native LinkPresentation (same as iMessage)
/// 2. Show loading spinner while fetching
/// 3. Show clickable link fallback after 10 seconds if native fails
///
/// This removes any_link_preview entirely since:
/// - Native succeeds ~95% of the time
/// - When native fails, HTTP scraping usually fails too
/// - Simpler = no race conditions, no state management complexity
class UrlPreviewWidget extends StatefulWidget {
  final String url;
  final double maxWidth;

  const UrlPreviewWidget({required this.url, this.maxWidth = 400, super.key});

  @override
  State<UrlPreviewWidget> createState() => _UrlPreviewWidgetState();
}

class _UrlPreviewWidgetState extends State<UrlPreviewWidget> {
  bool _timedOut = false;
  NativeLinkMetadata? _nativeMetadata;
  bool _nativeFailed = false;
  final _nativeService = NativeLinkPreviewService();

  @override
  void initState() {
    super.initState();
    _tryNativePreview();

    // Set timeout - show fallback if native hasn't succeeded
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _nativeMetadata == null) {
        setState(() {
          _timedOut = true;
        });
      }
    });
  }

  Future<void> _tryNativePreview() async {
    try {
      final metadata = await _nativeService.fetchMetadata(widget.url);
      if (mounted) {
        if (metadata != null) {
          setState(() {
            _nativeMetadata = metadata;
          });
        } else {
          setState(() {
            _nativeFailed = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _nativeFailed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Success: Show native preview
    if (_nativeMetadata != null) {
      return _buildNativePreview(_nativeMetadata!);
    }

    // Timeout or explicit failure: Show clickable link fallback
    if (_timedOut || _nativeFailed) {
      return _buildLinkFallback();
    }

    // Still loading: Show spinner
    return _buildLoadingWidget();
  }

  /// Build a clean clickable link fallback when native preview fails
  Widget _buildLinkFallback() {
    return GestureDetector(
      onTap: () => _launchUrl(widget.url),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MacosColors.controlBackgroundColor,
            border: Border.all(color: MacosColors.separatorColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Link icon
              const Icon(
                Icons.link,
                size: 24,
                color: MacosColors.systemBlueColor,
              ),
              const SizedBox(width: 12),
              // URL text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 4),
                    Text(
                      widget.url,
                      style: const TextStyle(
                        fontSize: 11,
                        color: MacosColors.systemBlueColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
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
              // Arrow icon
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: MacosColors.systemGrayColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MacosColors.controlBackgroundColor,
        border: Border.all(color: MacosColors.separatorColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              'Loading preview...',
              style: TextStyle(
                fontSize: 12,
                color: MacosColors.systemGrayColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build preview using native Apple LinkPresentation metadata
  Widget _buildNativePreview(NativeLinkMetadata metadata) {
    return GestureDetector(
      onTap: () => _launchUrl(widget.url),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          decoration: BoxDecoration(
            color: MacosColors.controlBackgroundColor,
            border: Border.all(color: MacosColors.separatorColor),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              () {
                final previewBytes = metadata.imageData ?? metadata.iconData;
                if (previewBytes == null) {
                  return const SizedBox.shrink();
                }

                final isIconFallback =
                    metadata.imageData == null && metadata.iconData != null;

                return Container(
                  constraints: const BoxConstraints(
                    maxHeight: 220,
                    minHeight: 140,
                  ),
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
                      return const SizedBox.shrink();
                    },
                  ),
                );
              }(),

              // Content section
              Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Domain
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
                    const SizedBox(height: 4),

                    // Title from native metadata
                    if (metadata.title != null) ...[
                      Text(
                        metadata.title!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}
