import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/spacing/app_spacing.dart';
import '../../../config/theme/theme_typography.dart';
import '../../app_czar/application/app_czar_presentation_projector.dart';
import '../domain/app_czar_diagnostic_review_state.dart';

class AppCzarDiagnosticReviewScreen extends ConsumerStatefulWidget {
  const AppCzarDiagnosticReviewScreen({
    required this.state,
    required this.onTryAssessmentAgain,
    required this.onQuitRequested,
    super.key,
  });

  static const screenKey = Key('app-czar-diagnostic-review-screen');
  static const tryAgainKey = Key('app-czar-diagnostic-review-try-again');
  static const quitKey = Key('app-czar-diagnostic-review-quit');
  static const technicalEvidenceKey = Key(
    'app-czar-diagnostic-review-technical-evidence',
  );

  final AppCzarDiagnosticReviewState state;
  final Future<void> Function() onTryAssessmentAgain;
  final Future<void> Function() onQuitRequested;

  @override
  ConsumerState<AppCzarDiagnosticReviewScreen> createState() =>
      _AppCzarDiagnosticReviewScreenState();
}

class _AppCzarDiagnosticReviewScreenState
    extends ConsumerState<AppCzarDiagnosticReviewScreen> {
  static const _projector = AppCzarPresentationProjector();

  bool _technicalEvidenceExpanded = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final occurrence = widget.state.occurrence!;
    final presentation = _projector.projectDiagnostic(
      AppCzarDiagnosticProjectionInput(
        occurrenceSequence: occurrence.processSequence,
        assessmentGeneration: occurrence.assessmentGeneration,
        capturedAssessmentState: occurrence.capturedAssessmentState,
        capturedAt: occurrence.capturedAt,
      ),
    );

    return ColoredBox(
      key: AppCzarDiagnosticReviewScreen.screenKey,
      color: colors.surfaces.canvas,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'MessageLens needs a diagnostic review',
                    style: typography.title1.copyWith(
                      color: colors.content.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Normal use or automatic repair cannot be selected from this bounded evidence.',
                    style: typography.body.copyWith(
                      color: colors.content.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SnapshotCard(
                    generation: presentation.assessmentGeneration,
                    capturedAt: presentation.capturedAt,
                    diagnosis: presentation.diagnosis,
                    colors: colors,
                    typography: typography,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final row in presentation.rows) ...[
                    _DiagnosticRow(
                      row: row,
                      colors: colors,
                      typography: typography,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  TextButton.icon(
                    key: AppCzarDiagnosticReviewScreen.technicalEvidenceKey,
                    onPressed: () {
                      setState(() {
                        _technicalEvidenceExpanded =
                            !_technicalEvidenceExpanded;
                      });
                    },
                    icon: Icon(
                      _technicalEvidenceExpanded
                          ? Icons.expand_less
                          : Icons.chevron_right,
                    ),
                    label: const Text('Technical evidence'),
                  ),
                  if (_technicalEvidenceExpanded)
                    _TechnicalEvidence(
                      rows: presentation.rows,
                      colors: colors,
                      typography: typography,
                    ),
                  if (widget.state.failure case final failure?) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'The restart request failed: $failure',
                      style: typography.body.copyWith(
                        color: colors.status.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      TextButton.icon(
                        key: AppCzarDiagnosticReviewScreen.tryAgainKey,
                        onPressed: widget.state.canRequestRestart
                            ? () async {
                                await widget.onTryAssessmentAgain();
                              }
                            : null,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Try Assessment Again'),
                      ),
                      TextButton.icon(
                        key: AppCzarDiagnosticReviewScreen.quitKey,
                        onPressed:
                            widget.state.phase ==
                                AppCzarDiagnosticReviewPhase.quitRequested
                            ? null
                            : () async {
                                await widget.onQuitRequested();
                              },
                        icon: const Icon(Icons.close),
                        label: const Text('Quit'),
                      ),
                    ],
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

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({
    required this.generation,
    required this.capturedAt,
    required this.diagnosis,
    required this.colors,
    required this.typography,
  });

  final int generation;
  final DateTime capturedAt;
  final String diagnosis;
  final ThemeColors colors;
  final ThemeTypography typography;

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
              diagnosis,
              style: typography.title3.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Assessment generation $generation',
              style: typography.controlValue.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            Text(
              'Captured at ${capturedAt.toLocal().toIso8601String()}',
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This is a bounded snapshot from this process; it is not continuously refreshed.',
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({
    required this.row,
    required this.colors,
    required this.typography,
  });

  final AppCzarDiagnosticPresentationRow row;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (row.status) {
      AppCzarDiagnosticEvidenceStatus.confirmedPositive =>
        colors.status.success,
      AppCzarDiagnosticEvidenceStatus.confirmedNegative => colors.status.error,
      AppCzarDiagnosticEvidenceStatus.insufficient => colors.status.warning,
      AppCzarDiagnosticEvidenceStatus.conflict => colors.status.warning,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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
              '${row.status.label} — ${row.value}',
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
    );
  }
}

class _TechnicalEvidence extends StatelessWidget {
  const _TechnicalEvidence({
    required this.rows,
    required this.colors,
    required this.typography,
  });

  final List<AppCzarDiagnosticPresentationRow> rows;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final row in rows) ...[
              Text(
                '${row.label} — ${row.status.label}',
                style: typography.headline.copyWith(
                  color: colors.content.textPrimary,
                ),
              ),
              for (final evidence in row.evidence)
                Text(
                  '• $evidence',
                  style: typography.caption.copyWith(
                    color: colors.content.textSecondary,
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
