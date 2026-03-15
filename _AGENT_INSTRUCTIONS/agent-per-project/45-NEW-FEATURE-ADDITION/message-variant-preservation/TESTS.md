---
tier: feature
scope: tests
owner: agent-per-project
last_reviewed: 2026-03-14
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./RETROSPECTIVE.md
tests: []
---

# Tests — Message Variant Preservation

## Import / Unit Tests (planned)

- source row with plain `text` preserves `raw_item_type` and classifies as plain text
- source row with `NULL text` and non-null `attributedBody` preserves typedstream evidence
- source row with `message_summary_info` preserves edit / unsend evidence
- source row with payload data and balloon bundle preserves balloon / app evidence
- sparse recovered orphan row preserves raw discriminators even when content channels are empty

## Migration / Unit Tests (planned)

- ledger raw discriminator fields project correctly into working-db
- normalized semantic fields are populated deterministically from preserved evidence
- sparse artifact rows remain preserved and flagged as such
- unknown raw variants remain unknown rather than falling back to ordinary text

## Classification Tests (planned)

- reaction / associated-message carrier rows classify separately from normal text
- edited / unsent rows classify separately from blank messages
- app / balloon rows classify separately from plain text
- attachment-only rows classify separately from sparse artifacts
- rows like recovered message `98015` classify as `unknown-variant` or `sparse-artifact`, never ordinary text

## Provider / Query Tests (planned)

- recovered-message providers surface raw and normalized semantic metadata
- existing message providers remain stable where new metadata is additive
- diagnostic filters can isolate sparse artifacts and unknown variants

## Widget / Manual Verification (planned)

- developer-only recovered UI shows raw item type and semantic classification
- a sparse artifact row no longer appears as a blank ordinary text message
- typedstream-backed recovered rows still show recovered body text where available
- edited / unsent examples are explainable when present in the dataset

## Regression Concerns

- schema growth without enough diagnostic value
- classifier overreach causing false-positive semantics
- broken backward assumptions in existing message consumers
- accidental dropping of anomalous rows while refining classification logic