import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_native_adapter.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/method_channel_attachment_archive_location_native_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('test/attachment_archive_location');
  const adapter = MethodChannelAttachmentArchiveLocationNativeAdapter(
    methodChannel: methodChannel,
    eventChannel: EventChannel('test/attachment_archive_location_events'),
  );

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test('decodes native bookmark creation and resolution payloads', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
          return switch (call.method) {
            'createBookmark' => <String, Object?>{
              'bookmarkDataBase64': 'AQID',
              'resolvedPath': '/Volumes/Disposable/Archive',
              'volumeName': 'Disposable',
            },
            'resolveBookmark' => <String, Object?>{
              'status': 'available',
              'resolvedPath': '/Volumes/Disposable/Archive',
              'refreshedBookmarkDataBase64': 'BAUG',
              'volumeName': 'Disposable',
            },
            _ => throw MissingPluginException(),
          };
        });

    final creation = await adapter.createBookmark(
      directoryPath: '/Volumes/Disposable/Archive',
    );
    final resolution = await adapter.resolveBookmark(
      bookmarkDataBase64: creation.bookmarkDataBase64,
    );

    expect(creation.bookmarkDataBase64, 'AQID');
    expect(creation.resolvedPath, '/Volumes/Disposable/Archive');
    expect(creation.volumeName, 'Disposable');
    expect(
      resolution.status,
      AttachmentArchiveBookmarkResolutionStatus.available,
    );
    expect(resolution.refreshedBookmarkDataBase64, 'BAUG');
  });

  test('maps native resolution failures to typed status', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
          throw PlatformException(
            code: 'permission_denied',
            message: 'Access denied.',
          );
        });

    final resolution = await adapter.resolveBookmark(
      bookmarkDataBase64: 'AQID',
    );

    expect(
      resolution.status,
      AttachmentArchiveBookmarkResolutionStatus.permissionDenied,
    );
    expect(resolution.issue, 'Access denied.');
  });

  test('malformed native resolution payload fails closed', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
          return <String, Object?>{'status': 'unexpected_status'};
        });

    final resolution = await adapter.resolveBookmark(
      bookmarkDataBase64: 'AQID',
    );

    expect(
      resolution.status,
      AttachmentArchiveBookmarkResolutionStatus.invalidBookmark,
    );
    expect(resolution.resolvedPath, isNull);
  });

  test('bookmark creation surfaces a typed adapter exception', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
          throw PlatformException(
            code: 'bookmark_creation_failed',
            message: 'Directory is unavailable.',
          );
        });

    await expectLater(
      adapter.createBookmark(directoryPath: '/missing'),
      throwsA(
        isA<AttachmentArchiveBookmarkCreationException>()
            .having((error) => error.code, 'code', 'bookmark_creation_failed')
            .having(
              (error) => error.message,
              'message',
              'Directory is unavailable.',
            ),
      ),
    );
  });
}
