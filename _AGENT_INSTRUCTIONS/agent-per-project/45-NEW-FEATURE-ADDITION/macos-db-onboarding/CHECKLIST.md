# DB Onboarding Implementation Checklist

## Phase 1: Domain Layer Foundation
- [ ] Create `lib/essentials/db_onboarding/domain/db_onboarding_phase.dart`
  - Define `DbOnboardingPhase` enum with all phases
- [ ] Create `lib/essentials/db_onboarding/domain/db_onboarding_state.dart`
  - Define `DbOnboardingState` freezed class
  - Include: currentPhase, fdaGranted, messagesDbFound, contactsDbFound, importComplete, errorMessage

## Phase 2: ViewSpec Integration
- [ ] Create `lib/essentials/navigation/domain/entities/features/db_setup_spec.dart`
  - Define `DbSetupSpec` freezed class with `firstRun()` and `rerunImport()` variants
- [ ] Update `lib/essentials/navigation/domain/entities/view_spec.dart`
  - Add `ViewSpec.dbSetup(DbSetupSpec spec)` variant
- [ ] Run code generation: `dart run build_runner build --delete-conflicting-outputs`

## Phase 3: State Provider
- [ ] Create `lib/essentials/db_onboarding/application/db_onboarding_state_provider.dart`
  - `DbOnboardingStateNotifier` @riverpod class
  - Methods: `startOnboarding()`, `advancePhase()`, `setError()`, `retry()`
  - Listen to import/migration progress and map to phases

## Phase 4: Bootstrap Guard
- [ ] Create `lib/essentials/db_onboarding/application/db_onboarding_bootstrap_guard.dart`
  - `dbOnboardingRequiredProvider` - checks if onboarding needed
  - Logic: working.db has zero messages AND import not complete

## Phase 5: ViewSpec Coordinator
- [ ] Create `lib/essentials/db_onboarding/view_spec/coordinators/db_setup_spec_coordinator.dart`
  - Pattern-match `DbSetupSpec` variants
  - Return appropriate panel widget
- [ ] Update `lib/essentials/navigation/application/panel_coordinator_provider.dart`
  - Add `dbSetup:` case routing to coordinator
- [ ] Export coordinator from feature_level_providers.dart (if created)

## Phase 6: Presentation Widgets
- [ ] Create `lib/essentials/db_onboarding/presentation/widgets/db_onboarding_phase_row.dart`
  - Single phase row: icon (spinner/checkmark/circle) + label
  - State: pending, active (spinning), complete, error
- [ ] Create `lib/essentials/db_onboarding/presentation/widgets/db_onboarding_stepper.dart`
  - Vertical list of phase rows
  - Current phase highlighted with spinner
  - Completed phases with checkmarks
- [ ] Create FDA instructions widget
  - Step-by-step instructions for enabling FDA
  - "Open System Settings" button
  - "Retry" button

## Phase 7: Panel View
- [ ] Create `lib/essentials/db_onboarding/presentation/view/db_onboarding_panel.dart`
  - Main panel UI consuming `dbOnboardingStateProvider`
  - Displays stepper + current status
  - Error state with retry option
  - Completion state with "Continue" or auto-dismiss

## Phase 8: App Shell Integration
- [ ] Update `lib/essentials/navigation/presentation/view/macos_app_shell.dart`
  - Watch `dbOnboardingRequiredProvider`
  - If true, render `DbOnboardingPanel` as overlay
  - When complete, transition to normal UI

## Phase 9: Import System Integration
- [ ] Create progress mapping utility
  - Map `DbImportStage` → `DbOnboardingPhase`
  - Map `DbMigrationStage` → `DbOnboardingPhase`
- [ ] Wire state provider to listen to import progress
- [ ] Implement FDA check logic
  - Stat file to verify permission
  - Update `fdaGranted` flag

## Phase 10: Polish & Testing
- [ ] Test fresh install flow (no databases)
- [ ] Test FDA denied → granted flow
- [ ] Test import error → retry flow
- [ ] Test completion → dismiss flow
- [ ] Verify no lint errors: `flutter analyze`
- [ ] Verify code generation clean

## Deferred / Future
- [ ] Settings panel "Database Setup" row (debug access)
- [ ] "Reset setup" debug command
- [ ] Re-run import option
- [ ] Progress percentage display (optional)
