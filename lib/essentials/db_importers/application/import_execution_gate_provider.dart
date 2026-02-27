import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'import_execution_gate_provider.g.dart';

class ImportExecutionGateState {
  const ImportExecutionGateState({
    this.owner,
    this.holdCount = 0,
    this.acquiredAtUtc,
    this.lastDeniedOwner,
    this.lastDeniedAtUtc,
    this.deniedRequests = 0,
  });

  final String? owner;
  final int holdCount;
  final DateTime? acquiredAtUtc;
  final String? lastDeniedOwner;
  final DateTime? lastDeniedAtUtc;
  final int deniedRequests;

  bool get isLocked => owner != null;

  ImportExecutionGateState copyWith({
    String? owner,
    int? holdCount,
    DateTime? acquiredAtUtc,
    String? lastDeniedOwner,
    DateTime? lastDeniedAtUtc,
    int? deniedRequests,
    bool clearOwner = false,
    bool clearAcquiredAtUtc = false,
  }) {
    return ImportExecutionGateState(
      owner: clearOwner ? null : owner ?? this.owner,
      holdCount: holdCount ?? this.holdCount,
      acquiredAtUtc: clearAcquiredAtUtc
          ? null
          : acquiredAtUtc ?? this.acquiredAtUtc,
      lastDeniedOwner: lastDeniedOwner ?? this.lastDeniedOwner,
      lastDeniedAtUtc: lastDeniedAtUtc ?? this.lastDeniedAtUtc,
      deniedRequests: deniedRequests ?? this.deniedRequests,
    );
  }
}

/// Global import/migration execution gate.
///
/// This acts as a single source of truth for who currently owns the import
/// execution token ("the ball"). Only one owner may run import/migration work
/// at a time. Re-entrant acquisition by the same owner is allowed.
@Riverpod(keepAlive: true)
class ImportExecutionGate extends _$ImportExecutionGate {
  @override
  ImportExecutionGateState build() {
    return const ImportExecutionGateState();
  }

  bool tryAcquire(String owner) {
    final now = DateTime.now().toUtc();

    if (!state.isLocked) {
      state = ImportExecutionGateState(
        owner: owner,
        holdCount: 1,
        acquiredAtUtc: now,
        lastDeniedOwner: state.lastDeniedOwner,
        lastDeniedAtUtc: state.lastDeniedAtUtc,
        deniedRequests: state.deniedRequests,
      );
      return true;
    }

    if (state.owner == owner) {
      state = state.copyWith(holdCount: state.holdCount + 1);
      return true;
    }

    state = state.copyWith(
      lastDeniedOwner: owner,
      lastDeniedAtUtc: now,
      deniedRequests: state.deniedRequests + 1,
    );
    return false;
  }

  void release(String owner) {
    if (!state.isLocked || state.owner != owner) {
      return;
    }

    final nextHoldCount = state.holdCount - 1;
    if (nextHoldCount > 0) {
      state = state.copyWith(holdCount: nextHoldCount);
      return;
    }

    state = state.copyWith(
      clearOwner: true,
      holdCount: 0,
      clearAcquiredAtUtc: true,
    );
  }
}
