# Feature 33 --- Environment Summary

## Prompt 05 --- Phase Three Checkpoint and Final Qualification / Polish

Phase Three has been reviewed and approved.

The real development screenshot and copied Environment Summary were
reviewed. The Message provenance shown there is correct: this
development environment did **not** import the 2012--2013 historical
Messages source, so showing one contributing source (`Live chat.db`)
beginning January 1, 2014 is truthful. Do not investigate or "restore" a
missing historical source.

This prompt should checkpoint Phase Three, then perform a small final
Feature 33 qualification/polish pass. Do not add new product scope.

------------------------------------------------------------------------

# 1. Checkpoint Phase Three

Expected branch: `feature/environment-summary`

Expected HEAD before Phase Three commit:
`fd046353639b48d1c40ad12850b9e05b03492156`

Phase Three is currently entirely unstaged.

Before committing: 1. inspect the complete Phase Three diff; 2. verify
it agrees with the Phase Three implementation record and Prompt 04; 3.
verify no unrelated changes are mixed in; 4. stage only intended Feature
33 Phase Three production/generated code, tests, architecture tests,
documentation, `pubspec.yaml`, and `CHANGELOG.md`; 5. leave all
unrelated untracked artifacts untouched; 6. run
`git diff --cached --check`; 7. commit.

Suggested commit message:
`feat(environment): add copy environment summary`

Do not push. Report the resulting commit hash before continuing.

------------------------------------------------------------------------

# 2. Final Feature 33 objective

Perform a focused final qualification and modest UI polish of the
existing Environment page.

Do NOT redesign the feature. Do NOT add new environment authority,
provenance, schema/migration work, startup work, Finder integration, or
per-path copy controls. Do NOT access production data or alter Feature
31 attachment authority or the real WD/Toshiba archive state.

The feature remains **READ-ONLY ENVIRONMENT AND PROVENANCE
PRESENTATION.**

# 3. Preserve proven Message provenance behavior

The development screenshot showed 138,521 Messages in MessageLens, one
contributing source, `Live chat.db`, `Current Mac Messages`, and a date
range beginning January 1, 2014.

This is correct because the older 2012--2013 source was never imported
into this development environment.

Preserve the rule: **Environment shows sources that actually contribute
to the current projected graph.**

Do not show sources merely registered elsewhere but contributing zero
current projected Messages, sources from another installation, sources
known from documentation/history, or hypothetical historical sources.
Add or retain tests proving zero-contribution registry sources remain
absent.

# 4. Review Copy Environment Summary button prominence

The current screenshot places a full-width blue
`Copy Environment Summary` button immediately below the Environment
heading.

The action is useful, but it is a support convenience rather than the
page's primary purpose.

Audit existing macOS/MessageLens Settings button conventions and make
the smallest visual adjustment needed so the action does not dominate
the page.

Preferred outcome: - easy to discover; - accessible; - ordinary
macOS-style action rather than a giant primary CTA; - positioned
naturally near the heading or introductory text; - no new toolbar
architecture; - no icon-only ambiguity.

Do not change action semantics or remove it. If the existing full-width
presentation is actually the established Settings convention, document
that and leave it unchanged.

# 5. Review Contacts provenance wording

The current ordinary-user card says:
`MessageLens does not retain the physical Contacts database that contributed these records.`

This is truthful but implementation-oriented. Review whether the
ordinary card can communicate the useful fact more simply,
e.g. `Current Mac Contacts` with aggregate counts beneath it.

The physical-source limitation may move to Technical Details if that is
cleaner.

Requirements: - never imply physical Contacts provenance that is not
retained; - never invent a database path; - preserve the limitation in
the read model; - preserve it in Copy Environment Summary; - do not
sacrifice truth merely to shorten the UI.

Choose the smallest improvement and document the decision.

# 6. Review ordinary-page information hierarchy

Confirm the page answers, in order: 1. Which MessageLens is this? 2.
Where is its primary data folder? 3. Where is its active attachment
archive? 4. How much Message data does this environment contain? 5.
Which Message sources actually contribute? 6. What Contacts data does it
contain? 7. Where can support/technical detail be found?

Do not add more sections merely because data exists. Keep Technical
Details collapsed by default.

# 7. Technical Details qualification

Confirm collapsed Technical Details contains only authoritative, cheap,
diagnostically useful fields such as environment/build identity, bundle
identifier, archive instance UUID, admitted primary root, active
attachment state/generation, startup admission evidence, relevant
database paths, actual/expected schema versions, database sizes, and FTS
status/count.

Do not turn it into a raw debug dump. Do not expose bookmark bytes,
device nodes, secrets/tokens, user content, attachment filenames, or
logs.

# 8. Clipboard output qualification

Preserve the pure formatter and explicit-copy action. Confirm the output
sections remain: - Installation - Data folder - Attachment archive -
Data - Technical

Confirm it can diagnose the stale-build/wrong-root incident without
screenshots. Preserve explicit support paths and typed distinctions such
as Loading, Unknown, Unavailable, Not retained, Failed, and
authoritative zero.

Do not add user-content fields, historical custom source labels/paths,
or clipboard writes on page open.

# 9. Progressive/partial-state qualification

Exercise disposable/provider fixtures for package info loading,
attachment snapshot not yet published, attachment disconnected, graph
unavailable, Contacts failure, FTS unavailable, zero historical Message
sources, multiple contributing Message sources, and authoritative zero
counts.

The page must remain useful when one section is unresolved. No
indefinite whole-page spinner. One section failure must not blank
unrelated sections.

# 10. Read-only purity requalification

Re-run/extend Phase One purity coverage as necessary. Opening
Environment must still cause zero archive traversal, payload reads,
hashes, database writes, overlay writes, bookmark persistence
attributable to Environment, location-generation changes,
import/recovery/maintenance/adoption actions, missing-database creation,
schema migration, and startup work.

Copying the summary adds only the explicit clipboard write.

The UI must consume `environmentSummaryProvider`; it must not bypass the
read model for environment facts.

# 11. Production/development parity

Using fixtures only, confirm the same architecture renders truthfully
for Development with an external admitted root/archive and Production
with its admitted Application Support root and fixture attachment
configuration.

Do not enable production archive adoption or access real production
data.

# 12. Accessibility and macOS behavior

Check keyboard focus and accessible labeling for Copy Environment
Summary, success/failure announcement, Technical Details disclosure
accessibility, text scaling/wrapping for long paths, narrow center-panel
behavior, and clipping at supported window sizes.

Prefer existing project/macOS conventions.

# 13. No new scope

Do not add Reveal in Finder, per-path Copy buttons, archive switching,
retained WD display, import management, environment switching, database
repair, health scans, source deletion, onboarding Attachment Showcase
integration, archive-adoption qualification, or a generic diagnostics
framework.

Document desirable ideas as future work only.

# 14. Documentation

Create:
`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/04-FINAL-QUALIFICATION-AND-POLISH.md`

Save this prompt as:
`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/prompts/05-FINAL-QUALIFICATION-AND-POLISH.md`

Document the Phase Three checkpoint commit, final page hierarchy,
Copy-button decision, Contacts wording decision, Message provenance
qualification, Technical Details, clipboard qualification,
partial/error/loading behavior, purity requalification,
production/development fixture coverage, accessibility findings, files
changed, validation, deferred ideas, and whether Feature 33 is ready to
merge.

# 15. Release metadata

If this polish changes user-visible production code after the Phase
Three checkpoint, update version/changelog according to project
conventions.

If no production code changes are necessary, do not manufacture a
version bump merely for qualification documentation.

# 16. Validation

Run at minimum: 1. focused Feature 33 read-model/provider tests; 2.
Environment panel/widget tests; 3. Copy action tests; 4. formatter
tests; 5. passive Feature 31 observation tests; 6. Message
source/provenance tests; 7. Contacts aggregate/provenance tests; 8.
partial/error/loading-state tests; 9. production/development fixture
tests; 10. accessibility/widget behavior tests where supported; 11.
Environment architecture tripwires; 12. complete architecture suite; 13.
relevant Settings/navigation regressions; 14. Feature 31 observation
regression ladder if touched; 15. `flutter analyze --no-pub`; 16. full
repository suite; 17. `git diff --check`; 18. documentation/reference
validation; 19. native tests only if native code changes.

Use disposable/in-memory fixtures. Do not run expensive real-data
qualification.

# Mandatory stop-and-report gates

STOP AND REPORT if: - the UI needs to bypass `EnvironmentSummary` for
authoritative facts; - a UI field requires archive traversal or payload
I/O; - opening Environment causes database/overlay mutation; - clipboard
formatting needs direct provider/filesystem/database access; - Contacts
physical provenance would need to be invented; - the absent 2012--2013
Message source appears because of a query/model defect rather than
because it is absent from this development graph; -
production/development require divergent Environment architectures; -
Settings integration requires bypassing established center-panel
architecture; - schema/migration changes become necessary; - native
changes become necessary without compelling existing-platform reason; -
real production data or real archive mutation becomes necessary.

Do not work around a stop gate. Report and wait.

# Completion state

Leave final-polish implementation entirely unstaged for review.

Do not commit the final polish. Do not push. Do not merge. Do not begin
another feature.

# Final report

Report: - Phase Three checkpoint commit hash; - current branch/HEAD; -
whether final production polish was required; - Copy button presentation
decision; - Contacts wording decision; - Message provenance result; -
ordinary-page final section hierarchy; - Technical Details final
contents; - clipboard final format; - partial/error/loading behavior; -
read-only purity result; - production/development parity result; -
accessibility result; - files changed; - release version if changed; -
focused test results; - architecture result; - full-suite result; -
analyzer result; - `git diff --check` result; - documentation
validation; - any stop gate encountered; - complete Git status.

Explicitly answer:

`FEATURE 33 READY TO MERGE: YES / NO`

and confirm: - Environment owns no environment authority; - attachment
observation remains passive; - no archive payload I/O occurs from
Environment; - no database/overlay mutation occurs from Environment; -
no startup work was added; - Message source cards represent only actual
current graph contributors; - Contacts physical provenance is not
invented; - clipboard output contains no user content; - production
adoption remains disabled; - no real production data or real archive was
accessed or modified.

Then STOP.
