import 'package:meta/meta.dart';

import 'attachment_archive_location_configuration.dart';
import 'attachment_archive_location_state.dart';

/// Presentation-safe observation of Feature 31's resolved location state.
///
/// This snapshot deliberately excludes bookmark bytes and every form of
/// mutation authority. Creating it performs no resolution or persistence.
@immutable
final class AttachmentArchiveLocationSnapshot {
  const AttachmentArchiveLocationSnapshot({
    required this.availability,
    required this.generation,
    required this.isReadable,
    required this.isPhysicallyWritable,
    this.mode,
    this.customWritePolicy,
    this.canonicalPath,
    this.lastKnownDisplayPath,
    this.volumeName,
    this.issue,
  });

  factory AttachmentArchiveLocationSnapshot.fromLocationState(
    AttachmentArchiveLocationState location,
  ) {
    final configuration = location.configuration;
    return AttachmentArchiveLocationSnapshot(
      availability: location.availability,
      generation: location.generation,
      isReadable: location.isAvailable,
      isPhysicallyWritable: location.isPhysicallyWritable,
      mode: configuration?.mode,
      customWritePolicy: configuration?.customWritePolicy,
      canonicalPath: location.archiveRootPath,
      lastKnownDisplayPath: location.lastKnownDisplayPath,
      volumeName: configuration?.volumeName,
      issue: location.issue,
    );
  }

  final AttachmentArchiveLocationAvailability availability;
  final int generation;
  final bool isReadable;
  final bool isPhysicallyWritable;
  final AttachmentArchiveLocationMode? mode;
  final AttachmentArchiveCustomWritePolicy? customWritePolicy;
  final String? canonicalPath;
  final String? lastKnownDisplayPath;
  final String? volumeName;
  final String? issue;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AttachmentArchiveLocationSnapshot &&
            availability == other.availability &&
            generation == other.generation &&
            isReadable == other.isReadable &&
            isPhysicallyWritable == other.isPhysicallyWritable &&
            mode == other.mode &&
            customWritePolicy == other.customWritePolicy &&
            canonicalPath == other.canonicalPath &&
            lastKnownDisplayPath == other.lastKnownDisplayPath &&
            volumeName == other.volumeName &&
            issue == other.issue;
  }

  @override
  int get hashCode => Object.hash(
    availability,
    generation,
    isReadable,
    isPhysicallyWritable,
    mode,
    customWritePolicy,
    canonicalPath,
    lastKnownDisplayPath,
    volumeName,
    issue,
  );
}
