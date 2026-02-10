# Feature Proposal: Enhanced Message Search

## 1. Summary
We propose to overhaul the message search capability in `remember_every_text`. The current implementation relies on simple substring matching (`LIKE '%query%'`), which limits users to single contiguous strings. The new system will support multi-term search (e.g., "quick lazy" matches "the quick brown fox... lazy dog") and establish a modular architecture for future enhancements like semantic search, synonym expansion, and metadata-based filtering (e.g., emotional intensity).

## 2. Goals
1.  **Multi-term Search**: Enable users to find messages containing multiple distinct terms (AND logic) with ranking based on relevance.
2.  **Modular Indexing Architecture**: Implement a `SearchIndexOrchestrator` and `SearchIndexer` pattern—mirroring the existing Import/Migration architecture—to manage derived data.
3.  **Extensibility**: Ensure the system can easily accommodate new indexers (e.g., Semantic, Emotional) without modifying the core search logic.
4.  **Maintainability**: Keep indexing logic isolated, testable, and debuggable.

## 3. Scope
### In Scope
-   **Phase 1: Foundation & Lexical Search**
    -   Define `SearchIndexOrchestrator`, `SearchIndexer`, and `SearchContext`.
    -   Implement `FtsMessageIndexer` to manage the existing `messages_fts` virtual table.
    -   Implement `SearchQueryParser` to handle multi-term queries.
    -   Update `GlobalMessagesViewModel` and `ContactMessagesViewModel` to use the new search engine.
-   **Phase 2: Indexing Infrastructure & Example Implementation**
    -   Integrate `SearchIndexOrchestrator` into the post-migration pipeline (incremental and full).
    -   Implement `MessageEmotionIndexer` as a concrete example of a secondary indexer requiring data processing during migration.
    -   Add basic "emotional" filters to the search UI (e.g., "Show intense messages").

### Out of Scope (for now)
-   Full Semantic Search (Embeddings/Vector DB).
-   Synonym/Alias Expansion (Lexicon-based).
-   Complex boolean operators (OR, NOT, parentheses) beyond implicit AND.

## 4. Architecture Overview
The solution adopts the "Indexer + Orchestrator" pattern:
-   **SearchIndexOrchestrator**: Manages a registry of `SearchIndexer`s and coordinates their execution (rebuild all, incremental update).
-   **SearchIndexer**: A self-contained module responsible for maintaining a specific derived table (e.g., `messages_fts`, `message_emotion_features`).
-   **SearchQueryParser**: Parses user input into a `SearchPlan`.
-   **SearchEngine**: Executes the `SearchPlan` against the various indices and merges results.

## 5. Risks & Constraints
-   **Performance**: Re-indexing large message histories must be efficient. We will leverage the existing incremental migration patterns.
-   **Complexity**: Adding another orchestration layer increases architectural weight. We will mitigate this by strictly following the established patterns from the Import/Migration layer.

## 6. Success Metrics
-   Searching "quick lazy" returns messages containing both words.
-   New messages are automatically indexed after import/migration.
-   The "Emotional" indexer correctly identifies all-caps or high-emoji messages.
