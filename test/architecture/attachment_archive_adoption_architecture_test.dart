import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  final repositoryRoot = Directory.current.path;

  String read(String relativePath) {
    return File(path.join(repositoryRoot, relativePath)).readAsStringSync();
  }

  group('attachment archive adoption architecture', () {
    test('adoption runtime has no legacy mover dependency', () {
      final adoptionSources = <String>[
        _attachmentApplicationPath(
          'attachment_archive_adoption_authority.dart',
        ),
        _attachmentApplicationPath('attachment_archive_adoption_provider.dart'),
        _attachmentApplicationPath(
          'attachment_archive_adoption_recovery_service.dart',
        ),
        _attachmentApplicationPath(
          'attachment_archive_remediation_authority.dart',
        ),
        _attachmentApplicationPath('attachment_archive_adoption_service.dart'),
        _attachmentApplicationPath('attachment_archive_file_store.dart'),
        path.join(
          'lib',
          'features',
          'attachments',
          'domain',
          'entities',
          'attachment_archive_adoption.dart',
        ),
        path.join(
          'lib',
          'features',
          'attachments',
          'infrastructure',
          'repositories',
          'filesystem_attachment_archive_adoption_transaction_store.dart',
        ),
        path.join(
          'lib',
          'features',
          'attachments',
          'infrastructure',
          'repositories',
          'filesystem_attachment_archive_file_store.dart',
        ),
      ];
      const forbidden = <String>[
        'attachment_archive_relocation_service',
        'attachment_archive_relocation_journal',
        'attachment_archive_relocation_manifest',
        'attachment_archive_relocation_progress',
        'attachment_archive_relocation_activation_gate',
        'AttachmentArchiveRelocationActivationPermit',
        'availableCapacityForImportantUsage',
        'stagingRootPath',
        'copyReceipt',
        'pauseRequested',
        'resumeStage',
      ];

      for (final sourcePath in adoptionSources) {
        final source = read(sourcePath);
        for (final token in forbidden) {
          expect(
            source,
            isNot(contains(token)),
            reason: '$sourcePath must not depend on $token',
          );
        }
      }
    });

    test('startup recovery cannot scan or hash attachment payloads', () {
      final recovery = read(
        'lib/features/attachments/application/'
        'attachment_archive_adoption_recovery_service.dart',
      );
      const forbidden = <String>[
        'FilesystemAttachmentArchiveCandidateVerifier',
        'AttachmentArchiveApprovalSnapshotReader',
        'AttachmentArchiveVerificationMetadataReader',
        'readCandidate(',
        'sha256',
        '.list(',
        'relocation',
      ];

      for (final token in forbidden) {
        expect(recovery, isNot(contains(token)), reason: token);
      }
    });

    test('Settings reaches adoption only through the workflow boundary', () {
      final settingsRoot = Directory(
        path.join(repositoryRoot, 'lib/features/settings'),
      );
      final dartFiles = settingsRoot
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final source = file.readAsStringSync();
        expect(source, isNot(contains('activateVerifiedAdoption')));
        expect(
          source,
          isNot(contains('attachmentArchiveAdoptionServiceProvider')),
        );
        expect(
          source,
          isNot(contains('AttachmentArchiveAdoptionConfigurationAuthority')),
        );
        expect(source, isNot(contains('persistConfiguration')));
      }
    });

    test('active adoption persistence is confined to adoption-owned seams', () {
      final libRoot = Directory(path.join(repositoryRoot, 'lib'));
      final callers = <String>[];
      for (final file
          in libRoot
              .listSync(recursive: true, followLinks: false)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))) {
        final source = file.readAsStringSync();
        if (source.contains('persistVerifiedAdoptionConfiguration(')) {
          callers.add(path.relative(file.path, from: repositoryRoot));
        }
      }
      callers.sort();

      expect(callers, <String>[
        _attachmentApplicationPath(
          'attachment_archive_location_controller.dart',
        ),
        _attachmentApplicationPath('attachment_archive_location_provider.dart'),
      ]);
    });

    test('only adoption constructs active custom configuration', () {
      final offenders = <String>[];
      final attachmentsRoot = Directory(
        path.join(repositoryRoot, 'lib/features/attachments'),
      );
      for (final file
          in attachmentsRoot
              .listSync(recursive: true, followLinks: false)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))) {
        final source = file.readAsStringSync();
        if (RegExp(
          r'customWritePolicy:\s*AttachmentArchiveCustomWritePolicy\s*\.\s*activeArchive',
          multiLine: true,
        ).hasMatch(source)) {
          offenders.add(path.relative(file.path, from: repositoryRoot));
        }
      }

      expect(offenders, <String>[
        _attachmentApplicationPath('attachment_archive_adoption_service.dart'),
      ]);
    });

    test('ordinary persistence rejects active configuration', () {
      final controller = read(
        _attachmentApplicationPath(
          'attachment_archive_location_controller.dart',
        ),
      );

      expect(
        controller,
        contains('Active custom attachment archives require verified adoption'),
      );
      expect(controller, contains('persistVerifiedAdoptionConfiguration'));
      expect(
        controller,
        contains('AttachmentArchiveAdoptionConfigurationAuthority'),
      );
      expect(controller, isNot(contains('persistVerifiedRelocation')));
      expect(controller, isNot(contains('RelocationActivationPermit')));
    });

    test('activation requires both scope and bookmark admission proofs', () {
      final authority = read(
        _attachmentApplicationPath(
          'attachment_archive_adoption_authority.dart',
        ),
      );
      final service = read(
        _attachmentApplicationPath('attachment_archive_adoption_service.dart'),
      );

      expect(authority, contains('AttachmentArchiveApprovalScopeProof'));
      expect(authority, contains('AttachmentArchiveAdoptionBookmarkProof'));
      expect(
        authority,
        contains('approvalScopeProof.requireExactReadyEvidence'),
      );
      expect(authority, contains('bookmarkProof.requireExactAdmission'));
      expect(
        service,
        contains('const AttachmentArchiveAdoptionBookmarkProof._('),
      );
      expect(
        service,
        isNot(contains('AttachmentArchiveAdoptionBookmarkProof({')),
      );
    });

    test('transaction model cannot contain mover state', () {
      final transaction = read(
        'lib/features/attachments/domain/entities/'
        'attachment_archive_adoption.dart',
      );
      const forbiddenSerializedKeys = <String>[
        "'payloadManifest'",
        "'copyReceipts'",
        "'fileProgress'",
        "'availableCapacityBytes'",
        "'stagingPath'",
        "'pauseRequested'",
        "'resumeStage'",
      ];

      for (final token in forbiddenSerializedKeys) {
        expect(transaction, isNot(contains(token)));
      }
      expect(transaction, contains('maximumRemediationPayloadCount = 256'));
      expect(
        transaction,
        contains('maximumRemediationBytes = 1024 * 1024 * 1024'),
      );
      expect(transaction, contains('activeRemediationPending'));
      expect(transaction, contains('AttachmentArchiveRemediationPayload'));
    });

    test(
      'remediation authority is exact, active, bounded, and non-destructive',
      () {
        final authority = read(
          _attachmentApplicationPath(
            'attachment_archive_remediation_authority.dart',
          ),
        );

        for (final token in <String>[
          'transactionId',
          'sourceCanonicalIdentity',
          'candidateCanonicalIdentity',
          'activeCandidateRootPath',
          'candidateLocationGeneration',
          'AttachmentArchiveRemediationPayload payload',
          'ArchiveMutationOperation.attachmentArchiveAdoption',
          'pending.remediationPayloads.contains(payload)',
          'writableLease.requireValid',
        ]) {
          expect(authority, contains(token), reason: token);
        }
        expect(
          authority,
          contains('Remediation authority never permits deletion.'),
        );
      },
    );

    test('remediation reuses one typed atomic no-overwrite installer seam', () {
      final contract = read(
        _attachmentApplicationPath('attachment_archive_file_store.dart'),
      );
      final fileStore = read(
        'lib/features/attachments/infrastructure/repositories/'
        'filesystem_attachment_archive_file_store.dart',
      );
      final service = read(
        _attachmentApplicationPath('attachment_archive_adoption_service.dart'),
      );

      expect(contract, contains('installVerifiedArchiveEntryAtPath'));
      expect(contract, contains('AttachmentArchiveRemediationAuthority'));
      expect(fileStore, contains('AtomicNoOverwriteFileInstaller'));
      expect(fileStore, contains('_installVerifiedAtPath('));
      expect(fileStore, contains('AtomicFileInstallResult.destinationExists'));
      expect(service, contains('AttachmentArchiveRemediationAuthority.issue'));
      expect(service, contains('installVerifiedArchiveEntryAtPath'));
      expect(service, isNot(contains('Directory.rename')));
      expect(service, isNot(contains('Directory.copy')));
      expect(service, isNot(contains('availableCapacity')));
    });

    test('adoption service requires normal Phase Four lease validation', () {
      final service = read(
        'lib/features/attachments/application/'
        'attachment_archive_adoption_service.dart',
      );

      expect(service, contains('_readWritableAdmission()'));
      expect(service, contains('lease.matchesConfiguration'));
      expect(service, contains('lease.requireValid('));
      expect(
        service,
        contains('AttachmentArchiveMutationBoundary.operationStart'),
      );
      expect(service, contains('lease.permitsDestructiveReset'));
    });
  });
}

String _attachmentApplicationPath(String fileName) {
  return path.join('lib', 'features', 'attachments', 'application', fileName);
}
