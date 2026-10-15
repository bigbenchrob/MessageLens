import 'package:flutter_test/flutter_test.dart';

import 'coherent_populated_reconstruction_observation.dart';

void main() {
  group('coherent populated reconstruction observation envelope', () {
    test('accepts one stable interval without destructive authority', () async {
      final harness = _Harness();

      final result = await harness.observe();

      expect(result.truth, ReconstructionObservationTruth.trueValue);
      expect(result.attemptCount, 1);
      expect(result.phaseEvidence, hasLength(8));
      expect(result.canAuthorizeDestructiveMutation, isFalse);
      expect(harness.createdAttemptIds, <int>[1]);
      expect(harness.closeCounts, <int, int>{1: 1});
    });

    test('discards one mismatch and accepts a fully fresh retry', () async {
      final firstAttemptEvidence = <ReconstructionPhaseEvidence>[];
      final secondAttemptEvidence = <ReconstructionPhaseEvidence>[];
      final harness = _Harness(
        fingerprintForRead: (attempt, read) {
          if (attempt == 1 && read == 2) {
            return _fingerprint(graphIdentity: 'graph-drift');
          }
          return _fingerprint();
        },
        evidenceForPhase: (attempt, phase, context) {
          final evidence = _trueEvidence(phase);
          if (attempt == 1) {
            firstAttemptEvidence.add(evidence);
          } else {
            secondAttemptEvidence.add(evidence);
          }
          return evidence;
        },
      );

      final result = await harness.observe();

      expect(result.truth, ReconstructionObservationTruth.trueValue);
      expect(result.attemptCount, 2);
      expect(result.totalFingerprintMismatchCount, 1);
      expect(result.fingerprintMismatchDiagnostics, <String>['graphIdentity']);
      expect(harness.createdAttemptIds, <int>[1, 2]);
      expect(harness.closeCounts, <int, int>{1: 1, 2: 1});
      expect(harness.phaseAttemptIds.toSet(), <int>{1, 2});
      expect(result.phaseEvidence.any(firstAttemptEvidence.contains), isFalse);
      expect(
        result.phaseEvidence.every(secondAttemptEvidence.contains),
        isTrue,
      );
    });

    test('two mismatches yield UNKNOWN after exactly two attempts', () async {
      final harness = _Harness(
        fingerprintForRead: (attempt, read) => read == 1
            ? _fingerprint()
            : _fingerprint(graphIdentity: 'graph-drift-$attempt'),
      );

      final result = await harness.observe();

      expect(result.truth, ReconstructionObservationTruth.unknown);
      expect(
        result.unknownReason,
        ReconstructionObservationUnknownReason.intervalInstability,
      );
      expect(result.attemptCount, 2);
      expect(result.totalFingerprintMismatchCount, 2);
      expect(result.phaseEvidence, isEmpty);
      expect(harness.createdAttemptIds, <int>[1, 2]);
      expect(harness.closeCounts, <int, int>{1: 1, 2: 1});
    });

    test('every binding-domain drift independently yields UNKNOWN', () async {
      final variants =
          <String, ReconstructionObservationFingerprint Function()>{
            'archiveInstanceUuid': () =>
                _fingerprint(archiveInstanceUuid: 'archive-drift'),
            'canonicalRoot': () => _fingerprint(canonicalRoot: '/root/drift'),
            'markerIdentity': () =>
                _fingerprint(markerIdentity: 'marker-drift'),
            'locationGeneration': () => _fingerprint(locationGeneration: 2),
            'sourceOccurrencesIdentity': () =>
                _fingerprint(sourceOccurrencesIdentity: 'occurrences-drift'),
            'sourceRegistryIdentity': () =>
                _fingerprint(sourceRegistryIdentity: 'registry-drift'),
            'ledgerIdentity': () =>
                _fingerprint(ledgerIdentity: 'ledger-drift'),
            'graphIdentity': () => _fingerprint(graphIdentity: 'graph-drift'),
            'overlayIdentity': () =>
                _fingerprint(overlayIdentity: 'overlay-drift'),
            'presenceIdentity': () =>
                _fingerprint(presenceIdentity: 'presence-drift'),
            'journalsReceiptsAndOperationsIdentity': () => _fingerprint(
              journalsReceiptsAndOperationsIdentity: 'history-drift',
            ),
            'implementationIdentity': () =>
                _fingerprint(implementationIdentity: 'implementation-drift'),
            'runtimeIdentity': () =>
                _fingerprint(runtimeIdentity: 'runtime-drift'),
          };

      for (final variant in variants.entries) {
        final harness = _Harness(
          fingerprintForRead: (attempt, read) =>
              read == 1 ? _fingerprint() : variant.value(),
        );

        final result = await harness.observe();

        expect(
          result.unknownReason,
          ReconstructionObservationUnknownReason.intervalInstability,
          reason: variant.key,
        );
        expect(result.attemptCount, 2, reason: variant.key);
        expect(result.totalFingerprintMismatchCount, 2, reason: variant.key);
        expect(result.fingerprintMismatchDiagnostics, <String>[
          variant.key,
          variant.key,
        ], reason: variant.key);
        expect(harness.closeCounts, <int, int>{1: 1, 2: 1});
      }
    });

    test(
      'a coherent contradiction is FALSE while another phase stays unknown',
      () async {
        final harness = _Harness(
          evidenceForPhase: (attempt, phase, context) {
            if (phase == ReconstructionObservationPhase.ledger) {
              return ReconstructionPhaseEvidence.known(
                payload: _payloadFor(phase),
                isTrue: false,
                diagnostic: 'ledger contradiction',
              );
            }
            if (phase == ReconstructionObservationPhase.presence) {
              return ReconstructionPhaseEvidence.unknown(
                phase: phase,
                reason: ReconstructionObservationUnknownReason.missingEvidence,
              );
            }
            return _trueEvidence(phase);
          },
        );

        final result = await harness.observe();

        expect(result.truth, ReconstructionObservationTruth.falseValue);
        expect(result.unknownReason, isNull);
        expect(
          result.phaseEvidence
              .singleWhere(
                (item) => item.phase == ReconstructionObservationPhase.presence,
              )
              .truth,
          ReconstructionObservationTruth.unknown,
        );
      },
    );

    test(
      'discarded contradiction cannot leak into an accepted retry',
      () async {
        final harness = _Harness(
          fingerprintForRead: (attempt, read) {
            if (attempt == 1 && read == 2) {
              return _fingerprint(graphIdentity: 'unstable');
            }
            return _fingerprint();
          },
          evidenceForPhase: (attempt, phase, context) {
            if (attempt == 1 &&
                phase == ReconstructionObservationPhase.ledger) {
              return ReconstructionPhaseEvidence.known(
                payload: _payloadFor(phase),
                isTrue: false,
              );
            }
            return _trueEvidence(phase);
          },
        );

        final result = await harness.observe();

        expect(result.truth, ReconstructionObservationTruth.trueValue);
        expect(
          result.phaseEvidence.every(
            (item) => item.truth == ReconstructionObservationTruth.trueValue,
          ),
          isTrue,
        );
        expect(result.phaseEvidence, hasLength(8));
      },
    );

    test(
      'cancellation and deadline fail closed and stop later phases',
      () async {
        for (final reason in <ReconstructionObservationUnknownReason>[
          ReconstructionObservationUnknownReason.cancellation,
          ReconstructionObservationUnknownReason.deadline,
        ]) {
          final clock = _FakeClock();
          var cancelled = false;
          final visited = <ReconstructionObservationPhase>[];
          final harness = _Harness(
            clock: clock,
            isCancelled: () => cancelled,
            evidenceForPhase: (attempt, phase, context) {
              visited.add(phase);
              if (phase == ReconstructionObservationPhase.graph) {
                if (reason ==
                    ReconstructionObservationUnknownReason.cancellation) {
                  cancelled = true;
                } else {
                  clock.advance(const Duration(seconds: 6));
                }
                context.checkpoint();
              }
              return _trueEvidence(phase);
            },
          );

          final result = await harness.observe();

          expect(result.truth, ReconstructionObservationTruth.unknown);
          expect(result.unknownReason, reason);
          expect(visited, <ReconstructionObservationPhase>[
            ReconstructionObservationPhase.archiveBinding,
            ReconstructionObservationPhase.sourceOccurrencesAndRegistry,
            ReconstructionObservationPhase.ledger,
            ReconstructionObservationPhase.graph,
          ]);
          expect(harness.closeCounts, <int, int>{1: 1});
        }
      },
    );

    test('all accounting limits fail closed with distinct reasons', () async {
      final cases =
          <
            ReconstructionObservationUnknownReason,
            void Function(ReconstructionObservationAttemptContext)
          >{
            ReconstructionObservationUnknownReason.rowLimit: (context) {
              context.recordPage(rows: 20001, bytes: 1, memoryBytes: 1);
            },
            ReconstructionObservationUnknownReason.byteLimit: (context) {
              context.recordPage(rows: 1, bytes: 2000001, memoryBytes: 1);
            },
            ReconstructionObservationUnknownReason.memoryLimit: (context) {
              context.recordPage(rows: 1, bytes: 1, memoryBytes: 2000001);
            },
            ReconstructionObservationUnknownReason.diskLimit: (context) {
              context.recordPage(
                rows: 1,
                bytes: 1,
                memoryBytes: 1,
                diskBytes: 2000001,
              );
            },
            ReconstructionObservationUnknownReason.diagnosticLimit: (context) {
              context.recordPage(
                rows: 1,
                bytes: 1,
                memoryBytes: 1,
                diagnostics: 9,
              );
            },
          };

      for (final item in cases.entries) {
        final harness = _Harness(
          evidenceForPhase: (attempt, phase, context) {
            if (phase == ReconstructionObservationPhase.ledger) {
              item.value(context);
            }
            return _trueEvidence(phase);
          },
        );

        final result = await harness.observe();

        expect(result.unknownReason, item.key);
        expect(result.truth, ReconstructionObservationTruth.unknown);
        expect(harness.closeCounts, <int, int>{1: 1});
      }
    });

    test('operational timestamps require exact lifecycle validation', () async {
      final before = _fingerprint(
        operationalTimestamps: const [
          OperationalTimestampProvenance(
            fieldIdentity: 'receipt.createdAt',
            lifecycleIdentity: 'receipt-insert',
            value: '1',
          ),
        ],
      );
      final after = _fingerprint(
        operationalTimestamps: const [
          OperationalTimestampProvenance(
            fieldIdentity: 'receipt.createdAt',
            lifecycleIdentity: 'receipt-insert',
            value: '2',
          ),
        ],
      );
      for (final validatorResult in <bool?>[null, false, true]) {
        final validations = <String>[];
        final harness = _Harness(
          fingerprintForRead: (attempt, read) => read == 1 ? before : after,
          validator: validatorResult == null
              ? null
              : ({required start, required end}) async {
                  validations.add(
                    '${start.lifecycleIdentity}:${start.value}->${end.value}',
                  );
                  return validatorResult;
                },
        );

        final result = await harness.observe();

        if (validatorResult == true) {
          expect(result.truth, ReconstructionObservationTruth.trueValue);
          expect(result.attemptCount, 1);
          expect(validations, <String>['receipt-insert:1->2']);
        } else {
          expect(
            result.unknownReason,
            ReconstructionObservationUnknownReason.intervalInstability,
          );
          expect(result.attemptCount, 2);
          expect(validations.length, validatorResult == null ? 0 : 2);
        }
      }
    });

    test('validator failure is an unsupported dependency', () async {
      final harness = _Harness(
        fingerprintForRead: (attempt, read) => _fingerprint(
          operationalTimestamps: [
            OperationalTimestampProvenance(
              fieldIdentity: 'operation.updatedAt',
              lifecycleIdentity: 'operation-progress',
              value: '$read',
            ),
          ],
        ),
        validator: ({required start, required end}) {
          throw StateError('validator unavailable');
        },
      );

      final result = await harness.observe();

      expect(
        result.unknownReason,
        ReconstructionObservationUnknownReason.unsupportedDependency,
      );
      expect(harness.closeCounts, <int, int>{1: 1});
    });

    test('missing phase evidence remains explicit UNKNOWN', () async {
      final harness = _Harness(
        omittedPhase: ReconstructionObservationPhase.presence,
      );

      final result = await harness.observe();

      expect(result.truth, ReconstructionObservationTruth.unknown);
      expect(
        result.unknownReason,
        ReconstructionObservationUnknownReason.missingEvidence,
      );
      expect(result.phaseEvidence, hasLength(8));
    });

    test('cleanup ambiguity never yields TRUE', () async {
      final harness = _Harness(closeFailureAttempt: 1);

      final result = await harness.observe();

      expect(result.truth, ReconstructionObservationTruth.unknown);
      expect(
        result.unknownReason,
        ReconstructionObservationUnknownReason.ambiguousCleanup,
      );
      expect(harness.closeCounts, <int, int>{1: 1});
    });

    test(
      '10,001 records retain at most one bounded page and fixed diagnostics',
      () async {
        var liveRecords = 0;
        var maximumLiveRecords = 0;
        final harness = _Harness(
          evidenceForPhase: (attempt, phase, context) {
            if (phase == ReconstructionObservationPhase.ledger) {
              var remaining = 10001;
              while (remaining > 0) {
                final pageRecords = remaining > 100 ? 100 : remaining;
                liveRecords += pageRecords;
                if (liveRecords > maximumLiveRecords) {
                  maximumLiveRecords = liveRecords;
                }
                context.recordPage(
                  rows: pageRecords,
                  bytes: pageRecords * 8,
                  memoryBytes: pageRecords * 8,
                );
                liveRecords -= pageRecords;
                context.releasePageMemory(pageRecords * 8);
                remaining -= pageRecords;
              }
            }
            return _trueEvidence(phase);
          },
        );

        final result = await harness.observe();

        expect(result.truth, ReconstructionObservationTruth.trueValue);
        expect(maximumLiveRecords, 100);
        expect(liveRecords, 0);
        expect(result.fingerprintMismatchDiagnostics, isEmpty);
      },
    );

    test('failure and cancellation at every phase always clean once', () async {
      for (final phaseToStop in ReconstructionObservationPhase.values) {
        for (final cancellation in <bool>[false, true]) {
          var cancelled = false;
          final harness = _Harness(
            isCancelled: () => cancelled,
            evidenceForPhase: (attempt, phase, context) {
              if (phase == phaseToStop) {
                if (cancellation) {
                  cancelled = true;
                  context.checkpoint();
                }
                throw StateError('phase failure');
              }
              return _trueEvidence(phase);
            },
          );

          final result = await harness.observe();

          expect(
            result.unknownReason,
            cancellation
                ? ReconstructionObservationUnknownReason.cancellation
                : ReconstructionObservationUnknownReason.phaseFailure,
          );
          expect(result.attemptCount, 1);
          expect(harness.createdAttemptIds, <int>[1]);
          expect(harness.closeCounts, <int, int>{1: 1});
        }
      }
    });

    test(
      'retry owns fresh callbacks and resources with no survivors',
      () async {
        final resourceTokens = <int, Object>{};
        final seenTokens = <Object>[];
        final harness = _Harness(
          onCreateAttempt: (attempt) {
            resourceTokens[attempt] = Object();
          },
          onReadPhase: (attempt, phase) {
            seenTokens.add(resourceTokens[attempt]!);
          },
          fingerprintForRead: (attempt, read) {
            if (read == 2) {
              return _fingerprint(graphIdentity: 'drift-$attempt');
            }
            return _fingerprint();
          },
        );

        final result = await harness.observe();

        expect(
          result.unknownReason,
          ReconstructionObservationUnknownReason.intervalInstability,
        );
        expect(resourceTokens[1], isNot(same(resourceTokens[2])));
        expect(
          seenTokens
              .where((token) => identical(token, resourceTokens[1]))
              .length,
          8,
        );
        expect(
          seenTokens
              .where((token) => identical(token, resourceTokens[2]))
              .length,
          8,
        );
        expect(harness.closeCounts, <int, int>{1: 1, 2: 1});
        expect(harness.createdAttemptIds, hasLength(2));
      },
    );

    test(
      'mismatch examples are bounded while counts remain complete',
      () async {
        final harness = _Harness(
          fingerprintForRead: (attempt, read) => read == 1
              ? _fingerprint()
              : _fingerprint(
                  archiveInstanceUuid: 'a',
                  canonicalRoot: 'b',
                  markerIdentity: 'c',
                  locationGeneration: 2,
                  sourceOccurrencesIdentity: 'd',
                  sourceRegistryIdentity: 'e',
                  ledgerIdentity: 'f',
                  graphIdentity: 'g',
                  overlayIdentity: 'h',
                  presenceIdentity: 'i',
                  journalsReceiptsAndOperationsIdentity: 'j',
                  implementationIdentity: 'k',
                  runtimeIdentity: 'l',
                ),
        );

        final result = await harness.observe();

        expect(result.attemptCount, 2);
        expect(result.totalFingerprintMismatchCount, 26);
        expect(result.fingerprintMismatchDiagnostics, hasLength(8));
      },
    );
  });
}

final class _FakeClock {
  Duration _value = Duration.zero;

  Duration call() => _value;

  void advance(Duration duration) {
    _value += duration;
  }
}

typedef _FingerprintForRead =
    ReconstructionObservationFingerprint Function(int attempt, int read);
typedef _EvidenceForPhase =
    ReconstructionPhaseEvidence Function(
      int attempt,
      ReconstructionObservationPhase phase,
      ReconstructionObservationAttemptContext context,
    );

final class _Harness {
  _Harness({
    _FakeClock? clock,
    ReconstructionCancellationReader? isCancelled,
    _FingerprintForRead? fingerprintForRead,
    _EvidenceForPhase? evidenceForPhase,
    this.validator,
    this.omittedPhase,
    this.closeFailureAttempt,
    this.onCreateAttempt,
    this.onReadPhase,
  }) : clock = clock ?? _FakeClock(),
       isCancelled = isCancelled ?? (() => false),
       fingerprintForRead =
           fingerprintForRead ?? ((attempt, read) => _fingerprint()),
       evidenceForPhase =
           evidenceForPhase ??
           ((attempt, phase, context) => _trueEvidence(phase));

  final _FakeClock clock;
  final ReconstructionCancellationReader isCancelled;
  final _FingerprintForRead fingerprintForRead;
  final _EvidenceForPhase evidenceForPhase;
  final OperationalTimestampLifecycleValidator? validator;
  final ReconstructionObservationPhase? omittedPhase;
  final int? closeFailureAttempt;
  final void Function(int attempt)? onCreateAttempt;
  final void Function(int attempt, ReconstructionObservationPhase phase)?
  onReadPhase;

  final List<int> createdAttemptIds = <int>[];
  final List<int> phaseAttemptIds = <int>[];
  final Map<int, int> closeCounts = <int, int>{};

  Future<CoherentReconstructionObservationResult> observe() {
    final envelope = CoherentPopulatedReconstructionObservationEnvelope(
      limits: const ReconstructionObservationLimits(
        deadline: Duration(seconds: 5),
        maximumRows: 20000,
        maximumBytes: 2000000,
        maximumMemoryBytes: 2000000,
        maximumDiskBytes: 2000000,
        maximumDiagnostics: 8,
      ),
      clock: clock.call,
      isCancelled: isCancelled,
    );
    return envelope.observe(
      createAttempt: (attempt, context) async {
        createdAttemptIds.add(attempt);
        onCreateAttempt?.call(attempt);
        var fingerprintRead = 0;
        return ReconstructionObservationAttempt(
          readFingerprint: (context) async {
            fingerprintRead += 1;
            return fingerprintForRead(attempt, fingerprintRead);
          },
          phaseReaders: <ReconstructionObservationPhaseReader>[
            for (final phase in ReconstructionObservationPhase.values)
              if (phase != omittedPhase)
                ReconstructionObservationPhaseReader(
                  phase: phase,
                  read: (context) async {
                    phaseAttemptIds.add(attempt);
                    onReadPhase?.call(attempt, phase);
                    return evidenceForPhase(attempt, phase, context);
                  },
                ),
          ],
          validateOperationalTimestamp: validator,
          close: () async {
            closeCounts.update(
              attempt,
              (count) => count + 1,
              ifAbsent: () => 1,
            );
            if (closeFailureAttempt == attempt) {
              throw StateError('ambiguous cleanup');
            }
          },
        );
      },
    );
  }
}

ReconstructionPhaseEvidence _trueEvidence(
  ReconstructionObservationPhase phase,
) {
  return ReconstructionPhaseEvidence.known(
    payload: _payloadFor(phase),
    isTrue: true,
  );
}

ReconstructionPhasePayload _payloadFor(ReconstructionObservationPhase phase) {
  return switch (phase) {
    ReconstructionObservationPhase.archiveBinding =>
      const ArchiveBindingPhasePayload(
        archiveInstanceUuid: 'archive',
        canonicalRoot: '/root',
        markerIdentity: 'marker',
        locationGeneration: 1,
      ),
    ReconstructionObservationPhase.sourceOccurrencesAndRegistry =>
      const SourceOccurrencesAndRegistryPhasePayload(
        occurrencesIdentity: 'occurrences',
        registryIdentity: 'registry',
      ),
    ReconstructionObservationPhase.ledger => const LedgerPhasePayload(
      materialIdentity: 'ledger',
    ),
    ReconstructionObservationPhase.graph => const GraphPhasePayload(
      materialIdentity: 'graph',
    ),
    ReconstructionObservationPhase.overlay => const OverlayPhasePayload(
      materialIdentity: 'overlay',
    ),
    ReconstructionObservationPhase.presence => const PresencePhasePayload(
      materialIdentity: 'presence',
    ),
    ReconstructionObservationPhase.journalsReceiptsAndOperations =>
      const JournalsReceiptsAndOperationsPhasePayload(
        materialIdentity: 'history',
      ),
    ReconstructionObservationPhase.implementationAndRuntime =>
      const ImplementationAndRuntimePhasePayload(
        implementationIdentity: 'implementation',
        runtimeIdentity: 'runtime',
      ),
  };
}

ReconstructionObservationFingerprint _fingerprint({
  String archiveInstanceUuid = 'archive',
  String canonicalRoot = '/root',
  String markerIdentity = 'marker',
  int locationGeneration = 1,
  String sourceOccurrencesIdentity = 'occurrences',
  String sourceRegistryIdentity = 'registry',
  String ledgerIdentity = 'ledger',
  String graphIdentity = 'graph',
  String overlayIdentity = 'overlay',
  String presenceIdentity = 'presence',
  String journalsReceiptsAndOperationsIdentity = 'history',
  String implementationIdentity = 'implementation',
  String runtimeIdentity = 'runtime',
  List<OperationalTimestampProvenance> operationalTimestamps = const [],
}) {
  return ReconstructionObservationFingerprint(
    archiveInstanceUuid: archiveInstanceUuid,
    canonicalRoot: canonicalRoot,
    markerIdentity: markerIdentity,
    locationGeneration: locationGeneration,
    sourceOccurrencesIdentity: sourceOccurrencesIdentity,
    sourceRegistryIdentity: sourceRegistryIdentity,
    ledgerIdentity: ledgerIdentity,
    graphIdentity: graphIdentity,
    overlayIdentity: overlayIdentity,
    presenceIdentity: presenceIdentity,
    journalsReceiptsAndOperationsIdentity:
        journalsReceiptsAndOperationsIdentity,
    implementationIdentity: implementationIdentity,
    runtimeIdentity: runtimeIdentity,
    operationalTimestamps: operationalTimestamps,
  );
}
