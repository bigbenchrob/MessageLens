# Stray Handles Management — Checklist

> **Branch:** `Ftr.strays`  
> **Status:** 🔵 In Progress

---

## Phase 1: Data Layer — Dismissal Persistence

### Overlay Schema
- [ ] Add `is_dismissed BOOLEAN DEFAULT 0` to `handle_to_participant_overrides`
- [ ] Add `dismissed_at TEXT` to `handle_to_participant_overrides`
- [ ] Add migration for schema changes
- [ ] Test: dismissal flag persists after overlay DB close/reopen

### Handle Normalization
- [ ] Implement `normalizeHandleIdentifier(String raw)` utility
  - Phone: strip formatting → E.164 or raw digits
  - Email: lowercase
- [ ] Ensure dismissal keyed by normalized identifier (survives re-import)
- [ ] Test: same phone in different formats maps to same dismissal state

### Dismissal Queries
- [ ] `setHandleDismissed(int handleId)` — sets `is_dismissed=true`, `dismissed_at=now`
- [ ] `restoreHandle(int handleId)` — sets `is_dismissed=false`, clears `dismissed_at`
- [ ] `getDismissedHandles()` — returns all dismissed handle IDs

---

## Phase 2: Provider Layer — Exclusion Logic

### Stray Handles Provider Updates
- [ ] Update `strayHandlesProvider` to exclude `is_dismissed=true` handles
- [ ] Create `spamCandidateHandlesProvider` — applies heuristic scoring
- [ ] Create `dismissedHandlesProvider` — returns only dismissed handles
- [ ] Test: dismissed handle removed from strayHandlesProvider results

### Heuristic Scoring
- [ ] Implement `calculateJunkScore(StrayHandleSummary handle, List<Message> messages)`:
  - Short code detection (+3)
  - Message count scoring (+1 to +2)
  - Temporal clustering (+1)
  - Outbound message check (+1)
  - Keyword scanning (+2)
  - URL detection (+1)
- [ ] Filter spam candidates by `junkScore >= 3`
- [ ] Test: known spam patterns score ≥ 3

### Search Exclusion (CRITICAL)
- [ ] Update global message search query to exclude dismissed handles
- [ ] Update All Messages query to exclude dismissed handles
- [ ] Test: search for text in dismissed message returns zero results

### Analytics Exclusion
- [ ] Update contact message count queries to exclude dismissed
- [ ] Update heatmap data queries to exclude dismissed
- [ ] Update timeline metadata to exclude dismissed
- [ ] Test: dismissed messages not counted in stats

---

## Phase 3: UI — Mode System

### Sidebar Mode Toggle
- [ ] Add mode state: `StrayHandleMode { allStrays, spamOneOff, dismissed }`
- [ ] Add segmented control to stray handles sidebar header
- [ ] Wire mode to appropriate provider:
  - `allStrays` → `strayHandlesProvider`
  - `spamOneOff` → `spamCandidateHandlesProvider`
  - `dismissed` → `dismissedHandlesProvider`
- [ ] Test: mode toggle switches displayed list

### Sidebar Row Updates
- [ ] Add optional badges (Short code, 2FA, Promo)
- [ ] Spam mode: always-visible Dismiss button on row
- [ ] All Strays mode: neutral styling, no row-level dismiss button
- [ ] Dismissed mode: "Restore" button on row
- [ ] Test: correct button visibility per mode

### Auto-Advance on Dismiss
- [ ] Track current selection index in sidebar state
- [ ] On dismiss: remove handle, select next item (or previous if at end)
- [ ] Test: dismiss advances selection without mouse travel

---

## Phase 4: UI — Label Handle Flow

### Label Action
- [ ] Add "Label handle…" button to Handle Lens action bar
- [ ] Create `LabelHandleDialog` with:
  - Text field for freeform label
  - Placeholder examples: "?Paul's brother", "?Old landlord"
  - Cancel / Confirm buttons
- [ ] Test: dialog appears and captures input

### Virtual Contact Creation
- [ ] On confirm: create/reuse virtual participant with label as `display_name`
- [ ] Link handle to virtual participant via overlay
- [ ] If handle was dismissed: implicitly restore it
- [ ] Invalidate `strayHandlesProvider`
- [ ] Test: labeled handle no longer appears in stray list

### Label Edit
- [ ] Add "Edit label" option for handles already linked to virtual participants
- [ ] Update virtual participant `display_name`
- [ ] Test: label change reflected in UI

---

## Phase 5: UI — Handle Lens Polish

### Message Ordering (DONE ✅)
- [x] Fix chronological sort (DateTime comparison, not string)
- [x] Add sort toggle button (oldest-first default)
- [x] Tooltip shows current sort mode

### Context Menu
- [ ] Add context menu to Handle Lens header:
  - Label handle…
  - Link to existing contact…
  - Dismiss
- [ ] Same actions available via buttons

### InfoCard
- [ ] Add InfoCard in Spam mode explaining exclusion semantics
- [ ] Add InfoCard in Dismissed mode explaining recovery options
- [ ] InfoCard can be dismissed (persisted in user prefs)

---

## Phase 6: Keyboard Shortcuts (Spam Mode)

- [ ] Up/Down arrow: move selection
- [ ] Enter: dismiss selected handle
- [ ] (Optional) Space: preview without changing selection
- [ ] Test: keyboard-only blitz workflow possible

---

## Phase 7: Settings Integration

- [ ] Add Settings → Advanced → "Show dismissed handles in sidebar"
- [ ] When enabled: adds "Dismissed" option to mode toggle
- [ ] Test: setting toggles mode availability

---

## Verification

### Manual Tests
- [ ] Complete blitz-dismiss of 20+ handles in Spam mode
- [ ] Verify dismissed content excluded from search
- [ ] Verify dismissed content excluded from All Messages
- [ ] Label a handle and verify it enters normal circulation
- [ ] App restart: dismissal state persists
- [ ] Re-import workflow: dismissal state persists

### Automated Tests
- [ ] Unit: `calculateJunkScore` returns expected scores
- [ ] Unit: `normalizeHandleIdentifier` handles edge cases
- [ ] Integration: `strayHandlesProvider` excludes dismissed
- [ ] Integration: search query excludes dismissed messages
