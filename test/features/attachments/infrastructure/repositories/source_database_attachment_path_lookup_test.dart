import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/source_database_port.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/source_database_attachment_path_lookup.dart';

void main() {
  late Directory tempDir;
  late File databaseFile;
  late _FakeSourceDatabase sourceDatabase;
  late _FakeSourceDatabaseOpener opener;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'source_database_attachment_path_lookup_test_',
    );
    databaseFile = File('${tempDir.path}/chat.db');
    sourceDatabase = _FakeSourceDatabase();
    opener = _FakeSourceDatabaseOpener(sourceDatabase);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('returns null without opening when source database is absent', () async {
    final lookup = SourceDatabaseAttachmentPathLookup(
      databasePath: databaseFile.path,
      sourceDatabaseOpener: opener,
    );

    final path = await lookup.attachmentPathForSourceRowId(200);

    expect(path, isNull);
    expect(opener.openedPaths, isEmpty);
    expect(sourceDatabase.closed, isFalse);
  });

  test('returns null when source attachment row is missing', () async {
    await databaseFile.writeAsString('sqlite');
    sourceDatabase.rows = <Map<String, Object?>>[];
    final lookup = SourceDatabaseAttachmentPathLookup(
      databasePath: databaseFile.path,
      sourceDatabaseOpener: opener,
    );

    final path = await lookup.attachmentPathForSourceRowId(200);

    expect(path, isNull);
    expect(opener.openedPaths, <String>[databaseFile.path]);
    expect(sourceDatabase.closed, isTrue);
  });

  test('normalizes null and blank filenames to null', () async {
    await databaseFile.writeAsString('sqlite');
    final lookup = SourceDatabaseAttachmentPathLookup(
      databasePath: databaseFile.path,
      sourceDatabaseOpener: opener,
    );

    sourceDatabase.rows = <Map<String, Object?>>[
      <String, Object?>{'filename': null},
    ];
    expect(await lookup.attachmentPathForSourceRowId(200), isNull);

    sourceDatabase.closed = false;
    sourceDatabase.rows = <Map<String, Object?>>[
      <String, Object?>{'filename': '   '},
    ];
    expect(await lookup.attachmentPathForSourceRowId(201), isNull);
    expect(sourceDatabase.closed, isTrue);
  });

  test('returns trimmed attachment filename', () async {
    await databaseFile.writeAsString('sqlite');
    sourceDatabase.rows = <Map<String, Object?>>[
      <String, Object?>{
        'filename': ' ~/Library/Messages/Attachments/photo.jpg ',
      },
    ];
    final lookup = SourceDatabaseAttachmentPathLookup(
      databasePath: databaseFile.path,
      sourceDatabaseOpener: opener,
    );

    final path = await lookup.attachmentPathForSourceRowId(200);

    expect(path, '~/Library/Messages/Attachments/photo.jpg');
    expect(sourceDatabase.queries.single.arguments, <Object?>[200]);
    expect(sourceDatabase.closed, isTrue);
  });
}

final class _FakeSourceDatabaseOpener implements SourceDatabaseOpener {
  _FakeSourceDatabaseOpener(this.database);

  final _FakeSourceDatabase database;
  final openedPaths = <String>[];

  @override
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath) async {
    openedPaths.add(databasePath);
    return database;
  }
}

final class _FakeSourceDatabase implements ReadOnlySourceDatabase {
  var rows = <Map<String, Object?>>[];
  var closed = false;
  final queries = <_QueryCall>[];

  @override
  Future<void> close() async {
    closed = true;
  }

  @override
  Future<List<Map<String, Object?>>> query(String table, {String? orderBy}) {
    throw StateError('query should not be used by this test');
  }

  @override
  Future<SourceMessageImportWindow> messageImportWindowAfter(int sourceRowId) {
    throw StateError('message import should not be used by this test');
  }

  @override
  Future<List<Map<String, Object?>>> readMessageImportPage({
    required int afterSourceRowId,
    required int throughSourceRowId,
    required int limit,
  }) {
    throw StateError('message import should not be used by this test');
  }

  @override
  Future<Set<String>> findExistingMessageGuids(Set<String> targetGuids) {
    throw StateError('message import should not be used by this test');
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    queries.add(_QueryCall(sql, arguments ?? <Object?>[]));
    return rows;
  }
}

final class _QueryCall {
  const _QueryCall(this.sql, this.arguments);

  final String sql;
  final List<Object?> arguments;
}
