# Settings Panel Overlay Database Integration Fix

## Problem

The settings panel was showing contact cards, but the data wasn't properly aligned between:

1. **Contact candidates provider** - Using old `contact:$contactRef` key format
2. **Overlay database** - Using `participant:${participantId}` key format

This mismatch meant short names weren't displaying correctly because the keys didn't match.

## Root Cause

The `contact_short_name_candidates_provider.dart` was generating contact keys using the old logic:

```dart
// OLD CODE (incorrect)
final contactRef = participant.contactRef?.trim();
final key = contactRef != null && contactRef.isNotEmpty
    ? 'contact:$contactRef'
    : 'participant:${participant.id}';
```

This created two different key formats:

- `contact:alpha` for participants with contactRef
- `participant:4` for participants without contactRef

But the overlay database **always** uses `participant:${participantId}` as the key.

## Solution

### Changed Key Generation Logic

Updated `contact_short_name_candidates_provider.dart` to always use participant ID:

```dart
// NEW CODE (correct)
// Always use participant ID as the key (matches overlay database format)
final key = 'participant:${participant.id}';
```

### Updated Tests

Modified `contact_short_name_candidates_provider_test.dart` to reflect the new behavior:

**Before:**

- Expected grouped contacts: `contact:alpha` containing multiple identities
- Mixed key formats: `contact:alpha`, `participant:4`

**After:**

- Each participant gets its own entry: `participant:1`, `participant:2`, `participant:4`
- Consistent key format throughout

### Test Results

```bash
✅ contact_short_name_candidates_provider_test.dart: 3/3 tests passing
✅ contact_short_names_controller_test.dart: 3/3 tests passing
✅ message_annotations_controller_test.dart: 8/8 tests passing
✅ All 23 settings tests passing
✅ Zero analyzer errors
```

## Why This Matters

### Data Consistency

- **Overlay database stores by participant ID** - This is the primary key
- **Contact ref is advisory** - It groups identities in AddressBook but doesn't define storage
- **Each participant is independent** - They can have different short names even if they share a contact

### Correct Behavior Now

1. **Settings panel displays all participants** - One card per participant ID
2. **Short names save correctly** - Keys match between UI and database
3. **Short names display correctly** - Keys match when reading from overlay DB
4. **Tests verify the contract** - Participant ID is the source of truth

## Example Data Flow

### User Sets Short Name

1. User sees card for "Claire Jennings" (participant ID: 123)
2. User enters short name "CJ"
3. Controller saves to overlay DB with key `participant:123`
4. Overlay DB stores: `participant_id=123, short_name="CJ"`

### Settings Panel Displays

1. Candidates provider queries working DB participants
2. For each participant, generates key: `participant:${id}`
3. Controller reads overlay DB short names by participant ID
4. Keys match → short names display correctly in UI

### Messages View Uses Short Names

1. Message has `sender_participant_id=123`
2. Query overlay DB: `getParticipantShortName(123)`
3. Returns "CJ"
4. Display "CJ" instead of "Claire Jennings"

## Files Changed

### Modified

1. `lib/features/settings/application/contact_short_names/contact_short_name_candidates_provider.dart`

   - Removed contactRef-based key logic
   - Always use participant ID for keys
   - Simplified and more consistent

2. `test/features/settings/contact_short_name_candidates_provider_test.dart`
   - Updated test expectations for participant-based keys
   - Changed from 2 grouped entries to 3 individual entries
   - Updated key format assertions

## Architecture Alignment

This fix aligns three layers correctly:

```
┌─────────────────────────────────────────────┐
│  Settings UI                                │
│  - Displays participant cards               │
│  - Key: 'participant:${id}'                 │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│  Contact Candidates Provider                │
│  - Reads working.participants               │
│  - Generates keys: 'participant:${id}'      │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│  Overlay Database                           │
│  - participant_overrides table              │
│  - Primary key: participant_id (integer)    │
│  - Maps to: 'participant:${participant_id}' │
└─────────────────────────────────────────────┘
```

## Next Steps

The settings panel is now correctly integrated with the overlay database. Users can:

1. ✅ View all participants from working database
2. ✅ Assign short names that persist in overlay database
3. ✅ See saved short names load correctly
4. ✅ Clear short names to revert to full names

The short names will now be available throughout the app when displaying participant names in:

- Chat lists
- Message headers
- Contact references
- Search results

## Status: ✅ Complete

Settings panel is now properly connected to the overlay database with consistent key formatting throughout the stack.
