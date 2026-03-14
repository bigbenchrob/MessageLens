---
tier: project
scope: inviolate-rules
owner: 10-DATABASES
last_reviewed: 2026-03-13
source_of_truth: doc
tests: []
---

# 🔥 INVIOLATE RULES — Data Integrity & Database Contracts

These rules are **absolute constraints**. They apply to every agent, every session, and every code change — regardless of convenience, velocity, or apparent benefit. Violating any rule below is a **hard failure** equivalent to data corruption.

---

## Rule 1: Overlay / Working DB Separation

> **Canonical doc:** [`07-overlay-database-independence.md`](07-overlay-database-independence.md)

- User intent → overlay DB **ONLY**
- Import/migration → working DB **ONLY**
- Providers merge at read time; overlay wins on conflict
- ❌ NEVER dual-write to both overlay AND working DB
- ❌ NEVER have migration read or consult overlay DB
- ❌ NEVER snapshot overlay before migration then restore into working
- ❌ NEVER store user-intent flags on working tables rebuilt by migration

---

## Rule 2: Record-Level Data Fidelity — NO Suppression of Anomalous Records

> **This is a data-integrity firewall. It exists because an agent once attempted to hide empty-text messages with `SizedBox.shrink()` instead of investigating the root cause. That instinct — "the data looks wrong, let me hide it" — is the single most dangerous thing an agent can do in this codebase.**

### The Contract

**Every record that exists in a source database MUST be faithfully imported, migrated, and rendered.** No record may be silently dropped, filtered, hidden, collapsed, or replaced with a placeholder at any layer of the system — import, migration, projection, or UI — unless the user has explicitly requested that specific filtering behaviour through a dedicated, visible user-facing control.

### What This Means In Practice

1. **Import pipeline**: If a row exists in macOS `chat.db` or the AddressBook, it MUST appear in `import.db`. The importer may flag it, annotate it, or log a warning — but it MUST NOT skip it.

2. **Migration pipeline**: If a row exists in `import.db`, it MUST appear in `working.db` (subject only to documented, intentional JOIN semantics). A migrator may add metadata columns to describe anomalies — but it MUST NOT filter the row out.

3. **UI / Presentation layer**: If a record exists in `working.db` and falls within the user's current query scope, it MUST be rendered visibly. The widget may render it with a fallback appearance (e.g., a muted "no text content" indicator) — but it MUST NOT return `SizedBox.shrink()`, an empty container, zero-height box, or any construct that makes the record invisible.

4. **Providers / data layer**: A provider may enrich, merge, or annotate records — but it MUST NOT silently exclude records that the underlying query returned.

### Forbidden Patterns

| Layer | ❌ Forbidden | ✅ Required Instead |
|-------|-------------|-------------------|
| Importer | `if (text == null) continue;` | Import the row; log that text is null |
| Migrator | `WHERE text IS NOT NULL` filter | Migrate all rows; add audit log entry for null-text count |
| Widget | `if (message.text.isEmpty) return SizedBox.shrink();` | Render an visible indicator: *"(no text content)"* or similar |
| Provider | Filtering out "empty" records before returning list | Return all records; let UI decide how to present them |
| Any layer | Silently swallowing exceptions during record processing | Log the exception and include the record with error metadata |

### Why This Is Non-Negotiable

- **Data loss is invisible.** If 50,000 messages exist in macOS Messages but only 40,000 appear in the app, the user may never notice the discrepancy — until they search for a specific conversation and it's gone.
- **Anomalies are diagnostic signals.** A message with NULL text isn't broken — it may be an attachment-only message, a reaction carrier, a system event, or evidence of an import bug. Hiding it destroys the signal.
- **Suppression masks bugs.** The "empty bubble" that prompted this rule turned out to be a data pipeline issue where message text was being lost during migration. Hiding the symptom would have hidden the bug indefinitely.
- **Users trust completeness.** This application's core promise is that it faithfully preserves the user's messaging history. Silently dropping records breaks that promise.

### The Only Exceptions

1. **Explicit user-facing filter controls** (e.g., "Hide system messages" toggle) where the user consciously chooses to filter — and can reverse that choice.
2. **Pagination / lazy loading** where records exist but are not yet fetched — they MUST become visible when scrolled into view.
3. **Documented, intentional JOIN semantics** in migration where a record cannot be migrated because a required foreign-key target does not exist — these MUST be counted in the audit log.

### When You Encounter Anomalous Data

The correct response is **always investigation, never concealment**:

1. **Log it** — Write a diagnostic entry to the audit log with full details
2. **Render it** — Show the record in the UI, even if imperfectly
3. **Flag it** — If possible, add visual indication that something is unusual
4. **Investigate it** — Trace the record back through migration → import → source to find where the anomaly originated
5. **Fix the root cause** — If the anomaly is a bug, fix the pipeline; don't paper over it in the UI

---

## Rule 3: Database Access Via Centralized Providers Only

- **Import DB**: `ref.watch(importDatabaseProvider)` or `ref.watch(sqfliteImportDatabaseProvider)`
- **Working DB**: `ref.watch(workingDatabaseProvider)` or `ref.watch(driftWorkingDatabaseProvider)`
- ❌ NEVER instantiate `ImportDatabase()` or `WorkingDatabase()` directly
- **Reason**: Multiple connections to the same SQLite file cause locking failures

---

## Enforcement

These rules are enforced by:
- Code review (human and agent)
- Audit logging (`import_log` and `migrate_log` compare source vs destination counts)
- The anti-pattern lists in `.github/copilot-instructions.md` and `AGENTS.md`
- This document, which agents MUST read before modifying any database, import, migration, or data-rendering code
