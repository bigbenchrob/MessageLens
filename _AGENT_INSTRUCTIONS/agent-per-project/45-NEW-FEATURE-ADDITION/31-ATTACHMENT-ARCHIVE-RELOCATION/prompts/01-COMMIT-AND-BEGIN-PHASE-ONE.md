This is now mature enough to move from architecture into implementation. I’d make the next Codex prompt **Phase 1 only**, with one preliminary housekeeping step: commit the audit document before touching production code.

That keeps the design baseline immutable and gives us a clean checkpoint before implementation begins. The audit itself explicitly defines Phase 1 as the location/configuration model, default-root compatibility, provider adaptation, and architecture tripwires, with the exit criterion that existing behaviour remains unchanged and all current tests pass. 00\-ARCHITECTURE\-AUDIT\-AND\-IMPLEMENTATION\-PLAN.md



We are ready to begin implementation of:

`31-ATTACHMENT-ARCHIVE-RELOCATION`

The architecture audit is now the design constraint and source of truth for this feature:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/00-ARCHITECTURE-AUDIT-AND-IMPLEMENTATION-PLAN.md`

Read that document in full before making any implementation changes.

Do not reinterpret or redesign the feature from scratch. Treat the decisions recorded there as settled unless direct code inspection proves that one of them is factually incorrect.

## Current branch and baseline

Expected branch:

`feature/attachment-archive-relocation`

Expected starting HEAD:

`c2f546dc99eb50c66233ef94ddb0e70c7d77990e`

Expected shared instructions submodule:

`95326f515ef4719f155ce6e223990398daad6311`

The audit document currently exists as a new untracked file.

There are also deliberate unrelated untracked files which must remain untouched, including:

- `.vscode/settings.json`
- the archive-recovery prompt
- Prompt 16
- `seed.md`
- `seed-response.md`

Do not add, modify, delete, move, stage, stash, or commit any unrelated untracked file.

---

# Step 0 — checkpoint the audit

Before changing production code:

1. Verify the branch, HEAD, tracked worktree, submodule state, and deliberate untracked files.
2. Stage only:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/00-ARCHITECTURE-AUDIT-AND-IMPLEMENTATION-PLAN.md`

3. Commit that document as a documentation-only checkpoint.

Suggested commit message:

`docs(attachments): add archive relocation architecture plan`

4. Confirm that:
   - only that document was committed;
   - the deliberate unrelated untracked files remain untouched;
   - the shared submodule remains unchanged.

Do not push unless repository instructions explicitly require it.

After that checkpoint, proceed with Phase 1 implementation.

---

# Phase 1 objective

Implement only:

**Location model and default compatibility**

The purpose of this phase is to introduce the architectural seam needed for a relocatable attachment archive while preserving the exact current physical behaviour:

`attachment_archive` remains beneath the admitted primary MessageLens data root.

There must be:

- no external folder selection yet;
- no bookmark implementation yet;
- no volume event handling yet;
- no relocation engine;
- no copy/move operation;
- no unavailable-external-drive UI;
- no old-copy retirement;
- no schema migration;
- no attachment payload migration.

At the end of Phase 1, MessageLens should behave exactly as it did before this feature began, but attachment archive consumers should now obtain their active root through the new attachment-owned location architecture.

The audit defines the Phase 1 exit criterion as:

> all current tests pass with the default root and no payload or schema change.

---

# Architectural requirements

## 1. Preserve the primary-root boundary

`ArchiveAccessAuthority` remains responsible for the admitted primary MessageLens data root.

Do not broaden its authority to include arbitrary external attachment roots.

Its only attachment-specific role in the new architecture should be deriving the existing default root:

`attachment_archive`

beneath the admitted primary root.

The audit explicitly requires an attachment-owned configurable-root boundary rather than expanding primary-root authority.

---

## 2. Introduce the location configuration model

Add an immutable model equivalent in semantics to:

`AttachmentArchiveLocationConfiguration`

The exact naming may follow repository conventions.

It must be versionable from the start.

For Phase 1 it only needs to support the current/default configuration in operational use, but structure it so that a later phase can represent:

- `defaultInternal`
- `customExternal`

without replacing the model.

Do not prematurely implement bookmarks or external-path behaviour.

The persisted configuration is machine-specific application configuration, not attachment identity.

Do not place absolute archive-root paths into `archived_attachments`.

---

## 3. Persist through the existing overlay settings abstraction

Reuse and extend the existing:

`OverlayAttachmentArchiveSettingsStore`

or the canonical equivalent found by code inspection.

Store one versioned logical location record through the existing settings mechanism.

Do not add:

- Drift schema columns;
- SQLite tables;
- schema migrations;
- FTS changes;
- graph-schema changes;
- import-schema changes.

The existing `archive_relative_path` storage must remain unchanged.

If no location setting exists yet, absence must cleanly resolve to the current default/internal behaviour.

This is essential for compatibility with every existing installation.

---

## 4. Introduce typed location state

Add an immutable attachment-owned location state model corresponding to the architecture in the audit.

The eventual design must be capable of expressing distinctions such as:

- default available;
- custom available;
- custom read-only;
- custom unavailable;
- permission denied;
- configured directory missing;
- configuration invalid.

However, Phase 1 must not pretend that external states are operational if their supporting native mechanisms do not yet exist.

Implement only what is needed to represent and consume the current default location cleanly while establishing a type structure that can be extended without replacing public contracts in Phase 2/3.

Avoid speculative complexity.

---

## 5. Introduce the attachment-owned location controller/repository

Create the narrow attachment-feature boundary responsible for:

- loading location configuration;
- deriving the default internal archive root from `ArchiveAccessAuthority`;
- publishing the active location state;
- owning the concept of attachment archive location.

This should live with the attachment feature except where repository architecture requires a narrower shared abstraction.

Do not put this logic in the database layer merely because the old provider was located there.

The audit identifies the current database-layer archive-directory provider as misplaced architectural ownership.

---

## 6. Preserve default behaviour exactly

For the existing default configuration:

- the physical location must remain exactly the same;
- existing payload files must remain untouched;
- existing overlay rows must remain untouched;
- existing hashes and relative paths must remain untouched;
- no archive directory should be moved, renamed, copied, recreated, or re-inventoried;
- no user database should be mutated except the harmless location-setting initialization if the design genuinely requires it.

Prefer a default-on-read model if it avoids gratuitously writing configuration into every existing overlay database.

Do not introduce migration merely to record “use the default.”

---

## 7. Adapt root consumers

Audit and update the current direct consumers of:

`attachmentArchiveDirectoryProvider`

and equivalent archive-root construction.

The important architectural outcome is that attachment feature consumers obtain the active root through the new attachment-owned location boundary.

Where practical, consumers that need only a usable root should receive typed resolved state or an operation-specific root object rather than reconstructing a string path.

However, do not implement the full availability-aware read/write lease architecture scheduled for later phases unless necessary to establish the Phase 1 seam.

Preserve behaviour.

Relevant areas identified by the audit include:

- attachment runtime providers;
- archive store providers;
- graph attachment archive providers;
- attachment archive service;
- archive read lookup;
- compatibility lookup;
- recovery destination wiring;
- settings/statistics access;
- tests and architecture fixtures.

Trace actual dependencies before editing.

---

## 8. Compatibility bridge

If removing `attachmentArchiveDirectoryProvider` immediately would produce excessive unrelated churn, it may temporarily remain as a compatibility provider.

If retained, it must delegate to the new attachment-owned location architecture rather than continuing to independently derive:

`ArchiveAccessAuthority.resolvePath('attachment_archive')`

No new code should depend directly on the legacy provider.

Document any temporary compatibility bridge and identify when it should disappear.

---

## 9. Location generation

The audit recommends that future root changes publish a monotonically changing location generation because runtime objects contain absolute paths.

Establish this concept in Phase 1 if it can be done cleanly without forcing Phase 2/3 behaviour.

The default location should have a stable generation.

Do not add fake volume-event logic.

The goal is to avoid needing a breaking provider redesign later when custom roots become active.

---

# Performance requirement

Do not make attachment archive location resolution expensive.

In particular, Phase 1 must not introduce:

- recursive archive scans;
- whole-archive stats reads;
- per-payload validation;
- integrity checks;
- directory traversal

into startup, installation classification, search, or ordinary message browsing.

The audit specifically found that archive status and recursive archive statistics are currently too closely coupled in some paths.

If Phase 1 naturally allows cheap configuration/location state to be separated from expensive stats, do so.

But do not broaden the scope into the complete Phase 3 diagnostics/UI work.

---

# Reuse requirements

Reuse existing architecture wherever appropriate.

In particular preserve or extend rather than replace:

- `ArchiveAccessAuthority` for the primary root;
- overlay settings persistence;
- attachment archive read/write/store interfaces;
- existing Riverpod/provider conventions;
- existing immutable model conventions;
- existing settings architecture;
- existing logging/error conventions.

Do not build a parallel settings system.

Do not build a generic filesystem-location framework unless the actual repository demonstrates that such abstraction is already warranted.

Keep this feature narrow.

---

# Architecture tripwires

Add or extend tests so the repository enforces the new ownership rule.

At minimum, establish protection against future feature code bypassing the location controller by reconstructing the active archive root from:

- the primary root plus literal `attachment_archive`;
- hard-coded `/Volumes/...`;
- arbitrary absolute paths.

Be careful not to prohibit legitimate donor-package code where `attachment_archive` is intentionally part of the historical package format.

The tripwire must distinguish:

**active archive root derivation**

from:

**donor archive format interpretation**

The audit explicitly says donor-package `attachment_archive` children remain valid and are not the active-root mechanism.

---

# Tests

Add focused tests for Phase 1.

At minimum cover:

1. No persisted location configuration resolves to the existing default archive directory.
2. Explicit default/internal configuration resolves to the same directory.
3. The default root is derived through `ArchiveAccessAuthority`.
4. Existing relative archive paths resolve identically before and after the refactor.
5. Existing archive write/read behaviour remains unchanged.
6. No absolute active-root path is added to attachment metadata.
7. No schema version changes occur.
8. No startup dependency on archive scanning is introduced.
9. Architecture tests prohibit unauthorized active-root reconstruction.
10. Existing donor/historical archive path conventions continue to work.
11. Relevant provider overrides used by tests remain practical and deterministic.
12. Existing production/development root behaviour remains unchanged.

Run the focused attachment/provider/architecture suites first, then the broader appropriate test suite required by repository instructions.

If any existing test depends directly on the old provider, update it to test the new ownership boundary rather than merely changing strings until it passes.

---

# Documentation

Update the feature folder with a Phase 1 implementation record.

Create an appropriately numbered document under:

`31-ATTACHMENT-ARCHIVE-RELOCATION/`

Record:

- files changed;
- new models/components;
- provider dependency changes;
- compatibility bridge, if any;
- configuration persistence behaviour;
- tests added/updated;
- exact tests run;
- any deviations from the audit;
- any findings that should alter Phase 2.

Do not overwrite the architecture audit.

---

# Explicitly out of scope

Do not implement any of these in Phase 1:

- external folder chooser;
- `/Volumes/...` persistence;
- Foundation bookmarks;
- security-scoped bookmarks;
- mount/unmount notifications;
- volume rename handling;
- app-activation re-resolution;
- capacity APIs;
- privacy manifest changes;
- archive-unavailable user messaging;
- read-only external archive state;
- relocation copy engine;
- relocation journal;
- migration progress UI;
- Move/Locate/Restore actions;
- old-copy deletion;
- checkpoint redesign;
- production archive relocation;
- any live move of Rob's attachment archive.

Do not touch the real MessageLens Application Support data.

---

# Guardrails

The audit establishes these invariants. Preserve them:

- no symlink-based architecture;
- no database/schema migration;
- no absolute active-root persistence in attachment rows;
- no deletion of attachment preservation data;
- no reset authority over an external archive;
- no archive scan on startup/search;
- no silent fallback behaviour;
- no widening of `ArchiveAccessAuthority` to arbitrary external locations.

Although some of these become operationally important in later phases, Phase 1 must not establish architecture that makes them difficult to enforce.

---

# Completion procedure

When Phase 1 is complete:

1. Run `git diff --check`.
2. Run all relevant focused tests.
3. Run the broader test/architecture validation required by project instructions.
4. Confirm there are no schema/migration changes.
5. Confirm no payload files or user databases were accessed or modified.
6. Confirm deliberate unrelated untracked files remain untouched.
7. Confirm the shared instructions submodule remains unchanged unless a repository rule explicitly required an approved documentation change there.
8. Review the full diff for accidental scope expansion.

Do not commit the Phase 1 implementation until reporting the results to me for review, unless repository instructions explicitly require commits during feature work.

Report:

- current branch and HEAD;
- audit-document checkpoint commit hash;
- concise implementation summary;
- exact new architecture introduced;
- files changed;
- tests added/changed;
- commands/tests run and results;
- any existing behaviour that had to change;
- any audit assumption disproved by implementation;
- remaining compatibility bridge/debt;
- proposed Phase 2 starting point;
- complete `git status`;
- confirmation that no archive payload or user data was changed.

There’s one detail in the audit I would watch closely during this phase: `ArchiveSettings.build()` currently waits on a recursive stats read, and `AttachmentResolver` in turn waits on `archiveSettingsProvider.future`. Codex identified that as a potential path by which a large archive can cause unnecessary filesystem work. 00\-ARCHITECTURE\-AUDIT\-AND\-IMPLEMENTATION\-PLAN.md

I’ve therefore allowed Phase 1 to separate **cheap location/configuration state** from **expensive statistics** if that falls naturally out of the refactor. I would not insist that Codex solve the entire stats architecture now, but I also wouldn’t want it to reproduce that coupling inside the new location controller.

The overall staged plan remains excellent: Phase 1 creates the seam; Phase 2 adds macOS bookmark/volume identity; Phase 3 makes reads and diagnostics genuinely unavailable-aware; Phase 4 makes writes safe; only Phase 5 actually moves bytes. 00\-ARCHITECTURE\-AUDIT\-AND\-IMPLEMENTATION\-PLAN.md