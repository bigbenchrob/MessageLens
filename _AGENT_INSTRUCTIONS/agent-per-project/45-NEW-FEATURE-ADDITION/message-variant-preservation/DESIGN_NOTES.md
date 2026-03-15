---
tier: feature
scope: design-notes
owner: agent-per-project
last_reviewed: 2026-03-14
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./RETROSPECTIVE.md
  - ../orphaned-messages/PROPOSAL.md
  - ../../15-MACOS-SOURCE-DATABASES/10-chat-db-orphan-messages.md
tests: []
---

# Design Notes — Message Variant Preservation

## Core Principle

Preserve useful source discriminators without trying to clone Apple’s entire schema.

That means:

- keep the fields that explain what a row might be
- keep enough payload evidence to revisit classification later
- classify conservatively
- preserve uncertainty explicitly

## Why This Exists After Orphaned Messages

The orphaned-messages work solved a preservation problem first:

- recover rows that Apple left in `message`
- keep them separate from normal thread-linked history

That work also exposed a second problem:

- some preserved rows are being described too simplistically because upstream semantics are too weak

In other words, orphan recovery revealed a classification gap.

## Rejected Approach

### Do not mirror all of `message`

Rejected because:

- `chat.db` is historically messy and wide
- a broad mirror would create long-term maintenance cost with little product value
- preserving every field would blur the boundary between “MessageLens model” and “Apple’s database internals”

### Do not classify only by `text` and a few `item_type` constants

Rejected because:

- edited / unsent messages may have `NULL text`
- app / balloon messages may carry meaning in payloads rather than text
- sparse artifacts can be structurally empty yet still important as diagnostics
- unknown Apple variants should not be mislabeled as ordinary text

## Recommended Preservation Model

### Ledger layer

Ledger should preserve raw source evidence.

Recommended categories of fields:

- raw discriminators
- payload carriers
- presence flags
- association / relationship hints

Examples:

- `raw_item_type`
- `raw_associated_message_type`
- `message_summary_info`
- `payload_data`
- `has_text`
- `has_attributed_body`
- `has_attachment_join`
- `has_chat_join`

### Working layer

Working-db should project a smaller, reusable semantic model.

Recommended outputs:

- `semantic_kind`
- `content_presence_kind`
- `is_sparse_artifact`
- `raw_item_type`
- `raw_associated_message_type`
- selected presence flags needed by providers and developer UI

## Classification Philosophy

The classifier should answer two separate questions:

1. What raw evidence channels exist?
2. What is the safest semantic label given that evidence?

These should not be collapsed into one field.

### Example distinction

For a row like recovered message `98015`:

- evidence: no text, no attributed body, no attachment join, no summary info, no payload data, no chat join, raw `item_type = 1`
- semantic label: likely `sparse artifact` or `unknown raw variant`

Not:

- `text`

## Candidate Normalized Fields

Possible `semantic_kind` values:

- `plain-text`
- `rich-text`
- `edited-or-unsent`
- `associated-reaction`
- `balloon-or-app`
- `attachment-only`
- `system`
- `unknown-variant`
- `sparse-artifact`

Possible `content_presence_kind` values:

- `plain-text-only`
- `typedstream-only`
- `text-and-typedstream`
- `summary-info-only`
- `payload-only`
- `attachment-only`
- `no-user-content`

## Why The `imessage-database` Crate Matters

The crate is useful as a semantic reference, not necessarily as a direct dependency choice.

It demonstrates that:

- Apple message interpretation requires more than `message.text`
- edited / unsent state can live in `message_summary_info`
- app / balloon / plugin messages form a large family of structured variants
- unknown variants should remain unknown until evidence supports stronger interpretation

## Implementation Sequencing

Recommended order:

1. approve preserved raw field set
2. extend ledger schema
3. extend working schema and migrators
4. implement classifier with tests
5. expose recovered developer diagnostics
6. evaluate broader linked-message usage

This keeps schema and semantics stable before UI consumers grow around them.