import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/contacts/contact_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_work_progress.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/source_database_port.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importDatabase;
  late String addressBookDbPath;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('contact_importer_test_');
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    addressBookDbPath = '${tempDir.path}/AddressBook-v22.abcddb';
    final sourceDb = await openDatabase(
      addressBookDbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ZABCDRECORD (
            Z_PK INTEGER PRIMARY KEY,
            ZFIRSTNAME TEXT,
            ZMIDDLENAME TEXT,
            ZLASTNAME TEXT,
            ZORGANIZATION TEXT,
            ZNICKNAME TEXT,
            ZCREATIONDATE REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE ZABCDEMAILADDRESS (
            ZOWNER INTEGER,
            ZADDRESS TEXT,
            ZADDRESSNORMALIZED TEXT,
            ZLABEL TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE ZABCDPHONENUMBER (
            ZOWNER INTEGER,
            ZFULLNUMBER TEXT,
            ZVALUE TEXT,
            ZLABEL TEXT
          )
        ''');
      },
    );
    await sourceDb.close();
  });

  tearDown(() async {
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('imports contacts and channels into the source-scoped ledger', () async {
    final sourceDb = await openDatabase(addressBookDbPath);
    await sourceDb.insert('ZABCDRECORD', <String, Object?>{
      'Z_PK': 24,
      'ZFIRSTNAME': 'Cathie',
      'ZLASTNAME': 'Campbell',
    });
    await sourceDb.insert('ZABCDPHONENUMBER', <String, Object?>{
      'ZOWNER': 24,
      'ZFULLNUMBER': '+1 (604) 999-5969',
    });
    await sourceDb.insert('ZABCDEMAILADDRESS', <String, Object?>{
      'ZOWNER': 24,
      'ZADDRESS': 'Cathie.Campbell@GMAIL.COM',
    });
    await sourceDb.close();

    final result = await ContactImporter(
      addressBookDbPath: addressBookDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importContacts();

    expect(result.examinedContactCount, 1);
    expect(result.insertedContactCount, 1);
    expect(result.insertedChannelCount, 2);

    final contactSsId = SourceScopedRowKey.pack(
      sourceId: liveAddressBookSourceId,
      sourceRowId: 24,
    );
    final contacts = await importDatabase.database.query('contacts');
    expect(contacts.single['ss_id'], contactSsId);
    expect(contacts.single['source_id'], liveAddressBookSourceId);
    expect(contacts.single['source_rowid'], 24);
    expect(contacts.single['display_name'], 'Cathie Campbell');

    final channels = await importDatabase.database.query(
      'contact_channels',
      orderBy: 'kind ASC',
    );
    expect(channels, hasLength(2));
    expect(channels.map((row) => row['value']).toSet(), <String>{
      'cathie.campbell@gmail.com',
      '6049995969',
    });

    final secondResult = await ContactImporter(
      addressBookDbPath: addressBookDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importContacts();
    expect(secondResult.insertedContactCount, 0);
    expect(secondResult.insertedChannelCount, 0);
  });

  test(
    'preserves source contact while accounting unavailable enrichment',
    () async {
      final sourceDb = await openDatabase(addressBookDbPath);
      await sourceDb.insert('ZABCDRECORD', <String, Object?>{'Z_PK': 31});
      await sourceDb.insert('ZABCDEMAILADDRESS', <String, Object?>{
        'ZOWNER': 31,
        'ZADDRESS': null,
      });
      await sourceDb.close();

      final result = await ContactImporter(
        addressBookDbPath: addressBookDbPath,
        importLedger: importDatabase,
        sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
      ).importContacts();

      expect(result.insertedContactCount, 1);
      expect(result.anomalyCounts.contactEnrichmentUnavailableCount, 1);
      expect(result.anomalyCounts.omittedContactChannelCount, 1);
      expect(await importDatabase.database.query('contacts'), hasLength(1));
      expect(await importDatabase.database.query('contact_channels'), isEmpty);
    },
  );

  test(
    'characterizes canonical contact and channel rows before extraction',
    () async {
      final sourceDatabase = _SyntheticContactSourceDatabase(
        contactRows: <Map<String, Object?>>[
          <String, Object?>{
            'Z_PK': 101,
            'ZFIRSTNAME': '  Ada ',
            'ZMIDDLENAME': ' M ',
            'ZLASTNAME': ' Lovelace  ',
            'ZORGANIZATION': ' Engine Society ',
            'ZCREATIONDATE': 1,
          },
          <String, Object?>{
            'Z_PK': 102,
            'ZFIRSTNAME': ' ',
            'ZORGANIZATION': '  Analytical Engines  ',
            'ZCREATIONDATE': 0,
          },
          <String, Object?>{'Z_PK': 'invalid-primary-key'},
          <String, Object?>{'Z_PK': 103},
          <String, Object?>{
            'Z_PK': 104,
            'ZFIRSTNAME': ' Channel ',
            'ZLASTNAME': ' Free ',
            'ZCREATIONDATE': null,
          },
        ],
        emailRows: <Map<String, Object?>>[
          <String, Object?>{
            'ZOWNER': 101,
            'ZADDRESS': ' Ada@Example.COM ',
            'ZLABEL': ' home ',
          },
          <String, Object?>{
            'ZOWNER': 101,
            'ZADDRESS': 'ada@example.com',
            'ZLABEL': 'duplicate ignored by ledger',
          },
          <String, Object?>{
            'ZOWNER': 101,
            'ZADDRESS': null,
            'ZADDRESSNORMALIZED': ' Normalized@Example.COM ',
            'ZLABEL': ' normalized ',
          },
          <String, Object?>{'ZOWNER': 999, 'ZADDRESS': 'orphan@example.com'},
          <String, Object?>{
            'ZOWNER': 'invalid-owner',
            'ZADDRESS': 'invalid@example.com',
          },
          <String, Object?>{
            'ZOWNER': 103,
            'ZADDRESS': null,
            'ZADDRESSNORMALIZED': ' ',
          },
        ],
        phoneRows: <Map<String, Object?>>[
          <String, Object?>{
            'ZOWNER': 101,
            'ZFULLNUMBER': '+1 (604) 555-0100',
            'ZLABEL': ' mobile ',
          },
          <String, Object?>{
            'ZOWNER': 101,
            'ZFULLNUMBER': ' extension only ',
            'ZLABEL': ' work ',
          },
          <String, Object?>{
            'ZOWNER': 102,
            'ZFULLNUMBER': ' ',
            'ZVALUE': ' +1 250 555 0101 x9 ',
            'ZLABEL': ' ',
          },
          <String, Object?>{'ZOWNER': 103, 'ZFULLNUMBER': null},
          <String, Object?>{
            'ZOWNER': 'invalid-owner',
            'ZFULLNUMBER': '604-555-0199',
          },
          <String, Object?>{
            'ZOWNER': 101,
            'ZFULLNUMBER': '6045550100',
            'ZLABEL': 'duplicate ignored by ledger',
          },
        ],
      );
      final progress = <SourceImportWorkProgress>[];

      final result = await ContactImporter(
        addressBookDbPath: 'synthetic-address-book.db',
        importLedger: importDatabase,
        sourceDatabaseOpener: _SyntheticContactSourceDatabaseOpener(
          sourceDatabase,
        ),
      ).importContacts(onProgress: progress.add);

      expect(result.examinedContactCount, 5);
      expect(result.insertedContactCount, 4);
      expect(result.insertedChannelCount, 5);
      expect(result.anomalyCounts.omittedContactRecordCount, 1);
      expect(result.anomalyCounts.contactEnrichmentUnavailableCount, 1);
      expect(result.anomalyCounts.omittedContactChannelCount, 5);
      expect(sourceDatabase.closed, isTrue);
      expect(sourceDatabase.observedQueries, <String>[
        'ZABCDRECORD|Z_PK ASC',
        'ZABCDEMAILADDRESS|ZOWNER ASC, ZADDRESS ASC',
        'ZABCDPHONENUMBER|ZOWNER ASC, ZFULLNUMBER ASC',
      ]);

      final contacts = await importDatabase.database.query(
        'contacts',
        orderBy: 'source_rowid ASC',
      );
      expect(contacts, <Map<String, Object?>>[
        <String, Object?>{
          'ss_id': SourceScopedRowKey.pack(
            sourceId: liveAddressBookSourceId,
            sourceRowId: 101,
          ),
          'source_id': liveAddressBookSourceId,
          'source_rowid': 101,
          'display_name': 'Ada M Lovelace',
          'first_name': 'Ada',
          'last_name': 'Lovelace',
          'organization': 'Engine Society',
          'created_at_utc': '2001-01-01T00:00:01.000Z',
          'batch_id': 1,
        },
        <String, Object?>{
          'ss_id': SourceScopedRowKey.pack(
            sourceId: liveAddressBookSourceId,
            sourceRowId: 102,
          ),
          'source_id': liveAddressBookSourceId,
          'source_rowid': 102,
          'display_name': 'Analytical Engines',
          'first_name': null,
          'last_name': null,
          'organization': 'Analytical Engines',
          'created_at_utc': null,
          'batch_id': 1,
        },
        <String, Object?>{
          'ss_id': SourceScopedRowKey.pack(
            sourceId: liveAddressBookSourceId,
            sourceRowId: 103,
          ),
          'source_id': liveAddressBookSourceId,
          'source_rowid': 103,
          'display_name': 'Unknown Contact',
          'first_name': null,
          'last_name': null,
          'organization': null,
          'created_at_utc': null,
          'batch_id': 1,
        },
        <String, Object?>{
          'ss_id': SourceScopedRowKey.pack(
            sourceId: liveAddressBookSourceId,
            sourceRowId: 104,
          ),
          'source_id': liveAddressBookSourceId,
          'source_rowid': 104,
          'display_name': 'Channel Free',
          'first_name': 'Channel',
          'last_name': 'Free',
          'organization': null,
          'created_at_utc': null,
          'batch_id': 1,
        },
      ]);

      final channels = await importDatabase.database.rawQuery('''
        SELECT
          source_id,
          source_contact_rowid,
          contact_ss_id,
          kind,
          value,
          label,
          batch_id
        FROM contact_channels
        ORDER BY rowid ASC
      ''');
      expect(channels, <Map<String, Object?>>[
        _expectedChannel(
          sourceContactRowId: 101,
          kind: 'email',
          value: 'ada@example.com',
          label: 'home',
        ),
        _expectedChannel(
          sourceContactRowId: 101,
          kind: 'email',
          value: 'normalized@example.com',
          label: 'normalized',
        ),
        _expectedChannel(
          sourceContactRowId: 101,
          kind: 'phone',
          value: '6045550100',
          label: 'mobile',
        ),
        _expectedChannel(
          sourceContactRowId: 101,
          kind: 'phone',
          value: 'extension only',
          label: 'work',
        ),
        _expectedChannel(
          sourceContactRowId: 102,
          kind: 'phone',
          value: '125055501019',
          label: null,
        ),
      ]);

      final batches = await importDatabase.database.query('import_batches');
      expect(batches, hasLength(1));
      expect(batches.single['batch_id'], 1);
      expect(batches.single['source_id'], liveAddressBookSourceId);
      expect(batches.single['finished_at_utc'], isNull);
      expect(batches.single['notes'], isNull);
      final startedAt = DateTime.parse(
        batches.single['started_at_utc']! as String,
      );
      expect(startedAt.isUtc, isTrue);

      expect(
        progress.map(_progressCharacterization).toList(),
        <Map<String, Object?>>[
          _expectedProgress(SourceImportWorkUnit.contacts, 0, 5),
          _expectedProgress(
            SourceImportWorkUnit.contacts,
            5,
            5,
            lastSourceRowId: 104,
            omittedContactCount: 1,
            unavailableEnrichmentCount: 1,
          ),
          _expectedProgress(SourceImportWorkUnit.contactEmailChannels, 0, 6),
          _expectedProgress(
            SourceImportWorkUnit.contactEmailChannels,
            6,
            6,
            lastSourceRowId: 103,
            omittedContactCount: 1,
            unavailableEnrichmentCount: 1,
            omittedChannelCount: 3,
          ),
          _expectedProgress(SourceImportWorkUnit.contactPhoneChannels, 0, 6),
          _expectedProgress(
            SourceImportWorkUnit.contactPhoneChannels,
            6,
            6,
            lastSourceRowId: 101,
            omittedContactCount: 1,
            unavailableEnrichmentCount: 1,
            omittedChannelCount: 5,
          ),
        ],
      );
    },
  );
}

Map<String, Object?> _expectedChannel({
  required int sourceContactRowId,
  required String kind,
  required String value,
  required String? label,
}) {
  return <String, Object?>{
    'source_id': liveAddressBookSourceId,
    'source_contact_rowid': sourceContactRowId,
    'contact_ss_id': SourceScopedRowKey.pack(
      sourceId: liveAddressBookSourceId,
      sourceRowId: sourceContactRowId,
    ),
    'kind': kind,
    'value': value,
    'label': label,
    'batch_id': 1,
  };
}

Map<String, Object?> _progressCharacterization(
  SourceImportWorkProgress progress,
) {
  return <String, Object?>{
    'unit': progress.unit,
    'completed': progress.completedWorkCount,
    'total': progress.totalWorkCount,
    'last_source_rowid': progress.lastCompletedSourceRowId,
    'omitted_contacts': progress.anomalyCounts.omittedContactRecordCount,
    'unavailable_enrichment':
        progress.anomalyCounts.contactEnrichmentUnavailableCount,
    'omitted_channels': progress.anomalyCounts.omittedContactChannelCount,
  };
}

Map<String, Object?> _expectedProgress(
  SourceImportWorkUnit unit,
  int completed,
  int total, {
  int? lastSourceRowId,
  int omittedContactCount = 0,
  int unavailableEnrichmentCount = 0,
  int omittedChannelCount = 0,
}) {
  return <String, Object?>{
    'unit': unit,
    'completed': completed,
    'total': total,
    'last_source_rowid': lastSourceRowId,
    'omitted_contacts': omittedContactCount,
    'unavailable_enrichment': unavailableEnrichmentCount,
    'omitted_channels': omittedChannelCount,
  };
}

final class _SyntheticContactSourceDatabaseOpener
    implements SourceDatabaseOpener {
  const _SyntheticContactSourceDatabaseOpener(this.database);

  final _SyntheticContactSourceDatabase database;

  @override
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath) async {
    return database;
  }
}

final class _SyntheticContactSourceDatabase implements ReadOnlySourceDatabase {
  _SyntheticContactSourceDatabase({
    required this.contactRows,
    required this.emailRows,
    required this.phoneRows,
  });

  final List<Map<String, Object?>> contactRows;
  final List<Map<String, Object?>> emailRows;
  final List<Map<String, Object?>> phoneRows;
  final List<String> observedQueries = <String>[];
  bool closed = false;

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    String? orderBy,
  }) async {
    observedQueries.add('$table|$orderBy');
    return switch (table) {
      'ZABCDRECORD' => contactRows,
      'ZABCDEMAILADDRESS' => emailRows,
      'ZABCDPHONENUMBER' => phoneRows,
      _ => throw StateError('Unexpected synthetic table: $table'),
    };
  }

  @override
  Future<void> close() async {
    closed = true;
  }

  @override
  Future<Set<String>> findExistingMessageGuids(Set<String> targetGuids) {
    throw UnsupportedError('Not used by contact importer characterization');
  }

  @override
  Future<SourceMessageImportWindow> messageImportWindowAfter(int sourceRowId) {
    throw UnsupportedError('Not used by contact importer characterization');
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) {
    throw UnsupportedError('Not used by contact importer characterization');
  }

  @override
  Future<List<Map<String, Object?>>> readMessageImportPage({
    required int afterSourceRowId,
    required int throughSourceRowId,
    required int limit,
  }) {
    throw UnsupportedError('Not used by contact importer characterization');
  }
}
