# Environment Summary — Phase Two Settings Center Panel

## 1. Outcome

Phase Two adds a stable, read-only `Settings → Environment` destination over
the Phase One `EnvironmentSummary` read model. The Settings sidebar remains
navigation only; the Environment feature owns the center-panel presentation.

This phase adds no Clipboard or Finder action, startup work, database schema or
migration, archive traversal, attachment-location initialization, or mutation
authority. All Phase Two work remains unstaged for review.

Phase One was checkpointed before this implementation:

- commit: `602893f815d8035827c1c371c5c94b5b5365639d`
- subject: `feat(environment): add pure environment summary foundation`
- branch: `feature/environment-summary`

## 2. Navigation reuse

The implementation extends the existing Settings route without introducing a
parallel stack:

1. `SettingsMenuActionId.environment` is a durable action under **Support**.
2. Choosing it records the persistent Settings context.
3. `SidebarFlowState.projectedSettingsCenterSpec` produces
   `SettingsViewSpec.environmentSummary()`.
4. The Settings `ViewSpecCoordinator` delegates to
   `EnvironmentSummaryPanelResolver`.
5. The resolver imports only the Environment feature's public seam and returns
   `EnvironmentSummaryPanel`.

The stable sidebar topology returns `null` for Environment. No report card,
submenu, modal, separate window, or stored center-stack entry is created.

## 3. Ownership and dependency boundary

`EnvironmentSummaryPanel` is owned by Feature 33 and watches only
`environmentSummaryProvider` for environment facts. It does not import or
watch the underlying package, root, database, Message, Contacts, FTS,
attachment-location, or archive-authority evidence providers.

The presentation has no filesystem, SQLite, PackageInfo, native bookmark,
attachment controller, database-provider, writable-lease, adoption,
maintenance-action, recovery, or import dependency. In particular, opening
the page does not initialize Feature 31 attachment resolution. It displays an
already-published passive snapshot or a bounded status-not-available state.

## 4. Page hierarchy

The center panel uses `CenterPanelReportLayout` with full-width sections. The
first screenful is ordered:

1. **This installation**
2. **Data folder**
3. **Attachment archive**

The remaining vertical order is:

4. **Message data**
5. **Contacts data**
6. **Technical Details**, collapsed by default

The panel is scrollable, width-bounded, and uses `AppSpacing` plus semantic
theme surfaces, content colors, borders, and status colors. Paths are rendered
as wrapping `SelectableText`; they have no ellipsis-only truncation.

## 5. Ordinary fields

### This installation

The first card shows product name, semantic version/build when available, and
the ordinary environment label. Missing or failed package metadata is rendered
as its typed status and never hides the synchronously admitted identity.

### Data folder

The card shows the read-model volume label, typed availability badge, and full
canonical admitted root. It does not rename an Application Support root to
“Internal” and does not invent writability, device, filesystem, or volume UUID
facts.

### Attachment archive

This card consumes only `EnvironmentAttachmentArchiveSummary`. It distinguishes
connected read/write, connected read-only, disconnected, permission required,
folder missing, invalid, unknown, and a not-yet-published snapshot. Ordinary UI
does not expose configuration enum names, write-policy enum names, generation,
bookmark terminology, or the retained pre-adoption archive.

### Message data

The aggregate metrics retain their exact meanings:

- Messages in MessageLens;
- Conversations;
- Attachment references.

Contributing-source cards distinguish Current Mac Messages from historical
Messages archives. Each card uses the current projected Message count and an
independent date-range status. A registry-proven historical `chat.db` path may
appear as selectable recorded identity, without claiming current drive
availability. The Phase One evidence repository omits sources with zero
current projected Messages; presentation fabricates no fallback source row.

### Contacts data

One **Current Mac Contacts** card shows the available aggregate projected
Contact, linked-handle, and imported-channel counts. A quiet note states that
MessageLens does not retain the physical Contacts database that contributed
the records. No discoverable AddressBook path or multi-source provenance is
invented.

## 6. Technical Details

The disclosure is collapsed by default and exposes its expanded/collapsed
state to accessibility services. When expanded it renders only Phase One
model fields:

- environment, build identity, and runtime mode;
- bundle identifier and archive instance UUID;
- canonical admitted data root;
- attachment canonical/display root, typed state, generation, mode, and write
  policy;
- startup installation state and admission basis;
- maintenance state only when active;
- current database role, full path, presence/readability, byte size, and
  actual/expected schema;
- FTS availability and count.

Schema mismatch is a warning presentation only. No repair or migration action
is reachable. WAL/SHM files, retired databases, bookmark bytes, device nodes,
logs, user content, retained WD paths, and Contacts source paths are absent.

## 7. Progressive and partial states

The page always renders one stable hierarchy from the synchronous aggregate.
Admitted identity and root therefore appear on first paint while package,
database, Message, date-range, Contacts, and FTS evidence settles
independently. The passive attachment summary can also arrive later without
replacing the page.

Value helpers keep these states distinct:

- `Loading`;
- `Unknown`;
- `Unavailable`;
- `Not retained`;
- `Failed`;
- authoritative numeric zero.

A section-local issue remains inside its section. There is no whole-page
spinner or monolithic future.

## 8. Accessibility

The title and card headings are semantic headers. Location cards and badges
carry textual state labels in addition to icons and colors. Message source
cards identify source type, label, count, and date status. Metrics include
label/value semantics, and Technical Details exposes a semantic button and
expanded state. Status is never encoded solely by color.

## 9. Regression and architecture coverage

Focused tests cover:

- stable Support-menu placement and persistent intent;
- exact flow-state and `SettingsViewSpec` projection;
- null sidebar child and Settings center-host dispatch;
- resolver ownership through the Environment public seam;
- first-screenful order and collapsed disclosure;
- synchronous identity/root first paint and independent model updates;
- package failure isolation and passive attachment absence;
- connected read/write, read-only, disconnected, permission-required,
  missing, and invalid attachment states;
- Message aggregates, current/historical source cards, independently loading
  dates, authoritative zero, and no invented empty source;
- Contacts aggregates and the physical-provenance limitation;
- long selectable paths;
- Unknown, Unavailable, and Not retained distinctions;
- database schema mismatch and unavailable FTS presentation;
- semantic light/dark colors and accessibility labels;
- production/development fixtures using the same page shape.

Architecture tripwires prove that Settings reaches the page only through the
Feature 33 public seam, the presentation consumes only the aggregate provider,
forbidden filesystem/database/archive mutation dependencies remain absent,
Feature 31 resolution is not initialized, and no startup, `main.dart`, or
onboarding reverse edge was added.

## 10. Release metadata

Repository convention requires significant user-facing work to update both
`pubspec.yaml` and `CHANGELOG.md`. The smallest truthful update advances the
version from `0.2.124+142` to `0.2.125+143` and records the read-only Settings
destination plus its safety boundary.

## 11. Phase Three handoff

Phase Three may wire the existing pure `EnvironmentSummaryFormatter` to one
explicit Copy Environment Summary action. It must preserve the same aggregate
read boundary and privacy exclusions. Per-path copy actions and Reveal in
Finder remain out of scope unless separately approved.

Phase Two intentionally provides no Clipboard invocation or placeholder
control.
