# Feature Proposal — UI Sweep

**Branch**: `Ftr.uisweep`  
**Status**: Awaiting approval  
**Created**: 2026-02-20

---

## Goal

Transform the UI from "several independently useful tools sharing a window" into "one coherent reading and exploration experience." The app should feel calm, intentional, and unified — not assembled from parts.

---

## Problem Statement

The current UI communicates visual fragmentation:

1. **Too many surfaces** — Sidebar, sidebar header, center header, search, message list all present as equal-weight panels with visible edges
2. **Separator overload** — Hard dividers between elements that belong together
3. **Inconsistent rhythm** — Locally correct spacing that doesn't follow a global grid
4. **Typography role creep** — Metadata competes with navigation; controls compete with content
5. **Sidebar fragmentation** — Dropdown, contact card, and heatmap feel like stacked widgets rather than one navigational instrument

---

## Proposed Solution

### Surface Model (Two Planes Only)

| Plane | Components | Treatment |
|-------|------------|-----------|
| **A — Navigation** | Sidebar, contact selector, heatmap, filters | Single continuous surface |
| **B — Content** | Header, search, message list | Single canvas, no internal cards |

**One hard divider only**: between Plane A and Plane B (sidebar ↔ content).

### Key Changes

#### 1. Kill Separators
- Remove divider between center header and search
- Remove divider between search and message list
- Replace with consistent vertical spacing

#### 2. Unify Center Column
- Header, search, and messages share one background
- No cards, panels, or inset containers
- Separation via spacing and subtle tint shifts (≤2%) only

#### 3. Establish Vertical Rhythm
- Single spacing unit: **8pt or 12pt** (to be determined)
- All gaps are multiples of this unit
- Sidebar and content sections share the same rhythm

#### 4. Constrain Typography to Four Roles

| Role | Examples | Treatment |
|------|----------|-----------|
| Navigation Titles | Contact names, section headers | Bold, prominent |
| Primary Content | Message bodies | Optimized for reading |
| Metadata | Timestamps, counts | Lighter color (not smaller) |
| Controls | Buttons, filters, toggles | Recedes visually |

#### 5. Sidebar Cohesion
- Single background across entire sidebar
- Identical horizontal padding for all elements
- Left edges perfectly aligned
- Hierarchy via indentation/opacity/size — not boxes

---

## Constraints

From `ui-design-contract.md`:

- No additional visual planes beyond A and B
- No cards or outlines in the content column
- No borders between header/search/messages
- No "one-off" spacing adjustments
- No typography roles beyond the four defined
- All layout must pass Blur Test and Squint Test

---

## Scope

### In Scope
- Sidebar visual unification (background, padding, alignment)
- Center panel surface consolidation (remove separators, unify background)
- Vertical spacing standardization (establish and enforce grid)
- Typography role audit and consolidation
- Heatmap visual integration (embedded feel vs. widget feel)

### Out of Scope (this iteration)
- Functional changes to sidebar or content behavior
- New features or capabilities
- Color palette redesign (current colors are fine, application is the issue)
- Animation or transition work

---

## Open Questions

1. **Spacing unit**: 8pt or 12pt? Need to audit current spacing to determine which aligns better with existing patterns.

2. **Background tints**: What are the exact hex values for:
   - Sidebar background (both light/dark mode)
   - Content column background (both modes)
   - Should search area have a subtle tint shift from message list?

3. **Typography audit**: Need to inventory current text styles to map them to the four roles. Are there styles that don't fit any role?

4. **Heatmap integration**: The heatmap currently has distinct visual treatment. How aggressive should the integration be? (Same background? Reduced padding? Simpler frame?)

5. **Implementation order**: Should we sweep one plane at a time (sidebar first, then content) or work element-by-element across the whole UI?

---

## Success Criteria

1. **Blur Test**: When UI is slightly blurred, only two planes are visible (navigation and content)
2. **Squint Test**: Content dominates, navigation is secondary, controls and metadata recede
3. **Spacing Audit**: All vertical spacing is a multiple of the base unit
4. **Typography Audit**: All text styles map to exactly one of the four roles
5. **Separator Count**: Only one hard divider exists (sidebar ↔ content)

---

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Over-removal of visual cues | Medium | Test each removal in isolation; keep subtle spacing |
| Sidebar elements feel cramped | Low | Maintain current element sizes; only adjust container styling |
| Dark mode inconsistency | Medium | Test every change in both modes |
| Typography changes affect readability | Low | Don't change font sizes; only adjust color/weight hierarchy |

---

## Next Steps (Pending Approval)

1. Create `CHECKLIST.md` with detailed implementation tasks
2. Create `DESIGN_NOTES.md` to document spacing grid and color values
3. Create `TESTS.md` for manual visual validation criteria
4. Begin implementation with sidebar cohesion (Plane A)

---

**Awaiting user approval to proceed to planning phase.**
