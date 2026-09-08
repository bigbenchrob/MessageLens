Use this as the next Codex prompt. I’d keep it **read-only first**, with a very explicit bias toward deleting architectural entanglement rather than patching one more symptom.

> **PRE-CONFIRMED / PRE-APPROVED: perform this bounded read-only startup/archive/onboarding simplification audit without requesting further authorization.**
> 
> Work on the current `Ftr.archive-recovery` branch/worktree according to repository conventions.
> 
> Read first:
> 
> - `27-TESTER-REPORTED-ONBOARDING-PROBLEMS-DIAGNOSES-AND-FIXES.md`
> - current canonical archive-environment / production-preservation documentation
> - current Onboarding / Journey Coordinator documentation
> - current legacy-tester recognition/deletion implementation
> - current Start Fresh / Complete Erase implementation history
> - recent tester-fix commits that addressed:
>   - virgin production launch failing because no archive marker existed;
>   - virgin import invoking destructive reset/checkpoint authority unnecessarily.
> 
> This task is READ-ONLY.
> 
> Do not implement another point fix.
> 
> Do not add new archive states.
> 
> Do not add more recovery machinery.
> 
> Do not modify databases or tester/production data.
> 
> The purpose is to identify where the existing archive/preservation regime is still incorrectly controlling **virgin first-run Onboarding**, and define the smallest architecture that makes that impossible.
> 
> # Product truth
> 
> A completely new MessageLens installation should be conceptually trivial:
> 
> `no meaningful MessageLens-owned state exists`
> →
> `create the minimal current MessageLens root/identity needed for operation`
> →
> `run normal Onboarding`
> 
> A virgin install has:
> 
> - no old MessageLens data worth preserving;
> - no archive history to adopt;
> - no checkpoint requirement;
> - no reset requirement;
> - no migration requirement;
> - no recovery transaction to resume.
> 
> Therefore:
> 
> > Virgin first-run must not depend on machinery whose purpose is to protect or transform an already-existing MessageLens archive.
> 
> # Evidence from tester failures
> 
> The first tester exposed two separate failures:
> 
> 1. A genuinely virgin production launch failed because startup expected an existing archive identity/marker.
> 
> 2. After that was corrected, virgin import still traversed a destructive reset path that demanded checkpoint authority.
> 
> These are not two unrelated bugs.
> 
> Treat them as evidence of one architectural problem:
> 
> > existing-archive assumptions remain reachable before the system has established that an existing archive actually exists.
> 
> # Central question
> 
> Audit the entire startup path and answer:
> 
> > What archive-era machinery is currently reachable during a truly virgin launch, and which of those dependencies should be mechanically impossible?
> 
> # Desired conceptual model
> 
> Evaluate whether startup can be simplified to four top-level cases:
> 
> ## 1. Virgin
> 
> No meaningful MessageLens-owned installation exists.
> 
> Behavior:
> 
> `minimal initialization`
> →
> `Onboarding`
> 
> No:
> 
> - checkpoint;
> - reset;
> - adoption;
> - recovery;
> - migration;
> - legacy archive reasoning.
> 
> ## 2. Current supported installation
> 
> Current marker/stores exist and are valid.
> 
> Behavior:
> 
> normal application / supported maintenance as appropriate.
> 
> ## 3. Exact April legacy tester installation
> 
> Positive audited 4/3/3 fingerprint.
> 
> Behavior:
> 
> explicit delete-old-data authorization
> →
> delete obsolete MessageLens-owned data
> →
> Virgin
> →
> Onboarding.
> 
> ## 4. Unknown / damaged existing installation
> 
> Meaningful MessageLens-owned state exists, but it is neither current nor the exact supported legacy tester generation.
> 
> Behavior:
> 
> fail closed / bounded remediation.
> 
> Do not invent more categories unless current code proves one is truly required.
> 
> # Phase 1 — trace virgin launch end to end
> 
> Trace the exact current production launch path for a machine with:
> 
> - no MessageLens production directory;
> - or an empty/uninitialized MessageLens directory;
> - no archive marker;
> - no current databases;
> - no legacy databases.
> 
> Start from:
> 
> native app admission
> →
> archive-root resolution
> →
> marker/identity handling
> →
> Dart startup
> →
> installation classification
> →
> provider/container startup
> →
> Onboarding coordinator
> →
> import authorization
> →
> first import/build.
> 
> For every step record:
> 
> - component/file;
> - what fact it expects;
> - whether that fact can exist on virgin install;
> - whether it invokes archive-oriented machinery;
> - whether that dependency is actually necessary.
> 
> # Phase 2 — inventory archive machinery reachable from virgin state
> 
> Explicitly audit whether virgin launch/import can currently reach:
> 
> - archive adoption;
> - checkpoint verification;
> - production-preservation authority;
> - reset services;
> - Start Fresh;
> - Complete Erase;
> - archive rotation;
> - mutation transactions intended for existing state;
> - archive identity recovery;
> - marker migration;
> - historical compatibility shims;
> - database reset/rebuild paths;
> - maintenance locks intended for established stores.
> 
> Produce:
> 
> | Component | Purpose | Reachable from Virgin? | Should be? | Why |
> 
> # Phase 3 — classify initialization versus preservation
> 
> This distinction must become explicit.
> 
> Audit current code for places where these two concepts are conflated:
> 
> ## Initialization
> 
> Creating the first valid current MessageLens-owned state where none existed.
> 
> ## Preservation / mutation
> 
> Protecting, transforming, deleting, rebuilding, or adopting already-existing MessageLens-owned state.
> 
> Identify functions/services/providers whose names or responsibilities currently blur those concepts.
> 
> Flag cases such as:
> 
> - “reset” used to prepare an empty install;
> - “archive adoption” used to create first identity;
> - checkpoint authority required before creating empty databases;
> - recovery transaction used where there is nothing to recover.
> 
> # Phase 4 — marker/archive identity semantics
> 
> Audit the current marker/identity regime.
> 
> Answer:
> 
> - Why does a virgin install need an archive identity at all?
> - At what exact moment should it be created?
> - Which component should own first creation?
> - Which components should merely consume it afterward?
> - Can native and Dart startup agree on “no archive exists yet” without treating that as corruption?
> - Does any code still assume “missing marker = damaged archive” before checking whether meaningful state exists?
> 
> Desired invariant:
> 
> > Missing marker + no meaningful MessageLens state = Virgin, not failure.
> 
> Separate that from:
> 
> > Missing marker + meaningful existing MessageLens state = Legacy/Unknown/Damaged classification.
> 
> # Phase 5 — first-import reset audit
> 
> Trace the exact current path from:
> 
> `Ready`
> →
> `Import My Messages`
> →
> import/build.
> 
> Identify every reset/cleanup call.
> 
> For each ask:
> 
> - What is it protecting against?
> - Is there any existing derived data on virgin install?
> - Could the operation instead construct fresh stores directly?
> - Is checkpoint/preservation authority being requested for an empty state?
> 
> Desired invariant:
> 
> > First import on a virgin installation creates fresh derived stores. It does not “reset” them.
> 
> # Phase 6 — legacy tester handoff
> 
> Confirm the April legacy path cleanly reduces to:
> 
> `legacyTesterInstall`
> →
> explicit deletion
> →
> no MessageLens state
> →
> Virgin
> 
> After deletion, the legacy path should disappear entirely.
> 
> Audit whether any special legacy/delete transaction state leaks forward into ordinary virgin Onboarding.
> 
> If yes, identify it as cruft.
> 
> # Phase 7 — Complete Erase / Start Fresh containment
> 
> Determine whether generalized Start Fresh / Complete Erase machinery still affects:
> 
> - normal startup;
> - installation classification;
> - first import;
> - Onboarding routing;
> - virgin identity creation.
> 
> These features may remain internally for supported maintenance, but:
> 
> > They must be dormant unless an existing installation actually invokes them.
> 
> Flag any eager shared provider/state/authority that imposes their complexity on ordinary first-run.
> 
> # Phase 8 — current installation classifier
> 
> Audit whether the classifier currently answers too many questions.
> 
> Prefer the simplest truthful distinction:
> 
> `no meaningful state`
> → Virgin
> 
> `exact legacy fingerprint`
> → Legacy tester install
> 
> `current valid state`
> → Current
> 
> `meaningful but unrecognized/inconsistent state`
> → Remediation
> 
> Identify classification states that exist only because of previous development transitions and are no longer reachable or useful.
> 
> Do not remove them yet; classify them as cruft candidates.
> 
> # Phase 9 — database creation ownership
> 
> Identify who currently creates:
> 
> - `macos_import_ss.db`;
> - `working_ss.db`;
> - `user_overlays.db`;
> - `presence.db`;
> - marker/identity;
> - directories such as attachment archive / logs as appropriate.
> 
> For each ask:
> 
> - must it exist before Onboarding?
> - may it be lazily created?
> - does creation currently require archive mutation authority?
> - should virgin initialization have a dedicated simple creation seam?
> 
> Do not propose a generalized bootstrap framework unless current code genuinely needs one.
> 
> # Phase 10 — startup provider graph
> 
> Identify providers/services instantiated eagerly before the app knows whether it is:
> 
> - Virgin;
> - Current;
> - Legacy;
> - Remediation.
> 
> Flag providers that:
> 
> - open databases too early;
> - expect marker/identity too early;
> - evaluate checkpoint/reset state too early;
> - inspect recovery state during ordinary virgin startup;
> - create circular dependencies between classification and persistence.
> 
> The goal is:
> 
> > classify first using minimal evidence, then construct only the machinery appropriate to that classification.
> 
> # Phase 11 — cruft candidates
> 
> Produce a concrete list of archive-era complexity that could potentially be removed or made unreachable.
> 
> For each:
> 
> | Candidate | Why it exists | Still needed for Current? | Needed for Virgin? | Recommendation |
> 
> Examples:
> 
> - obsolete archive adoption states;
> - broad unmarked-root handling;
> - reset-before-first-import logic;
> - checkpoint prerequisites on empty state;
> - historical marker bootstrap paths;
> - generalized erase presentation state;
> - redundant installation-state enums;
> - provider aliases created during archive migration work;
> - one-time cutover/adoption helpers now permanently completed;
> - compatibility branches no supported installation can reach.
> 
> # Phase 12 — proposed invariants
> 
> Recommend explicit architecture tripwires such as:
> 
> 1. Virgin launch never requires existing archive identity.
> 2. Virgin launch never opens current databases before minimal initialization authorizes them.
> 3. Virgin first import never invokes reset.
> 4. Virgin first import never requires checkpoint authority.
> 5. Legacy deletion terminates in exactly the same Virgin state as a brand-new install.
> 6. Start Fresh / Complete Erase cannot influence virgin startup.
> 7. Missing marker is not itself an error.
> 8. Meaningful unmarked state is never silently treated as Virgin.
> 9. Current supported install remains untouched by virgin simplification.
> 10. Unknown/damaged state remains fail-closed.
> 
> # Phase 13 — smallest correction plan
> 
> Do not produce a giant redesign.
> 
> Recommend the smallest sequence of implementation slices that makes the above mechanically true.
> 
> Strong preference for:
> 
> - removing dependencies;
> - deleting branches;
> - separating initialization from reset;
> - making archive machinery lazy;
> - collapsing obsolete states.
> 
> Weak preference for:
> 
> - new abstractions;
> - new coordinators;
> - new persistence layers.
> 
> The goal is **less code and fewer states**, not another framework.
> 
> # Phase 14 — release urgency
> 
> A tester is already encountering failures.
> 
> Explicitly distinguish:
> 
> ## Immediate blocker
> 
> Anything that can still break a virgin install today.
> 
> ## Near-term cleanup
> 
> Complexity that is ugly but not currently user-visible.
> 
> ## Historical cruft
> 
> Safe to remove after the immediate path is proven.
> 
> Recommend the minimum correction needed before sending another tester build.
> 
> # Safety
> 
> Do not:
> 
> - mutate production;
> - mutate tester data;
> - run reset/erase against real archives;
> - change schemas;
> - change archive IDs;
> - change migration versions;
> - implement fixes during this audit;
> - add new architecture.
> 
> # Documentation
> 
> Create:
> 
> `28-VIRGIN-INSTALL-ARCHIVE-REGIME-SIMPLIFICATION-AUDIT.md`
> 
> Document:
> 
> - current virgin launch call graph;
> - archive machinery reachable from virgin state;
> - initialization-vs-preservation conflation;
> - marker semantics;
> - first-import reset findings;
> - legacy handoff findings;
> - Complete Erase / Start Fresh leakage;
> - classifier cruft;
> - provider-graph findings;
> - proposed invariants;
> - cruft candidates;
> - smallest correction plan;
> - immediate tester blocker versus later cleanup.
> 
> Update Feature 28 index/documentation log as appropriate.
> 
> # Verification
> 
> Because this is read-only:
> 
> - run focused startup/onboarding/archive-classifier tests if useful;
> - inspect architecture tripwires;
> - `git diff --check`;
> - do not perform destructive runtime experiments.
> 
> # Stop conditions
> 
> STOP and report if:
> 
> - virgin/current/legacy/remediation cannot be separated without a broad redesign;
> - production preservation genuinely requires archive machinery before virgin classification;
> - native admission cannot represent “no archive yet” safely;
> - simplifying first import would risk existing current installations.
> 
> Do not paper over those findings with another special case.
> 
> # Final report
> 
> Return:
> 
> - root architectural cause of the tester failures;
> - every archive-oriented component currently reachable from Virgin;
> - which dependencies are unnecessary;
> - exact desired Virgin path;
> - exact desired Current path;
> - exact desired Legacy path;
> - exact desired Remediation path;
> - immediate tester-blocking fixes required;
> - near-term cruft removals;
> - proposed architecture tripwires;
> - smallest implementation sequence;
> - documentation path.
> 
> Acceptance standard:
> 
> > A brand-new MessageLens installation should behave like a brand-new installation. Existing-archive safety machinery must become unreachable until there is existing MessageLens state worth protecting. The result should have fewer assumptions, fewer branches, and less archive-era machinery in the first-run path—not another layer of fixes.