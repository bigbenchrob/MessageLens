# Import Database Architecture and Ingestion Strategy

**Status**: Authoritative specification for macos_import.db structure and ingestion process  
**Last Updated**: October 7, 2025

## Overview

The `macos_import.db` serves as a **staging database** that imports raw data from two macOS sources:

1. **chat.db** - iMessage/SMS conversations (handles, chats, messages, attachments)
2. **AddressBook.abcddb** - Contact information (names, phone numbers, emails)

The import database preserves original IDs and data relationships, then projects a cleaned subset into `working.db` for the application to use.

---

## Core Architecture Principles

### 1. Preserve Original IDs

- **chat.db ROWIDs** are preserved in handles, chats, messages tables
- **AddressBook Z_PK values** are preserved in contacts table
- This eliminates ID mapping complexity and enables incremental imports

### 2. Staging, Not Transformation

- macos_import.db stores **raw imported data** with minimal transformation
- Complex business logic (name resolution, spam filtering, display names) happens during **projection** to working.db
- Keep import simple and reproducible

### 3. Relationship Integrity

- All foreign key relationships from source databases are maintained
- New join tables link chat handles to AddressBook contacts
- No data is discarded during import (optional: flagged for later filtering)

---

## Import Database Schema

### Chat.db Tables (Existing)

#### `handles`

Stores communication endpoints from chat.db handle table.

```sql
CREATE TABLE handles (
  id INTEGER PRIMARY KEY,              -- Preserves chat.db handle.ROWID
  source_rowid INTEGER,                -- Redundant copy for clarity
  service TEXT NOT NULL,               -- 'iMessage', 'SMS', etc.
  raw_identifier TEXT NOT NULL,        -- Original handle ID (phone/email)
  normalized_identifier TEXT,          -- Cleaned version for matching
  country TEXT,
  last_seen_utc TEXT,
  is_ignored INTEGER DEFAULT 0,        -- Flag for spam/ignored handles
  batch_id INTEGER NOT NULL REFERENCES import_batches(id),
  UNIQUE(service, raw_identifier)
);
```

#### `chats`

Stores conversation metadata from chat.db chat table.

```sql
CREATE TABLE chats (
  id INTEGER PRIMARY KEY,              -- Preserves chat.db chat.ROWID
  source_rowid INTEGER,
  guid TEXT NOT NULL UNIQUE,
  service TEXT,
  display_name TEXT,
  is_group INTEGER DEFAULT 0,
  created_at_utc TEXT,
  updated_at_utc TEXT,
  is_ignored INTEGER DEFAULT 0,
  batch_id INTEGER NOT NULL REFERENCES import_batches(id)
);
```

#### `chat_to_handle`

Links chats to their participant handles (from chat.db chat_handle_join).

```sql
CREATE TABLE chat_to_handle (
  chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  handle_id INTEGER NOT NULL REFERENCES handles(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member',          -- 'member', 'owner', 'unknown'
  added_at_utc TEXT,
  PRIMARY KEY (chat_id, handle_id)
);
```

#### `messages`

Stores message content and metadata from chat.db message table.

```sql
CREATE TABLE messages (
  id INTEGER PRIMARY KEY,              -- Preserves chat.db message.ROWID
  source_rowid INTEGER,
  guid TEXT NOT NULL UNIQUE,
  chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender_handle_id INTEGER REFERENCES handles(id) ON DELETE SET NULL,
  service TEXT,
  is_from_me INTEGER NOT NULL,
  date_utc TEXT,
  date_read_utc TEXT,
  date_delivered_utc TEXT,
  subject TEXT,
  text TEXT,                           -- Plain text content
  attributed_body_blob BLOB,           -- Binary attributed string
  item_type TEXT,                      -- 'text', 'reaction-carrier', etc.
  error_code INTEGER,
  is_system_message INTEGER DEFAULT 0,
  thread_originator_guid TEXT,
  associated_message_guid TEXT,        -- For reactions/replies
  balloon_bundle_id TEXT,
  payload_json TEXT,
  is_ignored INTEGER DEFAULT 0,
  batch_id INTEGER NOT NULL REFERENCES import_batches(id)
);
```

_(Additional chat.db tables: attachments, message_attachments, reactions, message_links)_

---

### AddressBook Tables (New - Core Data)

These tables import **raw AddressBook data** preserving original structure. The Z_PK naming convention explicitly indicates fields sourced from AddressBook's Core Data schema.

**Design Principle**: Import raw data with only the minimal transformations required for direct projection. We precompute a stable `display_name`, but leave other derived fields (like `short_name`) to later projection/UI stages.

#### `contacts`

Stores contact records from AddressBook ZABCDRECORD table with the additional projection fields needed for direct migration into `working.db.participants`.

```sql
CREATE TABLE contacts (
  id INTEGER PRIMARY KEY,              -- Internal SQLite rowid (autoincrement)
  Z_PK INTEGER NOT NULL UNIQUE,        -- AddressBook ZABCDRECORD.Z_PK (preserved)
  first_name TEXT,                     -- From ZFIRSTNAME (raw)
  last_name TEXT,                      -- From ZLASTNAME (raw)
  organization TEXT,                   -- From ZORGANIZATION (raw)
  display_name TEXT NOT NULL,          -- Precomputed display name used by working.db
  short_name TEXT,                     -- Optional UI-friendly name (set later by user)
  created_at_utc TEXT,                 -- Import timestamp
  is_ignored INTEGER DEFAULT 0,        -- Flag contacts excluded from projection
  batch_id INTEGER NOT NULL REFERENCES import_batches(id)
);
```

**Key Points**:

- **Z_PK**: All AddressBook-sourced IDs use Z_PK naming to clearly indicate their origin
- **Display name precomputation**: We assemble a stable display string during import so the row can migrate directly into `working.db.participants`
- **`short_name` column**: Created now so the UI can persist user overrides without schema changes later (remains NULL by default)
- **Ignore flag**: `is_ignored = 1` marks unmatched contacts so projection can skip them while still preserving provenance
- **Always reference by Z_PK**: When joining, use Z_PK not the autoincrement id

**Import Logic**:

```sql
-- Pseudocode for importing ZABCDRECORD
INSERT INTO contacts (
  Z_PK,
  first_name,
  last_name,
  organization,
  display_name,
  short_name,
  created_at_utc,
  batch_id
)
SELECT
  Z_PK,
  ZFIRSTNAME,
  ZLASTNAME,
  ZORGANIZATION,
  COALESCE(
    TRIM(
      COALESCE(ZFIRSTNAME, '') ||
      CASE WHEN ZFIRSTNAME IS NOT NULL AND ZLASTNAME IS NOT NULL THEN ' ' ELSE '' END ||
      COALESCE(ZLASTNAME, '')
    ),
    ZORGANIZATION,
    'Unknown Contact'
  ) AS display_name,
  NULL AS short_name,
  datetime('now'),
  ?batch_id
FROM AddressBook.ZABCDRECORD
WHERE Z_ENT = 1;  -- Contact entity type
```

#### `contact_phone_email`

Unified table for phone numbers and email addresses (replaces separate tables).

```sql
CREATE TABLE contact_phone_email (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ZOWNER INTEGER NOT NULL REFERENCES contacts(Z_PK) ON DELETE CASCADE,
  kind TEXT NOT NULL CHECK(kind IN ('email', 'phone')),
  value TEXT NOT NULL,                 -- Phone number or email address
  label TEXT,                          -- 'home', 'work', 'mobile', etc.
  UNIQUE(kind, value)
);
```

**Note**: ZOWNER references the AddressBook source field, linking to `contacts(Z_PK)`.

**Import Logic**:

```sql
-- Import phone numbers from ZABCDPHONENUMBER
INSERT INTO contact_phone_email (ZOWNER, kind, value)
SELECT ZOWNER, 'phone', ZFULLNUMBER
FROM AddressBook.ZABCDPHONENUMBER
WHERE ZFULLNUMBER IS NOT NULL AND ZFULLNUMBER != '';

-- Import emails from ZABCDEMAILADDRESS
INSERT INTO contact_phone_email (ZOWNER, kind, value)
SELECT ZOWNER, 'email', ZADDRESSNORMALIZED
FROM AddressBook.ZABCDEMAILADDRESS
WHERE ZADDRESSNORMALIZED IS NOT NULL AND ZADDRESSNORMALIZED != '';
```

---

### Contact-to-Handle Linking Table (New - Critical)

#### `contact_to_chat_handle`

Links AddressBook contacts to chat.db handles based on phone/email matching.

#### `contact_to_chat_handle`

Links AddressBook contacts to chat.db handles (the **critical join table**).

```sql
CREATE TABLE contact_to_chat_handle (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  contact_Z_PK INTEGER NOT NULL REFERENCES contacts(Z_PK) ON DELETE CASCADE,
  chat_handle_id INTEGER NOT NULL REFERENCES handles(id) ON DELETE CASCADE,
  batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT,
  UNIQUE(contact_Z_PK, chat_handle_id)
);
```

**Purpose**: This table is the **bridge** between AddressBook contacts and chat handles, enabling participant name resolution.

**Key Design Points**:

- **contact_Z_PK**: References AddressBook source ID, not autoincrement id
- **chat_handle_id**: References chat.db handle ROWID (preserved in handles.id)
- **batch_id**: Required for direct migration to working.db with no recomputation
- **Immutable relationships**: Z_PK never changes, handle IDs preserved, ignore flags prevent deletion
- **One-time matching**: Links computed once during import Phase 3, then migrated as-is

**Direct Migration Capability**: Since Z_PK and handle ROWIDs are stable and spam filtering uses ignore flags (not deletion), this entire table can be copied directly to working.db with zero transformation.

---

## Ingestion Process (Step-by-Step)

### Phase 1: Import Chat.db Data

**Objective**: Import handles, chats, messages with relationships intact.

```
1. Import handles from chat.db → handles table (preserve ROWIDs)
2. Import chats from chat.db → chats table (preserve ROWIDs)
3. Import chat_handle_join → chat_to_handle table
4. Import messages from chat.db → messages table (preserve ROWIDs)
5. Import attachments, reactions, etc.
```

**Key Points**:

- All chat.db ROWIDs are preserved as `id` in import tables
- Foreign keys (chat_id, sender_handle_id) remain valid
- No transformation beyond basic type conversion and NULL handling

---

### Phase 2: Import AddressBook Data

**Objective**: Import all contacts and their communication endpoints.

```
1. Import ZABCDRECORD → contacts table
   - Preserve Z_PK as id
  - Assemble `display_name` during import; leave `short_name` NULL for later user overrides

2. Import ZABCDPHONENUMBER → contact_phone_email table
   - Link to contact via ZOWNER
   - Set kind = 'phone'

3. Import ZABCDEMAILADDRESS → contact_phone_email table
   - Link to contact via ZOWNER
   - Set kind = 'email'
```

**Key Points**:

- ALL contacts are imported (not just matched ones)
- Original AddressBook Z_PK values are preserved
- Phone numbers and emails stored in unified table
- `is_ignored` defaults to 0 and flips to 1 only after matching determines there are no linked handles

---

### Phase 3: Link Contacts to Handles

**Objective**: Match AddressBook contacts to chat handles and populate `contact_to_chat_handle`.

#### Algorithm

```sql
-- Match phone numbers
INSERT INTO contact_to_chat_handle (contact_Z_PK, chat_handle_id, batch_id)
SELECT
  cpe.ZOWNER,
  h.id,
  ?batch_id
FROM contact_phone_email cpe
JOIN handles h ON (
  -- Normalize both sides for matching
  -- Remove spaces, dashes, parentheses, country codes
  normalize_phone(cpe.value) = normalize_phone(h.raw_identifier)
  OR normalize_phone(cpe.value) = normalize_phone(h.normalized_identifier)
)
WHERE cpe.kind = 'phone'
AND h.service IN ('SMS', 'iMessage')
ON CONFLICT DO NOTHING;

-- Match email addresses
INSERT INTO contact_to_chat_handle (contact_Z_PK, chat_handle_id, batch_id)
SELECT
  cpe.ZOWNER,
  h.id,
  ?batch_id
FROM contact_phone_email cpe
JOIN handles h ON (
  LOWER(TRIM(cpe.value)) = LOWER(TRIM(h.raw_identifier))
  OR LOWER(TRIM(cpe.value)) = LOWER(TRIM(h.normalized_identifier))
)
WHERE cpe.kind = 'email'
ON CONFLICT DO NOTHING;
```

#### Ignore Flag Maintenance

- After the phone and email matching statements run, update every contact in the active batch whose `Z_PK` is missing from `contact_to_chat_handle` to set `is_ignored = 1`.
- The same pass should reset `is_ignored = 0` for any contacts that gained a match, ensuring subsequent incremental imports revive newly linked people.
- This keeps the ledger immutable (rows are never deleted) while giving projection a precise signal to exclude unmatched contacts by default.

**Key Points**:

- Phone matching requires normalization (remove formatting)
- Email matching is case-insensitive
- Some handles may not match any contact (spam, unknown senders)
- Some contacts may not match any handle (contacts who haven't texted)
- Contacts without matches are explicitly marked `is_ignored = 1` so migration can skip them while still preserving the original import row

---

## Example: Claire Merriman Campbell

Let's trace how Claire's data flows through the system:

### Step 1: AddressBook Import

**ZABCDRECORD (Z_PK = 17)**:

```
Z_PK: 17
ZFIRSTNAME: "Claire"
ZLASTNAME: "Merriman Campbell"
ZNICKNAME: "Claire"
ZORGANIZATION: NULL
```

**Imported to `contacts`**:

```sql
INSERT INTO contacts (
  id,
  Z_PK,
  first_name,
  last_name,
  organization,
  display_name,
  short_name,
  created_at_utc,
  is_ignored,
  batch_id
) VALUES (
  NULL,                        -- id (auto-incremented ledger rowid)
  17,                          -- Z_PK preserved from AddressBook
  'Claire',                    -- first_name
  'Merriman Campbell',         -- last_name
  NULL,                        -- organization
  'Claire Merriman Campbell',  -- display_name assembled during import
  NULL,                        -- short_name left for UI overrides
  '2025-10-01T08:45:00Z',      -- created_at_utc
  0,                           -- is_ignored (updated later if no matches)
  1                            -- batch_id
);
```

**ZABCDPHONENUMBER (ZOWNER = 17)**:

```sql
INSERT INTO contact_phone_email VALUES (
  NULL,                        -- id (auto-increment)
  17,                          -- ZOWNER (links to contacts.Z_PK)
  'phone',                     -- kind
  '+17789908506',              -- value
  'mobile'                     -- label
);
```

**ZABCDEMAILADDRESS (ZOWNER = 17)**:

```sql
INSERT INTO contact_phone_email VALUES (
  NULL,                        -- id (auto-increment)
  17,                          -- ZOWNER (links to contacts.Z_PK)
  'email',                     -- kind
  'clairemc@gmail.com',        -- value
  'home'                       -- label
);
```

### Step 2: Handle Matching

**Existing handle in chat.db** (ROWID = 42):

```
ROWID: 42
id: +17789908506
service: iMessage
```

**Imported to `handles`**:

```sql
INSERT INTO handles VALUES (
  42,                          -- id (preserved ROWID)
  42,                          -- source_rowid
  'iMessage',                  -- service
  '+17789908506',              -- raw_identifier
  '+17789908506',              -- normalized_identifier
  'CA',                        -- country
  '2025-10-06T12:00:00Z',      -- last_seen_utc
  0,                           -- is_ignored
  1                            -- batch_id
);
```

**Matching Process**:

````sql
-- Phone normalization matches:
normalize_phone('+17789908506') = '17789908506'
normalize_phone('+17789908506') = '17789908506'
-- Match found!

```sql
INSERT INTO contact_to_chat_handle VALUES (
  NULL,                        -- id (auto-increment)
  17,                          -- contact_Z_PK (Claire's Z_PK)
  42,                          -- chat_handle_id (handle ROWID)
  1                            -- batch_id
);
````

### Step 3: Query for Chat Participant Names

Now when displaying chats involving handle 42:

```sql
SELECT
  c.display_name,
  c.first_name,
  h.raw_identifier
FROM handles h
LEFT JOIN contact_to_chat_handle cch ON cch.chat_handle_id = h.id
LEFT JOIN contacts c ON c.Z_PK = cch.contact_Z_PK
WHERE h.id = 42;

-- Result:
-- display_name: "Claire Merriman Campbell"
-- first_name: "Claire"
-- raw_identifier: "+17789908506"
```

Application uses: `display_name` (or `first_name` for short display) instead of phone number.

---

## Projection to working.db

Once macos_import.db is populated, data is **projected** to working.db:

### What Gets Projected

1. **Participants** (from `contacts`):

- Only contacts that have at least one link in `contact_to_chat_handle`
- Preserve `contacts.Z_PK` as the participant primary key for direct provenance
- Copy `display_name`, `first_name`, `last_name`, `organization`, and `short_name` verbatim
- Skip rows flagged with `is_ignored = 1` so unmatched AddressBook entries never surface in the UI

2. **Handles** (from `handles`):

   - All handles (matched and unmatched)
   - Preserves original handle.id (chat.db ROWID)

3. **handle_to_participant** (from `contact_to_chat_handle`):

   - Links handles to participants
   - Uses preserved IDs from both tables

4. **Chats, Messages, etc.**:
   - All chat.db data projected as-is
   - Relationships remain intact via preserved IDs

### Projection is Idempotent

- Can be re-run without data loss
- Only updates changed records
- Preserves user customizations in working.db (short names, etc.)

---

## Critical Design Decisions

### 1. Why Separate Import and Working Databases?

**Import DB** (macos_import.db):

- **Immutable staging area** for raw source data
- Can be deleted and rebuilt from chat.db/AddressBook
- No user modifications
- Enables auditing and debugging

**Working DB** (working.db):

- **Application database** with user customizations
- Contains short names, favorites, UI state
- Optimized queries and indexes
- Never directly modified by import process

### 2. Why Preserve Original IDs?

- **Simplifies incremental imports**: New messages can be added without re-mapping IDs
- **Enables data provenance**: Track records back to source databases
- **Reduces complexity**: No ID mapping tables needed
- **Supports partial imports**: Import specific date ranges or contacts

### 3. Why contact_to_chat_handle in Import DB?

- **Reproducible matching**: Can re-run matching logic without affecting working.db
- **Batch operations**: Import all contacts, then match in one pass
- **Confidence scoring**: Can store match quality for fuzzy matching later
- **Debugging**: Inspect which contacts matched which handles

---

## Import Service Responsibilities

The `NewLedgerToWorkingMigrationService` should:

1. ✅ **Import chat.db data** to macos_import.db (handles, chats, messages)
2. ✅ **Import AddressBook data** to macos_import.db (contacts, phone/email)
3. ✅ **Run matching algorithm** to populate contact_to_chat_handle
4. ✅ **Project data** to working.db:
   - Participants (from contacts with links)
   - Handles (all)
   - handle_to_participant (from contact_to_chat_handle)
   - Chats, messages (all)
5. ❌ **NOT responsible for**:
   - Name formatting for display (UI layer)
   - Spam filtering logic (projection phase)
   - User preferences (working.db only)

---

## Current vs. Target State

### Current Issues

1. ❌ **No `contact_to_chat_handle` table** - cannot link contacts to handles
2. ❌ **No `contact_phone_email` table** - phone/email data not imported
3. ❌ **Only 5 participants in working.db** - matching not working
4. ❌ **Complex name resolution in migration** - should be in UI layer

### Target State

1. ✅ **All 109 contacts imported** to macos_import.db contacts table
2. ✅ **All phone/email data imported** to contact_phone_email table
3. ✅ **Matching populates** contact_to_chat_handle with ~80+ links
4. ✅ **Projection creates** 80+ participants in working.db
5. ✅ **UI queries** use handle_to_participant to resolve names

---

## Implementation Checklist

### Phase 1: Update Import DB Schema

- [ ] Add `contact_phone_email` table to sqflite_import_database.dart
- [ ] Add `contact_to_chat_handle` table to sqflite_import_database.dart
- [ ] Update schema version and migration
- [ ] Extend `contacts` table to persist `display_name`, `short_name`, and `is_ignored`

### Phase 2: Implement AddressBook Import

- [ ] Create method to import ZABCDRECORD → contacts
  - Populate `display_name`, keep `short_name` NULL, default `is_ignored` to 0
- [ ] Create method to import ZABCDPHONENUMBER → contact_phone_email
- [ ] Create method to import ZABCDEMAILADDRESS → contact_phone_email
- [ ] Test: Verify 109 contacts imported

### Phase 3: Implement Handle Matching

- [ ] Create phone normalization function
- [ ] Create email normalization function
- [ ] Implement matching algorithm (SQL or Dart)
- [ ] Populate contact_to_chat_handle table
- [ ] Update `is_ignored` flags: mark unmatched contacts and revive newly matched ones
- [ ] Test: Verify 80+ matches created

### Phase 4: Update Projection Logic

- [ ] Remove complex name resolution from migration service
- [ ] Project contacts with links → working.participants
  - Copy `display_name`, `first_name`, `last_name`, `organization`, `short_name`, and `is_ignored`
- [ ] Project contact_to_chat_handle → working.handle_to_participant
- [ ] Test: Verify 80+ participants in working.db

### Phase 5: Update UI Queries

- [ ] Update recent_chats_provider to use handle_to_participant
- [ ] Update message display to use participants
- [ ] Test: Verify names display correctly

---

## Conclusion

This architecture provides a **clean separation** between:

- **Import** (macos_import.db) - Raw data staging with matching
- **Projection** (working.db) - Application database with optimizations
- **Display** (UI layer) - Name formatting and presentation

By preserving original IDs and maintaining explicit join tables, we achieve:

- ✅ **Data integrity** - Source relationships preserved
- ✅ **Reproducibility** - Import can be re-run
- ✅ **Debuggability** - Trace records to source
- ✅ **Scalability** - Incremental imports supported

The key insight: **macos_import.db must contain ALL linking data before projection to working.db begins.**
