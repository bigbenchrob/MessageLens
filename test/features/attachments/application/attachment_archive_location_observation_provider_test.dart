import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_dependencies_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_native_adapter.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store_provider.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_snapshot.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  group('AttachmentArchiveLocationSnapshot', () {
    final activeConfiguration =
        AttachmentArchiveLocationConfiguration.customExternal(
          bookmarkDataBase64: base64Encode(<int>[1]),
          lastKnownPath: '/Volumes/Archive/attachment_archive',
          volumeName: 'Archive',
          customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
        );

    test('covers every typed location availability without bookmark data', () {
      final states = <AttachmentArchiveLocationState>[
        AttachmentArchiveLocationState.defaultAvailable(
          archiveRootPath: '/tmp/root/attachment_archive',
        ),
        AttachmentArchiveLocationState.customAvailable(
          configuration: activeConfiguration,
          archiveRootPath: '/Volumes/Archive/attachment_archive',
        ),
        AttachmentArchiveLocationState.customReadOnly(
          configuration: activeConfiguration,
          archiveRootPath: '/Volumes/Archive/attachment_archive',
        ),
        AttachmentArchiveLocationState.customUnavailable(
          configuration: activeConfiguration,
          issue: 'Disconnected.',
        ),
        AttachmentArchiveLocationState.permissionDenied(
          configuration: activeConfiguration,
          issue: 'Permission denied.',
        ),
        AttachmentArchiveLocationState.configuredDirectoryMissing(
          configuration: activeConfiguration,
          issue: 'Folder missing.',
        ),
        AttachmentArchiveLocationState.configurationInvalid(
          configuration: activeConfiguration,
          issue: 'Invalid bookmark.',
        ),
      ];

      final snapshots = states
          .map(AttachmentArchiveLocationSnapshot.fromLocationState)
          .toList(growable: false);

      expect(
        snapshots.map((snapshot) => snapshot.availability),
        AttachmentArchiveLocationAvailability.values,
      );
      expect(snapshots[1].customWritePolicy, isNotNull);
      expect(snapshots[3].canonicalPath, isNull);
      expect(
        snapshots[3].lastKnownDisplayPath,
        '/Volumes/Archive/attachment_archive',
      );
    });
  });

  test('watching observation does not initialize the location owner', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.exists(attachmentArchiveLocationProvider), isFalse);
    expect(
      container.read(attachmentArchiveLocationObservationProvider),
      isNull,
    );
    expect(container.exists(attachmentArchiveLocationProvider), isFalse);
  });

  test(
    'refreshed bookmark is persisted only by Feature 31 before pure observation',
    () async {
      final fixture = await TestArchiveFixture.create(
        prefix: 'attachment_location_observation_',
      );
      addTearDown(fixture.dispose);
      final configuration =
          AttachmentArchiveLocationConfiguration.customExternal(
            bookmarkDataBase64: base64Encode(<int>[1]),
            lastKnownPath: '/Volumes/Old/attachment_archive',
            customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
          );
      final store = _RecordingSettingsStore(configuration.toPersistedValue());
      final adapter = _RecordingNativeAdapter(
        AttachmentArchiveBookmarkResolution(
          status: AttachmentArchiveBookmarkResolutionStatus.available,
          resolvedPath: '/Volumes/New/attachment_archive',
          refreshedBookmarkDataBase64: base64Encode(<int>[2]),
          volumeName: 'New',
        ),
      );
      addTearDown(adapter.dispose);
      final container = ProviderContainer(
        overrides: <Override>[
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            fixture.authority,
          ),
          attachmentArchiveSettingsStoreProvider.overrideWith(
            (ref) async => store,
          ),
          attachmentArchiveLocationNativeAdapterProvider.overrideWithValue(
            adapter,
          ),
        ],
      );
      addTearDown(container.dispose);

      final ownerState = await container.read(
        attachmentArchiveLocationProvider.future,
      );
      expect(ownerState.generation, 0);
      expect(store.writeCount, 1);
      expect(adapter.resolveCount, 1);

      final observation = container.read(
        attachmentArchiveLocationObservationProvider,
      );
      final repeatedObservation = container.read(
        attachmentArchiveLocationObservationProvider,
      );

      expect(observation, repeatedObservation);
      expect(observation?.canonicalPath, '/Volumes/New/attachment_archive');
      expect(observation?.volumeName, 'New');
      expect(store.writeCount, 1);
      expect(adapter.resolveCount, 1);
      expect(
        container
            .read(attachmentArchiveLocationProvider)
            .requireValue
            .generation,
        0,
      );
    },
  );
}

final class _RecordingSettingsStore implements AttachmentArchiveSettingsStore {
  _RecordingSettingsStore(this.value);

  String? value;
  int writeCount = 0;

  @override
  Future<void> clearArchivedAttachmentRecords() async {}

  @override
  Future<String?> readSetting(String key) async => value;

  @override
  Future<void> writeSetting({
    required String key,
    required String value,
  }) async {
    writeCount += 1;
    this.value = value;
  }
}

final class _RecordingNativeAdapter
    implements AttachmentArchiveLocationNativeAdapter {
  _RecordingNativeAdapter(this.resolution);

  final AttachmentArchiveBookmarkResolution resolution;
  final StreamController<AttachmentArchiveLocationEvent> _events =
      StreamController<AttachmentArchiveLocationEvent>.broadcast();
  int resolveCount = 0;

  @override
  Future<AttachmentArchiveBookmarkCreation> createBookmark({
    required String directoryPath,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<AttachmentArchiveLocationEvent> get locationEvents => _events.stream;

  @override
  Future<AttachmentArchiveBookmarkResolution> resolveBookmark({
    required String bookmarkDataBase64,
  }) async {
    resolveCount += 1;
    return resolution;
  }

  Future<void> dispose() => _events.close();
}
