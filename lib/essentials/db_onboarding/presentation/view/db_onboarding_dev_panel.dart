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
    required this.description,
  });

  final String name;
  final String filename;
  final String description;

  String get path => '$_databaseDirectoryPath$filename';
  File get file => File(path);
  bool get exists => file.existsSync();
}

const _databases = [
  _DbFileInfo(
    name: 'Import Ledger',
    filename: 'macos_import.db',
    description: 'Raw data imported from macOS Messages & AddressBook',
  ),
  _DbFileInfo(
    name: 'Working Database',
    filename: 'working.db',
    description: 'Drift projection used by the Flutter UI',
  ),
  _DbFileInfo(
    name: 'User Overlays',
    filename: 'user_overlays.db',
    description: 'User preferences and manual link customizations',
  ),
];

/// Developer panel for testing the onboarding flow.
///
/// Provides controls to:
/// - View database file status
/// - Delete individual database files
/// - Trigger the onboarding flow without restarting
class DbOnboardingDevPanel extends ConsumerStatefulWidget {
  const DbOnboardingDevPanel({super.key});

  @override
  ConsumerState<DbOnboardingDevPanel> createState() =>
      _DbOnboardingDevPanelState();
}

class _DbOnboardingDevPanelState extends ConsumerState<DbOnboardingDevPanel> {
  bool _showOnboarding = false;

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
            const SizedBox(height: 32),
            _buildOnboardingSection(colors, onboardingState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeColors colors) {
    return Row(
      children: [
        Icon(
          CupertinoIcons.hammer,
          size: 28,
          color: colors.accents.primary,
        ),
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
          Text(
            'Database Files',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.content.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Delete databases to test onboarding from scratch',
            style: TextStyle(
              fontSize: 13,
              color: colors.content.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ..._databases.map((db) => _buildDatabaseRow(colors, db)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PushButton(
                  controlSize: ControlSize.regular,
                  secondary: true,
                  color: const Color(0xFFFF3B30),
                  onPressed: _deleteAllDatabases,
                  child: const Text('Delete All Databases'),
                ),
              ),
              const SizedBox(width: 12),
              MacosIconButton(
                icon: const MacosIcon(CupertinoIcons.refresh),
                onPressed: () => setState(() {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseRow(ThemeColors colors, _DbFileInfo db) {
    final exists = db.exists;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            exists ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle,
            size: 18,
            color: exists ? const Color(0xFF34C759) : colors.content.textTertiary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  db.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.content.textPrimary,
                  ),
                ),
                Text(
                  db.filename,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'SF Mono',
                    color: colors.content.textSecondary,
                  ),
                ),
              ],
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
              'Not found',
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
          Text(
            'Onboarding Flow',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.content.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Test the onboarding experience in this panel',
            style: TextStyle(
              fontSize: 13,
              color: colors.content.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildOnboardingStatus(colors, onboardingState),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PushButton(
                  controlSize: ControlSize.regular,
                  onPressed: _resetAndStartOnboarding,
                  child: const Text('Reset & Start Onboarding'),
                ),
              ),
              const SizedBox(width: 12),
              PushButton(
                controlSize: ControlSize.regular,
                secondary: true,
                onPressed: () {
                  setState(() {
                    _showOnboarding = !_showOnboarding;
                  });
                },
                child: Text(_showOnboarding ? 'Hide Stepper' : 'Show Stepper'),
              ),
            ],
          ),
          if (_showOnboarding) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaces.canvas,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.lines.border),
              ),
              child: DbOnboardingStepper(state: onboardingState),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOnboardingStatus(ThemeColors colors, DbOnboardingState state) {
    final phase = state.currentPhase;
    final isComplete = phase == DbOnboardingPhase.complete;
    final isError = phase == DbOnboardingPhase.error;

    final (IconData icon, Color color, String status) = isComplete
        ? (CupertinoIcons.checkmark_circle_fill, const Color(0xFF34C759), 'Complete')
        : isError
            ? (CupertinoIcons.exclamationmark_triangle_fill, const Color(0xFFFF3B30), 'Error')
            : (CupertinoIcons.time, colors.accents.primary, phase.name);

    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          'Current Phase: ',
          style: TextStyle(
            fontSize: 14,
            color: colors.content.textSecondary,
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.content.textPrimary,
          ),
        ),
      ],
    );
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

  void _resetAndStartOnboarding() {
    // Invalidate the bootstrap guard to re-check onboarding requirement
    ref.invalidate(dbOnboardingRequiredProvider);

    // Reset the onboarding state and start fresh
    final notifier = ref.read(dbOnboardingStateNotifierProvider.notifier);
    notifier.startOnboarding();

    setState(() {
      _showOnboarding = true;
    });
  }
}
