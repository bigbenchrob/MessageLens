import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/widget_builders/attachment_archive_settings_supplemental_content.dart';

void main() {
  testWidgets('renders selected-copy status with semantic labels', (
    tester,
  ) async {
    const payload = AttachmentArchiveSettingsCassettePayload(
      cassetteIndex: 2,
      statusLines: [
        AttachmentArchiveSettingsStatusLine(
          label: 'Selected copy',
          value: '/Volumes/Backup/attachment_archive',
        ),
        AttachmentArchiveSettingsStatusLine(
          label: 'Status',
          value: 'Backup · Connected',
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

    expect(find.text('Selected copy'), findsOneWidget);
    expect(find.text('/Volumes/Backup/attachment_archive'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Backup · Connected'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp('Selected copy: /Volumes/Backup/attachment_archive'),
      ),
      findsOneWidget,
    );
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('places dynamic result between selected copy and its action', (
    tester,
  ) async {
    const payload = AttachmentArchiveSettingsCassettePayload(
      cassetteIndex: 2,
      workflowView: AttachmentArchiveSettingsWorkflowView.verificationFailed,
      statusLines: [
        AttachmentArchiveSettingsStatusLine(
          label: 'Selected copy',
          value: '/Volumes/Backup/attachment_archive',
        ),
      ],
      workflowTitle: 'This copy couldn’t be verified',
      workflowBodyText:
          'MessageLens found an unexpected file. Your archive location has '
          'not changed.',
      actions: [
        SidebarActionDescriptor(
          label: 'Try Again',
          intent: AttachmentArchiveCheckAgainRequested(),
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

    final copyY = tester
        .getTopLeft(find.text('/Volumes/Backup/attachment_archive'))
        .dy;
    final resultY = tester
        .getTopLeft(find.text('This copy couldn’t be verified'))
        .dy;
    final actionY = tester.getTopLeft(find.text('Try Again')).dy;
    expect(resultY, greaterThan(copyY));
    expect(actionY, greaterThan(resultY));
  });
}
