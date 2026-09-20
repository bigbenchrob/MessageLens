import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_verification_metadata_reader.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_candidate_verification.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_candidate_verifier.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_verification_metadata_reader.dart';

void main() {
  group('FilesystemAttachmentArchiveCandidateVerifier', () {
    late Directory temporaryRoot;
    late Directory source;
    late Directory candidate;
    late OverlayDatabase database;
    late OverlayAttachmentArchiveVerificationMetadataReader metadataReader;

    setUp(() async {
      temporaryRoot = await Directory.systemTemp.createTemp(
        'attachment-adoption-verifier-',
      );
      source = await Directory(
        path.join(temporaryRoot.path, 'source'),
      ).create();
      candidate = await Directory(
        path.join(temporaryRoot.path, 'candidate'),
      ).create();
      database = OverlayDatabase(NativeDatabase.memory());
      metadataReader = OverlayAttachmentArchiveVerificationMetadataReader(
        overlayDatabase: database,
      );
    });

    tearDown(() async {
      await database.close();
      if (temporaryRoot.existsSync()) {
        await temporaryRoot.delete(recursive: true);
      }
    });

    test(
      'complete proves grouped metadata, null hashes, nested payloads, preservation files, debris, and extras',
      () async {
        final knownBytes = <int>[1, 2, 3, 4];
        final knownHash = sha256.convert(knownBytes).toString();
        await _writeBoth(
          source,
          candidate,
          'nested/deeper/known.bin',
          knownBytes,
        );
        await _insertMetadata(
          database,
          guid: 'known-1',
          attachmentId: 1,
          relativePath: 'nested/deeper/known.bin',
          bytes: knownBytes,
          hash: knownHash,
        );
        await _insertMetadata(
          database,
          guid: 'known-2',
          attachmentId: 2,
          relativePath: 'nested/deeper/known.bin',
          bytes: knownBytes,
          hash: knownHash,
        );

        final nullHashBytes = <int>[5, 6, 7];
        await _writeBoth(
          source,
          candidate,
          'metadata/null-hash.dat',
          nullHashBytes,
        );
        await _insertMetadata(
          database,
          guid: 'null-hash',
          attachmentId: 3,
          relativePath: 'metadata/null-hash.dat',
          bytes: nullHashBytes,
          hash: null,
        );

        final sourceHashRelative = await _writeContentAddressed(source, <int>[
          8,
          9,
          10,
        ], extension: 'bin');
        await _copyRelative(source, candidate, sourceHashRelative);
        await _writeBoth(source, candidate, '_by_id/77.jpg', <int>[11, 12]);

        final debrisRelative = _installerDebrisFor(sourceHashRelative);
        await _writeBoth(source, candidate, debrisRelative, <int>[99]);
        final extraHashRelative = await _writeContentAddressed(candidate, <int>[
          13,
          14,
          15,
        ], extension: 'png');
        await _write(candidate, '_by_id/999.pdf', <int>[16, 17]);
        await Directory(
          path.join(candidate.path, 'empty', 'safe'),
        ).create(recursive: true);

        final result = await _verifier(metadataReader).verify(
          sourceLocation: _sourceLocation(source, generation: 9),
          candidate: _candidate(candidate, writable: false),
        );

        expect(result, isA<AttachmentArchiveCandidateComplete>());
        final evidence = result.evidence!;
        expect(evidence.sourceLocationGeneration, 9);
        expect(evidence.candidateWasPhysicallyWritable, isFalse);
        expect(evidence.requiredSourcePhysicalFileCount, 4);
        expect(evidence.requiredSourceBytes, 12);
        expect(evidence.verifiedFileCount, 4);
        expect(evidence.verifiedBytes, 12);
        expect(evidence.metadataReferenceCount, 3);
        expect(evidence.unreferencedPreservationCount, 2);
        expect(evidence.sourceOperationalDebrisCount, 1);
        expect(evidence.candidateOperationalDebrisCount, 1);
        expect(evidence.allowedCandidateExtraCount, 2);
        expect(evidence.allowedCandidateExtraBytes, 5);
        expect(evidence.missingCount, 0);
        expect(
          evidence.diagnostics.allowedExtraPathExamples,
          containsAll(<String>[extraHashRelative, '_by_id/999.pdf']),
        );
        expect(evidence.contentCoverageDigest, hasLength(64));
        expect(evidence.sourceStructuralSnapshotFingerprint, hasLength(64));
        expect(evidence.candidateStructuralSnapshotFingerprint, hasLength(64));
      },
    );

    test(
      'identical archive relationship produces deterministic evidence',
      () async {
        await _writeMetadataPayload(
          database,
          source,
          candidate,
          relativePath: 'nested/item.bin',
          bytes: <int>[1, 3, 3, 7],
          withHash: true,
        );
        final verifier = _verifier(metadataReader);

        final first = await verifier.verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );
        final second = await verifier.verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );

        expect(first, isA<AttachmentArchiveCandidateComplete>());
        expect(second, isA<AttachmentArchiveCandidateComplete>());
        expect(
          second.evidence!.contentCoverageDigest,
          first.evidence!.contentCoverageDigest,
        );
        expect(
          second.evidence!.sourceStructuralSnapshotFingerprint,
          first.evidence!.sourceStructuralSnapshotFingerprint,
        );
        expect(
          second.evidence!.candidateStructuralSnapshotFingerprint,
          first.evidence!.candidateStructuralSnapshotFingerprint,
        );
      },
    );

    test(
      'source-only .DS_Store is ignored without hashing or preservation coverage',
      () async {
        final hashedPaths = <String>[];
        await _write(source, '.DS_Store', <int>[1, 2, 3]);

        final result =
            await _verifier(
              metadataReader,
              onPayloadHashStarted: hashedPaths.add,
            ).verify(
              sourceLocation: _sourceLocation(source),
              candidate: _candidate(candidate),
            );

        expect(result, isA<AttachmentArchiveCandidateComplete>());
        expect(result.evidence!.requiredSourcePhysicalFileCount, 0);
        expect(result.evidence!.requiredSourceBytes, 0);
        expect(result.evidence!.missingCount, 0);
        expect(hashedPaths, isEmpty);
      },
    );

    test(
      'candidate-only .DS_Store is ignored without hashing or extra evidence',
      () async {
        final hashedPaths = <String>[];
        await _write(candidate, '.DS_Store', <int>[4, 5, 6]);

        final result =
            await _verifier(
              metadataReader,
              onPayloadHashStarted: hashedPaths.add,
            ).verify(
              sourceLocation: _sourceLocation(source),
              candidate: _candidate(candidate),
            );

        expect(result, isA<AttachmentArchiveCandidateComplete>());
        expect(result.evidence!.allowedCandidateExtraCount, 0);
        expect(result.evidence!.allowedCandidateExtraBytes, 0);
        expect(hashedPaths, isEmpty);
      },
    );

    test(
      'near .DS_Store names and ordinary unknown files fail closed',
      () async {
        await _write(candidate, '.DS_Store.foo', <int>[1]);

        final nearName = await _verifier(metadataReader).verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );

        expect(nearName, isA<AttachmentArchiveCandidateInvalid>());
        expect(nearName.issue, contains('.DS_Store.foo'));

        await File(path.join(candidate.path, '.DS_Store.foo')).delete();
        await _write(source, 'ordinary-unknown.txt', <int>[2]);

        final ordinaryUnknown = await _verifier(metadataReader).verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );

        expect(
          ordinaryUnknown,
          isA<AttachmentArchiveCandidateVerificationFailed>(),
        );
        expect(ordinaryUnknown.issue, contains('ordinary-unknown.txt'));
      },
    );

    test(
      'metadata-known .DS_Store fails closed instead of being ignored',
      () async {
        final bytes = <int>[1, 2, 3];
        await _write(source, '.DS_Store', bytes);
        await _insertMetadata(
          database,
          guid: 'unexpected-finder-metadata',
          attachmentId: 91,
          relativePath: '.DS_Store',
          bytes: bytes,
          hash: sha256.convert(bytes).toString(),
        );

        final result = await _verifier(metadataReader).verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );

        expect(result, isA<AttachmentArchiveCandidateVerificationFailed>());
        expect(result.issue, contains('unexpectedly references'));
      },
    );

    test('behind reports one missing file and exact bytes', () async {
      await _writeMetadataPayload(
        database,
        source,
        null,
        relativePath: 'nested/missing.bin',
        bytes: <int>[1, 2, 3, 4, 5],
        withHash: false,
      );

      final result = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );

      expect(result, isA<AttachmentArchiveCandidateBehind>());
      expect(result.evidence!.missingCount, 1);
      expect(result.evidence!.missingBytes, 5);
      expect(result.evidence!.diagnostics.missingPathExamples, <String>[
        'nested/missing.bin',
      ]);
    });

    test(
      'behind caps examples without changing totals and permits extras',
      () async {
        for (var index = 0; index < 105; index++) {
          final paddedIndex = index.toString().padLeft(3, '0');
          final relativePath = 'missing/item-$paddedIndex.bin';
          await _writeMetadataPayload(
            database,
            source,
            null,
            relativePath: relativePath,
            bytes: <int>[index % 256],
            withHash: false,
            attachmentId: index,
          );
        }
        await _writeContentAddressed(candidate, <int>[9, 9, 9]);

        final result = await _verifier(metadataReader).verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );

        expect(result, isA<AttachmentArchiveCandidateBehind>());
        expect(result.evidence!.missingCount, 105);
        expect(result.evidence!.missingBytes, 105);
        expect(
          result.evidence!.diagnostics.missingPathExamples,
          hasLength(100),
        );
        expect(result.evidence!.allowedCandidateExtraCount, 1);
      },
    );

    test(
      'fresh invocation observes a source payload added after ready',
      () async {
        await _writeBoth(source, candidate, '_by_id/1.bin', <int>[1]);
        final verifier = _verifier(metadataReader);
        final ready = await verifier.verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );

        final added = await _writeContentAddressed(source, <int>[2, 2, 2]);
        final checkedAgain = await verifier.verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );

        expect(ready, isA<AttachmentArchiveCandidateComplete>());
        expect(checkedAgain, isA<AttachmentArchiveCandidateBehind>());
        expect(checkedAgain.evidence!.missingCount, 1);
        expect(checkedAgain.evidence!.diagnostics.missingPathExamples, <String>[
          added,
        ]);
      },
    );

    test('candidate conflict takes precedence over missing coverage', () async {
      await _writeMetadataPayload(
        database,
        source,
        null,
        relativePath: 'missing/item.bin',
        bytes: <int>[1],
        withHash: false,
      );
      await _write(candidate, 'unknown.txt', <int>[2]);

      final result = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );

      expect(result, isA<AttachmentArchiveCandidateInvalid>());
      expect(result.evidence!.missingCount, 1);
      expect(
        result.evidence!.diagnostics.conflictingPathExamples,
        contains('unknown.txt'),
      );
    });

    test('candidate size and content mismatches are invalid', () async {
      final bytes = <int>[1, 2, 3, 4];
      await _writeMetadataPayload(
        database,
        source,
        candidate,
        relativePath: 'known/item.bin',
        bytes: bytes,
        withHash: true,
      );
      await _write(candidate, 'known/item.bin', <int>[1, 2]);
      final wrongSize = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );

      await _write(candidate, 'known/item.bin', <int>[4, 3, 2, 1]);
      final wrongHash = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );

      expect(wrongSize, isA<AttachmentArchiveCandidateInvalid>());
      expect(wrongHash, isA<AttachmentArchiveCandidateInvalid>());
      expect(wrongSize.evidence!.missingCount, 0);
      expect(wrongHash.evidence!.verifiedFileCount, 0);
    });

    test('hash-named contradictory extra is invalid', () async {
      final claimedHash = sha256.convert(<int>[1, 2, 3]).toString();
      final relativePath = '${claimedHash.substring(0, 2)}/$claimedHash.bin';
      await _write(candidate, relativePath, <int>[3, 2, 1]);

      final result = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );

      expect(result, isA<AttachmentArchiveCandidateInvalid>());
      expect(
        result.evidence!.diagnostics.conflictingPathExamples,
        contains(relativePath),
      );
    });

    test('unknown candidate regular file is invalid', () async {
      await _write(candidate, 'notes.txt', <int>[1]);

      final result = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );

      expect(result, isA<AttachmentArchiveCandidateInvalid>());
    });

    test('candidate symlink and special entry are invalid', () async {
      await _writeBoth(source, candidate, '_by_id/1.bin', <int>[1]);
      await File(path.join(candidate.path, '_by_id/1.bin')).delete();
      await Link(
        path.join(candidate.path, '_by_id/1.bin'),
      ).create(path.join(source.path, '_by_id/1.bin'));

      final symlinkResult = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );
      expect(symlinkResult, isA<AttachmentArchiveCandidateInvalid>());

      await Link(path.join(candidate.path, '_by_id/1.bin')).delete();
      await _write(candidate, '_by_id/1.bin', <int>[1]);
      final pipePath = path.join(candidate.path, '_by_id/2.bin');
      final pipe = await Process.run('mkfifo', <String>[pipePath]);
      if (pipe.exitCode == 0) {
        final pipeResult = await _verifier(metadataReader).verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );
        expect(pipeResult, isA<AttachmentArchiveCandidateInvalid>());
      }
    });

    test('source root and source entry symlinks fail verification', () async {
      await _write(source, '_by_id/1.bin', <int>[1]);
      await Link(
        path.join(source.path, '_by_id/2.bin'),
      ).create(path.join(source.path, '_by_id/1.bin'));

      final entrySymlink = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );
      expect(entrySymlink, isA<AttachmentArchiveCandidateVerificationFailed>());

      final sourceLink = Link(path.join(temporaryRoot.path, 'source-link'));
      await sourceLink.create(source.path);
      final rootSymlink = await _verifier(metadataReader).verify(
        sourceLocation: AttachmentArchiveLocationState.defaultAvailable(
          archiveRootPath: sourceLink.path,
        ),
        candidate: _candidate(candidate),
      );
      expect(rootSymlink, isA<AttachmentArchiveCandidateVerificationFailed>());
    });

    test('near-miss installer temporary name is not allowlisted', () async {
      final payloadRelative = await _writeContentAddressed(candidate, <int>[
        1,
        2,
        3,
      ]);
      await File(path.join(candidate.path, payloadRelative)).delete();
      final parent = path.dirname(payloadRelative);
      final basename = path.basename(payloadRelative);
      await _write(
        candidate,
        path.join(parent, '.$basename.messagelens-install-not-a-uuid.tmp'),
        <int>[1, 2, 3],
      );

      final result = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );

      expect(result, isA<AttachmentArchiveCandidateInvalid>());
      expect(result.evidence!.candidateOperationalDebrisCount, 0);
    });

    test('source metadata conflicts fail verification', () async {
      await _write(source, 'known/item.bin', <int>[1, 2]);
      await _insertMetadata(
        database,
        guid: 'one',
        attachmentId: 1,
        relativePath: 'known/item.bin',
        bytes: <int>[1, 2],
        hash: _hash('a'),
      );
      await _insertMetadata(
        database,
        guid: 'two',
        attachmentId: 2,
        relativePath: 'known/item.bin',
        bytes: <int>[1, 2, 3],
        hash: _hash('b'),
      );

      final result = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );

      expect(result, isA<AttachmentArchiveCandidateVerificationFailed>());
      expect(result.issue, contains('Conflicting attachment'));
    });

    test('missing metadata-known source payload fails verification', () async {
      await _insertMetadata(
        database,
        guid: 'missing',
        attachmentId: 1,
        relativePath: 'known/missing.bin',
        bytes: <int>[1, 2],
        hash: null,
      );

      final result = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );

      expect(result, isA<AttachmentArchiveCandidateVerificationFailed>());
      expect(result.issue, contains('missing, unsafe, or non-regular'));
    });

    test('unknown source file and unsafe metadata path fail closed', () async {
      await _write(source, 'unknown.txt', <int>[1]);
      final unknown = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );
      expect(unknown, isA<AttachmentArchiveCandidateVerificationFailed>());

      await File(path.join(source.path, 'unknown.txt')).delete();
      await _insertMetadata(
        database,
        guid: 'escape',
        attachmentId: 1,
        relativePath: '../escape.bin',
        bytes: <int>[1],
        hash: null,
      );
      final traversal = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );
      expect(traversal, isA<AttachmentArchiveCandidateVerificationFailed>());
      expect(traversal.issue, contains('unsafe path'));
    });

    test('same and nested roots are invalid before traversal', () async {
      final verifier = _verifier(metadataReader);
      final same = await verifier.verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(source),
      );
      final nestedDirectory = await Directory(
        path.join(source.path, 'nested-candidate'),
      ).create();
      final nested = await verifier.verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(nestedDirectory),
      );
      final candidateLink = Link(
        path.join(temporaryRoot.path, 'candidate-link'),
      );
      await candidateLink.create(candidate.path);
      final linked = await verifier.verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(Directory(candidateLink.path)),
      );

      expect(same, isA<AttachmentArchiveCandidateInvalid>());
      expect(nested, isA<AttachmentArchiveCandidateInvalid>());
      expect(linked, isA<AttachmentArchiveCandidateInvalid>());
    });

    test('source and candidate unavailability remain distinct', () async {
      final missingSource = Directory(
        path.join(temporaryRoot.path, 'missing-source'),
      );
      final missingCandidate = Directory(
        path.join(temporaryRoot.path, 'missing-candidate'),
      );
      final verifier = _verifier(metadataReader);

      final sourceUnavailable = await verifier.verify(
        sourceLocation: _sourceLocation(missingSource),
        candidate: _candidate(candidate),
      );
      final candidateUnavailable = await verifier.verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(missingCandidate),
      );

      expect(
        sourceUnavailable,
        isA<AttachmentArchiveVerificationSourceUnavailable>(),
      );
      expect(
        candidateUnavailable,
        isA<AttachmentArchiveVerificationCandidateUnavailable>(),
      );
    });

    test('case-variant candidate path is rejected as ambiguous', () async {
      await _writeMetadataPayload(
        database,
        source,
        null,
        relativePath: 'aa/item.bin',
        bytes: <int>[1, 2, 3],
        withHash: false,
      );
      await _write(candidate, 'AA/item.bin', <int>[1, 2, 3]);

      final result = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );

      expect(result, isA<AttachmentArchiveCandidateInvalid>());
    });

    test(
      'content digest changes with path, payload, and classification',
      () async {
        await _writeBoth(source, candidate, '_by_id/1.bin', <int>[1, 2]);
        final verifier = _verifier(metadataReader);
        final original = await verifier.verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );

        await File(
          path.join(source.path, '_by_id/1.bin'),
        ).rename(path.join(source.path, '_by_id/2.bin'));
        await File(
          path.join(candidate.path, '_by_id/1.bin'),
        ).rename(path.join(candidate.path, '_by_id/2.bin'));
        final moved = await verifier.verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );

        await _writeBoth(source, candidate, '_by_id/2.bin', <int>[2, 1]);
        final changed = await verifier.verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );

        final changedHash = sha256.convert(<int>[2, 1]).toString();
        await _insertMetadata(
          database,
          guid: 'classified',
          attachmentId: 1,
          relativePath: '_by_id/2.bin',
          bytes: <int>[2, 1],
          hash: changedHash,
        );
        final classified = await verifier.verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );

        final digests = <String>{
          original.evidence!.contentCoverageDigest,
          moved.evidence!.contentCoverageDigest,
          changed.evidence!.contentCoverageDigest,
          classified.evidence!.contentCoverageDigest,
        };
        expect(digests, hasLength(4));
      },
    );

    test(
      'structural fingerprints detect source and candidate changes',
      () async {
        await _writeBoth(source, candidate, '_by_id/1.bin', <int>[1, 2, 3]);
        final verifier = _verifier(metadataReader);
        final initial = await verifier.verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );

        final added = await _writeContentAddressed(source, <int>[4, 5]);
        final sourceAdded = await verifier.verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );
        expect(
          sourceAdded.evidence!.sourceStructuralSnapshotFingerprint,
          isNot(initial.evidence!.sourceStructuralSnapshotFingerprint),
        );

        await _copyRelative(source, candidate, added);
        final candidateAdded = await verifier.verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );
        expect(
          candidateAdded.evidence!.candidateStructuralSnapshotFingerprint,
          isNot(initial.evidence!.candidateStructuralSnapshotFingerprint),
        );

        await File(path.join(source.path, added)).delete();
        final sourceRemoved = await verifier.verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
        );
        expect(
          sourceRemoved.evidence!.sourceStructuralSnapshotFingerprint,
          isNot(sourceAdded.evidence!.sourceStructuralSnapshotFingerprint),
        );
      },
    );

    test('fingerprints detect size, timestamp, and metadata changes', () async {
      final bytes = <int>[1, 2, 3, 4];
      await _writeMetadataPayload(
        database,
        source,
        candidate,
        relativePath: 'known/item.bin',
        bytes: bytes,
        withHash: false,
      );
      final verifier = _verifier(metadataReader);
      final initial = await verifier.verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );

      await _write(candidate, 'known/item.bin', <int>[1, 2]);
      final sizeChanged = await verifier.verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );
      expect(
        sizeChanged.evidence!.candidateStructuralSnapshotFingerprint,
        isNot(initial.evidence!.candidateStructuralSnapshotFingerprint),
      );

      final candidateFile = await _write(candidate, 'known/item.bin', <int>[
        4,
        3,
        2,
        1,
      ]);
      await candidateFile.setLastModified(DateTime.utc(2026, 9, 19));
      final timestampChanged = await verifier.verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );
      expect(
        timestampChanged.evidence!.candidateStructuralSnapshotFingerprint,
        isNot(initial.evidence!.candidateStructuralSnapshotFingerprint),
      );

      await _write(candidate, 'known/item.bin', bytes);
      await _insertMetadata(
        database,
        guid: 'duplicate',
        attachmentId: 2,
        relativePath: 'known/item.bin',
        bytes: bytes,
        hash: null,
      );
      final metadataChanged = await verifier.verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );
      expect(
        metadataChanged.evidence!.sourceStructuralSnapshotFingerprint,
        isNot(initial.evidence!.sourceStructuralSnapshotFingerprint),
      );
      expect(metadataChanged.evidence!.metadataReferenceCount, 2);
    });

    test('configuration and generation remain result-level evidence', () async {
      await _writeBoth(source, candidate, '_by_id/1.bin', <int>[1]);
      final verifier = _verifier(metadataReader);
      final first = await verifier.verify(
        sourceLocation: _sourceLocation(source, generation: 1),
        candidate: _candidate(candidate),
      );
      final second = await verifier.verify(
        sourceLocation: _sourceLocation(source, generation: 2),
        candidate: _candidate(candidate),
      );
      final externalConfiguration =
          AttachmentArchiveLocationConfiguration.customExternal(
            bookmarkDataBase64: 'AQID',
            lastKnownPath: source.path,
          );
      final third = await verifier.verify(
        sourceLocation: AttachmentArchiveLocationState.customAvailable(
          configuration: externalConfiguration,
          archiveRootPath: source.path,
          generation: 3,
        ),
        candidate: _candidate(candidate),
      );

      expect(first.evidence!.sourceLocationGeneration, 1);
      expect(second.evidence!.sourceLocationGeneration, 2);
      expect(
        third.evidence!.sourceLocationConfiguration,
        externalConfiguration,
      );
      expect(
        second.evidence!.sourceStructuralSnapshotFingerprint,
        first.evidence!.sourceStructuralSnapshotFingerprint,
      );
    });

    test('verification is read-only for roots and overlay', () async {
      await _writeMetadataPayload(
        database,
        source,
        candidate,
        relativePath: 'known/item.bin',
        bytes: <int>[1, 2, 3],
        withHash: true,
      );
      final sourceBefore = await _snapshotTree(source);
      final candidateBefore = await _snapshotTree(candidate);
      final overlayBefore = await _snapshotOverlay(database);

      final result = await _verifier(metadataReader).verify(
        sourceLocation: _sourceLocation(source),
        candidate: _candidate(candidate),
      );

      expect(result, isA<AttachmentArchiveCandidateComplete>());
      expect(await _snapshotTree(source), sourceBefore);
      expect(await _snapshotTree(candidate), candidateBefore);
      expect(await _snapshotOverlay(database), overlayBefore);
    });

    test('progress is ephemeral and cancellation needs no cleanup', () async {
      final bytes = List<int>.filled(2 * 1024 * 1024, 7);
      await _writeBoth(source, candidate, '_by_id/1.bin', bytes);
      var cancel = false;
      final progress = <AttachmentArchiveVerificationProgress>[];
      final sourceBefore = await _snapshotTree(source);
      final candidateBefore = await _snapshotTree(candidate);

      await expectLater(
        _verifier(metadataReader).verify(
          sourceLocation: _sourceLocation(source),
          candidate: _candidate(candidate),
          onProgress: (value) {
            progress.add(value);
            if (value.bytesChecked > 0) {
              cancel = true;
            }
          },
          isCancelled: () => cancel,
        ),
        throwsA(isA<AttachmentArchiveCandidateVerificationCancelled>()),
      );

      expect(progress, isNotEmpty);
      expect(
        progress.map((value) => value.phase),
        contains(AttachmentArchiveVerificationPhase.sourceCoverage),
      );
      expect(await _snapshotTree(source), sourceBefore);
      expect(await _snapshotTree(candidate), candidateBefore);
    });

    test(
      'metadata paging remains bounded for a larger synthetic set',
      () async {
        for (var index = 0; index < 75; index++) {
          final paddedIndex = index.toString().padLeft(3, '0');
          final relativePath = 'paged/item-$paddedIndex.bin';
          await _writeMetadataPayload(
            database,
            source,
            candidate,
            relativePath: relativePath,
            bytes: <int>[index],
            withHash: false,
            attachmentId: index,
          );
        }
        final recordingReader = _RecordingMetadataReader(metadataReader);

        final result = await _verifier(recordingReader, metadataPageSize: 16)
            .verify(
              sourceLocation: _sourceLocation(source),
              candidate: _candidate(candidate),
            );

        expect(result, isA<AttachmentArchiveCandidateComplete>());
        expect(recordingReader.pageLimits, everyElement(16));
        expect(recordingReader.pageLimits.length, greaterThan(1));
        expect(result.evidence!.requiredSourcePhysicalFileCount, 75);
      },
    );
  });
}

FilesystemAttachmentArchiveCandidateVerifier _verifier(
  AttachmentArchiveVerificationMetadataReader reader, {
  int metadataPageSize = 500,
  void Function(String path)? onPayloadHashStarted,
}) {
  return FilesystemAttachmentArchiveCandidateVerifier(
    metadataReader: reader,
    metadataPageSize: metadataPageSize,
    onPayloadHashStarted: onPayloadHashStarted,
    clock: () => DateTime.utc(2026, 9, 18, 12),
  );
}

AttachmentArchiveLocationState _sourceLocation(
  Directory source, {
  int generation = 1,
}) {
  return AttachmentArchiveLocationState.defaultAvailable(
    archiveRootPath: source.path,
    generation: generation,
  );
}

AttachmentArchiveCandidateAccess _candidate(
  Directory candidate, {
  bool writable = true,
}) {
  return AttachmentArchiveCandidateAccess(
    directoryPath: candidate.path,
    isPhysicallyWritable: writable,
  );
}

Future<File> _write(
  Directory root,
  String relativePath,
  List<int> bytes,
) async {
  final file = File(path.join(root.path, relativePath));
  await file.parent.create(recursive: true);
  return file.writeAsBytes(bytes, flush: true);
}

Future<void> _writeBoth(
  Directory source,
  Directory candidate,
  String relativePath,
  List<int> bytes,
) async {
  await _write(source, relativePath, bytes);
  await _write(candidate, relativePath, bytes);
}

Future<void> _copyRelative(
  Directory source,
  Directory candidate,
  String relativePath,
) async {
  await _write(
    candidate,
    relativePath,
    await File(path.join(source.path, relativePath)).readAsBytes(),
  );
}

Future<String> _writeContentAddressed(
  Directory root,
  List<int> bytes, {
  String extension = 'bin',
}) async {
  final hash = sha256.convert(bytes).toString();
  final relativePath = '${hash.substring(0, 2)}/$hash.$extension';
  await _write(root, relativePath, bytes);
  return relativePath;
}

String _installerDebrisFor(String payloadRelativePath) {
  final parent = path.dirname(payloadRelativePath);
  final basename = path.basename(payloadRelativePath);
  return path.join(
    parent,
    '.$basename.messagelens-install-'
    '123e4567-e89b-42d3-a456-426614174000.tmp',
  );
}

Future<void> _writeMetadataPayload(
  OverlayDatabase database,
  Directory source,
  Directory? candidate, {
  required String relativePath,
  required List<int> bytes,
  required bool withHash,
  int attachmentId = 1,
}) async {
  await _write(source, relativePath, bytes);
  if (candidate != null) {
    await _write(candidate, relativePath, bytes);
  }
  await _insertMetadata(
    database,
    guid: 'guid-$attachmentId-$relativePath',
    attachmentId: attachmentId,
    relativePath: relativePath,
    bytes: bytes,
    hash: withHash ? sha256.convert(bytes).toString() : null,
  );
}

Future<void> _insertMetadata(
  OverlayDatabase database, {
  required String guid,
  required int attachmentId,
  required String relativePath,
  required List<int> bytes,
  required String? hash,
}) {
  return database.customStatement(
    '''
    INSERT INTO archived_attachments (
      message_guid,
      import_attachment_id,
      archive_relative_path,
      archived_at_utc,
      file_size_bytes,
      content_hash,
      provenance
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
    ''',
    <Object?>[
      guid,
      attachmentId,
      relativePath,
      '2026-09-18T00:00:00.000Z',
      bytes.length,
      hash,
      'archived',
    ],
  );
}

String _hash(String character) => List<String>.filled(64, character).join();

Future<List<String>> _snapshotTree(Directory root) async {
  final rows = <String>[];
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    final relativePath = path.relative(entity.path, from: root.path);
    final type = FileSystemEntity.typeSync(entity.path, followLinks: false);
    if (type == FileSystemEntityType.file) {
      final stat = await entity.stat();
      final digest = sha256.convert(await File(entity.path).readAsBytes());
      rows.add(
        'file|$relativePath|${stat.size}|${stat.modified.microsecondsSinceEpoch}|$digest',
      );
    } else {
      rows.add('$type|$relativePath');
    }
  }
  rows.sort();
  return rows;
}

Future<List<String>> _snapshotOverlay(OverlayDatabase database) async {
  final rows = await database.customSelect('''
    SELECT message_guid, import_attachment_id, archive_relative_path,
           file_size_bytes, content_hash, provenance
    FROM archived_attachments
    ORDER BY message_guid, import_attachment_id
    ''').get();
  return rows.map((row) => row.data.toString()).toList(growable: false);
}

final class _RecordingMetadataReader
    implements AttachmentArchiveVerificationMetadataReader {
  _RecordingMetadataReader(this.delegate);

  final AttachmentArchiveVerificationMetadataReader delegate;
  final List<int> pageLimits = <int>[];

  @override
  Future<AttachmentArchiveVerificationMetadataGroup?> readByRelativePath(
    String relativePath,
  ) {
    return delegate.readByRelativePath(relativePath);
  }

  @override
  Future<AttachmentArchiveVerificationMetadataPage> readPage({
    required String? afterRelativePath,
    required int limit,
  }) {
    pageLimits.add(limit);
    return delegate.readPage(
      afterRelativePath: afterRelativePath,
      limit: limit,
    );
  }
}
