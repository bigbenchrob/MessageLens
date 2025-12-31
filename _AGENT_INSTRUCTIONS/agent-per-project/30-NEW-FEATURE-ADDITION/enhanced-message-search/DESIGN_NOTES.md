# Design Notes: Enhanced Message Search

## 1. Core Concepts

The search system mirrors the project's Import/Migration architecture, treating "Search" as a subsystem that maintains derived views of the canonical `working_messages` table.

### 1.1. The Indexer Pattern
To avoid a monolithic "search service" that knows everything, we split responsibilities into isolated **Indexers**.

*   **`SearchIndexer` Interface**:
    ```dart
    abstract class SearchIndexer {
      String get id;
      /// Clear and rebuild the entire index from canonical data.
      Future<void> rebuildAll(SearchContext context);
      /// Update index for specific messages (incremental).
      Future<void> rebuildForMessages(SearchContext context, Iterable<int> messageIds);
      /// Sanity check the index state.
      Future<void> validate(SearchContext context);
    }
    ```

*   **`SearchContext`**: A read-only façade providing access to:
    *   `working_messages` (canonical source)
    *   `global_message_index` (structural source)
    *   Helper methods (e.g., `streamAllMessages()`, `loadMessages(ids)`)

### 1.2. The Orchestrator
*   **`SearchIndexOrchestrator`**:
    *   Maintains the list of active indexers.
    *   Exposes `rebuildAll()` and `processUpdates(ids)`.
    *   Called by `ChatDbChangeMonitor` (or `HandlesMigrationService`) after a successful migration.

## 2. Concrete Indexers

### 2.1. `FtsMessageIndexer` (Lexical)
*   **Purpose**: Provides multi-term text search.
*   **Backing Store**: `messages_fts` (SQLite Virtual Table).
*   **Logic**:
    *   *Rebuild*: Truncate `messages_fts`, populate from `working_messages`.
    *   *Incremental*: Delete old entries for `messageIds`, insert new text.
    *   *Note*: Since we already have triggers on `messages_fts`, this indexer might primarily serve as a "Repair/Resync" tool and a query interface, rather than needing heavy manual maintenance code.

### 2.2. `MessageEmotionIndexer` (Metadata/Heuristic)
*   **Purpose**: Filter by "intensity" or "emotion".
*   **Backing Store**: `message_emotion_features` table.
    *   `message_id` (PK, FK)
    *   `is_all_caps` (bool)
    *   `exclamation_count` (int)
    *   `emoji_count` (int)
    *   `caps_ratio` (double)
*   **Logic**:
    *   Scans message text.
    *   Calculates simple heuristics (e.g., `text.toUpperCase() == text`).
    *   Stores features.

## 3. Query Execution Pipeline

### 3.1. `SearchQueryParser`
*   **Input**: User string (e.g., "quick lazy emotion:intense").
*   **Output**: `SearchPlan`.
    *   `terms`: ["quick", "lazy"]
    *   `filters`: { `emotion`: `intense` }

### 3.2. `SearchEngine` (The Coordinator)
*   Executes the `SearchPlan`.
*   **Step 1**: Run FTS query (`quick AND lazy`) -> Get List<MessageId> + Scores.
*   **Step 2**: Apply Filters (Join with `message_emotion_features` where `caps_ratio > 0.8`).
*   **Step 3**: Merge & Sort.
*   **Step 4**: Hydrate results (fetch full `Message` objects).

## 4. Integration Points

*   **`ChatDbChangeMonitor`**:
    *   Currently calls `Import` -> `Migration`.
    *   **New**: Will call `Import` -> `Migration` -> `SearchIndexOrchestrator.processUpdates()`.
*   **`GlobalMessagesViewModel`**:
    *   Currently does `LIKE` query.
    *   **New**: Delegates to `SearchEngine`.

## 5. Database Schema Updates

### `message_emotion_features`
```sql
CREATE TABLE message_emotion_features (
    message_id INTEGER NOT NULL PRIMARY KEY REFERENCES messages(id) ON DELETE CASCADE,
    caps_ratio REAL DEFAULT 0,
    exclamation_count INTEGER DEFAULT 0,
    emoji_count INTEGER DEFAULT 0,
    is_intense BOOLEAN GENERATED ALWAYS AS (caps_ratio > 0.6 OR exclamation_count > 2) VIRTUAL
);
```
