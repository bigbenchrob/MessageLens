import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/payloads/settings_top_menu_cassette_payload.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/resolver_tools/settings_reset_message_data_action_availability_provider.dart';
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
            .resolve(
              cassetteIndex: 0,
              persistentContextActionId: null,
              hasActiveTransientProjection: false,
            );

        expect(payload, isA<SettingsTopMenuCassettePayload>());
        expect(
          payload.renderKind,
          SidebarCassetteRenderKind.placementGovernedFeature,
        );
        expect(payload.role, SidebarCassetteRole.appControl);
        expect(payload.promptLabel, 'Choose setting or action');
        expect(payload.persistentContextActionId, isNull);
        expect(payload.expandInlineMenuWhenUnselected, isTrue);
        expect(
          container.read(settingsResetMessageDataActionAvailableProvider),
          isTrue,
        );
        expect(payload.rows, hasLength(11));
        expect(payload.rows.first, isA<SettingsTopMenuGroupHeaderRow>());
        expect(
          (payload.rows.first as SettingsTopMenuGroupHeaderRow).label,
          'Support',
        );
        expect(payload.rows[1], isA<SettingsTopMenuActionRow>());
        expect(
          (payload.rows[1] as SettingsTopMenuActionRow).actionId,
          SettingsMenuActionId.environment,
        );
        expect(
          (payload.rows[1] as SettingsTopMenuActionRow).intent,
          isA<SettingsPersistentContextChosen>().having(
            (intent) => intent.actionId,
            'actionId',
            SettingsMenuActionId.environment,
          ),
        );
        expect(payload.rows[2], isA<SettingsTopMenuActionRow>());
        expect(
          (payload.rows[2] as SettingsTopMenuActionRow).actionId,
          SettingsMenuActionId.attachmentArchive,
        );
        expect(payload.rows[3], isA<SettingsTopMenuActionRow>());
        expect(
          (payload.rows[3] as SettingsTopMenuActionRow).actionId,
          SettingsMenuActionId.historicalArchives,
        );
        expect(payload.rows[4], isA<SettingsTopMenuGroupHeaderRow>());
        expect(
          (payload.rows[4] as SettingsTopMenuGroupHeaderRow).label,
          'Troubleshooting',
        );
        expect(payload.rows[5], isA<SettingsTopMenuActionRow>());
        expect(
          (payload.rows[5] as SettingsTopMenuActionRow).actionId,
          SettingsMenuActionId.messageHistoryCoverage,
        );
        expect(
          (payload.rows[5] as SettingsTopMenuActionRow).intent,
          isA<SettingsPersistentContextChosen>().having(
            (intent) => intent.actionId,
            'actionId',
            SettingsMenuActionId.messageHistoryCoverage,
          ),
        );
        expect(payload.rows[6], isA<SettingsTopMenuActionRow>());
        expect(
          (payload.rows[6] as SettingsTopMenuActionRow).actionId,
          SettingsMenuActionId.sendLogs,
        );
        expect(
          (payload.rows[6] as SettingsTopMenuActionRow).intent,
          isA<ShowSendLogsFlow>(),
        );
        expect(payload.rows[7], isA<SettingsTopMenuActionRow>());
        expect(
          (payload.rows[7] as SettingsTopMenuActionRow).actionId,
          SettingsMenuActionId.resetMessageData,
        );
        expect(
          (payload.rows[7] as SettingsTopMenuActionRow).intent,
          isA<ShowResetMessageDataFlow>(),
        );
        expect(
          (payload.rows[9] as SettingsTopMenuActionRow).actionId,
          SettingsMenuActionId.textSize,
        );
        expect(
          (payload.rows[9] as SettingsTopMenuActionRow).intent,
          isA<SettingsPersistentContextChosen>().having(
            (intent) => intent.actionId,
            'actionId',
            SettingsMenuActionId.textSize,
          ),
        );
      },
    );

    test(
      'keeps the menu collapsed for an active transient projection',
      () async {
        final payload = await container
            .read(settingsRootResolverProvider.notifier)
            .resolve(
              cassetteIndex: 0,
              persistentContextActionId: null,
              hasActiveTransientProjection: true,
            );

        expect(payload.persistentContextActionId, isNull);
        expect(payload.expandInlineMenuWhenUnselected, isFalse);
      },
    );

    test(
      'omits Reset message data when its availability is disabled',
      () async {
        final restrictedContainer = ProviderContainer(
          overrides: [
            settingsResetMessageDataActionAvailableProvider.overrideWith(
              (ref) => false,
            ),
          ],
        );
        addTearDown(restrictedContainer.dispose);

        final payload = await restrictedContainer
            .read(settingsRootResolverProvider.notifier)
            .resolve(
              cassetteIndex: 0,
              persistentContextActionId: null,
              hasActiveTransientProjection: false,
            );
        final actionIds = payload.rows
            .whereType<SettingsTopMenuActionRow>()
            .map((row) => row.actionId);

        expect(payload.rows, hasLength(10));
        expect(
          actionIds,
          isNot(contains(SettingsMenuActionId.resetMessageData)),
        );
        expect(actionIds, contains(SettingsMenuActionId.sendLogs));
        expect(actionIds, contains(SettingsMenuActionId.textSize));
        expect(actionIds, contains(SettingsMenuActionId.imageSize));
      },
    );
  });
}
