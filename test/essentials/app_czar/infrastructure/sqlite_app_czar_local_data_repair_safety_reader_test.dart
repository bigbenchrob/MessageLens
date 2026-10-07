import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar/infrastructure/sqlite_app_czar_local_data_repair_safety_reader.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SqliteAppCzarLocalDataRepairSafetyReader', () {
    late Directory tempDirectory;
    late String sourcePath;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'app_czar_local_repair_safety_',
      );
      sourcePath = path.join(tempDirectory.path, 'chat.db');
      _createMessagesSource(sourcePath);
    });

    tearDown(() async {
      await tempDirectory.delete(recursive: true);
    });

    test('proves the exact live-only one-message partial fixture', () async {
      await _createImportFixture(tempDirectory.path, messageCount: 1);

      final observation = await _read(tempDirectory.path, sourcePath);

      expect(
        observation.condition,
        AppCzarLocalDataRepairSafetyCondition.rebuildableLiveOnlyPartial,
        reason: observation.issue,
      );
      expect(observation.mayResetDerivedStores, isTrue);
      expect(observation.resetFootprint, <String>[
        'macos_import_ss.db',
        'working_ss.db',
      ]);
    });

    test('pages a fixture larger than one proof page', () async {
      const messageCount = 450;
      _insertSourceMessages(sourcePath, start: 2, count: messageCount - 1);
      await _createImportFixture(
        tempDirectory.path,
        messageCount: messageCount,
      );

      final observation = await _read(tempDirectory.path, sourcePath);

      expect(
        observation.condition,
        AppCzarLocalDataRepairSafetyCondition.rebuildableLiveOnlyPartial,
        reason: observation.issue,
      );
      expect(observation.consequentialRowCounts['messages'], messageCount);
    });

    test(
      'a local message missing from current source is known unsafe',
      () async {
        await _createImportFixture(tempDirectory.path, messageCount: 1);
        final source = sqlite.sqlite3.open(sourcePath);
        source.execute('DELETE FROM message WHERE ROWID = 1');
        source.dispose();

        final observation = await _read(tempDirectory.path, sourcePath);

        expect(
          observation.condition,
          AppCzarLocalDataRepairSafetyCondition.sourceFactMissing,
        );
        expect(observation.mayResetDerivedStores, isFalse);
      },
    );

    test('unreadable current source yields unknown and no authority', () async {
      await _createImportFixture(tempDirectory.path, messageCount: 1);
      File(sourcePath).deleteSync();

      final observation = await _read(tempDirectory.path, sourcePath);

      expect(
        observation.condition,
        AppCzarLocalDataRepairSafetyCondition.unknown,
      );
      expect(observation.mayResetDerivedStores, isFalse);
    });

    test('source change during comparison yields unknown', () async {
      await _createImportFixture(tempDirectory.path, messageCount: 1);
      final source = sqlite.sqlite3.open(sourcePath);
      source.execute('PRAGMA journal_mode = WAL');
      source.dispose();

      final observationFuture = _read(
        tempDirectory.path,
        sourcePath,
        stabilityObservationInterval: const Duration(seconds: 2),
      );
      await Future<void>.delayed(const Duration(seconds: 1));
      final writer = sqlite.sqlite3.open(sourcePath);
      writer.execute(
        'INSERT INTO message (guid, attributedBody) VALUES (?, ?)',
        <Object?>[
          'message-written-during-proof',
          <int>[2],
        ],
      );
      writer.dispose();

      final observation = await observationFuture;

      expect(
        observation.condition,
        AppCzarLocalDataRepairSafetyCondition.unknown,
        reason: observation.issue,
      );
      expect(observation.mayResetDerivedStores, isFalse);
      expect(observation.issue, isNotNull);
    });

    test('protected non-live source inventory blocks reset', () async {
      await _createImportFixture(
        tempDirectory.path,
        messageCount: 1,
        addHistoricalSource: true,
      );

      final observation = await _read(tempDirectory.path, sourcePath);

      expect(
        observation.condition,
        AppCzarLocalDataRepairSafetyCondition.protectedMaterialPresent,
      );
    });

    test('an unmatched attachment relationship blocks reset', () async {
      await _createImportFixture(
        tempDirectory.path,
        messageCount: 1,
        addUnmatchedAttachmentRelationship: true,
      );

      final observation = await _read(tempDirectory.path, sourcePath);

      expect(
        observation.condition,
        AppCzarLocalDataRepairSafetyCondition.sourceFactMissing,
      );
    });

    test('current Contacts projection participates in proof', () async {
      final contactsPath = path.join(tempDirectory.path, 'AddressBook.abcddb');
      _createContactsSource(contactsPath);
      await _createImportFixture(
        tempDirectory.path,
        messageCount: 1,
        addContact: true,
      );

      final observation = await _read(
        tempDirectory.path,
        sourcePath,
        contactsPath: contactsPath,
        contactsCondition:
            AppCzarContactsPrerequisiteCondition.viableWithContacts,
      );
      expect(
        observation.condition,
        AppCzarLocalDataRepairSafetyCondition.rebuildableLiveOnlyPartial,
        reason: observation.issue,
      );

      final contacts = sqlite.sqlite3.open(contactsPath);
      contacts.execute('DELETE FROM ZABCDEMAILADDRESS');
      contacts.dispose();
      final missingChannel = await _read(
        tempDirectory.path,
        sourcePath,
        contactsPath: contactsPath,
        contactsCondition:
            AppCzarContactsPrerequisiteCondition.viableWithContacts,
      );
      expect(
        missingChannel.condition,
        AppCzarLocalDataRepairSafetyCondition.sourceFactMissing,
      );
    });

    test('consequential graph facts block Stage One reset', () async {
      await _createImportFixture(tempDirectory.path, messageCount: 1);
      final graphPath = path.join(tempDirectory.path, 'working_ss.db');
      final graph = sqlite.sqlite3.open(graphPath);
      graph.execute('PRAGMA user_version = 3');
      for (final table in <String>[
        'messages',
        'handles',
        'canonical_handles',
        'handle_aliases',
        'chats',
        'chat_to_message',
        'chat_to_handle',
        'contacts',
        'contact_to_handle',
        'attachments',
        'message_to_attachment',
      ]) {
        graph.execute('CREATE TABLE $table (value INTEGER)');
      }
      graph.execute('INSERT INTO messages VALUES (1)');
      graph.dispose();

      final observation = await _read(tempDirectory.path, sourcePath);

      expect(
        observation.condition,
        AppCzarLocalDataRepairSafetyCondition.protectedMaterialPresent,
      );
    });

    test('retired derived residue is not automatically deleted', () async {
      await _createImportFixture(tempDirectory.path, messageCount: 1);
      File(
        path.join(tempDirectory.path, 'macos_import.db'),
      ).writeAsStringSync('unclassified');

      final observation = await _read(tempDirectory.path, sourcePath);

      expect(
        observation.condition,
        AppCzarLocalDataRepairSafetyCondition.retiredArtifactsPresent,
      );
    });
  });
}

Future<AppCzarLocalDataRepairSafetyObservation> _read(
  String rootPath,
  String sourcePath, {
  String? contactsPath,
  AppCzarContactsPrerequisiteCondition contactsCondition =
      AppCzarContactsPrerequisiteCondition.viableEmpty,
  Duration stabilityObservationInterval = Duration.zero,
}) {
  return SqliteAppCzarLocalDataRepairSafetyReader(
    archiveRootPath: rootPath,
    archiveInstanceId: 'test-instance',
    messagesDatabasePath: sourcePath,
    contactsDatabasePath: contactsPath,
    stabilityObservationInterval: stabilityObservationInterval,
  ).read(
    attachmentArchive: const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Fixture archive',
      archiveScopeIdentity: 'fixture-scope',
      archiveGeneration: 4,
      resolvedPath: '/fixture/attachment_archive',
      coverage: AppCzarAttachmentCoverageObservation(
        condition: AppCzarAttachmentCoverageCondition.complete,
        requiredCount: 0,
        coveredCount: 0,
        missingCount: 0,
        unverifiableCount: 0,
        archiveScopeIdentity: 'fixture-scope',
        archiveGeneration: 4,
      ),
      repairability: AppCzarAttachmentRepairabilityObservation(
        condition: AppCzarAttachmentRepairOpportunityCondition.absent,
        availableFromMessagesCount: 0,
        sourceAbsentCount: 0,
        sourceUnknownCount: 0,
        recordBackedRecoveryCount: 0,
        unsafeOrConflictingCount: 0,
        archiveScopeIdentity: 'fixture-scope',
        archiveGeneration: 4,
      ),
    ),
    contactsPrerequisite: AppCzarContactsPrerequisiteObservation(
      condition: contactsCondition,
      contactCount:
          contactsCondition ==
              AppCzarContactsPrerequisiteCondition.viableWithContacts
          ? 1
          : 0,
      viableStoreCount: 1,
      sourceDatabasePath: contactsPath,
    ),
  );
}

void _createMessagesSource(String sourcePath) {
  final database = sqlite.sqlite3.open(sourcePath);
  database.execute('CREATE TABLE message (guid TEXT, attributedBody BLOB)');
  database.execute('CREATE TABLE handle (id TEXT)');
  database.execute('CREATE TABLE chat (guid TEXT)');
  database.execute('CREATE TABLE attachment (guid TEXT)');
  database.execute(
    'CREATE TABLE chat_message_join (chat_id INTEGER, message_id INTEGER)',
  );
  database.execute(
    'CREATE TABLE chat_handle_join (chat_id INTEGER, handle_id INTEGER)',
  );
  database.execute(
    'CREATE TABLE message_attachment_join '
    '(message_id INTEGER, attachment_id INTEGER)',
  );
  database.execute(
    'INSERT INTO message (guid, attributedBody) VALUES (?, ?)',
    <Object?>[
      'message-1',
      <int>[1],
    ],
  );
  database.dispose();
}

void _insertSourceMessages(
  String sourcePath, {
  required int start,
  required int count,
}) {
  final database = sqlite.sqlite3.open(sourcePath);
  for (var index = start; index < start + count; index += 1) {
    database.execute(
      'INSERT INTO message (guid, attributedBody) VALUES (?, ?)',
      <Object?>[
        'message-$index',
        <int>[index % 255],
      ],
    );
  }
  database.dispose();
}

Future<void> _createImportFixture(
  String rootPath, {
  required int messageCount,
  bool addHistoricalSource = false,
  bool addUnmatchedAttachmentRelationship = false,
  bool addContact = false,
}) async {
  final import = await ImportDatabase.open(
    databaseDirectory: rootPath,
    databaseName: appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
  );
  final database = import.database;
  final messageBatch = await database.insert(
    'import_batches',
    <String, Object?>{
      'source_id': 1,
      'started_at_utc': '2026-10-07T00:00:00.000Z',
    },
  );
  for (var rowId = 1; rowId <= messageCount; rowId += 1) {
    await database.insert('messages', <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(sourceId: 1, sourceRowId: rowId),
      'source_id': 1,
      'source_rowid': rowId,
      'guid': 'message-$rowId',
      'is_from_me': 0,
      'is_system_message': 0,
      'has_attributed_body_source': 1,
      'has_message_summary_info': 0,
      'has_payload_data_source': 0,
      'batch_id': messageBatch,
    });
  }
  if (addHistoricalSource) {
    await database.insert('source_registry', <String, Object?>{
      'source_id': 3,
      'source_key': 'historical-fixture',
      'source_kind': 'historical_messages',
      'created_at_utc': '2026-10-07T00:00:00.000Z',
    });
  }
  if (addUnmatchedAttachmentRelationship) {
    await database.insert('attachments', <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 1),
      'source_id': 1,
      'source_rowid': 1,
      'guid': 'attachment-1',
      'batch_id': messageBatch,
    });
    await database.insert('message_to_attachment', <String, Object?>{
      'message_source_id': 1,
      'attachment_source_id': 1,
      'source_message_rowid': 1,
      'source_attachment_rowid': 1,
      'message_ss_id': SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 1),
      'attachment_ss_id': SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 1),
      'batch_id': messageBatch,
    });
    final source = sqlite.sqlite3.open(path.join(rootPath, 'chat.db'));
    source.execute('INSERT INTO attachment (guid) VALUES (?)', <Object?>[
      'attachment-1',
    ]);
    source.dispose();
  }
  if (addContact) {
    final contactBatch = await database.insert(
      'import_batches',
      <String, Object?>{
        'source_id': 2,
        'started_at_utc': '2026-10-07T00:00:00.000Z',
      },
    );
    await database.insert('contacts', <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(sourceId: 2, sourceRowId: 10),
      'source_id': 2,
      'source_rowid': 10,
      'display_name': 'Ada Lovelace',
      'first_name': 'Ada',
      'last_name': 'Lovelace',
      'batch_id': contactBatch,
    });
    await database.insert('contact_channels', <String, Object?>{
      'source_id': 2,
      'source_contact_rowid': 10,
      'contact_ss_id': SourceScopedRowKey.pack(sourceId: 2, sourceRowId: 10),
      'kind': 'email',
      'value': 'ada@example.com',
      'label': 'home',
      'batch_id': contactBatch,
    });
  }
  await import.close();
}

void _createContactsSource(String contactsPath) {
  final database = sqlite.sqlite3.open(contactsPath);
  database.execute('''
CREATE TABLE ZABCDRECORD (
  Z_PK INTEGER PRIMARY KEY,
  ZFIRSTNAME TEXT,
  ZMIDDLENAME TEXT,
  ZLASTNAME TEXT,
  ZORGANIZATION TEXT,
  ZCREATIONDATE REAL
);
''');
  database.execute('''
CREATE TABLE ZABCDEMAILADDRESS (
  ZOWNER INTEGER,
  ZADDRESS TEXT,
  ZADDRESSNORMALIZED TEXT,
  ZLABEL TEXT
);
''');
  database.execute('''
CREATE TABLE ZABCDPHONENUMBER (
  ZOWNER INTEGER,
  ZFULLNUMBER TEXT,
  ZVALUE TEXT,
  ZLABEL TEXT
);
''');
  database.execute(
    'INSERT INTO ZABCDRECORD '
    '(Z_PK, ZFIRSTNAME, ZLASTNAME, ZCREATIONDATE) VALUES (?, ?, ?, ?)',
    <Object?>[10, 'Ada', 'Lovelace', 0.0],
  );
  database.execute(
    'INSERT INTO ZABCDEMAILADDRESS '
    '(ZOWNER, ZADDRESS, ZLABEL) VALUES (?, ?, ?)',
    <Object?>[10, 'ADA@example.com', 'home'],
  );
  database.dispose();
}
