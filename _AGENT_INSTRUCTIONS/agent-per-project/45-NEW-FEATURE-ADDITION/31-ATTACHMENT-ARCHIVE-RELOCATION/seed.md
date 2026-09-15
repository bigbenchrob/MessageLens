Absolutely. I’d make the first prompt explicitly **audit-only** and have Codex create the feature folder, document the current architecture, identify every coupling to the archive’s present location, and propose a migration design without changing production code yet.



We are beginning a new MessageLens feature investigation.

Create a new feature-development folder:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/`

This first phase is a **read-only architecture audit and implementation-planning exercise**.

Do not change production code, schemas, migrations, application behaviour, or user data yet, except for creating documentation inside the new feature folder.

## Objective

We want to evaluate and design support for relocating MessageLens's `attachment_archive` directory away from the main Application Support MessageLens data folder and onto a user-selected external drive.

The immediate motivation is storage pressure on the Mac's internal SSD: the current attachment archive is approximately 39 GB and will continue to grow.

The desired long-term architecture is that the attachment archive's physical location becomes configurable rather than intrinsically tied to the main MessageLens data directory.

The rest of MessageLens data may remain in its existing Application Support location.

MessageLensDevelopment already runs successfully with its data folder on an external drive, so external-storage performance itself is not expected to be a major concern. This feature should nevertheless preserve normal conversation browsing, searching, indexing, and startup performance when the attachment archive is external.

## Core design principles to investigate

The likely desired model is:

- Main MessageLens databases and latency-sensitive application state remain where they currently live.
- `attachment_archive` may reside either:
  - in the existing default location, or
  - in a user-selected external location.
- The application explicitly understands the configured attachment archive location.
- The application explicitly understands the state in which the configured external volume is temporarily unavailable.
- A missing/unmounted archive must **not** be interpreted as deleted or corrupt attachment data.
- Message browsing and searching should remain usable while the archive is unavailable.
- Attachment access should recover automatically when the external volume becomes available again.
- We should not rely on a filesystem symlink as the permanent application architecture.
- If attachment records currently persist absolute paths, investigate whether archive-relative paths plus a configurable archive root would be a superior model.
- Any migration of existing archive contents should be conservative, verifiable, and recoverable.

## Audit the current implementation

Trace the complete lifecycle of `attachment_archive`.

Identify:

1. Where its filesystem path is currently defined or derived.
2. Every place that assumes the archive is a child of the MessageLens Application Support/data directory.
3. Where attachment files are written into the archive.
4. Where attachment files are read from the archive.
5. Where archive paths or filenames are persisted in Drift, SQLite, preferences, metadata, caches, manifests, indexes, or other storage.
6. Whether persisted attachment references are:
   - absolute paths,
   - paths relative to the archive root,
   - paths relative to some broader application-data root,
   - filenames/IDs that are later resolved into paths,
   - or some mixture of these.
7. Whether archive paths participate in equality, deduplication, hashing, identity, cache keys, indexes, tests, or validation.
8. What startup/installation/database validation currently assumes about the archive's presence.
9. Whether any repair, migration, rebuild, cleanup, garbage-collection, integrity-checking, or import process treats a missing archive or missing files as corruption/deletion.
10. Whether attachment rendering/loading code accesses files directly or through an abstraction that could naturally accept a configurable archive root.
11. Whether attachment thumbnails/previews/caches depend on the archive's absolute location.
12. Whether any tests encode the current archive location.
13. Whether MessageLensDevelopment and production MessageLens already differ in how their data roots are selected, and whether any existing abstraction can be reused.

## macOS storage/access model

Investigate the application's current sandbox, entitlement, distribution, and filesystem-access model.

In particular determine:

- whether MessageLens is currently sandboxed;
- what filesystem entitlements it has;
- how it presently obtains access to user-selected external folders;
- whether persistent access to a user-selected external archive would require a security-scoped bookmark;
- whether existing project code already has a reusable implementation for security-scoped bookmarks or persisted external-folder access;
- how recent macOS privacy/storage permission behaviour affects this design;
- what happens across application relaunch, Mac restart, drive disconnect/reconnect, drive rename, or mount-path change;
- whether volume identity/bookmarks should be preferred over persisting a raw `/Volumes/...` path.

Do not invent a new mechanism if the repository already contains one that can be reused.

## External archive unavailable state

Audit the current code paths and identify exactly what would happen today if `attachment_archive` suddenly disappeared while the databases remained present.

Design the desired behaviour for at least these cases:

- external drive not connected at launch;
- drive disconnected while MessageLens is running;
- drive reconnected while MessageLens remains running;
- configured archive directory deleted;
- archive volume mounted under a changed path;
- user revokes filesystem permission;
- individual attachment file missing while archive itself is accessible;
- archive readable but not writable;
- insufficient space during an archive move.

The important distinction is:

**archive unavailable** must remain semantically different from **attachment file known to be missing/corrupt**.

Determine where that distinction should live architecturally.

## Relocation workflow

Propose a safe user-facing relocation workflow.

Our current preference is approximately:

1. User chooses `Move Attachment Archive…`.
2. User selects a destination folder/volume.
3. MessageLens validates access and available capacity.
4. Existing archive is **copied**, not destructively moved.
5. Copy is verified.
6. MessageLens switches the configured archive root.
7. MessageLens verifies that attachments can be resolved from the new location.
8. Only after successful switchover is the old archive eligible for deletion.
9. Ideally the user is given a deliberate final choice about removing the old archive.

Investigate what verification is practical using existing archive metadata.

Consider:

- file count;
- byte totals;
- per-file size;
- hashes, if already available;
- database-known attachment records;
- archive manifests, if any;
- partial/interrupted copies;
- resumption versus restart;
- rollback if switchover fails.

Do not add expensive hashing unless there is a compelling reason or suitable integrity data already exists.

## Configuration model

Recommend where the configured archive location should be stored.

Consider whether the model should contain concepts such as:

- default/internal archive;
- custom/external archive;
- archive root;
- security-scoped bookmark;
- last-known path for display/debugging;
- availability status;
- writable/read-only status.

Do not prematurely add database schema if preferences/configuration are more appropriate.

Also identify whether the archive location is machine-specific rather than part of portable MessageLens data. If so, make that explicit.

## Path architecture

If the current system stores absolute archive paths, investigate a migration toward a location-independent representation.

For example:

`attachment_archive/ab/cd/file.heic`

or an archive-relative equivalent may be preferable to:

`/Users/.../Application Support/.../attachment_archive/ab/cd/file.heic`

Do not assume that this is necessarily required. First determine how the current implementation actually works.

If a path migration would be required, identify:

- affected tables/fields;
- row counts or likely migration scale;
- whether migration can be lazy;
- backwards-compatibility concerns;
- rollback considerations;
- whether any existing path-normalization abstraction can be extended instead.

## Performance

Identify which operations touch the archive during:

- startup;
- conversation-list rendering;
- message timeline construction;
- search;
- attachment display;
- attachment import;
- integrity checking;
- rebuild/migration processes.

We want archive relocation to have effectively no impact on ordinary message browsing/search when attachments are not being opened.

Call out any existing code that unnecessarily scans or stats large portions of the archive and would become more noticeable on external storage.

## UI considerations

Do not implement UI yet, but propose how this could fit into existing MessageLens settings/preferences architecture.

A likely conceptual presentation would be something like:

`Attachment archive`
`/Volumes/MessageLens Data/MessageLens/attachment_archive`

with actions such as:

- `Move…`
- perhaps `Reveal in Finder`
- perhaps `Restore Default Location`

And when unavailable:

`Attachment archive unavailable`
`The external volume containing your attachment archive is not currently available. Messages and search remain available.`

Evaluate this against existing UI patterns and reuse existing settings components wherever possible.

## Reuse-first requirement

This is important.

Before proposing any new service, repository, provider, path abstraction, settings mechanism, status model, permission mechanism, or UI component, search the repository for an existing implementation that can be extended.

We want to reuse:

- existing application-data-root abstractions;
- existing attachment repositories/services;
- existing external-folder/file-picker infrastructure;
- existing macOS bookmark/security-scope infrastructure;
- existing settings persistence;
- existing startup state machinery;
- existing unavailable/degraded-state UI;
- existing progress/copy infrastructure;
- existing integrity validators;
- existing notification/error presentation;
- existing tests and fixtures.

Explicitly distinguish:

- components that can be reused unchanged;
- components that can be extended;
- genuinely new components that appear necessary.

## Deliverables

Create documentation in:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/`

At minimum produce an audit/report document containing:

### 1. Current architecture
How attachment archive storage works today.

### 2. Path/reference model
Exactly how archive files are identified and persisted.

### 3. Coupling inventory
Every important assumption that ties the archive to the current data directory.

### 4. macOS access findings
Sandbox, entitlements, external-folder persistence, security-scoped bookmark requirements, and existing reusable infrastructure.

### 5. Failure-state analysis
Current and desired behaviour when the archive or external volume is unavailable.

### 6. Reuse inventory
Existing project elements that should be reused rather than replaced.

### 7. Recommended architecture
A concrete proposed architecture for a relocatable attachment archive.

### 8. Migration strategy
How an existing internal archive could safely be moved.

### 9. UI proposal
High-level settings/status workflow, using existing MessageLens patterns.

### 10. Risks and edge cases
Including disconnects, permissions, partial copies, stale paths/bookmarks, insufficient space, and rollback.

### 11. Implementation phases
Break the future implementation into small, independently testable stages.

### 12. Testing plan
Unit, integration, filesystem, macOS-specific, migration, and failure-state tests.

## Important constraints

- This is an audit/design phase.
- Do not modify production code.
- Do not alter schemas.
- Do not run migrations against user databases.
- Do not move or modify the real attachment archive.
- Do not introduce a symlink as the proposed permanent architecture.
- Do not duplicate existing infrastructure unnecessarily.
- Trace actual code rather than inferring architecture from filenames.
- Include file paths and relevant symbols/classes/functions in the report so subsequent agents can navigate directly to them.
- Flag any areas where the repository contradicts the assumptions in this prompt.

At the end, give me:

1. a concise executive summary;
2. the recommended architecture;
3. the most important reuse opportunities;
4. the major risks;
5. the proposed implementation phases;
6. the exact documentation files created;
7. confirmation that no production code or user data was changed.

Once Codex brings back that audit, I’d treat its **reuse inventory** and its answer to **“how are attachment references persisted today?”** as the two most important findings before we write the implementation prompt.