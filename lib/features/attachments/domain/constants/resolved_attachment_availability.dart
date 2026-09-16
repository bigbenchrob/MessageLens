/// Runtime display availability returned by the attachment resolver.
enum ResolvedAttachmentAvailability {
  /// Archive-enabled mode found a live file and has started archive ingestion,
  /// but the attachment is not yet displayable from the archive.
  pendingArchive,

  /// A displayable file is available according to the current source policy.
  available,

  /// Archive metadata exists (or the active archive policy applies), but the
  /// configured archive root is unavailable, so payload state is unknown.
  archiveUnavailable,

  /// The attachment cannot be displayed yet, but background recovery may still
  /// make it available later.
  unavailableAwaitingRecovery,

  /// The resolver has high-confidence evidence that recovery is implausible.
  nonRecoverable,
}
