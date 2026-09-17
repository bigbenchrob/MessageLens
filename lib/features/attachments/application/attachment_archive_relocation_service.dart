import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../essentials/archive_environment/domain/archive_access_authority.dart';
import '../../../essentials/archive_environment/domain/archive_mutation_operation.dart';
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability;
import '../domain/entities/attachment_archive_location_configuration.dart';
import '../domain/entities/attachment_archive_location_state.dart';
import '../domain/entities/attachment_archive_relocation.dart';
import 'attachment_archive_location_native_adapter.dart';
import 'attachment_archive_location_provider.dart';
import 'attachment_archive_relocation_activation_gate.dart';
import 'attachment_archive_relocation_file_system.dart';
import 'attachment_archive_relocation_journal_store.dart';
import 'attachment_archive_relocation_metadata_reader.dart';

typedef AttachmentArchiveRelocationLocationReader =
    Future<AttachmentArchiveLocationState> Function();
typedef AttachmentArchiveRelocationActivator =
    Future<void> Function({
      required AttachmentArchiveLocationConfiguration configuration,
      required AttachmentArchiveRelocationActivationPermit activationPermit,
    });
typedef AttachmentArchiveRelocationWritableAdmissionReader =
    Future<AttachmentArchiveWritableRootAdmission> Function();
typedef AttachmentArchiveRelocationPauseRequestReader = bool Function();

final class AttachmentArchiveRelocationService {
  const AttachmentArchiveRelocationService({
    required ArchiveAccessAuthority archiveAccessAuthority,
    required AttachmentArchiveRelocationJournalStore journalStore,
    required AttachmentArchiveRelocationMetadataReader metadataReader,
    required AttachmentArchiveRelocationFileSystem fileSystem,
    required AttachmentArchiveLocationNativeAdapter nativeAdapter,
    required AttachmentArchiveRelocationActivationGate activationGate,
    required AttachmentArchiveRelocationLocationReader readLocation,
    required AttachmentArchiveRelocationActivator activateLocation,
    required AttachmentArchiveRelocationActivator restoreLocation,
    required AttachmentArchiveRelocationWritableAdmissionReader
    readWritableAdmission,
    DateTime Function() nowUtc = _defaultNowUtc,
  }) : _archiveAccessAuthority = archiveAccessAuthority,
       _journalStore = journalStore,
       _metadataReader = metadataReader,
       _fileSystem = fileSystem,
       _nativeAdapter = nativeAdapter,
       _activationGate = activationGate,
       _readLocation = readLocation,
       _activateLocation = activateLocation,
       _restoreLocation = restoreLocation,
       _readWritableAdmission = readWritableAdmission,
       _nowUtc = nowUtc;

  static const Uuid _uuid = Uuid();
  static const int _minimumSafetyMarginBytes = 1024 * 1024 * 1024;

  final ArchiveAccessAuthority _archiveAccessAuthority;
  final AttachmentArchiveRelocationJournalStore _journalStore;
  final AttachmentArchiveRelocationMetadataReader _metadataReader;
  final AttachmentArchiveRelocationFileSystem _fileSystem;
  final AttachmentArchiveLocationNativeAdapter _nativeAdapter;
  final AttachmentArchiveRelocationActivationGate _activationGate;
  final AttachmentArchiveRelocationLocationReader _readLocation;
  final AttachmentArchiveRelocationActivator _activateLocation;
  final AttachmentArchiveRelocationActivator _restoreLocation;
  final AttachmentArchiveRelocationWritableAdmissionReader
  _readWritableAdmission;
  final DateTime Function() _nowUtc;

  Future<AttachmentArchiveRelocationProgress?> readCurrentProgress() async {
    final journal = await _journalStore.readCurrent();
    return journal == null
        ? null
        : AttachmentArchiveRelocationProgress.fromJournal(journal);
  }

  Future<AttachmentArchiveRelocationProgress> readProgress(
    String operationId,
  ) async {
    return AttachmentArchiveRelocationProgress.fromJournal(
      await _journalStore.read(operationId),
    );
  }

  Future<AttachmentArchiveRelocationProgress> prepareForReview({
    required String operationId,
    required ArchiveMutationCapability mutationCapability,
  }) async {
    _requireCapability(mutationCapability);
    var journal = await _journalStore.read(operationId);
    _requireJournalIdentity(journal);
    if (journal.stage == AttachmentArchiveRelocationStage.paused) {
      final resumeStage = journal.resumeStage;
      if (resumeStage == null ||
          resumeStage.index >
              AttachmentArchiveRelocationStage.inventoryComplete.index) {
        throw StateError(
          'This relocation is not paused in a preflight-review stage.',
        );
      }
      journal = await _save(
        journal.copyWith(
          stage: resumeStage,
          clearDeferredReason: true,
          clearResumeStage: true,
          clearFailure: true,
          updatedAtUtc: _nowUtc(),
        ),
      );
    }
    if (journal.stage.isTerminal) {
      return AttachmentArchiveRelocationProgress.fromJournal(journal);
    }

    try {
      while (true) {
        _requireCapability(mutationCapability);
        switch (journal.stage) {
          case AttachmentArchiveRelocationStage.selected:
            await _requireSourceStillAuthoritative(journal);
            journal = await _save(
              journal.copyWith(
                stage: AttachmentArchiveRelocationStage.preflighting,
                updatedAtUtc: _nowUtc(),
              ),
            );
            journal = await _runPreflight(
              journal,
              resumeStartedPreflight: false,
            );
            continue;
          case AttachmentArchiveRelocationStage.preflighting:
            await _requireSourceStillAuthoritative(journal);
            journal = await _runPreflight(
              journal,
              resumeStartedPreflight: true,
            );
            continue;
          case AttachmentArchiveRelocationStage.preflighted:
            await _requireSourceStillAuthoritative(journal);
            journal = await _save(
              journal.copyWith(
                stage: AttachmentArchiveRelocationStage.inventorying,
                updatedAtUtc: _nowUtc(),
              ),
            );
            continue;
          case AttachmentArchiveRelocationStage.inventorying:
            await _requireSourceStillAuthoritative(journal);
            journal = await _runInventory(journal);
            continue;
          case AttachmentArchiveRelocationStage.inventoryComplete:
            await _requireSourceStillAuthoritative(journal);
            final destinationParent = await _resolveDestinationParent(journal);
            final available = await _nativeAdapter
                .availableCapacityForImportantUsage(destinationParent);
            final required = _requiredCapacity(journal.expectedByteCount);
            journal = await _save(
              journal.copyWith(
                availableCapacityBytes: available,
                requiredCapacityBytes: required,
                updatedAtUtc: _nowUtc(),
              ),
            );
            if (available < required) {
              journal = await _pause(
                journal,
                resumeStage: AttachmentArchiveRelocationStage.inventoryComplete,
                reason: AttachmentArchiveRelocationDeferredReason
                    .insufficientCapacity,
              );
            }
            return AttachmentArchiveRelocationProgress.fromJournal(journal);
          case AttachmentArchiveRelocationStage.copying ||
              AttachmentArchiveRelocationStage.verifying ||
              AttachmentArchiveRelocationStage.destinationFinalizing ||
              AttachmentArchiveRelocationStage.destinationFinalized ||
              AttachmentArchiveRelocationStage.configurationSwitching ||
              AttachmentArchiveRelocationStage.activated ||
              AttachmentArchiveRelocationStage.sourceRetained ||
              AttachmentArchiveRelocationStage
                  .rollbackRestoredOldConfiguration ||
              AttachmentArchiveRelocationStage.cancelled ||
              AttachmentArchiveRelocationStage.failed:
            return AttachmentArchiveRelocationProgress.fromJournal(journal);
          case AttachmentArchiveRelocationStage.paused:
            throw StateError(
              'Paused preflight was not restored before preparation.',
            );
        }
      }
    } on AttachmentArchiveRelocationPreflightException catch (error) {
      final paused = await _pause(
        journal,
        resumeStage: journal.stage,
        reason: error.reason,
        failure: error.toString(),
      );
      return AttachmentArchiveRelocationProgress.fromJournal(paused);
    } on FileSystemException catch (error) {
      final paused = await _pause(
        journal,
        resumeStage: journal.stage,
        reason: _deferredReasonForFileSystemError(journal, error),
        failure: error.toString(),
      );
      return AttachmentArchiveRelocationProgress.fromJournal(paused);
    } on Object catch (error) {
      await _save(
        journal.copyWith(
          stage: AttachmentArchiveRelocationStage.failed,
          failure: error.toString(),
          updatedAtUtc: _nowUtc(),
        ),
      );
      rethrow;
    }
  }

  Future<AttachmentArchiveRelocationProgress> selectDestination({
    required String destinationParentPath,
    required ArchiveMutationCapability mutationCapability,
  }) async {
    _requireCapability(mutationCapability);
    final current = await _readLocation();
    final sourceConfiguration = current.configuration;
    final sourceRootPath = current.archiveRootPath;
    if (!current.isAvailable ||
        sourceConfiguration == null ||
        sourceRootPath == null) {
      throw StateError(
        'The authoritative attachment archive is unavailable for relocation.',
      );
    }
    final pending = await _journalStore.readCurrent();
    if (pending != null && !pending.stage.isTerminal) {
      throw StateError(
        'Attachment archive relocation ${pending.operationId} is still active.',
      );
    }

    final destinationBookmark = await _nativeAdapter.createBookmark(
      directoryPath: destinationParentPath,
    );
    _requireCapability(mutationCapability);
    final now = _nowUtc();
    final journal = AttachmentArchiveRelocationJournal.selected(
      operationId: _uuid.v4(),
      archiveInstanceId:
          _archiveAccessAuthority.identity.archiveInstanceId.value,
      sourceRootPath: path.normalize(path.absolute(sourceRootPath)),
      sourceConfiguration: sourceConfiguration,
      sourceLocationGeneration: current.generation,
      destinationParentBookmarkDataBase64:
          destinationBookmark.bookmarkDataBase64,
      destinationParentLastKnownPath: destinationBookmark.resolvedPath,
      destinationVolumeName: destinationBookmark.volumeName,
      nowUtc: now,
    );
    await _journalStore.create(journal);
    return AttachmentArchiveRelocationProgress.fromJournal(journal);
  }

  Future<AttachmentArchiveRelocationProgress> run({
    required String operationId,
    required ArchiveMutationCapability mutationCapability,
    int? pauseAfterNewlyCopiedFiles,
    AttachmentArchiveRelocationPauseRequestReader? pauseRequested,
  }) async {
    _requireCapability(mutationCapability);
    var journal = await _journalStore.read(operationId);
    _requireJournalIdentity(journal);
    if (journal.stage == AttachmentArchiveRelocationStage.paused) {
      final resumeStage = journal.resumeStage;
      if (resumeStage == null) {
        throw StateError('Paused relocation has no durable resume stage.');
      }
      journal = await _save(
        journal.copyWith(
          stage: resumeStage,
          clearDeferredReason: true,
          clearResumeStage: true,
          clearFailure: true,
          updatedAtUtc: _nowUtc(),
        ),
      );
    }
    if (journal.stage.isTerminal) {
      return AttachmentArchiveRelocationProgress.fromJournal(journal);
    }

    try {
      while (!journal.stage.isTerminal) {
        _requireCapability(mutationCapability);
        switch (journal.stage) {
          case AttachmentArchiveRelocationStage.selected:
            await _requireSourceStillAuthoritative(journal);
            journal = await _save(
              journal.copyWith(
                stage: AttachmentArchiveRelocationStage.preflighting,
                updatedAtUtc: _nowUtc(),
              ),
            );
            journal = await _runPreflight(
              journal,
              resumeStartedPreflight: false,
            );
            continue;
          case AttachmentArchiveRelocationStage.preflighting:
            await _requireSourceStillAuthoritative(journal);
            journal = await _runPreflight(
              journal,
              resumeStartedPreflight: true,
            );
            continue;
          case AttachmentArchiveRelocationStage.preflighted:
            await _requireSourceStillAuthoritative(journal);
            journal = await _save(
              journal.copyWith(
                stage: AttachmentArchiveRelocationStage.inventorying,
                updatedAtUtc: _nowUtc(),
              ),
            );
            journal = await _runInventory(journal);
            continue;
          case AttachmentArchiveRelocationStage.inventorying:
            await _requireSourceStillAuthoritative(journal);
            journal = await _runInventory(journal);
            continue;
          case AttachmentArchiveRelocationStage.inventoryComplete:
            await _requireSourceStillAuthoritative(journal);
            final destinationParent = await _resolveDestinationParent(journal);
            final available = await _nativeAdapter
                .availableCapacityForImportantUsage(destinationParent);
            final required = _requiredCapacity(journal.expectedByteCount);
            if (available < required) {
              journal = await _pause(
                journal.copyWith(
                  availableCapacityBytes: available,
                  requiredCapacityBytes: required,
                ),
                resumeStage: AttachmentArchiveRelocationStage.inventoryComplete,
                reason: AttachmentArchiveRelocationDeferredReason
                    .insufficientCapacity,
              );
              return AttachmentArchiveRelocationProgress.fromJournal(journal);
            }
            await _journalStore.beginCopyReceipts(operationId);
            journal = await _save(
              journal.copyWith(
                stage: AttachmentArchiveRelocationStage.copying,
                availableCapacityBytes: available,
                requiredCapacityBytes: required,
                copiedFileCount: 0,
                copiedByteCount: 0,
                updatedAtUtc: _nowUtc(),
              ),
            );
            continue;
          case AttachmentArchiveRelocationStage.copying:
            await _requireSourceStillAuthoritative(journal);
            final copyResult = await _runCopy(
              journal,
              pauseAfterNewlyCopiedFiles: pauseAfterNewlyCopiedFiles,
              pauseRequested: pauseRequested,
            );
            journal = copyResult.journal;
            if (copyResult.didPause) {
              return AttachmentArchiveRelocationProgress.fromJournal(journal);
            }
            continue;
          case AttachmentArchiveRelocationStage.verifying:
            await _requireSourceStillAuthoritative(journal);
            journal = await _runVerification(journal);
            continue;
          case AttachmentArchiveRelocationStage.destinationFinalizing:
            await _requireSourceStillAuthoritative(journal);
            journal = await _runFinalization(journal);
            continue;
          case AttachmentArchiveRelocationStage.destinationFinalized:
            await _requireSourceStillAuthoritative(journal);
            journal = await _prepareActivation(journal);
            continue;
          case AttachmentArchiveRelocationStage.configurationSwitching:
            journal = await _runActivation(journal);
            continue;
          case AttachmentArchiveRelocationStage.activated:
            await _requireRetainedSource(journal);
            journal = await _save(
              journal.copyWith(
                stage: AttachmentArchiveRelocationStage.sourceRetained,
                sourceRetained: true,
                updatedAtUtc: _nowUtc(),
              ),
            );
            continue;
          case AttachmentArchiveRelocationStage.sourceRetained ||
              AttachmentArchiveRelocationStage
                  .rollbackRestoredOldConfiguration ||
              AttachmentArchiveRelocationStage.cancelled ||
              AttachmentArchiveRelocationStage.failed:
            return AttachmentArchiveRelocationProgress.fromJournal(journal);
          case AttachmentArchiveRelocationStage.paused:
            throw StateError('Paused relocation was not restored for resume.');
        }
      }
      return AttachmentArchiveRelocationProgress.fromJournal(journal);
    } on AttachmentArchiveRelocationPreflightException catch (error) {
      final paused = await _pause(
        journal,
        resumeStage: journal.stage,
        reason: error.reason,
        failure: error.toString(),
      );
      return AttachmentArchiveRelocationProgress.fromJournal(paused);
    } on FileSystemException catch (error) {
      final paused = await _pause(
        journal,
        resumeStage: journal.stage,
        reason: _deferredReasonForFileSystemError(journal, error),
        failure: error.toString(),
      );
      return AttachmentArchiveRelocationProgress.fromJournal(paused);
    } on Object catch (error) {
      if (journal.stage ==
          AttachmentArchiveRelocationStage.configurationSwitching) {
        return AttachmentArchiveRelocationProgress.fromJournal(
          await _rollbackActivation(journal, error),
        );
      }
      await _save(
        journal.copyWith(
          stage: AttachmentArchiveRelocationStage.failed,
          failure: error.toString(),
          updatedAtUtc: _nowUtc(),
        ),
      );
      rethrow;
    }
  }

  Future<AttachmentArchiveRelocationProgress> cancel({
    required String operationId,
    required ArchiveMutationCapability mutationCapability,
  }) async {
    _requireCapability(mutationCapability);
    final journal = await _journalStore.read(operationId);
    _requireJournalIdentity(journal);
    if (journal.stage ==
            AttachmentArchiveRelocationStage.configurationSwitching ||
        journal.stage == AttachmentArchiveRelocationStage.activated ||
        journal.stage == AttachmentArchiveRelocationStage.sourceRetained) {
      throw StateError(
        'Attachment relocation cannot be cancelled after activation begins.',
      );
    }
    if (journal.stage.isTerminal) {
      return AttachmentArchiveRelocationProgress.fromJournal(journal);
    }
    final cancelled = await _save(
      journal.copyWith(
        stage: AttachmentArchiveRelocationStage.cancelled,
        clearDeferredReason: true,
        clearResumeStage: true,
        updatedAtUtc: _nowUtc(),
      ),
    );
    return AttachmentArchiveRelocationProgress.fromJournal(cancelled);
  }

  Future<AttachmentArchiveRelocationJournal> _runPreflight(
    AttachmentArchiveRelocationJournal journal, {
    required bool resumeStartedPreflight,
  }) async {
    final destinationParent = await _resolveDestinationParent(journal);
    final result = await _fileSystem.preflight(
      sourceRootPath: journal.sourceRootPath,
      destinationParentPath: destinationParent,
      stagingDirectoryName: journal.stagingDirectoryName,
      finalDirectoryName: journal.finalDirectoryName,
      resumeStartedPreflight: resumeStartedPreflight,
    );
    return _save(
      journal.copyWith(
        stage: AttachmentArchiveRelocationStage.preflighted,
        destinationParentLastKnownPath: destinationParent,
        availableCapacityBytes: result.availableCapacityBytes,
        updatedAtUtc: _nowUtc(),
      ),
    );
  }

  Future<AttachmentArchiveRelocationJournal> _runInventory(
    AttachmentArchiveRelocationJournal journal,
  ) async {
    await _journalStore.beginManifest(journal.operationId);
    final result = await _fileSystem.inventory(
      sourceRootPath: journal.sourceRootPath,
      metadataReader: _metadataReader,
      onEntry: (entry) => _journalStore.appendManifestEntry(
        operationId: journal.operationId,
        entry: entry,
      ),
    );
    await _fileSystem.verifyMetadataCoverage(
      sourceRootPath: journal.sourceRootPath,
      metadataReader: _metadataReader,
    );
    final manifestHash = await _journalStore.hashManifest(journal.operationId);
    return _save(
      journal.copyWith(
        stage: AttachmentArchiveRelocationStage.inventoryComplete,
        inventoryCompletedAtUtc: _nowUtc(),
        manifestSha256: manifestHash,
        expectedFileCount: result.fileCount,
        expectedByteCount: result.byteCount,
        metadataRowCount: result.metadataRowCount,
        unreferencedFileCount: result.unreferencedFileCount,
        operationalDebrisCount: result.operationalDebrisCount,
        requiredCapacityBytes: _requiredCapacity(result.byteCount),
        updatedAtUtc: _nowUtc(),
      ),
    );
  }

  Future<_CopyRunResult> _runCopy(
    AttachmentArchiveRelocationJournal journal, {
    required int? pauseAfterNewlyCopiedFiles,
    required AttachmentArchiveRelocationPauseRequestReader? pauseRequested,
  }) async {
    final reconciled = await _reconcileCopyReceipts(journal);
    journal = reconciled;
    final destinationParent = await _resolveDestinationParent(journal);
    final stagingRoot = path.join(
      destinationParent,
      journal.stagingDirectoryName,
    );
    var index = 0;
    var copiedThisRun = 0;
    await for (final entry in _journalStore.readManifest(journal.operationId)) {
      if (index < journal.copiedFileCount) {
        index++;
        continue;
      }
      final receipt = await _fileSystem.copyAndVerify(
        index: index,
        entry: entry,
        sourceRootPath: journal.sourceRootPath,
        stagingRootPath: stagingRoot,
      );
      await _journalStore.appendCopyReceipt(
        operationId: journal.operationId,
        receipt: receipt,
      );
      journal = await _save(
        journal.copyWith(
          copiedFileCount: journal.copiedFileCount + 1,
          copiedByteCount: journal.copiedByteCount + entry.sizeBytes,
          updatedAtUtc: _nowUtc(),
        ),
      );
      index++;
      copiedThisRun++;
      final testPauseReached =
          pauseAfterNewlyCopiedFiles != null &&
          copiedThisRun >= pauseAfterNewlyCopiedFiles;
      final userPauseRequested = pauseRequested?.call() ?? false;
      if ((testPauseReached || userPauseRequested) &&
          journal.copiedFileCount < journal.expectedFileCount) {
        return _CopyRunResult(
          journal: await _pause(
            journal,
            resumeStage: AttachmentArchiveRelocationStage.copying,
            reason: AttachmentArchiveRelocationDeferredReason.userPaused,
          ),
          didPause: true,
        );
      }
    }
    if (index != journal.expectedFileCount ||
        journal.copiedFileCount != journal.expectedFileCount ||
        journal.copiedByteCount != journal.expectedByteCount) {
      throw StateError('Relocation copy coverage is incomplete.');
    }
    return _CopyRunResult(
      journal: await _save(
        journal.copyWith(
          stage: AttachmentArchiveRelocationStage.verifying,
          verifiedFileCount: 0,
          verifiedByteCount: 0,
          updatedAtUtc: _nowUtc(),
        ),
      ),
      didPause: false,
    );
  }

  Future<AttachmentArchiveRelocationJournal> _reconcileCopyReceipts(
    AttachmentArchiveRelocationJournal journal,
  ) async {
    final manifests = StreamIterator(
      _journalStore.readManifest(journal.operationId),
    );
    var count = 0;
    var bytes = 0;
    try {
      await for (final receipt in _journalStore.readCopyReceipts(
        journal.operationId,
      )) {
        if (!await manifests.moveNext()) {
          throw StateError(
            'Relocation has more receipts than manifest entries.',
          );
        }
        final entry = manifests.current;
        if (receipt.index != count ||
            receipt.relativePath != entry.relativePath ||
            receipt.sizeBytes != entry.sizeBytes) {
          throw StateError('Relocation receipt does not match manifest order.');
        }
        count++;
        bytes += receipt.sizeBytes;
      }
    } finally {
      await manifests.cancel();
    }
    if (count > journal.expectedFileCount ||
        bytes > journal.expectedByteCount) {
      throw StateError('Relocation receipt totals exceed the manifest.');
    }
    if (count == journal.copiedFileCount && bytes == journal.copiedByteCount) {
      return journal;
    }
    if (count < journal.copiedFileCount || bytes < journal.copiedByteCount) {
      throw StateError(
        'Relocation journal claims receipts that are not durable.',
      );
    }
    return _save(
      journal.copyWith(
        copiedFileCount: count,
        copiedByteCount: bytes,
        updatedAtUtc: _nowUtc(),
      ),
    );
  }

  Future<AttachmentArchiveRelocationJournal> _runVerification(
    AttachmentArchiveRelocationJournal journal,
  ) async {
    journal = await _save(
      journal.copyWith(
        verifiedFileCount: 0,
        verifiedByteCount: 0,
        updatedAtUtc: _nowUtc(),
      ),
    );
    await _requireCurrentSourceInventoryMatchesJournal(journal);
    final destinationParent = await _resolveDestinationParent(journal);
    final stagingRoot = path.join(
      destinationParent,
      journal.stagingDirectoryName,
    );
    journal = await _verifyCompleteManifest(
      journal,
      destinationRootPath: stagingRoot,
      recordProgress: true,
    );
    await _fileSystem.verifyDestinationCoverage(
      destinationRootPath: stagingRoot,
      expectedFileCount: journal.expectedFileCount,
      expectedByteCount: journal.expectedByteCount,
    );
    return _save(
      journal.copyWith(
        stage: AttachmentArchiveRelocationStage.destinationFinalizing,
        updatedAtUtc: _nowUtc(),
      ),
    );
  }

  Future<AttachmentArchiveRelocationJournal> _runFinalization(
    AttachmentArchiveRelocationJournal journal,
  ) async {
    final destinationParent = await _resolveDestinationParent(journal);
    final stagingRoot = path.join(
      destinationParent,
      journal.stagingDirectoryName,
    );
    final finalRoot = path.join(destinationParent, journal.finalDirectoryName);
    final stagingType = FileSystemEntity.typeSync(
      stagingRoot,
      followLinks: false,
    );
    final finalType = FileSystemEntity.typeSync(finalRoot, followLinks: false);
    if (stagingType == FileSystemEntityType.directory &&
        finalType == FileSystemEntityType.notFound) {
      await _fileSystem.finalizeDestination(
        stagingRootPath: stagingRoot,
        finalRootPath: finalRoot,
      );
    } else if (stagingType != FileSystemEntityType.notFound ||
        finalType != FileSystemEntityType.directory) {
      throw StateError(
        'Relocation finalization state is ambiguous; neither source nor '
        'destination may be inferred authoritative.',
      );
    }
    return _save(
      journal.copyWith(
        stage: AttachmentArchiveRelocationStage.destinationFinalized,
        updatedAtUtc: _nowUtc(),
      ),
    );
  }

  Future<AttachmentArchiveRelocationJournal> _prepareActivation(
    AttachmentArchiveRelocationJournal journal,
  ) async {
    final destinationParent = await _resolveDestinationParent(journal);
    final finalRoot = path.join(destinationParent, journal.finalDirectoryName);
    await _requireCurrentSourceInventoryMatchesJournal(journal);
    await _verifyCompleteManifest(
      journal,
      destinationRootPath: finalRoot,
      recordProgress: false,
    );
    await _fileSystem.verifyDestinationCoverage(
      destinationRootPath: finalRoot,
      expectedFileCount: journal.expectedFileCount,
      expectedByteCount: journal.expectedByteCount,
    );
    final bookmark = await _nativeAdapter.createBookmark(
      directoryPath: finalRoot,
    );
    final intended = AttachmentArchiveLocationConfiguration.customExternal(
      bookmarkDataBase64: bookmark.bookmarkDataBase64,
      lastKnownPath: bookmark.resolvedPath,
      volumeName: bookmark.volumeName,
      customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
    );
    return _save(
      journal.copyWith(
        stage: AttachmentArchiveRelocationStage.configurationSwitching,
        intendedConfiguration: intended,
        updatedAtUtc: _nowUtc(),
      ),
    );
  }

  Future<AttachmentArchiveRelocationJournal> _runActivation(
    AttachmentArchiveRelocationJournal journal,
  ) async {
    final intended = journal.intendedConfiguration;
    if (intended == null) {
      throw StateError('Relocation activation configuration is missing.');
    }
    final permit = await _activationGate.issuePermit(journal.operationId);
    final current = await _readLocation();
    if (current.configuration == journal.previousConfiguration) {
      await _activateLocation(
        configuration: intended,
        activationPermit: permit,
      );
    } else if (current.configuration != intended) {
      throw StateError(
        'Relocation activation found an unrelated authoritative '
        'configuration.',
      );
    }
    await _validateActivatedLocation(journal, permit);
    return _save(
      journal.copyWith(
        stage: AttachmentArchiveRelocationStage.activated,
        activationOccurred: true,
        updatedAtUtc: _nowUtc(),
      ),
    );
  }

  Future<void> _validateActivatedLocation(
    AttachmentArchiveRelocationJournal journal,
    AttachmentArchiveRelocationActivationPermit permit,
  ) async {
    final current = await _readLocation();
    final intended = journal.intendedConfiguration;
    if (current.configuration != intended ||
        current.availability !=
            AttachmentArchiveLocationAvailability.customAvailable ||
        current.archiveRootPath == null) {
      throw StateError(
        'Activated attachment archive did not resolve normally.',
      );
    }
    final resolvedRoot = path.normalize(
      await Directory(current.archiveRootPath!).resolveSymbolicLinks(),
    );
    final destinationParent = await _resolveDestinationParent(journal);
    final expectedRoot = path.normalize(
      await Directory(
        path.join(destinationParent, journal.finalDirectoryName),
      ).resolveSymbolicLinks(),
    );
    if (resolvedRoot != expectedRoot) {
      throw StateError(
        'Activated attachment archive resolved to another root.',
      );
    }
    await _verifyCompleteManifest(
      journal,
      destinationRootPath: resolvedRoot,
      recordProgress: false,
    );
    await _fileSystem.verifyDestinationCoverage(
      destinationRootPath: resolvedRoot,
      expectedFileCount: journal.expectedFileCount,
      expectedByteCount: journal.expectedByteCount,
    );
    final admission = await _readWritableAdmission();
    final lease = admission.lease;
    if (lease == null || lease.archiveRootPath != current.archiveRootPath) {
      throw StateError(
        'Verified external archive did not receive writable-root authority.',
      );
    }
    await lease.requireValid(
      operation: ArchiveMutationOperation.attachmentRelocation,
      boundary: AttachmentArchiveMutationBoundary.operationStart,
    );
    permit.requireActivationConfiguration(intended!);
  }

  Future<AttachmentArchiveRelocationJournal> _rollbackActivation(
    AttachmentArchiveRelocationJournal journal,
    Object activationError,
  ) async {
    final permit = await _activationGate.issuePermit(journal.operationId);
    final currentBeforeRollback = await _readLocation();
    final switched =
        currentBeforeRollback.configuration == journal.intendedConfiguration;
    await _restoreLocation(
      configuration: journal.previousConfiguration,
      activationPermit: permit,
    );
    final restored = await _readLocation();
    if (restored.configuration != journal.previousConfiguration ||
        restored.archiveRootPath == null ||
        path.normalize(path.absolute(restored.archiveRootPath!)) !=
            journal.sourceRootPath) {
      throw StateError(
        'Relocation activation rollback could not prove the old archive '
        'authoritative.',
      );
    }
    await _requireRetainedSource(journal);
    return _save(
      journal.copyWith(
        stage:
            AttachmentArchiveRelocationStage.rollbackRestoredOldConfiguration,
        activationOccurred: switched,
        sourceRetained: true,
        failure: activationError.toString(),
        updatedAtUtc: _nowUtc(),
      ),
    );
  }

  Future<AttachmentArchiveRelocationJournal> _verifyCompleteManifest(
    AttachmentArchiveRelocationJournal journal, {
    required String destinationRootPath,
    required bool recordProgress,
  }) async {
    final manifests = StreamIterator(
      _journalStore.readManifest(journal.operationId),
    );
    final receipts = StreamIterator(
      _journalStore.readCopyReceipts(journal.operationId),
    );
    var count = 0;
    var bytes = 0;
    try {
      while (await manifests.moveNext()) {
        if (!await receipts.moveNext()) {
          throw StateError('Relocation verification receipt is missing.');
        }
        final entry = manifests.current;
        final receipt = receipts.current;
        if (receipt.index != count) {
          throw StateError('Relocation verification receipt order is invalid.');
        }
        await _fileSystem.verifyReceipt(
          entry: entry,
          receipt: receipt,
          sourceRootPath: journal.sourceRootPath,
          destinationRootPath: destinationRootPath,
        );
        count++;
        bytes += entry.sizeBytes;
        if (recordProgress) {
          journal = await _save(
            journal.copyWith(
              verifiedFileCount: count,
              verifiedByteCount: bytes,
              updatedAtUtc: _nowUtc(),
            ),
          );
        }
      }
      if (await receipts.moveNext()) {
        throw StateError('Relocation has unexpected extra copy receipts.');
      }
    } finally {
      await manifests.cancel();
      await receipts.cancel();
    }
    if (count != journal.expectedFileCount ||
        bytes != journal.expectedByteCount) {
      throw StateError('Relocation verification coverage is incomplete.');
    }
    return journal;
  }

  Future<void> _requireCurrentSourceInventoryMatchesJournal(
    AttachmentArchiveRelocationJournal journal,
  ) async {
    final currentInventory = await _fileSystem.inventory(
      sourceRootPath: journal.sourceRootPath,
      metadataReader: _metadataReader,
      onEntry: (_) async {},
    );
    await _fileSystem.verifyMetadataCoverage(
      sourceRootPath: journal.sourceRootPath,
      metadataReader: _metadataReader,
    );
    if (currentInventory.fileCount != journal.expectedFileCount ||
        currentInventory.byteCount != journal.expectedByteCount ||
        currentInventory.metadataRowCount != journal.metadataRowCount ||
        currentInventory.unreferencedFileCount !=
            journal.unreferencedFileCount ||
        currentInventory.operationalDebrisCount !=
            journal.operationalDebrisCount) {
      throw StateError(
        'Relocation source inventory changed before activation.',
      );
    }
  }

  Future<String> _resolveDestinationParent(
    AttachmentArchiveRelocationJournal journal,
  ) async {
    final resolution = await _nativeAdapter.resolveBookmark(
      bookmarkDataBase64: journal.destinationParentBookmarkDataBase64,
    );
    if (resolution.status !=
            AttachmentArchiveBookmarkResolutionStatus.available ||
        resolution.resolvedPath == null) {
      throw FileSystemException(
        resolution.issue ?? 'Relocation destination is unavailable.',
        journal.destinationParentLastKnownPath,
      );
    }
    return path.normalize(path.absolute(resolution.resolvedPath!));
  }

  Future<void> _requireSourceStillAuthoritative(
    AttachmentArchiveRelocationJournal journal,
  ) async {
    final current = await _readLocation();
    if (!current.isAvailable || current.archiveRootPath == null) {
      throw AttachmentArchiveRelocationPreflightException(
        reason: AttachmentArchiveRelocationDeferredReason.sourceUnavailable,
        message: 'The authoritative relocation source is unavailable.',
        path: journal.sourceRootPath,
      );
    }
    if (current.configuration != journal.sourceConfiguration ||
        current.generation != journal.sourceLocationGeneration ||
        path.normalize(path.absolute(current.archiveRootPath!)) !=
            journal.sourceRootPath) {
      throw StateError(
        'The relocation source is no longer the authoritative archive.',
      );
    }
  }

  Future<void> _requireRetainedSource(
    AttachmentArchiveRelocationJournal journal,
  ) async {
    if (FileSystemEntity.typeSync(journal.sourceRootPath, followLinks: false) !=
        FileSystemEntityType.directory) {
      throw StateError('The retained relocation source is unavailable.');
    }
  }

  Future<AttachmentArchiveRelocationJournal> _pause(
    AttachmentArchiveRelocationJournal journal, {
    required AttachmentArchiveRelocationStage resumeStage,
    required AttachmentArchiveRelocationDeferredReason reason,
    String? failure,
  }) {
    return _save(
      journal.copyWith(
        stage: AttachmentArchiveRelocationStage.paused,
        resumeStage: resumeStage,
        deferredReason: reason,
        failure: failure,
        updatedAtUtc: _nowUtc(),
      ),
    );
  }

  Future<AttachmentArchiveRelocationJournal> _save(
    AttachmentArchiveRelocationJournal journal,
  ) async {
    await _journalStore.save(journal);
    return journal;
  }

  void _requireJournalIdentity(AttachmentArchiveRelocationJournal journal) {
    if (journal.archiveInstanceId !=
        _archiveAccessAuthority.identity.archiveInstanceId.value) {
      throw StateError(
        'Attachment relocation journal belongs to another archive instance.',
      );
    }
  }

  static void _requireCapability(ArchiveMutationCapability capability) {
    capability.requireOperation(ArchiveMutationOperation.attachmentRelocation);
  }

  static int _requiredCapacity(int sourceBytes) {
    final proportionalMargin = sourceBytes ~/ 20;
    final margin = proportionalMargin > _minimumSafetyMarginBytes
        ? proportionalMargin
        : _minimumSafetyMarginBytes;
    return sourceBytes + margin;
  }

  static AttachmentArchiveRelocationDeferredReason
  _deferredReasonForFileSystemError(
    AttachmentArchiveRelocationJournal journal,
    FileSystemException error,
  ) {
    final errorPath = error.path;
    if (errorPath != null) {
      final normalized = path.normalize(path.absolute(errorPath));
      if (normalized == journal.sourceRootPath ||
          path.isWithin(journal.sourceRootPath, normalized)) {
        return AttachmentArchiveRelocationDeferredReason.sourceUnavailable;
      }
    }
    return AttachmentArchiveRelocationDeferredReason.destinationUnavailable;
  }

  static DateTime _defaultNowUtc() => DateTime.now().toUtc();
}

final class _CopyRunResult {
  const _CopyRunResult({required this.journal, required this.didPause});

  final AttachmentArchiveRelocationJournal journal;
  final bool didPause;
}
