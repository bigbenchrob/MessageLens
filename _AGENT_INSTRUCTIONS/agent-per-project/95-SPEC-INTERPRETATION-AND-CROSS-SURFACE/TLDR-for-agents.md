# TLDR - Spec Interpretation and Cross-Surface Systems

Short rules for agents working with spec-driven systems.

---

## Canonical flow (do not break)

Spec
-> Feature coordinator (routing only)
-> Application-layer resolver / case handler
-> View model or content payload
-> App-level coordinator chooses chrome
-> Presentation widgets render UI

---

## Hard rules

- Essentials routes by feature only and never interprets inner specs.
- Coordinators do not call `ref.watch()`.
- Chrome decisions are finalized before returning the view model.
- Features interpret meaning; app-level coordinators compose UI.
- Do not merge onboarding/tooltips into cassette specs.

---

## Role summary

- `spec_coordinators`: routing only
- `spec_cases` / resolvers: meaning + data + async
- `spec_widget_builders`: widget assembly only
- presentation widgets: reactive rendering only

---

## Namespacing rules

- Provider names may be generic within a feature.
- Always import feature providers with an alias.
- Use `features/<feature>/feature_level_providers.dart` as the only entry point.

---

## Red flags checklist

- coordinator uses `ref.watch()`
- app-level coordinator switches on inner spec variants
- spec variant added just to express padding or chrome
- feature code decides card type or layout style
- onboarding/tooltips implemented as cassette variants

---

## If unsure, ask

1) Is this interpreting feature meaning? -> spec case / resolver
2) Is this just routing a spec? -> feature coordinator
3) Is this choosing chrome or layout? -> app-level coordinator
4) Is this drawing pixels or reacting to providers? -> presentation widget
