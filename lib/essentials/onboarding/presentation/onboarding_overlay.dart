import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';
import '../../conversation_graph/feature_level_providers.dart'
    show
        ConversationGraphBuildStatus,
        ConversationGraphBuildState,
        conversationGraphBuildControllerProvider;
import '../../logging/application/diagnostic_report_actions.dart';
import '../../logging/domain/diagnostic_report_presentation_result.dart';
import '../../logging/feature_level_providers.dart'
    show diagnosticReportExporterProvider;
import '../application/onboarding_environment_report_provider.dart';
import '../application/onboarding_gate_provider.dart';
import '../application/onboarding_journey_coordinator_provider.dart';
import '../application/onboarding_operation_snapshot_provider.dart';
import '../application/onboarding_overlay_actions_provider.dart';
import '../domain/onboarding_environment_report.dart';
import '../domain/onboarding_journey_state.dart';
import '../domain/onboarding_operation_snapshot.dart';
import '../domain/onboarding_status.dart';
import 'onboarding_journey_path.dart';

/// Full-window blocking overlay for Onboarding-owned operational phases.
///
/// Renders a semi-transparent barrier over the entire app and presents
/// a centered card whose content switches based on [OnboardingStatus]:
///   - [importing] / [buildingGraph] → live stage progress
///   - [complete] → success summary with "Get Started" button
///
/// Production required-source readiness is normally presented by the generic
/// Presence runner. The FDA content remains public because that runner delegates
/// the explicit platform-specific Step back to Onboarding.
class OnboardingOverlay extends ConsumerWidget {
  const OnboardingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(onboardingGateProvider);
    final journey = ref.watch(onboardingJourneyCoordinatorProvider);
    final report = ref.watch(onboardingEnvironmentReportProvider).valueOrNull;
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Stack(
      children: [
        // Barrier: absorbs all input, semi-transparent dark background.
        ModalBarrier(
          dismissible: false,
          color: colors.surfaces.panel.withValues(alpha: 0.85),
        ),
        // Centered card.
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 920),
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colors.surfaces.surfaceRaised,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.lines.borderSubtle,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  OnboardingJourneyPath(journey: journey),
                  switch (status) {
                    OnboardingStatus.recoveringFailedAttempt =>
                      _RecoveryContent(colors: colors, typography: typography),
                    OnboardingStatus.preparationFailed => _WelcomeContent(
                      report: report,
                      colors: colors,
                      typography: typography,
                      operationFailureSummary:
                          journey is OnboardingOperationFailed
                          ? journey.summary
                          : null,
                      presentationOverride: _preparationFailurePresentation,
                      showEnvironmentSummary: false,
                      retriesFailedOperation: true,
                    ),
                    OnboardingStatus.awaitingFda => OnboardingFdaContent(
                      report: report,
                      colors: colors,
                      typography: typography,
                      openSettings: () async {
                        await ref
                            .read(onboardingOverlayActionsProvider.notifier)
                            .openFullDiskAccessSettings();
                      },
                      recheckEnvironment: () {
                        ref
                            .read(onboardingOverlayActionsProvider.notifier)
                            .recheckEnvironment();
                      },
                    ),
                    OnboardingStatus.awaitingUserAction => _WelcomeContent(
                      report: report,
                      colors: colors,
                      typography: typography,
                      operationFailureSummary:
                          journey is OnboardingOperationFailed
                          ? journey.summary
                          : null,
                      retriesFailedOperation:
                          journey is OnboardingOperationFailed,
                    ),
                    OnboardingStatus.importing ||
                    OnboardingStatus.buildingGraph ||
                    OnboardingStatus.reimporting ||
                    OnboardingStatus.reimportBuildingGraph => _ProgressContent(
                      colors: colors,
                      typography: typography,
                      isPreparingFirstRun: status == OnboardingStatus.importing,
                      isReimport:
                          status == OnboardingStatus.reimporting ||
                          status == OnboardingStatus.reimportBuildingGraph,
                    ),
                    OnboardingStatus.complete => _CompleteContent(
                      colors: colors,
                      typography: typography,
                      title: 'You’re ready to start',
                      body: 'Your local MessageLens browsing data is prepared.',
                      dismissLabel: 'OK',
                    ),
                    OnboardingStatus.reimportComplete => _CompleteContent(
                      colors: colors,
                      typography: typography,
                      title: 'MessageLens is ready',
                      body: 'Your local browsing data is prepared.',
                      dismissLabel: 'Done',
                    ),
                    OnboardingStatus.notNeeded => const SizedBox.shrink(),
                  },
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// FDA instruction panel: explains why FDA is needed and how to grant it.
///
/// macOS requires an app restart after granting FDA, so this screen only
/// shows the "Open System Settings" button.  On relaunch the FDA check
/// in [OnboardingGate.build] will pass and the import welcome screen
/// appears automatically.
class OnboardingFdaContent extends StatelessWidget {
  const OnboardingFdaContent({
    required this.report,
    required this.colors,
    required this.typography,
    required this.openSettings,
    required this.recheckEnvironment,
    this.isOpeningSettings = false,
    super.key,
  });

  final OnboardingEnvironmentReport? report;
  final ThemeColors colors;
  final ThemeTypography typography;
  final Future<void> Function() openSettings;
  final VoidCallback? recheckEnvironment;
  final bool isOpeningSettings;

  @override
  Widget build(BuildContext context) {
    final bodyText = _permissionBodyText(report);

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
          bodyText,
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (report != null) ...[
          const SizedBox(height: 16),
          _EnvironmentSummaryCard(
            report: report!,
            colors: colors,
            typography: typography,
          ),
        ],
        const SizedBox(height: 20),
        // Step-by-step instructions.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaces.control,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InstructionStep(
                number: '1',
                text: 'Click "Open System Settings" below',
                colors: colors,
                typography: typography,
              ),
              const SizedBox(height: 8),
              _InstructionStep(
                number: '2',
                text:
                    'Add MessageLens: click the "+" button and find it, '
                    'or drag the app onto the list',
                colors: colors,
                typography: typography,
              ),
              const SizedBox(height: 8),
              _InstructionStep(
                number: '3',
                text:
                    'Toggle MessageLens ON and enter your password '
                    'when prompted',
                colors: colors,
                typography: typography,
              ),
              const SizedBox(height: 8),
              _InstructionStep(
                number: '4',
                text:
                    'macOS will ask you to quit and reopen the app \u2014 '
                    'when it restarts, setup will continue automatically',
                colors: colors,
                typography: typography,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: isOpeningSettings ? null : openSettings,
          style: FilledButton.styleFrom(
            backgroundColor: colors.buttons.primaryBackground,
            foregroundColor: colors.buttons.primaryForeground,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            isOpeningSettings
                ? 'Opening System Settings...'
                : 'Open System Settings',
          ),
        ),
        if (recheckEnvironment case final recheck?) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: recheck,
            child: Text(
              'Re-check environment',
              style: typography.caption.copyWith(
                color: colors.content.textTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({
    required this.number,
    required this.text,
    required this.colors,
    required this.typography,
  });

  final String number;
  final String text;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.accents.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: typography.caption.copyWith(
              color: colors.buttons.primaryForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: typography.body.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Welcome panel: app title + explanation + "Import My Messages" button.
class _WelcomeContent extends ConsumerWidget {
  const _WelcomeContent({
    required this.report,
    required this.colors,
    required this.typography,
    this.presentationOverride,
    this.showEnvironmentSummary = true,
    this.operationFailureSummary,
    this.retriesFailedOperation = false,
  });

  final OnboardingEnvironmentReport? report;
  final ThemeColors colors;
  final ThemeTypography typography;
  final _AwaitingUserActionPresentation? presentationOverride;
  final bool showEnvironmentSummary;
  final String? operationFailureSummary;
  final bool retriesFailedOperation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation =
        presentationOverride ?? _awaitingUserActionPresentation(report);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          presentation.icon,
          size: 56,
          color: presentation.iconColor(colors),
        ),
        const SizedBox(height: 20),
        Text(
          presentation.title,
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          presentation.body,
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (showEnvironmentSummary &&
            report != null &&
            _showsEnvironmentSummary(report!)) ...[
          const SizedBox(height: 16),
          _EnvironmentSummaryCard(
            report: report!,
            colors: colors,
            typography: typography,
          ),
        ],
        if (presentation.notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          _AdviceCard(
            notes: presentation.notes,
            colors: colors,
            typography: typography,
          ),
        ],
        const SizedBox(height: 32),
        if (presentation.canImportImmediately)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: () async {
                  final actions = ref.read(
                    onboardingOverlayActionsProvider.notifier,
                  );
                  if (retriesFailedOperation) {
                    await actions.retryFailedOperation();
                  } else {
                    await actions.startVirginImportAndGraphBuild();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.buttons.primaryBackground,
                  foregroundColor: colors.buttons.primaryForeground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(presentation.primaryActionLabel),
              ),
              if (presentation.canSendDiagnosticReport && report != null)
                OutlinedButton(
                  onPressed: () async {
                    final diagnosticReportExporter = await ref.read(
                      diagnosticReportExporterProvider.future,
                    );
                    final result =
                        await exportOnboardingFailureDiagnosticReport(
                          diagnosticReportExporter,
                          report: report!,
                          operationFailureSummary: operationFailureSummary,
                        );
                    if (!context.mounted) {
                      return;
                    }
                    _showDiagnosticReportSnackBar(context, result: result);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.content.textPrimary,
                    side: BorderSide(color: colors.lines.borderSubtle),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Send Report To Developer'),
                ),
            ],
          )
        else ...[
          FilledButton(
            onPressed: () {
              ref
                  .read(onboardingOverlayActionsProvider.notifier)
                  .recheckEnvironment();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colors.buttons.primaryBackground,
              foregroundColor: colors.buttons.primaryForeground,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Re-check Environment'),
          ),
          if (presentation.allowsManualImport) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await ref
                    .read(onboardingOverlayActionsProvider.notifier)
                    .startVirginImportAndGraphBuild();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.content.textPrimary,
                side: BorderSide(color: colors.lines.borderSubtle),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Import Anyway'),
            ),
          ],
        ],
      ],
    );
  }
}

bool _showsEnvironmentSummary(OnboardingEnvironmentReport report) {
  return report.state != OnboardingEnvironmentState.importFailed &&
      report.state != OnboardingEnvironmentState.graphProjectionFailed;
}

class _EnvironmentSummaryCard extends StatelessWidget {
  const _EnvironmentSummaryCard({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Environment summary',
            style: typography.body.copyWith(
              color: colors.content.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _DiagnosticRow(
            label: 'Full Disk Access',
            value: report.hasFullDiskAccess
                ? 'Available'
                : 'Missing or blocked',
            colors: colors,
            typography: typography,
            isGood: report.hasFullDiskAccess,
          ),
          _DiagnosticRow(
            label: 'Messages database',
            value: _messagesValue(report),
            colors: colors,
            typography: typography,
            isGood: report.messagesDatabase.readable,
          ),
          _DiagnosticRow(
            label: 'Contacts database',
            value: _contactsValue(report),
            colors: colors,
            typography: typography,
            isGood: report.addressBookDatabase?.readable ?? false,
          ),
          _DiagnosticRow(
            label: 'Imported message data',
            value: _appDbValue(report.sourceScopedImportDatabase),
            colors: colors,
            typography: typography,
            isGood: report.sourceScopedImportDatabase.hasData,
          ),
          _DiagnosticRow(
            label: 'Conversation browsing data',
            value: _appDbValue(report.conversationGraph),
            colors: colors,
            typography: typography,
            isGood: report.conversationGraph.hasData,
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({
    required this.notes,
    required this.colors,
    required this.typography,
  });

  final List<String> notes;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What to check',
            style: typography.body.copyWith(
              color: colors.content.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.accents.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      note,
                      style: typography.body.copyWith(
                        color: colors.content.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({
    required this.label,
    required this.value,
    required this.colors,
    required this.typography,
    required this.isGood,
  });

  final String label;
  final String value;
  final ThemeColors colors;
  final ThemeTypography typography;
  final bool isGood;

  @override
  Widget build(BuildContext context) {
    final statusColor = isGood ? colors.status.success : colors.status.warning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isGood ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: typography.caption.copyWith(
                  color: colors.content.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: typography.caption.copyWith(
                      color: colors.content.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _permissionBodyText(OnboardingEnvironmentReport? report) {
  if (report == null) {
    return 'MessageLens needs Full Disk Access to read your Messages and '
        'Contacts databases. Without it, the app cannot import your data.';
  }

  if (!report.messagesDatabase.exists) {
    return 'MessageLens cannot find a local Messages database on this Mac yet. '
        'That can happen if Messages has not created local history here, or if '
        'privacy settings are still blocking access.';
  }

  return 'MessageLens cannot read the local Messages database yet. Grant Full '
      'Disk Access, then relaunch the app so setup can continue.';
}

const _stableSetupFailureTitle = "MessageLens couldn't finish setup";
const _stableSetupFailureBody =
    "MessageLens couldn't finish preparing your browsing data. "
    'You can try again.';

const _preparationFailurePresentation = _AwaitingUserActionPresentation(
  title: _stableSetupFailureTitle,
  body: _stableSetupFailureBody,
  notes: [],
  canImportImmediately: true,
  canSendDiagnosticReport: true,
  allowsManualImport: false,
  primaryActionLabel: 'Try Again',
  icon: Icons.error_outline_rounded,
  iconKind: _PresentationIconKind.warning,
);

_AwaitingUserActionPresentation _awaitingUserActionPresentation(
  OnboardingEnvironmentReport? report,
) {
  if (report == null) {
    return const _AwaitingUserActionPresentation(
      title: 'Welcome to MessageLens',
      body:
          'To get started, MessageLens needs to import your Messages and '
          'Contacts data. This is a one-time process.',
      notes: [],
      canImportImmediately: true,
      canSendDiagnosticReport: false,
      allowsManualImport: false,
      primaryActionLabel: 'Import My Messages',
      icon: Icons.message_rounded,
      iconKind: _PresentationIconKind.primary,
    );
  }

  final incompleteOperationSummary = report.incompleteOperationSummary;
  if (incompleteOperationSummary != null &&
      (report.state == OnboardingEnvironmentState.importFailed ||
          report.state == OnboardingEnvironmentState.graphProjectionFailed)) {
    return _AwaitingUserActionPresentation(
      title: 'Setup was interrupted',
      body: incompleteOperationSummary,
      notes: const [],
      canImportImmediately: true,
      canSendDiagnosticReport: true,
      allowsManualImport: false,
      primaryActionLabel: 'Continue Setup',
      icon: Icons.sync_problem_rounded,
      iconKind: _PresentationIconKind.warning,
    );
  }

  switch (report.state) {
    case OnboardingEnvironmentState.readyToImport:
      return const _AwaitingUserActionPresentation(
        title: 'Ready to Import',
        body:
            'MessageLens can reach the local Messages and Contacts sources on '
            'this Mac. Importing will copy that data into the app.',
        notes: [],
        canImportImmediately: true,
        canSendDiagnosticReport: false,
        allowsManualImport: false,
        primaryActionLabel: 'Import My Messages',
        icon: Icons.message_rounded,
        iconKind: _PresentationIconKind.primary,
      );
    case OnboardingEnvironmentState.sourceUnavailable:
      return _AwaitingUserActionPresentation(
        title: 'Source Data Unavailable',
        body:
            'MessageLens cannot yet reach all of the local source data it '
            'needs on this Mac. Re-check the environment after resolving the '
            'issue below.',
        notes: _sourceUnavailableNotes(report),
        canImportImmediately: false,
        canSendDiagnosticReport: false,
        allowsManualImport: false,
        primaryActionLabel: 'Import My Messages',
        icon: Icons.storage_rounded,
        iconKind: _PresentationIconKind.warning,
      );
    case OnboardingEnvironmentState.sourceSparseOrUnsynced:
      return _AwaitingUserActionPresentation(
        title: 'Little Local Messages History Found',
        body:
            'MessageLens can read the Messages database, but this Mac appears '
            'to have little or no local message history right now.',
        notes: _sourceSparseNotes(report),
        canImportImmediately: false,
        canSendDiagnosticReport: false,
        allowsManualImport: true,
        primaryActionLabel: 'Import My Messages',
        icon: Icons.cloud_off_rounded,
        iconKind: _PresentationIconKind.warning,
      );
    case OnboardingEnvironmentState.importFailed:
      return const _AwaitingUserActionPresentation(
        title: _stableSetupFailureTitle,
        body: _stableSetupFailureBody,
        notes: [],
        canImportImmediately: true,
        canSendDiagnosticReport: true,
        allowsManualImport: false,
        primaryActionLabel: 'Try Import Again',
        icon: Icons.error_outline_rounded,
        iconKind: _PresentationIconKind.warning,
      );
    case OnboardingEnvironmentState.graphProjectionFailed:
      return const _AwaitingUserActionPresentation(
        title: _stableSetupFailureTitle,
        body: _stableSetupFailureBody,
        notes: [],
        canImportImmediately: true,
        canSendDiagnosticReport: true,
        allowsManualImport: false,
        primaryActionLabel: 'Retry Import and Graph Build',
        icon: Icons.sync_problem_rounded,
        iconKind: _PresentationIconKind.warning,
      );
    case OnboardingEnvironmentState.permissionBlocked:
      return _AwaitingUserActionPresentation(
        title: 'Permission Required',
        body: _permissionBodyText(report),
        notes: const [],
        canImportImmediately: false,
        canSendDiagnosticReport: false,
        allowsManualImport: false,
        primaryActionLabel: 'Import My Messages',
        icon: Icons.lock_outline_rounded,
        iconKind: _PresentationIconKind.warning,
      );
    case OnboardingEnvironmentState.ready:
      return const _AwaitingUserActionPresentation(
        title: 'Environment Ready',
        body:
            'The environment looks healthy. MessageLens should be able to use '
            'its imported data on this Mac.',
        notes: [],
        canImportImmediately: false,
        canSendDiagnosticReport: false,
        allowsManualImport: false,
        primaryActionLabel: 'Import My Messages',
        icon: Icons.check_circle_outline,
        iconKind: _PresentationIconKind.success,
      );
    case OnboardingEnvironmentState.maintenanceInProgress:
      return const _AwaitingUserActionPresentation(
        title: 'Message Data Maintenance In Progress',
        body:
            'MessageLens is completing an admitted message-data operation. '
            'Ordinary browsing will resume when that work finishes.',
        notes: [],
        canImportImmediately: false,
        canSendDiagnosticReport: false,
        allowsManualImport: false,
        primaryActionLabel: 'Import My Messages',
        icon: Icons.sync_rounded,
        iconKind: _PresentationIconKind.primary,
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

List<String> _sourceUnavailableNotes(OnboardingEnvironmentReport report) {
  final notes = <String>[];

  if (!report.messagesDatabase.exists) {
    notes.add(
      'Open Messages on this Mac and confirm local history exists here before re-checking.',
    );
  }

  if (report.addressBookDatabase == null ||
      !report.addressBookDatabase!.readable) {
    notes.add(
      report.addressBookFailureMessage ??
          'The Contacts source could not be resolved. Verify that Contacts data is available on this Mac.',
    );
  }

  if (notes.isEmpty) {
    notes.add('Resolve the source-data issue, then re-check the environment.');
  }

  return notes;
}

List<String> _sourceSparseNotes(OnboardingEnvironmentReport report) {
  final notes = <String>[];

  notes.add(
    'Open Messages and confirm this Mac is signed into the Apple Account you expect to inspect.',
  );
  notes.add(
    'If you use Messages in iCloud, wait for local history to appear on this Mac, then re-check the environment.',
  );

  final rowCount = report.messagesDatabase.rowCount;
  if (rowCount != null) {
    notes.add(
      'MessageLens currently sees only $rowCount messages in the local Messages database on this Mac.',
    );
  }

  notes.add(
    'If this Mac genuinely has only a small local archive, you can still import it using "Import Anyway".',
  );

  return notes;
}

String _messagesValue(OnboardingEnvironmentReport report) {
  if (!report.messagesDatabase.exists) {
    return 'Not found';
  }
  if (!report.messagesDatabase.readable) {
    return 'Blocked';
  }

  final rowCount = report.messagesDatabase.rowCount;
  if (rowCount == null) {
    return 'Readable';
  }

  return '$rowCount messages detected';
}

String _contactsValue(OnboardingEnvironmentReport report) {
  final probe = report.addressBookDatabase;
  if (probe == null) {
    return report.addressBookFailureMessage ?? 'Unavailable';
  }
  if (!probe.exists) {
    return 'Not found';
  }
  if (!probe.readable) {
    return 'Blocked';
  }

  final rowCount = probe.rowCount;
  if (rowCount == null) {
    return 'Readable';
  }

  return '$rowCount contacts detected';
}

String _appDbValue(OnboardingDatabaseProbe probe) {
  if (!probe.exists) {
    return 'Not created yet';
  }
  if (!probe.readable) {
    return 'Unavailable';
  }

  final rowCount = probe.rowCount;
  if (rowCount == null) {
    return 'Created';
  }

  if (rowCount == 0) {
    return 'Created but empty';
  }

  return '$rowCount messages stored';
}

enum _PresentationIconKind { primary, warning, success }

class _AwaitingUserActionPresentation {
  const _AwaitingUserActionPresentation({
    required this.title,
    required this.body,
    required this.notes,
    required this.canImportImmediately,
    required this.canSendDiagnosticReport,
    required this.allowsManualImport,
    required this.primaryActionLabel,
    required this.icon,
    required this.iconKind,
  });

  final String title;
  final String body;
  final List<String> notes;
  final bool canImportImmediately;
  final bool canSendDiagnosticReport;
  final bool allowsManualImport;
  final String primaryActionLabel;
  final IconData icon;
  final _PresentationIconKind iconKind;

  Color iconColor(ThemeColors colors) {
    return switch (iconKind) {
      _PresentationIconKind.primary => colors.accents.primary,
      _PresentationIconKind.warning => colors.status.warning,
      _PresentationIconKind.success => colors.status.success,
    };
  }
}

/// Progress panel: overall progress bar + per-stage list.
class _ProgressContent extends ConsumerWidget {
  const _ProgressContent({
    required this.colors,
    required this.typography,
    required this.isPreparingFirstRun,
    this.isReimport = false,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final bool isPreparingFirstRun;
  final bool isReimport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphBuildState = ref.watch(conversationGraphBuildControllerProvider);
    final operationSnapshot = ref
        .watch(onboardingOperationSnapshotProvider)
        .valueOrNull;
    final statusMessage = _progressStatusMessage(
      graphBuildState: graphBuildState,
      isPreparingFirstRun: isPreparingFirstRun,
      isReimport: isReimport,
    );
    final observedProgress = operationSnapshot?.progress;
    final progressValue =
        observedProgress != null && observedProgress.totalWorkUnits > 0
        ? observedProgress.completedWorkUnits / observedProgress.totalWorkUnits
        : !isPreparingFirstRun &&
              graphBuildState.status == ConversationGraphBuildStatus.succeeded
        ? 1.0
        : null;
    final substage = operationSnapshot?.currentSubstage;

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
        if (substage != null) ...[
          const SizedBox(height: 10),
          Text(
            _onboardingSubstageLabel(substage, progress: observedProgress),
            style: typography.body.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressValue,
            backgroundColor: colors.lines.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(colors.accents.primary),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Keep MessageLens open while it prepares your messages. '
          'You can use other apps in the meantime.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

String _onboardingSubstageLabel(
  OnboardingOperationSubstage substage, {
  required OnboardingOperationProgress? progress,
}) {
  final label = switch (substage) {
    OnboardingOperationSubstage.preparingEnvironment => 'Preparing storage',
    OnboardingOperationSubstage.resettingDerivedData =>
      'Resetting rebuildable data',
    OnboardingOperationSubstage.importingChats => 'Conversations',
    OnboardingOperationSubstage.importingHandles => 'Participants',
    OnboardingOperationSubstage.importingContacts => 'Contacts',
    OnboardingOperationSubstage.importingContactEmailChannels =>
      'Contact email addresses',
    OnboardingOperationSubstage.importingContactPhoneChannels =>
      'Contact phone numbers',
    OnboardingOperationSubstage.importingMessages => 'Messages',
    OnboardingOperationSubstage.extractingRichText => 'Message text',
    OnboardingOperationSubstage.persistingRichText => 'Saving message text',
    OnboardingOperationSubstage.importingAttachments => 'Attachments',
    OnboardingOperationSubstage.importingChatMessageRelationships ||
    OnboardingOperationSubstage.importingChatHandleRelationships ||
    OnboardingOperationSubstage.importingMessageAttachmentRelationships =>
      'Message relationships',
    OnboardingOperationSubstage.projectingHandles => 'Preparing participants',
    OnboardingOperationSubstage.projectingContacts => 'Preparing contacts',
    OnboardingOperationSubstage.projectingChatHandleRelationships ||
    OnboardingOperationSubstage.projectingChatMessageRelationships ||
    OnboardingOperationSubstage.projectingMessageAttachmentRelationships =>
      'Preparing relationships',
    OnboardingOperationSubstage.projectingConversations =>
      'Preparing conversations',
    OnboardingOperationSubstage.projectingMessages => 'Preparing messages',
    OnboardingOperationSubstage.projectingAttachments =>
      'Preparing attachments',
    OnboardingOperationSubstage.verifyingDurableReadiness =>
      'Checking prepared data',
  };
  if (progress == null || progress.totalWorkUnits == 0) {
    return label;
  }
  return '$label  ${progress.completedWorkUnits} / '
      '${progress.totalWorkUnits}';
}

String _progressStatusMessage({
  required ConversationGraphBuildState graphBuildState,
  required bool isPreparingFirstRun,
  required bool isReimport,
}) {
  if (isPreparingFirstRun) {
    return 'Preparing setup…';
  }

  return switch (graphBuildState.status) {
    ConversationGraphBuildStatus.running =>
      isReimport ? 'Rebuilding browsing data…' : 'Building browsing data…',
    ConversationGraphBuildStatus.succeeded =>
      isReimport ? 'Browsing data rebuilt' : 'Browsing data ready',
    ConversationGraphBuildStatus.failed =>
      "MessageLens couldn't finish preparing browsing data.",
    ConversationGraphBuildStatus.idle =>
      isReimport ? 'Preparing rebuild…' : 'Preparing setup…',
  };
}

/// Terminal first-run or maintenance completion handoff.
class _CompleteContent extends ConsumerWidget {
  const _CompleteContent({
    required this.colors,
    required this.typography,
    required this.title,
    required this.body,
    required this.dismissLabel,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final String title;
  final String body;
  final String dismissLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          title,
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          body,
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {
            ref.read(onboardingOverlayActionsProvider.notifier).dismiss();
          },
          style: FilledButton.styleFrom(
            backgroundColor: colors.buttons.primaryBackground,
            foregroundColor: colors.buttons.primaryForeground,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(dismissLabel),
        ),
      ],
    );
  }
}

class _RecoveryContent extends ConsumerWidget {
  const _RecoveryContent({required this.colors, required this.typography});

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cleaning_services_outlined,
          size: 56,
          color: colors.accents.primary,
        ),
        const SizedBox(height: 20),
        Text(
          'Preparing MessageLens to try again',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'MessageLens found incomplete browsing data and is preparing for '
          'another setup attempt. Please wait.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.accents.primary,
          ),
        ),
      ],
    );
  }
}
