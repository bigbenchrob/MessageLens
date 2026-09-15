---
tier: project
scope: tester-archive-import-failure
owner: agent-per-project
last_reviewed: 2026-09-13
source_of_truth: incident-analysis
links:
  - ./10-REMEDIATION-IMPLEMENTATION-AND-VERIFICATION-PLAN.md
  - ../../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
  - ../../20-DATA-IMPORT-MIGRATION/11-rust-message-extractor.md
  - ../../25-ONBOARDING-AND-ARCHIVE/50-deterministic-recovery.md
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
  - ../../10-DATABASES/INVIOLATE_RULES.md
---

# Tester Import Failure: Reported Episode, Evidence, and Diagnosis

## Status and scope

This document records the 2026-09-13 tester episode, the evidence available
on 2026-09-13, and the diagnosis supported by that evidence. It is an incident
analysis, not an implementation authorization and not a claim that every
system-wide application-memory alert has the same cause.

No tester database, message content, attachment payload, application data, or
production code was changed during this analysis. The companion remediation
plan is in
[`10-REMEDIATION-IMPLEMENTATION-AND-VERIFICATION-PLAN.md`](./10-REMEDIATION-IMPLEMENTATION-AND-VERIFICATION-PLAN.md).

Evidence reviewed:

- two photographs supplied with the report;
- `diagnostic_report.log` from support bundle
  `support_bundle_2026-09-13_173337`;
- `database_health.json` from the same bundle;
- the current source-import, rich-text extraction, onboarding, projection, and
  diagnostic code at commit `f7b8850bdd1ee415b832fcf05449c40df9a3bb42`;
- retired macOS Jetsam reports from the reporting developer's Mac, considered
  separately from the tester episode; and
- a bounded local decoder-loop probe, also considered separately because it
  did not use the tester's data.

All times below are on 2026-09-13. Bundle log timestamps are UTC; the tester's
bundle identifies the local timezone as CEST, so local times are UTC+02:00.

## Executive diagnosis

The import was interrupted during attributed-body rich-text extraction by a
macOS system-wide application-memory-pressure event. The application then
terminated without reaching its normal success or caught-failure path. The
source-scoped ledger contains the source facts committed before that stage,
while every later topology and graph table remains empty.

The demonstrated MessageLens defect is an unbounded working-set design:

1. the initial message importer reads every unseen source message, including
   every column and blob, into one in-memory result and holds one transaction
   across the full result;
2. the rich-text stage reads every eligible attributed-body blob into one
   list;
3. it copies those blobs into another whole-corpus map;
4. the extractor accumulates every decoded string in a third whole-corpus map;
   and
5. no decoded text is written to the ledger until extraction of the complete
   candidate set finishes.

For this episode the rich-text stage is the decisive location: the photograph
shows `Message text 24000 / 123561`, the last import logs are decoder warnings,
and the database state is exactly the state produced after source-message
insertion but before the next orchestrator stages.

This defect makes peak memory grow with archive size and makes a retry repeat
nearly all rich-text work. It is therefore a credible and high-confidence
material cause of the tester's event. The available artifacts do **not**
contain a tester Jetsam report, Activity Monitor sample, or an uncropped
MessageLens memory figure. The macOS alert is system-wide, and other
applications were open. The evidence therefore cannot prove that MessageLens
was the sole or largest memory consumer at the instant of the alert.

## 1. Reported circumstances

The reported sequence was:

1. A user who had previously tested MessageLens in April installed the current
   release.
2. An initial error referred to an existing archive. The operator had the user
   remove the application's Application Support data and installation then
   proceeded. That earlier problem is intentionally outside this incident's
   causal scope, but broad removal of Application Support must not become a
   remediation pattern because `attachment_archive/` is preservation data.
3. The user selected or presented an archived `~/Library/Messages` folder for
   import.
4. During the import, macOS displayed “Your system has run out of application
   memory.” A second photograph shows MessageLens in the Force Quit list and
   its onboarding panel at `Building browsing data... Message text 24000 /
   123561`.
5. The reporting developer noted similar system-wide memory alerts after
   waking a different Mac from sleep, even when MessageLens was not actively
   being used, and asked whether those alerts might have the same cause.

The photographs are not a MessageLens crash report. They show a macOS memory-
pressure dialog and a paused application. That distinction matters: the
operating system can suspend or terminate processes under global pressure
without producing a Dart exception in the application log.

## 2. Reconstructed timeline

| Local time (CEST) | Hard evidence | Meaning |
|---|---|---|
| 16:55:38 | App launch; startup classifies the installation as `virgin`. | The recorded run began as a fresh onboarding run. |
| 16:55:39 | Startup probe reports 123,934 importable source messages and zero graph messages. | A large source corpus existed; no graph build had completed. |
| 17:11:25 | `Starting fresh onboarding conversation graph build`. | The user-authorized build began. |
| 17:11:33–17:11:34 | Nine row-local `RustMessageExtractor` warnings say no text was found in particular attributed-body blobs. | Message insertion had completed far enough for rich-text extraction to be running. These warnings were caught, not fatal. |
| 17:17:59 | First photograph's creation time; macOS displays its application-memory alert. | System-wide memory pressure occurred while the build was active. |
| 17:19:34 | Second photograph's creation time; MessageLens is paused at `Message text 24000 / 123561`. | The visible MessageLens stage is attributed-body text extraction. |
| 17:32:42 | Next recorded app launch; startup calls the installation `resumable`. | The earlier process did not record normal completion or a caught failure. |
| 17:32:42 | Environment resolves to `graphProjectionFailed`; ledger rows are 123,942 and graph rows are zero. | Source facts survived, but the pipeline did not reach graph projection. |
| 17:33:22 | Another launch produces the same state. | The partial state is durable and reproducible across launches. |
| 17:33:37 | Database-health bundle is generated. | The structural snapshot was taken shortly after the interruption. |

There is no log entry between the decoder warnings and the next launch that
records rich-text completion, attachment or relationship import, graph
projection, a caught exception, or orderly shutdown. Abrupt external
suspension/termination is the best fit for that gap.

## 3. Database evidence locates the stopped stage

The bundle reports:

- the readable source `~/Library/Messages/chat.db`: 123,957 messages;
- the readable source-scoped import ledger: 123,942 messages;
- source-scoped handles: 1,380;
- source-scoped chats: 1,232;
- source-scoped contacts: 1,434;
- source-scoped contact channels: 2,790;
- `chat_to_message`: zero;
- `chat_to_handle`: zero;
- attachments: zero;
- `message_to_attachment`: zero; and
- all substantive conversation-graph tables: zero.

All three active MessageLens databases open read-only and report their expected
schema versions. The health audit reports zero audit errors. Its overall
`fail` and five failed relationship checks are consequences of populated child
fact tables having no later relationship rows; they are not evidence of SQLite
corruption.

The orchestrator order explains the shape exactly:

`chats -> handles -> contacts -> messages -> rich-text enrichment -> attachments -> chat/message edges -> chat/handle edges -> message/attachment edges -> graph projection`

The persisted rows stop on the boundary after messages and before attachments
and topology. Combined with the photographed progress label and final log
source, that makes rich-text enrichment—not graph projection—the stopped
operation. `graphProjectionFailed` is a coarse recovery classification for the
unfinished overall build.

The source-scoped messages belong to source ID 1. Under the current source
identity model, that is the canonical live Messages source. Consequently, the
bundle records execution through the fresh/live onboarding path, not through a
separately registered historical source. This does not contradict the user's
description that the data originated in an archive: the archived Messages
folder may have been restored or presented as the canonical
`~/Library/Messages` folder. It does mean the diagnostic artifact cannot prove
that the historical-archive-source workflow itself was selected.

The health JSON labels the app `0.1.16` build 17, while the inspected checkout
declares `0.2.110+128`. This is not reliable evidence that the tester ran an
old build: the health-audit service uses checked-in `0.1.16`/17 fallback
constants when Flutter build defines are absent, and the JSON itself warns
that fallbacks may be used. The support bundle therefore does not establish the
exact binary version or source commit. The diagnosed whole-corpus behavior is
nevertheless visible in the photographed progress, persisted stage boundary,
logs, and the inspected current implementation. Correct build provenance is a
required diagnostic follow-up in the companion plan.

The source count changed from 123,934 at startup to 123,957 when the bundle was
created. The 23-row change shows that the source was live or changed during the
session. The 15-row difference between source and ledger is small and is not,
by itself, evidence of data loss; those rows may have arrived after the
importer's read boundary. The current implementation does not record a stable
run high-water mark, so this explanation remains an inference.

The photographed rich-text denominator is 123,561, which is 381 fewer than the
ledger message count. That is consistent with the enrichment predicate: only
rows with null plain text and a non-null attributed-body blob are candidates.
The privacy-preserving health audit omits text and attributed-body values, so
the exact category of those 381 rows cannot be confirmed from the bundle.

## 4. Code evidence for unbounded memory growth

### 4.1 Message import is corpus-sized

`MessageImporter.importNewMessages()` in
`lib/essentials/source_scoped_import/application/messages/message_importer.dart`
issues one query for every source row after the existing ledger cursor:

```sql
SELECT m.ROWID AS source_rowid, m.*, ...
FROM message m
WHERE m.ROWID > ?
ORDER BY m.ROWID ASC
```

There is no upper high-water mark, `LIMIT`, or page cursor. `m.*` returns
unused blob payloads as well as the attributed body that must be preserved.
The implementation then retains the complete row list, derives a complete set
of association targets, and performs one ledger transaction over the entire
corpus.

This stage did commit in the tester episode, so it is a contributing
architectural risk rather than the observed stopping point.

### 4.2 Rich-text candidate loading is corpus-sized

`ImportDatabase.findMessagesNeedingTextEnrichment()` in
`lib/essentials/source_scoped_import/infrastructure/import_database_provider.dart`
selects `ss_id`, `source_rowid`, and `attributed_body_blob` for every matching
message, orders them, and converts the complete SQLite result to a Dart list.
It accepts no page size or keyset cursor.

`MessageRichTextEnricher` declares `extractionLimit = 200000`, but the value is
not passed to the ledger query or extractor and has no limiting effect.

### 4.3 Rich-text extraction duplicates and retains the corpus

`MessageRichTextEnricher._enrichMissingText()` retains the candidate list and
then constructs a second map containing all blobs keyed by source row ID. It
passes that full map to
`RustMessageExtractor.extractMessageTextsFromBlobs()`.

The extractor calls the synchronous Rust decoder once per entry and adds every
successful decoded string to a result map. It yields for progress every 1,000
records, but yielding does not release the candidate list, blob map, or decoded
strings. Those collections remain live together.

Only after all candidates have been decoded does the enricher open one write
transaction and begin persisting text. At the photographed 24,000/123,561
point, none of those 24,000 decode results had yet been checkpointed by this
stage.

### 4.4 Retry restarts the vulnerable work

The build service calls `enrichAllMissingText()` when a resumed message import
inserts zero new rows. Because the interrupted run persisted no decoded text,
the same large candidate set is selected on retry. Startup's phrase “retry
from a safe boundary” is correct for database integrity but misleading for
resource use and completed work: the database is safe, while the rich-text
stage is not incrementally checkpointed.

### 4.5 A separate multi-source identity risk

The all-sources enrichment path keys blobs by `source_rowid`, even though
source row IDs are unique only within a source. Two sources can therefore
collide in the map. This did not cause the present single-source episode, but
the remediation must use source-scoped identity (`ss_id` or an equivalent
typed key) when it introduces paging.

## 5. What the evidence rules out

### Database corruption

The active databases are readable, schema versions are recognized, and the
partial row distribution matches the orchestrator stage order. The incident
does not justify deleting or recreating the entire Application Support root.

### Full Disk Access failure

The bundle reports Full Disk Access as available, and both the Messages source
and contacts source are readable.

### The nine decoder warnings as a systemic crash

Each warning says a particular blob contained no extractable text. The
extractor catches those failures, reports them as row-local anomalies, and
continues. The log reaches multiple later row IDs and the UI reaches 24,000
candidates. An anomalous record must remain imported and visible; suppressing
such rows would violate the record-fidelity invariant and would not fix the
corpus-sized allocation.

### Graph projection as the operation consuming memory

The graph contains zero records and the pipeline had not imported the
relationships required before projection. The recovery label names the
overall unfinished outcome, not the stage shown in the photograph.

## 6. Confidence and remaining uncertainty

| Finding | Confidence | Basis / limitation |
|---|---|---|
| The run stopped during rich-text extraction. | Very high | Photograph, final log source, database stage boundary, and orchestrator order agree. |
| MessageLens has an unbounded whole-corpus memory design in that stage. | Certain | Direct source inspection. |
| MessageLens materially contributed to the tester's memory-pressure episode. | High | 123,561 live candidates were retained by the vulnerable path and the process ended during it. |
| MessageLens alone caused the system-wide alert. | Unproven | No tester Jetsam/process-memory report or visible MessageLens memory figure; other apps were open. |
| One malformed/pathological attributed-body blob caused a native allocation spike. | Possible, unproven | Row-local warnings exist, but no blob identity, size telemetry, stack sample, or native crash identifies such a row. |
| The current historical-source workflow, rather than the live onboarding path, ran. | Not supported by bundle | Persisted messages use live source ID 1. |
| The support bundle identifies the exact installed build. | Not supported | The health report can emit stale checked-in fallback version values. |

A controlled local probe decoded and retained 30,000 repetitions of the small
built-in smoke-test blob. Resident memory moved only from approximately 230 MB
to 234 MB. This is negative evidence for a simple per-call native leak on a
small normal input. It does not reproduce the tester corpus and does not rule
out large or adversarial typedstream blobs. The primary diagnosis does not
depend on such a native leak: the Dart-side whole-corpus retention is directly
demonstrated.

## 7. The reporting developer's separate wake-from-sleep alerts

Retired Jetsam reports available on the reporting developer's Mac cover six
recent system-memory events. In five, `CloudTelemetryService` was the largest
resident process at roughly 2.4–4.1 GB. In the sixth, a Visual Studio Code
Insiders renderer and `CloudTelemetryService` were each around 4.7 GB.
MessageLens instances in those reports were materially smaller—approximately
252–737 MB—and no recent MessageLens crash report was found.

Those reports are not evidence about the tester's Mac. They do show that the
developer's recurring wake alerts should not currently be attributed to
MessageLens as the primary trigger. MessageLens can still reduce available
headroom, especially if left open with a large in-memory view or a development
instance, and its import design still requires correction.

## 8. Final causal statement

The supported diagnosis is:

> A fresh/live onboarding build encountered macOS system-wide memory pressure
> while MessageLens was performing attributed-body rich-text extraction over
> 123,561 candidates. MessageLens's enrichment implementation retains the
> entire candidate/blob corpus and every decoded result until the full run
> completes, with no bounded pages or durable intermediate writes. The process
> ended externally before later import and graph stages. This unbounded design
> is the primary MessageLens defect and a likely material cause of the episode;
> the available evidence does not prove MessageLens was the system's sole or
> largest memory consumer.

The required response is to bound source reads and decoder work, persist each
completed page, preserve every source record and anomaly, and validate memory
behavior on a production-scale content-free fixture. That work is specified in
the companion plan.
