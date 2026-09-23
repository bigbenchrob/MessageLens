import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/environment_summary/infrastructure/system_environment_summary_clipboard_writer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('writes text through the Flutter system clipboard channel', () async {
    MethodCall? recordedCall;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      recordedCall = call;
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await const SystemEnvironmentSummaryClipboardWriter().writeText(
      'support summary',
    );

    expect(recordedCall?.method, 'Clipboard.setData');
    expect(recordedCall?.arguments, <String, Object?>{
      'text': 'support summary',
    });
  });
}
