import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_cassette_spec.freezed.dart';

/// Spec family for settings-mode sidebar cassettes.
///
/// Step 1 of the settings-sidebar redesign moves settings ownership into a
/// dedicated feature while preserving the current visible behavior.
@freezed
abstract class SettingsCassetteSpec with _$SettingsCassetteSpec {
  const factory SettingsCassetteSpec.historicalArchivesOverview() =
      _HistoricalArchivesOverview;

  const factory SettingsCassetteSpec.messageHistoryCoverageOverview() =
      _MessageHistoryCoverageOverview;

  const factory SettingsCassetteSpec.messageHistoryCoverageHowToRead() =
      _MessageHistoryCoverageHowToRead;

  const factory SettingsCassetteSpec.messageHistoryCoverageOlderMessagesNote() =
      _MessageHistoryCoverageOlderMessagesNote;

  const factory SettingsCassetteSpec.sendLogsPanel() = _SendLogsPanel;

  const factory SettingsCassetteSpec.resetMessageDataPanel() =
      _ResetMessageDataPanel;

  const factory SettingsCassetteSpec.textSizeInfo() = _TextSizeInfo;

  const factory SettingsCassetteSpec.imageSizeInfo() = _ImageSizeInfo;
}
