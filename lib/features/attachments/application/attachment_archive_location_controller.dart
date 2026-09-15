import '../../../essentials/archive_environment/domain/archive_access_authority.dart';
import '../domain/entities/attachment_archive_location_configuration.dart';
import '../domain/entities/attachment_archive_location_state.dart';
import 'attachment_archive_location_native_adapter.dart';
import 'attachment_archive_settings_store.dart';

const attachmentArchiveLocationSettingKey = 'attachment_archive_location';

/// Owns attachment archive location configuration and default-root derivation.
///
/// Custom locations resolve only through the native bookmark adapter. The
/// remembered display path is never used as a fallback root.
final class AttachmentArchiveLocationController {
  const AttachmentArchiveLocationController({
    required ArchiveAccessAuthority archiveAccessAuthority,
    required AttachmentArchiveSettingsStore settingsStore,
    required AttachmentArchiveLocationNativeAdapter nativeAdapter,
  }) : _archiveAccessAuthority = archiveAccessAuthority,
       _settingsStore = settingsStore,
       _nativeAdapter = nativeAdapter;

  static const defaultArchiveDirectoryName = 'attachment_archive';

  final ArchiveAccessAuthority _archiveAccessAuthority;
  final AttachmentArchiveSettingsStore _settingsStore;
  final AttachmentArchiveLocationNativeAdapter _nativeAdapter;

  Future<AttachmentArchiveLocationState> load() async {
    final persistedValue = await _settingsStore.readSetting(
      attachmentArchiveLocationSettingKey,
    );

    AttachmentArchiveLocationConfiguration configuration;
    if (persistedValue == null || persistedValue.trim().isEmpty) {
      configuration =
          const AttachmentArchiveLocationConfiguration.defaultInternal();
    } else {
      try {
        configuration =
            AttachmentArchiveLocationConfiguration.fromPersistedValue(
              persistedValue,
            );
      } on FormatException catch (error) {
        return AttachmentArchiveLocationState.configurationInvalid(
          issue: error.message,
        );
      }
    }

    return switch (configuration.mode) {
      AttachmentArchiveLocationMode.defaultInternal =>
        AttachmentArchiveLocationState.defaultAvailable(
          configuration: configuration,
          archiveRootPath: _archiveAccessAuthority.resolvePath(
            defaultArchiveDirectoryName,
          ),
        ),
      AttachmentArchiveLocationMode.customExternal => await _resolveCustom(
        configuration,
      ),
    };
  }

  Future<void> persistConfiguration(
    AttachmentArchiveLocationConfiguration configuration,
  ) async {
    await _settingsStore.writeSetting(
      key: attachmentArchiveLocationSettingKey,
      value: configuration.toPersistedValue(),
    );
  }

  Future<AttachmentArchiveLocationState> _resolveCustom(
    AttachmentArchiveLocationConfiguration configuration,
  ) async {
    final bookmarkData = configuration.bookmarkDataBase64;
    if (bookmarkData == null) {
      return AttachmentArchiveLocationState.configurationInvalid(
        configuration: configuration,
        issue: 'Custom attachment archive bookmark data is missing.',
      );
    }
    final resolution = await _nativeAdapter.resolveBookmark(
      bookmarkDataBase64: bookmarkData,
    );
    final issue = resolution.issue ?? _defaultIssue(resolution.status);
    return switch (resolution.status) {
      AttachmentArchiveBookmarkResolutionStatus.available =>
        await _availableCustomState(
          configuration: configuration,
          resolution: resolution,
          readOnly: false,
        ),
      AttachmentArchiveBookmarkResolutionStatus.readOnly =>
        await _availableCustomState(
          configuration: configuration,
          resolution: resolution,
          readOnly: true,
        ),
      AttachmentArchiveBookmarkResolutionStatus.unavailable =>
        AttachmentArchiveLocationState.customUnavailable(
          configuration: configuration,
          issue: issue,
        ),
      AttachmentArchiveBookmarkResolutionStatus.permissionDenied =>
        AttachmentArchiveLocationState.permissionDenied(
          configuration: configuration,
          issue: issue,
        ),
      AttachmentArchiveBookmarkResolutionStatus.configuredDirectoryMissing =>
        AttachmentArchiveLocationState.configuredDirectoryMissing(
          configuration: configuration,
          issue: issue,
        ),
      AttachmentArchiveBookmarkResolutionStatus.invalidBookmark =>
        AttachmentArchiveLocationState.configurationInvalid(
          configuration: configuration,
          issue: issue,
        ),
    };
  }

  Future<AttachmentArchiveLocationState> _availableCustomState({
    required AttachmentArchiveLocationConfiguration configuration,
    required AttachmentArchiveBookmarkResolution resolution,
    required bool readOnly,
  }) async {
    final resolvedPath = resolution.resolvedPath?.trim();
    if (resolvedPath == null || resolvedPath.isEmpty) {
      return AttachmentArchiveLocationState.configurationInvalid(
        configuration: configuration,
        issue: 'Resolved custom attachment archive path is missing.',
      );
    }
    final currentBookmark = configuration.bookmarkDataBase64;
    if (currentBookmark == null) {
      return AttachmentArchiveLocationState.configurationInvalid(
        configuration: configuration,
        issue: 'Custom attachment archive bookmark data is missing.',
      );
    }
    final refreshedConfiguration = configuration.withResolvedMetadata(
      bookmarkDataBase64:
          resolution.refreshedBookmarkDataBase64 ?? currentBookmark,
      lastKnownPath: resolvedPath,
      volumeName: resolution.volumeName ?? configuration.volumeName,
    );
    if (refreshedConfiguration != configuration) {
      await persistConfiguration(refreshedConfiguration);
    }
    if (readOnly) {
      return AttachmentArchiveLocationState.customReadOnly(
        configuration: refreshedConfiguration,
        archiveRootPath: resolvedPath,
        issue: resolution.issue,
      );
    }
    return AttachmentArchiveLocationState.customAvailable(
      configuration: refreshedConfiguration,
      archiveRootPath: resolvedPath,
    );
  }

  static String _defaultIssue(
    AttachmentArchiveBookmarkResolutionStatus status,
  ) {
    return switch (status) {
      AttachmentArchiveBookmarkResolutionStatus.available ||
      AttachmentArchiveBookmarkResolutionStatus.readOnly =>
        'Resolved custom attachment archive path is unavailable.',
      AttachmentArchiveBookmarkResolutionStatus.unavailable =>
        'The configured external attachment archive is unavailable.',
      AttachmentArchiveBookmarkResolutionStatus.permissionDenied =>
        'Permission to read the configured attachment archive was denied.',
      AttachmentArchiveBookmarkResolutionStatus.configuredDirectoryMissing =>
        'The configured attachment archive directory is missing.',
      AttachmentArchiveBookmarkResolutionStatus.invalidBookmark =>
        'The configured attachment archive bookmark is invalid.',
    };
  }
}
