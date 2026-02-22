/// For the "Top Chats" menu in the sidebar (SidebarUtilityCassetteSpec.topChatMenu).
/// Defines the possible choices for the menu. Use for (1) building the menu,
/// (2) interpreting the user's choice, and (3) serializing the choice in the feature
/// cassette spec.
enum TopChatMenuChoice {
  /// Contacts list
  contacts(id: 'contacts', label: 'From contacts'),

  /// Handles not matched to any contact (phone #, email, business URN)
  strayHandles(id: 'stray_handles', label: 'From unfamiliar sources'),

  /// Search all messages in the database (global timeline)
  searchAllMessages(id: 'search_all_messages', label: 'Search all messages'),

  /// Theme playground (for development)
  themePlayground(id: 'theme_playground', label: 'Theme playground');

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
  /// Contacts-related settings
  contacts(id: 'contacts', label: 'Contacts');

  const SettingsMenuChoice({required this.id, required this.label});

  /// A stable, non-display identifier that you can use
  /// for serialization, logging, etc.
  final String id;

  /// Human-oriented label.
  final String label;

  static SettingsMenuChoice fromId(String id) {
    return SettingsMenuChoice.values.firstWhere(
      (c) => c.id == id,
      orElse: () => SettingsMenuChoice.contacts,
    );
  }
}
