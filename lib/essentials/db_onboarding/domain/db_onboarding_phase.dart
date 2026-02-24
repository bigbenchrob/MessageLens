/// User-facing phases shown in the onboarding stepper.
///
/// These are simplified projections of the internal import/migration stages,
/// designed to be stable even as internals are refactored.
enum DbOnboardingPhase {
  /// Checking Full Disk Access permission
  checkingPermissions,

  /// Looking for Messages database (chat.db)
  locatingMessages,

  /// Messages database found successfully
  messagesFound,

  /// Reading and importing message data
  importingMessages,

  /// Looking for AddressBook database
  locatingContacts,

  /// Connecting chats to contacts
  linkingContacts,

  /// Setup complete, ready to use
  complete,

  /// An error occurred during setup
  error,
}

/// Extension methods for [DbOnboardingPhase].
extension DbOnboardingPhaseX on DbOnboardingPhase {
  /// Human-readable label for this phase.
  String get label => switch (this) {
        DbOnboardingPhase.checkingPermissions => 'Checking System Permissions',
        DbOnboardingPhase.locatingMessages => 'Locating Messages Database',
        DbOnboardingPhase.messagesFound => 'Messages Database Found',
        DbOnboardingPhase.importingMessages => 'Importing Messages',
        DbOnboardingPhase.locatingContacts => 'Locating Contacts',
        DbOnboardingPhase.linkingContacts => 'Linking Contacts',
        DbOnboardingPhase.complete => 'Setup Complete',
        DbOnboardingPhase.error => 'Setup Error',
      };

  /// Whether this phase represents a terminal state.
  bool get isTerminal =>
      this == DbOnboardingPhase.complete || this == DbOnboardingPhase.error;

  /// The ordered index of this phase in the stepper (0-based).
  /// Returns -1 for error state.
  int get stepIndex => switch (this) {
        DbOnboardingPhase.checkingPermissions => 0,
        DbOnboardingPhase.locatingMessages => 1,
        DbOnboardingPhase.messagesFound => 2,
        DbOnboardingPhase.importingMessages => 3,
        DbOnboardingPhase.locatingContacts => 4,
        DbOnboardingPhase.linkingContacts => 5,
        DbOnboardingPhase.complete => 6,
        DbOnboardingPhase.error => -1,
      };
}

/// All phases in stepper display order.
const kDbOnboardingPhaseOrder = [
  DbOnboardingPhase.checkingPermissions,
  DbOnboardingPhase.locatingMessages,
  DbOnboardingPhase.messagesFound,
  DbOnboardingPhase.importingMessages,
  DbOnboardingPhase.locatingContacts,
  DbOnboardingPhase.linkingContacts,
  DbOnboardingPhase.complete,
];
