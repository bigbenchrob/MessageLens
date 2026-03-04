# Onboarding — Feature Charter

## Mission

Present a full-window blocking overlay on first launch that detects absent/empty databases, lets the user kick off data import + migration with a single button, and shows the exact same stage-by-stage progress the developer pane shows — without adding, removing, or altering any orchestrator or migrator behavior.

## Inviolate Rules

1. **Zero orchestrator changes for cosmetic purposes.** Onboarding calls `runImportAndMigration()` (or the underlying services directly) and listens to the same `onExecutionPlan` / `onTableProgress` callbacks the dev pane uses. If something needs to be _exposed_ from an orchestrator so the UI can initialize or update, that's fine — but no new orchestrator logic, no new migrator steps, no alternate code paths.
2. **No user_overlays.db involvement.** Even if present from a prior run, the overlay DB is never read, written, or consulted during onboarding. The overlay merging at read time continues to work as normal once the app is running — onboarding simply doesn't touch it.
3. **Identical sequence to dev pane.** The user sees the same stages, same table names, same three-phase lifecycle (validatePrereqs → copy → postValidate) as the dev pane. Labels may be made friendlier later, but the underlying data and ordering are identical.
4. **Failure and early-dismiss are deferred.** V1 assumes success. Error handling, retry, partial progress, and mid-onboarding dismissal are future work.
5. **First-run only (V1).** Detection: `macos_import.db` and `working.db` are both absent or empty (zero rows in key tables). Re-import after corruption, sync mismatch, etc. is a later scenario.

## Two Phases

### Phase 1 — Full Disk Access (deferred)
- Informative dialog explaining why FDA is needed
- Screenshot of the macOS Privacy & Security → Full Disk Access pane
- Ideally, open that Settings pane programmatically
- **Not implemented in V1** — skip straight to Phase 2

### Phase 2 — DB Import & Migration (V1 focus)

#### Trigger
On app launch, before the main UI is usable, a provider checks:
- Does `macos_import.db` exist at `_databaseDirectoryPath` AND contain data?
- Does `working.db` exist at `_databaseDirectoryPath` AND contain data?

If **either** is absent or empty → show the onboarding overlay.

#### UX Flow
1. **Gray blocking overlay** covers the entire `MacosWindow` (including toolbar actions). Only the overlay is interactive.
2. **Welcome / explanation panel** with a single primary button: _"Import My Messages"_ (or similar).
3. User taps the button → overlay transitions to **progress view**.
4. **Progress view** displays:
   - Overall linear progress bar (completed stages / total stages)
   - Per-stage rows: icon (pending / active / complete / failed) + display name + row count + inline progress
   - This is the same `UiStageProgress` list the dev pane renders — fed by the same callbacks.
5. On completion → overlay shows **success summary** (message count, contact count, etc.) with a _"Get Started"_ button.
6. Tapping _"Get Started"_ dismisses the overlay and the normal app UI becomes interactive.

#### Architecture

```
lib/essentials/onboarding/
├── domain/
│   └── onboarding_status.dart           # enum: notNeeded, awaitingUserAction, importing, migrating, complete
├── application/
│   └── onboarding_gate_provider.dart    # @riverpod — checks DB existence, exposes OnboardingStatus
├── infrastructure/
│   └── database_existence_checker.dart  # pure function: path → bool (file exists + has rows)
└── presentation/
    ├── onboarding_overlay.dart          # the gray blocking overlay widget
    └── onboarding_progress_view.dart    # reuses UiStageProgress rendering from dev pane (or mirrors it)
```

#### Integration Point

In `MacosAppShell.build()`, the existing `Stack` wrapping `MacosWindow`:

```dart
return Stack(
  children: [
    MacosWindow(...),           // existing
    if (onboardingNeeded)       // NEW — watches onboarding gate provider
      const OnboardingOverlay(),
  ],
);
```

The overlay sits above everything, absorbs all input (via `ModalBarrier` or `AbsorbPointer`), and is removed when the gate provider transitions to `OnboardingStatus.notNeeded`.

#### Progress Data Source

Two options (decide during implementation):

**Option A — Reuse `DbImportControlProvider` directly.**
Onboarding calls `ref.read(dbImportControlProvider.notifier).runImportAndMigration()` and watches `dbImportControlProvider` for `stages`, `progress`, `lastImportResult`, `lastMigrationResult`. The dev pane and onboarding share the same notifier instance.

**Option B — Separate thin notifier that calls services directly.**
Onboarding creates its own `OnboardingImportProvider` that calls `OrchestratedLedgerImportService.runImport()` and `HandlesMigrationService.run()` with its own callbacks. Avoids coupling to the dev pane's UI state.

**Recommendation:** Option A for V1 — simpler, already works, and the dev pane won't be visible during onboarding anyway. If coupling becomes a problem, refactor to Option B later.

## Open Questions (deferred)

- FDA detection and programmatic Settings.app launch (Phase 1)
- Error handling, retry, partial progress recovery
- Mid-onboarding dismissal and resume
- Re-onboarding after DB corruption or manual DB deletion
- Friendly label mapping for stage names
- Animation / polish for stage transitions
