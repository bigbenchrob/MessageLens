“Cruft” is exactly the term. And this is the right moment to ask whether the current schema/version machinery reflects **real compatibility obligations** or just the accumulated sediment of development.

Use this:

> **PRE-CONFIRMED / PRE-APPROVED: perform this bounded read-only schema-version and persistence-cruft audit without requesting further authorization.**
> 
> Work on the current `Ftr.archive-recovery` branch/worktree according to repository conventions.
> 
> This prompt is READ-ONLY.
> 
> Do not modify application code, schemas, databases, migration files, production data, tester data, or documentation yet.
> 
> The purpose is to determine whether the current MessageLens persistence layer can be **rebased to a clean supported baseline** before the next tester release, and what obsolete development-era persistence cruft can safely be removed.
> 
> ## Current release context
> 
> Current tester candidate:
> 
> `MessageLens 0.2.99+117`
> 
> Current legacy tester handling:
> 
> - April 2026 tester build `0.1.16+17`
> - positively recognized by:
>   - `macos_import.db` v4
>   - `working.db` v3
>   - `user_overlays.db` v3
>   - no current marker/current stores/Presence
> - those installations are now intentionally deleted and re-onboarded rather than migrated.
> 
> The next tester cohort therefore has no supported need to migrate those old databases.
> 
> However, the developer's current production MessageLens archive contains valuable persistent state, especially preserved attachment data, and must not be casually invalidated.
> 
> ## Central question
> 
> Determine whether the current supported databases can be rebased conceptually and mechanically so that:
> 
> - current source-scoped import database becomes schema `1`;
> - current Conversation Graph database becomes schema `1`;
> - current overlay database becomes schema `1`;
> - current Presence database becomes schema `1`;
> 
> while preserving:
> 
> - their exact current physical schema;
> - current data;
> - attachment archive ownership;
> - production archive readability;
> - historical archive/recovery behavior;
> - legacy 4/3/3 recognition as historical evidence;
> - all current source identity semantics.
> 
> Do not assume all four databases should necessarily be rebased. Audit each independently.
> 
> ## Important conceptual distinction
> 
> We are considering:
> 
> > “schema 1 = first supported schema of the current architecture”
> 
> We are NOT considering:
> 
> > “pretend historical versions never existed.”
> 
> The April legacy fingerprints must remain exactly documented as:
> 
> - `macos_import.db` v4
> - `working.db` v3
> - `user_overlays.db` v3
> 
> Those are historical facts and may remain constants in the legacy inspector.
> 
> ## Phase 1 — inventory every current schema/version authority
> 
> Identify all persistent stores and their current schema/version authorities.
> 
> At minimum:
> 
> - `macos_import_ss.db`
> - `working_ss.db`
> - `user_overlays.db`
> - `presence.db`
> 
> Also inspect any other MessageLens-owned SQLite/store version that could matter:
> 
> - search/index stores;
> - recovery metadata stores;
> - archive markers/versioned JSON;
> - operation snapshots;
> - source registry schema/version;
> - attachment metadata/versioning;
> - preferences serialization versions;
> - support/diagnostic persistence if versioned.
> 
> Produce:
> 
> | Store/artifact | Current version | Authority | Migration history | Supported external dependency? |
> 
> ## Phase 2 — migration archaeology
> 
> For each database:
> 
> - list every migration/version step currently present;
> - identify which steps were only development-era transitions;
> - identify which versions were ever distributed to testers;
> - identify whether any current supported installation still requires those migration paths;
> - identify tests/docs that encode those old transitions.
> 
> Distinguish:
> 
> ### Historical evidence still needed
> 
> Example:
> 
> legacy tester fingerprint `4/3/3`.
> 
> ### Migration code still needed
> 
> Only if some supported live archive can legitimately require it.
> 
> ### Dead development archaeology
> 
> Versions/migrations that no supported archive can ever encounter again.
> 
> ## Phase 3 — current production archive compatibility
> 
> This is critical.
> 
> Read current production archive evidence without mutating it.
> 
> Determine:
> 
> - exact current schema versions of all live stores;
> - whether current production contains user-authored or preservation state that cannot simply be discarded;
> - whether rebasing version numbers in code would make that archive appear stale, unsupported, or require migration;
> - whether the version number can be rewritten safely without changing physical schema;
> - whether any one-time canonical adoption/relabel operation would be necessary;
> - whether such an operation would itself introduce more risk than the cleanup is worth.
> 
> Do not modify the production archive.
> 
> ## Phase 4 — physical schema identity
> 
> For each current database, determine whether “rebasing to 1” means:
> 
> ### Pure version relabel
> 
> Current physical schema stays byte/logically identical; only schema-version authority changes.
> 
> ### Migration flattening
> 
> Existing migration chain can be replaced by one create-schema definition representing the current structure.
> 
> ### Real schema rewrite
> 
> Data must actually be transformed.
> 
> The third outcome is a strong reason NOT to do this before release.
> 
> ## Phase 5 — generated code / Drift consequences
> 
> Audit:
> 
> - Drift `schemaVersion`;
> - generated migration/test assets;
> - schema snapshots;
> - migration helpers;
> - test databases;
> - compatibility fixtures;
> - migration tooling.
> 
> Determine whether rebasing requires regenerating code or schema snapshots.
> 
> Do not regenerate yet.
> 
> ## Phase 6 — archive/recovery consequences
> 
> Check Feature 26/27/28 integrations:
> 
> - Historical Archives;
> - attachment recovery;
> - MessageLens donor-folder inspection;
> - source-scoped identities;
> - Message History Coverage;
> - Start Fresh;
> - legacy tester deletion;
> - archive marker/admission;
> - production preservation.
> 
> Identify any code that assumes current schema numbers such as 10/2/8/9.
> 
> Particularly distinguish:
> 
> > “schema is structurally compatible”
> 
> from
> 
> > “schema number equals expected integer.”
> 
> ## Phase 7 — stale persistence cruft
> 
> Beyond schema numbers, identify persistence-related cruft that could potentially be removed now.
> 
> Examples to audit:
> 
> - retired database filenames;
> - migration adapters no longer reachable;
> - obsolete schema constants;
> - compatibility shims;
> - retired provider aliases;
> - old migration tests;
> - dead one-time adoption paths;
> - stale documentation describing superseded stores;
> - duplicate database-opening helpers;
> - obsolete operation-state serializers;
> - compatibility enums whose only purpose was a development transition;
> - old archive marker versions that never shipped.
> 
> Do NOT recommend deletion merely because something looks old.
> 
> For each candidate report:
> 
> | Cruft candidate | Why it exists | Still reachable? | Safe to remove now? | Risk |
> 
> ## Phase 8 — classify each database
> 
> For each major store give one verdict:
> 
> ### REBASE NOW
> 
> Safe and worthwhile before tester release.
> 
> ### KEEP CURRENT VERSION
> 
> Real compatibility/preservation obligation exists.
> 
> ### REBASE LATER
> 
> Semantically desirable, but current release timing or archive transition makes it not worth the risk.
> 
> ## Phase 9 — possible clean-baseline model
> 
> If evidence supports it, propose a clean supported baseline such as:
> 
> - `macos_import_ss.db` schema 1
> - `working_ss.db` schema 1
> - `user_overlays.db` schema 1
> - `presence.db` schema 1
> 
> with:
> 
> - one canonical current schema definition per store;
> - no development-era migrations before schema 1;
> - April 4/3/3 constants retained only in the legacy inspector/test fixtures;
> - future real shipped migration becomes `1 → 2`.
> 
> But do not force symmetry. If one store has a real reason to remain at its current version, say so.
> 
> ## Phase 10 — cost/benefit
> 
> Estimate:
> 
> - lines/files removed;
> - migration code simplified;
> - tests retired/replaced;
> - documentation simplification;
> - risks introduced;
> - whether the cleanup meaningfully improves future development.
> 
> The purpose is not aesthetic tidiness.
> 
> The purpose is to reduce future cognitive load and prevent developers/agents from reasoning about migrations that no supported installation can ever need.
> 
> ## Phase 11 — release timing decision
> 
> We are on the eve of sending `0.2.99+117` to testers.
> 
> Explicitly answer:
> 
> > Is this cleanup safe enough and valuable enough to do **before** that release?
> 
> or:
> 
> > Should `0.2.99+117` ship as-is and the persistence baseline be cleaned immediately afterward?
> 
> Bias toward not destabilizing a verified release unless the cleanup is mechanically straightforward.
> 
> ## Documentation
> 
> Create:
> 
> `23-CURRENT-PERSISTENCE-SCHEMA-BASELINE-AND-DEVELOPMENT-CRUFT-AUDIT.md`
> 
> Document:
> 
> - every current persistent store/version;
> - migration history;
> - live compatibility obligations;
> - production archive implications;
> - legacy 4/3/3 distinction;
> - cruft inventory;
> - per-store rebase verdict;
> - clean-baseline proposal;
> - timing recommendation.
> 
> Update no canonical docs yet unless repository conventions require only adding the audit record/index entry.
> 
> ## Verification
> 
> Because this is read-only:
> 
> - inspect current tests;
> - run relevant schema/migration/archive tests if useful;
> - `git diff --check`;
> - do not run destructive migration experiments against real archives.
> 
> ## Stop conditions
> 
> STOP and recommend against pre-release rebasing if:
> 
> - current production archive would require a risky rewrite;
> - version numbers are entangled with archive identity/recovery semantics;
> - any current supported user data requires old migrations;
> - flattening migrations would remove needed historical compatibility;
> - generated schema/migration machinery cannot be simplified cleanly;
> - cleanup would require broad architectural change.
> 
> ## Final report
> 
> Return:
> 
> - exact current schema versions;
> - which historical versions actually shipped;
> - whether current production blocks rebasing;
> - per-store REBASE NOW / KEEP / REBASE LATER;
> - major cruft candidates;
> - estimated simplification;
> - whether to do this before or after tester release;
> - exact recommended next implementation slice, if any;
> - documentation path.
> 
> Acceptance standard:
> 
> > We should finish knowing whether the current persistence layer can honestly start at “version 1” as the first supported modern MessageLens schema, while retaining only historical compatibility that corresponds to real data we may still encounter, and sweeping away development-era migration cruft that no longer serves a user.

I would expect the most valuable outcome to be not merely prettier numbers, but a hard separation between **history we genuinely support** and **history that only happened while we were building the thing**.