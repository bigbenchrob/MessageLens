import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/db/feature_level_providers.dart';
import '../../essentials/logging/application/message_logger.dart';
import '../../providers.dart';
import 'application/search_service.dart';
import 'indexing/fts_multi_term_indexer.dart';
import 'indexing/search_index_metrics_repository.dart';
import 'indexing/search_index_orchestrator.dart';
import 'indexing/search_indexer.dart';
import 'indexing/simple_lexical_indexer.dart';

part 'search_feature_providers.g.dart';

@riverpod
SearchService searchService(SearchServiceRef ref) {
  return SearchService(ref: ref);
}

@riverpod
SearchIndexMetricsRepository searchIndexMetricsRepository(
  SearchIndexMetricsRepositoryRef ref,
) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return SearchIndexMetricsRepository(preferences: prefsAsync.valueOrNull);
}

@riverpod
List<SearchIndexer> searchIndexers(SearchIndexersRef ref) {
  return [
    SimpleLexicalIndexer(),
    FtsMultiTermIndexer(),
  ];
}

@riverpod
bool useFtsSearchByDefault(UseFtsSearchByDefaultRef ref) => false;

@riverpod
SearchIndexOrchestrator searchIndexOrchestrator(
  SearchIndexOrchestratorRef ref,
) {
  final indexers = ref.watch(searchIndexersProvider);
  final metricsRepository = ref.watch(searchIndexMetricsRepositoryProvider);
  final logger = ref.read(messageLoggerProvider.notifier);

  Future<SearchIndexContext> buildContext() async {
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    return SearchIndexContext(
      db: db,
      infoLogger: (message, {context = const {}}) {
        logger.info(message, source: 'SearchIndex', context: context);
      },
      errorLogger: (message, {context = const {}}) {
        logger.error(message, source: 'SearchIndex', context: context);
      },
    );
  }

  return SearchIndexOrchestrator(
    indexers: indexers,
    contextBuilder: buildContext,
    metricsRepository: metricsRepository,
    onInfo: (message, {context = const {}}) {
      logger.info(message, source: 'SearchIndex', context: context);
    },
    onError: (message, {context = const {}}) {
      logger.error(message, source: 'SearchIndex', context: context);
    },
  );
}
