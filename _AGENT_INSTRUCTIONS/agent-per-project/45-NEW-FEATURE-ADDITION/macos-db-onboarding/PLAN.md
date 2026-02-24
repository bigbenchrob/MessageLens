# macOS DB Onboarding Feature Plan

## Overview

A **bootstrap gate** for first-run users that displays a friendly setup status UI while the app locates and imports local macOS databases. This is NOT a wizard—it's a simplified progress overlay that automatically renders until databases are ready.

## Architecture Summary

### Core Principle
`db_onboarding` is the **orchestrator + presenter** only. Heavy lifting stays where it belongs:
- `db_import` → imports data from macOS sources
- `db_migrate` → schema/data migration  
- `db_onboarding` → coordinates and renders user-friendly status

### Key Files
```
lib/essentials/db_onboarding/
├── domain/
│   ├── db_onboarding_state.dart          # DbOnboardingState freezed class
│   └── db_onboarding_phase.dart          # User-facing phase enum
├── application/
│   ├── db_onboarding_state_provider.dart # State notifier
│   └── db_onboarding_bootstrap_guard.dart # "DB empty?" check
├── view_spec/
│   └── coordinators/
│       └── db_setup_spec_coordinator.dart
└── presentation/
    ├── view/
    │   └── db_onboarding_panel.dart      # Center panel UI
    └── widgets/
        ├── db_onboarding_stepper.dart    # Vertical stepper
        └── db_onboarding_phase_row.dart  # Phase row component
```

## User-Facing Phases (Stepper Steps)

The stepper shows these simplified phases:
1. **Checking System Permissions** - Verify FDA (Full Disk Access)
2. **Locating Messages Database** - Finding chat.db
3. **Messages Database Found** - Success checkpoint
4. **Importing Messages** - Reading message data
5. **Locating Contacts** - Finding AddressBook
6. **Linking Contacts** - Connecting chats to contacts
7. **Setup Complete** - Ready to use

## ViewSpec Integration

### New DbSetupSpec
```dart
@freezed
abstract class DbSetupSpec with _$DbSetupSpec {
  const factory DbSetupSpec.firstRun() = _DbSetupFirstRun;
  const factory DbSetupSpec.rerunImport() = _DbSetupRerunImport;  // Future: manual trigger
}
```

### ViewSpec Addition
```dart
// In view_spec.dart
const factory ViewSpec.dbSetup(DbSetupSpec spec) = _ViewDbSetup;
```

### Bootstrap Gate Logic
```dart
// In MacosAppShell or equivalent
// Check at startup:
//   1. If working.db has zero messages AND import never completed
//   2. Route to ViewSpec.dbSetup(DbSetupSpec.firstRun())
//   3. Overlay simple stepper UI while import runs
//   4. When complete, dismiss overlay and show normal messages view
```

## First-Run Detection

Check at startup:
1. Query working.db for message count  
2. If zero messages AND no `import_complete` flag → show onboarding
3. Onboarding sets flag when successfully complete

## Full Disk Access (FDA) Handling

### Phase Flow
1. Show "Checking System Permissions" phase
2. Attempt to stat `/Users/<user>/Library/Messages/chat.db`
3. If permission denied:
   - Show instructions: "Enable Full Disk Access in System Settings"
   - Provide "Open System Settings" button
   - Show "Retry" button
4. Once FDA granted, proceed to next phase

### FDA Instructions Content
- Step-by-step guide to enable FDA
- Screenshot or icon hints
- Link to Apple's documentation (optional)

## State Management

### DbOnboardingState
```dart
@freezed
abstract class DbOnboardingState with _$DbOnboardingState {
  const factory DbOnboardingState({
    required DbOnboardingPhase currentPhase,
    required bool fdaGranted,
    required bool messagesDbFound,
    required bool contactsDbFound,
    required bool importComplete,
    String? errorMessage,
  }) = _DbOnboardingState;
}
```

### DbOnboardingPhase Enum
```dart
enum DbOnboardingPhase {
  checkingPermissions,
  locatingMessages,
  messagesFound,
  importingMessages,
  locatingContacts,
  linkingContacts,
  complete,
  error,
}
```

## UI Design

### Presentation Style
- **NOT** a replacemnt for the full import panel
- Simple overlay rendering in center panel area
- Vertical stepper with phases
- Current phase has spinner
- Completed phases have checkmarks
- Error state shows retry option

### Stepper Visual
```
✓ Checking System Permissions
✓ Locating Messages Database  
● Importing Messages... (with spinner)
○ Locating Contacts
○ Linking Contacts
○ Setup Complete
```

## Integration Points

### 1. MacosAppShell
- Check bootstrap guard at startup
- If triggered, render `DbOnboardingPanel` as overlay
- When complete, fade out and show normal UI

### 2. PanelCoordinator
- Add `dbSetup:` case to route to `DbSetupSpecCoordinator`

### 3. Import System
- Listen to existing `DbImportStage` / `DbMigrationStage` progress
- Map internal stages to simplified user phases

## Hard Invariants

1. **No dual-write** - Onboarding doesn't write to both overlay AND working DB
2. **Import system unchanged** - Don't modify core import logic
3. **Riverpod patterns** - Use @riverpod annotation, no manual providers
4. **Freezed abstract classes** - All Freezed classes must be abstract
5. **hooks_riverpod only** - Never flutter_riverpod
6. **Theme providers** - Use `themeColorsProvider`, not `MacosTheme.of(context)`

## Escape Hatches (Debug)

- "Reset setup" flag for development
- One-line diagnostic: "Last updated: ...", "Import DB: present/absent"
- Hidden "Re-run scan" option

## Success Criteria

1. First-run user sees friendly stepper, not scary import logs
2. FDA check comes first with clear instructions
3. Progress updates in real-time as import runs
4. Overlay dismisses automatically when complete
5. User lands on normal messages timeline
