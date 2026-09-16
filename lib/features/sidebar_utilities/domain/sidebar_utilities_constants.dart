/// For the "Top Chats" menu in the sidebar (SidebarUtilityCassetteSpec.topChatMenu).
/// Defines the possible choices for the menu. Use for (1) building the menu,
/// (2) interpreting the user's choice, and (3) serializing the choice in the feature
/// cassette spec.
enum TopChatMenuChoice {
  /// Canonical conversation graph browser.
  conversations(id: 'conversations', label: 'Conversations'),

  /// Contacts list
  contacts(id: 'contacts', label: 'Messages from contacts'),

  /// Handles not matched to any contact (phone #, email, business URN)
  strayHandles(id: 'stray_handles', label: 'From unfamiliar sources'),

  /// Search all messages in the database (global timeline)
  searchAllMessages(id: 'search_all_messages', label: 'Search all messages'),

  /// Source messages recovered outside the normal chat linkage model.
  recoveredUnlinkedMessages(
    id: 'recovered_unlinked_messages',
    label: 'Recovered deleted messages',
  ),

  /// Recovered orphaned records with no surviving handle linkage.
  recoveredNoHandleFromMeMessages(
    id: 'recovered_no_handle_from_me_messages',
    label: 'Recovered no-handle messages',
  );

  const TopChatMenuChoice({required this.id, required this.label});

  /// A stable, non-display identifier that you can use
  /// for serialization, logging, etc.
  final String id;

  /// Human-oriented label (you can swap this out for localization later).
  final String label;

  static TopChatMenuChoice fromId(String id) {
    return TopChatMenuChoice.values.firstWhere(
      (c) => c.id == id,
      orElse: () => defaultTopChatMenuChoice,
    );
  }
}

const defaultTopChatMenuChoice = TopChatMenuChoice.conversations;

enum SettingsMenuActionId {
  attachmentArchive(id: 'attachments_archive', label: 'Attachment archive'),
  historicalArchives(id: 'historical_archives', label: 'Historical Archives'),
  messageHistoryCoverage(
    id: 'message_history_coverage',
    label: 'Message history coverage report',
  ),
  sendLogs(id: 'send_logs', label: 'Send logs…'),
  resetMessageData(id: 'reset_message_data', label: 'Reset message data…'),
  textSize(id: 'text_size', label: 'Text size'),
  imageSize(id: 'image_size', label: 'Image size');

  const SettingsMenuActionId({required this.id, required this.label});

  final String id;
  final String label;

  static SettingsMenuActionId fromId(String id) {
    return SettingsMenuActionId.values.firstWhere(
      (actionId) => actionId.id == id,
      orElse: () => SettingsMenuActionId.sendLogs,
    );
  }
}

extension SettingsMenuActionIdX on SettingsMenuActionId {
  bool get isPersistentContext {
    return switch (this) {
      SettingsMenuActionId.attachmentArchive ||
      SettingsMenuActionId.historicalArchives ||
      SettingsMenuActionId.messageHistoryCoverage ||
      SettingsMenuActionId.textSize ||
      SettingsMenuActionId.imageSize => true,
      SettingsMenuActionId.sendLogs ||
      SettingsMenuActionId.resetMessageData => false,
    };
  }
}
