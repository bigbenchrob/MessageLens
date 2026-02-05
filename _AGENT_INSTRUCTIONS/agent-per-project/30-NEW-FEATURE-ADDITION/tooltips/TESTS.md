# Tooltips System - Test Plan

**Last Updated:** 2026-02-04

---

## Unit Tests

### TooltipCoordinator Tests
Location: `test/essentials/tooltips/application/tooltip_coordinator_test.dart`

| Test | Description | Status |
|------|-------------|--------|
| Routes contacts spec to contacts coordinator | Verify spec.contacts routes correctly | ⬜ Not started |
| Returns resolved content | Verify string content returned | ⬜ Not started |

### ContactsTooltipResolver Tests
Location: `test/features/contacts/application/tooltips_spec/resolvers/contacts_tooltip_resolver_test.dart`

| Test | Description | Status |
|------|-------------|--------|
| Resolves editDisplayName key | Returns "Edit display name" | ⬜ Not started |
| Future keys resolve correctly | As more keys added | ⬜ Not started |

---

## Widget Tests

### TooltipWrapper Tests
Location: `test/essentials/tooltips/presentation/tooltip_wrapper_test.dart`

| Test | Description | Status |
|------|-------------|--------|
| Shows tooltip on hover after delay | Mouse enter triggers tooltip | ⬜ Not started |
| Hides tooltip on mouse exit | Mouse leave hides tooltip | ⬜ Not started |
| Child widget receives taps | Click passes through to child | ⬜ Not started |
| No tooltip without hover | Tooltip not visible initially | ⬜ Not started |

---

## Integration Tests

### Hero Card Edit Icon
Location: `test/features/contacts/presentation/widgets/contact_highlight_row_test.dart`

| Test | Description | Status |
|------|-------------|--------|
| Edit icon visible | Pencil icon renders in hero card | ⬜ Not started |
| Tooltip appears on hover | "Edit display name" tooltip shows | ⬜ Not started |
| Icon click opens dialog | Edit dialog appears on tap | ⬜ Not started |

---

## Manual Verification Checklist

### Visual Appearance
- [x] Tooltip has readable styling (Flutter default)
- [x] Text is readable in light mode
- [x] Text is readable in dark mode
- [x] Tooltip doesn't cover the target element
- [x] Tooltip positions above target by default

### Timing Behavior
- [x] Tooltip appears after appropriate delay (~500ms)
- [x] No flicker on rapid mouse movement
- [x] Tooltip disappears immediately on mouse leave
- [x] Tooltip disappears when clicking the icon

### Edge Cases
- [x] Tooltip near edges positions correctly (Flutter auto-handles)
- [x] Multiple tooltips don't stack (only one visible at a time)

### State Interactions
- [x] Tooltip disappears when dialog opens
- [x] Tooltip reappears on subsequent hovers after dialog closes
- [x] Switching contacts doesn't leave stale tooltips

---

## Accessibility Testing

- [ ] Tooltip content available to screen readers (future enhancement)
- [ ] Keyboard navigation can trigger tooltip (future enhancement)

---

## Performance Testing

- [ ] No perceptible lag when tooltip appears
- [ ] No memory leaks from repeated hover in/out
- [ ] Tooltip doesn't block UI thread

---

## Test Results Log

| Date | Tester | Phase | Pass/Fail | Notes |
|------|--------|-------|-----------|-------|
| 2026-02-04 | User | Manual | ✅ Pass | All manual verification passed |

---

## Known Issues

(To be populated during testing)

| Issue | Severity | Status | Resolution |
|-------|----------|--------|------------|
| | | | |
