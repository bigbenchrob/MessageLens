# Stray Handles Management — Design Notes

> **Branch:** `Ftr.strays`  
> **Last updated:** 2026-02-22

---

## Core Mental Models

### 1. Handle-Based, Not Conversation-Based

Dismissal operates at the **handle level**. When a user dismisses a handle:
- ALL messages from that handle are excluded
- ALL conversations involving that handle are affected
- There is no way to dismiss individual messages

This is intentional — the feature targets the identity question ("Who is this?"), not conversation curation.

### 2. Dismiss = Total Exclusion

"Dismissed" is not "hidden" or "archived". It means:

```
Dismissed content MUST be excluded from:
├── Global message search
├── All Messages view  
├── Analytics / stats / heatmaps
├── Recents / Favorites
├── Stray handles list (all modes except Dismissed)
└── Any aggregate surface
```

This is a **stronger** semantic than the current `reviewed_at` flag, which only affects visual muting.

### 3. Label-First, Not Contact-First

The user action is: **"Label this handle"**, not "Create contact then assign handle".

```
User thinks: "I'll call this ?Paul's brother for now"
System does: Create virtual participant + link handle (invisible to user)
```

The virtual contact machinery is an implementation detail, not a conceptual step.

---

## Persistence Strategy

### Dismissal Survives Re-Import

Problem: Handle IDs are transient — they change on re-import.

Solution: Store dismissal keyed by **normalized handle value**, not by ID.

```sql
-- Option A: Store normalized value directly
ALTER TABLE handle_to_participant_overrides ADD COLUMN normalized_handle TEXT;
CREATE INDEX idx_hpo_normalized ON handle_to_participant_overrides(normalized_handle);

-- Option B: Lookup table
CREATE TABLE dismissed_handles (
  normalized_handle TEXT PRIMARY KEY,
  dismissed_at TEXT NOT NULL
);
```

**Decision:** Use Option B (separate table). Rationale:
- Cleaner separation of concerns
- No risk of orphaned rows when handles change
- Simpler query for "is this handle dismissed?"

### Normalization Function

```dart
String normalizeHandleIdentifier(String raw) {
  if (raw.contains('@')) {
    // Email: lowercase only
    return raw.toLowerCase().trim();
  }
  // Phone: strip everything except digits and leading +
  final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
  return digits;
}
```

---

## Heuristic Scoring Design

### Conservative Thresholds

The spam detection is **advisory only** — it determines list inclusion, never auto-action.

```dart
class JunkScoreCalculator {
  static int calculate(StrayHandleSummary handle, List<MessageSummary> messages) {
    var score = 0;
    
    // Short code: 3-8 digits with no country code prefix
    if (_isShortCode(handle.handleValue)) score += 3;
    
    // Message count
    if (handle.totalMessages == 1) score += 2;
    else if (handle.totalMessages <= 3) score += 1;
    
    // Temporal clustering
    if (_allMessagesWithin24Hours(messages)) score += 1;
    
    // No outbound
    if (_zeroOutbound(messages)) score += 1;
    
    // Keywords
    if (_hasOtpKeywords(messages)) score += 2;
    if (_hasUnsubscribeKeywords(messages)) score += 2;
    
    // URLs
    if (_hasUrls(messages)) score += 1;
    
    return score;
  }
  
  static bool _isShortCode(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 3 && digits.length <= 8 && !value.startsWith('+');
  }
}
```

### Keyword Lists

```dart
const _otpKeywords = [
  'verification code',
  'security code',
  '2fa',
  'otp',
  'one-time',
  'passcode',
  'confirm your',
  'verify your',
];

const _unsubscribeKeywords = [
  'unsubscribe',
  'reply stop',
  'stop to stop',
  'msg&data rates',
  'opt out',
  'text stop',
];
```

---

## Query Architecture

### Search Exclusion

The search query must join with dismissal state:

```sql
SELECT m.* FROM working_messages m
JOIN handles_canonical h ON m.sender_handle_id = h.id
LEFT JOIN dismissed_handles d ON d.normalized_handle = normalize(h.raw_identifier)
WHERE d.normalized_handle IS NULL  -- Exclude dismissed
  AND m.text_content MATCH ?
```

### Mode-Specific Providers

```dart
// Default: excludes dismissed
@riverpod
Future<List<StrayHandleSummary>> strayHandles(Ref ref) async {
  // Existing logic + filter out dismissed
}

// Spam mode: excludes dismissed, applies heuristics
@riverpod
Future<List<StrayHandleSummary>> spamCandidateHandles(Ref ref) async {
  final all = await ref.watch(strayHandlesProvider.future);
  return all.where((h) => calculateJunkScore(h) >= 3).toList();
}

// Dismissed mode: only dismissed
@riverpod
Future<List<StrayHandleSummary>> dismissedHandles(Ref ref) async {
  // Query dismissed_handles table + join for metadata
}
```

---

## UI State Management

### Mode State

```dart
enum StrayHandleMode {
  allStrays,    // Default
  spamOneOff,   // Heuristic-filtered
  dismissed,    // Escape hatch (requires setting)
}

@riverpod
class StrayHandleModeNotifier extends _$StrayHandleModeNotifier {
  @override
  StrayHandleMode build() => StrayHandleMode.allStrays;
  
  void setMode(StrayHandleMode mode) => state = mode;
}
```

### Auto-Advance Selection

```dart
void dismissAndAdvance(int handleId) {
  final currentIndex = state.selectedIndex;
  final listLength = state.handles.length;
  
  // Perform dismissal
  ref.read(overlayDatabaseProvider).dismissHandle(handleId);
  
  // Calculate next selection
  final nextIndex = currentIndex < listLength - 1 
      ? currentIndex  // Stay at same index (next item slides up)
      : currentIndex - 1;  // At end, select previous
  
  state = state.copyWith(selectedIndex: nextIndex);
}
```

---

## Inviolate Rules

1. **No auto-dismiss** — Heuristics inform, never act
2. **Overlay only** — Dismissal state lives in overlay DB, never working DB
3. **Normalized keys** — Dismissal survives re-import via normalized handle value
4. **Total exclusion** — Dismissed = invisible to all normal surfaces
5. **Label implies restore** — Labeling a dismissed handle automatically restores it

---

## Open Decisions

| Decision | Options | Status |
|----------|---------|--------|
| Dismissal table design | Separate table vs column | **Decided: Separate table** |
| Mode toggle UI | Segmented control vs dropdown | Pending |
| Keyboard shortcuts | Spam mode only vs all modes | Pending |
| InfoCard persistence | Per-session vs permanent dismiss | Pending |
