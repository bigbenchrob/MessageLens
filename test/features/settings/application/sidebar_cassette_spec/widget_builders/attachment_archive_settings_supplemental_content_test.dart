import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/widget_builders/attachment_archive_settings_supplemental_content.dart';

void main() {
  testWidgets('renders location status with semantic labels', (tester) async {
    const payload = AttachmentArchiveSettingsCassettePayload(
      cassetteIndex: 2,
      statusLines: [
        AttachmentArchiveSettingsStatusLine(
          label: 'Location',
          value: 'Internal',
        ),
        AttachmentArchiveSettingsStatusLine(
          label: 'Availability',
          value: 'Available',
        ),
      ],
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: SizedBox(
            width: 320,
            child: AttachmentArchiveSettingsSupplementalContent(
              payload: payload,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Internal'), findsOneWidget);
    expect(find.text('Availability'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Location: Internal')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Availability: Available')),
      findsOneWidget,
    );
    expect(find.byType(GestureDetector), findsNothing);
  });
}
