# Post-Adoption Polish and Attachment Showcase

## Status and scope

This checkpoint responds to the performance and presentation findings from
the first real MessageLensDevelopment archive adoption. It does not redesign
the validated authority model. Initial bulk copying remains outside
MessageLens; the candidate becomes authoritative before bounded historical
remediation; the retained source is never a fallback; and complete final
coverage remains mandatory before the transaction can retire.

The implementation and automated qualification use disposable archive roots.
Production adoption remains disabled. Onboarding is not integrated with the
showcase in this checkpoint.

## Findings corrected

The first real verified-behind adoption exposed four concrete issues:

1. pressing **Use This Copy** repeated the full source/candidate content pass;
2. the post-remediation full verifier ran without an explicit workflow state;
3. pending-transaction provider state could remain stale as terminal success
   was published; and
4. the center pane had no ambient feedback while missing attachments were
   installed.

It also proved that growth in the missing set did not establish chronology.
The UI now says that the copy is missing attachments currently stored in the
active archive; it does not call them newly received attachments.

## Approval-time structural delta

### Private per-entry baseline

A full complete/behind verification now retains an ordered, process-local
`AttachmentArchiveVerificationStructuralBaseline`. The Settings workflow holds
that evidence only inside its private ready-verification result. It is not
serialized into the adoption transaction, exposed in workflow presentation
state, or accepted as configuration or mutation authority.

Each `AttachmentArchiveStructuralEntryEvidence` records:

- normalized relative path;
- structural kind: directory, preservation payload, or installer debris;
- regular-file size;
- regular-file modified and changed timestamps in microseconds;
- preservation classification;
- grouped metadata file-size evidence;
- grouped metadata SHA-256 evidence; and
- grouped metadata reference count.

Directory evidence intentionally records path and kind but not directory
timestamps, because adding a descendant legitimately changes its ancestors.
The baseline is bounded by the number of archive entries and retains no
payload bytes.

### Additive-delta algorithm

Verified-behind approval still runs inside the uninterrupted typed
`attachmentArchiveAdoption` coordinator operation. It:

1. rereads the active source configuration and generation;
2. re-resolves source identity;
3. creates and resolves the candidate bookmark and proves writable admission;
4. performs the deterministic structural/metadata traversal;
5. requires the candidate structural fingerprint, matched totals, debris, and
   allowed-extra totals to remain exactly as reviewed;
6. diffs the current ordered source entries against the private baseline;
7. rejects every missing or changed existing entry, including type, size,
   timestamps, classification, and metadata evidence changes;
8. accepts only entries absent from the reviewed baseline;
9. validates each newly added preservation payload and requires its candidate
   path to remain absent before and after hashing;
10. stream-hashes only that new source payload and binds its exact size and
    SHA-256 into the refreshed missing set; and
11. reapplies the 256-payload and 1-GiB remediation limits before preparing the
    existing switch-first transaction.

The original reviewed missing set and the new additive set are sorted and
bound together. Aggregate fingerprint differences are never treated as proof
of additions. A source removal, replacement, timestamp change, metadata-group
change, unsafe entry, ambiguity, candidate change, or identity change fails
closed and requires another check.

Instrumentation covers a disposable archive containing 1,000 unchanged
synthetic payload pairs plus three post-review additions. Approval hashes
exactly the three added source paths. It hashes no unchanged source payload
and no candidate payload. A no-change approval hashes zero payloads.

## Final coverage remains authoritative

The optimization stops at approval. After every missing item is installed or
proved already present, the service still runs the complete
source-versus-active-candidate verifier. The transaction is cleared only when
that verifier returns `AttachmentArchiveCandidateComplete`.

The typed workflow stage `verifyingFinalCoverage` exposes the verifier's
determinate file and byte totals and percentage. The center pane states that
MessageLens is making one final check and explicitly says that attachments are
not still being copied. A final-verifier failure cannot publish success; the
candidate remains active with its durable remediation/recovery transaction.

## Pending transaction and stable success

After the service reports a successful adoption or resumed remediation, the
workflow invalidates and awaits the real pending-transaction provider. Success
is publishable only after that provider resolves absent. If it still resolves
an active transaction, the workflow reconstructs the typed pending state.

The resulting terminal success is retained in the keep-alive application
notifier. Ordinary location or pending-provider recomputation cannot replace
it with stale pending state. It remains visible until deliberate dismissal,
another selection/check action, provider disposal, or navigation lifecycle
that reconstructs the workflow. Complete-candidate adoption uses the same
pending-refresh and stable-success rule even though it has no remediation or
showcase events.

The success presentation identifies the current archive and retained original,
states that all attachments are up to date, says that the original remains
unchanged, and recommends keeping it for a few days. It offers no deletion or
disk-reclamation action.

## Attachment Showcase architecture

The governing invariant is:

> The operation produces attachments. The showcase observes them. The
> operation never waits for the showcase.

`AttachmentShowcaseItem` is transient presentation data only: a resolved local
path, media kind, stable presentation identity, and optional historical date,
display filename, and type. It contains no archive lease, mutation permit,
transaction state, database capability, or cancellation authority.

`AttachmentShowcaseSource` is separate from `AttachmentShowcaseView`. The
source accepts synchronous offers and retains at most the current item plus
one latest pending item. A 750-ms timer advances to the latest pending item;
intermediate rapid offers are deliberately coalesced. Stopping operation
updates drops the pending item but may leave the last visual as decoration.
There is no unbounded queue or persisted history.

The view reserves a stable 220-point center-panel area so determinate progress
does not jump. Images use local `Image.file`, `BoxFit.contain`, bounded decode
hints (`cacheWidth: 960`, `cacheHeight: 540`), a per-item key, a short default
crossfade, and an error fallback. Video, PDF, and other files use generic local
representations. This checkpoint adds no video thumbnail generation, PDF
renderer, cache directory, content analysis, captions, network request, or
showcase database.

### Remediation producer

Remediation publishes an item only after the exact payload has been installed
or atomically proved already present in the active candidate archive. The item
points at that active destination, not the retained source. The callback is
synchronous, is never awaited, and is enclosed by a catch-all presentation
boundary. A missing/disposed consumer, thrown callback, deleted preview path,
corrupt decode, unsupported media, or slow UI cannot alter the remediation
result.

The showcase is secondary to determinate remediation progress. When final
coverage begins, operation-progress showcase updates stop. The last image may
remain visible, but the stage and copy make clear that only verification is
running.

## Privacy

Showcase presentation remains entirely local and transient. It does not upload
media, call network services, analyze content, log paths or filenames, create
thumbnails, or persist history. It displays only files already available under
the application's local archive authority.

## Tests and architecture tripwires

Disposable tests cover pure additions, removal/replacement/metadata changes,
candidate changes, limit overflow, exact combined obligations, zero unchanged
rehashes, the 1,000-item instrumentation fixture, retained-source and candidate
unavailability, crash/recovery, determinate final coverage, pending-provider
absent-to-active-to-absent lifecycle, stable success, and complete-candidate
success.

Showcase tests cover post-install publication, image classification, callback
failure containment, failed-install suppression, absence of a consumer,
corrupt/deleted image fallback, unsupported media, disposed consumers, rapid
production, and the two-item retention bound. The disposable Settings
end-to-end test covers reviewed-behind adoption with post-review additions,
exact approval hashes, switch-first remediation, ordinary writes to the new
root, showcase publication, final coverage, transaction retirement, and
stable success.

Architecture tests require that:

- showcase presentation imports no mutation/adoption authority;
- showcase source has no filesystem, database, network, or settings store;
- remediation publishes only after the verified installer and does not await
  showcase rendering;
- behind approval hashes only the explicit added-entry collection and cannot
  invoke the full verifier;
- adoption coordination and final full coverage remain present;
- the exact development-only gate remains unchanged and production remains
  disabled;
- the retained source is not fallback; and
- legacy mover code remains absent.

## Future onboarding integration

Onboarding/import may later become a second producer. It can offer sampled
historical image items with their already-available month/year while its own
attachment operation proceeds independently. The shared item already permits
that optional date. This checkpoint does not read onboarding databases, alter
onboarding correctness, or add an onboarding producer.

## Deviations and remaining qualification

No durable success receipt was added; the postmortem mentioned it only as an
auditability possibility, and it is outside the four approved corrections.
Final coverage was deliberately not optimized or removed. Remediation does not
perform new date lookups for presentation. Unsupported video and PDF content
uses a generic representation rather than new thumbnail/rendering machinery.

Remaining real-development qualification is observational and separately
authorized: confirm terminal success presentation, disconnected-Toshiba
behavior, ordinary ingestion, and showcase behavior if a natural remediation
opportunity occurs. No real archive should be switched, mutated, or seeded to
manufacture that opportunity.

The exact next step is review of this entirely unstaged checkpoint. After that
review, checkpoint it separately before any optional development qualification.
Do not begin onboarding showcase integration or production qualification.
