import 'package:meta/meta.dart';

enum AttachmentShowcaseMediaKind { image, video, pdf, other }

/// Transient local presentation data for one already-authorized attachment.
///
/// This object carries no mutation permit, archive lease, transaction state,
/// persistence capability, or cancellation authority.
@immutable
final class AttachmentShowcaseItem {
  const AttachmentShowcaseItem({
    required this.resolvedPath,
    required this.mediaKind,
    required this.stablePresentationIdentity,
    this.historicalDate,
    this.displayFilename,
    this.displayType,
  });

  final String resolvedPath;
  final AttachmentShowcaseMediaKind mediaKind;
  final String stablePresentationIdentity;
  final DateTime? historicalDate;
  final String? displayFilename;
  final String? displayType;
}

typedef AttachmentShowcaseEventCallback =
    void Function(AttachmentShowcaseItem item);
