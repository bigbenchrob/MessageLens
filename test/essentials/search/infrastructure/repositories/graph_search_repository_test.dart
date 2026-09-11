import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/search/application/graph_message_search.dart';
import 'package:remember_this_text/essentials/search/application/message_text_search_query.dart';
import 'package:remember_this_text/essentials/search/infrastructure/repositories/graph_search_repository.dart';

import '../../../conversation_graph/conversation_graph_test_database.dart';

void main() {
  late ConversationGraphDatabase graphDatabase;
  late OverlayDatabase overlayDatabase;
  late SqliteGraphSearchRepository repository;

  setUp(() async {
    graphDatabase = await openConversationGraphTestDatabase();
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    await overlayDatabase.customSelect('SELECT 1').get();
    repository = SqliteGraphSearchRepository(
      graphDatabase: graphDatabase,
      overlayDatabase: overlayDatabase,
    );
  });

  tearDown(() async {
    await graphDatabase.close();
    await overlayDatabase.close();
  });

  test('searches graph message text and returns message_ss_id', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 1001,
      guid: 'guid-1001',
      text: 'The settlement offer is ready.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 1002,
      guid: 'guid-1002',
      text: 'Unrelated dinner plan.',
      dateUtc: '2026-05-02T12:00:00Z',
    );

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: const [PrefixMessageTextSearchToken('settlement')],
      matchAnyTerm: false,
      filterSaved: false,
    );

    expect(results, <int>[1001]);
  });

  test('does not apply tag normalization to message-text tokens', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 1101,
      guid: 'guid-1101',
      text: 'Re-Post the notice.',
      dateUtc: '2026-05-01T12:00:00Z',
    );

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: const [PrefixMessageTextSearchToken('re-post')],
      matchAnyTerm: false,
      filterSaved: false,
    );

    expect(results, <int>[1101]);
  });

  test('distinguishes exact token and prefix token semantics', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 1201,
      guid: 'guid-1201',
      text: 'The postmaster replied.',
      dateUtc: '2026-05-01T12:00:00Z',
    );

    final prefixResults = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: const [PrefixMessageTextSearchToken('post')],
      matchAnyTerm: false,
      filterSaved: false,
    );
    final exactResults = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: const [ExactMessageTextSearchToken('post')],
      matchAnyTerm: false,
      filterSaved: false,
    );

    expect(prefixResults, <int>[1201]);
    expect(exactResults, isEmpty);
  });

  test('uses word-prefix and exact-token semantics for message text', () async {
    const fixtures = <int, String>{
      1301: 'post',
      1302: 'post.',
      1303: 'post,',
      1304: '(post)',
      1305: 'post?',
      1306: 'posting',
      1307: 'posted',
      1308: 'posts',
      1309: 'postmaster',
      1310: 'crosspost',
      1311: 'support',
      1312: 'repository',
      1313: 'decompose',
      1314: 'possible',
      1315: 'point',
      1316: 'p',
      1317: 'ridiculous',
    };
    for (final entry in fixtures.entries) {
      final day = (entry.key - 1300).toString().padLeft(2, '0');
      await _insertMessage(
        graphDatabase,
        messageId: entry.key,
        guid: 'guid-${entry.key}',
        text: entry.value,
        dateUtc: '2026-05-${day}T12:00:00Z',
      );
    }

    expect(
      await _search(repository, const PrefixMessageTextSearchToken('po')),
      <int>[1315, 1314, 1309, 1308, 1307, 1306, 1305, 1304, 1303, 1302, 1301],
    );
    expect(
      await _search(repository, const PrefixMessageTextSearchToken('post')),
      <int>[1309, 1308, 1307, 1306, 1305, 1304, 1303, 1302, 1301],
    );
    expect(
      await _search(repository, const ExactMessageTextSearchToken('post')),
      <int>[1305, 1304, 1303, 1302, 1301],
    );
    expect(
      await _search(repository, const ExactMessageTextSearchToken('p')),
      <int>[1316],
    );
    expect(
      await _search(repository, const PrefixMessageTextSearchToken('ic')),
      isEmpty,
    );
  });

  test('uses unicode61 case, diacritic, and punctuation behavior', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 1401,
      guid: 'guid-1401',
      text: "CAFÉ don't post-master Привет under_score 👩‍💻post",
      dateUtc: '2026-05-01T12:00:00Z',
    );

    for (final token in const <MessageTextSearchToken>[
      ExactMessageTextSearchToken('cafe'),
      ExactMessageTextSearchToken('don'),
      ExactMessageTextSearchToken('master'),
      ExactMessageTextSearchToken('ПРИВЕТ'),
      ExactMessageTextSearchToken('under'),
      ExactMessageTextSearchToken('score'),
      ExactMessageTextSearchToken('post'),
    ]) {
      expect(await _search(repository, token), <int>[1401]);
    }
    expect(
      await _search(repository, const ExactMessageTextSearchToken('dont')),
      isEmpty,
    );
  });

  test(
    'quotes FTS syntax so user punctuation remains ordinary input',
    () async {
      await _insertMessage(
        graphDatabase,
        messageId: 1501,
        guid: 'guid-1501',
        text: 'post OR star text post quote mark',
        dateUtc: '2026-05-01T12:00:00Z',
      );
      await _insertMessage(
        graphDatabase,
        messageId: 1502,
        guid: 'guid-1502',
        text: 'postmaster starship',
        dateUtc: '2026-05-02T12:00:00Z',
      );

      expect(
        await _search(repository, const ExactMessageTextSearchToken('OR')),
        <int>[1501],
      );
      expect(
        await _search(repository, const ExactMessageTextSearchToken('star*')),
        <int>[1501],
      );
      expect(
        await _search(repository, const ExactMessageTextSearchToken('-post')),
        <int>[1501],
      );
      expect(
        await _search(repository, const ExactMessageTextSearchToken('(post)')),
        <int>[1501],
      );
      expect(
        await _search(repository, const ExactMessageTextSearchToken('post"')),
        <int>[1501],
      );
      expect(
        await _search(
          repository,
          const ExactMessageTextSearchToken('text:post'),
        ),
        <int>[1501],
      );

      for (final punctuation in const <String>['"', '*', '-', '(', ')', ':']) {
        expect(
          await _search(repository, ExactMessageTextSearchToken(punctuation)),
          isEmpty,
        );
      }
      for (final punctuation in const <String>['""', '**', '--', '()', '::']) {
        expect(
          await _search(repository, PrefixMessageTextSearchToken(punctuation)),
          isEmpty,
        );
      }
    },
  );

  test('does not return matches found only in invisible metadata', () async {
    await _insertHandle(
      graphDatabase,
      handleId: 1602,
      rawIdentifier: 'postmaster@example.com',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 1601,
      guid: 'post-guid-1601',
      text: 'unrelated visible content',
      dateUtc: '2026-05-01T12:00:00Z',
      senderHandleId: 1602,
    );
    await graphDatabase.executeSql('''
      UPDATE messages
      SET semantic_kind = 'post', item_kind = 'post'
      WHERE ss_id = 1601
      ''');

    expect(
      await _search(repository, const PrefixMessageTextSearchToken('post')),
      isEmpty,
    );
  });

  test('conversation scope does not leak matches from other chats', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 2001,
      guid: 'guid-2001',
      text: 'Flower delivery confirmed.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 2002,
      guid: 'guid-2002',
      text: 'Flower delivery confirmed.',
      dateUtc: '2026-05-02T12:00:00Z',
    );
    await _insertChatMessage(graphDatabase, chatId: 501, messageId: 2001);
    await _insertChatMessage(graphDatabase, chatId: 502, messageId: 2002);

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.conversation(501),
      textTokens: const [PrefixMessageTextSearchToken('flower')],
      matchAnyTerm: false,
      filterSaved: false,
    );

    expect(results, <int>[2001]);
  });

  test('preserves all-term and any-term combination behavior', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 2051,
      guid: 'guid-2051',
      text: 'Apple and banana.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 2052,
      guid: 'guid-2052',
      text: 'Apple only.',
      dateUtc: '2026-05-02T12:00:00Z',
    );
    const tokens = [
      ExactMessageTextSearchToken('apple'),
      PrefixMessageTextSearchToken('banana'),
    ];

    final allResults = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: tokens,
      matchAnyTerm: false,
      filterSaved: false,
    );
    final anyResults = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: tokens,
      matchAnyTerm: true,
      filterSaved: false,
    );

    expect(allResults, <int>[2051]);
    expect(anyResults, <int>[2052, 2051]);
  });

  test(
    'handle scope searches direct sender evidence without chat edges',
    () async {
      const canonicalHandleId = 7001;
      const aliasHandleId = 7002;
      const otherHandleId = 7003;
      await _insertHandle(
        graphDatabase,
        handleId: canonicalHandleId,
        rawIdentifier: '+16049995969',
      );
      await _insertHandle(
        graphDatabase,
        handleId: aliasHandleId,
        rawIdentifier: '6049995969',
      );
      await _insertHandle(
        graphDatabase,
        handleId: otherHandleId,
        rawIdentifier: '+17789908506',
      );
      await _insertCanonicalHandle(
        graphDatabase,
        canonicalHandleId: canonicalHandleId,
      );
      await _insertHandleAlias(
        graphDatabase,
        handleId: aliasHandleId,
        canonicalHandleId: canonicalHandleId,
        rawIdentifier: '6049995969',
      );
      await _insertMessage(
        graphDatabase,
        messageId: 2101,
        guid: 'guid-2101',
        text: 'Sender-only settlement evidence.',
        dateUtc: '2026-05-01T12:00:00Z',
        senderHandleId: aliasHandleId,
      );
      await _insertMessage(
        graphDatabase,
        messageId: 2102,
        guid: 'guid-2102',
        text: 'Other settlement evidence.',
        dateUtc: '2026-05-02T12:00:00Z',
        senderHandleId: otherHandleId,
      );

      final results = await repository.searchMessageIds(
        scope: const GraphMessageSearchScope.handle(canonicalHandleId),
        textTokens: const [PrefixMessageTextSearchToken('settlement')],
        matchAnyTerm: false,
        filterSaved: false,
      );

      expect(results, <int>[2101]);
    },
  );

  test('contact scope constrains FTS matches by canonical handles', () async {
    const canonicalHandleId = 7201;
    const aliasHandleId = 7202;
    await _insertHandle(
      graphDatabase,
      handleId: aliasHandleId,
      rawIdentifier: '6049995969',
    );
    await _insertHandleAlias(
      graphDatabase,
      handleId: aliasHandleId,
      canonicalHandleId: canonicalHandleId,
      rawIdentifier: '6049995969',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 2201,
      guid: 'guid-2201',
      text: 'Scoped settlement evidence.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 2202,
      guid: 'guid-2202',
      text: 'Other settlement evidence.',
      dateUtc: '2026-05-02T12:00:00Z',
    );
    await _insertChatMessage(graphDatabase, chatId: 521, messageId: 2201);
    await _insertChatMessage(graphDatabase, chatId: 522, messageId: 2202);
    await _insertChatHandle(
      graphDatabase,
      chatId: 521,
      handleId: aliasHandleId,
    );

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.contactCanonicalHandles(<int>[
        canonicalHandleId,
      ]),
      textTokens: const [PrefixMessageTextSearchToken('settlement')],
      matchAnyTerm: false,
      filterSaved: false,
    );

    expect(results, <int>[2201]);
  });

  test('orders text matches newest first then by descending ss_id', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 2301,
      guid: 'guid-2301',
      text: 'ordered result',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 2302,
      guid: 'guid-2302',
      text: 'ordered result',
      dateUtc: '2026-05-02T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 2303,
      guid: 'guid-2303',
      text: 'ordered result',
      dateUtc: '2026-05-02T12:00:00Z',
    );

    expect(
      await _search(repository, const ExactMessageTextSearchToken('ordered')),
      <int>[2303, 2302, 2301],
    );
    expect(graphSearchResultLimit, 500);
  });

  test('keeps the default graph search result cap at 500', () async {
    await graphDatabase.transaction(() async {
      for (var index = 1; index <= 501; index++) {
        await _insertMessage(
          graphDatabase,
          messageId: 8000 + index,
          guid: 'guid-cap-$index',
          text: 'capped result',
          dateUtc: '2026-05-01T12:00:00Z',
        );
      }
    });

    final results = await _search(
      repository,
      const ExactMessageTextSearchToken('capped'),
    );

    expect(results, hasLength(500));
    expect(results.first, 8501);
    expect(results.last, 8002);
    expect(results, isNot(contains(8001)));
  });

  test('reads graph-native saved overlay by message_ss_id', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 3001,
      guid: 'guid-3001',
      text: 'Graph-native saved message.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await overlayDatabase.customStatement(
      '''
      INSERT INTO message_intent_overlays (
        message_ss_id,
        is_saved,
        created_at_utc,
        updated_at_utc
      ) VALUES (?, 1, ?, ?)
      ''',
      <Object?>[3001, _now, _now],
    );

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: const [],
      matchAnyTerm: false,
      filterSaved: true,
    );

    expect(results, <int>[3001]);
  });

  test(
    'uses unique GUID-keyed saved overlay as compatibility bridge',
    () async {
      await _insertMessage(
        graphDatabase,
        messageId: 4001,
        guid: 'guid-4001',
        text: 'GUID-keyed saved message.',
        dateUtc: '2026-05-01T12:00:00Z',
      );
      await overlayDatabase.setMessageSaved(
        messageGuid: 'guid-4001',
        isSaved: true,
      );

      final results = await repository.searchMessageIds(
        scope: const GraphMessageSearchScope.global(),
        textTokens: const [],
        matchAnyTerm: false,
        filterSaved: true,
      );

      expect(results, <int>[4001]);
    },
  );

  test(
    'does not use GUID-keyed saved overlay when GUID is ambiguous',
    () async {
      await _insertMessage(
        graphDatabase,
        messageId: 5001,
        guid: 'shared-guid',
        text: 'First occurrence.',
        dateUtc: '2026-05-01T12:00:00Z',
      );
      await _insertMessage(
        graphDatabase,
        messageId: 5002,
        guid: 'shared-guid',
        text: 'Second occurrence.',
        dateUtc: '2026-05-02T12:00:00Z',
      );
      await overlayDatabase.setMessageSaved(
        messageGuid: 'shared-guid',
        isSaved: true,
      );

      final results = await repository.searchMessageIds(
        scope: const GraphMessageSearchScope.global(),
        textTokens: const [],
        matchAnyTerm: false,
        filterSaved: true,
      );

      expect(results, isEmpty);
    },
  );

  test('searches graph-native tags by message_ss_id', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 6001,
      guid: 'guid-6001',
      text: 'Ordinary text.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await overlayDatabase.customStatement(
      '''
      INSERT INTO message_intent_tags (
        message_ss_id,
        tag_display,
        tag_normalized,
        created_at_utc,
        updated_at_utc
      ) VALUES (?, ?, ?, ?, ?)
      ''',
      <Object?>[6001, 'Legal review', 'legal review', _now, _now],
    );

    final prefixResults = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: const [PrefixMessageTextSearchToken('legal')],
      matchAnyTerm: false,
      filterSaved: false,
    );
    final exactResults = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: const [ExactMessageTextSearchToken('legal')],
      matchAnyTerm: false,
      filterSaved: false,
    );

    expect(prefixResults, <int>[6001]);
    expect(exactResults, <int>[6001]);
  });

  test('intersects FTS or tag results with saved state', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 6101,
      guid: 'guid-6101',
      text: 'Invoice in visible text.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 6102,
      guid: 'guid-6102',
      text: 'Another invoice in visible text.',
      dateUtc: '2026-05-02T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 6103,
      guid: 'guid-6103',
      text: 'No text match.',
      dateUtc: '2026-05-03T12:00:00Z',
    );
    await overlayDatabase.customStatement(
      '''
      INSERT INTO message_intent_tags (
        message_ss_id,
        tag_display,
        tag_normalized,
        created_at_utc,
        updated_at_utc
      ) VALUES (?, ?, ?, ?, ?)
      ''',
      <Object?>[6103, 'Invoice', 'invoice', _now, _now],
    );
    for (final messageId in <int>[6102, 6103]) {
      await overlayDatabase.customStatement(
        '''
        INSERT INTO message_intent_overlays (
          message_ss_id,
          is_saved,
          created_at_utc,
          updated_at_utc
        ) VALUES (?, 1, ?, ?)
        ''',
        <Object?>[messageId, _now, _now],
      );
    }

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: const [ExactMessageTextSearchToken('invoice')],
      matchAnyTerm: false,
      filterSaved: true,
    );

    expect(results, <int>[6103, 6102]);
  });

  test('combines text and tag evidence per term in AND and OR modes', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 6201,
      guid: 'guid-6201',
      text: 'Invoice from accountant.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 6202,
      guid: 'guid-6202',
      text: 'Invoice only.',
      dateUtc: '2026-05-02T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 6203,
      guid: 'guid-6203',
      text: 'Holiday plans.',
      dateUtc: '2026-05-03T12:00:00Z',
    );
    await _insertGraphNativeTag(
      overlayDatabase,
      messageId: 6201,
      display: 'Tax',
      normalized: 'tax',
    );
    await _insertGraphNativeTag(
      overlayDatabase,
      messageId: 6203,
      display: 'Tax',
      normalized: 'tax',
    );
    const tokens = <MessageTextSearchToken>[
      ExactMessageTextSearchToken('invoice'),
      PrefixMessageTextSearchToken('tax'),
    ];

    final allResults = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: tokens,
      matchAnyTerm: false,
      filterSaved: false,
    );
    final anyResults = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: tokens,
      matchAnyTerm: true,
      filterSaved: false,
    );

    expect(allResults, <int>[6201]);
    expect(anyResults, <int>[6203, 6202, 6201]);
  });

  test('combines separate tags on one message in AND and OR modes', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 6301,
      guid: 'guid-6301',
      text: 'Unrelated text.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertGraphNativeTag(
      overlayDatabase,
      messageId: 6301,
      display: 'Tax',
      normalized: 'tax',
    );
    await _insertGraphNativeTag(
      overlayDatabase,
      messageId: 6301,
      display: 'Urgent',
      normalized: 'urgent',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 6302,
      guid: 'guid-6302',
      text: 'Other unrelated text.',
      dateUtc: '2026-05-02T12:00:00Z',
    );
    await _insertGraphNativeTag(
      overlayDatabase,
      messageId: 6302,
      display: 'Tax',
      normalized: 'tax',
    );
    const tokens = <MessageTextSearchToken>[
      ExactMessageTextSearchToken('tax'),
      ExactMessageTextSearchToken('urgent'),
    ];

    final allResults = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: tokens,
      matchAnyTerm: false,
      filterSaved: false,
    );
    final anyResults = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: tokens,
      matchAnyTerm: true,
      filterSaved: false,
    );

    expect(allResults, <int>[6301]);
    expect(anyResults, <int>[6302, 6301]);
  });

  test('deduplicates a term matched by both text and tags', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 6401,
      guid: 'guid-6401',
      text: 'Invoice in message text.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertGraphNativeTag(
      overlayDatabase,
      messageId: 6401,
      display: 'Invoice',
      normalized: 'invoice',
    );

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: const <MessageTextSearchToken>[
        ExactMessageTextSearchToken('invoice'),
      ],
      matchAnyTerm: true,
      filterSaved: false,
    );

    expect(results, <int>[6401]);
  });

  test('applies saved filtering before the final result limit', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 6501,
      guid: 'guid-6501',
      text: 'Invoice saved.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 6502,
      guid: 'guid-6502',
      text: 'Invoice unsaved.',
      dateUtc: '2026-05-02T12:00:00Z',
    );
    await overlayDatabase.customStatement(
      '''
      INSERT INTO message_intent_overlays (
        message_ss_id,
        is_saved,
        created_at_utc,
        updated_at_utc
      ) VALUES (?, 1, ?, ?)
      ''',
      <Object?>[6501, _now, _now],
    );

    for (final matchAnyTerm in <bool>[false, true]) {
      final results = await repository.searchMessageIds(
        scope: const GraphMessageSearchScope.global(),
        textTokens: const <MessageTextSearchToken>[
          ExactMessageTextSearchToken('invoice'),
        ],
        matchAnyTerm: matchAnyTerm,
        filterSaved: true,
        limit: 1,
      );

      expect(results, <int>[6501]);
    }
  });

  test(
    'does not lose saved matches beyond 500 preliminary text candidates',
    () async {
      await graphDatabase.transaction(() async {
        for (var index = 1; index <= 501; index++) {
          await _insertMessage(
            graphDatabase,
            messageId: 6550 + index,
            guid: 'guid-saved-cap-$index',
            text: 'Invoice candidate.',
            dateUtc: '2026-05-02T12:00:00Z',
          );
        }
        await _insertMessage(
          graphDatabase,
          messageId: 6550,
          guid: 'guid-saved-cap-target',
          text: 'Invoice saved target.',
          dateUtc: '2026-05-01T12:00:00Z',
        );
      });
      await overlayDatabase.customStatement(
        '''
        INSERT INTO message_intent_overlays (
          message_ss_id,
          is_saved,
          created_at_utc,
          updated_at_utc
        ) VALUES (?, 1, ?, ?)
        ''',
        <Object?>[6550, _now, _now],
      );

      final results = await repository.searchMessageIds(
        scope: const GraphMessageSearchScope.global(),
        textTokens: const <MessageTextSearchToken>[
          ExactMessageTextSearchToken('invoice'),
        ],
        matchAnyTerm: false,
        filterSaved: true,
      );

      expect(results, <int>[6550]);
    },
  );

  test('orders cross-domain matches before applying the final limit', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 6601,
      guid: 'guid-6601',
      text: 'Unrelated older text.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 6602,
      guid: 'guid-6602',
      text: 'Invoice in newer text.',
      dateUtc: '2026-05-02T12:00:00Z',
    );
    await _insertGraphNativeTag(
      overlayDatabase,
      messageId: 6601,
      display: 'Invoice',
      normalized: 'invoice',
    );

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: const <MessageTextSearchToken>[
        ExactMessageTextSearchToken('invoice'),
      ],
      matchAnyTerm: false,
      filterSaved: false,
      limit: 1,
    );

    expect(results, <int>[6602]);
  });

  test('applies scope before limiting tag results', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 6701,
      guid: 'guid-6701',
      text: 'Scoped message.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 6702,
      guid: 'guid-6702',
      text: 'Outside message.',
      dateUtc: '2026-05-02T12:00:00Z',
    );
    await _insertChatMessage(graphDatabase, chatId: 671, messageId: 6701);
    await _insertChatMessage(graphDatabase, chatId: 672, messageId: 6702);
    await _insertGraphNativeTag(
      overlayDatabase,
      messageId: 6701,
      display: 'Tax',
      normalized: 'tax',
    );
    await _insertGraphNativeTag(
      overlayDatabase,
      messageId: 6702,
      display: 'Tax',
      normalized: 'tax',
    );

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.conversation(671),
      textTokens: const <MessageTextSearchToken>[
        ExactMessageTextSearchToken('tax'),
      ],
      matchAnyTerm: false,
      filterSaved: false,
      limit: 1,
    );

    expect(results, <int>[6701]);
  });

  test('keeps saved as a filter in multi-term AND and OR modes', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 6801,
      guid: 'guid-6801',
      text: 'Invoice saved cross-domain.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 6802,
      guid: 'guid-6802',
      text: 'Invoice saved text-only.',
      dateUtc: '2026-05-02T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 6803,
      guid: 'guid-6803',
      text: 'Invoice unsaved.',
      dateUtc: '2026-05-03T12:00:00Z',
    );
    await _insertGraphNativeTag(
      overlayDatabase,
      messageId: 6801,
      display: 'Tax',
      normalized: 'tax',
    );
    for (final messageId in <int>[6801, 6802]) {
      await overlayDatabase.customStatement(
        '''
        INSERT INTO message_intent_overlays (
          message_ss_id,
          is_saved,
          created_at_utc,
          updated_at_utc
        ) VALUES (?, 1, ?, ?)
        ''',
        <Object?>[messageId, _now, _now],
      );
    }
    const tokens = <MessageTextSearchToken>[
      ExactMessageTextSearchToken('invoice'),
      ExactMessageTextSearchToken('tax'),
    ];

    final allResults = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: tokens,
      matchAnyTerm: false,
      filterSaved: true,
    );
    final anyResults = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: tokens,
      matchAnyTerm: true,
      filterSaved: true,
    );

    expect(allResults, <int>[6801]);
    expect(anyResults, <int>[6802, 6801]);
  });

  test('evaluates cross-domain AND inside the selected scope', () async {
    for (final messageId in <int>[6901, 6902]) {
      await _insertMessage(
        graphDatabase,
        messageId: messageId,
        guid: 'guid-$messageId',
        text: 'Invoice in scoped text.',
        dateUtc: messageId == 6901
            ? '2026-05-01T12:00:00Z'
            : '2026-05-02T12:00:00Z',
      );
      await _insertGraphNativeTag(
        overlayDatabase,
        messageId: messageId,
        display: 'Tax',
        normalized: 'tax',
      );
    }
    await _insertChatMessage(graphDatabase, chatId: 691, messageId: 6901);
    await _insertChatMessage(graphDatabase, chatId: 692, messageId: 6902);

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.conversation(691),
      textTokens: const <MessageTextSearchToken>[
        ExactMessageTextSearchToken('invoice'),
        ExactMessageTextSearchToken('tax'),
      ],
      matchAnyTerm: false,
      filterSaved: false,
    );

    expect(results, <int>[6901]);
  });

  test('includes unique GUID-keyed tags in per-term composition', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 7001,
      guid: 'guid-7001',
      text: 'Invoice from compatibility message.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await overlayDatabase.addMessageUserTags(
      messageGuid: 'guid-7001',
      tags: const <String>['Tax'],
    );

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      textTokens: const <MessageTextSearchToken>[
        ExactMessageTextSearchToken('invoice'),
        ExactMessageTextSearchToken('tax'),
      ],
      matchAnyTerm: false,
      filterSaved: false,
    );

    expect(results, <int>[7001]);
  });
}

const _now = '2026-05-30T12:00:00Z';

Future<void> _insertMessage(
  ConversationGraphDatabase graphDatabase, {
  required int messageId,
  required String guid,
  required String text,
  required String dateUtc,
  int? senderHandleId,
  int? senderCanonicalHandleId,
}) {
  return graphDatabase.database.insert('messages', <String, Object?>{
    'ss_id': messageId,
    'guid': guid,
    'is_from_me': 0,
    'date_utc': dateUtc,
    'text': text,
    'sender_handle_ss_id': senderHandleId,
    'sender_canonical_handle_ss_id': senderCanonicalHandleId,
  });
}

Future<void> _insertGraphNativeTag(
  OverlayDatabase overlayDatabase, {
  required int messageId,
  required String display,
  required String normalized,
}) {
  return overlayDatabase.customStatement(
    '''
    INSERT INTO message_intent_tags (
      message_ss_id,
      tag_display,
      tag_normalized,
      created_at_utc,
      updated_at_utc
    ) VALUES (?, ?, ?, ?, ?)
    ''',
    <Object?>[messageId, display, normalized, _now, _now],
  );
}

Future<void> _insertHandle(
  ConversationGraphDatabase graphDatabase, {
  required int handleId,
  required String rawIdentifier,
}) {
  return graphDatabase.database.insert('handles', <String, Object?>{
    'ss_id': handleId,
    'id': rawIdentifier,
  });
}

Future<void> _insertCanonicalHandle(
  ConversationGraphDatabase graphDatabase, {
  required int canonicalHandleId,
}) {
  return graphDatabase.database.insert('canonical_handles', <String, Object?>{
    'canonical_handle_ss_id': canonicalHandleId,
    'display_handle': '+16049995969',
    'normalized_identifier': '16049995969',
    'alias_count': 2,
  });
}

Future<void> _insertHandleAlias(
  ConversationGraphDatabase graphDatabase, {
  required int handleId,
  required int canonicalHandleId,
  required String rawIdentifier,
}) {
  return graphDatabase.database.insert('handle_aliases', <String, Object?>{
    'handle_ss_id': handleId,
    'canonical_handle_ss_id': canonicalHandleId,
    'raw_identifier': rawIdentifier,
    'normalized_identifier': '16049995969',
    'alias_kind': 'phone',
  });
}

Future<void> _insertChatMessage(
  ConversationGraphDatabase graphDatabase, {
  required int chatId,
  required int messageId,
}) {
  return graphDatabase.database.insert('chat_to_message', <String, Object?>{
    'chat_ss_id': chatId,
    'message_ss_id': messageId,
  });
}

Future<void> _insertChatHandle(
  ConversationGraphDatabase graphDatabase, {
  required int chatId,
  required int handleId,
}) {
  return graphDatabase.database.insert('chat_to_handle', <String, Object?>{
    'chat_ss_id': chatId,
    'handle_ss_id': handleId,
  });
}

Future<List<int>> _search(
  SqliteGraphSearchRepository repository,
  MessageTextSearchToken token,
) {
  return repository.searchMessageIds(
    scope: const GraphMessageSearchScope.global(),
    textTokens: <MessageTextSearchToken>[token],
    matchAnyTerm: false,
    filterSaved: false,
  );
}
