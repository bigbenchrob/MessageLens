



Please first checkpoint-commit the completed Stage 5 AND/OR work, then perform the previously deferred **read-only audit of Apple-stored link-preview metadata**.

Do not implement link-preview indexing yet.

## Part 1 — Stage 5 checkpoint

Confirm the branch is:

`feature/message-text-search`

Review the current Stage 5 diff and commit only the intended Stage 5 files.

Suggested commit message:

`fix(search): apply AND and OR across search terms`

Preserve untouched/untracked:

- `.vscode/settings.json`
- `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/30-SEARCH-ENHANCEMENT/`

Do not stage or commit those merely as part of this checkpoint.

After committing, report the commit hash.

---

# Part 2 — Read-only link-preview metadata audit

We previously deferred investigation of whether Apple stores useful semantic metadata alongside URL/link previews in Messages.

The product rationale is:

> A URL deliberately sent or received in a conversation is likely to represent information of interest. The literal URL may be semantically poor, while Apple's stored preview metadata may contain useful title, description, domain, canonical URL, keywords, or other retrievable information.

We want to use **only metadata Apple already stored**.

Do not crawl, fetch, revisit, or enrich historical URLs from the network.

## Questions to answer

### 1. What Apple actually stores

Trace the source data involved when an iMessage contains a rich URL/link preview.

Determine what useful metadata can exist, including where applicable:

- original URL;
- canonical URL;
- page title;
- preview title;
- description;
- site/domain name;
- publisher/provider;
- keywords;
- image/thumbnail references;
- MIME/content type;
- any other meaningful text Apple stores with the preview.

Do not assume all of these exist. Report only what the repository/schema/decoders establish.

### 2. Where it lives

Determine whether link-preview information is stored in:

- `chat.db` message columns;
- attributed/rich-text payloads;
- attachment records;
- serialized Apple archive/plist objects;
- separate Messages databases/files;
- some combination.

Identify relevant schema columns, payload types, or decoding paths.

### 3. What MessageLens already imports

Trace whether current onboarding and periodic intake already preserve any of this metadata.

For each useful field, classify it as:

- already imported and projected;
- imported but not projected;
- present in source data but currently discarded;
- decoded transiently but not persisted;
- not presently decoded;
- unavailable from evidence in the repository.

### 4. Existing typedstream/rich-link decoding

Inspect the existing NSAttributedString / typedstream / rich-text decoding pipeline.

Determine whether Apple's link-preview objects are already encountered there and whether existing decoder infrastructure can be reused.

Do not modify the decoder in this audit.

### 5. Historical availability

Determine whether link-preview metadata appears likely to be available for historical messages already present in the source/import data, or only for newly processed messages.

We want to know whether an eventual feature could be backfilled without network access.

Do not access private production/Application Support data merely to answer this unless project rules already contain an approved non-private fixture.

If repository fixtures cannot establish prevalence, say so explicitly.

### 6. Message identity

Determine how any preview metadata can reliably map back to canonical graph:

`message.ss_id`

We need a clean association so search results continue to identify messages, not detached links.

### 7. Search architecture

Evaluate whether the current Stage 5 composition naturally supports a separate domain such as:

```text
termHits(term) =
    textHits(term)
    UNION tagHits(term)
    UNION linkPreviewHits(term)
```

Prefer preserving:

`message_text_fts`

as visible message text only.

Evaluate whether a separate FTS table/domain such as:

`message_link_fts`

would be cleaner than adding preview fields to `message_text_fts`.

Consider likely fields such as:

- title;
- description;
- URL;
- domain/site;
- keywords or other stored semantic text.

Do not design a final schema before determining what Apple actually supplies.

### 8. Exact/prefix and AND/OR semantics

Assume the existing search semantics remain authoritative:

- unfinished token → prefix;
- whitespace-completed token → exact;
- AND → all query terms must be satisfied;
- OR → any query term may be satisfied;
- each term can be satisfied by any participating evidence domain.

Determine whether link-preview metadata can cleanly participate without special search syntax.

### 9. Explainability

Consider whether MessageLens can identify *why* a URL-only message matched.

For example, an eventual result might be able to indicate:

`Matched link preview: Thermocouple Calibration Guide`

rather than leaving the user looking at an opaque URL.

Do not implement this UI now. Just identify what stored metadata would make such explanation possible.

### 10. Privacy and network invariant

The feature must remain local-first.

The preferred invariant is:

> Search only Apple-stored historical preview metadata already available to MessageLens.

Do not propose routine network requests merely to make old URLs searchable.

If Apple's stored metadata is too sparse to make the feature worthwhile, report that rather than solving it with crawling.

---

# Deliverable

Return:

1. Apple source locations for link-preview metadata
2. Fields actually available
3. Existing decoding/import support
4. What MessageLens currently preserves versus discards
5. Historical/backfill feasibility
6. Mapping to graph `message.ss_id`
7. Recommended searchable fields
8. Recommended search-domain architecture
9. Whether a separate FTS domain is warranted
10. Fit with existing exact/prefix semantics
11. Fit with Stage 5 AND/OR composition
12. Explainability opportunities
13. Migration/backfill implications
14. Tests/fixtures already available
15. Unknowns that cannot be established without representative real data
16. Exact proposed implementation scope, if the feature appears worthwhile
17. Recommendation:
- implement in this branch before search close-out;
- defer to a subsequent feature branch;
- or do not implement based on available evidence.

Do not modify source files during this audit.
Do not implement link-preview search.
Do not change release metadata yet.

That honors the sequencing decision we made earlier: **finish AND/OR, then investigate Apple's existing URL metadata before declaring search enhancement complete.** After that audit, we can make an informed call on whether link-preview search belongs in this branch or becomes its own follow-up feature.