enum SourceImportPageStage { messages, richText }

enum SourceImportPageOutcome { completed, failed }

final class SourceImportPageMetric {
  const SourceImportPageMetric({
    required this.stage,
    required this.outcome,
    required this.pageOrdinal,
    required this.pageRowCount,
    required this.cumulativeCompletedCount,
    required this.totalWorkCount,
    required this.totalBlobBytes,
    required this.maximumBlobBytes,
    required this.elapsedMilliseconds,
  });

  final SourceImportPageStage stage;
  final SourceImportPageOutcome outcome;
  final int pageOrdinal;
  final int pageRowCount;
  final int cumulativeCompletedCount;
  final int totalWorkCount;
  final int totalBlobBytes;
  final int maximumBlobBytes;
  final int elapsedMilliseconds;

  Map<String, dynamic> toLogContext() {
    return <String, dynamic>{
      'stage': stage.name,
      'outcome': outcome.name,
      'pageOrdinal': pageOrdinal,
      'pageRowCount': pageRowCount,
      'cumulativeCompletedCount': cumulativeCompletedCount,
      'totalWorkCount': totalWorkCount,
      'totalBlobBytes': totalBlobBytes,
      'maximumBlobBytes': maximumBlobBytes,
      'elapsedMilliseconds': elapsedMilliseconds,
    };
  }
}

typedef SourceImportPageMetricObserver =
    void Function(SourceImportPageMetric metric);
