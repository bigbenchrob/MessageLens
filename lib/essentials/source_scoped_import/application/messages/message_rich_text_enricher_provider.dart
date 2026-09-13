import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../../paths/feature_level_providers.dart' show pathsHelperProvider;
import '../message_extractor_provider.dart';
import '../source_import_page_metric.dart';
import '../source_scoped_import_ledger_provider.dart';
import 'message_rich_text_enricher.dart';

part 'message_rich_text_enricher_provider.g.dart';

@riverpod
Future<MessageRichTextEnricher> messageRichTextEnricher(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  final logger = ref.read(appLoggerProvider.notifier);

  return MessageRichTextEnricher(
    chatDbPath: pathsHelper.chatDBPath,
    importLedger: importLedger,
    extractor: ref.watch(sourceScopedMessageExtractorProvider),
    onPageMetric: (metric) {
      final context = metric.toLogContext();
      if (metric.outcome == SourceImportPageOutcome.failed) {
        logger.warn(
          'Rich-text decoder page failed',
          source: 'MessageRichTextEnricher',
          context: context,
        );
      } else {
        logger.info(
          'Rich-text decoder page completed',
          source: 'MessageRichTextEnricher',
          context: context,
        );
      }
    },
  );
}
