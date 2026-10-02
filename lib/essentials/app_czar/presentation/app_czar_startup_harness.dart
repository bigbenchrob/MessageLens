import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/spacing/app_spacing.dart';
import '../../../config/theme/theme_typography.dart';
import '../../app_czar_data_update/application/app_czar_data_update_controller.dart';
import '../../app_czar_data_update/presentation/app_czar_data_update_screen.dart';
import '../../app_mode/feature_level_providers.dart'
    show switchableDarkModeProvider;
import '../application/app_czar_assessment_provider.dart';
import '../application/app_czar_presentation_projector.dart';

class AppCzarStartupHarness extends ConsumerWidget {
  const AppCzarStartupHarness({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(switchableDarkModeProvider);
    return MacosApp(
      title: 'MessageLens Development',
      theme: MacosThemeData.light().copyWith(),
      darkTheme: MacosThemeData.dark().copyWith(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const _AppCzarCoordinatorHost(),
    );
  }
}

class _AppCzarCoordinatorHost extends ConsumerWidget {
  const _AppCzarCoordinatorHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataUpdate = ref.watch(appCzarDataUpdateControllerProvider);
    if (dataUpdate.isVisible) {
      return const AppCzarDataUpdateScreen();
    }
    return const AppCzarAssessmentScreen();
  }
}

class AppCzarAssessmentScreen extends ConsumerStatefulWidget {
  const AppCzarAssessmentScreen({super.key});

  static const screenKey = Key('app-czar-assessment-screen');
  static const diagnosisKey = Key('app-czar-diagnosis');
  static const coordinatorKey = Key('app-czar-virtual-coordinator');
  static const detailsKey = Key('app-czar-assessment-details');
  static const runAgainKey = Key('app-czar-run-again');

  @override
  ConsumerState<AppCzarAssessmentScreen> createState() {
    return _AppCzarAssessmentScreenState();
  }
}

class _AppCzarAssessmentScreenState
    extends ConsumerState<AppCzarAssessmentScreen> {
  static const _projector = AppCzarPresentationProjector();

  var _detailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final state = ref.watch(appCzarAssessmentControllerProvider);
    final presentation = _projector.project(state);

    return ColoredBox(
      key: AppCzarAssessmentScreen.screenKey,
      color: colors.surfaces.canvas,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'MessageLens',
                    style: typography.title1.copyWith(
                      color: colors.content.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    presentation.complete
                        ? 'Your current Messages environment has been assessed.'
                        : 'Checking your Messages environment…',
                    style: typography.body.copyWith(
                      color: colors.content.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _AssessmentCard(
                    colors: colors,
                    typography: typography,
                    rows: presentation.rows,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DecisionCard(
                    colors: colors,
                    typography: typography,
                    presentation: presentation,
                  ),
                  if (presentation.complete) ...[
                    const SizedBox(height: AppSpacing.md),
                    _AssessmentDetailsDisclosure(
                      expanded: _detailsExpanded,
                      rows: presentation.rows,
                      colors: colors,
                      typography: typography,
                      onPressed: () {
                        setState(() {
                          _detailsExpanded = !_detailsExpanded;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      key: AppCzarAssessmentScreen.runAgainKey,
                      onPressed: presentation.complete
                          ? () {
                              setState(() {
                                _detailsExpanded = false;
                              });
                              ref
                                  .read(
                                    appCzarAssessmentControllerProvider
                                        .notifier,
                                  )
                                  .runAgain();
                            }
                          : null,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Run assessment again'),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.content.textSecondary,
                        textStyle: typography.controlValue,
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
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({
    required this.colors,
    required this.typography,
    required this.rows,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final List<AppCzarPresentationRow> rows;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            for (var index = 0; index < rows.length; index++) ...[
              _FactRow(
                row: rows[index],
                colors: colors,
                typography: typography,
              ),
              if (index != rows.length - 1) ...[
                const SizedBox(height: AppSpacing.md),
                Divider(height: 1, color: colors.lines.dividerQuiet),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.row,
    required this.colors,
    required this.typography,
  });

  final AppCzarPresentationRow row;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (row.significance) {
      AppCzarPresentationSignificance.healthy => colors.status.success,
      AppCzarPresentationSignificance.attention => colors.status.error,
      AppCzarPresentationSignificance.informational => colors.accents.primary,
      AppCzarPresentationSignificance.unknown => colors.status.warning,
      AppCzarPresentationSignificance.pending => colors.content.textTertiary,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppSpacing.lg,
          height: AppSpacing.lg,
          child: row.significance == AppCzarPresentationSignificance.pending
              ? const ProgressCircle(radius: AppSpacing.sm)
              : Icon(
                  switch (row.significance) {
                    AppCzarPresentationSignificance.healthy =>
                      Icons.check_circle_outline,
                    AppCzarPresentationSignificance.attention =>
                      Icons.error_outline,
                    AppCzarPresentationSignificance.informational =>
                      Icons.info_outline,
                    AppCzarPresentationSignificance.unknown =>
                      Icons.help_outline,
                    AppCzarPresentationSignificance.pending =>
                      Icons.hourglass_empty,
                  },
                  size: AppSpacing.lg,
                  color: statusColor,
                ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.label,
                style: typography.headline.copyWith(
                  color: colors.content.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                row.value,
                style: typography.controlValue.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                row.detail,
                style: typography.caption.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.colors,
    required this.typography,
    required this.presentation,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final AppCzarAssessmentPresentation presentation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surfaceRaised,
        border: Border.all(color: colors.lines.border),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnosis',
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              key: AppCzarAssessmentScreen.diagnosisKey,
              presentation.diagnosis,
              style: typography.title2.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: colors.lines.divider),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Coordinator that would be called',
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              key: AppCzarAssessmentScreen.coordinatorKey,
              presentation.virtualCoordinator,
              style: typography.title3.copyWith(
                color: presentation.complete
                    ? colors.content.textPrimary
                    : colors.content.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Diagnostic only. No coordinator has been started.',
              style: typography.caption.copyWith(
                color: colors.content.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentDetailsDisclosure extends StatelessWidget {
  const _AssessmentDetailsDisclosure({
    required this.expanded,
    required this.rows,
    required this.colors,
    required this.typography,
    required this.onPressed,
  });

  final bool expanded;
  final List<AppCzarPresentationRow> rows;
  final ThemeColors colors;
  final ThemeTypography typography;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          key: AppCzarAssessmentScreen.detailsKey,
          onPressed: onPressed,
          icon: Icon(
            expanded ? Icons.expand_less : Icons.chevron_right,
            size: AppSpacing.lg,
          ),
          label: const Text('Assessment details'),
          style: TextButton.styleFrom(
            foregroundColor: colors.content.textSecondary,
            padding: EdgeInsets.zero,
            textStyle: typography.controlValue,
          ),
        ),
        if (expanded)
          Semantics(
            container: true,
            label: 'AppCzar assessment evidence',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surfaces.control,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(color: colors.lines.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < rows.length; index++) ...[
                    Text(
                      rows[index].label,
                      style: typography.headline.copyWith(
                        color: colors.content.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    for (final evidence in rows[index].evidence)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          '• $evidence',
                          style: typography.caption.copyWith(
                            color: colors.content.textSecondary,
                          ),
                        ),
                      ),
                    if (index != rows.length - 1)
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
