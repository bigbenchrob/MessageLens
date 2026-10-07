import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/spacing/app_spacing.dart';
import '../../../config/theme/theme_typography.dart';
import '../application/app_czar_local_data_repair_controller.dart';
import '../domain/app_czar_local_data_repair_state.dart';

class AppCzarLocalDataRepairScreen extends ConsumerWidget {
  const AppCzarLocalDataRepairScreen({super.key});

  static const screenKey = Key('app-czar-local-data-repair-screen');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final state = ref.watch(appCzarLocalDataRepairControllerProvider);
    final failed = state.phase == AppCzarLocalDataRepairPhase.failed;
    final revalidating =
        state.phase == AppCzarLocalDataRepairPhase.revalidating;
    return ColoredBox(
      key: screenKey,
      color: colors.surfaces.canvas,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    failed
                        ? 'Local data repair needs attention'
                        : revalidating
                        ? 'Rechecking local repair safety'
                        : 'Preparing a clean local rebuild',
                    style: typography.title1.copyWith(
                      color: colors.content.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    failed
                        ? 'MessageLens stopped without claiming success. ${state.failure}'
                        : revalidating
                        ? 'MessageLens is comparing the exact local derived-store footprint with current live sources. Nothing has been deleted.'
                        : 'Current live sources were rechecked. MessageLens is removing only the two rebuildable derived message stores, then it will restart and assess the result.',
                    style: typography.body.copyWith(
                      color: colors.content.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (!failed) const LinearProgressIndicator(),
                  if (failed)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => ref
                            .read(
                              appCzarLocalDataRepairControllerProvider.notifier,
                            )
                            .restartAndReassess(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Restart and reassess'),
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
}
