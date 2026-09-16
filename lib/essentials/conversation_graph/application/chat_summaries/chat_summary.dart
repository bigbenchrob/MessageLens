import '../../../../features/attachments/feature_level_providers.dart'
    show AttachmentArchiveLocationAvailability, AttachmentArchivePayloadStatus;

enum ChatSummaryFilter { all, groupOnly, singleParticipantOnly }

enum ChatSummarySort {
  mostRecentMessage,
  largestMessageCount,
  largestParticipantCount,
}

class ChatSummary {
  const ChatSummary({
    required this.chatSsId,
    required this.participantHandles,
    required this.participantCount,
    required this.isGroup,
    required this.messageCount,
    required this.lastMessageAtUtc,
    required this.lastMessageText,
  });

  final int chatSsId;
  final List<String> participantHandles;
  final int participantCount;
  final bool isGroup;
  final int messageCount;
  final String? lastMessageAtUtc;
  final String? lastMessageText;
}

class RecentChatMessage {
  const RecentChatMessage({
    required this.messageSsId,
    required this.dateUtc,
    required this.isFromMe,
    required this.text,
    required this.attachmentCount,
  });

  final int messageSsId;
  final String? dateUtc;
  final bool isFromMe;
  final String? text;
  final int attachmentCount;
}

class MessageAttachment {
  const MessageAttachment({
    required this.attachmentSsId,
    required this.guid,
    required this.filename,
    required this.transferName,
    required this.uti,
    required this.mimeType,
    required this.totalBytes,
    required this.createdAtUtc,
    required this.localFileExists,
    required this.archiveRelativePath,
    required this.archiveAbsolutePath,
    AttachmentArchivePayloadStatus? archivePayloadStatus,
    bool? archiveFileExists,
    this.archiveLocationAvailability,
    this.archiveLocationGeneration,
    this.archiveRootIssue,
  }) : archivePayloadStatus =
           archivePayloadStatus ??
           (archiveRelativePath == null
               ? null
               : archiveFileExists == true
               ? AttachmentArchivePayloadStatus.available
               : AttachmentArchivePayloadStatus.missing);

  final int attachmentSsId;
  final String? guid;
  final String? filename;
  final String? transferName;
  final String? uti;
  final String? mimeType;
  final int? totalBytes;
  final String? createdAtUtc;
  final bool localFileExists;
  final String? archiveRelativePath;
  final String? archiveAbsolutePath;
  final AttachmentArchivePayloadStatus? archivePayloadStatus;
  final AttachmentArchiveLocationAvailability? archiveLocationAvailability;
  final int? archiveLocationGeneration;
  final String? archiveRootIssue;

  bool get archiveFileExists =>
      archivePayloadStatus == AttachmentArchivePayloadStatus.available;

  bool get hasSourcePathHint => filename != null && filename!.isNotEmpty;
  bool get hasArchiveRecord =>
      archiveRelativePath != null && archiveRelativePath!.isNotEmpty;
}

class ChatAttachmentStats {
  const ChatAttachmentStats({
    required this.messageWithAttachmentCount,
    required this.attachmentCount,
    required this.imageAttachmentCount,
    required this.videoAttachmentCount,
    required this.documentAttachmentCount,
    required this.sourcePathHintCount,
    required this.localFileAvailableCount,
    required this.localFileMissingCount,
    required this.archiveRecordCount,
    required this.archiveFileAvailableCount,
    required this.archiveFileMissingCount,
    this.archiveFileUnavailableCount = 0,
    this.archiveUnexpectedTypeCount = 0,
  });

  final int messageWithAttachmentCount;
  final int attachmentCount;
  final int imageAttachmentCount;
  final int videoAttachmentCount;
  final int documentAttachmentCount;
  final int sourcePathHintCount;
  final int localFileAvailableCount;
  final int localFileMissingCount;
  final int archiveRecordCount;
  final int archiveFileAvailableCount;
  final int archiveFileMissingCount;
  final int archiveFileUnavailableCount;
  final int archiveUnexpectedTypeCount;
}

class ChatMessageTextStats {
  const ChatMessageTextStats({
    required this.totalMessageCount,
    required this.textMessageCount,
    required this.noTextMessageCount,
  });

  final int totalMessageCount;
  final int textMessageCount;
  final int noTextMessageCount;
}

class ChatSummarySanityCounts {
  const ChatSummarySanityCounts({
    required this.groupChatCount,
    required this.singleParticipantChatCount,
    required this.orphanChatCount,
    required this.zeroHandleChatCount,
    required this.zeroMessageChatCount,
    required this.largestParticipantCount,
    required this.largestMessageCount,
  });

  final int groupChatCount;
  final int singleParticipantChatCount;
  final int orphanChatCount;
  final int zeroHandleChatCount;
  final int zeroMessageChatCount;
  final int largestParticipantCount;
  final int largestMessageCount;
}
