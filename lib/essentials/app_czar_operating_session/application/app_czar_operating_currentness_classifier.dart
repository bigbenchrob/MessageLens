import '../../app_czar/domain/app_czar_models.dart';
import '../domain/app_czar_operating_currentness_models.dart';

AppCzarOperatingCurrentnessDecision classifyAppCzarOperatingCurrentness(
  AppCzarOperatingCurrentnessObservation observation,
) {
  if (!observation.isCoherent) {
    return const AppCzarOperatingCurrentnessDecision(
      disposition: AppCzarOperatingCurrentnessDisposition.transient,
      detail:
          'The current source/local sample crossed a local mutation or archive-location revision.',
    );
  }

  final source = observation.source!;
  switch (source.condition) {
    case AppCzarSourceCondition.accessDenied:
    case AppCzarSourceCondition.unavailable:
      return AppCzarOperatingCurrentnessDecision(
        disposition: AppCzarOperatingCurrentnessDisposition.sourceUnreadable,
        detail: source.issue ?? 'The Messages source is no longer readable.',
      );
    case AppCzarSourceCondition.unknown:
      return AppCzarOperatingCurrentnessDecision(
        disposition: AppCzarOperatingCurrentnessDisposition.sourceUnknown,
        detail:
            source.issue ??
            'Current evidence does not establish whether the Messages source is readable.',
      );
    case AppCzarSourceCondition.readable:
      break;
  }

  if (source.sampleStable != true) {
    return AppCzarOperatingCurrentnessDecision(
      disposition: AppCzarOperatingCurrentnessDisposition.sourceUnstable,
      detail: source.sampleStable == false
          ? 'The Messages source changed during its bounded sample.'
          : 'A stable Messages source sample could not be established.',
    );
  }

  final importStore = observation.importStore!;
  final graphStore = observation.graphStore!;
  final importCount = importStore.messageCount;
  final graphCount = graphStore.messageCount;
  final liveCount = importStore.liveMessageCount;
  final liveHighWater = importStore.liveMaxSourceRowId;
  final sourceCount = source.messageCount;
  final sourceHighWater = source.maxRowId;
  if (importStore.condition != AppCzarDatabaseCondition.healthy ||
      graphStore.condition != AppCzarDatabaseCondition.healthy ||
      importCount == null ||
      importCount <= 0 ||
      graphCount == null ||
      graphCount != importCount ||
      (graphStore.chatCount ?? 0) <= 0 ||
      (graphStore.chatMessageEdgeCount ?? 0) <= 0 ||
      liveCount == null ||
      liveCount < 0 ||
      liveCount > importCount ||
      liveHighWater == null ||
      liveHighWater < 0 ||
      sourceCount == null ||
      sourceCount < 0 ||
      sourceHighWater == null ||
      sourceHighWater < 0) {
    return const AppCzarOperatingCurrentnessDecision(
      disposition: AppCzarOperatingCurrentnessDisposition.localContradiction,
      detail:
          'Current import and graph evidence does not establish one coherent local dataset.',
    );
  }

  if (sourceCount < liveCount || sourceHighWater < liveHighWater) {
    return AppCzarOperatingCurrentnessDecision(
      disposition: AppCzarOperatingCurrentnessDisposition.localContradiction,
      detail:
          'Source count/high-water $sourceCount/$sourceHighWater and local '
          '$liveCount/$liveHighWater do not establish a forward delta.',
    );
  }

  if (sourceCount == liveCount && sourceHighWater == liveHighWater) {
    return AppCzarOperatingCurrentnessDecision(
      disposition: AppCzarOperatingCurrentnessDisposition.noChange,
      detail:
          'Source and local count/high-water agree at '
          '$sourceCount/$sourceHighWater.',
    );
  }

  return AppCzarOperatingCurrentnessDecision(
    disposition: AppCzarOperatingCurrentnessDisposition.sourceAhead,
    detail:
        'Source count/high-water $sourceCount/$sourceHighWater is ahead of '
        'local $liveCount/$liveHighWater.',
  );
}
