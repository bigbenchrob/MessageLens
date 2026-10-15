import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/search/application/graph_message_search.dart';
import 'package:remember_this_text/essentials/search/application/message_text_search_query.dart';
import 'package:remember_this_text/essentials/search/infrastructure/repositories/graph_search_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_semantic_projection.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import 'fts_equivalence_evidence.dart';
import 'production_graph_replay_harness.dart';

const _date = '2026-01-02T00:00:00.000Z';
const _rawCorpus = <String, String>{
  'old': '"oldword"',
  'new': '"newword"',
  'ghost': '"ghostword"',
  'case': '"CAFE"',
  'phrase': '"co-op"',
  'prefix2': '"po"*',
  'prefix3': '"pos"*',
  'prefix4': '"post"*',
  'greek': '"Καλημέρα"',
  'cyrillic': '"ПРИВЕТ"',
  'repeat': '"alpha beta"',
  'apostrophe': '"don"',
  'underscore': '"score"',
};

int _id(int row) => SourceScopedRowKey.pack(sourceId: 1, sourceRowId: row);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  tearDown(() {
    expect(_activeHandles, 0);
    expect(_peakHandles, lessThanOrEqualTo(6));
    expect(_worlds.every((world) => world.disposed), isTrue);
  });
  _evidenceTests();
  group('characterization', () {
    test(
      'independent writers, exact schema, runtime and read-only search',
      () async {
        final left = await _World.create();
        final right = await _World.create();
        try {
          final beforeLeft = left.files();
          final beforeRight = right.files();
          final a = left.open();
          final b = right.open();
          try {
            expect(a.schema(), b.schema());
            _expectSchema(a.schema());
            expect(a.runtime(), b.runtime());
            // Synthetic runtime identity only, never message material.
            stdout.writeln('FTS_RUNTIME ${jsonEncode(a.runtime())}');
            expect(a.content(), b.content());
            expect(a.content(), hasLength(24));
            for (final entry in _rawCorpus.entries) {
              expect(a.raw(entry.value), b.raw(entry.value), reason: entry.key);
            }
            expect(a.raw('"post"'), <int>[_id(110), _id(114), _id(115)]);
            expect(
              a.raw('"CAFE"'),
              containsAll(<int>[_id(40), _id(41), _id(106), _id(107)]),
            );
            expect(a.raw('"ghostword"'), <int>[_id(105)]);
            expect(() => a.raw('co-op'), throwsA(isA<sql.SqliteException>()));
            expect(
              () => a.raw('"unterminated'),
              throwsA(isA<sql.SqliteException>()),
            );
            for (final request in _requests()) {
              expect(
                await a.search(request),
                await b.search(request),
                reason: request.name,
              );
            }
            expect(await a.search(const _Request('exact', 'post ')), <int>[
              _id(115),
              _id(114),
              _id(110),
            ]);
            expect(await a.search(const _Request('saved', 'is:saved')), <int>[
              _id(103),
              _id(110),
            ]);
            expect(await a.search(const _Request('and', 'post alpha ')), <int>[
              _id(115),
            ]);
            expect(
              await a.search(const _Request('or', 'post alpha ', any: true)),
              <int>[_id(115), _id(114), _id(110)],
            );
            expect(await a.search(const _Request('compat', 'compat ')), <int>[
              _id(110),
            ]);
            expect(
              await a.search(const _Request('cap', 'post', limit: 1)),
              <int>[_id(115)],
            );
            expect(await a.search(const _Request('single', 'p')), isEmpty);
            expect(
              await a.search(const _Request('zero', 'post', limit: 0)),
              isEmpty,
            );
            for (final reader in <_Reader>[a, b]) {
              reader.assertWritesRefused();
            }
            expect(a.schema(), b.schema());
          } finally {
            await a.close();
            await b.close();
          }
          expect(left.files(), beforeLeft);
          expect(right.files(), beforeRight);
        } finally {
          await left.dispose();
          await right.dispose();
        }
      },
    );

    test(
      'repeat, same text, null empty and delete reinsert use production writers',
      () async {
        final world = await _World.create(characterizeTransitions: true);
        try {
          final reader = world.open();
          try {
            expect(reader.raw('"oldword"'), <int>[_id(103)]);
          } finally {
            await reader.close();
          }
        } finally {
          await world.dispose();
        }
      },
    );

    test(
      'equal content and restored DDL hide stale postings; tags mask missing hit',
      () async {
        final clean = await _World.create();
        final stale = await _World.create(fault: _Fault.stale);
        try {
          final a = clean.open();
          final b = stale.open();
          try {
            expect(a.content(), b.content());
            expect(a.schema(), b.schema());
            expect(a.raw('"oldword"'), <int>[_id(103)]);
            expect(b.raw('"oldword"'), isEmpty);
            expect(b.raw('"newword"'), contains(_id(103)));
            const request = _Request('masked', 'oldword ');
            expect(await a.search(request), <int>[_id(103)]);
            expect(await b.search(request), await a.search(request));
          } finally {
            await a.close();
            await b.close();
          }
        } finally {
          await clean.dispose();
          await stale.dispose();
        }
      },
    );
  });
}

enum _Fault { none, stale, missing, ghost, capped, overlay, ambiguousGuid }

final class _Request {
  const _Request(
    this.name,
    this.query, {
    this.scope,
    this.any = false,
    this.limit = 500,
  });
  final String name;
  final String query;
  final GraphMessageSearchScope? scope;
  final bool any;
  final int limit;
}

List<_Request> _requests() => <_Request>[
  const _Request('exact', 'post '),
  const _Request('prefix', 'post'),
  const _Request('prefix2', 'po'),
  const _Request('prefix3', 'pos'),
  const _Request('punctuation', 'co-op '),
  const _Request('quoted', '"quote" '),
  const _Request('all', 'post alpha '),
  const _Request('any', 'post alpha ', any: true),
  const _Request('case', 'CAFÉ '),
  const _Request('decomposed', 'cafe\u0301 '),
  const _Request('saved', 'is:saved'),
  const _Request('saved-text', 'post is:saved'),
  const _Request('tag-masked', 'oldword '),
  const _Request('guid-tag', 'compat '),
  const _Request('cap', 'post', limit: 1),
  const _Request('zero', 'post', limit: 0),
  const _Request('single', 'p'),
  _Request(
    'conversation',
    'post',
    scope: GraphMessageSearchScope.conversation(_id(30)),
  ),
  _Request('handle', 'post', scope: GraphMessageSearchScope.handle(_id(10))),
  _Request(
    'contact',
    'post',
    scope: GraphMessageSearchScope.contactCanonicalHandles(<int>[_id(10)]),
  ),
];

int _activeHandles = 0;
int _peakHandles = 0;
final _worlds = <_World>[];

void _reserveHandles(int count) {
  if (_activeHandles + count > 6) {
    throw const FtsObservationFailure(FtsReason.handleLimit);
  }
  _activeHandles += count;
  if (_activeHandles > _peakHandles) {
    _peakHandles = _activeHandles;
  }
}

int _ownedDiskBytes() => _worlds
    .where((w) => !w.disposed)
    .fold<int>(
      0,
      (total, world) =>
          total +
          world.root
              .listSync(recursive: true, followLinks: false)
              .whereType<File>()
              .fold<int>(0, (bytes, file) => bytes + file.lengthSync()),
    );

final class _World {
  _World(this.root, this.graphPath, this.overlayPath, this.registry);
  final String registry;
  final Directory root;
  final String graphPath;
  final String overlayPath;
  final List<_Reader> readers = <_Reader>[];
  bool disposed = false;
  bool observerPreserved = false;

  static Future<_World> create({
    _Fault fault = _Fault.none,
    bool characterizeTransitions = false,
  }) async {
    _reserveHandles(3);
    final harness = await ProductionGraphReplayHarness.open();
    final overlayPath = '${harness.root.path}/overlay.db';
    final overlay = OverlayDatabase(NativeDatabase(File(overlayPath)));
    var closed = false;
    try {
      await harness.seedCanonicalFixture();
      final texts = <String?>[
        null,
        '',
        ' \t\n',
        'oldword',
        'newword',
        'ghostword',
        'CAFÉ',
        'cafe\u0301',
        'co-op',
        "don't",
        'post postmaster',
        'under_score',
        'Привет мир',
        'Καλημέρα',
        '👩‍💻post',
        'post alpha beta alpha',
        'embedded "quote"',
        null,
      ];
      for (final (index, fact) in <(int, MessageRichTextDecoderFact)>[
        (0, const MessageRichTextDecoderResult('   ')),
        (3, const MessageRichTextDecoderResult(' oldword ')),
        (
          17,
          const MessageRichTextDecoderFailure(
            MessageRichTextDecodeFailureKind.decoderDidNotProduceText,
          ),
        ),
      ]) {
        final result = projectMessageRichTextSemantics(
          MessageRichTextSemanticInput(
            ssId: _id(100 + index),
            sourceRowId: 100 + index,
            attributedBodyBlobByteCount: 1,
            loadedAttributedBodyBlobByteCount: 1,
            maximumAttributedBodyBlobBytes: 8 * 1024 * 1024,
            decoderFact: fact,
          ),
        );
        texts[index] = result is PersistMessageRichText
            ? result.normalizedText
            : null;
      }
      for (var i = 0; i < texts.length; i++) {
        final row = 100 + i;
        await harness.importLedger.database
            .insert('messages', <String, Object?>{
              'ss_id': _id(row),
              'source_id': 1,
              'source_rowid': row,
              'guid': fault == _Fault.ambiguousGuid && row == 117
                  ? 'fts-110'
                  : 'fts-$row',
              'sender_handle_ss_id': _id(10),
              'is_from_me': 0,
              'date_utc': row == 110 ? null : _date,
              'text': texts[i],
              'batch_id': 1001,
            });
        await harness.importLedger.database
            .insert('chat_to_message', <String, Object?>{
              'ss_id': _id(1000 + row),
              'source_id': 1,
              'source_rowid': 1000 + row,
              'source_chat_rowid': 30,
              'source_message_rowid': row,
              'chat_ss_id': _id(30),
              'message_ss_id': _id(row),
            });
      }
      await harness.replayFull();
      if (characterizeTransitions) {
        final baseline = await harness.snapshot();
        await harness.replayFull();
        expect(await harness.snapshot(), baseline);
        for (final text in <String?>['oldword', null, '', 'oldword']) {
          await harness.importLedger.database.update(
            'messages',
            <String, Object?>{'text': text},
            where: 'ss_id = ?',
            whereArgs: <Object?>[_id(103)],
          );
          await harness.replayFull();
          expect(
            await harness.searchMessageIds('"oldword"'),
            text == 'oldword' ? <int>[_id(103)] : isEmpty,
          );
        }
        await harness.graph.executeSql(
          'DELETE FROM messages WHERE ss_id = ?',
          <Object?>[_id(103)],
        );
        expect(await harness.searchMessageIds('"oldword"'), isEmpty);
        await harness.replayFull();
        expect(await harness.snapshot(), baseline);
      }
      if (fault == _Fault.stale) {
        final trigger = (await harness.graph.selectRows(
          "SELECT sql FROM sqlite_master WHERE name = 'message_text_fts_after_text_update'",
        )).single['sql'];
        if (trigger is! String) {
          throw StateError('Missing trigger SQL');
        }
        await harness.graph.executeSql(
          'UPDATE messages SET text = ? WHERE ss_id = ?',
          <Object?>['newword', _id(103)],
        );
        await harness.graph.executeSql(
          'DROP TRIGGER message_text_fts_after_text_update',
        );
        await harness.graph.executeSql(
          'UPDATE messages SET text = ? WHERE ss_id = ?',
          <Object?>['oldword', _id(103)],
        );
        await harness.graph.executeSql(trigger);
      }
      if (fault == _Fault.missing || fault == _Fault.capped) {
        final row = fault == _Fault.capped ? 110 : 103;
        final text = fault == _Fault.capped ? 'post postmaster' : 'oldword';
        await harness.graph.executeSql(
          "INSERT INTO message_text_fts(message_text_fts,rowid,text) VALUES ('delete',?,?)",
          <Object?>[_id(row), text],
        );
      }
      if (fault == _Fault.ghost) {
        await harness.graph.executeSql(
          'INSERT INTO message_text_fts(rowid,text) VALUES (?,?)',
          <Object?>[_id(999), 'ghostword'],
        );
      }
      await overlay.customSelect('SELECT 1').get();
      await overlay.customStatement(
        'INSERT INTO message_intent_tags(message_ss_id,tag_display,tag_normalized,created_at_utc,updated_at_utc) VALUES (?,?,?,?,?)',
        <Object?>[_id(103), 'oldword', 'oldword', _date, _date],
      );
      await overlay.customStatement(
        'INSERT INTO message_user_tags(message_guid,tag_display,tag_normalized,created_at_utc,updated_at_utc) VALUES (?,?,?,?,?)',
        <Object?>['fts-110', 'compat', 'compat', _date, _date],
      );
      await overlay.customStatement(
        'INSERT INTO message_intent_overlays(message_ss_id,is_saved,created_at_utc,updated_at_utc) VALUES (?,1,?,?)',
        <Object?>[_id(103), _date, _date],
      );
      await overlay.setMessageSaved(messageGuid: 'fts-110', isSaved: true);
      if (fault == _Fault.overlay) {
        await overlay.customStatement('DELETE FROM message_intent_tags');
        await overlay.customStatement(
          'UPDATE message_intent_overlays SET is_saved = 0',
        );
      }
      final registry = jsonEncode(
        await harness.sourceRegistryRows(),
      ).replaceAll(harness.root.path, '<synthetic-root>');
      await overlay.close();
      await harness.graph.close();
      await harness.importLedger.close();
      closed = true;
      final world = _World(
        harness.root,
        harness.graphPath,
        overlayPath,
        registry,
      );
      _worlds.add(world);
      world.files();
      return world;
    } finally {
      _activeHandles -= 3;
      if (!closed) {
        await overlay.close();
        await harness.dispose();
      }
    }
  }

  Map<String, String> files() {
    final result = <String, String>{};
    var bytes = 0;
    for (final entity in root.listSync(recursive: true, followLinks: false)) {
      if (entity is Link) {
        throw StateError('Unexpected link');
      }
      if (entity is File) {
        bytes += entity.lengthSync();
        if (bytes > 32 * 1024 * 1024) {
          throw const FtsObservationFailure(FtsReason.diskLimit);
        }
        final data = entity.readAsBytesSync();
        result[entity.path.substring(root.path.length)] = sha256
            .convert(data)
            .toString();
      }
    }
    if (bytes > 32 * 1024 * 1024) {
      throw StateError('Disposable disk bound');
    }
    return result;
  }

  _Reader open() {
    _reserveHandles(2);
    try {
      final reader = _Reader.open(this);
      readers.add(reader);
      return reader;
    } on Object {
      _activeHandles -= 2;
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (disposed) {
      throw StateError('Duplicate world disposal');
    }
    for (final reader in readers) {
      if (reader.closeCount == 0) {
        await reader.close();
      }
      expect(reader.closeCount, 1);
      if (!reader.closed) {
        throw StateError('Reader closure unconfirmed; retain disposable root');
      }
    }
    await root.delete(recursive: true);
    expect(root.existsSync(), isFalse);
    disposed = true;
  }
}

final class _Reader {
  static _Reader open(_World world) {
    final root = world.root.resolveSymbolicLinksSync();
    for (final path in <String>[world.graphPath, world.overlayPath]) {
      if (!File(path).resolveSymbolicLinksSync().startsWith('$root/')) {
        throw StateError('Reader path outside owned disposable root');
      }
    }
    final graph = sql.sqlite3.open(
      world.graphPath,
      mode: sql.OpenMode.readOnly,
    );
    sql.Database? overlay;
    try {
      overlay = sql.sqlite3.open(
        world.overlayPath,
        mode: sql.OpenMode.readOnly,
      );
      graph.execute('PRAGMA query_only = ON');
      overlay.execute('PRAGMA query_only = ON');
      return _Reader._(graph, overlay);
    } on Object {
      overlay?.dispose();
      graph.dispose();
      rethrow;
    }
  }

  _Reader._(this.rawGraph, this.rawOverlay) {
    graph = ConversationGraphDatabase(
      NativeDatabase.opened(rawGraph, enableMigrations: false),
    );
    overlay = OverlayDatabase(
      NativeDatabase.opened(rawOverlay, enableMigrations: false),
    );
    repository = SqliteGraphSearchRepository(
      graphDatabase: graph,
      overlayDatabase: overlay,
    );
  }
  final sql.Database rawGraph;
  final sql.Database rawOverlay;
  late final ConversationGraphDatabase graph;
  late final OverlayDatabase overlay;
  late final SqliteGraphSearchRepository repository;
  int closeCount = 0;
  bool closed = false;

  List<Map<String, Object?>> schema() => <Map<String, Object?>>[
    for (final row in rawGraph.select(
      "SELECT name,sql FROM sqlite_master WHERE name IN ('messages','message_text_fts','message_text_fts_after_insert','message_text_fts_after_delete','message_text_fts_after_text_update') ORDER BY name",
    ))
      Map<String, Object?>.from(row),
  ];
  Map<String, Object?> runtime() => <String, Object?>{
    ...rawGraph
        .select(
          'SELECT sqlite_version() AS version, sqlite_source_id() AS source',
        )
        .single,
    'options':
        rawGraph
            .select('PRAGMA compile_options')
            .map((r) => r.values.single)
            .toList()
          ..sort((a, b) => a.toString().compareTo(b.toString())),
    'schema': rawGraph.select('PRAGMA user_version').single.values.single,
  };
  List<Map<String, Object?>> content() => <Map<String, Object?>>[
    for (final row in rawGraph.select(
      'SELECT ss_id,text FROM messages ORDER BY ss_id LIMIT 129',
    ))
      Map<String, Object?>.from(row),
  ];
  List<int> raw(String expression) => <int>[
    for (final row in rawGraph.select(
      'SELECT rowid FROM message_text_fts WHERE message_text_fts MATCH ? ORDER BY rowid LIMIT 129',
      <Object?>[expression],
    ))
      row['rowid'] as int,
  ];
  Future<List<int>> search(_Request request) {
    final query = MessageTextSearchQuery.parse(request.query);
    return repository.searchMessageIds(
      scope: request.scope ?? const GraphMessageSearchScope.global(),
      textTokens: query.tokens,
      matchAnyTerm: request.any,
      filterSaved: query.filterSaved,
      limit: request.limit,
    );
  }

  void assertWritesRefused() {
    for (final statement in <String>[
      "UPDATE messages SET text = 'forbidden'",
      "INSERT INTO message_text_fts(message_text_fts) VALUES ('integrity-check')",
      "INSERT INTO message_text_fts(message_text_fts,rank) VALUES ('integrity-check',1)",
      "INSERT INTO message_text_fts(message_text_fts) VALUES ('rebuild')",
      "INSERT INTO message_text_fts(message_text_fts) VALUES ('optimize')",
      'DROP TRIGGER message_text_fts_after_insert',
      'CREATE VIRTUAL TABLE denied USING fts5(text)',
      'CREATE VIRTUAL TABLE temp.denied USING fts5(text)',
      'PRAGMA user_version = 99',
    ]) {
      expect(
        () => rawGraph.execute(statement),
        throwsA(isA<sql.SqliteException>()),
      );
    }
    expect(
      () => rawOverlay.execute('DELETE FROM message_intent_tags'),
      throwsA(isA<sql.SqliteException>()),
    );
  }

  Future<void> close() async {
    closeCount++;
    if (closeCount != 1) {
      throw StateError('Duplicate reader close');
    }
    try {
      await graph.close();
    } finally {
      await overlay.close();
    }
    closed = true;
    _activeHandles -= 2;
  }
}

void _expectSchema(List<Map<String, Object?>> rows) {
  String normalized(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').trim();
  final expected = <String, String>{
    'message_text_fts':
        "CREATE VIRTUAL TABLE message_text_fts USING fts5( text, content='messages', content_rowid='ss_id', tokenize='unicode61 remove_diacritics 2', prefix='2 3 4' )",
    'message_text_fts_after_insert':
        'CREATE TRIGGER message_text_fts_after_insert AFTER INSERT ON messages BEGIN INSERT INTO message_text_fts(rowid, text) VALUES (new.ss_id, new.text); END',
    'message_text_fts_after_delete':
        "CREATE TRIGGER message_text_fts_after_delete AFTER DELETE ON messages BEGIN INSERT INTO message_text_fts(message_text_fts, rowid, text) VALUES ('delete', old.ss_id, old.text); END",
    'message_text_fts_after_text_update':
        "CREATE TRIGGER message_text_fts_after_text_update AFTER UPDATE OF text ON messages BEGIN INSERT INTO message_text_fts(message_text_fts, rowid, text) VALUES ('delete', old.ss_id, old.text); INSERT INTO message_text_fts(rowid, text) VALUES (new.ss_id, new.text); END",
  };
  expect(rows.map((row) => row['name']).toSet(), <String>{
    'messages',
    ...expected.keys,
  });
  for (final row in rows) {
    final name = row['name'];
    final ddl = row['sql'];
    if (name is! String || ddl is! String) {
      throw StateError('Missing schema field');
    }
    if (name == 'messages') {
      expect(normalized(ddl), contains('ss_id INTEGER PRIMARY KEY'));
    } else {
      expect(normalized(ddl), expected[name]);
    }
  }
}

void _evidenceTests() {
  group('six dimensions', () {
    test('clean independent replay is finite evidence only', () async {
      final result = await _physicalComparison(_Fault.none);
      for (final dimension in FtsDimension.values.take(4)) {
        expect(result.dimensions[dimension]?.truth, FtsTruth.trueValue);
      }
      _expectUnproven(result);
    });
    for (final fault in <_Fault>[
      _Fault.stale,
      _Fault.missing,
      _Fault.ghost,
      _Fault.capped,
    ]) {
      test('physical ${fault.name} cannot be masked', () async {
        final expressions = fault == _Fault.ghost
            ? <String>['"ghostword"']
            : fault == _Fault.capped
            ? <String>['"post"*']
            : <String>['"oldword"'];
        final requests = fault == _Fault.ghost
            ? <_Request>[const _Request('ghost', 'ghostword ')]
            : fault == _Fault.capped
            ? <_Request>[const _Request('cap', 'post', limit: 1)]
            : <_Request>[const _Request('tag', 'oldword ')];
        final result = await _physicalComparison(
          fault,
          raw: expressions,
          requests: requests,
        );
        expect(
          result.dimensions[FtsDimension.contentMaterialEquivalence]?.truth,
          FtsTruth.trueValue,
        );
        expect(
          result.dimensions[FtsDimension.schemaRuntimeCompatibility]?.truth,
          FtsTruth.trueValue,
        );
        expect(
          result
              .dimensions[FtsDimension.boundedRawMatchCorpusEquivalence]
              ?.truth,
          FtsTruth.falseValue,
        );
        expect(
          result
              .dimensions[FtsDimension.boundedProductionSearchCorpusEquivalence]
              ?.truth,
          FtsTruth.trueValue,
        );
        _expectUnproven(result);
      });
    }
    test(
      'physical overlay-only difference belongs to production search',
      () async {
        final result = await _physicalComparison(_Fault.overlay);
        expect(
          result.dimensions[FtsDimension.contentMaterialEquivalence]?.truth,
          FtsTruth.trueValue,
        );
        expect(
          result
              .dimensions[FtsDimension.boundedRawMatchCorpusEquivalence]
              ?.truth,
          FtsTruth.trueValue,
        );
        expect(
          result
              .dimensions[FtsDimension.boundedProductionSearchCorpusEquivalence]
              ?.truth,
          FtsTruth.falseValue,
        );
        _expectUnproven(result);
      },
    );
    test(
      'physical duplicate GUID excludes compatibility tag and saved match',
      () async {
        final result = await _physicalComparison(_Fault.ambiguousGuid);
        expect(
          result
              .dimensions[FtsDimension.boundedRawMatchCorpusEquivalence]
              ?.truth,
          FtsTruth.trueValue,
        );
        expect(
          result
              .dimensions[FtsDimension.boundedProductionSearchCorpusEquivalence]
              ?.truth,
          FtsTruth.falseValue,
        );
        _expectUnproven(result);
      },
    );
    test(
      'physical malformed expression is unknown, not successful empty',
      () async {
        final result = await _physicalComparison(
          _Fault.none,
          raw: <String>['"unterminated'],
        );
        expect(
          result
              .dimensions[FtsDimension.boundedRawMatchCorpusEquivalence]
              ?.truth,
          FtsTruth.unknown,
        );
        expect(
          result
              .dimensions[FtsDimension.boundedRawMatchCorpusEquivalence]
              ?.reason,
          FtsReason.readFailure,
        );
        expect(result.diagnostics.join(), isNot(contains('unterminated')));
      },
    );
    test(
      'simulated content-only differences preserve null and empty',
      () async {
        final a = _FakeSource();
        final b = _FakeSource()
          ..rows = <FtsContentRow>[const FtsContentRow(1, '')];
        final result = await _compare(a, b);
        expect(
          result.dimensions[FtsDimension.contentMaterialEquivalence]?.truth,
          FtsTruth.falseValue,
        );
        expect(
          result
              .dimensions[FtsDimension.boundedRawMatchCorpusEquivalence]
              ?.truth,
          FtsTruth.trueValue,
        );
        _expectUnproven(result);
      },
    );
    test(
      'known named contradiction survives an unrelated failed request',
      () async {
        final b = _FakeSource()
          ..differentRaw = true
          ..failedRaw = 1;
        final result = await _compare(_FakeSource(), b, rawCount: 2);
        expect(
          result
              .dimensions[FtsDimension.boundedRawMatchCorpusEquivalence]
              ?.truth,
          FtsTruth.falseValue,
        );
        expect(
          result.diagnostics,
          contains('boundedRawMatchCorpusEquivalence.request.1.readFailure'),
        );
        _expectUnproven(result);
      },
    );
    test(
      'runtime, schema and tokenizer identity drift fail compatibility only',
      () async {
        for (final field in <String>[
          'version',
          'source',
          'options',
          'schema',
          'tokenizer',
        ]) {
          final b = _FakeSource()..runtimeDrift = field;
          final result = await _compare(_FakeSource(), b);
          expect(
            result.dimensions[FtsDimension.schemaRuntimeCompatibility]?.truth,
            FtsTruth.falseValue,
          );
          for (final dimension in FtsDimension.values.skip(1).take(3)) {
            expect(result.dimensions[dimension]?.truth, FtsTruth.unknown);
          }
        }
      },
    );
    test(
      'unqualified runtime, snapshot, registry and graph occurrence fail closed',
      () async {
        for (final kind in <String>[
          'runtime',
          'snapshot',
          'registry',
          'replacement',
          'drift',
        ]) {
          final b = _FakeSource()
            ..bindingFault = kind
            ..differentRaw = true;
          final result = await _compare(_FakeSource(), b);
          for (final dimension in FtsDimension.values.take(4)) {
            expect(
              result.dimensions[dimension]?.truth,
              FtsTruth.unknown,
              reason: kind,
            );
          }
          _expectUnproven(result);
        }
      },
    );
    test('all budget overflows are unknown without truncation', () async {
      for (final (resources, reason) in <(FtsResources, FtsReason)>[
        (
          const FtsResources(
            messages: 129,
            textBytes: 0,
            openHandles: 0,
            ownedDiskBytes: 0,
          ),
          FtsReason.rowLimit,
        ),
        (
          const FtsResources(
            messages: 1,
            textBytes: 262145,
            openHandles: 0,
            ownedDiskBytes: 0,
          ),
          FtsReason.byteLimit,
        ),
        (
          const FtsResources(
            messages: 1,
            textBytes: 0,
            openHandles: 7,
            ownedDiskBytes: 0,
          ),
          FtsReason.handleLimit,
        ),
        (
          const FtsResources(
            messages: 1,
            textBytes: 0,
            openHandles: 0,
            ownedDiskBytes: 33554433,
          ),
          FtsReason.diskLimit,
        ),
      ]) {
        final b = _FakeSource()..resourceValue = resources;
        final result = await _compare(_FakeSource(), b);
        expect(
          result.dimensions[FtsDimension.contentMaterialEquivalence]?.reason,
          reason,
        );
        expect(b.closeCount, 1);
      }
      final countResult = await _compare(
        _FakeSource(),
        _FakeSource(),
        rawCount: 64,
      );
      expect(
        countResult.dimensions[FtsDimension.contentMaterialEquivalence]?.reason,
        FtsReason.requestLimit,
      );
      final b = _FakeSource()..oversizedResult = true;
      final result = await _compare(_FakeSource(), b);
      expect(
        result
            .dimensions[FtsDimension.boundedRawMatchCorpusEquivalence]
            ?.reason,
        FtsReason.resultLimit,
      );
      expect(
        result.dimensions[FtsDimension.boundedRawMatchCorpusEquivalence]?.truth,
        FtsTruth.unknown,
      );
      for (final rows in <List<FtsContentRow>>[
        List<FtsContentRow>.generate(129, (i) => FtsContentRow(i, null)),
        <FtsContentRow>[FtsContentRow(1, 'x' * 262145)],
      ]) {
        final result = await _compare(
          _FakeSource(),
          _FakeSource()..rows = rows,
        );
        expect(
          result.dimensions[FtsDimension.contentMaterialEquivalence]?.truth,
          FtsTruth.unknown,
        );
      }
    });
    test(
      'simulated error before and after each read phase closes once',
      () async {
        for (var point = 1; point <= 8; point++) {
          for (final after in <bool>[false, true]) {
            final a = _FakeSource();
            final b = _FakeSource()
              ..failureAt = point
              ..failAfter = after;
            final result = await _compare(a, b);
            expect(a.closeCount, 1);
            expect(b.closeCount, 1);
            expect(
              result.dimensions.values.any((v) => v.truth == FtsTruth.unknown),
              isTrue,
            );
            expect(b.inFlight, 0);
            final affected = point == 4
                ? FtsDimension.contentMaterialEquivalence
                : point == 5
                ? FtsDimension.boundedRawMatchCorpusEquivalence
                : point == 6
                ? FtsDimension.boundedProductionSearchCorpusEquivalence
                : FtsDimension.schemaRuntimeCompatibility;
            expect(result.dimensions[affected]?.truth, FtsTruth.unknown);
            expect(result.diagnostics.join(), isNot(contains('PRIVATE')));
          }
        }
      },
    );
    test(
      'cancel and deadline at every boundary, including cleanup, quiesce first',
      () async {
        // 8 reads/world, before+after each, plus post-close; 34 checkpoints total.
        for (var point = 1; point <= 34; point++) {
          for (final timed in <bool>[false, true]) {
            var checks = 0;
            final a = _FakeSource();
            final b = _FakeSource();
            final runner = FtsEvidenceComparison(
              now: () => timed ? ++checks : 0,
              cancelled: () => !timed && ++checks >= point,
              deadline: timed ? point : 999,
            );
            final result = await runner.compare(
              expected: a,
              observed: b,
              corpus: _corpus(),
            );
            expect(a.closeCount, 1);
            expect(b.closeCount, 1);
            expect(a.inFlight + b.inFlight, 0);
            for (final dimension in FtsDimension.values.take(4)) {
              expect(
                result.dimensions[dimension]?.truth,
                FtsTruth.unknown,
                reason: '$point/$timed',
              );
            }
          }
        }
      },
    );
    test(
      'cleanup failure cannot publish success; disposal waits for work',
      () async {
        final b = _FakeSource()..closeFails = true;
        final result = await _compare(_FakeSource(), b);
        expect(
          result.dimensions[FtsDimension.contentMaterialEquivalence]?.reason,
          FtsReason.cleanupFailure,
        );
        expect(b.closeCount, 1);
        expect(b.inFlight, 0);
      },
    );
    test(
      'diagnostics redact content and bound examples without hiding counts',
      () async {
        final a = _FakeSource()
          ..rows = List<FtsContentRow>.generate(
            100,
            (i) => FtsContentRow(i, 'PRIVATE👩‍💻'),
          );
        final b = _FakeSource()
          ..rows = List<FtsContentRow>.generate(
            100,
            (i) => FtsContentRow(i, 'SECRET'),
          );
        final result = await _compare(a, b);
        expect(result.diagnosticCount, 100);
        expect(result.diagnostics, hasLength(32));
        expect(result.diagnostics.toSet(), <String>{'content.mismatch'});
        expect(
          result.dimensions[FtsDimension.contentMaterialEquivalence]?.truth,
          FtsTruth.falseValue,
        );
      },
    );
    test(
      'real readers close before root deletion on cancellation and failure',
      () async {
        for (final fail in <bool>[false, true]) {
          final left = await _World.create();
          final right = await _World.create();
          try {
            var checks = 0;
            final result =
                await FtsEvidenceComparison(
                  now: () => 0,
                  deadline: 100,
                  cancelled: () => !fail && ++checks >= 8,
                ).compare(
                  expected: _PhysicalSource(
                    left,
                    <String>['"oldword"'],
                    <_Request>[const _Request('old', 'oldword ')],
                  ),
                  observed: _PhysicalSource(
                    right,
                    <String>['"oldword"'],
                    <_Request>[const _Request('old', 'oldword ')],
                  )..failOnClose = fail,
                  corpus: _corpus(),
                );
            expect(_activeHandles, 0);
            expect(right.observerPreserved, isTrue);
            expect(
              result.dimensions[FtsDimension.contentMaterialEquivalence]?.truth,
              FtsTruth.unknown,
            );
            expect(
              result
                  .dimensions[FtsDimension.contentMaterialEquivalence]
                  ?.reason,
              fail ? FtsReason.cleanupFailure : FtsReason.cancelled,
            );
          } finally {
            if (!left.disposed) {
              await left.dispose();
            }
            if (!right.disposed) {
              await right.dispose();
            }
          }
        }
      },
    );
    test('architecture: helper has no production authority or query policy', () {
      final helper = File(
        'test/essentials/conversation_graph/application/reconstruction/fts_equivalence_evidence.dart',
      ).readAsStringSync();
      expect(
        RegExp(
          r'^import .*;',
          multiLine: true,
        ).allMatches(helper).map((m) => m.group(0)),
        <String>["import 'dart:convert';"],
      );
      for (final forbidden in <String>[
        'SELECT ',
        'MATCH ',
        'ATTACH ',
        'Provider',
        'Coordinator',
        'ArchiveMutation',
        'canAuthorize',
        'tokenize',
        'sqlite3.open',
      ]) {
        expect(helper, isNot(contains(forbidden)));
      }
      final productionFiles = Directory('lib')
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      for (final file in productionFiles) {
        expect(
          file.readAsStringSync(),
          isNot(contains('fts_equivalence_evidence.dart')),
          reason: file.path,
        );
      }
    });
  });
}

void _expectUnproven(FtsEvidenceResult result) {
  for (final dimension in FtsDimension.values.skip(4)) {
    expect(result.dimensions[dimension]?.truth, FtsTruth.unknown);
    expect(result.dimensions[dimension]?.assessed, isFalse);
  }
}

FtsCorpus _corpus({int rawCount = 1, int productionCount = 1}) => FtsCorpus(
  identity: 'synthetic-112-v1',
  rawCount: rawCount,
  productionCount: productionCount,
);

Future<FtsEvidenceResult> _compare(
  FtsEvidenceSource a,
  FtsEvidenceSource b, {
  int rawCount = 1,
}) => FtsEvidenceComparison(now: () => 0, cancelled: () => false, deadline: 100)
    .compare(
      expected: a,
      observed: b,
      corpus: _corpus(rawCount: rawCount),
    );

Future<FtsEvidenceResult> _physicalComparison(
  _Fault fault, {
  List<String>? raw,
  List<_Request>? requests,
}) async {
  final left = await _World.create();
  final right = await _World.create(fault: fault);
  final expressions = raw ?? _rawCorpus.values.toList();
  final queries = requests ?? _requests();
  try {
    final result =
        await FtsEvidenceComparison(
          now: () => 0,
          cancelled: () => false,
          deadline: 100,
        ).compare(
          expected: _PhysicalSource(left, expressions, queries),
          observed: _PhysicalSource(right, expressions, queries),
          corpus: _corpus(
            rawCount: expressions.length,
            productionCount: queries.length,
          ),
        );
    expect(left.observerPreserved, isTrue);
    expect(right.observerPreserved, isTrue);
    return result;
  } finally {
    if (!left.disposed) {
      await left.dispose();
    }
    if (!right.disposed) {
      await right.dispose();
    }
  }
}

final class _PhysicalSource implements FtsEvidenceSource {
  _PhysicalSource(this.world, this.expressions, this.requests)
    : before = world.files(),
      reader = world.open();
  final Map<String, String> before;
  final _World world;
  final _Reader reader;
  final List<String> expressions;
  final List<_Request> requests;
  bool failOnClose = false;

  @override
  Future<FtsResources> resources() async {
    final row = reader.rawGraph
        .select(
          'SELECT count(*) AS n, coalesce(sum(length(cast(text AS BLOB))),0) AS bytes FROM messages',
        )
        .single;
    final resources = FtsResources(
      messages: row['n'] as int,
      textBytes: row['bytes'] as int,
      openHandles: _activeHandles,
      ownedDiskBytes: _ownedDiskBytes(),
    );
    if (resources.messages > 128) {
      throw const FtsObservationFailure(FtsReason.rowLimit);
    }
    if (resources.textBytes > 262144) {
      throw const FtsObservationFailure(FtsReason.byteLimit);
    }
    if (resources.ownedDiskBytes > 33554432) {
      throw const FtsObservationFailure(FtsReason.diskLimit);
    }
    return resources;
  }

  @override
  Future<FtsBinding> binding() async => FtsBinding(
    occurrence: world.graphPath,
    fingerprint: jsonEncode(world.files()),
    sourceRegistry: world.registry,
    qualified: true,
  );
  @override
  Future<FtsRuntimeSchema> runtimeSchema() async {
    final runtime = reader.runtime();
    return FtsRuntimeSchema(
      version: runtime['version']! as String,
      sourceId: runtime['source']! as String,
      compileOptions: (runtime['options']! as List<Object?>).cast<String>(),
      schema: jsonEncode(reader.schema()),
      ftsAvailable: reader.raw('"probe"').isEmpty,
      qualified: true,
    );
  }

  @override
  Future<List<FtsContentRow>> content() async {
    await resources();
    return <FtsContentRow>[
      for (final row in reader.content())
        FtsContentRow(row['ss_id']! as int, row['text'] as String?),
    ];
  }

  @override
  Future<List<int>> rawMatch(int requestIndex) async =>
      reader.raw(expressions[requestIndex]);
  @override
  Future<List<int>> productionSearch(int requestIndex) =>
      reader.search(requests[requestIndex]);
  @override
  Future<void> close() async {
    try {
      await reader.close();
      expect(world.files(), before);
      world.observerPreserved = true;
    } finally {
      await world.dispose();
    }
    if (failOnClose) {
      throw StateError('Injected post-cleanup failure');
    }
  }
}

final class _FakeSource implements FtsEvidenceSource {
  int closeCount = 0;
  int inFlight = 0;
  int calls = 0;
  int bindings = 0;
  int? failureAt;
  bool failAfter = false;
  bool closeFails = false;
  bool differentRaw = false;
  bool oversizedResult = false;
  int? failedRaw;
  String? runtimeDrift;
  String? bindingFault;
  List<FtsContentRow> rows = <FtsContentRow>[const FtsContentRow(1, null)];
  FtsResources resourceValue = const FtsResources(
    messages: 1,
    textBytes: 0,
    openHandles: 0,
    ownedDiskBytes: 0,
  );
  Future<T> run<T>(T Function() action) async {
    calls++;
    if (calls == failureAt && !failAfter) {
      throw StateError('PRIVATE simulated before read failure');
    }
    inFlight++;
    try {
      final value = action();
      if (calls == failureAt && failAfter) {
        throw StateError('PRIVATE simulated after read failure');
      }
      return value;
    } finally {
      inFlight--;
    }
  }

  @override
  Future<FtsResources> resources() => run(() => resourceValue);
  @override
  Future<FtsBinding> binding() => run(() {
    bindings++;
    return FtsBinding(
      occurrence: bindingFault == 'replacement' && bindings == 2
          ? 'replaced'
          : 'fixture',
      fingerprint: bindingFault == 'drift' && bindings == 2
          ? 'changed'
          : 'stable',
      sourceRegistry: bindingFault == 'registry' ? 'other-source' : 'source',
      qualified: bindingFault != 'snapshot',
    );
  });
  @override
  Future<FtsRuntimeSchema> runtimeSchema() => run(
    () => FtsRuntimeSchema(
      version: runtimeDrift == 'version' ? 'other' : 'synthetic',
      sourceId: runtimeDrift == 'source' ? 'other' : 'synthetic-source',
      compileOptions: runtimeDrift == 'options'
          ? <String>['other']
          : <String>['synthetic-fts'],
      schema: runtimeDrift == 'schema' || runtimeDrift == 'tokenizer'
          ? 'other'
          : 'schema',
      ftsAvailable: bindingFault != 'runtime',
      qualified: bindingFault != 'runtime',
    ),
  );
  @override
  Future<List<FtsContentRow>> content() => run(() => rows);
  @override
  Future<List<int>> rawMatch(int requestIndex) => run(() {
    if (failedRaw == requestIndex) {
      throw StateError('PRIVATE simulated corrupt index');
    }
    return oversizedResult
        ? List<int>.generate(129, (i) => i)
        : <int>[if (differentRaw) 2 else 1];
  });
  @override
  Future<List<int>> productionSearch(int requestIndex) => run(() => <int>[1]);
  @override
  Future<void> close() async {
    expect(inFlight, 0);
    closeCount++;
    if (closeFails) {
      throw StateError('PRIVATE simulated close failure');
    }
  }
}
