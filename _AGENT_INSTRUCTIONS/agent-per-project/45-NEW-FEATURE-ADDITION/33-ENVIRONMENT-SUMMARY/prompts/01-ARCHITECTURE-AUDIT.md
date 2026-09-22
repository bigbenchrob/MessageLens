NEW FEATURE — 33-ENVIRONMENT-SUMMARY

We are beginning a new MessageLens feature.

# Repository starting point

The completed attachment-archive feature currently ends at:

Branch:
feature/attachment-archive-relocation

Expected HEAD:
2c8bbaae5da30300dda8d4e9e3eaef57e353cea4

Subject:
feat(attachments): polish archive adoption and add attachment showcase

Before doing anything:

1. verify the current branch and HEAD;
2. verify the tracked worktree and index are clean;
3. verify only the known unrelated untracked files remain;
4. verify the shared-instructions submodule is clean;
5. do not modify, merge, squash, or otherwise alter the completed attachment
   archive work.

Create a new feature branch directly from this HEAD:

feature/environment-summary

Do not push.

Create:

_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/

and:

_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/prompts/

Save this prompt as:

prompts/01-ARCHITECTURE-AUDIT.md

This first task is:

READ-ONLY ARCHITECTURE AUDIT AND DESIGN PLANNING.

Do not implement the feature yet.

Do not change production code.

Do not change schemas, migrations, databases, providers, Settings topology,
native code, generated files, release metadata, or changelog.

Do not access or modify production MessageLens data.

Do not modify either the active Toshiba development attachment archive or the
retained WD archive.

Do not begin onboarding Attachment Showcase integration.

# Background

Recent development work exposed a practical problem.

A stale MessageLensDevelopment build was launched without its configured
development-root environment override.

It correctly admitted its default Application Support development root rather
than the intended external WD development root.

The application was behaving according to its architecture, but the user had
no simple way to answer:

- Which MessageLens installation am I running?
- Which primary data folder is actually admitted?
- Which attachment archive is actually active?
- Which physical volume contains each?
- Which Messages data/archive sources contributed to this installation?
- Which Contacts sources contributed?
- Which databases am I actually using?
- Is this Production or Development?
- What archive instance is this?
- What useful technical state should I include when asking for support?

We want a read-only Environment page that answers those questions directly.

This is NOT an archive-relocation/adoption feature.

This is NOT a configuration editor.

This is NOT a general diagnostics framework.

The central product question is:

“What MessageLens environment am I actually looking at, and where did its data
come from?”

# Proposed product location

The likely product shape is:

Settings
→ Environment

with the feature body in the Settings center/detail pane.

Do not assume this is architecturally correct until you audit the existing
Settings topology and reusable center-panel patterns.

The sidebar should remain navigation.

The Environment page itself should be read-only.

# Governing architecture principle

THE ENVIRONMENT PAGE OWNS NO ENVIRONMENT STATE.

It derives presentation from the SAME authoritative providers/services that the
application itself uses.

Do not create a parallel “environment model” that independently decides:

- root paths;
- archive authority;
- database locations;
- import provenance;
- build identity;
- availability.

A presentation/read-model aggregation type is appropriate.

A second source of truth is not.

# Candidate information architecture

The following is a PRODUCT HYPOTHESIS to audit, not a requirement to fabricate
unsupported data.

The page may contain sections such as:

1. This installation
2. Data folder
3. Attachment archive
4. Message data
5. Contacts data
6. Technical details
7. Copy Environment Summary

Determine which fields are actually supportable from current authoritative
architecture.

Do not invent missing provenance.

---

# 1. AUDIT CURRENT INSTALLATION IDENTITY

Find the authoritative existing sources for:

- product name;
- semantic version;
- build number;
- archive environment:
  - production;
  - development;
  - FDA experiment;
  - test/qualification identities as relevant;
- build identity;
- bundle identifier;
- archive instance UUID;
- admitted ArchiveAccessAuthority identity;
- any distinction between runtime environment and build identity.

Determine which of these are already available through Dart providers versus
native/build metadata.

Prefer reuse.

Do not add a native bridge merely because some information is currently read
another way.

Report the exact authoritative source/provider/file for each field.

---

# 2. AUDIT PRIMARY DATA ROOT

Determine the canonical architecture for the currently admitted MessageLens
primary data root.

We need to know whether the page can truthfully show something like:

DATA FOLDER

WD_ELEMENTS · Connected

/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development

or in production:

Macintosh HD · Connected

~/Library/Application Support/<production MessageLens root>

Audit:

- canonical root derivation;
- ArchiveAccessAuthority;
- environment/root admission;
- development override handling;
- volume identity/name;
- availability;
- readability/writability if already typed;
- whether the root is default or explicitly overridden/configured;
- archive instance UUID/marker relationship.

Do not describe the root as “Internal” merely because it is the default root.

Physical storage location and configuration mode are different concepts.

Determine the correct user-facing vocabulary.

---

# 3. AUDIT ACTIVE ATTACHMENT ARCHIVE

Feature 31 established substantial attachment-location architecture.

Audit and reuse it.

Determine the authoritative existing sources for:

- current canonical attachment archive root;
- current display path;
- physical volume name/identity;
- internal/default versus custom-external configuration internally;
- current availability;
- readability;
- writability;
- location generation;
- bookmark state/staleness where appropriate;
- custom write policy;
- whether external archive is active;
- whether a retained previous archive is represented anywhere after successful
  adoption;
- whether retained-source information is durable or only available during the
  adoption workflow;
- whether “original retained archive” can truthfully be shown after relaunch.

Important:

Do not recreate attachment-location logic in Feature 33.

Consume existing typed location state.

The ordinary user-facing summary should prefer:

Toshiba_manual_bu · Connected
/path/to/attachment_archive

over architecture vocabulary such as:

customExternal
activeArchive
generation 1

Those technical fields may belong in a disclosure.

---

# 4. AUDIT MESSAGE DATA PROVENANCE

This is the most important unknown in the audit.

Determine exactly what MessageLens currently knows, durably and
authoritatively, about the Messages data that contributed to the current
working graph.

Investigate:

- live/current macOS Messages database source;
- imported Messages archives;
- old-drive imports;
- MessageLens-created archive/import packages;
- source IDs;
- source descriptors;
- source labels;
- source database paths if retained;
- archive/import UUIDs;
- import timestamps;
- first/last message dates by source;
- message counts by source;
- attachment counts by source;
- whether graph rows preserve source identity;
- whether source identity survives projection/import;
- whether source records are persisted in import.db, working.db, overlay, graph
  metadata, installation metadata, or elsewhere;
- whether historical source paths are retained;
- whether a source can be identified meaningfully after the original drive is
  gone;
- whether imported sources can be distinguished from the currently live
  Messages database.

Trace the full provenance path:

source database/archive
→ import
→ normalization/projection
→ working graph
→ current read models

Do not assume source provenance exists merely because IDs contain a source
component.

Determine exactly what can be reconstructed and what cannot.

# Questions this section must answer

Can the Environment page currently show, truthfully, something like:

MESSAGE DATA

Current Mac Messages
January 2014 – present
126,000 messages

Old Mac archive
July 2012 – December 2013
12,000 messages

Imported August 2026

?

For every candidate field above, classify:

A. already authoritatively available;
B. cheaply derivable from existing authoritative data;
C. derivable but expensive;
D. not currently retained / unavailable;
E. ambiguous and unsafe to present.

Do not fill D/E fields with guesses.

---

# 5. AUDIT MESSAGE COUNTS AND DATE RANGES

Determine the cheapest authoritative sources for:

- total graph message count;
- searchable FTS row count;
- earliest/latest message date;
- counts/date ranges by source if source identity supports it;
- chat count;
- attachment-reference count if useful.

Opening Environment must not trigger an expensive archive scan.

Prefer:

- existing database aggregates;
- existing health/read-model evidence;
- cheap indexed SQL;
- already-materialized counts.

Identify any count that would be misleading because of:

- duplicate source records;
- recovered messages;
- reaction envelopes;
- suppressed rows;
- deleted/hidden records;
- graph normalization.

Recommend user-facing labels that state exactly what is counted.

---

# 6. AUDIT CONTACTS DATA PROVENANCE

Perform the equivalent audit for Contacts.

Determine what MessageLens knows about:

- current macOS Contacts source;
- imported/historical Contacts sources;
- AddressBook database identity/path;
- import timestamps;
- contact counts;
- handle counts;
- source identity;
- provenance retained in the graph;
- whether multiple Contacts sources can meaningfully be distinguished.

Again classify candidate fields A–E:

A. authoritative;
B. cheaply derivable;
C. expensive;
D. unavailable;
E. ambiguous.

Do not invent a Contacts provenance model if none exists.

---

# 7. AUDIT APPLICATION DATABASES

Determine which actual databases/files are meaningful to show under an
optional:

Technical details

disclosure.

Audit at minimum:

- working/graph database;
- import database;
- user_overlays.db;
- presence database if applicable;
- any installation/identity metadata;
- FTS storage if separate;
- attachment-location configuration storage;
- other durable application databases relevant to understanding the current
  environment.

For each determine:

- canonical path;
- owning feature/layer;
- whether path disclosure is safe/useful;
- schema/user version if cheaply available;
- file size if cheaply available without recursive work;
- current open/admitted identity where relevant.

Do not dump every SQLite/WAL/SHM file merely because it exists.

The page should explain the environment, not resemble `ls -la`.

---

# 8. AUDIT DATABASE/GRAPH HEALTH EVIDENCE

Determine whether useful compact health information already exists, such as:

- installation validation status;
- graph schema version;
- overlay schema version;
- FTS availability/count;
- graph health state;
- pending maintenance/recovery state;
- last successful import/projector state.

Do not turn Environment into a health dashboard.

Identify only fields that materially help answer:

“Is this the environment/database I think it is?”

Technical health may belong behind disclosure.

Do not trigger expensive integrity checks merely by opening the page.

---

# 9. AUDIT IMPORT/ARCHIVE HISTORY

Search for any existing durable representation of:

- import sessions;
- imported packages;
- source database identities;
- source-range metadata;
- migration/import reports;
- archive history;
- previous roots;
- installation history.

Pay particular attention to whether information currently exists only in:

- logs;
- transient import state;
- historical diagnostics;
- documentation;

rather than durable product data.

Logs are not automatically suitable product provenance.

If useful provenance was discarded after import, say so explicitly.

Do not propose a schema change yet.

---

# 10. AUDIT SETTINGS CENTER-PANEL REUSE

Feature 31 recently added/reused a Settings center-panel workflow.

Audit:

- SettingsViewSpec;
- panel widget providers;
- Settings coordinator/resolver;
- stable sidebar topology;
- generic section/card components;
- path/volume/status presentation;
- disclosure/technical-details patterns;
- copy-to-clipboard patterns if any.

Determine the minimum new UI architecture required for:

Settings → Environment

Prefer reuse over another custom Settings subsystem.

The Environment page should not put its content in the narrow sidebar.

---

# 11. PROPOSE USER-FACING PAGE

Based ONLY on fields current architecture can support truthfully, propose the
center-panel information architecture.

A likely shape is:

ENVIRONMENT

THIS INSTALLATION

MessageLens Development
Version 0.2.xxx (xxx)
Development

DATA FOLDER

WD_ELEMENTS · Connected
/Volumes/.../MessageLens Development

ATTACHMENT ARCHIVE

Toshiba_manual_bu · Connected
/Volumes/.../attachment_archive

External archive · Read/write

MESSAGE DATA

<actual supportable source/provenance information>

CONTACTS DATA

<actual supportable source/provenance information>

TECHNICAL DETAILS
[disclosure]

Do not force this exact layout if the audit reveals a better representation.

Distinguish:

- ordinary useful information;
- development/support detail.

---

# 12. COPY ENVIRONMENT SUMMARY

Audit the feasibility of a button:

Copy Environment Summary

This should copy a compact plain-text support summary to the clipboard.

Determine:

- existing clipboard infrastructure;
- whether the UI and clipboard summary can share one environment read model;
- which fields should be included by default;
- whether absolute local paths should be included;
- whether sensitive/user-content data should be excluded.

The summary should contain environment facts, not conversation content.

Potential shape:

MessageLens Development 0.2.xxx+xxx
Environment: development

Data root:
  WD_ELEMENTS
  /Volumes/.../MessageLens Development

Attachment archive:
  Toshiba_manual_bu
  /Volumes/.../attachment_archive
  Connected · writable

Messages:
  138,481
FTS:
  138,481

Archive instance:
  e9310d3f-...

Do not implement clipboard behavior yet.

Recommend exact privacy-conscious contents.

---

# 13. PATH PRESENTATION

Paths can be long.

Audit existing path-display conventions.

Recommend:

- wrapping versus truncation;
- selectable text;
- monospaced versus ordinary UI font;
- Reveal in Finder affordance, if existing infrastructure makes this trivial;
- whether copying individual paths is useful.

Do not introduce mutation/configuration actions.

Reveal in Finder is navigational, not configuration, but include it only if
consistent with existing UI architecture.

---

# 14. AVAILABILITY VOCABULARY

Avoid context-free:

Available

Prefer physical/user-meaningful combinations such as:

WD_ELEMENTS · Connected
Toshiba_manual_bu · Connected
Toshiba_manual_bu · Disconnected
Read-only
Permission required

Audit existing typed states and map them carefully.

Do not collapse:

unavailable
missing
permission denied
read-only

into one generic state if current architecture distinguishes them.

---

# 15. READ-ONLY GUARANTEE

Environment must be observational.

Opening it must not:

- write settings;
- refresh bookmarks by persisting new data;
- trigger imports;
- trigger archive ingestion;
- run maintenance sweeps;
- run integrity scans;
- recursively stat attachment archives;
- hash payloads;
- rebuild FTS;
- create databases;
- alter location generation.

If an existing provider has side effects merely when watched, identify that
risk.

Recommend safe read-only seams.

---

# 16. PERFORMANCE BUDGET

Classify every proposed field as:

- already in memory/provider state;
- cheap bounded filesystem metadata;
- cheap indexed SQL;
- moderate SQL aggregate;
- expensive/unbounded.

The normal page should contain only the first three categories unless there is
a compelling reason otherwise.

Moderate fields may load asynchronously.

Expensive/unbounded fields should not run automatically.

Propose a target for first meaningful render using existing cached/provider
state.

Do not introduce startup work for this feature.

---

# 17. PRODUCTION VS DEVELOPMENT

The page must work in both.

Audit what differs.

Development may show:

- external primary data root;
- development build identity;
- development archive UUID;
- active external attachment archive.

Production may show:

- Application Support primary root;
- production build identity;
- production archive UUID;
- internal/default or external attachment archive.

Do not make the page development-only merely because development motivated it.

Development-only technical fields may be conditionally shown if useful.

---

# 18. SUPPORT / DIAGNOSTIC VALUE

Identify the minimum information that would have diagnosed the stale-build /
wrong-root incident immediately.

At minimum consider:

- version/build;
- environment;
- bundle/product identity;
- canonical admitted data root;
- archive instance UUID;
- active attachment archive;
- active volume;
- build/root override state if authoritatively available.

Recommend whether a concise summary of those fields should appear at the top
or only in Copy Environment Summary.

Do not expose raw environment variables unnecessarily in ordinary UI.

---

# 19. FUTURE EXTENSIBILITY

Keep the design capable of later showing additional environment facts such as:

- Attachment Showcase/import provenance;
- archive adoption history;
- connected source packages;
- qualification/support artifacts;

but do not build a generic metadata framework now.

YAGNI applies.

The page should be a straightforward typed read model and presentation.

---

# 20. SCHEMA / PROVENANCE GAP ANALYSIS

If the audit finds information we genuinely want but do not currently retain,
list it separately.

For each gap report:

- desired field;
- why it is useful;
- whether it can be reconstructed;
- cost of reconstruction;
- whether future imports could retain it;
- whether adding it would require schema/persistence changes.

Do NOT implement those changes in this audit.

Distinguish:

“Environment page can ship without this”

from:

“Environment page would be misleading without this.”

---

# 21. ARCHITECTURE TRIPWIRE PLAN

Propose tests that would guarantee:

- Environment owns no authoritative environment state;
- page uses existing root/location authority;
- no recursive attachment scan;
- no archive payload I/O;
- no database mutation;
- no import/recovery side effects;
- no configuration persistence;
- no raw-path authority;
- clipboard summary derives from the same read model;
- production/development both supported;
- Settings center-panel architecture reused.

Do not implement tests yet.

---

# 22. FEATURE BOUNDARY

Feature 33 must not become:

- archive relocation/adoption;
- archive deletion;
- database repair;
- import management;
- source removal;
- environment switching;
- development-root configuration;
- diagnostics execution;
- maintenance controls.

It is:

READ-ONLY ENVIRONMENT AND PROVENANCE PRESENTATION.

Actions should be limited to presentation/navigation conveniences such as:

- Copy Environment Summary;
- Copy path;
- perhaps Reveal in Finder.

No mutation.

---

# 23. REPOSITORY / FEATURE SETUP

Create:

_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/

Create:

_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/prompts/

Save this prompt as:

prompts/01-ARCHITECTURE-AUDIT.md

Create the audit deliverable:

00-ARCHITECTURE-AUDIT-Yes. It was truncated again at:

Create the audit deliverable:

00-ARCHITECTURE-AUDIT-

Don’t use what follows as a separate conceptual prompt; this is simply the missing tail of the Feature 33 prompt you already have. Append this directly after that last line:

AND-DESIGN.md
Do not update the Feature Index yet unless existing repository instructions
explicitly require registration at audit creation time.
Do not update release version/changelog for this documentation-only audit.
Do not stage or commit the audit.
---
# 24. PROPOSED ENVIRONMENT READ MODEL
Based on the audit, design a single typed read model suitable for BOTH:
- Environment center-panel presentation; and
- Copy Environment Summary.
Do not implement it yet.
The model should aggregate existing authoritative evidence without becoming
authority itself.
Propose exact fields and types.
Prefer nested semantic groups such as:
EnvironmentInstallationSummary
EnvironmentDataRootSummary
EnvironmentAttachmentArchiveSummary
EnvironmentMessageDataSummary
EnvironmentContactsDataSummary
EnvironmentTechnicalSummary
Names are illustrative; follow repository conventions.
For every proposed field document:
- authoritative source;
- derivation;
- cost classification;
- null/unavailable semantics;
- ordinary UI versus Technical Details;
- clipboard inclusion/exclusion.
Do not put raw provider objects or database handles in presentation types.
---
# 25. MESSAGE SOURCE PRESENTATION DECISION
The audit must make an explicit product recommendation about Message provenance.
Choose among:
A. Present individual source cards now because durable provenance is already
   sufficient.
B. Present only aggregate Message data now because individual-source provenance
   is incomplete or ambiguous.
C. Present a hybrid:
   aggregate authoritative totals plus only those source distinctions that are
   strongly supported.
Do not choose based on what would look impressive.
Choose based on what MessageLens can prove.
If historical source identity is only partially retained, state exactly what
would be misleading about presenting it as a complete import history.
---
# 26. CONTACT SOURCE PRESENTATION DECISION
Make the equivalent explicit decision for Contacts.
Do not force symmetry with Messages.
It is acceptable for the Environment page to show rich Messages provenance but
only aggregate Contacts information, or vice versa, if that is what the
architecture supports.
---
# 27. RETAINED ATTACHMENT SOURCE QUESTION
Feature 31 currently has:
ACTIVE:
Toshiba attachment archive
RETAINED:
WD original archive
The successful adoption deliberately does not use WD as fallback.
Audit whether the retained-original path is durably available after:
- transaction retirement;
- app restart;
- provider reconstruction.
If it is NOT durably retained as product state, the Environment page must NOT
pretend that it knows the retained-original location.
Do not infer it from historical logs, the abandoned relocation artifacts, or
the development rehearsal.
If durable retained-source presentation would require new persistence, classify
that as a provenance gap for later consideration.
---
# 28. VOLUME IDENTITY
Determine how to obtain physical volume information for:
- primary data root;
- active attachment archive;
- any database/source path where volume identity materially helps.
Prefer existing bounded filesystem/location infrastructure.
Audit whether the page can safely display:
- human-readable volume name;
- connected/disconnected;
- read-only;
- filesystem type if useful;
- stable volume UUID only in Technical Details.
Do not add low-level volume probing merely to decorate the UI.
Do not expose device nodes such as `/dev/disk12s2` in ordinary UI.
---
# 29. TECHNICAL DETAILS CONTENT
Recommend the exact default-collapsed Technical Details content.
Candidate fields include:
- environment;
- build identity;
- bundle identifier;
- archive instance UUID;
- canonical admitted primary root;
- active attachment canonical root;
- attachment location generation;
- attachment location configuration mode;
- custom write policy;
- bookmark stale/non-stale state;
- graph schema version;
- overlay schema version;
- database paths;
- FTS status/count;
- installation validation status.
Include only fields that are:
- authoritative;
- cheap;
- diagnostically useful.
Do not turn this into a raw debug dump.
For each included field explain what diagnostic question it answers.
---
# 30. COPY ENVIRONMENT SUMMARY DESIGN
Specify the exact proposed plain-text clipboard format.
It should be human-readable when pasted into:
- ChatGPT;
- Codex;
- GitHub issue;
- support email;
- plain text note.
Use stable labels.
Do not emit JSON unless there is a compelling existing project convention.
The clipboard summary should include enough information to diagnose the
stale-build/wrong-root incident without requiring screenshots.
At minimum evaluate inclusion of:
- product/version/build;
- environment/build identity;
- bundle identifier;
- primary data root;
- primary volume/status;
- active attachment archive;
- attachment volume/status;
- archive instance UUID;
- graph message count;
- FTS count;
- database paths under a technical subsection.
Exclude:
- message text;
- contact names;
- phone numbers/email addresses;
- attachment filenames where they may contain user content;
- conversation titles;
- raw bookmark data;
- secrets/tokens;
- unnecessary logs.
Absolute filesystem paths are acceptable if the audit concludes that their
diagnostic value outweighs local username disclosure for this explicitly
user-initiated support action.
If absolute paths are included, note that the user deliberately invokes Copy
Environment Summary.
---
# 31. COPY INDIVIDUAL VALUES
Audit whether useful fields should expose lightweight copy affordances.
Potentially:
- data-root path;
- attachment-root path;
- archive instance UUID;
- database paths.
Prefer native/selectable text or an existing copy affordance.
Do not clutter every row with buttons if text selection already solves the
problem.
Recommend one consistent interaction.
---
# 32. REVEAL IN FINDER
Determine whether:
Reveal in Finder
is worth including for:
- primary data folder;
- attachment archive;
- perhaps application database folder.
Requirements:
- navigation only;
- no mutation;
- no directory creation;
- no fallback;
- unavailable/disconnected paths disable the action truthfully.
Prefer an existing project/native shell-open abstraction if one exists.
Do not add a native bridge solely for this audit.
If no clean reusable implementation exists, recommend omitting it from v1.
---
# 33. EMPTY / UNAVAILABLE / PARTIAL STATES
Design truthful presentation for situations such as:
- attachment archive disconnected;
- bookmark permission denied;
- primary root unavailable;
- graph database unavailable;
- FTS unavailable;
- source provenance absent;
- no historical imports;
- provenance unknown rather than absent;
- a count still loading asynchronously.
Do not use a spinner forever.
Distinguish:
None
Unknown
Unavailable
Not retained
Loading
where those meanings differ.
The page must remain useful even when one section cannot resolve.
---
# 34. ERROR ISOLATION
The Environment page aggregates several independent domains.
One failed section must not blank the whole page.
Recommend section-level typed error/unavailable states.
For example:
Installation identity may render even if attachment location is disconnected.
Data-root identity may render even if graph counts fail.
Attachment status may render even if Contacts provenance is unavailable.
Do not convert all failures into one generic page error.
---
# 35. ASYNCHRONOUS LOADING STRATEGY
Propose how the center panel should render progressively.
Preferred conceptual model:
FIRST PAINT:
- installation identity;
- admitted data root;
- active attachment location from existing provider state.
THEN CHEAP ASYNC:
- message counts;
- FTS count;
- contacts aggregates;
- database metadata.
Do not hold the entire Environment page behind the slowest aggregate.
Do not add startup prefetch solely for this feature.
---
# 36. NO STARTUP COUPLING
Environment is user-invoked Settings content.
It must not add work to:
- application startup;
- installation classification;
- graph admission;
- onboarding;
- Messages list loading;
- Contacts list loading;
- attachment resolution.
All Environment-specific aggregation should begin only when the Environment
view/read model is requested, unless the underlying data is already naturally
available.
Add this as an explicit architecture invariant.
---
# 37. CURRENT FEATURE-31 DEVELOPMENT STATE
The audit must understand, but not modify, the established development state:
Primary MessageLensDevelopment data root:
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development
Active attachment archive:
/Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive
Retained original attachment archive:
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development/attachment_archive
Important:
The retained WD attachment archive is NOT fallback authority.
Do not access either real archive merely to populate the audit.
Use source architecture and existing documentation/code evidence.
Do not run another archive verification.
Do not change the active configuration.
---
# 38. AUDIT USING SOURCE FIRST
This audit should primarily inspect:
- source code;
- schemas;
- existing tests;
- architecture documents;
- provider topology;
- repository documentation.
Do not launch MessageLens merely to discover architecture.
Do not inspect real user databases unless a specific provenance question cannot
be answered from schema/source/tests and read-only inspection of development
fixtures is explicitly justified.
If such inspection appears necessary:
STOP AND REPORT first rather than accessing a real database.
Disposable/in-memory test fixtures may be inspected freely.
---
# 39. EXISTING DOCUMENTATION TO CONSULT
At minimum inspect relevant documentation for:
- archive environment/admission;
- import architecture;
- graph/source identity;
- Contacts import/projection;
- attachment archive location/adoption;
- startup validation;
- database ownership;
- Settings center-panel architecture.
Feature 31 documentation is historical context for attachment-location
authority, especially the final simplified adoption records.
Do not treat historical superseded mover design as current architecture.
---
# 40. PROPOSE IMPLEMENTATION PHASES
Based on actual audit findings, propose the smallest safe implementation plan.
Likely phases might be:
Phase One:
- typed read model;
- authoritative provider aggregation;
- cheap counts/provenance queries;
- architecture tests.
Phase Two:
- Settings Environment navigation;
- center-panel presentation;
- Technical Details disclosure.
Phase Three:
- Copy Environment Summary;
- optional Copy path / Reveal in Finder;
- qualification.
But do not force these phases if the audit suggests a smaller or different
sequence.
Prefer fewer phases than Feature 31.
This should be a relatively modest read-only feature.
---
# 41. TEST STRATEGY
Propose focused tests for:
## Read model
- production identity;
- development identity;
- alternate data root;
- active default attachment root;
- active external attachment root;
- disconnected attachment root;
- message aggregate counts;
- provenance-present;
- provenance-unavailable;
- Contacts aggregates;
- partial section failure.
## Purity
- no database writes;
- no overlay writes;
- no archive traversal;
- no payload I/O;
- no hashing;
- no bookmark persistence;
- no location-generation change;
- no import/recovery trigger;
- no maintenance trigger.
## Settings
- Environment navigation;
- center-panel selection;
- progressive rendering;
- Technical Details disclosure;
- long paths;
- unavailable states.
## Clipboard
- same read model as UI;
- no user message/contact content;
- no raw bookmark bytes;
- stable labels;
- production/development differences.
## Performance
- no startup work;
- no recursive archive stat;
- no unbounded query;
- bounded/indexed aggregate queries.
Do not implement these tests yet.
---
# 42. RISKS
Identify risks including:
- presenting inferred provenance as fact;
- conflating physical volume with configuration mode;
- triggering side effects by watching existing providers;
- expensive counts on large databases;
- leaking user content into support summaries;
- stale path presentation;
- duplicate sources/count semantics;
- overloading the page with developer-only detail;
- creating a second environment source of truth.
For each recommend mitigation.
---
# 43. MANDATORY STOP-AND-REPORT GATES
STOP AND REPORT rather than silently designing around the problem if:
- current source provenance is too weak to identify imported Message sources
  truthfully;
- a desired ordinary-user field requires expensive archive traversal;
- existing root/location providers mutate state merely when observed;
- database counts require unbounded materialization;
- the page would require schema/migration changes merely to show its basic
  useful v1;
- Settings center-panel integration would require bypassing established
  navigation architecture;
- Copy Environment Summary would require duplicating environment derivation;
- production and development identity cannot be represented through one
  coherent read model;
- real production data access becomes necessary;
- active/retained archive state would need to be changed.
Do not implement a workaround.
Document the finding and wait.
A provenance gap is not automatically a blocker.
The page may ship with less information if that is the truthful design.
---
# 44. DELIVERABLE
Create:
_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/00-ARCHITECTURE-AUDIT-AND-DESIGN.md
The document must contain:
1. Executive summary.
2. Product goal.
3. Explicit non-goals.
4. Repository/branch starting state.
5. Existing Settings architecture and reuse plan.
6. Installation/build identity inventory.
7. Primary data-root authority.
8. Attachment-archive authority.
9. Message provenance architecture.
10. Message provenance A–E field classification.
11. Message aggregate/count semantics.
12. Contacts provenance architecture.
13. Contacts provenance A–E field classification.
14. Application database inventory.
15. Existing health/validation evidence.
16. Import/archive-history audit.
17. Provenance gaps.
18. Proposed Environment read model.
19. Field-by-field source/cost/nullability matrix.
20. Proposed ordinary-user center-panel layout.
21. Proposed Technical Details disclosure.
22. Exact Copy Environment Summary format.
23. Path/copy/reveal interaction recommendations.
24. Availability vocabulary.
25. Partial/error/loading states.
26. Progressive loading strategy.
27. Performance budget.
28. Read-only/purity guarantees.
29. Production versus Development behavior.
30. Support-diagnostic scenario analysis.
31. Architecture tripwire plan.
32. Test strategy.
33. Risks and mitigations.
34. Proposed implementation phases.
35. Recommended v1 scope.
36. Deferred/future opportunities.
37. Decision record.
The document should explicitly answer:
CAN ENVIRONMENT V1 SHIP WITHOUT SCHEMA CHANGES: YES / NO
CAN MESSAGE SOURCES BE SHOWN INDIVIDUALLY AND TRUTHFULLY: YES / NO / PARTIAL
CAN CONTACT SOURCES BE SHOWN INDIVIDUALLY AND TRUTHFULLY: YES / NO / PARTIAL
CAN ACTIVE ATTACHMENT LOCATION BE SHOWN AUTHORITATIVELY: YES / NO
CAN RETAINED PREVIOUS ATTACHMENT LOCATION BE SHOWN AFTER RELAUNCH:
YES / NO / PARTIAL
CAN COPY ENVIRONMENT SUMMARY USE THE SAME READ MODEL AS THE UI: YES / NO
DOES OPENING ENVIRONMENT REQUIRE ANY ARCHIVE PAYLOAD I/O: YES / NO
DOES OPENING ENVIRONMENT REQUIRE ANY DATABASE MUTATION: YES / NO
DOES FEATURE 33 REQUIRE ANY STARTUP WORK: YES / NO
ENVIRONMENT SUMMARY READY TO IMPLEMENT: YES / NO
If any answer is NO/PARTIAL, explain precisely why.
---
# 45. VALIDATION OF THE AUDIT
Because this is documentation-only:
- validate all referenced source paths/symbols;
- validate Markdown links;
- run git diff --check;
- confirm no production/generated/native/schema files changed;
- confirm no real archive/database was accessed;
- confirm Feature 31 active development state was not changed.
Do not run the full Flutter suite merely for a documentation-only audit unless
repository instructions explicitly require it.
---
# COMPLETION STATE
Leave the new Feature 33 documentation entirely unstaged.
Do not commit.
Do not push.
Do not begin implementation.
Do not update release metadata.
Do not update Feature 31.
Report:
- branch created;
- starting HEAD;
- feature folder/files created;
- concise executive findings;
- Message provenance conclusion;
- Contacts provenance conclusion;
- attachment-location conclusion;
- retained-source conclusion;
- proposed v1 page sections;
- proposed Technical Details fields;
- exact Copy Environment Summary recommendation;
- performance/purity conclusion;
- provenance gaps;
- schema-change conclusion;
- proposed implementation phases;
- any stop-and-report gate encountered;
- validation performed;
- complete Git status.
Then STOP.
Do not begin Feature 33 implementation until reviewed.

That completes the Feature 33 Prompt 01. You can append this directly to the truncated copy you already have.
