import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/payloads/settings_top_menu_cassette_payload.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/resolver_tools/sidebar_top_menu_actions_provider.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/settings_top_menu_widget.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/settings_top_menu_row.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

void main() {
  testWidgets('tracked Settings menu opens outside its fixed-height cell', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: Center(
            child: SizedBox(
              width: 280,
              height: 40,
              child: SettingsTopMenuWidget(
                panelPresentation:
                    SettingsTopMenuPanelPresentation.anchoredOverlay,
                payload: SettingsTopMenuCassettePayload(
                  cassetteIndex: 0,
                  promptLabel: 'Choose setting or action',
                  persistentContextActionId:
                      SettingsMenuActionId.messageHistoryCoverage,
                  rows: <SettingsTopMenuRow>[
                    SettingsTopMenuGroupHeaderRow(label: 'Message Data'),
                    SettingsTopMenuActionRow.persistentContext(
                      label: 'Message History Coverage',
                      actionId: SettingsMenuActionId.messageHistoryCoverage,
                    ),
                    SettingsTopMenuActionRow.persistentContext(
                      label: 'Historical Archives',
                      actionId: SettingsMenuActionId.historicalArchives,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Message Data'), findsNothing);
    await tester.tap(find.text('Message history coverage report'));
    await tester.pump();

    expect(find.text('Message Data'), findsOneWidget);
    expect(find.text('Historical Archives'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tapAt(const Offset(4, 4));
    await tester.pump();

    expect(find.text('Message Data'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'transient reset selection dispatches once and stays closed after remount',
    (tester) async {
      final selections = <SettingsTopMenuActionRow>[];

      await _pumpInlineMenu(
        tester,
        selections: selections,
        hasTransientProjection: false,
      );
      expect(find.text('Troubleshooting'), findsOneWidget);

      await tester.tap(find.text('Reset message data…'));
      await tester.pump();

      expect(selections, hasLength(1));
      expect(selections.single.actionId, SettingsMenuActionId.resetMessageData);
      expect(find.text('Troubleshooting'), findsNothing);

      await _pumpInlineMenu(
        tester,
        selections: selections,
        hasTransientProjection: true,
      );

      expect(find.text('Troubleshooting'), findsNothing);
      expect(selections, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('persistent Settings navigation still selects and closes', (
    tester,
  ) async {
    final selections = <SettingsTopMenuActionRow>[];
    await _pumpInlineMenu(
      tester,
      selections: selections,
      persistentContextActionId: SettingsMenuActionId.environment,
      hasTransientProjection: false,
    );

    expect(find.text('Troubleshooting'), findsNothing);
    await tester.tap(find.text('Environment'));
    await tester.pump();
    expect(find.text('Troubleshooting'), findsOneWidget);

    await tester.tap(find.text('Historical Archives'));
    await tester.pump();

    expect(selections, hasLength(1));
    expect(selections.single.actionId, SettingsMenuActionId.historicalArchives);
    expect(find.text('Troubleshooting'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpInlineMenu(
  WidgetTester tester, {
  required List<SettingsTopMenuActionRow> selections,
  required bool hasTransientProjection,
  SettingsMenuActionId? persistentContextActionId,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sidebarTopMenuActionsProvider.overrideWith(
          () => _RecordingSidebarTopMenuActions(selections),
        ),
      ],
      child: CupertinoApp(
        home: Center(
          child: SizedBox(
            width: 320,
            child: SettingsTopMenuWidget(
              key: ValueKey(hasTransientProjection),
              payload: SettingsTopMenuCassettePayload(
                cassetteIndex: 0,
                promptLabel: 'Choose setting or action',
                persistentContextActionId: persistentContextActionId,
                expandInlineMenuWhenUnselected: !hasTransientProjection,
                rows: const <SettingsTopMenuRow>[
                  SettingsTopMenuGroupHeaderRow(label: 'Troubleshooting'),
                  SettingsTopMenuActionRow.transientAction(
                    label: 'Reset message data…',
                    actionId: SettingsMenuActionId.resetMessageData,
                  ),
                  SettingsTopMenuActionRow.persistentContext(
                    label: 'Environment',
                    actionId: SettingsMenuActionId.environment,
                  ),
                  SettingsTopMenuActionRow.persistentContext(
                    label: 'Historical Archives',
                    actionId: SettingsMenuActionId.historicalArchives,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

final class _RecordingSidebarTopMenuActions extends SidebarTopMenuActions {
  _RecordingSidebarTopMenuActions(this.selections);

  final List<SettingsTopMenuActionRow> selections;

  @override
  void build() {}

  @override
  Future<void> selectSettingsMenuRow({
    required SettingsTopMenuActionRow row,
    required int cassetteIndex,
  }) async {
    selections.add(row);
  }
}
