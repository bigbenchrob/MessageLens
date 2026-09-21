import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../application/atomic_no_overwrite_file_installer.dart';
import '../../application/attachment_archive_file_store.dart';
import '../../application/attachment_archive_location_provider.dart';
import '../../application/attachment_archive_remediation_authority.dart';
import 'darwin_atomic_no_overwrite_file_installer.dart';

class FilesystemAttachmentArchiveFileStore
    implements AttachmentArchiveFileStore {
  const FilesystemAttachmentArchiveFileStore({
    AtomicNoOverwriteFileInstaller atomicInstaller =
        const DarwinAtomicNoOverwriteFileInstaller(),
  }) : _atomicInstaller = atomicInstaller;

  static const _temporaryMarker = '.messagelens-install-';
  static const _uuid = Uuid();

  final AtomicNoOverwriteFileInstaller _atomicInstaller;

  @override
  String expandHomePath(String rawPath) {
    if (rawPath.startsWith('~/')) {
      final home = Platform.environment['HOME'] ?? '';
      if (home.isNotEmpty) {
        return rawPath.replaceFirst('~', home);
      }
    }
    return rawPath;
  }

  @override
  bool fileExists(String path) {
    return File(path).existsSync();
  }

  @override
  Future<void> ensureArchiveDirectory(
    String archiveDirectoryPath, {
    required Future<void> Function(AttachmentArchiveMutationBoundary boundary)
    validateMutation,
  }) async {
    await validateMutation(
      AttachmentArchiveMutationBoundary.beforeRootCreation,
    );
    if (_isSymlink(archiveDirectoryPath)) {
      throw StateError('Attachment archive directory must not be a symlink.');
    }
    await Directory(archiveDirectoryPath).create(recursive: true);
  }

  @override
  Future<ArchivedAttachmentFileWrite?> writeArchiveEntry({
    required String archiveDirectoryPath,
    required String sourcePath,
    required ArchiveCompatibilityKey archiveKey,
    required String? sha256Hex,
    required Future<void> Function(AttachmentArchiveMutationBoundary boundary)
    validateMutation,
  }) async {
    await validateMutation(AttachmentArchiveMutationBoundary.beforeSourceRead);
    if (_isSymlink(archiveDirectoryPath)) {
      throw StateError('Attachment archive directory must not be a symlink.');
    }

    final sourceFile = File(sourcePath);
    if (!_isRegularFile(sourcePath)) {
      return null;
    }
    final extension = path.extension(sourcePath).toLowerCase();
    try {
      _safeExtension(extension);
    } on ArgumentError {
      return null;
    }

    final computedHash = await _computeSha256(sourceFile);
    if (computedHash == null) {
      return null;
    }
    final suppliedHash = sha256Hex?.trim().toLowerCase();
    final contentHash = _isSha256(suppliedHash) ? suppliedHash! : computedHash;
    if (contentHash != computedHash) {
      return null;
    }
    await validateMutation(AttachmentArchiveMutationBoundary.afterSourceHash);
    final install = await installVerifiedArchiveEntry(
      archiveDirectoryPath: archiveDirectoryPath,
      sourceBytes: sourceFile.openRead(),
      sourceExtension: extension,
      expectedSizeBytes: await sourceFile.length(),
      expectedSha256: contentHash,
      validateMutation: validateMutation,
    );
    if (install.status != AttachmentArchiveFileInstallStatus.installed &&
        install.status != AttachmentArchiveFileInstallStatus.alreadyPresent) {
      return null;
    }

    return ArchivedAttachmentFileWrite(
      sourcePath: sourcePath,
      relativePath: install.relativePath,
      fileSizeBytes: install.fileSizeBytes,
      contentHash: install.contentHash,
    );
  }

  @override
  Future<AttachmentArchiveFileInstall> installVerifiedArchiveEntry({
    required String archiveDirectoryPath,
    required Stream<List<int>> sourceBytes,
    required String sourceExtension,
    required int expectedSizeBytes,
    required String expectedSha256,
    required Future<void> Function(AttachmentArchiveMutationBoundary boundary)
    validateMutation,
  }) async {
    await validateMutation(
      AttachmentArchiveMutationBoundary.beforeRootCreation,
    );
    final normalizedHash = expectedSha256.trim().toLowerCase();
    if (!_isSha256(normalizedHash) || expectedSizeBytes < 0) {
      throw ArgumentError('Verified archive payload evidence is invalid.');
    }
    if (_isSymlink(archiveDirectoryPath)) {
      throw StateError('Attachment archive directory must not be a symlink.');
    }

    await ensureArchiveDirectory(
      archiveDirectoryPath,
      validateMutation: validateMutation,
    );
    final extension = _safeExtension(sourceExtension);
    final relativePath =
        '${normalizedHash.substring(0, 2)}/$normalizedHash$extension';
    return _installVerifiedAtPath(
      archiveDirectoryPath: archiveDirectoryPath,
      relativePath: relativePath,
      sourceBytes: sourceBytes,
      expectedSizeBytes: expectedSizeBytes,
      expectedSha256: normalizedHash,
      validateMutation: validateMutation,
      allowArchiveRootCreation: true,
    );
  }

  @override
  Future<AttachmentArchiveFileInstall> installVerifiedArchiveEntryAtPath({
    required String archiveDirectoryPath,
    required Stream<List<int>> sourceBytes,
    required AttachmentArchiveRemediationAuthority remediationAuthority,
  }) {
    final payload = remediationAuthority.payload;
    return _installVerifiedAtPath(
      archiveDirectoryPath: archiveDirectoryPath,
      relativePath: payload.relativePath,
      sourceBytes: sourceBytes,
      expectedSizeBytes: payload.expectedSizeBytes,
      expectedSha256: payload.expectedSha256,
      validateMutation: (boundary) => remediationAuthority.requireValid(
        candidateRootPath: archiveDirectoryPath,
        boundary: boundary,
      ),
      allowArchiveRootCreation: false,
    );
  }

  Future<AttachmentArchiveFileInstall> _installVerifiedAtPath({
    required String archiveDirectoryPath,
    required String relativePath,
    required Stream<List<int>> sourceBytes,
    required int expectedSizeBytes,
    required String expectedSha256,
    required Future<void> Function(AttachmentArchiveMutationBoundary boundary)
    validateMutation,
    required bool allowArchiveRootCreation,
  }) async {
    await validateMutation(
      AttachmentArchiveMutationBoundary.beforeRootCreation,
    );
    final normalizedHash = expectedSha256.trim().toLowerCase();
    if (!_isSha256(normalizedHash) || expectedSizeBytes < 0) {
      throw ArgumentError('Verified archive payload evidence is invalid.');
    }
    final normalizedRelativePath = _safeRemediationRelativePath(
      relativePath,
      expectedSha256: normalizedHash,
    );
    if (_isSymlink(archiveDirectoryPath)) {
      throw StateError('Attachment archive directory must not be a symlink.');
    }

    if (allowArchiveRootCreation) {
      await ensureArchiveDirectory(
        archiveDirectoryPath,
        validateMutation: validateMutation,
      );
    } else if (!_isDirectory(archiveDirectoryPath)) {
      throw StateError('The active remediation archive must already exist.');
    }
    final destinationFile = File(
      path.join(archiveDirectoryPath, normalizedRelativePath),
    );
    await validateMutation(
      AttachmentArchiveMutationBoundary.beforeRootCreation,
    );
    await _ensureDestinationParentWithoutRecreatingRoot(
      archiveDirectoryPath: archiveDirectoryPath,
      relativePath: normalizedRelativePath,
      validateMutation: validateMutation,
    );
    if (_isSymlink(destinationFile.parent.path) ||
        _isSymlink(destinationFile.path) ||
        _isDirectory(destinationFile.path)) {
      throw StateError(
        'Attachment archive destination must be a regular file path.',
      );
    }

    final existing = await _classifyExistingDestination(
      destinationFile: destinationFile,
      relativePath: normalizedRelativePath,
      expectedSizeBytes: expectedSizeBytes,
      expectedSha256: normalizedHash,
    );
    if (existing != null) {
      return existing;
    }

    await validateMutation(
      AttachmentArchiveMutationBoundary.beforeTemporaryCopy,
    );

    final temporaryFile = File(
      path.join(
        destinationFile.parent.path,
        '.${path.basename(destinationFile.path)}'
        '$_temporaryMarker${_uuid.v4()}.tmp',
      ),
    );
    await temporaryFile.create(exclusive: true);
    try {
      await validateMutation(
        AttachmentArchiveMutationBoundary.beforeSourceRead,
      );
      final output = await temporaryFile.open(mode: FileMode.write);
      try {
        await for (final chunk in sourceBytes) {
          await output.writeFrom(chunk);
        }
        await output.flush();
      } finally {
        await output.close();
      }

      await validateMutation(AttachmentArchiveMutationBoundary.afterSourceHash);

      await validateMutation(
        AttachmentArchiveMutationBoundary.beforePayloadVerification,
      );

      final temporarySize = await temporaryFile.length();
      final temporaryHash = await _computeSha256(temporaryFile);
      if (temporarySize != expectedSizeBytes ||
          temporaryHash != normalizedHash) {
        return AttachmentArchiveFileInstall(
          status: AttachmentArchiveFileInstallStatus.donorChanged,
          relativePath: normalizedRelativePath,
          fileSizeBytes: temporarySize,
          contentHash: temporaryHash ?? '',
        );
      }

      await validateMutation(
        AttachmentArchiveMutationBoundary.beforeFinalInstall,
      );

      final installResult = await _atomicInstaller.install(
        temporaryPath: temporaryFile.path,
        destinationPath: destinationFile.path,
      );
      if (installResult == AtomicFileInstallResult.destinationExists) {
        return await _classifyExistingDestination(
              destinationFile: destinationFile,
              relativePath: normalizedRelativePath,
              expectedSizeBytes: expectedSizeBytes,
              expectedSha256: normalizedHash,
            ) ??
            AttachmentArchiveFileInstall(
              status: AttachmentArchiveFileInstallStatus.conflict,
              relativePath: normalizedRelativePath,
              fileSizeBytes: 0,
              contentHash: normalizedHash,
            );
      }

      await validateMutation(
        AttachmentArchiveMutationBoundary.afterFinalInstall,
      );

      final installed = await _classifyExistingDestination(
        destinationFile: destinationFile,
        relativePath: normalizedRelativePath,
        expectedSizeBytes: expectedSizeBytes,
        expectedSha256: normalizedHash,
      );
      if (installed == null ||
          installed.status !=
              AttachmentArchiveFileInstallStatus.alreadyPresent) {
        return AttachmentArchiveFileInstall(
          status: AttachmentArchiveFileInstallStatus.verificationFailed,
          relativePath: normalizedRelativePath,
          fileSizeBytes: 0,
          contentHash: normalizedHash,
        );
      }
      return AttachmentArchiveFileInstall(
        status: AttachmentArchiveFileInstallStatus.installed,
        relativePath: normalizedRelativePath,
        fileSizeBytes: expectedSizeBytes,
        contentHash: normalizedHash,
      );
    } finally {
      if (temporaryFile.existsSync()) {
        await temporaryFile.delete();
      }
    }
  }

  @override
  Future<ArchiveIntegrityFileCheck> checkIntegrity({
    required String archiveDirectoryPath,
    required String relativePath,
    required String? storedHash,
  }) async {
    final file = _archiveFile(
      archiveDirectoryPath: archiveDirectoryPath,
      relativePath: relativePath,
    );
    if (file == null) {
      return const ArchiveIntegrityFileCheck(
        fileExists: false,
        actualSizeBytes: null,
        hashMatches: null,
        actualHash: null,
      );
    }

    if (!file.existsSync()) {
      return const ArchiveIntegrityFileCheck(
        fileExists: false,
        actualSizeBytes: null,
        hashMatches: null,
        actualHash: null,
      );
    }

    if (storedHash == null || storedHash.isEmpty) {
      return ArchiveIntegrityFileCheck(
        fileExists: true,
        actualSizeBytes: await file.length(),
        hashMatches: null,
        actualHash: null,
      );
    }

    final actualHash = await _computeSha256(file);
    return ArchiveIntegrityFileCheck(
      fileExists: true,
      actualSizeBytes: await file.length(),
      hashMatches: actualHash == storedHash,
      actualHash: actualHash,
    );
  }

  static Future<String?> _computeSha256(File file) async {
    try {
      final filePath = file.path;
      return await Isolate.run(
        () async =>
            (await sha256.bind(File(filePath).openRead()).first).toString(),
      );
    } on Exception {
      return null;
    }
  }

  static Future<AttachmentArchiveFileInstall?> _classifyExistingDestination({
    required File destinationFile,
    required String relativePath,
    required int expectedSizeBytes,
    required String expectedSha256,
  }) async {
    final type = FileSystemEntity.typeSync(
      destinationFile.path,
      followLinks: false,
    );
    if (type == FileSystemEntityType.notFound) {
      return null;
    }
    if (type != FileSystemEntityType.file) {
      return AttachmentArchiveFileInstall(
        status: AttachmentArchiveFileInstallStatus.conflict,
        relativePath: relativePath,
        fileSizeBytes: 0,
        contentHash: expectedSha256,
      );
    }

    final size = await destinationFile.length();
    final hash = await _computeSha256(destinationFile);
    return AttachmentArchiveFileInstall(
      status: size == expectedSizeBytes && hash == expectedSha256
          ? AttachmentArchiveFileInstallStatus.alreadyPresent
          : AttachmentArchiveFileInstallStatus.conflict,
      relativePath: relativePath,
      fileSizeBytes: size,
      contentHash: hash ?? '',
    );
  }

  static bool _isSha256(String? value) {
    return value != null && RegExp(r'^[0-9a-f]{64}$').hasMatch(value);
  }

  static String _safeRemediationRelativePath(
    String relativePath, {
    required String expectedSha256,
  }) {
    final normalized = path.normalize(relativePath);
    if (relativePath.isEmpty ||
        path.isAbsolute(relativePath) ||
        normalized != relativePath ||
        normalized == '.' ||
        normalized == '..' ||
        normalized.startsWith('../')) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'Remediation path is unsafe.',
      );
    }
    final components = path.split(normalized);
    final basename = components.last;
    final contentAddressed =
        components.length == 2 &&
        components.first == expectedSha256.substring(0, 2) &&
        RegExp(
          '^${RegExp.escape(expectedSha256)}(\\.[A-Za-z0-9]{1,16})?\$',
        ).hasMatch(basename);
    final byId =
        components.length == 2 &&
        components.first == '_by_id' &&
        RegExp(r'^\d+(\.[A-Za-z0-9]{1,16})?$').hasMatch(basename);
    if (!contentAddressed && !byId) {
      // Metadata-known payload paths may predate these two standard shapes.
      // Their exact path is nevertheless safe because typed remediation
      // authority binds it to the verified transaction item.
      for (final component in components) {
        if (component.isEmpty || component == '.' || component == '..') {
          throw ArgumentError.value(
            relativePath,
            'relativePath',
            'Remediation path is unsafe.',
          );
        }
      }
    }
    return normalized;
  }

  static String _safeExtension(String rawExtension) {
    final extension = rawExtension.trim().toLowerCase();
    if (extension.isEmpty) {
      return '';
    }
    if (!RegExp(r'^\.[a-z0-9]{1,16}$').hasMatch(extension)) {
      throw ArgumentError.value(
        rawExtension,
        'sourceExtension',
        'Attachment extension is unsafe.',
      );
    }
    return extension;
  }

  static Future<void> _ensureDestinationParentWithoutRecreatingRoot({
    required String archiveDirectoryPath,
    required String relativePath,
    required Future<void> Function(AttachmentArchiveMutationBoundary boundary)
    validateMutation,
  }) async {
    final relativeParent = path.dirname(relativePath);
    if (relativeParent == '.') {
      return;
    }
    var current = archiveDirectoryPath;
    for (final component in path.split(relativeParent)) {
      await validateMutation(
        AttachmentArchiveMutationBoundary.beforeRootCreation,
      );
      if (!_isDirectory(current)) {
        throw StateError(
          'The active archive root became unavailable during installation.',
        );
      }
      current = path.join(current, component);
      final type = FileSystemEntity.typeSync(current, followLinks: false);
      if (type == FileSystemEntityType.notFound) {
        await Directory(current).create();
      } else if (type != FileSystemEntityType.directory) {
        throw StateError(
          'Attachment archive destination parent must be a directory.',
        );
      }
      if (!_isDirectory(current)) {
        throw StateError(
          'Attachment archive destination parent is unavailable or unsafe.',
        );
      }
    }
  }

  static bool _isRegularFile(String filePath) {
    return FileSystemEntity.typeSync(filePath, followLinks: false) ==
        FileSystemEntityType.file;
  }

  static bool _isDirectory(String filePath) {
    return FileSystemEntity.typeSync(filePath, followLinks: false) ==
        FileSystemEntityType.directory;
  }

  static bool _isSymlink(String filePath) {
    return FileSystemEntity.typeSync(filePath, followLinks: false) ==
        FileSystemEntityType.link;
  }

  static File? _archiveFile({
    required String archiveDirectoryPath,
    required String relativePath,
  }) {
    if (archiveDirectoryPath.isEmpty ||
        relativePath.isEmpty ||
        path.isAbsolute(relativePath) ||
        _isSymlink(archiveDirectoryPath)) {
      return null;
    }

    final archiveRoot = path.normalize(path.absolute(archiveDirectoryPath));
    final absolutePath = path.normalize(path.join(archiveRoot, relativePath));
    if (!path.isWithin(archiveRoot, absolutePath)) {
      return null;
    }

    return File(absolutePath);
  }
}
