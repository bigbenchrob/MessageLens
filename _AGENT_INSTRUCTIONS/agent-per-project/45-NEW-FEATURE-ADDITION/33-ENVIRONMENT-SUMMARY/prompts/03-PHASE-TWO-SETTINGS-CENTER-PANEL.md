# Feature 33 — Environment Summary
## Prompt 03 — Phase Two: Settings Center Panel

Phase One is reviewed and approved. Read in full:

- `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/00-ARCHITECTURE-AUDIT-AND-DESIGN.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/01-PHASE-ONE-PURE-OBSERVATION-AND-READ-MODEL.md`

Treat their decisions, purity boundaries, terminology, and V1 scope as authoritative. This phase adds the Settings navigation and center-panel presentation over the Phase One read model. Do not bypass `environmentSummaryProvider` to rediscover environment facts in widgets. Do not add Clipboard invocation yet; that remains Phase Three. Do not add Reveal in Finder, schema/migration changes, startup work, or environment mutation.

## Step 0 — checkpoint Phase One

Expected branch: `feature/environment-summary`. Expected pre-commit HEAD: `84f0d3f0fcea3d3b752a125632254561a270ddae`. Inspect the complete Phase One diff, verify it agrees with the Phase One decision record, stage only intended Phase One production/generated code, tests, architecture changes, documentation and Prompt 02, leave unrelated untracked files untouched, run `git diff --cached --check`, and commit. Suggested message: `feat(environment): add pure environment summary foundation`. Do not push. Report the commit hash before continuing.

## Phase Two objective

Implement `Settings → Environment` as a read-only center-panel page using the established Settings menu → flow state → `SettingsViewSpec` → coordinator/resolver route. The sidebar is navigation only. The page answers: **What MessageLens installation am I running, where is its data, and what data contributed to it?**

The first screenful must show, in this order: **This installation**, **Data folder**, **Attachment archive**. Below those show **Message data**, **Contacts data**, and a default-collapsed **Technical Details** disclosure.

### This installation
Show product name, semantic version/build when available, and ordinary environment label (Production/Development/etc.). Version failure must not hide admitted identity. Put bundle ID, archive UUID, build identity and runtime mode in Technical Details.

### Data folder
Show the admitted primary root from the read model, e.g. `WD_ELEMENTS · Connected` plus the full selectable wrapping path. For Application Support use `This Mac` where that is the truthful model value. Never call a default root “Internal”. Do not invent read/write, filesystem type, device node or volume UUID.

### Attachment archive
Use only `EnvironmentAttachmentArchiveSummary`. Show volume/status, full selectable path, and read/write or read-only only when typed evidence proves it. Map disconnected, permission-required, folder-missing, invalid and unknown distinctly. Do not expose `defaultInternal`, `customExternal`, `activeArchive`, generation or bookmark terminology in ordinary UI. Do not show the retained WD pre-adoption archive. If the passive Feature 31 snapshot has not yet been published, show a bounded “status not available yet” state; do not initialize attachment resolution.

### Message data
Show aggregate `Messages in MessageLens`, Conversations, and attachment references only with the exact Phase One semantics. Do not call projected records “unique messages”. Then show compact cards for each current contributing Message source. Distinguish Current Mac Messages and historical Messages archives. Cards may show projected count and independently loading earliest/latest dates. Historical `chat.db` identity may appear as secondary detail because the registry proves it, but do not infer current drive availability. Never call registry creation or optional workflow completion the original import date. Omit registered sources with zero current projected Messages.

### Contacts data
Show one aggregate **Current Mac Contacts** card with projected contact count, linked handles and imported channels where useful. Include a quiet note that MessageLens does not retain the physical Contacts database that contributed those records. Do not display the currently discoverable AddressBook path as provenance and do not invent multiple Contacts source cards.

### Progressive loading and failure isolation
Render immediate authority/root evidence first. Package metadata, database metadata, Message counts/sources/date ranges, Contacts aggregates and FTS settle independently. No whole-page spinner and no monolithic future. Preserve `Loading`, `Unknown`, `Unavailable`, `Not retained`, `Failed`, and authoritative zero as distinct states. One failed section must not blank the others.

### Technical Details
Default collapsed. Show only fields already in the Phase One model: environment, build identity, runtime mode, bundle ID, archive instance UUID, canonical admitted root, attachment canonical/display root, attachment generation/mode/write policy, startup admission state/basis, maintenance state when active, current database summaries, and FTS status/count. Database rows should use human-readable roles and show full path, present/missing/unreadable, size, and actual/expected schema when available. Do not list WAL/SHM or retired databases. Do not expose bookmark bytes, device nodes, logs, user content, retained WD path, or physical Contacts source path.

### Paths and visual design
Paths wrap and are selectable; avoid ellipsis-only truncation. Do not add per-path Copy buttons or Reveal in Finder. Reuse `CenterPanelReportLayout`, `AppSpacing`, semantic theme colors/typography, existing disclosures and section/card conventions. Do not import Feature 31 private widgets or create a new design system. Verify light/dark behavior using semantic colors.

### Accessibility
Provide semantic labels for headings, connected/disconnected/read-only states, loading/unavailable states, Message source identity, and disclosure state. Do not encode status solely by color.

## Navigation architecture
Add one persistent `Environment` Settings menu action under the existing Support grouping unless current established topology has an unequivocally better existing group. Add the corresponding `SettingsViewSpec` case and coordinator/resolver route. The sidebar utility child remains null/navigation-only. Do not create a bespoke window, modal, sidebar report body, or alternate navigation stack.

## Strict Phase One boundary
Widgets/resolvers consume the Phase One read model/provider only. They must not import SQLite repositories, PackageInfo, filesystem APIs, attachment location controllers/native adapters, database providers, archive authority construction, import/recovery/maintenance actions, writable leases, or adoption services. Presentation must not become a second authority.

## No Phase Three actions yet
Do not add `Clipboard.setData`, Copy Environment Summary button behavior, individual copy buttons, or Reveal in Finder. The pure formatter already exists; Phase Three will wire the explicit clipboard action. If layout benefits from reserving a natural action area, it may exist without a functional control only if that is consistent with existing UI conventions; otherwise omit it entirely.

## Tests
Add focused tests for: stable Environment menu row; persistent Settings context; exact ViewSpec dispatch; sidebar remains navigation-only; immediate first paint from synchronous evidence; progressive independent section updates; package metadata failure isolation; attachment snapshot absent/connected/read-only/disconnected/permission/missing/invalid; Message aggregate/source cards; zero-row registry source absent from presentation; independently loading source date ranges; Contacts aggregate plus provenance limitation; Technical Details collapsed by default and accurate when expanded; long selectable/wrapping paths; Unknown/Unavailable/Not retained distinctions; database schema mismatch presentation without mutation; FTS unavailable; light/dark semantic tokens; accessibility semantics; production/development fixtures.

Add/extend architecture tripwires proving the UI imports only the approved Feature 33 read-model/provider seams, has no database/filesystem/archive mutation dependencies, adds no startup/main/onboarding references, and does not initialize Feature 31 attachment resolution.

Run at minimum: Riverpod/freezed generation if needed; focused Feature 33 navigation/presentation tests; Phase One purity/read-model tests; affected Settings/sidebar regressions; Feature 31 passive-observation regressions; architecture suite; `flutter analyze --no-pub`; full repository suite; `git diff --check`; documentation/reference validation. Native tests only if native code changes (none expected).

## Documentation
Create `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/02-PHASE-TWO-SETTINGS-CENTER-PANEL.md`. Document navigation reuse, page hierarchy, ordinary vs technical fields, progressive loading, partial/error states, path presentation, accessibility, tests, deviations, and Phase Three handoff. Save this prompt as `prompts/03-PHASE-TWO-SETTINGS-CENTER-PANEL.md`. Do not update release metadata yet unless repository conventions require it for implemented user-facing work; if they do, report the exact convention and make the smallest truthful update.

## Stop-and-report gates
STOP AND REPORT rather than work around the architecture if: the UI needs to bypass `EnvironmentSummary`/approved providers; opening the page would initialize mutation-capable attachment resolution; a desired field requires archive traversal/payload I/O; Settings integration requires a parallel navigation system; truthful Message source cards require new provenance persistence; Contacts presentation would require invented physical provenance; the page requires database writes/migrations; a section failure cannot be isolated without collapsing the whole model; startup work becomes necessary; real production data or real WD/Toshiba archive access becomes necessary.

## Completion state
Leave all Phase Two changes unstaged. Do not commit or push. Do not begin Phase Three clipboard integration. Do not modify real archives/databases. Report: Phase One commit hash; branch/HEAD; files changed; navigation/ViewSpec implementation; exact first-screenful presentation; Message source presentation; Contacts limitation presentation; Technical Details contents; progressive loading/error behavior; tests and validation; any stop gate; complete Git status; confirmation no startup work, database/archive mutation, production access, retained-source invention, Contacts provenance invention, or Phase Three action was introduced. Then STOP.
