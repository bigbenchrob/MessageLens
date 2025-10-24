# Participant-Handle Architecture: The Correct Design

**Created**: 2025-10-05  
**Status**: Design specification for major refactoring

## The Core Problem

The current `WorkingParticipants` table conflates **people** (participants/contacts) with **communication handles** (phone numbers, email addresses). This creates artificial duplication where "Claire Merriman Campbell" appears as 6 separate participant entries just because she texted via both SMS and iMessage.

**Current (WRONG) design**: Participant = Person × Service  
**Correct design**: Participant = Person, Handle = Communication endpoint

## The Data Model Truth

### Source Data (chat.db)

- **Chats**: Each chat has ONE handle and ONE service (SMS/iMessage/etc)
- **Handles**: Reusable identifiers ("+19991234567", "rusung@icloud.com")
- **Messages**: Belong to chats, linked to sender handles
- **Service**: Property of the CHAT, not the person

### Real World Truth

- **People don't change**: "Cousin Danny" is one person
- **Communication methods vary**: Danny might text from "5149875432" or "danny@circocable.ca"
- **Same handle, multiple chats**: "rusung@icloud.com" appears in many different chat threads
- **One person, multiple handles**: Danny's phone AND email both identify him

## The Correct Architecture

### Canonical Handle Merging Strategy

During migration from import.db to working.db, the system encounters multiple handle records that represent the same real-world identity but differ in service or raw form. For example:

- `+17789908506` with service `iMessage` (handle ID 5)
- `+17789908506` with service `SMS` (handle ID 60)  
- `+17789908506` with service `iMessageLite` (handle ID 265)

Or:

- `+14127362358` (handle ID 123)
- `tel:+14127362358` (handle ID 456)

**Canonicalization Rules:**

1. **Normalization**: All handles are normalized by stripping URI schemes (`tel:`, `mailto:`), removing formatting, and lowercasing emails or extracting digits from phone numbers
2. **Grouping**: Handles with the **same normalized identifier** are grouped together, **regardless of service**
3. **Canonical Selection**: Within each group, one handle is selected as canonical based on preference scoring:
   - For emails: exact match to normalized form (no `mailto:` prefix)
   - For phones: international format with `+` prefix
   - No URI scheme prefix (`tel:`, `mailto:`) is preferred
   - Lowest handle ID as tiebreaker
4. **Alias Recording**: All non-canonical handles in the group are marked as aliases

**Example Result:**

```
handle_canonical_map:
source_handle_id | canonical_handle_id | raw_identifier      | service      | alias_kind
60               | 5                   |  +17789908506       | SMS          | normalized_variant
265              | 5                   | +17789908506        | iMessageLite | normalized_variant

handles table:
id  | raw_identifier | service
5   | +17789908506   | iMessage
```

**How It Works:**

1. **Canonical handles** (handle 5) exist ONLY in the `handles` table
2. **Alias handles** (60, 265) exist ONLY in `handle_canonical_map`, pointing to their canonical
3. **Source handle ID lookup**: If a handle ID isn't in `handle_canonical_map`, it IS the canonical handle

**Critical Insight**: Service is a property of chats, not handles. The same phone number or email used across multiple services (iMessage, SMS, RCS) maps to a **single canonical handle**. This enables:

- One person → one set of canonical handles (phone + email)
- All chats using variants of the same phone number appear under that person
- Proper deduplication: "Claire" appears once, not 3 times for each service

**Migration Impact**: The `handle_canonical_map` table preserves the original chat.db handle IDs (source_handle_id) and maps them to canonical handles (canonical_handle_id). The `chat_to_handle` migrator resolves all source handle IDs to their canonical equivalents when projecting from import.db to working.db.

**Schema Note**: The `handle_canonical_map` table uses `source_handle_id` as PRIMARY KEY. There is NO `UNIQUE(canonical_handle_id, raw_identifier)` constraint - this would incorrectly prevent multiple handles with the same raw identifier (like `+17789908506` across different services) from mapping to the same canonical handle.

### 1. Participants Table (People/Contacts)

```sql
CREATE TABLE participants (
  id INTEGER PRIMARY KEY,        -- Preserves AddressBook Z_PK (no auto-increment!)

  -- Contact identity (from AddressBook)
  original_name TEXT NOT NULL,   -- From AddressBook: COALESCE(first+middle+last, first+org)
  display_name TEXT NOT NULL,    -- User-editable: "Cousin Danny", "Rusung Lee", etc.
  short_name TEXT NOT NULL,      -- For cramped UI: "Danny", "Rusung", etc.

  -- Display metadata
  avatar_ref TEXT
);
```

**Purpose**: Represents actual people/contacts. Populated ONLY when a handle matches an AddressBook contact.  
**Key Design**: `id` preserves the original AddressBook `Z_PK` value for traceability - no auto-increment, no ID mapping needed.

### 2. Handles Table (Communication Endpoints)

```sql
CREATE TABLE handles (
  id INTEGER PRIMARY KEY,             -- Matches chat.db handle.ROWID

  -- Handle identity
  raw_identifier TEXT NOT NULL,       -- "+19991234567", "danny@circocable.ca"
  normalized_identifier TEXT,         -- Canonical form for comparisons
  service TEXT NOT NULL,              -- SMS, iMessage, RCS, etc.

  -- Classification flags
  is_ignored INTEGER DEFAULT 0,       -- Ledger-sourced suppression flag
  is_visible INTEGER DEFAULT 1,       -- UI toggle (defaults to !is_ignored)
  is_blacklisted INTEGER DEFAULT 0,   -- User-managed spam block

  UNIQUE(raw_identifier, service)
);
```

**Purpose**: Represents communication endpoints from chat.db. Exists independently of whether we know the person.

**Flag semantics**:
- `is_ignored`: Imported directly from the ledger projection and never mutated by UI flows. If the source marks a handle as ignored, the working projection keeps that truth.
- `is_visible`: Driven by the UI. Defaults to the inverse of `is_ignored`, but user actions may toggle visibility without touching the ledger flag.
- `is_blacklisted`: Represents an explicit user spam decision. Blacklisted handles hide from UI surfaces and stay blacklisted across import resets because the migration service reapplies stored user decisions after clearing the working tables.

### 3. HandleToParticipant (The Bridge)

```sql
CREATE TABLE handle_to_participant (
  id INTEGER PRIMARY KEY AUTOINCREMENT,

  handle_id INTEGER NOT NULL,        -- FK to handles (alphabetically first)
  participant_id INTEGER NOT NULL,   -- FK to participants (alphabetically second)

  -- Link confidence/source
  confidence REAL DEFAULT 1.0,       -- How sure are we? (1.0 = AddressBook match)
  source TEXT DEFAULT 'addressbook', -- 'addressbook', 'user_manual', 'migration', etc.

  FOREIGN KEY (handle_id) REFERENCES handles(id) ON DELETE CASCADE,
  FOREIGN KEY (participant_id) REFERENCES participants(id) ON DELETE CASCADE,

  UNIQUE(handle_id, participant_id)
);
```

**Purpose**: Maps handles to people when we can identify them. Allows:

1. One person → many handles (Danny's phone + email)
2. Display chats with human-recognizable names
3. "Show all chats with Danny" feature

**Naming**: Follows SQL naming standard from `13-sql-database-standards.md` - alphabetically ordered singular names with `_to_` separator.

### 4. Chats Table (Updated)

```sql
CREATE TABLE chats (
  id INTEGER PRIMARY KEY,        -- Matches chat.db chat.ROWID

  handle_id INTEGER NOT NULL,    -- Which handle this chat uses
  service TEXT NOT NULL,         -- SMS, iMessage (redundant but useful)

  -- Chat metadata
  display_name TEXT,
  guid TEXT NOT NULL UNIQUE,

  FOREIGN KEY (handle_id) REFERENCES handles(id)
);
```

**Key insight**: Service is a CHAT property, not a participant property.

### 5. Messages Table (Updated)

```sql
CREATE TABLE messages (
  id INTEGER PRIMARY KEY,             -- Matches chat.db message.ROWID

  chat_id INTEGER NOT NULL,
  sender_handle_id INTEGER NOT NULL,  -- Sender's handle (renamed from sender_participant_id)

  -- Message content
  text TEXT,
  date INTEGER,
  is_from_me INTEGER,

  FOREIGN KEY (chat_id) REFERENCES chats(id),
  FOREIGN KEY (sender_handle_id) REFERENCES handles(id)
);
```

**No more `sender_participant_id`**: Messages link to handles, not participants. We can resolve to participants via `handle_to_participant` when needed.

## The Import Process (Corrected)

### Phase 1: Import Core Chat Data + AddressBook Data

**Into macos_import.db:**

```sql
-- Import chat.db handles/chats/messages (preserve ROWIDs)
1. Import handles from chat.db → handles table
2. Import chats from chat.db → chats table (with handle_id FK)
3. Import messages from chat.db → messages table (with sender_handle_id FK)

-- Import AddressBook contacts (preserve Z_PK)
4. Import ZABCDRECORD → contact table:
   - id: Z_PK (preserved, no auto-increment!)
   - first_name: ZFIRSTNAME
   - middle_name: ZMIDDLENAME
   - last_name: ZLASTNAME
   - nickname: ZNICKNAME
   - organization: ZORGANIZATION

5. Import ZABCDPHONENUMBER → contact_phones table:
   - contact_id: ZOWNER (FK to contact.id)
   - full_number: ZFULLNUMBER

6. Import ZABCDEMAILADDRESS → contact_emails table:
   - contact_id: ZOWNER (FK to contact.id)
   - address_normalized: ZADDRESSNORMALIZED
```

At this point: **All source data imported to staging database (macos_import.db)**.

### Phase 2: Match Handles to Contacts

**In macos_import.db, create matching table:**

```sql
CREATE TABLE contact_to_chat_handle (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  contact_id INTEGER NOT NULL,      -- FK to contact (AddressBook Z_PK)
  chat_handle_id INTEGER NOT NULL,  -- FK to handles (chat.db ROWID)
  match_type TEXT NOT NULL,         -- 'phone' or 'email'

  FOREIGN KEY (contact_id) REFERENCES contact(id),
  FOREIGN KEY (chat_handle_id) REFERENCES handles(id),

  UNIQUE(contact_id, chat_handle_id)
);
```

**Matching algorithm:**

```
For each handle in handles table:
  1. Extract phone/email from handle.handle_id

  2a. If phone: Query contact_phones WHERE full_number matches
  2b. If email: Query contact_emails WHERE address_normalized matches

  3. If MATCH found:
     INSERT INTO contact_to_chat_handle (contact_id, chat_handle_id, match_type)

  4. If NO MATCH:
     - Handle remains unmatched (bank, unknown sender, etc.)
     - No contact_to_chat_handle entry created (correct!)
```

### Phase 3: Project to working.db

**From macos_import.db → working.db:**

**Step 3.1: Create canonical handles**

The `handles_migrator` groups all import.db handles by normalized identifier (stripping schemes, normalizing phone/email):

```dart
// Group by normalized identifier (NOT by compound identifier or service)
final key = parsed.canonicalNormalized;  // e.g., "7789908506"
```

For each group:
- Select one canonical handle (lowest ID, best formatting)
- Insert ONLY the canonical handle into `working.handles`
- Record ALL handles (canonical + aliases) in `working.handle_canonical_map`

Result: 
- `working.handles` contains 194 canonical handles (from 232 source handles)
- `working.handle_canonical_map` contains 232 entries mapping source→canonical

**Step 3.2: Project chats with canonical handle references**

The `chat_to_handle_migrator` rewrites chat memberships to use canonical handles:

```sql
INSERT INTO chat_to_handle (chat_id, handle_id, ...)
SELECT 
  cth.chat_id,
  map.canonical_handle_id,  -- Resolves source → canonical
  ...
FROM import.chat_to_handle cth
JOIN handle_canonical_map map ON map.source_handle_id = cth.handle_id
```

This ensures all chats reference canonical handles, regardless of which service variant was used in the original chat.db.

**Step 3.3: Create participants from matched contacts**

```sql
INSERT INTO working.participants (id, original_name, display_name, short_name, avatar_ref)
SELECT
  c.id,  -- Preserve AddressBook Z_PK!
  COALESCE(
    TRIM(c.first_name || ' ' || COALESCE(c.middle_name, '') || ' ' || c.last_name),
    COALESCE(c.first_name, '') || ' ' || c.organization
  ) AS original_name,
  COALESCE(c.nickname, c.first_name, c.organization) AS display_name,
  COALESCE(c.nickname, c.first_name, c.organization) AS short_name,
  NULL AS avatar_ref
FROM macos_import.contact c
WHERE EXISTS (
  SELECT 1 FROM macos_import.contact_to_chat_handle cch
  WHERE cch.contact_id = c.id
);
```

**Step 3.4: Create handle_to_participant links**

The `handle_to_participant_migrator` maps CANONICAL handles to participants:

```sql
INSERT INTO working.handle_to_participant (handle_id, participant_id, confidence, source)
SELECT
  map.canonical_handle_id,  -- Uses canonical, not source
  c.Z_PK,
  1.0,
  'addressbook'
FROM macos_import.contact_to_chat_handle cch
JOIN handle_canonical_map map ON map.source_handle_id = cch.chat_handle_id
JOIN macos_import.contacts c ON c.Z_PK = cch.contact_id
```

**Critical**: Links are created to CANONICAL handles only. Since Claire's phone has canonical handle 5, the link is: `(handle_id=5, participant_id=17)`. All chats using handles 5, 60, or 265 will resolve to this single link.

### Phase 4: Filter Spam/Junk (Optional)

```
For each handle in working.handles WHERE NOT EXISTS (
  SELECT 1 FROM handle_to_participant WHERE handle_id = handles.id
):
  1. Validate format: Is it a well-formed phone number or email?

  2. If INVALID (e.g., "0134", "59874", "claiee"):
     a. UPDATE handles SET is_blacklisted = 1
     b. Option: Mark associated chats as hidden
     c. Option: DELETE chats and messages (cascade)
     - Never show these handles in UI
```

### Phase 5: User Customization (Optional)

```
Allow user to:
1. Edit display_name/short_name for participants
2. Manually link handles to participants (if AddressBook matching failed)
3. Manually blacklist handles (mark as spam)
4. Manually create participants (for contacts not in AddressBook)
```

## What This Architecture Enables

### ✅ Benefits

1. **No duplicate people**: "Claire" appears once in participants table
2. **Multiple handles per person**: One participant links to phone + email + ...
3. **Handles without people**: Bank's "5551234" exists in handles but not participants
4. **Service belongs to chat**: Chats have services, people don't
5. **Clean spam filtering**: Invalid handles ("0134") blacklisted, never become participants
6. **Referential integrity**: chat.db data structure preserved completely

### ✅ User Features

1. **Chat labeling**: Display "Cousin Danny" instead of "5149875432"
2. **Contact-based filtering**: "Show all chats with Danny" (across all his handles)
3. **Spam management**: View/unblock blacklisted handles
4. **Manual linking**: User can connect handles to contacts if matching failed
5. **No ChatToParticipant table**: UI joins through handles directly (chats.handle_id → handle_to_participant → participants)

### ✅ Data Quality

- No "claiee" entries in participants (only in handles, can be blacklisted)
- No "59874" spam in participants (blacklisted in handles)
- AddressBook-sourced participants have high data quality

## Migration Strategy

### Schema Changes Required

1. **participants table**: Remove `service`/`normalized_address`/`contact_ref`/`is_system`, add `original_name`/`display_name`/`short_name`, change `id` to preserve AddressBook Z_PK (no auto-increment)
2. **handles table**: NEW table replacing handle data scattered across tables
3. **handle_to_participant**: Renamed from `participant_handle_links`, enhanced with confidence/source, follows SQL naming standard
4. **chats table**: Add `handle_id` FK, change `last_sender_participant_id` to `last_sender_handle_id`
5. **messages table**: Change FK from `sender_participant_id` to `sender_handle_id`
6. **reactions table**: Change FK from `reactor_participant_id` to `reactor_handle_id`
7. **chat_to_participant table**: **DELETED** - UI now joins through handles (chats.handle_id → handle_to_participant)

### Code Changes Required

1. **Import service**: Complete rewrite following Phase 1-5 process above, using macos_import.db staging database
2. **Queries**: Update to join through `handle_to_participant` when resolving handles → people
3. **UI displays**: Update to resolve handle → participant → display_name, remove ChatToParticipant joins
4. **Settings panel**: Show participants (not handle×service combinations), no more contactRef/isSystem/normalizedAddress

### Data Migration (working.db)

```sql
-- Migration v4 → v5: _migrateToHandlesArchitecture()

-- 1. Create new handles table from existing chat.db data
--    (Preserves chat.db handle.ROWID as handles.id)

-- 2. Create cleaned participants table (one per contact, uses AddressBook Z_PK as id)
--    (Deduplicates by display_name: 6 Claires → 1 Claire)

-- 3. Rebuild handle_to_participant from old WorkingParticipants
--    (Maps each handle to its deduplicated participant)

-- 4. Update chats/messages/reactions FKs to point to handles
--    (chats.handle_id, messages.sender_handle_id, reactions.reactor_handle_id)

-- 5. Drop old WorkingParticipants columns (service, normalized_address, contact_ref, is_system)

-- 6. Delete ChatToParticipant table entirely (UI does joins differently)
```

**Note**: Future imports will use the Phase 1-5 process with macos_import.db staging.

## Design Principles Validated

### ✅ Single Source of Truth

- **chat.db**: Authoritative for chats, messages, handles, services
- **AddressBook.db**: Authoritative for contact names, identities
- **working.db**: Projection combining both, with user customizations

### ✅ Referential Integrity

- Every message → chat → handle (guaranteed by chat.db structure)
- Every participant → contact_ref (guaranteed by UNIQUE constraint)
- Participant-handle links are additive (presence or absence doesn't break structure)

### ✅ Data Quality

- Participants sourced from AddressBook (high quality)
- Junk handles filtered by validation (before becoming participants)
- User can override/customize (short_name, manual links)

### ✅ Separation of Concerns

- **Handles**: Communication endpoints (technical identifiers)
- **Participants**: People/contacts (human identities)
- **Links**: The mapping between them (with confidence scores)

## The Manifesto Summary

> **A participant is a person, not a phone number.**  
> **Service is a property of chats, not people.**  
> **Handles are communication endpoints, independent of whether we know the person.**  
> **Links between handles and participants are discovered, not assumed.**

This architecture respects the reality that:

- People have multiple contact methods
- Not all handles belong to known contacts
- Spam should be filtered at the handle level
- Users should see "people" in their UI, not "phone-number-service-combinations"

---

## Next Steps

This document becomes the specification for:

1. **Schema redesign** (participants, handles, participant_handle_links)
2. **Import service rewrite** (Phases 1-4 above)
3. **Query updates** (join through links table)
4. **UI updates** (display participants, not handle combinations)
5. **Migration script** (transform existing working.db)

**Estimated scope**: Major refactoring touching import, schema, queries, UI  
**Estimated benefit**: Eliminates duplicate participants, enables proper contact-based features, fixes data quality issues

ᕕ( ᐛ )ᕗ
