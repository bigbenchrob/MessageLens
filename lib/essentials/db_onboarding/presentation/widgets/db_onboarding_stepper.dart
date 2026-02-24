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
  const DbOnboardingStepper({
    required this.state,
    super.key,
  });

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
}
