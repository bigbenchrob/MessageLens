/// High-level stages emitted during the database import pipeline.
///
/// Each stage uses a stable [key] so downstream telemetry can react without
/// depending on display strings. The [label] is intended for human-friendly
/// status messages.
enum DbImportStage {
  preparingSources('preparingSources', 'Preparing import sources'),
  clearingLedger('clearingLedger', 'Clearing previous ledger data'),
  importingHandles('importingHandles', 'Importing message handles'),
  importingChats('importingChats', 'Importing chats'),
  importingParticipants(
    'importingParticipants',
    'Linking chats to participants',
  ),
  importingMessages('importingMessages', 'Importing messages'),
  extractingRichContent(
    'extractingRichContent',
    'Extracting rich message content',
  ),
  importingAttachments('importingAttachments', 'Importing attachments'),
  linkingMessageArtifacts(
    'linkingMessageArtifacts',
    'Linking message relationships',
  ),
  importingAddressBook(
    'importingAddressBook',
    'Importing AddressBook contacts',
  ),
  linkingContacts('linkingContacts', 'Linking contacts with handles'),
  completed('completed', 'Import completed');

  const DbImportStage(this.key, this.label);

  /// Stable identifier suitable for logs/analytics.
  final String key;

  /// Human friendly description for progress UI.
  final String label;
}
