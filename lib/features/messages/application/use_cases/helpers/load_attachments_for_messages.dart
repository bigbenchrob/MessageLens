// import 'dart:io';
// import 'dart:ui' as ui;

// import 'package:video_player/video_player.dart';

// import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
// import '../../../presentation/presentation/view_model/attachment_info.dart';

// final Map<String, ui.Size> _mediaSizeCache = <String, ui.Size>{};

// Future<List<AttachmentInfo>> loadAttachmentsForMessage(
//   WorkingDatabase db,
//   String messageGuid,
// ) async {
//   final attachmentRows = await (db.select(
//     db.workingAttachments,
//   )..where((attachment) => attachment.messageGuid.equals(messageGuid))).get();

//   final results = <AttachmentInfo>[];
//   for (final attachment in attachmentRows) {
//     results.add(await loadAttachment(attachment));
//   }
//   return results;
// }

// Future<AttachmentInfo> loadAttachment(WorkingAttachment attachment) async {
//   final resolvedPath = _resolvePath(attachment.localPath);
//   ui.Size? cachedSize;
//   double? width;
//   double? height;

//   if (resolvedPath != null) {
//     cachedSize = _mediaSizeCache[resolvedPath];
//     if (cachedSize == null) {
//       final file = File(resolvedPath);
//       if (file.existsSync()) {
//         if (_looksLikeImage(attachment.mimeType, resolvedPath)) {
//           final size = await _decodeImageSize(file);
//           if (size != null) {
//             cachedSize = size;
//           }
//         } else if (_looksLikeVideo(attachment.mimeType, resolvedPath)) {
//           final size = await _readVideoSize(file);
//           if (size != null) {
//             cachedSize = size;
//           }
//         }
//       }
//       if (cachedSize != null) {
//         _mediaSizeCache[resolvedPath] = cachedSize;
//       }
//     }

//     if (cachedSize != null) {
//       width = cachedSize.width;
//       height = cachedSize.height;
//     }
//   }

//   return AttachmentInfo(
//     id: attachment.id,
//     localPath: attachment.localPath,
//     mimeType: attachment.mimeType,
//     transferName: attachment.transferName,
//     mediaWidth: width,
//     mediaHeight: height,
//   );
// }

// String? _resolvePath(String? path) {
//   if (path == null || path.isEmpty) {
//     return null;
//   }
//   if (path.startsWith('~/')) {
//     final home = Platform.environment['HOME'] ?? '';
//     if (home.isEmpty) {
//       return path;
//     }
//     return path.replaceFirst('~', home);
//   }
//   return path;
// }

// bool _looksLikeImage(String? mimeType, String resolvedPath) {
//   if (mimeType != null && mimeType.isNotEmpty) {
//     return mimeType.toLowerCase().startsWith('image/');
//   }
//   final lower = resolvedPath.toLowerCase();
//   return lower.endsWith('.jpg') ||
//       lower.endsWith('.jpeg') ||
//       lower.endsWith('.png') ||
//       lower.endsWith('.heic') ||
//       lower.endsWith('.heif') ||
//       lower.endsWith('.gif') ||
//       lower.endsWith('.webp');
// }

// bool _looksLikeVideo(String? mimeType, String resolvedPath) {
//   if (mimeType != null && mimeType.isNotEmpty) {
//     return mimeType.toLowerCase().startsWith('video/');
//   }
//   final lower = resolvedPath.toLowerCase();
//   return lower.endsWith('.mov') ||
//       lower.endsWith('.mp4') ||
//       lower.endsWith('.m4v') ||
//       lower.endsWith('.avi') ||
//       lower.endsWith('.mkv') ||
//       lower.endsWith('.webm');
// }

// Future<ui.Size?> _decodeImageSize(File file) async {
//   try {
//     final bytes = await file.readAsBytes();
//     final codec = await ui.instantiateImageCodec(bytes);
//     final frameInfo = await codec.getNextFrame();
//     final image = frameInfo.image;
//     final size = ui.Size(image.width.toDouble(), image.height.toDouble());
//     image.dispose();
//     codec.dispose();
//     return size;
//   } catch (_) {
//     return null;
//   }
// }

// Future<ui.Size?> _readVideoSize(File file) async {
//   VideoPlayerController? controller;
//   try {
//     controller = VideoPlayerController.file(file);
//     await controller.initialize();
//     final value = controller.value;
//     if (value.size.width <= 0 || value.size.height <= 0) {
//       return null;
//     }
//     return value.size;
//   } catch (_) {
//     return null;
//   } finally {
//     await controller?.dispose();
//   }
// }
