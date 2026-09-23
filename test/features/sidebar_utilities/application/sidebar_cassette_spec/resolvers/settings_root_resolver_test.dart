import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/payloads/settings_top_menu_cassette_payload.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/resolvers/settings_root_resolver.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/settings_top_menu_row.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

void main() {
  group('SettingsRootResolver', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'returns a flat mixed-row menu payload for the settings root',
      () async {
        final payload = await container
            .read(settingsRootResolverProvider.notifier)
            .resolve(cassetteIndex: 0, persistentContextActionId: null);

        expect(payload, isA<SettingsTopMenuCassettePayload>());
        expect(
          payload.renderKind,
          SidebarCassetteRenderKind.placementGovernedFeature,
        );
        expect(payload.role, SidebarCassetteRole.appControl);
        expect(payload.promptLabel, 'Choose setting or action');
        expect(payload.persistentContextActionId, isNull);
        expect(payload.rows, hasLength(10));
        expect(payload.rows.first, isA<SettingsTopMenuGroupHeaderRow>());
        expect(
          (payload.rows.first as SettingsTopMenuGroupHeaderRow).label,
          'Support',
        );
        expect(payload.rows[1], isA<SettingsTopMenuActionRow>());
        expect(
          (payload.rows[1] as SettingsTopMenuActionRow).actionId,
          SettingsMenuActionId.attachmentArchive,
        );
        expect(
          (payload.rows[1] as SettingsTopMenuActionRow).intent,
          isA<SettingsPersistentContextChosen>().having(
            (intent) => intent.actionId,
            'actionId',
            SettingsMenuActionId.attachmentArchive,
          ),
        );
        expect(payload.rows[2], isA<SettingsTopMenuActionRow>());
        expect(
          (payload.rows[2] as SettingsTopMenuActionRow).actionId,
          SettingsMenuActionId.historicalArchives,
        );
        expect(payload.rows[3], isA<SettingsTopMenuGroupHeaderRow>());
        expect(
          (payload.rows[3] as SettingsTopMenuGroupHeaderRow).label,
          'Troubleshooting',
        );
        expect(payload.rows[4], isA<SettingsTopMenuActionRow>());
        expect(
          (payload.rows[4] as SettingsTopMenuActionRow).actionId,
          SettingsMenuActionId.messageHistoryCoverage,
        );
        expect(
          (payload.rows[4] as SettingsTopMenuActionRow).intent,
          isA<SettingsPersistentContextChosen>().having(
            (intent) => intent.actionId,
            'actionId',
            SettingsMenuActionId.messageHistoryCoverage,
          ),
        );
        expect(payload.rows[5], isA<SettingsTopMenuActionRow>());
        expect(
          (payload.rows[5] as SettingsTopMenuActionRow).actionId,
          SettingsMenuActionId.sendLogs,
        );
        expect(
          (payload.rows[5] as SettingsTopMenuActionRow).intent,
          isA<ShowSendLogsFlow>(),
        );
        expect(
          (payload.rows[8] as SettingsTopMenuActionRow).actionId,
          SettingsMenuActionId.textSize,
        );
        expect(
          (payload.rows[8] as SettingsTopMenuActionRow).intent,
          isA<SettingsPersistentContextChosen>().having(
            (intent) => intent.actionId,
            'actionId',
            SettingsMenuActionId.textSize,
          ),
        );
      },
    );
  });
}
