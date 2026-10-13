import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/date_converter.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/attachments/attachment_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_work_progress.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/source_database_port.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late String chatDbPath;
  late ImportDatabase importDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('attachment_import_test_');
    chatDbPath = '${tempDir.path}/chat.db';
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    await _createSourceAttachmentTable(chatDbPath);
  });

  tearDown(() async {
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('imports attachment source facts and provenance', () async {
    await _insertSourceAttachment(
      chatDbPath,
      rowId: 10,
      guid: 'attachment-guid',
      filename: '/Users/rob/Library/Messages/Attachments/photo.jpg',
      transferName: 'photo.jpg',
      uti: 'public.jpeg',
      mimeType: 'image/jpeg',
      totalBytes: 1234,
    );

    final result = await AttachmentImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importAttachments();
    final rows = await importDatabase.database.query('attachments');

    expect(result.startedAfterSourceRowId, 0);
    expect(result.examinedAttachmentCount, 1);
    expect(result.insertedAttachmentCount, 1);
    expect(result.lastImportedSourceRowId, 10);
    expect(
      rows.single['ss_id'],
      SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 10),
    );
    expect(rows.single['source_id'], liveChatDbSourceId);
    expect(rows.single['source_rowid'], 10);
    expect(rows.single['guid'], 'attachment-guid');
    expect(rows.single['filename'], contains('photo.jpg'));
    expect(rows.single['transfer_name'], 'photo.jpg');
    expect(rows.single['uti'], 'public.jpeg');
    expect(rows.single['mime_type'], 'image/jpeg');
    expect(rows.single['total_bytes'], 1234);
  });

  test('is idempotent and continues from source-scoped cursor', () async {
    await _insertSourceAttachment(chatDbPath, rowId: 1, guid: 'one');
    await _insertSourceAttachment(chatDbPath, rowId: 2, guid: 'two');

    final importer = AttachmentImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );
    final firstResult = await importer.importAttachments();
    final secondResult = await importer.importAttachments();

    expect(firstResult.insertedAttachmentCount, 2);
    expect(secondResult.startedAfterSourceRowId, 2);
    expect(secondResult.insertedAttachmentCount, 0);
  });

  test('source-scoped continuation ignores another source', () async {
    final batchId = await importDatabase.insertImportBatch(
      sourceId: liveChatDbSourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    await _insertSource(importDatabase, sourceId: 3);
    await importDatabase.database.insert('attachments', <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(sourceId: 3, sourceRowId: 9999),
      'source_id': 3,
      'source_rowid': 9999,
      'guid': 'archive-attachment',
      'batch_id': batchId,
    });
    await _insertSourceAttachment(chatDbPath, rowId: 5, guid: 'live-five');

    final result = await AttachmentImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importAttachments();

    expect(result.startedAfterSourceRowId, 0);
    expect(result.insertedAttachmentCount, 1);
    expect(result.lastImportedSourceRowId, 5);
  });

  test('reports attachment start and exact completed count', () async {
    await _insertSourceAttachment(chatDbPath, rowId: 3, guid: 'three');
    await _insertSourceAttachment(chatDbPath, rowId: 8, guid: 'eight');
    final observations = <SourceImportWorkProgress>[];

    await AttachmentImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importAttachments(onProgress: observations.add);

    expect(observations, hasLength(2));
    expect(observations.first.completedWorkCount, 0);
    expect(observations.first.totalWorkCount, 2);
    expect(observations.last.completedWorkCount, 2);
    expect(observations.last.lastCompletedSourceRowId, 8);
  });

  test('preserves an attachment fact with degraded metadata', () async {
    await _insertSourceAttachment(chatDbPath, rowId: 9, guid: null);

    final result = await AttachmentImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importAttachments();

    expect(result.insertedAttachmentCount, 1);
    expect(result.anomalyCounts.attachmentMetadataDegradedCount, 1);
    expect(await importDatabase.database.query('attachments'), hasLength(1));
  });

  test('characterizes complete ordered attachment rows, raw metadata, dates, '
      'duplicates, progress, anomalies, and incremental reruns before '
      'extraction', () async {
    final oldAppleSeconds = DateConverter.apple2CoreTS(
      DateConverter.dateString2Apple('2012-07-25'),
    );
    final modernAppleNanoseconds = DateConverter.dateString2Apple('2026-08-16');
    final sourceDatabase = _SyntheticAttachmentSourceDatabase(
      rows: <Map<String, Object?>>[
        <String, Object?>{
          'source_rowid': 1,
          'guid': 'attachment-1',
          'filename': '/raw/source/path/photo.jpg',
          'transfer_name': 'photo.jpg',
          'uti': 'public.jpeg',
          'mime_type': 'image/jpeg',
          'total_bytes': 1234,
          'created_date': oldAppleSeconds,
          'created_at': modernAppleNanoseconds,
          'irrelevant_source_column': 'not persisted',
        },
        <String, Object?>{
          'source_rowid': 2.4,
          'guid': '   ',
          'filename': '',
          'transfer_name': null,
          'uti': 7,
          'mime_type': '',
          'total_bytes': 12.6,
          'created_date': modernAppleNanoseconds,
        },
        <String, Object?>{
          'source_rowid': 3,
          'guid': null,
          'filename': null,
          'transfer_name': '',
          'uti': null,
          'mime_type': 99,
          'total_bytes': 'unknown',
          'created_date': 0,
          'created_at': oldAppleSeconds,
        },
        <String, Object?>{
          'source_rowid': 4,
          'guid': '添付-📎',
          'filename': '/原資料/写真 📷.heic',
          'transfer_name': '写真 📷.heic',
          'uti': 'public.heic',
          'mime_type': 'image/heic',
          'total_bytes': 0,
          'created_date': null,
          'created_at': null,
        },
        <String, Object?>{
          'source_rowid': 4,
          'guid': null,
          'filename': null,
          'transfer_name': null,
          'uti': null,
          'mime_type': null,
          'total_bytes': -1,
          'created_date': modernAppleNanoseconds,
        },
        <String, Object?>{
          'source_rowid': SourceScopedRowKey.maxSourceRowId,
          'guid': 'boundary-row',
          'filename': '/raw/source/path/boundary.bin',
          'transfer_name': 'boundary.bin',
          'uti': 'public.data',
          'mime_type': 'application/octet-stream',
          'total_bytes': 9223372036854775807,
          'created_date': modernAppleNanoseconds.toDouble(),
        },
      ],
    );
    final firstProgress = <SourceImportWorkProgress>[];
    final importer = AttachmentImporter(
      chatDbPath: 'synthetic-chat.db',
      importLedger: importDatabase,
      sourceDatabaseOpener: _SyntheticAttachmentSourceDatabaseOpener(
        sourceDatabase,
      ),
    );

    final firstResult = await importer.importAttachments(
      onProgress: firstProgress.add,
    );

    expect(firstResult.startedAfterSourceRowId, 0);
    expect(firstResult.examinedAttachmentCount, 6);
    expect(firstResult.insertedAttachmentCount, 5);
    expect(
      firstResult.lastImportedSourceRowId,
      SourceScopedRowKey.maxSourceRowId,
    );
    expect(firstResult.anomalyCounts.attachmentMetadataDegradedCount, 2);
    expect(sourceDatabase.closeCount, 1);
    expect(sourceDatabase.observedQueries, <Map<String, Object?>>[
      <String, Object?>{
        'sql': _attachmentSourceQuery,
        'arguments': <Object?>[0],
      },
    ]);
    expect(await _readAttachments(importDatabase), <Map<String, Object?>>[
      _expectedAttachment(
        sourceRowId: 1,
        guid: 'attachment-1',
        filename: '/raw/source/path/photo.jpg',
        transferName: 'photo.jpg',
        uti: 'public.jpeg',
        mimeType: 'image/jpeg',
        totalBytes: 1234,
        createdAtUtc: DateConverter.appleToIsoString(oldAppleSeconds),
      ),
      _expectedAttachment(
        sourceRowId: 2,
        guid: '   ',
        filename: null,
        transferName: null,
        uti: null,
        mimeType: null,
        totalBytes: 13,
        createdAtUtc: DateConverter.appleToIsoString(modernAppleNanoseconds),
      ),
      _expectedAttachment(
        sourceRowId: 3,
        guid: null,
        filename: null,
        transferName: null,
        uti: null,
        mimeType: null,
        totalBytes: null,
        createdAtUtc: DateConverter.appleToIsoString(oldAppleSeconds),
      ),
      _expectedAttachment(
        sourceRowId: 4,
        guid: '添付-📎',
        filename: '/原資料/写真 📷.heic',
        transferName: '写真 📷.heic',
        uti: 'public.heic',
        mimeType: 'image/heic',
        totalBytes: 0,
        createdAtUtc: null,
      ),
      _expectedAttachment(
        sourceRowId: SourceScopedRowKey.maxSourceRowId,
        guid: 'boundary-row',
        filename: '/raw/source/path/boundary.bin',
        transferName: 'boundary.bin',
        uti: 'public.data',
        mimeType: 'application/octet-stream',
        totalBytes: 9223372036854775807,
        createdAtUtc: DateConverter.appleToIsoString(modernAppleNanoseconds),
      ),
    ]);
    expect(
      firstProgress.map(_attachmentProgressCharacterization).toList(),
      <Map<String, Object?>>[
        _expectedAttachmentProgress(completed: 0, total: 6),
        _expectedAttachmentProgress(
          completed: 6,
          total: 6,
          lastSourceRowId: SourceScopedRowKey.maxSourceRowId,
          metadataDegradedCount: 2,
        ),
      ],
    );

    sourceDatabase.observedQueries.clear();
    final secondProgress = <SourceImportWorkProgress>[];
    final secondResult = await importer.importAttachments(
      onProgress: secondProgress.add,
    );

    expect(
      secondResult.startedAfterSourceRowId,
      SourceScopedRowKey.maxSourceRowId,
    );
    expect(secondResult.examinedAttachmentCount, 0);
    expect(secondResult.insertedAttachmentCount, 0);
    expect(secondResult.lastImportedSourceRowId, isNull);
    expect(secondResult.anomalyCounts.attachmentMetadataDegradedCount, 0);
    expect(sourceDatabase.closeCount, 2);
    expect(sourceDatabase.observedQueries, <Map<String, Object?>>[
      <String, Object?>{
        'sql': _attachmentSourceQuery,
        'arguments': <Object?>[SourceScopedRowKey.maxSourceRowId],
      },
    ]);
    expect(
      secondProgress.map(_attachmentProgressCharacterization).toList(),
      <Map<String, Object?>>[
        _expectedAttachmentProgress(completed: 0, total: 0),
      ],
    );
    expect(await _readAttachments(importDatabase), hasLength(5));
    expect(await importDatabase.database.query('import_batches'), hasLength(1));
  });

  test(
    'characterizes empty synthetic source without allocating a batch',
    () async {
      final sourceDatabase = _SyntheticAttachmentSourceDatabase(
        rows: const <Map<String, Object?>>[],
      );
      final progress = <SourceImportWorkProgress>[];

      final result = await AttachmentImporter(
        chatDbPath: 'synthetic-chat.db',
        importLedger: importDatabase,
        sourceDatabaseOpener: _SyntheticAttachmentSourceDatabaseOpener(
          sourceDatabase,
        ),
      ).importAttachments(onProgress: progress.add);

      expect(result.startedAfterSourceRowId, 0);
      expect(result.examinedAttachmentCount, 0);
      expect(result.insertedAttachmentCount, 0);
      expect(result.lastImportedSourceRowId, isNull);
      expect(sourceDatabase.closeCount, 1);
      expect(await importDatabase.database.query('attachments'), isEmpty);
      expect(await importDatabase.database.query('import_batches'), isEmpty);
      expect(
        progress.map(_attachmentProgressCharacterization).toList(),
        <Map<String, Object?>>[
          _expectedAttachmentProgress(completed: 0, total: 0),
        ],
      );
    },
  );

  test('characterizes malformed identity rollback, retained batch, published '
      'progress, direct error, and closure', () async {
    final sourceDatabase = _SyntheticAttachmentSourceDatabase(
      rows: <Map<String, Object?>>[
        <String, Object?>{'source_rowid': 21, 'guid': 'valid-attachment'},
        <String, Object?>{'source_rowid': null, 'guid': 'missing-rowid'},
      ],
    );
    final progress = <SourceImportWorkProgress>[];

    await expectLater(
      AttachmentImporter(
        chatDbPath: 'synthetic-chat.db',
        importLedger: importDatabase,
        sourceDatabaseOpener: _SyntheticAttachmentSourceDatabaseOpener(
          sourceDatabase,
        ),
      ).importAttachments(onProgress: progress.add),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'attachment.source_rowid is required',
        ),
      ),
    );

    expect(sourceDatabase.closeCount, 1);
    expect(await importDatabase.database.query('attachments'), isEmpty);
    expect(await importDatabase.database.query('import_batches'), hasLength(1));
    expect(
      progress.map(_attachmentProgressCharacterization).toList(),
      <Map<String, Object?>>[
        _expectedAttachmentProgress(completed: 0, total: 2),
      ],
    );
  });

  test('closes synthetic source and propagates query failure before batch '
      'creation', () async {
    final sourceDatabase = _SyntheticAttachmentSourceDatabase(
      rows: const <Map<String, Object?>>[],
      queryError: StateError('synthetic attachment query failed'),
    );

    await expectLater(
      AttachmentImporter(
        chatDbPath: 'synthetic-chat.db',
        importLedger: importDatabase,
        sourceDatabaseOpener: _SyntheticAttachmentSourceDatabaseOpener(
          sourceDatabase,
        ),
      ).importAttachments(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'synthetic attachment query failed',
        ),
      ),
    );

    expect(sourceDatabase.closeCount, 1);
    expect(await importDatabase.database.query('attachments'), isEmpty);
    expect(await importDatabase.database.query('import_batches'), isEmpty);
  });
}

const _attachmentSourceQuery =
    'SELECT ROWID AS source_rowid, * FROM attachment '
    'WHERE ROWID > ? ORDER BY ROWID ASC';

Map<String, Object?> _expectedAttachment({
  required int sourceRowId,
  required String? guid,
  required String? filename,
  required String? transferName,
  required String? uti,
  required String? mimeType,
  required int? totalBytes,
  required String? createdAtUtc,
}) {
  return <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': liveChatDbSourceId,
    'source_rowid': sourceRowId,
    'guid': guid,
    'filename': filename,
    'transfer_name': transferName,
    'uti': uti,
    'mime_type': mimeType,
    'total_bytes': totalBytes,
    'created_at_utc': createdAtUtc,
    'batch_id': 1,
  };
}

Map<String, Object?> _attachmentProgressCharacterization(
  SourceImportWorkProgress progress,
) {
  return <String, Object?>{
    'unit': progress.unit,
    'completed': progress.completedWorkCount,
    'total': progress.totalWorkCount,
    'last_source_rowid': progress.lastCompletedSourceRowId,
    'attachment_metadata_degraded':
        progress.anomalyCounts.attachmentMetadataDegradedCount,
  };
}

Map<String, Object?> _expectedAttachmentProgress({
  required int completed,
  required int total,
  int? lastSourceRowId,
  int metadataDegradedCount = 0,
}) {
  return <String, Object?>{
    'unit': SourceImportWorkUnit.attachments,
    'completed': completed,
    'total': total,
    'last_source_rowid': lastSourceRowId,
    'attachment_metadata_degraded': metadataDegradedCount,
  };
}

Future<List<Map<String, Object?>>> _readAttachments(
  ImportDatabase importDatabase,
) {
  return importDatabase.database.query(
    'attachments',
    orderBy: 'source_rowid ASC',
  );
}

final class _SyntheticAttachmentSourceDatabaseOpener
    implements SourceDatabaseOpener {
  const _SyntheticAttachmentSourceDatabaseOpener(this.database);

  final _SyntheticAttachmentSourceDatabase database;

  @override
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath) async {
    return database;
  }
}

final class _SyntheticAttachmentSourceDatabase
    implements ReadOnlySourceDatabase {
  _SyntheticAttachmentSourceDatabase({required this.rows, this.queryError});

  final List<Map<String, Object?>> rows;
  final Object? queryError;
  final List<Map<String, Object?>> observedQueries = <Map<String, Object?>>[];
  int closeCount = 0;

  @override
  Future<void> close() async {
    closeCount += 1;
  }

  @override
  Future<Set<String>> findExistingMessageGuids(Set<String> targetGuids) {
    throw UnsupportedError('Attachment importer does not read message GUIDs');
  }

  @override
  Future<SourceMessageImportWindow> messageImportWindowAfter(int sourceRowId) {
    throw UnsupportedError('Attachment importer does not use message paging');
  }

  @override
  Future<List<Map<String, Object?>>> query(String table, {String? orderBy}) {
    throw UnsupportedError('Attachment importer uses one bounded raw query');
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    observedQueries.add(<String, Object?>{
      'sql': sql,
      'arguments': arguments == null ? null : List<Object?>.of(arguments),
    });
    expect(sql, _attachmentSourceQuery);
    expect(arguments, hasLength(1));
    if (arguments == null) {
      fail('Attachment source query arguments are required');
    }
    final startedAfterSourceRowId = arguments.single;
    if (startedAfterSourceRowId is! int) {
      fail('Attachment source cursor must be an int');
    }
    if (queryError != null) {
      throw queryError!;
    }
    return rows
        .where((row) {
          final value = row['source_rowid'];
          final rowId = value is int
              ? value
              : value is double
              ? value.round()
              : null;
          return rowId == null || rowId > startedAfterSourceRowId;
        })
        .toList(growable: false);
  }

  @override
  Future<List<Map<String, Object?>>> readMessageImportPage({
    required int afterSourceRowId,
    required int throughSourceRowId,
    required int limit,
  }) {
    throw UnsupportedError('Attachment importer does not read message pages');
  }
}

Future<void> _createSourceAttachmentTable(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.execute('''
    CREATE TABLE attachment (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT,
      filename TEXT,
      transfer_name TEXT,
      uti TEXT,
      mime_type TEXT,
      total_bytes INTEGER,
      created_date INTEGER
    )
  ''');
  await db.close();
}

Future<void> _insertSourceAttachment(
  String chatDbPath, {
  required int rowId,
  required String? guid,
  String? filename,
  String? transferName,
  String? uti,
  String? mimeType,
  int? totalBytes,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('attachment', <String, Object?>{
    'ROWID': rowId,
    'guid': guid,
    'filename': filename,
    'transfer_name': transferName,
    'uti': uti,
    'mime_type': mimeType,
    'total_bytes': totalBytes,
  });
  await db.close();
}

Future<void> _insertSource(
  ImportDatabase importDatabase, {
  required int sourceId,
}) async {
  await importDatabase.database.insert('source_registry', <String, Object?>{
    'source_id': sourceId,
    'source_key': 'source-$sourceId',
    'source_kind': 'archive_chat_db',
    'created_at_utc': DateTime.now().toUtc().toIso8601String(),
  });
}
