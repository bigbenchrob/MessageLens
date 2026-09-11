# Deferred follow-up: index Apple-stored link preview metadata

## Audit outcome — 2026-09-11

The read-only repository audit found this feature worthwhile but not ready to
implement without representative Apple payload fixtures. It is deferred to a
separate feature branch after the message-text search enhancement closes.

The future invariant is:

> Search only Apple-stored historical preview metadata already available to
> MessageLens. Do not crawl, revisit, or enrich historical URLs over the
> network.

The existing local plist decoder recognizes title, summary, site name, one
stored URL, and image/icon/video URL references, but it is not connected to
production import, projection, or search. Fixture validation must establish
which fields Apple reliably supplies before a final schema is designed.

Likely useful searchable fields are title, summary/description, site name, and
stored URL/domain. Asset URLs and binary preview media should not become search
text. Preserve visible message text in `message_text_fts` and add preview
metadata through a distinct `message_link_fts`-style evidence domain so future
results can explain why an opaque URL matched.

## Product rationale

Messages that contain URLs often carry much more meaning in their link-preview metadata than in the literal URL text itself.

If a user deliberately sends or receives a URL in a conversation, that URL is likely to represent something of interest and should be retrievable later by its semantic content where possible.

For example, a message containing only an opaque URL might still be discoverable through:

- page title;
- preview title;
- description;
- site/domain name;
- canonical URL;
- visible URL;
- keywords, if present;
- any other useful metadata Apple already stored for the link preview.

## Scope constraint

Use **only metadata Apple already persisted with the message/link preview**.

Do not design or implement historical crawling or network fetching of URLs merely to enrich search.

Reasons include:

- privacy;
- changed/dead pages;
- authentication;
- migration cost;
- unpredictable network activity;
- divergence from the historical preview the user originally saw.

## Architectural intent

Do not automatically mix this material into `message_text_fts` as though it were visible message text.

Prefer treating link-preview metadata as a distinct searchable evidence domain so that MessageLens can eventually explain why a result matched.

Conceptually:

- message text → `message_text_fts`
- link-preview metadata → separate link/search metadata domain
- tags → overlay-owned
- saved state → overlay-owned

The exact schema should be determined only after auditing what Apple actually stores.

## Deferred sequence

Do **not** implement this until the current message-search work has completed:

1. exact/prefix term semantics;
2. raw query preservation;
3. highlighting alignment;
4. AND/OR product semantics.

After AND/OR is settled, perform a **read-only audit** of:

- what Apple link-preview metadata is present in imported/source data;
- where it lives;
- whether current import/projection code already decodes or preserves it;
- whether historical records contain enough metadata to make indexing worthwhile;
- how it should join back to canonical message `ss_id`;
- whether a separate FTS domain is appropriate.

Only then design the implementation.

## Reminder

Before closing the `30-SEARCH-ENHANCEMENT` workstream, revisit this note and decide whether to proceed with a dedicated link-preview metadata search stage.
