Absolutely. I’d make the close-out prompt explicit that Codex should **prepare for merge, but not merge automatically** unless that is already your project convention. That gives us one last chance to inspect the branch as a whole.



Please perform the **final close-out stage** for the completed MessageLens message-text search enhancement on:

`feature/message-text-search`

The search implementation is now functionally complete.

Completed work includes:

- structured exact/prefix query semantics;
- FTS5-backed message-text search;
- preservation of raw editor input and trailing whitespace;
- aligned highlighting;
- natural AND/OR semantics across message text and tags;
- corrected final 500-result composition;
- corrected Handle Messages / Handle Lens filtering;
- accessibility/tooltips for AND/OR;
- domain-neutral result wording.

The deferred Apple link-preview metadata audit is also complete and concluded that link-preview indexing should be implemented later on a **separate feature branch**, not in this branch.

Do not implement link-preview indexing here.

## 1. Confirm branch and worktree

Confirm:

- current branch is `feature/message-text-search`;
- current HEAD;
- `git status`;
- no unintended staged/unstaged files exist.

Preserve the explicitly unrelated untracked file:

- `.vscode/settings.json`

The search-enhancement instruction directory may contain deliberate project documentation/audit material. Inspect repository conventions before deciding whether any of that directory belongs in the final feature commit.

Do not blindly stage the entire directory.

## 2. Verify checkpoint history

Report the relevant feature commits already present, including at least:

- Stage 1–3 structured query + FTS checkpoint;
- Stage 4 raw-input/highlighting checkpoint;
- Stage 5 AND/OR checkpoint.

Confirm there are no accidental unrelated commits on this branch.

If the branch contains unexpected history relative to `main`, stop and report it before doing release metadata work.

## 3. Version bump

Inspect the current application version and project versioning conventions.

Apply the appropriate **smallest release-worthy version bump** consistent with the project’s existing policy.

Do not invent a new versioning scheme.

Report:

- old version;
- new version;
- why that increment is appropriate.

## 4. CHANGELOG

Add a concise but meaningful changelog entry describing the user-visible search improvements.

The entry should cover, in project-appropriate wording:

- incremental word-prefix search;
- trailing-space completion for exact whole-token search;
- one-character completed-token support;
- disappearance of the “press Space twice” bug;
- FTS5-backed message-text search;
- removal of hidden metadata-only text matches;
- AND/OR now meaning “match all terms” / “match any term” across message text and tags;
- corrected result filtering and final 500 selection;
- corrected Handle Messages / Handle Lens search filtering;
- search highlighting now follows exact/prefix semantics.

Do not mention implementation minutiae that belong only in developer documentation unless the project changelog normally does so.

Do not claim link-preview metadata search exists.

## 5. Search documentation / agent instructions

Review the existing search-related documentation and agent instructions.

Update only the documentation that should now describe the new authoritative behavior.

The documented search model should reflect:

### Incremental term semantics

- unfinished one-character token: no broad text search;
- completed one-character token: exact token search;
- unfinished token of two or more characters: word-initial prefix;
- whitespace-completed token: exact token;
- prefix matching does not perform arbitrary internal substring matching;
- raw editor text remains untouched.

Examples:

```text
p       → no broad search
p       → if followed by whitespace, exact token p
po      → word prefix po*
post    → word prefix post*
post␠   → exact token post
```

### Boolean semantics

AND:

> Match all terms.

OR:

> Match any term.

Each term may be satisfied by any participating search domain, currently:

- visible message text;
- message tags.

`is:saved` remains a filter, not a boolean alternative.

### Search domains

Document that:

- `message_text_fts` indexes visible message text only;
- metadata such as GUID/sender/semantic kind no longer participates in ordinary message-text search;
- tags are a separate search domain;
- saved state is a filter;
- scopes remain mandatory restrictions.

### Deferred link-preview work

Ensure the deferred follow-up is recorded clearly enough that it will not be lost after this branch merges.

The note should state that:

- Apple-stored link-preview metadata appears worthwhile to index;
- the future work should use only Apple-stored/offline metadata;
- no historical URL crawling/network enrichment should be used;
- likely useful fields include title, summary/description, site name, stored URL/domain;
- the implementation should use a separate `message_link_fts`-style search domain;
- it should occur on a separate feature branch after fixture/decoder validation.

Do not turn this close-out stage into implementation of that feature.

## 6. Final regression validation

Run the full relevant validation required by project conventions.

At minimum include:

- Stage 1 parser tests;
- SearchService tests;
- FTS runtime tests;
- graph search repository tests;
- graph migration tests;
- projector tests;
- tag/saved search tests;
- affected provider tests;
- global/conversation/contact/handle/Handle Lens/recovered search tests;
- highlighting tests;
- AND/OR control tests;
- architecture tripwires;
- `flutter analyze`;
- formatting checks;
- `git diff --check`.

If the project has a standard broader/full test command for release-ready feature branches, run it as well unless clearly prohibitive.

Report exact pass/fail results.

Do not conceal flaky or pre-existing failures; distinguish them from regressions introduced by this branch.

## 7. Manual acceptance matrix

Before declaring merge-ready, verify the intended behavior using either existing automated coverage or an appropriate local/manual test path.

At minimum confirm:

### Incremental/exact search

```text
p
p␠
post
post␠
bass
bass␠
```

Expected:

- `p` does not trigger broad archive matching;
- `p ` searches exact token `p`;
- `post` includes `postmaster` / `postsecondary` where token-prefix semantics apply;
- `post ` excludes those and retains exact `post`;
- `bass` includes `bassist` / `basset`;
- `bass ` restricts to exact `bass`;
- the first typed trailing space remains visible immediately.

### AND/OR

Using suitable fixtures:

- AND requires every entered term to match the same message;
- terms may be distributed across text and tags;
- separate tags can jointly satisfy AND;
- OR requires any entered term;
- `is:saved` remains mandatory under either mode.

### Result presentation

- nonmatching Handle Messages rows disappear;
- nonmatching Handle Lens rows disappear;
- highlighting agrees with exact/prefix semantics;
- counts and displayed membership agree.

## 8. Performance sanity

Do not fabricate benchmark claims.

If representative non-private performance fixtures exist, run a lightweight sanity check for:

- common two-character prefixes;
- multi-term AND/OR;
- saved-filter queries;
- large candidate sets.

If no representative fixture exists, state that explicitly.

Do not access private production/Application Support data merely for close-out.

## 9. Final commit

If all close-out edits and validation succeed:

- stage only intended close-out files;
- create a final commit for version/changelog/documentation changes.

Use a project-appropriate message such as:

`docs(release): finalize message text search enhancement`

or a more appropriate conventional commit if repository history indicates another style.

Do not amend prior feature checkpoints unless required by project policy.

## 10. Merge-readiness audit

After the final commit, compare:

`feature/message-text-search`

against:

`main`

and report:

- commits unique to the feature branch;
- files changed;
- whether working tree is clean apart from deliberately untracked personal files;
- whether submodules are clean;
- whether branch appears mergeable without unrelated dependencies;
- whether `main` has advanced since this branch was created;
- whether a merge/rebase/update is needed before integration.

Do not merge into `main` automatically unless project instructions explicitly require that as part of the normal close-out workflow.

If `main` has advanced, recommend the safest integration step rather than silently rewriting history.

## 11. Final deliverable

Return a concise close-out report containing:

1. branch and HEAD;
2. feature commit history;
3. version change;
4. changelog entry summary;
5. documentation updated;
6. deferred link-preview note location;
7. validation results;
8. manual acceptance results;
9. performance evidence or stated limitation;
10. final close-out commit;
11. git status;
12. submodule status;
13. delta from `main`;
14. merge-readiness assessment;
15. exact recommended next Git action.

Do not implement new search features during this stage.
Do not implement link-preview search.
Do not redesign recovered-message `is:saved` behavior.

That should get the branch to a clean, reviewable “ready to integrate” state without accidentally smuggling the link-preview work into the current feature.