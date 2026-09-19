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
        _attachmentApplicationPath('attachment_archive_adoption_service.dart'),
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

    test('Settings has no adoption activation dependency', () {
      final settingsRoot = Directory(
        path.join(repositoryRoot, 'lib/features/settings'),
      );
      final dartFiles = settingsRoot
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final source = file.readAsStringSync();
        expect(source, isNot(contains('attachment_archive_adoption')));
        expect(source, isNot(contains('activateVerifiedAdoption')));
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
