import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_state_classifier.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';

void main() {
  const classifier = MessageLensInstallationStateClassifier();

  test('no consequential artifacts is virgin', () {
    expect(
      classifier.classify(_evidence()).kind,
      MessageLensInstallationStateKind.virgin,
    );
  });

  test('valid empty derived stores are virgin', () {
    expect(
      classifier
          .classify(
            _evidence(
              sourceScopedImport: _usableDatabase(
                messageCount: 0,
                nonLiveSourceCount: 0,
              ),
              conversationGraph: _usableDatabase(
                messageCount: 0,
                chatCount: 0,
                chatMessageEdgeCount: 0,
              ),
            ),
          )
          .kind,
      MessageLensInstallationStateKind.virgin,
    );
  });

  test('one valid empty derived store is still virgin', () {
    expect(
      classifier
          .classify(
            _evidence(
              sourceScopedImport: _usableDatabase(
                messageCount: 0,
                nonLiveSourceCount: 0,
              ),
            ),
          )
          .kind,
      MessageLensInstallationStateKind.virgin,
    );
  });

  test('post-reset empty stores with preserved stores are virgin', () {
    expect(
      classifier
          .classify(
            _evidence(
              sourceScopedImport: _usableDatabase(
                messageCount: 0,
                nonLiveSourceCount: 0,
              ),
              conversationGraph: _usableDatabase(
                messageCount: 0,
                chatCount: 0,
                chatMessageEdgeCount: 0,
              ),
              overlay: _usableDatabase(),
              presence: _usableDatabase(),
            ),
          )
          .kind,
      MessageLensInstallationStateKind.virgin,
    );
  });

  test('running coherent operation is resumable', () {
    expect(
      classifier
          .classify(_evidence(operationSnapshot: _runningSnapshot()))
          .kind,
      MessageLensInstallationStateKind.resumable,
    );
  });

  test('interrupted coherent operation is resumable', () {
    expect(
      classifier
          .classify(
            _evidence(
              operationSnapshot: _runningSnapshot().interrupt(
                observedAtUtc: DateTime.utc(2026, 8, 25, 1),
              ),
            ),
          )
          .kind,
      MessageLensInstallationStateKind.resumable,
    );
  });

  test('retryable failed operation is resumable', () {
    final failed = _runningSnapshot().fail(
      failure: OnboardingOperationFailure(
        category: OnboardingOperationFailureCategory.messageDataBuild,
        occurredAtUtc: DateTime.utc(2026, 8, 25, 2),
        summary: 'interrupted import',
        recoveryDisposition:
            OnboardingOperationRecoveryDisposition.retryFromSafeBoundary,
      ),
    );

    expect(
      classifier.classify(_evidence(operationSnapshot: failed)).kind,
      MessageLensInstallationStateKind.resumable,
    );
  });

  test('idle consequential derived data is abandoned', () {
    expect(
      classifier
          .classify(
            _evidence(sourceScopedImport: _usableDatabase(messageCount: 12)),
          )
          .kind,
      MessageLensInstallationStateKind.abandoned,
    );
  });

  test('retired derived artifacts are consequential', () {
    expect(
      classifier.classify(_evidence(hasRetiredDerivedArtifacts: true)).kind,
      MessageLensInstallationStateKind.abandoned,
    );
  });

  test('healthy durable databases outrank stale snapshot', () {
    final stale = _runningSnapshot().interrupt(
      observedAtUtc: DateTime.utc(2026, 8, 25, 3),
    );
    final state = classifier.classify(
      _evidence(
        sourceScopedImport: _usableDatabase(messageCount: 137373),
        conversationGraph: _usableDatabase(
          messageCount: 137373,
          chatCount: 400,
          chatMessageEdgeCount: 116633,
        ),
        operationSnapshot: stale,
      ),
    );

    expect(state.kind, MessageLensInstallationStateKind.completed);
  });

  test('completed snapshot without durable completion needs remediation', () {
    final completed = _runningSnapshot().complete(
      verifiedAtUtc: DateTime.utc(2026, 8, 25, 4),
    );
    expect(
      classifier.classify(_evidence(operationSnapshot: completed)).kind,
      MessageLensInstallationStateKind.remediationRequired,
    );
  });

  test('unreadable preserved store needs remediation', () {
    const unreadable = InstallationDatabaseEvidence(
      boundedInspectionStatus: InstallationBoundedInspectionStatus.failed,
      failure: InstallationBoundedInspectionFailure(
        kind: InstallationBoundedInspectionFailureKind.invalidSqlite,
        message: 'not a database',
      ),
    );
    expect(
      classifier.classify(_evidence(overlay: unreadable)).kind,
      MessageLensInstallationStateKind.remediationRequired,
    );
  });

  test('historical source evidence blocks ordinary Start Fresh', () {
    expect(
      classifier
          .classify(
            _evidence(
              sourceScopedImport: _usableDatabase(
                messageCount: 12,
                nonLiveSourceCount: 1,
              ),
            ),
          )
          .kind,
      MessageLensInstallationStateKind.remediationRequired,
    );
  });
}

MessageLensInstallationEvidence _evidence({
  InstallationDatabaseEvidence sourceScopedImport =
      const InstallationDatabaseEvidence.absent(),
  InstallationDatabaseEvidence conversationGraph =
      const InstallationDatabaseEvidence.absent(),
  InstallationDatabaseEvidence overlay =
      const InstallationDatabaseEvidence.absent(),
  InstallationDatabaseEvidence presence =
      const InstallationDatabaseEvidence.absent(),
  OnboardingOperationSnapshot operationSnapshot =
      const OnboardingOperationSnapshot.idle(),
  bool hasRetiredDerivedArtifacts = false,
}) {
  return MessageLensInstallationEvidence(
    sourceScopedImport: sourceScopedImport,
    conversationGraph: conversationGraph,
    overlay: overlay,
    presence: presence,
    hasRetiredDerivedArtifacts: hasRetiredDerivedArtifacts,
    operationSnapshot: operationSnapshot,
  );
}

InstallationDatabaseEvidence _usableDatabase({
  int? messageCount,
  int? chatCount,
  int? chatMessageEdgeCount,
  int? nonLiveSourceCount,
}) {
  return InstallationDatabaseEvidence.passed(
    userVersion: 1,
    messageCount: messageCount,
    chatCount: chatCount,
    chatMessageEdgeCount: chatMessageEdgeCount,
    nonLiveSourceCount: nonLiveSourceCount,
  );
}

OnboardingOperationSnapshot _runningSnapshot() {
  return OnboardingOperationSnapshot.running(
    operationId: OnboardingOperationId('123e4567-e89b-42d3-a456-426614174010'),
    processSessionId: OnboardingProcessSessionId(
      '123e4567-e89b-42d3-a456-426614174011',
    ),
    kind: OnboardingOperationKind.initialImport,
    stage: OnboardingOperationStage.messageDataBuild,
    observedAtUtc: DateTime.utc(2026, 8, 25),
  );
}
