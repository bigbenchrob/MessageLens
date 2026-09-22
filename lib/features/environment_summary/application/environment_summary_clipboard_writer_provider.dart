import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/system_environment_summary_clipboard_writer.dart';
import 'environment_summary_clipboard_writer.dart';

part 'environment_summary_clipboard_writer_provider.g.dart';

@riverpod
EnvironmentSummaryClipboardWriter environmentSummaryClipboardWriter(Ref ref) {
  return const SystemEnvironmentSummaryClipboardWriter();
}
