---
tier: project
scope: architecture
owner: @rob
last_reviewed: 2025-10-25
source_of_truth: doc
links:
  - ../_shared/00-global/riverpod-rules.md
tests: []
---

# ADR-0001 — Riverpod Codegen Only

## Status
Accepted

## Context
We want consistency and less boilerplate.

## Decision
Use `@riverpod` for all providers; no manual `StateNotifierProvider` creation.

## Consequences
- Pros: less boilerplate, uniform patterns
- Cons: build_runner dependency
