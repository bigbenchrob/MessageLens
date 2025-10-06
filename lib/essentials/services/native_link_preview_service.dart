import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

/// Metadata returned from Apple's LinkPresentation framework
class NativeLinkMetadata {
  const NativeLinkMetadata({
    required this.title,
    required this.url,
    this.imageData,
    this.iconData,
  });

  final String? title;
  final String? url;
  final Uint8List? imageData;
  final Uint8List? iconData;

  bool get hasImage => imageData != null;
  bool get hasIcon => iconData != null;
  bool get hasAnyImage => hasImage || hasIcon;
}

/// Service for fetching URL metadata using Apple's native LinkPresentation framework.
/// This provides better success rates than HTTP scraping and matches iMessage quality.
class NativeLinkPreviewService {
  static const _channel = MethodChannel('com.remember_this_text/link_preview');

  /// Fetch metadata for a URL using Apple's LinkPresentation framework.
  /// Returns null if the platform doesn't support it or if fetching fails.
  ///
  /// Timeout is 10 seconds to match our fallback behavior.
  Future<NativeLinkMetadata?> fetchMetadata(String url) async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'fetchMetadata',
        {'url': url},
      );

      if (result == null) {
        return null;
      }

      // Convert result to proper types
      final title = result['title'] as String?;
      final resultUrl = result['url'] as String?;

      // Decode base64 image data if present
      Uint8List? imageData;
      final imageDataRaw = result['imageData'];
      if (imageDataRaw is String) {
        imageData = base64Decode(imageDataRaw);
      }

      Uint8List? iconData;
      final iconDataRaw = result['iconData'];
      if (iconDataRaw is String) {
        iconData = base64Decode(iconDataRaw);
      }

      return NativeLinkMetadata(
        title: title,
        url: resultUrl,
        imageData: imageData,
        iconData: iconData,
      );
    } on PlatformException catch (e) {
      // Log but don't throw - we'll fall back to HTTP scraping
      print('LinkPresentation failed: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error in LinkPresentation: $e');
      return null;
    }
  }
}
