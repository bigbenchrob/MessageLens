import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/db_onboarding_phase.dart';
import '../../domain/db_onboarding_state.dart';
import '../../domain/import_sub_stage.dart';
import 'db_onboarding_phase_row.dart';

/// Import stage keys that belong to the "Importing Messages" phase.
const _importMessagesStageKeys = <String>{
  'clearingLedger',
  'importingHandles',
  'importingChats',
  'importingParticipants',
  'importingMessages',
  'extractingRichContent',
  'importingAttachments',
  'linkingMessageArtifacts',
};

/// Import stage keys that belong to the "Locating Contacts" phase.
const _locatingContactsStageKeys = <String>{
  'importingAddressBook',
};

/// Import stage keys that belong to the "Linking Contacts" phase.
const _linkingContactsStageKeys = <String>{
  'linkingContacts',
};

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
            subStages: _subStagesForPhase(phase),
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

  /// Get sub-stages applicable to a specific phase.
  List<ImportSubStage> _subStagesForPhase(DbOnboardingPhase phase) {
    // Only return sub-stages for the currently active phase
    if (phase != state.currentPhase) {
      return const [];
    }

    // Filter sub-stages by phase
    final applicableKeys = switch (phase) {
      DbOnboardingPhase.importingMessages => _importMessagesStageKeys,
      DbOnboardingPhase.locatingContacts => _locatingContactsStageKeys,
      DbOnboardingPhase.linkingContacts => _linkingContactsStageKeys,
      _ => const <String>{},
    };

    if (applicableKeys.isEmpty) {
      return const [];
    }

    return state.importSubStages
        .where((s) => applicableKeys.contains(s.key))
        .toList();
  }
}
