import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('candidate verifier implementation is read-only', () {
    final source = _read(_verifierPath);
    for (final token in _filesystemMutationTokens) {
      expect(
        source,
        isNot(contains(token)),
        reason: 'Candidate verifier contains filesystem mutation token $token',
      );
    }
    expect(source, isNot(contains('customStatement')));
    expect(source, isNot(contains('persistConfiguration')));
    expect(source, isNot(contains('activeArchive')));
  });

  test('candidate verifier has no legacy mover runtime dependency', () {
    final sources = <String>[
      _read(_verifierContractPath),
      _read(_verificationMetadataPath),
      _read(_verifierPath),
      _read(_verificationMetadataRepositoryPath),
    ].join('\n');

    for (final token in _legacyRuntimeTokens) {
      expect(
        sources,
        isNot(contains(token)),
        reason: 'Adoption verification depends on legacy runtime token $token',
      );
    }
  });

  test('Checkpoint Two has no Settings or public adoption route', () {
    final settingsAndSidebar = _settingsRoutePaths.map(_read).join('\n');
    final attachmentSeam = _read(
      'lib/features/attachments/feature_level_providers.dart',
    );

    expect(
      settingsAndSidebar,
      isNot(contains('AttachmentArchiveCandidateVerifier')),
    );
    expect(
      settingsAndSidebar,
      isNot(contains('attachmentArchiveCandidateVerifierProvider')),
    );
    expect(
      attachmentSeam,
      isNot(contains('attachment_archive_candidate_verifier')),
    );
  });

  test('verification cannot discover parked relocation artifacts', () {
    final sources = <String>[
      _read(_verifierContractPath),
      _read(_verificationMetadataPath),
      _read(_verifierPath),
      _read(_verificationMetadataRepositoryPath),
    ].join('\n');

    expect(sources, isNot(contains('5c20c87a-c6d6-4489-8887-ae629301884f')));
    expect(sources, isNot(contains('.attachment_archive_relocations')));
    expect(sources, isNot(contains('manifest.ndjson')));
    expect(sources, isNot(contains('current.json')));
  });

  test('grouped verification metadata repository issues SELECT only', () {
    final source = _read(_verificationMetadataRepositoryPath);
    expect(source, contains('SELECT archive_relative_path'));
    expect(source, contains('GROUP BY archive_relative_path'));
    expect(source, contains('ORDER BY archive_relative_path'));
    expect(source.toUpperCase(), isNot(contains('INSERT INTO')));
    expect(source.toUpperCase(), isNot(contains('UPDATE ')));
    expect(source.toUpperCase(), isNot(contains('DELETE FROM')));
  });
}

String _read(String path) => File(path).readAsStringSync();

const _verifierContractPath =
    'lib/features/attachments/application/'
    'attachment_archive_candidate_verifier.dart';
const _verificationMetadataPath =
    'lib/features/attachments/application/'
    'attachment_archive_verification_metadata_reader.dart';
const _verifierPath =
    'lib/features/attachments/infrastructure/repositories/'
    'filesystem_attachment_archive_candidate_verifier.dart';
const _verificationMetadataRepositoryPath =
    'lib/features/attachments/infrastructure/repositories/'
    'overlay_attachment_archive_verification_metadata_reader.dart';

const _filesystemMutationTokens = <String>[
  '.create(',
  '.delete(',
  '.rename(',
  '.copy(',
  '.writeAsBytes(',
  'FileMode.write',
  'FileMode.append',
];

const _legacyRuntimeTokens = <String>[
  'attachment_archive_relocation_service',
  'attachment_archive_relocation_journal',
  'attachment_archive_relocation_file_system',
  'attachment_archive_relocation_progress_monitor',
  'attachment_archive_relocation_activation_gate',
  'AttachmentArchiveDestinationCapacityReader',
  'AttachmentArchiveExclusiveDirectoryFinalizer',
  'FilesystemAttachmentArchiveRelocationJournalStore',
  'FilesystemAttachmentArchiveRelocationFileSystem',
];

const _settingsRoutePaths = <String>[
  'lib/essentials/sidebar/domain/sidebar_action_intent.dart',
  'lib/essentials/sidebar/application/sidebar_action_dispatcher.dart',
  'lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart',
  'lib/features/settings/application/sidebar_cassette_spec/coordinators/settings_coordinator.dart',
  'lib/features/settings/application/view_spec/coordinators/view_spec_coordinator.dart',
  'lib/features/settings/presentation/view/attachment_archive_panel.dart',
  'lib/features/settings/feature_level_providers.dart',
];
