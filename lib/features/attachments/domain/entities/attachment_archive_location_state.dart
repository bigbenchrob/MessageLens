import 'package:meta/meta.dart';

import 'attachment_archive_location_configuration.dart';

/// Root-level availability for the configured attachment archive.
///
/// Phase One emits only [defaultAvailable] and [configurationInvalid]. The
/// remaining values establish the stable state vocabulary for later native
/// external-location phases; they do not imply that external roots are
/// operational yet.
enum AttachmentArchiveLocationAvailability {
  defaultAvailable,
  customAvailable,
  customReadOnly,
  customUnavailable,
  permissionDenied,
  configuredDirectoryMissing,
  configurationInvalid,
}

/// The resolved attachment archive root and its configuration generation.
@immutable
final class AttachmentArchiveLocationState {
  const AttachmentArchiveLocationState._({
    required this.availability,
    required this.generation,
    this.configuration,
    this.archiveRootPath,
    this.issue,
  });

  factory AttachmentArchiveLocationState.defaultAvailable({
    required String archiveRootPath,
    int generation = initialGeneration,
    AttachmentArchiveLocationConfiguration configuration =
        const AttachmentArchiveLocationConfiguration.defaultInternal(),
  }) {
    return AttachmentArchiveLocationState._(
      availability: AttachmentArchiveLocationAvailability.defaultAvailable,
      generation: generation,
      configuration: configuration,
      archiveRootPath: archiveRootPath,
    );
  }

  factory AttachmentArchiveLocationState.configurationInvalid({
    required String issue,
    int generation = initialGeneration,
    AttachmentArchiveLocationConfiguration? configuration,
  }) {
    return AttachmentArchiveLocationState._(
      availability: AttachmentArchiveLocationAvailability.configurationInvalid,
      generation: generation,
      configuration: configuration,
      issue: issue,
    );
  }

  static const int initialGeneration = 0;

  final AttachmentArchiveLocationAvailability availability;
  final int generation;
  final AttachmentArchiveLocationConfiguration? configuration;
  final String? archiveRootPath;
  final String? issue;

  bool get isAvailable {
    return switch (availability) {
      AttachmentArchiveLocationAvailability.defaultAvailable ||
      AttachmentArchiveLocationAvailability.customAvailable ||
      AttachmentArchiveLocationAvailability.customReadOnly => true,
      _ => false,
    };
  }

  bool get isWritable {
    return switch (availability) {
      AttachmentArchiveLocationAvailability.defaultAvailable ||
      AttachmentArchiveLocationAvailability.customAvailable => true,
      _ => false,
    };
  }

  String requireArchiveRootPath() {
    final rootPath = archiveRootPath;
    if (!isAvailable || rootPath == null) {
      throw StateError(
        'Attachment archive root is unavailable: '
        '${issue ?? availability.name}',
      );
    }
    return rootPath;
  }
}
