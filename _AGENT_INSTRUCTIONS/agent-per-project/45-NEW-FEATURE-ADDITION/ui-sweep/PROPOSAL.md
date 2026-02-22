# Feature Proposal — UI Sweep

**Branch**: `Ftr.uisweep`  
**Status**: ✅ Approved — proceeding to planning  
**Created**: 2026-02-20  
**Approved**: 2026-02-20

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
- Base spacing unit: **8pt**
- Visual groupings: **16pt**, **24pt**, **32pt** multiples
- All gaps are multiples of the base unit
- Sidebar and content sections share the same rhythm
- One-off spacing values strictly prohibited

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

## Resolved Decisions

1. **Spacing unit**: 8pt base. Visual groupings use 16pt, 24pt, 32pt multiples. No one-offs.

2. **Search area tint**: Subtle background tint (≤2% delta) allowed for interaction mode. Must remain visually continuous with content plane — no borders, elevation, or card semantics.

3. **Cassette structure**: Keep the cassette *flow and logic*, remove the *card chrome*. Styling comes from token roles and structural wrapper context, not per-cassette decisions.

4. **Implementation order**: Sidebar (Plane A) first, then content (Plane B).

---

## Implementation Approach

### Token System

Introduce design tokens to enforce consistency and eliminate ad-hoc styling:

| Token Class | Purpose |
|-------------|---------|
| `AppSpacing` | 8pt base + standard multiples (sm, md, lg, xl) |
| `AppTypography` | Four roles: NavigationTitle, Content, Metadata, Controls |
| `AppColors` | Plane backgrounds, text hierarchy, state colors |
| `AppDividers` | Single divider style for plane separation |

### Structural Wrappers

Create wrapper widgets that own plane-level styling:

| Wrapper | Responsibility |
|---------|----------------|
| `SidebarPlane` | Background, single divider on right edge |
| `ContentPlane` | Single continuous surface for header/search/list |
| `CassetteChrome` | Padding + rhythm + selection states (no card borders) |

### Enforcement Rule

Feature widgets must use tokens exclusively:
- ❌ `Container(color: ...)` — prohibited
- ❌ `EdgeInsets(...)` — prohibited  
- ❌ `TextStyle(...)` — prohibited
- ✅ `AppSpacing.md`, `AppColors.sidebarBg`, `AppTypography.metadata`

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

## Next Steps

1. ✅ Create `PROPOSAL.md` — complete
2. 🔄 Create `DESIGN_NOTES.md` — document token definitions
3. 🔄 Create `CHECKLIST.md` — detailed implementation tasks
4. 🔄 Create `TESTS.md` — visual validation criteria
5. Begin implementation: Sidebar (Plane A) first

---

**Proposal approved. Proceeding to planning phase.**
