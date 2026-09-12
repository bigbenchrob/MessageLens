import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/application/archive_marker_store.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_access_authority.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_build_identity.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_environment.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_instance_id.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_marker.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/resolved_archive_identity.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_state_classifier.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_validation_service.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/onboarding/domain/startup_installation_validation.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/compatibility/legacy_complete_installation_erase_journal_compatibility.dart';

void main() {
  final currentArchiveId = ArchiveInstanceId(
    '11111111-1111-4111-8111-111111111111',
  );
  final replacementArchiveId = ArchiveInstanceId(
    '22222222-2222-4222-8222-222222222222',
  );
  late Directory root;
  late File journal;
  late _FakeMarkerStore markerStore;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('legacy-erase-compat-');
    journal = File(
      path.join(
        root.path,
        LegacyCompleteInstallationEraseJournalCompatibility
            .obsoleteJournalFileName,
      ),
    );
    markerStore = _FakeMarkerStore(
      _marker(archiveInstanceId: currentArchiveId),
    );
  });

  tearDown(() {
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });

  test('without a legacy journal, performs ordinary admission only', () async {
    var admissionCalls = 0;
    final compatibility = _compatibility(_virginEvidence());

    final result = await compatibility.admit(
      canonicalRootPath: root.path,
      expectedEnvironment: ArchiveEnvironment.test,
      markerStore: markerStore,
      ordinaryAdmission: () async {
        admissionCalls += 1;
        return _authority(root.path, currentArchiveId);
      },
    );

    expect(admissionCalls, 1);
    expect(
      result.disposition,
      LegacyCompleteInstallationEraseJournalDisposition.noJournal,
    );
  });

  test('removes only a proven stale pre-erase journal', () async {
    final sentinel = File(path.join(root.path, 'conversation_graph.db'));
    final markerSentinel = File(
      path.join(root.path, '.messagelens-archive.json'),
    );
    await sentinel.writeAsBytes(<int>[1, 2, 3, 4]);
    await markerSentinel.writeAsString('marker bytes');
    await _writeJournal(journal, replacementArchiveId);

    final result = await _compatibility(_completedEvidence()).admit(
      canonicalRootPath: root.path,
      expectedEnvironment: ArchiveEnvironment.test,
      markerStore: markerStore,
      ordinaryAdmission: () async => _authority(root.path, currentArchiveId),
    );

    expect(
      result.disposition,
      LegacyCompleteInstallationEraseJournalDisposition
          .removedStalePreEraseJournal,
    );
    expect(journal.existsSync(), isFalse);
    expect(await sentinel.readAsBytes(), <int>[1, 2, 3, 4]);
    expect(await markerSentinel.readAsString(), 'marker bytes');
    expect(
      root.listSync().map((entity) => path.basename(entity.path)).toSet(),
      <String>{'conversation_graph.db', '.messagelens-archive.json'},
    );
  });

  test('removes only a proven stale post-install journal', () async {
    markerStore.marker = _marker(archiveInstanceId: replacementArchiveId);
    final sentinel = File(path.join(root.path, '.messagelens-archive.json'));
    await sentinel.create();
    await sentinel.writeAsString('preserved');
    await _writeJournal(journal, replacementArchiveId);

    final result = await _compatibility(_virginEvidence()).admit(
      canonicalRootPath: root.path,
      expectedEnvironment: ArchiveEnvironment.test,
      markerStore: markerStore,
      ordinaryAdmission: () async =>
          _authority(root.path, replacementArchiveId),
    );

    expect(
      result.disposition,
      LegacyCompleteInstallationEraseJournalDisposition
          .removedStalePostInstallJournal,
    );
    expect(journal.existsSync(), isFalse);
    expect(await sentinel.readAsString(), 'preserved');
    expect(
      root.listSync().map((entity) => path.basename(entity.path)).toSet(),
      <String>{'.messagelens-archive.json'},
    );
  });

  test('malformed journal fails closed and remains untouched', () async {
    final bytes = utf8.encode('{not-json');
    await journal.writeAsBytes(bytes);

    await expectLater(
      _compatibility(_virginEvidence()).admit(
        canonicalRootPath: root.path,
        expectedEnvironment: ArchiveEnvironment.test,
        markerStore: markerStore,
        ordinaryAdmission: () async => _authority(root.path, currentArchiveId),
      ),
      throwsA(
        isA<LegacyCompleteInstallationEraseJournalException>().having(
          (error) => error.code,
          'code',
          'malformed_journal',
        ),
      ),
    );
    expect(await journal.readAsBytes(), bytes);
  });

  test('environment mismatch fails closed', () async {
    await _writeJournal(
      journal,
      replacementArchiveId,
      environment: ArchiveEnvironment.production,
    );

    await _expectFailure(
      compatibility: _compatibility(_completedEvidence()),
      journal: journal,
      markerStore: markerStore,
      rootPath: root.path,
      code: 'environment_mismatch',
      currentArchiveId: currentArchiveId,
    );
  });

  test('missing marker fails closed', () async {
    markerStore.marker = null;
    await _writeJournal(journal, replacementArchiveId);

    await _expectFailure(
      compatibility: _compatibility(_completedEvidence()),
      journal: journal,
      markerStore: markerStore,
      rootPath: root.path,
      code: 'marker_missing',
      currentArchiveId: currentArchiveId,
    );
  });

  test(
    'matching replacement identity that is not Virgin fails closed',
    () async {
      markerStore.marker = _marker(archiveInstanceId: replacementArchiveId);
      await _writeJournal(journal, replacementArchiveId);

      await _expectFailure(
        compatibility: _compatibility(_completedEvidence()),
        journal: journal,
        markerStore: markerStore,
        rootPath: root.path,
        code: 'replacement_identity_not_virgin',
        currentArchiveId: replacementArchiveId,
      );
    },
  );

  test('failed ordinary admission never permits journal cleanup', () async {
    await _writeJournal(journal, replacementArchiveId);
    final originalBytes = await journal.readAsBytes();

    await expectLater(
      _compatibility(_completedEvidence()).admit(
        canonicalRootPath: root.path,
        expectedEnvironment: ArchiveEnvironment.test,
        markerStore: markerStore,
        ordinaryAdmission: () async => throw StateError('admission denied'),
      ),
      throwsA(
        isA<LegacyCompleteInstallationEraseJournalException>().having(
          (error) => error.code,
          'code',
          'ordinary_admission_failed',
        ),
      ),
    );
    expect(await journal.readAsBytes(), originalBytes);
  });

  test('failed database integrity never permits pre-erase cleanup', () async {
    await _writeJournal(journal, replacementArchiveId);

    await _expectFailure(
      compatibility: _compatibility(
        _completedEvidence(),
        fullIntegrityValidated: false,
      ),
      journal: journal,
      markerStore: markerStore,
      rootPath: root.path,
      code: 'current_archive_not_coherent',
      currentArchiveId: currentArchiveId,
    );
  });

  test('unavailable installation evidence fails closed', () async {
    await _writeJournal(journal, replacementArchiveId);
    final originalBytes = await journal.readAsBytes();
    final compatibility = LegacyCompleteInstallationEraseJournalCompatibility(
      fullValidator: _FakeFullValidator(
        () async => throw StateError('inspection failed'),
      ),
    );

    await expectLater(
      compatibility.admit(
        canonicalRootPath: root.path,
        expectedEnvironment: ArchiveEnvironment.test,
        markerStore: markerStore,
        ordinaryAdmission: () async => _authority(root.path, currentArchiveId),
      ),
      throwsA(
        isA<LegacyCompleteInstallationEraseJournalException>().having(
          (error) => error.code,
          'code',
          'installation_evidence_unavailable',
        ),
      ),
    );
    expect(await journal.readAsBytes(), originalBytes);
  });

  test('unexpected post-install artifact fails closed', () async {
    markerStore.marker = _marker(archiveInstanceId: replacementArchiveId);
    await _writeJournal(journal, replacementArchiveId);
    final payload = File(path.join(root.path, 'attachment_archive'));
    await payload.writeAsString('preserved');

    await _expectFailure(
      compatibility: _compatibility(_virginEvidence()),
      journal: journal,
      markerStore: markerStore,
      rootPath: root.path,
      code: 'replacement_identity_has_unexpected_artifacts',
      currentArchiveId: replacementArchiveId,
    );
    expect(await payload.readAsString(), 'preserved');
  });

  test('unexpected partial archive state fails closed', () async {
    markerStore.marker = _marker(archiveInstanceId: replacementArchiveId);
    await _writeJournal(journal, replacementArchiveId);

    await _expectFailure(
      compatibility: _compatibility(_abandonedEvidence()),
      journal: journal,
      markerStore: markerStore,
      rootPath: root.path,
      code: 'replacement_identity_not_virgin',
      currentArchiveId: replacementArchiveId,
    );
  });

  test(
    'symbolic-link journal path fails closed without touching target',
    () async {
      final target = File(path.join(root.path, 'outside-journal.json'));
      await target.writeAsString('target bytes');
      await Link(journal.path).create(target.path);

      await expectLater(
        _compatibility(_completedEvidence()).admit(
          canonicalRootPath: root.path,
          expectedEnvironment: ArchiveEnvironment.test,
          markerStore: markerStore,
          ordinaryAdmission: () async =>
              _authority(root.path, currentArchiveId),
        ),
        throwsA(
          isA<LegacyCompleteInstallationEraseJournalException>().having(
            (error) => error.code,
            'code',
            'journal_not_regular_file',
          ),
        ),
      );
      expect(await target.readAsString(), 'target bytes');
      expect(await Link(journal.path).exists(), isTrue);
    },
  );

  test(
    'journal changed during inspection is retained and fails closed',
    () async {
      markerStore.marker = _marker(archiveInstanceId: replacementArchiveId);
      await _writeJournal(journal, replacementArchiveId);
      final changedBytes = utf8.encode('changed concurrently');
      final compatibility = LegacyCompleteInstallationEraseJournalCompatibility(
        fullValidator: _FakeFullValidator(() async {
          await journal.writeAsBytes(changedBytes);
          return _fullValidation(_virginEvidence());
        }),
      );

      await expectLater(
        compatibility.admit(
          canonicalRootPath: root.path,
          expectedEnvironment: ArchiveEnvironment.test,
          markerStore: markerStore,
          ordinaryAdmission: () async =>
              _authority(root.path, replacementArchiveId),
        ),
        throwsA(
          isA<LegacyCompleteInstallationEraseJournalException>().having(
            (error) => error.code,
            'code',
            'journal_changed_before_cleanup',
          ),
        ),
      );
      expect(await journal.readAsBytes(), changedBytes);
    },
  );
}

LegacyCompleteInstallationEraseJournalCompatibility _compatibility(
  MessageLensInstallationEvidence evidence, {
  bool fullIntegrityValidated = true,
}) {
  return LegacyCompleteInstallationEraseJournalCompatibility(
    fullValidator: _FakeFullValidator(
      () async => _fullValidation(
        evidence,
        fullIntegrityValidated: fullIntegrityValidated,
      ),
    ),
  );
}

Future<void> _writeJournal(
  File journal,
  ArchiveInstanceId replacementArchiveId, {
  ArchiveEnvironment environment = ArchiveEnvironment.test,
}) async {
  await journal.writeAsString(
    jsonEncode(<String, Object>{
      'formatVersion': 1,
      'environment': environment.serializedName,
      'newArchiveInstanceId': replacementArchiveId.value,
      'createdAtUtc': DateTime.utc(2026, 9, 5).toIso8601String(),
    }),
  );
}

Future<void> _expectFailure({
  required LegacyCompleteInstallationEraseJournalCompatibility compatibility,
  required File journal,
  required ArchiveMarkerStore markerStore,
  required String rootPath,
  required String code,
  required ArchiveInstanceId currentArchiveId,
}) async {
  final originalBytes = await journal.readAsBytes();
  await expectLater(
    compatibility.admit(
      canonicalRootPath: rootPath,
      expectedEnvironment: ArchiveEnvironment.test,
      markerStore: markerStore,
      ordinaryAdmission: () async => _authority(rootPath, currentArchiveId),
    ),
    throwsA(
      isA<LegacyCompleteInstallationEraseJournalException>().having(
        (error) => error.code,
        'code',
        code,
      ),
    ),
  );
  expect(await journal.readAsBytes(), originalBytes);
}

ArchiveMarker _marker({required ArchiveInstanceId archiveInstanceId}) {
  return ArchiveMarker(
    formatVersion: ArchiveMarker.currentFormatVersion,
    environment: ArchiveEnvironment.test,
    archiveInstanceId: archiveInstanceId,
    createdAtUtc: DateTime.utc(2026, 9, 5),
  );
}

ArchiveAccessAuthority _authority(
  String rootPath,
  ArchiveInstanceId archiveInstanceId,
) {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.test,
      buildIdentity: ArchiveBuildIdentity.testHarness,
      archiveInstanceId: archiveInstanceId,
      canonicalRootPath: rootPath,
      bundleIdentifier: 'test.messagelens',
      productName: 'MessageLens Test',
    ),
  );
}

MessageLensInstallationEvidence _virginEvidence() {
  return const MessageLensInstallationEvidence(
    sourceScopedImport: InstallationDatabaseEvidence.absent(),
    conversationGraph: InstallationDatabaseEvidence.absent(),
    overlay: InstallationDatabaseEvidence.absent(),
    presence: InstallationDatabaseEvidence.absent(),
    hasRetiredDerivedArtifacts: false,
    operationSnapshot: OnboardingOperationSnapshot.idle(),
  );
}

MessageLensInstallationEvidence _completedEvidence() {
  const source = InstallationDatabaseEvidence.passed(
    userVersion: 10,
    messageCount: 10,
    nonLiveSourceCount: 0,
  );
  const graph = InstallationDatabaseEvidence.passed(
    userVersion: 3,
    messageCount: 10,
    chatCount: 2,
    chatMessageEdgeCount: 10,
  );
  return const MessageLensInstallationEvidence(
    sourceScopedImport: source,
    conversationGraph: graph,
    overlay: InstallationDatabaseEvidence.absent(),
    presence: InstallationDatabaseEvidence.absent(),
    hasRetiredDerivedArtifacts: false,
    operationSnapshot: OnboardingOperationSnapshot.idle(),
  );
}

MessageLensInstallationEvidence _abandonedEvidence() {
  return const MessageLensInstallationEvidence(
    sourceScopedImport: InstallationDatabaseEvidence.passed(
      userVersion: 10,
      messageCount: 1,
      nonLiveSourceCount: 0,
    ),
    conversationGraph: InstallationDatabaseEvidence.absent(),
    overlay: InstallationDatabaseEvidence.absent(),
    presence: InstallationDatabaseEvidence.absent(),
    hasRetiredDerivedArtifacts: false,
    operationSnapshot: OnboardingOperationSnapshot.idle(),
  );
}

final class _FakeMarkerStore implements ArchiveMarkerStore {
  _FakeMarkerStore(this.marker);

  ArchiveMarker? marker;

  @override
  Future<bool> canCreateInitialMarker() async => marker == null;

  @override
  Future<void> createInitialMarker(ArchiveMarker marker) async {
    this.marker = marker;
  }

  @override
  Future<ArchiveMarker?> read() async => marker;
}

FullInstallationValidationResult _fullValidation(
  MessageLensInstallationEvidence evidence, {
  bool fullIntegrityValidated = true,
}) {
  final state = const MessageLensInstallationStateClassifier().classify(
    evidence,
  );
  return FullInstallationValidationResult(
    evidence: evidence,
    installationState: fullIntegrityValidated
        ? state
        : const MessageLensInstallationState(
            kind: MessageLensInstallationStateKind.remediationRequired,
            reason: 'physical integrity validation failed',
          ),
    integrityReport: InstallationIntegrityValidationReport(
      results: const <InstallationDatabaseIntegrityValidation>[],
    ),
    fullIntegrityValidated: fullIntegrityValidated,
  );
}

final class _FakeFullValidator implements MessageLensInstallationFullValidator {
  const _FakeFullValidator(this.callback);

  final Future<FullInstallationValidationResult> Function() callback;

  @override
  Future<FullInstallationValidationResult> validateFully({
    required String archiveRootPath,
    required InstallationIntegrityValidationTrigger trigger,
  }) {
    return callback();
  }
}
