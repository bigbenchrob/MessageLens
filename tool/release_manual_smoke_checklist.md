# MessageLens Manual Release Smoke Checklist

Use this checklist against the real development install before calling a build
release-candidate ready. Record the date, branch, commit, and any failures.

Date:
Branch:
Commit:
Tester:

## Startup And Readiness

- [ ] Launch MessageLens from a closed app state.
- [ ] App opens without a developer panel or manual import requirement.
- [ ] Readiness/status surface reports Messages access available.
- [ ] Readiness/status surface reports AddressBook access available.
- [ ] Readiness/status surface reports imported message data ready.
- [ ] Readiness/status surface reports conversation browsing data ready.
- [ ] Readiness/status surface reports overlay/user settings available.
- [ ] Readiness/status surface reports attachment archive directory available.
- [ ] Retired `macos_import.db` / `working.db` presence does not affect readiness.

Notes:

## Ordinary Browsing

- [ ] Conversations top menu loads conversation signatures.
- [ ] Selecting a conversation opens message evidence.
- [ ] Favourites display consistently where present.
- [ ] Contacts top menu loads the contact picker/sidebar.
- [ ] Known multi-handle contact opens All Messages.
- [ ] Contact heatmap coordinates with the full message range.
- [ ] By Conversation loads that contact's conversations.
- [ ] Specific-handle filter scopes heatmap and message evidence correctly.

Notes:

## Search

- [ ] Contact-scope search finds a known recent term.
- [ ] An unfinished term such as `pos` uses word-prefix matching while it is
      being typed.
- [ ] Completing `post ` with one Space preserves that Space and returns the
      exact token `post`, excluding longer tokens such as `postmaster`.
- [ ] **Match all terms** requires every term and **Match any term** requires
      at least one term across visible message text and tags.
- [ ] Saved-message filtering remains mandatory in both AND and OR modes.
- [ ] Matching terms highlight visibly.
- [ ] Match navigation scrolls to the selected match.
- [ ] Conversation-scope search scopes to matching evidence.
- [ ] Header reports match counts clearly.
- [ ] Global/search-all opens results through the shared message evidence surface.

Notes:

## Live Updates

- [ ] Plain text message appears without pressing manual import.
- [ ] Viewport does not jump when scrolled away from the end.
- [ ] New-message indicator appears when new evidence is waiting.
- [ ] Message with attachment appears after the automatic update cycle.
- [ ] Attachment evidence renders or shows a calm unavailable/pending state.

Notes:

## Attachments And Archive

- [ ] Known archived image preview renders.
- [ ] Known video attachment renders or opens correctly.
- [ ] Known URL/plugin payload preview renders once.
- [ ] Missing/unavailable attachments remain visible as evidence.
- [ ] Graph/status health explains attachment archive readiness without a release-blocking unexplained issue.

Notes:

## Historical Archives

- [ ] Historical Archives opens without developer-only controls in normal mode.
- [ ] Choosing a known historical Messages folder preflights counts and range.
- [ ] Dry run estimates are clear.
- [ ] Safe test import surfaces archive messages through normal evidence views.
- [ ] Removing the imported archive source is idempotent and does not disturb live evidence.

Notes:

## Recovery And Diagnostics

- [ ] Unfamiliar/recovered message surfaces render through shared message evidence.
- [ ] Diagnostic/status panels do not spin indefinitely.
- [ ] Report language explains warnings without graph-migration knowledge.

Notes:

## Build Readiness

- [ ] `tool/release_smoke.sh` passes.
- [ ] Additional focused tests pass for any release area changed after the smoke script was last updated.
- [ ] `flutter build macos` passes when this is a release-candidate build.
- [ ] Bundle id and signing path preserve Full Disk Access continuity.

Notes:

## Outcome

- [ ] Pass
- [ ] Pass with non-blocking notes
- [ ] Blocked

Blocking issues:
