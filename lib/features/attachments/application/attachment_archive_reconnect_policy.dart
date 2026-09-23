import '../domain/entities/attachment_archive_location_configuration.dart';
import '../domain/entities/attachment_archive_location_state.dart';

/// Returns true only for a non-writable → writable custom-archive edge.
///
/// The caller schedules one existing bounded sweep. Repeated mount/application
/// events that resolve to the same writable state therefore do not duplicate
/// work, and this policy never requests a full scan.
bool shouldScheduleBoundedAttachmentArchiveReconnectSweep({
  required AttachmentArchiveLocationState? previous,
  required AttachmentArchiveLocationState current,
}) {
  return previous != null &&
      !previous.isWritableMutationEligible &&
      current.isWritableMutationEligible &&
      current.configuration?.mode ==
          AttachmentArchiveLocationMode.customExternal;
}
