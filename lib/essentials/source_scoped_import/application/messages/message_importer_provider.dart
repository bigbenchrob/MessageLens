import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../../paths/feature_level_providers.dart' show pathsHelperProvider;
import '../source_database_opener_provider.dart';
import '../source_import_page_metric.dart';
import '../source_scoped_import_ledger_provider.dart';
import 'message_importer.dart';

part 'message_importer_provider.g.dart';

@riverpod
Future<MessageImporter> messageImporter(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  final sourceDatabaseOpener = ref.watch(sourceDatabaseOpenerProvider);
  final logger = ref.read(appLoggerProvider.notifier);

  return MessageImporter(
    chatDbPath: pathsHelper.chatDBPath,
    importLedger: importLedger,
    sourceDatabaseOpener: sourceDatabaseOpener,
    onPageMetric: (metric) {
      final context = metric.toLogContext();
      if (metric.outcome == SourceImportPageOutcome.failed) {
        logger.warn(
          'Source message import page failed',
          source: 'MessageImporter',
          context: context,
        );
      } else {
        logger.info(
          'Source message import page completed',
          source: 'MessageImporter',
          context: context,
        );
      }
    },
  );
}
