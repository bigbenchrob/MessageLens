# Tests: Settings Cassette System

## Manual Verification Scenarios

### 1. State Preservation (The "Lens" Test)
*   **Goal**: Ensure switching modes does not destroy the user's context in the Messages view.
*   **Steps**:
    1.  Launch the app.
    2.  Navigate to a specific chat in the "Messages" mode.
    3.  Scroll to a specific position in the message list (e.g., halfway up).
    4.  Click the "Settings" gear icon in the toolbar.
    5.  **Check**: The sidebar changes to show Settings options. The center panel may change or dim (depending on final design), but the app should clearly be in Settings mode.
    6.  Click the "Messages" icon (or toggle back).
    7.  **Check**: The app returns to the "Messages" mode. The previously selected chat is still active. The scroll position is exactly where it was left.

### 2. Settings Navigation
*   **Goal**: Verify the cassette system works for settings hierarchy.
*   **Steps**:
    1.  Enter "Settings" mode.
    2.  **Check**: The "Root" settings list is visible (e.g., Appearance, Data, etc.).
    3.  Click on a category (e.g., "Appearance").
    4.  **Check**: A new cassette slides in/appears below, showing options for that category.
    5.  Toggle a setting (e.g., Theme).
    6.  **Check**: The setting applies immediately.

### 3. Mode Distinction
*   **Goal**: Ensure the user knows which mode they are in.
*   **Steps**:
    1.  Observe the Toolbar.
    2.  **Check**: When in "Messages", the Messages icon is active/highlighted.
    3.  **Check**: When in "Settings", the Gear icon is active/highlighted.
