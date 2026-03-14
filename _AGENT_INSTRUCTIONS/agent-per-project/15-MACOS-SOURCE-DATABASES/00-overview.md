---
tier: project
scope: macos-source-databases
owner: agent-per-project
last_reviewed: 2026-03-13
source_of_truth: doc
links:
  - ./README.md
  - ./10-chat-db-orphan-messages.md
  - ./20-external-tools-and-rust-crates.md
  - ./apple-typedstream-format-reference.md
  - ../10-DATABASES/04-db-chat.md
tests: []
---

# macOS Source Database Overview

The app’s import pipeline depends on Apple-managed sqlite databases whose internal data model is richer and messier than the app’s thread-oriented projection model.

## Current Focus

The most important source database is:

- `~/Library/Messages/chat.db`

This database contains:

- chats and chat membership (`chat`, `chat_handle_join`)
- handles (`handle`)
- message rows (`message`)
- chat linkage (`chat_message_join`)
- attachment linkage (`attachment`, `message_attachment_join`)

## Key Insight

`chat.db` is not equivalent to “messages currently visible in the Messages app conversation list”.

Direct inspection in this repository showed that `chat.db` contains a substantial orphan message population:

- records present in `message`
- often linked to real handles
- often carrying plain text, rich text blobs, or attachment joins
- but lacking a `chat_message_join` row

That means source truth in `chat.db` must be treated as:

- richer than the current import model
- potentially more complete than thread-linked views
- internally inconsistent from the perspective of a simple `message -> chat` assumption

## Design Implication

When MessageLens chooses not to import or display a source record, that must be an explicit product decision, not an accidental consequence of assuming Apple’s schema is perfectly normalized.

## Related Topics

- For orphan-source-message findings, see `10-chat-db-orphan-messages.md`.
- For `attributedBody` decoding, see `apple-typedstream-format-reference.md`.
- For external ecosystem tools that parse `chat.db`, see `20-external-tools-and-rust-crates.md`.