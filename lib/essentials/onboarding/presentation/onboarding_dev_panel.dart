import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';
import '../../conversation_graph/feature_level_providers.dart'
    show
        ConversationGraphBuildReport,
        ConversationGraphBuildStatus,
        ConversationGraphBuildState,
        conversationGraphBuildControllerProvider;
import '../application/onboarding_dev_panel_actions_provider.dart';
import '../application/onboarding_environment_report_provider.dart';
import '../application/onboarding_gate_provider.dart';
import '../application/onboarding_journey_coordinator_provider.dart';
import '../application/onboarding_overlay_actions_provider.dart';
import '../domain/onboarding_environment_report.dart';
import '../domain/onboarding_status.dart';

/// Diagnostic-only developer panel; it does not select production Journey UI.
///
/// Raw report and graph facts are displayed for inspection only. Production
/// onboarding presentation remains owned by [OnboardingJourneyCoordinator].
/// The explicit reset action is a development tool rather than a Journey
/// transition or an alternate state authority.
class OnboardingDevPanel extends ConsumerWidget {
  const OnboardingDevPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final status = ref.watch(onboardingGateProvider);
    final report = ref.watch(onboardingEnvironmentReportProvider).valueOrNull;
    final graphBuildState = ref.watch(conversationGraphBuildControllerProvider);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and reset button.
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Onboarding Dev Panel',
                        style: typography.headline.copyWith(
                          color: colors.content.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${status.name}',
                        style: typography.caption.copyWith(
                          color: colors.content.textSecondary,
                        ),
                      ),
                      if (report != null)
                        Text(
                          'Blocker: ${report.blockerKind.name} • Sync: ${report.syncPlausibility.name}${_pipelineSummary(report)}',
                          style: typography.caption.copyWith(
                            color: colors.content.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: colors.buttons.secondaryBackground,
                  onPressed: () {
                    ref
                        .read(onboardingDevPanelActionsProvider.notifier)
                        .refreshDiagnostics();
                  },
                  child: Text(
                    'Refresh Diagnostics',
                    style: typography.body.copyWith(
                      color: colors.buttons.secondaryForeground,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: colors.buttons.destructiveForeground,
                  onPressed: graphBuildState.isRunning
                      ? null
                      : () async {
                          await ref
                              .read(onboardingDevPanelActionsProvider.notifier)
                              .resetDerivedDataAndRefreshEnvironment();
                        },
                  child: Text(
                    'Reset DBs & Re-trigger',
                    style: typography.body.copyWith(
                      color: colors.buttons.primaryForeground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: colors.lines.borderSubtle),
            const SizedBox(height: 16),
            _DevSimulationControls(colors: colors, typography: typography),
            const SizedBox(height: 16),
            if (report != null) ...[
              _DevEnvironmentSummary(
                report: report,
                colors: colors,
                typography: typography,
              ),
              const SizedBox(height: 16),
            ],
            // Onboarding card content — same as the overlay.
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: switch (status) {
                    OnboardingStatus.recoveringFailedAttempt =>
                      _DevRecoveryContent(
                        colors: colors,
                        typography: typography,
                        report: report,
                      ),
                    OnboardingStatus.preparationFailed =>
                      _DevPreparationFailureContent(
                        colors: colors,
                        typography: typography,
                      ),
                    OnboardingStatus.awaitingFda => _DevFdaContent(
                      colors: colors,
                      typography: typography,
                    ),
                    OnboardingStatus.awaitingUserAction => _DevWelcomeContent(
                      colors: colors,
                      typography: typography,
                    ),
                    OnboardingStatus.importing ||
                    OnboardingStatus.buildingGraph ||
                    OnboardingStatus.reimporting ||
                    OnboardingStatus.reimportBuildingGraph =>
                      _DevProgressContent(
                        colors: colors,
                        typography: typography,
                        graphBuildState: graphBuildState,
                        isReimport:
                            status == OnboardingStatus.reimporting ||
                            status == OnboardingStatus.reimportBuildingGraph,
                      ),
                    OnboardingStatus.complete ||
                    OnboardingStatus.reimportComplete => _DevCompleteContent(
                      colors: colors,
                      typography: typography,
                      graphBuildState: graphBuildState,
                    ),
                    OnboardingStatus.notNeeded => _DevNotNeededContent(
                      colors: colors,
                      typography: typography,
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DevSimulationControls extends ConsumerWidget {
  const _DevSimulationControls({
    required this.colors,
    required this.typography,
  });

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overrides = ref.watch(onboardingDevOverridesProvider);
    final actions = ref.read(onboardingDevPanelActionsProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Simulation Controls',
                  style: typography.body.copyWith(
                    color: colors.content.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (overrides.hasAnyOverride)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: () {
                    actions.clearSimulations();
                  },
                  child: Text(
                    'Clear Simulations',
                    style: typography.caption.copyWith(
                      color: colors.accents.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'These controls only simulate onboarding states inside the app. They do not change macOS permissions or source databases.',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _SimulationToggleRow(
            label: 'Simulate Full Disk Access blocked',
            value: overrides.simulateFullDiskAccessBlocked,
            colors: colors,
            typography: typography,
            onChanged: (value) {
              actions.setFullDiskAccessBlocked(enabled: value);
            },
          ),
          _SimulationToggleRow(
            label: 'Simulate Messages database missing',
            value: overrides.simulateMessagesDatabaseMissing,
            colors: colors,
            typography: typography,
            onChanged: (value) {
              actions.setMessagesDatabaseMissing(enabled: value);
            },
          ),
          _SimulationToggleRow(
            label: 'Simulate Contacts source unavailable',
            value: overrides.simulateAddressBookUnavailable,
            colors: colors,
            typography: typography,
            onChanged: (value) {
              actions.setAddressBookUnavailable(enabled: value);
            },
          ),
          _SimulationToggleRow(
            label: 'Simulate sparse local message history',
            value: overrides.simulateSparseSourceHistory,
            colors: colors,
            typography: typography,
            onChanged: (value) {
              actions.setSparseSourceHistory(enabled: value);
            },
          ),
          _SimulationToggleRow(
            label: 'Simulate import failure',
            value: overrides.simulateImportFailure,
            colors: colors,
            typography: typography,
            onChanged: (value) {
              actions.setImportFailure(enabled: value);
            },
          ),
          _SimulationToggleRow(
            label: 'Simulate graph projection failure',
            value: overrides.simulateGraphProjectionFailure,
            colors: colors,
            typography: typography,
            onChanged: (value) {
              actions.setGraphProjectionFailure(enabled: value);
            },
          ),
        ],
      ),
    );
  }
}

class _SimulationToggleRow extends StatelessWidget {
  const _SimulationToggleRow({
    required this.label,
    required this.value,
    required this.colors,
    required this.typography,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ThemeColors colors;
  final ThemeTypography typography;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: typography.body.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DevEnvironmentSummary extends StatelessWidget {
  const _DevEnvironmentSummary({
    required this.report,
    required this.colors,
    required this.typography,
  });

  final OnboardingEnvironmentReport report;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Environment Report',
            style: typography.body.copyWith(
              color: colors.content.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Messages: ${_probeSummary(report.messagesDatabase)}',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          Text(
            'Contacts: ${report.addressBookDatabase == null ? report.addressBookFailureMessage ?? 'Unavailable' : _probeSummary(report.addressBookDatabase!)}',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          Text(
            'Source-scoped import ledger: ${_probeSummary(report.sourceScopedImportDatabase)}',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          Text(
            'Conversation graph: ${_probeSummary(report.conversationGraph)}',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          if (report.hasImportFailure)
            Text(
              'Last import error: ${report.importFailureMessage ?? 'Unknown error'}${_failureTimestampSuffix(report.lastImportFailureRecordedAt, persisted: report.usingPersistedImportFailure)}',
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          if (report.hasGraphProjectionFailure)
            Text(
              'Last graph projection error: ${report.graphProjectionFailureMessage ?? 'Unknown error'}${_failureTimestampSuffix(report.lastGraphProjectionFailureRecordedAt, persisted: report.usingPersistedGraphProjectionFailure)}',
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

String _pipelineSummary(OnboardingEnvironmentReport report) {
  if (report.hasGraphProjectionFailure) {
    return ' • Pipeline: graph projection failed';
  }
  if (report.hasImportFailure) {
    return ' • Pipeline: import failed';
  }
  return '';
}

String _failureTimestampSuffix(DateTime? timestamp, {required bool persisted}) {
  if (timestamp == null) {
    return '';
  }

  final local = timestamp.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final formatted = '${local.year}-$month-$day $hour:$minute';
  final now = DateTime.now().toLocal();
  final sameDay =
      local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;

  if (!persisted) {
    return ' at $formatted';
  }

  if (sameDay) {
    return ' persisted earlier today at $formatted';
  }

  return ' persisted on $formatted';
}

String _probeSummary(OnboardingDatabaseProbe probe) {
  if (!probe.exists) {
    return 'missing';
  }
  if (!probe.readable) {
    return probe.failureMessage == null
        ? 'blocked'
        : 'blocked: ${probe.failureMessage}';
  }
  final rowCount = probe.rowCount;
  if (rowCount == null) {
    return 'readable';
  }
  return '$rowCount rows';
}

class _DevFdaContent extends ConsumerWidget {
  const _DevFdaContent({required this.colors, required this.typography});

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 56,
          color: colors.status.warning,
        ),
        const SizedBox(height: 20),
        Text(
          'Full Disk Access Required',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'The app cannot read the Messages database.\n'
          'Grant Full Disk Access in System Settings, then relaunch the app.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () async {
            await ref
                .read(onboardingOverlayActionsProvider.notifier)
                .openFullDiskAccessSettings();
          },
          style: FilledButton.styleFrom(
            backgroundColor: colors.buttons.primaryBackground,
            foregroundColor: colors.buttons.primaryForeground,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Open System Settings'),
        ),
      ],
    );
  }
}

class _DevWelcomeContent extends ConsumerWidget {
  const _DevWelcomeContent({required this.colors, required this.typography});

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionContext = ref.watch(
      onboardingJourneyCoordinatorProvider.select(
        (journey) => journey.actionContext,
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.message_rounded, size: 56, color: colors.accents.primary),
        const SizedBox(height: 20),
        Text(
          'Welcome to MessageLens',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'To get started, MessageLens needs to import your Messages '
          'and Contacts data. This is a one-time process.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () async {
            await ref
                .read(onboardingOverlayActionsProvider.notifier)
                .startVirginImportAndGraphBuild(actionContext);
          },
          style: FilledButton.styleFrom(
            backgroundColor: colors.buttons.primaryBackground,
            foregroundColor: colors.buttons.primaryForeground,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Import My Messages'),
        ),
      ],
    );
  }
}

class _DevProgressContent extends StatelessWidget {
  const _DevProgressContent({
    required this.colors,
    required this.typography,
    required this.graphBuildState,
    required this.isReimport,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final ConversationGraphBuildState graphBuildState;
  final bool isReimport;

  @override
  Widget build(BuildContext context) {
    final statusMessage = switch (graphBuildState.status) {
      ConversationGraphBuildStatus.running =>
        isReimport
            ? 'Rebuilding conversation graph…'
            : 'Building conversation graph…',
      ConversationGraphBuildStatus.succeeded =>
        isReimport ? 'Conversation graph rebuilt' : 'Conversation graph built',
      ConversationGraphBuildStatus.failed =>
        graphBuildState.lastError ?? 'Conversation graph build failed',
      ConversationGraphBuildStatus.idle =>
        isReimport ? 'Preparing graph rebuild…' : 'Preparing graph build…',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          statusMessage,
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Source-scoped import ledger and conversation graph build',
          style: typography.caption.copyWith(
            color: colors.content.textTertiary,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value:
                graphBuildState.status == ConversationGraphBuildStatus.succeeded
                ? 1.0
                : null,
            backgroundColor: colors.lines.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(colors.accents.primary),
            minHeight: 6,
          ),
        ),
        if (graphBuildState.lastError != null) ...[
          const SizedBox(height: 12),
          Text(
            graphBuildState.lastError!,
            style: typography.caption.copyWith(color: colors.status.warning),
          ),
        ],
      ],
    );
  }
}

class _DevPreparationFailureContent extends StatelessWidget {
  const _DevPreparationFailureContent({
    required this.colors,
    required this.typography,
  });

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "MessageLens couldn't finish setup",
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "MessageLens couldn't finish preparing your browsing data. "
          'You can try again.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
        ),
      ],
    );
  }
}

class _DevRecoveryContent extends StatelessWidget {
  const _DevRecoveryContent({
    required this.colors,
    required this.typography,
    required this.report,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final OnboardingEnvironmentReport? report;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cleaning up previous setup attempt…',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          report?.resetAppDatabasesReason ??
              'MessageLens is deleting incomplete derived app databases before allowing setup to continue.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            backgroundColor: colors.lines.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(colors.accents.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _DevCompleteContent extends ConsumerWidget {
  const _DevCompleteContent({
    required this.colors,
    required this.typography,
    required this.graphBuildState,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final ConversationGraphBuildState graphBuildState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphBuildReport = graphBuildState.lastReport;
    final actionContext = ref.watch(
      onboardingJourneyCoordinatorProvider.select(
        (journey) => journey.actionContext,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 56,
          color: colors.status.success,
        ),
        const SizedBox(height: 20),
        Text(
          'Import Complete!',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (graphBuildReport != null) ...[
          _GraphBuildSummaryMetrics(
            report: graphBuildReport,
            colors: colors,
            typography: typography,
          ),
          const SizedBox(height: 24),
        ],
        FilledButton(
          onPressed: () {
            ref
                .read(onboardingOverlayActionsProvider.notifier)
                .dismiss(actionContext);
          },
          style: FilledButton.styleFrom(
            backgroundColor: colors.buttons.primaryBackground,
            foregroundColor: colors.buttons.primaryForeground,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Get Started'),
        ),
      ],
    );
  }
}

class _DevNotNeededContent extends StatelessWidget {
  const _DevNotNeededContent({required this.colors, required this.typography});

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 56,
          color: colors.content.textTertiary,
        ),
        const SizedBox(height: 20),
        Text(
          'Onboarding Not Needed',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Both databases exist and contain data.\n'
          'Use "Reset DBs & Re-trigger" above to simulate a fresh install.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _GraphBuildSummaryMetrics extends StatelessWidget {
  const _GraphBuildSummaryMetrics({
    required this.report,
    required this.colors,
    required this.typography,
  });

  final ConversationGraphBuildReport report;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final metrics = <(String, int)>[
      ('Imported', report.messageImportResult.insertedMessageCount),
      ('Projected', report.messageProjectionResult.insertedMessageCount),
      ('Text enriched', report.richTextEnrichmentResult.enrichedMessageCount),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final (label, count) in metrics)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaces.control,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count.toString(),
                  style: typography.headline.copyWith(
                    color: colors.content.textPrimary,
                  ),
                ),
                Text(
                  label,
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
