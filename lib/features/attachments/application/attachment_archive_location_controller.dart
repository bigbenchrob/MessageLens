import '../../../essentials/archive_environment/domain/archive_access_authority.dart';
import '../domain/entities/attachment_archive_location_configuration.dart';
import '../domain/entities/attachment_archive_location_state.dart';
import 'attachment_archive_settings_store.dart';

const attachmentArchiveLocationSettingKey = 'attachment_archive_location';

/// Owns attachment archive location configuration and default-root derivation.
///
/// Phase One deliberately resolves only the existing internal location. It
/// performs no filesystem access and writes no setting merely to establish the
/// default.
final class AttachmentArchiveLocationController {
  const AttachmentArchiveLocationController({
    required ArchiveAccessAuthority archiveAccessAuthority,
    required AttachmentArchiveSettingsStore settingsStore,
  }) : _archiveAccessAuthority = archiveAccessAuthority,
       _settingsStore = settingsStore;

  static const defaultArchiveDirectoryName = 'attachment_archive';

  final ArchiveAccessAuthority _archiveAccessAuthority;
  final AttachmentArchiveSettingsStore _settingsStore;

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
      AttachmentArchiveLocationMode.customExternal =>
        AttachmentArchiveLocationState.configurationInvalid(
          configuration: configuration,
          issue:
              'Custom external attachment archive locations are not supported '
              'until the native location phase is implemented.',
        ),
    };
  }

  Future<void> persistConfiguration(
    AttachmentArchiveLocationConfiguration configuration,
  ) async {
    if (configuration.mode != AttachmentArchiveLocationMode.defaultInternal) {
      throw UnsupportedError(
        'Phase One can persist only the default internal attachment archive '
        'configuration.',
      );
    }
    await _settingsStore.writeSetting(
      key: attachmentArchiveLocationSettingKey,
      value: configuration.toPersistedValue(),
    );
  }
}
