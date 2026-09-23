import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../../essentials/archive_environment/domain.dart'
    show ArchiveMutationOperation;
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability, archiveMutationCoordinatorProvider;
import '../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../domain/entities/attachment_recovery_metadata.dart';
import 'archive_settings_provider.dart';
import 'attachment_archive_file_store.dart';
import 'attachment_archive_location_provider.dart';
import 'attachment_archive_settings_store.dart';
import 'attachment_archive_settings_store_provider.dart';
import 'attachment_archive_store_providers.dart'
    show
        attachmentArchiveFileStoreProvider,
        attachmentArchiveWriteStoreProvider;
import 'attachment_archive_write_store.dart';
import 'graph_attachment_archive_candidate_reader.dart';
import 'graph_attachment_archive_providers.dart'
    show
        currentMessagesAttachmentPathLookupProvider,
        graphAttachmentArchiveCandidateReaderProvider;

part 'attachment_archive_service_provider.g.dart';

const _kDefaultGraphSweepLimit = 100;
const _kGraphSweepSelectionPageSize = 250;
const _kManualSweepBurstChunkCount = 25;
const _kManualSweepSkippedSampleLimit = 3;

/// Service that copies attachment files into the MessageLens archive and
/// records them through the attachment archive store.
///
/// Archiving is idempotent: if an archive record already exists for the
/// derived archive compatibility key, the file is not re-copied.
@Riverpod(keepAlive: true)
class AttachmentArchiveService extends _$AttachmentArchiveService {
  bool _pauseRequested = false;
  bool _cancelRequested = false;
  bool _graphSweepInFlight = false;

  @override
  BulkArchiveProgress build() {
    return const BulkArchiveProgress(phase: BulkArchivePhase.idle);
  }

  /// Archive a single attachment file if not already archived.
  ///
  Future<AttachmentArchiveIngestionOutcome> archiveAttachment({
    required ArchiveCompatibilityKey archiveKey,
    required String resolvedLocalPath,
    required String? mimeType,
    required String? sha256Hex,
  }) {
    return _runAttachmentMutation(
      ownerLabel: 'attachment-single-archive',
      onDeferred: AttachmentArchiveIngestionOutcome.deferred,
      action: (mutationCapability, writableRootLease) => _archiveAttachment(
        mutationCapability: mutationCapability,
        writableRootLease: writableRootLease,
        archiveKey: archiveKey,
        resolvedLocalPath: resolvedLocalPath,
        mimeType: mimeType,
        sha256Hex: sha256Hex,
      ),
    );
  }

  Future<AttachmentArchiveIngestionOutcome> _archiveAttachment({
    required ArchiveMutationCapability mutationCapability,
    required AttachmentArchiveWritableRootLease writableRootLease,
    required ArchiveCompatibilityKey archiveKey,
    required String resolvedLocalPath,
    required String? mimeType,
    required String? sha256Hex,
  }) async {
    final archiveStore = await ref.read(
      attachmentArchiveWriteStoreProvider.future,
    );
    final fileStore = ref.read(attachmentArchiveFileStoreProvider);

    // Idempotency check: skip if already archived.
    final alreadyArchived = await archiveStore.hasArchiveRecord(archiveKey);

    if (alreadyArchived) {
      await archiveStore.clearRecoveryHint(archiveKey);
      return const AttachmentArchiveIngestionOutcome.alreadyArchived();
    }

    final sourcePath = await _resolveArchivableSourcePath(
      preferredLocalPath: resolvedLocalPath,
      archiveKey: archiveKey,
    );
    if (sourcePath == null) {
      return const AttachmentArchiveIngestionOutcome.sourceMissing();
    }

    late final ArchivedAttachmentFileWrite archiveWrite;
    try {
      final writeResult = await fileStore.writeArchiveEntry(
        archiveDirectoryPath: writableRootLease.archiveRootPath,
        sourcePath: sourcePath,
        archiveKey: archiveKey,
        sha256Hex: sha256Hex,
        validateMutation: (boundary) async {
          mutationCapability.requireOperation(
            ArchiveMutationOperation.attachmentReconciliation,
          );
          await writableRootLease.requireValid(
            operation: ArchiveMutationOperation.attachmentReconciliation,
            boundary: boundary,
          );
        },
      );
      if (writeResult == null) {
        return const AttachmentArchiveIngestionOutcome.failed();
      }
      archiveWrite = writeResult;
    } on AttachmentArchiveMutationDeferredException {
      rethrow;
    } on Object catch (error) {
      final validation = await writableRootLease.validate(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        boundary: AttachmentArchiveMutationBoundary.beforePayloadVerification,
      );
      if (!validation.isValid) {
        throw AttachmentArchiveMutationDeferredException(
          reason: validation.deferredReason!,
          boundary: AttachmentArchiveMutationBoundary.beforePayloadVerification,
          issue: validation.issue,
        );
      }
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Failed to archive attachment '
            '${archiveKey.liveSourceAttachmentRowId}: $error',
            source: 'AttachmentArchiveService',
          );
      return const AttachmentArchiveIngestionOutcome.failed();
    }

    await writableRootLease.requireValid(
      operation: ArchiveMutationOperation.attachmentReconciliation,
      boundary: AttachmentArchiveMutationBoundary.beforeMetadataCommit,
    );
    await archiveStore.writeArchiveRecord(
      ArchivedAttachmentWrite(
        archiveKey: archiveKey,
        archiveRelativePath: archiveWrite.relativePath,
        archivedAtUtc: DateTime.now().toUtc().toIso8601String(),
        fileSizeBytes: archiveWrite.fileSizeBytes,
        contentHash: archiveWrite.contentHash,
        originalLocalPath: archiveWrite.sourcePath,
      ),
    );

    await archiveStore.clearRecoveryHint(archiveKey);

    return const AttachmentArchiveIngestionOutcome.archived();
  }

  Future<void> prioritizeRecovery({
    required ArchiveCompatibilityKey archiveKey,
    required String? resolvedLocalPath,
    required String? mimeType,
  }) {
    return _prioritizeRecovery(
      archiveKey: archiveKey,
      resolvedLocalPath: resolvedLocalPath,
      mimeType: mimeType,
    );
  }

  Future<void> _prioritizeRecovery({
    required ArchiveCompatibilityKey archiveKey,
    required String? resolvedLocalPath,
    required String? mimeType,
  }) async {
    final settings = await ref.read(archiveSettingsProvider.future);
    if (!settings.isEnabled) {
      return;
    }

    final archiveStore = await ref.read(
      attachmentArchiveWriteStoreProvider.future,
    );
    final existingHint = await archiveStore.readRecoveryHint(archiveKey);
    final now = DateTime.now().toUtc();
    final currentPriority = existingHint?.recoveryPriority ?? 0;

    final prioritizedHint = AttachmentRecoveryMetadata(
      lastRecoveryAttemptAt: existingHint?.lastRecoveryAttemptAt,
      nextRecoveryAttemptAt: now,
      recoveryAttemptCount: existingHint?.recoveryAttemptCount ?? 0,
      recoveryPriority: currentPriority >= 10 ? currentPriority : 10,
      userInterestRaisedAt: now,
      lastRecoveryErrorSummary: existingHint?.lastRecoveryErrorSummary,
      isNonRecoverable: existingHint?.isNonRecoverable ?? false,
    );

    await archiveStore.writeRecoveryHint(
      archiveKey: archiveKey,
      metadata: prioritizedHint,
    );

    if (resolvedLocalPath == null || resolvedLocalPath.isEmpty) {
      return;
    }

    final fileStore = ref.read(attachmentArchiveFileStoreProvider);
    if (!fileStore.fileExists(fileStore.expandHomePath(resolvedLocalPath))) {
      return;
    }

    unawaited(
      archiveAttachment(
        archiveKey: archiveKey,
        resolvedLocalPath: resolvedLocalPath,
        mimeType: mimeType,
        sha256Hex: null,
      ),
    );
  }

  Future<AttachmentArchiveResult> archiveGraphMessageSourceRange({
    required int sourceId,
    required int startedAfterSourceRowId,
    required int? lastImportedSourceRowId,
  }) {
    return _runAttachmentMutation(
      ownerLabel: 'attachment-live-source-range',
      onDeferred: AttachmentArchiveResult.deferred,
      action: (mutationCapability, writableRootLease) =>
          _archiveGraphMessageSourceRange(
            mutationCapability: mutationCapability,
            writableRootLease: writableRootLease,
            sourceId: sourceId,
            startedAfterSourceRowId: startedAfterSourceRowId,
            lastImportedSourceRowId: lastImportedSourceRowId,
          ),
    );
  }

  Future<AttachmentArchiveResult> _archiveGraphMessageSourceRange({
    required ArchiveMutationCapability mutationCapability,
    required AttachmentArchiveWritableRootLease writableRootLease,
    required int sourceId,
    required int startedAfterSourceRowId,
    required int? lastImportedSourceRowId,
  }) async {
    final lastSourceRowId = lastImportedSourceRowId;
    if (lastSourceRowId == null || lastSourceRowId <= startedAfterSourceRowId) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    final settings = await ref.read(archiveSettingsProvider.future);
    if (!settings.isEnabled) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    final candidateReader = await ref.read(
      graphAttachmentArchiveCandidateReaderProvider.future,
    );
    final logger = ref.read(appLoggerProvider.notifier);

    final rows = await candidateReader.readSourceRange(
      sourceId: sourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
      lastSourceRowId: lastSourceRowId,
    );

    final archiveOutcome = await _archiveRows(
      mutationCapability: mutationCapability,
      writableRootLease: writableRootLease,
      rows: rows,
      updateProgressState: false,
    );
    final result = archiveOutcome.result;

    logger.info(
      'Attachment archive graph source range '
      '$startedAfterSourceRowId-$lastSourceRowId: '
      '${result.newlyArchived} new, ${result.skipped} skipped, '
      '${result.failed} failed out of ${result.totalScanned} attachment(s)',
      source: 'AttachmentArchiveService',
    );

    ref.invalidate(archiveSettingsProvider);

    return result;
  }

  /// Sweep a small rolling chunk of conventional graph attachments that are
  /// not yet archived but may now exist in Messages/Attachments.
  ///
  /// This is intentionally low-cost: it advances by graph attachment ID,
  /// touches only a bounded chunk per invocation, and persists its cursor in
  /// overlay settings so delayed iCloud downloads are eventually archived.
  /// Opaque NULL/blank-MIME payloads remain excluded pending a preservation
  /// policy.
  Future<AttachmentArchiveResult> archiveNextGraphSweepChunk({
    int limit = _kDefaultGraphSweepLimit,
    bool updateSweepDebugState = true,
  }) {
    return _runAttachmentMutation(
      ownerLabel: 'attachment-graph-sweep-chunk',
      onDeferred: AttachmentArchiveResult.deferred,
      action: (mutationCapability, writableRootLease) =>
          _archiveNextGraphSweepChunk(
            mutationCapability: mutationCapability,
            writableRootLease: writableRootLease,
            limit: limit,
            updateSweepDebugState: updateSweepDebugState,
          ),
    );
  }

  Future<AttachmentArchiveResult> _archiveNextGraphSweepChunk({
    required ArchiveMutationCapability mutationCapability,
    required AttachmentArchiveWritableRootLease writableRootLease,
    required int limit,
    required bool updateSweepDebugState,
  }) async {
    if (limit <= 0) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    final settings = await ref.read(archiveSettingsProvider.future);
    if (!settings.isEnabled) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    if (_graphSweepInFlight) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    _graphSweepInFlight = true;

    try {
      final settingsStore = await ref.read(
        attachmentArchiveSettingsStoreProvider.future,
      );
      final candidateReader = await ref.read(
        graphAttachmentArchiveCandidateReaderProvider.future,
      );
      final logger = ref.read(appLoggerProvider.notifier);
      final startedAtUtc = DateTime.now().toUtc().toIso8601String();

      final cursor = await _readGraphSweepCursor(settingsStore);
      final selection = await candidateReader.selectSweepCandidates(
        afterAttachmentId: cursor,
        limit: limit,
        pageSize: _kGraphSweepSelectionPageSize,
      );

      final archiveOutcome = await _archiveRows(
        mutationCapability: mutationCapability,
        writableRootLease: writableRootLease,
        rows: selection.rows,
        updateProgressState: false,
      );
      final result = archiveOutcome.result;
      if (result.isDeferred) {
        return result;
      }
      if (updateSweepDebugState) {
        final completedAtUtc = DateTime.now().toUtc().toIso8601String();
        await _writeGraphSweepStatus(
          settingsStore,
          startedAtUtc: startedAtUtc,
          completedAtUtc: completedAtUtc,
          nextCursor: selection.nextCursor,
          result: result,
        );
      } else {
        await _writeGraphSweepCursor(
          settingsStore,
          nextCursor: selection.nextCursor,
        );
      }

      logger.debug(
        'Graph attachment sweep: ${result.newlyArchived} new, '
        '${result.skipped} skipped, ${result.failed} failed out of '
        '${result.totalScanned} attachment(s); next cursor ${selection.nextCursor}',
        source: 'AttachmentArchiveService',
      );

      ref.invalidate(archiveSettingsProvider);

      return result;
    } finally {
      _graphSweepInFlight = false;
    }
  }

  /// Run a stronger manual sweep for developer tooling.
  ///
  /// This scans multiple regular sweep chunks in one call, stopping once it
  /// reaches the end of the current cursor cycle so it does not rescan the
  /// same tail candidates repeatedly inside a single manual run.
  Future<AttachmentArchiveResult> archiveGraphSweepBurst({
    int chunkLimit = _kDefaultGraphSweepLimit,
    int maxChunks = _kManualSweepBurstChunkCount,
  }) {
    return _runAttachmentMutation(
      ownerLabel: 'attachment-graph-sweep-burst',
      onDeferred: AttachmentArchiveResult.deferred,
      action: (mutationCapability, writableRootLease) =>
          _archiveGraphSweepBurst(
            mutationCapability: mutationCapability,
            writableRootLease: writableRootLease,
            chunkLimit: chunkLimit,
            maxChunks: maxChunks,
          ),
    );
  }

  Future<AttachmentArchiveResult> _archiveGraphSweepBurst({
    required ArchiveMutationCapability mutationCapability,
    required AttachmentArchiveWritableRootLease writableRootLease,
    required int chunkLimit,
    required int maxChunks,
  }) async {
    if (chunkLimit <= 0 || maxChunks <= 0) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    final settings = await ref.read(archiveSettingsProvider.future);
    if (!settings.isEnabled) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    if (_graphSweepInFlight) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    _graphSweepInFlight = true;

    try {
      final settingsStore = await ref.read(
        attachmentArchiveSettingsStoreProvider.future,
      );
      final candidateReader = await ref.read(
        graphAttachmentArchiveCandidateReaderProvider.future,
      );
      final startedAtUtc = DateTime.now().toUtc().toIso8601String();
      var cursor = await _readGraphSweepCursor(settingsStore);
      var totalScanned = 0;
      var newlyArchived = 0;
      var skipped = 0;
      var failed = 0;
      final skippedSamples = <String>[];

      for (var index = 0; index < maxChunks; index++) {
        final previousCursor = cursor;
        final selection = await candidateReader.selectSweepCandidates(
          afterAttachmentId: cursor,
          limit: chunkLimit,
          pageSize: _kGraphSweepSelectionPageSize,
        );
        final archiveOutcome = await _archiveRows(
          mutationCapability: mutationCapability,
          writableRootLease: writableRootLease,
          rows: selection.rows,
          updateProgressState: false,
          skippedSampleLimit:
              _kManualSweepSkippedSampleLimit - skippedSamples.length,
        );
        final result = archiveOutcome.result;
        totalScanned += result.totalScanned;
        newlyArchived += result.newlyArchived;
        skipped += result.skipped;
        failed += result.failed;
        skippedSamples.addAll(archiveOutcome.skippedSamples);

        if (result.isDeferred) {
          return AttachmentArchiveResult(
            totalScanned: totalScanned,
            newlyArchived: newlyArchived,
            skipped: skipped,
            failed: failed,
            deferred: result.deferred,
            deferredReason: result.deferredReason,
          );
        }

        cursor = selection.nextCursor;
        await _writeGraphSweepCursor(settingsStore, nextCursor: cursor);

        if (result.totalScanned == 0) {
          break;
        }

        if (cursor == 0) {
          break;
        }

        if (previousCursor > 0 && cursor <= previousCursor) {
          break;
        }
      }

      final burstResult = AttachmentArchiveResult(
        totalScanned: totalScanned,
        newlyArchived: newlyArchived,
        skipped: skipped,
        failed: failed,
      );

      final completedAtUtc = DateTime.now().toUtc().toIso8601String();
      await _writeManualSweepBurstStatus(
        settingsStore,
        startedAtUtc: startedAtUtc,
        completedAtUtc: completedAtUtc,
        result: burstResult,
        skippedSamples: skippedSamples,
      );

      ref.invalidate(archiveSettingsProvider);

      return burstResult;
    } finally {
      _graphSweepInFlight = false;
    }
  }

  /// Archive all locally available attachments from the conversation graph.
  ///
  /// Intended for manual graph archive sweeps. Live graph updates use
  /// source-row-range archiving instead. Runs in the background without
  /// blocking the UI. Emits [BulkArchiveProgress] state updates and supports
  /// pause/cancel.
  Future<AttachmentArchiveResult> archiveAllAvailable() {
    return _runAttachmentMutation(
      ownerLabel: 'attachment-archive-all',
      onDeferred: AttachmentArchiveResult.deferred,
      action: _archiveAllAvailable,
    );
  }

  Future<AttachmentArchiveResult> _archiveAllAvailable(
    ArchiveMutationCapability mutationCapability,
    AttachmentArchiveWritableRootLease writableRootLease,
  ) async {
    _pauseRequested = false;
    _cancelRequested = false;

    // Respect the user's archive-enabled preference.
    final settings = await ref.read(archiveSettingsProvider.future);
    if (!settings.isEnabled) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    final candidateReader = await ref.read(
      graphAttachmentArchiveCandidateReaderProvider.future,
    );
    final fileStore = ref.read(attachmentArchiveFileStoreProvider);
    final logger = ref.read(appLoggerProvider.notifier);

    // Ensure archive directory exists.
    await fileStore.ensureArchiveDirectory(
      writableRootLease.archiveRootPath,
      validateMutation: (boundary) async {
        mutationCapability.requireOperation(
          ArchiveMutationOperation.attachmentReconciliation,
        );
        await writableRootLease.requireValid(
          operation: ArchiveMutationOperation.attachmentReconciliation,
          boundary: boundary,
        );
      },
    );

    final rows = await candidateReader.readAllAvailableLive();

    final archiveOutcome = await _archiveRows(
      mutationCapability: mutationCapability,
      writableRootLease: writableRootLease,
      rows: rows,
      updateProgressState: true,
    );
    final result = archiveOutcome.result;

    logger.info(
      'Attachment archive: ${result.newlyArchived} new, ${result.skipped} '
      'skipped, ${result.failed} failed out of ${result.totalScanned} '
      'attachments',
      source: 'AttachmentArchiveService',
    );

    state = BulkArchiveProgress(
      phase: BulkArchivePhase.complete,
      totalItems: result.totalScanned,
      processedItems: result.totalScanned,
      newlyArchived: result.newlyArchived,
    );

    ref.invalidate(archiveSettingsProvider);

    return result;
  }

  Future<T> _runAttachmentMutation<T>({
    required String ownerLabel,
    required T Function(AttachmentArchiveMutationDeferredReason reason)
    onDeferred,
    required Future<T> Function(
      ArchiveMutationCapability mutationCapability,
      AttachmentArchiveWritableRootLease writableRootLease,
    )
    action,
  }) {
    return ref
        .read(archiveMutationCoordinatorProvider.notifier)
        .runWithCapability<T>(
          operation: ArchiveMutationOperation.attachmentReconciliation,
          ownerLabel: ownerLabel,
          action: (mutationCapability) async {
            final admission = await ref.read(
              attachmentArchiveWritableRootAdmissionProvider.future,
            );
            final writableRootLease = admission.lease;
            if (writableRootLease == null) {
              return onDeferred(admission.deferredReason!);
            }
            try {
              await writableRootLease.requireValid(
                operation: ArchiveMutationOperation.attachmentReconciliation,
                boundary: AttachmentArchiveMutationBoundary.operationStart,
              );
              return await action(mutationCapability, writableRootLease);
            } on AttachmentArchiveMutationDeferredException catch (error) {
              return onDeferred(error.reason);
            }
          },
        );
  }

  Future<_ArchiveRowsOutcome> _archiveRows({
    required ArchiveMutationCapability mutationCapability,
    required AttachmentArchiveWritableRootLease writableRootLease,
    required List<GraphAttachmentArchiveCandidate> rows,
    required bool updateProgressState,
    int skippedSampleLimit = 0,
  }) async {
    if (updateProgressState) {
      state = BulkArchiveProgress(
        phase: BulkArchivePhase.running,
        totalItems: rows.length,
      );
    }

    var archived = 0;
    var skipped = 0;
    var failed = 0;
    var deferred = 0;
    AttachmentArchiveMutationDeferredReason? deferredReason;
    final skippedSamples = <String>[];
    final fileStore = ref.read(attachmentArchiveFileStoreProvider);

    for (final row in rows) {
      // Handle cancellation.
      if (_cancelRequested) {
        if (updateProgressState) {
          state = const BulkArchiveProgress(phase: BulkArchivePhase.idle);
        }
        break;
      }

      // Handle pause — spin-wait until resumed or cancelled.
      while (_pauseRequested && !_cancelRequested) {
        if (updateProgressState) {
          state = state.copyWith(phase: BulkArchivePhase.paused);
        }
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      if (_cancelRequested) {
        if (updateProgressState) {
          state = const BulkArchiveProgress(phase: BulkArchivePhase.idle);
        }
        break;
      }
      if (updateProgressState && state.phase == BulkArchivePhase.paused) {
        state = state.copyWith(phase: BulkArchivePhase.running);
      }

      final archiveKey = row.archiveCompatibilityKey;
      final localPath = row.localPath;

      if (archiveKey == null || localPath == null) {
        skipped++;
        _recordSkippedSample(
          skippedSamples,
          archiveKey: archiveKey,
          localPath: localPath,
          reason: 'missing metadata',
          sampleLimit: skippedSampleLimit,
        );
        continue;
      }

      final resolvedPath = fileStore.expandHomePath(localPath);

      final archivablePath = await _resolveArchivableSourcePath(
        preferredLocalPath: resolvedPath,
        archiveKey: archiveKey,
      );
      if (archivablePath == null) {
        skipped++;
        _recordSkippedSample(
          skippedSamples,
          archiveKey: archiveKey,
          localPath: resolvedPath,
          reason: 'source missing',
          sampleLimit: skippedSampleLimit,
        );
        continue;
      }

      try {
        final outcome = await _archiveAttachment(
          mutationCapability: mutationCapability,
          writableRootLease: writableRootLease,
          archiveKey: archiveKey,
          resolvedLocalPath: archivablePath,
          mimeType: row.mimeType,
          sha256Hex: row.sha256Hex,
        );

        if (outcome.status == AttachmentArchiveIngestionStatus.archived) {
          archived++;
        } else if (outcome.status ==
            AttachmentArchiveIngestionStatus.deferred) {
          deferredReason = outcome.deferredReason;
          deferred = rows.length - archived - skipped - failed;
          break;
        } else {
          skipped++;
          _recordSkippedSample(
            skippedSamples,
            archiveKey: archiveKey,
            localPath: resolvedPath,
            reason: 'not archived',
            sampleLimit: skippedSampleLimit,
          );
        }
      } on AttachmentArchiveMutationDeferredException catch (error) {
        deferredReason = error.reason;
        deferred = rows.length - archived - skipped - failed;
        break;
      } on Exception {
        failed++;
      }

      // Update progress every 10 items or on the last item.
      final processed = archived + skipped;
      if (updateProgressState &&
          (processed % 10 == 0 || processed == rows.length)) {
        state = BulkArchiveProgress(
          phase: BulkArchivePhase.running,
          totalItems: rows.length,
          processedItems: processed,
          newlyArchived: archived,
        );
      }
    }

    return _ArchiveRowsOutcome(
      result: AttachmentArchiveResult(
        totalScanned: rows.length,
        newlyArchived: archived,
        skipped: skipped,
        failed: failed,
        deferred: deferred,
        deferredReason: deferredReason,
      ),
      skippedSamples: skippedSamples,
    );
  }

  void _recordSkippedSample(
    List<String> skippedSamples, {
    required ArchiveCompatibilityKey? archiveKey,
    required String? localPath,
    required String reason,
    required int sampleLimit,
  }) {
    if (sampleLimit <= 0 || skippedSamples.length >= sampleLimit) {
      return;
    }

    final archiveCompatibilitySourceRowId =
        archiveKey?.liveSourceAttachmentRowId;
    final attachmentLabel = archiveCompatibilitySourceRowId == null
        ? 'unknown-id'
        : '$archiveCompatibilitySourceRowId';
    final pathLabel = localPath == null || localPath.isEmpty
        ? 'no-path'
        : localPath;
    final sample = '$attachmentLabel | $reason | $pathLabel';
    if (skippedSamples.contains(sample)) {
      return;
    }

    skippedSamples.add(sample);
  }

  /// Pause the running bulk archive operation.
  void pause() {
    _pauseRequested = true;
  }

  /// Resume a paused bulk archive operation.
  void resume() {
    _pauseRequested = false;
  }

  /// Cancel the running bulk archive operation.
  void cancel() {
    _cancelRequested = true;
    _pauseRequested = false;
  }

  /// Dismiss the completed/idle progress display.
  void dismissProgress() {
    state = const BulkArchiveProgress(phase: BulkArchivePhase.idle);
  }

  /// Verify archive integrity by re-hashing files and comparing to stored
  /// content hashes. Returns a result describing how many passed, failed,
  /// or were missing.
  Future<ArchiveIntegrityResult> verifyIntegrity() async {
    final archiveStore = await ref.read(
      attachmentArchiveWriteStoreProvider.future,
    );
    final archiveDir = await _readReadableArchiveRootPath();
    final logger = ref.read(appLoggerProvider.notifier);
    final fileStore = ref.read(attachmentArchiveFileStoreProvider);

    final rows = await archiveStore.readIntegrityEntries();

    var verified = 0;
    var hashMismatch = 0;
    var fileMissing = 0;
    var noHash = 0;

    for (final row in rows) {
      final integrityCheck = await fileStore.checkIntegrity(
        archiveDirectoryPath: archiveDir,
        relativePath: row.relativePath,
        storedHash: row.contentHash,
      );

      if (!integrityCheck.fileExists) {
        fileMissing++;
        continue;
      }

      if (row.contentHash == null || row.contentHash!.isEmpty) {
        noHash++;
        continue;
      }

      if (integrityCheck.hashMatches == true) {
        verified++;
      } else {
        hashMismatch++;
        logger.warn(
          'Archive integrity: hash mismatch for ${row.relativePath} '
          '(stored: ${row.contentHash}, '
          'actual: ${integrityCheck.actualHash})',
          source: 'AttachmentArchiveService',
        );
      }
    }

    logger.info(
      'Archive integrity check: $verified OK, '
      '$hashMismatch mismatch, $fileMissing missing, $noHash no-hash '
      'out of ${rows.length} records',
      source: 'AttachmentArchiveService',
    );

    return ArchiveIntegrityResult(
      totalRecords: rows.length,
      verified: verified,
      hashMismatch: hashMismatch,
      fileMissing: fileMissing,
      noHash: noHash,
    );
  }

  Future<String> _readReadableArchiveRootPath() async {
    final location = await ref.read(attachmentArchiveLocationProvider.future);
    return location.requireArchiveRootPath();
  }

  Future<String?> _resolveArchivableSourcePath({
    required String preferredLocalPath,
    required ArchiveCompatibilityKey archiveKey,
  }) async {
    final fileStore = ref.read(attachmentArchiveFileStoreProvider);
    final expandedPreferredPath = fileStore.expandHomePath(preferredLocalPath);
    if (fileStore.fileExists(expandedPreferredPath)) {
      return expandedPreferredPath;
    }

    final refreshedPath = await _lookupCurrentMessagesAttachmentPath(
      archiveKey,
    );
    if (refreshedPath == null) {
      return null;
    }

    final expandedRefreshedPath = fileStore.expandHomePath(refreshedPath);
    if (!fileStore.fileExists(expandedRefreshedPath)) {
      return null;
    }

    if (expandedRefreshedPath != expandedPreferredPath) {
      ref
          .read(appLoggerProvider.notifier)
          .debug(
            'Attachment ${archiveKey.liveSourceAttachmentRowId} resolved via refreshed chat.db '
            'path $expandedRefreshedPath',
            source: 'AttachmentArchiveService',
          );
    }

    return expandedRefreshedPath;
  }

  Future<String?> _lookupCurrentMessagesAttachmentPath(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    try {
      final lookup = await ref.read(
        currentMessagesAttachmentPathLookupProvider.future,
      );
      return lookup.attachmentPathForSourceRowId(
        archiveKey.liveSourceAttachmentRowId,
      );
    } on Object catch (error) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Failed to refresh attachment path for '
            '${archiveKey.liveSourceAttachmentRowId}: $error',
            source: 'AttachmentArchiveService',
          );
      return null;
    }
  }

  Future<int> _readGraphSweepCursor(
    AttachmentArchiveSettingsStore settingsStore,
  ) async {
    final rawValue = await settingsStore.readSetting(kArchiveSweepCursorKey);
    if (rawValue == null || rawValue.isEmpty) {
      return 0;
    }

    return int.tryParse(rawValue) ?? 0;
  }

  Future<void> _writeGraphSweepStatus(
    AttachmentArchiveSettingsStore settingsStore, {
    required String startedAtUtc,
    required String completedAtUtc,
    required int nextCursor,
    required AttachmentArchiveResult result,
  }) async {
    await _writeGraphSweepCursor(settingsStore, nextCursor: nextCursor);
    await settingsStore.writeSetting(
      key: kArchiveSweepLastStartedAtUtcKey,
      value: startedAtUtc,
    );
    await settingsStore.writeSetting(
      key: kArchiveSweepLastCompletedAtUtcKey,
      value: completedAtUtc,
    );
    await settingsStore.writeSetting(
      key: kArchiveSweepLastTotalScannedKey,
      value: '${result.totalScanned}',
    );
    await settingsStore.writeSetting(
      key: kArchiveSweepLastNewlyArchivedKey,
      value: '${result.newlyArchived}',
    );
    await settingsStore.writeSetting(
      key: kArchiveSweepLastSkippedKey,
      value: '${result.skipped}',
    );
    await settingsStore.writeSetting(
      key: kArchiveSweepLastFailedKey,
      value: '${result.failed}',
    );
  }

  Future<void> _writeGraphSweepCursor(
    AttachmentArchiveSettingsStore settingsStore, {
    required int nextCursor,
  }) async {
    await settingsStore.writeSetting(
      key: kArchiveSweepCursorKey,
      value: '$nextCursor',
    );
  }

  Future<void> _writeManualSweepBurstStatus(
    AttachmentArchiveSettingsStore settingsStore, {
    required String startedAtUtc,
    required String completedAtUtc,
    required AttachmentArchiveResult result,
    List<String> skippedSamples = const [],
  }) async {
    await settingsStore.writeSetting(
      key: kArchiveManualSweepLastStartedAtUtcKey,
      value: startedAtUtc,
    );
    await settingsStore.writeSetting(
      key: kArchiveManualSweepLastCompletedAtUtcKey,
      value: completedAtUtc,
    );
    await settingsStore.writeSetting(
      key: kArchiveManualSweepLastTotalScannedKey,
      value: '${result.totalScanned}',
    );
    await settingsStore.writeSetting(
      key: kArchiveManualSweepLastNewlyArchivedKey,
      value: '${result.newlyArchived}',
    );
    await settingsStore.writeSetting(
      key: kArchiveManualSweepLastSkippedKey,
      value: '${result.skipped}',
    );
    await settingsStore.writeSetting(
      key: kArchiveManualSweepLastFailedKey,
      value: '${result.failed}',
    );
    await settingsStore.writeSetting(
      key: kArchiveManualSweepLastSkippedSamplesKey,
      value: skippedSamples.join('\n'),
    );
  }
}

enum AttachmentArchiveIngestionStatus {
  archived,
  alreadyArchived,
  sourceMissing,
  failed,
  deferred,
}

class AttachmentArchiveIngestionOutcome {
  const AttachmentArchiveIngestionOutcome.archived()
    : status = AttachmentArchiveIngestionStatus.archived,
      deferredReason = null;

  const AttachmentArchiveIngestionOutcome.alreadyArchived()
    : status = AttachmentArchiveIngestionStatus.alreadyArchived,
      deferredReason = null;

  const AttachmentArchiveIngestionOutcome.sourceMissing()
    : status = AttachmentArchiveIngestionStatus.sourceMissing,
      deferredReason = null;

  const AttachmentArchiveIngestionOutcome.failed()
    : status = AttachmentArchiveIngestionStatus.failed,
      deferredReason = null;

  const AttachmentArchiveIngestionOutcome.deferred(this.deferredReason)
    : status = AttachmentArchiveIngestionStatus.deferred;

  final AttachmentArchiveIngestionStatus status;
  final AttachmentArchiveMutationDeferredReason? deferredReason;
}

/// Result of a bulk archiving operation.
class AttachmentArchiveResult {
  const AttachmentArchiveResult({
    required this.totalScanned,
    required this.newlyArchived,
    required this.skipped,
    required this.failed,
    this.deferred = 0,
    this.deferredReason,
  });

  const AttachmentArchiveResult.deferred(
    AttachmentArchiveMutationDeferredReason reason,
  ) : totalScanned = 0,
      newlyArchived = 0,
      skipped = 0,
      failed = 0,
      deferred = 1,
      deferredReason = reason;

  final int totalScanned;
  final int newlyArchived;
  final int skipped;
  final int failed;
  final int deferred;
  final AttachmentArchiveMutationDeferredReason? deferredReason;

  bool get isDeferred => deferredReason != null;
}

class _ArchiveRowsOutcome {
  const _ArchiveRowsOutcome({
    required this.result,
    required this.skippedSamples,
  });

  final AttachmentArchiveResult result;
  final List<String> skippedSamples;
}

/// Phases of a bulk archive operation.
enum BulkArchivePhase { idle, running, paused, complete }

/// Live progress of a bulk archive operation.
class BulkArchiveProgress {
  const BulkArchiveProgress({
    required this.phase,
    this.totalItems = 0,
    this.processedItems = 0,
    this.newlyArchived = 0,
  });

  final BulkArchivePhase phase;
  final int totalItems;
  final int processedItems;
  final int newlyArchived;

  double get progress => totalItems > 0 ? processedItems / totalItems : 0;

  BulkArchiveProgress copyWith({
    BulkArchivePhase? phase,
    int? totalItems,
    int? processedItems,
    int? newlyArchived,
  }) {
    return BulkArchiveProgress(
      phase: phase ?? this.phase,
      totalItems: totalItems ?? this.totalItems,
      processedItems: processedItems ?? this.processedItems,
      newlyArchived: newlyArchived ?? this.newlyArchived,
    );
  }
}

/// Result of an archive integrity verification.
class ArchiveIntegrityResult {
  const ArchiveIntegrityResult({
    required this.totalRecords,
    required this.verified,
    required this.hashMismatch,
    required this.fileMissing,
    required this.noHash,
  });

  final int totalRecords;
  final int verified;
  final int hashMismatch;
  final int fileMissing;
  final int noHash;

  bool get allGood => hashMismatch == 0 && fileMissing == 0;
}
