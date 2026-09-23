import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/settings_cassette_spec.dart';
import '../payloads/historical_archives_settings_cassette_payload.dart';
import '../resolvers/historical_archives_settings_resolver.dart';
import '../resolvers/message_history_coverage_settings_resolver.dart';
import '../resolvers/reset_message_data_settings_resolver.dart';
import '../resolvers/send_logs_settings_resolver.dart';
import '../resolvers/settings_info_resolver.dart';

part 'settings_coordinator.g.dart';

@riverpod
class SettingsCassetteCoordinator extends _$SettingsCassetteCoordinator {
  @override
  void build() {}

  Future<SidebarCassettePayload> buildViewModel(
    SettingsCassetteSpec spec, {
    required int cassetteIndex,
    List<HistoricalArchiveSidebarSourceSummary>? historicalArchivesKnownSources,
  }) async {
    return spec.when(
      historicalArchivesOverview: () => ref
          .read(historicalArchivesSettingsResolverProvider.notifier)
          .resolve(
            cassetteIndex: cassetteIndex,
            knownSources: historicalArchivesKnownSources ?? const [],
          ),
      messageHistoryCoverageOverview: () => ref
          .read(messageHistoryCoverageSettingsResolverProvider.notifier)
          .resolveOverview(cassetteIndex: cassetteIndex),
      messageHistoryCoverageHowToRead: () => ref
          .read(messageHistoryCoverageSettingsResolverProvider.notifier)
          .resolveHowToRead(cassetteIndex: cassetteIndex),
      messageHistoryCoverageOlderMessagesNote: () => ref
          .read(messageHistoryCoverageSettingsResolverProvider.notifier)
          .resolveOlderMessagesNote(cassetteIndex: cassetteIndex),
      sendLogsPanel: () => ref
          .read(sendLogsSettingsResolverProvider.notifier)
          .resolve(cassetteIndex: cassetteIndex),
      resetMessageDataPanel: () => ref
          .read(resetMessageDataSettingsResolverProvider.notifier)
          .resolve(cassetteIndex: cassetteIndex),
      textSizeInfo: () => ref
          .read(settingsInfoResolverProvider.notifier)
          .resolve(title: 'Text Size', bodyText: 'Coming soon'),
      imageSizeInfo: () => ref
          .read(settingsInfoResolverProvider.notifier)
          .resolve(title: 'Image Size', bodyText: 'Coming soon'),
    );
  }
}
