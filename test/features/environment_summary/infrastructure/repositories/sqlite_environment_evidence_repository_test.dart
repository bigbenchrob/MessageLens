import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_evidence_repository.dart';
import 'package:remember_this_text/features/environment_summary/domain/entities/environment_summary.dart';
import 'package:remember_this_text/features/environment_summary/infrastructure/repositories/sqlite_environment_evidence_repository.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('SqliteEnvironmentEvidenceRepository', () {
    late Directory root;

    setUp(() {
      root = Directory.systemTemp.createTempSync('environment_evidence_');
      _createEnvironmentFixture(root.path);
    });

    tearDown(() {
      if (root.existsSync()) {
        root.deleteSync(recursive: true);
      }
    });

    test(
      'reads exact database metadata and authoritative schema versions',
      () async {
        const repository = SqliteEnvironmentEvidenceRepository(
          useBackgroundIsolate: false,
        );

        final databases = await repository.inspectDatabases(root.path);

        expect(databases, hasLength(4));
        expect(
          databases.map((database) => database.role),
          EnvironmentDatabaseRole.values,
        );
        expect(databases.map((database) => database.userVersion), <int>[
          10,
          3,
          8,
          9,
        ]);
        expect(databases.map((database) => database.expectedVersion), <int>[
          10,
          3,
          8,
          9,
        ]);
        expect(databases.every((database) => database.readable), isTrue);
      },
    );

    test(
      'joins registry identity to packed graph membership without deduping GUIDs',
      () async {
        const repository = SqliteEnvironmentEvidenceRepository(
          useBackgroundIsolate: false,
        );

        final messages = await repository.readMessageEvidence(root.path);
        final ranges = await repository.readMessageDateRanges(
          root.path,
          messages.sources.map((source) => source.sourceId),
        );

        expect(messages.projectedMessageCount, 3);
        expect(messages.conversationCount, 2);
        expect(messages.attachmentReferenceCount, 2);
        expect(messages.sources, hasLength(2));
        expect(messages.sources[0].sourceId, 1);
        expect(messages.sources[0].projectedMessageCount, 1);
        expect(messages.sources[1].sourceId, 3);
        expect(messages.sources[1].projectedMessageCount, 2);
        expect(
          messages.sources[1].canonicalSourcePath,
          '/Volumes/Offline/Archive/chat.db',
        );
        expect(messages.sources.any((source) => source.sourceId == 4), isFalse);
        expect(ranges, hasLength(2));
        expect(ranges[0].earliestMessageUtc, DateTime.utc(2020));
        expect(ranges[1].earliestMessageUtc, DateTime.utc(2010));
        expect(ranges[1].latestMessageUtc, DateTime.utc(2011));
      },
    );

    test(
      'counts Contacts and embedded FTS without reading user values',
      () async {
        const repository = SqliteEnvironmentEvidenceRepository(
          useBackgroundIsolate: false,
        );

        final contacts = await repository.readContactsEvidence(root.path);
        final fts = await repository.readFtsEvidence(root.path);

        expect(contacts.projectedContactCount, 2);
        expect(contacts.linkedHandleCount, 3);
        expect(contacts.importedChannelCount, 4);
        expect(fts.isAvailable, isTrue);
        expect(fts.rowCount, 2);
      },
    );

    test(
      'all SQL is guarded and observation leaves databases byte-identical',
      () async {
        final statements = <String>[];
        final repository = SqliteEnvironmentEvidenceRepository(
          sqlObserver: statements.add,
          useBackgroundIsolate: false,
        );
        final databaseFiles = <File>[
          for (final database in <AppDatabaseFile>[
            AppDatabaseFile.sourceScopedImport,
            AppDatabaseFile.conversationGraph,
            AppDatabaseFile.overlay,
            AppDatabaseFile.presence,
          ])
            File(appDatabasePath(database, databaseDirectory: root.path)),
        ];
        final before = <String, (Digest, DateTime)>{
          for (final file in databaseFiles)
            file.path: (
              sha256.convert(file.readAsBytesSync()),
              file.statSync().modified,
            ),
        };

        final messages = await repository.readMessageEvidence(root.path);
        await repository.readMessageDateRanges(
          root.path,
          messages.sources.map((source) => source.sourceId),
        );
        await repository.readContactsEvidence(root.path);
        await repository.readFtsEvidence(root.path);
        await repository.inspectDatabases(root.path);

        expect(statements, isNotEmpty);
        for (final statement in statements) {
          expect(
            () => assertEnvironmentSummaryReadOnlySql(statement),
            returnsNormally,
          );
        }
        for (final file in databaseFiles) {
          final original = before[file.path]!;
          expect(sha256.convert(file.readAsBytesSync()), original.$1);
          expect(file.statSync().modified, original.$2);
        }
      },
    );

    test('missing databases remain missing after every observation', () async {
      final emptyRoot = Directory.systemTemp.createTempSync(
        'environment_missing_databases_',
      );
      addTearDown(() {
        if (emptyRoot.existsSync()) {
          emptyRoot.deleteSync(recursive: true);
        }
      });
      const repository = SqliteEnvironmentEvidenceRepository();

      final metadata = await repository.inspectDatabases(emptyRoot.path);
      await expectLater(
        repository.readMessageEvidence(emptyRoot.path),
        throwsA(isA<EnvironmentEvidenceUnavailableException>()),
      );

      expect(metadata.every((database) => !database.exists), isTrue);
      expect(emptyRoot.listSync(), isEmpty);
    });

    test('packed range includes both documented boundaries', () async {
      final boundaryRoot = Directory.systemTemp.createTempSync(
        'environment_packed_bounds_',
      );
      addTearDown(() {
        if (boundaryRoot.existsSync()) {
          boundaryRoot.deleteSync(recursive: true);
        }
      });
      const sourceId = SourceScopedRowKey.maxSourceId;
      final identity =
          HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
            '/Volumes/Boundary/chat.db',
          );
      _createMinimalImportDatabase(
        boundaryRoot.path,
        sources: <(int, String, String, String?)>[
          (sourceId, identity.value, identity.sourceKind, null),
        ],
      );
      _createMinimalGraphDatabase(
        boundaryRoot.path,
        messages: <(int, String, String)>[
          (
            SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 1),
            'first',
            '2000-01-01T00:00:00.000Z',
          ),
          (
            SourceScopedRowKey.pack(
              sourceId: sourceId,
              sourceRowId: SourceScopedRowKey.maxSourceRowId,
            ),
            'last',
            '2001-01-01T00:00:00.000Z',
          ),
        ],
      );
      const repository = SqliteEnvironmentEvidenceRepository(
        useBackgroundIsolate: false,
      );

      final evidence = await repository.readMessageEvidence(boundaryRoot.path);

      expect(evidence.sources.single.projectedMessageCount, 2);
    });
  });

  group('Environment SQL guard', () {
    test('rejects mutation statements and write-affecting PRAGMAs', () {
      expect(
        () => assertEnvironmentSummaryReadOnlySql('DELETE FROM messages;'),
        throwsStateError,
      );
      expect(
        () => assertEnvironmentSummaryReadOnlySql('PRAGMA journal_mode=WAL;'),
        throwsStateError,
      );
      expect(
        () => assertEnvironmentSummaryReadOnlySql('PRAGMA user_version=99;'),
        throwsStateError,
      );
    });
  });

  test(
    'root inspection uses physical volume wording without creating paths',
    () async {
      const repository = SqliteEnvironmentEvidenceRepository(
        useBackgroundIsolate: false,
      );
      final missingPath = path.join('/Volumes', 'Detached', 'MessageLens');

      final missing = await repository.inspectDataRoot(missingPath);

      expect(missing.displayVolumeName, 'Detached');
      expect(missing.availability, EnvironmentAvailability.disconnected);
      expect(Directory(missingPath).existsSync(), isFalse);
    },
  );
}

void _createEnvironmentFixture(String rootPath) {
  final historicalIdentity =
      HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
        '/Volumes/Offline/Archive/chat.db',
      );
  final zeroIdentity =
      HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
        '/Volumes/Offline/Removed/chat.db',
      );
  _createMinimalImportDatabase(
    rootPath,
    sources: <(int, String, String, String?)>[
      (1, 'live-chat-db', 'live_chat_db', null),
      (3, historicalIdentity.value, historicalIdentity.sourceKind, 'Old Mac'),
      (4, zeroIdentity.value, zeroIdentity.sourceKind, 'Removed'),
    ],
    contactChannelCount: 4,
  );
  _createMinimalGraphDatabase(
    rootPath,
    messages: <(int, String, String)>[
      (
        SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 1),
        'duplicate-guid',
        '2020-01-01T00:00:00.000Z',
      ),
      (
        SourceScopedRowKey.pack(sourceId: 3, sourceRowId: 1),
        'duplicate-guid',
        '2010-01-01T00:00:00.000Z',
      ),
      (
        SourceScopedRowKey.pack(
          sourceId: 3,
          sourceRowId: SourceScopedRowKey.maxSourceRowId,
        ),
        'historical-second',
        '2011-01-01T00:00:00.000Z',
      ),
    ],
    chatCount: 2,
    attachmentReferenceCount: 2,
    contactCount: 2,
    linkedHandleCount: 3,
    ftsRowCount: 2,
  );
  _createVersionOnlyDatabase(
    appDatabasePath(AppDatabaseFile.overlay, databaseDirectory: rootPath),
    8,
  );
  _createVersionOnlyDatabase(
    appDatabasePath(AppDatabaseFile.presence, databaseDirectory: rootPath),
    9,
  );
}

void _createMinimalImportDatabase(
  String rootPath, {
  required List<(int, String, String, String?)> sources,
  int contactChannelCount = 0,
}) {
  final database = sqlite3.open(
    appDatabasePath(
      AppDatabaseFile.sourceScopedImport,
      databaseDirectory: rootPath,
    ),
  );
  try {
    database.execute('PRAGMA user_version = 10;');
    database.execute('''
CREATE TABLE source_registry (
  source_id INTEGER PRIMARY KEY,
  source_key TEXT NOT NULL,
  source_kind TEXT NOT NULL,
  source_label TEXT
);
''');
    database.execute('''
CREATE TABLE contact_channels (
  source_id INTEGER NOT NULL,
  source_contact_rowid INTEGER NOT NULL,
  kind TEXT NOT NULL,
  value TEXT NOT NULL
);
''');
    for (final source in sources) {
      database.execute(
        'INSERT INTO source_registry '
        '(source_id, source_key, source_kind, source_label) '
        'VALUES (?, ?, ?, ?);',
        <Object?>[source.$1, source.$2, source.$3, source.$4],
      );
    }
    for (var index = 0; index < contactChannelCount; index++) {
      database.execute(
        'INSERT INTO contact_channels '
        '(source_id, source_contact_rowid, kind, value) '
        'VALUES (2, ?, ?, ?);',
        <Object?>[index + 1, 'email', 'private-$index@example.invalid'],
      );
    }
  } finally {
    database.dispose();
  }
}

void _createMinimalGraphDatabase(
  String rootPath, {
  required List<(int, String, String)> messages,
  int chatCount = 0,
  int attachmentReferenceCount = 0,
  int contactCount = 0,
  int linkedHandleCount = 0,
  int ftsRowCount = 0,
}) {
  final database = sqlite3.open(
    appDatabasePath(
      AppDatabaseFile.conversationGraph,
      databaseDirectory: rootPath,
    ),
  );
  try {
    database.execute('PRAGMA user_version = 3;');
    database.execute(
      'CREATE TABLE messages '
      '(ss_id INTEGER PRIMARY KEY, guid TEXT, date_utc TEXT);',
    );
    database.execute('CREATE TABLE chats (ss_id INTEGER PRIMARY KEY);');
    database.execute(
      'CREATE TABLE message_to_attachment '
      '(message_ss_id INTEGER, attachment_ss_id INTEGER);',
    );
    database.execute('CREATE TABLE contacts (contact_id INTEGER PRIMARY KEY);');
    database.execute(
      'CREATE TABLE contact_to_handle '
      '(contact_id INTEGER, handle_ss_id INTEGER);',
    );
    database.execute(
      'CREATE TABLE message_text_fts (rowid INTEGER PRIMARY KEY, text TEXT);',
    );
    for (final message in messages) {
      database.execute(
        'INSERT INTO messages (ss_id, guid, date_utc) VALUES (?, ?, ?);',
        <Object?>[message.$1, message.$2, message.$3],
      );
    }
    for (var index = 0; index < chatCount; index++) {
      database.execute('INSERT INTO chats (ss_id) VALUES (?);', <Object?>[
        index + 1,
      ]);
    }
    for (var index = 0; index < attachmentReferenceCount; index++) {
      database.execute(
        'INSERT INTO message_to_attachment '
        '(message_ss_id, attachment_ss_id) VALUES (?, ?);',
        <Object?>[index + 1, index + 1],
      );
    }
    for (var index = 0; index < contactCount; index++) {
      database.execute(
        'INSERT INTO contacts (contact_id) VALUES (?);',
        <Object?>[index + 1],
      );
    }
    for (var index = 0; index < linkedHandleCount; index++) {
      database.execute(
        'INSERT INTO contact_to_handle '
        '(contact_id, handle_ss_id) VALUES (?, ?);',
        <Object?>[(index % contactCount) + 1, index + 1],
      );
    }
    for (var index = 0; index < ftsRowCount; index++) {
      database.execute(
        'INSERT INTO message_text_fts (rowid, text) VALUES (?, ?);',
        <Object?>[index + 1, 'private message $index'],
      );
    }
  } finally {
    database.dispose();
  }
}

void _createVersionOnlyDatabase(String databasePath, int userVersion) {
  final database = sqlite3.open(databasePath);
  try {
    database.execute('PRAGMA user_version = $userVersion;');
  } finally {
    database.dispose();
  }
}
