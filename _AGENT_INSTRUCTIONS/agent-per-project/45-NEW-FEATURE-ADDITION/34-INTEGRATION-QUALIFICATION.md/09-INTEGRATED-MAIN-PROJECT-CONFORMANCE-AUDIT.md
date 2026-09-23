# Integrated `main` Project Conformance Audit

Date: 2026-09-23

## Scope

- Branch: `main`
- Audited HEAD: `55006b173082b710fd74cffe94a5c73bd1aac3db`
- Integration base: `7e8e6ea959ef1a3e078ee049159489d1ac3b6b8f`
- Feature 31 tip: `1693ce583927bd43b8e4b419618ff4bae020e78f`
- Feature 33 tip: `5529ff1470389e2fb5b4ddc3c16990a932204dc2`
- Feature 31 merge: `dad684a479fa6c7714d00bfe5ace064797288d3a`
- Generated-source-hash checkpoint: `fc344c57af9e5871e5c5817a4882745d03cf59c0`
- Feature 33 merge: `55006b173082b710fd74cffe94a5c73bd1aac3db`
- Accumulated implementation reviewed:
  `7e8e6ea959ef1a3e078ee049159489d1ac3b6b8f..55006b173082b710fd74cffe94a5c73bd1aac3db`
- Tracked unstaged/index changes included: none. Known unrelated untracked
  prompts, responses, editor settings, and Feature 34 working documents were
  excluded.

This is the whole-repository/pre-qualification audit required after both
corrected feature histories were integrated. It supplements the accumulated
Feature 31 and Feature 33 audits rather than replacing them.

## Instructions reviewed

- `AGENTS.md`
- `_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/README.md`
- `_AGENT_INSTRUCTIONS/agent-instructions-shared/10-language/dart.md`
- `_AGENT_INSTRUCTIONS/agent-instructions-shared/20-flutter/widgets.md`
- `_AGENT_INSTRUCTIONS/agent-instructions-shared/20-flutter/riverpod-provider-patterns.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/01-PROJECT/02-architecture-overview.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/07-CENTER-PANEL-LAYOUTS/00-center-panel-control-panels-and-infographics.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/00-all-databases-accessed.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/07-overlay-database-independence.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/13-apple-timestamp-conversion.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/40-feature-responsibilities.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md`
- Feature 31 architecture, implementation, rehearsal, and final-polish records
- Feature 33 architecture, phase, and final-qualification records
- `07-PRE-INTEGRATION-CONFORMANCE-CORRECTIONS.md`
- `MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`
- `08-INTEGRATE-CORRECTED-FEATURES-INTO-MAIN.md`

No governing-instruction conflict was found.

## Findings

### NO ISSUE — Cross-feature reuse and Settings ownership

`SettingsViewSpec` routes Attachment Archive and Environment through the
shared data-only `SettingsPanelRenderDescriptor`. The application coordinator
imports neither Flutter presentation nor either panel. The single Settings
presentation render router constructs both panels through their public feature
seams. The retired Attachment Archive sidebar workspace remains absent, and
both Settings entries remain center-only navigation destinations.

### NO ISSUE — Archive location and mutation authority

The attachment feature remains the only owner of active-root derivation,
bookmark resolution, location generation, writable-root lease issuance,
adoption authority, and remediation authority. Raw paths and passive location
snapshots carry no mutation capability. External custom roots remain
read/location-only unless the exact verified adoption transaction activates
them, every payload mutation revalidates typed authority, and destructive
reset remains unavailable for external roots. The retained source is used
only for transaction-bound remediation/recovery and is not an ordinary read
fallback.

The adoption execution gate remains fail-closed to the exact reviewed
MessageLens Development identity, canonical WD qualification root, and archive
instance. Production, FDA-experiment, and test identities remain rejected, and
there is no runtime override.

### NO ISSUE — Environment observation boundary

Environment owns no archive, root, database lifecycle, startup, import,
recovery, maintenance, or mutation authority. It consumes the admitted root,
an already-published passive attachment snapshot, already-live startup
telemetry when present, and bounded read-only evidence. Opening the page does
not initialize attachment location resolution or add a startup/onboarding
reverse edge.

The SQLite evidence repository is an infrastructure-owned, one-shot probe. It
opens only existing canonical database filenames with `OpenMode.readOnly`,
sets `PRAGMA query_only = ON`, validates every statement through the shared
read-only SQL guard plus a narrower PRAGMA allow-list, closes every handle,
and performs its synchronous work in a background isolate. It neither creates
missing databases nor uses persistent database providers as an alternate
lifecycle owner.

### NO ISSUE — Database, schema, path, and identity sources of truth

Feature 33 consumes `appDatabasePath`, `AppDatabaseFile`, the central schema
version constants, admitted archive authority, packed source identity, and
historical-source identity parsing. The source import, graph, overlay, and
Presence implementations now consume the same centralized schema constants;
the Environment read model does not redeclare them. No Apple timestamp
arithmetic was introduced; Environment reads the graph's canonical UTC date
text.

### NO ISSUE — Dependency direction and project idioms

Domain types carry immutable evidence only. Application providers coordinate
typed ports and read models. Filesystem, SQLite, platform package metadata,
clipboard, bookmark, and folder-chooser implementations remain in
infrastructure/native edges. Presentation renders aggregate state and invokes
typed actions. Riverpod providers are annotation-generated with
`hooks_riverpod`; generated outputs are tracked. Changed presentation uses
the semantic theme providers and shared spacing/typography rather than direct
Flutter or macOS theme lookup.

The architecture allowlist delta is narrow and explained: one read-only SQLite
probe, the attachment bookmark method channel, the archive folder chooser,
the bounded showcase timer, one verification metadata reader, and the two
pre-existing exact attachment-application `dart:io` exceptions. The exact
development path exception applies only to the reviewed qualification gate.

### NO ISSUE — Performance and bounded work

Ordinary location observation performs no recursive archive scan. Environment
uses aggregate SQL counts and per-contributing-source indexed packed-ID ranges,
does not materialize messages or contacts, and runs off the UI isolate. Archive
verification and approval remain deterministic and streamed; verified-behind
approval hashes only added preservation payloads and reapplies the 256-file/
1-GiB limit before remediation. Showcase state retains at most the current
item and one latest pending item, with bounded image decode hints and no
persistent media cache/history added by the feature.

### NO ISSUE — Privacy, logging, and data minimization

Environment copy is explicit and crosses a typed clipboard port. It includes
support-relevant admitted roots, active attachment path, canonical database
paths, identities, schema and aggregate counts, but excludes message/contact
content, bookmark bytes, attachment filenames/content, historical-source paths
and labels, logs, secrets, and raw rows. The local attachment showcase is
transient, does not log paths or filenames, does not persist history, and adds
no network access. No new ad-hoc logging or debug printing was introduced.

### NO ISSUE — Error and state semantics

Environment preserves loading, ready, unavailable, failed, not-retained, and
authoritative-zero states section by section. Attachment location distinguishes
connected, read-only, disconnected, permission-required, missing, and invalid
states. Adoption/remediation retains typed changed, unavailable, conflict,
pending-recovery, success, and final-coverage states rather than translating
unavailability into missing payloads or silent fallback.

### NO ISSUE — Dead/superseded machinery and native hygiene

The legacy mover, journal, staging/finalizer, capacity API, sidebar action
shell, generated providers, native disk-space bridge, and privacy declaration
remain absent. Production references to the former relocation terminology are
limited to backward-compatible parsing of the persisted legacy read-only
policy value. The bookmark bridge is registered once in `AppDelegate`, appears
once in the Runner Sources phase, and has disposable Runner XCTest coverage.
Production bundle identifier/product identity remain unchanged for Full Disk
Access continuity.

### NO ISSUE — Tests, generated/dependency hygiene, and documentation

Behavioral and architecture coverage protects typed authority, development
gating, exact archive-root ownership, no-fallback behavior, streamed/bounded
work, Settings render-edge ownership, passive Environment observation,
read-only SQL, clipboard ownership, progressive state, privacy boundaries,
accessibility, and mover absence. `unorm_dart` is used by deterministic NFC
collision detection and `fake_async` by bounded showcase timing tests. Release
metadata is coherent at `0.2.128+146`, and the changelog and final feature/
correction records agree with current behavior. Historical phase records were
preserved as history rather than rewritten.

### NO ISSUE — UX architecture

Attachment adoption remains one task-oriented center-pane workflow with the
sidebar as navigation. Environment is a read-only center-pane report with
progressive sections, collapsed technical detail, a secondary explicit copy
action, selectable wrapping paths, semantic headings/statuses, keyboard
activation, text-scale coverage, and no requirement that users understand
internal authority terminology.

## Checklist summary

- Reuse before invention: NO ISSUE
- Layering/ownership: NO ISSUE
- Dependency direction: NO ISSUE
- Single source of truth: NO ISSUE
- Project idioms: NO ISSUE
- Performance/bounded work: NO ISSUE
- Privacy/logging: NO ISSUE
- Mutation/authority safety: NO ISSUE
- State/error semantics: NO ISSUE
- Dead/superseded code: NO ISSUE
- Tests/architecture coverage: NO ISSUE
- Generated/dependency hygiene: NO ISSUE
- Documentation agreement: NO ISSUE
- UX conventions: NO ISSUE

Unresolved BLOCKER findings: 0.

Unresolved SHOULD FIX findings: 0.

OPTIONAL findings: 0.

## Validation supporting the audit

The reviewed corrected combined tree already had 487 architecture tests,
2,606 complete Flutter tests with one existing skip, 299 current Feature 31
focused tests, 115 Feature 33 focused tests, clean analyzer/generation/diff
checks, and clean submodule state. On integrated `main`, the intermediate
Feature 31 gate passed 478 architecture tests, 299 focused tests, and
`flutter analyze --no-pub`. A clean generator rebuild identified one
metadata-only Riverpod source hash refresh, checkpointed separately at
`fc344c57`; two whitespace-only Freezed artifacts were excluded.

Final integrated validation completed with:

- normal Riverpod/Freezed generation successful; its sole tracked result was
  the already-diagnosed whitespace-only blank-line artifact in
  `settings_view_spec.freezed.dart`, which was excluded, leaving no generated
  source or metadata difference;
- `flutter analyze --no-pub`: no issues;
- complete architecture suite: 487 passed;
- integrated Feature 31 focused matrix: 301 passed;
- Feature 33 focused matrix: 115 passed;
- complete serial Flutter suite: 2,606 passed with the one existing
  qualification skip;
- complete macOS Runner XCTest: 16 executed, 16 passed, 0 failures against a
  fresh disposable `/private/tmp` development root;
- the known Xcode post-test result-bundle finalization stall reproduced after
  the complete passing XCTest summary, remained stalled for more than 60
  seconds, and was interrupted with shell status 130; the disposable empty
  root was removed afterward;
- `git diff --check`: clean;
- production bundle identity unchanged at
  `com.bigbenchsoftware.MessageLens` / `MessageLens`;
- release metadata coherent at `0.2.128+146`, with the matching 0.2.128
  changelog entry and all final Feature 31, Feature 33, and correction records
  present; and
- shared instructions submodule unchanged and clean at
  `95326f515ef4719f155ce6e223990398daad6311`.

All Flutter and native filesystem tests used disposable fixtures. No real
database, attachment archive, bookmark configuration, mounted external
archive, or abandoned relocation artifact was accessed or modified. The
application was not launched and clean-slate human qualification did not
begin.

## Final verdict

`PROJECT CONFORMANCE: PASS`
