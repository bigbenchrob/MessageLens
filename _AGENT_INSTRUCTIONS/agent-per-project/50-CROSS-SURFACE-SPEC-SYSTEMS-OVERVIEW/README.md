# 50 — Cross-Surface Spec Systems Overview

High-level architecture for how sealed spec classes coordinate UI content
across all app surfaces: sidebar, center panel, right panel, tooltips.

## The Big Picture

This app has multiple UI surfaces that each display a mix of content from
different features. Rather than each surface inventing its own wiring, all
surfaces follow a **shared architectural pattern**:

1. A **sealed spec class** describes what should appear
2. **Surface state** (rack, panel stack…) holds the current specs
3. An **app-level coordinator** iterates specs and routes to features
4. **Feature coordinators** interpret specs and produce surface-appropriate payloads
5. The app-level coordinator applies **chrome/layout** and renders

## Documents

| File | Purpose |
|---|---|
| [00-cross-surface-spec-system.md](00-cross-surface-spec-system.md) | Architecture: surfaces, two-level specs, state models, dispatch, design principles |
| [INVIOLATE_RULES.md](INVIOLATE_RULES.md) | Non-negotiable rules that apply across ALL surfaces |

## Drill-Down Folders

| Folder | Scope |
|---|---|
| [52 — Feature Handling](../52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/) | How features process specs (coordinator → resolver → widget_builder) |
| [54 — Sidebar Cassette System](../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/) | CassetteSpec, rack state, cascade, card chrome |
| [56 — View Spec Panel System](../56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/) | ViewSpec, PanelStack, panel coordinator, feature dispatch |


