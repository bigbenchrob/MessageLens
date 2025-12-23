import 'dart:io';

class AttachmentInfo {
  const AttachmentInfo({
    required this.id,
    required this.localPath,
    required this.mimeType,
    required this.transferName,
    this.mediaWidth,
    this.mediaHeight,
  });

  final int id;
  final String? localPath;
  final String? mimeType;
  final String? transferName;
  final double? mediaWidth;
  final double? mediaHeight;

  bool get hasLocalFile => localPath != null && localPath!.isNotEmpty;

  bool get hasDimensions =>
      mediaWidth != null &&
      mediaWidth! > 0 &&
      mediaHeight != null &&
      mediaHeight! > 0;

  double? get aspectRatio {
    if (!hasDimensions) {
      return null;
    }
    return mediaWidth! / mediaHeight!;
  }

  bool get isImage {
    if (mimeType != null && mimeType!.isNotEmpty) {
      return mimeType!.toLowerCase().startsWith('image/');
    }
    if (!hasLocalFile) {
      return false;
    }
    final path = localPath!.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.heic') ||
        path.endsWith('.heif') ||
        path.endsWith('.gif') ||
        path.endsWith('.webp');
  }

  bool get isVideo {
    if (mimeType != null && mimeType!.isNotEmpty) {
      return mimeType!.toLowerCase().startsWith('video/');
    }
    if (!hasLocalFile) {
      return false;
    }
    final path = localPath!.toLowerCase();
    return path.endsWith('.mov') ||
        path.endsWith('.mp4') ||
        path.endsWith('.m4v') ||
        path.endsWith('.avi') ||
        path.endsWith('.mkv') ||
        path.endsWith('.webm');
  }

  bool get isUrlPreview {
    if (!hasLocalFile) {
      return false;
    }
    return localPath!.toLowerCase().endsWith('.pluginpayloadattachment');
  }

  /// Returns the expanded absolute path if the [localPath] begins with `~/`.
  /// Otherwise, returns [localPath] unchanged.
  String? resolvedLocalPath() {
    if (!hasLocalFile) {
      return null;
    }
    final rawPath = localPath!;
    if (rawPath.startsWith('~/')) {
      final home = Platform.environment['HOME'] ?? '';
      if (home.isEmpty) {
        return rawPath;
      }
      return rawPath.replaceFirst('~', home);
    }
    return rawPath;
  }
}
