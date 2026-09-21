import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('approval revalidation is application-only and cannot activate', () {
    final sources = _revalidationPaths.map(_read).join('\n');

    for (final token in _activationAndPersistenceTokens) {
      expect(
        sources,
        isNot(contains(token)),
        reason: 'Approval revalidation contains forbidden authority: $token',
      );
    }
  });

  test('approval revalidation depends on no relocation runtime', () {
    final sources = <String>[
      ..._revalidationPaths.map(_read),
      _read(_filesystemVerifierPath),
    ].join('\n');

    for (final token in _relocationRuntimeTokens) {
      expect(
        sources,
        isNot(contains(token)),
        reason: 'Approval revalidation depends on relocation runtime: $token',
      );
    }
    expect(sources, isNot(contains('5c20c87a-c6d6-4489-8887-ae629301884f')));
  });

  test('only candidateComplete evidence can enter the approval boundary', () {
    final source = _read(_revalidatorPath);

    expect(
      RegExp(
        r'revalidate\(\s*AttachmentArchiveCandidateComplete verification,',
        multiLine: true,
      ).hasMatch(source),
      isTrue,
    );
    expect(
      RegExp(
        r'revalidateWithinApprovalScope\(\{\s*required '
        r'AttachmentArchiveCandidateComplete verification,',
        multiLine: true,
      ).hasMatch(source),
      isTrue,
    );
    expect(
      source,
      isNot(
        contains('AttachmentArchiveCandidateVerificationResult verification'),
      ),
    );
    expect(source, isNot(contains('String sourcePath')));
    expect(source, isNot(contains('String candidatePath')));
    expect(source, isNot(contains('String directoryPath')));
  });

  test('approval-ready evidence is process-local and non-serializable', () {
    final source = _read(_revalidationEntityPath);

    expect(
      source,
      contains('final AttachmentArchiveCandidateComplete verification;'),
    );
    expect(source, isNot(contains('toJson')));
    expect(source, isNot(contains('fromJson')));
    expect(source, isNot(contains('toPersistedValue')));
    expect(source, isNot(contains('bookmarkDataBase64')));
  });

  test('structural approval traversal cannot invoke payload hashing', () {
    final source = _read(_filesystemVerifierPath);
    final snapshotStart = source.indexOf('_readApprovalSnapshotRoots({');
    final fullVerificationStart = source.indexOf('_verifyRoots({');
    final sourceStructureStart = source.indexOf(
      '_inspectSourceStructureEntry({',
    );
    final walkStart = source.indexOf('Stream<_ArchiveEntry> _walk(');

    expect(snapshotStart, greaterThanOrEqualTo(0));
    expect(fullVerificationStart, greaterThan(snapshotStart));
    expect(sourceStructureStart, greaterThan(fullVerificationStart));
    expect(walkStart, greaterThan(sourceStructureStart));

    final structuralSource = <String>[
      source.substring(snapshotStart, fullVerificationStart),
      source.substring(sourceStructureStart, walkStart),
    ].join('\n');
    expect(structuralSource, isNot(contains('.hashFile(')));
    expect(structuralSource, isNot(contains('.open(')));
    expect(structuralSource, isNot(contains('.readAsBytes(')));
  });

  test('Settings and public feature seams expose no approval route', () {
    final settingsAndSeams = _settingsAndSeamPaths.map(_read).join('\n');

    expect(
      settingsAndSeams,
      isNot(contains('AttachmentArchiveApprovalRevalidator')),
    );
    expect(
      settingsAndSeams,
      isNot(contains('attachmentArchiveApprovalRevalidatorProvider')),
    );
    expect(
      settingsAndSeams,
      isNot(contains('attachment_archive_approval_revalidator')),
    );
  });

  test('adoption revalidation has one narrow coordinator operation', () {
    final operationSource = _read(
      'lib/essentials/archive_environment/domain/archive_mutation_operation.dart',
    );
    final revalidatorSource = _read(_revalidatorPath);

    expect(operationSource, contains('attachmentArchiveAdoption,'));
    expect(
      revalidatorSource,
      contains('ArchiveMutationOperation.attachmentArchiveAdoption'),
    );
    expect(revalidatorSource, contains('runWithCapability'));
    expect(revalidatorSource, contains('capability.requireOperation'));
  });

  test('behind approval hashes only the explicit added-entry set', () {
    final service = _read(
      'lib/features/attachments/application/'
      'attachment_archive_adoption_service.dart',
    );
    final verifier = _read(_filesystemVerifierPath);
    final addedStart = verifier.indexOf('readAddedMissingPayloads({');
    final structuralStart = verifier.indexOf(
      '_readApprovalSnapshotRoots({',
      addedStart,
    );

    expect(addedStart, greaterThanOrEqualTo(0));
    expect(structuralStart, greaterThan(addedStart));
    final addedReader = verifier.substring(addedStart, structuralStart);
    expect(addedReader, contains('for (final entry in addedEntries)'));
    expect(addedReader, contains('progress.hashFile('));
    expect(addedReader, isNot(contains('_verifyRoots(')));
    expect(addedReader, isNot(contains('candidateHash')));

    final refreshStart = service.indexOf('_refreshBehindVerification({');
    final resumeStart = service.indexOf(
      '_resumePendingWithinScope({',
      refreshStart,
    );
    expect(refreshStart, greaterThanOrEqualTo(0));
    expect(resumeStart, greaterThan(refreshStart));
    final approvalRefresh = service.substring(refreshStart, resumeStart);
    expect(approvalRefresh, contains('_requirePureSourceAdditions('));
    expect(approvalRefresh, contains('readAddedMissingPayloads('));
    expect(approvalRefresh, isNot(contains('_candidateVerifier.verify(')));
  });

  test('behind optimization retains coordination and final coverage proof', () {
    final source = _read(
      'lib/features/attachments/application/'
      'attachment_archive_adoption_service.dart',
    );

    expect(
      source,
      contains('ArchiveMutationOperation.attachmentArchiveAdoption'),
    );
    expect(source, contains('await _proveFinalCoverage('));
    expect(source, contains('onProgress: onFinalCoverageProgress'));
    expect(source, contains('final result = await verifier.verify('));
  });
}

String _read(String path) => File(path).readAsStringSync();

const _revalidatorPath =
    'lib/features/attachments/application/'
    'attachment_archive_approval_revalidator.dart';
const _snapshotReaderPath =
    'lib/features/attachments/application/'
    'attachment_archive_approval_snapshot_reader.dart';
const _revalidationEntityPath =
    'lib/features/attachments/domain/entities/'
    'attachment_archive_approval_revalidation.dart';
const _filesystemVerifierPath =
    'lib/features/attachments/infrastructure/repositories/'
    'filesystem_attachment_archive_candidate_verifier.dart';

const _revalidationPaths = <String>[
  _revalidatorPath,
  _snapshotReaderPath,
  _revalidationEntityPath,
];

const _activationAndPersistenceTokens = <String>[
  'persistConfiguration',
  'activeArchive',
  'AttachmentArchiveLocationController',
  'attachmentArchiveLocationProvider',
  'AttachmentArchiveSettingsStore',
  'bookmarkDataBase64',
  'writeAsString',
  'customStatement',
];

const _relocationRuntimeTokens = <String>[
  'attachment_archive_relocation_service',
  'attachment_archive_relocation_journal',
  'attachment_archive_relocation_file_system',
  'attachment_archive_relocation_progress_monitor',
  'attachment_archive_relocation_activation_gate',
  'AttachmentArchiveDestinationCapacityReader',
  'AttachmentArchiveExclusiveDirectoryFinalizer',
  'FilesystemAttachmentArchiveRelocationJournalStore',
  'FilesystemAttachmentArchiveRelocationFileSystem',
  'AttachmentArchiveRelocationActivationPermit',
];

const _settingsAndSeamPaths = <String>[
  'lib/essentials/sidebar/domain/sidebar_action_intent.dart',
  'lib/essentials/sidebar/application/sidebar_action_dispatcher.dart',
  'lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart',
  'lib/features/settings/application/sidebar_cassette_spec/coordinators/settings_coordinator.dart',
  'lib/features/settings/application/sidebar_cassette_spec/resolvers/attachment_archive_settings_resolver.dart',
  'lib/features/settings/feature_level_providers.dart',
  'lib/features/attachments/feature_level_providers.dart',
];
