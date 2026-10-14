import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'production_graph_replay_harness.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('empty graph receives the bounded source-scoped fixture', () async {
    await _withHarness((harness) async {
      expect(harness.openedPaths, everyElement(startsWith(harness.root.path)));
      expect(
        harness.openedPaths,
        everyElement(isNot(contains('/Library/Messages'))),
      );
      await harness.seedCanonicalFixture();
      expect(harness.duplicateChatMessageInsertCount, 0);
      expect(harness.duplicateMessageAttachmentInsertCount, 0);

      final empty = await harness.snapshot();
      expect(empty.values.expand((rows) => rows), isEmpty);

      await harness.replayFull();
      final projected = await harness.snapshot();
      expect(projected['messages'], hasLength(6));
      expect(projected['handles'], hasLength(5));
      expect(projected['contacts'], hasLength(2));
      expect(projected['chats'], hasLength(3));
      expect(projected['attachments'], hasLength(3));
      expect(projected['chat_to_message'], hasLength(6));
      expect(projected['message_to_attachment'], hasLength(3));
    });
  });

  test('repeated full replay is materially idempotent', () async {
    await _withHarness((harness) async {
      await harness.seedCanonicalFixture();
      await harness.replayFull();
      final first = await harness.snapshot();
      await harness.replayFull();
      final second = await harness.snapshot();
      _expectSnapshotsEqual(second, first);
    });
  });

  test(
    'stale contact, chat, and extra edges literally do not converge',
    () async {
      await _withHarness((harness) async {
        await harness.seedCanonicalFixture();
        await harness.replayFull();
        await harness.makeGraphDeliberatelyStale();
        final stale = await harness.snapshot();

        await harness.replayFull();
        final replayed = await harness.snapshot();
        _expectSnapshotsEqual(replayed, stale);
        expect(
          replayed['contacts'],
          contains(
            predicate<Map<String, Object?>>(
              (row) => row['display_name'] == 'Stale Contact Name',
            ),
          ),
        );
        expect(
          replayed['chats'],
          contains(
            allOf(
              containsPair('ss_id', harness.ss(1, 30)),
              containsPair('is_group', 0),
            ),
          ),
        );
        expect(replayed['chat_to_message'], hasLength(7));
        expect(replayed['message_to_attachment'], hasLength(4));
      });
    },
  );

  test(
    'supported incremental entry points match a subsequent full replay',
    () async {
      late GraphMaterialSnapshot fullSnapshot;
      await _withHarness((harness) async {
        await harness.seedCanonicalFixture();
        await harness.replayFull();
        await harness.addIncrementalLiveFacts();
        await harness.replayFull();
        fullSnapshot = await harness.snapshot();
      });
      await _withHarness((harness) async {
        await harness.seedCanonicalFixture();
        await harness.replayFull();
        await harness.addIncrementalLiveFacts();
        await harness.replayIncrementalLive();
        _expectSnapshotsEqual(await harness.snapshot(), fullSnapshot);
      });
    },
  );

  test(
    'historical removal and reprojection retain registry identity',
    () async {
      await _withHarness((harness) async {
        await harness.seedCanonicalFixture();
        await harness.replayFull();
        final before = await harness.snapshot();
        final registryBefore = await harness.sourceRegistryRows();

        final result = await harness.removeHistoricalSource();
        expect(result.sourceId, harness.historicalSourceId);
        expect(result.graphReprojected, isTrue);
        expect(await harness.sourceRegistryRows(), registryBefore);
        final removed = await harness.snapshot();
        expect(
          removed['handles'],
          isNot(
            contains(
              containsPair('ss_id', harness.ss(harness.historicalSourceId, 10)),
            ),
          ),
        );
        expect(
          removed['chats'],
          isNot(
            contains(
              containsPair('ss_id', harness.ss(harness.historicalSourceId, 30)),
            ),
          ),
        );
        expect(
          removed['messages'],
          isNot(
            contains(
              containsPair('ss_id', harness.ss(harness.historicalSourceId, 40)),
            ),
          ),
        );
        expect(
          removed['attachments'],
          isNot(
            contains(
              containsPair('ss_id', harness.ss(harness.historicalSourceId, 50)),
            ),
          ),
        );
        expect(
          removed['chat_to_handle'],
          isNot(
            contains(
              containsPair(
                'chat_ss_id',
                harness.ss(harness.historicalSourceId, 30),
              ),
            ),
          ),
        );
        expect(
          removed['chat_to_message'],
          isNot(
            contains(
              containsPair(
                'message_ss_id',
                harness.ss(harness.historicalSourceId, 40),
              ),
            ),
          ),
        );
        expect(
          removed['message_to_attachment'],
          isNot(
            contains(
              containsPair(
                'attachment_ss_id',
                harness.ss(harness.historicalSourceId, 50),
              ),
            ),
          ),
        );

        await harness.seedHistoricalFacts();
        await harness.replayFull();
        _expectSnapshotsEqual(await harness.snapshot(), before);
        expect(await harness.sourceRegistryRows(), registryBefore);
      });
    },
  );

  test(
    'aliases, references, semantics, and FTS follow production writers',
    () async {
      await _withHarness((harness) async {
        await harness.seedCanonicalFixture();
        await harness.replayFull();
        final snapshot = await harness.snapshot();
        final liveTarget = harness.ss(1, 40);
        final canonicalPhone = harness.ss(1, 10);

        expect(
          snapshot['chats']!.singleWhere(
            (row) => row['ss_id'] == harness.ss(1, 30),
          )['is_group'],
          1,
        );
        expect(
          snapshot['chats']!.singleWhere(
            (row) => row['ss_id'] == harness.ss(1, 31),
          )['is_group'],
          0,
        );
        expect(
          snapshot['handles']!.singleWhere(
            (row) => row['ss_id'] == harness.ss(1, 13),
          )['is_me'],
          1,
        );

        expect(snapshot['handle_aliases'], hasLength(4));
        expect(
          snapshot['handle_aliases'],
          containsAll(<Matcher>[
            containsPair('handle_ss_id', harness.ss(1, 10)),
            containsPair('handle_ss_id', harness.ss(1, 11)),
          ]),
        );
        expect(
          snapshot['handle_aliases'],
          isNot(contains(containsPair('handle_ss_id', harness.ss(1, 12)))),
        );
        expect(snapshot['contact_to_handle'], hasLength(2));
        expect(
          snapshot['contact_to_handle'],
          everyElement(containsPair('handle_ss_id', canonicalPhone)),
        );
        final associated = snapshot['messages']!.singleWhere(
          (row) => row['ss_id'] == harness.ss(1, 42),
        );
        final missing = snapshot['messages']!.singleWhere(
          (row) => row['ss_id'] == harness.ss(1, 43),
        );
        final richText = snapshot['messages']!.singleWhere(
          (row) => row['ss_id'] == harness.ss(1, 41),
        );
        final nullText = snapshot['messages']!.singleWhere(
          (row) => row['ss_id'] == harness.ss(1, 44),
        );
        expect(richText['semantic_kind'], 'rich_text');
        expect(richText['item_kind'], 'text');
        expect(richText['has_attributed_body_source'], 1);
        expect(richText['is_sparse_artifact'], 0);
        expect(associated['semantic_kind'], 'associated');
        expect(associated['item_kind'], 'associated');
        expect(associated['associated_message_ss_id'], liveTarget);
        expect(missing['semantic_kind'], 'associated');
        expect(missing['item_kind'], 'associated');
        expect(missing['associated_message_ss_id'], isNull);
        expect(nullText['semantic_kind'], 'sparse_artifact');
        expect(nullText['item_kind'], 'unknown');
        expect(nullText['is_sparse_artifact'], 1);
        expect(nullText['has_attributed_body_source'], 0);
        expect(
          snapshot['messages']!.singleWhere(
            (row) => row['ss_id'] == liveTarget,
          )['sender_canonical_handle_ss_id'],
          canonicalPhone,
        );

        expect(await harness.searchMessageIds('café'), contains(liveTarget));
        expect(await harness.searchMessageIds('CAFE'), contains(liveTarget));
        expect(await harness.searchMessageIds('"co-op"'), contains(liveTarget));
        expect(await harness.searchMessageIds('ca*'), contains(liveTarget));
        expect(await harness.searchMessageIds('caf*'), contains(liveTarget));
        expect(await harness.searchMessageIds('café*'), contains(liveTarget));
        expect(
          await harness.searchMessageIds('Καλημέρα'),
          contains(harness.ss(1, 41)),
        );
        expect(
          await harness.searchMessageIds('"live-null-text"'),
          isNot(contains(harness.ss(1, 44))),
        );

        await harness.updateLiveMessageText(
          sourceRowId: 40,
          text: 'replacement token',
        );
        await harness.replayFull();
        expect(
          await harness.searchMessageIds('café'),
          isNot(contains(liveTarget)),
        );
        expect(
          await harness.searchMessageIds('replacement'),
          contains(liveTarget),
        );
      });
    },
  );

  test(
    'source registry identity changes packed historical graph identity',
    () async {
      late GraphMaterialSnapshot sourceThreeSnapshot;
      late int sourceThreeMessageId;
      await _withHarness((harness) async {
        await harness.seedCanonicalFixture();
        await harness.replayFull();
        sourceThreeSnapshot = await harness.snapshot();
        sourceThreeMessageId = harness.ss(3, 40);
        expect(
          sourceThreeSnapshot['messages'],
          contains(containsPair('ss_id', sourceThreeMessageId)),
        );
      });
      await _withHarness((harness) async {
        await harness.seedCanonicalFixture();
        await harness.replayFull();
        final sourceFourSnapshot = await harness.snapshot();
        expect(
          _snapshotDifference(sourceFourSnapshot, sourceThreeSnapshot),
          contains('messages: missing keys'),
        );
        expect(
          sourceFourSnapshot['messages'],
          contains(containsPair('ss_id', harness.ss(4, 40))),
        );
        expect(
          sourceFourSnapshot['messages'],
          isNot(contains(containsPair('ss_id', sourceThreeMessageId))),
        );
      }, historicalSourceId: 4);
    },
  );

  test(
    'writer-stage failure exposes partial commits and cleanup is bounded',
    () async {
      final harness = await ProductionGraphReplayHarness.open();
      final rootPath = harness.root.path;
      try {
        await harness.seedCanonicalFixture();
        await expectLater(
          harness.replayFull(stopAfter: GraphReplayStage.messages),
          throwsA(
            isA<GraphReplayInterrupted>().having(
              (error) => error.completedStage,
              'completedStage',
              GraphReplayStage.messages,
            ),
          ),
        );
        final partial = await harness.snapshot();
        expect(partial['handles'], isNotEmpty);
        expect(partial['contacts'], isNotEmpty);
        expect(partial['chats'], isNotEmpty);
        expect(partial['messages'], isNotEmpty);
        expect(partial['attachments'], isEmpty);
        expect(partial['chat_to_message'], isEmpty);
        expect(partial['message_to_attachment'], isEmpty);
      } finally {
        await harness.dispose();
      }
      expect(Directory(rootPath).existsSync(), isFalse);
    },
  );
}

Future<void> _withHarness(
  Future<void> Function(ProductionGraphReplayHarness harness) body, {
  int historicalSourceId = 3,
}) async {
  final harness = await ProductionGraphReplayHarness.open(
    historicalSourceId: historicalSourceId,
  );
  final rootPath = harness.root.path;
  try {
    await body(harness);
  } finally {
    await harness.dispose();
  }
  expect(Directory(rootPath).existsSync(), isFalse);
}

void _expectSnapshotsEqual(
  GraphMaterialSnapshot actual,
  GraphMaterialSnapshot expected,
) {
  final difference = _snapshotDifference(actual, expected);
  expect(difference, isEmpty, reason: difference);
}

String _snapshotDifference(
  GraphMaterialSnapshot actual,
  GraphMaterialSnapshot expected,
) {
  final differences = <String>[];
  final tableNames = <String>{...actual.keys, ...expected.keys}.toList()
    ..sort();
  for (final tableName in tableNames) {
    final actualRows = _rowsByKey(tableName, actual[tableName] ?? const []);
    final expectedRows = _rowsByKey(tableName, expected[tableName] ?? const []);
    final missingKeys = expectedRows.keys.toSet().difference(
      actualRows.keys.toSet(),
    );
    final extraKeys = actualRows.keys.toSet().difference(
      expectedRows.keys.toSet(),
    );
    final changedKeys = actualRows.keys.toSet().intersection(
      expectedRows.keys.toSet(),
    )..removeWhere((key) => actualRows[key] == expectedRows[key]);
    if (missingKeys.isNotEmpty) {
      differences.add(
        '$tableName: missing keys ${missingKeys.toList()..sort()}',
      );
    }
    if (extraKeys.isNotEmpty) {
      differences.add('$tableName: extra keys ${extraKeys.toList()..sort()}');
    }
    for (final key in changedKeys.toList()..sort()) {
      differences.add(
        '$tableName: changed $key\n'
        '  expected ${expectedRows[key]}\n'
        '  actual   ${actualRows[key]}',
      );
    }
  }
  return differences.join('\n');
}

Map<String, String> _rowsByKey(
  String tableName,
  List<Map<String, Object?>> rows,
) {
  return <String, String>{
    for (final row in rows) _materialKey(tableName, row): _stableJson(row),
  };
}

String _materialKey(String tableName, Map<String, Object?> row) {
  return switch (tableName) {
    'messages' || 'handles' || 'chats' || 'attachments' => '${row['ss_id']}',
    'message_text_fts' => '${row['rowid']}',
    'canonical_handles' => '${row['canonical_handle_ss_id']}',
    'handle_aliases' => '${row['handle_ss_id']}',
    'contacts' => '${row['contact_id']}',
    'chat_to_message' => '${row['chat_ss_id']}:${row['message_ss_id']}',
    'chat_to_handle' => '${row['chat_ss_id']}:${row['handle_ss_id']}',
    'contact_to_handle' => '${row['contact_id']}:${row['handle_ss_id']}',
    'message_to_attachment' =>
      '${row['message_ss_id']}:${row['attachment_ss_id']}',
    _ => throw StateError('No material key for $tableName'),
  };
}

String _stableJson(Map<String, Object?> row) {
  final keys = row.keys.toList()..sort();
  return jsonEncode(<String, Object?>{for (final key in keys) key: row[key]});
}
