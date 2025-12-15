/// For the "Top Chats" menu in the sidebar (SidebarUtilityCassetteSpec.topChatMenu).
/// Defines the possible choices for the menu. Use for (1) building the menu,
/// (2) interpreting the user's choice, and (3) serializing the choice in the feature
/// cassette spec.
enum TopChatMenuChoice {
  contacts(id: 'contacts', label: 'Contacts'),
  unmatchedHandles(
    id: 'unmatched_handles',
    label: 'Unmatched phone numbers and emails',
  ),
  allMessages(id: 'all_messages', label: 'All messages'),
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
