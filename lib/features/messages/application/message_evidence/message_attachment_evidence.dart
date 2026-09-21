import '../../../../essentials/conversation_graph/application/chat_summaries/chat_summary.dart';
import '../../../attachments/domain/constants/attachment_provenance.dart';
import '../../../attachments/domain/constants/resolved_attachment_availability.dart';
import '../../../attachments/feature_level_providers.dart'
    show
        AttachmentArchiveLocationAvailability,
        AttachmentArchivePayloadStatus,
        AttachmentFileAccess;
import '../../domain/entities/attachment_info.dart' as recovered_domain;

class MessageAttachmentEvidence {
  const MessageAttachmentEvidence({
    required this.attachmentSsId,
    required this.displayName,
    required this.mimeType,
    required this.uti,
    required this.transferName,
    required this.sourcePathHint,
    required this.displayPath,
    required this.availability,
    required this.provenance,
    required this.totalBytes,
    this.archivePayloadStatus,
    this.archiveRootAvailability,
    this.archiveLocationGeneration,
    this.archiveRootIssue,
    this.sourceRecordCount = 1,
  });

  final int attachmentSsId;
  final String displayName;
  final String? mimeType;
  final String? uti;
  final String? transferName;
  final String? sourcePathHint;
  final String? displayPath;
  final ResolvedAttachmentAvailability availability;
  final AttachmentProvenance? provenance;
  final int? totalBytes;
  final AttachmentArchivePayloadStatus? archivePayloadStatus;
  final AttachmentArchiveLocationAvailability? archiveRootAvailability;
  final int? archiveLocationGeneration;
  final String? archiveRootIssue;
  final int sourceRecordCount;

  bool get isDisplayable =>
      availability == ResolvedAttachmentAvailability.available &&
      displayPath != null &&
      displayPath!.isNotEmpty;

  bool get isImage {
    final normalizedMimeType = mimeType?.toLowerCase();
    if (normalizedMimeType != null && normalizedMimeType.isNotEmpty) {
      return normalizedMimeType.startsWith('image/');
    }
    final normalizedUti = uti?.toLowerCase();
    if (normalizedUti != null && normalizedUti.contains('image')) {
      return true;
    }
    return _hasAnyExtension([
      '.jpg',
      '.jpeg',
      '.png',
      '.heic',
      '.gif',
      '.webp',
    ]);
  }

  bool get isVideo {
    final normalizedMimeType = mimeType?.toLowerCase();
    if (normalizedMimeType != null && normalizedMimeType.isNotEmpty) {
      return normalizedMimeType.startsWith('video/');
    }
    final normalizedUti = uti?.toLowerCase();
    if (normalizedUti != null && normalizedUti.contains('video')) {
      return true;
    }
    return _hasAnyExtension(['.mov', '.mp4', '.m4v', '.avi', '.webm']);
  }

  bool get isUrlPreview {
    return _hasAnyExtension(['.pluginpayloadattachment']);
  }

  String get availabilityLabel {
    return switch (availability) {
      ResolvedAttachmentAvailability.available =>
        archivePayloadStatus == AttachmentArchivePayloadStatus.rootUnavailable
            ? 'available from Messages · archive unavailable'
            : provenance == AttachmentProvenance.archived
            ? 'archived'
            : 'available',
      ResolvedAttachmentAvailability.archiveUnavailable =>
        'archive unavailable',
      ResolvedAttachmentAvailability.pendingArchive => 'pending archive',
      ResolvedAttachmentAvailability.pendingHistoricalRemediation =>
        'pending historical archive update',
      ResolvedAttachmentAvailability.unavailableAwaitingRecovery =>
        'unavailable',
      ResolvedAttachmentAvailability.nonRecoverable => 'not recoverable',
    };
  }

  bool _hasAnyExtension(List<String> extensions) {
    final candidates = [
      displayName,
      transferName,
      sourcePathHint,
      displayPath,
    ].whereType<String>().map((value) => value.toLowerCase());
    for (final candidate in candidates) {
      for (final extension in extensions) {
        if (candidate.endsWith(extension)) {
          return true;
        }
      }
    }
    return false;
  }
}

String? firstUrlInMessageText(String? text) {
  final normalized = text?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  final urlPattern = RegExp(
    r'https?://[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );
  return urlPattern.firstMatch(normalized)?.group(0);
}

List<MessageAttachmentEvidence> messageAttachmentEvidenceFromMessageAttachments(
  List<MessageAttachment> attachments,
  AttachmentFileAccess fileAccess,
) {
  final evidence = attachments
      .map(
        (attachment) => messageAttachmentEvidenceFromMessageAttachment(
          attachment,
          fileAccess,
        ),
      )
      .toList(growable: false);
  if (evidence.length < 2) {
    return evidence;
  }

  final collapsed = <MessageAttachmentEvidence>[];
  var urlPreviewResourceCount = 0;
  for (final attachment in evidence) {
    if (attachment.isUrlPreview) {
      urlPreviewResourceCount += 1;
      if (urlPreviewResourceCount == 1) {
        collapsed.add(attachment);
      }
      continue;
    }
    collapsed.add(attachment);
  }

  if (urlPreviewResourceCount < 2) {
    return evidence;
  }

  final firstUrlPreviewIndex = collapsed.indexWhere(
    (attachment) => attachment.isUrlPreview,
  );
  if (firstUrlPreviewIndex < 0) {
    return evidence;
  }

  final firstUrlPreview = collapsed[firstUrlPreviewIndex];
  collapsed[firstUrlPreviewIndex] = MessageAttachmentEvidence(
    attachmentSsId: firstUrlPreview.attachmentSsId,
    displayName: firstUrlPreview.displayName,
    mimeType: firstUrlPreview.mimeType,
    uti: firstUrlPreview.uti,
    transferName: firstUrlPreview.transferName,
    sourcePathHint: firstUrlPreview.sourcePathHint,
    displayPath: firstUrlPreview.displayPath,
    availability: firstUrlPreview.availability,
    provenance: firstUrlPreview.provenance,
    totalBytes: firstUrlPreview.totalBytes,
    archivePayloadStatus: firstUrlPreview.archivePayloadStatus,
    archiveRootAvailability: firstUrlPreview.archiveRootAvailability,
    archiveLocationGeneration: firstUrlPreview.archiveLocationGeneration,
    archiveRootIssue: firstUrlPreview.archiveRootIssue,
    sourceRecordCount: urlPreviewResourceCount,
  );

  return collapsed;
}

MessageAttachmentEvidence messageAttachmentEvidenceFromMessageAttachment(
  MessageAttachment attachment,
  AttachmentFileAccess fileAccess,
) {
  final sourcePathHint = attachment.filename;
  final archivedPath = attachment.archiveAbsolutePath;
  final hasArchivedFile =
      attachment.archivePayloadStatus ==
          AttachmentArchivePayloadStatus.available &&
      archivedPath != null &&
      archivedPath.isNotEmpty;
  final archiveIsUnavailable =
      attachment.archivePayloadStatus ==
      AttachmentArchivePayloadStatus.rootUnavailable;
  final expandedSourcePath = fileAccess.existingExpandedPath(sourcePathHint);
  final displayPath = hasArchivedFile ? archivedPath : expandedSourcePath;
  final hasDisplayFile = displayPath != null && displayPath.isNotEmpty;

  return MessageAttachmentEvidence(
    attachmentSsId: attachment.attachmentSsId,
    displayName: _attachmentDisplayName(attachment),
    mimeType: attachment.mimeType,
    uti: attachment.uti,
    transferName: attachment.transferName,
    sourcePathHint: sourcePathHint,
    displayPath: displayPath,
    availability: hasDisplayFile
        ? ResolvedAttachmentAvailability.available
        : archiveIsUnavailable
        ? ResolvedAttachmentAvailability.archiveUnavailable
        : attachment.hasArchiveRecord || attachment.hasSourcePathHint
        ? ResolvedAttachmentAvailability.unavailableAwaitingRecovery
        : ResolvedAttachmentAvailability.nonRecoverable,
    provenance: hasArchivedFile
        ? AttachmentProvenance.archived
        : expandedSourcePath != null
        ? AttachmentProvenance.messagesLive
        : null,
    totalBytes: attachment.totalBytes,
    archivePayloadStatus: attachment.archivePayloadStatus,
    archiveRootAvailability: attachment.archiveLocationAvailability,
    archiveLocationGeneration: attachment.archiveLocationGeneration,
    archiveRootIssue: attachment.archiveRootIssue,
  );
}

MessageAttachmentEvidence messageAttachmentEvidenceFromRecoveredAttachment(
  recovered_domain.AttachmentInfo attachment,
  AttachmentFileAccess fileAccess,
) {
  final localPath = attachment.localPath;
  final displayPath = fileAccess.existingExpandedPath(localPath);
  final hasDisplayFile = displayPath != null && displayPath.isNotEmpty;

  return MessageAttachmentEvidence(
    attachmentSsId: attachment.id,
    displayName: _recoveredAttachmentDisplayName(attachment),
    mimeType: attachment.mimeType,
    uti: null,
    transferName: attachment.transferName,
    sourcePathHint: localPath,
    displayPath: displayPath,
    availability: hasDisplayFile
        ? ResolvedAttachmentAvailability.available
        : localPath != null && localPath.isNotEmpty
        ? ResolvedAttachmentAvailability.unavailableAwaitingRecovery
        : ResolvedAttachmentAvailability.nonRecoverable,
    provenance: hasDisplayFile ? AttachmentProvenance.archived : null,
    totalBytes: null,
  );
}

String _attachmentDisplayName(MessageAttachment attachment) {
  final transferName = attachment.transferName?.trim();
  if (transferName != null && transferName.isNotEmpty) {
    return transferName;
  }
  final filename = attachment.filename?.trim();
  if (filename != null && filename.isNotEmpty) {
    return filename.split('/').last;
  }
  final guid = attachment.guid?.trim();
  if (guid != null && guid.isNotEmpty) {
    return guid;
  }
  return 'attachment ${attachment.attachmentSsId}';
}

String _recoveredAttachmentDisplayName(
  recovered_domain.AttachmentInfo attachment,
) {
  final transferName = attachment.transferName?.trim();
  if (transferName != null && transferName.isNotEmpty) {
    return transferName;
  }
  final localPath = attachment.localPath?.trim();
  if (localPath != null && localPath.isNotEmpty) {
    return localPath.split('/').last;
  }
  return 'attachment ${attachment.id}';
}
