part of 'archive_mutation_coordinator_provider.dart';

/// Inert observations only: neither authority nor caller-supplied continuations.
final class ArchiveMutationAdmissionObservation {
  const ArchiveMutationAdmissionObservation({
    required this.resetReads,
    required this.candidateReads,
    required this.ordinaryEntries,
    required this.reentrantEntries,
    required this.completed,
    required this.denial,
  });

  final int resetReads;
  final int candidateReads;
  final int ordinaryEntries;
  final int reentrantEntries;
  final bool completed;
  final ArchiveResetDenialReason? denial;
}

/// Hidden from public seams and prohibited in production by architecture tests.
final class ArchiveMutationAdmissionTestSupport {
  const ArchiveMutationAdmissionTestSupport._();

  static Future<ArchiveMutationAdmissionObservation> inspect({
    required ArchiveMutationOperation operation,
    required ArchiveResetAdmission? lifetime,
    required bool reentrantCandidate,
  }) async {
    if (!kDebugMode) {
      throw UnsupportedError('Admission test support is debug-only.');
    }
    var reads = 0;
    var candidates = 0;
    var ordinary = 0;
    var reentrant = 0;
    var completed = false;
    ArchiveResetDenialReason? denial;
    Future<bool> finish(ArchiveResetAdmissionBinding? binding) async {
      // An inert suspension, not an acquired tenure/checkpoint. Exercise the
      // same late-check primitive used before real capability publication.
      await Future<void>.value();
      _requireResetBinding(binding, operation);
      return true;
    }

    try {
      completed = await _dispatchBeforeTenure<bool>(
        operation: operation,
        readAdmission: () {
          reads += 1;
          if (lifetime == null) {
            throw StateError('Synthetic unavailable input');
          }
          return lifetime;
        },
        isReentrantCandidate: () {
          candidates += 1;
          return reentrantCandidate;
        },
        ordinary: (binding) {
          ordinary += 1;
          return finish(binding);
        },
        reentrant: (binding) {
          reentrant += 1;
          return finish(binding);
        },
      );
    } on ArchiveResetDenied catch (error) {
      denial = error.reason;
    }
    return ArchiveMutationAdmissionObservation(
      resetReads: reads,
      candidateReads: candidates,
      ordinaryEntries: ordinary,
      reentrantEntries: reentrant,
      completed: completed,
      denial: denial,
    );
  }
}
