import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;
import 'package:remember_this_text/features/attachments/application/archive_settings_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_file_operations.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_runtime_providers.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_stats_reader.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_stats.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  late _FakeArchiveSettingsStore settingsStore;
  late _FakeArchiveStatsReader statsReader;
  late _FakeArchiveFileOperations fileOperations;
  late ProviderContainer container;
  late TestArchiveFixture archiveFixture;

  setUp(() async {
    archiveFixture = await TestArchiveFixture.create(
      prefix: 'archive_settings_test_',
    );
    settingsStore = _FakeArchiveSettingsStore();
    statsReader = _FakeArchiveStatsReader(
      const AttachmentArchiveStats(recordCount: 12, sizeBytes: 1536),
    );
    fileOperations = _FakeArchiveFileOperations();
    container = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          archiveFixture.authority,
        ),
        attachmentArchiveSettingsStoreProvider.overrideWith(
          (ref) async => settingsStore,
        ),
        attachmentArchiveLocationProvider.overrideWith(
          () => _FixedAttachmentArchiveLocation(
            AttachmentArchiveLocationState.defaultAvailable(
              archiveRootPath: archiveFixture.authority.resolvePath(
                'attachment_archive',
              ),
            ),
          ),
        ),
        attachmentArchiveStatsReaderProvider.overrideWith(
          (ref) async => statsReader,
        ),
        attachmentArchiveFileOperationsProvider.overrideWith(
          (ref) => fileOperations,
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await archiveFixture.dispose();
  });

  test(
    'defaults archive enabled without scanning archive statistics',
    () async {
      final state = await container.read(archiveSettingsProvider.future);

      expect(state.isEnabled, isTrue);
      expect(statsReader.readCount, 0);
    },
  );

  test('only explicit false disables archive setting', () async {
    settingsStore.settings['attachment_archive_enabled'] = 'false';

    final disabledState = await container.read(archiveSettingsProvider.future);

    expect(disabledState.isEnabled, isFalse);

    settingsStore.settings['attachment_archive_enabled'] = 'anything-else';
    container.invalidate(archiveSettingsProvider);
    final enabledState = await container.read(archiveSettingsProvider.future);

    expect(enabledState.isEnabled, isTrue);
  });

  test('statistics are scanned only through the explicit provider', () async {
    await container.read(archiveSettingsProvider.future);
    expect(statsReader.readCount, 0);

    final inventory = await container.read(
      attachmentArchiveStatisticsProvider.future,
    );

    expect(inventory.isAvailable, isTrue);
    expect(inventory.stats?.recordCount, 12);
    expect(inventory.stats?.sizeBytes, 1536);
    expect(statsReader.readCount, 1);
  });

  test('location refresh does not trigger a statistics scan', () async {
    await container.read(archiveSettingsProvider.future);

    container.invalidate(attachmentArchiveLocationProvider);
    await container.read(attachmentArchiveLocationProvider.future);

    expect(statsReader.readCount, 0);
  });

  test('parses sweep and manual sweep diagnostics from settings', () async {
    settingsStore.settings.addAll(<String, String>{
      kArchiveSweepCursorKey: '120',
      kArchiveSweepLastStartedAtUtcKey: '2026-06-19T10:00:00.000Z',
      kArchiveSweepLastCompletedAtUtcKey: '2026-06-19T10:01:00.000Z',
      kArchiveSweepLastTotalScannedKey: '10',
      kArchiveSweepLastNewlyArchivedKey: '7',
      kArchiveSweepLastSkippedKey: '2',
      kArchiveSweepLastFailedKey: '1',
      kArchiveManualSweepLastStartedAtUtcKey: '2026-06-19T11:00:00.000Z',
      kArchiveManualSweepLastCompletedAtUtcKey: '2026-06-19T11:02:00.000Z',
      kArchiveManualSweepLastTotalScannedKey: '20',
      kArchiveManualSweepLastNewlyArchivedKey: '17',
      kArchiveManualSweepLastSkippedKey: '2',
      kArchiveManualSweepLastFailedKey: '1',
      kArchiveManualSweepLastSkippedSamplesKey: ' first.jpg \n\n second.jpg ',
    });

    final state = await container.read(archiveSettingsProvider.future);

    expect(state.sweepDebug.cursor, 120);
    expect(state.sweepDebug.lastTotalScanned, 10);
    expect(state.sweepDebug.lastNewlyArchived, 7);
    expect(state.sweepDebug.lastSkipped, 2);
    expect(state.sweepDebug.lastFailed, 1);
    expect(state.sweepDebug.hasCompletedRun, isTrue);
    expect(
      state.sweepDebug.lastResultLabel,
      'Scanned 10, archived 7, skipped 2, failed 1',
    );
    expect(state.manualSweepDebug.lastTotalScanned, 20);
    expect(state.manualSweepDebug.lastNewlyArchived, 17);
    expect(state.manualSweepDebug.lastSkippedSamples, <String>[
      'first.jpg',
      'second.jpg',
    ]);
  });

  test('setEnabled writes overlay setting and refreshes state', () async {
    await container
        .read(archiveSettingsProvider.notifier)
        .setEnabled(enabled: false);

    expect(settingsStore.settings['attachment_archive_enabled'], 'false');
    final state = await container.read(archiveSettingsProvider.future);
    expect(state.isEnabled, isFalse);
  });

  test(
    'clearArchive resets files and archive records without disabling archive',
    () async {
      settingsStore.settings['attachment_archive_enabled'] = 'true';

      await container.read(archiveSettingsProvider.notifier).clearArchive();

      expect(fileOperations.resetPaths, <String>[
        archiveFixture.authority.resolvePath('attachment_archive'),
      ]);
      expect(settingsStore.archiveRecordsCleared, isTrue);
      final state = await container.read(archiveSettingsProvider.future);
      expect(state.isEnabled, isTrue);
    },
  );
}

final class _FakeArchiveSettingsStore
    implements AttachmentArchiveSettingsStore {
  final settings = <String, String>{};
  var archiveRecordsCleared = false;

  @override
  Future<void> clearArchivedAttachmentRecords() async {
    archiveRecordsCleared = true;
  }

  @override
  Future<String?> readSetting(String key) async {
    return settings[key];
  }

  @override
  Future<void> writeSetting({
    required String key,
    required String value,
  }) async {
    settings[key] = value;
  }
}

final class _FakeArchiveStatsReader implements AttachmentArchiveStatsReader {
  _FakeArchiveStatsReader(this.stats);

  final AttachmentArchiveStats stats;
  var readCount = 0;

  @override
  Future<AttachmentArchiveStats> readStats() async {
    readCount += 1;
    return stats;
  }
}

final class _FakeArchiveFileOperations
    implements AttachmentArchiveFileOperations {
  final resetPaths = <String>[];

  @override
  Future<int?> exportArchiveDirectory(String archiveDirectoryPath) async {
    return 0;
  }

  @override
  Future<void> resetArchiveDirectory(String archiveDirectoryPath) async {
    resetPaths.add(archiveDirectoryPath);
  }
}

final class _FixedAttachmentArchiveLocation extends AttachmentArchiveLocation {
  _FixedAttachmentArchiveLocation(this.location);

  final AttachmentArchiveLocationState location;

  @override
  Future<AttachmentArchiveLocationState> build() async => location;
}
