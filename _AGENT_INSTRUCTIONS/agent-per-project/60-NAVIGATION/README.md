# Navigation Documentation

This folder gathers all guidance for the ViewSpec-driven navigation system. This project standardizes on sealed ViewSpec types, panel view state providers, and feature coordinators to keep navigation declarative, type-safe, and testable.

## Included References
- `navigation-overview.md` — architecture walkthrough of the ViewSpec/PanelCoordinator stack (migrated from the legacy `_old/` tree).
- Additional navigation notes, migration guides, or examples should live alongside this README so future agents immediately know where to look.

## Using This Folder
- Treat `navigation-overview.md` as the canonical architecture description when adopting the navigation pattern in other projects.
- When introducing new ViewSpec variants or panels, update the overview with the rationale and provider wiring.
- Link from feature documentation (e.g., `40-FEATURES`) to relevant sections here to avoid duplicating the navigation description.
