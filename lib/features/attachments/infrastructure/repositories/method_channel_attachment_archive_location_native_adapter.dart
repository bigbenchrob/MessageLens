import 'package:flutter/services.dart';

import '../../application/attachment_archive_location_native_adapter.dart';

final class MethodChannelAttachmentArchiveLocationNativeAdapter
    implements AttachmentArchiveLocationNativeAdapter {
  const MethodChannelAttachmentArchiveLocationNativeAdapter({
    MethodChannel methodChannel = const MethodChannel(
      'com.bigbenchsoftware.MessageLens/attachment_archive_location',
    ),
    EventChannel eventChannel = const EventChannel(
      'com.bigbenchsoftware.MessageLens/attachment_archive_location_events',
    ),
  }) : _methodChannel = methodChannel,
       _eventChannel = eventChannel;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  @override
  Future<AttachmentArchiveBookmarkCreation> createBookmark({
    required String directoryPath,
  }) async {
    try {
      final payload = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
        'createBookmark',
        <String, Object?>{'directoryPath': directoryPath},
      );
      if (payload == null) {
        throw const FormatException(
          'Native bookmark creation returned no payload.',
        );
      }
      return AttachmentArchiveBookmarkCreation(
        bookmarkDataBase64: _requiredString(payload, 'bookmarkDataBase64'),
        resolvedPath: _requiredString(payload, 'resolvedPath'),
        volumeName: _optionalString(payload, 'volumeName'),
      );
    } on PlatformException catch (error) {
      throw AttachmentArchiveBookmarkCreationException(
        code: error.code,
        message: error.message ?? 'Native bookmark creation failed.',
      );
    }
  }

  @override
  Future<AttachmentArchiveBookmarkResolution> resolveBookmark({
    required String bookmarkDataBase64,
  }) async {
    try {
      final payload = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
        'resolveBookmark',
        <String, Object?>{'bookmarkDataBase64': bookmarkDataBase64},
      );
      if (payload == null) {
        return const AttachmentArchiveBookmarkResolution(
          status: AttachmentArchiveBookmarkResolutionStatus.unavailable,
          issue: 'Native bookmark resolution returned no payload.',
        );
      }
      return AttachmentArchiveBookmarkResolution(
        status: _resolutionStatus(_requiredString(payload, 'status')),
        resolvedPath: _optionalString(payload, 'resolvedPath'),
        refreshedBookmarkDataBase64: _optionalString(
          payload,
          'refreshedBookmarkDataBase64',
        ),
        volumeName: _optionalString(payload, 'volumeName'),
        issue: _optionalString(payload, 'issue'),
      );
    } on PlatformException catch (error) {
      return AttachmentArchiveBookmarkResolution(
        status: switch (error.code) {
          'permission_denied' =>
            AttachmentArchiveBookmarkResolutionStatus.permissionDenied,
          'configured_directory_missing' =>
            AttachmentArchiveBookmarkResolutionStatus
                .configuredDirectoryMissing,
          'invalid_bookmark' =>
            AttachmentArchiveBookmarkResolutionStatus.invalidBookmark,
          _ => AttachmentArchiveBookmarkResolutionStatus.unavailable,
        },
        issue: error.message ?? 'Native bookmark resolution failed.',
      );
    } on FormatException catch (error) {
      return AttachmentArchiveBookmarkResolution(
        status: AttachmentArchiveBookmarkResolutionStatus.invalidBookmark,
        issue: error.message,
      );
    }
  }

  @override
  Stream<AttachmentArchiveLocationEvent> get locationEvents {
    return _eventChannel.receiveBroadcastStream().map((event) {
      if (event is! String) {
        throw const FormatException(
          'Attachment archive location event must be a string.',
        );
      }
      return switch (event) {
        'volume_mounted' => AttachmentArchiveLocationEvent.volumeMounted,
        'volume_unmounted' => AttachmentArchiveLocationEvent.volumeUnmounted,
        'volume_renamed' => AttachmentArchiveLocationEvent.volumeRenamed,
        'application_activated' =>
          AttachmentArchiveLocationEvent.applicationActivated,
        _ => throw FormatException(
          'Unsupported attachment archive location event: $event',
        ),
      };
    });
  }

  static AttachmentArchiveBookmarkResolutionStatus _resolutionStatus(
    String value,
  ) {
    return switch (value) {
      'available' => AttachmentArchiveBookmarkResolutionStatus.available,
      'read_only' => AttachmentArchiveBookmarkResolutionStatus.readOnly,
      'unavailable' => AttachmentArchiveBookmarkResolutionStatus.unavailable,
      'permission_denied' =>
        AttachmentArchiveBookmarkResolutionStatus.permissionDenied,
      'configured_directory_missing' =>
        AttachmentArchiveBookmarkResolutionStatus.configuredDirectoryMissing,
      'invalid_bookmark' =>
        AttachmentArchiveBookmarkResolutionStatus.invalidBookmark,
      _ => throw FormatException(
        'Unsupported native bookmark resolution status: $value',
      ),
    };
  }

  static String _requiredString(Map<Object?, Object?> payload, String key) {
    final value = _optionalString(payload, key);
    if (value == null || value.isEmpty) {
      throw FormatException('Native bookmark payload is missing $key.');
    }
    return value;
  }

  static String? _optionalString(Map<Object?, Object?> payload, String key) {
    final value = payload[key];
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw FormatException('Native bookmark payload $key must be a string.');
    }
    return value;
  }
}
