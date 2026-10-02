import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_current_state_reader_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_evidence_reader.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';

void main() {
  test('each read classifies fresh durable evidence', () async {
    final evidenceReader = _SequenceEvidenceReader([
      _resumableEvidence(),
      _completedEvidence(),
    ]);
    final reader = BoundedAdvancedStartFreshCurrentStateReader(
      archiveRootPath: '/test/archive',
      evidenceReader: evidenceReader,
    );

    expect(
      (await reader.readCurrentState()).kind,
      MessageLensInstallationStateKind.resumable,
    );
    expect(
      (await reader.readCurrentState()).kind,
      MessageLensInstallationStateKind.completed,
    );
    expect(evidenceReader.requestedRoots, ['/test/archive', '/test/archive']);
  });
}

MessageLensInstallationEvidence _resumableEvidence() {
  return MessageLensInstallationEvidence(
    sourceScopedImport: const InstallationDatabaseEvidence.absent(),
    conversationGraph: const InstallationDatabaseEvidence.absent(),
    overlay: const InstallationDatabaseEvidence.absent(),
    presence: const InstallationDatabaseEvidence.absent(),
    hasRetiredDerivedArtifacts: false,
    operationSnapshot: OnboardingOperationSnapshot.running(
      operationId: OnboardingOperationId(
        '123e4567-e89b-42d3-a456-426614174020',
      ),
      processSessionId: OnboardingProcessSessionId(
        '123e4567-e89b-42d3-a456-426614174021',
      ),
      kind: OnboardingOperationKind.initialImport,
      stage: OnboardingOperationStage.messageDataBuild,
      observedAtUtc: DateTime.utc(2026, 9, 30),
    ),
  );
}

MessageLensInstallationEvidence _completedEvidence() {
  return const MessageLensInstallationEvidence(
    sourceScopedImport: InstallationDatabaseEvidence.passed(
      userVersion: 1,
      messageCount: 12,
      nonLiveSourceCount: 0,
    ),
    conversationGraph: InstallationDatabaseEvidence.passed(
      userVersion: 1,
      messageCount: 12,
      chatCount: 2,
      chatMessageEdgeCount: 12,
    ),
    overlay: InstallationDatabaseEvidence.absent(),
    presence: InstallationDatabaseEvidence.absent(),
    hasRetiredDerivedArtifacts: false,
    operationSnapshot: OnboardingOperationSnapshot.idle(),
  );
}

final class _SequenceEvidenceReader
    implements MessageLensInstallationEvidenceReader {
  _SequenceEvidenceReader(this._evidence);

  final List<MessageLensInstallationEvidence> _evidence;
  final requestedRoots = <String>[];
  int _index = 0;

  @override
  Future<MessageLensInstallationEvidence> readBounded({
    required String archiveRootPath,
  }) async {
    requestedRoots.add(archiveRootPath);
    return _evidence[_index++];
  }
}
