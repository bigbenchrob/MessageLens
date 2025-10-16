# 11 – Import & Migration Orchestrator Strategy

This note documents the shared contract that every orchestrator, importer, and migrator must respect. Read it alongside:

- [10 – Database Schema Overview](10-database-schema-overview.md)
- [12 – Import Orchestration Flow](12-import-orchestration.md)
- [13 – Migration Orchestration Flow](13-migration-orchestration.md)
- [AGENT_CONTEXT](AGENT_CONTEXT.md) for the master index

## Dependency Graph First, Execution Second

Both orchestrators accept a list of agents (importers or migrators) that expose:

- `name` – unique identifier for progress logs
- `dependsOn` – list of upstream agent names
- Phase callbacks (`validatePrereqs`, `copy`, `postValidate`)

Before any work begins we perform a **Kahn’s algorithm** topological sort over `dependsOn`. This guarantees we never process a join table (e.g., `chat_to_handle`) before its parents (`chats`, `handles`). Cycles raise a fatal orchestration error rather than proceeding in an undefined state.

Topological ordering is computed once per run, logged for audit, and then enforced rigorously. Agents may assume that every dependency listed in `dependsOn` has completed all phases successfully before their own phases begin.

## Phase Contract

Every agent is executed in the same three-phase lifecycle:

1. **`validatePrereqs(ctx)`** – identify defects that already exist in the source data. This phase **must not mutate** either database. By catching broken foreign keys, duplicate identifiers, or enum mismatches here we avoid blaming the downstream copy logic for corrupted inputs.
2. **`copy(ctx)`** – perform the entire projection in **one transaction**. The orchestrator requires agents to keep their work atomic: a failure anywhere must roll back the transaction and leave both databases in their pre-phase state.
3. **`postValidate(ctx)`** – verify the projection outcome (row counts, referential integrity, domain-specific assertions). Like `validatePrereqs`, this phase should avoid writes except for logging or throwing.

Agents return control to the orchestrator only after they have detached any ledger attachments, released database handles, and restored the system to a clean state. This is essential because the orchestrator immediately proceeds to the next agent in the sorted order.

## Atomic Attach/Detach Discipline

- Agents must **attach the import database once**, inside their phase, work with it, and **detach before returning**.
- Do not rely on implicit connection cleanup—explicitly detach or the orchestrator will trip over locked database errors (`SQLITE_LOCKED`, `SQLITE_BUSY`).
- The orchestrator performs preflight and postflight checks (`ensureImportReady` / `ensureImportClean`) around every phase. Agents that leave stray attachments will throw targeted `MigrationException`/`ImportException` errors.

## Failure Handling

- Any exception thrown during a phase aborts the current agent, logs the failure, and stops the global run. Downstream agents **never** execute when a dependency fails.
- The orchestrator wraps each agent’s transaction and emits structured progress events so the UI can update status panels accurately.
- Agents may throw domain-specific exceptions (`MigrationException`, `ImportException`) with codes, human-readable messages, and optional `details` maps for debugging.

## Designing New Agents

When adding a new importer or migrator:

1. **Describe its dependencies** explicitly; do not assume ordering.
2. **Implement a rigorous `validatePrereqs`** that checks the source data for the specific invariants your copy step assumes. Leverage anti-joins to detect orphan foreign keys, `PRAGMA foreign_key_check`, and uniqueness scans.
3. **Wrap copy logic in `transaction(() async { ... })`** and keep the number of SQL statements minimal and deterministic.
4. **Ensure cleanup is airtight** (detach attachments, close cursors) even when exceptions occur.
5. **Document the behavior** in the feature-specific note ([12](12-import-orchestration.md) or [13](13-migration-orchestration.md)) and update [10](10-database-schema-overview.md) if new tables or columns are involved.

By keeping these rules consistent we avoid data races, lock contention, and the blame game that previously plagued our migration iterations. The orchestrator becomes a reliable referee instead of a source of mystery bugs.
