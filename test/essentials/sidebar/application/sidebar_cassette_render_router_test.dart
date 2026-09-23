import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_mode/application/app_mode_providers.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_cassette_render_router.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_cassette_sectioning.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_body_model.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/stray_handles_investigation_switcher_cassette_payload.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/payloads/messages_heatmap_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/settings_info_actions_cassette_payload.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_cassette_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/payloads/settings_top_menu_cassette_payload.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/settings_top_menu_row.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('sidebar cassette render contract', () {
    test('placement-governed feature payloads expose feature render kind', () {
      expect(
        const MessagesHeatmapCassettePayload(contactId: 42).renderKind,
        SidebarCassetteRenderKind.placementGovernedFeature,
      );
    });

    test('feature info payloads expose info render kind', () {
      expect(
        const StaticFeatureInfoSidebarCassettePayload(
          bodyText: 'info',
        ).renderKind,
        SidebarCassetteRenderKind.featureInfo,
      );
    });

    test('shared body-model payloads expose body-model render kind', () {
      expect(
        const SharedBodyModelSidebarCassettePayload(
          bodyModel: SidebarInfoBodyModel(bodyText: 'info'),
        ).renderKind,
        SidebarCassetteRenderKind.sharedBodyModel,
      );
    });

    testWidgets(
      'routes the unfamiliar-source investigation switcher through handles',
      (tester) async {
        final widget = buildSidebarCassettePayloadWidget(
          mode: SidebarMode.messages,
          resolvedCassette: const ResolvedSidebarCassette(
            spec: CassetteSpec.handles(
              HandlesCassetteSpec.strayHandlesInvestigationSwitcher(),
            ),
            cassetteIndex: 1,
            payload: StrayHandlesInvestigationSwitcherCassettePayload(
              selectedInvestigation: StrayHandleInvestigation.identifySources,
              cassetteIndex: 1,
            ),
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: widget,
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Identify'), findsOneWidget);
        expect(find.text('Numeric IDs'), findsOneWidget);
      },
    );

    testWidgets(
      'builds a flat mixed-row settings top menu widget open by default',
      (tester) async {
        final widget = buildSidebarCassettePayloadWidget(
          mode: SidebarMode.settings,
          resolvedCassette: const ResolvedSidebarCassette(
            spec: CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
            cassetteIndex: 0,
            payload: SettingsTopMenuCassettePayload(
              cassetteIndex: 0,
              promptLabel: 'Choose setting or action',
              rows: <SettingsTopMenuRow>[
                SettingsTopMenuGroupHeaderRow(label: 'Troubleshooting'),
                SettingsTopMenuActionRow.transientAction(
                  label: 'Send logs…',
                  actionId: SettingsMenuActionId.sendLogs,
                ),
                SettingsTopMenuGroupHeaderRow(label: 'Appearance'),
                SettingsTopMenuActionRow.persistentContext(
                  label: 'Text size',
                  actionId: SettingsMenuActionId.textSize,
                ),
              ],
            ),
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: widget,
            ),
          ),
        );

        expect(find.text('Choose setting or action'), findsOneWidget);

        expect(find.text('Troubleshooting'), findsOneWidget);
        expect(find.text('Appearance'), findsOneWidget);
        expect(find.text('Send logs…'), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.chevron_up), findsOneWidget);
        expect(find.text('▴'), findsNothing);
        expect(find.text('▾'), findsNothing);

        final headerText = tester.widget<Text>(find.text('Troubleshooting'));
        final actionText = tester.widget<Text>(find.text('Send logs…'));
        expect(
          headerText.style?.fontSize,
          lessThan(actionText.style!.fontSize!),
        );
        expect(
          headerText.style?.letterSpacing,
          greaterThan(actionText.style?.letterSpacing ?? 0),
        );
        expect(headerText.style?.fontSize, 11);
        expect(headerText.style?.fontWeight, FontWeight.w500);

        final firstHeaderPadding = tester.widget<Padding>(
          find
              .ancestor(
                of: find.text('Troubleshooting'),
                matching: find.byType(Padding),
              )
              .first,
        );
        expect(
          firstHeaderPadding.padding,
          EdgeInsets.only(
            left: sidebarMenuSectionHeaderHorizontalInset,
            right: sidebarMenuSectionHeaderHorizontalInset,
            top: sidebarMenuSectionHeaderTopSpacing(isFirstInMenu: true),
            bottom: sidebarMenuSectionHeaderBottomSpacing(),
          ),
        );

        final secondHeaderPadding = tester.widget<Padding>(
          find
              .ancestor(
                of: find.text('Appearance'),
                matching: find.byType(Padding),
              )
              .first,
        );
        expect(
          secondHeaderPadding.padding,
          EdgeInsets.only(
            left: sidebarMenuSectionHeaderHorizontalInset,
            right: sidebarMenuSectionHeaderHorizontalInset,
            top: sidebarMenuSectionHeaderTopSpacing(isFirstInMenu: false),
            bottom: sidebarMenuSectionHeaderBottomSpacing(),
          ),
        );

        final actionPadding = tester.widget<Padding>(
          find
              .ancestor(
                of: find.text('Send logs…'),
                matching: find.byType(Padding),
              )
              .first,
        );
        expect(
          actionPadding.padding,
          const EdgeInsets.symmetric(
            horizontal: sidebarMenuItemHorizontalInset,
            vertical: 10,
          ),
        );

        expect(
          find.ancestor(
            of: find.text('Troubleshooting'),
            matching: find.byType(MouseRegion),
          ),
          findsNothing,
        );
        expect(
          find.ancestor(
            of: find.text('Troubleshooting'),
            matching: find.byType(GestureDetector),
          ),
          findsNothing,
        );
        expect(
          find.ancestor(
            of: find.text('Send logs…'),
            matching: find.byType(MouseRegion),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('uses stronger header contrast in dark mode only', (
      tester,
    ) async {
      final widget = buildSidebarCassettePayloadWidget(
        mode: SidebarMode.settings,
        resolvedCassette: const ResolvedSidebarCassette(
          spec: CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
          cassetteIndex: 0,
          payload: SettingsTopMenuCassettePayload(
            cassetteIndex: 0,
            promptLabel: 'Choose setting or action',
            rows: <SettingsTopMenuRow>[
              SettingsTopMenuGroupHeaderRow(label: 'Troubleshooting'),
            ],
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            platformBrightnessProvider.overrideWith((ref) => Brightness.dark),
          ],
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: widget,
          ),
        ),
      );

      final darkHeaderText = tester.widget<Text>(find.text('Troubleshooting'));
      expect(darkHeaderText.style?.color?.a, closeTo(0.82, 0.001));
    });

    testWidgets(
      'uses a translucent muted-blue selected row background in dark mode',
      (tester) async {
        final widget = buildSidebarCassettePayloadWidget(
          mode: SidebarMode.settings,
          resolvedCassette: const ResolvedSidebarCassette(
            spec: CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
            cassetteIndex: 0,
            payload: SettingsTopMenuCassettePayload(
              cassetteIndex: 0,
              promptLabel: 'Choose setting or action',
              persistentContextActionId: SettingsMenuActionId.textSize,
              rows: <SettingsTopMenuRow>[
                SettingsTopMenuGroupHeaderRow(label: 'Appearance'),
                SettingsTopMenuActionRow.persistentContext(
                  label: 'Text size',
                  actionId: SettingsMenuActionId.textSize,
                ),
              ],
            ),
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              platformBrightnessProvider.overrideWith((ref) => Brightness.dark),
            ],
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: widget,
            ),
          ),
        );

        await tester.tap(find.text('Text size').first);
        await tester.pump();

        expect(find.text('Appearance'), findsOneWidget);

        expect(
          find.ancestor(
            of: find.text('Text size').last,
            matching: find.byWidgetPredicate((widget) {
              if (widget is! DecoratedBox) {
                return false;
              }

              final decoration = widget.decoration;
              if (decoration is! BoxDecoration) {
                return false;
              }

              return decoration.color == const Color(0x405287B8);
            }),
          ),
          findsOneWidget,
        );

        final selectedRowText = tester.widget<Text>(
          find.text('Text size').last,
        );
        final selectedCheckmark = tester.widget<Text>(find.text('✓'));
        expect(selectedRowText.style?.color, const Color(0xFF4DA6FF));
        expect(selectedCheckmark.style?.color, const Color(0xFF4DA6FF));
      },
    );

    testWidgets('builds a unified send logs cassette with inline action', (
      tester,
    ) async {
      final widget = buildSidebarCassettePayloadWidget(
        mode: SidebarMode.settings,
        resolvedCassette: const ResolvedSidebarCassette(
          spec: CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
          cassetteIndex: 1,
          payload: SettingsInfoActionsCassettePayload(
            cassetteIndex: 1,
            bodyText:
                'Send log data to help diagnose problems with MessageLens. The exported report includes application logs and database health diagnostics. It does not modify your imported data.',
            actions: [
              SidebarActionDescriptor(
                label: 'Send log data…',
                intent: SendLogsRequested(),
                tone: SidebarActionTone.primary,
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: widget,
          ),
        ),
      );

      expect(
        find.textContaining('database health diagnostics'),
        findsOneWidget,
      );
      expect(find.text('Send log data…'), findsOneWidget);
      expect(find.text('Send Logs'), findsNothing);
    });

    testWidgets('builds a sidebar-local reset message data confirm cassette', (
      tester,
    ) async {
      final widget = buildSidebarCassettePayloadWidget(
        mode: SidebarMode.settings,
        resolvedCassette: const ResolvedSidebarCassette(
          spec: CassetteSpec.settings(
            SettingsCassetteSpec.resetMessageDataPanel(),
          ),
          cassetteIndex: 1,
          payload: SettingsInfoActionsCassettePayload(
            cassetteIndex: 1,
            title: 'Reset Message Data',
            bodyText:
                'Use this advanced action if the messages or contacts shown in MessageLens do not match what you see in Messages or Contacts on your Mac. After confirmation, Start Fresh removes only rebuildable imported-message and conversation-index data. It preserves your preferences, MessageLens customizations, setup history, and archived attachments, verifies a clean state, then restarts Onboarding.',
            actions: [
              SidebarActionDescriptor(
                label: 'Reset message data…',
                intent: ResetMessageDataRequested(),
                tone: SidebarActionTone.destructive,
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: widget,
          ),
        ),
      );

      expect(find.textContaining('Start Fresh'), findsOneWidget);
      expect(find.text('Reset Message Data'), findsOneWidget);
      expect(find.text('Reset message data…'), findsOneWidget);
    });
  });
}
