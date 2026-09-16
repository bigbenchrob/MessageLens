import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_environment/domain.dart'
    show ArchiveMutationOperation;
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show archiveMutationCoordinatorProvider;
import 'attachment_archive_location_provider.dart';
import 'attachment_archive_runtime_providers.dart'
    show attachmentArchiveFileOperationsProvider;
import 'attachment_archive_settings_store.dart';
import 'attachment_archive_settings_store_provider.dart';

part 'archive_settings_provider.g.dart';

const _kArchiveEnabledKey = 'attachment_archive_enabled';
const kArchiveSweepCursorKey = 'attachment_archive_sweep_cursor';
const kArchiveSweepLastStartedAtUtcKey =
    'attachment_archive_sweep_last_started_at_utc';
const kArchiveSweepLastCompletedAtUtcKey =
    'attachment_archive_sweep_last_completed_at_utc';
const kArchiveSweepLastTotalScannedKey =
    'attachment_archive_sweep_last_total_scanned';
const kArchiveSweepLastNewlyArchivedKey =
    'attachment_archive_sweep_last_newly_archived';
const kArchiveSweepLastSkippedKey = 'attachment_archive_sweep_last_skipped';
const kArchiveSweepLastFailedKey = 'attachment_archive_sweep_last_failed';
const kArchiveManualSweepLastStartedAtUtcKey =
    'attachment_archive_manual_sweep_last_started_at_utc';
const kArchiveManualSweepLastCompletedAtUtcKey =
    'attachment_archive_manual_sweep_last_completed_at_utc';
const kArchiveManualSweepLastTotalScannedKey =
    'attachment_archive_manual_sweep_last_total_scanned';
const kArchiveManualSweepLastNewlyArchivedKey =
    'attachment_archive_manual_sweep_last_newly_archived';
const kArchiveManualSweepLastSkippedKey =
    'attachment_archive_manual_sweep_last_skipped';
const kArchiveManualSweepLastFailedKey =
    'attachment_archive_manual_sweep_last_failed';
const kArchiveManualSweepLastSkippedSamplesKey =
    'attachment_archive_manual_sweep_last_skipped_samples';

/// Manages the attachment archive user preferences.
///
/// The archive-enabled flag is persisted in the overlay DB's
/// `overlay_settings` key-value table so it survives derived-data rebuilds.
@Riverpod(keepAlive: true)
class ArchiveSettings extends _$ArchiveSettings {
  @override
  Future<ArchiveSettingsState> build() async {
    final settingsStore = await ref.watch(
      attachmentArchiveSettingsStoreProvider.future,
    );

    // Read enabled flag from overlay settings.
    final enabledStr = await settingsStore.readSetting(_kArchiveEnabledKey);
    final enabled = enabledStr != 'false'; // Default: enabled.

    final sweepDebug = await _readSweepDebugState(settingsStore);
    final manualSweepDebug = await _readManualSweepDebugState(settingsStore);

    return ArchiveSettingsState(
      isEnabled: enabled,
      sweepDebug: sweepDebug,
      manualSweepDebug: manualSweepDebug,
    );
  }

  Future<void> setEnabled({required bool enabled}) async {
    final settingsStore = await ref.read(
      attachmentArchiveSettingsStoreProvider.future,
    );
    await settingsStore.writeSetting(
      key: _kArchiveEnabledKey,
      value: enabled.toString(),
    );
    ref.invalidateSelf();
  }

  Future<void> clearArchive() {
    return ref
        .read(archiveMutationCoordinatorProvider.notifier)
        .run<void>(
          operation: ArchiveMutationOperation.attachmentClearing,
          ownerLabel: 'attachment-archive-clear',
          action: () async {
            final mutationRoot = await ref.read(
              attachmentArchiveMutationRootProvider.future,
            );
            final archiveFileOperations = ref.read(
              attachmentArchiveFileOperationsProvider,
            );
            final settingsStore = await ref.read(
              attachmentArchiveSettingsStoreProvider.future,
            );

            await archiveFileOperations.resetArchiveDirectory(
              mutationRoot.archiveRootPath,
            );
            await settingsStore.clearArchivedAttachmentRecords();

            ref.invalidateSelf();
          },
        );
  }

  /// Returns the number of files copied, or `null` if the user cancelled.
  Future<int?> exportArchive() async {
    final location = await ref.read(attachmentArchiveLocationProvider.future);
    final archiveDir = location.requireArchiveRootPath();
    final archiveFileOperations = ref.read(
      attachmentArchiveFileOperationsProvider,
    );
    return archiveFileOperations.exportArchiveDirectory(archiveDir);
  }

  static Future<ArchiveSweepDebugState> _readSweepDebugState(
    AttachmentArchiveSettingsStore settingsStore,
  ) async {
    return ArchiveSweepDebugState(
      cursor: _parseInt(
        await settingsStore.readSetting(kArchiveSweepCursorKey),
      ),
      lastStartedAtUtc: await settingsStore.readSetting(
        kArchiveSweepLastStartedAtUtcKey,
      ),
      lastCompletedAtUtc: await settingsStore.readSetting(
        kArchiveSweepLastCompletedAtUtcKey,
      ),
      lastTotalScanned: _parseInt(
        await settingsStore.readSetting(kArchiveSweepLastTotalScannedKey),
      ),
      lastNewlyArchived: _parseInt(
        await settingsStore.readSetting(kArchiveSweepLastNewlyArchivedKey),
      ),
      lastSkipped: _parseInt(
        await settingsStore.readSetting(kArchiveSweepLastSkippedKey),
      ),
      lastFailed: _parseInt(
        await settingsStore.readSetting(kArchiveSweepLastFailedKey),
      ),
    );
  }

  static Future<ArchiveSweepRunDebugState> _readManualSweepDebugState(
    AttachmentArchiveSettingsStore settingsStore,
  ) async {
    return ArchiveSweepRunDebugState(
      lastStartedAtUtc: await settingsStore.readSetting(
        kArchiveManualSweepLastStartedAtUtcKey,
      ),
      lastCompletedAtUtc: await settingsStore.readSetting(
        kArchiveManualSweepLastCompletedAtUtcKey,
      ),
      lastTotalScanned: _parseInt(
        await settingsStore.readSetting(kArchiveManualSweepLastTotalScannedKey),
      ),
      lastNewlyArchived: _parseInt(
        await settingsStore.readSetting(
          kArchiveManualSweepLastNewlyArchivedKey,
        ),
      ),
      lastSkipped: _parseInt(
        await settingsStore.readSetting(kArchiveManualSweepLastSkippedKey),
      ),
      lastFailed: _parseInt(
        await settingsStore.readSetting(kArchiveManualSweepLastFailedKey),
      ),
      lastSkippedSamples: _parseLines(
        await settingsStore.readSetting(
          kArchiveManualSweepLastSkippedSamplesKey,
        ),
      ),
    );
  }

  static int _parseInt(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return 0;
    }

    return int.tryParse(rawValue) ?? 0;
  }

  static List<String> _parseLines(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return const [];
    }

    return rawValue
        .split('\n')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }
}

class ArchiveSettingsState {
  const ArchiveSettingsState({
    required this.isEnabled,
    required this.sweepDebug,
    required this.manualSweepDebug,
  });

  final bool isEnabled;
  final ArchiveSweepDebugState sweepDebug;
  final ArchiveSweepRunDebugState manualSweepDebug;
}

class ArchiveSweepDebugState {
  const ArchiveSweepDebugState({
    required this.cursor,
    required this.lastStartedAtUtc,
    required this.lastCompletedAtUtc,
    required this.lastTotalScanned,
    required this.lastNewlyArchived,
    required this.lastSkipped,
    required this.lastFailed,
  });

  final int cursor;
  final String? lastStartedAtUtc;
  final String? lastCompletedAtUtc;
  final int lastTotalScanned;
  final int lastNewlyArchived;
  final int lastSkipped;
  final int lastFailed;

  bool get hasCompletedRun => lastCompletedAtUtc != null;

  String get lastStartedLabel => _formatTimestamp(lastStartedAtUtc);

  String get lastCompletedLabel => _formatTimestamp(lastCompletedAtUtc);

  String get lastResultLabel =>
      'Scanned $lastTotalScanned, archived $lastNewlyArchived, '
      'skipped $lastSkipped, failed $lastFailed';

  static String _formatTimestamp(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return 'Never';
    }

    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) {
      return rawValue;
    }

    final local = parsed.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute:$second';
  }
}

class ArchiveSweepRunDebugState {
  const ArchiveSweepRunDebugState({
    required this.lastStartedAtUtc,
    required this.lastCompletedAtUtc,
    required this.lastTotalScanned,
    required this.lastNewlyArchived,
    required this.lastSkipped,
    required this.lastFailed,
    required this.lastSkippedSamples,
  });

  final String? lastStartedAtUtc;
  final String? lastCompletedAtUtc;
  final int lastTotalScanned;
  final int lastNewlyArchived;
  final int lastSkipped;
  final int lastFailed;
  final List<String> lastSkippedSamples;

  bool get hasCompletedRun => lastCompletedAtUtc != null;

  String get lastStartedLabel =>
      ArchiveSweepDebugState._formatTimestamp(lastStartedAtUtc);

  String get lastCompletedLabel =>
      ArchiveSweepDebugState._formatTimestamp(lastCompletedAtUtc);

  String get lastResultLabel =>
      'Scanned $lastTotalScanned, archived $lastNewlyArchived, '
      'skipped $lastSkipped, failed $lastFailed';
}
