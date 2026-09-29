import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/logging/application/diagnostic_report_actions.dart';
import '../../../../essentials/logging/domain/diagnostic_report_presentation_result.dart';
import '../../../../essentials/logging/domain/pipeline_incident_report.dart';
import '../../../../essentials/logging/feature_level_providers.dart'
    show
        diagnosticReportExporterProvider,
        activeBlockingPipelineIncidentProvider;
import '../../../../essentials/onboarding/domain/onboarding_journey_state.dart';
import '../../../../essentials/onboarding/feature_level_providers.dart'
    show onboardingJourneyCoordinatorProvider;
import '../../application/pipeline_incident_actions_provider.dart';

class PipelineIncidentPanelView extends ConsumerWidget {
  const PipelineIncidentPanelView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final report = ref
        .watch(activeBlockingPipelineIncidentProvider)
        .valueOrNull;
    final onboardingJourney = ref.watch(onboardingJourneyCoordinatorProvider);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: report == null
              ? Center(
                  child: Text(
                    'No active pipeline incident.',
                    style: typography.body.copyWith(
                      color: colors.content.textSecondary,
                    ),
                  ),
                )
              : _PipelineIncidentBody(
                  report: report,
                  onboardingJourney: onboardingJourney,
                  colors: colors,
                  typography: typography,
                ),
        ),
      ),
    );
  }
}

class _PipelineIncidentBody extends ConsumerWidget {
  const _PipelineIncidentBody({
    required this.report,
    required this.onboardingJourney,
    required this.colors,
    required this.typography,
  });

  final PipelineIncidentReport report;
  final OnboardingJourneyState onboardingJourney;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnboardingRetryAvailable = switch (onboardingJourney) {
      OnboardingOperationFailed(:final failureAction) =>
        failureAction.retriesCommand,
      _ => false,
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: colors.surfaces.surfaceRaised,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colors.status.error.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.status.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: colors.status.error,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Something Went Wrong!',
                  style: typography.headline.copyWith(
                    color: colors.content.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  report.summary,
                  style: typography.body.copyWith(
                    color: colors.content.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetaChip(
                      label: 'Stage: ${report.stage.displayLabel}',
                      colors: colors,
                      typography: typography,
                    ),
                    _MetaChip(
                      label: 'Batch: ${report.batchId}',
                      colors: colors,
                      typography: typography,
                    ),
                    _MetaChip(
                      label: _formatRecordedAt(report.recordedAtUtc),
                      colors: colors,
                      typography: typography,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'What happened',
            colors: colors,
            typography: typography,
            child: Text(
              report.headline,
              style: typography.body.copyWith(
                color: colors.content.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Diagnostic context',
            colors: colors,
            typography: typography,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in report.entries) ...[
                  _IncidentEntryTile(
                    entry: entry,
                    colors: colors,
                    typography: typography,
                  ),
                  if (entry != report.entries.last) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (isOnboardingRetryAvailable)
                FilledButton(
                  onPressed: () {
                    ref
                        .read(pipelineIncidentActionsProvider.notifier)
                        .retryImportAndGraphBuild(
                          onboardingJourney.actionContext,
                        );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.buttons.primaryBackground,
                    foregroundColor: colors.buttons.primaryForeground,
                  ),
                  child: const Text('Retry Import and Graph Build'),
                ),
              OutlinedButton(
                onPressed: () async {
                  final diagnosticReportExporter = await ref.read(
                    diagnosticReportExporterProvider.future,
                  );
                  final result = await exportPipelineIncidentDiagnosticReport(
                    diagnosticReportExporter,
                    report: report,
                  );
                  if (!context.mounted) {
                    return;
                  }
                  _showDiagnosticReportSnackBar(context, result: result);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.content.textPrimary,
                  side: BorderSide(color: colors.lines.borderSubtle),
                ),
                child: const Text('Send Report To Developer'),
              ),
              if (!isOnboardingRetryAvailable)
                OutlinedButton(
                  onPressed: () {
                    ref
                        .read(pipelineIncidentActionsProvider.notifier)
                        .dismissActiveReport();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.content.textPrimary,
                    side: BorderSide(color: colors.lines.borderSubtle),
                  ),
                  child: const Text('Not Now'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.colors,
    required this.typography,
    required this.child,
  });

  final String title;
  final ThemeColors colors;
  final ThemeTypography typography;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaces.surfaceRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typography.body.copyWith(
              color: colors.content.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.colors,
    required this.typography,
  });

  final String label;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(color: colors.content.textSecondary),
      ),
    );
  }
}

class _IncidentEntryTile extends StatelessWidget {
  const _IncidentEntryTile({
    required this.entry,
    required this.colors,
    required this.typography,
  });

  final PipelineIncidentEntry entry;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final accent = switch (entry.severity) {
      PipelineIncidentSeverity.blocking => colors.status.error,
      PipelineIncidentSeverity.warning => colors.status.warning,
      PipelineIncidentSeverity.context => colors.accents.primary,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.22), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.summary,
            style: typography.body.copyWith(
              color: colors.content.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (entry.detail != null && entry.detail!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              entry.detail!,
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

void _showDiagnosticReportSnackBar(
  BuildContext context, {
  required DiagnosticReportPresentationResult result,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }

  final message = result.exportPath == null
      ? 'MessageLens could not prepare a diagnostic report right now.'
      : result.attachedToMailDraft
      ? 'Email draft prepared with the support bundle attached.'
      : 'Support bundle prepared. It was opened in Finder so it can be attached manually.';

  messenger.showSnackBar(SnackBar(content: Text(message)));
}

String _formatRecordedAt(DateTime recordedAtUtc) {
  final local = recordedAtUtc.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return 'Recorded ${local.year}-$month-$day $hour:$minute';
}
