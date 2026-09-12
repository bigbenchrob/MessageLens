---
tier: project
scope: feature-history
owner: agent-per-project
last_reviewed: 2026-09-12
source_of_truth: implementation
links:
  - ../../40-FEATURES/search/SEARCH_SEMANTICS.md
  - ./04-DEFERRED-LINK-PREVIEW-SEARCH.md
tests:
  - test/essentials/search/application/message_text_search_query_test.dart
  - test/essentials/conversation_graph/infrastructure/message_text_fts_runtime_test.dart
  - test/essentials/search/infrastructure/repositories/graph_search_repository_test.dart
  - test/essentials/onboarding/application/message_lens_installation_validation_service_test.dart
  - test/startup_installation_state_surface_test.dart
status: completed
---

# Message-Text Search Enhancement

This completed feature-history package records the staged prompts, audits, and
implementation decisions that produced MessageLens' structured message search.

The shipped behavior includes:

- raw editor input and trailing whitespace preservation;
- unfinished word-prefix and whitespace-completed exact-token semantics;
- graph-owned FTS5 indexing of visible message text only;
- highlighting aligned with execution semantics;
- per-term AND/OR composition across visible message text and tags;
- saved and scope restrictions applied outside boolean alternatives;
- final result ordering and limiting after evidence composition;
- consistent filtering across global, Conversation, Contact, Handle, Handle
  Lens, and recovered-message surfaces.

Current operating guidance lives in
[`40-FEATURES/search/SEARCH_SEMANTICS.md`](../../40-FEATURES/search/SEARCH_SEMANTICS.md).
The local-only Apple link-preview metadata investigation remains a separate
future feature and is recorded in
[`04-DEFERRED-LINK-PREVIEW-SEARCH.md`](04-DEFERRED-LINK-PREVIEW-SEARCH.md).

The post-integration startup follow-up is also retained here because the new
graph-owned FTS schema exposed a stale startup schema ceiling. That correction
now shares the authoritative graph schema version, renders a restricted shell
before classification, and reserves full physical integrity scans for typed
suspicious evidence and safety-critical workflows. Prompts 12–14 and responses
15–20 preserve the audit, policy decision, implementation, and measured launch
results.
