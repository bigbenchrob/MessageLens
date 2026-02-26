# DB Onboarding UX Development - State of Progress

**Date:** February 26, 2026  
**Branch:** `Ftr.import-fix`  
**Focus:** Creating a smooth, readable onboarding flow for database import

---

## Task Overview

The goal is to create a polished onboarding experience that shows users the progress of importing their macOS Messages and Contacts databases. The UI is a vertical stepper showing phases like:

1. Permissions verified
2. Messages database found
3. Conversation metadata imported
4. Messages imported
5. Message content processed
6. Attachments imported (with substages)
7. Contacts Database
8. Setup Complete

Each phase should transition smoothly with readable labels that change based on state:
- **Pending:** "Contacts Database"
- **Active:** "Importing contacts..."
- **Complete:** "Contacts imported"

---

## Architecture: Mapping Import Events to UI

### Two-Layer System

1. **`DbImportControlProvider`** (`db_import_control_provider.dart`)
   - Orchestrates the actual import/migration pipeline
   - Fires granular stage events (e.g., `importingHandles`, `importingChats`, `importingMessages`)
   - Reports progress via `UiStageProgress` objects with `current`/`total` counts

2. **`DbOnboardingStateNotifier`** (`db_onboarding_state_provider.dart`)
   - Maps granular import stages to user-friendly phases
   - Manages the visual stepper state
   - Handles phase transition timing/throttling

### Stage-to-Phase Mapping

```dart
DbOnboardingPhase? _mapImportStageToPhase(DbImportStage stage) {
  return switch (stage) {
    DbImportStage.preparingSources => DbOnboardingPhase.messagesDatabase,
    DbImportStage.clearingLedger => DbOnboardingPhase.conversationMetadata,
    DbImportStage.importingHandles => DbOnboardingPhase.conversationMetadata,
    DbImportStage.importingChats => DbOnboardingPhase.conversationMetadata,
    DbImportStage.importingParticipants => DbOnboardingPhase.conversationMetadata,
    DbImportStage.importingMessages => DbOnboardingPhase.importingMessages,
    DbImportStage.extractingRichContent => DbOnboardingPhase.processingContent,
    DbImportStage.importingAttachments => DbOnboardingPhase.importingAttachments,
    DbImportStage.linkingMessageArtifacts => DbOnboardingPhase.importingAttachments,
    DbImportStage.importingAddressBook => DbOnboardingPhase.contactsDatabase,
    DbImportStage.linkingContacts => DbOnboardingPhase.contactsDatabase,
    DbImportStage.completed => null,
  };
}
```

---

## Problems Fixed

### 1. Uneven Step Length
**Problem:** Original phases had wildly different durations - some with 4+ substages, others instant.

**Solution:** Restructured phases for visual pacing:
- Combined `locatingMessages + messagesFound` → `messagesDatabase`
- Split massive `importingMessages` into 4 phases: `conversationMetadata`, `importingMessages`, `processingContent`, `importingAttachments`
- Combined `locatingContacts + linkingContacts` → `contactsDatabase`

### 2. Duplicate Progress Bars
**Problem:** Phases with a single substage showed two parallel progress bars (main + substage) advancing at the same rate.

**Solution:** New display rules in `db_onboarding_phase_row.dart`:
- **Single-substage phases:** Show main progress bar + count on phase row, hide substage list
- **Multi-substage phases (2+):** Show only individual substage progress bars, no main bar

```dart
// Show main progress bar ONLY for single-substage phases
if (singleActiveSubStage != null)
  _buildSingleSubstageProgressBar(singleActiveSubStage, colors),

// Show sub-stages list only when there are multiple (2+) sub-stages
if (state == PhaseRowState.active && subStages.length >= 2)
  _buildSubStagesList(colors),
```

### 3. Progress Bar Visibility
**Problem:** Progress bar background was invisible (same color as canvas).

**Solution:** Changed from `colors.surfaces.controlMuted` to `colors.lines.border`.

### 4. Progress Calculation Issues
**Problem:** Progress stuck at 1% or showing stale data.

**Solution:** Priority in `_updateStageProgress()`:
1. Use `current/total` from row counts when available
2. Fall back to `stageProgress` only if no row counts

### 5. Substages Disappearing
**Problem:** Execution order differs from template display order, causing already-completed stages to disappear.

**Solution:** Preserve completed stages in `_updateStageProgress()` by checking existing state before overwriting.

---

## Current Problem: Phase Transition Timing

### Desired Behavior
Each phase should be visible for at least 1 second so users can read the pending→active→complete label transitions.

### What We've Tried

#### Attempt 1: Single Pending Phase
```dart
DbOnboardingPhase? _pendingPhase;
```
**Problem:** When Phase B is queued and Phase C arrives, C overwrites B. Users see phases jump directly from A to C.

#### Attempt 2: Queue-Based System
```dart
final List<DbOnboardingPhase> _phaseQueue = [];
```
**Problem:** Import stages fire repeatedly during batch processing (e.g., `importingMessages` fires hundreds of times). The queue fills with duplicates and old phases, causing random jumping (1→4→1→5).

#### Attempt 3: Forward-Only Stepping (Current)
```dart
DbOnboardingPhase? _targetPhase;

void _transitionToPhase(DbOnboardingPhase newPhase) {
  // Only accept forward transitions
  if (newPhase.stepIndex < state.currentPhase.stepIndex) {
    return;
  }
  // Update target if further ahead
  if (_targetPhase == null || newPhase.stepIndex > _targetPhase!.stepIndex) {
    _targetPhase = newPhase;
  }
  _scheduleNextStep();
}

void _executeNextStep() {
  // Step to next phase in sequence
  final nextIndex = state.currentPhase.stepIndex + 1;
  final nextPhase = kDbOnboardingPhaseOrder.firstWhere(
    (p) => p.stepIndex == nextIndex,
  );
  state = state.copyWith(currentPhase: nextPhase);
  // Continue if not at target
  if (nextPhase.stepIndex < _targetPhase!.stepIndex) {
    _scheduleNextStep();
  }
}
```

**Status:** Committed but not yet tested. The theory is sound:
- Only accept forward phase transitions
- Track the furthest-ahead "target" phase
- Step through phases one at a time (1→2→3→4...)
- Each step respects the 1-second minimum duration

---

## Key Files

| File | Purpose |
|------|---------|
| `domain/db_onboarding_phase.dart` | Phase enum with `stepIndex`, `pendingLabel`, `activeLabel`, `completeLabel` |
| `domain/db_onboarding_state.dart` | Freezed state class with current phase, substages, progress |
| `application/db_onboarding_state_provider.dart` | State machine, phase mapping, transition throttling |
| `presentation/widgets/db_onboarding_stepper.dart` | Vertical stepper widget, substage grouping |
| `presentation/widgets/db_onboarding_phase_row.dart` | Individual phase row with progress bars |

---

## Recent Commits (Chronological)

1. `d8c00c8` - Auto-navigate to dev panel when DBs empty
2. `3f27f1b` - Progress bar visibility fix
3. `94daab7` - Start button disabled fix
4. `42793b8` - Progress calculation from row counts
5. `24cc228` - Preserve completed stages
6. `80f5e57` - Phase restructuring for even pacing
7. `bb815b4` - Minimum 1-second phase duration (initial)
8. `3084da5` - Hide substage list for single-substage phases
9. `68d76b3` - Simplified progress bar display rules
10. `826c0e3` - Queue-based phase transitions (broken)
11. `42657a1` - Forward-only stepping (current approach, needs testing)

---

## Next Steps

1. **Test the current forward-stepping implementation** - Run the app and verify phases progress smoothly 1→2→3→...→8

2. **If still broken**, consider alternative approaches:
   - Decouple UI animation from import events entirely
   - Use a state machine with explicit entry/exit transitions
   - Add logging to diagnose what's actually happening

3. **Edge cases to verify:**
   - Reset State button clears everything properly
   - Error states display correctly
   - Very fast imports (small databases) still show each phase
   - Very slow imports show progress within each phase

---

## Testing the Onboarding Flow

1. Open Dev Tools panel (auto-opens when databases are empty/absent)
2. Click "Reset State" to clear any existing state
3. Click "Start Import" to begin the onboarding flow
4. Watch the stepper - each phase should:
   - Show pending label briefly
   - Transition to active state with spinner and progress
   - Transition to complete state with checkmark
   - Hold for at least 1 second before next phase starts

Good luck! 🍀
