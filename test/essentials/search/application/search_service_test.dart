import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/search/application/graph_message_search.dart';
import 'package:remember_this_text/essentials/search/application/graph_search_repository_provider.dart';
import 'package:remember_this_text/essentials/search/application/message_text_search_query.dart';
import 'package:remember_this_text/essentials/search/application/search_service.dart';
import 'package:remember_this_text/essentials/search/application/search_service_provider.dart';

void main() {
  test(
    'searchGraphMessageIds delegates graph scope and parsed tokens',
    () async {
      final repository = _FakeGraphSearchRepository(resultIds: const [11, 12]);
      final container = _container(repository);
      addTearDown(container.dispose);

      final service = container.read(searchServiceProvider);
      final resultIds = await service.searchGraphMessageIds(
        scope: const GraphMessageSearchScope.conversation(42),
        query: 'settlement offer',
      );

      expect(resultIds, const [11, 12]);
      expect(repository.requests, hasLength(1));
      expect(
        repository.requests.single.scope.type,
        GraphMessageSearchScopeType.conversation,
      );
      expect(repository.requests.single.scope.id, 42);
      expect(repository.requests.single.textTokens, const [
        ExactMessageTextSearchToken('settlement'),
        PrefixMessageTextSearchToken('offer'),
      ]);
      expect(repository.requests.single.matchAnyTerm, isFalse);
      expect(repository.requests.single.filterSaved, isFalse);
    },
  );

  test('searchGraphMessageIds preserves any-term search mode', () async {
    final repository = _FakeGraphSearchRepository(resultIds: const [99]);
    final container = _container(repository);
    addTearDown(container.dispose);

    final service = container.read(searchServiceProvider);
    await service.searchGraphMessageIds(
      scope: const GraphMessageSearchScope.global(),
      query: 'flower invoice',
      mode: SearchMode.anyTerm,
    );

    expect(repository.requests.single.matchAnyTerm, isTrue);
  });

  test('does not execute an unfinished one-character prefix', () async {
    final repository = _FakeGraphSearchRepository(resultIds: const [99]);
    final container = _container(repository);
    addTearDown(container.dispose);

    final service = container.read(searchServiceProvider);
    final resultIds = await service.searchGraphMessageIds(
      scope: const GraphMessageSearchScope.global(),
      query: 'p',
    );

    expect(resultIds, isEmpty);
    expect(repository.requests, isEmpty);
  });

  test('passes exact and prefix token kinds to the repository', () async {
    final repository = _FakeGraphSearchRepository(resultIds: const [8]);
    final container = _container(repository);
    addTearDown(container.dispose);
    final service = container.read(searchServiceProvider);

    const cases = <(String, List<MessageTextSearchToken>)>[
      ('p ', [ExactMessageTextSearchToken('p')]),
      ('po', [PrefixMessageTextSearchToken('po')]),
      ('post', [PrefixMessageTextSearchToken('post')]),
      ('post ', [ExactMessageTextSearchToken('post')]),
      (
        'bass pl',
        [
          ExactMessageTextSearchToken('bass'),
          PrefixMessageTextSearchToken('pl'),
        ],
      ),
    ];

    for (final (query, expectedTokens) in cases) {
      await service.searchGraphMessageIds(
        scope: const GraphMessageSearchScope.global(),
        query: query,
      );

      expect(repository.requests.last.textTokens, expectedTokens);
    }
  });

  test(
    'executes an existing structured intent without reparsing raw text',
    () async {
      final repository = _FakeGraphSearchRepository(resultIds: const [8]);
      final container = _container(repository);
      addTearDown(container.dispose);
      final service = container.read(searchServiceProvider);
      final intent = MessageTextSearchQuery.parse('post ').executionIntent;

      await service.searchGraphMessageIdsForIntent(
        scope: const GraphMessageSearchScope.global(),
        intent: intent,
      );

      expect(repository.requests.single.textTokens, const [
        ExactMessageTextSearchToken('post'),
      ]);
    },
  );

  test(
    'searchGraphMessageIds structurally parses saved operator and text intent',
    () async {
      final repository = _FakeGraphSearchRepository(resultIds: const [77]);
      final container = _container(repository);
      addTearDown(container.dispose);

      final service = container.read(searchServiceProvider);
      final resultIds = await service.searchGraphMessageIds(
        scope: const GraphMessageSearchScope.global(),
        query: 'is:saved archive plan',
      );

      expect(resultIds, const [77]);
      expect(repository.requests.single.textTokens, const [
        ExactMessageTextSearchToken('archive'),
        PrefixMessageTextSearchToken('plan'),
      ]);
      expect(repository.requests.single.filterSaved, isTrue);
    },
  );

  test('searchGraphMessageIds can request saved-only graph evidence', () async {
    final repository = _FakeGraphSearchRepository(resultIds: const [31]);
    final container = _container(repository);
    addTearDown(container.dispose);

    final service = container.read(searchServiceProvider);
    final resultIds = await service.searchGraphMessageIds(
      scope: const GraphMessageSearchScope.handle(10),
      query: 'is:saved',
    );

    expect(resultIds, const [31]);
    expect(repository.requests.single.textTokens, isEmpty);
    expect(repository.requests.single.filterSaved, isTrue);
  });

  test('empty search does not hit repository', () async {
    final repository = _FakeGraphSearchRepository(resultIds: const [1]);
    final container = _container(repository);
    addTearDown(container.dispose);

    final service = container.read(searchServiceProvider);
    final resultIds = await service.searchGraphMessageIds(
      scope: const GraphMessageSearchScope.global(),
      query: '   ',
    );

    expect(resultIds, isEmpty);
    expect(repository.requests, isEmpty);
  });

  test(
    'equivalent execution intent does not require reconstructed raw input',
    () async {
      final repository = _FakeGraphSearchRepository(resultIds: const [8]);
      final container = _container(repository);
      addTearDown(container.dispose);

      final service = container.read(searchServiceProvider);
      await service.searchGraphMessageIds(
        scope: const GraphMessageSearchScope.global(),
        query: 'flower ',
      );
      await service.searchGraphMessageIds(
        scope: const GraphMessageSearchScope.global(),
        query: 'flower    ',
      );

      expect(repository.requests, hasLength(2));
      expect(repository.requests.first.textTokens, const [
        ExactMessageTextSearchToken('flower'),
      ]);
      expect(
        repository.requests.last.textTokens,
        repository.requests.first.textTokens,
      );
    },
  );
}

ProviderContainer _container(_FakeGraphSearchRepository repository) {
  return ProviderContainer(
    overrides: [
      graphSearchRepositoryProvider.overrideWith((ref) async {
        return repository;
      }),
    ],
  );
}

class _FakeGraphSearchRepository implements GraphSearchRepository {
  _FakeGraphSearchRepository({required this.resultIds});

  final List<int> resultIds;
  final requests = <_SearchRequest>[];

  @override
  Future<List<int>> searchMessageIds({
    required GraphMessageSearchScope scope,
    required List<MessageTextSearchToken> textTokens,
    required bool matchAnyTerm,
    required bool filterSaved,
    int limit = graphSearchResultLimit,
  }) async {
    requests.add(
      _SearchRequest(
        scope: scope,
        textTokens: textTokens,
        matchAnyTerm: matchAnyTerm,
        filterSaved: filterSaved,
        limit: limit,
      ),
    );
    return resultIds;
  }
}

class _SearchRequest {
  const _SearchRequest({
    required this.scope,
    required this.textTokens,
    required this.matchAnyTerm,
    required this.filterSaved,
    required this.limit,
  });

  final GraphMessageSearchScope scope;
  final List<MessageTextSearchToken> textTokens;
  final bool matchAnyTerm;
  final bool filterSaved;
  final int limit;
}
