import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/source_database_port.dart';
import 'package:remember_this_text/features/attachments/application/current_messages_attachment_source_reader.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/source_database_current_messages_attachment_source_reader.dart';
import 'package:sqflite/sqflite.dart' show DatabaseException;

void main() {
  const archiveKey = ArchiveCompatibilityKey(
    messageGuid: 'exact-message-guid',
    importAttachmentId: 42,
  );

  late Directory temporaryDirectory;
  late File databaseFile;
  late File payloadFile;
  late _FakeSourceDatabase database;
  late _FakeSourceDatabaseOpener opener;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'current_messages_attachment_source_reader_test_',
    );
    databaseFile = File('${temporaryDirectory.path}/chat.db');
    await databaseFile.writeAsString('sqlite fixture');
    payloadFile = File('${temporaryDirectory.path}/payload.jpg');
    await payloadFile.writeAsString('current attachment bytes');
    database = _FakeSourceDatabase();
    opener = _FakeSourceDatabaseOpener(database);
    database.rows = <Map<String, Object?>>[
      <String, Object?>{
        'request_index': 0,
        'source_attachment_rowid': 42,
        'filename': payloadFile.path,
        'mime_type': 'image/jpeg',
      },
    ];
  });

  tearDown(() async {
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'proves exact GUID and ROWID and returns current material evidence',
    () async {
      final reader = SourceDatabaseCurrentMessagesAttachmentSourceReader(
        databasePath: databaseFile.path,
        sourceDatabaseOpener: opener,
      );

      final result = await reader.observeCurrent(archiveKey);

      expect(
        result.condition,
        CurrentMessagesAttachmentSourceCondition.available,
      );
      expect(result.archiveKey, archiveKey);
      expect(result.sourcePath, payloadFile.path);
      expect(result.mimeType, 'image/jpeg');
      expect(result.fileSizeBytes, await payloadFile.length());
      expect(result.modifiedAtMicrosecondsSinceEpoch, isPositive);
      expect(database.queries, hasLength(1));
      expect(database.queries.single.sql, contains('message_attachment_join'));
      expect(database.queries.single.sql, contains('JOIN message'));
      expect(database.queries.single.sql, contains('attachment.ROWID'));
      expect(database.queries.single.sql, contains('message.guid'));
      expect(database.queries.single.arguments, <Object?>[
        0,
        42,
        'exact-message-guid',
      ]);
      expect(database.closed, isTrue);
    },
  );

  test('classifies a missing exact GUID and ROWID pair as absent', () async {
    database.rows = <Map<String, Object?>>[
      <String, Object?>{
        'request_index': 0,
        'source_attachment_rowid': null,
        'filename': null,
        'mime_type': null,
      },
    ];
    final reader = SourceDatabaseCurrentMessagesAttachmentSourceReader(
      databasePath: databaseFile.path,
      sourceDatabaseOpener: opener,
    );

    final result = await reader.observeCurrent(archiveKey);

    expect(result.condition, CurrentMessagesAttachmentSourceCondition.absent);
    expect(database.queries.single.arguments, <Object?>[
      0,
      42,
      'exact-message-guid',
    ]);
    expect(database.closed, isTrue);
  });

  test('classifies missing path or payload as absent', () async {
    database.rows = <Map<String, Object?>>[
      <String, Object?>{
        'request_index': 0,
        'source_attachment_rowid': 42,
        'filename': '   ',
        'mime_type': 'image/jpeg',
      },
    ];
    final reader = SourceDatabaseCurrentMessagesAttachmentSourceReader(
      databasePath: databaseFile.path,
      sourceDatabaseOpener: opener,
    );

    expect(
      (await reader.observeCurrent(archiveKey)).condition,
      CurrentMessagesAttachmentSourceCondition.absent,
    );

    database.rows = <Map<String, Object?>>[
      <String, Object?>{
        'request_index': 0,
        'source_attachment_rowid': 42,
        'filename': '${temporaryDirectory.path}/missing.jpg',
        'mime_type': 'image/jpeg',
      },
    ];
    expect(
      (await reader.observeCurrent(archiveKey)).condition,
      CurrentMessagesAttachmentSourceCondition.absent,
    );
  });

  test('keeps missing MIME and non-regular payloads inconclusive', () async {
    database.rows = <Map<String, Object?>>[
      <String, Object?>{
        'request_index': 0,
        'source_attachment_rowid': 42,
        'filename': payloadFile.path,
        'mime_type': ' ',
      },
    ];
    final missingMimeReader =
        SourceDatabaseCurrentMessagesAttachmentSourceReader(
          databasePath: databaseFile.path,
          sourceDatabaseOpener: opener,
        );
    expect(
      (await missingMimeReader.observeCurrent(archiveKey)).condition,
      CurrentMessagesAttachmentSourceCondition.unknown,
    );

    database.rows = <Map<String, Object?>>[
      <String, Object?>{
        'request_index': 0,
        'source_attachment_rowid': 42,
        'filename': payloadFile.path,
        'mime_type': 'image/jpeg',
      },
    ];
    final linkReader = SourceDatabaseCurrentMessagesAttachmentSourceReader(
      databasePath: databaseFile.path,
      sourceDatabaseOpener: opener,
      entityTypeReader: (_, {followLinks = true}) async =>
          FileSystemEntityType.link,
    );
    expect(
      (await linkReader.observeCurrent(archiveKey)).condition,
      CurrentMessagesAttachmentSourceCondition.unknown,
    );
  });

  test(
    'keeps installer-incompatible source extensions out of automatic work',
    () async {
      final unsafePayload = File(
        '${temporaryDirectory.path}/payload.too-long-for-archive',
      );
      await unsafePayload.writeAsString('current attachment bytes');
      database.rows = <Map<String, Object?>>[
        <String, Object?>{
          'request_index': 0,
          'source_attachment_rowid': 42,
          'filename': unsafePayload.path,
          'mime_type': 'application/octet-stream',
        },
      ];
      final reader = SourceDatabaseCurrentMessagesAttachmentSourceReader(
        databasePath: databaseFile.path,
        sourceDatabaseOpener: opener,
      );

      final result = await reader.observeCurrent(archiveKey);

      expect(
        result.condition,
        CurrentMessagesAttachmentSourceCondition.unknown,
      );
      expect(result.issue, contains('cannot be represented safely'));
    },
  );

  test('distinguishes unreadable payload from absent and unknown', () async {
    final reader = SourceDatabaseCurrentMessagesAttachmentSourceReader(
      databasePath: databaseFile.path,
      sourceDatabaseOpener: opener,
      readabilityVerifier: (_) async {
        throw const FileSystemException(
          'Permission denied',
          null,
          OSError('Permission denied', 13),
        );
      },
    );

    final result = await reader.observeCurrent(archiveKey);

    expect(
      result.condition,
      CurrentMessagesAttachmentSourceCondition.unreadable,
    );
  });

  test('classifies unavailable source database separately', () async {
    await databaseFile.delete();
    final reader = SourceDatabaseCurrentMessagesAttachmentSourceReader(
      databasePath: databaseFile.path,
      sourceDatabaseOpener: opener,
    );

    final absentDatabase = await reader.observeCurrent(archiveKey);

    expect(
      absentDatabase.condition,
      CurrentMessagesAttachmentSourceCondition.sourceUnavailable,
    );
    expect(opener.openedPaths, isEmpty);

    await databaseFile.writeAsString('sqlite fixture');
    opener.openError = const FileSystemException(
      'Operation not permitted',
      null,
      OSError('Operation not permitted', 1),
    );
    final deniedDatabase = await reader.observeCurrent(archiveKey);
    expect(
      deniedDatabase.condition,
      CurrentMessagesAttachmentSourceCondition.sourceUnavailable,
    );
  });

  test('classifies inconclusive query failures globally and closes', () async {
    database.queryError = StateError('simulated schema mismatch');
    final reader = SourceDatabaseCurrentMessagesAttachmentSourceReader(
      databasePath: databaseFile.path,
      sourceDatabaseOpener: opener,
    );

    final result = await reader.observeCurrent(archiveKey);

    expect(
      result.condition,
      CurrentMessagesAttachmentSourceCondition.sourceInconclusive,
    );
    expect(database.closed, isTrue);
  });

  test('classifies database permission errors as source unavailable', () async {
    opener.openError = _FakeDatabaseException(
      'open_failed: operation not permitted',
      resultCode: 14,
    );
    final reader = SourceDatabaseCurrentMessagesAttachmentSourceReader(
      databasePath: databaseFile.path,
      sourceDatabaseOpener: opener,
    );

    expect(
      (await reader.observeCurrent(archiveKey)).condition,
      CurrentMessagesAttachmentSourceCondition.sourceUnavailable,
    );

    opener.openError = null;
    database.queryError = _FakeDatabaseException(
      'not authorized',
      resultCode: 23,
    );
    expect(
      (await reader.observeCurrent(archiveKey)).condition,
      CurrentMessagesAttachmentSourceCondition.sourceUnavailable,
    );
    expect(database.closed, isTrue);
  });

  test(
    'keeps genuine database schema uncertainty globally inconclusive',
    () async {
      database.queryError = _FakeDatabaseException(
        'no such table: attachment',
        resultCode: 1,
      );
      final reader = SourceDatabaseCurrentMessagesAttachmentSourceReader(
        databasePath: databaseFile.path,
        sourceDatabaseOpener: opener,
      );

      final result = await reader.observeCurrent(archiveKey);

      expect(
        result.condition,
        CurrentMessagesAttachmentSourceCondition.sourceInconclusive,
      );
      expect(database.closed, isTrue);
    },
  );

  test(
    'observes a bounded page in one database session and input order',
    () async {
      const secondKey = ArchiveCompatibilityKey(
        messageGuid: 'second-message-guid',
        importAttachmentId: 43,
      );
      final secondPayload = File('${temporaryDirectory.path}/second.bin');
      await secondPayload.writeAsString('second current attachment');
      database.rows = <Map<String, Object?>>[
        <String, Object?>{
          'request_index': 0,
          'source_attachment_rowid': 42,
          'filename': payloadFile.path,
          'mime_type': 'image/jpeg',
        },
        <String, Object?>{
          'request_index': 1,
          'source_attachment_rowid': 43,
          'filename': secondPayload.path,
          'mime_type': 'application/octet-stream',
        },
      ];
      var activeReadabilityChecks = 0;
      var maximumActiveReadabilityChecks = 0;
      final reader = SourceDatabaseCurrentMessagesAttachmentSourceReader(
        databasePath: databaseFile.path,
        sourceDatabaseOpener: opener,
        readabilityVerifier: (path) async {
          activeReadabilityChecks += 1;
          if (activeReadabilityChecks > maximumActiveReadabilityChecks) {
            maximumActiveReadabilityChecks = activeReadabilityChecks;
          }
          await Future<void>.delayed(Duration.zero);
          activeReadabilityChecks -= 1;
        },
      );

      final results = await reader.observeCurrentPage(<ArchiveCompatibilityKey>[
        archiveKey,
        secondKey,
      ]);

      expect(
        results.map((result) => result.archiveKey),
        <ArchiveCompatibilityKey>[archiveKey, secondKey],
      );
      expect(
        results.map((result) => result.condition),
        everyElement(CurrentMessagesAttachmentSourceCondition.available),
      );
      expect(opener.openedPaths, <String>[databaseFile.path]);
      expect(database.queries, hasLength(1));
      expect(database.queries.single.arguments, <Object?>[
        0,
        42,
        'exact-message-guid',
        1,
        43,
        'second-message-guid',
      ]);
      expect(maximumActiveReadabilityChecks, 1);
    },
  );

  test('rejects source pages larger than the bounded limit', () async {
    final reader = SourceDatabaseCurrentMessagesAttachmentSourceReader(
      databasePath: databaseFile.path,
      sourceDatabaseOpener: opener,
    );
    final keys = List<ArchiveCompatibilityKey>.generate(
      currentMessagesAttachmentSourceObservationPageLimit + 1,
      (index) => ArchiveCompatibilityKey(
        messageGuid: 'message-$index',
        importAttachmentId: index + 1,
      ),
    );

    await expectLater(reader.observeCurrentPage(keys), throwsArgumentError);
    expect(opener.openedPaths, isEmpty);
  });

  test('expands home only from the current source row', () async {
    final homeDirectory = Directory('${temporaryDirectory.path}/home');
    await homeDirectory.create();
    final homePayload = File('${homeDirectory.path}/attachment.bin');
    await homePayload.writeAsString('home bytes');
    database.rows = <Map<String, Object?>>[
      <String, Object?>{
        'request_index': 0,
        'source_attachment_rowid': 42,
        'filename': '~/attachment.bin',
        'mime_type': 'application/octet-stream',
      },
    ];
    final reader = SourceDatabaseCurrentMessagesAttachmentSourceReader(
      databasePath: databaseFile.path,
      sourceDatabaseOpener: opener,
      homeDirectory: homeDirectory.path,
    );

    final result = await reader.observeCurrent(archiveKey);

    expect(
      result.condition,
      CurrentMessagesAttachmentSourceCondition.available,
    );
    expect(result.sourcePath, homePayload.path);
  });
}

final class _FakeSourceDatabaseOpener implements SourceDatabaseOpener {
  _FakeSourceDatabaseOpener(this.database);

  final _FakeSourceDatabase database;
  final openedPaths = <String>[];
  Object? openError;

  @override
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath) async {
    openedPaths.add(databasePath);
    final error = openError;
    if (error != null) {
      throw error;
    }
    return database;
  }
}

final class _FakeSourceDatabase implements ReadOnlySourceDatabase {
  var rows = <Map<String, Object?>>[];
  final queries = <_QueryCall>[];
  Object? queryError;
  var closed = false;

  @override
  Future<void> close() async {
    closed = true;
  }

  @override
  Future<Set<String>> findExistingMessageGuids(Set<String> targetGuids) {
    throw StateError('Message import is outside this test.');
  }

  @override
  Future<SourceMessageImportWindow> messageImportWindowAfter(int sourceRowId) {
    throw StateError('Message import is outside this test.');
  }

  @override
  Future<List<Map<String, Object?>>> query(String table, {String? orderBy}) {
    throw StateError('Table query is outside this test.');
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    queries.add(_QueryCall(sql, arguments ?? <Object?>[]));
    final error = queryError;
    if (error != null) {
      throw error;
    }
    return rows;
  }

  @override
  Future<List<Map<String, Object?>>> readMessageImportPage({
    required int afterSourceRowId,
    required int throughSourceRowId,
    required int limit,
  }) {
    throw StateError('Message import is outside this test.');
  }
}

final class _QueryCall {
  const _QueryCall(this.sql, this.arguments);

  final String sql;
  final List<Object?> arguments;
}

final class _FakeDatabaseException extends DatabaseException {
  _FakeDatabaseException(super.message, {required this.resultCode});

  final int? resultCode;

  @override
  Object? get result => null;

  @override
  int? getResultCode() => resultCode;
}
