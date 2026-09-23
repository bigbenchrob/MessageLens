import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../domain/entities/environment_summary.dart';
import '../domain/services/environment_summary_formatter.dart';
import 'environment_summary_clipboard_writer_provider.dart';

part 'environment_summary_actions_provider.g.dart';

enum EnvironmentSummaryCopyResult { copied, failed }

@riverpod
class EnvironmentSummaryActions extends _$EnvironmentSummaryActions {
  @override
  void build() {}

  Future<EnvironmentSummaryCopyResult> copy(EnvironmentSummary summary) async {
    try {
      final text = const EnvironmentSummaryFormatter().format(summary);
      await ref.read(environmentSummaryClipboardWriterProvider).writeText(text);
      return EnvironmentSummaryCopyResult.copied;
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Environment summary clipboard write failed',
            source: 'EnvironmentSummaryActions',
            context: <String, Object?>{
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
      return EnvironmentSummaryCopyResult.failed;
    }
  }
}
