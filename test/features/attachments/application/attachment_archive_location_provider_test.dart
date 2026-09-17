import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;
import 'package:remember_this_text/essentials/db/app_database_schema_versions.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_controller.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_dependencies_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_folder_chooser.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_native_adapter.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_store_providers.dart';
import 'package:remember_this_text/features/attachments/domain/constants/attachment_archive_payload_status.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  group('AttachmentArchiveLocationConfiguration', () {
    test('custom configuration round-trips bookmark identity and metadata', () {
      final configuration =
          AttachmentArchiveLocationConfiguration.customExternal(
            bookmarkDataBase64: base64Encode(<int>[1, 2, 3, 4]),
            lastKnownPath: '/Volumes/Disposable/Archive',
            volumeName: 'Disposable',
          );

      final restored =
          AttachmentArchiveLocationConfiguration.fromPersistedValue(
            configuration.toPersistedValue(),
          );

      expect(restored, configuration);
      expect(restored.mode, AttachmentArchiveLocationMode.customExternal);
      expect(restored.lastKnownPath, '/Volumes/Disposable/Archive');
      expect(
        restored.customWritePolicy,
        AttachmentArchiveCustomWritePolicy.readOnlyUntilVerifiedRelocation,
      );
    });

    test('verified custom activation policy round-trips explicitly', () {
      final configuration =
          AttachmentArchiveLocationConfiguration.customExternal(
            bookmarkDataBase64: base64Encode(<int>[5, 6]),
            lastKnownPath: '/Volumes/Verified/Archive',
            customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
          );

      final restored =
          AttachmentArchiveLocationConfiguration.fromPersistedValue(
            configuration.toPersistedValue(),
          );

      expect(
        restored.customWritePolicy,
        AttachmentArchiveCustomWritePolicy.activeArchive,
      );
    });

    test('malformed custom bookmark data fails closed', () {
      expect(
        () => AttachmentArchiveLocationConfiguration.fromPersistedValue(
          jsonEncode(<String, Object>{
            'formatVersion': 1,
            'mode': 'custom_external',
            'bookmarkDataBase64': 'not base64',
            'lastKnownPath': '/Volumes/Remembered',
          }),
        ),
        throwsFormatException,
      );
    });

    test('default configuration remains backward compatible', () {
      final restored =
          AttachmentArchiveLocationConfiguration.fromPersistedValue(
            '{"formatVersion":1,"mode":"default_internal"}',
          );

      expect(
        restored,
        const AttachmentArchiveLocationConfiguration.defaultInternal(),
      );
      expect(restored.bookmarkDataBase64, isNull);
      expect(restored.lastKnownPath, isNull);
    });
  });

  group('AttachmentArchiveLocationController', () {
    late TestArchiveFixture archiveFixture;
    late _FakeAttachmentArchiveSettingsStore settingsStore;
    late _FakeAttachmentArchiveLocationNativeAdapter nativeAdapter;

    setUp(() async {
      archiveFixture = await TestArchiveFixture.create(
        prefix: 'attachment_archive_location_controller_test_',
      );
      settingsStore = _FakeAttachmentArchiveSettingsStore();
      nativeAdapter = _FakeAttachmentArchiveLocationNativeAdapter();
    });

    tearDown(() async {
      await nativeAdapter.dispose();
      await archiveFixture.dispose();
    });

    test('missing configuration resolves the existing default root', () async {
      final controller = AttachmentArchiveLocationController(
        archiveAccessAuthority: archiveFixture.authority,
        settingsStore: settingsStore,
        nativeAdapter: nativeAdapter,
      );

      final location = await controller.load();

      expect(
        location.availability,
        AttachmentArchiveLocationAvailability.defaultAvailable,
      );
      expect(
        location.requireArchiveRootPath(),
        archiveFixture.authority.resolvePath('attachment_archive'),
      );
      expect(
        location.generation,
        AttachmentArchiveLocationState.initialGeneration,
      );
      expect(settingsStore.readKeys, <String>[
        attachmentArchiveLocationSettingKey,
      ]);
      expect(settingsStore.writes, isEmpty);
    });

    test('explicit default configuration resolves identically', () async {
      final controller = AttachmentArchiveLocationController(
        archiveAccessAuthority: archiveFixture.authority,
        settingsStore: settingsStore,
        nativeAdapter: nativeAdapter,
      );
      const configuration =
          AttachmentArchiveLocationConfiguration.defaultInternal();

      await controller.persistConfiguration(configuration);
      final location = await controller.load();

      expect(location.configuration, configuration);
      expect(
        location.requireArchiveRootPath(),
        archiveFixture.authority.resolvePath('attachment_archive'),
      );
      final persistedValue =
          settingsStore.settings[attachmentArchiveLocationSettingKey];
      expect(persistedValue, isNotNull);
      expect(persistedValue, isNot(contains(archiveFixture.root.path)));
      expect(persistedValue, contains('default_internal'));
    });

    test('unsupported future configuration fails closed', () async {
      settingsStore.settings[attachmentArchiveLocationSettingKey] =
          '{"formatVersion":2,"mode":"default_internal"}';
      final controller = AttachmentArchiveLocationController(
        archiveAccessAuthority: archiveFixture.authority,
        settingsStore: settingsStore,
        nativeAdapter: nativeAdapter,
      );

      final location = await controller.load();

      expect(
        location.availability,
        AttachmentArchiveLocationAvailability.configurationInvalid,
      );
      expect(location.archiveRootPath, isNull);
      expect(location.requireArchiveRootPath, throwsStateError);
    });

    test('custom configuration without bookmark data fails closed', () async {
      settingsStore.settings[attachmentArchiveLocationSettingKey] =
          '{"formatVersion":1,"mode":"custom_external"}';
      final controller = AttachmentArchiveLocationController(
        archiveAccessAuthority: archiveFixture.authority,
        settingsStore: settingsStore,
        nativeAdapter: nativeAdapter,
      );

      final location = await controller.load();

      expect(
        location.availability,
        AttachmentArchiveLocationAvailability.configurationInvalid,
      );
      expect(location.configuration, isNull);
      expect(location.archiveRootPath, isNull);
    });

    test(
      'custom bookmark resolves without treating remembered path as root',
      () async {
        final configuration =
            AttachmentArchiveLocationConfiguration.customExternal(
              bookmarkDataBase64: base64Encode(<int>[8, 9]),
              lastKnownPath: '/Volumes/Remembered/Archive',
              volumeName: 'Remembered',
            );
        settingsStore.settings[attachmentArchiveLocationSettingKey] =
            configuration.toPersistedValue();
        nativeAdapter.resolution = const AttachmentArchiveBookmarkResolution(
          status: AttachmentArchiveBookmarkResolutionStatus.available,
          resolvedPath: '/Volumes/Resolved/Archive',
          volumeName: 'Resolved',
        );
        final controller = AttachmentArchiveLocationController(
          archiveAccessAuthority: archiveFixture.authority,
          settingsStore: settingsStore,
          nativeAdapter: nativeAdapter,
        );

        final location = await controller.load();

        expect(
          location.availability,
          AttachmentArchiveLocationAvailability.customAvailable,
        );
        expect(location.requireArchiveRootPath(), '/Volumes/Resolved/Archive');
        expect(location.lastKnownDisplayPath, '/Volumes/Resolved/Archive');
        expect(nativeAdapter.resolvedBookmarks, hasLength(1));
        expect(
          nativeAdapter.resolvedBookmarks.single,
          configuration.bookmarkDataBase64,
        );
      },
    );

    test('unavailable bookmark never exposes the remembered path', () async {
      final configuration =
          AttachmentArchiveLocationConfiguration.customExternal(
            bookmarkDataBase64: base64Encode(<int>[10]),
            lastKnownPath: '/Volumes/Absent/Archive',
          );
      settingsStore.settings[attachmentArchiveLocationSettingKey] =
          configuration.toPersistedValue();
      nativeAdapter.resolution = const AttachmentArchiveBookmarkResolution(
        status: AttachmentArchiveBookmarkResolutionStatus.unavailable,
        issue: 'Volume is absent.',
      );
      final controller = AttachmentArchiveLocationController(
        archiveAccessAuthority: archiveFixture.authority,
        settingsStore: settingsStore,
        nativeAdapter: nativeAdapter,
      );

      final location = await controller.load();

      expect(
        location.availability,
        AttachmentArchiveLocationAvailability.customUnavailable,
      );
      expect(location.archiveRootPath, isNull);
      expect(location.lastKnownDisplayPath, '/Volumes/Absent/Archive');
      expect(location.requireArchiveRootPath, throwsStateError);
      expect(location.isWritableMutationEligible, isFalse);
    });

    test(
      'stale bookmark refresh persists resolved identity metadata',
      () async {
        final oldBookmark = base64Encode(<int>[11]);
        final refreshedBookmark = base64Encode(<int>[12]);
        final configuration =
            AttachmentArchiveLocationConfiguration.customExternal(
              bookmarkDataBase64: oldBookmark,
              lastKnownPath: '/Volumes/Before/Archive',
              volumeName: 'Before',
            );
        settingsStore.settings[attachmentArchiveLocationSettingKey] =
            configuration.toPersistedValue();
        nativeAdapter.resolution = AttachmentArchiveBookmarkResolution(
          status: AttachmentArchiveBookmarkResolutionStatus.available,
          resolvedPath: '/Volumes/After/Archive',
          refreshedBookmarkDataBase64: refreshedBookmark,
          volumeName: 'After',
        );
        final controller = AttachmentArchiveLocationController(
          archiveAccessAuthority: archiveFixture.authority,
          settingsStore: settingsStore,
          nativeAdapter: nativeAdapter,
        );

        final location = await controller.load();
        final persisted =
            AttachmentArchiveLocationConfiguration.fromPersistedValue(
              settingsStore.settings[attachmentArchiveLocationSettingKey]!,
            );

        expect(location.configuration?.bookmarkDataBase64, refreshedBookmark);
        expect(location.requireArchiveRootPath(), '/Volumes/After/Archive');
        expect(persisted.bookmarkDataBase64, refreshedBookmark);
        expect(persisted.lastKnownPath, '/Volumes/After/Archive');
        expect(persisted.volumeName, 'After');
      },
    );

    test('custom resolution statuses retain typed failure semantics', () async {
      final configuration =
          AttachmentArchiveLocationConfiguration.customExternal(
            bookmarkDataBase64: base64Encode(<int>[13]),
            lastKnownPath: '/Volumes/Typed/Archive',
          );
      settingsStore.settings[attachmentArchiveLocationSettingKey] =
          configuration.toPersistedValue();
      final controller = AttachmentArchiveLocationController(
        archiveAccessAuthority: archiveFixture.authority,
        settingsStore: settingsStore,
        nativeAdapter: nativeAdapter,
      );

      for (final expectation
          in <
            (
              AttachmentArchiveBookmarkResolutionStatus,
              AttachmentArchiveLocationAvailability,
            )
          >[
            (
              AttachmentArchiveBookmarkResolutionStatus.readOnly,
              AttachmentArchiveLocationAvailability.customReadOnly,
            ),
            (
              AttachmentArchiveBookmarkResolutionStatus.permissionDenied,
              AttachmentArchiveLocationAvailability.permissionDenied,
            ),
            (
              AttachmentArchiveBookmarkResolutionStatus
                  .configuredDirectoryMissing,
              AttachmentArchiveLocationAvailability.configuredDirectoryMissing,
            ),
            (
              AttachmentArchiveBookmarkResolutionStatus.invalidBookmark,
              AttachmentArchiveLocationAvailability.configurationInvalid,
            ),
          ]) {
        nativeAdapter.resolution = AttachmentArchiveBookmarkResolution(
          status: expectation.$1,
          resolvedPath:
              expectation.$1 ==
                  AttachmentArchiveBookmarkResolutionStatus.readOnly
              ? '/Volumes/Typed/Archive'
              : null,
          issue: 'Typed test status.',
        );

        final location = await controller.load();

        expect(location.availability, expectation.$2);
        expect(
          location.archiveRootPath,
          expectation.$1 == AttachmentArchiveBookmarkResolutionStatus.readOnly
              ? '/Volumes/Typed/Archive'
              : isNull,
        );
      }
    });
  });

  group('writable-root scheduling eligibility', () {
    test('default location is eligible without manufacturing authority', () {
      final location = AttachmentArchiveLocationState.defaultAvailable(
        archiveRootPath: '/internal/attachment_archive',
        generation: 7,
      );

      expect(location.isWritableMutationEligible, isTrue);
    });

    test('physically writable selected custom location remains ineligible', () {
      final configuration =
          AttachmentArchiveLocationConfiguration.customExternal(
            bookmarkDataBase64: base64Encode(<int>[14]),
            lastKnownPath: '/Volumes/External/Archive',
          );
      final location = AttachmentArchiveLocationState.customAvailable(
        configuration: configuration,
        archiveRootPath: '/Volumes/External/Archive',
      );

      expect(location.isPhysicallyWritable, isTrue);
      expect(location.requireArchiveRootPath(), '/Volumes/External/Archive');
      expect(location.isWritableMutationEligible, isFalse);
    });
  });

  group('attachmentArchiveLocationProvider', () {
    late TestArchiveFixture archiveFixture;

    setUp(() async {
      archiveFixture = await TestArchiveFixture.create(
        prefix: 'attachment_archive_location_provider_test_',
      );
    });

    tearDown(() async {
      await archiveFixture.dispose();
    });

    test(
      'derives a cheap default root without creating or scanning it',
      () async {
        final settingsStore = _FakeAttachmentArchiveSettingsStore();
        final archiveDirectory = Directory(
          archiveFixture.authority.resolvePath('attachment_archive'),
        );
        expect(archiveDirectory.existsSync(), isFalse);
        final container = ProviderContainer(
          overrides: [
            admittedArchiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            attachmentArchiveSettingsStoreProvider.overrideWith(
              (ref) async => settingsStore,
            ),
            attachmentArchiveLocationNativeAdapterProvider.overrideWithValue(
              _FakeAttachmentArchiveLocationNativeAdapter(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final location = await container.read(
          attachmentArchiveLocationProvider.future,
        );

        expect(location.requireArchiveRootPath(), archiveDirectory.path);
        expect(archiveDirectory.existsSync(), isFalse);
        expect(settingsStore.writes, isEmpty);
      },
    );

    test(
      'relative archive records resolve through the new root seam',
      () async {
        final overlayDatabase = OverlayDatabase(NativeDatabase.memory());
        addTearDown(overlayDatabase.close);
        final archiveFile = File(
          archiveFixture.authority.resolvePath(
            path.join('attachment_archive', 'ab', 'payload.bin'),
          ),
        );
        await archiveFile.create(recursive: true);
        await archiveFile.writeAsString('payload');
        await overlayDatabase
            .into(overlayDatabase.archivedAttachments)
            .insert(
              ArchivedAttachmentsCompanion.insert(
                messageGuid: 'message-guid',
                importAttachmentId: 42,
                archiveRelativePath: path.join('ab', 'payload.bin'),
                archivedAtUtc: DateTime.utc(2026, 9, 13).toIso8601String(),
                fileSizeBytes: await archiveFile.length(),
                contentHash: const drift.Value('hash'),
              ),
            );
        final container = ProviderContainer(
          overrides: [
            admittedArchiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            overlayDatabaseProvider.overrideWith(
              (ref) async => overlayDatabase,
            ),
            attachmentArchiveLocationNativeAdapterProvider.overrideWithValue(
              _FakeAttachmentArchiveLocationNativeAdapter(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final readStore = await container.read(
          attachmentArchiveReadStoreProvider.future,
        );
        final record = await readStore.readArchiveRecord(
          const ArchiveCompatibilityKey(
            messageGuid: 'message-guid',
            importAttachmentId: 42,
          ),
        );

        expect(record, isNotNull);
        expect(record!.archiveRelativePath, path.join('ab', 'payload.bin'));
        expect(record.archiveAbsolutePath, archiveFile.path);
        expect(record.archiveFileExists, isTrue);
        expect(overlayDatabase.schemaVersion, 8);
        expect(conversationGraphSchemaVersion, 3);
      },
    );

    test(
      'selection, availability events, and reselection advance generation',
      () async {
        final settingsStore = _FakeAttachmentArchiveSettingsStore();
        final nativeAdapter = _FakeAttachmentArchiveLocationNativeAdapter();
        addTearDown(nativeAdapter.dispose);
        final selectedBookmark = base64Encode(<int>[21]);
        nativeAdapter.creation = AttachmentArchiveBookmarkCreation(
          bookmarkDataBase64: selectedBookmark,
          resolvedPath: '/Volumes/Disposable/Archive',
          volumeName: 'Disposable',
        );
        nativeAdapter.resolution = const AttachmentArchiveBookmarkResolution(
          status: AttachmentArchiveBookmarkResolutionStatus.available,
          resolvedPath: '/Volumes/Disposable/Archive',
          volumeName: 'Disposable',
        );
        final container = ProviderContainer(
          overrides: [
            admittedArchiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            attachmentArchiveSettingsStoreProvider.overrideWith(
              (ref) async => settingsStore,
            ),
            attachmentArchiveLocationNativeAdapterProvider.overrideWithValue(
              nativeAdapter,
            ),
          ],
        );
        addTearDown(container.dispose);

        final initial = await container.read(
          attachmentArchiveLocationProvider.future,
        );
        expect(initial.generation, 0);

        await container
            .read(attachmentArchiveLocationProvider.notifier)
            .configureCustomLocation(
              directoryPath: '/Volumes/Disposable/Archive',
            );
        var location = await container.read(
          attachmentArchiveLocationProvider.future,
        );
        expect(
          location.availability,
          AttachmentArchiveLocationAvailability.customAvailable,
        );
        expect(location.generation, 1);
        expect(nativeAdapter.createdPaths, <String>[
          '/Volumes/Disposable/Archive',
        ]);
        final admission = await container.read(
          attachmentArchiveWritableRootAdmissionProvider.future,
        );
        expect(admission.isAdmitted, isFalse);
        expect(
          admission.deferredReason,
          AttachmentArchiveMutationDeferredReason.customArchiveNotActivated,
        );

        await container
            .read(attachmentArchiveLocationProvider.notifier)
            .refresh();
        location = await container.read(
          attachmentArchiveLocationProvider.future,
        );
        expect(location.generation, 1);

        nativeAdapter.resolution = const AttachmentArchiveBookmarkResolution(
          status: AttachmentArchiveBookmarkResolutionStatus.unavailable,
          issue: 'Volume removed.',
        );
        nativeAdapter.emit(AttachmentArchiveLocationEvent.volumeUnmounted);
        location = await _waitForLocation(
          container,
          (candidate) =>
              candidate.availability ==
                  AttachmentArchiveLocationAvailability.customUnavailable &&
              candidate.generation == 2,
        );
        expect(location.archiveRootPath, isNull);

        final resolveCountBeforeRepeat = nativeAdapter.resolveCalls;
        var identicalStateNotificationCount = 0;
        final identicalStateSubscription = container.listen(
          attachmentArchiveLocationProvider,
          (previous, next) {
            identicalStateNotificationCount += 1;
          },
        );
        nativeAdapter.emit(AttachmentArchiveLocationEvent.applicationActivated);
        await _waitForResolveCount(nativeAdapter, resolveCountBeforeRepeat + 1);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        location = container
            .read(attachmentArchiveLocationProvider)
            .requireValue;
        expect(location.generation, 2);
        expect(identicalStateNotificationCount, 0);
        identicalStateSubscription.close();

        nativeAdapter.resolution = const AttachmentArchiveBookmarkResolution(
          status: AttachmentArchiveBookmarkResolutionStatus.available,
          resolvedPath: '/Volumes/Renamed/Archive',
          volumeName: 'Renamed',
        );
        nativeAdapter.emit(AttachmentArchiveLocationEvent.volumeRenamed);
        location = await _waitForLocation(
          container,
          (candidate) =>
              candidate.archiveRootPath == '/Volumes/Renamed/Archive' &&
              candidate.generation == 3,
        );
        expect(
          location.availability,
          AttachmentArchiveLocationAvailability.customAvailable,
        );

        nativeAdapter.resolution = const AttachmentArchiveBookmarkResolution(
          status: AttachmentArchiveBookmarkResolutionStatus.readOnly,
          resolvedPath: '/Volumes/Renamed/Archive',
          issue: 'Read-only volume.',
        );
        nativeAdapter.emit(AttachmentArchiveLocationEvent.volumeMounted);
        location = await _waitForLocation(
          container,
          (candidate) =>
              candidate.availability ==
                  AttachmentArchiveLocationAvailability.customReadOnly &&
              candidate.generation == 4,
        );
        expect(location.isPhysicallyWritable, isFalse);

        await container
            .read(attachmentArchiveLocationProvider.notifier)
            .configureCustomLocation(
              directoryPath: '/Volumes/Disposable/Archive',
            );
        location = await container.read(
          attachmentArchiveLocationProvider.future,
        );
        expect(location.generation, 5);

        await container
            .read(attachmentArchiveLocationProvider.notifier)
            .useDefaultInternalLocation();
        location = await container.read(
          attachmentArchiveLocationProvider.future,
        );
        expect(
          location.availability,
          AttachmentArchiveLocationAvailability.defaultAvailable,
        );
        expect(location.generation, 6);
        expect(nativeAdapter.eventListenCount, 1);
        expect(nativeAdapter.eventCancelCount, 1);
      },
    );

    test(
      'disconnect and remount invalidate stale absolute attachment paths',
      () async {
        final overlayDatabase = OverlayDatabase(NativeDatabase.memory());
        addTearDown(overlayDatabase.close);
        final firstRoot = Directory(
          archiveFixture.authority.resolvePath('external-one'),
        );
        final secondRoot = Directory(
          archiveFixture.authority.resolvePath('external-renamed'),
        );
        final firstFile = File(path.join(firstRoot.path, 'payload.bin'));
        final secondFile = File(path.join(secondRoot.path, 'payload.bin'));
        await firstFile.create(recursive: true);
        await firstFile.writeAsString('first');
        await secondFile.create(recursive: true);
        await secondFile.writeAsString('second');
        await overlayDatabase
            .into(overlayDatabase.archivedAttachments)
            .insert(
              ArchivedAttachmentsCompanion.insert(
                messageGuid: 'generation-message',
                importAttachmentId: 91,
                archiveRelativePath: 'payload.bin',
                archivedAtUtc: '2026-09-15T10:00:00.000Z',
                fileSizeBytes: 5,
              ),
            );
        final configuration =
            AttachmentArchiveLocationConfiguration.customExternal(
              bookmarkDataBase64: base64Encode(<int>[41]),
              lastKnownPath: firstRoot.path,
            );
        final settingsStore = _FakeAttachmentArchiveSettingsStore();
        settingsStore.settings[attachmentArchiveLocationSettingKey] =
            configuration.toPersistedValue();
        final nativeAdapter = _FakeAttachmentArchiveLocationNativeAdapter();
        addTearDown(nativeAdapter.dispose);
        nativeAdapter.resolution = AttachmentArchiveBookmarkResolution(
          status: AttachmentArchiveBookmarkResolutionStatus.available,
          resolvedPath: firstRoot.path,
        );
        final container = ProviderContainer(
          overrides: [
            admittedArchiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            overlayDatabaseProvider.overrideWith(
              (ref) async => overlayDatabase,
            ),
            attachmentArchiveSettingsStoreProvider.overrideWith(
              (ref) async => settingsStore,
            ),
            attachmentArchiveLocationNativeAdapterProvider.overrideWithValue(
              nativeAdapter,
            ),
          ],
        );
        addTearDown(container.dispose);
        const archiveKey = ArchiveCompatibilityKey(
          messageGuid: 'generation-message',
          importAttachmentId: 91,
        );

        var readStore = await container.read(
          attachmentArchiveReadStoreProvider.future,
        );
        var record = await readStore.readArchiveRecord(archiveKey);
        expect(record?.archiveAbsolutePath, firstFile.path);
        expect(record?.locationGeneration, 0);

        nativeAdapter.resolution = const AttachmentArchiveBookmarkResolution(
          status: AttachmentArchiveBookmarkResolutionStatus.unavailable,
          issue: 'Volume disconnected.',
        );
        nativeAdapter.emit(AttachmentArchiveLocationEvent.volumeUnmounted);
        await _waitForLocation(
          container,
          (candidate) =>
              candidate.availability ==
                  AttachmentArchiveLocationAvailability.customUnavailable &&
              candidate.generation == 1,
        );
        readStore = await container.read(
          attachmentArchiveReadStoreProvider.future,
        );
        record = await readStore.readArchiveRecord(archiveKey);
        expect(
          record?.payloadStatus,
          AttachmentArchivePayloadStatus.rootUnavailable,
        );
        expect(record?.archiveAbsolutePath, isNull);
        expect(record?.locationGeneration, 1);

        nativeAdapter.resolution = AttachmentArchiveBookmarkResolution(
          status: AttachmentArchiveBookmarkResolutionStatus.available,
          resolvedPath: secondRoot.path,
        );
        nativeAdapter.emit(AttachmentArchiveLocationEvent.volumeRenamed);
        await _waitForLocation(
          container,
          (candidate) =>
              candidate.archiveRootPath == secondRoot.path &&
              candidate.generation == 2,
        );
        readStore = await container.read(
          attachmentArchiveReadStoreProvider.future,
        );
        record = await readStore.readArchiveRecord(archiveKey);
        expect(record?.archiveAbsolutePath, secondFile.path);
        expect(record?.archiveAbsolutePath, isNot(firstFile.path));
        expect(record?.locationGeneration, 2);
      },
    );

    test('invalid configuration can be corrected by a new selection', () async {
      final settingsStore = _FakeAttachmentArchiveSettingsStore();
      settingsStore.settings[attachmentArchiveLocationSettingKey] =
          '{"formatVersion":2,"mode":"custom_external"}';
      final nativeAdapter = _FakeAttachmentArchiveLocationNativeAdapter();
      addTearDown(nativeAdapter.dispose);
      nativeAdapter.creation = AttachmentArchiveBookmarkCreation(
        bookmarkDataBase64: base64Encode(<int>[31]),
        resolvedPath: '/Volumes/Corrected/Archive',
      );
      nativeAdapter.resolution = const AttachmentArchiveBookmarkResolution(
        status: AttachmentArchiveBookmarkResolutionStatus.available,
        resolvedPath: '/Volumes/Corrected/Archive',
      );
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
          attachmentArchiveSettingsStoreProvider.overrideWith(
            (ref) async => settingsStore,
          ),
          attachmentArchiveLocationNativeAdapterProvider.overrideWithValue(
            nativeAdapter,
          ),
        ],
      );
      addTearDown(container.dispose);

      final invalid = await container.read(
        attachmentArchiveLocationProvider.future,
      );
      expect(
        invalid.availability,
        AttachmentArchiveLocationAvailability.configurationInvalid,
      );

      await container
          .read(attachmentArchiveLocationProvider.notifier)
          .configureCustomLocation(directoryPath: '/Volumes/Corrected/Archive');
      final corrected = await container.read(
        attachmentArchiveLocationProvider.future,
      );

      expect(
        corrected.availability,
        AttachmentArchiveLocationAvailability.customAvailable,
      );
      expect(corrected.generation, 1);
    });

    test('cancelled folder selection leaves configuration unchanged', () async {
      const chooser = _FakeAttachmentArchiveLocationFolderChooser(null);
      final nativeAdapter = _FakeAttachmentArchiveLocationNativeAdapter();
      addTearDown(nativeAdapter.dispose);
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
          attachmentArchiveLocationNativeAdapterProvider.overrideWithValue(
            nativeAdapter,
          ),
          attachmentArchiveLocationFolderChooserProvider.overrideWithValue(
            chooser,
          ),
        ],
      );
      addTearDown(container.dispose);
      final before = await container.read(
        attachmentArchiveLocationProvider.future,
      );

      final selected = await container
          .read(attachmentArchiveLocationProvider.notifier)
          .chooseCustomLocation();
      final after = await container.read(
        attachmentArchiveLocationProvider.future,
      );

      expect(selected, isFalse);
      expect(after.configuration, before.configuration);
      expect(after.generation, before.generation);
      expect(nativeAdapter.createdPaths, isEmpty);
    });
  });
}

Future<AttachmentArchiveLocationState> _waitForLocation(
  ProviderContainer container,
  bool Function(AttachmentArchiveLocationState location) predicate,
) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    final location = container
        .read(attachmentArchiveLocationProvider)
        .valueOrNull;
    if (location != null && predicate(location)) {
      return location;
    }
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  throw StateError(
    'Timed out waiting for attachment archive location transition.',
  );
}

Future<void> _waitForResolveCount(
  _FakeAttachmentArchiveLocationNativeAdapter adapter,
  int expected,
) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (adapter.resolveCalls >= expected) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  throw StateError('Timed out waiting for bookmark re-resolution.');
}

final class _FakeAttachmentArchiveSettingsStore
    implements AttachmentArchiveSettingsStore {
  final settings = <String, String>{};
  final readKeys = <String>[];
  final writes = <String, String>{};

  @override
  Future<void> clearArchivedAttachmentRecords() async {}

  @override
  Future<String?> readSetting(String key) async {
    readKeys.add(key);
    return settings[key];
  }

  @override
  Future<void> writeSetting({
    required String key,
    required String value,
  }) async {
    settings[key] = value;
    writes[key] = value;
  }
}

final class _FakeAttachmentArchiveLocationNativeAdapter
    implements AttachmentArchiveLocationNativeAdapter {
  _FakeAttachmentArchiveLocationNativeAdapter() {
    _events = StreamController<AttachmentArchiveLocationEvent>.broadcast(
      sync: true,
      onListen: () {
        eventListenCount += 1;
      },
      onCancel: () {
        eventCancelCount += 1;
      },
    );
  }

  late final StreamController<AttachmentArchiveLocationEvent> _events;
  AttachmentArchiveBookmarkCreation creation =
      const AttachmentArchiveBookmarkCreation(
        bookmarkDataBase64: 'AQ==',
        resolvedPath: '/Volumes/Disposable/Archive',
        volumeName: 'Disposable',
      );
  AttachmentArchiveBookmarkResolution resolution =
      const AttachmentArchiveBookmarkResolution(
        status: AttachmentArchiveBookmarkResolutionStatus.available,
        resolvedPath: '/Volumes/Disposable/Archive',
        volumeName: 'Disposable',
      );
  final createdPaths = <String>[];
  final resolvedBookmarks = <String>[];
  var resolveCalls = 0;
  var eventListenCount = 0;
  var eventCancelCount = 0;

  @override
  Future<AttachmentArchiveBookmarkCreation> createBookmark({
    required String directoryPath,
  }) async {
    createdPaths.add(directoryPath);
    return creation;
  }

  @override
  Stream<AttachmentArchiveLocationEvent> get locationEvents => _events.stream;

  @override
  Future<AttachmentArchiveBookmarkResolution> resolveBookmark({
    required String bookmarkDataBase64,
  }) async {
    resolveCalls += 1;
    resolvedBookmarks.add(bookmarkDataBase64);
    return resolution;
  }

  void emit(AttachmentArchiveLocationEvent event) {
    _events.add(event);
  }

  Future<void> dispose() async {
    await _events.close();
  }
}

final class _FakeAttachmentArchiveLocationFolderChooser
    implements AttachmentArchiveLocationFolderChooser {
  const _FakeAttachmentArchiveLocationFolderChooser(this.selectedPath);

  final String? selectedPath;

  @override
  Future<String?> chooseArchiveDirectory() async => selectedPath;
}
