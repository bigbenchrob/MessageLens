import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../messages/domain/entities/attachment_info.dart';
import '../constants/attachment_archive_payload_status.dart';
import '../constants/attachment_provenance.dart';
import '../constants/resolved_attachment_availability.dart';
import 'attachment_archive_location_state.dart';
import 'attachment_recovery_metadata.dart';

part 'resolved_attachment.freezed.dart';

/// The result of resolving an attachment through the multi-source pipeline.
///
/// Combines the attachment metadata with its runtime availability state,
/// the provenance of the resolved file (if any), and the displayable file path
/// selected by the resolver.
@freezed
abstract class ResolvedAttachment with _$ResolvedAttachment {
  const factory ResolvedAttachment({
    required AttachmentInfo attachmentInfo,
    required ResolvedAttachmentAvailability availability,
    AttachmentProvenance? provenance,
    String? resolvedFilePath,
    AttachmentRecoveryMetadata? recoveryMetadata,
    AttachmentArchivePayloadStatus? archivePayloadStatus,
    AttachmentArchiveLocationAvailability? archiveRootAvailability,
    int? archiveLocationGeneration,
    String? archiveRootIssue,
  }) = _ResolvedAttachment;

  const ResolvedAttachment._();

  bool get isDisplayable {
    return availability == ResolvedAttachmentAvailability.available &&
        resolvedFilePath != null;
  }
}
