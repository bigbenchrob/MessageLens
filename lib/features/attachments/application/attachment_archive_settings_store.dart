/// Minimal persistence boundary for attachment archive settings.
///
/// The application layer owns the setting keys and their meaning. The concrete
/// store owns where those settings and archive records live.
const attachmentArchiveEnabledSettingKey = 'attachment_archive_enabled';

abstract class AttachmentArchiveSettingsStore {
  Future<String?> readSetting(String key);

  Future<void> writeSetting({required String key, required String value});

  Future<void> clearArchivedAttachmentRecords();
}
