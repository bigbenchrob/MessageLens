enum GraphArchivePhysicalAuditStatus {
  notRequested,
  completed,
  deferredRootUnavailable,
}

class GraphHealthReport {
  const GraphHealthReport({
    required this.messageCount,
    required this.chatCount,
    required this.handleCount,
    required this.canonicalHandleCount,
    required this.handleAliasCount,
    required this.contactCount,
    required this.attachmentCount,
    required this.archiveFileAuditIncluded,
    required this.archivePhysicalAuditStatus,
    required this.archivePhysicalAuditIssue,
    required this.archiveRecordCount,
    required this.attachmentsWithArchiveRecordCount,
    required this.attachmentsMissingArchiveRecordCount,
    required this.archiveFilesAvailableCount,
    required this.archiveFilesMissingCount,
    required this.archiveRecordsWithoutGraphAttachmentCount,
    required this.attachmentRecoveryAuditIncluded,
    required this.historicalArchiveAvailable,
    required this.historicalArchiveRecordCount,
    required this.historicalArchiveFilesAvailableCount,
    required this.historicalArchiveFilesMissingCount,
    required this.attachmentsRecoverableFromHistoricalArchiveCount,
    required this.recoveredMessagesSourceAvailable,
    required this.recoveredMessagesAttachmentKeyCount,
    required this.attachmentsRecoverableFromRecoveredMessagesCount,
    required this.attachmentsRecoverableFromBothRecoverySourcesCount,
    required this.attachmentsStillMissingFromKnownRecoverySourcesCount,
    required this.dryRunAlreadyAvailableInCurrentArchiveCount,
    required this.dryRunWouldCopyFromHistoricalArchiveCount,
    required this.dryRunWouldCopyFromRecoveredMessagesCount,
    required this.dryRunWouldArchiveFromCurrentSourcePathCount,
    required this.dryRunStillMissingEverywhereCount,
    required this.dryRunStillMissingPluginPayloadCandidateCount,
    required this.missingAttachmentSamples,
    required this.chatToMessageEdgeCount,
    required this.chatToHandleEdgeCount,
    required this.messageToAttachmentEdgeCount,
    required this.contactToHandleEdgeCount,
    required this.orphanMessageCount,
    required this.chatsWithZeroMessagesCount,
    required this.chatsWithZeroHandlesCount,
    required this.attachmentsWithoutMessageEdgeCount,
    required this.messagesMissingSenderCanonicalHandleCount,
    required this.handlesWithoutCanonicalAliasCount,
    required this.contactsWithoutHandlesCount,
    required this.chatToMessageEdgesMissingChatCount,
    required this.chatToMessageEdgesMissingMessageCount,
    required this.chatToHandleEdgesMissingChatCount,
    required this.chatToHandleEdgesMissingHandleCount,
    required this.messageToAttachmentEdgesMissingMessageCount,
    required this.messageToAttachmentEdgesMissingAttachmentCount,
    required this.contactToHandleEdgesMissingContactCount,
    required this.contactToHandleEdgesMissingHandleCount,
  });

  final int messageCount;
  final int chatCount;
  final int handleCount;
  final int canonicalHandleCount;
  final int handleAliasCount;
  final int contactCount;
  final int attachmentCount;
  final bool archiveFileAuditIncluded;
  final GraphArchivePhysicalAuditStatus archivePhysicalAuditStatus;
  final String? archivePhysicalAuditIssue;
  final int archiveRecordCount;
  final int attachmentsWithArchiveRecordCount;
  final int attachmentsMissingArchiveRecordCount;
  final int archiveFilesAvailableCount;
  final int archiveFilesMissingCount;
  final int archiveRecordsWithoutGraphAttachmentCount;
  final bool attachmentRecoveryAuditIncluded;
  final bool historicalArchiveAvailable;
  final int historicalArchiveRecordCount;
  final int historicalArchiveFilesAvailableCount;
  final int historicalArchiveFilesMissingCount;
  final int attachmentsRecoverableFromHistoricalArchiveCount;
  final bool recoveredMessagesSourceAvailable;
  final int recoveredMessagesAttachmentKeyCount;
  final int attachmentsRecoverableFromRecoveredMessagesCount;
  final int attachmentsRecoverableFromBothRecoverySourcesCount;
  final int attachmentsStillMissingFromKnownRecoverySourcesCount;
  final int dryRunAlreadyAvailableInCurrentArchiveCount;
  final int dryRunWouldCopyFromHistoricalArchiveCount;
  final int dryRunWouldCopyFromRecoveredMessagesCount;
  final int dryRunWouldArchiveFromCurrentSourcePathCount;
  final int dryRunStillMissingEverywhereCount;
  final int dryRunStillMissingPluginPayloadCandidateCount;
  final List<MissingAttachmentRecoverySample> missingAttachmentSamples;
  final int chatToMessageEdgeCount;
  final int chatToHandleEdgeCount;
  final int messageToAttachmentEdgeCount;
  final int contactToHandleEdgeCount;

  final int orphanMessageCount;
  final int chatsWithZeroMessagesCount;
  final int chatsWithZeroHandlesCount;
  final int attachmentsWithoutMessageEdgeCount;
  final int messagesMissingSenderCanonicalHandleCount;
  final int handlesWithoutCanonicalAliasCount;
  final int contactsWithoutHandlesCount;

  final int chatToMessageEdgesMissingChatCount;
  final int chatToMessageEdgesMissingMessageCount;
  final int chatToHandleEdgesMissingChatCount;
  final int chatToHandleEdgesMissingHandleCount;
  final int messageToAttachmentEdgesMissingMessageCount;
  final int messageToAttachmentEdgesMissingAttachmentCount;
  final int contactToHandleEdgesMissingContactCount;
  final int contactToHandleEdgesMissingHandleCount;

  int get sourceRowsWithoutTopologyCount =>
      orphanMessageCount +
      chatsWithZeroMessagesCount +
      attachmentsWithoutMessageEdgeCount;

  int get semanticCoverageIssueCount =>
      chatsWithZeroHandlesCount +
      messagesMissingSenderCanonicalHandleCount +
      handlesWithoutCanonicalAliasCount +
      contactsWithoutHandlesCount;

  int get missingEndpointIssueCount =>
      chatToMessageEdgesMissingChatCount +
      chatToMessageEdgesMissingMessageCount +
      chatToHandleEdgesMissingChatCount +
      chatToHandleEdgesMissingHandleCount +
      messageToAttachmentEdgesMissingMessageCount +
      messageToAttachmentEdgesMissingAttachmentCount +
      contactToHandleEdgesMissingContactCount +
      contactToHandleEdgesMissingHandleCount;
}

class MissingAttachmentRecoverySample {
  const MissingAttachmentRecoverySample({
    required this.attachmentSsId,
    required this.archiveMessageGuid,
    required this.archiveCompatibilitySourceRowId,
    required this.filename,
    required this.mimeType,
    required this.uti,
    required this.currentSourcePathExists,
    required this.historicalArchiveKeyExists,
    required this.recoveredMessagesKeyExists,
    required this.attemptedRecoveredPath,
  });

  final int attachmentSsId;
  final String archiveMessageGuid;
  final int archiveCompatibilitySourceRowId;
  final String? filename;
  final String? mimeType;
  final String? uti;
  final bool currentSourcePathExists;
  final bool historicalArchiveKeyExists;
  final bool recoveredMessagesKeyExists;
  final String? attemptedRecoveredPath;
}
