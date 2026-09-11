I’d make this first prompt explicitly **read-only** and ask Codex to trace the smallest clean implementation path before changing anything. We now have sufficiently precise semantics that it should be able to evaluate architecture rather than invent behaviour. The current audit established that message text is presently an unrestricted substring scan and that trailing whitespace is being stripped before it can carry semantic meaning, so those are the two principal things this investigation needs to replace or disentangle. [oai_citation:0‡search_review.md](sediment://file_00000000bfc4820ea422a59b80b61200)



Please perform a **read-only investigation** of MessageLens message-text search and propose the smallest, cleanest implementation plan for introducing natural incremental word search.

Do not edit any files yet.

## Context

A tester identified several problems with current message search. We have already established that:

- message text is currently searched as an unrestricted case-insensitive substring, effectively `%term%`;
- therefore `bass` also matches `bassist`;
- there is currently no exact-word search;
- trailing whitespace is trimmed in parts of the presentation/search pipeline;
- on the global All Messages surface, normalized/trimmed state is fed back into the editable controller, causing the first typed trailing space to disappear;
- the lower-level search service has some awareness of trailing whitespace for tag completion, but message-text search does not currently use that distinction.

We now want to redesign **message-text token semantics first**.

Please leave AND/OR behaviour out of scope for this investigation except where existing architecture must be noted. We will revisit boolean semantics after basic term handling is correct.

## Desired user-facing behaviour

The search box should behave naturally enough that an ordinary user does not need to know search syntax, quote delimiters, or wildcards.

The key principle is:

> An unfinished search token refers to the **beginning of the sought-for word**, not to an arbitrary substring inside it.

For example, entering:

`po`

should be capable of finding words such as:

- `post`
- `possible`
- `point`
- `police`

but should **not** normally find words such as:

- `support`
- `repository`
- `decompose`

Similarly:

`post`

should find:

- `post`
- `posts`
- `posted`
- `posting`
- `postmaster`

but should **not** normally find:

- `crosspost`

We may later introduce explicit wildcard syntax such as `*ic*` for users who intentionally want arbitrary substring matching. That future capability is out of scope now.

## Proposed semantic rules

Please treat these as the desired behaviour unless implementation constraints reveal a compelling reason to modify them.

### 1. Unfinished token shorter than two characters

Input:

`p`

Do not perform an ordinary broad message-text search yet.

A one-character prefix search would be both noisy and potentially expensive.

### 2. Completed one-character token

Input:

`p `

The trailing whitespace means the user has completed the token.

Search for the standalone word/token `p`.

This should allow searches such as:

- `p value`
- `p =`
- `x axis`
- `R squared`

without requiring special syntax.

### 3. Unfinished token of two or more characters

Input:

`po`

Interpret the active token as a **word-initial prefix**.

Conceptually this means:

`po*`

at a token boundary, not:

`*po*`

The same applies to longer unfinished input:

`post`

means words beginning with `post`.

### 4. Token completed with whitespace

Input:

`post `

Interpret `post` as a completed whole token.

It should match standalone `post`, including normal punctuation boundaries such as:

- `post`
- `post.`
- `post,`
- `(post)`
- `post?`
- `post` at end of message
- `post` before a newline

It must **not** match:

- `postmaster`
- `posting`
- `posted`

The whitespace is a signal about the state of the **query token**. It should not require literal whitespace after the corresponding word in the message.

Please investigate how apostrophes, hyphens, Unicode punctuation, emoji boundaries, and similar cases are currently tokenized or could sensibly be tokenized. Do not invent elaborate syntax; simply identify decisions we will need to make.

### 5. Multiple terms

The same distinction should naturally apply within a longer query.

For example:

`bass pl`

contains:

- completed token `bass`
- active prefix token `pl`

So `bass` should be matched as a whole token while `pl` should match the beginning of a word.

Likewise:

`bass player `

contains two completed tokens.

Do not redesign AND/OR yet. Just determine how completed versus active tokens can be represented cleanly so the later boolean layer can consume them.

### 6. Raw input must remain raw

The editable search controller must preserve exactly what the user types.

Search normalization must never rewrite the visible query.

In particular, typing the first trailing space must not make it disappear.

Raw presentation/controller state and normalized search state should be separate concepts.

## Important design intent

This is meant to feel like an ordinary search box, not a miniature query language.

The user should discover these behaviours simply by typing:

- while typing a word, results progressively narrow by word prefix;
- once Space is pressed, that word becomes exact.

No special trick should be required to distinguish:

`bass`

from:

`bass `

Wildcards, quoted phrases, arbitrary substring search, exclusions, and other advanced syntax may be considered later, but should not complicate this first implementation.

## Investigation requested

Please trace the current implementation and report:

1. Every layer involved from the editable search field through:
   - controller state;
   - providers/session state;
   - token parsing/normalization;
   - repository/service calls;
   - SQL generation;
   - result retrieval.

2. Which search surfaces share this pipeline and which diverge:
   - global All Messages;
   - contact message search;
   - handle search;
   - recovered-message search;
   - any other message-text search surface using the same infrastructure.

3. Where `.trim()`, whitespace splitting, lowercasing, or other normalization occurs.

4. Where raw query state is currently synchronized back into UI/controller state.

5. Whether an existing tokenizer, parser, query object, FTS abstraction, SQLite helper, or search-domain type can be reused rather than creating a parallel implementation.

6. Whether SQLite FTS5 is already available anywhere in the project or dependencies, even if it is not currently used for message search.

7. Whether the desired semantics are best implemented using:
   - the existing SQL/LIKE architecture;
   - SQLite FTS5;
   - another existing project facility;
   - or a staged approach.

Please evaluate this in terms of:
- correctness;
- search latency;
- database/index size;
- onboarding/import cost;
- periodic intake of newly arriving messages;
- migration requirements for existing users;
- compatibility with the current 10,000-result contract;
- ability to support future explicit wildcard or phrase syntax without painting us into a corner.

8. If FTS5 is appropriate, determine specifically how its tokenizer and prefix-query capabilities map to the desired semantics. Identify any mismatch rather than assuming FTS automatically gives us exactly what we want.

9. Determine how existing message-text search can stop producing invisible metadata-only matches if that behaviour is coupled into the same query path. Do not change it yet unless necessary; just identify the architecture and whether message text can cleanly become its own search domain.

10. Identify all focused tests that already cover this pipeline and the tests that should be added.

## Hard behavioural invariants

The eventual implementation should satisfy at least these cases:

| Input | Expected interpretation |
|---|---|
| `p` | no broad text search yet |
| `p ` | exact standalone token `p` |
| `po` | word-prefix `po*` |
| `post` | word-prefix `post*` |
| `post ` | exact token `post` |
| `post` | may match `postmaster` |
| `post ` | must not match `postmaster` |
| `post` | should not match `crosspost` |
| `ic` | should not match `ridiculous` merely because it contains `ic` |
| `bass pl` | exact `bass` + prefix `pl*` at the token-semantics layer |

Case matching should remain case-insensitive unless the existing architecture reveals a reason otherwise.

## Scope constraints

For this pass:

- **Do not edit files.**
- Do not implement anything.
- Do not redesign AND/OR.
- Do not introduce wildcard syntax.
- Do not introduce quote/phrase syntax.
- Do not perform broad unrelated refactors.
- Preserve existing project architectural conventions wherever possible.
- Prefer reuse of existing search/token/index infrastructure over inventing a second system.

## Deliverable

Please return:

1. **Current architecture**
2. **Relevant reusable components**
3. **Where current behaviour conflicts with the desired semantics**
4. **Recommended technical approach**
5. **Alternatives considered and why they are weaker**
6. **Exact proposed edit scope**
7. **Migration/index implications, if any**
8. **Focused test plan**
9. **Hard invariants to preserve**
10. **Minimal implementation sequence**

Please explicitly flag any assumption that you cannot establish from the repository.

No files should be changed.

Once Codex reports back, I’d scrutinize especially its FTS5 recommendation: FTS is likely attractive here, but we should make sure its tokenizer gives us *our* definition of “finished word” rather than quietly accepting whatever token semantics SQLite happens to provide.