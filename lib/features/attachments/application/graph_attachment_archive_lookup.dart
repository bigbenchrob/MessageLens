import '../domain/constants/attachment_archive_payload_status.dart';
import '../domain/entities/attachment_archive_location_state.dart';

class GraphAttachmentArchiveRecord {
  const GraphAttachmentArchiveRecord({
    required this.archiveRelativePath,
    required this.archiveAbsolutePath,
    required this.payloadStatus,
    required this.locationAvailability,
    required this.locationGeneration,
    required this.rootIssue,
  });

  final String archiveRelativePath;
  final String? archiveAbsolutePath;
  final AttachmentArchivePayloadStatus payloadStatus;
  final AttachmentArchiveLocationAvailability locationAvailability;
  final int locationGeneration;
  final String? rootIssue;

  bool get archiveFileExists =>
      payloadStatus == AttachmentArchivePayloadStatus.available;
}

abstract interface class GraphAttachmentArchiveLookup {
  Future<GraphAttachmentArchiveRecord?> readArchiveRecord({
    required int messageSsId,
    required int attachmentSsId,
  });
}
