# Agent Instruction: Info Card With Escape Action Pattern

## Purpose
Implement a reusable **Info Card With Escape Action** pattern for sidebar cassettes.  
This pattern explains a scoped/selected state and provides a **single, lightweight escape hatch** to return to the prior state—without competing with identity (Hero) or content cassettes.

---

## When to Use
Use this pattern when:
- The sidebar is in a **constrained state** (e.g., contact selected, filter applied, scope chosen).
- A short explanation of the state is helpful.
- There is a natural **undo / change selection** action that returns to a previous state.

Examples:
- Contact selected → “‹ Change contact…”
- Filter applied → “Clear filter”
- Scoped view → “Exit scoped view”

---

## When NOT to Use
Do NOT use this pattern when:
- The action changes settings (use Settings patterns).
- Multiple actions are required (use a control cassette / toolbar).
- The action edits the selected entity’s attributes (belongs in Hero).
- The action is a primary CTA (belongs elsewhere).

---

## Structure (Single Card)
**One Info cassette card surface** with two regions:

1. **Info Body**
   - Brief explanatory text (typically 1–3 lines).
   - May include a short hint (e.g., “Click the name to edit…”).

2. **Escape Action Slot (Optional)**
   - Hosts exactly **one** action.
   - Semantics: “undo this state / go back”.
   - Visually subordinate to the info body.
   - Rendered **inside the same card surface**.

**Constraint:** Maximum of **one** escape action.

---

## Visual & Typography Rules

### Info Body
- Use standard Info card body text style.

### Escape Action
- **Font size:** Same as info body.
- **Weight:** Same or slightly lighter than body (never heavier).
- **Color (rest):** One step lower contrast than info body.
- **Color (hover/focus):** Interactive-muted (NOT saturated accent).
- **Underline:** Optional on hover; keep subtle if used.
- **Icon:** Optional leading chevron (e.g., “‹”); icon slightly lighter than text at rest.

### Spacing
- Add a small semantic break between body and action:
  - Slightly more than normal line spacing.
  - Significantly less than spacing between cassettes.
- No divider line between body and action.

---

## Interaction Spec
- Entire action row is clickable (generous hit target).
- Hover:
  - Text shifts to interactive-muted.
  - Optional underline OR subtle hint (avoid stacking signals).
  - Cursor becomes pointer.
- Focus:
  - Mirrors hover (keyboard accessible).
- Click:
  - Triggers transition back to the prior state (e.g., reopen picker, clear selection).

---

## Semantic Ownership Rule
**Escape actions belong inside the explanation of the state they escape from.**  
They must not:
- Appear in the Hero card.
- Duplicate identity information.
- Compete with content cassettes.

---

## Cassette System Contract

### Info Cassette
- Owns the card surface and explanatory message.
- Exposes an optional `escapeActionSlot`.

### Escape Action Content
- May reuse an existing navigation/link widget.
- Must adopt Info card context:
  - No separate card chrome.
  - No elevation.
  - No borders or shadows.
- Hosted by the Info card; **not** a peer cassette.

---

## Example: Contact Selected
- Top menu: “Messages from contacts”
- Info card body: “Showing messages and activity for the selected contact…”
- Escape action: “‹ Change contact…”
- Hero card: Selected contact identity + rename affordance
- Content: Heatmap, stats, etc.

---

## PR Checklist
- [ ] Escape action present only when a reversible scoped state exists
- [ ] Escape action count ≤ 1
- [ ] No identity duplication in escape action
- [ ] Escape action typography matches body size, lower contrast
- [ ] Body/action spacing is a small semantic break
- [ ] Hover/focus indicates clickability without saturated accent
- [ ] Hero card contains identity + entity edits only

---

## One-Line Summary
“The Info Card may host a single, optional escape action that undoes the state it explains—rendered inside the same surface, visually subordinate, and never competing with identity or content.”