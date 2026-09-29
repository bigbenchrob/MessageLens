import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/logging/application/diagnostic_report_actions.dart';
import '../../../../essentials/logging/domain/diagnostic_report_presentation_result.dart';
import '../../../../essentials/logging/feature_level_providers.dart'
    show diagnosticReportExporterProvider;
import '../../../../essentials/onboarding/domain/onboarding_environment_report.dart';
import '../../../../essentials/onboarding/domain/onboarding_journey_state.dart';
import '../../../../essentials/onboarding/feature_level_providers.dart'
    show onboardingDevOverridesProvider, onboardingJourneyCoordinatorProvider;
import '../../../../essentials/onboarding/presentation/onboarding_journey_path.dart';
import '../../application/environment_readiness_actions_provider.dart';
import '../../application/view_spec/resolver_tools/environment_readiness_surface_provider.dart';
import '../../domain/entities/environment_readiness_surface_view_model.dart';

class EnvironmentReadinessPanelView extends ConsumerStatefulWidget {
  const EnvironmentReadinessPanelView({super.key});

  @override
  ConsumerState<EnvironmentReadinessPanelView> createState() =>
      _EnvironmentReadinessPanelViewState();
}

class _EnvironmentReadinessPanelViewState
    extends ConsumerState<EnvironmentReadinessPanelView> {
  bool _detailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final journey = ref.watch(onboardingJourneyCoordinatorProvider);
    final report = journey.evidence?.report;
    final surface = ref.watch(environmentReadinessSurfaceProvider);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  OnboardingJourneyPath(journey: journey),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, contentConstraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: contentConstraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _Episode(
                                  surface: surface,
                                  report: report,
                                  colors: colors,
                                  typography: typography,
                                ),
                                if (surface.evidence.isNotEmpty) ...<Widget>[
                                  const SizedBox(height: 28),
                                  _DetailsDisclosure(
                                    surface: surface,
                                    report: report,
                                    expanded: _detailsExpanded,
                                    onPressed: () {
                                      setState(() {
                                        _detailsExpanded = !_detailsExpanded;
                                      });
                                    },
                                    colors: colors,
                                    typography: typography,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
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

class _Episode extends ConsumerWidget {
  const _Episode({
    required this.surface,
    required this.report,
    required this.colors,
    required this.typography,
  });

  final EnvironmentReadinessSurfaceViewModel surface;
  final OnboardingEnvironmentReport? report;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _accentFor(surface.tone, colors);
    return Semantics(
      container: true,
      liveRegion: true,
      label: surface.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (surface.kind == EnvironmentReadinessEpisodeKind.checking) ...[
            const ProgressCircle(radius: 12),
            const SizedBox(height: 24),
          ] else ...[
            Icon(_iconFor(surface.kind), size: 38, color: accent),
            const SizedBox(height: 20),
          ],
          Text(
            surface.title,
            style: typography.title1.copyWith(
              color: colors.content.textPrimary,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            surface.body,
            style: typography.body.copyWith(
              color: colors.content.textSecondary,
              fontSize: 16,
              height: 1.45,
            ),
          ),
          if (surface.sanityEvidence case final evidence?) ...<Widget>[
            const SizedBox(height: 18),
            Text(
              evidence,
              style: typography.body.copyWith(
                color: colors.content.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (surface.instructions.isNotEmpty) ...<Widget>[
            const SizedBox(height: 22),
            for (final (index, instruction) in surface.instructions.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${index + 1}.',
                        style: typography.body.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        instruction,
                        style: typography.body.copyWith(
                          color: colors.content.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (surface.primaryAction case final action?) ...<Widget>[
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _ReadinessActionButton(
                  action: action,
                  report: report,
                  actionContext: surface.actionContext,
                  primary: true,
                  colors: colors,
                ),
                for (final secondaryAction in surface.secondaryActions)
                  _ReadinessActionButton(
                    action: secondaryAction,
                    report: report,
                    actionContext: surface.actionContext,
                    primary: false,
                    colors: colors,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadinessActionButton extends ConsumerWidget {
  const _ReadinessActionButton({
    required this.action,
    required this.report,
    required this.primary,
    required this.colors,
    required this.actionContext,
  });

  final EnvironmentReadinessAction action;
  final OnboardingEnvironmentReport? report;
  final bool primary;
  final ThemeColors colors;
  final OnboardingJourneyActionContext actionContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onPressed = _actionCallback(context, ref);
    if (primary) {
      return FilledButton(
        autofocus: true,
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.buttons.primaryBackground,
          foregroundColor: colors.buttons.primaryForeground,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
        child: Text(action.label),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.content.textPrimary,
        side: BorderSide(color: colors.lines.borderSubtle),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      ),
      child: Text(action.label),
    );
  }

  VoidCallback? _actionCallback(BuildContext context, WidgetRef ref) {
    return switch (action.kind) {
      EnvironmentReadinessActionKind.openSettings => () {
        ref
            .read(environmentReadinessActionsProvider.notifier)
            .openFdaSettings();
      },
      EnvironmentReadinessActionKind.recheck => () {
        ref
            .read(environmentReadinessActionsProvider.notifier)
            .refreshEnvironment();
      },
      EnvironmentReadinessActionKind.acceptLocalHistory => () {
        ref
            .read(environmentReadinessActionsProvider.notifier)
            .acceptLocalMessageHistory(actionContext);
      },
      EnvironmentReadinessActionKind.startImport => () {
        ref
            .read(environmentReadinessActionsProvider.notifier)
            .startVirginImportAndGraphBuild(actionContext);
      },
      EnvironmentReadinessActionKind.retryOperation => () {
        ref
            .read(environmentReadinessActionsProvider.notifier)
            .retryFailedOperation(actionContext);
      },
      EnvironmentReadinessActionKind.sendReport =>
        report == null
            ? null
            : () async {
                final exporter = await ref.read(
                  diagnosticReportExporterProvider.future,
                );
                final result = await exportOnboardingFailureDiagnosticReport(
                  exporter,
                  report: report!,
                );
                if (!context.mounted) {
                  return;
                }
                _showDiagnosticReportSnackBar(context, result: result);
              },
    };
  }
}

class _DetailsDisclosure extends ConsumerWidget {
  const _DetailsDisclosure({
    required this.surface,
    required this.report,
    required this.expanded,
    required this.onPressed,
    required this.colors,
    required this.typography,
  });

  final EnvironmentReadinessSurfaceViewModel surface;
  final OnboardingEnvironmentReport? report;
  final bool expanded;
  final VoidCallback onPressed;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devOverrides = ref.watch(onboardingDevOverridesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextButton.icon(
          onPressed: onPressed,
          icon: Icon(
            expanded ? Icons.expand_less : Icons.chevron_right,
            size: 20,
          ),
          label: const Text('Details'),
          style: TextButton.styleFrom(
            foregroundColor: colors.content.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          ),
        ),
        if (expanded)
          Semantics(
            container: true,
            label: 'Environment readiness details',
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 240),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surfaces.control,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.lines.borderSubtle),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final evidence in surface.evidence)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 190,
                              child: Text(
                                evidence.label,
                                style: typography.caption.copyWith(
                                  color: colors.content.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                evidence.value,
                                style: typography.caption1.copyWith(
                                  color: colors.content.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (devOverrides.hasAnyOverride) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        'Developer simulation is active.',
                        style: typography.caption.copyWith(
                          color: colors.content.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          ref
                              .read(
                                environmentReadinessActionsProvider.notifier,
                              )
                              .clearSimulationsAndRefresh();
                        },
                        child: const Text('Clear Simulations'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

IconData _iconFor(EnvironmentReadinessEpisodeKind kind) {
  return switch (kind) {
    EnvironmentReadinessEpisodeKind.checking => Icons.hourglass_empty,
    EnvironmentReadinessEpisodeKind.blocked => Icons.lock_outline_rounded,
    EnvironmentReadinessEpisodeKind.ready => Icons.check_circle_outline_rounded,
    EnvironmentReadinessEpisodeKind.failed => Icons.error_outline_rounded,
  };
}

Color _accentFor(EnvironmentReadinessTone tone, ThemeColors colors) {
  return switch (tone) {
    EnvironmentReadinessTone.primary => colors.accents.primary,
    EnvironmentReadinessTone.warning => colors.status.warning,
    EnvironmentReadinessTone.success => colors.status.success,
    EnvironmentReadinessTone.failure => colors.status.error,
  };
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
      : 'Support bundle prepared and opened in Finder.';
  messenger.showSnackBar(SnackBar(content: Text(message)));
}
