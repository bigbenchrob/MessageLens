import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../application/atomic_no_overwrite_file_installer.dart';
import '../../application/attachment_archive_relocation_file_system.dart';
import '../../application/attachment_archive_relocation_metadata_reader.dart';
import '../../domain/entities/attachment_archive_relocation.dart';
import 'darwin_atomic_no_overwrite_file_installer.dart';
import 'darwin_exclusive_directory_finalizer.dart';

final class FilesystemAttachmentArchiveRelocationFileSystem
    implements AttachmentArchiveRelocationFileSystem {
  const FilesystemAttachmentArchiveRelocationFileSystem({
    required AttachmentArchiveDestinationCapacityReader capacityReader,
    AtomicNoOverwriteFileInstaller atomicInstaller =
        const DarwinAtomicNoOverwriteFileInstaller(),
    AttachmentArchiveExclusiveDirectoryFinalizer directoryFinalizer =
        const DarwinExclusiveDirectoryFinalizer(),
  }) : _capacityReader = capacityReader,
       _atomicInstaller = atomicInstaller,
       _directoryFinalizer = directoryFinalizer;

  static const int _copyChunkBytes = 1024 * 1024;
  static const int _metadataPageSize = 500;
  static const Uuid _uuid = Uuid();

  final AttachmentArchiveDestinationCapacityReader _capacityReader;
  final AtomicNoOverwriteFileInstaller _atomicInstaller;
  final AttachmentArchiveExclusiveDirectoryFinalizer _directoryFinalizer;

  @override
  Future<AttachmentArchiveRelocationPreflightResult> preflight({
    required String sourceRootPath,
    required String destinationParentPath,
    required String stagingDirectoryName,
    required String finalDirectoryName,
    required bool resumeStartedPreflight,
  }) async {
    final String sourceRoot;
    try {
      sourceRoot = await _canonicalExistingDirectory(
        sourceRootPath,
        label: 'source archive',
        requireWritable: false,
      );
    } on Object {
      throw AttachmentArchiveRelocationPreflightException(
        reason: AttachmentArchiveRelocationDeferredReason.sourceUnavailable,
        message: 'The current attachment archive is unavailable.',
        path: sourceRootPath,
      );
    }
    final String destinationParent;
    try {
      destinationParent = await _canonicalExistingDirectory(
        destinationParentPath,
        label: 'destination parent',
        requireWritable: true,
      );
    } on FileSystemException catch (error) {
      throw AttachmentArchiveRelocationPreflightException(
        reason:
            FileSystemEntity.typeSync(
                  destinationParentPath,
                  followLinks: false,
                ) ==
                FileSystemEntityType.directory
            ? AttachmentArchiveRelocationDeferredReason.destinationReadOnly
            : AttachmentArchiveRelocationDeferredReason.destinationUnavailable,
        message: error.message,
        path: destinationParentPath,
      );
    } on Object catch (error) {
      throw AttachmentArchiveRelocationPreflightException(
        reason: AttachmentArchiveRelocationDeferredReason.unsafeLocation,
        message: error.toString(),
        path: destinationParentPath,
      );
    }
    if (sourceRoot == destinationParent ||
        path.isWithin(sourceRoot, destinationParent) ||
        path.isWithin(destinationParent, sourceRoot)) {
      throw AttachmentArchiveRelocationPreflightException(
        reason: AttachmentArchiveRelocationDeferredReason.unsafeLocation,
        message:
            'The destination must not be the source archive or nested inside it.',
        path: destinationParent,
      );
    }

    final stagingRoot = _safeManagedChild(
      destinationParent,
      stagingDirectoryName,
    );
    final finalRoot = _safeManagedChild(destinationParent, finalDirectoryName);
    final stagingType = FileSystemEntity.typeSync(
      stagingRoot,
      followLinks: false,
    );
    if (stagingType != FileSystemEntityType.notFound) {
      if (!resumeStartedPreflight ||
          stagingType != FileSystemEntityType.directory) {
        throw AttachmentArchiveRelocationPreflightException(
          reason:
              AttachmentArchiveRelocationDeferredReason.conflictingDestination,
          message:
              'A conflicting MessageLens relocation staging directory already exists.',
          path: stagingRoot,
        );
      }
      await _cleanInterruptedProbeArtifacts(stagingRoot);
      if (!await Directory(stagingRoot).list(followLinks: false).isEmpty) {
        throw AttachmentArchiveRelocationPreflightException(
          reason:
              AttachmentArchiveRelocationDeferredReason.conflictingDestination,
          message:
              'The existing relocation staging directory contains unclassified data.',
          path: stagingRoot,
        );
      }
    }
    if (FileSystemEntity.typeSync(finalRoot, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw AttachmentArchiveRelocationPreflightException(
        reason:
            AttachmentArchiveRelocationDeferredReason.conflictingDestination,
        message: 'A conflicting managed attachment archive already exists.',
        path: finalRoot,
      );
    }

    try {
      if (stagingType == FileSystemEntityType.notFound) {
        await Directory(stagingRoot).create();
      }
    } on FileSystemException catch (error) {
      throw AttachmentArchiveRelocationPreflightException(
        reason: AttachmentArchiveRelocationDeferredReason.destinationReadOnly,
        message: error.message,
        path: destinationParent,
      );
    }
    try {
      await _probeRequiredSemantics(stagingRoot);
    } on Object catch (error) {
      throw AttachmentArchiveRelocationPreflightException(
        reason: AttachmentArchiveRelocationDeferredReason.unsupportedFilesystem,
        message:
            'The destination filesystem does not support the safe file operations required by MessageLens: $error',
        path: destinationParent,
      );
    }
    final int availableCapacity;
    try {
      availableCapacity = await _capacityReader
          .availableCapacityForImportantUsage(destinationParent);
    } on Object catch (error) {
      throw AttachmentArchiveRelocationPreflightException(
        reason:
            AttachmentArchiveRelocationDeferredReason.destinationUnavailable,
        message: 'Destination capacity could not be read: $error',
        path: destinationParent,
      );
    }
    if (availableCapacity < 0) {
      throw AttachmentArchiveRelocationPreflightException(
        reason:
            AttachmentArchiveRelocationDeferredReason.destinationUnavailable,
        message: 'Destination capacity is unavailable.',
        path: destinationParent,
      );
    }
    return AttachmentArchiveRelocationPreflightResult(
      availableCapacityBytes: availableCapacity,
    );
  }

  @override
  Future<AttachmentArchiveRelocationInventoryResult> inventory({
    required String sourceRootPath,
    required AttachmentArchiveRelocationMetadataReader metadataReader,
    required Future<void> Function(
      AttachmentArchiveRelocationManifestEntry entry,
    )
    onEntry,
  }) async {
    final sourceRoot = await _canonicalExistingDirectory(
      sourceRootPath,
      label: 'source archive',
      requireWritable: false,
    );
    var fileCount = 0;
    var byteCount = 0;
    var metadataRowCount = 0;
    var unreferencedFileCount = 0;
    var operationalDebrisCount = 0;

    await for (final entity in Directory(
      sourceRoot,
    ).list(recursive: true, followLinks: false)) {
      final type = FileSystemEntity.typeSync(entity.path, followLinks: false);
      if (type == FileSystemEntityType.link) {
        throw StateError(
          'Attachment relocation cannot classify symbolic link: ${entity.path}',
        );
      }
      if (type == FileSystemEntityType.directory) {
        continue;
      }
      if (type != FileSystemEntityType.file) {
        throw StateError(
          'Attachment relocation cannot classify filesystem entry: '
          '${entity.path}',
        );
      }
      final relativePath = _safeRelativePath(
        sourceRoot: sourceRoot,
        entityPath: entity.path,
      );
      if (_isInstallerTemporaryArtifact(relativePath)) {
        operationalDebrisCount++;
        continue;
      }

      final file = File(entity.path);
      final size = await file.length();
      final metadata = await metadataReader.readByRelativePath(relativePath);
      if (metadata != null && metadata.fileSizeBytes != size) {
        throw StateError(
          'Attachment metadata size does not match source payload: '
          '$relativePath',
        );
      }
      if (metadata == null && !_isCanonicalUnreferencedPayload(relativePath)) {
        throw StateError(
          'Unreferenced source entry is not a classifiable preservation '
          'payload: $relativePath',
        );
      }

      final entry = AttachmentArchiveRelocationManifestEntry(
        relativePath: relativePath,
        sizeBytes: size,
        kind: metadata == null
            ? AttachmentArchiveRelocationEntryKind
                  .unreferencedPreservationPayload
            : AttachmentArchiveRelocationEntryKind.metadataKnown,
        knownSha256: metadata?.contentHash,
        metadataRowCount: metadata?.rowCount ?? 0,
      );
      await onEntry(entry);
      fileCount++;
      byteCount += size;
      metadataRowCount += entry.metadataRowCount;
      if (metadata == null) {
        unreferencedFileCount++;
      }
    }

    return AttachmentArchiveRelocationInventoryResult(
      fileCount: fileCount,
      byteCount: byteCount,
      metadataRowCount: metadataRowCount,
      unreferencedFileCount: unreferencedFileCount,
      operationalDebrisCount: operationalDebrisCount,
    );
  }

  @override
  Future<void> verifyMetadataCoverage({
    required String sourceRootPath,
    required AttachmentArchiveRelocationMetadataReader metadataReader,
  }) async {
    final sourceRoot = await _canonicalExistingDirectory(
      sourceRootPath,
      label: 'source archive',
      requireWritable: false,
    );
    String? afterRelativePath;
    while (true) {
      final page = await metadataReader.readPage(
        afterRelativePath: afterRelativePath,
        limit: _metadataPageSize,
      );
      for (final metadata in page.entries) {
        final relativePath = _validateRelativePath(metadata.relativePath);
        final filePath = path.join(sourceRoot, relativePath);
        _requireNoSymlinkComponents(sourceRoot, relativePath);
        if (FileSystemEntity.typeSync(filePath, followLinks: false) !=
            FileSystemEntityType.file) {
          throw StateError(
            'Attachment metadata references a missing or non-regular payload: '
            '$relativePath',
          );
        }
        if (await File(filePath).length() != metadata.fileSizeBytes) {
          throw StateError(
            'Attachment metadata size does not match payload: $relativePath',
          );
        }
      }
      if (page.entries.isEmpty || !page.hasMore) {
        return;
      }
      afterRelativePath = page.entries.last.relativePath;
    }
  }

  @override
  Future<AttachmentArchiveRelocationCopyReceipt> copyAndVerify({
    required int index,
    required AttachmentArchiveRelocationManifestEntry entry,
    required String sourceRootPath,
    required String stagingRootPath,
  }) async {
    final relativePath = _validateRelativePath(entry.relativePath);
    _requireNoSymlinkComponents(sourceRootPath, relativePath);
    _requireNoSymlinkComponents(stagingRootPath, relativePath);
    final sourceFile = File(path.join(sourceRootPath, relativePath));
    if (FileSystemEntity.typeSync(sourceFile.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw FileSystemException(
        'Relocation source payload is unavailable.',
        sourceFile.path,
      );
    }
    if (await sourceFile.length() != entry.sizeBytes) {
      throw StateError('Relocation source payload changed: $relativePath');
    }
    final sourceHash = await _hash(sourceFile);
    if (entry.knownSha256 != null && sourceHash != entry.knownSha256) {
      throw StateError('Relocation source hash mismatch: $relativePath');
    }

    final destinationFile = File(path.join(stagingRootPath, relativePath));
    await destinationFile.parent.create(recursive: true);
    _requireNoSymlinkComponents(stagingRootPath, relativePath);
    await _cleanInterruptedCopyArtifacts(destinationFile);
    final existingType = FileSystemEntity.typeSync(
      destinationFile.path,
      followLinks: false,
    );
    if (existingType != FileSystemEntityType.notFound) {
      if (existingType != FileSystemEntityType.file ||
          await destinationFile.length() != entry.sizeBytes ||
          await _hash(destinationFile) != sourceHash) {
        throw StateError(
          'Relocation destination contains a conflicting partial payload: '
          '$relativePath',
        );
      }
      return AttachmentArchiveRelocationCopyReceipt(
        index: index,
        relativePath: relativePath,
        sizeBytes: entry.sizeBytes,
        sha256: sourceHash,
      );
    }

    final temporaryFile = File(
      path.join(
        destinationFile.parent.path,
        '.${path.basename(destinationFile.path)}'
        '.messagelens-relocation-${_uuid.v4()}.tmp',
      ),
    );
    await temporaryFile.create(exclusive: true);
    try {
      await _copyStreaming(sourceFile, temporaryFile);
      if (await temporaryFile.length() != entry.sizeBytes ||
          await _hash(temporaryFile) != sourceHash) {
        throw StateError(
          'Relocation temporary payload verification failed: $relativePath',
        );
      }
      final install = await _atomicInstaller.install(
        temporaryPath: temporaryFile.path,
        destinationPath: destinationFile.path,
      );
      if (install == AtomicFileInstallResult.destinationExists &&
          (FileSystemEntity.typeSync(
                    destinationFile.path,
                    followLinks: false,
                  ) !=
                  FileSystemEntityType.file ||
              await destinationFile.length() != entry.sizeBytes ||
              await _hash(destinationFile) != sourceHash)) {
        throw StateError(
          'Relocation destination raced with conflicting contents: '
          '$relativePath',
        );
      }
      if (await destinationFile.length() != entry.sizeBytes ||
          await _hash(destinationFile) != sourceHash) {
        throw StateError(
          'Relocation installed payload verification failed: $relativePath',
        );
      }
      return AttachmentArchiveRelocationCopyReceipt(
        index: index,
        relativePath: relativePath,
        sizeBytes: entry.sizeBytes,
        sha256: sourceHash,
      );
    } finally {
      if (temporaryFile.existsSync()) {
        await temporaryFile.delete();
      }
    }
  }

  @override
  Future<void> verifyDestinationCoverage({
    required String destinationRootPath,
    required int expectedFileCount,
    required int expectedByteCount,
  }) async {
    final destinationRoot = await _canonicalExistingDirectory(
      destinationRootPath,
      label: 'relocation destination archive',
      requireWritable: false,
    );
    var fileCount = 0;
    var byteCount = 0;
    await for (final entity in Directory(
      destinationRoot,
    ).list(recursive: true, followLinks: false)) {
      final type = FileSystemEntity.typeSync(entity.path, followLinks: false);
      if (type == FileSystemEntityType.directory) {
        continue;
      }
      if (type != FileSystemEntityType.file) {
        throw StateError(
          'Relocation destination contains a non-regular entry: '
          '${entity.path}',
        );
      }
      fileCount++;
      byteCount += await File(entity.path).length();
    }
    if (fileCount != expectedFileCount || byteCount != expectedByteCount) {
      throw StateError(
        'Relocation destination physical coverage does not match the '
        'verified manifest.',
      );
    }
  }

  @override
  Future<void> verifyReceipt({
    required AttachmentArchiveRelocationManifestEntry entry,
    required AttachmentArchiveRelocationCopyReceipt receipt,
    required String sourceRootPath,
    required String destinationRootPath,
  }) async {
    if (receipt.relativePath != entry.relativePath ||
        receipt.sizeBytes != entry.sizeBytes) {
      throw StateError('Relocation receipt does not match its manifest entry.');
    }
    final relativePath = _validateRelativePath(entry.relativePath);
    _requireNoSymlinkComponents(sourceRootPath, relativePath);
    _requireNoSymlinkComponents(destinationRootPath, relativePath);
    final sourceFile = File(path.join(sourceRootPath, relativePath));
    final destinationFile = File(path.join(destinationRootPath, relativePath));
    if (FileSystemEntity.typeSync(sourceFile.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw FileSystemException(
        'Relocation verification source payload is unavailable.',
        sourceFile.path,
      );
    }
    if (FileSystemEntity.typeSync(destinationFile.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw FileSystemException(
        'Relocation verification destination payload is unavailable.',
        destinationFile.path,
      );
    }
    if (await sourceFile.length() != entry.sizeBytes ||
        await destinationFile.length() != entry.sizeBytes) {
      throw StateError('Relocation verification size mismatch: $relativePath');
    }
    final sourceHash = await _hash(sourceFile);
    final destinationHash = await _hash(destinationFile);
    if (sourceHash != receipt.sha256 ||
        destinationHash != receipt.sha256 ||
        (entry.knownSha256 != null && sourceHash != entry.knownSha256)) {
      throw StateError('Relocation verification hash mismatch: $relativePath');
    }
  }

  @override
  Future<void> finalizeDestination({
    required String stagingRootPath,
    required String finalRootPath,
  }) {
    return _directoryFinalizer.finalize(
      stagingRootPath: stagingRootPath,
      finalRootPath: finalRootPath,
    );
  }

  Future<void> _probeRequiredSemantics(String stagingRoot) async {
    final probeDirectory = Directory(
      path.join(stagingRoot, '.messagelens-relocation-probe-${_uuid.v4()}'),
    );
    await probeDirectory.create();
    try {
      final temporary = File(path.join(probeDirectory.path, 'payload.tmp'));
      await temporary.create(exclusive: true);
      final handle = await temporary.open(mode: FileMode.write);
      try {
        await handle.writeFrom(<int>[1, 3, 3, 7]);
        await handle.flush();
      } finally {
        await handle.close();
      }
      final installed = path.join(probeDirectory.path, 'payload.final');
      final firstInstall = await _atomicInstaller.install(
        temporaryPath: temporary.path,
        destinationPath: installed,
      );
      final secondInstall = await _atomicInstaller.install(
        temporaryPath: temporary.path,
        destinationPath: installed,
      );
      final installedBytes = await File(installed).readAsBytes();
      if (firstInstall != AtomicFileInstallResult.installed ||
          secondInstall != AtomicFileInstallResult.destinationExists ||
          installedBytes.length != 4 ||
          installedBytes[0] != 1 ||
          installedBytes[1] != 3 ||
          installedBytes[2] != 3 ||
          installedBytes[3] != 7) {
        throw StateError(
          'Destination does not provide atomic no-overwrite link semantics.',
        );
      }

      final renameSource = Directory(
        path.join(probeDirectory.path, 'rename-source'),
      );
      final renameDestination = path.join(
        probeDirectory.path,
        'rename-destination',
      );
      await renameSource.create();
      await _directoryFinalizer.finalize(
        stagingRootPath: renameSource.path,
        finalRootPath: renameDestination,
      );
      if (!Directory(renameDestination).existsSync()) {
        throw StateError(
          'Destination does not provide exclusive rename finalization.',
        );
      }
    } finally {
      if (probeDirectory.existsSync()) {
        await probeDirectory.delete(recursive: true);
      }
    }
  }

  static Future<void> _cleanInterruptedProbeArtifacts(
    String stagingRoot,
  ) async {
    await for (final entity in Directory(
      stagingRoot,
    ).list(followLinks: false)) {
      if (entity is Directory &&
          path
              .basename(entity.path)
              .startsWith('.messagelens-relocation-probe-')) {
        await entity.delete(recursive: true);
      }
    }
  }

  static Future<void> _cleanInterruptedCopyArtifacts(
    File destinationFile,
  ) async {
    final prefix =
        '.${path.basename(destinationFile.path)}'
        '.messagelens-relocation-';
    await for (final entity in destinationFile.parent.list(
      followLinks: false,
    )) {
      if (entity is File) {
        final basename = path.basename(entity.path);
        if (basename.startsWith(prefix) && basename.endsWith('.tmp')) {
          await entity.delete();
        }
      }
    }
  }

  static Future<String> _canonicalExistingDirectory(
    String directoryPath, {
    required String label,
    required bool requireWritable,
  }) async {
    if (!path.isAbsolute(directoryPath)) {
      throw StateError('The $label path must be absolute.');
    }
    final type = FileSystemEntity.typeSync(directoryPath, followLinks: false);
    if (type == FileSystemEntityType.link) {
      throw StateError('The $label must not be a symbolic link.');
    }
    if (type == FileSystemEntityType.notFound) {
      throw FileSystemException('The $label is unavailable.', directoryPath);
    }
    if (type != FileSystemEntityType.directory) {
      throw StateError('The $label must be an existing directory.');
    }
    if (requireWritable) {
      final probe = File(
        path.join(directoryPath, '.messagelens-write-probe-${_uuid.v4()}'),
      );
      try {
        await probe.create(exclusive: true);
      } finally {
        if (probe.existsSync()) {
          await probe.delete();
        }
      }
    }
    return path.normalize(
      await Directory(directoryPath).resolveSymbolicLinks(),
    );
  }

  static String _safeManagedChild(String parentPath, String childName) {
    if (childName.isEmpty ||
        childName == '.' ||
        childName == '..' ||
        path.isAbsolute(childName) ||
        path.basename(childName) != childName) {
      throw ArgumentError.value(
        childName,
        'childName',
        'Unsafe managed child.',
      );
    }
    final child = path.normalize(path.join(parentPath, childName));
    if (!path.isWithin(parentPath, child)) {
      throw StateError('Managed relocation child escapes destination parent.');
    }
    return child;
  }

  static String _safeRelativePath({
    required String sourceRoot,
    required String entityPath,
  }) {
    final relativePath = path.relative(entityPath, from: sourceRoot);
    return _validateRelativePath(relativePath);
  }

  static String _validateRelativePath(String relativePath) {
    if (relativePath.isEmpty || path.isAbsolute(relativePath)) {
      throw StateError('Attachment relocation path is not relative.');
    }
    final normalized = path.normalize(relativePath);
    if (normalized == '.' ||
        normalized == '..' ||
        normalized.startsWith('../')) {
      throw StateError('Attachment relocation path escapes its root.');
    }
    return normalized;
  }

  static void _requireNoSymlinkComponents(
    String rootPath,
    String relativePath,
  ) {
    var current = path.normalize(rootPath);
    if (FileSystemEntity.typeSync(current, followLinks: false) ==
        FileSystemEntityType.link) {
      throw StateError('Attachment relocation root is a symbolic link.');
    }
    for (final component in path.split(_validateRelativePath(relativePath))) {
      current = path.join(current, component);
      if (FileSystemEntity.typeSync(current, followLinks: false) ==
          FileSystemEntityType.link) {
        throw StateError(
          'Attachment relocation path contains a symbolic link: '
          '$relativePath',
        );
      }
    }
  }

  static bool _isInstallerTemporaryArtifact(String relativePath) {
    return path.basename(relativePath).contains('.messagelens-install-');
  }

  static bool _isCanonicalUnreferencedPayload(String relativePath) {
    final components = path.split(relativePath);
    if (components.length != 2) {
      return false;
    }
    if (components.first == '_by_id') {
      return RegExp(r'^\d+(\.[A-Za-z0-9]{1,16})?$').hasMatch(components.last);
    }
    if (!RegExp(r'^[0-9a-f]{2}$').hasMatch(components.first)) {
      return false;
    }
    return RegExp(
      r'^[0-9a-f]{64}(\.[A-Za-z0-9]{1,16})?$',
    ).hasMatch(components.last);
  }

  static Future<void> _copyStreaming(File source, File destination) async {
    final input = await source.open();
    final output = await destination.open(mode: FileMode.write);
    try {
      while (true) {
        final bytes = await input.read(_copyChunkBytes);
        if (bytes.isEmpty) {
          break;
        }
        await output.writeFrom(bytes);
      }
      await output.flush();
    } finally {
      await input.close();
      await output.close();
    }
  }

  static Future<String> _hash(File file) async {
    return (await sha256.bind(file.openRead()).first).toString();
  }
}
