/// User-facing phases shown in the onboarding stepper.
///
/// These are simplified projections of the internal import/migration stages,
/// designed to provide even visual pacing even as internals are refactored.
enum DbOnboardingPhase {
  /// Checking Full Disk Access permission
  checkingPermissions,

  /// Looking for and verifying Messages database (chat.db)
  messagesDatabase,

  /// Importing conversation structure (handles, chats, participants)
  conversationMetadata,

  /// Importing message records (the big one)
  importingMessages,

  /// Extracting rich text content from messages
  processingContent,

  /// Importing attachments and linking to messages
  importingAttachments,

  /// Importing and linking contacts from AddressBook
  contactsDatabase,

  /// Setup complete, ready to use
  complete,

  /// An error occurred during setup
  error,
}

/// Extension methods for [DbOnboardingPhase].
extension DbOnboardingPhaseX on DbOnboardingPhase {
  /// Human-readable label for this phase when pending.
  String get pendingLabel => switch (this) {
    DbOnboardingPhase.checkingPermissions => 'System Permissions',
    DbOnboardingPhase.messagesDatabase => 'macOS Messages Database',
    DbOnboardingPhase.conversationMetadata => 'Conversation Metadata',
    DbOnboardingPhase.importingMessages => 'Messages',
    DbOnboardingPhase.processingContent => 'Message Content',
    DbOnboardingPhase.importingAttachments => 'Attachments',
    DbOnboardingPhase.contactsDatabase => 'Contacts Database',
    DbOnboardingPhase.complete => 'Setup Complete',
    DbOnboardingPhase.error => 'Setup Error',
  };

  /// Human-readable label for this phase when active.
  String get activeLabel => switch (this) {
    DbOnboardingPhase.checkingPermissions => 'Checking system permissions...',
    DbOnboardingPhase.messagesDatabase => 'Locating messages database...',
    DbOnboardingPhase.conversationMetadata =>
      'Importing conversation metadata...',
    DbOnboardingPhase.importingMessages => 'Importing messages...',
    DbOnboardingPhase.processingContent => 'Processing message content...',
    DbOnboardingPhase.importingAttachments => 'Importing attachments...',
    DbOnboardingPhase.contactsDatabase => 'Importing contacts...',
    DbOnboardingPhase.complete => 'Setup Complete',
    DbOnboardingPhase.error => 'Setup Error',
  };

  /// Human-readable label for this phase when complete.
  String get completeLabel => switch (this) {
    DbOnboardingPhase.checkingPermissions => 'Permissions verified',
    DbOnboardingPhase.messagesDatabase => 'Messages database found',
    DbOnboardingPhase.conversationMetadata => 'Conversation metadata imported',
    DbOnboardingPhase.importingMessages => 'Messages imported',
    DbOnboardingPhase.processingContent => 'Message content processed',
    DbOnboardingPhase.importingAttachments => 'Attachments imported',
    DbOnboardingPhase.contactsDatabase => 'Contacts imported',
    DbOnboardingPhase.complete => 'Setup Complete',
    DbOnboardingPhase.error => 'Setup Error',
  };

  /// Legacy label getter for backward compatibility.
  String get label => pendingLabel;

  /// Whether this phase represents a terminal state.
  bool get isTerminal =>
      this == DbOnboardingPhase.complete || this == DbOnboardingPhase.error;

  /// The ordered index of this phase in the stepper (0-based).
  /// Returns -1 for error state.
  int get stepIndex => switch (this) {
    DbOnboardingPhase.checkingPermissions => 0,
    DbOnboardingPhase.messagesDatabase => 1,
    DbOnboardingPhase.conversationMetadata => 2,
    DbOnboardingPhase.importingMessages => 3,
    DbOnboardingPhase.processingContent => 4,
    DbOnboardingPhase.importingAttachments => 5,
    DbOnboardingPhase.contactsDatabase => 6,
    DbOnboardingPhase.complete => 7,
    DbOnboardingPhase.error => -1,
  };
}

/// All phases in stepper display order.
const kDbOnboardingPhaseOrder = [
  DbOnboardingPhase.checkingPermissions,
  DbOnboardingPhase.messagesDatabase,
  DbOnboardingPhase.conversationMetadata,
  DbOnboardingPhase.importingMessages,
  DbOnboardingPhase.processingContent,
  DbOnboardingPhase.importingAttachments,
  DbOnboardingPhase.contactsDatabase,
  DbOnboardingPhase.complete,
];
