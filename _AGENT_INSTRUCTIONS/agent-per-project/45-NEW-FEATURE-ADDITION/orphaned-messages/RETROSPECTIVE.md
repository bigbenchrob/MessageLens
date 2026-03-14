---
tier: feature
scope: retrospective
owner: agent-per-project
last_reviewed: 2026-03-14
source_of_truth: synthesis
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ../../15-MACOS-SOURCE-DATABASES/10-chat-db-orphan-messages.md
  - ../../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
  - ../../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
tests: []
---

# Retrospective — Recovered Deleted Messages

This note exists to capture the human story behind the recovered deleted-messages work.

The reference docs describe the schema, import path, and UI surfaces. This file explains what was actually learned, why the feature became more valuable than it first appeared, and what MessageLens now reveals that the old app architecture hid.

## What We Initially Thought

The earlier app model effectively assumed that if a source row was not reachable through `chat_message_join`, then it was outside the meaningful message history of the user.

That assumption was tidy, but wrong.

The import pipeline was faithful to the visible thread graph rather than to the deeper source data shape. In practice that meant the app treated Apple's thread linkage as if it were the same thing as message existence.

## What The Source Database Actually Showed

Direct inspection of `~/Library/Messages/chat.db` showed a large population of `message` rows that:

- still existed in the source database
- often still carried meaningful payloads
- sometimes still retained real handle identity
- but no longer had a `chat_message_join` relationship

That was the turning point.

The important discovery was not merely that these rows existed. It was that many of them looked like real user conversation fragments rather than junk:

- ordinary conversational text
- outbound short replies
- `attributedBody`-only messages whose text could be recovered
- attachment-linked rows

This suggested that Apple's visible conversation graph can hide or sever message reachability without fully deleting the underlying message rows.

## What We Now Hypothesize About Apple

These are working hypotheses, not proven facts from Apple's implementation:

1. Apple may make messages disappear from normal thread traversal by removing or severing relationship rows rather than always fully deleting the underlying `message` row.
2. That hide/delete path appears lossy and asymmetric. Some recovered rows retain handle identity, while others preserve content and timestamps but lose sender linkage.
3. The source database likely has more than two meaningful states for a message: fully thread-visible, materially present but graph-hidden, and fully absent.
4. A meaningful portion of the orphan population may be associated with conversations deleted from Apple's Messages UI on iPad via swipe-left gestures. That is presently a strong user-level correlation, not a reverse-engineered fact.

The practical lesson is simple: visible-thread membership is not the same thing as source-data existence.

## How MessageLens Was Restructured

The app was changed in a deliberately conservative way.

It did **not** solve the problem by pretending those rows belonged to a normal chat.

Instead, the recovery path was split out explicitly:

- source orphan rows are preserved in dedicated recovered ledger tables
- migration projects them into dedicated recovered working-db tables
- recovered content is surfaced through dedicated ViewSpec routes and UI surfaces
- normal chat providers remain thread-oriented and are not polluted with speculative chat membership

This matters because it preserves source truth while still making the hidden content visible.

The app became more honest in two directions at once:

- more complete about what survives in Apple's databases
- more cautious about what it can actually prove about thread membership

## Why The Feature Became Much More Useful

The first recovered rows were interesting, but often fragmentary.

The larger breakthrough came later: once nearby outgoing no-handle recovered rows were shown alongside directly attributable recovered rows, some contact-scoped views suddenly became conversation-like.

In practice, the user's own replies often supplied the missing context that made an inbound recovered orphan intelligible.

That changed the feature from:

- "here is a bucket of weird hidden records"

to:

- "here is a partial but meaningful reconstruction of conversation context that Apple's normal thread graph no longer exposes"

The app still does not claim those inferred outgoing rows are proven members of the same original chat. But showing them, clearly labeled as best-guess context, restores meaning that was otherwise invisible.

## What Was Previously Hidden

Before this work, the app hid information for architectural reasons rather than because the source databases lacked it.

Specifically, the old model hid:

- source message rows that survived without thread linkage
- recovered rich text that still lived in `attributedBody`
- attachment-linked recovered rows
- nearby outgoing context that could make a surviving orphan message understandable

The recovered deleted-messages feature reveals that hidden layer without rewriting it as ordinary chat history.

## Why This Matters As A Product Principle

This work reinforced a broader MessageLens rule:

> when Apple's data model looks anomalous, preserve and expose the anomaly first; only then decide how much interpretation is safe.

That principle is why the recovered deleted-messages feature is valuable. It does not erase uncertainty. It makes previously hidden information visible while keeping uncertainty explicit.

## Current Limits

The recovered view is still intentionally conservative.

- It does not fabricate normal chat membership.
- It does not claim every nearby outgoing orphan row belongs to the same original deleted conversation.
- Sparse artifacts remain preserved but lower-priority in the UI.
- Broader recovered search and more advanced conversation reconstruction remain future work.

## Bottom Line

The most important outcome was not just a new feature.

It was the discovery that Apple's apparent deletion / hiding behavior and the app's old thread-only assumptions were combining to conceal a meaningful class of user history.

MessageLens now reveals that class of history on purpose.