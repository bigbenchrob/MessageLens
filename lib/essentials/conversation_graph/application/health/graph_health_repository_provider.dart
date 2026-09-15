import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/attachments/feature_level_providers.dart'
    show attachmentArchiveLocationProvider;
import '../../../db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import '../../infrastructure/repositories/graph_health_repository.dart';
import 'graph_health_repository.dart';

part 'graph_health_repository_provider.g.dart';

@riverpod
Future<GraphHealthRepository> graphHealthRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  final location = await ref.watch(attachmentArchiveLocationProvider.future);
  return SqliteGraphHealthRepository(
    graphDatabase: graphDatabase,
    overlayDatabase: overlayDatabase,
    attachmentArchiveDirectory: location.requireArchiveRootPath(),
    historicalMessageLensDataFolderPath:
        historicalMessageLensDataFolderPathForGraphHealth,
    recoveredMessagesFolderPath: recoveredMessagesFolderPathForGraphHealth,
    recoveredMessagesAttachmentsFolderName:
        recoveredMessagesAttachmentsFolderNameForGraphHealth,
  );
}

const historicalMessageLensDataFolderPathForGraphHealth =
    String.fromEnvironment('MESSAGE_LENS_GRAPH_HEALTH_HISTORICAL_DATA_FOLDER');

// External recovery sources are diagnostic-only and intentionally opt-in.
const recoveredMessagesFolderPathForGraphHealth = String.fromEnvironment(
  'MESSAGE_LENS_GRAPH_HEALTH_RECOVERED_MESSAGES_FOLDER',
);

const recoveredMessagesAttachmentsFolderNameForGraphHealth =
    String.fromEnvironment(
      'MESSAGE_LENS_GRAPH_HEALTH_RECOVERED_MESSAGES_ATTACHMENTS_FOLDER',
      defaultValue: 'Attachments',
    );
