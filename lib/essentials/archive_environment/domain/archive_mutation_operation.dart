/// Protected classes of mutation that can change an admitted archive.
enum ArchiveMutationOperation {
  liveGraphUpdate,
  graphBuild,
  onboardingImport,
  automaticRecovery,
  startFresh,
  messageDataReset,
  historicalArchiveDryRun,
  historicalArchiveImport,
  historicalArchiveRemoval,
  attachmentReconciliation,
  attachmentArchiveAdoption,
  attachmentClearing,
  destructiveMaintenance,
  localAccountIdentityReconciliation,
}

/// Protected resource actions whose admission depends on the active mutation
/// owner and the requesting async branch's current operation scope.
enum ArchiveMutationResourceAction {
  openConversationGraphConnection,
  openPersistentArchiveStore,
}

enum ArchiveMutationResourceAdmission {
  unrestricted,
  admittedOwner,
  deniedByActiveMutation;

  bool get isAllowed {
    return this != ArchiveMutationResourceAdmission.deniedByActiveMutation;
  }
}

extension ArchiveMutationOperationPolicy on ArchiveMutationOperation {
  /// Whether reads must avoid reopening archive databases during the operation.
  bool get blocksDatabaseReopen {
    return switch (this) {
      ArchiveMutationOperation.messageDataReset ||
      ArchiveMutationOperation.startFresh ||
      ArchiveMutationOperation.historicalArchiveImport ||
      ArchiveMutationOperation.historicalArchiveRemoval ||
      ArchiveMutationOperation.destructiveMaintenance => true,
      _ => false,
    };
  }

  bool get requiresVerifiedCheckpoint {
    return switch (this) {
      ArchiveMutationOperation.messageDataReset ||
      ArchiveMutationOperation.historicalArchiveImport ||
      ArchiveMutationOperation.historicalArchiveRemoval ||
      ArchiveMutationOperation.attachmentClearing ||
      ArchiveMutationOperation.destructiveMaintenance => true,
      _ => false,
    };
  }

  bool permitsOwnerResourceAction(ArchiveMutationResourceAction action) {
    return switch (action) {
      ArchiveMutationResourceAction.openConversationGraphConnection =>
        this == ArchiveMutationOperation.historicalArchiveImport ||
            this == ArchiveMutationOperation.historicalArchiveRemoval,
      ArchiveMutationResourceAction.openPersistentArchiveStore => false,
    };
  }
}
