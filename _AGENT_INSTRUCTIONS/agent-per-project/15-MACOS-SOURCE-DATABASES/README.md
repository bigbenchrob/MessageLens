---
tier: project
scope: macos-source-databases
owner: agent-per-project
last_reviewed: 2026-03-13
source_of_truth: doc
links:
  - ./00-overview.md
  - ./10-chat-db-orphan-messages.md
  - ./20-external-tools-and-rust-crates.md
  - ./apple-typedstream-format-reference.md
tests: []
---

# macOS Source Databases

This section documents the raw Apple-owned source databases that MessageLens reads from, with emphasis on how `~/Library/Messages/chat.db` behaves in practice rather than how the import ledger wishes it behaved.

Use these docs when you need to reason about:

- what the source `chat.db` schema actually stores
- which records are well-formed versus partially linked
- how `attributedBody` / typedstream content fits into message recovery
- which external reverse-engineering and Rust tools are useful when validating assumptions outside the Flutter app

## Canonical Docs

- `00-overview.md` — Scope and operating model for source-database analysis
- `10-chat-db-orphan-messages.md` — Findings from direct inspection of source `chat.db` orphan message rows
- `20-external-tools-and-rust-crates.md` — External references for `chat.db` parsing and export
- `apple-typedstream-format-reference.md` — Reverse-engineering notes for Apple's typedstream format used in `attributedBody`

## Practical Rule

When import or migration behavior looks suspicious, inspect the source database model first. Do not assume Apple’s own tables form a perfectly thread-linked graph.