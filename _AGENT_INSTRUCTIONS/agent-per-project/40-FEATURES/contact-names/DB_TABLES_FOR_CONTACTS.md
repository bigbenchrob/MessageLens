# Contact Name Data Storage Analysis

## 1. Primary Storage: `working.db` (Projection)
This database stores the "source of truth" data projected from macOS AddressBook and Messages. It is generally treated as **read-only** by the UI, as it is overwritten during imports.

### Table: `participants` (`WorkingParticipants`)
*   **Purpose:** Stores contact details imported from the system AddressBook.
*   **Key Columns:**
    *   `id` (PK): Matches the AddressBook `Z_PK`.
    *   `originalName`: The raw name from the source.
    *   `displayName`: The calculated display name (e.g., combined First + Last).
    *   `shortName`: A derived short version (e.g., "Rob B.").
    *   `givenName`, `familyName`: Structured name components.
    *   `organization`: Company name.

### Table: `handles_canonical` (`HandlesCanonical`)
*   **Purpose:** Stores raw handles (phone numbers/emails) and their fallback display names when no contact exists.
*   **Key Columns:**
    *   `displayName`: Formatted phone number or email (e.g., "+1 (555) 000-0000").

## 2. User Overrides: `user_overlays.db` (Mutable)
This database stores user-specific customizations that persist across imports. This is where user-modifiable names should live.

### Table: `participant_overrides` (`ParticipantOverrides`)
*   **Purpose:** Stores user edits that override the system data.
*   **Key Columns:**
    *   `participantId` (PK): Foreign key to `working.participants.id`.
    *   `shortName`: Currently stores a user-defined short name.
    *   **Note:** There is currently **no** `displayName` column in this table. To support custom display names, a `displayName` column would need to be added here.

### Table: `virtual_participants` (`VirtualParticipants`)
*   **Purpose:** Contacts created manually by the user (not in AddressBook).
*   **Key Columns:**
    *   `displayName`: Full name set by the user.
    *   `shortName`: Short name set by the user.

## 3. Drift Functions for Editing & Persisting

These functions are located in `OverlayDatabase` (`lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`).

### Existing Functions (for `shortName`)

*   **`setParticipantShortName(int participantId, String? shortName)`**
    *   **Action:** Inserts or updates a row in `participant_overrides`.
    *   **Logic:** Uses `insertOnConflictUpdate` to handle both creation and modification.
    *   **Timestamping:** Automatically sets `createdAtUtc` and `updatedAtUtc`.

*   **`getAllShortNamesByKey()`**
    *   **Action:** Retrieves all overrides to be merged with working data in memory.
    *   **Return:** `Map<String, String>` (Key: `participant:<id>`, Value: `shortName`).

### For Virtual Participants

*   **`createVirtualParticipant({required String displayName, ...})`**
    *   **Action:** Creates a new purely local contact.

## 4. Recommendation for "User-Modifiable Display Names"

To implement user-modifiable display names for existing contacts, you will need to:

1.  **Modify Schema:** Add a `displayName` `TextColumn` to the `ParticipantOverrides` table in `overlay_database.dart`.
2.  **Migration:** Increment `schemaVersion` in `OverlayDatabase` and write a migration to add the column.
3.  **Add Accessor:** Create a `setParticipantDisplayName(int id, String? name)` method in `OverlayDatabase` mirroring the logic of `setParticipantShortName`.
