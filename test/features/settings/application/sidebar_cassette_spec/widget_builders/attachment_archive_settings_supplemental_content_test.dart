import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/widget_builders/attachment_archive_settings_supplemental_content.dart';

void main() {
  testWidgets('renders textual progress and semantic typed actions', (
    tester,
  ) async {
    const payload = AttachmentArchiveSettingsCassettePayload(
      cassetteIndex: 2,
      workflowView: AttachmentArchiveSettingsWorkflowView.copying,
      statusLines: [
        AttachmentArchiveSettingsStatusLine(
          label: 'Files copied',
          value: '12 of 40',
        ),
        AttachmentArchiveSettingsStatusLine(
          label: 'Data copied',
          value: '12.4 GB of 39.0 GB',
        ),
        AttachmentArchiveSettingsStatusLine(
          label: 'Destination availability',
          value: 'Available at the last journal update',
        ),
      ],
      actions: [
        SidebarActionDescriptor(
          label: 'Pause',
          intent: AttachmentArchivePauseRelocationRequested(
            operationId: 'operation-id',
          ),
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

    expect(find.text('Files copied'), findsOneWidget);
    expect(find.text('12 of 40'), findsOneWidget);
    expect(find.text('12.4 GB of 39.0 GB'), findsOneWidget);
    expect(find.text('Available at the last journal update'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Files copied: 12 of 40')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Pause'), findsOneWidget);
  });

  testWidgets(
    'disabled production action remains visibly and semantically disabled',
    (tester) async {
      const payload = AttachmentArchiveSettingsCassettePayload(
        cassetteIndex: 2,
        actions: [
          SidebarActionDescriptor(
            label: 'Move…',
            intent: AttachmentArchiveMoveRequested(),
            isEnabled: false,
          ),
        ],
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: CupertinoApp(
            home: AttachmentArchiveSettingsSupplementalContent(
              payload: payload,
            ),
          ),
        ),
      );
      await tester.pump();

      final semantics = tester.getSemantics(find.bySemanticsLabel('Move…'));
      expect(
        semantics.getSemanticsData().hasAction(SemanticsAction.tap),
        isFalse,
      );
    },
  );
}
