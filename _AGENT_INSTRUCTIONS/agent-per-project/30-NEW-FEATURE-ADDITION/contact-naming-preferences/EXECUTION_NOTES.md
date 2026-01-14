---
tier: project
scope: execution-notes
author: GitHub Copilot (GPT-5-Codex Preview)
created: 2026-01-07
status: draft
links:
  - PROPOSAL.md
  - CHECKLIST.md
---

# Contact Naming Preferences – Execution Notes Log

Use this living document to capture discoveries, decisions, blockers, and follow-up tasks while working through the checklist. Keep entries chronological and include timestamps for traceability.

## Template for Log Entries
```
## [YYYY-MM-DD] Stage X – <stage name>
- Summary: <short description of progress>
- Decisions: <bullet list of confirmed decisions>
- Open Questions: <bullet list>
- Blockers/Risks: <bullet list>
- Next Actions: <who / what / when>
```

## Active Threads
- ## [2026-01-07] Stage 0 – Kickoff Alignment
- Summary: Confirmed storage, visibility, and undo expectations for naming preferences.
- Decisions:
  - Persist global naming defaults and per-contact overrides exclusively in the overlay database layer.
  - Keep override reviews contextual; no aggregate list of contacts with overrides in Settings.
  - Skip dedicated undo/redo mechanics; rely on direct edits for reversibility.
- Open Questions:
  - None at this stage.
- Blockers/Risks:
  - Future backup strategy for overlay DB still to be defined (outside current scope).
- Next Actions:
  - Begin Stage 1 data/provider audit planning per checklist.

## [2026-01-07] Stage 1 – Data & Provider Readiness (Implementation)
- Summary: Added overlay database helpers and generated providers for the global contact naming preference; awaiting review before proceeding to Stage 2.
- Decisions (reaffirmed):
  - Persist the default name mode under the overlay settings key `contacts.name_mode.default` via dedicated helpers.
  - Surface the preference through `contact_name_mode_provider.dart`, re-exported from `feature_level_providers.dart` for cross-feature access.
- Implementation Highlights:
  - Added `_defaultParticipantNameModeKey` plus `getDefaultParticipantNameMode` / `setDefaultParticipantNameMode` helpers to `OverlayDatabase` using `insertOnConflictUpdate` for idempotent writes.
  - Created async read + command providers that wrap the overlay helpers and handle invalidation after updates.
  - Ensured other features can only access the provider through the contacts feature boundary.
- Open Questions:
  - None for Stage 1; pending confirmation that fallback copy remains local to the settings cassette.
- Blockers/Risks:
  - None currently; invalidation occurs in the setter provider.
- Next Actions:
  - Pause for Stage 1 approval per checklist, then begin Stage 2 planning once accepted.

## [2026-01-07] Stage 2 – Settings Sidebar Enhancements (Planning)
- Summary: Outline UI/state changes needed to wire the Settings cassette to the new provider while aligning with macOS sidebar styling. Settings sidebar now starts with a dropdown-style top menu (single "Contacts" option) that immediately cascades to the contact naming cassette; the old list-style card has been removed.
- Observations:
  - `ContactShortNamesSettingsCassette` currently renders static option rows; we need interactive radio controls bound to the provider state.
  - Sidebar cassette cards expect lightweight widgets; reuse existing typography/colors and maintain spacing conventions.
- Decisions / Plan:
  1. **UI Structure**: Replace static `_OptionRow` widgets with a reusable radio-list component (`_NameModeOption`) that:
     - Reads the async `contactNameModeProvider` via `ref.watch` and handles loading/error states (e.g., spinner or inline message).
     - Displays three options (First name only, First initial + last name, Nickname when available) with copy updated to “How names are shown”.
  2. **State Flow**: On selection, call `setContactNameModeProvider(mode)`; disable interaction while mutation in progress and display subtle status (optional toast/log).
  3. **File Impact**:
     - Update `presentation/cassettes/settings/contact_short_names_settings_cassette.dart` for interactive UI and provider wiring.
     - Introduce small helper widget within the same file (no new files) to avoid scattering logic.
     - Ensure imports reference `contacts.feature_level_providers.dart` rather than reaching directly into application folders.
  4. **Copy & Helper Text**: Adjust headings to “How names are shown” with helper “Applies to contacts without custom settings.”; keep caption on nickname fallback if space allows.
- Open Questions:
  - Confirm whether we should surface a short inline success state after updates or rely on silent updates (leaning silent for now).
- Blockers/Risks:
  - Need to ensure cassette remains performant with async provider; consider `AsyncValueWidget` pattern to avoid rebuild jitter.
- Next Actions:
  - Prepare Stage 2 implementation once plan is approved (update cassette, add loading/error handling, integrate provider calls).

## Parking Lot / Future Considerations
- Capture ideas that fall outside current scope (e.g., override list UI, undo/redo support, telemetry enhancements).

## Communication Protocol
- Update this log before each “pause for review”.
- Reference specific checklist items when noting progress or issues.
- Highlight items needing user feedback with `**Needs Approval**` or `**Needs Clarification**` tags.
