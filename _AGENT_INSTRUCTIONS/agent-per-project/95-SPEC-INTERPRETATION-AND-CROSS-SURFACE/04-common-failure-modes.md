# Common Failure Modes

This document lists recurring mistakes and how to detect and fix them.

---

## 1) App-level coordinator learns feature semantics

Symptoms:
- System coordinator switches on inner spec variants.
- System coordinator formats feature-specific text.

Fix:
- Move logic into feature spec cases/resolvers.
- Leave app-level coordinator as routing-only.

---

## 2) Coordinator calls `ref.watch()`

Symptoms:
- Coordinator rebuilds on provider changes.
- Async meaning resolution is mixed into reactive rebuilds.

Fix:
- Replace `watch` with `read` in coordinators.
- Move reactive data usage into child widgets.

---

## 3) Chrome decisions happen inside features

Symptoms:
- Features decide card type, chrome, or layout style.
- App-level coordinator infers chrome by widget type.

Fix:
- Return a neutral view model or payload.
- Let the app-level coordinator choose chrome.

---

## 4) Spec explosion to encode UI choices

Symptoms:
- New spec variants exist only to tweak padding or card shape.

Fix:
- Keep specs semantic and high-level.
- Put UI policy in app-level coordinators.

---

## 5) Cross-surface logic duplicated

Symptoms:
- Same explanatory text appears in multiple features/surfaces with drift.

Fix:
- Introduce feature-local content keys.
- Centralize meaning in a content resolver.

---

## 6) Feature leakage across systems

Symptoms:
- One feature queries another feature's repositories.
- Feature code reaches into `essentials/<system>/` internals.

Fix:
- Route by feature and use feature-level providers only.
- Use the system's public payload types.

---

## Hard rules (violations are regressions)

- Essentials routes by feature only; it never interprets inner specs.
- Coordinators do not call `ref.watch()`.
- Chrome decisions are finalized before returning the view model.
- Features interpret meaning; app-level coordinators compose UI.
- Do not merge onboarding/tooltips into cassette specs.
