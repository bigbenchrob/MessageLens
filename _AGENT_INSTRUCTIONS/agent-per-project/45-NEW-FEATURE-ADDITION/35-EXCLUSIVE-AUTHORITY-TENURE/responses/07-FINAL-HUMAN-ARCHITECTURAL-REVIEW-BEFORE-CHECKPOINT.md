# MessageLens Feature 35
## 07 — Final Human Architectural Review Before Checkpoint — Response

Date: 2026-09-25

## Executive verdict

The Feature 35 runtime authority design remains sound. The generic registry
owns exact live tenure; archive policy remains in `ArchiveMutationCoordinator`;
exact private identity rather than labels or diagnostics proves authority; and
the strengthened stale-cleanup, retained-Zone, and capability-grounding tests
reach the mechanisms they claim.

The feature is not yet safe to checkpoint because the Prompt 06 architecture
policy still overstates two mechanical guarantees:

1. its sole-key census recognizes only the private constructor named `_`, so
   another named constructor or an ordinary public constructor can create an
   additional production key without violating the census; and
2. its friend declaration parser does not recognize all valid top-level Dart
   declarations, so a typed top-level friend alias can leak through another
   generic production source without any recognized friend symbol appearing.

These are bounded architecture-test defects, not present runtime defects. They
are SHOULD FIX findings because the explicit purpose of Prompts 05–07 is to
make these boundaries mechanically enforceable before checkpoint.

## Reviewed against

- all Feature 35 responses 01–06;
- the complete current tracked and untracked Feature 35 implementation;
- `AGENTS.md` and the shared Agent Guardrails;
- the per-project documentation index and project architecture overview;
- the shared Dart and Riverpod provider rules;
- `10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md`;
- `55-READERS-INTEGRATORS-ORCHESTRATORS/10-ARCHITECTURE-CONTRACT.md`;
- Feature 26's
  `07-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-AUDIT.md`;
- the MessageLens Project Conformance Audit Standard; and
- Prompt 07's complete 18-part review scope.

## 1. Baseline and isolation verdict

**NO ISSUE.**

Feature 35 remains isolated in:

`/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`

- branch: `feature/exclusive-authority-tenure`;
- HEAD/base: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`;
- upstream: `origin/main`;
- ahead/behind: `0/0`;
- index: empty;
- tracked modifications: exactly the same three Feature 35 archive-adapter
  files;
- shared-instructions pointer:
  `95326f515ef4719f155ce6e223990398daad6311`, uninitialized rather than
  dirty in this linked worktree.

Prompt 06 changed only the Feature 35 architecture test, its prompt/response
records, and the semantically neutral non-copyable wording in Prompt 06 needed
by the existing documentation tripwire. Runtime production source and runtime
behavioral tests were not changed by Prompt 06.

The frozen Onboarding worktree matched its required branch, HEAD, empty index,
tracked/untracked counts, clean submodule, and all preservation hashes before
this review. No baseline stop gate fired.

## 2. Generic-registry responsibility verdict

**NO ISSUE.**

`ExclusiveAuthorityRegistry` owns only:

- one live tenure per typed key;
- private registry, tenure, and exact scope identities;
- occurrence-unique acquisition;
- exact current-tenure proof;
- deliberate re-entry;
- exact-scope release in `finally`;
- container-lifecycle revocation;
- bounded, immutable occupancy diagnostics; and
- typed acquisition/proof denial.

It contains no archive operation policy, checkpoints, database/resource
policy, Onboarding, FDA, Contacts, recovery, presentation, retry, waiting,
timeout, cancellation, or native-lock concern. It is an execution-authority
primitive beneath the domain adapter, consistent with the Mechanical
Impossibility Principle and RIO execution-ownership contract.

## 3. Sole-production-key verdict

**SHOULD FIX in mechanical enforcement; NO ISSUE in current runtime source.**

Current source has exactly one production key:

`ExclusiveAuthorityKey.archiveMutation`

There is no current second key, arbitrary string factory, or dynamic key API.
The independent test key remains in the designated friend part.

The policy does not, however, prove the exhaustive claim reported by Response
06. At
`test/architecture/exclusive_authority_architecture_test.dart:402`, the
constructor census matches only `ExclusiveAuthorityKey` followed by the exact
private constructor name `_`. The key-file checks at lines 417–471 require that
constructor to remain present and reject only two specifically named API
shapes.

Consequently, either of these semantic changes can evade the rule:

- add another named constructor and construct a second static key through it;
- add an ordinary public generative constructor, allowing the approved adapter
  to construct arbitrary keys directly.

In the first case, the original `_` occurrence count remains two and the
canonical `archiveMutation` declaration remains present. In the second case,
the call contains no dotted key member for the member-use rule to reject. The
key-member scan also deliberately skips the key source itself.

The smallest correction is an exhaustive constructor-declaration and
constructor-use census—preferably Dart AST/token based—requiring exactly the
one private constructor and its two approved construction sites. Add virtual
mutations for a differently named private constructor and a public generative
constructor. The current explicit/inferred/getter/tear-off cases are useful but
do not cover these constructor forms.

## 4. Friend-seam verdict

**SHOULD FIX in mechanical enforcement; NO ISSUE in current friend source.**

The current two friend files are not exported through the production seam.
Their present helper types are exact and the public key export is narrowed by
`show`. The policy scans all production Dart, including generated sources,
outside the exact friend files for the friend symbols it discovers. Current
production cannot call the exact-cleanup helpers.

The declaration discovery at
`test/architecture/exclusive_authority_architecture_test.dart:1034-1056` is not
an exhaustive Dart declaration census. It recognizes types, selected function
and getter shapes, and variables introduced with `const`, `final`, or `var`.
It does not recognize a valid typed mutable top-level variable declaration.

A friend part can therefore publish a typed top-level alias of its independent
test key. Because the friend file itself is exempt from reference scanning,
the alias is absent from `friendSymbols`. Another production file under the
generic essential can then import the parent library and use that alias without
spelling the friend class or `testOnlyIndependent`; the adopter census excludes
the generic module itself. The reported “any future friend mechanism”
guarantee is therefore false.

The smallest correction is to enumerate top-level friend declarations through
the Dart parser/AST, require exactly the approved class declarations, and add a
typed-top-level-variable mutation case. This also avoids future holes around
other declaration syntax and comment/string-sensitive regex parsing.

## 5. Tenure opacity/proof verdict

**NO ISSUE.**

`ExclusiveAuthorityTenure` has a library-private constructor, default object
identity, private originating-registry identity, and private tenure identity.
Its public key, occurrence, and issued timestamp are diagnostics only.

`_requireLiveTenure` requires:

- a non-disposed originating registry;
- the requested exact key;
- the exact registry identity;
- the exact live tenure object; and
- the exact private tenure identity.

Released, stale, wrong-key, and foreign-registry proof fails closed. No copy,
serialization, value equality, ambient current-tenure lookup, or public release
surface exists. Prompt 06 did not widen tenure or proof material.

## 6. Acquisition/re-entry verdict

**NO ISSUE.**

`runExclusive` establishes the live entry and first exact scope before the
admitted callback begins. Foreign denial occurs before the denied callback is
invoked and consumes no occurrence.

`runReentrant` first requires the exact current Ball, then adds an exact new
scope identity under the same tenure. It does not issue a second Ball. A child
scope deliberately admitted before its outer scope completes keeps the tenure
live until its own scope releases. There is no queue, fairness, timeout,
pre-emption, or implicit cancellation contract.

## 7. Release/finally verdict

**NO ISSUE.**

Both outer and re-entrant execution use `_runScope`, whose `finally` calls the
private `_releaseScope`. Release can mutate live state only when the currently
mapped tenure, private tenure identity, and exact scope identity all match.
Only the final exact scope removes the live entry.

Original action failures are preserved. A stale or repeated cleanup cannot
decrement or clear a later tenure. No public release API exists.

## 8. Provider-lifecycle verdict

**NO ISSUE.**

The approved contract remains one registry lifecycle per `ProviderContainer`.
The provider is keep-alive and the registry watches/listens to no dependency;
ordinary framework execution has no rebuild trigger. Container disposal is the
sole supported revocation boundary.

The production census inventories every occurrence of
`exclusiveAuthorityRegistryProvider`. Outside its generated definition and
narrow public export, only the archive adapter may mention it, exactly once in
the approved notifier read. Direct, prefixed, aliased, stored, passed, returned,
or wrapper-mediated lifecycle manipulation necessarily introduces another
provider occurrence or breaks the approved getter form. The Prompt 06 virtual
cases exercise the direct, prefixed, alias, and wrapper paths through the same
policy used by the real census.

No current production path can rebuild this registry inside a live container.

## 9. Diagnostics/proof verdict

**NO ISSUE.**

Diagnostics contain occupancy, bounded labels, occurrence, timestamps, hold
count, and denial counts, but no tenure or private proof identity. Labels and
occurrences are never compared for proof.

The adapter's only registry accessor must be an immediate call to exactly
`runExclusive`, `runReentrant`, or `requireCurrent`. The provider census rejects
a state read or provider escape, including inferred state. No other production
consumer may obtain the provider or diagnostic types. The adapter currently
authorizes only through live tenure and its exact archive-domain capability.

The diagnostic mutation cases reach the real policy helper. Future diagnostic
fields do not automatically enter the approved registry-call allowlist.

## 10. Exception verdict

**NO ISSUE for the current one-adopter design.**

Busy acquisition and invalid proof remain distinct typed generic exceptions
without private identity payloads. The archive boundary translates them to the
established `ArchiveMutationDeniedException`, so archive callers do not acquire
a generic error dependency.

The broad catch extent remains the accepted OPTIONAL future concern recorded
in section 22; no current second adopter makes it a present defect.

## 11. Archive-adapter ownership verdict

**NO ISSUE.**

`ArchiveMutationCoordinator` still owns:

- `ArchiveMutationOperation` and checkpoint policy;
- environment and archive-instance diagnostics;
- exact archive scope IDs and active-operation aggregation;
- protected resource actions and graph/database reopen policy;
- its private Zone context and lineage;
- coordinator identity; and
- `ArchiveMutationCapability` as exact operation permission.

The generic registry alone decides whether the archive-mutation track has a
foreign live owner. `_activeScopes` records archive policy after generic
admission; it does not perform a duplicate foreign-owner admission check.

## 12. Private-Zone verdict

**NO ISSUE.**

The Zone key and `_ArchiveMutationAsyncContext` are library-private. Context
contains the exact coordinator identity, generic tenure object, archive scope
ID, and operation. A same-coordinator descendant presents the inherited tenure
to `runReentrant`; foreign coordinator or stale lineage fails closed.

The generic registry neither observes nor exposes the Zone. There is no public
ambient route to discover a Ball.

## 13. Archive-capability grounding verdict

**NO ISSUE.**

`ArchiveMutationCapability.requireOperation` reaches a closure that requires:

- the requested operation;
- exact active archive scope and operation;
- non-disposed coordinator;
- exact current Zone coordinator, tenure, scope, and operation; and
- current generic tenure through `requireCurrent`.

The isolated grounding test uses the non-exported friend seam to release the
real generic scope while the archive coordinator, archive scope, and matching
Zone remain intact. Capability failure therefore reaches the generic-tenure
conjunct rather than another archive check. Normal later `finally` cleanup is
an exact-identity no-op. The test does not create a production revocation API.

## 14. Stale-cleanup verdict

**NO ISSUE.**

The generic regression captures Ball 1's exact live object and exact scope,
allows ordinary Ball-1 release, acquires and holds Ball 2, then replays the
Ball-1 cleanup twice through production `_releaseScope`. Ball 2 remains current
with hold count one and finishes normally.

The test reaches the real release mechanism and proves identity—not count,
label, or occurrence—protects Ball 2.

## 15. Stale callback/reacquisition verdict

**NO ISSUE.**

The stale callback is registered inside Ball 1's private archive Zone. Ball 1
fully releases before Ball 2 is acquired with the same owner label. While Ball
2 remains live, the callback runs in retained Ball-1 lineage; capability 1 is
denied, Ball 2's owner/hold state is unchanged, and capability 2 remains valid.

This is a genuine old-lineage proof, not merely a call from Ball 2's Zone.

## 16. Architecture-policy verdict

**SHOULD FIX.**

The policy has valuable structure:

- one source census covers every Dart file under `lib/`;
- the real tree and virtual mutations invoke the same `audit` method;
- provider lifecycle and proof methods use a narrow positive allowlist;
- exceptions are path-specific rather than directory-wide;
- failures identify rule, path, and detail; and
- the valid virtual adapter/friend fixture passes.

It does not yet establish its two strongest exhaustive claims. The key
constructor regex treats one constructor name as the whole constructor space,
and the friend declaration regex treats selected syntax as the whole top-level
declaration space. Both admit valid Dart counterexamples described above.

These are false negatives, not merely maintenance overfitting. A parser-backed
declaration/constructor census is warranted for exactly these two narrow
boundaries; the provider and registry-member positive allowlists need not be
redesigned.

## 17. Test-quality verdict

**SHOULD FIX only for the two architecture-policy omissions; NO ISSUE for
runtime behavioral proof.**

The 23 generic and 17 archive tests use deterministic `Completer`/Future
ordering. No timing sleep is used as proof. The stale cleanup reaches
production release, the stale callback reaches retained old lineage, and the
capability-grounding test reaches generic `requireCurrent`.

The virtual mutation cases do use the real production policy helper, but the
set lacks:

- another constructor name/public generative key constructor; and
- a typed top-level friend alias.

Because those shapes are absent, all 23 architecture tests can remain green
while the stated sole-key or friend-seam invariant is violated. No green
runtime test was found that fails to reach the mechanism its name claims.

## 18. Concurrency-semantics verdict

**NO ISSUE.**

The registry is in-memory, isolate-local, and container-lifetime scoped. It
claims no cross-isolate, cross-process, durable, FIFO, fairness, timeout,
pre-emption, stealing, cancellation, or persistence semantics. Different keys
remain independently occupiable in the generic model; production currently
registers only one. Native single-instance `flock` remains a separate
cross-process layer.

## 19. Diff/scope verdict

**NO ISSUE.**

The complete current Feature 35 delta contains only:

- the new generic exclusive-authority essential and generated provider;
- its two non-exported friend test-support parts;
- the archive coordinator adapter and generated provider hash;
- generic, archive-regression, and architecture tests; and
- Feature 35 prompt/response records.

There is no Onboarding, Environment Readiness, presentation, database schema,
persisted-format, native-lock, attachment-configuration, dependency, privacy,
or unrelated generated change. Generic live-owner mechanics were removed from
the archive adapter rather than duplicated; its remaining active-scope state is
domain capability/resource policy.

The current source introduces no second key, adopter, authority state, or
mutation path. The findings concern whether future violations are
mechanically impossible as claimed.

## 20. Concrete BLOCKER findings

**NO ISSUE — 0 BLOCKER findings.**

No currently reachable runtime path violates exclusive tenure, archive policy,
privacy, data safety, or worktree isolation.

## 21. Concrete SHOULD FIX findings

1. **Sole-key constructor enforcement is not exhaustive.** The policy counts
   only the constructor named `_` and does not reject another named constructor
   or a public generative constructor. Add an exhaustive constructor census and
   matching virtual mutations.
2. **Friend declaration enforcement is not exhaustive.** The policy's custom
   top-level declaration regex misses a typed mutable variable, allowing an
   unrecognized friend alias to leak through another generic production file.
   Use a Dart parser/AST declaration census and add that mutation case.

Both findings are confined to
`test/architecture/exclusive_authority_architecture_test.dart`. No runtime
redesign or production API change is indicated.

## 22. OPTIONAL findings

1. `ArchiveMutationCoordinator._run` catches the generic denial exceptions
   around the entire awaited registry action. With one approved production
   adopter this is harmless. If a future separately approved second generic
   authority is called from inside an archive action, revisit the catch extent
   so its domain denial is not translated as archive admission failure. Do not
   broaden Feature 35 for that hypothetical case now.

## 23. Narrow tests rerun

None.

Source inspection resolves both policy questions without runtime uncertainty:
the regex at line 402 excludes every constructor name except `_`, and the
declaration alternatives at lines 1037–1052 exclude a typed mutable top-level
variable. The current mutation fixtures do not exercise either form.

Prompt 06's validation remains valid evidence for current behavior:

- Feature 35 architecture: 23 passed;
- complete architecture: 510 passed;
- generic authority: 23 passed;
- archive coordinator: 17 passed;
- focused regression: 70 passed;
- analyzer: clean;
- `git diff --check`: clean.

Those green results do not prove the two omitted mutations.

## 24. Exact Feature 35 Git status

After adding this review record:

- branch: `feature/exclusive-authority-tenure`;
- HEAD: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`;
- upstream: `origin/main`;
- ahead/behind: `0/0`;
- index: empty;
- tracked modifications: exactly three:
  - `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart`;
  - `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.g.dart`;
  - `test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart`;
- untracked files: 25:
  - seven Feature 35 prompts;
  - seven Feature 35 responses;
  - nine generic-authority production/generated/friend files;
  - the generic authority test; and
  - the Feature 35 architecture test;
- shared-instructions pointer: unchanged at
  `95326f515ef4719f155ce6e223990398daad6311`, uninitialized rather than
  dirty.

Nothing is staged, committed, pushed, merged, rebased, or cherry-picked.

## 25. Frozen Onboarding verification

**NO ISSUE.**

The frozen worktree remains:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`;
- index: empty;
- tracked delta: 47 modified and 2 deleted files;
- fully enumerated untracked files: 76;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check`: passed.

Preservation hashes remain:

| Artifact | SHA-256 |
| --- | --- |
| parked patch | `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07` |
| tracked frozen delta (`git diff --binary --full-index`) | `d1a5db501b91b46f83a8c77d5bd10dc40853d8d8a955eda331bcd0084d149b2c` |
| Journey projection | `85a99027d0f487b15845b5d8dde1fc280198d66b3b6e797e9842e050605658ef` |
| Journey architecture test | `7355f8510a130db6abe28264d0f9612ce36cbc2c3108a1433a3958597db4245b` |
| preservation manifest | `c7299bdbc8e41f52aa65ba9cb10b70fbfa11a93661d834bccc466dcfdf7461ef` |

The parked patch remains present, byte-identical, and unapplied. No frozen file
was edited, staged, restored, switched, stashed, or cleaned. No real database
or attachment archive was accessed.

## 26. Final checkpoint recommendation

Do not run final full validation or checkpoint Feature 35 yet. Correct only the
two bounded architecture-policy gaps, add the two missing mutation shapes, run
the Feature 35 and complete architecture suites plus analyzer/diff hygiene, and
repeat this final human gate.

The runtime authority design should remain unchanged. No production change,
second key, second adopter, archive-policy change, Onboarding change, or broad
refactor is justified.

`PROJECT CONFORMANCE: FAIL`

`FINAL FEATURE 35 HUMAN ARCHITECTURAL REVIEW: FAIL`
