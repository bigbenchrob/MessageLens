# MessageLens Feature 35
## 09 — Final Targeted Human Review of AST Enforcement

Prompt 08 replaced the final two regex-based architecture claims with AST-backed
enforcement.

The runtime authority implementation was not changed.

This task is deliberately **narrow**. It is not another full Feature 35
architectural review.

The runtime architecture has already been repeatedly reviewed and found sound.
This review answers only:

> Did Prompt 08 make the two remaining architecture-policy guarantees genuinely
> exhaustive without weakening or overfitting the existing Feature 35 boundary?

If YES, Feature 35 proceeds directly to final full validation and checkpoint.

Do NOT modify production code.
Do NOT modify tests.
Do NOT regenerate code.
Do NOT stage or commit.
Do NOT merge, rebase, cherry-pick, or push.
Do NOT touch the frozen Onboarding worktree.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read:

- `responses/07-FINAL-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`
- `responses/08-REPLACE-REGEX-BOUNDARIES-WITH-AST-ENFORCEMENT.md`
- the current `test/architecture/exclusive_authority_architecture_test.dart`
- the unchanged current Feature 35 production diff only as needed to confirm
  Prompt 08 did not alter runtime behavior.

---

# 1. Baseline

Verify:

- worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`
- branch:
  `feature/exclusive-authority-tenure`
- HEAD:
  `fe14793bbee8622b08829c4973a1e6ae218e8bb2`
- upstream:
  `origin/main`
- ahead/behind:
  `0/0`
- index:
  empty

Confirm Prompt 08 changed only:

- `test/architecture/exclusive_authority_architecture_test.dart`;
- the Prompt 08 response record.

No runtime production source should have changed in Prompt 08.

Reconfirm the frozen Onboarding preservation hashes and Git state remain
unchanged.

If not, STOP AND REPORT.

---

# 2. Review AST parser use itself

Confirm the architecture test uses the repository's existing `analyzer`
dependency and parses the same real source text that the repository audit sees.

Verify:

- parse errors fail closed;
- comments and strings cannot masquerade as declarations or constructor use;
- AST inspection is used only for the two boundaries Prompt 08 intended to fix;
- unrelated Prompt 06 enforcement remains intact.

No new runtime dependency or production parser code should exist.

---

# 3. Verify the authority-key constructor census is exhaustive

Inspect the AST implementation.

Confirm it proves all of these mechanically:

1. exactly one `ExclusiveAuthorityKey` class exists;
2. it remains `final`;
3. exactly one constructor declaration exists;
4. that constructor is the approved private const generative constructor;
5. no second named constructor exists;
6. no public constructor exists;
7. no factory constructor exists;
8. no redirecting constructor exists;
9. no alternate construction path exists;
10. production construction sites are exactly:
    - canonical `archiveMutation`;
    - the designated independent test key in the friend part;
11. constructor tear-offs cannot create an uncounted path.

Do not rely on the report alone. Inspect the AST visitors and data actually
compared.

---

# 4. Verify constructor mutation tests exercise the real policy

Inspect the virtual/mutation cases.

Confirm the same `_ExclusiveAuthorityProductionPolicy` used against the real
repository rejects:

- second private named constructor;
- public unnamed constructor;
- public named constructor;
- factory constructor;
- redirecting constructor;
- alternate construction site;
- constructor tear-off.

Also confirm the approved current source passes through that same policy.

There must not be a separate simplified fixture checker.

---

# 5. Verify friend declaration census is exhaustive

Inspect the AST top-level declaration census.

Confirm it enumerates every top-level declaration that can widen the friend
surface, including:

- classes;
- enums;
- mixins;
- extension types;
- named extensions;
- typedefs;
- functions;
- getters;
- setters;
- top-level variables regardless of `const`, `final`, `var`, explicit type, or
  `late`;
- unknown/future declaration kinds fail closed rather than disappearing.

Confirm declaration **count and identity** are checked, not just a set that could
hide duplicates.

---

# 6. Verify the exact friend surfaces remain narrow

The only approved top-level declarations should be:

## Key friend

- `class ExclusiveAuthorityKeyTestSupport`

## Registry friend

- `class ExclusiveAuthorityRegistryTestSupport`
- `class ExclusiveAuthorityScopeCleanupTestHandle`

Confirm:

- no other friend declaration is accepted;
- the two friend files are still the only privileged files;
- those friend symbols remain hidden from the public production seam;
- production-use scanning outside the exact friend files remains intact.

---

# 7. Verify the Prompt 07 escape is now mechanically impossible

Inspect the mutation for a typed mutable alias such as:

```dart
ExclusiveAuthorityKey independentAlias =
    ExclusiveAuthorityKeyTestSupport.independent;
```

Confirm:

1. the friend declaration itself is rejected;
2. rejection does not depend on a downstream production file spelling
   `ExclusiveAuthorityKeyTestSupport`;
3. a production consumer using only `independentAlias` cannot evade the rule.

Also inspect the mutations for:

- typed `final`;
- `late` typed variable;
- getter alias;
- function returning the test key;
- typedef;
- named extension.

---

# 8. Check for AST false negatives and false positives

Perform a targeted adversarial review of the new AST logic.

Ask:

- Is there any ordinary Dart constructor/declaration syntax still unclassified?
- Can import prefixes or tear-offs evade the constructor-use census?
- Can part/library structure hide a declaration from the friend census?
- Can duplicate declarations collapse into one accepted result?
- Does the test accidentally reject harmless private/local declarations that do
  not widen authority?
- Does formatting or a private variable rename break the rule unnecessarily?

The objective is semantic enforcement, not source-layout freezing.

Report a concrete issue only if you can describe an actual Dart shape that
evades or incorrectly triggers the policy.

---

# 9. Confirm Prompt 06 enforcement was not weakened

Spot-check that the unchanged architecture policy still enforces:

- sole production adopter;
- provider refresh/invalidation prohibition;
- provider alias/wrapper escape;
- diagnostics-not-proof;
- approved proof APIs only;
- no public release;
- no ambient current-tenure lookup;
- no serialization;
- presentation/workflow separation;
- native-lock separation.

This is a regression check, not another broad design review.

---

# 10. Runtime sanity only

Confirm from Git diff that Prompt 08 made **no runtime production change**.

Do not re-review the whole Ball/Track implementation unless the diff disproves
that premise.

The previously established runtime conclusions remain accepted:

- one live tenure per key;
- exact identity proof;
- exact-scope release;
- stale cleanup safety;
- archive capability grounding;
- domain policy remains in `ArchiveMutationCoordinator`.

---

# 11. Validation scope

Prompt 08 already reports:

- Feature 35 architecture: 36 passed;
- complete architecture: 523 passed;
- generic authority: 23 passed;
- archive coordinator: 17 passed;
- analyzer: clean;
- `git diff --check`: clean;
- Project Conformance: PASS;
- BLOCKER: 0;
- SHOULD FIX: 0.

Do not rerun the full repository test suite.

Rerun only the Feature 35 architecture test if source inspection raises a
specific ambiguity.

---

# 12. Required response

Create:

`35-EXCLUSIVE-AUTHORITY-TENURE/responses/09-FINAL-TARGETED-HUMAN-REVIEW-AST-ENFORCEMENT.md`

Report:

1. baseline/isolation;
2. AST parser mechanism verdict;
3. constructor-declaration census verdict;
4. constructor-use census verdict;
5. constructor mutation-test verdict;
6. friend declaration census verdict;
7. exact friend-surface verdict;
8. typed-alias escape verdict;
9. other friend mutation verdict;
10. AST false-negative/false-positive verdict;
11. Prompt 06 regression-check verdict;
12. runtime-diff sanity;
13. concrete BLOCKER findings;
14. concrete SHOULD FIX findings;
15. OPTIONAL findings;
16. narrow tests rerun, if any;
17. exact Feature 35 Git status;
18. frozen Onboarding verification;
19. final recommendation.

Use:

- BLOCKER
- SHOULD FIX
- OPTIONAL
- NO ISSUE

Do not modify implementation.

Conclude exactly:

`FINAL TARGETED FEATURE 35 HUMAN REVIEW: PASS / FAIL`

If PASS, also conclude:

`SAFE TO RUN FEATURE 35 FINAL FULL VALIDATION AND CHECKPOINT: YES / NO`

Then STOP.
