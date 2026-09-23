# First Real Archive Adoption — Postmortem

## Audit status and scope

This is the read-only post-adoption audit of the first real simplified
MessageLensDevelopment archive adoption on 2026-09-21.

The audited development identity was:

- process: PID `7989`, launched 2026-09-21 07:36:07 PDT;
- executable:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app/Contents/MacOS/MessageLens Development`;
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`;
- product: `MessageLens Development`;
- build: `0.2.123+141`;
- admitted primary root:
  `/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`;
- archive environment: `development`;
- archive instance UUID: `e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5`.

Production MessageLens data was not accessed. The abandoned relocation
artifacts and legacy relocation journal were not inspected or changed. No
repair, retry, resume, configuration change, synthetic payload, archive write,
or database write was performed.

## Executive result

The adoption completed successfully. Toshiba is the authoritative active
attachment archive, the 39-item remediation set completed, final coverage was
proved before the durable transaction was retired, and WD remains physically
retained without being a runtime fallback.

| Question | Result |
|---|---|
| Toshiba authoritative | **YES** |
| Next ordinary archive write targets Toshiba | **YES** |
| 39 remediation payloads complete | **YES** |
| Pending remediation transaction | **NO** |
| WD source retained | **YES** |
| WD used as fallback | **NO** |
| Final coverage complete | **YES** |
| 30 to 39 explained | **YES** — two bounded development maintenance sweeps archived seven and then two older December 2025 attachments after the first verification snapshot and before approval-time verification. |
| Approval-time full byte recheck inherently necessary | **NO** — not if the initial result retains sufficient process-local per-entry structural evidence to prove an additive source delta and hash only the new entries. The current implementation lacks that delta evidence, so it conservatively reruns the full verifier. |
| Safe to continue development qualification | **YES**, after recording the UX/performance corrections below; no data-integrity blocker remains. |

## 1. Actual final authority

The development overlay setting `attachment_archive_location` contains one
format-1 configuration with:

```text
mode: custom_external
lastKnownPath: /Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive
volumeName: Toshiba_manual_bu
customWritePolicy: active_archive
bookmarkDataBase64 length: 1,736 characters
```

The persisted bookmark was resolved read-only through the same Foundation API
and `.withoutUI` option used by the native bridge. It resolved to exactly:

```text
/Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive
```

The bookmark is not stale. The target exists, is a directory, is readable and
writable, and canonicalizes to the same path. It is on mounted volume
`Toshiba_manual_bu`, device `/dev/disk12s2`, Journaled HFS+, volume UUID
`E0DD8906-3B97-3521-9CD0-335260A82857`, partition UUID
`ADF71738-230D-49B9-B774-287B1CD3D4A7`. The volume and media are not read-only.

The archive-instance UUID remains the identity of the admitted development
data root. The selected attachment archive is not itself a second MessageLens
data root and therefore does not carry a second `.messagelens-archive.json`
marker.

**IS TOSHIBA NOW THE AUTHORITATIVE ACTIVE ATTACHMENT ARCHIVE: YES.**

## 2. Writable-root authority

The live location provider began this uninterrupted process at generation `0`
on the WD-backed default attachment location. Verified activation forces
exactly one generation advance. No later effective-location change is present,
so the active generation is `1`.

The Phase Four writable admission therefore has:

```text
lease root: /Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive
configuration identity: the persisted format-1 custom_external configuration above
location generation: 1
mode: custom_external
custom write policy: active_archive
destructive reset permitted: false
```

There is direct runtime confirmation in addition to the static provider proof.
At 15:16:22Z, after adoption coordination had released, the normal graph
attachment sweep archived eight payloads. Those eight files, totalling
1,803,999 bytes, exist on Toshiba with 08:16:20–08:16:22 PDT installation
times. WD remained at 4,082 payloads. That ordinary write path obtains the
writable-root admission and validates the lease at `operationStart` before it
can install anything; it therefore proved the active Toshiba root,
configuration identity, generation, and writable availability in the running
application.

**WOULD THE NEXT ORDINARY ARCHIVED ATTACHMENT BE WRITTEN TO TOSHIBA: YES**, as
long as the current configuration/generation and Toshiba availability remain
unchanged. No ordinary write path is authorized to fall back to WD.

## 3. Adoption/remediation transaction

The only approved adoption transaction path was inspected. No pending record
exists at:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development/
.messagelens-attachment-adoption-transaction.json
```

Consequently there is no live transaction version, ID, state, or remaining
obligation count to report. This run used the format-2 `verified_behind`
workflow, but the design intentionally deletes the record after success and
does not retain its transaction ID in the application log.

Absence is the expected successful terminal state here, not missing recovery
evidence. For this workflow the service can clear the record only after:

1. all fixed remediation items install or prove already present;
2. a full final verifier returns `AttachmentArchiveCandidateComplete`; and
3. `clearPending` confirms the expected transaction ID.

The current configuration is the intended active Toshiba configuration, all
39 installations are visible as one bounded filesystem interval, and no
pending record remains.

**REMEDIATION TRANSACTION FULLY COMPLETED: YES.**

**PENDING HISTORICAL REMEDIATION REMAINS: NO.**

Auditability note: retiring the only record also retires its transaction ID,
timestamps, and exact obligation list. The physical evidence and guarded
control flow prove this run, but a compact non-authoritative success receipt in
development diagnostics would make later audits easier without becoming
runtime authority.

## 4. Final and current coverage

The final remediation obligation was exactly:

```text
39 payloads
124,022,201 bytes
118.277 MiB
```

Exactly 39 regular payload files on Toshiba have installation mtimes from
14:58:12Z through 14:58:28Z, and their byte sum is exactly 124,022,201. There
are no installer temporary files. Each install streamed through the canonical
no-overwrite installer, hashed the completed temporary payload against the
transaction SHA-256, atomically installed it, and reverified the destination.
The service then performed its full final source/candidate content verification
before clearing the transaction.

Current read-only evidence is:

| Evidence | WD retained source | Toshiba active archive |
|---|---:|---:|
| Preservation payload files | 4,082 | 4,090 |
| Preservation payload bytes | 3,591,101,186 | 3,592,905,185 |
| Finder `.DS_Store` files ignored by policy | 1 | 1 |
| Installer temporary files | 0 | 0 |

Current authoritative metadata contains 4,375 attachment-reference rows,
4,090 distinct content-addressed paths, 3,592,905,185 distinct payload bytes,
and no null content hashes. Duplicate metadata references account for the
difference between row and physical-path counts. No duplicate path has
inconsistent size evidence.

A stat-only coverage pass found every one of the 4,090 metadata-known paths on
Toshiba with the expected byte length. Toshiba's physical payload count and
byte total exactly equal the distinct metadata count and total. The eight-file
difference from WD is the successful post-adoption ordinary sweep described
above. No expensive redundant hashing was run by this audit.

There is no `pendingHistoricalRemediation` evidence because that availability
can be produced only for an exact path in an active durable transaction, and
no transaction exists.

**FINAL COVERAGE COMPLETE: YES.**

## 5. Original WD source preservation and fallback policy

The original archive still exists at the exact canonical path:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development/attachment_archive
```

It remains on `WD_ELEMENTS`, device `/dev/disk11s1`, APFS, volume UUID and
partition UUID `A841DF7B-27A0-44F7-882E-528BDC9AD35D`. The volume and media
are not read-only.

Its 4,082 payloads and 3,591,101,186 bytes exactly match the approval-time
authoritative-source snapshot. The remediation service opens retained source
files for bounded reads only; its mutation authority can install only the
corresponding exact candidate path and cannot delete, rename, overwrite, or
otherwise mutate the source. No source deletion or rename is visible.

WD is not configured as an active root or secondary read root. The resolver
can label an exact active-transaction item as pending remediation, but even in
that state it does not serve bytes from the retained source. With the
transaction retired, that narrow pending state is unavailable too.

Expected result proved: **retained physically, not authoritative, not
fallback**.

## 6. Exact 30 to 39 and 4,073 to 4,082 explanation

### Reconciled totals

```text
Initial missing set: 30 payloads, 122,082,618 bytes (116.427 MiB)
Added between snapshots: 9 payloads, 1,939,583 bytes (1.850 MiB)
Final missing set: 39 payloads, 124,022,201 bytes (118.277 MiB)

Initial required set: 4,073 payloads
Added between snapshots: 9 payloads
Approval required set: 4,082 payloads
```

The arithmetic exactly reconciles both UI changes.

### The exact nine

For every row below, the SHA-256 is the full 64-hex filename stem shown in the
relative path. Attachment identity is source `1` plus its attachment ROWID and
attachment GUID. Message identity is source `1` plus its message ROWID and
message GUID. All times are UTC.

| Archive relative path / SHA-256 | Bytes | Attachment identity | Message identity and date | Recognized in WD | Installed on Toshiba |
|---|---:|---|---|---|---|
| `20/20584eff2ecef8c7c87a10924d1d1bb510bc2291890d9c2342cf08622f12601a.png` | 468,243 | row 36492 · `at_0_9591EB5F-7569-45A2-B290-18A1FB985D95` | row 125933 · `9591EB5F-7569-45A2-B290-18A1FB985D95` · 2025-12-06 12:16:37 | 2026-09-21 14:46:18.498224 | 2026-09-21 14:58:17 |
| `da/dac3d1752bee1b6f298b3f8cd13e523a8a46a8763a83da1bd195057334e59d21.png` | 102,212 | row 36507 · `at_0_41A75DF6-E8C2-41D6-9042-28755450D596` | row 125969 · `41A75DF6-E8C2-41D6-9042-28755450D596` · 2025-12-06 18:10:31 | 2026-09-21 14:46:18.557392 | 2026-09-21 14:58:28 |
| `6b/6bc0579022413a09b08c6721c9d817bbb6e32c328dab6ac40fca0b89d72571f1.png` | 142,661 | row 36553 · `at_0_9A05487A-EC56-4053-A165-D505637ABF59` | row 126036 · `9A05487A-EC56-4053-A165-D505637ABF59` · 2025-12-07 08:47:01 | 2026-09-21 14:46:18.687492 | 2026-09-21 14:58:25 |
| `57/57fbacafc3041825349dacc4acec5a70d3ef5e102f28dd8d0751920a5b9c887e.png` | 131,114 | row 36555 · `at_0_23063FFD-07F2-471C-9520-EBD574893090` | row 126042 · `23063FFD-07F2-471C-9520-EBD574893090` · 2025-12-07 09:15:50 | 2026-09-21 14:46:18.724490 | 2026-09-21 14:58:19 |
| `9e/9ed7501b30437398ea8947b71db9437775dedc2bc7cb2512ab6aaa06ec0d8df6.png` | 217,633 | row 36582 · `at_0_46888940-3037-463E-9840-A5BC1AA851BF` | row 126096 · `46888940-3037-463E-9840-A5BC1AA851BF` · 2025-12-08 21:37:06 | 2026-09-21 14:46:18.785213 | 2026-09-21 14:58:26 |
| `c9/c9795d0434b0600135dfff09a8be0e5ffd6e91f5e8d1f7aef12c7d290572dad1.png` | 145,458 | row 36589 · `at_0_8DE560AA-D716-4D13-8DB8-DD455E81CCF5` | row 126133 · `8DE560AA-D716-4D13-8DB8-DD455E81CCF5` · 2025-12-09 06:23:35 | 2026-09-21 14:46:18.800501 | 2026-09-21 14:58:28 |
| `0e/0e74e2c724810f2511db719733638261197920a5f690fc0e164efc60bce4cd39.png` | 142,491 | row 36596 · `at_0_6C8E9FBA-061F-49B9-A073-DBF4C2044426` | row 126148 · `6C8E9FBA-061F-49B9-A073-DBF4C2044426` · 2025-12-09 19:17:13 | 2026-09-21 14:46:18.890843 | 2026-09-21 14:58:16 |
| `79/79f32e1800acada7ed3839df1c872ed6951096aea2d51e5361d41241910510b3.png` | 146,485 | row 36638 · `at_0_5EB72885-0166-4E21-9F66-926A6ECAC3DF` | row 126215 · `5EB72885-0166-4E21-9F66-926A6ECAC3DF` · 2025-12-11 10:35:37 | 2026-09-21 14:51:18.207390 | 2026-09-21 14:58:26 |
| `0a/0a6bd3b530bed41de1854f58f9fb040abc8251b40c2cd520e00286d299df5677.png` | 443,286 | row 36676 · `at_0_23336B8F-CEC1-46C7-8217-CFDCCF8ABFD0` | row 126269 · `23336B8F-CEC1-46C7-8217-CFDCCF8ABFD0` · 2025-12-12 12:22:22 | 2026-09-21 14:51:18.251869 | 2026-09-21 14:58:12 |

### Mechanism

The first full verification took its source snapshot before these nine were
archived. The application's normal bounded maintenance sweep then examined two
100-attachment graph chunks:

- 14:46:19Z: seven newly archived, 93 skipped, zero failed;
- 14:51:18Z: two newly archived, 98 skipped, zero failed.

All nine associated messages are from 2025-12-06 through 2025-12-12. They are
not newly received messages. They are existing imported messages whose payloads
became part of the development archive when the delayed-source reconciliation
sweep reached them. They were therefore absent from the first 4,073-file
physical source snapshot and present in the approval-time 4,082-file snapshot.

The user's observation that regular production MessageLens received no new
messages during the interval is fully consistent with this evidence.

### Wording finding

The sentence “Since the copy was made, the current archive has received 30 new
attachments” is not semantically justified. Verification proves only that 30
currently required source payloads are absent from the selected copy. It does
not know when or how the copy was made, and “received” can be mistaken for new
Messages traffic.

Use this wording instead:

> This copy is missing 30 attachments currently stored in the active archive.

For the refreshed set it should say 39, using the exact final count.

## 7. Approval-time full-check analysis

The approval-time **Checking the final archive changes…** phase is a complete
call to `FilesystemAttachmentArchiveCandidateVerifier.verify`, not the cheap
approval snapshot reader. It:

1. traverses metadata and both filesystem trees to prepare exact structural
   totals and fingerprints;
2. hashes every required source payload again;
3. hashes every matching candidate payload again;
4. hashes allowed candidate extras where applicable;
5. rebuilds content coverage and exact missing-payload evidence; and
6. compares the new result with the reviewed result to require an unchanged
   candidate and purely additive source growth.

The progress denominator reports one decision per required source payload, so
the UI's 4,082 files / 3.34 GiB does not reveal that matching source and
candidate bytes are both streamed. The phase repeats substantially all of the
first expensive verification.

Complete-candidate adoption already uses
`AttachmentArchiveApprovalRevalidator`, whose structural snapshot contains no
payload-byte hashes. The new verified-behind path bypasses that optimization
and calls the full verifier because it must discover and obtain exact SHA-256
evidence for source entries added after review. This is a verified-behind
optimization regression introduced by the requested “full refresh,” not a
general failure of the earlier approval-fingerprint design.

### Smallest safe optimization

Do not attempt to infer additions from aggregate fingerprints alone. The
current evidence cannot safely do that.

Instead:

1. keep a private, process-local ordered structural entry index from the
   initial full verification; do not put it in UI state or the durable
   transaction;
2. under the existing uninterrupted adoption coordination, resolve both roots
   and run the cheap structural snapshot traversal;
3. require the candidate identity, fingerprint, totals, and entry structure to
   be exactly unchanged;
4. diff the source's ordered structural entries against the private reviewed
   index and require the delta to be additions only—no removal, replacement,
   metadata-reference change, type change, or modified existing entry;
5. fully hash and validate only the added source payloads, require each to be
   absent from the unchanged candidate, and append those exact path/size/hash
   obligations to the reviewed missing set;
6. reapply the 256-file/1-GiB bound and then switch and remediate.

This preserves the initial full content proof and approval-time freshness while
avoiding rehashing thousands of unchanged files. A structural fingerprint by
itself is explicitly not durable content authority, so the per-entry baseline
and hashes for additions are required.

The post-remediation `_proveFinalCoverage` is a separate, currently silent full
verification. Under today's architecture it remains the durable terminal proof
because no per-item success receipt replaces aggregate content authority. It
could later be optimized only with equally strong baseline and typed-installer
evidence; it must not be removed merely because all progress callbacks fired.

## 8. Missing terminal success presentation

The transaction did not remain nonterminal. The visible 39-item installation
finished at 14:58:28Z, but the adoption coordinator was still held at 15:01:17Z
and had released before the successful 15:06:18Z ordinary sweep. During that
interval the service was performing `_proveFinalCoverage`, which invokes a
second complete source/candidate verifier after remediation.

The remediation callback reports `39 of 39` before `_proveFinalCoverage`
starts. The workflow remains in `remediating`, and the final verifier receives
no UI progress callback. The UI therefore looks finished while silently
hashing the whole archive. Only after that pass succeeds and the transaction
is deleted does `adopted` map to `success`.

That unpresented finalization interval is the primary cause of the observed
missing-success experience: payload installation was complete, but the
operation was not yet logically complete.

There is also a secondary state-publication defect to correct. The pending
transaction provider is invalidated when remediation first begins, so it can
cache `activeRemediationPending`. On a successful adoption the workflow does
not invalidate/read that provider again after `clearPending`; it refreshes it
only for a `remediationPending` result. The immediate success assignment should
normally render, but the stale cache can reconstruct or later republish a false
pending state. Existing tests fake a static pending provider and do not cover
this real lifecycle.

### Required terminal presentation

After the last payload, explicitly transition to a **Verifying final
coverage…** state and show determinate verifier progress if the full pass is
retained. Then refresh the pending-transaction provider after the clear and
publish a stable success state:

```text
Attachment archive switched

CURRENT ARCHIVE
Toshiba_manual_bu · Connected
/Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive

All attachments are up to date.

Your original archive remains unchanged at:
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development/attachment_archive

Keep it for a few days while you confirm everything is working normally.

You're ready to continue using MessageLens.
```

Keep this state visible until the user navigates away or deliberately
dismisses/starts another action. Completion must never be communicated only by
the disappearance of a progress indicator.

**MISSING SUCCESS UI CAUSE:** the 39/39 callback preceded an unlabelled,
whole-archive final coverage pass; success could not publish until that pass
and transaction retirement completed, and the pending-transaction provider was
then left with a stale-cache risk.

## 9. Remediation preview feasibility

**PREVIEW POLISH FEASIBLE WITH EXISTING INFRASTRUCTURE: YES.**

The smallest approach is:

1. extend non-authoritative remediation progress with the current relative
   path (and optional inferred media kind), without exposing mutation
   authority;
2. update it after a payload is successfully installed and render from the
   active Toshiba destination, not from retained-source authority;
3. for image extensions, reuse the existing bounded `Image.file` presentation
   pattern with a small box, decode-size hints, an `errorBuilder`, and a key
   that releases the previous image when progress advances;
4. show the existing generic file representation for other types;
5. for video, use a thumbnail only if a new read-only lookup finds an already
   existing entry in `VideoThumbnailCache`; do not call the current
   `getOrCreateThumbnailPath`, because it may create cache directories and run
   thumbnail generation;
6. use no PDF/video generator, cache, or blocking pipeline for remediation.

Preview failure must be swallowed into the generic representation and must
never affect, delay, authorize, or cancel remediation. The correctness path
continues to use only typed transaction and installer evidence.

## 10. Runtime health

At the final audit check:

- PID `7989` remained in normal sleeping foreground state with low CPU and no
  crash/restart;
- the process had remained continuous since 07:36:07 PDT;
- the application log contained no adoption, remediation, Settings/provider,
  or platform exceptions;
- two warnings at 14:56:17Z and 15:01:17Z were expected fail-closed
  coordination denials of the periodic attachment sweep while adoption held
  `attachmentArchiveAdoption`;
- later periodic sweeps completed normally, most recently with 100 scanned,
  100 skipped, zero failed at 15:46:18Z;
- no pending adoption/maintenance/recovery record exists;
- readiness returned to `ready` after the operation;
- the development conversation graph contains 138,481 messages and its FTS
  index contains 138,481 searchable rows, so normal browsing/search backing
  stores are available.

## 11. Recommended corrections before further qualification

1. Add an explicit final-coverage workflow stage and determinate progress.
2. Refresh the pending-transaction provider after every successful transaction
   clear before publishing stable success.
3. Retain the terminal success view until navigation or deliberate dismissal.
4. Replace “received new attachments” with exact missing-from-copy wording.
5. Restore cheap approval revalidation for verified-behind adoption using a
   private per-entry baseline and hash only additive source entries.
6. Optionally retain a compact diagnostic-only completed-adoption receipt
   containing transaction ID, counts, bytes, paths, and completion time; it
   must not become configuration or mutation authority.
7. Treat the preview as independent polish after the correctness and terminal
   UX changes.

No correction requires relaxing the development gate, permitting production
adoption, using WD as fallback, or weakening final coverage.

## 12. Remaining acceptance tests

1. A real-provider verified-behind workflow test that drives a live pending
   transaction provider through absent → active → absent and proves the final
   state remains `success` rather than returning to pending.
2. A UI test for `39/39` → `Verifying final coverage…` → stable terminal
   success, including retained-original text.
3. A final-verification failure/interruption test proving Toshiba remains
   active, the transaction remains pending, and success is never claimed.
4. Approval-delta tests for one and multiple purely additive source entries,
   with byte hashing limited to those additions.
5. Fail-closed approval tests for candidate changes, source removal,
   replacement, metadata-only changes, type changes, symlinks, conflicts, and
   limit overflow.
6. A post-adoption ordinary-ingestion test proving the writable lease targets
   Toshiba and rejects WD or a stale generation.
7. A disconnected-Toshiba test proving unavailability and no WD fallback.
8. A preview test proving image decode failure and unsupported media never
   affect remediation outcome or retain previous payload state.
9. Repeat the development manual rehearsal after the corrections, keeping
   production adoption disabled.

## 13. Repository and mutation statement

This audit changed no application source, generated file, archive payload,
archive configuration, database, transaction, or runtime state. It created
only this required postmortem as an unstaged documentation file. No files were
staged or committed.
