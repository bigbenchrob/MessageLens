import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_environment/domain.dart'
    show ArchiveMutationOperation;
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability, archiveMutationCoordinatorProvider;
import '../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import 'attachment_archive_location_provider.dart';
import 'deterministic_recovery_runtime_providers.dart'
    show
        crossSnapshotMapperProvider,
        historicalSnapshotReaderFactoryProvider,
        recoveredAttachmentArchiveWriterProvider;

part 'deterministic_recovery_provider.g.dart';

/// Phase of the deterministic recovery operation.
enum DeterministicRecoveryPhase {
  idle,
  validating,
  readingSnapshot,
  mapping,
  archiving,
  deferred,
  complete,
  error,
}

/// Full result of a deterministic recovery operation.
class DeterministicRecoveryResult {
  const DeterministicRecoveryResult({
    required this.totalHistoricalPairs,
    required this.filesFound,
    required this.filesMissing,
    required this.nullPathRecords,
    required this.mappedByGuid,
    required this.mappedBySingleFallback,
    required this.unmappedMessageMissing,
    required this.unmappedGuidMismatch,
    required this.unmappedAmbiguous,
    required this.unmappedNoCurrentAttachment,
    required this.unmappedFileMissing,
    required this.archivedNew,
    required this.skippedAlreadyArchived,
    required this.archiveFailed,
    required this.totalBytesArchived,
    required this.walDetected,
    required this.shmDetected,
  });

  final int totalHistoricalPairs;
  final int filesFound;
  final int filesMissing;
  final int nullPathRecords;
  final int mappedByGuid;
  final int mappedBySingleFallback;
  final int unmappedMessageMissing;
  final int unmappedGuidMismatch;
  final int unmappedAmbiguous;
  final int unmappedNoCurrentAttachment;
  final int unmappedFileMissing;
  final int archivedNew;
  final int skippedAlreadyArchived;
  final int archiveFailed;
  final int totalBytesArchived;
  final bool walDetected;
  final bool shmDetected;

  int get totalMapped => mappedByGuid + mappedBySingleFallback;
}

/// Current state of the deterministic recovery operation.
class DeterministicRecoveryState {
  const DeterministicRecoveryState({
    required this.phase,
    this.phaseProgress = 0,
    this.phaseTotal = 0,
    this.result,
    this.errorMessage,
    this.deferredReason,
  });

  final DeterministicRecoveryPhase phase;
  final int phaseProgress;
  final int phaseTotal;
  final DeterministicRecoveryResult? result;
  final String? errorMessage;
  final AttachmentArchiveMutationDeferredReason? deferredReason;

  bool get isRunning =>
      phase == DeterministicRecoveryPhase.validating ||
      phase == DeterministicRecoveryPhase.readingSnapshot ||
      phase == DeterministicRecoveryPhase.mapping ||
      phase == DeterministicRecoveryPhase.archiving;

  DeterministicRecoveryState copyWith({
    DeterministicRecoveryPhase? phase,
    int? phaseProgress,
    int? phaseTotal,
    DeterministicRecoveryResult? result,
    String? errorMessage,
    AttachmentArchiveMutationDeferredReason? deferredReason,
  }) {
    return DeterministicRecoveryState(
      phase: phase ?? this.phase,
      phaseProgress: phaseProgress ?? this.phaseProgress,
      phaseTotal: phaseTotal ?? this.phaseTotal,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      deferredReason: deferredReason ?? this.deferredReason,
    );
  }
}

/// Orchestrates the full deterministic historical attachment recovery pipeline:
/// Phase 1 (snapshot reader) → Phase 2 (mapper) → Phase 3 (archive writer).
@Riverpod(keepAlive: true)
class DeterministicRecovery extends _$DeterministicRecovery {
  bool _cancelRequested = false;

  @override
  DeterministicRecoveryState build() {
    return const DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.idle,
    );
  }

  /// Run the full deterministic recovery pipeline.
  Future<void> recover({
    required String chatDbPath,
    required String attachmentsFolderPath,
  }) {
    return ref
        .read(archiveMutationCoordinatorProvider.notifier)
        .runWithCapability<void>(
          operation: ArchiveMutationOperation.automaticRecovery,
          ownerLabel: 'deterministic-attachment-recovery',
          action: (mutationCapability) async {
            final admission = await ref.read(
              attachmentArchiveWritableRootAdmissionProvider.future,
            );
            final writableRootLease = admission.lease;
            if (writableRootLease == null) {
              state = DeterministicRecoveryState(
                phase: DeterministicRecoveryPhase.deferred,
                deferredReason: admission.deferredReason,
                errorMessage: admission.issue,
              );
              return;
            }
            try {
              await writableRootLease.requireValid(
                operation: ArchiveMutationOperation.automaticRecovery,
                boundary: AttachmentArchiveMutationBoundary.operationStart,
              );
              await _recover(
                chatDbPath: chatDbPath,
                attachmentsFolderPath: attachmentsFolderPath,
                mutationCapability: mutationCapability,
                writableRootLease: writableRootLease,
              );
            } on AttachmentArchiveMutationDeferredException catch (error) {
              state = DeterministicRecoveryState(
                phase: DeterministicRecoveryPhase.deferred,
                deferredReason: error.reason,
                errorMessage: error.issue,
              );
            }
          },
        );
  }

  Future<void> _recover({
    required String chatDbPath,
    required String attachmentsFolderPath,
    required ArchiveMutationCapability mutationCapability,
    required AttachmentArchiveWritableRootLease writableRootLease,
  }) async {
    if (state.isRunning) {
      return;
    }

    _cancelRequested = false;
    final logger = ref.read(appLoggerProvider.notifier);

    // --- Validation ---
    state = const DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.validating,
    );

    final readerFactory = ref.read(historicalSnapshotReaderFactoryProvider);
    final reader = readerFactory.create(
      chatDbPath: chatDbPath,
      attachmentsFolderPath: attachmentsFolderPath,
    );

    final validation = reader.validate();
    if (!validation.isValid) {
      state = DeterministicRecoveryState(
        phase: DeterministicRecoveryPhase.error,
        errorMessage: validation.errorMessage,
      );
      return;
    }

    final mapper = await ref.read(crossSnapshotMapperProvider.future);
    final hasCurrentAttachmentSnapshot = await mapper
        .hasCurrentAttachmentSnapshot();
    if (!hasCurrentAttachmentSnapshot) {
      state = const DeterministicRecoveryState(
        phase: DeterministicRecoveryPhase.error,
        errorMessage:
            'Current attachment snapshot must be populated first. '
            'Run a normal import before historical recovery.',
      );
      return;
    }

    if (_cancelRequested) {
      _resetToIdle();
      return;
    }

    // --- Phase 1: Read snapshot ---
    state = const DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.readingSnapshot,
    );

    logger.info(
      'Deterministic recovery: reading historical snapshot from $chatDbPath',
      source: 'DeterministicRecovery',
    );

    final enumerationResult = reader.enumerate(
      onProgress: (processed) {
        state = state.copyWith(phaseProgress: processed);
      },
      isCancelled: () => _cancelRequested,
    );

    if (enumerationResult == null || _cancelRequested) {
      _resetToIdle();
      return;
    }

    logger.info(
      'Deterministic recovery: enumerated ${enumerationResult.totalHistoricalPairs} pairs, '
      '${enumerationResult.filesFound} files found, '
      '${enumerationResult.filesMissing} missing',
      source: 'DeterministicRecovery',
    );

    // --- Phase 2: Map to current identity ---
    state = DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.mapping,
      phaseTotal: enumerationResult.records.length,
    );

    final mappingResult = await mapper.mapRecords(
      historicalRecords: enumerationResult.records,
      onProgress: (processed) {
        state = state.copyWith(phaseProgress: processed);
      },
      isCancelled: () => _cancelRequested,
    );

    if (mappingResult == null || _cancelRequested) {
      _resetToIdle();
      return;
    }

    logger.info(
      'Deterministic recovery: mapped ${mappingResult.mapped.length} records '
      '(${mappingResult.mappedByGuid} by GUID, '
      '${mappingResult.mappedBySingleFallback} by fallback), '
      '${mappingResult.unmapped.length} unmapped',
      source: 'DeterministicRecovery',
    );

    // --- Phase 3: Archive ---
    state = DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.archiving,
      phaseTotal: mappingResult.mapped.length,
    );

    final archiveWriter = await ref.read(
      recoveredAttachmentArchiveWriterProvider.future,
    );

    var archivedNew = 0;
    var skippedAlreadyArchived = 0;
    var archiveFailed = 0;
    var totalBytesArchived = 0;

    for (var i = 0; i < mappingResult.mapped.length; i++) {
      if (_cancelRequested) {
        break;
      }

      final record = mappingResult.mapped[i];

      try {
        final archived = await archiveWriter.archive(
          record: record,
          writableRootLease: writableRootLease,
          mutationCapability: mutationCapability,
        );

        if (archived == null) {
          skippedAlreadyArchived++;
        } else {
          archivedNew++;
          totalBytesArchived += archived;
        }
      } on AttachmentArchiveMutationDeferredException {
        rethrow;
      } on Exception catch (error) {
        archiveFailed++;
        logger.warn(
          'Deterministic recovery: failed to archive '
          '${record.resolvedFilePath}: $error',
          source: 'DeterministicRecovery',
        );
      }

      if (i % 10 == 0 || i == mappingResult.mapped.length - 1) {
        state = state.copyWith(phaseProgress: i + 1);
      }
    }

    logger.info(
      'Deterministic recovery complete: '
      '$archivedNew new, $skippedAlreadyArchived already archived, '
      '$archiveFailed failed, '
      '${_formatSize(totalBytesArchived)} archived',
      source: 'DeterministicRecovery',
    );

    // --- Complete ---
    state = DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.complete,
      result: DeterministicRecoveryResult(
        totalHistoricalPairs: enumerationResult.totalHistoricalPairs,
        filesFound: enumerationResult.filesFound,
        filesMissing: enumerationResult.filesMissing,
        nullPathRecords: enumerationResult.nullPathRecords,
        mappedByGuid: mappingResult.mappedByGuid,
        mappedBySingleFallback: mappingResult.mappedBySingleFallback,
        unmappedMessageMissing: mappingResult.unmappedMessageMissing,
        unmappedGuidMismatch: mappingResult.unmappedGuidMismatch,
        unmappedAmbiguous: mappingResult.unmappedAmbiguous,
        unmappedNoCurrentAttachment: mappingResult.unmappedNoCurrentAttachment,
        unmappedFileMissing: mappingResult.unmappedFileMissing,
        archivedNew: archivedNew,
        skippedAlreadyArchived: skippedAlreadyArchived,
        archiveFailed: archiveFailed,
        totalBytesArchived: totalBytesArchived,
        walDetected: enumerationResult.walDetected,
        shmDetected: enumerationResult.shmDetected,
      ),
    );
  }

  /// Request cooperative cancellation.
  void cancel() {
    _cancelRequested = true;
  }

  /// Reset to idle.
  void reset() {
    _cancelRequested = false;
    state = const DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.idle,
    );
  }

  void _resetToIdle() {
    _cancelRequested = false;
    state = const DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.idle,
    );
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
