# Feature 33 — Environment Summary
## Checkpoint Phase Two, then implement Phase Three: Copy Environment Summary

We are continuing Feature 33 on:

- Branch: `feature/environment-summary`
- Phase One commit: `602893f815d8035827c1c371c5c94b5b5365639d`
- Current HEAD: `602893f815d8035827c1c371c5c94b5b5365639d`
- Phase Two is complete, validated, entirely unstaged, and has not been pushed.
- Phase Three has not begun.
- Shared instructions submodule is clean at `95326f515ef4719f155ce6e223990398daad6311`.

The Phase Two implementation/report is authoritative context. Preserve its architecture, ownership boundaries, typed-state semantics, privacy exclusions, and validation guarantees.

Proceed in the following order.

---

# PART A — REVIEW AND CHECKPOINT PHASE TWO

## 1. Review the existing unstaged Phase Two work

Before staging anything:

- inspect the complete Phase Two diff;
- confirm that every intended tracked and untracked Phase Two file belongs to Feature 33 Phase Two;
- confirm that unrelated untracked files remain untouched;
- confirm the shared-instructions submodule remains clean and unchanged;
- confirm no Phase Three clipboard implementation has already leaked into the Phase Two diff.

Phase Two should still implement only the stable read-only:

`Settings → Support → Environment`

center-panel destination over the Phase One aggregate read model.

Verify in particular that:

- Settings navigation reuses the existing Settings flow/coordinator/resolver architecture;
- Environment has no sidebar child;
- `EnvironmentSummaryPanel` consumes only `environmentSummaryProvider` for environment facts;
- presentation does not import or watch underlying filesystem, database, Message, Contacts, FTS, attachment-location, archive-authority, bookmark, lease, controller, or mutation providers;
- opening Environment does not initialize Feature 31 attachment resolution;
- loading/unknown/unavailable/not-retained/failed/authoritative-zero remain distinct;
- no retained-source, Contacts-provenance, WD/Toshiba-access, startup, database/archive mutation, Clipboard, or Finder behavior was introduced.

Do not “clean up” or broaden Phase Two during this review unless you find an actual defect that prevents checkpointing. If you find such a defect, STOP and report it before changing scope.

## 2. Re-run qualification appropriate to checkpointing

At minimum, re-run the relevant focused Phase Two tests and cheap static checks necessary to ensure the unstaged work still matches the reported green state.

The completed Phase Two report recorded:

- focused Environment/navigation/sidebar/passive Feature 31 tests: 105 passed
- architecture suite: 484 passed
- full repository suite: 2,612 passed, 1 qualification test skipped
- final panel suite: 18 passed
- `flutter analyze --no-pub`: no issues
- `git diff --check`: clean
- native tests not run because there were no native changes

Do not gratuitously rerun expensive suites if repository instructions and unchanged state make that unnecessary, but do not checkpoint work whose current state has become uncertain.

## 3. Stage only Phase Two

Stage exactly the intended Phase Two files.

Do NOT stage any unrelated untracked files, including the previously known unrelated settings/prompts/responses.

Inspect the staged diff and staged file list carefully before committing.

## 4. Commit Phase Two as its own historical checkpoint

Create one normal commit preserving Phase Two as a distinct checkpoint.

Use an appropriate commit subject in the existing repository style, for example:

`feat(environment): add settings environment summary`

Do not squash Phase One.

Do not amend Phase One.

Do not push.

After committing:

- verify the worktree/index state;
- report the new Phase Two commit hash;
- confirm unrelated untracked files remain untouched;
- confirm the shared-instructions submodule remains clean.

If the checkpoint cannot be made cleanly, STOP before Phase Three.

---

# PART B — IMPLEMENT PHASE THREE: COPY ENVIRONMENT SUMMARY

Only begin this part after Phase Two has been successfully committed.

## 5. Save this prompt with the next sequential Feature 33 prompt number

Preserve the established sequential prompt naming convention.

The next Feature 33 prompt should be saved as:

`04-PHASE-THREE-COPY-ENVIRONMENT-SUMMARY.md`

in the Feature 33 prompts location used by the existing architecture-audit / Phase One / Phase Two prompts.

Do not renumber existing prompt files.

---

# PHASE THREE GOAL

Add one explicit **Copy Environment Summary** action to the Environment Settings page.

Phase Three must wire the existing pure `EnvironmentSummaryFormatter` to the UI while preserving the same aggregate read boundary and privacy exclusions established in Phases One and Two.

This phase is deliberately narrow.

It is NOT a general export system.

It is NOT a filesystem-navigation feature.

It is NOT a path-by-path clipboard toolkit.

It is NOT a Finder integration phase.

The Phase Two handoff explicitly permits one Copy Environment Summary action and keeps per-path copy actions and Reveal in Finder out of scope.

---

# 6. Architecture audit before implementation

Before editing implementation code, inspect:

- the existing pure `EnvironmentSummaryFormatter`;
- the Feature 33 public seam;
- `EnvironmentSummaryPanel`;
- established repository patterns for explicit copy-to-clipboard actions;
- any existing reusable button/action presentation used in Settings or report-style center panels;
- clipboard ownership boundaries and test patterns.

Prefer reuse over introducing parallel abstractions.

Document the intended dependency direction before implementation.

The desired architecture should remain conceptually:

`EnvironmentSummaryPanel`
→ explicit user action
→ existing pure Environment summary formatter
→ narrow clipboard adapter/action boundary

Environment facts must still come only from the aggregate Feature 33 read model.

Do not let clipboard integration become a route for the presentation layer to query lower-level evidence providers directly.

---

# 7. Copy action semantics

Add one clearly named action:

**Copy Environment Summary**

The action must be explicit and user initiated.

It should copy a support-oriented textual summary generated from the existing aggregate model through the existing formatter.

Requirements:

- no clipboard write merely from opening the page;
- no hidden automatic copy;
- no per-field or per-path copy actions in this phase;
- no Reveal in Finder;
- no mutation of environment/database/archive state;
- no attachment-location initialization;
- no new filesystem probing;
- no new SQL/database access;
- no reconstruction of unavailable provenance;
- no inclusion of privacy-excluded fields merely because they exist elsewhere in the app.

The clipboard text must honor the formatter/read-model semantics for:

- Loading
- Unknown
- Unavailable
- Not retained
- Failed
- authoritative zero

Do not convert those states into fabricated values.

---

# 8. Privacy and support boundary

Preserve the existing Feature 33 exclusions.

The copied summary must not expose information that Phase One/Two intentionally exclude from the aggregate support surface, including unsupported or privacy-sensitive implementation detail such as:

- bookmark bytes;
- WAL/SHM files;
- retired databases;
- device nodes;
- logs;
- user message/contact content;
- retained WD paths;
- invented Contacts source paths;
- hidden archive-authority internals not represented by the aggregate;
- anything obtained through fresh filesystem/database discovery.

If the existing formatter already defines the correct safe textual contract, reuse it rather than duplicating formatting logic in the panel.

---

# 9. Clipboard ownership

Use the narrowest existing application/UI clipboard mechanism.

Do not add clipboard knowledge to the domain/read-model layer.

Do not make `EnvironmentSummary` itself perform side effects.

Keep formatting pure and clipboard invocation imperative at the presentation/application boundary.

If no suitable existing clipboard seam exists, introduce the smallest testable abstraction consistent with repository architecture. Do not create a generalized clipboard subsystem unless one already exists or repository conventions require it.

---

# 10. UX

The action should fit naturally into the Environment page without disturbing the established information hierarchy:

1. This installation
2. Data folder
3. Attachment archive
4. Message data
5. Contacts data
6. Technical Details

Do not replace the stable report page with an export workflow.

Use established semantic controls and accessibility patterns.

The action should have:

- an accessible textual label;
- a clear enabled/disabled policy;
- bounded feedback appropriate to an explicit copy action.

Do not add noisy persistent status UI if the repository already has a lighter established confirmation pattern.

If formatter input is partially settled, preserve the aggregate model's semantics rather than inventing values. Determine from existing formatter/contracts whether copying a partially settled summary is valid; follow the architecture rather than guessing.

---

# 11. Tests

Add focused coverage for at least:

- Copy Environment Summary action is present in the intended Environment UI;
- invoking it uses the existing pure formatter output;
- clipboard write happens only after explicit activation;
- opening/rendering Environment does not write to clipboard;
- the copied text preserves typed status distinctions;
- privacy-excluded/internal evidence is absent;
- no per-path copy controls are introduced;
- no Reveal in Finder control is introduced;
- Environment presentation still consumes only the aggregate provider for environment facts;
- no Feature 31 attachment-resolution initialization is introduced;
- existing Settings navigation/sidebar behavior remains unchanged;
- accessibility semantics for the action are appropriate.

Add/extend architecture tripwires if needed to preserve the aggregate-only boundary and prevent clipboard concerns leaking into domain/infrastructure layers.

---

# 12. Documentation and release metadata

Follow repository conventions for user-facing work.

Determine whether this Phase Three user-facing action requires the next version/build bump and changelog entry under current repository rules. If so, make the smallest truthful update.

Create the Phase Three implementation report/documentation using the next appropriate sequential Feature 33 documentation filename, preserving the established naming convention.

Update only documentation that is actually made stale by Phase Three.

Do not broaden documentation into future Finder/per-path-copy work.

---

# 13. Validation

Run appropriate validation for the completed Phase Three implementation, including:

- focused Feature 33 formatter/panel/clipboard tests;
- relevant Settings/navigation tests;
- architecture tests;
- `flutter analyze --no-pub`;
- `git diff --check`;
- full repository suite if repository qualification rules require it for this scope.

Run native tests only if Phase Three actually changes native code.

Do not access real production databases, archives, WD/Toshiba sources, or user content merely to validate clipboard formatting.

Use fixtures/fakes established by the feature architecture.

---

# 14. STOP GATE

At the end of Phase Three:

- leave all Phase Three implementation changes entirely UNSTAGED;
- do not commit Phase Three;
- do not push;
- do not begin any Phase Four / Finder / per-path-copy work.

Report:

1. Phase Two commit hash and subject;
2. branch and current HEAD;
3. complete Phase Three changed/new file list;
4. implementation summary;
5. exact clipboard/formatter ownership path;
6. UX behavior and feedback;
7. privacy/boundary confirmations;
8. release/version/changelog changes, if any;
9. tests and validation results;
10. architecture-tripwire results;
11. complete Git status;
12. shared-instructions submodule status;
13. confirmation that Phase Three remains entirely unstaged;
14. confirmation that nothing was pushed;
15. confirmation that no Finder/per-path-copy/future-phase work was begun.

Then STOP.
