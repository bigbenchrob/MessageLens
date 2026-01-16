import 'search_index_metrics_repository.dart';
import 'search_indexer.dart';

typedef SearchIndexContextBuilder = Future<SearchIndexContext> Function();
typedef _LogFn = void Function(String message, {Map<String, dynamic> context});

class SearchIndexOrchestrator {
  SearchIndexOrchestrator({
    required List<SearchIndexer> indexers,
    required SearchIndexContextBuilder contextBuilder,
    required SearchIndexMetricsRepository metricsRepository,
    _LogFn? onInfo,
    _LogFn? onError,
  }) : _indexers = indexers,
       _contextBuilder = contextBuilder,
       _metricsRepository = metricsRepository,
       _logInfo = onInfo,
       _logError = onError;

  final List<SearchIndexer> _indexers;
  final SearchIndexContextBuilder _contextBuilder;
  final SearchIndexMetricsRepository _metricsRepository;
  final _LogFn? _logInfo;
  final _LogFn? _logError;

  Future<void> rebuildAll() async {
    final context = await _contextBuilder();
    final failures = <String, Object>{};

    for (final indexer in _indexers) {
      final success = await _runIndexerOperation(
        context: context,
        indexer: indexer,
        operationName: 'rebuildAll',
        operation: (ctx) => indexer.rebuildAll(ctx),
      );
      if (!success.$1) {
        failures[indexer.id] = success.$2!;
      }
    }

    if (failures.isNotEmpty) {
      throw SearchIndexOrchestratorException(failures);
    }
  }

  Future<void> rebuildForMessages(Iterable<int> messageIds) async {
    if (messageIds.isEmpty) {
      return;
    }
    final context = await _contextBuilder();
    final failures = <String, Object>{};

    for (final indexer in _indexers) {
      if (!indexer.supportsPartialRebuild) {
        continue;
      }

      final success = await _runIndexerOperation(
        context: context,
        indexer: indexer,
        operationName: 'rebuildForMessages',
        messageCount: messageIds.length,
        operation: (ctx) => indexer.rebuildForMessages(ctx, messageIds),
      );

      if (!success.$1) {
        failures[indexer.id] = success.$2!;
      }
    }

    if (failures.isNotEmpty) {
      throw SearchIndexOrchestratorException(failures);
    }
  }

  Future<void> validateAll() async {
    final context = await _contextBuilder();
    final failures = <String, Object>{};

    for (final indexer in _indexers) {
      final success = await _runIndexerOperation(
        context: context,
        indexer: indexer,
        operationName: 'validate',
        recordMetrics: false,
        operation: (ctx) => indexer.validate(ctx),
      );

      if (!success.$1) {
        failures[indexer.id] = success.$2!;
      }
    }

    if (failures.isNotEmpty) {
      throw SearchIndexOrchestratorException(failures);
    }
  }

  Future<(bool, Object?)> _runIndexerOperation({
    required SearchIndexContext context,
    required SearchIndexer indexer,
    required String operationName,
    required Future<void> Function(SearchIndexContext ctx) operation,
    int? messageCount,
    bool recordMetrics = true,
  }) async {
    final startedAt = context.currentTime;
    _logInfo?.call(
      '[SearchIndexOrchestrator] Starting $operationName for ${indexer.id}',
    );

    if (recordMetrics) {
      await _metricsRepository.save(
        indexer.id,
        SearchIndexerRunRecord(
          lastRebuildStartedAt: startedAt,
          status: SearchIndexerRunStatus.idle,
          lastRebuildMessageCount: messageCount,
        ),
      );
    }

    try {
      await operation(context);
      final finishedAt = context.currentTime;
      _logInfo?.call(
        '[SearchIndexOrchestrator] Completed $operationName for ${indexer.id}',
      );

      if (recordMetrics) {
        await _metricsRepository.save(
          indexer.id,
          SearchIndexerRunRecord(
            lastRebuildStartedAt: startedAt,
            lastRebuildFinishedAt: finishedAt,
            status: SearchIndexerRunStatus.succeeded,
            lastRebuildMessageCount: messageCount,
          ),
        );
      }
      return (true, null);
    } catch (error, stackTrace) {
      _logError?.call(
        '[SearchIndexOrchestrator] $operationName failed for ${indexer.id}: $error',
        context: {'stackTrace': stackTrace.toString()},
      );

      if (recordMetrics) {
        await _metricsRepository.save(
          indexer.id,
          SearchIndexerRunRecord(
            lastRebuildStartedAt: startedAt,
            lastRebuildFinishedAt: context.currentTime,
            status: SearchIndexerRunStatus.failed,
            lastRebuildMessageCount: messageCount,
            lastMessage: '$operationName failed: $error',
          ),
        );
      }
      return (false, error);
    }
  }
}

class SearchIndexOrchestratorException implements Exception {
  SearchIndexOrchestratorException(this.failures);

  final Map<String, Object> failures;

  @override
  String toString() {
    final joined = failures.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('; ');
    return 'SearchIndexOrchestratorException($joined)';
  }
}
