# Design Notes: Settings Cassette System

## Architecture Overview

The Settings system will leverage the existing "Cassette" architecture used for the Sidebar, but instantiated in a separate "Mode" to ensure state isolation. This allows the user to toggle between "Messages" (the main app) and "Settings" without losing their context (scroll position, selection, navigation history) in either mode.

### 1. State Management: The "Mode" Concept

We will introduce a `SidebarMode` enum to distinguish between the two application contexts:
```dart
enum SidebarMode {
  messages,
  settings,
}
```

To support independent navigation stacks and cassette racks for each mode, we will convert key providers into **Family Providers** keyed by `SidebarMode`.

*   **`panelsViewStateProvider`** → `panelsViewStateProvider(SidebarMode)`
    *   Stores the `PanelStack` (navigation history) for the Center Panel.
    *   `messages` mode: Stores the chat/contact navigation.
    *   `settings` mode: Stores the settings drill-down history.

*   **`cassetteRackStateProvider`** → `cassetteRackStateProvider(SidebarMode)`
    *   Stores the list of active cassettes in the Sidebar.
    *   `messages` mode: Stores Search, Recent Chats, etc.
    *   `settings` mode: Stores the Settings Root and subsequent drill-down cassettes.

*   **`cassetteWidgetCoordinatorProvider`** → `cassetteWidgetCoordinatorProvider(SidebarMode)`
    *   Builds the widget tree for the sidebar based on the rack state of the given mode.

### 2. UI Structure: `MacosAppShell`

The `MacosAppShell` will be refactored to use an `IndexedStack` to preserve the widget tree (and thus scroll offsets/input state) of both modes.

```dart
IndexedStack(
  index: currentMode.index,
  children: [
    // Mode: Messages
    WorkspaceLayout(mode: SidebarMode.messages),
    // Mode: Settings
    WorkspaceLayout(mode: SidebarMode.settings),
  ],
)
```

The `WorkspaceLayout` widget will be a reusable component that consumes the family providers for its assigned mode to build the Left Panel (Sidebar) and Center Panel.

### 3. Settings Module Structure (`lib/essentials/settings/`)

*   **`domain/`**:
    *   `SettingsSpec`: A sealed class hierarchy defining the navigation targets (e.g., `SettingsSpec.root()`, `SettingsSpec.appearance()`, `SettingsSpec.data()`).
*   **`presentation/`**:
    *   `SettingsCassette`: Widgets for the sidebar cassettes.
    *   `SettingsPanel`: Widgets for the center panel (if settings require a detail view).
*   **`application/`**:
    *   `SettingsCassetteCoordinator`: Logic to map `SettingsSpec` to widgets.

### 4. Navigation Logic

*   **Toolbar Toggle**:
    *   Clicking "Settings" switches `activeSidebarModeProvider` to `settings`.
    *   Clicking "Messages" switches `activeSidebarModeProvider` to `messages`.
*   **Drill-down**:
    *   Clicking an item in a Settings Cassette (e.g., "Appearance") pushes a new `SettingsSpec` to the `cassetteRackStateProvider(SidebarMode.settings)`.
    *   This mimics the "drill-down" behavior of the Messages sidebar.

## Migration Strategy

1.  **Refactor Providers**: Update `PanelsViewState` and `CassetteRackState` to be families.
2.  **Update Call Sites**: Fix all compilation errors by passing `SidebarMode.messages` to existing calls.
3.  **Implement Shell**: Update `MacosAppShell` to support the mode toggle and `IndexedStack`.
4.  **Implement Settings**: Create the basic `SettingsSpec` and Root Cassette.

## Risks & Mitigations

*   **Risk**: Refactoring core providers (Family) touches many files.
    *   *Mitigation*: Use `dart fix` or bulk edits carefully. Ensure `build_runner` is run frequently.
*   **Risk**: State loss if `IndexedStack` isn't used correctly.
    *   *Mitigation*: Verify scroll position persistence early in the implementation.
