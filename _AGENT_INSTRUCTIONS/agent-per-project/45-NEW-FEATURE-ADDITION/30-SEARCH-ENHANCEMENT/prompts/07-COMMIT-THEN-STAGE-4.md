### Please first create a clean checkpoint commit for the completed Stage 1–3 message-search work, then implementStage 4 only: raw editor-state preservation and search-result highlighting.
Work only on:
### feature/message-text-search
# Part 1 — Commit completed Stage 1–3 work
### Before committing:
1. Confirm the current branch.
2. Inspect git status.
3. Review the diff and ensure only intended Stage 1–3 search work is included.
4. Preserve unrelated untracked work:  
   * .vscode/settings.json
   * 30-SEARCH-ENHANCEMENT/

⠀Do not stage either of those unless 30-SEARCH-ENHANCEMENT/ has deliberately become tracked project documentation under existing repository conventions. If uncertain, leave both untracked.
Stage and commit the completed structured-query + FTS5 implementation.
Suggested commit message:
### feat(search): add structured FTS5 message text search
Do not amend unrelated history.
After the commit, verify that only intentionally untracked files remain.
 
⸻
 
# Part 2 — Stage 4 objective
### Fix the user-facing editor-state bug and make highlighting obey the same exact/prefix token semantics as the new search backend.
### Donot change:
* FTS schema;
* FTS tokenizer;
* migration;
* repository search semantics;
* tag semantics;
* saved filtering;
* AND/OR product semantics;
* result cap;
* wildcard syntax;
* phrase syntax.

⠀A. Preserve raw editor input
### The search field must preserve exactly what the user types.
### The known bug is:
### controller: "post "
### → presentation/provider trims to "post"
### → trimmed value is written back into controller
### → visible trailing space disappears
### Eliminate this trim-and-write-back cycle.
### The UI/editor must retain raw input including:
* trailing space;
* repeated trailing spaces;
* leading space if typed;
* tabs/newlines where the control permits them.

⠀Normalization and parsing must occur only for search execution, never by rewriting visible editor state.
# B. Verify all search surfaces
### Audit and update every message-search surface that currently trims or rewrites the query before presentation/controller synchronization, including as applicable:
* global All Messages;
* Search-page All Messages tracks;
* conversation messages;
* contact messages;
* handle messages;
* Handle Lens;
* recovered messages;
* unfamiliar-source/handle tracks.

⠀Do not blindly remove .trim() where it is legitimately used only for execution or empty-state checks.
The requirement is specifically:
raw editor state remains raw; parsed search intent drives execution.
Use the existing Stage 1 MessageTextSearchQuery parser rather than introducing another raw/normalized representation.
# C. Execution semantics must now be observable
### After this stage:
### Typing:
### post
should execute prefix post*.
Typing the first following space:
### post
must immediately remain visible and execute exact post.
There must be no need to press Space twice.
Likewise:
### p
should not launch broad prefix search.
Typing:
### p
must remain visible and execute exact token p.
# D. Provider/cache identity
### Review provider/scope equality and stable keys that currently trim query strings.
### Ensure semantically distinct parsed intents cannot collapse together.
### In particular:
### post
and:
### post
must not share an execution identity.
However, avoid using byte-for-byte raw input as persistence/search identity where parsed intent is identical.
For example:
### post
and:
### post
may preserve different raw UI strings while sharing equivalent parsed search intent.
Prefer execution identity derived from structured intent.
Do not broaden this into an unrelated provider architecture refactor.
# E. Highlighting
### UpdateSearchHighlightedText or the existing highlighting path so highlighted spans reflect the same token semantics as search results.
Current substring highlighting is no longer acceptable because it can visually imply matches that FTS would not return.
Required examples:
## Prefix query
### post
### Highlight the matching word-prefix portion in:
* post
* posting
* postmaster

⠀Do not highlight post inside:
* crosspost

⠀Exact query
### post
### Highlight whole-tokenpost in:
* post
* post.
* (post)
* post?
* post-master if this follows the accepted unicode61 boundary behavior

⠀Do not highlight inside:
* posting
* postmaster
* crosspost

⠀Highlighting should align as closely as practical with the accepted unicode61 tokenizer behavior established in Stage 3.
Do not introduce a second hand-written tokenization model that predictably diverges from FTS.
If exact replication of SQLite token boundaries in Dart is not practical, identify the narrowest maintainable approximation and characterize any mismatch explicitly with tests.
# F. Multiple tokens
### For a parsed query such as:
### bass pl
highlight:
* exact token bass
* word-prefix pl...

⠀Do not let generic substring highlighting reappear for either token.
AND/OR still determines result composition elsewhere; highlighting should simply show matching token spans present in displayed text.
# Tests
### Add focused tests for at least:
### Raw editor state
* first trailing space remains visible;
* post and post generate distinct execution intent;
* repeated trailing spaces remain visible;
* parsing does not rewrite controller text;
* p versus p behaves correctly.

⠀Search surfaces
### Cover global All Messages and representative additional surfaces sharing the same control/state infrastructure.
### Where implementation is shared, avoid duplicating superficial tests for every surface; prove shared behavior plus any divergent paths.
### Provider identity
### Prove:
* post ≠ post at execution-intent level;
* equivalent parsed intent from different raw spacing does not cause unnecessary search divergence where applicable.

⠀Highlighting
### Cover:
* prefix post in posting;
* prefix post not in crosspost;
* exact post in punctuation-delimited forms;
* exact post not in postmaster;
* bass pl;
* case-insensitive matching;
* accepted hyphen/apostrophe behavior;
* representative Unicode/diacritic behavior where practical.

⠀Validation
### Run:
* Stage 1 parser tests;
* SearchService tests;
* repository FTS tests;
* affected provider tests;
* affected view/widget tests;
* highlighting tests;
* architecture tripwires;
* flutter analyze;
* git diff --check.

⠀Do not change release metadata yet.
# Deliverable
### Report:
1. checkpoint commit hash and message;
2. files changed in Stage 4;
3. raw-vs-parsed state architecture;
4. where trim/write-back behavior was removed;
5. search surfaces verified;
6. provider/cache identity changes;
7. highlighting implementation;
8. any known mismatch with SQLite unicode61;
9. tests added/updated;
10. validation results;
11. git status;
12. recommended Stage 5 boundary.

⠀Do not proceed into AND/OR redesign or release metadata after completing Stage 4.
