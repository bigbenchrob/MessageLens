import 'package:flutter/cupertino.dart';
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

/// Developer panel that mirrors the onboarding overlay UI in the center panel.
///
/// Includes a "Reset & Re-trigger" button that deletes both databases and
/// re-checks the onboarding gate, simulating a fresh first-run scenario.
class OnboardingDevPanel extends ConsumerWidget {
  const OnboardingDevPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final status = ref.watch(onboardingGateProvider);
    final controlState = ref.watch(dbImportControlViewModelProvider);

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
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: const Color(0xFFCC3333),
                  onPressed: controlState.isProcessing
                      ? null
                      : () async {
                          final notifier = ref.read(
                            dbImportControlViewModelProvider.notifier,
                          );
                          await notifier.resetAllDatabases();
                          // Re-evaluate the onboarding gate after DBs are deleted.
                          ref.invalidate(onboardingGateProvider);
                        },
                  child: Text(
                    'Reset DBs & Re-trigger',
                    style: typography.body.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: colors.lines.borderSubtle),
            const SizedBox(height: 16),
            // Onboarding card content — same as the overlay.
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: switch (status) {
                    OnboardingStatus.awaitingUserAction => _DevWelcomeContent(
                      colors: colors,
                      typography: typography,
                    ),
                    OnboardingStatus.importing ||
                    OnboardingStatus.migrating => _DevProgressContent(
                      colors: colors,
                      typography: typography,
                      controlState: controlState,
                    ),
                    OnboardingStatus.complete => _DevCompleteContent(
                      colors: colors,
                      typography: typography,
                      controlState: controlState,
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

class _DevWelcomeContent extends ConsumerWidget {
  const _DevWelcomeContent({required this.colors, required this.typography});

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
            backgroundColor: colors.accents.primary,
            foregroundColor: Colors.white,
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
    required this.controlState,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final DbImportControlState controlState;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controlState.selectedMode == DbImportMode.migration
              ? 'Migrating data…'
              : 'Importing data…',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
        ),
        if (controlState.statusMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            controlState.statusMessage!,
            style: typography.caption.copyWith(
              color: colors.content.textTertiary,
            ),
          ),
        ],
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
      ],
    );
  }
}

class _DevCompleteContent extends ConsumerWidget {
  const _DevCompleteContent({
    required this.colors,
    required this.typography,
    required this.controlState,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final DbImportControlState controlState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importResult = controlState.lastImportResult;

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
        if (importResult != null) ...[
          _SummaryMetrics(
            importResult: importResult,
            migrationResult: controlState.lastMigrationResult,
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
            backgroundColor: colors.accents.primary,
            foregroundColor: Colors.white,
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

class _SummaryMetrics extends StatelessWidget {
  const _SummaryMetrics({
    required this.importResult,
    required this.migrationResult,
    required this.colors,
    required this.typography,
  });

  final DbImportResult importResult;
  final DbMigrationResult? migrationResult;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final metrics = <(String, int)>[
      ('Messages', importResult.messagesImported),
      ('Chats', importResult.chatsImported),
      ('Contacts', importResult.contactsImported),
      ('Attachments', importResult.attachmentsImported),
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
