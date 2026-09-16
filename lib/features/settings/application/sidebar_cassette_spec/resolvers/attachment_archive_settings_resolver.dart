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
      bodyText: [
        status,
        if (location.configuration?.volumeName case final volumeName?)
          'Volume: $volumeName',
        if (displayPath != null && displayPath.isNotEmpty)
          'Location: $displayPath',
        if (issue != null && issue.isNotEmpty) 'Status detail: $issue',
      ].join('\n\n'),
      footnote:
          'External locations are read-only to MessageLens in this phase.',
    );
  }
}
