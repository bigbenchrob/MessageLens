CONTACT PICKER — RECENTS / FAVORITES PRECEDENCE & DE-DUPLICATION SPEC

Goal
Ensure the contact picker reflects current conversational relevance without duplication, while preserving the semantic truth of long-term Favorites.

⸻

Core Principle

Contacts may appear in only one picker section at a time.
Section placement reflects temporal relevance first, long-term importance second.

⸻

Section Precedence (Highest → Lowest)
	1.	RECENTS
	•	Contacts with recent message activity.
	•	Represents current relevance.
	•	Takes absolute precedence over all other sections.
	2.	FAVORITES
	•	User-designated long-term important contacts.
	•	Represents baseline access.
	•	Only includes contacts not currently in Recents.
	3.	ALPHABETICAL (A–Z)
	•	All remaining contacts not included above.

⸻

De-duplication Rule (Hard Invariant)
	•	A contact must never appear in more than one section simultaneously.
	•	If a contact qualifies for multiple sections:
	•	It appears only in the highest-precedence section.

Precedence resolution:

```
if inRecents → show in RECENTS
else if isFavorite → show in FAVORITES
else → show in A–Z
```
Semantic Preservation Rule

Favorite status is orthogonal to section placement.
	•	A contact listed under RECENTS may still be a Favorite.
	•	Favorite status must not be lost or hidden when the contact is promoted into RECENTS.

⸻

Favorite Indicator in Non-Favorite Sections

When a Favorite contact appears outside the FAVORITES section (e.g., in RECENTS):
	•	Display a very subtle favorite indicator to preserve semantic truth.
	•	Indicator requirements:
	•	Non-interactive
	•	Visually subordinate to row content
	•	Same muted visual language as the Hero card favorite star
	•	Must not change row weight, ordering, or interaction affordance

Purpose:
	•	Clarify why a Favorite is not currently listed under FAVORITES.
	•	Communicate “temporarily promoted due to recency”.

⸻

Explicit Non-Goals
	•	No duplicate rows across sections.
	•	No category systems.
	•	No color-coded contact types.
	•	No icons that compete with row selection.
	•	No inline favorite toggles in the picker.

⸻

User Mental Model (Authoritative)
	•	RECENTS = who I’m talking to now
	•	FAVORITES = who I usually care about
	•	A–Z = everyone else

Recency outranks favoritism; favoritism is preserved semantically even when not structurally visible.

⸻

One-Line Summary

“Contacts appear in exactly one picker section at a time; Recents outrank Favorites, Favorites outrank alphabetical, and favorite status is preserved even when a contact is temporarily promoted by recency.”