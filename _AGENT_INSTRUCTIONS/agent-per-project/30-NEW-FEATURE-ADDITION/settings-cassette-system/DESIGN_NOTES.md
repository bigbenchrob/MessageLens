# Design Notes: Settings Cassette System

## Architecture Overview

The Settings system will leverage the existing "Cassette" architecture used for the Sidebar. Instead of creating parallel state trees, we will use a **Mode-Based Orchestration** approach. This ensures the `CassetteRackState` remains the single source of truth for what is currently displayed in the sidebar, while a higher-level orchestrator manages the context switching between "Messages" and "Settings".

### 1. State Management: The "Mode" Concept

We will introduce a `SidebarMode` enum to distinguish between the two application contexts:
```dart
enum SidebarMode {
  messages,
  settings,
}
```

We will introduce a `SidebarModeOrchestrator` (Notifier) that manages the active mode and handles the transitions.

*   **`activeSidebarModeProvider`**: Exposes the current `SidebarMode`.
*   **Transition Logic (Messages → Settings)**:
    1.  Snapshot the current `CassetteRackState` (Messages context) and store it in memory within the orchestrator.
    2.  Clear the `CassetteRackState`.
    3.  Push the `SettingsRootCassetteSpec` into the `CassetteRackState`.
    4.  (Optional) Snapshot Center Panel state if needed, though `IndexedStack` in the shell might handle the view persistence better.
*   **Transition Logic (Settings → Messages)**:
    1.  Clear the `CassetteRackState` (Settings context).
    2.  Restore the snapshotted `CassetteRackState` (Messages context).

### 2. UI Structure: `MacosAppShell`

The `MacosAppShell` will use an `IndexedStack` for the **Center Panel** content to preserve the heavy widget trees (Message List, etc.) when switching modes.

The **Sidebar** will remain a single widget tree driven by `CassetteWidgetCoordinator`, but its appearance will react to `activeSidebarModeProvider` (e.g., background tint).

```dart
// Simplified Shell Structure
Row(
  children: [
    // Sidebar (Shared, content changes via Rack State)
    Container(
      color: mode == settings ? tintedColor : defaultColor,
      child: LeftPanelWidget(), 
    ),
    // Center Panel (IndexedStack for state preservation)
    Expanded(
      child: IndexedStack(
        index: mode.index,
        children: [
          MessagesCenterPanel(),
          SettingsCenterPanel(), // Likely empty or specific detail view
        ],
      ),
    ),
  ],
)
```

### 3. Settings Module Structure (`lib/essentials/settings/`)

*   **`domain/`**:
    *   `SettingsSpec`: A sealed class hierarchy defining the navigation targets.
*   **`presentation/`**:
    *   `SettingsCassette`: Widgets for the sidebar cassettes.
*   **`application/`**:
    *   `SettingsCassetteCoordinator`: Logic to map `SettingsSpec` to widgets.
    *   `SidebarModeOrchestrator`: Manages mode switching and state snapshotting.

### 4. Navigation Logic

*   **Toolbar Toggle**:
    *   Clicking "Settings" calls `ref.read(sidebarModeOrchestratorProvider.notifier).toggle(SidebarMode.settings)`.
    *   Clicking "Messages" calls `ref.read(sidebarModeOrchestratorProvider.notifier).toggle(SidebarMode.messages)`.
*   **Drill-down**:
    *   Works exactly like existing cassettes: `ref.read(cassetteRackStateProvider.notifier).push(newSpec)`.

## Migration Strategy

1.  **Define Mode**: Create `SidebarMode` enum.
2.  **Create Orchestrator**: Implement `SidebarModeOrchestrator` to handle snapshot/restore of the rack.
3.  **Update Shell**: Implement `IndexedStack` for the center panel and connect the Toolbar.
4.  **Implement Settings**: Create the `SettingsSpec` and Root Cassette.

## Risks & Mitigations

*   **Risk**: `CassetteRackState` snapshotting might miss ephemeral state (e.g., scroll position *within* a sidebar cassette).
    *   *Mitigation*: Accept this for V1. The primary context users care about preserving is the *Center Panel* (Message List scroll/selection), which `IndexedStack` handles perfectly. Sidebar navigation depth is restored by the snapshot, but exact scroll pixel offset in the sidebar might reset.
