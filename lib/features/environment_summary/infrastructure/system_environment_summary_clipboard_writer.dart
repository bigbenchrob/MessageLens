import 'package:flutter/services.dart';

import '../application/environment_summary_clipboard_writer.dart';

final class SystemEnvironmentSummaryClipboardWriter
    implements EnvironmentSummaryClipboardWriter {
  const SystemEnvironmentSummaryClipboardWriter();

  @override
  Future<void> writeText(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }
}
