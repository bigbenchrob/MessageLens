---
tier: project
scope: cassettes
owner: agent-per-project
last_reviewed: 2026-01-08
source_of_truth: doc
links:
  - ../README.md
  - ./00-cassette-choice-flow-and-responsibilities.md
tests: []
---

## TL;DR — Cassette Card Rules (Read This First)

**These rules are non-negotiable.**

1. **Hierarchy has exactly one owner**
   - The **cassette wrapper** owns all titles, subtitles, section labels, spacing, and emphasis.
   - Feature content must be **body-only**.

2. **Feature code must NOT render**
   - Titles
   - Subtitles
   - Section headers
   - Footer / explanatory paragraphs

3. **A cassette is a semantic scaffold, not a generic card**
   - Use named slots: `title`, `subtitle`, `sectionTitle`, `body`, `footerText`
   - Do **not** pass arbitrary children that invent hierarchy.

4. **Subtitle and footer are the same semantic class**
   - Both are quiet explanatory text
   - Both should use the same (or nearly the same) style
   - Neither should compete with the title or section label

5. **Visual hierarchy order must be obvious at a glance**
   1. Title (strongest)
   2. Section label (decision framing)
   3. Controls (primary interaction)
   4. Subtitle / footer (quiet context)

6. **Spacing communicates meaning**
   - Small gaps within a concept
   - Large gaps between conceptual layers
   - Use ~22px between subtitle and section label

7. **If a card feels flat or busy**
   - Hierarchy is being defined in more than one place
   - Stop and fix the contract before adjusting styles

**If a change violates any rule above, it is incorrect even if it “looks okay.”**

# Cassette Card Design Guidelines

This document defines the architectural and visual design rules for **cassette cards** used in the sidebar settings system.

Its purpose is to prevent visual entropy, duplicated hierarchy, and ad-hoc styling as new cassettes and features are added—especially when work is shared between humans and AI agents.

---

## 1. Core Principle: Single Owner of Hierarchy

**A cassette card must have exactly one owner of visual hierarchy.**

- The **card wrapper** owns all typography, spacing, and emphasis.
- The **feature content** provides body-only UI and must not introduce headings, subtitles, or footers.

If hierarchy is expressed in more than one layer, the result will always feel flat or visually confused.

> If both wrapper and feature attempt to express hierarchy, the design is already broken.

---

## 2. Cassette ≠ Generic Card

A cassette is **not** a generic “card with a child widget”.

A cassette is a **semantic layout scaffold** with named regions:

1. **Title** – identifies what the setting is
2. **Subtitle** – quiet explanatory context
3. **Section label** – introduces a decision
4. **Body** – interactive controls (feature-owned)
5. **Footer** – quiet reassurance or clarification

### Implication

The wrapper must expose **slots**, not just a `child`:

- `title`
- `subtitle`
- `sectionTitle`
- `body`
- `footerText`

Only `body` is provided as a widget by the feature.

---

## 3. Responsibilities by Layer

### SidebarCassetteCard (Wrapper)

Owns:
- Typography tokens
- Color emphasis
- Vertical rhythm / spacing
- Visual hierarchy
- Card chrome (background, border, radius, shadow)

Renders:
- Title
- Subtitle
- Section label(s)
- Footer text

### Feature Cassette (Content)

Owns:
- Interactive controls
- Control grouping
- Option-specific helper text *within* controls

Must **not** render:
- Titles
- Subtitles
- Section headers
- Footer/helper paragraphs

If feature code “needs a heading”, that heading belongs in the wrapper.

---

## 4. Visual Hierarchy Rules

### 4.1 Title

- Strongest visual element in the card
- Uses **primary text color**
- Heavier font weight (e.g. `w700`)
- Establishes identity, not action

### 4.2 Subtitle

- Explanatory, not navigational
- Must not compete with the title or section label
- Styled the same as (or very close to) footer text

**Subtitle and footer are the same semantic class: quiet context.**

### 4.3 Section Label

- Introduces a decision
- Stronger than subtitle/footer
- Weaker than title
- Often caption-sized, secondary color, bold

### 4.4 Body (Controls)

- Visual center of gravity
- Should feel like “the thing to interact with”
- Controls should be visually grouped (indentation or soft background)

### 4.5 Footer

- Reassurance or clarification
- Least prominent element
- Styled the same as subtitle

---

## 5. Spacing & Rhythm

Hierarchy is communicated as much by **spacing** as by typography.

Recommended vertical rhythm:

- Title → Subtitle: tight (≈ 6–8 px)
- Subtitle → Section label: **semantic break** (≈ 22 px)
- Section label → Controls: medium (≈ 8–10 px)
- Controls → Footer: medium (≈ 12 px)

Key rule:

> Use larger gaps between conceptual layers, smaller gaps within them.

Avoid uniform spacing everywhere.

---

## 6. Control Grouping

When presenting multiple related controls (e.g. radio buttons):

- Group them visually
- Avoid heavy borders
- The group should read as *one decision*, not multiple unrelated items

Option-specific helper text (e.g. under “Nickname”) is allowed inside the body, but must remain visually subordinate to the option label.

---

## 7. Typography Token Guidance

Avoid using typography tokens whose semantic intent does not match the role:

- ❌ `vizInstruction` for card titles
- ❌ Multiple heading-sized styles in one card

Preferred mapping:

- **Title** → body-sized text, primary color, heavy weight
- **Section label** → caption-sized, secondary color, bold
- **Subtitle / Footer** → caption-sized, tertiary color

Consistency matters more than exact font sizes.

---

## 8. Diagnostic Checklist

If a cassette card feels “flat”, “busy”, or “confusing”, check:

- Are title and subtitle rendered in more than one place?
- Is explanatory text competing with headings?
- Does feature content define its own hierarchy?
- Are spacing jumps too uniform?

If any answer is “yes”, the cassette contract has been violated.

---

## 9. Design Goal (North Star)

A well-designed cassette card should:

- Be understandable at a glance
- Draw the eye first to the decision
- Allow explanatory text to be ignored unless needed
- Feel calm, native, and inevitable

If the final design looks “obvious”, it is correct.

---

## 10. Summary

**Do this**
- Centralize hierarchy in the wrapper
- Use slots, not arbitrary children
- Treat subtitle and footer as the same semantic layer
- Use spacing to signal meaning

**Avoid this**
- Duplicate headings
- Feature-defined titles
- Uniform spacing everywhere
- Typography tokens that don’t match intent

This system is what allows cassette cards to scale without visual entropy.