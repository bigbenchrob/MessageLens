import '../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import 'sidebar_utilities_constants.dart';

sealed class SettingsTopMenuRow {
  const SettingsTopMenuRow();
}

final class SettingsTopMenuGroupHeaderRow extends SettingsTopMenuRow {
  const SettingsTopMenuGroupHeaderRow({required this.label});

  final String label;
}

final class SettingsTopMenuActionRow extends SettingsTopMenuRow {
  const SettingsTopMenuActionRow({
    required this.label,
    required this.actionId,
    required this.isPersistentContext,
  });

  const SettingsTopMenuActionRow.persistentContext({
    required this.label,
    required this.actionId,
  }) : isPersistentContext = true;

  const SettingsTopMenuActionRow.transientAction({
    required this.label,
    required this.actionId,
  }) : isPersistentContext = false;

  final String label;
  final SettingsMenuActionId actionId;
  final bool isPersistentContext;

  SidebarActionIntent get intent {
    if (isPersistentContext) {
      return SettingsPersistentContextChosen(actionId: actionId);
    }

    return switch (actionId) {
      SettingsMenuActionId.attachmentArchive ||
      SettingsMenuActionId.historicalArchives ||
      SettingsMenuActionId.messageHistoryCoverage => throw StateError(
        '$actionId must use durable settings context transport.',
      ),
      SettingsMenuActionId.sendLogs => const ShowSendLogsFlow(),
      SettingsMenuActionId.resetMessageData => const ShowResetMessageDataFlow(),
      SettingsMenuActionId.textSize ||
      SettingsMenuActionId.imageSize => throw StateError(
        'Persistent settings rows must not use transient action transport.',
      ),
    };
  }
}
