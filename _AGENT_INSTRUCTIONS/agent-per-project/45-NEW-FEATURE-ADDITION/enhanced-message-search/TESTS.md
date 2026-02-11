# Tests: Enhanced Message Search

## Manual Verification Steps

### 1. Multi-term Search (Lexical)
- [ ] **Setup**: Ensure you have messages with distinct words (e.g., "The quick brown fox jumped over the lazy dog").
- [ ] **Action**: Enter "quick lazy" in the global search bar.
- [ ] **Expectation**: The message appears in results.
- [ ] **Action**: Enter "quick zebra" (where "zebra" is missing).
- [ ] **Expectation**: The message does NOT appear.

### 2. Incremental Indexing
- [ ] **Setup**: Have the app running.
- [ ] **Action**: Send a new message via iMessage (e.g., "Testing incremental search index").
- [ ] **Observation**: Wait for "Incremental migration successful" log.
- [ ] **Action**: Search for "incremental search".
- [ ] **Expectation**: The new message appears immediately.

### 3. Emotional Search (Phase 2)
- [ ] **Setup**: Send a message "I AM SO ANGRY!!!"
- [ ] **Action**: Search for "emotion:intense".
- [ ] **Expectation**: The angry message appears.
- [ ] **Action**: Search for "emotion:intense angry".
- [ ] **Expectation**: The message appears (combines filter + text).

## Automated Tests (Plan)

### Unit Tests
- `search_query_parser_test.dart`:
    - Parse "hello world" -> `terms: ['hello', 'world']`
    - Parse "emotion:intense hello" -> `terms: ['hello'], filters: {emotion: intense}`

### Integration Tests
- `fts_indexer_test.dart`:
    - Insert message into `working_messages`.
    - Run `FtsMessageIndexer.rebuildAll`.
    - Query `messages_fts` and verify match.
