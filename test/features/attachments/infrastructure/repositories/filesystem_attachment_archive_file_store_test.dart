import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/features/attachments/application/atomic_no_overwrite_file_installer.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_file_store.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_file_store.dart';

void main() {
  late Directory tempDir;
  late Directory archiveDir;
  late FilesystemAttachmentArchiveFileStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'filesystem_attachment_archive_file_store_test_',
    );
    archiveDir = Directory(path.join(tempDir.path, 'attachment_archive'));
    store = const FilesystemAttachmentArchiveFileStore();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('ensures archive directory exists', () async {
    expect(archiveDir.existsSync(), isFalse);

    await store.ensureArchiveDirectory(
      archiveDir.path,
      validateMutation: _acceptMutationBoundary,
    );

    expect(archiveDir.existsSync(), isTrue);
  });

  test('rejects symlinked archive directory', () async {
    final outsideDir = Directory(path.join(tempDir.path, 'outside_archive'))
      ..createSync();
    final archiveLink = Link(archiveDir.path);
    await archiveLink.create(outsideDir.path);

    await expectLater(
      store.ensureArchiveDirectory(
        archiveDir.path,
        validateMutation: _acceptMutationBoundary,
      ),
      throwsStateError,
    );
  });

  test('returns null when source file is absent', () async {
    final write = await store.writeArchiveEntry(
      archiveDirectoryPath: archiveDir.path,
      sourcePath: path.join(tempDir.path, 'missing.jpg'),
      archiveKey: _archiveKey(),
      sha256Hex: null,
      validateMutation: _acceptMutationBoundary,
    );

    expect(write, isNull);
    expect(archiveDir.existsSync(), isFalse);
  });

  test('returns null when source file is a symlink', () async {
    final outsideFile = File(path.join(tempDir.path, 'outside.jpg'));
    await outsideFile.writeAsString('outside image');
    final sourceLink = Link(path.join(tempDir.path, 'linked.jpg'));
    await sourceLink.create(outsideFile.path);

    final write = await store.writeArchiveEntry(
      archiveDirectoryPath: archiveDir.path,
      sourcePath: sourceLink.path,
      archiveKey: _archiveKey(),
      sha256Hex: null,
      validateMutation: _acceptMutationBoundary,
    );

    expect(write, isNull);
    expect(archiveDir.existsSync(), isFalse);
  });

  test('writes archive entry using computed content hash path', () async {
    final sourceFile = File(path.join(tempDir.path, 'Photo.JPG'));
    await sourceFile.writeAsString('image bytes');
    final expectedHash = sha256
        .convert(await sourceFile.readAsBytes())
        .toString();

    final write = await store.writeArchiveEntry(
      archiveDirectoryPath: archiveDir.path,
      sourcePath: sourceFile.path,
      archiveKey: _archiveKey(),
      sha256Hex: null,
      validateMutation: _acceptMutationBoundary,
    );

    expect(write, isNotNull);
    expect(write!.sourcePath, sourceFile.path);
    expect(
      write.relativePath,
      '${expectedHash.substring(0, 2)}/$expectedHash.jpg',
    );
    expect(write.fileSizeBytes, await sourceFile.length());
    expect(write.contentHash, expectedHash);
    expect(
      File(path.join(archiveDir.path, write.relativePath)).existsSync(),
      isTrue,
    );
  });

  test('writes archive entry using supplied content hash', () async {
    final sourceFile = File(path.join(tempDir.path, 'photo.png'));
    await sourceFile.writeAsString('image bytes');
    final suppliedHash = sha256
        .convert(await sourceFile.readAsBytes())
        .toString();

    final write = await store.writeArchiveEntry(
      archiveDirectoryPath: archiveDir.path,
      sourcePath: sourceFile.path,
      archiveKey: _archiveKey(),
      sha256Hex: suppliedHash,
      validateMutation: _acceptMutationBoundary,
    );

    expect(write, isNotNull);
    expect(
      write!.relativePath,
      '${suppliedHash.substring(0, 2)}/$suppliedHash.png',
    );
    expect(write.contentHash, suppliedHash);
    expect(
      File(
        path.join(
          archiveDir.path,
          suppliedHash.substring(0, 2),
          '$suppliedHash.png',
        ),
      ).existsSync(),
      isTrue,
    );
  });

  test('rejects symlinked archive destination target', () async {
    final sourceFile = File(path.join(tempDir.path, 'photo.png'));
    await sourceFile.writeAsString('image bytes');
    final suppliedHash = sha256
        .convert(await sourceFile.readAsBytes())
        .toString();
    final outsideFile = File(path.join(tempDir.path, 'outside.png'));
    await outsideFile.writeAsString('outside');
    final destinationParent = Directory(
      path.join(archiveDir.path, suppliedHash.substring(0, 2)),
    );
    await destinationParent.create(recursive: true);
    final destinationLink = Link(
      path.join(destinationParent.path, '$suppliedHash.png'),
    );
    await destinationLink.create(outsideFile.path);

    await expectLater(
      store.writeArchiveEntry(
        archiveDirectoryPath: archiveDir.path,
        sourcePath: sourceFile.path,
        archiveKey: _archiveKey(),
        sha256Hex: suppliedHash,
        validateMutation: _acceptMutationBoundary,
      ),
      throwsStateError,
    );
    expect(outsideFile.readAsStringSync(), 'outside');
  });

  test('computes canonical hash when supplied hash is unusable', () async {
    final sourceFile = File(path.join(tempDir.path, 'photo.heic'));
    await sourceFile.writeAsString('image bytes');

    final write = await store.writeArchiveEntry(
      archiveDirectoryPath: archiveDir.path,
      sourcePath: sourceFile.path,
      archiveKey: _archiveKey(),
      sha256Hex: 'a',
      validateMutation: _acceptMutationBoundary,
    );

    expect(write, isNotNull);
    final expectedHash = sha256
        .convert(await sourceFile.readAsBytes())
        .toString();
    expect(
      write!.relativePath,
      '${expectedHash.substring(0, 2)}/$expectedHash.heic',
    );
    expect(write.contentHash, expectedHash);
    expect(
      File(
        path.join(
          archiveDir.path,
          expectedHash.substring(0, 2),
          '$expectedHash.heic',
        ),
      ).existsSync(),
      isTrue,
    );
  });

  test(
    'lease loss before source read or after hash prevents installation',
    () async {
      final sourceFile = File(path.join(tempDir.path, 'source.bin'));
      await sourceFile.writeAsString('source payload');
      for (final deniedBoundary in <AttachmentArchiveMutationBoundary>[
        AttachmentArchiveMutationBoundary.beforeSourceRead,
        AttachmentArchiveMutationBoundary.afterSourceHash,
      ]) {
        await expectLater(
          store.writeArchiveEntry(
            archiveDirectoryPath: archiveDir.path,
            sourcePath: sourceFile.path,
            archiveKey: _archiveKey(),
            sha256Hex: null,
            validateMutation: (boundary) async {
              if (boundary == deniedBoundary) {
                throw AttachmentArchiveMutationDeferredException(
                  reason:
                      AttachmentArchiveMutationDeferredReason.staleGeneration,
                  boundary: boundary,
                );
              }
            },
          ),
          throwsA(isA<AttachmentArchiveMutationDeferredException>()),
        );
        if (archiveDir.existsSync()) {
          expect(
            archiveDir.listSync(recursive: true).whereType<File>(),
            isEmpty,
          );
        }
      }
    },
  );

  group('preservation-safe installation', () {
    test(
      'lease loss at pre-install boundaries exposes no final payload',
      () async {
        final bytes = 'boundary payload'.codeUnits;
        final expectedHash = sha256.convert(bytes).toString();
        for (final deniedBoundary in <AttachmentArchiveMutationBoundary>[
          AttachmentArchiveMutationBoundary.beforeRootCreation,
          AttachmentArchiveMutationBoundary.beforeTemporaryCopy,
          AttachmentArchiveMutationBoundary.beforePayloadVerification,
          AttachmentArchiveMutationBoundary.beforeFinalInstall,
        ]) {
          if (archiveDir.existsSync()) {
            await archiveDir.delete(recursive: true);
          }

          await expectLater(
            store.installVerifiedArchiveEntry(
              archiveDirectoryPath: archiveDir.path,
              sourceBytes: Stream<List<int>>.value(bytes),
              sourceExtension: '.bin',
              expectedSizeBytes: bytes.length,
              expectedSha256: expectedHash,
              validateMutation: (boundary) async {
                if (boundary == deniedBoundary) {
                  throw AttachmentArchiveMutationDeferredException(
                    reason:
                        AttachmentArchiveMutationDeferredReason.staleGeneration,
                    boundary: boundary,
                  );
                }
              },
            ),
            throwsA(isA<AttachmentArchiveMutationDeferredException>()),
          );

          final destination = File(
            path.join(
              archiveDir.path,
              expectedHash.substring(0, 2),
              '$expectedHash.bin',
            ),
          );
          expect(destination.existsSync(), isFalse);
          if (archiveDir.existsSync()) {
            expect(
              archiveDir
                  .listSync(recursive: true)
                  .where(
                    (entity) => entity.path.contains('.messagelens-install-'),
                  ),
              isEmpty,
            );
          }
        }
      },
    );

    test('lease loss during copy removes the temporary payload', () async {
      final bytes = 'boundary payload'.codeUnits;
      final expectedHash = sha256.convert(bytes).toString();
      const copyFailure = AttachmentArchiveMutationDeferredException(
        reason: AttachmentArchiveMutationDeferredReason.staleGeneration,
        boundary: AttachmentArchiveMutationBoundary.beforePayloadVerification,
      );

      await expectLater(
        store.installVerifiedArchiveEntry(
          archiveDirectoryPath: archiveDir.path,
          sourceBytes: Stream<List<int>>.error(copyFailure),
          sourceExtension: '.bin',
          expectedSizeBytes: bytes.length,
          expectedSha256: expectedHash,
          validateMutation: _acceptMutationBoundary,
        ),
        throwsA(same(copyFailure)),
      );

      expect(archiveDir.listSync(recursive: true).whereType<File>(), isEmpty);
    });

    test(
      'post-install lease loss leaves only an unclaimed safe orphan',
      () async {
        final bytes = 'installed before disconnect'.codeUnits;
        final expectedHash = sha256.convert(bytes).toString();

        await expectLater(
          store.installVerifiedArchiveEntry(
            archiveDirectoryPath: archiveDir.path,
            sourceBytes: Stream<List<int>>.value(bytes),
            sourceExtension: '.bin',
            expectedSizeBytes: bytes.length,
            expectedSha256: expectedHash,
            validateMutation: (boundary) async {
              if (boundary ==
                  AttachmentArchiveMutationBoundary.afterFinalInstall) {
                throw AttachmentArchiveMutationDeferredException(
                  reason:
                      AttachmentArchiveMutationDeferredReason.staleGeneration,
                  boundary: boundary,
                );
              }
            },
          ),
          throwsA(isA<AttachmentArchiveMutationDeferredException>()),
        );

        expect(
          File(
            path.join(
              archiveDir.path,
              expectedHash.substring(0, 2),
              '$expectedHash.bin',
            ),
          ).readAsBytesSync(),
          bytes,
        );
      },
    );

    test(
      'installs atomically and removes its recognizable temp file',
      () async {
        final bytes = 'verified donor payload'.codeUnits;
        final expectedHash = sha256.convert(bytes).toString();

        final result = await store.installVerifiedArchiveEntry(
          archiveDirectoryPath: archiveDir.path,
          sourceBytes: Stream<List<int>>.value(bytes),
          sourceExtension: '.bin',
          expectedSizeBytes: bytes.length,
          expectedSha256: expectedHash,
          validateMutation: _acceptMutationBoundary,
        );

        expect(result.status, AttachmentArchiveFileInstallStatus.installed);
        expect(
          File(
            path.join(archiveDir.path, result.relativePath),
          ).readAsBytesSync(),
          bytes,
        );
        expect(
          archiveDir
              .listSync(recursive: true)
              .where((entity) => entity.path.contains('.messagelens-install-')),
          isEmpty,
        );
      },
    );

    test('verification mismatch leaves no final or temporary file', () async {
      final bytes = 'changed donor payload'.codeUnits;
      final expectedHash = sha256.convert('expected'.codeUnits).toString();

      final result = await store.installVerifiedArchiveEntry(
        archiveDirectoryPath: archiveDir.path,
        sourceBytes: Stream<List<int>>.value(bytes),
        sourceExtension: '.bin',
        expectedSizeBytes: bytes.length,
        expectedSha256: expectedHash,
        validateMutation: _acceptMutationBoundary,
      );

      expect(result.status, AttachmentArchiveFileInstallStatus.donorChanged);
      expect(
        File(
          path.join(
            archiveDir.path,
            expectedHash.substring(0, 2),
            '$expectedHash.bin',
          ),
        ).existsSync(),
        isFalse,
      );
      expect(
        archiveDir
            .listSync(recursive: true)
            .where((entity) => entity.path.contains('.messagelens-install-')),
        isEmpty,
      );
    });

    test('copy failure cleans temp and exposes no final file', () async {
      final expectedHash = sha256.convert('expected'.codeUnits).toString();
      final failingStream = Stream<List<int>>.error(
        const FileSystemException('donor disappeared'),
      );

      await expectLater(
        store.installVerifiedArchiveEntry(
          archiveDirectoryPath: archiveDir.path,
          sourceBytes: failingStream,
          sourceExtension: '.bin',
          expectedSizeBytes: 8,
          expectedSha256: expectedHash,
          validateMutation: _acceptMutationBoundary,
        ),
        throwsA(isA<FileSystemException>()),
      );

      expect(archiveDir.listSync(recursive: true).whereType<File>(), isEmpty);
    });

    test('identical retry is already present and does not rewrite', () async {
      final bytes = 'stable payload'.codeUnits;
      final expectedHash = sha256.convert(bytes).toString();
      final first = await store.installVerifiedArchiveEntry(
        archiveDirectoryPath: archiveDir.path,
        sourceBytes: Stream<List<int>>.value(bytes),
        sourceExtension: '.pdf',
        expectedSizeBytes: bytes.length,
        expectedSha256: expectedHash,
        validateMutation: _acceptMutationBoundary,
      );
      final destination = File(path.join(archiveDir.path, first.relativePath));
      final firstModified = destination.lastModifiedSync();

      final second = await store.installVerifiedArchiveEntry(
        archiveDirectoryPath: archiveDir.path,
        sourceBytes: Stream<List<int>>.value(bytes),
        sourceExtension: '.pdf',
        expectedSizeBytes: bytes.length,
        expectedSha256: expectedHash,
        validateMutation: _acceptMutationBoundary,
      );

      expect(second.status, AttachmentArchiveFileInstallStatus.alreadyPresent);
      expect(destination.lastModifiedSync(), firstModified);
      expect(destination.readAsBytesSync(), bytes);
    });

    test('conflicting existing destination is never overwritten', () async {
      final bytes = 'expected payload'.codeUnits;
      final expectedHash = sha256.convert(bytes).toString();
      final destination = File(
        path.join(
          archiveDir.path,
          expectedHash.substring(0, 2),
          '$expectedHash.bin',
        ),
      );
      await destination.parent.create(recursive: true);
      await destination.writeAsString('conflict');

      final result = await store.installVerifiedArchiveEntry(
        archiveDirectoryPath: archiveDir.path,
        sourceBytes: Stream<List<int>>.value(bytes),
        sourceExtension: '.bin',
        expectedSizeBytes: bytes.length,
        expectedSha256: expectedHash,
        validateMutation: _acceptMutationBoundary,
      );

      expect(result.status, AttachmentArchiveFileInstallStatus.conflict);
      expect(destination.readAsStringSync(), 'conflict');
    });

    test('concurrent destination creation wins without overwrite', () async {
      final bytes = 'expected payload'.codeUnits;
      final expectedHash = sha256.convert(bytes).toString();
      const racingStore = FilesystemAttachmentArchiveFileStore(
        atomicInstaller: _RacingAtomicInstaller('concurrent payload'),
      );

      final result = await racingStore.installVerifiedArchiveEntry(
        archiveDirectoryPath: archiveDir.path,
        sourceBytes: Stream<List<int>>.value(bytes),
        sourceExtension: '.bin',
        expectedSizeBytes: bytes.length,
        expectedSha256: expectedHash,
        validateMutation: _acceptMutationBoundary,
      );

      expect(result.status, AttachmentArchiveFileInstallStatus.conflict);
      expect(
        File(
          path.join(archiveDir.path, result.relativePath),
        ).readAsStringSync(),
        'concurrent payload',
      );
    });
  });

  test('checks archive integrity using stored hash', () async {
    final archiveFile = File(path.join(archiveDir.path, 'ab/photo.jpg'));
    await archiveFile.parent.create(recursive: true);
    await archiveFile.writeAsString('image bytes');
    final expectedHash = sha256
        .convert(await archiveFile.readAsBytes())
        .toString();

    final matching = await store.checkIntegrity(
      archiveDirectoryPath: archiveDir.path,
      relativePath: 'ab/photo.jpg',
      storedHash: expectedHash,
    );
    final mismatching = await store.checkIntegrity(
      archiveDirectoryPath: archiveDir.path,
      relativePath: 'ab/photo.jpg',
      storedHash: 'not-the-hash',
    );
    final missing = await store.checkIntegrity(
      archiveDirectoryPath: archiveDir.path,
      relativePath: 'missing.jpg',
      storedHash: expectedHash,
    );
    final unchecked = await store.checkIntegrity(
      archiveDirectoryPath: archiveDir.path,
      relativePath: 'ab/photo.jpg',
      storedHash: null,
    );

    expect(matching.fileExists, isTrue);
    expect(matching.hashMatches, isTrue);
    expect(matching.actualHash, expectedHash);
    expect(mismatching.fileExists, isTrue);
    expect(mismatching.hashMatches, isFalse);
    expect(mismatching.actualHash, expectedHash);
    expect(missing.fileExists, isFalse);
    expect(missing.hashMatches, isNull);
    expect(missing.actualHash, isNull);
    expect(unchecked.fileExists, isTrue);
    expect(unchecked.hashMatches, isNull);
    expect(unchecked.actualHash, isNull);
  });

  test('integrity check does not read paths outside archive root', () async {
    final outsideFile = File(path.join(tempDir.path, 'outside.jpg'));
    await outsideFile.writeAsString('outside image');
    final outsideHash = sha256
        .convert(await outsideFile.readAsBytes())
        .toString();

    final result = await store.checkIntegrity(
      archiveDirectoryPath: archiveDir.path,
      relativePath: '../outside.jpg',
      storedHash: outsideHash,
    );

    expect(result.fileExists, isFalse);
    expect(result.hashMatches, isNull);
    expect(result.actualHash, isNull);
  });
}

Future<void> _acceptMutationBoundary(
  AttachmentArchiveMutationBoundary boundary,
) async {}

class _RacingAtomicInstaller implements AtomicNoOverwriteFileInstaller {
  const _RacingAtomicInstaller(this.concurrentContents);

  final String concurrentContents;

  @override
  Future<AtomicFileInstallResult> install({
    required String temporaryPath,
    required String destinationPath,
  }) async {
    expect(File(destinationPath).existsSync(), isFalse);
    await File(destinationPath).writeAsString(concurrentContents);
    return AtomicFileInstallResult.destinationExists;
  }
}

ArchiveCompatibilityKey _archiveKey() {
  return const ArchiveCompatibilityKey(
    messageGuid: 'message-guid',
    importAttachmentId: 200,
  );
}
