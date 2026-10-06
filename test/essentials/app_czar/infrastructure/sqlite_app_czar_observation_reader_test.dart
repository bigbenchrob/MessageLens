import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar/infrastructure/sqlite_app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('missing stores are observed without being created', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'app_czar_read_only_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));
    final sourcePath = path.join(tempDirectory.path, 'missing_chat.db');
    final reader = SqliteAppCzarObservationReader(
      archiveRootPath: tempDirectory.path,
      messagesDatabasePath: sourcePath,
      attachmentArchiveProbe: const _ArchiveProbe(),
      physicalEvidenceReader:
          const SqliteMessageLensInstallationEvidenceReader(),
    );

    final importStore = await reader.readImportStore();
    final graphStore = await reader.readGraphStore();
    final overlay = await reader.readOverlay();
    final source = await reader.readSource();

    expect(importStore.condition, AppCzarDatabaseCondition.absent);
    expect(graphStore.condition, AppCzarDatabaseCondition.absent);
    expect(overlay.condition, AppCzarDatabaseCondition.absent);
    expect(source.condition, AppCzarSourceCondition.unavailable);
    expect(File(sourcePath).existsSync(), isFalse);
    expect(
      tempDirectory.listSync(followLinks: false),
      isEmpty,
      reason: 'Read-only AppCzar inspection must not create a database.',
    );
  });

  test(
    'source evidence counts every message record without filtering',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'app_czar_source_fidelity_test_',
      );
      addTearDown(() => tempDirectory.delete(recursive: true));
      final sourcePath = path.join(tempDirectory.path, 'chat.db');
      final database = sqlite3.open(sourcePath);
      database.execute('CREATE TABLE message (guid TEXT)');
      database.execute('INSERT INTO message (guid) VALUES (?), (?)', <Object?>[
        'message-guid',
        null,
      ]);
      database.dispose();
      final reader = SqliteAppCzarObservationReader(
        archiveRootPath: tempDirectory.path,
        messagesDatabasePath: sourcePath,
        attachmentArchiveProbe: const _ArchiveProbe(),
        physicalEvidenceReader:
            const SqliteMessageLensInstallationEvidenceReader(),
      );

      final source = await reader.readSource();

      expect(source.condition, AppCzarSourceCondition.readable);
      expect(source.messageCount, 2);
      expect(source.maxRowId, 2);
      expect(source.sampleStable, isTrue);
    },
  );

  group('initial-construction scope classification', () {
    test('absent or healthy-empty derived stores are safe', () {
      expect(
        classifyInitialConstructionScopeEvidence(_physicalEvidence()).condition,
        AppCzarInitialConstructionScopeCondition.safeEmpty,
      );
      expect(
        classifyInitialConstructionScopeEvidence(
          _physicalEvidence(
            import: const InstallationDatabaseEvidence.passed(
              userVersion: 10,
              messageCount: 0,
              nonLiveSourceCount: 0,
            ),
            graph: const InstallationDatabaseEvidence.passed(
              userVersion: 3,
              messageCount: 0,
              chatCount: 0,
              chatMessageEdgeCount: 0,
            ),
          ),
        ).condition,
        AppCzarInitialConstructionScopeCondition.safeEmpty,
      );
    });

    test('any consequential import or graph material is not safe', () {
      expect(
        classifyInitialConstructionScopeEvidence(
          _physicalEvidence(
            import: const InstallationDatabaseEvidence.passed(
              userVersion: 10,
              messageCount: 1,
              nonLiveSourceCount: 0,
            ),
          ),
        ).condition,
        AppCzarInitialConstructionScopeCondition.consequentialData,
      );
      expect(
        classifyInitialConstructionScopeEvidence(
          _physicalEvidence(
            graph: const InstallationDatabaseEvidence.passed(
              userVersion: 3,
              messageCount: 0,
              chatCount: 1,
              chatMessageEdgeCount: 1,
            ),
          ),
        ).condition,
        AppCzarInitialConstructionScopeCondition.consequentialData,
      );
    });

    test('non-live, retired, unhealthy, and unknown remain distinct', () {
      expect(
        classifyInitialConstructionScopeEvidence(
          _physicalEvidence(
            import: const InstallationDatabaseEvidence.passed(
              userVersion: 10,
              messageCount: 0,
              nonLiveSourceCount: 1,
            ),
          ),
        ).condition,
        AppCzarInitialConstructionScopeCondition.protectedNonLiveData,
      );
      expect(
        classifyInitialConstructionScopeEvidence(
          _physicalEvidence(hasRetiredDerivedArtifacts: true),
        ).condition,
        AppCzarInitialConstructionScopeCondition.retiredOrUnsupportedMaterial,
      );
      expect(
        classifyInitialConstructionScopeEvidence(
          _physicalEvidence(
            graph: const InstallationDatabaseEvidence(
              boundedInspectionStatus:
                  InstallationBoundedInspectionStatus.failed,
            ),
          ),
        ).condition,
        AppCzarInitialConstructionScopeCondition.unhealthy,
      );
      expect(
        classifyInitialConstructionScopeEvidence(
          _physicalEvidence(
            overlay: const InstallationDatabaseEvidence(
              boundedInspectionStatus:
                  InstallationBoundedInspectionStatus.contention,
            ),
          ),
        ).condition,
        AppCzarInitialConstructionScopeCondition.unknown,
      );
    });

    test('healthy overlay state does not become disposable derived data', () {
      final result = classifyInitialConstructionScopeEvidence(
        _physicalEvidence(
          overlay: const InstallationDatabaseEvidence.passed(userVersion: 8),
        ),
      );

      expect(
        result.condition,
        AppCzarInitialConstructionScopeCondition.safeEmpty,
      );
      expect(result.importMessageCount, 0);
      expect(result.graphMessageCount, 0);
    });
  });
}

MessageLensPhysicalInstallationEvidence _physicalEvidence({
  InstallationDatabaseEvidence import =
      const InstallationDatabaseEvidence.absent(),
  InstallationDatabaseEvidence graph =
      const InstallationDatabaseEvidence.absent(),
  InstallationDatabaseEvidence overlay =
      const InstallationDatabaseEvidence.absent(),
  bool hasRetiredDerivedArtifacts = false,
}) {
  return MessageLensPhysicalInstallationEvidence(
    sourceScopedImport: import,
    conversationGraph: graph,
    overlay: overlay,
    presence: const InstallationDatabaseEvidence.absent(),
    hasRetiredDerivedArtifacts: hasRetiredDerivedArtifacts,
  );
}

final class _ArchiveProbe implements AppCzarAttachmentArchiveProbe {
  const _ArchiveProbe();

  @override
  Future<AppCzarArchiveObservation> readCurrent() async {
    return const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.notCreated,
      label: 'Default attachment archive',
      archiveScopeIdentity: 'test-scope',
      archiveGeneration: 0,
      coverage: AppCzarAttachmentCoverageObservation(
        condition: AppCzarAttachmentCoverageCondition.complete,
        requiredCount: 0,
        coveredCount: 0,
        missingCount: 0,
        unverifiableCount: 0,
        archiveScopeIdentity: 'test-scope',
        archiveGeneration: 0,
      ),
    );
  }
}
