# MessageLens Feature 34
## Response 74 — Diagnose and Correct the Development-Override Canonical-Root Admission Contract

Date: 2026-10-06

### 1. Baseline verification

The primary worktree began on `fix/onboarding-import-stuck-state` at
`ed84400ef3440b5485e77313cad01fa5bc1bb618`, synchronized `0/0` with its
upstream. The tracked worktree and index were clean, only the known unrelated
untracked material plus Prompt/Response 73 and Prompt 74 were present, and the
shared-instructions submodule was clean at
`95326f515ef4719f155ce6e223990398daad6311`. Exactly one Feature 34 worktree was
present. Response 72 implementation commit
`5435e803b55ba0362a5c8f1e08cfac2bbc43ea72` was an ancestor. A fresh external
baseline manifest was written at
`/private/tmp/messagelens-prompt74-baseline-20261006.md`.

### 2. Prompt 73/Response 73 failed-qualification checkpoint

Prompt 73 and Response 73 alone were committed as
`3d06155f` (`docs(onboarding): record failed isolated qualification`) and pushed
normally before source editing. The record states:

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

This is not classified as an Onboarding semantic failure.

### 3. Exact native root-resolution call chain

`MainFlutterWindow.awakeFromNib()` constructs
`MessageLensNativeArchiveClaimResolver`, which reads bundle environment, build
identity, bundle identifier, product name, and production-signature evidence.
The resolver reads `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` from its injected
`processEnvironment`, whose runtime default is
`ProcessInfo.processInfo.environment`. It resolves the canonical root, emits it
in `MessageLensNativeArchiveClaim.channelPayload`, and only then constructs the
exact-root `MessageLens.instance.lock`. A primary lock holder publishes the
claim through the archive-identity method channel. Lock scope therefore remains
the native claimed canonical root.

### 4. Exact Dart root-resolution call chain

`main.dart::_admitArchive()` reads the native claim through
`MethodChannelNativeArchiveClaimReader`, gets the normal Application Support
default through `getApplicationSupportDirectory()`, and independently calls
`DevelopmentArchiveRootOverrideResolver.resolveExpectedRoot()`. That resolver
reads `Platform.environment`, resolves the expected root, and supplies it to
`ExactCanonicalArchiveRootPolicy`. `ArchiveIdentityValidator.validateClaim()`
then requires exact normalized equality before `ArchiveAdmissionService`
performs ordinary marker and archive-instance admission.

### 5. Raw override semantics on each side

Both sides trim surrounding whitespace, treat absent or empty input as the
normal development default except that the FDA experiment requires an explicit
override, require an absolute path, require an existing directory, and reject a
production use of the override. Native additionally performs its existing
writability check before creating the claim. Dart uses
`Directory.resolveSymbolicLinksSync()` and fails closed on an unresolved path.
Native now performs POSIX `realpath` after the existing lexical, existence,
directory, and writability checks. Missing paths and regular files are rejected;
they are never lexically normalized into admission.

### 6. Pre-fix deterministic reproduction

The same existing disposable path was evaluated without launching the GUI:

```text
raw override:
/private/tmp/messagelens-appczar-onboarding-qualification-NbWi58/safe-empty

native Foundation result before correction:
/tmp/messagelens-appczar-onboarding-qualification-NbWi58/safe-empty

Dart resolveSymbolicLinksSync result:
/private/tmp/messagelens-appczar-onboarding-qualification-NbWi58/safe-empty
```

The external probe was
`/private/tmp/messagelens_prompt74_dart_root_probe.dart`. POSIX `realpath` also
proved that `/tmp` resolves to `/private/tmp`. No real archive was used.

### 7. Native canonical result

Before correction, Foundation's
`standardizedFileURL.resolvingSymlinksInPath().standardizedFileURL` produced the
claim spelling beneath `/tmp`. After correction, native POSIX `realpath`
produces and preserves the filesystem spelling beneath `/private/tmp`.

### 8. Dart canonical result

Dart's existing `Directory.resolveSymbolicLinksSync()` produced
`/private/tmp/messagelens-appczar-onboarding-qualification-NbWi58/safe-empty`
before and after the correction. No Dart root authority was weakened or taught
to trust the native claim.

### 9. Exact compared strings

The pre-fix `NativeArchiveClaim.root` was:

`/tmp/messagelens-appczar-onboarding-qualification-NbWi58/safe-empty`

The pre-fix `ExactCanonicalArchiveRootPolicy.expectedRoot` was:

`/private/tmp/messagelens-appczar-onboarding-qualification-NbWi58/safe-empty`

Exact comparison was false. With the correction, both independently resolve to
the second string and exact comparison is true.

### 10. Proven root-cause category

**Category E: symlink/realpath semantics differed.** More precisely, Foundation
URL standardization rewrote the filesystem-real `/private/tmp` spelling to the
lexical alias `/tmp`, while Dart retained the POSIX filesystem-real spelling.
Both sides consumed the same override and selected the same development policy;
neither substituted the WD root.

### 11. Canonicalization specification

For a configured macOS development override:

- trim the input and require a non-empty absolute path;
- require the target to exist and be a directory;
- retain native's existing writability requirement;
- resolve trailing separators and `.` / `..` through filesystem reality;
- permit a directory symlink and resolve it to its physical target;
- use POSIX filesystem `realpath`, including `/tmp` to `/private/tmp`;
- preserve filesystem-returned case and Unicode spelling without separate case
  folding or Unicode rewriting;
- fail closed for missing paths, files, relative paths, or unresolved identity;
- derive the result independently in native and Dart and require exact equality.

The normal absent-override development default is unchanged.

### 12. Implementation correction

`MessageLensNativeArchiveClaimResolver` now replaces its final Foundation URL
symlink-standardization step with `Darwin.realpath`, after all existing guards.
The returned URL preserves the POSIX result. No AppCzar, marker, database,
archive-location, or onboarding semantics changed. Release metadata advanced to
`0.2.140+158`, and the canonical environment/data-location documentation and
changelog were updated.

### 13. Proof independent agreement remains

Native still creates its claim before Flutter/Dart admission. Dart still reads
the process environment independently, creates its own expected root, constructs
`ExactCanonicalArchiveRootPolicy`, and calls
`ArchiveIdentityValidator.validateClaim()`. The implementation did not pass the
native result into the Dart override resolver and did not reuse one side's
result as the other's expected value.

### 14. Proof no arbitrary-claim bypass exists

`validator.validateClaim(claim)` remains unconditional and still follows the
new diagnostic-only comparison. A mismatched claim continues to throw
`ArchiveAdmissionFailure.nonCanonicalRoot`. Tests retain the mismatched-root,
environment, bundle/product, marker, and production rejection cases. There is
no development-wide acceptance, `/private/tmp` exception, marker-based bypass,
or qualification-only branch.

### 15. Diagnostic-evidence improvement

Immediately before the unchanged validator fails a development mismatch,
`_admitArchive()` emits one structured diagnostic containing:

- native claimed canonical root;
- Dart independently expected canonical root;
- environment;
- build identity;
- whether a non-empty development override is present.

Paths are JSON encoded, the diagnostic is development-only, and it grants no
authority. Production path disclosure was not broadened.

### 16. Typed override-provenance decision

**NO typed provenance bit is required.** The process environment is already an
independent input on both sides, and exact independently derived root agreement
removes the ambiguity. Adding durable or semantic `override applied` state would
not strengthen admission and could create a second policy fact.

### 17. Plain temp-root parity result

PASS. Separate native and Dart tests accepted a plain existing disposable
absolute directory and produced the identical POSIX realpath. The integrated
Dart admission regression also admitted an arbitrary disposable root through
the normal policy/marker service.

### 18. Trailing slash/dot/dot-dot parity results

PASS. A trailing slash, a `.` segment, and an in-scope `..` segment all
converged to the same exact existing directory in both native and Dart tests.

### 19. `/tmp` versus `/private/tmp` result

PASS. Both spellings converged to the identical `/private/tmp/...` result on
macOS. This directly covers the Prompt 73 failure vector without hard-coding an
admission exception.

### 20. Spaces/path-normalization result

PASS. Matrix roots intentionally contained spaces. Lexically equivalent
absolute inputs converged through filesystem resolution, and exact strings
agreed.

### 21. Non-existent/file-path/symlink results

PASS. Non-existent paths and existing regular files fail closed. Existing
directory symlinks are permitted by the current contract and both sides resolve
them to the same physical target.

### 22. Empty/relative/absent override results

PASS. Empty whitespace-only and absent overrides retain the existing normal
development default behavior; relative inputs are rejected. The FDA experiment
still rejects a missing explicit override.

### 23. Production override rejection result

PASS. Native and Dart retain their existing explicit rejection of a non-empty
development-root override under production. Production root and signature
admission were not relaxed.

### 24. Archive-admission regression result

PASS. The focused Dart group passed 33 tests. It includes arbitrary disposable
root admission, normal current-marker creation/admission, exact-root mismatch,
production behavior, and marker environment refusal. Existing archive
environment and authority tests also passed in the 252-test focused group and
the full suite.

### 25. Virgin/bootstrap-empty regression result

PASS. A bootstrap-empty disposable development root creates and validates the
normal current marker; a native lock file is permitted before initial marker
creation; non-empty unmarked roots remain refused. Virgin/bootstrap architecture
tests passed.

### 26. Marker/identity/process-lock regressions

PASS. Current-format marker admission, marker environment mismatch, exact
bundle/product/build environment, production signature, archive authority, and
exact-root process-lock tests passed. Native tests proved the lock still derives
from the claim's canonical root and that only one holder can own it.

### 27. AppCzar Onboarding regressions

PASS. AppCzar Onboarding controller/presentation and startup-composition tests
passed in the focused 252-test group; the broader Onboarding and Journey suite
passed inside the 3,061-test full run. Human qualification remains pending and
was not simulated as completed.

### 28. Existing qualified coordinator regressions

PASS. Data Update, Source Access Repair, Attachment Archive Repair, and
Operating Session/Stage Two tests all passed in the focused 252-test group and
the full suite. AppCzar jurisdiction code was not edited.

### 29. Architecture result

PASS: 601 architecture tests. The new tripwire proves that canonical-root
diagnostics remain development-only evidence, occur before the unchanged
validator, include both paths and override presence, and do not replace
validation.

### 30. Analyzer result

PASS. `flutter analyze` completed with `No issues found!`.

### 31. Full Flutter-suite result

PASS. The complete deterministic Flutter suite finished with 3,061 passing
tests and one intentional qualification skip (`~1`). There were no failures.

### 32. Native test result

PASS. The final signed, RunnerTests-only Xcode invocation passed all 20 native
tests, including the complete canonicalization matrix and existing identity and
lock tests. An initial unsigned-host attempt could not bootstrap the XCTest
host. The first signed all-scheme diagnostic run exposed three stale
Foundation-spelling expectations; those expectations were corrected to the
documented POSIX-realpath contract, after which the final native run passed.

### 33. Diff/format/generated hygiene

PASS. `git diff --check` and the cached diff check were clean. Dart formatter
verification reported zero changes after formatting. `build_runner` completed
successfully and left no generated-file diff beyond the ten intended tracked
files. No dependency file changed. Unrelated untracked files were not staged or
modified.

### 34. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

The complete implementation diff was reviewed against the canonical Project
Conformance standard. Reuse, native/platform ownership, dependency direction,
single authority, independent root witnesses, bounded work, privacy/logging,
mutation safety, error semantics, test coverage, generated consistency,
documentation agreement, and unchanged UI semantics were all explicitly
inspected. There are no unresolved findings.

### 35. BLOCKER findings

**0.** The development override remains development-only; exact independent
agreement, immutable admitted authority, marker/identity validation, production
rejection, and exact-root locking all remain intact.

### 36. SHOULD FIX findings

**0.** No duplicated policy, new semantic state, qualification-only path,
production relaxation, AppCzar jurisdiction change, or stale generated output
was introduced.

### 37. Implementation checkpoint commit

`182d96812dc6c96e14387d5af51c235d41d0de0b`

Subject: `fix(archive): unify development override canonical root`

The commit contains only the ten intended source, tests, canonical docs,
changelog, and version files.

### 38. Documentation checkpoint commit

Prompt 74 and this Response 74 form the narrow documentation checkpoint. Its
commit is intentionally reported in the post-commit handoff because a commit
cannot embed its own final hash without changing that hash.

### 39. Pushed recovery anchor

The pre-implementation failed-qualification recovery anchor is pushed at
`3d06155f`. After the Prompt/Response 74 checkpoint, the implementation and
documentation commits are to be pushed normally together; no force push,
rebase, or squash is used.

### 40. Exact build identity/path/hashes

The corrected artifact was built after implementation commit `182d9681` and was
not launched:

- bundle path:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`
- product/display/executable: `MessageLens Development`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- environment/build identity: `development` / `developmentDebug`
- version/build: `0.2.140 (158)`
- executable SHA-256:
  `fc884969590b34b358ad9c45c233012f1ca9bbf0a0203cbbad68119414b9f882`
- `App.framework/App` SHA-256:
  `46374aa98731246b1f4758b23dc6cba04848fed35c8066a09021e73035c2fa0c`

The build completed successfully. The corrected development app was not
launched. An already-running installed production MessageLens process was
observed and left untouched; this task neither launched nor interacted with it.

### 41. Final Git/worktree/index/submodule state

At implementation checkpoint, tracked worktree and index were clean and only
known unrelated untracked files plus Prompt 74 remained. The shared-instructions
submodule remained clean at
`95326f515ef4719f155ce6e223990398daad6311`. The final handoff reports the exact
post-documentation HEAD/upstream and confirms Prompt/Response 74 are the only
additional staged/committed scope. The prior disposable Prompt 73 fixtures and
their evidence remain retained and unmodified by the correction.

### 42. Readiness to rerun isolated Onboarding human qualification

**YES.** The pre-AppCzar contract contradiction is corrected and validated.
The next task is a fresh rerun of Prompt 73 with new isolated safe-empty and
consequential-partial roots against the exact artifact above. The real WD
development root must not be substituted, and no Onboarding outcome is claimed
until that human rerun occurs.

PROMPT 73 FAILURE WAS PRE-APPCZAR ARCHIVE ADMISSION: YES

NATIVE AND DART NOW DERIVE THE SAME DEVELOPMENT OVERRIDE ROOT: YES

INDEPENDENT EXACT-ROOT AGREEMENT IS STILL ENFORCED: YES

PRODUCTION DEVELOPMENT-OVERRIDE REJECTION IS UNCHANGED: YES

VALID DISPOSABLE DEVELOPMENT ROOTS CAN BE ADMITTED: YES

APPCZAR ONBOARDING SEMANTICS CHANGED: NO

PROJECT CONFORMANCE: PASS

READY TO RERUN ISOLATED ONBOARDING HUMAN QUALIFICATION: YES
