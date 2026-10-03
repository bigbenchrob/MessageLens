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
    this.expandInlineMenuWhenUnselected = true,
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
  final bool expandInlineMenuWhenUnselected;
}

SettingsTopMenuCassettePayload buildSettingsTopMenuCassettePayload({
  required int cassetteIndex,
  required SettingsMenuActionId? persistentContextActionId,
  bool expandInlineMenuWhenUnselected = true,
  bool resetMessageDataActionAvailable = true,
}) {
  return SettingsTopMenuCassettePayload(
    cassetteIndex: cassetteIndex,
    promptLabel: 'Choose setting or action',
    persistentContextActionId: persistentContextActionId,
    expandInlineMenuWhenUnselected: expandInlineMenuWhenUnselected,
    rows: List<SettingsTopMenuRow>.unmodifiable([
      const SettingsTopMenuGroupHeaderRow(label: 'Support'),
      const SettingsTopMenuActionRow.persistentContext(
        label: 'Environment',
        actionId: SettingsMenuActionId.environment,
      ),
      const SettingsTopMenuActionRow.persistentContext(
        label: 'Attachment archive',
        actionId: SettingsMenuActionId.attachmentArchive,
      ),
      const SettingsTopMenuActionRow.persistentContext(
        label: 'Historical Archives',
        actionId: SettingsMenuActionId.historicalArchives,
      ),
      const SettingsTopMenuGroupHeaderRow(label: 'Troubleshooting'),
      const SettingsTopMenuActionRow.persistentContext(
        label: 'Message history coverage report',
        actionId: SettingsMenuActionId.messageHistoryCoverage,
      ),
      const SettingsTopMenuActionRow.transientAction(
        label: 'Send logs…',
        actionId: SettingsMenuActionId.sendLogs,
      ),
      if (resetMessageDataActionAvailable)
        const SettingsTopMenuActionRow.transientAction(
          label: 'Reset message data…',
          actionId: SettingsMenuActionId.resetMessageData,
        ),
      const SettingsTopMenuGroupHeaderRow(label: 'Appearance'),
      const SettingsTopMenuActionRow.persistentContext(
        label: 'Text size',
        actionId: SettingsMenuActionId.textSize,
      ),
      const SettingsTopMenuActionRow.persistentContext(
        label: 'Image size',
        actionId: SettingsMenuActionId.imageSize,
      ),
    ]),
  );
}
