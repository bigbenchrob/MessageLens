# Tests: Contacts Feature Cross-Surface Cleanup

**Branch**: `Ftr.cntct-audit`  
**Last Updated**: 2026-02-03

---

## Test Strategy

This cleanup is primarily a refactoring effort. Testing focuses on:
1. **No regression** — Existing functionality must continue to work
2. **Analyzer compliance** — All changes pass `flutter analyze`
3. **Build success** — Code generation succeeds

---

## Automated Tests

### Pre-Cleanup Baseline

Run before making changes to establish baseline:

```bash
flutter test test/features/contacts/
flutter analyze
```

- [ ] Record test count and pass rate
- [ ] Note any existing failures

### Post-Cleanup Verification

Run after each phase to catch regressions:

```bash
flutter test test/features/contacts/
flutter analyze
```

- [ ] Same or better pass rate
- [ ] No new analyzer warnings

---

## Manual Test Cases

### TC-1: Contact Chooser — Few Contacts (< 6)

**Precondition**: Database has fewer than 6 contacts

| Step | Action | Expected |
|------|--------|----------|
| 1 | Navigate to Messages mode | Sidebar shows |
| 2 | Observe contact chooser cassette | Flat menu displayed |
| 3 | If recent contacts exist | Recent contacts section at top |
| 4 | Click a contact | Hero summary appears, messages in center |

- [ ] PASS / FAIL

### TC-2: Contact Chooser — Many Contacts (≥ 6)

**Precondition**: Database has 6 or more contacts

| Step | Action | Expected |
|------|--------|----------|
| 1 | Navigate to Messages mode | Sidebar shows |
| 2 | Observe contact chooser cassette | Grouped/alphabetical picker displayed |
| 3 | If recent contacts exist | Recent contacts section at top |
| 4 | Click a contact | Hero summary appears, messages in center |
| 5 | Scroll through picker | Alphabetical grouping visible |

- [ ] PASS / FAIL

### TC-3: Recent Contacts Section

**Precondition**: User has previously selected contacts

| Step | Action | Expected |
|------|--------|----------|
| 1 | Navigate to Messages mode | Sidebar shows |
| 2 | Observe contact chooser | Recent contacts at top |
| 3 | Click recent contact | Hero summary appears |
| 4 | Select different contact | Previous is tracked as recent |

- [ ] PASS / FAIL

### TC-4: Contact Hero Summary

| Step | Action | Expected |
|------|--------|----------|
| 1 | Select a contact | Hero summary cassette appears |
| 2 | Verify name displayed | Contact name visible |
| 3 | Verify metrics | Message count, date range, etc. |
| 4 | Click back/different contact | Hero summary updates |

- [ ] PASS / FAIL

### TC-5: Contact Short Names Settings

| Step | Action | Expected |
|------|--------|----------|
| 1 | Navigate to Settings mode | Settings sidebar shows |
| 2 | Select Contacts settings | Short names option visible |
| 3 | Toggle short names setting | Setting persists |
| 4 | Navigate to Messages | Contact names reflect setting |

- [ ] PASS / FAIL

### TC-6: Info Cassette

| Step | Action | Expected |
|------|--------|----------|
| 1 | Trigger info cassette display | Info card appears |
| 2 | Verify content | Title, body, footnote display correctly |

- [ ] PASS / FAIL

---

## Regression Checklist

After cleanup is complete:

- [ ] No new warnings from `flutter analyze`
- [ ] No new test failures
- [ ] All manual test cases pass
- [ ] Contact chooser still shows recent contacts
- [ ] Flat/grouped switching still works
- [ ] Hero summary still displays correctly
- [ ] Settings still work

---

## Coverage Notes

Areas with limited test coverage that need careful manual testing:
1. Recent contacts tracking (database interaction)
2. Picker mode threshold switching (6 contact boundary)
3. Settings persistence across app restarts
