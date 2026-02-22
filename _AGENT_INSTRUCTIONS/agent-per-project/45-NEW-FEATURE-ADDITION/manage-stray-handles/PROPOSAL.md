# Stray Handles Management — Proposal

> **Branch:** `Ftr.strays`  
> **Status:** Planning  
> **Created:** 2026-02-22

## Problem Statement

The existing stray handles feature (Phase 1-2 from `identify-stray-handles`) provides basic identification and linking. However, users face two pain points:

1. **Spam/junk triage is tedious** — Short codes, 2FA messages, and one-off commercial texts clutter the stray handles list. Users must manually review each one.
2. **Dismiss semantics are weak** — Current "dismiss" only sets `reviewed_at` but still exposes content in search, All Messages, and analytics.

## Goals

1. **Blitz-dismiss workflow** — A "Spam / One-off" mode that surfaces junk-like handles with an always-visible Dismiss button for rapid triage.
2. **Strong dismissal semantics** — Dismissed handles are fully excluded from search, All Messages, analytics, and aggregate surfaces.
3. **Label-first virtual contacts** — Users label a handle directly ("?Paul's brother") without the mental overhead of "create contact → link handle".
4. **Persistent dismissal** — Dismissal survives re-imports, keyed by normalized handle identifier.

## Non-Goals (MUST NOT Implement)

- ❌ Auto-dismiss of any handle (ever)
- ❌ "Search dismissed messages" scope
- ❌ Advanced filters to temporarily include dismissed content
- ❌ Time-based expiry for dismissal
- ❌ Partial dismissal of individual messages (handle-level only)

## Mode System

### Mode A: All Strays (default)
- Shows: All stray handles that are NOT dismissed
- Purpose: Resolve identity or decide to dismiss
- Actions: Label handle… / Link to existing contact / Dismiss (via context menu or message list header)

### Mode B: Spam / One-off
- Shows: Only stray handles matching junk-like heuristics (and not dismissed)
- Purpose: Fast blitz-dismiss workflow
- **Critical UI rule:** Sidebar row owns the Dismiss button (always visible)
- **Critical behavior:** Dismiss auto-advances to next handle

### Mode C: Dismissed (escape hatch)
- Access: Settings → Advanced → Dismissed handles (optionally as sidebar mode)
- Shows: Dismissed handles only
- Actions: Restore / Label handle… (implicit restore)

## User Experience Flow

### Blitz Dismiss (Spam Mode)
```
User selects "From stray phone numbers" → Spam tab
  → Sees dense list with always-visible Dismiss buttons
  → Clicks Dismiss (or presses Enter)
  → Handle disappears, next handle auto-selected
  → Repeat until list is empty
```

### Label Handle (All Strays Mode)
```
User selects unknown handle → sees message preview
  → Clicks "Label handle…"
  → Enters "?Paul's brother" in text field
  → Virtual contact created automatically
  → Handle no longer stray, messages enter circulation
```

## Heuristics for Spam Mode

Scoring system (include if `junkScore >= 3`):

| Signal | Score |
|--------|-------|
| Short code (3–8 digits, no country code) | +3 |
| Message count == 1 | +2 |
| Message count <= 3 | +1 |
| All messages within 24h window | +1 |
| Zero outbound messages from user | +1 |
| OTP keywords (verification, security code, 2FA, OTP, passcode) | +2 |
| Unsubscribe keywords (reply STOP, msg&data rates) | +2 |
| URL presence in messages | +1 |

Badges (optional, low visual weight):
- "Short code" — numeric handles 3–8 digits
- "2FA" — OTP keyword match
- "Promo" — unsubscribe keyword match

## Open Questions

1. **Keyboard shortcuts scope** — Enable in Spam mode only, or all modes?
2. **Mode toggle location** — Segmented control in sidebar header, or separate menu items?
3. **InfoCard placement** — Persistent banner in Spam mode, or dismissible?

## Dependencies

- Existing `strayHandlesProvider` (Phase 1)
- Existing `HandleLensView` (Phase 2)
- Overlay DB schema (`handle_to_participant_overrides`)
- Virtual participants infrastructure

## Success Criteria

- [ ] User can dismiss 50+ junk handles in under 2 minutes using Spam mode
- [ ] Dismissed handle messages never appear in search results
- [ ] Dismissed handle messages excluded from All Messages view
- [ ] Label action creates virtual contact in single step
- [ ] Dismissal persists across app restart and re-import
