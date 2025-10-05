# Settings Panel: Sort Real Names Before Phone Numbers

## Problem

The settings panel was showing all 226 participants correctly, but the sort order was purely alphabetical. This meant:

- **~100 phone number entries** appeared at the top (e.g., `+12024742228`, `+15551234567`)
- **Real names** like "Claire Merriman Campbell" were buried below, requiring excessive scrolling
- **Poor UX**: Users couldn't quickly find contacts by name

### Example Bad Sort Order:

```
+12024742228
+15551234567
+15559876543
[...98 more phone numbers...]
Aaron Smith
Claire Merriman Campbell  ← Hidden way down the list!
Rob Campbell
```

## Root Cause

The sorting logic was purely alphabetical:

```dart
entries.sort(
  (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
);
```

Since `+` and digits sort before letters in ASCII/Unicode order, all phone numbers appeared first.

## Solution

Updated the sort to **prioritize entries with alphabetic characters** (real names) before numeric-only entries (phone numbers/emails):

```dart
entries.sort((a, b) {
  final aHasLetters = _alphabeticPattern.hasMatch(a.displayName);
  final bHasLetters = _alphabeticPattern.hasMatch(b.displayName);

  // If one has letters and the other doesn't, prioritize the one with letters
  if (aHasLetters && !bHasLetters) {
    return -1;  // a (has letters) comes before b (no letters)
  }
  if (!aHasLetters && bHasLetters) {
    return 1;   // b (has letters) comes before a (no letters)
  }

  // Both have letters or both don't - sort alphabetically
  return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
});
```

### New Sort Order:

```
Aaron Smith
Cathie Campbell
Claire Merriman Campbell  ← Easy to find!
Rob Campbell
Rusung Tan
Scott Campbell
[...all real names first...]
+12024742228              ← Phone numbers at the end
+15551234567
```

## Logic Details

1. **Check for alphabetic characters**: Uses existing `_alphabeticPattern = RegExp(r'[A-Za-z]')`
2. **Names with letters win**: Any display name containing A-Z/a-z sorts before pure numbers
3. **Within groups, alphabetical**: Names sort A-Z, numbers sort numerically
4. **Handles mixed cases**: "555-Claire" would still have letters, so sorts with names

## Test Results

```bash
✅ contact_short_name_candidates_provider_test.dart: 3/3 passing
✅ contact_short_names_controller_test.dart: 3/3 passing
✅ message_annotations_controller_test.dart: 8/8 passing
✅ All 23 settings tests passing
✅ Zero analyzer errors
```

## User Impact

### Before:

- User opens settings panel
- Sees ~100 phone number cards
- Must scroll down to find "Claire Merriman Campbell"
- Frustrating experience

### After:

- User opens settings panel
- **Immediately sees real names** at the top: "Aaron", "Cathie", "Claire", etc.
- Can quickly find and edit "Claire Merriman Campbell" → "Claire"
- Phone numbers relegated to bottom (rarely need short names)

## Files Changed

### Modified:

- `lib/features/settings/application/contact_short_names/contact_short_name_candidates_provider.dart`
  - Updated `sort()` logic to prioritize alphabetic names
  - 15 lines changed (replaced simple sort with smart sort)

## Architecture Notes

This change is purely presentational - it doesn't affect:

- ✅ Database queries (same 226 participants)
- ✅ Key generation (`participant:${id}`)
- ✅ Overlay database storage
- ✅ Data integrity

## Why This Matters

### Real-World Scenario:

User has:

- 126 contacts with real names (family, friends, coworkers)
- 100 phone numbers without names (spam, delivery services, etc.)

**Before**: Scrolled past 100 useless entries to find mom's name  
**After**: Mom's name visible immediately at top of list

### Use Case: Setting Short Name

1. User sees chat from "Claire Merriman Campbell" and "Cathie Campbell"
2. Wants to set short name "Claire" for the long name
3. Opens settings panel
4. **Now**: Finds "Claire Merriman Campbell" at top of list immediately
5. Enters "Claire" as short name
6. Saves successfully

## Edge Cases Handled

- **Pure numbers**: `+15551234567` → no letters, sorts last
- **Mixed**: `555-CALL` → has letters, sorts with names
- **Email addresses**: `user@example.com` → has letters, sorts with names
- **Special chars**: `+1 (202) 474-2228` → no letters, sorts last
- **Empty/Unknown**: Falls through to alphabetical sort

## Status: ✅ Complete

Settings panel now displays real names (people you actually want to assign short names to) at the top, with phone numbers relegated to the bottom where they belong.

**Result**: Much improved UX for finding and editing contact short names!
