# Phase 2 — Checklist

## Sidebar Cassette
- [ ] Define `StrayHandlesSpec` in cassette spec system
- [ ] Create stray handles cassette coordinator
- [ ] Create sidebar list widget (handle rows with count + date)
- [ ] Wire `strayHandlesProvider` to sidebar list
- [ ] Implement sort: message count desc, recency tiebreak
- [ ] Visual muting for reviewed-but-unlinked handles
- [ ] Register cassette in sidebar navigation

## Handle Lens — Center Panel
- [ ] Define `HandleLensSpec` ViewSpec
- [ ] Create Handle Lens coordinator
- [ ] Create Handle Lens widget layout (header + actions + message list)
- [ ] Implement message list (timestamp + body, newest first)
- [ ] Implement lazy loading / pagination for message list
- [ ] Wire sidebar tap → center panel navigation

## Action: Create Contact
- [ ] Inline mini-form widget (name field)
- [ ] Create virtual participant on submit
- [ ] Write handle override linking to virtual participant
- [ ] Navigate to new contact's standard view
- [ ] Verify strayHandlesProvider invalidates

## Action: Link to Existing Contact
- [ ] Open standard contact picker on button tap
- [ ] Write handle override on selection
- [ ] Navigate to selected contact's standard view
- [ ] Verify strayHandlesProvider invalidates

## Action: Dismiss / Skip
- [ ] Set reviewed_at on handle override row
- [ ] Return focus to sidebar list
- [ ] Verify handle is visually muted in list

## Integration
- [ ] Full flow: browse → identify → create contact → see messages
- [ ] Full flow: browse → identify → link existing → see messages
- [ ] Full flow: browse → dismiss → handle muted
- [ ] All Phase 1 tests still pass
- [ ] `flutter analyze` clean
