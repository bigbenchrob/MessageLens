1. Start from what you already have

From seed.md, you already have:
	•	Structural indices: global_message_index, message_index, contact_message_index with ordinals + month keys for global / per-chat / per-contact timelines.
	•	A ready-to-use messages_fts virtual table with triggers that keep it in sync with working_messages.
	•	Current search: simple LIKE '%query%' over working_messages, scoped by either chat or contact, not using messages_fts yet.  ￼

So the good news: your “lexical text indexer” is basically already present, just underused.

⸻

2. Mirror the migration architecture: “search indexers + orchestrator”

Think of “search” as its own mini-subsystem with:
	•	SearchIndexOrchestrator
	•	Knows the list of indexers.
	•	Can:
	•	rebuildAllSearchIndexes()
	•	rebuildForMessages(Set<MessageId>) (for incremental use)
	•	Called:
	•	After migrations (similar to how HandlesMigrationService rebuilds message indexes now).
	•	Optionally from admin/debug tools.
	•	SearchIndexer interface (analogous to your table migrators)
	•	String get id;
	•	Future<void> rebuildAll(SearchContext ctx);
	•	Optional: Future<void> rebuildForMessages(SearchContext ctx, Iterable<MessageId>);
	•	Future<void> validate(SearchContext ctx); (self-check, assert invariants).
	•	Each indexer:
	•	Owns its own tables / virtual tables.
	•	Never requires another indexer; it only reads canonical tables and common context.
	•	SearchContext
	•	Read-only façade over:
	•	working_messages, global_message_index, etc.
	•	Maybe some utility helpers (e.g., loadMessagesByIds, iterateAllMessagesInBatches).
	•	No references to other indexers’ tables; that’s how you avoid dependency chains.

This gets you the same benefits as the migration refactor:
	•	You can remove / disable an indexer without affecting others.
	•	If a bug appears, you know which indexer’s rebuild/validate to inspect.
	•	You can test each indexer in isolation.

⸻

3. Concrete indexers to support your new search modes

3.1 Lexical FTS indexer (multi-term ranking baseline)

Goal: Replace LIKE '%query%' with FTS-based queries that naturally support multi-term ranking.
	•	Tables used/owned
	•	Reuse existing messages_fts table + triggers.
	•	Indexer responsibilities
	•	FtsMessageIndexer:
	•	rebuildAll just truncates and repopulates messages_fts from working_messages (if ever needed).
	•	validate might:
	•	Sample a few messages and confirm they show up in FTS.
	•	Check row counts ≈ working_messages minus excluded types.
	•	Search behavior (query side, not indexer side)
	•	A query like "project meeting slides" becomes FTS query: project meeting slides.
	•	FTS gives you:
	•	Multi-term scoring (BM25-style) “for free”: more terms matched → higher score.
	•	Phrase queries if needed: "artificial intelligence" etc.
	•	Your search service:
	•	Parses the user’s multiple terms.
	•	Runs them against messages_fts.
	•	Sorts primarily by FTS rank, secondarily by sent_at_utc / ordinal.

This already satisfies the “termA + termB + termC ranked higher than only termA + termB” requirement as a first pass, without new schema.

⸻

3.2 Semantic indexer (for “AI” → “LLM”, “artificial intelligence”)

I’d deliberately separate two layers here:
	1.	Cheap synonym/alias expansion (no embeddings)
	2.	Optional, heavier semantic embedding index

3.2.1 Synonym / alias expansion indexer
Idea: Pre-maintain a small “domain lexicon” of related terms that the query parser can consult.
	•	Tables
	•	semantic_term_groups
	•	group_id
	•	canonical_term (e.g., "artificial intelligence")
	•	semantic_terms
	•	group_id
	•	term ("AI", "A.I.", "LLM", "GPT", "chatbot", …)
	•	Indexer: SemanticLexiconIndexer
	•	Actually tiny; more like a seeder + validator:
	•	On rebuildAll, ensure the lexicon tables exist and maybe seed a default set.
	•	On validate, check consistency (no duplicate terms, groups have ≥1 member).
	•	Query side
	•	When the user types "AI", the query parser:
	•	Looks up semantic_terms.term == 'ai'.
	•	Fetches the group_id and all terms in that group.
	•	Rewrites the FTS query: (AI OR "artificial intelligence" OR LLM OR GPT).
	•	Your basic FTS indexer still does the heavy lifting; this indexer just feeds it better queries.

You can add new groups over time: privacy, finance, work-project names, family nicknames, etc.

3.2.2 Optional semantic embeddings indexer
If/when you want true semantic search:
	•	Tables
	•	message_embeddings
	•	message_id
	•	embedding (BLOB or separate vector store ref)
	•	dim
	•	Maybe some metadata: created_at, model_version.
	•	Indexer: SemanticEmbeddingIndexer
	•	rebuildAll:
	•	Batch over all messages, skipping very short/boring ones.
	•	Generate embeddings via an external service and insert/update rows.
	•	rebuildForMessages:
	•	Re-embed only changed messages (e.g., new imports, manual edits).
	•	validate:
	•	Check counts.
	•	Check a few random embeddings are non-null, correct dimensions.
	•	Query side
	•	Convert the user query to an embedding.
	•	Cosine similarity against message_embeddings.
	•	Merge that semantic score with:
	•	FTS lexical score.
	•	Timeline recency.
	•	Emotion score, if relevant.

Crucially: this indexer only depends on working_messages and your embedding client; no other indexer.

⸻

3.3 Emotional / “intense messages” indexer

This feels like a perfect self-contained index.

Features you mentioned:
	•	All-caps usage.
	•	Multiple punctuation (“!!!”, “???”).
	•	Emoji density.
	•	Possibly sentiment (if you want).

Tables
	•	message_emotion_features
	•	message_id (PK / FK → working_messages.id)
	•	caps_ratio (0–1)
	•	max_run_of_exclamation
	•	max_run_of_question
	•	emoji_count
	•	emoji_ratio
	•	sentiment_score or emotion_label (if you add NLP later)
	•	has_swearing etc., if you want.

Indexer: MessageEmotionIndexer
	•	rebuildAll(SearchContext ctx)
	•	Stream all messages in batches.
	•	For each message:
	•	Compute scalar features from its body (simple, local logic).
	•	Bulk insert/replace into message_emotion_features.
	•	rebuildForMessages
	•	Same, but only for a subset of IDs.
	•	validate
	•	Sanity checks:
	•	Values in expected ranges.
	•	Counts align with working_messages for certain subsets.
	•	Search side
	•	“Show me angry messages”:
	•	Convert to thresholds (e.g., caps_ratio > 0.4 OR max_run_of_exclamation >= 3 OR sentiment_score < -0.5).
	•	“Show excited/happy ones”:
	•	High emoji ratio, many exclamation marks, positive sentiment.
	•	You can combine this with lexical / semantic filters:
	•	(emotion_score > threshold) AND FTS('vacation beach').

Again, totally independent: it has its own table, works off canonical text only.

⸻

4. Query-time architecture (how searches are executed)

Just like you separated migration into orchestrator + table migrators, you can separate search execution into:
	•	SearchQueryParser
	•	Input: raw user string + selected mode(s) (lexical, semantic, emotional).
	•	Responsibilities:
	•	Tokenize multi-term queries.
	•	Apply synonym expansion via SemanticLexiconIndexer’s tables.
	•	Interpret special modifiers:
	•	emotion:angry, emotion:excited, has:emoji, etc.
	•	Maybe in:chat(<contact>), from:me, etc.
	•	Produce a SearchPlan (more below).
	•	SearchPlan
	•	Something like:
	•	lexicalTerms: list of terms, with MUST/SHOULD weights.
	•	semanticExpansionTerms: grouped synonyms.
	•	emotionFilters: concrete numeric predicates.
	•	scopes: global / specific chat / specific contact.
	•	dateRange constraints (optional).
	•	SearchEngine / SearchCoordinator
	•	Given a SearchPlan, runs:
	1.	FTS search if needed (via FtsMessageIndexer’s table).
	2.	Semantic embedding search if enabled.
	3.	Emotion-feature filtering and/or scoring.
	•	Merges results:
	•	Each backend returns (message_id, score_component_X).
	•	Combine into a composite score:
	•	finalScore = w_lex * lexicalScore + w_sem * semanticScore + w_em * emotionScore + w_recent * recencyScore.
	•	Apply sort and pagination.
	•	Hydrates ChatMessageListItem etc. using existing providers + index tables.

The search engine knows about indexers only in terms of their tables / backing datasources, not their rebuild logic.

⸻

5. How indexers stay independent but can still “share”

Key principles so you don’t recreate the big opaque blob:
	1.	Single canonical data source
	•	Every indexer reads from:
	•	working_messages + existing structural indices (global_message_index, etc.).
	•	They don’t read each other’s tables to derive second-order features.
	•	If multiple indexers need the same derived fact, you can:
	•	Put it back in canonical tables, or
	•	Expose it via SearchContext as a pure function.
	2.	No hard ordering
	•	Orchestrator runs indexers in a fixed but conceptually arbitrary order.
	•	No indexer expects another to have run first; they either:
	•	Work from canonical data, or
	•	Assert via validation that their required base tables exist.
	3.	Versioned / optional
	•	You can mark indexers as “optional”:
	•	SemanticEmbeddingIndexer might be disabled in dev or on machines without an embedding API key.
	•	Search engine checks capabilities:
	•	If semantic index not available, it just omits that score component.
	4.	Per-indexer tests
	•	You get the same debugging story as migrations:
	•	If emotional search looks off, you jump straight to MessageEmotionIndexer tests and validation.

⸻

6. A plausible first-phase roadmap

To keep this incremental and safe:
	1.	Phase 1 – Multi-term lexical search
	•	Wire up messages_fts as the default backend for global / chat / contact search.
	•	Implement SearchQueryParser for multiple terms and simple AND/OR.
	•	Use FTS ranking to order results by #terms matched and proximity.
	•	Keep schema changes to a minimum.
	2.	Phase 2 – Emotional indexer
	•	Add message_emotion_features + MessageEmotionIndexer.
	•	Add simple emotional filters:
	•	“show intense messages”, “has many emojis”, etc.
	•	Combine with lexical search.
	3.	Phase 3 – Semantic synonyms
	•	Add semantic_term_groups / semantic_terms.
	•	Query parser does term expansion before calling FTS.
	•	For "AI", you now get "LLM", "artificial intelligence", etc.
	4.	Phase 4 – Full semantic embeddings (optional)
	•	Add message_embeddings + SemanticEmbeddingIndexer.
	•	Merge embedding similarity into ranking.
	•	Possibly expose a “semantic search” mode in the UI.

Each phase is a new indexer + minimal orchestrator / query changes, not a giant rewrite.