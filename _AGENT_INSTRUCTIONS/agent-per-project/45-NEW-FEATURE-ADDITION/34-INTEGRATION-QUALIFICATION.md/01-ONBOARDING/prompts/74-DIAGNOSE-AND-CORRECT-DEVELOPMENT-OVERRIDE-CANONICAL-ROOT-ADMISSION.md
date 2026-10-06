# MessageLens Feature 34
## 74 — Diagnose and Correct the Development-Override Canonical-Root Admission Contract

Response 73 stopped correctly before AppCzar.

The failure was:

```text
MessageLens could not open its archive

ArchiveAdmissionException(
  ArchiveAdmissionFailure.nonCanonicalRoot
):
Archive root is not canonical for development.
```

The disposable safe-empty fixture itself was valid enough to contain a current
development archive marker, and the macOS launch context read back the exact
fixture root. Native bootstrap consumed the override far enough to produce a
development archive claim, but Dart archive admission rejected that claim as
noncanonical.

Therefore this is **not yet evidence of an AppCzar Onboarding defect**.

It is a contradiction in the development launch/admission contract that must be
resolved before Prompt 73 can be rerun.

The intended architecture is already clear:

```text
MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
    is a development-only exact-root override

native bootstrap
    independently resolves/canonicalizes that override
    -> NativeArchiveClaim(root)

Dart admission
    independently resolves/canonicalizes the same override
    -> ExactCanonicalArchiveRootPolicy(expectedRoot)

claim.root == expectedRoot
    -> root may proceed to marker/identity admission

claim.root != expectedRoot
    -> fail closed
```

The correction must preserve the **independent agreement check**.

Do NOT "fix" this by trusting the native claim alone.
Do NOT accept arbitrary claim roots.
Do NOT weaken production root admission.
Do NOT hard-code `/private/tmp` as special.
Do NOT point any test at the user's real development archive.
Do NOT launch production MessageLens.

This task should diagnose the exact divergence, make the smallest source-grounded
correction, validate it with temporary roots, build the corrected development
artifact, and stop.

Human Onboarding qualification remains a separate rerun.

---

# 1. Baseline

Primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`
- HEAD/upstream:
  `ed84400ef3440b5485e77313cad01fa5bc1bb618`
- ahead/behind `0/0`;
- tracked worktree clean;
- index clean;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one Feature 34 worktree.

Verify Response 72 implementation commit is an ancestor:

`5435e803b55ba0362a5c8f1e08cfac2bbc43ea72`

Read:

- Response 73;
- archive-admission architecture/docs;
- native archive-claim resolver;
- Dart `_admitArchive()` path;
- canonical-root policy implementation;
- development launch configuration;
- archive marker/identity validation;
- native tests;
- Dart archive-admission tests;
- canonical Project Conformance standard.

Create a fresh external baseline manifest.

---

# 2. Checkpoint Prompt 73 / Response 73 as a FAILED qualification record

Prompt 73/Response 73 are valuable evidence even though the qualification did
not reach AppCzar.

Create a narrow documentation checkpoint before source edits.

Record exactly:

```text
AppCzar Onboarding human qualification:
    FAIL — NOT REACHED

Failure boundary:
    development archive admission

Observed:
    launchd override = disposable safe fixture root
    native bootstrap produced development archive claim
    Dart admission rejected claim as noncanonical
    AppCzar did not run
    Onboarding did not run
    no build/cleanup occurred
    real development root and Toshiba archive were not used
```

Do not describe this as an Onboarding semantic failure.

Push the documentation checkpoint normally.

No force push, rebase, squash, or unrelated staging.

---

# 3. Reconstruct the exact two-sided root-resolution contract

Source-trace both sides completely.

## Native side

At minimum trace:

```text
MainFlutterWindow / bootstrap
-> MessageLensNativeArchiveClaimResolver
-> bundle identity/environment/build identity
-> MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT read
-> path normalization/canonicalization
-> root existence/directory checks
-> process lock
-> NativeArchiveClaim.root
```

Report:

- exact API reading the environment;
- raw value;
- whitespace/empty behavior;
- absolute-path requirement;
- path normalization behavior;
- symlink/realpath behavior;
- whether the root must already exist;
- whether the final path must be a directory;
- whether trailing slash / `.` / `..` are normalized;
- exact claimed root string;
- exact conditions under which development override is ignored/rejected.

## Dart side

At minimum trace:

```text
main.dart::_admitArchive()
-> environment/build identity
-> MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT read
-> expected development root resolution
-> ExactCanonicalArchiveRootPolicy
-> ArchiveAdmissionService
-> NativeArchiveClaim validation
```

Report the same details.

Do not infer equivalence from intent. Compare exact implementation semantics.

---

# 4. Reproduce the Response 73 divergence without the GUI

Before editing, create the smallest deterministic test/harness that uses a
temporary existing directory shaped like:

```text
/private/tmp/.../safe-empty
```

or the platform's canonical temporary equivalent.

The reproduction must identify:

```text
raw override string
native canonical result
Dart canonical result
NativeArchiveClaim.root
ExactCanonicalArchiveRootPolicy.expectedRoot
comparison result
```

Prefer existing injectable seams/tests.

If direct cross-language execution is impractical, reproduce each side from the
same path vector and compare the emitted canonical strings.

Do not use the real WD root as the only passing control.

Also include the historically qualified WD development root as a **string/test
vector only** if useful; do not inspect or mutate it.

---

# 5. Determine the exact cause

Classify the failure into one exact category, or report a more precise one:

```text
A. native and Dart canonicalize the same raw override differently

B. one side does not actually consume the launchd override

C. one side substitutes a configured/default development root

D. one side canonicalizes before path existence while the other does so after

E. symlink/realpath semantics differ
   (/tmp vs /private/tmp is an example, not an assumed diagnosis)

F. trailing separator/dot/Unicode/path normalization differs

G. environment/build identity chooses a different root policy on one side

H. another exact source-grounded cause
```

Report the two actual compared strings if source/test reproduction can establish
them.

Do not change code until the cause is proven.

---

# 6. Preserve the root-security invariant

The corrected contract must remain:

> A development override defines one exact canonical primary root for that
> process. Native and Dart resolve it independently and must agree exactly.

Development behavior:

```text
override absent
    -> existing normal development default root policy

override present and valid
    -> canonicalize exact supplied absolute directory
    -> native claim must equal independently derived Dart expected root

override invalid/inconclusive
    -> fail closed
```

Production behavior:

```text
development override present
    -> rejected exactly as today
```

Do not weaken marker identity, environment identity, bundle identity, process
locking, or archive-instance validation.

---

# 7. Prefer one documented canonicalization specification

Native and Dart implementations may necessarily be separate, but their semantics
must implement one explicit specification.

Define from current intended behavior, source-grounded:

- absolute path handling;
- path existence requirement;
- directory requirement;
- lexical normalization;
- symlink resolution or rejection;
- trailing separators;
- `.` and `..`;
- Unicode/filesystem normalization if applicable;
- case behavior on the active filesystem;
- error behavior when canonicalization cannot be established.

Do not invent cross-platform behavior that MessageLens does not need.

Add shared test vectors where practical so future edits cannot silently make the
two sides diverge again.

---

# 8. Correct the smallest responsible layer

Fix the root cause, not the Prompt 73 fixture.

Acceptable examples:

- make Dart resolve the override with the same canonical filesystem semantics as
  native;
- make native preserve the same canonical form Dart independently expects;
- correct an incorrect fallback to the configured WD default;
- correct launch-environment ingestion;
- centralize a lower path-normalization helper without collapsing independent
  authority.

Unacceptable:

```text
if development -> accept claim.root

if path startsWith('/private/tmp') -> accept

if marker says development -> accept

skip ExactCanonicalArchiveRootPolicy for tests/qualification
```

The exact same development app binary should be able to admit any valid
development override root satisfying the documented contract, not just one
hard-coded archive.

---

# 9. Add useful failure evidence

Response 73's UI exposed only:

```text
Archive root is not canonical for development.
```

That was safe but insufficient to diagnose which side differed.

Add the narrowest diagnostic evidence needed so a future
`nonCanonicalRoot` failure can establish:

```text
native claimed canonical root
Dart independently expected canonical root
environment/build identity
whether a development override was present
```

Prefer structured diagnostic/log evidence.

For development builds, user-visible technical detail may include both paths if
that matches existing error presentation.

For production, do not broaden sensitive path disclosure unnecessarily.

Do not turn diagnostics into authority.

---

# 10. Typed development-override provenance audit

Earlier architecture explicitly noted that `ArchiveAccessAuthority` did not
retain a typed `development override applied` fact.

Reassess whether this correction actually requires such provenance.

Preferred answer:

```text
NO
```

if independent exact-root derivation is enough.

If a typed provenance bit is required to remove ambiguity:

- derive it independently from the environment/config input, not from path shape;
- use it only for validation/diagnostics;
- do not let it bypass exact-root comparison;
- do not persist it as semantic application state.

Report the decision.

---

# 11. Native/Dart parity test matrix

At minimum cover temporary existing directories for:

1. plain canonical absolute path;
2. trailing slash;
3. `.` segment;
4. `..` segment that resolves within the intended path;
5. `/tmp/...` versus `/private/tmp/...` on macOS if both forms are meaningful;
6. path containing spaces;
7. non-existent path;
8. existing regular file instead of directory;
9. symlink path if current contract permits or rejects it;
10. empty override;
11. relative override;
12. override absent;
13. development bundle/environment;
14. production bundle/environment with override present.

For every case prove native and Dart either:

```text
accept to the same exact canonical string
```

or:

```text
both fail under the intended contract
```

where the architecture requires parity.

Do not weaken production rejection.

---

# 12. Archive-admission regression tests

Prove:

1. valid arbitrary disposable development root is admitted;
2. current-format marker at that root is validated normally;
3. bootstrap-empty root follows existing virgin marker-creation semantics where
   applicable;
4. mismatched claim root fails `nonCanonicalRoot`;
5. mismatched environment fails;
6. mismatched bundle/product identity fails;
7. marker UUID/environment mismatch fails;
8. process lock remains exact-root scoped;
9. default development root path still works;
10. production override remains rejected;
11. no test-only environment is admitted as development accidentally.

---

# 13. Protect already-qualified AppCzar behavior

Run regressions for:

- Data Update;
- Source Access Repair;
- Attachment Archive Repair;
- Onboarding automated suite;
- Operating Session / Stage Two;
- AppCzar development host census;
- archive authority / primary-root consumers.

The correction must not change AppCzar jurisdiction semantics.

This task fixes the boundary **before** AppCzar.

---

# 14. Project Conformance

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

Explicitly audit:

- development override remains development-only;
- native/Dart agreement remains independent;
- one immutable admitted `ArchiveAccessAuthority`;
- no root-policy bypass;
- no special-case qualification path;
- no production relaxation;
- no new semantic state;
- diagnostics are not authority;
- current AppCzar jurisdictions unchanged.

---

# 15. Validation

Run:

1. focused native canonical-root tests;
2. focused Dart canonical-root tests;
3. parity/vector tests;
4. archive-admission tests;
5. virgin/bootstrap-empty admission regressions;
6. primary-root authority regressions;
7. AppCzar Onboarding regressions;
8. existing qualified coordinator regressions;
9. architecture suite;
10. analyzer;
11. full deterministic Flutter suite;
12. native macOS tests;
13. `git diff --check`;
14. formatting/generated consistency;
15. debug macOS development build.

Do not launch the built application.

---

# 16. Checkpoint after validation

If all gates pass:

1. create a narrow implementation commit;
2. create/update Prompt 74 / Response 74 documentation checkpoint;
3. push normally.

Recommended implementation subject:

`fix(archive): unify development override canonical root`

Record:

```text
Prompt 73 Onboarding qualification:
    FAILED BEFORE APPCZAR — preserved as evidence

development override canonical-root contract:
    corrected and validated

Onboarding human qualification:
    PENDING RERUN
```

No force push, rebase, squash, or unrelated staging.

---

# 17. Build identity

Advance version/build sequentially if required by project convention.

Build but do not launch.

Report:

- bundle path;
- product;
- bundle identifier;
- environment/build identity;
- version/build;
- executable SHA-256;
- App.framework SHA-256.

---

# 18. Next human step

If Prompt 74 passes, the next task is a **rerun of Prompt 73** against the new
exact artifact.

Do not redesign the Onboarding experiment.

Reuse the same two conceptual disposable fixtures:

```text
SAFE EMPTY
-> must reach AppCzar
-> must select Onboarding
-> initial build
-> restart
-> fresh AppCzar

CONSEQUENTIAL PARTIAL
-> must reach AppCzar
-> must NOT select Onboarding
-> no cleanup/build
```

Create fresh disposable roots unless there is a compelling reason to preserve
the previous ones.

Do not use the real WD development root for that qualification.

---

# 19. Stop gates

STOP AND REPORT if:

- the two actual compared canonical roots cannot be established;
- fixing the issue requires trusting the native claim without independent Dart
  agreement;
- arbitrary development override roots are intentionally forbidden by a stronger
  current architecture requirement not reflected in prior docs;
- production would have to accept a development override;
- the correction requires weakening marker/identity/process-lock safety;
- AppCzar semantics must change;
- Project Conformance cannot reach PASS.

---

# 20. Required response

Create Response 74 and report:

1. baseline verification;
2. Prompt 73/Response 73 failed-qualification checkpoint;
3. exact native root-resolution call chain;
4. exact Dart root-resolution call chain;
5. raw override semantics on each side;
6. pre-fix deterministic reproduction;
7. native canonical result;
8. Dart canonical result;
9. exact compared strings;
10. proven root cause category;
11. canonicalization specification;
12. implementation correction;
13. proof independent agreement remains;
14. proof no arbitrary-claim bypass exists;
15. diagnostic-evidence improvement;
16. typed override-provenance decision;
17. plain temp-root parity result;
18. trailing slash/dot/dot-dot parity results;
19. `/tmp` vs `/private/tmp` result if applicable;
20. spaces/path normalization result;
21. non-existent/file-path/symlink results;
22. empty/relative/absent override results;
23. production override rejection result;
24. archive-admission regression result;
25. virgin/bootstrap-empty regression result;
26. marker/identity/process-lock regressions;
27. AppCzar Onboarding regressions;
28. existing qualified coordinator regressions;
29. architecture result;
30. analyzer result;
31. full Flutter-suite result;
32. native test result;
33. diff/format/generated hygiene;
34. Project Conformance verdict;
35. BLOCKER findings;
36. SHOULD FIX findings;
37. implementation checkpoint commit;
38. documentation checkpoint commit;
39. pushed recovery anchor;
40. exact build identity/path/hashes;
41. final Git/worktree/index/submodule state;
42. readiness to rerun isolated Onboarding human qualification.

Conclude exactly:

`PROMPT 73 FAILURE WAS PRE-APPCZAR ARCHIVE ADMISSION: YES / NO`

`NATIVE AND DART NOW DERIVE THE SAME DEVELOPMENT OVERRIDE ROOT: YES / NO`

`INDEPENDENT EXACT-ROOT AGREEMENT IS STILL ENFORCED: YES / NO`

`PRODUCTION DEVELOPMENT-OVERRIDE REJECTION IS UNCHANGED: YES / NO`

`VALID DISPOSABLE DEVELOPMENT ROOTS CAN BE ADMITTED: YES / NO`

`APPCZAR ONBOARDING SEMANTICS CHANGED: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY TO RERUN ISOLATED ONBOARDING HUMAN QUALIFICATION: YES / NO`

Then STOP.
