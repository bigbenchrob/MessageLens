# Ordinal Index All Messages — Phase Plan

## Phase 0: Planning
- **Goal:** Confirm scope, dependencies, and approval before coding.
- **Steps:**
  - Review proposal with stakeholders and capture feedback.
  - Validate schema details for `message_index` and related tables.
  - Finalize checklist, design notes, and risk register.
- **Success Criteria:** Stakeholders sign off on scope; no open blocking questions.
- **Status:** Passed

## Phase 1: Drift DAO Enhancements
- **Goal:** Expose keyset pagination APIs that stream global message ordinals.
- **Steps:**
  - Add DAO query methods for forward/backward paging using `message_index`.
  - Ensure queries return lightweight identifiers only.
  - Cover DAO with unit tests verifying ordering and bounds.
- **Success Criteria:** Tests prove deterministic ordering and pagination correctness.
- **Tests:**
  - [x] `flutter test test/essentials/db/infrastructure/data_sources/local/working/global_message_index_triggers_test.dart`
  - [x] `flutter test test/essentials/db/infrastructure/data_sources/local/working/message_index_triggers_test.dart`
  - [x] `flutter test test/features/messages/infrastructure/data_sources/global_message_index_data_source_test.dart`
- **Status:** Passed

## Phase 2: Application Service Layer
- **Goal:** Provide a use case that mediates between UI cursors and DAO calls.
- **Steps:**
  - Implement `FetchGlobalMessageTimeline` (name TBD) returning DTOs.
  - Handle empty states, end-of-data detection, and error surfaces.
  - Add unit tests covering cursor transitions and error paths.
- **Success Criteria:** Service unit tests pass; API contracts documented.
- **Tests:**
  - [x] `flutter test test/features/messages/application/fetch_global_message_timeline_provider_test.dart`
- **Status:** Passed

## Phase 3: Provider & State Integration
- **Goal:** Wire Riverpod providers that drive pagination and hydration.
- **Steps:**
  - Generate provider family for global timeline cursors.
  - Integrate with existing message hydration providers.
  - Write provider tests ensuring lazy loading and retry behavior.
- **Success Criteria:** Provider tests demonstrate correct paging and recovery semantics.
- **Tests:**
  - [x] `flutter test test/features/messages/presentation/view_model/global_timeline_controller_test.dart`
- **Status:** Passed

## Phase 4: Navigation Wiring
- **Goal:** Make the global timeline reachable via ViewSpec navigation.
- **Steps:**
  - Add `MessagesSpec.globalTimeline` (or equivalent) and update coordinators.
  - Extend "Show messages from" menu with an "All Messages" option.
  - Verify navigation interactions through targeted tests.
- **Success Criteria:** Navigating from menu loads the timeline without regressions.
- **Status:** Passed

## Phase 5: Timeline UI Implementation
- **Goal:** Build the macOS timeline view with virtualization and jump controls.
- **Steps:**
  - Create timeline widget leveraging the new providers.
  - Implement virtual scrolling with lazy hydration triggers.
  - Add jump affordances (first/last/date) and contextual metadata.
  - Cover UI with widget tests where practical.
- **Success Criteria:** Manual runs show smooth scrolling on large datasets; widget tests pass.
- **Status:** Pending

## Phase 6: Polish & Final Review
- **Goal:** Stabilize the feature and get sign-off before release.
- **Steps:**
  - Address usability feedback and edge cases.
  - Run full regression suite and lint checks.
  - Conduct stakeholder review/demo.
- **Success Criteria:** Review approved; no open critical issues; CI clean.
- **Status:** Pending

## Phase 7: Documentation & Handoff
- **Goal:** Update documentation and close out the feature folder.
- **Steps:**
  - Update relevant docs in `40-FEATURES` and any user-facing guides.
  - Complete `STATUS.md` with outcomes and metrics.
  - Prepare release notes or internal announcement.
- **Success Criteria:** Documentation merged; feature folder ready to move/close.
- **Status:** Pending
