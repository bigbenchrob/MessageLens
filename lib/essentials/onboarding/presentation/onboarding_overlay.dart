import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';
import '../../db_importers/domain/entities/db_import_result.dart';
import '../../db_importers/presentation/view_model/db_import_control_provider.dart';
import '../../db_migrate/domain/entities/db_migration_result.dart';
import '../application/onboarding_gate_provider.dart';
import '../domain/onboarding_status.dart';
import 'onboarding_progress_view.dart';

/// Full-window blocking overlay shown during first-run onboarding.
///
/// Renders a semi-transparent barrier over the entire app and presents
/// a centered card whose content switches based on [OnboardingStatus]:
///   - [awaitingUserAction] → welcome panel with "Import" button
///   - [importing] / [migrating] → live stage progress
///   - [complete] → success summary with "Get Started" button
class OnboardingOverlay extends ConsumerWidget {
  const OnboardingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(onboardingGateProvider);
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
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
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
              child: switch (status) {
                OnboardingStatus.awaitingUserAction => _WelcomeContent(
                  colors: colors,
                  typography: typography,
                ),
                OnboardingStatus.importing ||
                OnboardingStatus.migrating ||
                OnboardingStatus.reimporting ||
                OnboardingStatus.reimportMigrating => _ProgressContent(
                  colors: colors,
                  typography: typography,
                  isReimport:
                      status == OnboardingStatus.reimporting ||
                      status == OnboardingStatus.reimportMigrating,
                ),
                OnboardingStatus.complete => _CompleteContent(
                  colors: colors,
                  typography: typography,
                  dismissLabel: 'Get Started',
                ),
                OnboardingStatus.reimportComplete => _CompleteContent(
                  colors: colors,
                  typography: typography,
                  dismissLabel: 'Done',
                ),
                OnboardingStatus.notNeeded => const SizedBox.shrink(),
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Welcome panel: app title + explanation + "Import My Messages" button.
class _WelcomeContent extends ConsumerWidget {
  const _WelcomeContent({required this.colors, required this.typography});

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          onPressed: () {
            ref.read(onboardingGateProvider.notifier).startImportAndMigration();
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

/// Progress panel: overall progress bar + per-stage list.
class _ProgressContent extends ConsumerWidget {
  const _ProgressContent({
    required this.colors,
    required this.typography,
    this.isReimport = false,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final bool isReimport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlState = ref.watch(dbImportControlViewModelProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controlState.statusMessage ?? 'Working…',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: controlState.progress,
            backgroundColor: colors.lines.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(colors.accents.primary),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: OnboardingProgressView(
            stages: controlState.stages,
            colors: colors,
            typography: typography,
          ),
        ),
        if (!isReimport) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ref.read(onboardingGateProvider.notifier).abortImport();
              },
              child: Text(
                'Abort Import',
                style: typography.caption.copyWith(
                  color: colors.content.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Success panel: summary metrics + dismiss button.
class _CompleteContent extends ConsumerWidget {
  const _CompleteContent({
    required this.colors,
    required this.typography,
    required this.dismissLabel,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final String dismissLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlState = ref.watch(dbImportControlViewModelProvider);
    final importResult = controlState.lastImportResult;
    final migrationResult = controlState.lastMigrationResult;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 56,
          color: Color(0xFF4CAF50),
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
        if (importResult != null || migrationResult != null) ...[
          _SummaryMetrics(
            importResult: importResult,
            migrationResult: migrationResult,
            colors: colors,
            typography: typography,
          ),
          const SizedBox(height: 24),
        ],
        FilledButton(
          onPressed: () {
            ref.read(onboardingGateProvider.notifier).dismiss();
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

/// Displays key counts from the import/migration results.
class _SummaryMetrics extends StatelessWidget {
  const _SummaryMetrics({
    required this.importResult,
    required this.migrationResult,
    required this.colors,
    required this.typography,
  });

  final DbImportResult? importResult;
  final DbMigrationResult? migrationResult;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final metrics = <(String, int)>[];

    if (importResult != null) {
      metrics.add(('Messages', importResult!.messagesImported));
      metrics.add(('Chats', importResult!.chatsImported));
      metrics.add(('Contacts', importResult!.contactsImported));
      metrics.add(('Attachments', importResult!.attachmentsImported));
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final (label, count) in metrics)
          _MetricChip(
            label: label,
            count: count,
            colors: colors,
            typography: typography,
          ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.count,
    required this.colors,
    required this.typography,
  });

  final String label;
  final int count;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
