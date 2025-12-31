# Checklist: Enhanced Message Search

## Phase 1: Foundation & Lexical Search

- [ ] **Infrastructure Setup**
    - [ ] Define `SearchIndexer` interface.
    - [ ] Define `SearchContext` class.
    - [ ] Create `SearchIndexOrchestrator` skeleton.
    - [ ] Register `SearchIndexOrchestrator` in Riverpod.

- [ ] **FTS Indexer**
    - [ ] Implement `FtsMessageIndexer`.
    - [ ] Implement `rebuildAll` (truncate/fill).
    - [ ] Implement `validate` (row count check).

- [ ] **Query Parsing & Execution**
    - [ ] Implement `SearchQueryParser` (basic term splitting).
    - [ ] Implement `SearchEngine` (FTS query execution).
    - [ ] Create `SearchPlan` value object.

- [ ] **UI Integration**
    - [ ] Update `GlobalMessagesViewModel` to use `SearchEngine`.
    - [ ] Update `ContactMessagesViewModel` to use `SearchEngine`.

## Phase 2: Indexing Infrastructure & Example

- [ ] **Emotional Indexer (Schema)**
    - [ ] Create `message_emotion_features` table in Drift (`working.db`).
    - [ ] Run `dart run build_runner build`.

- [ ] **Emotional Indexer (Logic)**
    - [ ] Implement `MessageEmotionIndexer`.
    - [ ] Implement heuristic logic (caps, emojis).
    - [ ] Register in `SearchIndexOrchestrator`.

- [ ] **Pipeline Integration**
    - [ ] Update `ChatDbChangeMonitor` to call `SearchIndexOrchestrator.rebuildForMessages` (or `rebuildAll` for now) after migration.
    - [ ] Verify new messages get indexed automatically.

- [ ] **Search Enhancements**
    - [ ] Update `SearchQueryParser` to handle `emotion:intense`.
    - [ ] Update `SearchEngine` to filter by emotion features.

## Phase 3: Verification & Cleanup

- [ ] **Testing**
    - [ ] Unit test `SearchQueryParser`.
    - [ ] Integration test FTS search (multi-term).
    - [ ] Verify incremental updates work end-to-end.
- [ ] **Documentation**
    - [ ] Update `STATUS.md`.
    - [ ] Move feature docs to `40-FEATURES`.
