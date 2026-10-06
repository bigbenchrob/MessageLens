import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar/infrastructure/sqlite_app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/db/app_database_schema_versions.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_bookmark_adapter.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store.dart';
import 'package:remember_this_text/features/attachments/application/current_messages_attachment_source_reader.dart';
import 'package:remember_this_text/features/attachments/application/required_attachment_evidence_reader.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/read_only_app_czar_attachment_archive_probe.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/read_only_app_czar_attachment_coverage_probe.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('ReadOnlyAppCzarAttachmentCoverageProbe', () {
    test(
      'derives the exact conventional live required set deterministically',
      () async {
        final fixture = await _CoverageFixture.create();
        addTearDown(fixture.dispose);
        fixture.addRequired(
          messageGuid: 'required-guid',
          messageRowId: 10,
          attachmentRowId: 20,
        );
        fixture.addRequired(
          messageGuid: 'opaque-guid',
          messageRowId: 11,
          attachmentRowId: 21,
          mimeType: '   ',
        );
        fixture.addRequired(
          messageGuid: 'missing-path-guid',
          messageRowId: 12,
          attachmentRowId: 22,
          filename: '   ',
        );
        fixture.addRequired(
          messageGuid: 'historical-guid',
          messageRowId: 13,
          attachmentRowId: 23,
          sourceId: liveChatDbSourceId + 1,
        );
        fixture.writePayload('objects/payload.bin', <int>[1, 2, 3]);
        fixture.writeRecord(
          messageGuid: 'required-guid',
          attachmentRowId: 20,
          relativePath: 'objects/payload.bin',
          size: 3,
        );
        fixture.writeUnrelatedMalformedRecord();
        final before = fixture.snapshot();

        final first = await fixture.read(scope: 'scope-a', generation: 7);
        final second = await fixture.read(scope: 'scope-a', generation: 7);

        expect(first.condition, AppCzarAttachmentCoverageCondition.complete);
        expect(first.requiredCount, 1);
        expect(first.coveredCount, 1);
        expect(first.missingCount, 0);
        expect(first.unverifiableCount, 0);
        expect(second.condition, first.condition);
        expect(second.requiredCount, first.requiredCount);
        expect(second.coveredCount, first.coveredCount);
        expect(fixture.snapshot(), before);
      },
    );

    test('zero required payloads is complete zero-of-zero coverage', () async {
      final fixture = await _CoverageFixture.create();
      addTearDown(fixture.dispose);

      final observation = await fixture.read();

      expect(
        observation.condition,
        AppCzarAttachmentCoverageCondition.complete,
      );
      expect(observation.requiredCount, 0);
      expect(observation.coveredCount, 0);
      expect(observation.missingCount, 0);
      expect(observation.unverifiableCount, 0);
    });

    test(
      'disabled preservation policy has an empty required universe',
      () async {
        final fixture = await _CoverageFixture.create();
        addTearDown(fixture.dispose);
        fixture.addRequired(
          messageGuid: 'graph-guid',
          messageRowId: 10,
          attachmentRowId: 20,
        );
        fixture.setArchiveEnabled(enabled: false);

        final observation = await fixture.read();

        expect(
          observation.condition,
          AppCzarAttachmentCoverageCondition.complete,
        );
        expect(observation.requiredCount, 0);
        expect(observation.coveredCount, 0);
      },
    );

    test('known missing evidence or payload is incomplete', () async {
      final fixture = await _CoverageFixture.create();
      addTearDown(fixture.dispose);
      fixture.addRequired(
        messageGuid: 'required-guid',
        messageRowId: 10,
        attachmentRowId: 20,
      );

      final noRecord = await fixture.read();
      expect(noRecord.condition, AppCzarAttachmentCoverageCondition.incomplete);
      expect(noRecord.missingCount, 1);

      final payload = fixture.writePayload('objects/payload.bin', <int>[
        1,
        2,
        3,
      ]);
      final payloadWithoutRecord = await fixture.read();
      expect(
        payloadWithoutRecord.condition,
        AppCzarAttachmentCoverageCondition.incomplete,
      );

      fixture.writeRecord(
        messageGuid: 'required-guid',
        attachmentRowId: 20,
        relativePath: 'objects/payload.bin',
        size: 3,
      );
      final payloadAndRecord = await fixture.read();
      expect(
        payloadAndRecord.condition,
        AppCzarAttachmentCoverageCondition.complete,
      );

      payload.deleteSync();
      final noPayload = await fixture.read();
      expect(
        noPayload.condition,
        AppCzarAttachmentCoverageCondition.incomplete,
      );
      expect(noPayload.missingCount, 1);
    });

    test('ambiguous required evidence is UNKNOWN', () async {
      final fixture = await _CoverageFixture.create();
      addTearDown(fixture.dispose);
      fixture.addRequired(
        messageGuid: 'required-guid',
        messageRowId: 10,
        attachmentRowId: 20,
      );
      fixture.writePayload('objects/payload.bin', <int>[1, 2, 3]);
      fixture.writeRecord(
        messageGuid: 'required-guid',
        attachmentRowId: 20,
        relativePath: 'objects/payload.bin',
        size: 3,
        hash: 'not-a-sha256',
      );

      final observation = await fixture.read();

      expect(observation.condition, AppCzarAttachmentCoverageCondition.unknown);
      expect(observation.requiredCount, 1);
      expect(observation.unverifiableCount, 1);
      expect(observation.issue, contains('could not be verified'));
    });

    test('unsafe or conflicting durable evidence is UNKNOWN', () async {
      final unsafeFixture = await _CoverageFixture.create();
      addTearDown(unsafeFixture.dispose);
      unsafeFixture.addRequired(
        messageGuid: 'unsafe-guid',
        messageRowId: 10,
        attachmentRowId: 20,
      );
      unsafeFixture.writeRecord(
        messageGuid: 'unsafe-guid',
        attachmentRowId: 20,
        relativePath: '../outside.bin',
        size: 3,
      );

      final unsafe = await unsafeFixture.read();

      expect(unsafe.condition, AppCzarAttachmentCoverageCondition.unknown);
      expect(unsafe.unverifiableCount, 1);

      final conflictFixture = await _CoverageFixture.create();
      addTearDown(conflictFixture.dispose);
      conflictFixture.addRequired(
        messageGuid: 'first-guid',
        messageRowId: 10,
        attachmentRowId: 20,
      );
      conflictFixture.addRequired(
        messageGuid: 'second-guid',
        messageRowId: 11,
        attachmentRowId: 21,
      );
      conflictFixture.writePayload('objects/shared.bin', <int>[1, 2, 3]);
      conflictFixture.writeRecord(
        messageGuid: 'first-guid',
        attachmentRowId: 20,
        relativePath: 'objects/shared.bin',
        size: 3,
      );
      conflictFixture.writeRecord(
        messageGuid: 'second-guid',
        attachmentRowId: 21,
        relativePath: 'objects/shared.bin',
        size: 4,
      );

      final conflict = await conflictFixture.read();

      expect(conflict.condition, AppCzarAttachmentCoverageCondition.unknown);
      expect(conflict.requiredCount, 2);
      expect(conflict.unverifiableCount, 2);
    });

    test(
      'wrong-size is incomplete while symbolic-link evidence is UNKNOWN',
      () async {
        final sizeFixture = await _CoverageFixture.create();
        addTearDown(sizeFixture.dispose);
        sizeFixture.addRequired(
          messageGuid: 'size-guid',
          messageRowId: 10,
          attachmentRowId: 20,
        );
        sizeFixture.writePayload('objects/payload.bin', <int>[1, 2, 3]);
        sizeFixture.writeRecord(
          messageGuid: 'size-guid',
          attachmentRowId: 20,
          relativePath: 'objects/payload.bin',
          size: 4,
        );

        final wrongSize = await sizeFixture.read();

        expect(
          wrongSize.condition,
          AppCzarAttachmentCoverageCondition.incomplete,
        );
        expect(wrongSize.missingCount, 1);

        final linkFixture = await _CoverageFixture.create();
        addTearDown(linkFixture.dispose);
        linkFixture.addRequired(
          messageGuid: 'link-guid',
          messageRowId: 10,
          attachmentRowId: 20,
        );
        final target = linkFixture.writePayload('target.bin', <int>[1, 2, 3]);
        final linkPath = path.join(
          linkFixture.archiveRoot.path,
          'objects',
          'payload.bin',
        );
        Directory(path.dirname(linkPath)).createSync(recursive: true);
        Link(linkPath).createSync(target.path);
        linkFixture.writeRecord(
          messageGuid: 'link-guid',
          attachmentRowId: 20,
          relativePath: 'objects/payload.bin',
          size: 3,
        );

        final symbolicLink = await linkFixture.read();

        expect(
          symbolicLink.condition,
          AppCzarAttachmentCoverageCondition.unknown,
        );
        expect(symbolicLink.unverifiableCount, 1);
      },
    );

    test(
      'read-only archive payload evidence can still prove coverage',
      () async {
        final fixture = await _CoverageFixture.create();
        addTearDown(fixture.dispose);
        fixture.addRequired(
          messageGuid: 'required-guid',
          messageRowId: 10,
          attachmentRowId: 20,
        );
        final payload = fixture.writePayload('objects/payload.bin', <int>[
          1,
          2,
          3,
        ]);
        fixture.writeRecord(
          messageGuid: 'required-guid',
          attachmentRowId: 20,
          relativePath: 'objects/payload.bin',
          size: 3,
        );
        payload.setLastModifiedSync(DateTime.utc(2026));
        await Process.run('chmod', <String>['0444', payload.path]);
        await Process.run('chmod', <String>['0555', fixture.archiveRoot.path]);
        addTearDown(() async {
          await Process.run('chmod', <String>[
            '0755',
            fixture.archiveRoot.path,
          ]);
        });

        final observation = await fixture.read();

        expect(
          observation.condition,
          AppCzarAttachmentCoverageCondition.complete,
        );
        expect(observation.archiveGeneration, 0);
      },
    );

    test(
      'fresh reads are scoped to the supplied identity and generation',
      () async {
        final fixture = await _CoverageFixture.create();
        addTearDown(fixture.dispose);

        final oldScope = await fixture.read(scope: 'old-scope', generation: 3);
        final currentScope = await fixture.read(
          scope: 'current-scope',
          generation: 4,
        );

        expect(oldScope.archiveScopeIdentity, 'old-scope');
        expect(oldScope.archiveGeneration, 3);
        expect(currentScope.archiveScopeIdentity, 'current-scope');
        expect(currentScope.archiveGeneration, 4);
        expect(
          currentScope.archiveScopeIdentity,
          isNot(oldScope.archiveScopeIdentity),
        );
        expect(
          currentScope.archiveGeneration,
          isNot(oldScope.archiveGeneration),
        );
      },
    );

    test('maps two matching shared-reader summaries', () async {
      final fixture = await _CoverageFixture.create();
      addTearDown(fixture.dispose);
      final binding = RequiredAttachmentEvidenceBinding(
        archiveRootPath: fixture.archiveRoot.path,
        archiveScopeIdentity: 'shared-scope',
        archiveGeneration: 9,
      );
      final reader = _FakeRequiredAttachmentEvidenceReader(
        <RequiredAttachmentEvidenceSummary>[
          RequiredAttachmentEvidenceSummary(
            requiredCount: 3,
            coveredCount: 2,
            missingCount: 1,
            unverifiableCount: 0,
            materialFingerprint: 'same-fingerprint',
            binding: binding,
          ),
          RequiredAttachmentEvidenceSummary(
            requiredCount: 3,
            coveredCount: 2,
            missingCount: 1,
            unverifiableCount: 0,
            materialFingerprint: 'same-fingerprint',
            binding: binding,
          ),
        ],
      );
      final probe = ReadOnlyAppCzarAttachmentCoverageProbe(
        archiveAccessAuthority: fixture.authority,
        evidenceReader: reader,
        sourceReaderResolver: () async => const _AbsentSourceReader(),
      );
      File(fixture._graphPath).deleteSync();

      final observation = await probe.readCurrent(
        archiveRootPath: fixture.archiveRoot.path,
        archiveScopeIdentity: 'shared-scope',
        archiveGeneration: 9,
      );

      expect(
        observation.condition,
        AppCzarAttachmentCoverageCondition.incomplete,
      );
      expect(observation.requiredCount, 3);
      expect(observation.coveredCount, 2);
      expect(observation.missingCount, 1);
      expect(reader.summaryReads, 2);
    });

    test('startup coverage adapter owns no required-set SQL', () {
      final source = File(
        'lib/features/attachments/infrastructure/repositories/'
        'read_only_app_czar_attachment_coverage_probe.dart',
      ).readAsStringSync();

      expect(source, contains('RequiredAttachmentEvidenceReader'));
      expect(source, isNot(contains('message_to_attachment')));
      expect(source, isNot(contains('archived_attachments')));
      expect(source, isNot(contains('package:sqlite3')));
      expect(source, isNot(contains('SourceScopedRowSql')));
    });

    test('rejects changing shared-reader material evidence', () async {
      final fixture = await _CoverageFixture.create();
      addTearDown(fixture.dispose);
      final binding = RequiredAttachmentEvidenceBinding(
        archiveRootPath: fixture.archiveRoot.path,
        archiveScopeIdentity: 'shared-scope',
        archiveGeneration: 9,
      );
      final reader = _FakeRequiredAttachmentEvidenceReader(
        <RequiredAttachmentEvidenceSummary>[
          RequiredAttachmentEvidenceSummary(
            requiredCount: 1,
            coveredCount: 0,
            missingCount: 1,
            unverifiableCount: 0,
            materialFingerprint: 'first-fingerprint',
            binding: binding,
          ),
          RequiredAttachmentEvidenceSummary(
            requiredCount: 1,
            coveredCount: 0,
            missingCount: 1,
            unverifiableCount: 0,
            materialFingerprint: 'second-fingerprint',
            binding: binding,
          ),
        ],
      );
      final probe = ReadOnlyAppCzarAttachmentCoverageProbe(
        archiveAccessAuthority: fixture.authority,
        evidenceReader: reader,
        sourceReaderResolver: () async => const _AbsentSourceReader(),
      );

      final observation = await probe.readCurrent(
        archiveRootPath: fixture.archiveRoot.path,
        archiveScopeIdentity: 'shared-scope',
        archiveGeneration: 9,
      );

      expect(observation.condition, AppCzarAttachmentCoverageCondition.unknown);
      expect(observation.issue, contains('changed during'));
      expect(reader.summaryReads, 2);
    });

    test(
      'fresh production reader reconstructs graph-current incomplete coverage and self-heals from reality',
      () async {
        final fixture = await _DurableRestartFixture.create();
        addTearDown(fixture.dispose);

        final initial = await fixture.readFreshAssessment();
        expect(
          initial.assessment!.virtualCoordinator,
          AppCzarVirtualCoordinator.operatingSession,
        );

        fixture.commitCurrentDeltaWithoutPreservation();
        final incomplete = await fixture.readFreshAssessment();

        expect(incomplete.source!.messageCount, 2);
        expect(incomplete.source!.maxRowId, 2);
        expect(incomplete.importStore!.messageCount, 2);
        expect(incomplete.importStore!.liveMessageCount, 2);
        expect(incomplete.importStore!.liveMaxSourceRowId, 2);
        expect(incomplete.graphStore!.messageCount, 2);
        expect(
          incomplete.attachmentArchive!.condition,
          AppCzarArchiveCondition.available,
        );
        expect(
          incomplete.attachmentArchive!.coverage.condition,
          AppCzarAttachmentCoverageCondition.incomplete,
        );
        expect(
          incomplete.assessment!
              .fact(AppCzarFactId.attachmentCoverageComplete)
              .truth,
          AppCzarTruth.falseValue,
        );
        expect(
          incomplete.assessment!.virtualCoordinator,
          AppCzarVirtualCoordinator.attachmentArchiveRepair,
        );
        expect(
          incomplete.assessment!.virtualCoordinator,
          isNot(AppCzarVirtualCoordinator.operatingSession),
        );

        fixture.installCurrentPayloadAndEvidence();
        final restored = await fixture.readFreshAssessment();

        expect(
          restored.attachmentArchive!.coverage.condition,
          AppCzarAttachmentCoverageCondition.complete,
        );
        expect(restored.attachmentArchive!.coverage.requiredCount, 1);
        expect(restored.attachmentArchive!.coverage.coveredCount, 1);
        expect(
          restored.assessment!.virtualCoordinator,
          AppCzarVirtualCoordinator.operatingSession,
        );
      },
    );
  });
}

final class _FakeRequiredAttachmentEvidenceReader
    implements RequiredAttachmentEvidenceReader {
  _FakeRequiredAttachmentEvidenceReader(
    List<RequiredAttachmentEvidenceSummary> summaries,
  ) : _summaries = List<RequiredAttachmentEvidenceSummary>.of(summaries);

  final List<RequiredAttachmentEvidenceSummary> _summaries;
  var summaryReads = 0;
  var pageReads = 0;

  @override
  Future<RequiredAttachmentEvidencePage> readPage({
    required RequiredAttachmentEvidenceBinding binding,
    RequiredAttachmentEvidenceCursor? after,
    int limit = 75,
  }) async {
    pageReads += 1;
    final summary = _summaries.first;
    final items = <RequiredAttachmentEvidenceItem>[
      for (var index = 0; index < summary.coveredCount; index++)
        _aggregateItem(
          index,
          RequiredAttachmentEvidenceCondition.coveredAndValid,
        ),
      for (var index = 0; index < summary.missingCount; index++)
        _aggregateItem(
          summary.coveredCount + index,
          RequiredAttachmentEvidenceCondition.noDurableRecord,
        ),
      for (var index = 0; index < summary.unverifiableCount; index++)
        _aggregateItem(
          summary.coveredCount + summary.missingCount + index,
          RequiredAttachmentEvidenceCondition.unsafeOrUnverifiablePath,
        ),
    ];
    final start = after == null
        ? 0
        : items.indexWhere((item) => item.cursor == after) + 1;
    final end = (start + limit).clamp(0, items.length);
    final page = items.sublist(start, end);
    return RequiredAttachmentEvidencePage(
      items: page,
      nextCursor: page.isEmpty ? null : page.last.cursor,
      hasMore: end < items.length,
      binding: binding,
    );
  }

  @override
  Future<RequiredAttachmentEvidenceSummary> readSummary({
    required RequiredAttachmentEvidenceBinding binding,
    int pageSize = 75,
  }) async {
    final result = _summaries[summaryReads];
    summaryReads += 1;
    return result;
  }
}

RequiredAttachmentEvidenceItem _aggregateItem(
  int index,
  RequiredAttachmentEvidenceCondition condition,
) {
  return RequiredAttachmentEvidenceItem(
    cursor: RequiredAttachmentEvidenceCursor(
      messageGuid: 'aggregate-guid-$index',
      liveAttachmentRowId: index,
    ),
    archiveKey: ArchiveCompatibilityKey(
      messageGuid: 'aggregate-guid-$index',
      importAttachmentId: index,
    ),
    condition: condition,
    materialFingerprint: 'aggregate-$index-${condition.name}',
  );
}

final class _AbsentSourceReader
    implements CurrentMessagesAttachmentSourceReader {
  const _AbsentSourceReader();

  @override
  Future<CurrentMessagesAttachmentSourceObservation> observeCurrent(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    return CurrentMessagesAttachmentSourceObservation.absent(
      archiveKey: archiveKey,
    );
  }

  @override
  Future<List<CurrentMessagesAttachmentSourceObservation>> observeCurrentPage(
    List<ArchiveCompatibilityKey> archiveKeys,
  ) async {
    return <CurrentMessagesAttachmentSourceObservation>[
      for (final archiveKey in archiveKeys)
        CurrentMessagesAttachmentSourceObservation.absent(
          archiveKey: archiveKey,
        ),
    ];
  }
}

Future<AppCzarAssessment> _waitForAssessment(
  ProviderContainer container,
) async {
  container.read(appCzarAssessmentControllerProvider);
  final timeout = Stopwatch()..start();
  while (timeout.elapsed < const Duration(seconds: 10)) {
    final assessment = container
        .read(appCzarAssessmentControllerProvider)
        .assessment;
    if (assessment != null) {
      return assessment;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  throw StateError('Fresh AppCzar assessment did not complete.');
}

final class _DurableRestartFixture {
  _DurableRestartFixture({
    required this.root,
    required this.archiveRoot,
    required this.sourcePath,
    required this.authority,
  });

  static Future<_DurableRestartFixture> create() async {
    final root = await Directory.systemTemp.createTemp(
      'app_czar_durable_restart_',
    );
    final archiveRoot = Directory(path.join(root.path, 'attachment_archive'))
      ..createSync();
    final sourcePath = path.join(root.path, 'chat.db');
    final authority = ArchiveAccessAuthority(
      identity: ResolvedArchiveIdentity(
        environment: ArchiveEnvironment.test,
        buildIdentity: ArchiveBuildIdentity.testHarness,
        archiveInstanceId: ArchiveInstanceId(
          'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
        ),
        canonicalRootPath: root.path,
        bundleIdentifier: 'com.example.MessageLens.durable-restart-tests',
        productName: 'MessageLens Durable Restart Tests',
      ),
    );

    final source = sqlite3.open(sourcePath);
    source
      ..execute('CREATE TABLE message (guid TEXT)')
      ..execute('CREATE TABLE attachment (filename TEXT, mime_type TEXT)')
      ..execute(
        'CREATE TABLE message_attachment_join '
        '(message_id INTEGER, attachment_id INTEGER)',
      )
      ..execute('INSERT INTO message (ROWID, guid) VALUES (?, ?)', <Object?>[
        1,
        'initial-guid',
      ])
      ..dispose();

    final importStore = sqlite3.open(
      appDatabasePath(
        AppDatabaseFile.sourceScopedImport,
        databaseDirectory: root.path,
      ),
    );
    importStore
      ..execute('PRAGMA user_version = $sourceScopedImportSchemaVersion')
      ..execute(
        'CREATE TABLE source_registry (source_id INTEGER, source_kind TEXT)',
      )
      ..execute(
        'CREATE TABLE messages (source_id INTEGER, source_rowid INTEGER)',
      )
      ..execute('INSERT INTO source_registry VALUES (?, ?)', <Object?>[
        liveChatDbSourceId,
        liveChatDbSourceKind,
      ])
      ..execute('INSERT INTO messages VALUES (?, ?)', <Object?>[
        liveChatDbSourceId,
        1,
      ])
      ..dispose();

    final graph = sqlite3.open(
      appDatabasePath(
        AppDatabaseFile.conversationGraph,
        databaseDirectory: root.path,
      ),
    );
    final initialMessageId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 1,
    );
    graph
      ..execute('PRAGMA user_version = $conversationGraphSchemaVersion')
      ..execute('CREATE TABLE messages (ss_id INTEGER PRIMARY KEY, guid TEXT)')
      ..execute('CREATE TABLE chats (ss_id INTEGER PRIMARY KEY)')
      ..execute('''
CREATE TABLE chat_to_message (
  chat_ss_id INTEGER,
  message_ss_id INTEGER
)
''')
      ..execute('''
CREATE TABLE attachments (
  ss_id INTEGER PRIMARY KEY,
  filename TEXT,
  mime_type TEXT
)
''')
      ..execute('''
CREATE TABLE message_to_attachment (
  message_ss_id INTEGER NOT NULL,
  attachment_ss_id INTEGER NOT NULL
)
''')
      ..execute('INSERT INTO messages VALUES (?, ?)', <Object?>[
        initialMessageId,
        'initial-guid',
      ])
      ..execute('INSERT INTO chats VALUES (?)', <Object?>[1])
      ..execute('INSERT INTO chat_to_message VALUES (?, ?)', <Object?>[
        1,
        initialMessageId,
      ])
      ..dispose();

    final overlay = sqlite3.open(
      appDatabasePath(AppDatabaseFile.overlay, databaseDirectory: root.path),
    );
    overlay
      ..execute('PRAGMA user_version = $overlaySchemaVersion')
      ..execute('''
CREATE TABLE overlay_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
)
''')
      ..execute('''
CREATE TABLE archived_attachments (
  message_guid TEXT NOT NULL,
  import_attachment_id INTEGER NOT NULL,
  archive_relative_path,
  file_size_bytes,
  content_hash,
  PRIMARY KEY (message_guid, import_attachment_id)
)
''')
      ..dispose();

    return _DurableRestartFixture(
      root: root,
      archiveRoot: archiveRoot,
      sourcePath: sourcePath,
      authority: authority,
    );
  }

  final Directory root;
  final Directory archiveRoot;
  final String sourcePath;
  final ArchiveAccessAuthority authority;

  Future<void> dispose() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  }

  Future<AppCzarAssessmentState> readFreshAssessment() async {
    final coverageProbe = ReadOnlyAppCzarAttachmentCoverageProbe(
      archiveAccessAuthority: authority,
      sourceReaderResolver: () async => _FixtureSourceReader(root),
    );
    final archiveProbe = ReadOnlyAppCzarAttachmentArchiveProbe(
      archiveAccessAuthority: authority,
      bookmarkAdapter: const _UnsupportedBookmarkAdapter(),
      coverageProbe: coverageProbe,
    );
    final reader = SqliteAppCzarObservationReader(
      archiveRootPath: root.path,
      messagesDatabasePath: sourcePath,
      attachmentArchiveProbe: archiveProbe,
      physicalEvidenceReader:
          const SqliteMessageLensInstallationEvidenceReader(),
    );
    final container = ProviderContainer(
      overrides: [
        appCzarObservationReaderProvider.overrideWithValue(
          _EstablishedFixtureObservationReader(reader),
        ),
      ],
    );
    try {
      await _waitForAssessment(container);
      return container.read(appCzarAssessmentControllerProvider);
    } finally {
      container.dispose();
    }
  }

  void commitCurrentDeltaWithoutPreservation() {
    final sourcePayload = File(path.join(root.path, 'source-payload.bin'))
      ..writeAsBytesSync(<int>[1, 2, 3], flush: true);
    final source = sqlite3.open(sourcePath);
    source
      ..execute('INSERT INTO message (ROWID, guid) VALUES (?, ?)', <Object?>[
        2,
        'required-guid',
      ])
      ..execute(
        'INSERT INTO attachment (ROWID, filename, mime_type) VALUES (?, ?, ?)',
        <Object?>[20, sourcePayload.path, 'application/octet-stream'],
      )
      ..execute('INSERT INTO message_attachment_join VALUES (?, ?)', <Object?>[
        2,
        20,
      ])
      ..dispose();

    final importStore = sqlite3.open(
      appDatabasePath(
        AppDatabaseFile.sourceScopedImport,
        databaseDirectory: root.path,
      ),
    );
    importStore
      ..execute('INSERT INTO messages VALUES (?, ?)', <Object?>[
        liveChatDbSourceId,
        2,
      ])
      ..dispose();

    final messageId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 2,
    );
    final attachmentId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 20,
    );
    final graph = sqlite3.open(
      appDatabasePath(
        AppDatabaseFile.conversationGraph,
        databaseDirectory: root.path,
      ),
    );
    graph
      ..execute('INSERT INTO messages VALUES (?, ?)', <Object?>[
        messageId,
        'required-guid',
      ])
      ..execute('INSERT INTO chat_to_message VALUES (?, ?)', <Object?>[
        1,
        messageId,
      ])
      ..execute('INSERT INTO attachments VALUES (?, ?, ?)', <Object?>[
        attachmentId,
        '/source/payload.bin',
        'application/octet-stream',
      ])
      ..execute('INSERT INTO message_to_attachment VALUES (?, ?)', <Object?>[
        messageId,
        attachmentId,
      ])
      ..dispose();
  }

  void installCurrentPayloadAndEvidence() {
    final payload = File(path.join(archiveRoot.path, 'objects', 'payload.bin'));
    payload.parent.createSync(recursive: true);
    payload.writeAsBytesSync(<int>[1, 2, 3], flush: true);

    final overlay = sqlite3.open(
      appDatabasePath(AppDatabaseFile.overlay, databaseDirectory: root.path),
    );
    overlay
      ..execute(
        'INSERT INTO archived_attachments VALUES (?, ?, ?, ?, ?)',
        <Object?>['required-guid', 20, 'objects/payload.bin', 3, null],
      )
      ..dispose();
  }
}

final class _EstablishedFixtureObservationReader
    implements AppCzarObservationReader, AppCzarInitialConstructionScopeReader {
  const _EstablishedFixtureObservationReader(this._delegate);

  final SqliteAppCzarObservationReader _delegate;

  @override
  Future<AppCzarInitialConstructionScopeObservation>
  readInitialConstructionScope() async {
    return const AppCzarInitialConstructionScopeObservation(
      condition: AppCzarInitialConstructionScopeCondition.consequentialData,
      importMessageCount: 1,
      graphMessageCount: 1,
      graphChatCount: 1,
      graphEdgeCount: 1,
      nonLiveSourceCount: 0,
      hasRetiredDerivedArtifacts: false,
      issue: 'The fixture represents an established current installation.',
    );
  }

  @override
  Future<AppCzarRootObservation> readRoot() => _delegate.readRoot();

  @override
  Future<AppCzarSourceObservation> readSource() => _delegate.readSource();

  @override
  Future<AppCzarDatabaseObservation> readImportStore() =>
      _delegate.readImportStore();

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() =>
      _delegate.readGraphStore();

  @override
  Future<AppCzarDatabaseObservation> readOverlay() => _delegate.readOverlay();

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() =>
      _delegate.readAttachmentArchive();
}

final class _UnsupportedBookmarkAdapter
    implements AttachmentArchiveBookmarkAdapter {
  const _UnsupportedBookmarkAdapter();

  @override
  Future<AttachmentArchiveBookmarkCreation> createBookmark({
    required String directoryPath,
  }) {
    throw UnsupportedError(
      'The durable restart fixture uses internal storage.',
    );
  }

  @override
  Stream<AttachmentArchiveLocationEvent> get locationEvents =>
      const Stream<AttachmentArchiveLocationEvent>.empty();

  @override
  Future<AttachmentArchiveBookmarkResolution> resolveBookmark({
    required String bookmarkDataBase64,
  }) {
    throw UnsupportedError(
      'The durable restart fixture uses internal storage.',
    );
  }
}

final class _FixtureSourceReader
    implements CurrentMessagesAttachmentSourceReader {
  const _FixtureSourceReader(this.root);

  final Directory root;

  @override
  Future<CurrentMessagesAttachmentSourceObservation> observeCurrent(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    return _observation(archiveKey);
  }

  @override
  Future<List<CurrentMessagesAttachmentSourceObservation>> observeCurrentPage(
    List<ArchiveCompatibilityKey> archiveKeys,
  ) async {
    return archiveKeys.map(_observation).toList(growable: false);
  }

  CurrentMessagesAttachmentSourceObservation _observation(
    ArchiveCompatibilityKey archiveKey,
  ) {
    final payload = File(path.join(root.path, 'source-payload.bin'));
    if (!payload.existsSync()) {
      return CurrentMessagesAttachmentSourceObservation.absent(
        archiveKey: archiveKey,
      );
    }
    final stat = payload.statSync();
    return CurrentMessagesAttachmentSourceObservation.available(
      archiveKey: archiveKey,
      sourcePath: payload.path,
      mimeType: 'application/octet-stream',
      fileSizeBytes: stat.size,
      modifiedAtMicrosecondsSinceEpoch: stat.modified.microsecondsSinceEpoch,
    );
  }
}

final class _CoverageFixture {
  _CoverageFixture({
    required this.root,
    required this.archiveRoot,
    required this.authority,
  });

  static Future<_CoverageFixture> create() async {
    final root = await Directory.systemTemp.createTemp('app_czar_coverage_');
    final archiveRoot = Directory(path.join(root.path, 'attachment_archive'))
      ..createSync();
    final authority = ArchiveAccessAuthority(
      identity: ResolvedArchiveIdentity(
        environment: ArchiveEnvironment.test,
        buildIdentity: ArchiveBuildIdentity.testHarness,
        archiveInstanceId: ArchiveInstanceId(
          'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        ),
        canonicalRootPath: root.path,
        bundleIdentifier: 'com.example.MessageLens.tests',
        productName: 'MessageLens Tests',
      ),
    );
    final graph = sqlite3.open(path.join(root.path, 'working_ss.db'));
    graph
      ..execute('CREATE TABLE messages (ss_id INTEGER PRIMARY KEY, guid TEXT)')
      ..execute('''
CREATE TABLE attachments (
  ss_id INTEGER PRIMARY KEY,
  filename TEXT,
  mime_type TEXT
)
''')
      ..execute('''
CREATE TABLE message_to_attachment (
  message_ss_id INTEGER NOT NULL,
  attachment_ss_id INTEGER NOT NULL
)
''')
      ..dispose();
    final overlay = sqlite3.open(path.join(root.path, 'user_overlays.db'));
    overlay
      ..execute(
        'CREATE TABLE overlay_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      )
      ..execute('''
CREATE TABLE archived_attachments (
  message_guid TEXT NOT NULL,
  import_attachment_id INTEGER NOT NULL,
  archive_relative_path,
  file_size_bytes,
  content_hash,
  PRIMARY KEY (message_guid, import_attachment_id)
)
''')
      ..dispose();
    return _CoverageFixture(
      root: root,
      archiveRoot: archiveRoot,
      authority: authority,
    );
  }

  final Directory root;
  final Directory archiveRoot;
  final ArchiveAccessAuthority authority;

  String get _graphPath => path.join(root.path, 'working_ss.db');
  String get _overlayPath => path.join(root.path, 'user_overlays.db');

  Future<void> dispose() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  }

  void addRequired({
    required String messageGuid,
    required int messageRowId,
    required int attachmentRowId,
    String filename = '/source/payload.bin',
    String? mimeType = 'application/octet-stream',
    int sourceId = liveChatDbSourceId,
  }) {
    final messageSsId = SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: messageRowId,
    );
    final attachmentSsId = SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: attachmentRowId,
    );
    final graph = sqlite3.open(_graphPath);
    graph
      ..execute('INSERT INTO messages VALUES (?, ?)', <Object?>[
        messageSsId,
        messageGuid,
      ])
      ..execute('INSERT INTO attachments VALUES (?, ?, ?)', <Object?>[
        attachmentSsId,
        filename,
        mimeType,
      ])
      ..execute('INSERT INTO message_to_attachment VALUES (?, ?)', <Object?>[
        messageSsId,
        attachmentSsId,
      ])
      ..dispose();
  }

  File writePayload(String relativePath, List<int> bytes) {
    final file = File(path.join(archiveRoot.path, relativePath));
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes, flush: true);
    return file;
  }

  void writeRecord({
    required String messageGuid,
    required int attachmentRowId,
    required String relativePath,
    required int size,
    String? hash,
  }) {
    final overlay = sqlite3.open(_overlayPath);
    overlay
      ..execute(
        'INSERT INTO archived_attachments VALUES (?, ?, ?, ?, ?)',
        <Object?>[messageGuid, attachmentRowId, relativePath, size, hash],
      )
      ..dispose();
  }

  void writeUnrelatedMalformedRecord() {
    final overlay = sqlite3.open(_overlayPath);
    overlay
      ..execute(
        'INSERT INTO archived_attachments VALUES (?, ?, ?, ?, ?)',
        <Object?>['unrelated', 999, 42, 'not-an-int', null],
      )
      ..dispose();
  }

  void setArchiveEnabled({required bool enabled}) {
    final overlay = sqlite3.open(_overlayPath);
    overlay
      ..execute(
        'INSERT OR REPLACE INTO overlay_settings (key, value) VALUES (?, ?)',
        <Object?>[attachmentArchiveEnabledSettingKey, enabled.toString()],
      )
      ..dispose();
  }

  Future<AppCzarAttachmentCoverageObservation> read({
    String scope = 'fixture-scope',
    int generation = 0,
  }) {
    return ReadOnlyAppCzarAttachmentCoverageProbe(
      archiveAccessAuthority: authority,
      sourceReaderResolver: () async => const _AbsentSourceReader(),
    ).readCurrent(
      archiveRootPath: archiveRoot.path,
      archiveScopeIdentity: scope,
      archiveGeneration: generation,
    );
  }

  String snapshot() {
    final graph = File(_graphPath);
    final overlay = File(_overlayPath);
    final entities = root.listSync(recursive: true, followLinks: false)
      ..sort((left, right) => left.path.compareTo(right.path));
    final entries = entities
        .map((entity) => path.relative(entity.path, from: root.path))
        .toList(growable: false);
    final payloadEvidence = entities
        .whereType<File>()
        .map((file) {
          return <Object>[
            path.relative(file.path, from: root.path),
            file.readAsBytesSync(),
            file.lastModifiedSync().microsecondsSinceEpoch,
          ];
        })
        .toList(growable: false);
    return <Object>[
      graph.readAsBytesSync(),
      graph.lastModifiedSync().microsecondsSinceEpoch,
      overlay.readAsBytesSync(),
      overlay.lastModifiedSync().microsecondsSinceEpoch,
      entries,
      payloadEvidence,
    ].toString();
  }
}
