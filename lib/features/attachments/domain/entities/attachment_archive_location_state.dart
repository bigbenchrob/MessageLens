import 'package:meta/meta.dart';

import 'attachment_archive_location_configuration.dart';

/// Root-level availability for the configured attachment archive.
enum AttachmentArchiveLocationAvailability {
  defaultAvailable,
  customAvailable,
  customReadOnly,
  customUnavailable,
  permissionDenied,
  configuredDirectoryMissing,
  configurationInvalid,
}

/// Phase Two capability for mutation paths that are still restricted to the
/// admitted default/internal archive.
///
/// The private constructor prevents callers from manufacturing mutation
/// authority from an arbitrary or remembered filesystem path.
@immutable
final class AttachmentArchiveMutationRoot {
  const AttachmentArchiveMutationRoot._({
    required this.archiveRootPath,
    required this.locationGeneration,
  });

  final String archiveRootPath;
  final int locationGeneration;
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
    if (configuration.mode != AttachmentArchiveLocationMode.defaultInternal) {
      throw ArgumentError.value(
        configuration.mode,
        'configuration',
        'Default location state requires defaultInternal configuration.',
      );
    }
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

  factory AttachmentArchiveLocationState.customAvailable({
    required AttachmentArchiveLocationConfiguration configuration,
    required String archiveRootPath,
    int generation = initialGeneration,
  }) {
    _requireCustomConfiguration(configuration);
    return AttachmentArchiveLocationState._(
      availability: AttachmentArchiveLocationAvailability.customAvailable,
      generation: generation,
      configuration: configuration,
      archiveRootPath: archiveRootPath,
    );
  }

  factory AttachmentArchiveLocationState.customReadOnly({
    required AttachmentArchiveLocationConfiguration configuration,
    required String archiveRootPath,
    int generation = initialGeneration,
    String? issue,
  }) {
    _requireCustomConfiguration(configuration);
    return AttachmentArchiveLocationState._(
      availability: AttachmentArchiveLocationAvailability.customReadOnly,
      generation: generation,
      configuration: configuration,
      archiveRootPath: archiveRootPath,
      issue: issue,
    );
  }

  factory AttachmentArchiveLocationState.customUnavailable({
    required AttachmentArchiveLocationConfiguration configuration,
    required String issue,
    int generation = initialGeneration,
  }) {
    return _customUnavailableState(
      availability: AttachmentArchiveLocationAvailability.customUnavailable,
      configuration: configuration,
      issue: issue,
      generation: generation,
    );
  }

  factory AttachmentArchiveLocationState.permissionDenied({
    required AttachmentArchiveLocationConfiguration configuration,
    required String issue,
    int generation = initialGeneration,
  }) {
    return _customUnavailableState(
      availability: AttachmentArchiveLocationAvailability.permissionDenied,
      configuration: configuration,
      issue: issue,
      generation: generation,
    );
  }

  factory AttachmentArchiveLocationState.configuredDirectoryMissing({
    required AttachmentArchiveLocationConfiguration configuration,
    required String issue,
    int generation = initialGeneration,
  }) {
    return _customUnavailableState(
      availability:
          AttachmentArchiveLocationAvailability.configuredDirectoryMissing,
      configuration: configuration,
      issue: issue,
      generation: generation,
    );
  }

  static const int initialGeneration = 0;

  final AttachmentArchiveLocationAvailability availability;
  final int generation;
  final AttachmentArchiveLocationConfiguration? configuration;
  final String? archiveRootPath;
  final String? issue;

  String? get lastKnownDisplayPath => configuration?.lastKnownPath;

  bool get isAvailable {
    return switch (availability) {
      AttachmentArchiveLocationAvailability.defaultAvailable ||
      AttachmentArchiveLocationAvailability.customAvailable ||
      AttachmentArchiveLocationAvailability.customReadOnly => true,
      _ => false,
    };
  }

  /// Physical status reported by bookmark resolution, not mutation authority.
  ///
  /// Callers that mutate must acquire [AttachmentArchiveMutationRoot].
  bool get isPhysicallyWritable {
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

  AttachmentArchiveMutationRoot requireInternalMutationRoot() {
    final rootPath = archiveRootPath;
    if (availability !=
            AttachmentArchiveLocationAvailability.defaultAvailable ||
        configuration?.mode != AttachmentArchiveLocationMode.defaultInternal ||
        rootPath == null) {
      throw StateError(
        'Attachment archive mutation is restricted to the available '
        'default/internal root during Phase Two.',
      );
    }
    return AttachmentArchiveMutationRoot._(
      archiveRootPath: rootPath,
      locationGeneration: generation,
    );
  }

  AttachmentArchiveLocationState withGeneration(int value) {
    return AttachmentArchiveLocationState._(
      availability: availability,
      generation: value,
      configuration: configuration,
      archiveRootPath: archiveRootPath,
      issue: issue,
    );
  }

  bool hasSameEffectiveLocationAs(AttachmentArchiveLocationState other) {
    return availability == other.availability &&
        configuration?.mode == other.configuration?.mode &&
        archiveRootPath == other.archiveRootPath;
  }

  static AttachmentArchiveLocationState _customUnavailableState({
    required AttachmentArchiveLocationAvailability availability,
    required AttachmentArchiveLocationConfiguration configuration,
    required String issue,
    required int generation,
  }) {
    _requireCustomConfiguration(configuration);
    return AttachmentArchiveLocationState._(
      availability: availability,
      generation: generation,
      configuration: configuration,
      issue: issue,
    );
  }

  static void _requireCustomConfiguration(
    AttachmentArchiveLocationConfiguration configuration,
  ) {
    if (configuration.mode != AttachmentArchiveLocationMode.customExternal) {
      throw ArgumentError.value(
        configuration.mode,
        'configuration',
        'Custom location state requires customExternal configuration.',
      );
    }
  }
}
