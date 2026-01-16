import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/search/indexing/search_index_metrics_repository.dart';
import 'package:remember_this_text/essentials/search/indexing/search_index_orchestrator.dart';
import 'package:remember_this_text/essentials/search/indexing/search_indexer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late WorkingDatabase db;
  late SearchIndexMetricsRepository metricsRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = WorkingDatabase(NativeDatabase.memory());
    final prefs = await SharedPreferences.getInstance();
    metricsRepository = SearchIndexMetricsRepository(preferences: prefs);
  });

  tearDown(() async {
    await db.close();
  });

  Future<SearchIndexContext> buildContext(List<String> logs) async {
    return SearchIndexContext(
      db: db,
      infoLogger: (message, {context = const {}}) {
        logs.add('info:$message');
      },
      errorLogger: (message, {context = const {}}) {
        logs.add('error:$message');
      },
    );
  }

  test(
    'rebuildAll executes indexers sequentially and records metrics',
    () async {
      final callLog = <String>[];
      final indexers = [
        _FakeIndexer('alpha', callLog),
        _FakeIndexer('beta', callLog),
      ];
      final orchestrator = SearchIndexOrchestrator(
        indexers: indexers,
        contextBuilder: () => buildContext([]),
        metricsRepository: metricsRepository,
      );

      await orchestrator.rebuildAll();

      expect(callLog, ['alpha:rebuildAll', 'beta:rebuildAll']);

      final record = await metricsRepository.load('alpha');
      expect(record?.status, SearchIndexerRunStatus.succeeded);
      expect(record?.lastRebuildStartedAt, isNotNull);
      expect(record?.lastRebuildFinishedAt, isNotNull);
    },
  );

  test('rebuildAll isolates failures and surfaces summary', () async {
    final callLog = <String>[];
    final indexers = [
      _FakeIndexer('alpha', callLog, failRebuildAll: true),
      _FakeIndexer('beta', callLog),
    ];
    final orchestrator = SearchIndexOrchestrator(
      indexers: indexers,
      contextBuilder: () => buildContext([]),
      metricsRepository: metricsRepository,
    );

    await expectLater(
      () => orchestrator.rebuildAll(),
      throwsA(isA<SearchIndexOrchestratorException>()),
    );
    expect(callLog, ['alpha:rebuildAll', 'beta:rebuildAll']);

    final alphaMetrics = await metricsRepository.load('alpha');
    final betaMetrics = await metricsRepository.load('beta');
    expect(alphaMetrics?.status, SearchIndexerRunStatus.failed);
    expect(betaMetrics?.status, SearchIndexerRunStatus.succeeded);
  });

  test('rebuildForMessages skips indexers without partial rebuild', () async {
    final callLog = <String>[];
    final indexers = [
      _FakeIndexer('alpha', callLog),
      _FakeIndexer('beta', callLog, supportsPartial: true),
    ];
    final orchestrator = SearchIndexOrchestrator(
      indexers: indexers,
      contextBuilder: () => buildContext([]),
      metricsRepository: metricsRepository,
    );

    await orchestrator.rebuildForMessages(const {1, 2, 3});

    expect(callLog, ['beta:rebuildForMessages(3)']);
  });

  test('validateAll does not record metrics', () async {
    final callLog = <String>[];
    final indexers = [
      _FakeIndexer('alpha', callLog),
      _FakeIndexer('beta', callLog),
    ];

    final orchestrator = SearchIndexOrchestrator(
      indexers: indexers,
      contextBuilder: () => buildContext([]),
      metricsRepository: metricsRepository,
    );

    await orchestrator.validateAll();
    final record = await metricsRepository.load('alpha');
    expect(record, isNull);
  });
}

class _FakeIndexer implements SearchIndexer {
  _FakeIndexer(
    this.id,
    this.callLog, {
    this.supportsPartial = false,
    this.failRebuildAll = false,
  });

  @override
  final String id;
  final List<String> callLog;
  final bool supportsPartial;
  final bool failRebuildAll;

  @override
  bool get supportsPartialRebuild => supportsPartial;

  @override
  String get description => id;

  @override
  Future<void> rebuildAll(SearchIndexContext context) async {
    callLog.add('$id:rebuildAll');
    if (failRebuildAll) {
      throw StateError('$id failed');
    }
  }

  @override
  Future<void> rebuildForMessages(
    SearchIndexContext context,
    Iterable<int> messageIds,
  ) async {
    callLog.add('$id:rebuildForMessages(${messageIds.length})');
  }

  @override
  Future<void> validate(SearchIndexContext context) async {
    callLog.add('$id:validate');
  }
}
