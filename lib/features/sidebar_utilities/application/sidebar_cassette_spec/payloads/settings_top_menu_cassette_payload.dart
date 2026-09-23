import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/settings_top_menu_row.dart';
import '../../../domain/sidebar_utilities_constants.dart';

final class SettingsTopMenuCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const SettingsTopMenuCassettePayload({
    required this.rows,
    required this.cassetteIndex,
    required this.promptLabel,
    this.persistentContextActionId,
    super.title = '',
    super.role = SidebarCassetteRole.appControl,
    super.topSpacing = 0,
    super.placementMode = SidebarBodyPlacementMode.fullWidth,
    super.contentAlignment = SidebarBodyContentAlignment.insetControl,
    super.layoutStyle = SidebarCardLayoutStyle.standard,
    super.isNaked = true,
    super.shouldExpand = false,
  });

  final List<SettingsTopMenuRow> rows;
  final int cassetteIndex;
  final String promptLabel;
  final SettingsMenuActionId? persistentContextActionId;
}

SettingsTopMenuCassettePayload buildSettingsTopMenuCassettePayload({
  required int cassetteIndex,
  required SettingsMenuActionId? persistentContextActionId,
}) {
  return SettingsTopMenuCassettePayload(
    cassetteIndex: cassetteIndex,
    promptLabel: 'Choose setting or action',
    persistentContextActionId: persistentContextActionId,
    rows: const [
      SettingsTopMenuGroupHeaderRow(label: 'Support'),
      SettingsTopMenuActionRow.persistentContext(
        label: 'Attachment archive',
        actionId: SettingsMenuActionId.attachmentArchive,
      ),
      SettingsTopMenuActionRow.persistentContext(
        label: 'Historical Archives',
        actionId: SettingsMenuActionId.historicalArchives,
      ),
      SettingsTopMenuGroupHeaderRow(label: 'Troubleshooting'),
      SettingsTopMenuActionRow.persistentContext(
        label: 'Message history coverage report',
        actionId: SettingsMenuActionId.messageHistoryCoverage,
      ),
      SettingsTopMenuActionRow.transientAction(
        label: 'Send logs…',
        actionId: SettingsMenuActionId.sendLogs,
      ),
      SettingsTopMenuActionRow.transientAction(
        label: 'Reset message data…',
        actionId: SettingsMenuActionId.resetMessageData,
      ),
      SettingsTopMenuGroupHeaderRow(label: 'Appearance'),
      SettingsTopMenuActionRow.persistentContext(
        label: 'Text size',
        actionId: SettingsMenuActionId.textSize,
      ),
      SettingsTopMenuActionRow.persistentContext(
        label: 'Image size',
        actionId: SettingsMenuActionId.imageSize,
      ),
    ],
  );
}
