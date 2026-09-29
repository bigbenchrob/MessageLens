enum OnboardingEnvironmentState {
  permissionBlocked,
  sourceUnavailable,
  sourceSparseOrUnsynced,
  importFailed,
  graphProjectionFailed,
  maintenanceInProgress,
  readyToImport,
  ready,
}

enum OnboardingBlockerKind {
  none,
  fullDiskAccessMissing,
  messagesDatabaseMissing,
  addressBookUnavailable,
  sourceDataSparseOrUnsynced,
  importFailed,
  graphProjectionFailed,
  sourceScopedImportDatabaseMissing,
  conversationGraphMissing,
  sourceScopedImportDatabaseEmpty,
  conversationGraphEmpty,
}

enum OnboardingSyncPlausibility {
  unknown,
  likelySyncedOrLocallyAvailable,
  likelySparseOrUnsynced,
}

enum OnboardingFailureFreshness { unknown, today, older }

enum OnboardingPipelinePhase { import, graphProjection }

enum OnboardingAttachmentArchiveStatus { available, readOnly, unavailable }

class OnboardingPipelineFailure {
  const OnboardingPipelineFailure({
    required this.phase,
    this.batchId,
    this.message,
  });

  final OnboardingPipelinePhase phase;
  final String? message;
  final int? batchId;
}

class OnboardingDatabaseProbe {
  const OnboardingDatabaseProbe({
    required this.path,
    required this.exists,
    required this.readable,
    this.sizeBytes,
    this.lastModified,
    this.rowCount,
    this.failureMessage,
  });

  final String path;
  final bool exists;
  final bool readable;
  final int? sizeBytes;
  final DateTime? lastModified;
  final int? rowCount;
  final String? failureMessage;

  bool get hasData => (rowCount ?? 0) > 0;
}

class OnboardingEnvironmentReport {
  const OnboardingEnvironmentReport({
    required this.state,
    required this.blockerKind,
    required this.syncPlausibility,
    required this.messagesDatabase,
    required this.addressBookDatabase,
    required this.overlayDatabase,
    required this.sourceScopedImportDatabase,
    required this.conversationGraph,
    required this.attachmentArchiveDirectory,
    required this.hasFullDiskAccess,
    this.sourceAttachmentCount,
    this.addressBookFailureMessage,
    this.lastImportFailure,
    this.lastGraphProjectionFailure,
    this.lastImportFailureRecordedAt,
    this.lastGraphProjectionFailureRecordedAt,
    this.usingPersistedImportFailure = false,
    this.usingPersistedGraphProjectionFailure = false,
    this.shouldResetAppDatabasesBeforeImport = false,
    this.resetAppDatabasesReason,
    this.graphBuildStatusLabel = 'unknown',
    this.graphBuildFinishedAt,
    this.graphBuildLastError,
    this.liveUpdateCursorRowId,
    this.liveUpdateLastChangeDetectedAt,
    this.liveUpdateLastError,
    this.attachmentArchiveStatus = OnboardingAttachmentArchiveStatus.available,
    this.attachmentArchiveIssue,
    this.attachmentArchiveLocationGeneration = 0,
  });

  final OnboardingEnvironmentState state;
  final OnboardingBlockerKind blockerKind;
  final OnboardingSyncPlausibility syncPlausibility;
  final OnboardingDatabaseProbe messagesDatabase;
  final OnboardingDatabaseProbe? addressBookDatabase;
  final OnboardingDatabaseProbe overlayDatabase;
  final OnboardingDatabaseProbe sourceScopedImportDatabase;
  final OnboardingDatabaseProbe conversationGraph;
  final OnboardingDatabaseProbe attachmentArchiveDirectory;
  final bool hasFullDiskAccess;
  final int? sourceAttachmentCount;
  final String? addressBookFailureMessage;
  final OnboardingPipelineFailure? lastImportFailure;
  final OnboardingPipelineFailure? lastGraphProjectionFailure;
  final DateTime? lastImportFailureRecordedAt;
  final DateTime? lastGraphProjectionFailureRecordedAt;
  final bool usingPersistedImportFailure;
  final bool usingPersistedGraphProjectionFailure;
  final bool shouldResetAppDatabasesBeforeImport;
  final String? resetAppDatabasesReason;
  final String graphBuildStatusLabel;
  final DateTime? graphBuildFinishedAt;
  final String? graphBuildLastError;
  final int? liveUpdateCursorRowId;
  final DateTime? liveUpdateLastChangeDetectedAt;
  final String? liveUpdateLastError;
  final OnboardingAttachmentArchiveStatus attachmentArchiveStatus;
  final String? attachmentArchiveIssue;
  final int attachmentArchiveLocationGeneration;

  bool get hasPopulatedAppDatabases {
    return sourceScopedImportDatabase.hasData && conversationGraph.hasData;
  }

  bool get hasImportFailure {
    return lastImportFailure != null;
  }

  bool get hasGraphProjectionFailure {
    return lastGraphProjectionFailure != null;
  }

  String? get importFailureMessage {
    if (!hasImportFailure) {
      return null;
    }

    return lastImportFailure!.message;
  }

  String? get graphProjectionFailureMessage {
    if (!hasGraphProjectionFailure) {
      return null;
    }

    return lastGraphProjectionFailure!.message;
  }

  DateTime? get latestFailureRecordedAt {
    return lastGraphProjectionFailureRecordedAt ?? lastImportFailureRecordedAt;
  }

  OnboardingFailureFreshness importFailureFreshness({DateTime? now}) {
    return _failureFreshness(lastImportFailureRecordedAt, now: now);
  }

  OnboardingFailureFreshness graphProjectionFailureFreshness({DateTime? now}) {
    return _failureFreshness(lastGraphProjectionFailureRecordedAt, now: now);
  }

  OnboardingFailureFreshness _failureFreshness(
    DateTime? timestamp, {
    DateTime? now,
  }) {
    if (timestamp == null) {
      return OnboardingFailureFreshness.unknown;
    }

    final localTimestamp = timestamp.toLocal();
    final localNow = (now ?? DateTime.now()).toLocal();
    final sameDay =
        localTimestamp.year == localNow.year &&
        localTimestamp.month == localNow.month &&
        localTimestamp.day == localNow.day;

    if (sameDay) {
      return OnboardingFailureFreshness.today;
    }

    return OnboardingFailureFreshness.older;
  }
}
