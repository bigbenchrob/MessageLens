import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../application/db_onboarding_bootstrap_guard.dart';
import '../../application/db_onboarding_state_provider.dart';
import '../../domain/db_onboarding_phase.dart';
import '../../domain/db_onboarding_state.dart';
import '../widgets/db_onboarding_stepper.dart';

/// Database directory path for app databases.
const _databaseDirectoryPath = '/Users/rob/sqlite_rmc/remember_every_text/';

/// Database file definitions for the dev panel.
class _DbFileInfo {
  const _DbFileInfo({
    required this.name,
    required this.filename,
  });

  final String name;
  final String filename;

  String get path => '$_databaseDirectoryPath$filename';
  File get file => File(path);
  bool get exists => file.existsSync();
}

const _databases = [
  _DbFileInfo(name: 'Import Ledger', filename: 'macos_import.db'),
  _DbFileInfo(name: 'Working Database', filename: 'working.db'),
  _DbFileInfo(name: 'User Overlays', filename: 'user_overlays.db'),
];

/// Developer panel for testing the onboarding flow.
///
/// Provides controls to:
/// - View database file status and delete files
/// - See all onboarding phases with their current state (always visible)
/// - Trigger and reset onboarding without the fullscreen overlay
class DbOnboardingDevPanel extends ConsumerStatefulWidget {
  const DbOnboardingDevPanel({super.key});

  @override
  ConsumerState<DbOnboardingDevPanel> createState() =>
      _DbOnboardingDevPanelState();
}

class _DbOnboardingDevPanelState extends ConsumerState<DbOnboardingDevPanel> {
  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final onboardingState = ref.watch(dbOnboardingStateNotifierProvider);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colors),
            const SizedBox(height: 24),
            _buildDatabaseSection(colors),
            const SizedBox(height: 24),
            _buildOnboardingSection(colors, onboardingState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeColors colors) {
    return Row(
      children: [
        Icon(CupertinoIcons.hammer, size: 28, color: colors.accents.primary),
        const SizedBox(width: 12),
        Text(
          'Onboarding Developer Tools',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.content.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDatabaseSection(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lines.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Database Files',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.content.textPrimary,
                ),
              ),
              const Spacer(),
              MacosIconButton(
                icon: const MacosIcon(CupertinoIcons.refresh),
                onPressed: () => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._databases.map((db) => _buildDatabaseRow(colors, db)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: PushButton(
              controlSize: ControlSize.regular,
              secondary: true,
              color: const Color(0xFFFF3B30),
              onPressed: _deleteAllDatabases,
              child: const Text('Delete All Databases'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseRow(ThemeColors colors, _DbFileInfo db) {
    final exists = db.exists;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            exists
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.xmark_circle,
            size: 16,
            color:
                exists ? const Color(0xFF34C759) : colors.content.textTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              db.filename,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'SF Mono',
                color: colors.content.textPrimary,
              ),
            ),
          ),
          if (exists)
            PushButton(
              controlSize: ControlSize.small,
              secondary: true,
              onPressed: () => _deleteDatabase(db),
              child: const Text('Delete'),
            )
          else
            Text(
              'Missing',
              style: TextStyle(
                fontSize: 12,
                color: colors.content.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOnboardingSection(
    ThemeColors colors,
    DbOnboardingState onboardingState,
  ) {
    final isComplete =
        onboardingState.currentPhase == DbOnboardingPhase.complete;
    final isError = onboardingState.currentPhase == DbOnboardingPhase.error;
    final isInitial =
        onboardingState.currentPhase == DbOnboardingPhase.checkingPermissions &&
            !onboardingState.fdaGranted &&
            !onboardingState.devMode;
    final isRunning = !isComplete && !isError && !isInitial;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lines.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Onboarding Steps',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.content.textPrimary,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(colors, isComplete, isError, isRunning),
            ],
          ),
          const SizedBox(height: 16),
          // Always show the stepper
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaces.canvas,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.lines.border),
            ),
            child: DbOnboardingStepper(state: onboardingState),
          ),
          // Error message if applicable
          if (isError && onboardingState.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 16,
                    color: Color(0xFFFF3B30),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      onboardingState.errorMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFFF3B30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: PushButton(
                  controlSize: ControlSize.regular,
                  secondary: true,
                  onPressed: _resetState,
                  child: const Text('Reset State'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PushButton(
                  controlSize: ControlSize.regular,
                  onPressed: isRunning ? null : _startOnboarding,
                  child: Text(isRunning ? 'Running...' : 'Start Onboarding'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    ThemeColors colors,
    bool isComplete,
    bool isError,
    bool isRunning,
  ) {
    if (isComplete) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF34C759).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'Complete',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF34C759),
          ),
        ),
      );
    }
    if (isError) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'Error',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFF3B30),
          ),
        ),
      );
    }
    if (isRunning) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.accents.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Running',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.accents.primary,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _deleteDatabase(_DbFileInfo db) {
    try {
      if (db.exists) {
        db.file.deleteSync();
        setState(() {});
      }
    } catch (e) {
      debugPrint('Failed to delete ${db.filename}: $e');
    }
  }

  void _deleteAllDatabases() {
    for (final db in _databases) {
      try {
        if (db.exists) {
          db.file.deleteSync();
        }
      } catch (e) {
        debugPrint('Failed to delete ${db.filename}: $e');
      }
    }
    setState(() {});
  }

  void _resetState() {
    // Invalidate the bootstrap guard to re-check onboarding requirement
    ref.invalidate(dbOnboardingRequiredProvider);

    // Reset the onboarding state (preserving dev mode)
    ref
        .read(dbOnboardingStateNotifierProvider.notifier)
        .resetState(preserveDevMode: true);

    setState(() {});
  }

  void _startOnboarding() {
    // Invalidate the bootstrap guard to re-check onboarding requirement
    ref.invalidate(dbOnboardingRequiredProvider);

    // Start onboarding in dev mode (suppresses the fullscreen overlay)
    ref.read(dbOnboardingStateNotifierProvider.notifier).startOnboarding(
          devMode: true,
        );
  }
}
