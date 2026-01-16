import 'dart:async' show unawaited;

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/db/domain/overlay_db_constants.dart';
import '../../../feature_level_providers.dart';

class ContactShortNamesSettingsCassette extends ConsumerWidget {
  const ContactShortNamesSettingsCassette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final nameModeAsync = ref.watch(contactNameModeProvider);

    return nameModeAsync.when(
      loading: () => const SizedBox(
        height: 72,
        child: Center(child: CupertinoActivityIndicator(radius: 10)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (selectedMode) => _RadioGroup(
        selectedMode: selectedMode,
        colors: colors,
        typography: typography,
        onModeSelected: (mode) {
          if (mode != selectedMode) {
            unawaited(ref.read(setContactNameModeProvider(mode).future));
          }
        },
      ),
    );
  }
}

class _RadioGroup extends StatelessWidget {
  const _RadioGroup({
    required this.selectedMode,
    required this.colors,
    required this.typography,
    required this.onModeSelected,
  });

  final ParticipantNameMode selectedMode;
  final ThemeColors colors;
  final ThemeTypography typography;
  final ValueChanged<ParticipantNameMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control.withValues(
          alpha: colors.isDark ? 0.45 : 0.60,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OptionRow(
              label: 'First name only',
              mode: ParticipantNameMode.firstNameOnly,
              isSelected: selectedMode == ParticipantNameMode.firstNameOnly,
              colors: colors,
              typography: typography,
              onTap: () => onModeSelected(ParticipantNameMode.firstNameOnly),
            ),
            _OptionRow(
              label: 'First initial + last name',
              mode: ParticipantNameMode.firstInitialLastName,
              isSelected:
                  selectedMode == ParticipantNameMode.firstInitialLastName,
              colors: colors,
              typography: typography,
              onTap: () =>
                  onModeSelected(ParticipantNameMode.firstInitialLastName),
            ),
            _OptionRow(
              label: 'Nickname',
              mode: ParticipantNameMode.nickname,
              isSelected: selectedMode == ParticipantNameMode.nickname,
              colors: colors,
              typography: typography,
              helper: 'Uses a custom name you set per contact',
              onTap: () => onModeSelected(ParticipantNameMode.nickname),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.mode,
    required this.isSelected,
    required this.colors,
    required this.typography,
    required this.onTap,
    this.helper,
  });

  final String label;
  final ParticipantNameMode mode;
  final String? helper;
  final bool isSelected;
  final ThemeColors colors;
  final ThemeTypography typography;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      isSelected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
      size: 16,
      color: isSelected ? colors.accents.primary : colors.lines.border,
    );

    // Use semantic typography: selected emphasized, unselected recedes
    final labelStyle = isSelected
        ? typography.optionListLabelSelected
        : typography.optionListLabelUnselected;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 1), child: icon),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: labelStyle),
                  if (helper != null) ...[
                    const SizedBox(height: 3),
                    Text(helper!, style: typography.optionListHelper),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
