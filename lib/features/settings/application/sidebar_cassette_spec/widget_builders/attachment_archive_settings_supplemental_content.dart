import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../payloads/attachment_archive_settings_cassette_payload.dart';
import 'settings_action_list.dart';

class AttachmentArchiveSettingsSupplementalContent extends ConsumerWidget {
  const AttachmentArchiveSettingsSupplementalContent({
    super.key,
    required this.payload,
  });

  final AttachmentArchiveSettingsCassettePayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (payload.statusLines.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaces.control,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (
                    var index = 0;
                    index < payload.statusLines.length;
                    index++
                  ) ...[
                    Semantics(
                      label:
                          '${payload.statusLines[index].label}: '
                          '${payload.statusLines[index].value}',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            payload.statusLines[index].label,
                            style: typography.caption1.copyWith(
                              color: colors.content.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            payload.statusLines[index].value,
                            style: typography.controlValue.copyWith(
                              color: colors.content.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < payload.statusLines.length - 1)
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
          ),
        ],
        if (payload.actions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SettingsActionList(
            actions: payload.actions,
            cassetteIndex: payload.cassetteIndex,
          ),
        ],
      ],
    );
  }
}
