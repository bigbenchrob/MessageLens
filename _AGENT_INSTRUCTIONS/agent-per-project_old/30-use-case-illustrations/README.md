# Use Case Illustrations

## Purpose

This directory contains narrative explanations of key user-facing features and their complete implementation chains. Each illustration tells the story of a feature from user intent through database operations, explaining the rationale, design decisions, and technical details that span multiple system layers.

## Why These Illustrations Matter

When examining code, it's easy to see **what** happens (e.g., "this method updates a table") but difficult to understand **why** it happens or how it fits into the broader system. Use case illustrations solve this by:

1. **Explaining Rationale**: Why does this feature exist? What user problem does it solve?
2. **Tracing Impact**: How does one user action ripple through multiple system layers?
3. **Revealing Constraints**: What performance, data consistency, or architectural concerns influenced the design?
4. **Connecting the Dots**: How do seemingly unrelated components (migration, overlay DB, index tables) work together?

Without these narratives, understanding a feature like "manual handle-to-contact linking" would require:
- Finding the UI trigger (right-click menu)
- Following the method chain through providers
- Discovering the overlay database table
- Realizing the migration had to change
- Understanding why the contact_message_index needs partial rebuilding
- Connecting all these pieces into a coherent story

**With** these illustrations, you get the complete story in one place.

## What Makes a Good Use Case Illustration

Each illustration should cover:

- **User Problem**: What pain point or need triggered this feature?
- **Solution Overview**: High-level approach (e.g., "overlay database pattern for user preferences")
- **System Impact**: Which layers/components are affected (migration, providers, UI, databases)?
- **Key Design Decisions**: Why this approach over alternatives? What trade-offs were made?
- **Technical Details**: Database schemas, performance considerations, data flow
- **Cross-References**: Links to implementation docs (PROPOSAL.md, CHECKLIST.md, code files)

## How to Use These Illustrations

**For New Features**: Before implementing, write the use case illustration first. It forces clear thinking about rationale and system impact.

**For Understanding Code**: When you encounter confusing code, find (or write) the relevant use case illustration to understand the bigger picture.

**For Onboarding**: These narratives help new developers (or future you) understand not just the mechanics but the **why** behind architectural decisions.

## Relationship to Other Documentation

- **`20-new-features/`**: Contains detailed PROPOSAL.md and CHECKLIST.md for features under development. Use case illustrations complement these by providing the narrative context.
- **`00-project/architecture-overview.md`**: Describes system layers abstractly. Use case illustrations show how layers interact in concrete scenarios.
- **`05-databases/`**: Documents database schemas. Use case illustrations explain why tables exist and how they're used together.

**Recommendation**: When working on a feature documented in `20-new-features/`, always read the corresponding use case illustration first to understand the full context before diving into implementation checklists.

---

## Available Illustrations

- [Manual Handle-to-Contact Linking](./manual-handle-to-contact-linking.md) - User-assigned handle-participant matching with overlay database persistence
