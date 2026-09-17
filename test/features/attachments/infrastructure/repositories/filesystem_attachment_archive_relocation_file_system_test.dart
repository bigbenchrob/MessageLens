import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/features/attachments/application/atomic_no_overwrite_file_installer.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_relocation_file_system.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_relocation_metadata_reader.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_relocation.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_relocation_file_system.dart';

void main() {
  group('FilesystemAttachmentArchiveRelocationFileSystem', () {
    late Directory root;
    late Directory source;
    late Directory destination;
    late FilesystemAttachmentArchiveRelocationFileSystem fileSystem;

    setUp(() {
      root = Directory.systemTemp.createTempSync('relocation_fs_test_');
      source = Directory('${root.path}/source')..createSync();
      destination = Directory('${root.path}/destination')..createSync();
      fileSystem = const FilesystemAttachmentArchiveRelocationFileSystem(
        capacityReader: _FixedCapacityReader(10 * 1024 * 1024 * 1024),
      );
    });

    tearDown(() async {
      if (root.existsSync()) {
        await root.delete(recursive: true);
      }
    });

    test('preflight proves required semantics in a managed child', () async {
      if (!Platform.isMacOS) {
        return;
      }
      final result = await fileSystem.preflight(
        sourceRootPath: source.path,
        destinationParentPath: destination.path,
        stagingDirectoryName: '.messagelens-attachment-relocation-test',
        finalDirectoryName: 'MessageLens Attachment Archive test',
        resumeStartedPreflight: false,
      );

      expect(result.availableCapacityBytes, 10 * 1024 * 1024 * 1024);
      final staging = Directory(
        '${destination.path}/.messagelens-attachment-relocation-test',
      );
      expect(staging.existsSync(), isTrue);
      expect(staging.listSync(), isEmpty);
    });

    test(
      'preflight rejects equal, nested, symlink, and conflicting roots',
      () async {
        await expectLater(
          fileSystem.preflight(
            sourceRootPath: source.path,
            destinationParentPath: source.path,
            stagingDirectoryName: '.messagelens-attachment-relocation-equal',
            finalDirectoryName: 'MessageLens Attachment Archive equal',
            resumeStartedPreflight: false,
          ),
          throwsStateError,
        );
        final containingDestination = Directory('${root.path}/containing')
          ..createSync();
        final nestedSource = Directory('${containingDestination.path}/source')
          ..createSync();
        await expectLater(
          fileSystem.preflight(
            sourceRootPath: nestedSource.path,
            destinationParentPath: containingDestination.path,
            stagingDirectoryName:
                '.messagelens-attachment-relocation-source-nested',
            finalDirectoryName: 'MessageLens Attachment Archive source nested',
            resumeStartedPreflight: false,
          ),
          throwsStateError,
        );
        final nested = Directory('${source.path}/nested')..createSync();
        await expectLater(
          fileSystem.preflight(
            sourceRootPath: source.path,
            destinationParentPath: nested.path,
            stagingDirectoryName: '.messagelens-attachment-relocation-nested',
            finalDirectoryName: 'MessageLens Attachment Archive nested',
            resumeStartedPreflight: false,
          ),
          throwsStateError,
        );
        final symlink = Link('${root.path}/destination-link')
          ..createSync(destination.path);
        await expectLater(
          fileSystem.preflight(
            sourceRootPath: source.path,
            destinationParentPath: symlink.path,
            stagingDirectoryName: '.messagelens-attachment-relocation-link',
            finalDirectoryName: 'MessageLens Attachment Archive link',
            resumeStartedPreflight: false,
          ),
          throwsStateError,
        );
        Directory(
          '${destination.path}/MessageLens Attachment Archive conflict',
        ).createSync();
        await expectLater(
          fileSystem.preflight(
            sourceRootPath: source.path,
            destinationParentPath: destination.path,
            stagingDirectoryName: '.messagelens-attachment-relocation-conflict',
            finalDirectoryName: 'MessageLens Attachment Archive conflict',
            resumeStartedPreflight: false,
          ),
          throwsA(isA<FileSystemException>()),
        );
      },
    );

    test(
      'preflight fails closed when no-overwrite semantics are weak',
      () async {
        const weakFileSystem = FilesystemAttachmentArchiveRelocationFileSystem(
          capacityReader: _FixedCapacityReader(10 * 1024 * 1024 * 1024),
          atomicInstaller: _WeakOverwriteInstaller(),
          directoryFinalizer: _PortableExclusiveDirectoryFinalizer(),
        );

        await expectLater(
          weakFileSystem.preflight(
            sourceRootPath: source.path,
            destinationParentPath: destination.path,
            stagingDirectoryName: '.messagelens-attachment-relocation-weak',
            finalDirectoryName: 'MessageLens Attachment Archive weak',
            resumeStartedPreflight: false,
          ),
          throwsStateError,
        );
      },
    );

    test(
      'inventory preserves known and unreferenced payloads but classifies temp debris',
      () async {
        final knownBytes = <int>[1, 2, 3];
        final knownHash = sha256.convert(knownBytes).toString();
        final unreferencedBytes = <int>[4, 5, 6, 7];
        final unreferencedHash = sha256.convert(unreferencedBytes).toString();
        _write(source, 'aa/$knownHash.bin', knownBytes);
        _write(source, 'bb/$unreferencedHash.bin', unreferencedBytes);
        _write(
          source,
          'aa/.$knownHash.messagelens-install-disposable.tmp',
          <int>[9],
        );
        final reader =
            _MapMetadataReader(<String, AttachmentArchiveRelocationMetadata>{
              'aa/$knownHash.bin': AttachmentArchiveRelocationMetadata(
                relativePath: 'aa/$knownHash.bin',
                fileSizeBytes: knownBytes.length,
                contentHash: knownHash,
                rowCount: 2,
              ),
            });
        final entries = <AttachmentArchiveRelocationManifestEntry>[];

        final result = await fileSystem.inventory(
          sourceRootPath: source.path,
          metadataReader: reader,
          onEntry: (entry) async => entries.add(entry),
        );

        expect(result.fileCount, 2);
        expect(result.byteCount, 7);
        expect(result.metadataRowCount, 2);
        expect(result.unreferencedFileCount, 1);
        expect(result.operationalDebrisCount, 1);
        expect(entries.map((entry) => entry.kind).toSet(), <
          AttachmentArchiveRelocationEntryKind
        >{
          AttachmentArchiveRelocationEntryKind.metadataKnown,
          AttachmentArchiveRelocationEntryKind.unreferencedPreservationPayload,
        });
      },
    );

    test(
      'inventory fails closed on unknown files, symlinks, and metadata mismatch',
      () async {
        _write(source, 'unknown.txt', <int>[1]);
        await expectLater(
          fileSystem.inventory(
            sourceRootPath: source.path,
            metadataReader: const _MapMetadataReader(
              <String, AttachmentArchiveRelocationMetadata>{},
            ),
            onEntry: (_) async {},
          ),
          throwsStateError,
        );
        File('${source.path}/unknown.txt').deleteSync();
        Link('${source.path}/payload-link').createSync('/tmp');
        await expectLater(
          fileSystem.inventory(
            sourceRootPath: source.path,
            metadataReader: const _MapMetadataReader(
              <String, AttachmentArchiveRelocationMetadata>{},
            ),
            onEntry: (_) async {},
          ),
          throwsStateError,
        );
        Link('${source.path}/payload-link').deleteSync();
        _write(source, 'nested/payload.bin', <int>[1, 2]);
        const mismatchReader =
            _MapMetadataReader(<String, AttachmentArchiveRelocationMetadata>{
              'nested/payload.bin': AttachmentArchiveRelocationMetadata(
                relativePath: 'nested/payload.bin',
                fileSizeBytes: 999,
                contentHash: null,
                rowCount: 1,
              ),
            });
        await expectLater(
          fileSystem.inventory(
            sourceRootPath: source.path,
            metadataReader: mismatchReader,
            onEntry: (_) async {},
          ),
          throwsStateError,
        );
      },
    );

    test('copy verifies contents and rejects a same-name conflict', () async {
      if (!Platform.isMacOS) {
        return;
      }
      final bytes = <int>[8, 6, 7, 5, 3, 0, 9];
      final hash = sha256.convert(bytes).toString();
      final relativePath = 'aa/$hash.bin';
      _write(source, relativePath, bytes);
      final staging = Directory('${destination.path}/staging')..createSync();
      final entry = AttachmentArchiveRelocationManifestEntry(
        relativePath: relativePath,
        sizeBytes: bytes.length,
        kind: AttachmentArchiveRelocationEntryKind.metadataKnown,
        knownSha256: hash,
        metadataRowCount: 1,
      );

      final receipt = await fileSystem.copyAndVerify(
        index: 0,
        entry: entry,
        sourceRootPath: source.path,
        stagingRootPath: staging.path,
      );
      final staleTemporary = File(
        '${staging.path}/aa/.${path.basename(relativePath)}'
        '.messagelens-relocation-interrupted.tmp',
      )..writeAsBytesSync(<int>[1], flush: true);
      final repeatedReceipt = await fileSystem.copyAndVerify(
        index: 0,
        entry: entry,
        sourceRootPath: source.path,
        stagingRootPath: staging.path,
      );
      expect(repeatedReceipt.sha256, receipt.sha256);
      expect(staleTemporary.existsSync(), isFalse);
      await fileSystem.verifyReceipt(
        entry: entry,
        receipt: receipt,
        sourceRootPath: source.path,
        destinationRootPath: staging.path,
      );
      File('${staging.path}/$relativePath').writeAsBytesSync(<int>[0]);

      await expectLater(
        fileSystem.copyAndVerify(
          index: 0,
          entry: entry,
          sourceRootPath: source.path,
          stagingRootPath: staging.path,
        ),
        throwsStateError,
      );
    });

    test(
      'verification rejects missing, wrong-size, wrong-hash, and unsafe paths',
      () async {
        if (!Platform.isMacOS) {
          return;
        }
        final bytes = <int>[1, 2, 3, 4];
        final hash = sha256.convert(bytes).toString();
        final relativePath = 'aa/$hash.bin';
        _write(source, relativePath, bytes);
        final staging = Directory('${destination.path}/staging')..createSync();
        final entry = AttachmentArchiveRelocationManifestEntry(
          relativePath: relativePath,
          sizeBytes: bytes.length,
          kind: AttachmentArchiveRelocationEntryKind.metadataKnown,
          knownSha256: hash,
          metadataRowCount: 1,
        );
        final receipt = await fileSystem.copyAndVerify(
          index: 0,
          entry: entry,
          sourceRootPath: source.path,
          stagingRootPath: staging.path,
        );
        final destinationFile = File('${staging.path}/$relativePath');

        destinationFile.writeAsBytesSync(<int>[9], flush: true);
        await expectLater(
          fileSystem.verifyReceipt(
            entry: entry,
            receipt: receipt,
            sourceRootPath: source.path,
            destinationRootPath: staging.path,
          ),
          throwsStateError,
        );

        destinationFile.writeAsBytesSync(<int>[4, 3, 2, 1], flush: true);
        await expectLater(
          fileSystem.verifyReceipt(
            entry: entry,
            receipt: receipt,
            sourceRootPath: source.path,
            destinationRootPath: staging.path,
          ),
          throwsStateError,
        );

        destinationFile.deleteSync();
        await expectLater(
          fileSystem.verifyReceipt(
            entry: entry,
            receipt: receipt,
            sourceRootPath: source.path,
            destinationRootPath: staging.path,
          ),
          throwsA(isA<FileSystemException>()),
        );

        destinationFile.writeAsBytesSync(bytes, flush: true);
        await fileSystem.verifyDestinationCoverage(
          destinationRootPath: staging.path,
          expectedFileCount: 1,
          expectedByteCount: bytes.length,
        );
        File('${staging.path}/extra.bin').writeAsBytesSync(<int>[0]);
        await expectLater(
          fileSystem.verifyDestinationCoverage(
            destinationRootPath: staging.path,
            expectedFileCount: 1,
            expectedByteCount: bytes.length,
          ),
          throwsStateError,
        );

        const unsafeEntry = AttachmentArchiveRelocationManifestEntry(
          relativePath: '../escape.bin',
          sizeBytes: 1,
          kind: AttachmentArchiveRelocationEntryKind.metadataKnown,
          knownSha256: null,
          metadataRowCount: 1,
        );
        await expectLater(
          fileSystem.copyAndVerify(
            index: 1,
            entry: unsafeEntry,
            sourceRootPath: source.path,
            stagingRootPath: staging.path,
          ),
          throwsStateError,
        );
      },
    );
  });
}

final class _WeakOverwriteInstaller implements AtomicNoOverwriteFileInstaller {
  const _WeakOverwriteInstaller();

  @override
  Future<AtomicFileInstallResult> install({
    required String temporaryPath,
    required String destinationPath,
  }) async {
    await File(temporaryPath).copy(destinationPath);
    return AtomicFileInstallResult.installed;
  }
}

final class _PortableExclusiveDirectoryFinalizer
    implements AttachmentArchiveExclusiveDirectoryFinalizer {
  const _PortableExclusiveDirectoryFinalizer();

  @override
  Future<void> finalize({
    required String stagingRootPath,
    required String finalRootPath,
  }) async {
    if (FileSystemEntity.typeSync(finalRootPath, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw FileSystemException('Destination exists.', finalRootPath);
    }
    await Directory(stagingRootPath).rename(finalRootPath);
  }
}

final class _FixedCapacityReader
    implements AttachmentArchiveDestinationCapacityReader {
  const _FixedCapacityReader(this.capacity);

  final int capacity;

  @override
  Future<int> availableCapacityForImportantUsage(String directoryPath) async {
    return capacity;
  }
}

final class _MapMetadataReader
    implements AttachmentArchiveRelocationMetadataReader {
  const _MapMetadataReader(this.entries);

  final Map<String, AttachmentArchiveRelocationMetadata> entries;

  @override
  Future<AttachmentArchiveRelocationMetadata?> readByRelativePath(
    String relativePath,
  ) async {
    return entries[relativePath];
  }

  @override
  Future<AttachmentArchiveRelocationMetadataPage> readPage({
    required String? afterRelativePath,
    required int limit,
  }) async {
    final ordered = entries.values.toList()
      ..sort((left, right) => left.relativePath.compareTo(right.relativePath));
    final selected = ordered
        .where(
          (entry) =>
              afterRelativePath == null ||
              entry.relativePath.compareTo(afterRelativePath) > 0,
        )
        .take(limit + 1)
        .toList();
    return AttachmentArchiveRelocationMetadataPage(
      entries: selected.take(limit).toList(),
      hasMore: selected.length > limit,
    );
  }
}

void _write(Directory root, String relativePath, List<int> bytes) {
  final file = File('${root.path}/$relativePath');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes, flush: true);
}
