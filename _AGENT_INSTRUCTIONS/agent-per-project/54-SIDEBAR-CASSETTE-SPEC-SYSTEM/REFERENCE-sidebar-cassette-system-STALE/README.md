---
tier: project
scope: cassette-content-control
owner: agent-per-project
last_reviewed: 2025-12-21
source_of_truth: doc
links:
  - ../README.md
  - ./00-cassette-choice-flow-and-responsibilities.md
tests: []
---

# Cassette Content Control

This folder defines **where cassette UI choices are made** (and where they are *not* made).

- Primary doc: [`00-cassette-choice-flow-and-responsibilities.md`](00-cassette-choice-flow-and-responsibilities.md)

## What belongs here

- Responsibility boundaries for cassette selection (feature vs essentials vs presentation)
- Canonical “decision flow” diagrams / narratives
- Guardrails and anti-patterns (what to avoid)

## What does not belong here

- Feature-specific UI implementation details (those belong in the feature’s own docs)
- One-off debugging notes that aren’t generalized into a reusable rule
