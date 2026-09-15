Preparation is complete, with no file edits made.

## Repository state

- Created and switched to `feature/attachment-archive-relocation`
- Branch point: `c2f546dc99eb50c66233ef94ddb0e70c7d77990e`
- `feature/link-preview-search` remains unchanged at the same commit
- Tracked worktree is clean
- Shared instructions submodule is clean at `95326f515ef4719f155ce6e223990398daad6311`
- The three deliberate untracked files remain untouched

## Architecture findings

The attachment archive is currently coupled to the main admitted application-data root through [persistent_database_providers.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/db/feature_level_providers/persistent_database_providers.dart). `attachmentArchiveDirectoryProvider` resolves `attachment_archive` beneath that root.

The good news is that the stored attachment identity is already relocation-friendly:

- `user_overlays.db` stores `archive_relative_path`, content hash, size, and provenance.
- It does not store the current archive root as part of attachment identity.
- Absolute archive paths are assembled transiently at read time.
- Therefore, relocating payload files should require no database schema or row migration.

Other important findings:

- Message browsing and text search do not inherently depend on archive availability.
- The existing file installer already provides hashing, destination-side verification, bounded paths, and atomic no-overwrite installation.
- The current resolver cannot distinguish “external archive unavailable” from “this payload is missing.”
- Integrity checks could falsely report every attachment as missing while a volume is disconnected.
- The current writer can create a missing directory. That is unsafe for an unavailable mount because it could create a replacement directory at the expected mount path.
- Archive statistics recursively scan the entire physical archive; this must not become a routine availability check.
- The old export helper is an unverified recursive copy and is not suitable for relocation.
- The production checkpoint currently assumes `attachment_archive` lives beneath the primary data root. Moving it externally changes backup/checkpoint coverage and must be addressed explicitly.
- A legacy recovery writer bypasses the canonical installer and must be migrated or retired before switching roots.
- The app is currently unsandboxed. Persistent security-scoped access is therefore not required today, but a normal Foundation bookmark remains useful for volume rename and mount-path changes. A future sandboxed build would require the user-selected entitlement and security-scoped bookmark lifecycle. [Apple file-access guidance](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox)

## Recommended architecture

- Keep `ArchiveAccessAuthority` responsible only for the primary application-data root, databases, locks, and state.
- Introduce a separate attachment-archive location abstraction with:
  - default internal location;
  - configured external location;
  - bookmark data;
  - last-known display path;
  - typed availability and writability state.
- Store the versioned configuration in the existing overlay settings store, avoiding a schema change. Treat it as machine-specific configuration and fail closed if its bookmark cannot be resolved.
- Add a macOS adapter for bookmark creation/resolution and mount, unmount, and volume-rename notifications.
- Never silently fall back from a configured external archive to the internal archive.
- Never create an external archive root unless its selected parent volume has been positively resolved and validated.
- Keep search, conversation browsing, and database access available when the archive is disconnected.
- Report “archive unavailable” separately from “payload missing” and “payload corrupt.”
- On volume reconnection, re-resolve the bookmark and invalidate affected attachment-resolution providers without restarting the app.

Relocation should use a resumable:

> select → preflight → copy → verify → activate → retain old copy

workflow. The source must remain untouched until every unique payload path has been copied and verified. Switching the configuration should be transactional and reversible. Deleting the old archive should be a later, separately confirmed operation—not part of the initial move.

## Hard invariants

- No symlink-based permanent architecture.
- No database, FTS, import, or graph-schema changes.
- No mutation of existing user databases during relocation design.
- No deletion of the source archive during the copy or activation phase.
- No reset/recovery authority over external preservation data.
- No classification of a disconnected archive as corrupt or missing.
- No external-archive scan on application startup or the normal search path.
- Overlay metadata remains authoritative; duplicate rows sharing one content-addressed path must not inflate file-count verification.
- Unreferenced archive payloads must be preserved and inventoried rather than discarded.

## Principal risks to document

- Existing whole-root checkpoint coverage no longer automatically includes external payloads.
- An absent mount path could accidentally be recreated unless writes are strictly gated.
- Provider caches may retain obsolete absolute paths after activation or reconnection.
- Concurrent ingestion must be paused through the existing mutation coordinator during the final snapshot and switch.
- External filesystems may not support the installer’s expected atomic operations; preflight must test the actual destination.
- Large archives need resumable manifests and adequate-space checks, not a one-shot recursive copy.
- macOS capacity APIs may require privacy-manifest declarations.
- Legacy writers and tests contain assumptions that `attachment_archive` is a child of the main root.

## Proposed documentation-only edit

I propose creating exactly one document:

[00-ARCHITECTURE-AUDIT-AND-IMPLEMENTATION-PLAN.md](/Users/rob/Development/FlutterProjects/remember_every_text/_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/00-ARCHITECTURE-AUDIT-AND-IMPLEMENTATION-PLAN.md)

It will contain all twelve requested audit sections, an executive summary, the recommended architecture, reuse inventory, migration state machine, failure taxonomy, UI plan, implementation phases, and test strategy.

This phase will not touch:

- `lib/`, `macos/`, tests, schemas, databases, or archive payloads;
- `pubspec.yaml` or `CHANGELOG.md`;
- the Feature Index;
- any deliberate untracked file.

Afterward I will run documentation-link validation, `git diff --check`, inspect repository/submodule state, and report the complete diff. Per the repository guardrails, I need your explicit approval before creating that document.

::git-create-branch{cwd="/Users/rob/Development/FlutterProjects/remember_every_text" branch="feature/attachment-archive-relocation"}