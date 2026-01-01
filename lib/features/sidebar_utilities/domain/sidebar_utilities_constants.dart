/// For the "Top Chats" menu in the sidebar (SidebarUtilityCassetteSpec.topChatMenu).
/// Defines the possible choices for the menu. Use for (1) building the menu,
/// (2) interpreting the user's choice, and (3) serializing the choice in the feature
/// cassette spec.
enum TopChatMenuChoice {
  /// Contacts list
  contacts(id: 'contacts', label: 'Contacts'),

  /// New global timeline experience (V2)
  globalTimeline(id: 'global_timeline', label: 'Global timeline'),

  /// All messages in the database
  allMessages(id: 'all_messages', label: 'All messages'),

  /// Phone numbers not matched to any contact
  strayPhoneNumbers(id: 'stray_phone_numbers', label: 'Stray phone numbers'),

  /// Email addresses not matched to any contact
  strayEmails(id: 'stray_emails', label: 'Stray emails'),

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
  /// General settings
  general(id: 'general', label: 'General'),

  /// Appearance settings
  appearance(id: 'appearance', label: 'Appearance'),

  /// Contact short names settings
  contactShortNames(id: 'contact_short_names', label: 'Contact Short Names');

  const SettingsMenuChoice({required this.id, required this.label});

  /// A stable, non-display identifier that you can use
  /// for serialization, logging, etc.
  final String id;

  /// Human-oriented label.
  final String label;

  static SettingsMenuChoice fromId(String id) {
    return SettingsMenuChoice.values.firstWhere(
      (c) => c.id == id,
      orElse: () => SettingsMenuChoice.general,
    );
  }
}
