# MessageLens Feature 34
## Response 38 — Forensic Audit of Mechanical-Impossibility Failure and Lazy Contact Resolution

## Executive finding

The two reported symptoms share an enabling condition but are separate defects.
Start Fresh correctly left the installation virgin, and the next clean-slate import
completed durably. However, Start Fresh intentionally preserved the overlay and
therefore also preserved two presentation/navigation preferences. On the next
launch, `SidebarFlow` restored contact `17592186044472` without asking whether
that contact selection was admissible in the current installation state. The
center resolver then faithfully projected that stale sidebar selection. There is
no evidence that a contact-message center page was independently persisted.

The contact-name failure begins at a different boundary. An immutable
`DisplayIdentityResolver` can be built while the graph is empty, and its provider
does not depend on `messageDataVersionProvider`. `contactsListRepositoryProvider`
does watch the version, but its captured `ContactsListReader` can continue using
the stale resolver. After the graph build, real contact rows were therefore
combined with an empty resolver and rendered as `contact <id>`. Selecting a row
changed the cassette/center consumer tree. The relevant providers are
auto-disposed, so the newly mounted hero/header branch recreated the resolver
against the populated graph; returning to the picker then consumed the corrected
resolver. The selection did not create or repair identity data. It accidentally
caused stale read-model state to be recreated.

The exact claim that the same contact center remained visibly mounted throughout
an actual **Conversations** state cannot be proved from the available telemetry
and is contradicted by the synchronous source transition: Conversations with no
selected conversation projects `null`. The logs do prove both the stale restored
contact projection and that clearing the contact selection produces an empty
center. The overall center-state explanation is therefore **PARTIAL**, while the
contact lazy-resolution explanation is **YES**.

---

## 1. Running/build verification

The preservation capture was taken at **2026-10-01 06:57:45 -0700**
(**2026-10-01T13:57:45Z**). MessageLens Development was not running, so there was
no live PID, executable path, process working directory, or parent process to
record. This was a stable post-run capture rather than a capture racing a running
app.

The last-run artifact is the development artifact in this worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Verified identity:

- bundle identifier: `com.bigbenchsoftware.MessageLens.development`;
- app version/build: `0.2.128 (146)`;
- environment: `development`;
- build identity: `developmentDebug`;
- executable SHA-256:
  `3bda065d195022f064f9aee14f2e4f2248f2d8af4b40c3ea4a351fc0f0574b70`;
- `App.framework` SHA-256:
  `2b1fef6aacf71ce0ab65408dde3d7a0583e913cb14c968b7ea4380243c53fcd2`.

Those byte hashes exactly match the Prompt 36 qualified build. The artifact's
mtime is later because it was rebuilt from VS Code, but the executable and Dart
framework bytes are identical. Startup telemetry independently reports
`archive_environment=development` and `build_identity=developmentDebug`.

Repository identity is:

- worktree: `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream:
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- accumulated tracked diff SHA-256:
  `88dd2190a8c989fcf7d1bbab5af49ff646b02a132ea423286353c6207c56f5be`.

The Prompt 32 and Prompt 35 production, generated, and test fingerprints match
their recorded handoffs. The wrong-worktree/wrong-build stop gate did not fire.

## 2. Preserved evidence boundary

The pre-content capture record is:

`/private/tmp/messagelens-prompt38-preserved-evidence-20261001T065745-0700.txt`

SHA-256:
`4d04ddcff3f78348b1747e583faf54e8100fcc510e87c2c331aee7080cd861b0`.

The relevant development log is the external-root log, not the older internal
Application Support log:

`/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development/application_logs/app.log`

At both opening capture and closing verification it was 717,225 bytes, inode
430755, mtime 2026-10-01 06:52:12 -0700, SHA-256
`cb97c85066255a427b93692bbf2456f6102c82ba0ad3caa2d74eedd484938e79`.

Database evidence at both boundaries:

| Store | Size | Inode | SHA-256 | WAL/SHM |
|---|---:|---:|---|---|
| `user_overlays.db` | 2,035,712 | 227329 | `337fdfa14f1c38535635ddc6c21102856211828cba6fb79d67e06cdb122b64d6` | absent/absent |
| `macos_import_ss.db` | 145,276,928 | 434396 | `e18f4967dfd45e6bdcba8f5d7a1ba0200b2752ba9d367c69cd21db2e96fe99da` | absent/absent |
| `working_ss.db` | 68,567,040 | 434356 | `1239826953f386e7787242096d4be624fad3ef38a8d5a1d617ba677702dd3e9e` | absent/absent |
| `presence.db` | 163,840 | 254381 | `887217e2596480f45817e86a4f398bd1ae3a75140c0efbeedc200b2d72497d82` | absent/absent |

Retired `macos_import.db` and `working.db` were absent. All SQLite inspection
used read-only/immutable/query-only access. No checkpoint, temp table, migration,
vacuum, helper, or write-capable app path was used. Attachment payloads were not
traversed.

## 3. Exact human-observation timeline

1. Response 34 established successful Start Fresh at approximately
   `2026-09-30T20:32:44Z`: import storage absent, graph valid and empty, and the
   durable operation snapshot idle.
2. At `2026-10-01T13:22:00Z`, startup bounded inspection found overlay and
   presence valid, source-scoped import absent, and graph schema 3 valid.
3. At `13:22:01.006571Z`, startup classified the installation `virgin` with
   `virginNoConsequentialImport`. At `13:22:02.622698Z`, the monitor confirmed
   graph import count 0 and no imported cursor.
4. The initial center was empty, then Journey's center sync installed the
   sidebar-independent Environment Readiness panel. The log does not record an
   independently stored contact-message panel before import.
5. The human started import at `13:22:59.784Z`. Journey moved to
   `buildingGraph` and cleared the readiness panel.
6. At `13:22:59.815111Z`—before the first 500-message page completed at
   `13:23:00.499177Z`—the effective center became
   `MessagesSpec.forContact(17592186044472)`. This is the preserved sidebar
   selection becoming visible as soon as readiness stopped masking it.
7. Source import processed 138,822 messages. Rich-text work completed 125,521
   items at `13:24:22.181346Z`. The durable operation snapshot records operation
   `54216d43-4d76-4a2d-a5aa-caa3c07d5f96` completed at
   `13:25:05.816715Z` after durable-readiness verification.
8. The center was still Rusung's contact spec at `13:27:03Z` and again at
   `13:33:54Z`.
9. At `13:34:51Z`, **Change contact** cleared `chosenContactId`; the logged
   projected spec became `null`, and the next center build was empty. This is
   direct runtime proof that the effective center follows the flow state.
10. The fallback names in Favourites, the phone-row click, and the immediate
    hero/header name restoration are human-observed; the app does not log label
    strings or provider lifecycle events. At `13:51:05Z`, the center did project
    Claire (`17592186044433`), and overlay `lastInteraction` was updated at
    `13:51:05.853548Z`. Returning to the picker showed both proper names. At
    `13:52:12Z`, **Change contact** again cleared Claire and the projection.

The pre-import center symptom and post-import name symptom must not be merged:
the former is restored navigation state across a virgin boundary; the latter is
stale identity read-model state after graph generation changed.

## 4. Intended sidebar -> center dependency graph

```text
active app sidebar mode (Messages or Settings)
        +
SidebarFlowState
  - top menu choice
  - selected conversation/contact/handle
  - message scope/contact projection
        +
allowed sidebar-independent Journey/Settings presentation, if any
        ↓
effectiveCenterPanelStackProvider(mode)
        ↓
ViewSpec-derived PanelStack
        ↓
PanelStackSurface
```

For flow-managed message/contact content, the intended narrower chain is:

```text
SidebarFlowState.projectedCenterSpecForMode
        ↓
_resolveEffectiveCenterStack
        ↓
derived:<ViewSpec> page identity
        ↓
current center widget
```

That structural design is present. The missing condition is an **allowed
projection state** that rejects a restored contact/conversation selection when
the current installation/graph cannot admit it.

## 5. Every actual center-panel content source

The source census found these paths:

1. `SidebarFlowState.projectedCenterSpec` creates flow-managed messages,
   conversations, contact timelines, recovered-message views, global search,
   and handle-investigation specs.
2. `SidebarFlowState.projectedSettingsCenterSpec` creates persistent Settings
   center specs.
3. `PanelsViewState` can hold an in-memory stored center stack. For Messages and
   Settings, `effectiveCenterPanelStackProvider` gives a sidebar-independent spec
   (Environment Readiness/Onboarding) precedence.
4. A stored flow-managed spec never wins over the current flow projection; the
   resolver either uses the current projection or returns an empty stack.
5. Other stored, non-flow-managed specs are admitted only through compatibility
   rules in `_shouldHideStoredCenterPanel`.
6. For modes other than Messages/Settings, the raw stored center stack is used.

`PanelsViewState` is not a durable preference and starts empty in a new process.
`PanelStackSurface` returns its placeholder for an empty stack. Its
`AutomaticKeepAliveClientMixin` applies only to pages still present in the
current `IndexedStack`; it cannot retain a page after the effective stack is
empty. No durable serialized message payload or independently persisted contact
center page was found.

## 6. Conversations -> Contacts mode-switch state trace

Conversations and Contacts are top-menu branches inside `SidebarMode.messages`,
not two `SidebarMode` enum values.

The production dispatch path is:

```text
SidebarTopMenuActions.selectMessageMenuChoice
  -> SidebarActionDispatcher(TopMenuChanged)
  -> SidebarFlow.topMenuChangedRestoringContactContext
```

- Choosing **Conversations** calls `topMenuChanged` synchronously. It replaces
  the entire flow state with `topMenuChoice=conversations` and no selected
  conversation. `projectedCenterSpec` is therefore `null`; the effective center
  must be empty.
- Choosing **Contacts** performs an asynchronous read of preserved
  `sidebar_contact_context`. If it contains a contact ID, the method deliberately
  restores that ID and immediately projects that contact's message spec.
- Choosing **Contacts** without preserved context produces Contacts with no
  chosen contact and therefore an empty center.

No current telemetry records top-menu choice changes, so the historical exact
Conversations interval cannot be reconstructed. The code does not intentionally
retain a contact view in the Conversations/no-selection state, and the existing
runtime `chooseAnotherContact` trace proves a `null` projection results in an
empty center.

## 7. Stale center-content survival explanation

The proven survival path is not an independent center-page cache:

```text
Start Fresh preserves user_overlays.db
  -> sidebar_flow_navigation preserves Contacts + Rusung contact ID
  -> sidebar_contact_context preserves the same contact context
  -> next process SidebarFlow asynchronously restores that flow state
  -> Environment Readiness temporarily masks the flow projection
  -> import starts; readiness stack is cleared
  -> effective center immediately exposes MessagesSpec.forContact(Rusung)
```

`_restoreNavigationPreference` checks only disposal, a local-mutation race, and
whether a preference exists. It does not check installation state, graph
readiness, or whether the selected entity currently exists. Likewise,
`topMenuChangedRestoringContactContext` restores the contact context without an
admissibility check.

This fully explains stale contact selection across reset, restart, and import.
It does **not** prove that actual old messages were durably renderable while the
installation was virgin, and it does not explain a literally unchanged contact
page during a settled Conversations/no-selection state. That last human
observation remains unreconstructed; a rapid async Contacts restore race is
source-possible, but there is insufficient telemetry to claim it occurred.

## 8. Virgin classifier store/condition census

`MessageLensInstallationStateClassifier` considers:

- overlay existence, bounded readability, and schema support;
- presence existence, bounded readability, and schema support;
- source-scoped import existence/readability/schema;
- source-scoped imported-message count;
- non-live historical-source count;
- Conversation Graph existence/readability/schema;
- graph message count, chat count, and chat-to-message edge count;
- presence of retired `macos_import.db` / `working.db` artifacts;
- durable onboarding operation snapshot status and parse failure.

It returns `virgin` only when consequential derived counts/topology and retired
artifacts are absent and the operation snapshot is idle. Preserved overlay and
presence stores may remain valid and nonempty; that is intentional.

It does not classify UI navigation preferences inside the overlay as
consequential imported data, nor should a contact selection by itself turn an
otherwise clean installation into a completed or abandoned import.

## 9. Center-panel readable-store census

The contact-message center can read:

- the current `SidebarFlowState` and its overlay-restored IDs;
- Conversation Graph contacts, handles, chats, messages, edges, and FTS/indexed
  projections through central providers;
- overlay user intent and display-name overrides at read/merge time;
- presence/readiness providers where the surface needs them;
- attachment archive metadata and payloads only when rendering referenced
  attachments (not used in this audit).

Ordinary contact-message presentation does not use live Apple `chat.db` as a
fallback and does not render from `macos_import_ss.db` directly. No alternate
legacy graph database existed. No persisted in-memory widget cache can survive a
process restart.

## 10. Virgin-vs-UI admissibility comparison

```text
Virgin classifier considers:
- all consequential derived message rows/topology
- retired derived artifacts
- durable operation evidence
- bounded health of preserved/derived stores

Center selection admission currently considers:
- syntactic validity of the restored SidebarFlow preference
- whether local flow mutation won the restore race

Center message rendering considers:
- current graph/overlay providers after a ViewSpec is admitted
```

There is no hidden durable content store omitted from virgin classification.
The mismatch is at the navigation-admission layer: overlay navigation state is
correctly preserved, but a selected entity is treated as renderable without
checking whether the current installation state/graph admits the selection.

## 11. Was consequential message content durably available while virgin?

**No evidence says yes.** At the exact virgin startup:

- source import was absent;
- graph import message count was 0;
- the graph had no imported cursor;
- retired graph/import files were absent;
- the prior Start Fresh capture had verified the graph empty;
- no independent message cache or direct-source contact-message path exists.

What was durably available was the stale **selection ID** in the preserved
overlay. The log shows its contact ViewSpec becoming effective at import start,
before page 1 completed. Actual message content could then hydrate progressively
from the newly rebuilt graph. Historical pixels before import cannot be
reconstructed, but the strongest source- and log-supported finding is: stale
selection/projection restored first, newly rebuilt data hydrated it later.

## 12. Claire identity/name trace

Participant/contact ID: `17592186044433`.

- Overlay favourite intent exists and remains `is_favorited=1`.
- Current graph contact row is present with display name
  `Claire Merriman Campbell`, given name `Claire`, and family name
  `Merriman Campbell`.
- Graph contact-to-handle links include phone handle `8796093022213`
  (`+17789908506`, contact display value `(778) 990-8506`) and email handle
  `8796093022250` (`clairemc@gmail.com`).
- Chat-to-handle and chat-to-message topology exists for those identities.
- No participant display-name override or handle-to-participant override exists;
  the correct label is graph-derived.
- `SqliteDisplayIdentityRepository` maps the graph contact row and its canonical
  handle variants to one `ParticipantDisplayIdentity`.
- Picker and hero reach that identity through `contactsListRepositoryProvider`;
  the message header reaches the same `displayIdentityResolverProvider`
  directly.

The correct Claire identity existed in the completed graph. It was not created
by the click.

## 13. Rusung identity/name trace

Participant/contact ID: `17592186044472`.

- Overlay favourite intent exists and remains `is_favorited=1`.
- Current graph contact row is present with display name `Rusung Tan`, given
  name `Rusung`, and family name `Tan`.
- Linked handles include `rusung@icloud.com`, `rusung@gmail.com`,
  `+97466780166`, `+16478042698`, and `+15037760150`, with canonical graph
  mappings and chat associations.
- No participant display-name override or handle-to-participant override exists;
  the correct label is graph-derived.
- The same shared display-identity resolver is responsible for mapping the
  contact ID and handles to `Rusung Tan`.

Again, the durable graph identity was correct after import. The fallback was a
read-model currentness failure, not identity loss.

## 14. Exact picker fallback source path

```text
filteredPickerSectionsProvider
  -> groupedContactsProvider + favoriteContactsProvider
  -> contactsListRepositoryProvider
  -> contactsListReaderProvider
  -> GraphContactsListReader(read graph rows)
  -> captured DisplayIdentityResolver.resolveContact(contactId)
  -> fallback "contact $contactId" when resolver map lacks the ID
```

`GraphContactsListReader` reads the real graph `display_name` as
`autoGeneratedName`, but assigns the user-facing `displayName` from the captured
resolver. Therefore graph rows can be present while the visible label is the
lowercase fallback. `favoriteContactsProvider` joins overlay favourite IDs to
those same `ContactSummary` objects; it does not independently resolve names.

## 15. Exact phone-number selection action path

The row action is:

```text
ContactGroupedPickerWidget row
  -> ContactPickerActions.chooseContact
  -> unawaited prewarmContactProfile + prewarmContactMessages
  -> SidebarActionDispatcher(ContactChosen)
  -> SidebarFlow.contactChosen (synchronous selection/projection/rack change)
  -> ContactAccessActions.recordContactSelection
  -> overlay last-interaction update
  -> invalidate recentContactsProvider only
```

The action does not write graph identity, canonicalize a handle, bump
`messageDataVersionProvider`, invalidate `displayIdentityResolverProvider`, or
invalidate `contactsListRepositoryProvider`. The click was on a phone row in the
human interaction, but the dispatched semantic action selects the contact ID,
not a new identity mapping.

## 16. Exact mechanism that restored hero/header names

The resolver provider builds an immutable resolver snapshot from graph and
overlay. It watches database providers but not `messageDataVersionProvider`.
The resolver, contacts reader, and contacts list are generated as auto-dispose
providers.

The picker had retained consumers holding an empty-graph resolver snapshot.
Selecting the contact replaces the chooser cassette branch with the selected
contact branch and installs the contact center ViewSpec. That removes/replaces
the picker consumer tree and creates fresh hero/header consumers. Auto-disposal
then permits a new resolver construction against the now-populated graph:

- `ContactHeroSummaryWidget` reads/listens to
  `contactsListRepositoryProvider`;
- `contactEvidenceHeaderContextProvider` directly awaits
  `displayIdentityResolverProvider`.

Those newly created consumers received `Claire Merriman Campbell`. No data write
explains the repair; lifecycle-driven recreation of a stale immutable resolver
does. Provider lifecycle is not logged, so the exact disposal instant is inferred
from the generated auto-dispose declarations, the cassette transition, the
absence of any identity mutation/invalidation in the action, and the observed
correct result.

## 17. Exact mechanism that subsequently restored picker names

When the human returned to the picker, the chooser subtree was mounted again.
Its `filteredPickerSectionsProvider` rebuilt grouped/favourite sections through
the now-current contacts list/resolver chain. Both favourite IDs then resolved to
their graph-backed display identities.

This is not shared mutable cache population by the hero. It is consumer-tree
replacement plus auto-dispose/recreation. The fact that both names became correct
after one contact selection is expected because the recreated resolver reads the
entire contacts/handles identity set, not just the selected contact.

## 18. Is selection improperly serving as initialization?

**Yes, accidentally.** Selection is not designed as identity initialization,
and the action contains no such semantic operation. In this runtime shape,
however, selection was the event that replaced enough consumers for stale
auto-dispose providers to be recreated. The practical result is that selection
served as accidental initialization/currentness repair.

Classification: **provider-dependency/cache-coherence bug with an accidental
lifecycle initialization side effect**. It is not legitimate lazy loading.

## 19. Provider/cache/invalidation findings

1. `displayIdentityResolverProvider` does not watch
   `messageDataVersionProvider`.
2. `contactsListReaderProvider` captures one immutable resolver.
3. `contactsListRepositoryProvider` does watch message-data version, but a rerun
   may reuse the still-live reader and its stale resolver.
4. The graph build controller bumps message-data version correctly; the identity
   provider simply is not downstream of it.
5. Contact selection invalidates only `recentContactsProvider` after updating
   last interaction.
6. Picker, hero, and header are not three independent name authorities: picker
   and hero share the contacts list; header shares the underlying display
   identity resolver. That common stale dependency explains cross-surface
   convergence after recreation.
7. The failure is currentness/lifetime, not missing graph rows, broken canonical
   IDs, lost favourites, or an overlay conflict.

## 20. Common-root analysis

Verdict: **common enabling mechanism, separate defects**.

The common enabling mechanism is retained contact selection across the reset and
graph-generation boundary. It causes the contact center and its identity
consumers to exist while the graph is empty, creating the stale resolver timing
shape.

The defects remain distinct:

- center defect: restored navigation/contact context lacks installation/entity
  admissibility;
- name defect: display-identity/contacts-reader lifetime lacks graph-generation
  invalidation.

Neither requires an independent center-state authority or a second identity
authority to explain the observations.

## 21. Existing Mechanical-Impossibility test gap

Existing tests prove important but narrower invariants:

- a flow-managed stored center does not override the sidebar projection;
- Conversations with no selected conversation projects `null`;
- plain `topMenuChanged(Contacts)` with no selection projects `null`;
- `chooseAnotherContact` clears the selected-contact branch by derivation;
- startup and Contacts actions intentionally restore persisted contact context.

They enforce structural dependency and several local mode/no-selection
transitions. They do **not** combine:

- app restart;
- preserved `sidebar_flow_navigation` / `sidebar_contact_context`;
- current installation state `virgin`;
- an empty graph or a stale selected entity ID;
- production `topMenuChangedRestoringContactContext`;
- the Journey readiness panel being removed at import start;
- effective center identity before any newly imported row exists.

The test suite therefore proves “center follows SidebarFlow,” but not “restored
SidebarFlow is admissible for the current installation generation.”

## 22. Existing contact/picker test gap

Current display-identity repository tests construct/read after graph fixtures are
already populated. Contacts-list tests do not hold a resolver created against an
empty graph across a message-data version bump. Favourite tests override the
contacts list with already named summaries. Picker widget tests use resolved
fixtures.

Missing regression shape:

1. create resolver/reader while graph is empty;
2. retain a picker consumer;
3. populate/reopen graph through the supported build lifecycle;
4. bump message-data version;
5. assert favourite picker names are correct before any selection;
6. assert hero and message header agree without lifecycle priming.

No current test proves graph-completion invalidation of the shared display
identity resolver.

## 23. Original stuck-Onboarding defect verdict

**NOT REPRODUCED.** The operation did not remain stuck, self-deny, or publish a
false failure. The durable snapshot is `completed`, has no failure, records both
message-data build and durable-readiness verification, and is scoped to one
operation/session. The Prompt 35 single-flight correction is not implicated by
the observed regressions.

## 24. Durable clean-slate import verdict

**PASS.** Durable current facts reconcile:

- import messages: 138,822;
- graph messages: 138,822;
- graph contacts: 97;
- graph chats: 245;
- import contacts: 113;
- operation status: completed;
- durable verification finished at `2026-10-01T13:25:05.816715Z`;
- no operation failure.

Recorded anomaly counts are evidence, not omitted records: 13 unnormalized
messages, 20,764 recovered-unlinked messages, 35 unavailable rich-text payloads,
7 unresolved reactions, and 16 contact-enrichment-unavailable observations; all
omitted-record counts are zero.

## 25. Contact-name regression verdict

**FAIL / regression proven.** Correct graph names existed, but the first picker
projection used an empty-generation identity snapshot and displayed fallback
IDs. A user selection should not be required to make durable contact identities
visible.

## 26. Mechanical-Impossibility verdict

**FAIL at the admissibility boundary.** Flow-managed center content is still a
mechanical projection of current `SidebarFlowState`; no independent persistent
center authority was found. But the system permits a stale, virgin-inadmissible
selection to become current SidebarFlow state and therefore to project a center
spec. The stronger product invariant—only a currently admissible sidebar state
can have a center projection—is not mechanically enforced.

The literal claim of a contact page surviving a settled Conversations state is
not proven and is source-inconsistent; hence the causal explanation of the full
human report is partial rather than complete.

## 27. Overall clean-slate qualification verdict

**FAIL.** The destructive reset and import pipeline passed, but clean-slate
qualification includes immediate presentation correctness and sidebar-to-center
conformance. Both the restored-selection admissibility failure and first-load
contact-name currentness failure remain release-blocking for this qualification
run.

## 28. BLOCKER findings

1. A preserved contact selection is restored across a verified virgin boundary
   without installation or entity admissibility, and it becomes effective as
   soon as the readiness panel is removed.
2. Display identity can remain an empty-graph snapshot after graph completion,
   producing fallback IDs across picker/hero/header until lifecycle recreation.
3. No regression test covers virgin restart + restored selection + Journey
   readiness removal.
4. No regression test covers resolver creation before graph build and correct
   names immediately after the generation bump.

There is **no proven blocker** involving durable message content accessible from
an unclassified store while virgin and no proven independent persistent center
authority.

## 29. SHOULD FIX findings

1. Add diagnostic telemetry for top-menu transition request/completion and the
   resulting projected center spec, without content-bearing data.
2. Add bounded diagnostics for display-identity resolver construction generation
   and contact-count only; this would make future currentness failures directly
   observable.
3. Investigate the unrelated repeated macOS Scrollbar/no-ScrollPosition errors
   seen after import. They do not explain either audited symptom.
4. Consider whether both persisted navigation keys are necessary or whether one
   can be derived from the other. This is not required for the bounded fix.

## 30. Recommended bounded corrections

### A. Restore/admission correction

Keep the center a pure projection. Do not add a `Clear center` command. At the
SidebarFlow restore/admission boundary, validate restored entity-bearing
navigation against current installation/graph readiness. If the installation is
virgin, rebuilding, or the selected entity is absent from the admitted graph,
restore the branch without the selected entity (or retain the preference only as
non-effective historical navigation intent). Apply the same rule to
`topMenuChangedRestoringContactContext`.

Required tests:

- virgin startup + persisted contact => no chosen contact and no center spec;
- completed graph + existing persisted contact => restoration still works;
- completed graph + missing/stale contact => no center spec;
- production Conversations transition => empty center with no conversation;
- production Contacts restore => contact center only when admissible;
- Journey readiness removal cannot expose a virgin-inadmissible flow spec.

### B. Identity-generation correction

Make `displayIdentityResolverProvider` explicitly downstream of the authoritative
message-data/graph generation, so `contactsListReaderProvider` cannot retain a
resolver from an older generation. Preserve the singular resolver and existing
read paths; do not add a second name cache or selection-driven hydration layer.

Required tests:

- resolver/reader created at empty generation;
- graph populated and version bumped;
- Favourites immediately shows Claire and Rusung by name before selection;
- hero and header return the same names;
- selecting a contact is not required to prime any other surface.

These are bounded dependency/admission fixes. The evidence does not justify a
broad center-panel or Contacts architecture rewrite.

## 31. Exact Git/worktree/index/submodule state

At audit close:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream:
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- index: empty;
- tracked worktree: the same 29 accumulated Prompt 32 + Prompt 35 modified files
  present at audit start;
- accumulated tracked diff SHA-256:
  `88dd2190a8c989fcf7d1bbab5af49ff646b02a132ea423286353c6207c56f5be`;
- `git diff --check`: PASS;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311` (`heads/main`);
- untracked state: 44 porcelain entries / 63 individual files after adding this
  response;
- this Response 38 is one new intended untracked documentation file;
- every previously known unrelated untracked file remains untouched.

No file was staged, committed, pushed, restored, or removed.

## 32. Confirmation nothing was modified

No production source, generated source, test, release metadata, database,
archive configuration, attachment payload, app preference, favourite, contact,
message, or existing prompt/response was modified. MessageLens Development was
not launched or driven. Production data was not accessed. The development log
and all four relevant database main-file hashes match the opening capture, with
WAL/SHM files still absent.

The only workspace write is this requested Response 38 deliverable. The only
other audit write is the evidence manifest in `/private/tmp`.

---

`MECHANICAL-IMPOSSIBILITY FORENSIC AUDIT COMPLETE: YES`

`CENTER-PANEL STATE VIOLATION EXPLAINED: PARTIAL`

`CONTACT LAZY-RESOLUTION REGRESSION EXPLAINED: YES`

`ORIGINAL STUCK-ONBOARDING DEFECT REPRODUCED: NO`

`CORRECTED CLEAN-SLATE ONBOARDING QUALIFICATION: FAIL`
