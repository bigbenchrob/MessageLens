# Remember This Text — UI Design Contract

This document defines the **non-negotiable visual and structural rules** for the Remember This Text application.  
All UI work must conform to this contract. Deviations require explicit justification.

---

## 1. Core Design Intent

The application must feel like:

> A calm, intentional reading and exploration environment  
> — not a collection of widgets or tools.

The UI should communicate:
- coherence over cleverness
- restraint over decoration
- reading comfort over feature visibility

---

## 2. Surface Model (Critical)

The entire app is composed of **exactly two visual planes**:

### Plane A — Navigation
Includes:
- Sidebar
- Contact selector
- Heatmap
- Navigation filters

### Plane B — Content
Includes:
- Header
- Search
- Message list

**Rules**
- No additional visual planes may be introduced.
- No cards, outlines, or boxed widgets inside Plane B.
- Plane B must read as *one continuous canvas*.

There is **one and only one hard divider**:
- Between Plane A (sidebar) and Plane B (content).

All other separation is achieved through spacing, alignment, and typography.

---

## 3. Borders & Separators

### Prohibited
- Borders between header and search
- Borders between search and message list
- Card outlines in the main content area
- Divider lines used as layout crutches

### Permitted
- Single vertical divider between sidebar and content
- Extremely subtle separators only if spacing alone fails

**Rule of thumb**  
If two elements belong to the same plane, they must not be separated by a line.

---

## 4. Vertical Rhythm & Spacing

The UI must adhere to a **single vertical spacing unit** (8pt or 12pt).

### Rules
- All vertical spacing is a multiple of the base unit.
- Header → Search gap equals Search → Message List gap.
- Sidebar sections use the same vertical rhythm as content sections.
- No “one-off” spacing adjustments are allowed.

Whitespace is the primary layout mechanism.

---

## 5. Typography Roles (Strictly Limited)

Only **four text roles** may exist in the app:

1. **Navigation Titles**
   - Contact names
   - Section headers
   - Primary anchors

2. **Primary Content**
   - Message bodies
   - Long-form readable text

3. **Metadata**
   - Timestamps
   - Counts
   - IDs
   - Secondary annotations

4. **Controls**
   - Buttons
   - Filters
   - Toggles
   - Search affordances

### Rules
- Metadata is *lighter*, not smaller.
- Primary content optimizes for readability:
  - generous line height
  - stable column width
- Controls must never visually compete with content.

No additional text styles may be introduced.

---

## 6. Sidebar Cohesion

The sidebar must read as **one navigational instrument**, not stacked widgets.

### Rules
- Single background across the entire sidebar.
- Identical horizontal padding for:
  - dropdowns
  - contact items
  - heatmap
  - labels
- Left edges align perfectly.
- Hierarchy is expressed via:
  - indentation
  - opacity
  - size
—not boxes or cards.

The heatmap must feel *embedded*, not bolted on.

---

## 7. Content Column Composition

The center column (Plane B) must behave as a **reading surface**.

### Rules
- Header, search, and messages share one background.
- No cards, panels, or inset containers.
- Separation is achieved with:
  - vertical spacing
  - subtle background tint shifts (≤2%) if required
- Message list is visually dominant.
- UI chrome recedes.

This is not a dashboard. It is a reader.

---

## 8. Visual Hierarchy Tests

Every layout must pass the following tests:

### Blur Test
If the UI is slightly blurred:
- The two planes must still be obvious.
- The reading flow must remain legible.
- No accidental focal points appear.

### Squint Test
When squinting:
- Content > navigation > controls
- Metadata never pulls focus
- No equal-weight blocks compete

If the eye doesn’t know where to rest, the design has failed.

---

## 9. Prohibited Patterns

The following are explicitly disallowed:
- Card-based layouts in the content column
- Decorative separators
- Widget-level theming
- Inconsistent padding
- Locally “clever” styling that breaks global rhythm

Consistency beats novelty.

---

## 10. Guiding Principle

> Fewer surfaces.  
> Stronger rhythm.  
> Calmer typography.

When in doubt:
- remove before adding
- align before decorating
- simplify before optimizing

This contract governs all future UI work.