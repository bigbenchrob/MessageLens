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

  group('material graph schema inventory and comparator', () {
    test('inventories every production material table and column', () async {
      await _withHarness((harness) async {
        expect(graphMaterialTableSpecs, hasLength(11));
        expect(
          graphMaterialTableSpecs.map((spec) => spec.name),
          isNot(contains('message_text_fts')),
        );

        for (final spec in graphMaterialTableSpecs) {
          final tableInfo = await harness.graphTableInfo(spec.name);
          expect(
            tableInfo.map((row) => row['name']).toList(),
            spec.columnNames,
            reason: '${spec.name} column inventory changed',
          );
          for (var index = 0; index < spec.columns.length; index += 1) {
            final actual = tableInfo[index];
            final expected = spec.columns[index];
            expect(
              actual['type'],
              expected.sqliteType,
              reason: '${spec.name}.${expected.name} SQLite type changed',
            );
            expect(
              actual['notnull'],
              expected.pragmaNotNull ? 1 : 0,
              reason: '${spec.name}.${expected.name} nullability changed',
            );
            expect(
              actual['pk'],
              expected.primaryKeyPosition,
              reason: '${spec.name}.${expected.name} primary key changed',
            );
          }

          if (spec.identityConstraint ==
              GraphMaterialIdentityConstraint.unique) {
            expect(
              await harness.graphUniqueIndexes(spec.name),
              contains(equals(spec.identityColumns)),
              reason: '${spec.name} material identity constraint changed',
            );
          }
        }
      });
    });

    test('equal independently allocated rows have no differences', () {
      final expected = <String, List<Map<String, Object?>>>{
        'messages': <Map<String, Object?>>[
          <String, Object?>{'ss_id': 1, 'text': null},
        ],
      };
      final observed = <String, List<Map<String, Object?>>>{
        'messages': <Map<String, Object?>>[
          <String, Object?>{'text': null, 'ss_id': 1},
        ],
      };

      expect(
        compareGraphMaterialSnapshots(
          expected: expected,
          observed: observed,
        ).isEqual,
        isTrue,
      );
    });

    test('missing and extra rows are expected-to-observed directional', () {
      final expected = <String, List<Map<String, Object?>>>{
        'messages': <Map<String, Object?>>[
          <String, Object?>{'ss_id': 1, 'text': 'expected'},
        ],
      };
      final observed = <String, List<Map<String, Object?>>>{
        'messages': <Map<String, Object?>>[
          <String, Object?>{'ss_id': 2, 'text': 'observed'},
        ],
      };

      final comparison = compareGraphMaterialSnapshots(
        expected: expected,
        observed: observed,
      );
      expect(
        comparison.description,
        contains(
          'messages key{ss_id=1}: expected row missing from observed snapshot',
        ),
      );
      expect(
        comparison.description,
        contains('messages key{ss_id=2}: extra observed row'),
      );
    });

    test('changed fields distinguish null from absent evidence', () {
      final expected = <String, List<Map<String, Object?>>>{
        'messages': <Map<String, Object?>>[
          <String, Object?>{'ss_id': 1, 'guid': null, 'text': null},
        ],
      };
      final observed = <String, List<Map<String, Object?>>>{
        'messages': <Map<String, Object?>>[
          <String, Object?>{'ss_id': 1, 'text': 'observed'},
        ],
      };

      final comparison = compareGraphMaterialSnapshots(
        expected: expected,
        observed: observed,
      );
      expect(
        comparison.description,
        contains(
          'messages key{ss_id=1} field{guid}: '
          'expected <null>, observed <absent>',
        ),
      );
      expect(
        comparison.description,
        contains(
          'messages key{ss_id=1} field{text}: '
          'expected <null>, observed "observed"',
        ),
      );
    });

    test('diagnostics are deterministic and bounded', () {
      final expected = <String, List<Map<String, Object?>>>{
        'messages': <Map<String, Object?>>[
          for (var id = 1; id <= 5; id += 1)
            <String, Object?>{'ss_id': id, 'text': 'expected-$id'},
        ],
      };
      final comparison = compareGraphMaterialSnapshots(
        expected: expected,
        observed: const <String, List<Map<String, Object?>>>{},
        diagnosticLimit: 2,
      );

      expect(comparison.totalDifferenceCount, 5);
      expect(comparison.diagnostics, hasLength(2));
      expect(
        comparison.description,
        endsWith(
          '... 3 additional material difference(s) omitted '
          '(diagnostic limit 2)',
        ),
      );
    });
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

  test('independent production replays are materially equal', () async {
    late GraphMaterialSnapshot expected;
    await _withHarness((harness) async {
      await harness.seedCanonicalFixture();
      await harness.replayFull();
      expected = await harness.snapshot();
    });
    await _withHarness((harness) async {
      await harness.seedCanonicalFixture();
      await harness.replayFull();
      _expectSnapshotsEqual(await harness.snapshot(), expected);
    });
  });

  group('bidirectional material graph anti-differences', () {
    test(
      'reports message nullability, sender, association, and semantic fields',
      () async {
        await _withHarness((harness) async {
          await harness.seedCanonicalFixture();
          await harness.replayFull();
          final expected = await harness.snapshot();
          final targetId = harness.ss(1, 40);
          final associatedId = harness.ss(1, 42);

          await harness.graph.executeSql(
            'UPDATE messages SET text = NULL WHERE ss_id = ?',
            <Object?>[targetId],
          );
          await harness.graph.executeSql(
            'UPDATE messages SET '
            "guid = 'changed-guid', "
            'sender_handle_ss_id = NULL, '
            'is_from_me = 1, '
            'date_utc = NULL, '
            'associated_message_ss_id = NULL, '
            'sender_canonical_handle_ss_id = NULL, '
            "semantic_kind = 'changed-semantic', "
            "item_kind = 'changed-item', "
            'is_system_message = 1, '
            'is_sparse_artifact = 1, '
            'has_attributed_body_source = 1, '
            'has_message_summary_info = 1, '
            'has_payload_data_source = 1, '
            'error_code = 99 '
            'WHERE ss_id = ?',
            <Object?>[associatedId],
          );

          final comparison = compareGraphMaterialSnapshots(
            expected: expected,
            observed: await harness.snapshot(),
          );
          _expectChangedFields(
            comparison,
            tableName: 'messages',
            key: 'key{ss_id=$targetId}',
            fields: const <String>['text'],
          );
          _expectChangedFields(
            comparison,
            tableName: 'messages',
            key: 'key{ss_id=$associatedId}',
            fields: const <String>[
              'guid',
              'sender_handle_ss_id',
              'is_from_me',
              'date_utc',
              'associated_message_ss_id',
              'sender_canonical_handle_ss_id',
              'semantic_kind',
              'item_kind',
              'is_system_message',
              'is_sparse_artifact',
              'has_attributed_body_source',
              'has_message_summary_info',
              'has_payload_data_source',
              'error_code',
            ],
          );
          expect(
            comparison.description,
            contains('expected "Café co-op punctuation", observed <null>'),
          );
        });
      },
    );

    test(
      'reports handle, canonical alias, chat, contact, and attachment fields',
      () async {
        await _withHarness((harness) async {
          await harness.seedCanonicalFixture();
          await harness.replayFull();
          final expected = await harness.snapshot();
          final canonicalId =
              expected['canonical_handles']!.first['canonical_handle_ss_id']!
                  as int;
          final aliasId =
              expected['handle_aliases']!.first['handle_ss_id']! as int;
          final attachmentId = harness.ss(1, 50);

          await harness.graph.executeSql(
            "UPDATE handles SET id = 'changed', service = NULL, is_me = 1 "
            'WHERE ss_id = ?',
            <Object?>[harness.ss(1, 10)],
          );
          await harness.graph.executeSql(
            "UPDATE canonical_handles SET display_handle = 'changed', "
            "normalized_identifier = 'changed', service = NULL, "
            'alias_count = alias_count + 1 '
            'WHERE canonical_handle_ss_id = ?',
            <Object?>[canonicalId],
          );
          await harness.graph.executeSql(
            'UPDATE handle_aliases SET '
            'canonical_handle_ss_id = canonical_handle_ss_id + 1, '
            "raw_identifier = 'changed', "
            "normalized_identifier = 'changed', alias_kind = 'changed' "
            'WHERE handle_ss_id = ?',
            <Object?>[aliasId],
          );
          await harness.graph.executeSql(
            "UPDATE chats SET guid = 'changed', service = NULL, "
            'is_group = 0, last_read_message_at_utc = NULL '
            'WHERE ss_id = ?',
            <Object?>[harness.ss(1, 30)],
          );
          await harness.graph.executeSql(
            "UPDATE contacts SET display_name = 'changed', "
            "given_name = 'changed', family_name = 'changed', "
            "organization = 'changed' WHERE contact_id = ?",
            <Object?>[harness.ss(2, 20)],
          );
          await harness.graph.executeSql(
            "UPDATE contact_to_handle SET handle_value = 'changed' "
            'WHERE contact_id = ?',
            <Object?>[harness.ss(2, 20)],
          );
          await harness.graph.executeSql(
            "UPDATE attachments SET guid = 'changed', filename = NULL, "
            "transfer_name = 'changed', uti = NULL, mime_type = NULL, "
            'total_bytes = NULL, created_at_utc = NULL WHERE ss_id = ?',
            <Object?>[attachmentId],
          );

          final comparison = compareGraphMaterialSnapshots(
            expected: expected,
            observed: await harness.snapshot(),
          );
          for (final entry in <(String, String, List<String>)>[
            (
              'handles',
              'key{ss_id=${harness.ss(1, 10)}}',
              <String>['id', 'service', 'is_me'],
            ),
            (
              'canonical_handles',
              'key{canonical_handle_ss_id=$canonicalId}',
              <String>[
                'display_handle',
                'normalized_identifier',
                'service',
                'alias_count',
              ],
            ),
            (
              'handle_aliases',
              'key{handle_ss_id=$aliasId}',
              <String>[
                'canonical_handle_ss_id',
                'raw_identifier',
                'normalized_identifier',
                'alias_kind',
              ],
            ),
            (
              'chats',
              'key{ss_id=${harness.ss(1, 30)}}',
              <String>[
                'guid',
                'service',
                'is_group',
                'last_read_message_at_utc',
              ],
            ),
            (
              'contacts',
              'key{contact_id=${harness.ss(2, 20)}}',
              <String>[
                'display_name',
                'given_name',
                'family_name',
                'organization',
              ],
            ),
            (
              'contact_to_handle',
              'key{contact_id=${harness.ss(2, 20)},'
                  'handle_ss_id=${harness.ss(1, 10)}}',
              <String>['handle_value'],
            ),
            (
              'attachments',
              'key{ss_id=$attachmentId}',
              <String>[
                'guid',
                'filename',
                'transfer_name',
                'uti',
                'mime_type',
                'total_bytes',
                'created_at_utc',
              ],
            ),
          ]) {
            _expectChangedFields(
              comparison,
              tableName: entry.$1,
              key: entry.$2,
              fields: entry.$3,
            );
          }
        });
      },
    );

    test('reports missing and extra rows for every relationship table', () async {
      await _withHarness((harness) async {
        await harness.seedCanonicalFixture();
        await harness.replayFull();
        final expected = await harness.snapshot();
        final chat30 = harness.ss(1, 30);
        final chat31 = harness.ss(1, 31);
        final message40 = harness.ss(1, 40);
        final message41 = harness.ss(1, 41);
        final handle10 = harness.ss(1, 10);
        final handle12 = harness.ss(1, 12);
        final contact20 = harness.ss(2, 20);
        final contact21 = harness.ss(2, 21);
        final attachment50 = harness.ss(1, 50);

        await harness.graph.executeSql(
          'DELETE FROM chat_to_message '
          'WHERE chat_ss_id = ? AND message_ss_id = ?',
          <Object?>[chat30, message40],
        );
        await harness.graph.executeSql(
          'INSERT INTO chat_to_message (chat_ss_id, message_ss_id) '
          'VALUES (?, ?)',
          <Object?>[chat31, message40],
        );
        await harness.graph.executeSql(
          'DELETE FROM chat_to_handle '
          'WHERE chat_ss_id = ? AND handle_ss_id = ?',
          <Object?>[chat30, handle12],
        );
        await harness.graph.executeSql(
          'INSERT INTO chat_to_handle (chat_ss_id, handle_ss_id) VALUES (?, ?)',
          <Object?>[chat31, handle10],
        );
        await harness.graph.executeSql(
          'DELETE FROM contact_to_handle '
          'WHERE contact_id = ? AND handle_ss_id = ?',
          <Object?>[contact20, handle10],
        );
        await harness.graph.executeSql(
          'INSERT INTO contact_to_handle '
          '(contact_id, handle_ss_id, handle_value) VALUES (?, ?, ?)',
          <Object?>[contact21, handle12, '*city*'],
        );
        await harness.graph.executeSql(
          'DELETE FROM message_to_attachment '
          'WHERE message_ss_id = ? AND attachment_ss_id = ?',
          <Object?>[message40, attachment50],
        );
        await harness.graph.executeSql(
          'INSERT INTO message_to_attachment '
          '(message_ss_id, attachment_ss_id) VALUES (?, ?)',
          <Object?>[message41, attachment50],
        );

        final comparison = compareGraphMaterialSnapshots(
          expected: expected,
          observed: await harness.snapshot(),
        );
        for (final tableName in <String>[
          'chat_to_message',
          'chat_to_handle',
          'contact_to_handle',
          'message_to_attachment',
        ]) {
          expect(
            comparison.description,
            contains('$tableName key{'),
            reason: '$tableName must identify its material row',
          );
        }
        expect(comparison.description, contains('expected row missing'));
        expect(comparison.description, contains('extra observed row'));
      });
    });
  });

  test(
    'stale contact, chat, and extra edges literally do not converge',
    () async {
      await _withHarness((harness) async {
        await harness.seedCanonicalFixture();
        await harness.replayFull();
        final clean = await harness.snapshot();
        await harness.makeGraphDeliberatelyStale();
        final stale = await harness.snapshot();

        final antiDifference = compareGraphMaterialSnapshots(
          expected: clean,
          observed: stale,
        );
        expect(
          antiDifference.description,
          contains(
            'contacts key{contact_id=${harness.ss(2, 20)}} '
            'field{display_name}',
          ),
        );
        expect(
          antiDifference.description,
          contains('chats key{ss_id=${harness.ss(1, 30)}} field{is_group}'),
        );
        expect(antiDifference.description, contains('chat_to_message key{'));
        expect(
          antiDifference.description,
          contains('message_to_attachment key{'),
        );

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

        expect(snapshot, isNot(contains('message_text_fts')));
        expect(
          await harness.messageTextIndexRows(),
          contains(containsPair('rowid', liveTarget)),
        );

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
        await expectLater(harness.searchMessageIds('co-op'), throwsA(anything));
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
        final comparison = compareGraphMaterialSnapshots(
          expected: sourceThreeSnapshot,
          observed: sourceFourSnapshot,
        );
        expect(
          comparison.description,
          contains(
            'messages key{ss_id=$sourceThreeMessageId}: '
            'expected row missing from observed snapshot',
          ),
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
  GraphMaterialSnapshot observed,
  GraphMaterialSnapshot expected,
) {
  final comparison = compareGraphMaterialSnapshots(
    expected: expected,
    observed: observed,
  );
  expect(comparison.isEqual, isTrue, reason: comparison.description);
}

void _expectChangedFields(
  GraphMaterialComparison comparison, {
  required String tableName,
  required String key,
  required List<String> fields,
}) {
  for (final field in fields) {
    expect(
      comparison.description,
      contains('$tableName $key field{$field}:'),
      reason: '$tableName.$field must be a material comparison field',
    );
  }
}
