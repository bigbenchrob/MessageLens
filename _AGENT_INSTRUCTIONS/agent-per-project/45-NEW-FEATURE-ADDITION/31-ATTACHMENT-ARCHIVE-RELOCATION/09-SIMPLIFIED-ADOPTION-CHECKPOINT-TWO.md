# Simplified Adoption — Checkpoint Two Candidate Verification Core

**Status:** implemented and validated on 2026-09-18

**Checkpoint One commit:**
`e4a3625832def2f70cbb1c4bd133369e9fbfac47`

## 1. Scope and authority boundary

Checkpoint Two implements only the pure, read-only comparison between the
current authoritative attachment archive and a user-supplied candidate archive.
It returns process-local typed evidence for a later adoption checkpoint.

The implementation is deliberately disconnected from Settings and ordinary
runtime composition. It cannot:

- copy, move, rename, create, repair, or delete archive entries;
- create probe files or infer writability by attempting a write;
- persist archive configuration or activate `customExternal`;
- mint mutation or configuration authority;
- create, resume, alter, or delete a relocation/adoption journal; or
- inspect or mutate the parked relocation operation.

All automated verification uses disposable temporary directories and an
in-memory overlay database. Neither the development nor production archive is
an acceptance-test input.

## 2. Typed result vocabulary

`AttachmentArchiveCandidateVerificationResult` is sealed and exposes exactly
these outcomes:

- `candidateComplete`;
- `candidateBehind`;
- `candidateInvalid`;
- `sourceUnavailable`;
- `candidateUnavailable`; and
- `verificationFailed`.

`candidateComplete` is the only outcome a future checkpoint may consider for
adoption. It does not itself authorize a configuration write. Candidate
conflicts take precedence over missing source payloads, so a conflicting copy
is never described as merely behind.

The result context records the requested roots, any canonical identities
resolved before failure, source configuration, source generation, UTC check
time, and native candidate-writability evidence supplied by the future caller.
The verifier does not probe for writability. A complete result can therefore
be displayed as read-only evidence, but Checkpoint Three must require current
writable availability before any later adoption transaction.

Complete, behind, and post-traversal invalid results carry evidence containing:

- source and candidate canonical identities;
- source configuration and generation;
- UTC verification time and candidate-writability evidence;
- required source physical file count and bytes;
- verified file count and bytes;
- metadata reference count;
- unreferenced preservation count;
- source and candidate operational-debris counts;
- allowed candidate-extra count and bytes;
- missing count and bytes;
- bounded missing, conflict, extra, debris, and source-anomaly examples;
- a content-coverage digest; and
- separate source and candidate structural snapshot fingerprints.

No ready result is persisted.

## 3. Grouped metadata evidence

`OverlayAttachmentArchiveVerificationMetadataReader` owns the shared,
SELECT-only metadata extraction. It pages groups in strict
`archive_relative_path` order and exposes both bounded pages and exact-path
lookups. Every group preserves its total compatibility-row/reference count.

The reader:

- validates safe, normalized, root-relative archive paths;
- rejects conflicting `file_size_bytes` values;
- rejects conflicting non-null `content_hash` values;
- validates non-null hashes as lowercase SHA-256;
- allows null hash evidence when all non-null values agree; and
- never updates, inserts into, or deletes from overlay data.

The legacy relocation metadata reader remains only as a compile-time adapter to
this shared verification reader. The new verifier has no dependency on the old
mover service or state machine, and the grouped SQL is not duplicated.

## 4. Read-only traversal and preservation classification

Both roots are canonicalized as existing readable directories. A symlink root
is rejected before resolution. Source and candidate must be different canonical
directories and must not contain one another.

Traversal uses `followLinks: false`, sorts one directory at a time by lexical
basename, and performs depth-first enumeration. This bounds traversal memory by
the largest individual directory. Exact-path inspection rejects link
components, wrong-case or otherwise non-exact resolution, directories where a
file is required, special entries, and missing required paths. Sibling names
that collide after NFC normalization and lowercasing fail closed.

Source files are classified as one of:

1. metadata-known preservation payload;
2. valid content-addressed unreferenced preservation payload;
3. valid legacy `_by_id` unreferenced preservation payload; or
4. exact known installer debris.

Unknown source shapes, source symlinks, source special entries, metadata
conflicts, source size conflicts, and source hash contradictions produce
`verificationFailed`; they are not omitted to manufacture a complete result.

The content-addressed shape is exactly a two-character lowercase-hex directory
followed by a 64-character lowercase SHA-256 filename, optionally with a safe
one-to-sixteen-character alphanumeric extension. The directory prefix must
equal the first two hash characters. Actual payload SHA-256 must match the
filename identity.

The legacy shape is exactly `_by_id/<numeric-id>` with the same optional safe
extension. It remains preservation data even without current metadata.

Installer debris is recognized only when its basename matches the existing
canonical hidden temporary form:

```text
.<valid-preservation-target>.messagelens-install-<lowercase-v4-uuid>.tmp
```

Reconstructing the target name must itself produce a supported unreferenced
preservation path. Near matches are unknown and fail closed. Recognized debris
is reported but is neither required coverage nor deletion authority.

## 5. Coverage and candidate extras

Every required source payload is streamed through SHA-256 in one-mebibyte
chunks. The candidate is inspected at the exact same relative path:

- absent becomes `candidateBehind` evidence;
- a link, special entry, directory, spelling mismatch, size mismatch, or hash
  mismatch is a candidate conflict;
- a metadata hash, when present, must match both payloads; and
- otherwise source and candidate hashes must match each other.

Candidate traversal then classifies files not present in the source. Valid
content-addressed extras are accepted only after the content matches the
filename hash. Valid legacy `_by_id` extras are hashed and preserved. Exact
installer debris is reported. Any other extra, ambiguous sibling, link, special
entry, or invalid hash-named payload produces `candidateInvalid`.

Empty safe directories do not affect coverage. Diagnostic lists default to the
first 100 deterministic examples per category; exact counts and byte totals are
not capped.

## 6. Evidence encoding

All three evidence digests are SHA-256 streams of unambiguous, length-prefixed
UTF-8 fields. Each field is encoded as its UTF-8 byte length, a colon, its text,
and a semicolon. Null is encoded explicitly. Contract headers version each
stream.

The content stream begins with
`messagelens-archive-content-coverage-v1`. In deterministic source order it
records each required payload's path, classification, source and candidate
sizes, metadata hash, actual source and candidate hashes, and metadata reference
count. It also records classified source debris. Candidate traversal appends
allowed or invalid extras with their actual hash and disposition, plus
classified candidate debris.

The source structural stream begins with
`messagelens-source-structural-snapshot-v1`; the candidate stream begins with
`messagelens-candidate-structural-snapshot-v1`. Each includes root modification
and change timestamps. Source grouped metadata evidence is recorded in ordered
pages before source entries. Every traversed directory or file contributes its
relative path, entity type, size, modification time, change time, and
classification. The candidate stream likewise includes every safe traversed
entry and its classification.

Structural fingerprints intentionally do not hash payload bytes. The strong
coverage digest proves the full comparison; fingerprints are the bounded-memory
O(number of entries) recheck material for Checkpoint Three. The supported model
detects ordinary changes. A hostile actor that replaces bytes while preserving
all path, size, and filesystem timestamp evidence remains outside that model and
would require a full rehash at activation.

Source configuration, source generation, canonical identities, and candidate
writability are typed result fields rather than inputs to the filesystem
fingerprints. Checkpoint Three must compare them independently.

## 7. Ephemeral progress and cancellation

The application interface accepts optional progress and cancellation callbacks.
Progress reports the current metadata, source-coverage, or candidate-extras
phase plus streamed files and bytes checked. Cancellation throws the typed
`AttachmentArchiveCandidateVerificationCancelled` exception. Neither mechanism
persists state or performs cleanup because verification creates no filesystem
state.

## 8. Files introduced or adapted

The checkpoint adds:

- the candidate-verification domain result and evidence types;
- the read-only verifier application interface;
- grouped verification-metadata types and reader interface;
- the overlay grouped-metadata repository;
- the filesystem candidate verifier;
- focused repository and verifier tests; and
- architecture tripwires for the read-only/disconnected boundary.

It adapts the legacy relocation metadata reader to the shared implementation
without connecting the legacy mover to runtime composition.

`unorm_dart` is used only for deterministic NFC sibling-collision checks.

## 9. Validation coverage

The disposable test matrix covers:

- complete, behind, invalid, unavailable, and failed outcomes;
- duplicate metadata references, null hashes, conflicting sizes/hashes, safe
  path validation, stable paging, and read-only overlay behavior;
- metadata-known, content-addressed, legacy `_by_id`, exact debris, candidate
  extras, unknown shapes, and debris near misses;
- symlink roots/components, special entries, same/nested roots, exact spelling,
  case/NFC ambiguity detection, size conflicts, and hash conflicts;
- deterministic digests, path/payload/classification changes, source and
  candidate structural changes, metadata changes, timestamps, source
  configuration, and generation evidence;
- diagnostic caps with exact uncapped totals;
- bounded metadata pages and streamed hashing;
- ephemeral progress and cancellation; and
- architecture restrictions against mutation, Settings/public routing, parked
  operation access, and legacy runtime dependencies.

Checkpoint validation also runs the prior attachment feature tests, architecture
tests, analyzer, full Flutter suite, and diff checks.

## 10. Deliberate platform seams

Canonical identity is represented by the fully resolved canonical path in this
checkpoint. A later macOS caller supplies a bookmark-resolved candidate path;
the verifier never treats a display path as bookmark authority.

Candidate physical writability is also supplied as bounded native evidence. It
is recorded, not inferred by access-bit heuristics or a write probe. The later
adoption transaction must resolve the bookmark again and require current
available/writable native status.

## 11. Checkpoint Three handoff

Checkpoint Three may start from a process-local `candidateComplete` result. It
must first acquire the existing archive mutation coordinator using a narrowly
named adoption operation, then re-read and compare the active source
configuration, generation, and canonical source/candidate identities. While the
coordinator remains held, it must recompute both structural/metadata
fingerprints and all relevant totals without reusing a stale manifest.

Any mismatch discards readiness and returns a typed “check again” result without
changing configuration. Only unchanged evidence may proceed toward the separate
verified-adoption authority and small reversible configuration transaction
described in the design.

Checkpoint Three must not treat this verifier result as a permit. Settings
integration, activation, bookmark persistence, configuration writes, pending
transaction recovery, and legacy mover deletion remain outside Checkpoint Two.
