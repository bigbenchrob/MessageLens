import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../actions/settings_action_list_actions_provider.dart';

class SettingsActionList extends ConsumerWidget {
  const SettingsActionList({
    super.key,
    required this.actions,
    required this.cassetteIndex,
  });

  final List<SidebarActionDescriptor> actions;
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final activeIntent = ref.watch(settingsActionListActionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < actions.length; index++) ...[
          _SettingsActionRow(
            action: actions[index],
            cassetteIndex: cassetteIndex,
            activeIntent: activeIntent,
          ),
          if (index < actions.length - 1)
            SizedBox(
              height: 0.5,
              child: ColoredBox(color: colors.lines.borderSubtle),
            ),
        ],
      ],
    );
  }
}

class _SettingsActionRow extends HookConsumerWidget {
  const _SettingsActionRow({
    required this.action,
    required this.cassetteIndex,
    required this.activeIntent,
  });

  final SidebarActionDescriptor action;
  final int cassetteIndex;
  final SidebarActionIntent? activeIntent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = useState(false);
    final isPressed = useState(false);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final isActive =
        activeIntent != null &&
        activeIntent.runtimeType == action.intent.runtimeType;
    final isEnabled = action.isEnabled && activeIntent == null;
    final isCheckingReset =
        isActive && action.intent is ResetMessageDataRequested;
    final visibleLabel = isCheckingReset
        ? 'Checking reset availability…'
        : action.label;
    final backgroundColor = !isEnabled
        ? colors.surfaces.canvas.withValues(alpha: 0)
        : isPressed.value
        ? colors.surfaces.pressed
        : isHovered.value
        ? colors.surfaces.hover
        : colors.surfaces.canvas.withValues(alpha: 0);
    final callback = ref
        .read(settingsActionListActionsProvider.notifier)
        .selectActionCallback(action: action, cassetteIndex: cassetteIndex);

    return Semantics(
      key: ValueKey<String>(
        'settings-action-semantics-${action.intent.runtimeType}',
      ),
      button: true,
      enabled: isEnabled,
      label: visibleLabel,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) {
          if (isEnabled) {
            isHovered.value = true;
          }
        },
        onExit: (_) {
          isHovered.value = false;
          isPressed.value = false;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: isEnabled
              ? (_) {
                  isPressed.value = true;
                }
              : null,
          onTapUp: isEnabled
              ? (_) {
                  isPressed.value = false;
                }
              : null,
          onTapCancel: isEnabled
              ? () {
                  isPressed.value = false;
                }
              : null,
          onTap: callback,
          child: DecoratedBox(
            key: ValueKey<String>(
              'settings-action-surface-${action.intent.runtimeType}',
            ),
            decoration: BoxDecoration(color: backgroundColor),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  if (isCheckingReset) ...[
                    CupertinoActivityIndicator(
                      radius: 7,
                      color: colors.content.textSecondary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      visibleLabel,
                      style: typography.controlValue.copyWith(
                        color: isCheckingReset
                            ? colors.content.textSecondary
                            : _actionColor(
                                colors: colors,
                                action: action,
                                isEnabled: isEnabled,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _actionColor({
    required ThemeColors colors,
    required SidebarActionDescriptor action,
    required bool isEnabled,
  }) {
    if (isEnabled) {
      return switch (action.tone) {
        SidebarActionTone.neutral => colors.content.textPrimary,
        SidebarActionTone.primary => colors.accents.primary,
        SidebarActionTone.destructive => colors.buttons.destructiveForeground,
      };
    }
    return colors.content.textDisabled;
  }
}
