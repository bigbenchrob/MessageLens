# Onboarding — Interactions & Navigation

## Integration Point

The onboarding overlay lives **outside** the ViewSpec navigation system. It does not use `ViewSpec`, `WindowPanel`, or the sidebar. It is a `Stack` child in `MacosAppShell.build()` that sits above the `MacosWindow` and absorbs all input until dismissed.

```dart
// In MacosAppShell.build():
return Stack(
  children: [
    MacosWindow(...),                      // existing app
    if (showOnboarding)                    // NEW
      const OnboardingOverlay(),           // blocks everything underneath
  ],
);
```

## User Flow (V1 — Happy Path Only)

### Screen 1: Welcome
- Full-window semi-transparent dark overlay
- Centered card with:
  - App icon / title
  - Brief explanation: "MessageLens needs to import your Messages data to get started."
  - Single primary button: **"Import My Messages"**
- All toolbar buttons, sidebar, and content are non-interactive behind the overlay

### Screen 2: Progress
- Same overlay, card transitions to progress view
- **Overall progress bar** at top (stages completed / total stages)
- **Stage list** — each stage is a row:
  - Status icon: ○ pending, ◉ active, ✓ complete
  - Display name
  - Row count (current / total) when active
  - Inline progress bar when active
- Two phases shown sequentially:
  1. **Import** stages (all 13 table importers)
  2. **Migration** stages (11 table migrators + index rebuilds)
- The label above the stage list updates: "Importing data…" → "Migrating data…"

### Screen 3: Complete
- Card transitions to success summary:
  - "Import complete!" heading
  - Key metrics: X messages, Y contacts, Z chats imported
  - Single primary button: **"Get Started"**
- Tapping "Get Started" → overlay removed, app fully usable

## Widget Tree

```
OnboardingOverlay (ConsumerWidget)
├── ModalBarrier(color: Colors.black54, dismissible: false)
└── Center
    └── ConstrainedBox(maxWidth: ~500, maxHeight: ~600)
        └── Card / Container with rounded corners
            └── switch (onboardingStatus) {
                  awaitingUserAction → WelcomeContent(onStart: ...)
                  importing / migrating → ProgressContent(stages: ..., phase: ...)
                  complete → CompleteContent(result: ..., onDismiss: ...)
                }
```

## Provider Wiring

```
OnboardingOverlay
  watches → onboardingGateProvider (OnboardingStatus)
  
OnboardingGateProvider
  reads → file system (DB existence check) on build()
  reads → dbImportControlProvider (to call runImportAndMigration and observe progress)
  exposes → OnboardingStatus enum

MacosAppShell
  watches → onboardingGateProvider
  conditionally renders → OnboardingOverlay when status != notNeeded
```

## What Onboarding Does NOT Do

- Does not create any new ViewSpec variants
- Does not modify the sidebar or cassette system
- Does not add toolbar buttons
- Does not touch the overlay database
- Does not add any new table importers or migrators
- Does not alter orchestrator execution flow
- Does not handle errors (V1)
- Does not handle early dismissal (V1)
- Does not handle re-onboarding after DB deletion (V1)

## ViewSpec Entry Points

_To be defined during planning._

## Cross-Feature Touchpoints

- Import orchestrator
- Migration orchestrator
- Sidebar rack state (must not be disrupted)
- Window state / panel management
