import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/source_database_port.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database_current_messages_coverage_reader.dart';

void main() {
  test('uses every physical message ROWID as the denominator', () async {
    final database = _FakeSourceDatabase();
    final reader = SourceDatabaseCurrentMessagesCoverageReader(
      sourceDatabaseOpener: _FakeSourceDatabaseOpener(database),
    );

    final evidence = await reader.read(databasePath: '/source/chat.db');

    expect(evidence.sourceRowIds, <int>{1, 2, 9});
    expect(evidence.totalRowCount, 3);
    expect(database.closed, isTrue);
    expect(database.sql.single, contains('SELECT ROWID AS source_rowid'));
    expect(database.sql.single, isNot(contains('DISTINCT')));
  });

  test('rejects duplicate or invalid physical row identity', () async {
    final duplicate = _FakeSourceDatabase(
      identityRows: const <Map<String, Object?>>[
        <String, Object?>{'source_rowid': 1},
        <String, Object?>{'source_rowid': 1},
      ],
    );
    final reader = SourceDatabaseCurrentMessagesCoverageReader(
      sourceDatabaseOpener: _FakeSourceDatabaseOpener(duplicate),
    );

    await expectLater(
      reader.read(databasePath: '/source/chat.db'),
      throwsStateError,
    );
    expect(duplicate.closed, isTrue);
  });
}

final class _FakeSourceDatabaseOpener implements SourceDatabaseOpener {
  const _FakeSourceDatabaseOpener(this.database);

  final ReadOnlySourceDatabase database;

  @override
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath) async {
    return database;
  }
}

final class _FakeSourceDatabase implements ReadOnlySourceDatabase {
  _FakeSourceDatabase({
    this.identityRows = const <Map<String, Object?>>[
      <String, Object?>{'source_rowid': 1},
      <String, Object?>{'source_rowid': 2},
      <String, Object?>{'source_rowid': 9},
    ],
  });

  final List<Map<String, Object?>> identityRows;
  final sql = <String>[];
  var closed = false;

  @override
  Future<void> close() async {
    closed = true;
  }

  @override
  Future<List<Map<String, Object?>>> query(String table, {String? orderBy}) {
    throw StateError('query is not used');
  }

  @override
  Future<SourceMessageImportWindow> messageImportWindowAfter(int sourceRowId) {
    throw StateError('message import is not used');
  }

  @override
  Future<List<Map<String, Object?>>> readMessageImportPage({
    required int afterSourceRowId,
    required int throughSourceRowId,
    required int limit,
  }) {
    throw StateError('message import is not used');
  }

  @override
  Future<Set<String>> findExistingMessageGuids(Set<String> targetGuids) {
    throw StateError('message import is not used');
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String statement, [
    List<Object?>? arguments,
  ]) async {
    if (statement.contains('SELECT ROWID AS source_rowid')) {
      sql.add(statement);
      return identityRows;
    }
    return const <Map<String, Object?>>[
      <String, Object?>{'first_date': null, 'last_date': null},
    ];
  }
}
