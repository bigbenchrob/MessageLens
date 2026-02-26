import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/db_onboarding_phase.dart';
import '../../domain/db_onboarding_state.dart';
import 'db_onboarding_phase_row.dart';

/// Vertical stepper showing all onboarding phases.
///
/// Renders each phase with the appropriate state (pending/active/completed/error)
/// based on the current onboarding state.
class DbOnboardingStepper extends ConsumerWidget {
  const DbOnboardingStepper({required this.state, super.key});

  /// The current onboarding state.
  final DbOnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final phase in kDbOnboardingPhaseOrder)
          DbOnboardingPhaseRow(
            label: phase.label,
            state: _rowStateForPhase(phase),
            progress: _progressForPhase(phase),
          ),
      ],
    );
  }

  PhaseRowState _rowStateForPhase(DbOnboardingPhase phase) {
    // Error state overrides all
    if (state.currentPhase == DbOnboardingPhase.error) {
      // Mark the phase where error occurred as error
      // For now, mark current phase as error
      return PhaseRowState.pending;
    }

    final currentIndex = state.currentPhase.stepIndex;
    final phaseIndex = phase.stepIndex;

    if (phaseIndex < currentIndex) {
      return PhaseRowState.completed;
    } else if (phaseIndex == currentIndex) {
      return PhaseRowState.active;
    } else {
      return PhaseRowState.pending;
    }
  }

  /// Get progress data for a phase (only meaningful for active phase).
  PhaseProgress? _progressForPhase(DbOnboardingPhase phase) {
    // Only provide progress for the currently active phase
    if (phase != state.currentPhase) {
      return null;
    }

    // Only certain phases have meaningful progress
    if (phase != DbOnboardingPhase.importingMessages &&
        phase != DbOnboardingPhase.linkingContacts) {
      return null;
    }

    return PhaseProgress(
      current: state.importCurrent,
      total: state.importTotal,
      percent: state.progressPercent,
      statusMessage: state.importStatusMessage,
    );
  }
}
