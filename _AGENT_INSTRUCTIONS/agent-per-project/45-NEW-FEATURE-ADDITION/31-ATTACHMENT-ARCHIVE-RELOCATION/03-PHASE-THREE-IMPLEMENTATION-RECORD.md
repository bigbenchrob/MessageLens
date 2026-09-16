---
tier: project
scope: attachment-archive-relocation
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: implementation-record
links:
  - 00-ARCHITECTURE-AUDIT-AND-IMPLEMENTATION-PLAN.md
  - 01-PHASE-ONE-IMPLEMENTATION-RECORD.md
  - 02-PHASE-TWO-IMPLEMENTATION-RECORD.md
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
  - ../../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md
---

# Attachment Archive Relocation: Phase Three Implementation Record

## Status and baseline

Phase Three implements availability-aware attachment reads, evidence,
diagnostics, generation invalidation, and user-visible archive status. It is
complete and intentionally unstaged for review.

Phase Two was committed locally on `feature/attachment-archive-relocation` as
`0822f27bd92c9de28902dcd51f007fd08c998ead` with subject
`feat(attachments): add safe external archive location identity`. That commit
is the current `HEAD` and was not pushed by this work. Phase Three does not
weaken the Phase Two internal-only mutation authority.

The shared-instructions submodule remained unchanged at
`95326f515ef4719f155ce6e223990398daad6311`.

## Read contract and exact state taxonomy

Root availability is now classified before any attachment payload path is
inspected. `AttachmentArchiveLookupRecord`, graph lookup records, resolved
attachments, message evidence, and chat-summary attachment models carry typed
payload state plus location availability, generation, and root issue.

The read taxonomy is:

1. no archive metadata record: the lookup returns `null`;
2. metadata exists but the archive root is unavailable:
   `AttachmentArchivePayloadStatus.rootUnavailable`, with no absolute path and
   no per-file stat;
3. root available and payload is a regular file: `available`;
4. root available and payload is absent: `missing`;
5. root available but the entry is not the expected regular-file type:
   `unexpectedFileType`;
6. stored metadata does not contain a safe root-relative path:
   `invalidMetadataPath`; and
7. an explicit size/hash verification proves damage: `verifiedCorrupt`.

The final status is reserved for deliberate verification boundaries; ordinary
reads do not hash payloads or manufacture corruption. The legacy convenience
`archiveFileExists` value is derived from typed `available` state rather than
being an independent source of truth.

Both the overlay read store and graph compatibility lookup reject unsafe
relative paths before root joining. An unavailable root exposes no usable
absolute path. Tests inject a counting file-type reader and prove that the
unavailable branch performs no payload stat.

## Resolver, evidence, and live-source semantics

The attachment resolver watches the root-aware read-store provider, so its
results are rebuilt from the current location generation. The resolver now
returns `ResolvedAttachmentAvailability.archiveUnavailable` when archive
metadata may exist but its configured root cannot be inspected.

If the independent Apple Messages source is readable, it remains a legitimate
display fallback. The result then identifies `messagesLive` provenance while
retaining the archive root's unavailable status, issue, and generation. If no
live source is available, the attachment surface reports that the archive is
unavailable. Neither branch creates recovery metadata, claims corruption, nor
starts repair or ingestion merely because the external volume is disconnected.

For an available custom root, including `customReadOnly`, archived regular
files display normally. If its archived payload is absent but a live file is
readable, the live file may display, but custom roots still cannot enter the
on-demand ingestion path. Only an available default/internal location whose
state admits the typed Phase Two mutation capability can trigger that write.

Message attachment evidence uses explicit `archive unavailable` wording. A
live fallback is described as `available from Messages · archive unavailable`,
so successful display does not erase root evidence. Attachment placeholders
use unavailable-specific copy and disable recovery controls until the root is
available.

The import-ledger evidence reader similarly returns typed inaccessible
evidence without invoking its payload inspector when the root is unavailable.
Chat-summary hydration counts root-unavailable records separately from missing
files and carries the current generation into hydrated attachment models.

## Generation invalidation and derived caches

`AttachmentArchiveLocationState` now has value equality. Effective-location
comparison includes availability, configuration mode, bookmark identity,
resolved root, and root issue. The notifier does not publish an identical
`AsyncData` observation, avoiding unnecessary dependent-provider churn.

All production providers that construct archive read stores or graph lookups
watch the current location state rather than extracting a path once. Their
path-bearing records include the generation. Tests exercise this sequence:

- an attachment first resolves below the original custom root;
- disconnect removes the absolute path and produces root-unavailable state;
- reconnect resolves below the current root;
- rename/remount replaces the old absolute prefix; and
- a repeated identical observation produces no notification.

No generation transition starts recursive statistics, an integrity audit, or
an inventory.

`VideoThumbnailCacheService` was audited. It keys derived thumbnails by the
resolved absolute source path. Because path-bearing attachment results are
invalidated first, an old source path cannot remain an authoritative result;
a changed path safely produces a cache miss and recomputation. A broader
root-relative or content-addressed thumbnail-key migration is deliberately
deferred because it is an optimization, not a Phase Three correctness need.

## Health and onboarding behavior

Graph health now reports physical archive audit status independently as
`notRequested`, `completed`, or `deferredRootUnavailable`, with a typed
root-level reason. When the root is unavailable, metadata/database counts
continue normally, payload missing/available counts remain zero, and recovery
conclusions are deferred. The status sheet tells the user to reconnect the
configured volume before deliberately rerunning the physical audit.

Onboarding reads the full location state. For an unavailable external root it
does not probe the directory and instead emits an optional unavailable
attachment-archive diagnostic. That condition does not alter readiness,
trigger onboarding, request Start Fresh, initiate database recovery, or block
startup. Environment readiness presents `External archive unavailable`; an
available read-only root presents `Available (read-only)`.

## Settings, statistics, and user-visible state

Attachment Archive is now a durable Settings menu destination backed by the
existing cassette architecture. Its read-only status surface reports:

- Internal or External location;
- resolved or last-known display path;
- volume name when known;
- Available, Available (read-only), Unavailable, Permission denied, or
  Configured directory missing; and
- the typed location issue where present.

There is no startup modal and no production Move Archive action. Temporary
disconnection does not force reselection.

Cheap `ArchiveSettingsState` no longer contains recursive record-count or size
statistics. The new `attachmentArchiveStatisticsProvider` is an explicit,
potentially recursive operation and returns a root-level unavailable snapshot
without scanning when the root is unavailable. A source-level performance
tripwire proves it has no implicit production consumer, so startup, search,
ordinary Settings status, location events, reconnect, and attachment
resolution cannot accidentally request a recursive scan.

The user-facing release is recorded as `0.2.112+130` in `pubspec.yaml` and in
the `0.2.112` changelog entry.

## Mutation boundary

`AttachmentArchiveMutationRoot` remains the write authority. Location state
admits it only for the available default/internal root. No Phase Three read,
evidence, settings, health, or onboarding path can turn physical custom-root
writability, a bookmark, a remembered path, or a resolved path into mutation
authority.

Existing mutation-safety tests still cover ingestion writes, recovery writes,
root creation, archive reset/deletion, and high-level recovery construction.
Custom external locations remain read/location-only throughout Phase Three.

## Main files changed

Read and resolution boundaries:

- `lib/features/attachments/domain/constants/attachment_archive_payload_status.dart`
- `lib/features/attachments/application/attachment_archive_read_store.dart`
- `lib/features/attachments/infrastructure/repositories/overlay_attachment_archive_read_store.dart`
- `lib/features/attachments/application/graph_attachment_archive_lookup.dart`
- `lib/features/attachments/infrastructure/repositories/overlay_archive_compatibility_lookup.dart`
- `lib/features/attachments/application/attachment_resolver_provider.dart`
- `lib/features/attachments/domain/entities/resolved_attachment.dart`
- `lib/features/attachments/infrastructure/repositories/import_ledger_message_lens_attachment_evidence_reader.dart`

Evidence, graph hydration, and presentation:

- `lib/features/messages/application/message_evidence/message_attachment_evidence.dart`
- `lib/essentials/conversation_graph/application/chat_summaries/chat_summary.dart`
- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart`
- `lib/features/messages/presentation/view/recovered_attachment_sidebar_view.dart`
- `lib/features/messages/presentation/view_model/shared/display_widgets/new_display_widgets.dart`

Location, statistics, health, onboarding, and Settings:

- `lib/features/attachments/domain/entities/attachment_archive_location_state.dart`
- `lib/features/attachments/application/attachment_archive_location_provider.dart`
- `lib/features/attachments/application/archive_settings_provider.dart`
- `lib/features/attachments/application/attachment_archive_runtime_providers.dart`
- `lib/essentials/conversation_graph/application/health/graph_health_report.dart`
- `lib/essentials/conversation_graph/infrastructure/repositories/graph_health_repository.dart`
- `lib/essentials/conversation_graph/presentation/status/conversation_graph_status_sheet.dart`
- `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart`
- `lib/essentials/onboarding/domain/onboarding_environment_report.dart`
- `lib/features/environment_readiness/application/view_spec/resolver_tools/environment_readiness_surface_provider.dart`
- Settings coordinator, topology, menu payload, and attachment-archive cassette
  resolver files under `lib/essentials/sidebar/`, `lib/features/settings/`, and
  `lib/features/sidebar_utilities/`
- generated Riverpod and Freezed outputs affected by these providers/models
- `CHANGELOG.md` and `pubspec.yaml`

Focused coverage is in the corresponding attachment, message-evidence, graph
health, onboarding, sidebar/settings, and performance test files, including
`test/features/attachments/application/attachment_archive_phase_three_performance_test.dart`.

## Validation

Provider/model generation completed successfully:

```text
dart run build_runner build --delete-conflicting-outputs
```

The expanded attachment/location/read/resolver/evidence/health/onboarding/
settings/statistics/mutation regression set passed:

```text
flutter test <19 focused Phase One/Two/Three test files> --reporter compact
```

Result: all 143 focused tests passed.

Architecture validation:

```text
flutter test test/architecture/forbidden_imports_test.dart --reporter compact
```

Result: all 388 architecture tests passed.

Full repository and static validation:

```text
flutter test --reporter expanded
flutter analyze
git diff --check
```

Result: the complete repository suite passed 2,330 tests with one intentional
qualification-harness skip; analysis reported no issues; and the diff check
passed.

No native files changed in Phase Three, so the Phase Two native bridge suite
was not rerun. The generated files were produced by the normal generator and
were not edited by hand.

The disposable automated acceptance exercise covered custom-root display,
disconnect without per-file stat, truthful archive-unavailable presentation,
live-source fallback without ingestion, reconnect without restart, renamed-root
path replacement, no recursive statistics, deferred health audit, and denied
custom mutation. All filesystem cases used temporary directories and in-memory
databases.

## Audit conformance, remaining debt, and Phase Four starting point

No Phase Three architecture-audit assumption was disproved. The existing
recursive statistics coupling was stronger than the Phase Two narrow refactor
left in place, so Phase Three removed statistics from cheap settings state
entirely and exposed an explicit operation, as the audit already recommended.

No schema or migration changed. No FTS, import, graph schema, archive-relative
identity, or content-hash representation changed. Phase Three introduced no
payload relocation, external writes, capacity preflight, inventory, journal,
activation, retirement, deletion authority, or split-root checkpoint change.

Phase Four should begin by introducing the generation-bound writable lease and
the policy for deferred ingestion/recovery while a writable destination is
unavailable. Only after that authority and interruption model are proven should
relocation add a journal, bounded inventory, capacity preflight, copy and
verification, atomic activation, and conservative source retirement. External
archive deletion authority remains explicitly out of scope until designed.

No user database or real attachment archive was opened, scanned, copied, moved,
created, reset, or deleted during implementation or validation.
