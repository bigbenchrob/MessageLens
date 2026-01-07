# Virtual Participants

## What are they?
**Virtual Participants** are contacts that exist **only** inside the "Remember Every Text" app. They are not synced to or from your macOS Contacts (Address Book).

## Why do they exist?
They allow you to manually create a "person" and assign them to a phone number or email address (handle) without having to add that person to your system-wide macOS Contacts app.

For example, if you have a chat with a number `+1-555-0123` that isn't in your contacts, you can create a Virtual Participant named "Plumber" inside the app. The app will show "Plumber" for that chat, but your actual Mac Contacts app remains untouched.

## Technical Details
*   **Storage:** They are stored in the `user_overlays.db` (the user preference database), not in the `working.db` (which mirrors your system data). This ensures they persist even if you re-import your system contacts.
*   **ID Range:** To prevent their IDs from clashing with real contacts imported from macOS, Virtual Participants are assigned IDs starting at **1,000,000,000** (1 billion).
    *   *Real Contacts:* IDs `1` to `999,999,999`
    *   *Virtual Contacts:* IDs `1,000,000,000+`
*   **Data:** They have a simple structure containing just a `displayName`, `shortName`, and `notes`.

## Comparison

| Feature | Real Participant | Virtual Participant |
| :--- | :--- | :--- |
| **Source** | macOS Address Book | Created manually in-app |
| **Storage** | `working.db` (read-only projection) | `user_overlays.db` (mutable) |
| **IDs** | Low numbers (e.g., 1, 42, 500) | High numbers (1,000,000,000+) |
| **Persistence** | Overwritten on every import | Persists across imports |
