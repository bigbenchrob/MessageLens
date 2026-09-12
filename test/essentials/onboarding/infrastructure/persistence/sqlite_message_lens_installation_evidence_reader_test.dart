import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/db/app_database_schema_versions.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_state_classifier.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_store.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('pristine inspection creates no archive files', () async {
    final root = Directory.systemTemp.createTempSync(
      'messagelens-installation-evidence-pristine-',
    );
    addTearDown(() {
      root.deleteSync(recursive: true);
    });

    final before = root.listSync().map((entry) => entry.path).toSet();
    final evidence = await const SqliteMessageLensInstallationEvidenceReader()
        .read(archiveRootPath: root.path);
    final after = root.listSync().map((entry) => entry.path).toSet();

    expect(evidence.sourceScopedImport.exists, isFalse);
    expect(evidence.conversationGraph.exists, isFalse);
    expect(evidence.overlay.exists, isFalse);
    expect(evidence.presence.exists, isFalse);
    expect(evidence.operationSnapshot.status, OnboardingOperationStatus.idle);
    expect(after, before);
  });

  test(
    'reads a durable operation snapshot without changing its store',
    () async {
      final root = Directory.systemTemp.createTempSync(
        'messagelens-installation-evidence-snapshot-',
      );
      addTearDown(() {
        root.deleteSync(recursive: true);
      });
      final overlayPath = appDatabasePath(
        AppDatabaseFile.overlay,
        databaseDirectory: root.path,
      );
      final snapshot = OnboardingOperationSnapshot.running(
        operationId: OnboardingOperationId(
          '123e4567-e89b-42d3-a456-426614174010',
        ),
        processSessionId: OnboardingProcessSessionId(
          '123e4567-e89b-42d3-a456-426614174011',
        ),
        kind: OnboardingOperationKind.initialImport,
        stage: OnboardingOperationStage.messageDataBuild,
        observedAtUtc: DateTime.utc(2026, 9, 2),
      );
      _createOverlayDatabase(overlayPath, operationSnapshot: snapshot);
      final file = File(overlayPath);
      final bytesBefore = file.readAsBytesSync();
      final modifiedBefore = file.lastModifiedSync();

      final evidence = await const SqliteMessageLensInstallationEvidenceReader()
          .read(archiveRootPath: root.path);

      expect(
        evidence.operationSnapshot.status,
        OnboardingOperationStatus.running,
      );
      expect(evidence.operationSnapshot.operationId, snapshot.operationId);
      expect(file.readAsBytesSync(), bytesBefore);
      expect(file.lastModifiedSync(), modifiedBefore);
      expect(File('$overlayPath-wal').existsSync(), isFalse);
      expect(File('$overlayPath-shm').existsSync(), isFalse);
    },
  );

  test(
    'accepts a healthy schema-3 FTS graph without requesting remediation',
    () async {
      final root = Directory.systemTemp.createTempSync(
        'messagelens-installation-evidence-',
      );
      addTearDown(() {
        root.deleteSync(recursive: true);
      });

      _createImportDatabase(
        appDatabasePath(
          AppDatabaseFile.sourceScopedImport,
          databaseDirectory: root.path,
        ),
      );
      final graphPath = appDatabasePath(
        AppDatabaseFile.conversationGraph,
        databaseDirectory: root.path,
      );
      _createGraphDatabase(graphPath);
      _createOverlayDatabase(
        appDatabasePath(AppDatabaseFile.overlay, databaseDirectory: root.path),
      );
      _createPresenceDatabase(
        appDatabasePath(AppDatabaseFile.presence, databaseDirectory: root.path),
      );

      const reader = SqliteMessageLensInstallationEvidenceReader();
      final evidence = await reader.read(archiveRootPath: root.path);
      final state = const MessageLensInstallationStateClassifier().classify(
        evidence,
      );

      final graphDatabase = sqlite3.open(graphPath, mode: OpenMode.readOnly);
      addTearDown(graphDatabase.dispose);
      final indexedMessageCount = graphDatabase
          .select('SELECT COUNT(*) FROM message_text_fts')
          .single
          .values
          .single;

      expect(evidence.sourceScopedImport.isUsable, isTrue);
      expect(evidence.sourceScopedImport.messageCount, 2);
      expect(evidence.sourceScopedImport.nonLiveSourceCount, 0);
      expect(evidence.conversationGraph.isUsable, isTrue);
      expect(evidence.conversationGraph.userVersion, 3);
      expect(evidence.conversationGraph.schemaVersionSupported, isTrue);
      expect(evidence.conversationGraph.messageCount, 2);
      expect(evidence.conversationGraph.chatCount, 1);
      expect(evidence.conversationGraph.chatMessageEdgeCount, 2);
      expect(indexedMessageCount, 2);
      expect(evidence.overlay.isUsable, isTrue);
      expect(evidence.presence.isUsable, isTrue);
      expect(state.kind, MessageLensInstallationStateKind.completed);
      expect(
        state.kind,
        isNot(MessageLensInstallationStateKind.remediationRequired),
      );
    },
  );

  test('rejects a genuinely unsupported future graph schema', () async {
    final root = Directory.systemTemp.createTempSync(
      'messagelens-installation-evidence-future-graph-',
    );
    addTearDown(() {
      root.deleteSync(recursive: true);
    });
    _createGraphDatabase(
      appDatabasePath(
        AppDatabaseFile.conversationGraph,
        databaseDirectory: root.path,
      ),
      schemaVersion: conversationGraphSchemaVersion + 1,
    );

    final evidence = await const SqliteMessageLensInstallationEvidenceReader()
        .read(archiveRootPath: root.path);
    final state = const MessageLensInstallationStateClassifier().classify(
      evidence,
    );

    expect(
      evidence.conversationGraph.userVersion,
      conversationGraphSchemaVersion + 1,
    );
    expect(evidence.conversationGraph.integrityOk, isTrue);
    expect(evidence.conversationGraph.schemaVersionSupported, isFalse);
    expect(evidence.conversationGraph.isUsable, isFalse);
    expect(state.kind, MessageLensInstallationStateKind.remediationRequired);
  });

  test(
    'reports unsupported or malformed preservation store as unusable',
    () async {
      final root = Directory.systemTemp.createTempSync(
        'messagelens-installation-evidence-bad-',
      );
      addTearDown(() {
        root.deleteSync(recursive: true);
      });
      File(
        appDatabasePath(AppDatabaseFile.overlay, databaseDirectory: root.path),
      ).writeAsStringSync('not sqlite');

      final evidence = await const SqliteMessageLensInstallationEvidenceReader()
          .read(archiveRootPath: root.path);

      expect(evidence.overlay.exists, isTrue);
      expect(evidence.overlay.isUsable, isFalse);
      expect(evidence.overlay.failure, isNotNull);
    },
  );

  test(
    'keeps the caller event loop responsive during SQLite contention',
    () async {
      final root = Directory.systemTemp.createTempSync(
        'messagelens-installation-evidence-contention-',
      );
      addTearDown(() {
        root.deleteSync(recursive: true);
      });

      _createImportDatabase(
        appDatabasePath(
          AppDatabaseFile.sourceScopedImport,
          databaseDirectory: root.path,
        ),
      );
      final graphPath = appDatabasePath(
        AppDatabaseFile.conversationGraph,
        databaseDirectory: root.path,
      );
      _createGraphDatabase(graphPath);
      _createOverlayDatabase(
        appDatabasePath(AppDatabaseFile.overlay, databaseDirectory: root.path),
      );
      _createPresenceDatabase(
        appDatabasePath(AppDatabaseFile.presence, databaseDirectory: root.path),
      );

      final blocker = sqlite3.open(graphPath);
      addTearDown(blocker.dispose);
      blocker.execute('BEGIN EXCLUSIVE;');

      final lockReleased = Completer<void>();
      Timer(const Duration(milliseconds: 100), () {
        blocker.execute('ROLLBACK;');
        lockReleased.complete();
      });

      final evidenceFuture = const SqliteMessageLensInstallationEvidenceReader()
          .read(archiveRootPath: root.path);

      await lockReleased.future.timeout(const Duration(seconds: 1));
      final evidence = await evidenceFuture;

      expect(evidence.conversationGraph.isUsable, isTrue);
    },
  );
}

void _createImportDatabase(String path) {
  final database = sqlite3.open(path);
  try {
    database.execute('PRAGMA user_version = 10;');
    database.execute('CREATE TABLE messages (id INTEGER PRIMARY KEY);');
    database.execute(
      'CREATE TABLE source_registry (source_id INTEGER PRIMARY KEY);',
    );
    database.execute('INSERT INTO messages (id) VALUES (1), (2);');
    database.execute('INSERT INTO source_registry (source_id) VALUES (1);');
  } finally {
    database.dispose();
  }
}

void _createGraphDatabase(
  String path, {
  int schemaVersion = conversationGraphSchemaVersion,
}) {
  final database = sqlite3.open(path);
  try {
    database.execute('PRAGMA user_version = $schemaVersion;');
    database.execute(
      'CREATE TABLE messages (ss_id INTEGER PRIMARY KEY, text TEXT);',
    );
    database.execute('CREATE TABLE chats (ss_id INTEGER PRIMARY KEY);');
    database.execute(
      'CREATE TABLE chat_to_message '
      '(chat_ss_id INTEGER NOT NULL, message_ss_id INTEGER NOT NULL);',
    );
    database.execute('''
      CREATE VIRTUAL TABLE message_text_fts USING fts5(
        text,
        content='messages',
        content_rowid='ss_id',
        tokenize='unicode61 remove_diacritics 2',
        prefix='2 3 4'
      );
    ''');
    database.execute('''
      INSERT INTO messages (ss_id, text) VALUES
        (1, 'first searchable message'),
        (2, 'second searchable message');
    ''');
    database.execute('''
      INSERT INTO message_text_fts(message_text_fts) VALUES ('rebuild');
    ''');
    database.execute('INSERT INTO chats (ss_id) VALUES (1);');
    database.execute(
      'INSERT INTO chat_to_message (chat_ss_id, message_ss_id) '
      'VALUES (1, 1), (1, 2);',
    );
  } finally {
    database.dispose();
  }
}

void _createOverlayDatabase(
  String path, {
  OnboardingOperationSnapshot? operationSnapshot,
}) {
  final database = sqlite3.open(path);
  try {
    database.execute('PRAGMA user_version = 8;');
    database.execute(
      'CREATE TABLE overlay_settings (key TEXT PRIMARY KEY, value TEXT);',
    );
    if (operationSnapshot != null) {
      database.execute(
        'INSERT INTO overlay_settings (key, value) VALUES (?, ?)',
        <Object?>[
          onboardingOperationSnapshotSettingKey,
          jsonEncode(operationSnapshot.toJson()),
        ],
      );
    }
  } finally {
    database.dispose();
  }
}

void _createPresenceDatabase(String path) {
  final database = sqlite3.open(path);
  try {
    database.execute('PRAGMA user_version = 9;');
    database.execute(
      'CREATE TABLE schedule_definitions (id INTEGER PRIMARY KEY);',
    );
    database.execute('CREATE TABLE schedule_runs (id INTEGER PRIMARY KEY);');
  } finally {
    database.dispose();
  }
}
