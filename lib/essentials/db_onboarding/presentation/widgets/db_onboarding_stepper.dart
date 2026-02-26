import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/db_onboarding_phase.dart';
import '../../domain/db_onboarding_state.dart';
import '../../domain/import_sub_stage.dart';
import 'db_onboarding_phase_row.dart';

/// Import stage keys that belong to the "Conversation Metadata" phase.
const _conversationMetadataStageKeys = <String>{
  'clearingLedger',
  'importingHandles',
  'importingChats',
  'importingParticipants',
};

/// Import stage keys that belong to the "Importing Messages" phase.
const _importingMessagesStageKeys = <String>{'importingMessages'};

/// Import stage keys that belong to the "Processing Content" phase.
const _processingContentStageKeys = <String>{'extractingRichContent'};

/// Import stage keys that belong to the "Importing Attachments" phase.
const _importingAttachmentsStageKeys = <String>{
  'importingAttachments',
  'linkingMessageArtifacts',
};

/// Import stage keys that belong to the "Contacts Database" phase.
const _contactsDatabaseStageKeys = <String>{
  'importingAddressBook',
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
            label: _labelForPhase(phase),
            state: _rowStateForPhase(phase),
            subStages: _subStagesForPhase(phase),
          ),
      ],
    );
  }

  /// Get the appropriate label based on the phase's current visual state.
  String _labelForPhase(DbOnboardingPhase phase) {
    final rowState = _rowStateForPhase(phase);
    return switch (rowState) {
      PhaseRowState.pending => phase.pendingLabel,
      PhaseRowState.active => phase.activeLabel,
      PhaseRowState.completed => phase.completeLabel,
      PhaseRowState.error => phase.pendingLabel,
    };
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
      DbOnboardingPhase.conversationMetadata => _conversationMetadataStageKeys,
      DbOnboardingPhase.importingMessages => _importingMessagesStageKeys,
      DbOnboardingPhase.processingContent => _processingContentStageKeys,
      DbOnboardingPhase.importingAttachments => _importingAttachmentsStageKeys,
      DbOnboardingPhase.contactsDatabase => _contactsDatabaseStageKeys,
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
