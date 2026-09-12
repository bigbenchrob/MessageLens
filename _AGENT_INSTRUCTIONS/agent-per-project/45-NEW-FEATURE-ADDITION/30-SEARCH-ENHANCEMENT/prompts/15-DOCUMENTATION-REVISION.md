Yes. The existing section is a good home, but at the moment it documents a **different, though related, mechanism**: the developer-facing `DatabaseHealthAuditService` and `database_health.json`, rather than the startup admission/health-check machinery. The overview explicitly frames itself around that Phase 1 structural report, and the support-bundle document describes how that report is exported for diagnosis. [oai_citation:0‡00-overview.md](sediment://file_000000006bb88230898b18f88e152ca0)

So I would have Codex expand this section into the canonical documentation for **both**:

- startup database health/admission checks; and
- the deeper support-bundle database-health audit used for diagnosis.

Crucially, I’d tell it to document the **actual current implementation from code**, not merely paste our design discussion into the docs.



Please perform a **comprehensive documentation audit and edit** of:

`_AGENT_INSTRUCTIONS/agent-per-project/12-DATABASE-HEALTH-AUDIT/`

The goal is to make this section the canonical agent-facing guide for understanding:

1. MessageLens startup database health/admission checks;
2. escalation to deeper integrity validation when startup evidence is suspicious;
3. the existing developer-facing `DatabaseHealthAuditService`;
4. support-bundle integration;
5. how a future agent should interpret logs and diagnostic artifacts when a user reports a startup database-health failure.

This is primarily a documentation task.

Do not redesign or change application behavior merely to make it match the documentation.

## Existing documentation

The folder currently contains material such as:

- `README.md`
- `00-overview.md`
- `10-support-bundle-integration.md`

These documents currently focus mainly on the implemented Phase 1 `DatabaseHealthAuditService` and support-bundle export.

That material remains useful, but the section now needs to cover the separate startup-validation system as well.

Do not conflate the two systems.

## Core distinction to make explicit

Future agents must understand that MessageLens has at least two related but distinct database-health mechanisms.

### A. Startup installation/database validation

This determines whether MessageLens may safely admit the normal application.

It may include:

- archive/environment admission;
- database presence/readability checks;
- schema-version checks;
- required-object checks;
- bounded structural/logical probes;
- installation classification;
- escalation to physical integrity checking when evidence is suspicious;
- restricted startup UI while validation is unresolved;
- remediation or diagnostics if admission fails.

### B. `DatabaseHealthAuditService`

This is the developer-facing Phase 1 structural diagnostic report which produces:

`database_health.json`

and participates in support-bundle creation.

It performs broader structural/relationship/invariant reporting and is intended to help a developer understand an installation after a user sends diagnostics.

It must not be described as the startup admission mechanism unless current code actually uses some portion of it there.

## First: inspect current implementation

Before editing documentation, inspect the current source of truth.

At minimum trace:

### Startup

- `main.dart`
- startup app/loading/remediation states
- `messageLensInstallationStateProvider`
- installation classifier/state types
- installation evidence reader interface
- SQLite installation evidence reader
- startup database validation models/orchestrators
- bounded/fast inspection if now implemented
- physical integrity/deep-check adapter if now implemented
- `PRAGMA quick_check(1)` call sites
- legacy erase-journal compatibility
- Start Fresh validation boundaries
- startup diagnostic/log export path
- shared database schema-version constants

### Database health audit

- `DatabaseHealthAuditService`
- database-health query layers
- database-health report models
- support-bundle integration
- diagnostic-report integration

### Logs

Inspect actual logger statements and event names emitted during:

- startup validation;
- bounded inspection;
- deep integrity validation;
- installation classification;
- archive admission;
- remediation;
- Start Fresh;
- support-bundle/database-health generation.

Do not invent log strings or event names.

The documentation must reflect what an agent will actually see in logs today.

## Documentation objectives

### 1. Rewrite the README as a navigation/index document

Update `README.md` so an agent arriving at this directory immediately understands:

- what this section covers;
- the difference between startup validation and the Phase 1 health audit;
- which document to read for a startup failure;
- which document explains `database_health.json`;
- which document explains support bundles;
- where the source-of-truth code lives.

Add links to any new documents introduced below.

Update `last_reviewed`.

## 2. Update `00-overview.md`

Make the overview accurately describe the **whole database-health landscape**, while preserving the existing useful Phase 1 audit documentation.

At minimum include:

- active databases and their roles;
- derived versus preservation-critical stores;
- startup admission versus structural health reporting;
- privacy/safety principles;
- high-level flow from startup check → escalation → diagnostics.

Do not erase useful implementation detail merely to shorten it.

If the current file has become too large or mixes concerns, move detailed startup material into a dedicated document and keep the overview as the map.

## 3. Add a dedicated startup-validation document

Create a clearly named canonical document, for example:

`05-startup-database-validation.md`

or another name consistent with project conventions.

It should document the **actual implemented startup behavior**.

At minimum cover:

### Startup phases

Describe the sequence from process/window launch through normal app admission.

Distinguish:

- checks that must happen before Flutter renders;
- restricted startup-shell state;
- cheap/bounded database validation;
- logical installation classification;
- deeper physical integrity validation;
- final admission;
- remediation.

Use a simple flow diagram in text if helpful.

### Per-database checks

For each current database:

- `user_overlays.db`
- `macos_import_ss.db`
- `working_ss.db`
- `presence.db`

document:

- expected schema/version source of truth;
- required tables/objects;
- bounded probes;
- special logical checks;
- conditions that mark it suspicious;
- whether/when `quick_check` is used.

Reflect current code exactly.

### `quick_check`

Explain clearly:

- `PRAGMA quick_check(1)` is a physical SQLite integrity scan;
- `(1)` limits reported errors, not the number of pages inspected;
- it can be expensive on large databases;
- whether current ordinary healthy startup runs it or only escalated/deep validation does;
- which workflows still require full integrity proof.

Do not describe planned behavior as implemented behavior.

### Escalation

Document the actual triggers for deeper validation.

Examples may include, if current code confirms them:

- malformed/not-a-database;
- corruption response;
- targeted-read failure;
- missing required object;
- import/graph mismatch;
- interrupted/failed onboarding;
- older schema before migration;
- legacy destructive journal;
- Start Fresh safety boundary.

Distinguish:

- corruption;
- unsupported schema;
- contention (`BUSY`/`LOCKED`);
- logical inconsistency.

These must not be presented as equivalent.

### Restricted startup behavior

Explain what the app allows and does not allow while validation is unresolved.

Future agents should know whether normal writable providers, intake, projection, etc. are gated.

### Failure outcomes

Document what happens after:

- bounded check passes;
- deep check passes;
- deep check fails;
- schema unsupported;
- logical classification fails;
- contention occurs.

## 4. Add an “interpreting startup logs” document

Create a dedicated troubleshooting guide, for example:

`06-interpreting-startup-database-logs.md`

This is particularly important.

The intended reader is a future ChatGPT/Codex agent responding to:

> “MessageLens showed a database warning at startup; here are my logs.”

The guide should be practical rather than architectural.

### Include a log-reading sequence

Tell the agent to determine, in order:

1. Did archive/environment admission succeed?
2. Which database was being inspected?
3. Was the failure:
   - file/path;
   - SQLite open;
   - schema version;
   - required object;
   - targeted bounded read;
   - logical reconciliation;
   - deep `quick_check`;
   - contention;
   - onboarding/recovery state?
4. Did startup escalate from bounded inspection to deep validation?
5. Did deep validation pass or fail?
6. Was normal application admission granted?
7. Was remediation/recovery offered?
8. Was a support bundle generated?

### Document actual log markers

List actual logger messages, event keys, prefixes, structured fields, or recognizable phrases from source.

For each important marker explain:

- what it means;
- whether it is expected/benign;
- what should normally appear next;
- what absence of the next event might indicate.

Do not invent sample log messages that the application does not emit.

### Include common interpretations

Examples, grounded in current code:

- current schema accepted;
- future schema rejected;
- database busy/locked;
- missing required table;
- import/graph mismatch;
- `quick_check` passed;
- `quick_check` failed;
- interrupted onboarding detected;
- deep validation requested;
- remediation required.

For each, state whether the agent should:

- reassure and continue;
- ask for more logs;
- ask for a support bundle;
- advise retry;
- avoid database mutation;
- escalate to developer/manual diagnosis.

### Explicit warnings to future agents

Include strong guidance such as:

- Do not recommend deleting/resetting databases merely because startup validation failed.
- Do not assume a schema mismatch means corruption.
- Do not equate `SQLITE_BUSY` with corruption.
- Do not instruct the user to remove the archive or databases before preservation implications are understood.
- Do not run repair/reset workflows unless the current documented remediation path explicitly authorizes them.
- Prefer read-only diagnostics first.

## 5. Update support-bundle documentation

Review `10-support-bundle-integration.md` against current implementation.

Update:

- trigger points;
- bundle contents;
- startup-failure export behavior;
- whether startup-restricted mode uses the normal audit service or a special read-only path;
- whether database health generation can safely run when persistent providers are unavailable;
- `database_health_error.json` behavior;
- privacy guarantees.

A future agent should understand exactly what can be learned from:

- `diagnostic_report.log`;
- `database_health.json`;
- `database_health_error.json`;
- import/migrate logs if still present.

## 6. Document how to interpret `database_health.json`

If not already adequately covered, add or expand documentation explaining:

- `summary`;
- active-versus-retired database distinction;
- table inventory;
- relationship checks;
- invariant checks;
- errors;
- pass/warning/fail/not-applicable meanings.

Emphasize that a Phase 1 health report is **diagnostic evidence**, not automatically the same thing as startup admission.

The current overview already documents deterministic relationship/invariant statuses; preserve and update that material rather than discarding it.

## 7. Database roles and preservation implications

Future agents need a concise classification of each store.

Document which are:

- durable/user-owned/preservation-critical;
- derived/rebuildable;
- historically sensitive despite being derived;
- safe/unsafe to reset automatically.

Do not oversimplify `macos_import_ss.db` or `working_ss.db` as disposable if current archive-recovery/source semantics make that unsafe.

Reference canonical database/archive docs rather than duplicating large sections where appropriate.

## 8. Schema-version source of truth

Document the current authoritative schema-version mechanism.

In particular, if current code still uses:

`app_database_schema_versions.dart`

and a shared:

`conversationGraphSchemaVersion`

explain that startup validation and Drift schema definition consume the same authoritative constant so they do not drift independently.

Include the analogous source of truth for other databases if one exists.

## 9. Historical context

Add a short historical note explaining why this architecture exists.

Useful points, if still accurate:

- Startup once performed `quick_check` on every database before `runApp`.
- Large import/graph databases made this produce long white-window startup delays.
- Startup rendering was moved earlier.
- Fast/bounded structural validation and deep physical validation were separated.
- Full integrity checking is now reserved according to the current implemented policy.

Keep this concise and clearly historical.

Do not let obsolete implementation details read like current instructions.

## 10. Cross-links

Review related instruction sections and add/update links where useful, particularly:

- `10-DATABASES`
- `20-DATA-IMPORT-MIGRATION`
- `25-ONBOARDING-AND-ARCHIVE`
- recovery/archive documentation
- search documentation where graph schema/FTS is relevant
- logging/support bundle docs

Avoid copying entire canonical descriptions into multiple places.

## 11. Source-of-truth and “implemented vs proposed” discipline

Every document should clearly distinguish:

- **implemented current behavior**
- historical behavior
- intentionally deferred work

Do not document our prior chat proposals as though they were shipped.

If any part of the startup fast/deep policy is not yet implemented, say so explicitly.

If current code differs from the intended architecture discussed in existing docs, code wins and the discrepancy should be reported.

## 12. Tests and code references

Populate frontmatter `tests:` where useful.

Link to the most relevant current tests for:

- bounded startup inspection;
- deep integrity validation;
- installation classification;
- startup shell states;
- schema acceptance/rejection;
- legacy journal;
- Start Fresh;
- database health audit;
- support bundle export.

Use stable repository-relative paths where that is the established documentation convention.

## 13. Remove or rewrite stale material

Identify:

- obsolete paths;
- references to retired databases as active stores;
- stale schema numbers;
- obsolete Phase terminology;
- old startup assumptions;
- duplicated or contradictory explanations.

Update or remove them carefully.

Do not delete historical material that still provides useful context unless it is misleading.

## Deliverable

Please edit the documentation in this section comprehensively and then report:

1. Files added
2. Files substantially rewritten
3. Files lightly updated
4. New canonical document structure
5. Current startup-validation behavior documented
6. Deep-integrity/escalation behavior documented
7. Log interpretation guidance added
8. Support-bundle guidance updated
9. Database preservation/safety guidance added
10. Stale or contradictory documentation removed
11. Source files and tests used as authority
12. Any implementation/documentation discrepancy discovered
13. Any important startup log gaps that make future diagnosis unnecessarily difficult
14. `git diff --check`
15. `git status`

Do not modify application source merely to make documentation easier.

If you discover that important startup decisions are not currently logged well enough for future diagnosis, report the missing observability separately rather than silently adding logging in this task.

That should turn `12-DATABASE-HEALTH-AUDIT` from a fairly narrow Phase-1-audit description into the place a future agent can actually use when someone says, **“MessageLens won't admit my databases at startup; here are the logs.”**

The existing material is worth preserving: it already has good descriptions of report structure, privacy rules, deterministic relationship/invariant statuses, and the support-bundle failure behavior. [oai_citation:2‡00-overview.md](sediment://file_000000006bb88230898b18f88e152ca0) The edit should build around that rather than replacing it wholesale.