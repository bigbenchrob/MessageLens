# 52 — Feature Handling of X-Surface Specs

How a feature receives, interprets, and renders a spec from **any** UI surface.

This folder documents the **universal pattern** shared by all spec types:
sidebar cassettes, view specs (panel content), tooltips (future), settings sidebar (future).

## Key Concept

Every UI surface dispatches specs to features using the same structural flow:

```
App-level coordinator → Feature coordinator → Resolver → Widget builder
```

Features own everything from the coordinator inward.
The app-level coordinator owns chrome and layout.

## Documents

| File | Purpose |
|---|---|
| [00-universal-spec-handling-pattern.md](00-universal-spec-handling-pattern.md) | The canonical flow, 4-folder structure, barrel rules, contracts per surface |
| [INVIOLATE_RULES.md](INVIOLATE_RULES.md) | Non-negotiable rules — read before writing any spec-handling code |

## Surface-Specific Detail

This folder defines the **shared pattern**. For surface-specific architecture:

- **Sidebar cassettes** → [`54-SIDEBAR-CASSETTE-SPEC-SYSTEM/`](../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/)
- **View spec / panel content** → [`56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/`](../56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/)


