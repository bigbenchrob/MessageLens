import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/attachment_archive_settings_resolver.dart';

void main() {
  late ProviderContainer container;
  late AttachmentArchiveSettingsResolver resolver;

  setUp(() {
    container = ProviderContainer();
    resolver = container.read(
      attachmentArchiveSettingsResolverProvider.notifier,
    );
  });

  tearDown(() => container.dispose());

  test('internal state is status-only with no mover action', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.defaultAvailable(
        archiveRootPath: '/tmp/MessageLens/attachment_archive',
        generation: 3,
      ),
    );

    expect(
      payload.workflowView,
      AttachmentArchiveSettingsWorkflowView.currentLocation,
    );
    expect(payload.bodyText, contains('built-in attachment archive'));
    expect(payload.bodyText, contains('/tmp/MessageLens/attachment_archive'));
    expect(payload.actions, isEmpty);
    expect(payload.footnote, isNull);
    expect(
      payload.statusLines.map((line) => (line.label, line.value)),
      containsAll(<(String, String)>[
        ('Location', 'Internal'),
        ('Availability', 'Available'),
      ]),
    );
  });

  test('available external state reports location without fallback action', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.customAvailable(
        configuration: _activeExternalConfiguration,
        archiveRootPath: '/Volumes/External/attachment_archive',
        generation: 4,
      ),
    );

    expect(payload.bodyText, contains('connected and available for reads'));
    expect(payload.bodyText, contains('Volume: External'));
    expect(payload.bodyText, contains('/Volumes/External/attachment_archive'));
    expect(payload.actions, isEmpty);
    expect(payload.footnote, contains('does not silently fall back'));
    expect(
      payload.statusLines.map((line) => (line.label, line.value)),
      containsAll(<(String, String)>[
        ('Location', 'External'),
        ('Availability', 'Available'),
      ]),
    );
  });

  test('unavailable external state retains path, volume, and issue', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.customUnavailable(
        configuration: _activeExternalConfiguration,
        issue: 'Volume disconnected.',
        generation: 5,
      ),
    );

    expect(
      payload.bodyText,
      contains('external attachment archive is unavailable'),
    );
    expect(payload.bodyText, contains('/Volumes/External/attachment_archive'));
    expect(payload.bodyText, contains('Volume: External'));
    expect(payload.bodyText, contains('Volume disconnected.'));
    expect(payload.actions, isEmpty);
    expect(
      payload.statusLines.map((line) => (line.label, line.value)),
      contains(('Availability', 'Unavailable')),
    );
  });

  test('read-only and permission-denied states remain distinct', () {
    final readOnly = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.customReadOnly(
        configuration: _activeExternalConfiguration,
        archiveRootPath: '/Volumes/External/attachment_archive',
        issue: 'Mounted read-only.',
        generation: 6,
      ),
    );
    final denied = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.permissionDenied(
        configuration: _activeExternalConfiguration,
        issue: 'Permission was denied.',
        generation: 7,
      ),
    );

    expect(readOnly.bodyText, contains('read-only mode'));
    expect(
      readOnly.statusLines.map((line) => (line.label, line.value)),
      contains(('Availability', 'Available (read-only)')),
    );
    expect(denied.bodyText, contains('Permission to read'));
    expect(
      denied.statusLines.map((line) => (line.label, line.value)),
      contains(('Availability', 'Permission denied')),
    );
    expect(readOnly.actions, isEmpty);
    expect(denied.actions, isEmpty);
  });
}

final _activeExternalConfiguration =
    AttachmentArchiveLocationConfiguration.customExternal(
      bookmarkDataBase64: 'AQID',
      lastKnownPath: '/Volumes/External/attachment_archive',
      volumeName: 'External',
      customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
    );
