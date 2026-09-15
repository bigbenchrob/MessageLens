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
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_store_providers.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  group('AttachmentArchiveLocationController', () {
    late TestArchiveFixture archiveFixture;
    late _FakeAttachmentArchiveSettingsStore settingsStore;

    setUp(() async {
      archiveFixture = await TestArchiveFixture.create(
        prefix: 'attachment_archive_location_controller_test_',
      );
      settingsStore = _FakeAttachmentArchiveSettingsStore();
    });

    tearDown(() async {
      await archiveFixture.dispose();
    });

    test('missing configuration resolves the existing default root', () async {
      final controller = AttachmentArchiveLocationController(
        archiveAccessAuthority: archiveFixture.authority,
        settingsStore: settingsStore,
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
      );

      final location = await controller.load();

      expect(
        location.availability,
        AttachmentArchiveLocationAvailability.configurationInvalid,
      );
      expect(location.archiveRootPath, isNull);
      expect(location.requireArchiveRootPath, throwsStateError);
    });

    test('external discriminator is reserved but not operational', () async {
      settingsStore.settings[attachmentArchiveLocationSettingKey] =
          '{"formatVersion":1,"mode":"custom_external"}';
      final controller = AttachmentArchiveLocationController(
        archiveAccessAuthority: archiveFixture.authority,
        settingsStore: settingsStore,
      );

      final location = await controller.load();

      expect(
        location.configuration?.mode,
        AttachmentArchiveLocationMode.customExternal,
      );
      expect(
        location.availability,
        AttachmentArchiveLocationAvailability.configurationInvalid,
      );
      expect(location.archiveRootPath, isNull);
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
  });
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
