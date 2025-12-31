# Checklist: Settings Cassette System

## Phase 1: Core Architecture (Mode Orchestration)
- [ ] Define `SidebarMode` enum in `lib/essentials/navigation/domain/sidebar_mode.dart`.
- [ ] Create `SidebarModeOrchestrator` in `lib/essentials/navigation/application/sidebar_mode_orchestrator.dart`.
    - [ ] Implement `toggle(SidebarMode)` logic.
    - [ ] Implement snapshotting of `CassetteRackState`.
    - [ ] Implement restoration of `CassetteRackState`.
- [ ] Register `sidebarModeOrchestratorProvider`.

## Phase 2: Shell & Navigation
- [ ] Update `MacosAppShell` to use `IndexedStack` for the **Center Panel** only.
- [ ] Connect Toolbar "Settings" button to `SidebarModeOrchestrator.toggle(settings)`.
- [ ] Connect Toolbar "Messages" button to `SidebarModeOrchestrator.toggle(messages)`.
- [ ] Apply visual tint to Sidebar when in Settings mode.

## Phase 3: Settings Infrastructure
- [ ] Create `lib/essentials/settings/` directory structure (`domain`, `application`, `presentation`).
- [ ] Define `SettingsSpec` sealed class hierarchy in `domain/entities/settings_spec.dart`.
- [ ] Implement `SettingsCassetteCoordinator` in `application/settings_cassette_coordinator.dart`.
- [ ] Update `CassetteWidgetCoordinator` to delegate `SettingsSpec` to `SettingsCassetteCoordinator`.

## Phase 4: Root Settings Implementation
- [ ] Implement `RootSettingsCassette` widget in `presentation/cassettes/root_settings_cassette.dart`.
- [ ] Update `SidebarModeOrchestrator` to push `SettingsSpec.root()` when entering Settings mode.
- [ ] Implement a basic "Appearance" setting (e.g., Theme Toggle) to verify interactivity.

## Phase 5: Verification & Polish
- [ ] Verify toggling between modes preserves the scroll position and selection in "Messages" (Center Panel).
- [ ] Verify "Settings" mode displays the Root Cassette.
- [ ] Verify navigation within Settings (drill-down) works.
- [ ] Ensure visual distinction between modes (e.g., active icon state, sidebar tint).
