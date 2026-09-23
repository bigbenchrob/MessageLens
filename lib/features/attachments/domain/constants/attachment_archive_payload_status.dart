/// Physical read state for an attachment that has archive metadata.
///
/// Root availability is classified before any payload path is inspected, so
/// [rootUnavailable] never implies that an individual payload is missing.
enum AttachmentArchivePayloadStatus {
  rootUnavailable,
  available,
  missing,
  unexpectedFileType,
  invalidMetadataPath,
  verifiedCorrupt,
}
