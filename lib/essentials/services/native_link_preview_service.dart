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

/// LRU cache entry with metadata and timestamp.
class _CacheEntry {
  _CacheEntry(this.metadata) : timestamp = DateTime.now();

  final NativeLinkMetadata? metadata;
  final DateTime timestamp;
}

/// Service for fetching URL metadata using Apple's native LinkPresentation framework.
/// This provides better success rates than HTTP scraping and matches iMessage quality.
///
/// Includes an in-memory LRU cache to avoid refetching on scroll.
class NativeLinkPreviewService {
  static const _channel = MethodChannel('com.remember_this_text/link_preview');

  /// Maximum number of cached previews.
  static const _maxCacheSize = 200;

  /// Cache duration before re-fetch (24 hours).
  static const _cacheDuration = Duration(hours: 24);

  /// In-memory LRU cache keyed by URL.
  static final Map<String, _CacheEntry> _cache = {};

  /// URLs currently being fetched (prevents duplicate concurrent requests).
  static final Set<String> _pendingUrls = {};

  /// Fetch metadata for a URL using Apple's LinkPresentation framework.
  /// Returns null if the platform doesn't support it or if fetching fails.
  ///
  /// Results are cached in memory to avoid refetching during scrolling.
  Future<NativeLinkMetadata?> fetchMetadata(String url) async {
    // Check cache first
    final cached = _cache[url];
    if (cached != null) {
      final age = DateTime.now().difference(cached.timestamp);
      if (age < _cacheDuration) {
        // Move to end (LRU behavior)
        _cache.remove(url);
        _cache[url] = cached;
        return cached.metadata;
      }
      // Expired - remove and refetch
      _cache.remove(url);
    }

    // Wait if this URL is already being fetched
    if (_pendingUrls.contains(url)) {
      // Poll for completion (simple approach)
      for (var i = 0; i < 100; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final result = _cache[url];
        if (result != null) {
          return result.metadata;
        }
        if (!_pendingUrls.contains(url)) {
          break; // Fetch completed but failed
        }
      }
      return null;
    }

    _pendingUrls.add(url);

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'fetchMetadata',
        {'url': url},
      );

      NativeLinkMetadata? metadata;
      if (result != null) {
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

        metadata = NativeLinkMetadata(
          title: title,
          url: resultUrl,
          imageData: imageData,
          iconData: iconData,
        );
      }

      // Cache the result (even null results to avoid repeat failures)
      _addToCache(url, metadata);
      return metadata;
    } on PlatformException catch (_) {
      _addToCache(url, null);
      return null;
    } catch (_) {
      _addToCache(url, null);
      return null;
    } finally {
      _pendingUrls.remove(url);
    }
  }

  void _addToCache(String url, NativeLinkMetadata? metadata) {
    // Evict oldest entries if cache is full
    while (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[url] = _CacheEntry(metadata);
  }

  /// Clear the cache (useful for testing or memory pressure).
  static void clearCache() {
    _cache.clear();
    _pendingUrls.clear();
  }
}
