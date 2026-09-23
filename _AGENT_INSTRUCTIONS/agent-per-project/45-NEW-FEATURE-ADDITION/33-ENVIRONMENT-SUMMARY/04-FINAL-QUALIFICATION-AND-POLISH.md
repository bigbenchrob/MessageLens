# Environment Summary — Final Qualification and Polish

Date: 2026-09-22

Phase Three checkpoint: `044966260497e2bf39fcb2a3e066c3e019e390b5`
(`feat(environment): add copy environment summary`)

## Scope and result

The final pass requalified Feature 33 as a read-only Environment and
provenance surface and made three bounded presentation improvements:

1. **Copy Environment Summary** now uses a compact `TextButton.icon` treatment
   beside the page heading instead of a blue primary-action treatment.
2. The ordinary Contacts card now presents `Current Mac Contacts` and its
   aggregate counts without implementation-oriented database prose. The
   authoritative physical-source limitation moved to collapsed Technical
   Details and remains in copied support text.
3. Status-badge text can wrap under narrow, scaled-text constraints rather
   than overflowing horizontally.

No provider, repository, query, read model, formatter, navigation, archive,
database, startup, native, or authority behavior changed.

## Final page hierarchy

The ordinary page answers the intended questions in this order:

1. **This installation** — product, version, and environment.
2. **Data folder** — admitted volume, availability, and canonical root.
3. **Attachment archive** — active volume, availability/write state, and
   active path when available.
4. **Message data** — projected Messages, conversations, and attachment
   references.
5. **Contributing Message sources** — only sources with Messages in the
   current projected graph, including type, count, and date evidence.
6. **Contacts data** — `Current Mac Contacts` plus projected Contacts, linked
   handles, and imported channels.
7. **Technical Details** — support evidence, collapsed by default.

No new section or dashboard treatment was added.

## Copy-button decision

The copy action is a support convenience, not the page's primary purpose. The
final presentation therefore uses the existing `TextButton.icon` convention
already present in the Environment panel. It remains visibly labeled, near the
heading, and easy to discover without visually competing with the report.

The action remains explicit and uses the existing application action,
formatter, clipboard port, and system adapter. It is disabled only while a
copy is in flight. Tab focus plus Enter activation is covered by a widget
test. Success and failure continue to use bounded `SnackBar` feedback with
semantic labels.

## Contacts wording decision

The ordinary card now states the useful provenance level the application can
support: `Current Mac Contacts`. It does not mention or imply a physical
database path. The read-model field `physicalSourceIdentityRetained` remains
unchanged. Technical Details now presents:

`Contacts physical source identity: Not retained`

The pure formatter still emits:

`Contacts provenance: Current Mac Contacts; physical source identity not retained`

No Contacts physical provenance was invented or reconstructed.

## Message provenance qualification

The reviewed development result—one contributing `Live chat.db` source with
a range beginning 2014—is truthful for that graph. Feature 33 does not add the
unimported 2012–2013 source.

The evidence repository enumerates registered Message sources but adds a
source to the Environment aggregate only when its packed source-ID range has a
non-zero count in the current graph. Its disposable SQLite fixture registers
source ID 4 with zero projected contribution and proves that source is absent
from the result. Multiple contributing sources and a zero-contributor result
remain covered separately.

## Technical Details

Technical Details remains collapsed by default and contains only typed,
already-observed support evidence:

- environment, build identity, and runtime mode;
- bundle identifier and archive instance UUID;
- canonical admitted data root;
- active attachment root, state, generation, configuration mode, and write
  policy;
- startup installation state and admission basis;
- active maintenance state when applicable;
- Contacts physical-source retention state;
- relevant database roles and paths, presence/readability, actual and expected
  schema versions, sizes, and bounded issues;
- FTS availability/status and row count.

It contains no bookmark bytes, device nodes, secrets, tokens, logs, user
content, attachment filenames, retained previous archive, or raw debug dump.

## Clipboard qualification

The pure formatter and explicit-copy ownership path are unchanged. The copied
text retains these sections:

1. `Installation`
2. `Data folder`
3. `Attachment archive`
4. `Data`
5. `Technical`

It includes the admitted root, active attachment path/state, build and bundle
identity, archive instance UUID, startup evidence, database paths/schema/size,
and FTS evidence needed to diagnose stale-build or wrong-root incidents. It
preserves `Loading`, `Unknown`, `Unavailable`, `Not retained`, `Failed`, and
authoritative zero.

It excludes user Message/Contacts content, historical custom source labels
and paths, bookmark data, archive payload details, WAL/SHM paths, logs, and
other non-aggregate internals. Rendering the page performs no clipboard write.

## Progressive and partial states

Disposable provider and widget fixtures cover package metadata loading or
failure, an unpublished/loading attachment snapshot, disconnected and other
typed attachment states, graph unavailability, Contacts failure, FTS
unavailability, no contributing Message source, multiple contributors, and
authoritative zero counts. Identity and unrelated sections remain visible
while any one section settles or fails; there is no whole-page future or
spinner.

## Read-only purity

The final architecture and repository suites reconfirm that opening
Environment performs no archive traversal, attachment payload read, hash,
database/overlay write, bookmark persistence, location-generation change,
import/recovery/maintenance/adoption action, missing-database creation,
migration, or startup work. Copying adds only the explicit clipboard write.

The UI still watches `environmentSummaryProvider` as its sole environment-fact
source. Feature 31 attachment observation remains passive and does not
initialize `attachmentArchiveLocationProvider`.

## Production/development parity

Fixture-only tests render the same page architecture for:

- Development with an external admitted data root and attachment archive;
- Production with an admitted Application Support root and fixture attachment
  configuration.

No real production database/archive or real WD/Toshiba archive was read or
modified. Production archive adoption remains disabled.

## Accessibility and macOS behavior

Qualification covers:

- visible and semantic `Copy Environment Summary` labeling;
- Tab focus and Enter activation through the standard text button;
- semantic success and failure feedback;
- accessible Technical Details button/expanded state;
- semantic headings and textual status labels independent of color;
- selectable, wrapping long paths;
- a 460-point center panel at 150% text scaling without clipping or overflow;
- light and dark semantic theme colors.

## Files changed after the Phase Three checkpoint

- `lib/features/environment_summary/presentation/view/environment_summary_panel.dart`
- `test/features/environment_summary/presentation/view/environment_summary_panel_test.dart`
- `pubspec.yaml`
- `CHANGELOG.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/04-FINAL-QUALIFICATION-AND-POLISH.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/prompts/05-FINAL-QUALIFICATION-AND-POLISH.md`

## Release metadata

Because the final pass changes user-visible production presentation, the
version advances from `0.2.126+144` to `0.2.127+145`. `CHANGELOG.md` records
the compact action treatment, Contacts wording relocation, current-graph-only
provenance boundary, and unchanged safety guarantees.

## Validation

- final Environment panel suite: 23 passed;
- focused Feature 33/read-model/provider/clipboard/passive-observation/
  Settings-navigation/architecture matrix: 533 passed;
- complete repository suite: 2,622 passed, 1 existing qualification skip;
- `flutter analyze --no-pub`: no issues;
- Dart formatting: clean;
- `git diff --check`: clean;
- documentation/reference validation: canonical prompt, checkpoint, version,
  Feature 33 numbering, and clipboard-ownership references are consistent;
- native tests: not applicable because no native code changed.

## Deferred ideas

Reveal in Finder, per-path copy, archive switching, retained WD presentation,
import management, environment switching, database repair/health scans,
source deletion, onboarding Attachment Showcase integration, archive-adoption
qualification, and generic diagnostics remain out of scope. None was begun.

## Merge readiness

Feature 33 is ready to merge after this unstaged final-polish diff is reviewed
and checkpointed. No mandatory stop gate was encountered.
