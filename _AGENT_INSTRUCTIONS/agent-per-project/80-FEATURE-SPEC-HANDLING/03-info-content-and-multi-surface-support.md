# Info Content and Multi-Surface Support

This document explains how **feature-owned informational content** (help text,
definitions, guidance) is handled in a way that supports **multiple UI surfaces**
without duplicating logic.

Examples of such surfaces include:

- Sidebar informational cassettes
- Tooltips
- Onboarding overlays
- Inspector or inline help

---

## The Core Insight

Informational text is a **content domain**, not a UI concern.

The same explanation may need to appear:

- as a sidebar info card
- as a tooltip
- as onboarding guidance
- in a help panel

If informational logic is embedded in surface-specific code, duplication and
inconsistency become inevitable.

---

## Feature-Owned Keys

Each feature defines its own set of informational keys.
There is no global registry.

Examples:

Handles feature:

- definition of stray email address handles
- definition of stray phone number handles

Contacts feature:

- explanation of favourites vs recents
- explanation of contact grouping rules

Keys are feature-local enums.

They express *what needs explaining*, not *where it will appear*.

---

## Content Resolvers

Each feature exposes a **content resolver** responsible for mapping keys to
resolved informational content.

Responsibilities:

- Own the semantic meaning of each key
- Query repositories if necessary
- Compute derived values
- Format feature-specific explanatory text
- Return surface-agnostic content

The resolver is the **single source of truth** for informational meaning.

---

## Surface-Agnostic Content

Content resolvers return a neutral payload that does not assume a specific UI
surface.

Typical content fields include:

- optional title
- body text
- optional actions or links

This payload expresses *what is being communicated*, not *how it is displayed*.

---

## Surface Renderers

Each UI surface provides its own renderer that converts resolved content into UI.

Examples:

- Sidebar renderer → produces a sidebar cassette view model
- Tooltip renderer → produces a tooltip widget
- Onboarding renderer → produces an overlay widget

Surface renderers:

- do not interpret keys
- do not query repositories
- do not contain feature logic

They apply **presentation policy** appropriate to the surface.

---

## Sidebar Info Cassettes as One Surface

Sidebar info cards are simply one consumer of informational content.

Flow:

- Sidebar coordinator routes an info-related spec
- Feature content resolver returns informational content
- Sidebar surface renderer wraps it in appropriate chrome
- Cassette widget coordinator inserts the result into the stack

The same content may later be reused unchanged by other surfaces.

---

## Avoiding Duplication

This structure avoids:

- duplicated pattern matching across surfaces
- duplicated explanatory text
- inconsistent wording between sidebar and tooltip
- feature logic leaking into UI code

All interpretation lives in one place: the feature’s content resolver.

---

## Key Principle

Features own **what information means**.

UI surfaces own **how that information is presented**.