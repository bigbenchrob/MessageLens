---
tier: project
scope: macos-source-databases
owner: agent-per-project
last_reviewed: 2026-03-14
source_of_truth: live-source-db-analysis
links:
  - ./00-overview.md
  - ../10-DATABASES/04-db-chat.md
  - ../10-DATABASES/10-group-import-working.md
  - ../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
  - ../45-NEW-FEATURE-ADDITION/orphaned-messages/PROPOSAL.md
tests: []
---

# `chat.db` Orphan Message Findings

This document records direct read-only analysis of `~/Library/Messages/chat.db` performed against a live user database in March 2026.

## Definition

In this context, an “orphan message” is a row that exists in `message` but has no corresponding `chat_message_join.message_id` entry.

SQL shape:

```sql
SELECT *
FROM message m
WHERE m.ROWID NOT IN (SELECT message_id FROM chat_message_join);
```

## Confirmed Counts

- source `message` rows: `116614`
- source `chat_message_join` rows: `106997`
- orphan `message` rows: `9618`

These counts exactly match the source-vs-ledger delta seen in `import_log` during a fresh rebuild.

## High-Value Signal

The orphan population is not mostly junk.

- orphan rows with non-empty plain `text`: `279`
- orphan rows without plain text: `9339`
- of those non-plain-text rows, rows with non-null `attributedBody`: `8904`
- orphan rows participating in `message_attachment_join`: `450` distinct orphan messages, `658` join rows

## Conservative Product Buckets

Using a conservative “likely real content” rule:

- likely real content = has plain `text`, or has `attributedBody`, or has an attachment join
- sparse artifact = no plain `text`, no `attributedBody`, and no attachment join

Observed counts:

- likely real orphan content: `9184`
- sparse orphan artifacts: `434`

Combination breakdown:

| plain text | attributedBody | attachment join | count |
| --- | --- | --- | --- |
| 0 | 1 | 0 | 8458 |
| 0 | 1 | 1 | 446 |
| 0 | 0 | 0 | 434 |
| 1 | 1 | 0 | 276 |
| 1 | 1 | 1 | 3 |
| 0 | 0 | 1 | 1 |

## Content Characteristics

### Text-bearing orphan rows

Observed examples included:

- SMS verification codes
- delivery notifications
- ordinary conversational text
- outbound short replies

These rows were linked to concrete `handle_id` values and looked user-meaningful.

### Non-plain-text orphan rows

Observed characteristics:

- overwhelmingly `iMessage`
- many `is_from_me = 1`
- most had non-null `attributedBody`
- some had valid attachment joins to photos, videos, screenshots, and plugin payload attachments

### Sparse orphan artifacts

The truly sparse subset (`434` rows) was mostly:

- `iMessage`
- inbound
- non-text item types
- no plain text
- no `attributedBody`
- no attachment join

These are the best candidates for a secondary “artifact” bucket rather than a main recovered-content surface.

## Handle Evidence

The orphan population is not limited to short codes.

Large orphan counts were observed for real iMessage handles, including one identity contributing `2410` orphan rows.

That means the source orphan issue is not just service noise; it includes conversation-linked identities users would recognize.

## Confirmed Behavioral Pattern

Across the live dataset and subsequent app-side recovery work, the following pattern is now well supported:

- some source `message` rows survive in `chat.db`
- those rows can retain real content payloads (`text`, `attributedBody`, attachment joins)
- but their thread linkage through `chat_message_join` is absent
- some rows still retain a sender handle
- some outbound rows appear to lose sender linkage entirely while still preserving timing and content

This means the missing thread relationship is not equivalent to message deletion from the database. At minimum, Apple can leave meaningful message records in place while making them disappear from ordinary thread-linked traversal.

## User-Level Correlation Observed During Recovery Work

During manual inspection of recovered rows in MessageLens, a strong practical correlation emerged:

- many or most identifiable orphaned rows appeared to belong to iMessage conversations that had been removed with swipe-left delete gestures on iPad

This is not a source-db fact that can be proven from SQL alone. It is a user-observed correlation between:

- conversations the user remembers deleting from Apple's Messages UI on iPad
- recovered orphan rows that remain materially present in `chat.db`

That correlation is important because it gives a concrete real-world candidate mechanism for how these rows became graph-hidden while still remaining in the source database.

## Working Hypotheses About Apple Behavior

These points are hypotheses, not reverse-engineered facts proven from Apple's code:

1. **Thread hiding / deletion may be implemented partly by relationship removal rather than full row deletion.**
  The strongest evidence is the large population of meaningful `message` rows that remain present while lacking `chat_message_join` membership.

2. **The hiding path appears lossy and asymmetric.**
  Some recovered rows still carry handle identity cleanly, while others preserve text and timing but lose sender linkage. This suggests Apple may sever multiple relationships during a hide/delete flow, not just one.

3. **Outbound context is more likely to survive as structurally damaged rows.**
  In contact-scoped recovered browsing, adding nearby no-handle outgoing rows often reconstructs the user's replies and makes the surviving inbound orphan rows suddenly intelligible as conversation fragments.

4. **The source database likely contains multiple "visibility states," not just present vs deleted.**
  The observed orphan population fits a model where rows can remain materially present in `message` while no longer being reachable through the app's normal conversation graph.

5. **Swipe-left conversation deletion on iPad is a plausible trigger for at least part of the orphan population.**
  User-observed recovery sessions suggest that many identifiable recovered rows correspond to conversations removed from Apple's Messages UI on iPad with swipe-left delete. This does not prove Apple's internal mechanism, but it is currently one of the strongest user-level correlations explaining why meaningful rows survive while thread linkage disappears.

These hypotheses should be treated as a practical interpretation of the data shape, not as a definitive explanation of Apple's implementation.

## Product Implication

The safest interpretation is:

- orphan rows should not be silently discarded as meaningless
- orphan rows should not be merged into existing chats without stronger evidence of chat membership
- a quarantined but user-accessible surface such as `Unlinked Messages` or `Recovered Unlinked Content` is justified

## What MessageLens Now Reveals

The app has now been restructured to preserve and surface this previously hidden class of source records rather than discarding them.

Current behavior:

- import preserves source orphan rows into dedicated recovered tables
- migration projects them into dedicated working-db recovered tables
- the UI exposes them through a separate recovered-deleted-messages surface
- contact-scoped browsing can match rows by surviving sender identity and, conservatively, infer nearby outgoing no-handle replies to restore conversation context

The result is not a proof of original chat membership, but it does reveal user-meaningful conversational context that the earlier thread-only model hid from the app entirely.

## Import Implication

If the app later imports orphan rows, do not fabricate a normal chat relationship. Preserve their orphan status explicitly and expose that status in both audit logs and UI metadata.