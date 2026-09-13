import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDirectory;
  late ImportDatabase database;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'message_text_paging_test_',
    );
    database = await ImportDatabase.open(
      databaseDirectory: tempDirectory.path,
      databaseName: 'import.db',
    );
    await database.database.insert('source_registry', <String, Object?>{
      'source_id': 3,
      'source_key': 'archive-test',
      'source_kind': 'historical_messages_archive',
      'created_at_utc': DateTime.now().toUtc().toIso8601String(),
    });
    for (final sourceId in <int>[liveChatDbSourceId, 3]) {
      final batchId = await database.insertImportBatch(
        sourceId: sourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      for (final sourceRowId in <int>[10, 30, 90]) {
        await database.database.insert('messages', <String, Object?>{
          'ss_id': SourceScopedRowKey.pack(
            sourceId: sourceId,
            sourceRowId: sourceRowId,
          ),
          'source_id': sourceId,
          'source_rowid': sourceRowId,
          'guid': 'message-$sourceId-$sourceRowId',
          'is_from_me': 0,
          'text': null,
          'attributed_body_blob': Uint8List.fromList(<int>[sourceRowId]),
          'batch_id': batchId,
        });
      }
    }
  });

  tearDown(() async {
    await database.close();
    await tempDirectory.delete(recursive: true);
  });

  test('captures count and source-scoped ss_id high-water', () async {
    final window = await database.messageTextEnrichmentWindow();

    expect(window.candidateCount, 6);
    expect(
      window.highWaterSsId,
      SourceScopedRowKey.pack(sourceId: 3, sourceRowId: 90),
    );
  });

  test('reads keyset pages without skipping rows removed by writes', () async {
    final window = await database.messageTextEnrichmentWindow();
    final first = await database.readMessageTextEnrichmentPage(
      afterSsId: 0,
      throughSsId: window.highWaterSsId!,
      limit: 2,
    );
    await database.writeTransaction((txn) async {
      for (final candidate in first) {
        await txn.update(
          'messages',
          <String, Object?>{'text': 'decoded'},
          where: 'ss_id = ?',
          whereArgs: <Object?>[candidate.ssId],
        );
      }
    });
    final second = await database.readMessageTextEnrichmentPage(
      afterSsId: first.last.ssId,
      throughSsId: window.highWaterSsId!,
      limit: 2,
    );

    expect(first.map((candidate) => candidate.sourceRowId), <int>[10, 30]);
    expect(second.map((candidate) => candidate.sourceRowId), <int>[90, 10]);
    expect(second.first.ssId, greaterThan(first.last.ssId));
  });

  test('honors source and started-after filters in count and pages', () async {
    final window = await database.messageTextEnrichmentWindow(
      sourceId: 3,
      startedAfterSourceRowId: 10,
    );
    final page = await database.readMessageTextEnrichmentPage(
      afterSsId: 0,
      throughSsId: window.highWaterSsId!,
      limit: 10,
      sourceId: 3,
      startedAfterSourceRowId: 10,
    );

    expect(window.candidateCount, 2);
    expect(page.map((candidate) => candidate.sourceRowId), <int>[30, 90]);
    expect(
      page.map(
        (candidate) => SourceScopedRowKey.unpackSourceId(candidate.ssId),
      ),
      everyElement(3),
    );
  });
}
