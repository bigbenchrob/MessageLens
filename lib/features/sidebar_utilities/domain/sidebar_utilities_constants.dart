/// For the "Top Chats" menu in the sidebar (SidebarUtilityCassetteSpec.topChatMenu).
/// Defines the possible choices for the menu. Use for (1) building the menu,
/// (2) interpreting the user's choice, and (3) serializing the choice in the feature
/// cassette spec.
enum TopChatMenuChoice {
  /// Contacts list
  contacts(id: 'contacts', label: 'Messages from contacts'),

  /// Handles not matched to any contact (phone #, email, business URN)
  strayHandles(id: 'stray_handles', label: 'From unfamiliar sources'),

  /// Source messages recovered outside the normal chat linkage model.
  recoveredUnlinkedMessages(
    id: 'recovered_unlinked_messages',
    label: 'Recovered Deleted Messages',
  ),

  /// Recovered orphaned records with no surviving handle linkage.
  recoveredNoHandleFromMeMessages(
    id: 'recovered_no_handle_from_me_messages',
    label: 'Recovered No-Handle Messages',
  ),

  /// Search all messages in the database (global timeline)
  searchAllMessages(id: 'search_all_messages', label: 'Search all messages');

  const TopChatMenuChoice({required this.id, required this.label});

  /// A stable, non-display identifier that you can use
  /// for serialization, logging, etc.
  final String id;

  /// Human-oriented label (you can swap this out for localization later).
  final String label;

  static TopChatMenuChoice fromId(String id) {
    return TopChatMenuChoice.values.firstWhere(
      (c) => c.id == id,
      orElse: () => TopChatMenuChoice.contacts,
    );
  }
}

/// For the "Settings" menu in the sidebar (SidebarUtilityCassetteSpec.settingsMenu).
/// Defines the possible choices for the menu.
enum SettingsMenuChoice {
  /// Actions panel with Send Logs and other utilities
  actions(id: 'actions', label: 'Actions');

  const SettingsMenuChoice({required this.id, required this.label});

  /// A stable, non-display identifier that you can use
  /// for serialization, logging, etc.
  final String id;

  /// Human-oriented label.
  final String label;

  static SettingsMenuChoice fromId(String id) {
    return SettingsMenuChoice.values.firstWhere(
      (c) => c.id == id,
      orElse: () => SettingsMenuChoice.actions,
    );
  }
}

/// For the "Actions" submenu in settings mode.
/// Defines the possible actions available to the user.
enum ActionsMenuChoice {
  /// Send diagnostic logs for troubleshooting
  sendLogs(id: 'send_logs', label: 'Send Logs\u2026'),

  /// Reimport all chat and address book data
  reimportData(id: 'reimport_data', label: 'Reimport Data\u2026');

  const ActionsMenuChoice({required this.id, required this.label});

  final String id;
  final String label;

  static ActionsMenuChoice fromId(String id) {
    return ActionsMenuChoice.values.firstWhere(
      (c) => c.id == id,
      orElse: () => ActionsMenuChoice.sendLogs,
    );
  }
}
