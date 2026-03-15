---
tier: feature
scope: retrospective
owner: agent-per-project
last_reviewed: 2026-03-14
source_of_truth: synthesis
links:
  - ../orphaned-messages/RETROSPECTIVE.md
  - ./PROPOSAL.md
  - ../../15-MACOS-SOURCE-DATABASES/10-chat-db-orphan-messages.md
  - ../../15-MACOS-SOURCE-DATABASES/20-external-tools-and-rust-crates.md
tests: []
---

# Retrospective — What Led Here

This note exists to capture why a new message-variant preservation feature became necessary.

## The Immediate Trigger

During review of recovered deleted messages, many rows were surfacing as:

- identifiable handle
- plausible date and service
- item type shown as `text`
- rendered body shown as `(No text content)`

At first glance, that looked like a body-extraction failure.

## What Investigation Showed

Direct inspection of a concrete row, recovered message `98015`, showed:

- working-db preserved the row faithfully
- import ledger also had `text = NULL`
- source `chat.db` had both `text = NULL` and `attributedBody = NULL`
- the row had no `chat_message_join`
- the row had no `message_attachment_join`
- the row was therefore not a failed text extraction and not an attachment-backed message

That changed the question from:

- “why didn’t we decode this text?”

to:

- “why are we currently describing this Apple row as ordinary text at all?”

## The Deeper Discovery

The recovered-row investigation exposed a broader semantic weakness:

- preservation is stronger than classification

We are already preserving more anomalous rows than before because of the orphaned-messages work. But once those rows became visible, it became obvious that the importer’s message taxonomy was still too crude.

Rows with materially different Apple shapes can currently collapse into the same app-facing label.

## Why External Schema Research Mattered

Reviewing the `imessage-database` Rust crate documentation helped confirm that this is a genuine modeling gap, not just a one-off bad row.

Reference:

- docs.rs crate homepage: https://docs.rs/imessage-database/latest/imessage_database/index.html

The library documents many message families that do not behave like plain text:

- rich typedstream-backed text
- edited / unsent messages
- tapbacks and associated-message carriers
- app / balloon payload messages
- other structured variants

That reinforced a key point:

`NULL text` is not one thing.

Sometimes it means rich text lives elsewhere. Sometimes it means edited / unsent state. Sometimes it means plugin payloads. Sometimes it means the row is a sparse artifact. Those states should not all collapse into `text`.

## Why This Merits A Separate Feature

The orphaned-messages branch taught us to preserve hidden source records.

This next feature is about learning to preserve and interpret more of their **meaningful shape**.

That is a separate problem because it affects:

- ledger schema
- working schema
- classifier logic
- diagnostics
- future UX decisions

## Product Lesson

The recovered deleted-messages work showed that MessageLens becomes more valuable when it reveals source reality instead of simplifying it away.

This feature continues that principle:

preserve what is useful, classify conservatively, and keep uncertainty explicit.