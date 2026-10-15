import 'dart:async';

enum ReconstructionObservationTruth { trueValue, falseValue, unknown }

enum ReconstructionObservationUnknownReason {
  missingEvidence,
  intervalInstability,
  cancellation,
  deadline,
  rowLimit,
  byteLimit,
  memoryLimit,
  diskLimit,
  diagnosticLimit,
  unsupportedDependency,
  phaseFailure,
  ambiguousCleanup,
}

enum ReconstructionObservationPhase {
  archiveBinding,
  sourceOccurrencesAndRegistry,
  ledger,
  graph,
  overlay,
  presence,
  journalsReceiptsAndOperations,
  implementationAndRuntime,
}

abstract interface class ReconstructionPhasePayload {
  ReconstructionObservationPhase get phase;
}

final class ArchiveBindingPhasePayload implements ReconstructionPhasePayload {
  const ArchiveBindingPhasePayload({
    required this.archiveInstanceUuid,
    required this.canonicalRoot,
    required this.markerIdentity,
    required this.locationGeneration,
  });

  final String archiveInstanceUuid;
  final String canonicalRoot;
  final String markerIdentity;
  final int locationGeneration;

  @override
  ReconstructionObservationPhase get phase =>
      ReconstructionObservationPhase.archiveBinding;
}

final class SourceOccurrencesAndRegistryPhasePayload
    implements ReconstructionPhasePayload {
  const SourceOccurrencesAndRegistryPhasePayload({
    required this.occurrencesIdentity,
    required this.registryIdentity,
  });

  final String occurrencesIdentity;
  final String registryIdentity;

  @override
  ReconstructionObservationPhase get phase =>
      ReconstructionObservationPhase.sourceOccurrencesAndRegistry;
}

final class LedgerPhasePayload implements ReconstructionPhasePayload {
  const LedgerPhasePayload({required this.materialIdentity});

  final String materialIdentity;

  @override
  ReconstructionObservationPhase get phase =>
      ReconstructionObservationPhase.ledger;
}

final class GraphPhasePayload implements ReconstructionPhasePayload {
  const GraphPhasePayload({required this.materialIdentity});

  final String materialIdentity;

  @override
  ReconstructionObservationPhase get phase =>
      ReconstructionObservationPhase.graph;
}

final class OverlayPhasePayload implements ReconstructionPhasePayload {
  const OverlayPhasePayload({required this.materialIdentity});

  final String materialIdentity;

  @override
  ReconstructionObservationPhase get phase =>
      ReconstructionObservationPhase.overlay;
}

final class PresencePhasePayload implements ReconstructionPhasePayload {
  const PresencePhasePayload({required this.materialIdentity});

  final String materialIdentity;

  @override
  ReconstructionObservationPhase get phase =>
      ReconstructionObservationPhase.presence;
}

final class JournalsReceiptsAndOperationsPhasePayload
    implements ReconstructionPhasePayload {
  const JournalsReceiptsAndOperationsPhasePayload({
    required this.materialIdentity,
  });

  final String materialIdentity;

  @override
  ReconstructionObservationPhase get phase =>
      ReconstructionObservationPhase.journalsReceiptsAndOperations;
}

final class ImplementationAndRuntimePhasePayload
    implements ReconstructionPhasePayload {
  const ImplementationAndRuntimePhasePayload({
    required this.implementationIdentity,
    required this.runtimeIdentity,
  });

  final String implementationIdentity;
  final String runtimeIdentity;

  @override
  ReconstructionObservationPhase get phase =>
      ReconstructionObservationPhase.implementationAndRuntime;
}

final class ReconstructionPhaseEvidence {
  const ReconstructionPhaseEvidence._({
    required this.phase,
    required this.truth,
    required this.payload,
    required this.unknownReason,
    required this.diagnostic,
  });

  factory ReconstructionPhaseEvidence.known({
    required ReconstructionPhasePayload payload,
    required bool isTrue,
    String? diagnostic,
  }) {
    return ReconstructionPhaseEvidence._(
      phase: payload.phase,
      truth: isTrue
          ? ReconstructionObservationTruth.trueValue
          : ReconstructionObservationTruth.falseValue,
      payload: payload,
      unknownReason: null,
      diagnostic: diagnostic,
    );
  }

  factory ReconstructionPhaseEvidence.unknown({
    required ReconstructionObservationPhase phase,
    required ReconstructionObservationUnknownReason reason,
    ReconstructionPhasePayload? payload,
    String? diagnostic,
  }) {
    if (payload != null && payload.phase != phase) {
      throw ArgumentError('The payload does not belong to $phase.');
    }
    return ReconstructionPhaseEvidence._(
      phase: phase,
      truth: ReconstructionObservationTruth.unknown,
      payload: payload,
      unknownReason: reason,
      diagnostic: diagnostic,
    );
  }

  final ReconstructionObservationPhase phase;
  final ReconstructionObservationTruth truth;
  final ReconstructionPhasePayload? payload;
  final ReconstructionObservationUnknownReason? unknownReason;
  final String? diagnostic;
}

final class OperationalTimestampProvenance {
  const OperationalTimestampProvenance({
    required this.fieldIdentity,
    required this.lifecycleIdentity,
    required this.value,
  });

  final String fieldIdentity;
  final String lifecycleIdentity;
  final String value;

  bool sameAs(OperationalTimestampProvenance other) {
    return fieldIdentity == other.fieldIdentity &&
        lifecycleIdentity == other.lifecycleIdentity &&
        value == other.value;
  }
}

final class ReconstructionObservationFingerprint {
  ReconstructionObservationFingerprint({
    required this.archiveInstanceUuid,
    required this.canonicalRoot,
    required this.markerIdentity,
    required this.locationGeneration,
    required this.sourceOccurrencesIdentity,
    required this.sourceRegistryIdentity,
    required this.ledgerIdentity,
    required this.graphIdentity,
    required this.overlayIdentity,
    required this.presenceIdentity,
    required this.journalsReceiptsAndOperationsIdentity,
    required this.implementationIdentity,
    required this.runtimeIdentity,
    List<OperationalTimestampProvenance> operationalTimestamps = const [],
  }) : operationalTimestamps = List.unmodifiable(operationalTimestamps);

  final String archiveInstanceUuid;
  final String canonicalRoot;
  final String markerIdentity;
  final int locationGeneration;
  final String sourceOccurrencesIdentity;
  final String sourceRegistryIdentity;
  final String ledgerIdentity;
  final String graphIdentity;
  final String overlayIdentity;
  final String presenceIdentity;
  final String journalsReceiptsAndOperationsIdentity;
  final String implementationIdentity;
  final String runtimeIdentity;
  final List<OperationalTimestampProvenance> operationalTimestamps;

  Map<String, Object> get materialFields => <String, Object>{
    'archiveInstanceUuid': archiveInstanceUuid,
    'canonicalRoot': canonicalRoot,
    'markerIdentity': markerIdentity,
    'locationGeneration': locationGeneration,
    'sourceOccurrencesIdentity': sourceOccurrencesIdentity,
    'sourceRegistryIdentity': sourceRegistryIdentity,
    'ledgerIdentity': ledgerIdentity,
    'graphIdentity': graphIdentity,
    'overlayIdentity': overlayIdentity,
    'presenceIdentity': presenceIdentity,
    'journalsReceiptsAndOperationsIdentity':
        journalsReceiptsAndOperationsIdentity,
    'implementationIdentity': implementationIdentity,
    'runtimeIdentity': runtimeIdentity,
  };
}

final class ReconstructionObservationLimits {
  const ReconstructionObservationLimits({
    required this.deadline,
    required this.maximumRows,
    required this.maximumBytes,
    required this.maximumMemoryBytes,
    required this.maximumDiskBytes,
    required this.maximumDiagnostics,
    this.cleanupTimeout = const Duration(seconds: 1),
  });

  final Duration deadline;
  final int maximumRows;
  final int maximumBytes;
  final int maximumMemoryBytes;
  final int maximumDiskBytes;
  final int maximumDiagnostics;
  final Duration cleanupTimeout;
}

typedef ReconstructionMonotonicClock = Duration Function();
typedef ReconstructionCancellationReader = bool Function();

final class ReconstructionObservationAttemptContext {
  ReconstructionObservationAttemptContext({
    required ReconstructionObservationLimits limits,
    required ReconstructionMonotonicClock clock,
    required ReconstructionCancellationReader isCancelled,
  }) : _limits = limits,
       _clock = clock,
       _isCancelled = isCancelled,
       _startedAt = clock();

  final ReconstructionObservationLimits _limits;
  final ReconstructionMonotonicClock _clock;
  final ReconstructionCancellationReader _isCancelled;
  final Duration _startedAt;

  int _rows = 0;
  int _bytes = 0;
  int _currentMemoryBytes = 0;
  int _diskBytes = 0;
  int _diagnostics = 0;

  int get observedRows => _rows;
  int get observedBytes => _bytes;
  int get currentMemoryBytes => _currentMemoryBytes;
  int get observedDiskBytes => _diskBytes;
  int get observedDiagnostics => _diagnostics;

  void checkpoint() {
    if (_isCancelled()) {
      throw const _ObservationAbort(
        ReconstructionObservationUnknownReason.cancellation,
      );
    }
    if (_clock() - _startedAt >= _limits.deadline) {
      throw const _ObservationAbort(
        ReconstructionObservationUnknownReason.deadline,
      );
    }
  }

  Future<T> runBounded<T>(Future<T> Function() callback) async {
    checkpoint();
    final elapsed = _clock() - _startedAt;
    final remaining = _limits.deadline - elapsed;
    final value = await callback().timeout(
      remaining,
      onTimeout: () {
        throw const _ObservationAbort(
          ReconstructionObservationUnknownReason.deadline,
        );
      },
    );
    checkpoint();
    return value;
  }

  void recordPage({
    required int rows,
    required int bytes,
    required int memoryBytes,
    int diskBytes = 0,
    int diagnostics = 0,
  }) {
    if (rows < 0 ||
        bytes < 0 ||
        memoryBytes < 0 ||
        diskBytes < 0 ||
        diagnostics < 0) {
      throw ArgumentError('Observation accounting cannot be negative.');
    }
    checkpoint();
    _rows += rows;
    _bytes += bytes;
    _currentMemoryBytes += memoryBytes;
    _diskBytes += diskBytes;
    _diagnostics += diagnostics;
    if (_rows > _limits.maximumRows) {
      throw const _ObservationAbort(
        ReconstructionObservationUnknownReason.rowLimit,
      );
    }
    if (_bytes > _limits.maximumBytes) {
      throw const _ObservationAbort(
        ReconstructionObservationUnknownReason.byteLimit,
      );
    }
    if (_currentMemoryBytes > _limits.maximumMemoryBytes) {
      throw const _ObservationAbort(
        ReconstructionObservationUnknownReason.memoryLimit,
      );
    }
    if (_diskBytes > _limits.maximumDiskBytes) {
      throw const _ObservationAbort(
        ReconstructionObservationUnknownReason.diskLimit,
      );
    }
    if (_diagnostics > _limits.maximumDiagnostics) {
      throw const _ObservationAbort(
        ReconstructionObservationUnknownReason.diagnosticLimit,
      );
    }
  }

  void releasePageMemory(int memoryBytes) {
    if (memoryBytes < 0 || memoryBytes > _currentMemoryBytes) {
      throw ArgumentError.value(memoryBytes, 'memoryBytes');
    }
    _currentMemoryBytes -= memoryBytes;
    checkpoint();
  }
}

typedef ReconstructionFingerprintReader =
    Future<ReconstructionObservationFingerprint> Function(
      ReconstructionObservationAttemptContext context,
    );
typedef ReconstructionPhaseEvidenceReader =
    Future<ReconstructionPhaseEvidence> Function(
      ReconstructionObservationAttemptContext context,
    );
typedef OperationalTimestampLifecycleValidator =
    Future<bool> Function({
      required OperationalTimestampProvenance start,
      required OperationalTimestampProvenance end,
    });

final class ReconstructionObservationPhaseReader {
  const ReconstructionObservationPhaseReader({
    required this.phase,
    required this.read,
  });

  final ReconstructionObservationPhase phase;
  final ReconstructionPhaseEvidenceReader read;
}

final class ReconstructionObservationAttempt {
  ReconstructionObservationAttempt({
    required this.readFingerprint,
    required List<ReconstructionObservationPhaseReader> phaseReaders,
    required this.close,
    this.validateOperationalTimestamp,
  }) : phaseReaders = List.unmodifiable(phaseReaders);

  final ReconstructionFingerprintReader readFingerprint;
  final List<ReconstructionObservationPhaseReader> phaseReaders;
  final OperationalTimestampLifecycleValidator? validateOperationalTimestamp;
  final Future<void> Function() close;
}

typedef ReconstructionObservationAttemptFactory =
    Future<ReconstructionObservationAttempt> Function(
      int attemptNumber,
      ReconstructionObservationAttemptContext context,
    );

final class CoherentReconstructionObservationResult {
  CoherentReconstructionObservationResult({
    required this.truth,
    required this.unknownReason,
    required this.attemptCount,
    required List<ReconstructionPhaseEvidence> phaseEvidence,
    required this.totalFingerprintMismatchCount,
    required List<String> fingerprintMismatchDiagnostics,
  }) : phaseEvidence = List.unmodifiable(phaseEvidence),
       fingerprintMismatchDiagnostics = List.unmodifiable(
         fingerprintMismatchDiagnostics,
       );

  final ReconstructionObservationTruth truth;
  final ReconstructionObservationUnknownReason? unknownReason;
  final int attemptCount;
  final List<ReconstructionPhaseEvidence> phaseEvidence;
  final int totalFingerprintMismatchCount;
  final List<String> fingerprintMismatchDiagnostics;

  bool get canAuthorizeDestructiveMutation => false;
}

final class CoherentPopulatedReconstructionObservationEnvelope {
  const CoherentPopulatedReconstructionObservationEnvelope({
    required this.limits,
    required this.clock,
    required this.isCancelled,
  });

  final ReconstructionObservationLimits limits;
  final ReconstructionMonotonicClock clock;
  final ReconstructionCancellationReader isCancelled;

  Future<CoherentReconstructionObservationResult> observe({
    required ReconstructionObservationAttemptFactory createAttempt,
  }) async {
    final first = await _runAttempt(1, createAttempt);
    if (!first.isFingerprintMismatch) {
      return first.toPublicResult(attemptCount: 1);
    }

    final second = await _runAttempt(2, createAttempt);
    if (!second.isFingerprintMismatch) {
      return second.toPublicResult(
        attemptCount: 2,
        earlierMismatchCount: first.totalFingerprintMismatchCount,
        earlierMismatchDiagnostics: first.fingerprintMismatchDiagnostics,
        diagnosticLimit: limits.maximumDiagnostics,
      );
    }

    return CoherentReconstructionObservationResult(
      truth: ReconstructionObservationTruth.unknown,
      unknownReason: ReconstructionObservationUnknownReason.intervalInstability,
      attemptCount: 2,
      phaseEvidence: const [],
      totalFingerprintMismatchCount:
          first.totalFingerprintMismatchCount +
          second.totalFingerprintMismatchCount,
      fingerprintMismatchDiagnostics: _boundedDiagnostics(<String>[
        ...first.fingerprintMismatchDiagnostics,
        ...second.fingerprintMismatchDiagnostics,
      ], limits.maximumDiagnostics),
    );
  }

  Future<_AttemptOutcome> _runAttempt(
    int attemptNumber,
    ReconstructionObservationAttemptFactory createAttempt,
  ) async {
    final context = ReconstructionObservationAttemptContext(
      limits: limits,
      clock: clock,
      isCancelled: isCancelled,
    );
    ReconstructionObservationAttempt? attempt;
    _AttemptOutcome outcome;
    try {
      final acquiredAttempt = await context.runBounded(
        () => createAttempt(attemptNumber, context),
      );
      attempt = acquiredAttempt;
      final readers =
          <ReconstructionObservationPhase, ReconstructionPhaseEvidenceReader>{};
      var duplicateReader = false;
      for (final reader in acquiredAttempt.phaseReaders) {
        if (readers.containsKey(reader.phase)) {
          duplicateReader = true;
        }
        readers[reader.phase] = reader.read;
      }
      if (duplicateReader) {
        throw const _ObservationAbort(
          ReconstructionObservationUnknownReason.unsupportedDependency,
        );
      }

      final start = await context.runBounded(
        () => acquiredAttempt.readFingerprint(context),
      );
      final phaseEvidence = <ReconstructionPhaseEvidence>[];
      for (final phase in ReconstructionObservationPhase.values) {
        final reader = readers[phase];
        if (reader == null) {
          phaseEvidence.add(
            ReconstructionPhaseEvidence.unknown(
              phase: phase,
              reason: ReconstructionObservationUnknownReason.missingEvidence,
            ),
          );
          continue;
        }
        final evidence = await context.runBounded(() => reader(context));
        if (evidence.phase != phase ||
            (evidence.payload != null &&
                evidence.payload!.phase != evidence.phase)) {
          throw const _ObservationAbort(
            ReconstructionObservationUnknownReason.unsupportedDependency,
          );
        }
        phaseEvidence.add(evidence);
      }
      final end = await context.runBounded(
        () => acquiredAttempt.readFingerprint(context),
      );
      final comparison = await _compareFingerprints(
        start: start,
        end: end,
        attempt: acquiredAttempt,
        context: context,
      );
      if (!comparison.isEqual) {
        outcome = _AttemptOutcome.fingerprintMismatch(comparison);
      } else {
        outcome = _AttemptOutcome.accepted(phaseEvidence);
      }
    } on _ObservationAbort catch (error) {
      outcome = _AttemptOutcome.unknown(error.reason);
    } on Object {
      outcome = _AttemptOutcome.unknown(
        ReconstructionObservationUnknownReason.phaseFailure,
      );
    }

    if (attempt != null) {
      try {
        await attempt.close().timeout(limits.cleanupTimeout);
      } on Object {
        outcome = _AttemptOutcome.unknown(
          ReconstructionObservationUnknownReason.ambiguousCleanup,
        );
      }
    }
    return outcome;
  }

  Future<_FingerprintComparison> _compareFingerprints({
    required ReconstructionObservationFingerprint start,
    required ReconstructionObservationFingerprint end,
    required ReconstructionObservationAttempt attempt,
    required ReconstructionObservationAttemptContext context,
  }) async {
    var totalMismatchCount = 0;
    final diagnostics = <String>[];

    void record(String field) {
      totalMismatchCount += 1;
      if (diagnostics.length < limits.maximumDiagnostics) {
        diagnostics.add(field);
      }
    }

    for (final entry in start.materialFields.entries) {
      if (entry.value != end.materialFields[entry.key]) {
        record(entry.key);
      }
    }

    final startOperational = <String, OperationalTimestampProvenance>{
      for (final provenance in start.operationalTimestamps)
        provenance.fieldIdentity: provenance,
    };
    final endOperational = <String, OperationalTimestampProvenance>{
      for (final provenance in end.operationalTimestamps)
        provenance.fieldIdentity: provenance,
    };
    final identities = <String>{
      ...startOperational.keys,
      ...endOperational.keys,
    }.toList()..sort();
    for (final identity in identities) {
      final before = startOperational[identity];
      final after = endOperational[identity];
      if (before != null && after != null && before.sameAs(after)) {
        continue;
      }
      final validator = attempt.validateOperationalTimestamp;
      if (before == null || after == null || validator == null) {
        record('operationalTimestamp:$identity');
        continue;
      }
      bool validated;
      try {
        validated = await context.runBounded(
          () => validator(start: before, end: after),
        );
      } on _ObservationAbort {
        rethrow;
      } on Object {
        throw const _ObservationAbort(
          ReconstructionObservationUnknownReason.unsupportedDependency,
        );
      }
      if (!validated) {
        record('operationalTimestamp:$identity');
      }
    }
    return _FingerprintComparison(
      totalMismatchCount: totalMismatchCount,
      diagnostics: diagnostics,
    );
  }
}

final class _ObservationAbort implements Exception {
  const _ObservationAbort(this.reason);

  final ReconstructionObservationUnknownReason reason;
}

final class _FingerprintComparison {
  _FingerprintComparison({
    required this.totalMismatchCount,
    required List<String> diagnostics,
  }) : diagnostics = List.unmodifiable(diagnostics);

  final int totalMismatchCount;
  final List<String> diagnostics;

  bool get isEqual => totalMismatchCount == 0;
}

final class _AttemptOutcome {
  _AttemptOutcome._({
    required this.truth,
    required this.unknownReason,
    required this.phaseEvidence,
    required this.isFingerprintMismatch,
    required this.totalFingerprintMismatchCount,
    required this.fingerprintMismatchDiagnostics,
  });

  factory _AttemptOutcome.accepted(List<ReconstructionPhaseEvidence> evidence) {
    final falseEvidence = evidence.any(
      (item) => item.truth == ReconstructionObservationTruth.falseValue,
    );
    final firstUnknown = evidence
        .where((item) => item.truth == ReconstructionObservationTruth.unknown)
        .firstOrNull;
    return _AttemptOutcome._(
      truth: falseEvidence
          ? ReconstructionObservationTruth.falseValue
          : firstUnknown == null
          ? ReconstructionObservationTruth.trueValue
          : ReconstructionObservationTruth.unknown,
      unknownReason: falseEvidence ? null : firstUnknown?.unknownReason,
      phaseEvidence: List.unmodifiable(evidence),
      isFingerprintMismatch: false,
      totalFingerprintMismatchCount: 0,
      fingerprintMismatchDiagnostics: const [],
    );
  }

  factory _AttemptOutcome.fingerprintMismatch(
    _FingerprintComparison comparison,
  ) {
    return _AttemptOutcome._(
      truth: ReconstructionObservationTruth.unknown,
      unknownReason: ReconstructionObservationUnknownReason.intervalInstability,
      phaseEvidence: const [],
      isFingerprintMismatch: true,
      totalFingerprintMismatchCount: comparison.totalMismatchCount,
      fingerprintMismatchDiagnostics: comparison.diagnostics,
    );
  }

  factory _AttemptOutcome.unknown(
    ReconstructionObservationUnknownReason reason,
  ) {
    return _AttemptOutcome._(
      truth: ReconstructionObservationTruth.unknown,
      unknownReason: reason,
      phaseEvidence: const [],
      isFingerprintMismatch: false,
      totalFingerprintMismatchCount: 0,
      fingerprintMismatchDiagnostics: const [],
    );
  }

  final ReconstructionObservationTruth truth;
  final ReconstructionObservationUnknownReason? unknownReason;
  final List<ReconstructionPhaseEvidence> phaseEvidence;
  final bool isFingerprintMismatch;
  final int totalFingerprintMismatchCount;
  final List<String> fingerprintMismatchDiagnostics;

  CoherentReconstructionObservationResult toPublicResult({
    required int attemptCount,
    int earlierMismatchCount = 0,
    List<String> earlierMismatchDiagnostics = const [],
    int diagnosticLimit = 64,
  }) {
    return CoherentReconstructionObservationResult(
      truth: truth,
      unknownReason: unknownReason,
      attemptCount: attemptCount,
      phaseEvidence: phaseEvidence,
      totalFingerprintMismatchCount:
          earlierMismatchCount + totalFingerprintMismatchCount,
      fingerprintMismatchDiagnostics: _boundedDiagnostics(<String>[
        ...earlierMismatchDiagnostics,
        ...fingerprintMismatchDiagnostics,
      ], diagnosticLimit),
    );
  }
}

List<String> _boundedDiagnostics(List<String> values, int limit) {
  return List.unmodifiable(values.take(limit));
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
