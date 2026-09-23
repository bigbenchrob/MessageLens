import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_cassette_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('settings stable topology regression', () {
    test(
      'settings root immediate child follows durable persistent context',
      () {
        const currentSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.settingsMenu(),
        );

        const historicalArchivesContext = StableCassetteTopologyContext(
          messageScope: StableCascadeMessageScope.regular,
          persistentSettingsContext: SettingsMenuActionId.historicalArchives,
        );
        const attachmentArchiveContext = StableCassetteTopologyContext(
          messageScope: StableCascadeMessageScope.regular,
          persistentSettingsContext: SettingsMenuActionId.attachmentArchive,
        );
        const environmentContext = StableCassetteTopologyContext(
          messageScope: StableCascadeMessageScope.regular,
          persistentSettingsContext: SettingsMenuActionId.environment,
        );
        const messageHistoryCoverageContext = StableCassetteTopologyContext(
          messageScope: StableCascadeMessageScope.regular,
          persistentSettingsContext:
              SettingsMenuActionId.messageHistoryCoverage,
        );
        const textSizeContext = StableCassetteTopologyContext(
          messageScope: StableCascadeMessageScope.regular,
          persistentSettingsContext: SettingsMenuActionId.textSize,
        );
        const imageSizeContext = StableCassetteTopologyContext(
          messageScope: StableCascadeMessageScope.regular,
          persistentSettingsContext: SettingsMenuActionId.imageSize,
        );
        const noContext = StableCassetteTopologyContext(
          messageScope: StableCascadeMessageScope.regular,
        );

        expect(
          resolveStableCascadeChild(currentSpec, context: environmentContext),
          isNull,
          reason: 'Environment is center-pane navigation only.',
        );
        expect(
          resolveStableCascadeChild(
            currentSpec,
            context: attachmentArchiveContext,
          ),
          isNull,
          reason: 'Attachment archive is center-pane navigation only.',
        );
        expect(
          resolveStableCascadeChild(
            currentSpec,
            context: historicalArchivesContext,
          ),
          equals(
            const CassetteSpec.settings(
              SettingsCassetteSpec.historicalArchivesOverview(),
            ),
          ),
        );
        expect(
          resolveStableCascadeChild(
            currentSpec,
            context: messageHistoryCoverageContext,
          ),
          equals(
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageOverview(),
            ),
          ),
        );
        expect(
          resolveStableCascadeChild(currentSpec, context: textSizeContext),
          equals(
            const CassetteSpec.settings(SettingsCassetteSpec.textSizeInfo()),
          ),
        );
        expect(
          resolveStableCascadeChild(currentSpec, context: imageSizeContext),
          equals(
            const CassetteSpec.settings(SettingsCassetteSpec.imageSizeInfo()),
          ),
        );
        expect(
          resolveStableCascadeChild(currentSpec, context: noContext),
          isNull,
        );
      },
    );

    test(
      'transient settings actions are not stable children of settings root',
      () {
        const currentSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.settingsMenu(),
        );

        const sendLogsContext = StableCassetteTopologyContext(
          messageScope: StableCascadeMessageScope.regular,
          persistentSettingsContext: SettingsMenuActionId.sendLogs,
        );
        const resetContext = StableCassetteTopologyContext(
          messageScope: StableCascadeMessageScope.regular,
          persistentSettingsContext: SettingsMenuActionId.resetMessageData,
        );

        expect(
          resolveStableCascadeChild(currentSpec, context: sendLogsContext),
          isNull,
        );
        expect(
          resolveStableCascadeChild(currentSpec, context: resetContext),
          isNull,
        );
      },
    );

    test('historical archives settings card does not cascade further', () {
      expect(
        resolveStableCascadeChild(
          const CassetteSpec.settings(
            SettingsCassetteSpec.historicalArchivesOverview(),
          ),
          context: const StableCassetteTopologyContext(
            messageScope: StableCascadeMessageScope.regular,
          ),
        ),
        isNull,
      );
    });

    test(
      'message history coverage settings cards cascade in durable order',
      () {
        expect(
          resolveStableCascadeChild(
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageOverview(),
            ),
            context: const StableCassetteTopologyContext(
              messageScope: StableCascadeMessageScope.regular,
            ),
          ),
          equals(
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageHowToRead(),
            ),
          ),
        );

        expect(
          resolveStableCascadeChild(
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageHowToRead(),
            ),
            context: const StableCassetteTopologyContext(
              messageScope: StableCascadeMessageScope.regular,
            ),
          ),
          equals(
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageOlderMessagesNote(),
            ),
          ),
        );

        expect(
          resolveStableCascadeChild(
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageOlderMessagesNote(),
            ),
            context: const StableCassetteTopologyContext(
              messageScope: StableCascadeMessageScope.regular,
            ),
          ),
          isNull,
        );
      },
    );
  });
}
