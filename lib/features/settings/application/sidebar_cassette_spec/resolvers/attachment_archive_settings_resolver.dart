import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../attachments/feature_level_providers.dart'
    show AttachmentArchiveLocationAvailability, AttachmentArchiveLocationState;
import '../payloads/attachment_archive_settings_cassette_payload.dart';

part 'attachment_archive_settings_resolver.g.dart';

@riverpod
class AttachmentArchiveSettingsResolver
    extends _$AttachmentArchiveSettingsResolver {
  @override
  void build() {}

  AttachmentArchiveSettingsCassettePayload resolve({
    required int cassetteIndex,
    required AttachmentArchiveLocationState location,
  }) {
    final displayPath =
        location.archiveRootPath ?? location.lastKnownDisplayPath;
    final isInternal =
        location.availability ==
        AttachmentArchiveLocationAvailability.defaultAvailable;
    final status = switch (location.availability) {
      AttachmentArchiveLocationAvailability.defaultAvailable =>
        'The built-in attachment archive is available.',
      AttachmentArchiveLocationAvailability.customAvailable =>
        'The external attachment archive is connected and available for reads.',
      AttachmentArchiveLocationAvailability.customReadOnly =>
        'The external attachment archive is connected in read-only mode.',
      AttachmentArchiveLocationAvailability.customUnavailable =>
        'The external attachment archive is unavailable. Message browsing and '
            'search remain available; reconnect the configured volume to read '
            'archived payloads.',
      AttachmentArchiveLocationAvailability.permissionDenied =>
        'Permission to read the external attachment archive was denied. '
            'Messages and search remain available.',
      AttachmentArchiveLocationAvailability.configuredDirectoryMissing =>
        'The configured attachment archive directory is missing. Messages and '
            'search remain available.',
      AttachmentArchiveLocationAvailability.configurationInvalid =>
        'The external attachment archive configuration is invalid. Messages '
            'and search remain available.',
    };
    final issue = location.issue;
    return AttachmentArchiveSettingsCassettePayload(
      cassetteIndex: cassetteIndex,
      bodyText: [
        status,
        if (location.configuration?.volumeName case final volumeName?)
          'Volume: $volumeName',
        if (displayPath != null && displayPath.isNotEmpty)
          'Location: $displayPath',
        if (issue != null && issue.isNotEmpty) 'Status detail: $issue',
      ].join('\n\n'),
      statusLines: [
        AttachmentArchiveSettingsStatusLine(
          label: 'Location',
          value: isInternal ? 'Internal' : 'External',
        ),
        AttachmentArchiveSettingsStatusLine(
          label: 'Availability',
          value: _availabilityLabel(location.availability),
        ),
      ],
      footnote: isInternal
          ? null
          : 'The external archive remains authoritative when available. '
                'MessageLens does not silently fall back to an internal copy.',
    );
  }

  String _availabilityLabel(
    AttachmentArchiveLocationAvailability availability,
  ) {
    return switch (availability) {
      AttachmentArchiveLocationAvailability.defaultAvailable ||
      AttachmentArchiveLocationAvailability.customAvailable => 'Available',
      AttachmentArchiveLocationAvailability.customReadOnly =>
        'Available (read-only)',
      AttachmentArchiveLocationAvailability.customUnavailable => 'Unavailable',
      AttachmentArchiveLocationAvailability.permissionDenied =>
        'Permission denied',
      AttachmentArchiveLocationAvailability.configuredDirectoryMissing =>
        'Configured directory missing',
      AttachmentArchiveLocationAvailability.configurationInvalid =>
        'Configuration invalid',
    };
  }
}
