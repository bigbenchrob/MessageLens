import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test('legacy mover production files are physically absent', () {
    for (final relativePath in _retiredProductionPaths) {
      expect(
        File(relativePath).existsSync(),
        isFalse,
        reason: '$relativePath must not return',
      );
    }
  });

  test('production runtime contains no mover execution or journal discovery', () {
    final offenders = <String>[];
    for (final file in _productionSources()) {
      final source = file.readAsStringSync();
      for (final token in _retiredRuntimeTokens) {
        if (source.contains(token)) {
          offenders.add(
            '${path.relative(file.path, from: Directory.current.path)}: $token',
          );
        }
      }
    }

    expect(offenders, isEmpty);
  });

  test('only simplified adoption actions remain in Settings', () {
    final settingsSources = _settingsRoutePaths
        .map((relativePath) => File(relativePath).readAsStringSync())
        .join('\n');

    for (final token in _retiredSettingsTokens) {
      expect(settingsSources, isNot(contains(token)), reason: token);
    }
    for (final token in _adoptionSettingsTokens) {
      expect(settingsSources, contains(token), reason: token);
    }
  });
}

Iterable<File> _productionSources() sync* {
  for (final rootPath in <String>['lib', 'macos/Runner']) {
    final root = Directory(rootPath);
    for (final entity in root.listSync(recursive: true, followLinks: false)) {
      if (entity is File &&
          (entity.path.endsWith('.dart') || entity.path.endsWith('.swift'))) {
        yield entity;
      }
    }
  }
  yield File('macos/Runner.xcodeproj/project.pbxproj');
}

const _retiredProductionPaths = <String>[
  'lib/features/attachments/application/attachment_archive_relocation_activation_gate.dart',
  'lib/features/attachments/application/attachment_archive_relocation_enablement_provider.dart',
  'lib/features/attachments/application/attachment_archive_relocation_file_system.dart',
  'lib/features/attachments/application/attachment_archive_relocation_journal_store.dart',
  'lib/features/attachments/application/attachment_archive_relocation_metadata_reader.dart',
  'lib/features/attachments/application/attachment_archive_relocation_progress_monitor.dart',
  'lib/features/attachments/application/attachment_archive_relocation_provider.dart',
  'lib/features/attachments/application/attachment_archive_relocation_service.dart',
  'lib/features/attachments/domain/entities/attachment_archive_relocation.dart',
  'lib/features/attachments/infrastructure/repositories/darwin_exclusive_directory_finalizer.dart',
  'lib/features/attachments/infrastructure/repositories/filesystem_attachment_archive_relocation_file_system.dart',
  'lib/features/attachments/infrastructure/repositories/filesystem_attachment_archive_relocation_journal_store.dart',
  'lib/features/attachments/infrastructure/repositories/overlay_attachment_archive_relocation_metadata_reader.dart',
  'lib/features/settings/application/attachment_archive_relocation_actions_provider.dart',
  'macos/Runner/PrivacyInfo.xcprivacy',
];

const _retiredRuntimeTokens = <String>[
  'AttachmentArchiveRelocation',
  'attachmentArchiveRelocation',
  'attachmentRelocation',
  'attachment_archive_relocation',
  '.attachment_archive_relocations',
  'manifest.ndjson',
  'copy_receipts.ndjson',
  'availableCapacityForImportantUsage',
  'volumeAvailableCapacityForImportantUsage',
  'DarwinExclusiveDirectoryFinalizer',
  'AttachmentArchiveDestinationCapacityReader',
  'E174.1',
  'PrivacyInfo.xcprivacy',
];

const _settingsRoutePaths = <String>[
  'lib/essentials/sidebar/domain/sidebar_action_intent.dart',
  'lib/essentials/sidebar/application/sidebar_action_dispatcher.dart',
  'lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart',
  'lib/features/settings/application/sidebar_cassette_spec/coordinators/settings_coordinator.dart',
  'lib/features/settings/application/sidebar_cassette_spec/resolvers/attachment_archive_settings_resolver.dart',
  'lib/features/settings/feature_level_providers.dart',
  'lib/features/attachments/feature_level_providers.dart',
];

const _retiredSettingsTokens = <String>[
  'AttachmentArchiveMoveRequested',
  'AttachmentArchiveChooseAnotherLocationRequested',
  'AttachmentArchiveRetryPreflightRequested',
  'AttachmentArchiveBeginRelocationRequested',
  'AttachmentArchivePauseRelocationRequested',
  'AttachmentArchiveResumeRelocationRequested',
  'AttachmentArchiveCancelRelocationRequested',
  'Begin Relocation',
  'Retry Preflight',
  'Preparing Archive Move',
  'Review Archive Move',
];

const _adoptionSettingsTokens = <String>[
  'AttachmentArchiveUseExistingRequested',
  'AttachmentArchiveChooseAnotherFolderRequested',
  'AttachmentArchiveCheckAgainRequested',
  'AttachmentArchiveUseCandidateRequested',
  'AttachmentArchiveCancelCheckRequested',
];
