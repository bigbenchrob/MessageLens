---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: doc
links:
      - ./02-import-migration-schema-reference.md
      - ./10-import-orchestrator.md
      - ./11-rust-message-extractor.md
      - ./12-bounded-message-import-and-rich-text-enrichment.md
      - ./15-table-importers.md
      - ./20-migration-orchestrator.md
      - ./30-incremental-mode-flag.md
      - ../10-DATABASES/00-all-databases-accessed.md
      - ../10-DATABASES/12-identity-model-contacts-handles-participants.md
tests: []
---

# Source Import and Graph Build Overview

This folder contains the current source-scoped graph lifecycle context plus
retired import/projection references. Use it as the starting point
whenever you touch source ingestion, graph projection, archive coordination, or
the Rust attributed-body decoder.

## Current Production Path

Ordinary app data now flows through the source-scoped graph:

```
chat.db + AddressBook.sqlite
            |
            v
   source-scoped import
     macos_import_ss.db
            |
            v
   conversation graph build
      working_ss.db
            |
            v
 Message Evidence Spine + graph readers
            |
            v
 overlay merge at read time
```

The historical `macos_import.db` -> `working.db` projection implementation has
been retired from active app code. Old files remain retired cleanup inventory:
old `macos_import.db` files may contain historical archive-source metadata, old
`working.db` files may be inspected read-only by diagnostics, and neither file
is the ordinary live-sync, archive-source metadata, or user-facing read spine.

## 🔥 Automatic Background Sync

**Graph updates are triggered automatically** - the app polls `chat.db` every **15 seconds** and runs source-scoped import + graph projection when new messages are detected.

| Component | Purpose |
|-----------|---------|
| macOS application-instance authority | Admits one ordinary MessageLens process before Flutter and database providers start; duplicate launches activate the existing app and exit |
| `ChatDbChangeMonitor` | Polls `MAX(ROWID)` from `chat.db`; triggers source-scoped graph build on change |
| Source-scoped graph build lifecycle | Imports source facts into `macos_import_ss.db` and projects canonical graph rows into `working_ss.db` |
| Local-account identity reconciliation | At startup, scans historical Messages account/destination metadata, annotates matching imported handles, and projects only changed `is_me` graph facts without reimporting messages |
| Graph/message data version providers | Bumped after successful graph import/projection so UI providers refresh without closing Drift connections |
| `AttachmentArchiveService` | Orchestrates live graph archive runs and periodic graph sweeps; graph reads, overlay writes, archive settings, and filesystem work remain behind named attachment-feature ports |

**Result:** New messages appear in the UI within ~15-20 seconds of arrival without user action.

See `10-import-orchestrator.md` for current graph-build and
`ChatDbChangeMonitor` orchestration. Use `15-table-importers.md` only for the
deleted retired framework and old-log interpretation.

The monitor remains an orchestration client. Historical local-account
reconciliation is exposed through the Conversation Graph build service and
runs under the same execution authority as other graph mutations; the monitor
must not compose importer and projector internals itself.

## Two Levels of Execution Authority

MessageLens protects derived and user-intent storage at two distinct scopes:

1. **Application-instance authority:** macOS bootstrap acquires an
   application-lifetime advisory lock before constructing the Flutter engine.
   An ordinary duplicate launch cannot reach providers or open application
   databases. It activates the existing same-bundle app when available, then
   exits. The operating system releases the authority when the owning process
   exits or crashes; the lock file by itself carries no authority.
2. **Graph-maintenance execution authority:** once inside the admitted
   process, `GraphMaintenanceExecutionGate` coordinates source import, graph
   build, archive import/removal, and other graph mutations. This Riverpod
   authority is intentionally process-local.

Neither layer replaces the other. The application-instance authority prevents
multiple app processes from independently believing they may write. The graph
maintenance gate decides which orchestrator may mutate derived data inside the
one admitted process.

## Retired Storage Reference Flow

```
old app data folder
        |
        v
retired storage files
macos_import.db / working.db
        |
        v
reset cleanup / health diagnostics / explicit retired-file audit
```

- **Source-scoped import** pulls source facts into `macos_import_ss.db`; graph projection derives canonical `ss_id` rows and topology in `working_ss.db`.
- **Retired import/projection** is historical reference only. If old
  `macos_import.db` or `working.db` contents matter for archive/recovery,
  migrate, export, or intentionally discard that storage evidence through an
  explicit retention task. Do not recreate the old import/projection pipeline.
- **Archive coordination** belongs to the attachment feature, not to
  import/projection. The live graph path archives newly imported source ranges
  after graph build. Historical archive workflows use source-scoped archive
  import and graph projection. Periodic archive sweeps read graph/import facts
  and overlay archive records through named attachment ports; they must not
  consult retired `working.db` files as an attachment authority.
- **Search and message evidence** now select graph `message_ss_id` scopes. Legacy working indexes are not the ordinary search spine.
- **Overlay providers** merge user overrides at runtime; they are documented in `../10-DATABASES/05-db-overlay.md` and operate strictly after graph/import projection.

## Responsibilities

| Concern | Owner | Document |
| --- | --- | --- |
| Source-scoped graph build lifecycle | Conversation graph build controller/services | `10-import-orchestrator.md` |
| Retired table import sequencing, validation, logging | Retired `ImportOrchestrator` docs | `15-table-importers.md` |
| Bounded source-message import, rich-text paging, source-scoped identity, and retry | Source-scoped importer/enricher | `12-bounded-message-import-and-rich-text-enrichment.md` |
| Typedstream decoding and native resource envelope | Rust FFI decoder | `11-rust-message-extractor.md` |
| Retired projection + legacy ID preservation | Retired `MigrationOrchestrator` docs | `20-migration-orchestrator.md` |
| Historical incremental-mode semantics | Retired migrator docs | `30-incremental-mode-flag.md` |
| Retired cleanup schema expectations | Historical schema inventory | `02-import-migration-schema-reference.md` |
| Attachment archive + deterministic recovery | Attachments feature + onboarding/archive docs | `../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md`, `../25-ONBOARDING-AND-ARCHIVE/50-deterministic-recovery.md` |

## Audit Logs

Retired import/projection runs may have written filesystem
audit reports alongside the runtime databases:

- `~/Library/Application Support/com.bigbenchsoftware.MessageLens/import_log`
- `~/Library/Application Support/com.bigbenchsoftware.MessageLens/migrate_log`

Use these only when interpreting older retired runs. Current graph build status,
stage timings, and graph health are surfaced through the Conversation Graph
status panel. Historical logs may capture:

- Source row counts from macOS `chat.db` and AddressBook
- Destination row counts in retired-file `macos_import.db` and `working.db`
- Rich-text extraction stats such as `messages.richTextApplied`
- Message text-presence counts before and after migration
- Source-vs-destination deltas that explain intentional JOIN-driven exclusions

## Current Source Reality: Chat-Orphan Messages

macOS `chat.db` can contain `message` rows that have no corresponding row in `chat_message_join`.

MessageLens now treats these source orphans as a first-class recovery path instead of silently leaving them outside the app's message model.

Current graph-era behavior:

- chat-linked source rows flow into ordinary conversation graph topology
- source orphan rows are preserved as recovered/orphan graph evidence
- recovered rich text and recovered attachment joins remain on that separate path
- projection does not invent normal chat membership for rows Apple no longer links to chats

Audit logs therefore now show both:

- the source orphan count from `chat.db`
- the preserved recovered/orphan graph evidence count

This distinction matters: a source-vs-thread-linked delta is no longer automatically equivalent to app-side invisibility.

## Recovered Context Reconstruction

The app's recovered browsing path deliberately separates **confirmed recovered rows** from **inferred nearby context**.

- confirmed rows are matched by surviving sender identity
- some outbound orphan rows preserve timing/content but lose handle identity
- contact-scoped recovered browsing can conservatively include nearby outgoing no-handle rows as best-guess context

This is an app-side recovery heuristic, not a claim that the source database proved original thread membership. Its purpose is to restore human-readable conversation meaning when Apple's visible thread graph no longer does.

## Operational Guardrails

- **Never bypass the graph build lifecycle.** Manual SQL shortcuts risk breaking
  the source-scoped ID contracts that downstream providers rely on.
- **Never remove or defer the macOS application-instance authority past Flutter
  startup.** Cross-process exclusion must be established before providers can
  open writable application databases.
- **Do not edit ledger tables manually.** Source-scoped import and graph
  projection own derived data; overlay services own user intent.
- **Run graph projection after source-scoped import.** Graph projection is disposable derived data; rebuilding is cheaper than debugging drift.
- **Keep the Rust FFI decoder available.** Active rich-text enrichment uses the
  bundled `attributed_string_decoder` framework. The separately packaged
  `extract_messages_limited` executable is a compatibility interface, not the
  live/archive enrichment path.
- **Keep message and rich-text work bounded.** Preserve frozen high-water
  windows, keyset paging, the 500-record defaults, the 8 MiB decoder-byte
  target and per-record ceiling, per-page transactions, and `ss_id` work keys.
  See `12-bounded-message-import-and-rich-text-enrichment.md`.
- **Do not route live polling through retired import/migration projection.** `ChatDbChangeMonitor` owns source-scoped graph build and graph data-version invalidation.
- **Do not invalidate graph database connections from live polling.** The monitor bumps graph/message data-version providers; active readers should refresh through typed graph/evidence providers.

## Runbook Snapshot

| Action | Command / Trigger | Notes |
| --- | --- | --- |
| **Automatic sync** | Always running | `ChatDbChangeMonitor` polls every 15s; no user action required. |
| Manual graph import + projection | Conversation graph status panel | Only needed for diagnostics or manual catch-up; normal sync is automatic. |
| Headless import | No current documented supported command | Use the app control panels unless a maintained tool is added. Older references to `tool/import.dart` are legacy. |
| Inspect latest source-scoped batch | Query `macos_import_ss.db.import_batches` | Confirms source paths, batch IDs, and row counts for the graph path. |
| Inspect graph status | Conversation graph status panel | Shows source/import/working graph counts, stage timings, and health diagnostics. |
| Retired archive projection rebuild | No active generic retired rebuild path | Design explicit graph-era recovery tooling if this becomes necessary. |

## Related Reading

- `../55-READERS-INTEGRATORS-ORCHESTRATORS/69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md` - Message evidence spine invariant.
- `12-bounded-message-import-and-rich-text-enrichment.md` - Current bounded
  source-message and attributed-body architecture.
- `../10-DATABASES/03-db-address-book.md` and `../10-DATABASES/04-db-chat.md` - Source database expectations.
- `../10-DATABASES/11-contact-to-chat-linking.md` - Verification path for participant linkage after migration.
