import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_view_spec.freezed.dart';

@freezed
abstract class SettingsViewSpec with _$SettingsViewSpec {
  const factory SettingsViewSpec.attachmentArchiveWorkflow() =
      _AttachmentArchiveWorkflow;

  const factory SettingsViewSpec.historicalArchivesWorkflow() =
      _HistoricalArchivesWorkflow;

  const factory SettingsViewSpec.messageHistoryCoverageReport() =
      _MessageHistoryCoverageReport;
}
