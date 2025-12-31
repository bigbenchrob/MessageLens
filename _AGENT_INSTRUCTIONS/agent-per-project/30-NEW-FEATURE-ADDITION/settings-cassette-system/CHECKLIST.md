# Checklist: Settings Cassette System

## Phase 1: Core Architecture Refactor
- [ ] Define `SidebarMode` enum in `lib/essentials/navigation/domain/sidebar_mode.dart`.
- [ ] Create `activeSidebarModeProvider` in `lib/essentials/navigation/application/sidebar_mode_provider.dart`.
- [ ] Refactor `PanelsViewState` to be a family provider: `panelsViewStateProvider(SidebarMode)`.
- [ ] Refactor `CassetteRackState` to be a family provider: `cassetteRackStateProvider(SidebarMode)`.
- [ ] Refactor `CassetteWidgetCoordinator` to be a family provider: `cassetteWidgetCoordinatorProvider(SidebarMode)`.
- [ ] Update all existing call sites (Toolbar, Panels, etc.) to use `SidebarMode.messages`.
- [ ] Run `build_runner` and fix any compilation errors.

## Phase 2: Shell & Navigation
- [ ] Extract current shell content into a reusable `WorkspaceLayout` widget that accepts `SidebarMode`.
- [ ] Update `MacosAppShell` to use `IndexedStack` with two `WorkspaceLayout` children (one for each mode).
- [ ] Connect Toolbar "Settings" button to toggle `activeSidebarModeProvider`.
- [ ] Connect Toolbar "Messages" button (new) to toggle `activeSidebarModeProvider`.
- [ ] Verify "Messages" mode functions identically to before (regression test).

## Phase 3: Settings Infrastructure
- [ ] Create `lib/essentials/settings/` directory structure (`domain`, `application`, `presentation`).
- [ ] Define `SettingsSpec` sealed class hierarchy in `domain/entities/settings_spec.dart`.
- [ ] Implement `SettingsCassetteCoordinator` in `application/settings_cassette_coordinator.dart`.
- [ ] Update `CassetteWidgetCoordinator` to delegate `SettingsSpec` to `SettingsCassetteCoordinator`.

## Phase 4: Root Settings Implementation
- [ ] Implement `RootSettingsCassette` widget in `presentation/cassettes/root_settings_cassette.dart`.
- [ ] Configure `cassetteRackStateProvider(SidebarMode.settings)` to initialize with `SettingsSpec.root()`.
- [ ] Implement a basic "Appearance" setting (e.g., Theme Toggle) to verify interactivity.

## Phase 5: Verification & Polish
- [ ] Verify toggling between modes preserves the scroll position and selection in "Messages".
- [ ] Verify "Settings" mode displays the Root Cassette.
- [ ] Verify navigation within Settings (drill-down) works.
- [ ] Ensure visual distinction between modes (e.g., active icon state).
