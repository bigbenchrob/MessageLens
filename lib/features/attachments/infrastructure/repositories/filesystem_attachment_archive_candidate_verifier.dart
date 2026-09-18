import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:unorm_dart/unorm_dart.dart' as unicode;

import '../../application/attachment_archive_candidate_verifier.dart';
import '../../application/attachment_archive_verification_metadata_reader.dart';
import '../../domain/entities/attachment_archive_candidate_verification.dart';
import '../../domain/entities/attachment_archive_location_configuration.dart';
import '../../domain/entities/attachment_archive_location_state.dart';

/// Pure read-only verification of an existing attachment archive candidate.
///
/// Structural fingerprints use length-prefixed UTF-8 fields. Source evidence
/// is ordered as grouped metadata followed by depth-first lexical filesystem
/// entries. Candidate evidence is depth-first lexical filesystem entries.
/// Entry evidence contains relative path, type, size, modified/change times,
/// and classification. The fingerprint intentionally does not hash payload
/// bytes; it detects ordinary filesystem changes but is not durable authority.
final class FilesystemAttachmentArchiveCandidateVerifier
    implements AttachmentArchiveCandidateVerifier {
  FilesystemAttachmentArchiveCandidateVerifier({
    required AttachmentArchiveVerificationMetadataReader metadataReader,
    DateTime Function()? clock,
    this.metadataPageSize = 500,
    this.diagnosticExampleLimit = 100,
  }) : _metadataReader = metadataReader,
       _clock = clock ?? _utcNow {
    if (metadataPageSize <= 0 || metadataPageSize > 1000) {
      throw ArgumentError.value(
        metadataPageSize,
        'metadataPageSize',
        'Metadata page size must be between 1 and 1000.',
      );
    }
    if (diagnosticExampleLimit <= 0) {
      throw ArgumentError.value(
        diagnosticExampleLimit,
        'diagnosticExampleLimit',
        'Diagnostic example limit must be positive.',
      );
    }
  }

  static const int hashChunkBytes = 1024 * 1024;

  final AttachmentArchiveVerificationMetadataReader _metadataReader;
  final DateTime Function() _clock;
  final int metadataPageSize;
  final int diagnosticExampleLimit;

  @override
  Future<AttachmentArchiveCandidateVerificationResult> verify({
    required AttachmentArchiveLocationState sourceLocation,
    required AttachmentArchiveCandidateAccess candidate,
    AttachmentArchiveVerificationProgressCallback? onProgress,
    bool Function()? isCancelled,
  }) async {
    var context = AttachmentArchiveCandidateVerificationContext(
      sourceLocationConfiguration: sourceLocation.configuration,
      sourceLocationGeneration: sourceLocation.generation,
      requestedSourcePath: sourceLocation.archiveRootPath,
      requestedCandidatePath: candidate.directoryPath,
      verifiedAtUtc: _clock().toUtc(),
      candidateWasPhysicallyWritable: candidate.isPhysicallyWritable,
    );
    final sourcePath = sourceLocation.archiveRootPath;
    if (!sourceLocation.isAvailable || sourcePath == null) {
      return AttachmentArchiveVerificationSourceUnavailable(
        context: context,
        issue:
            sourceLocation.issue ?? 'The authoritative archive is unavailable.',
      );
    }
    final sourceConfiguration = sourceLocation.configuration;
    if (sourceConfiguration == null) {
      return AttachmentArchiveCandidateVerificationFailed(
        context: context,
        issue: 'The authoritative archive has no location configuration.',
      );
    }

    final _CanonicalRoot sourceRoot;
    try {
      sourceRoot = await _canonicalRoot(sourcePath, label: 'source');
    } on _RootUnavailable catch (error) {
      return AttachmentArchiveVerificationSourceUnavailable(
        context: context,
        issue: error.message,
      );
    } on _RootInvalid catch (error) {
      return AttachmentArchiveCandidateVerificationFailed(
        context: context,
        issue: error.message,
      );
    }
    context = context.withCanonicalIdentities(
      sourceCanonicalIdentity: sourceRoot.path,
    );

    final _CanonicalRoot candidateRoot;
    try {
      candidateRoot = await _canonicalRoot(
        candidate.directoryPath,
        label: 'candidate',
      );
    } on _RootUnavailable catch (error) {
      return AttachmentArchiveVerificationCandidateUnavailable(
        context: context,
        issue: error.message,
      );
    } on _RootInvalid catch (error) {
      return AttachmentArchiveCandidateInvalid(
        context: context,
        issue: error.message,
      );
    }
    context = context.withCanonicalIdentities(
      candidateCanonicalIdentity: candidateRoot.path,
    );

    if (_rootsOverlap(sourceRoot.path, candidateRoot.path)) {
      return AttachmentArchiveCandidateInvalid(
        context: context,
        issue:
            'The candidate must be distinct from and not nested with the '
            'authoritative archive.',
      );
    }

    final progress = _ProgressTracker(
      onProgress: onProgress,
      isCancelled: isCancelled,
    );
    try {
      return await _verifyRoots(
        sourceRoot: sourceRoot,
        candidateRoot: candidateRoot,
        sourceLocation: sourceLocation,
        sourceConfiguration: sourceConfiguration,
        candidate: candidate,
        context: context,
        progress: progress,
      );
    } on AttachmentArchiveCandidateVerificationCancelled {
      rethrow;
    } on _SourceVerificationFailure catch (error) {
      return AttachmentArchiveCandidateVerificationFailed(
        context: context,
        issue: error.message,
      );
    } on _CandidateUnavailableFailure catch (error) {
      return AttachmentArchiveVerificationCandidateUnavailable(
        context: context,
        issue: error.message,
      );
    } on _CandidateStructureFailure catch (error) {
      return AttachmentArchiveCandidateInvalid(
        context: context,
        issue: error.message,
      );
    } on FileSystemException catch (error) {
      return AttachmentArchiveCandidateVerificationFailed(
        context: context,
        issue:
            'Archive verification could not read filesystem evidence: '
            '${error.message}',
      );
    } on Object catch (error) {
      return AttachmentArchiveCandidateVerificationFailed(
        context: context,
        issue: 'Archive verification failed: $error',
      );
    }
  }

  Future<AttachmentArchiveCandidateVerificationResult> _verifyRoots({
    required _CanonicalRoot sourceRoot,
    required _CanonicalRoot candidateRoot,
    required AttachmentArchiveLocationState sourceLocation,
    required AttachmentArchiveLocationConfiguration sourceConfiguration,
    required AttachmentArchiveCandidateAccess candidate,
    required AttachmentArchiveCandidateVerificationContext context,
    required _ProgressTracker progress,
  }) async {
    final counters = _VerificationCounters();
    final diagnostics = _DiagnosticCollector(diagnosticExampleLimit);
    final sourceFingerprint = _EvidenceDigestBuilder(
      'messagelens-source-structural-snapshot-v1',
    );
    final candidateFingerprint = _EvidenceDigestBuilder(
      'messagelens-candidate-structural-snapshot-v1',
    );
    final contentDigest = _EvidenceDigestBuilder(
      'messagelens-archive-content-coverage-v1',
    );

    _addRootStructuralEvidence(sourceFingerprint, sourceRoot.path);

    progress.setPhase(AttachmentArchiveVerificationPhase.metadata);
    await _verifyGroupedMetadata(
      sourceRoot: sourceRoot.path,
      counters: counters,
      sourceFingerprint: sourceFingerprint,
      progress: progress,
    );

    progress.setPhase(AttachmentArchiveVerificationPhase.sourceCoverage);
    await for (final entry in _walk(
      sourceRoot.path,
      progress,
      isSource: true,
    )) {
      await _inspectSourceEntry(
        entry: entry,
        sourceRoot: sourceRoot.path,
        candidateRoot: candidateRoot.path,
        counters: counters,
        diagnostics: diagnostics,
        sourceFingerprint: sourceFingerprint,
        contentDigest: contentDigest,
        progress: progress,
      );
    }

    progress.setPhase(AttachmentArchiveVerificationPhase.candidateExtras);
    _addRootStructuralEvidence(candidateFingerprint, candidateRoot.path);
    await for (final entry in _walk(
      candidateRoot.path,
      progress,
      isSource: false,
    )) {
      await _inspectCandidateEntry(
        entry: entry,
        sourceRoot: sourceRoot.path,
        candidateRoot: candidateRoot.path,
        counters: counters,
        diagnostics: diagnostics,
        candidateFingerprint: candidateFingerprint,
        contentDigest: contentDigest,
        progress: progress,
      );
    }

    final evidence = AttachmentArchiveCandidateVerificationEvidence(
      sourceCanonicalIdentity: sourceRoot.path,
      candidateCanonicalIdentity: candidateRoot.path,
      sourceLocationConfiguration: sourceConfiguration,
      sourceLocationGeneration: sourceLocation.generation,
      verifiedAtUtc: context.verifiedAtUtc,
      candidateWasPhysicallyWritable: candidate.isPhysicallyWritable,
      requiredSourcePhysicalFileCount: counters.requiredSourceFileCount,
      requiredSourceBytes: counters.requiredSourceBytes,
      verifiedFileCount: counters.verifiedFileCount,
      verifiedBytes: counters.verifiedBytes,
      metadataReferenceCount: counters.metadataReferenceCount,
      unreferencedPreservationCount: counters.unreferencedPreservationCount,
      sourceOperationalDebrisCount: counters.sourceDebrisCount,
      candidateOperationalDebrisCount: counters.candidateDebrisCount,
      allowedCandidateExtraCount: counters.allowedExtraCount,
      allowedCandidateExtraBytes: counters.allowedExtraBytes,
      missingCount: counters.missingCount,
      missingBytes: counters.missingBytes,
      contentCoverageDigest: contentDigest.close(),
      sourceStructuralSnapshotFingerprint: sourceFingerprint.close(),
      candidateStructuralSnapshotFingerprint: candidateFingerprint.close(),
      diagnostics: diagnostics.freeze(),
    );

    if (counters.candidateConflictCount > 0) {
      return AttachmentArchiveCandidateInvalid(
        context: context,
        issue:
            counters.firstCandidateConflict ??
            'The candidate contains conflicting archive evidence.',
        evidence: evidence,
      );
    }
    if (counters.missingCount > 0) {
      return AttachmentArchiveCandidateBehind(
        context: context,
        evidence: evidence,
      );
    }
    return AttachmentArchiveCandidateComplete(
      context: context,
      evidence: evidence,
    );
  }

  Future<void> _verifyGroupedMetadata({
    required String sourceRoot,
    required _VerificationCounters counters,
    required _EvidenceDigestBuilder sourceFingerprint,
    required _ProgressTracker progress,
  }) async {
    String? afterRelativePath;
    while (true) {
      progress.checkCancellation();
      final page = await _metadataReader.readPage(
        afterRelativePath: afterRelativePath,
        limit: metadataPageSize,
      );
      if (page.groups.isEmpty) {
        if (page.hasMore) {
          throw const _SourceVerificationFailure(
            'Grouped metadata paging returned an empty non-terminal page.',
          );
        }
        return;
      }
      for (final group in page.groups) {
        progress.checkCancellation();
        final relativePath = _validateRelativePath(group.relativePath);
        if (afterRelativePath != null &&
            relativePath.compareTo(afterRelativePath) <= 0) {
          throw const _SourceVerificationFailure(
            'Grouped metadata paging is not strictly ordered.',
          );
        }
        final inspection = await _inspectExactPath(
          root: sourceRoot,
          relativePath: relativePath,
        );
        if (inspection.type != FileSystemEntityType.file ||
            inspection.actualRelativePath != relativePath) {
          throw _SourceVerificationFailure(
            'Attachment metadata references a missing, unsafe, or '
            'non-regular source payload: $relativePath',
          );
        }
        if (inspection.sizeBytes != group.fileSizeBytes) {
          throw _SourceVerificationFailure(
            'Attachment metadata size does not match source payload: '
            '$relativePath',
          );
        }
        counters.metadataReferenceCount += group.referenceCount;
        sourceFingerprint.add(<Object?>[
          'metadata',
          relativePath,
          group.fileSizeBytes,
          group.contentHash,
          group.referenceCount,
        ]);
        afterRelativePath = relativePath;
      }
      if (!page.hasMore) {
        return;
      }
    }
  }

  static void _addRootStructuralEvidence(
    _EvidenceDigestBuilder fingerprint,
    String root,
  ) {
    final stat = Directory(root).statSync();
    fingerprint.add(<Object?>[
      'root',
      'directory',
      stat.modified.microsecondsSinceEpoch,
      stat.changed.microsecondsSinceEpoch,
    ]);
  }

  Future<void> _inspectSourceEntry({
    required _ArchiveEntry entry,
    required String sourceRoot,
    required String candidateRoot,
    required _VerificationCounters counters,
    required _DiagnosticCollector diagnostics,
    required _EvidenceDigestBuilder sourceFingerprint,
    required _EvidenceDigestBuilder contentDigest,
    required _ProgressTracker progress,
  }) async {
    if (entry.type == FileSystemEntityType.directory) {
      sourceFingerprint.add(entry.structuralFields('directory'));
      return;
    }
    if (entry.type == FileSystemEntityType.link) {
      diagnostics.addSourceAnomaly(entry.relativePath);
      throw _SourceVerificationFailure(
        'The authoritative archive contains a symbolic link: '
        '${entry.relativePath}',
      );
    }
    if (entry.type != FileSystemEntityType.file) {
      diagnostics.addSourceAnomaly(entry.relativePath);
      throw _SourceVerificationFailure(
        'The authoritative archive contains a special filesystem entry: '
        '${entry.relativePath}',
      );
    }

    if (_installerDebrisTarget(entry.relativePath) != null) {
      counters.sourceDebrisCount++;
      diagnostics.addOperationalDebris(entry.relativePath);
      sourceFingerprint.add(
        entry.structuralFields(
          AttachmentArchivePreservationClassification.installerDebris.name,
        ),
      );
      contentDigest.add(<Object?>[
        'source-debris',
        entry.relativePath,
        AttachmentArchivePreservationClassification.installerDebris.name,
        entry.sizeBytes,
      ]);
      return;
    }

    final metadata = await _metadataReader.readByRelativePath(
      entry.relativePath,
    );
    final classification = _sourceClassification(
      relativePath: entry.relativePath,
      metadata: metadata,
    );
    if (classification == null) {
      diagnostics.addSourceAnomaly(entry.relativePath);
      throw _SourceVerificationFailure(
        'The authoritative archive contains an unknown preservation shape: '
        '${entry.relativePath}',
      );
    }
    if (metadata != null && metadata.fileSizeBytes != entry.sizeBytes) {
      diagnostics.addSourceAnomaly(entry.relativePath);
      throw _SourceVerificationFailure(
        'Attachment metadata size does not match source payload: '
        '${entry.relativePath}',
      );
    }

    sourceFingerprint.add(entry.structuralFields(classification.name));
    counters.requiredSourceFileCount++;
    counters.requiredSourceBytes += entry.sizeBytes;
    if (metadata == null) {
      counters.unreferencedPreservationCount++;
    }

    final sourceHash = await progress.hashFile(
      File(entry.absolutePath),
      phase: AttachmentArchiveVerificationPhase.sourceCoverage,
    );
    final expectedPathHash = _contentAddressedHash(entry.relativePath);
    final authoritativeHash = metadata?.contentHash ?? expectedPathHash;
    if (authoritativeHash != null && sourceHash != authoritativeHash) {
      diagnostics.addSourceAnomaly(entry.relativePath);
      throw _SourceVerificationFailure(
        'The authoritative source hash contradicts its preservation '
        'evidence: ${entry.relativePath}',
      );
    }

    final candidateInspection = await _inspectExactPath(
      root: candidateRoot,
      relativePath: entry.relativePath,
    );
    if (candidateInspection.type == FileSystemEntityType.notFound) {
      counters.missingCount++;
      counters.missingBytes += entry.sizeBytes;
      diagnostics.addMissing(entry.relativePath);
      contentDigest.add(<Object?>[
        'required',
        entry.relativePath,
        classification.name,
        entry.sizeBytes,
        null,
        metadata?.contentHash,
        sourceHash,
        null,
        metadata?.referenceCount ?? 0,
      ]);
      return;
    }
    if (candidateInspection.type != FileSystemEntityType.file ||
        candidateInspection.actualRelativePath != entry.relativePath) {
      _recordCandidateConflict(
        counters,
        diagnostics,
        entry.relativePath,
        'Candidate path is unsafe or is not a regular file: '
        '${entry.relativePath}',
      );
      contentDigest.add(<Object?>[
        'required',
        entry.relativePath,
        classification.name,
        entry.sizeBytes,
        candidateInspection.sizeBytes,
        metadata?.contentHash,
        sourceHash,
        null,
        metadata?.referenceCount ?? 0,
      ]);
      return;
    }
    if (candidateInspection.sizeBytes != entry.sizeBytes) {
      _recordCandidateConflict(
        counters,
        diagnostics,
        entry.relativePath,
        'Candidate size conflicts with the authoritative source: '
        '${entry.relativePath}',
      );
      contentDigest.add(<Object?>[
        'required',
        entry.relativePath,
        classification.name,
        entry.sizeBytes,
        candidateInspection.sizeBytes,
        metadata?.contentHash,
        sourceHash,
        null,
        metadata?.referenceCount ?? 0,
      ]);
      return;
    }

    final candidateHash = await progress.hashFile(
      File(candidateInspection.absolutePath),
      phase: AttachmentArchiveVerificationPhase.sourceCoverage,
    );
    final expectedHash = authoritativeHash ?? sourceHash;
    if (candidateHash != expectedHash) {
      _recordCandidateConflict(
        counters,
        diagnostics,
        entry.relativePath,
        'Candidate content conflicts with the authoritative source: '
        '${entry.relativePath}',
      );
    } else {
      counters.verifiedFileCount++;
      counters.verifiedBytes += entry.sizeBytes;
    }
    contentDigest.add(<Object?>[
      'required',
      entry.relativePath,
      classification.name,
      entry.sizeBytes,
      candidateInspection.sizeBytes,
      metadata?.contentHash,
      sourceHash,
      candidateHash,
      metadata?.referenceCount ?? 0,
    ]);
  }

  Future<void> _inspectCandidateEntry({
    required _ArchiveEntry entry,
    required String sourceRoot,
    required String candidateRoot,
    required _VerificationCounters counters,
    required _DiagnosticCollector diagnostics,
    required _EvidenceDigestBuilder candidateFingerprint,
    required _EvidenceDigestBuilder contentDigest,
    required _ProgressTracker progress,
  }) async {
    if (entry.type == FileSystemEntityType.directory) {
      candidateFingerprint.add(entry.structuralFields('directory'));
      return;
    }
    if (entry.type == FileSystemEntityType.link) {
      candidateFingerprint.add(entry.structuralFields('invalid-link'));
      _recordCandidateConflict(
        counters,
        diagnostics,
        entry.relativePath,
        'The candidate contains a symbolic link: ${entry.relativePath}',
      );
      return;
    }
    if (entry.type != FileSystemEntityType.file) {
      candidateFingerprint.add(entry.structuralFields('invalid-special'));
      _recordCandidateConflict(
        counters,
        diagnostics,
        entry.relativePath,
        'The candidate contains a special filesystem entry: '
        '${entry.relativePath}',
      );
      return;
    }

    if (_installerDebrisTarget(entry.relativePath) != null) {
      counters.candidateDebrisCount++;
      diagnostics.addOperationalDebris(entry.relativePath);
      candidateFingerprint.add(
        entry.structuralFields(
          AttachmentArchivePreservationClassification.installerDebris.name,
        ),
      );
      contentDigest.add(<Object?>[
        'candidate-debris',
        entry.relativePath,
        AttachmentArchivePreservationClassification.installerDebris.name,
        entry.sizeBytes,
      ]);
      return;
    }

    final sourceInspection = await _inspectExactPath(
      root: sourceRoot,
      relativePath: entry.relativePath,
    );
    if (sourceInspection.type == FileSystemEntityType.file &&
        sourceInspection.actualRelativePath == entry.relativePath) {
      final metadata = await _metadataReader.readByRelativePath(
        entry.relativePath,
      );
      final classification = _sourceClassification(
        relativePath: entry.relativePath,
        metadata: metadata,
      );
      candidateFingerprint.add(
        entry.structuralFields(classification?.name ?? 'required-unknown'),
      );
      return;
    }

    final extraClassification = _unreferencedClassification(entry.relativePath);
    if (extraClassification == null) {
      candidateFingerprint.add(entry.structuralFields('invalid-extra'));
      _recordCandidateConflict(
        counters,
        diagnostics,
        entry.relativePath,
        'The candidate contains an unknown extra entry: '
        '${entry.relativePath}',
      );
      return;
    }

    final actualHash = await progress.hashFile(
      File(entry.absolutePath),
      phase: AttachmentArchiveVerificationPhase.candidateExtras,
    );
    final filenameHash = _contentAddressedHash(entry.relativePath);
    if (filenameHash != null && actualHash != filenameHash) {
      candidateFingerprint.add(
        entry.structuralFields('invalid-content-addressed-extra'),
      );
      _recordCandidateConflict(
        counters,
        diagnostics,
        entry.relativePath,
        'Candidate hash-named extra contradicts its filename: '
        '${entry.relativePath}',
      );
      contentDigest.add(<Object?>[
        'extra',
        entry.relativePath,
        extraClassification.name,
        entry.sizeBytes,
        actualHash,
        'invalid-filename-hash',
      ]);
      return;
    }

    counters.allowedExtraCount++;
    counters.allowedExtraBytes += entry.sizeBytes;
    diagnostics.addAllowedExtra(entry.relativePath);
    candidateFingerprint.add(entry.structuralFields(extraClassification.name));
    contentDigest.add(<Object?>[
      'extra',
      entry.relativePath,
      extraClassification.name,
      entry.sizeBytes,
      actualHash,
      'allowed',
    ]);
  }

  Stream<_ArchiveEntry> _walk(
    String root,
    _ProgressTracker progress, {
    required bool isSource,
  }) async* {
    yield* _walkDirectory(
      root: root,
      directoryPath: root,
      parentRelativePath: '',
      progress: progress,
      isSource: isSource,
    );
  }

  Stream<_ArchiveEntry> _walkDirectory({
    required String root,
    required String directoryPath,
    required String parentRelativePath,
    required _ProgressTracker progress,
    required bool isSource,
  }) async* {
    progress.checkCancellation();
    final List<FileSystemEntity> children;
    try {
      children = await Directory(
        directoryPath,
      ).list(followLinks: false).toList();
    } on FileSystemException catch (error) {
      if (isSource) {
        throw _SourceVerificationFailure(
          'The authoritative archive became unavailable while checking: '
          '${error.message}',
        );
      }
      throw _CandidateUnavailableFailure(
        'The candidate archive became unavailable while checking: '
        '${error.message}',
      );
    }
    children.sort(
      (left, right) =>
          path.basename(left.path).compareTo(path.basename(right.path)),
    );
    _requireUnambiguousSiblings(
      children,
      parentRelativePath,
      isSource: isSource,
    );

    for (final child in children) {
      progress.checkCancellation();
      final name = path.basename(child.path);
      final relativePath = _validateRelativePath(
        parentRelativePath.isEmpty ? name : path.join(parentRelativePath, name),
      );
      final expectedPath = path.normalize(path.join(root, relativePath));
      if (path.normalize(child.path) != expectedPath) {
        final message =
            'Filesystem enumeration escaped its archive root: $relativePath';
        if (isSource) {
          throw _SourceVerificationFailure(message);
        }
        throw _CandidateStructureFailure(message);
      }
      final type = FileSystemEntity.typeSync(child.path, followLinks: false);
      FileStat? stat;
      if (type == FileSystemEntityType.file ||
          type == FileSystemEntityType.directory) {
        stat = await child.stat();
      }
      final entry = _ArchiveEntry(
        absolutePath: child.path,
        relativePath: relativePath,
        type: type,
        sizeBytes: type == FileSystemEntityType.file ? stat?.size ?? 0 : 0,
        modifiedMicros: stat?.modified.microsecondsSinceEpoch,
        changedMicros: stat?.changed.microsecondsSinceEpoch,
      );
      yield entry;
      if (type == FileSystemEntityType.directory) {
        yield* _walkDirectory(
          root: root,
          directoryPath: child.path,
          parentRelativePath: relativePath,
          progress: progress,
          isSource: isSource,
        );
      }
    }
  }

  Future<_ExactPathInspection> _inspectExactPath({
    required String root,
    required String relativePath,
  }) async {
    final normalizedRelativePath = _validateRelativePath(relativePath);
    var current = root;
    for (final component in path.split(normalizedRelativePath)) {
      current = path.join(current, component);
      final componentType = FileSystemEntity.typeSync(
        current,
        followLinks: false,
      );
      if (componentType == FileSystemEntityType.link) {
        return _ExactPathInspection(
          absolutePath: current,
          actualRelativePath: null,
          type: componentType,
          sizeBytes: null,
        );
      }
      if (componentType == FileSystemEntityType.notFound) {
        return _ExactPathInspection(
          absolutePath: current,
          actualRelativePath: null,
          type: componentType,
          sizeBytes: null,
        );
      }
    }
    final type = FileSystemEntity.typeSync(current, followLinks: false);
    String? actualRelativePath;
    if (type == FileSystemEntityType.file ||
        type == FileSystemEntityType.directory) {
      final resolved = type == FileSystemEntityType.file
          ? await File(current).resolveSymbolicLinks()
          : await Directory(current).resolveSymbolicLinks();
      actualRelativePath = path.normalize(path.relative(resolved, from: root));
    }
    return _ExactPathInspection(
      absolutePath: current,
      actualRelativePath: actualRelativePath,
      type: type,
      sizeBytes: type == FileSystemEntityType.file
          ? await File(current).length()
          : null,
    );
  }

  static Future<_CanonicalRoot> _canonicalRoot(
    String rawPath, {
    required String label,
  }) async {
    if (!path.isAbsolute(rawPath)) {
      throw _RootInvalid('The $label archive path must be absolute.');
    }
    final normalized = path.normalize(rawPath);
    final type = FileSystemEntity.typeSync(normalized, followLinks: false);
    if (type == FileSystemEntityType.notFound) {
      throw _RootUnavailable('The $label archive is unavailable.');
    }
    if (type == FileSystemEntityType.link) {
      throw _RootInvalid(
        'The $label archive root must not be a symbolic link.',
      );
    }
    if (type != FileSystemEntityType.directory) {
      throw _RootInvalid('The $label archive root must be a directory.');
    }
    try {
      final canonical = path.normalize(
        await Directory(normalized).resolveSymbolicLinks(),
      );
      await Directory(canonical).list(followLinks: false).take(1).toList();
      return _CanonicalRoot(canonical);
    } on FileSystemException catch (error) {
      throw _RootUnavailable(
        'The $label archive could not be read: ${error.message}',
      );
    }
  }

  static bool _rootsOverlap(String source, String candidate) {
    return source == candidate ||
        path.isWithin(source, candidate) ||
        path.isWithin(candidate, source);
  }

  static String _validateRelativePath(String relativePath) {
    if (relativePath.isEmpty || path.isAbsolute(relativePath)) {
      throw const _SourceVerificationFailure(
        'Attachment archive evidence contains a non-relative path.',
      );
    }
    final normalized = path.normalize(relativePath);
    if (normalized != relativePath ||
        normalized == '.' ||
        normalized == '..' ||
        normalized.startsWith('../')) {
      throw _SourceVerificationFailure(
        'Attachment archive evidence contains an unsafe path: $relativePath',
      );
    }
    return normalized;
  }

  static void _requireUnambiguousSiblings(
    List<FileSystemEntity> children,
    String parentRelativePath, {
    required bool isSource,
  }) {
    final seen = <String, String>{};
    for (final child in children) {
      final name = path.basename(child.path);
      final collisionKey = unicode.nfc(name).toLowerCase();
      final previous = seen[collisionKey];
      if (previous != null && previous != name) {
        final parent = parentRelativePath.isEmpty ? '.' : parentRelativePath;
        final message =
            'Archive path names are ambiguous under supported filesystem '
            'semantics in $parent: $previous and $name';
        if (isSource) {
          throw _SourceVerificationFailure(message);
        }
        throw _CandidateStructureFailure(message);
      }
      seen[collisionKey] = name;
    }
  }

  static AttachmentArchivePreservationClassification? _sourceClassification({
    required String relativePath,
    required AttachmentArchiveVerificationMetadataGroup? metadata,
  }) {
    if (metadata != null) {
      return AttachmentArchivePreservationClassification.metadataKnown;
    }
    return _unreferencedClassification(relativePath);
  }

  static AttachmentArchivePreservationClassification?
  _unreferencedClassification(String relativePath) {
    if (_contentAddressedHash(relativePath) != null) {
      return AttachmentArchivePreservationClassification
          .contentAddressedUnreferenced;
    }
    final components = path.split(relativePath);
    if (components.length == 2 &&
        components.first == '_by_id' &&
        RegExp(r'^\d+(\.[A-Za-z0-9]{1,16})?$').hasMatch(components.last)) {
      return AttachmentArchivePreservationClassification.byIdUnreferenced;
    }
    return null;
  }

  static String? _contentAddressedHash(String relativePath) {
    final components = path.split(relativePath);
    if (components.length != 2 ||
        !RegExp(r'^[0-9a-f]{2}$').hasMatch(components.first)) {
      return null;
    }
    final match = RegExp(
      r'^([0-9a-f]{64})(\.[A-Za-z0-9]{1,16})?$',
    ).firstMatch(components.last);
    final hash = match?.group(1);
    if (hash == null || components.first != hash.substring(0, 2)) {
      return null;
    }
    return hash;
  }

  static String? _installerDebrisTarget(String relativePath) {
    final basename = path.basename(relativePath);
    final match = RegExp(
      r'^\.(.+)\.messagelens-install-'
      r'[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-'
      r'[89ab][0-9a-f]{3}-[0-9a-f]{12}\.tmp$',
    ).firstMatch(basename);
    final targetName = match?.group(1);
    if (targetName == null) {
      return null;
    }
    final parent = path.dirname(relativePath);
    final targetRelativePath = parent == '.'
        ? targetName
        : path.join(parent, targetName);
    return _unreferencedClassification(targetRelativePath) == null
        ? null
        : targetRelativePath;
  }

  static void _recordCandidateConflict(
    _VerificationCounters counters,
    _DiagnosticCollector diagnostics,
    String relativePath,
    String issue,
  ) {
    counters.candidateConflictCount++;
    counters.firstCandidateConflict ??= issue;
    diagnostics.addConflict(relativePath);
  }

  static DateTime _utcNow() => DateTime.now().toUtc();
}

final class _CanonicalRoot {
  const _CanonicalRoot(this.path);

  final String path;
}

final class _ArchiveEntry {
  const _ArchiveEntry({
    required this.absolutePath,
    required this.relativePath,
    required this.type,
    required this.sizeBytes,
    required this.modifiedMicros,
    required this.changedMicros,
  });

  final String absolutePath;
  final String relativePath;
  final FileSystemEntityType type;
  final int sizeBytes;
  final int? modifiedMicros;
  final int? changedMicros;

  List<Object?> structuralFields(String classification) {
    return <Object?>[
      'entry',
      relativePath,
      _entityTypeName(type),
      sizeBytes,
      modifiedMicros,
      changedMicros,
      classification,
    ];
  }

  static String _entityTypeName(FileSystemEntityType value) {
    if (value == FileSystemEntityType.file) {
      return 'file';
    }
    if (value == FileSystemEntityType.directory) {
      return 'directory';
    }
    if (value == FileSystemEntityType.link) {
      return 'link';
    }
    if (value == FileSystemEntityType.notFound) {
      return 'notFound';
    }
    if (value == FileSystemEntityType.pipe) {
      return 'pipe';
    }
    if (value == FileSystemEntityType.unixDomainSock) {
      return 'unixDomainSocket';
    }
    return 'unknown';
  }
}

final class _ExactPathInspection {
  const _ExactPathInspection({
    required this.absolutePath,
    required this.actualRelativePath,
    required this.type,
    required this.sizeBytes,
  });

  final String absolutePath;
  final String? actualRelativePath;
  final FileSystemEntityType type;
  final int? sizeBytes;
}

final class _VerificationCounters {
  int requiredSourceFileCount = 0;
  int requiredSourceBytes = 0;
  int verifiedFileCount = 0;
  int verifiedBytes = 0;
  int metadataReferenceCount = 0;
  int unreferencedPreservationCount = 0;
  int sourceDebrisCount = 0;
  int candidateDebrisCount = 0;
  int allowedExtraCount = 0;
  int allowedExtraBytes = 0;
  int missingCount = 0;
  int missingBytes = 0;
  int candidateConflictCount = 0;
  String? firstCandidateConflict;
}

final class _DiagnosticCollector {
  _DiagnosticCollector(this.limit);

  final int limit;
  final List<String> _missing = <String>[];
  final List<String> _conflicts = <String>[];
  final List<String> _allowedExtras = <String>[];
  final List<String> _debris = <String>[];
  final List<String> _sourceAnomalies = <String>[];

  void addMissing(String value) => _add(_missing, value);
  void addConflict(String value) => _add(_conflicts, value);
  void addAllowedExtra(String value) => _add(_allowedExtras, value);
  void addOperationalDebris(String value) => _add(_debris, value);
  void addSourceAnomaly(String value) => _add(_sourceAnomalies, value);

  void _add(List<String> values, String value) {
    if (values.length < limit) {
      values.add(value);
    }
  }

  AttachmentArchiveVerificationDiagnostics freeze() {
    return AttachmentArchiveVerificationDiagnostics(
      missingPathExamples: List<String>.unmodifiable(_missing),
      conflictingPathExamples: List<String>.unmodifiable(_conflicts),
      allowedExtraPathExamples: List<String>.unmodifiable(_allowedExtras),
      operationalDebrisPathExamples: List<String>.unmodifiable(_debris),
      sourceAnomalyPathExamples: List<String>.unmodifiable(_sourceAnomalies),
    );
  }
}

final class _ProgressTracker {
  _ProgressTracker({required this.onProgress, required this.isCancelled});

  final AttachmentArchiveVerificationProgressCallback? onProgress;
  final bool Function()? isCancelled;
  AttachmentArchiveVerificationPhase _phase =
      AttachmentArchiveVerificationPhase.metadata;
  int _filesChecked = 0;
  int _bytesChecked = 0;

  void setPhase(AttachmentArchiveVerificationPhase value) {
    _phase = value;
    _publish();
  }

  void checkCancellation() {
    if (isCancelled?.call() ?? false) {
      throw const AttachmentArchiveCandidateVerificationCancelled();
    }
  }

  Future<String> hashFile(
    File file, {
    required AttachmentArchiveVerificationPhase phase,
  }) async {
    _phase = phase;
    final digestSink = _DigestSink();
    final hashSink = sha256.startChunkedConversion(digestSink);
    final input = await file.open();
    try {
      while (true) {
        checkCancellation();
        final chunk = await input.read(
          FilesystemAttachmentArchiveCandidateVerifier.hashChunkBytes,
        );
        if (chunk.isEmpty) {
          break;
        }
        hashSink.add(chunk);
        _bytesChecked += chunk.length;
        _publish();
      }
    } finally {
      await input.close();
      hashSink.close();
    }
    final digest = digestSink.value;
    if (digest == null) {
      throw StateError('SHA-256 did not produce a digest for ${file.path}.');
    }
    _filesChecked++;
    _publish();
    return digest.toString();
  }

  void _publish() {
    onProgress?.call(
      AttachmentArchiveVerificationProgress(
        phase: _phase,
        filesChecked: _filesChecked,
        bytesChecked: _bytesChecked,
      ),
    );
  }
}

final class _EvidenceDigestBuilder {
  _EvidenceDigestBuilder(String contract) {
    _sink = _DigestSink();
    _input = sha256.startChunkedConversion(_sink);
    add(<Object?>[contract]);
  }

  late final _DigestSink _sink;
  late final ByteConversionSink _input;
  bool _closed = false;

  void add(List<Object?> fields) {
    if (_closed) {
      throw StateError('Evidence digest is already closed.');
    }
    final encoded = fields.map(_encodeField).join();
    _input.add(utf8.encode(encoded));
  }

  String close() {
    if (!_closed) {
      _closed = true;
      _input.close();
    }
    final value = _sink.value;
    if (value == null) {
      throw StateError('Evidence digest did not produce a value.');
    }
    return value.toString();
  }

  static String _encodeField(Object? value) {
    final text = value?.toString() ?? '<null>';
    return '${utf8.encode(text).length}:$text;';
  }
}

final class _DigestSink implements Sink<Digest> {
  Digest? value;

  @override
  void add(Digest data) {
    value = data;
  }

  @override
  void close() {}
}

final class _RootUnavailable implements Exception {
  const _RootUnavailable(this.message);

  final String message;
}

final class _RootInvalid implements Exception {
  const _RootInvalid(this.message);

  final String message;
}

final class _SourceVerificationFailure implements Exception {
  const _SourceVerificationFailure(this.message);

  final String message;
}

final class _CandidateUnavailableFailure implements Exception {
  const _CandidateUnavailableFailure(this.message);

  final String message;
}

final class _CandidateStructureFailure implements Exception {
  const _CandidateStructureFailure(this.message);

  final String message;
}
