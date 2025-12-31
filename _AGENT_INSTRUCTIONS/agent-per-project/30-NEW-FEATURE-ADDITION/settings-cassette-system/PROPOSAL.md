# Feature Proposal: Settings Cassette System

**Goal**: Implement a settings system using the existing sidebar cassette architecture to avoid monolithic settings screens and provide a guided, contextual configuration experience. The system will allow users to toggle between a "Messages" mode (content) and a "Settings" mode (configuration) without losing their place in the content.

**Scope**:
*   **New Module**: `lib/essentials/settings/` for all settings-related infrastructure.
*   **UI/UX**:
    *   Add a "Mode Toggle" to the Toolbar (Messages ↔ Settings).
    *   Implement "Settings Mode" where the sidebar displays a stack of Settings Cassettes instead of navigation/search cassettes.
    *   Ensure visual distinction between modes (e.g., active icon states, sidebar headers).
*   **Architecture**:
    *   Introduce `SidebarMode` state to control the application context.
    *   Implement `SettingsCassette` widgets and specifications.
    *   Ensure the "Messages" view state (scroll position, selection) is preserved when switching to Settings and back.
*   **Content**:
    *   Implement the "Root" settings cassette.
    *   Migrate at least one existing setting (e.g., Theme) to the new system to prove the pattern.

**Out of Scope**:
*   Migrating *all* possible settings immediately. This task focuses on the *system* and the *first implementation*.
*   Complex data management settings (e.g., "Import") are out of scope for the *initial* setup, though the system must support them.

**Success Criteria**:
*   User can toggle between Messages and Settings modes.
*   When switching back to Messages, the previous state (selected chat, scroll position) is exactly as left.
*   Settings are presented via the Cassette system (hierarchical, drill-down).
*   The UI clearly indicates which mode is active.
